#define _XOPEN_SOURCE 700
#include "book.h"

#include <dirent.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

/* Read fixed cameras, image-space text regions and named anchor transforms. */
struct Vec { double x, y, z; };
struct Camera { struct Vec pos, look; double fov; bool zup; struct TextRegion text; };
#define TEXT_REGION_MARGIN 32.0f
#define TEXT_REGION_MARGIN_RATIO 0.03f
#define MIN_CAMERA_TEXT_SCALE 0.5f
#define MAX_CAMERA_TEXT_SCALE 2.0f
static xmlDoc *scene_doc;
static struct Camera camera;
static assetName_t loaded_camera;
static filePath_t loaded_rooms;

static struct Vec sub(struct Vec a, struct Vec b) { return (struct Vec){a.x-b.x,a.y-b.y,a.z-b.z}; }
static double dot(struct Vec a, struct Vec b) { return a.x*b.x+a.y*b.y+a.z*b.z; }
static struct Vec cross(struct Vec a, struct Vec b) { return (struct Vec){a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x}; }
static struct Vec normal(struct Vec a)
{
    double d = sqrt(dot(a,a));
    return d > 1e-8 ? (struct Vec){a.x/d,a.y/d,a.z/d} : (struct Vec){0,0,1};
}

static struct Vec xml_vec(xmlNode *node, const char *name, struct Vec fallback)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)name);
    if (!value) return fallback;
    struct Vec v; char extra;
    if (sscanf((char *)value, "%lf %lf %lf %c", &v.x,&v.y,&v.z,&extra) != 3 ||
        !isfinite(v.x) || !isfinite(v.y) || !isfinite(v.z)) fail("invalid %s in Scener metadata", name);
    xmlFree(value); return v;
}

static bool xml_name(xmlNode *node, const char *tag)
{
    return node->type == XML_ELEMENT_NODE && !xmlStrcmp(node->name, (const xmlChar *)tag);
}

static struct TextRegion read_text_region(xmlNode *node)
{
    struct TextRegion region={0};
    xmlChar *rect=xmlGetProp(node,(const xmlChar *)"textRect");
    xmlChar *scale=xmlGetProp(node,(const xmlChar *)"textScale");
    if (!rect && scale) fail("camera textScale requires textRect");
    if (rect) {
        frect_t r; char extra;
        if (sscanf((char *)rect,"%f %f %f %f %c",&r.origin.x,&r.origin.y,
                   &r.size.width,&r.size.height,&extra)!=4 ||
            !isfinite(r.origin.x) || !isfinite(r.origin.y) ||
            !isfinite(r.size.width) || !isfinite(r.size.height) ||
            r.origin.x<0 || r.origin.y<0 || r.size.width<=0 || r.size.height<=0 ||
            r.origin.x+r.size.width>1 || r.origin.y+r.size.height>1)
            fail("camera textRect must be a positive normalized image rectangle");
        float factor=1;
        if (scale && (sscanf((char *)scale,"%f %c",&factor,&extra)!=1 || !isfinite(factor) ||
                      factor<MIN_CAMERA_TEXT_SCALE || factor>MAX_CAMERA_TEXT_SCALE))
            fail("camera textScale must be between 0.5 and 2");
        region=(struct TextRegion){r,TEXT_BASE_SIZE*factor,true};
    }
    xmlFree(rect); xmlFree(scale);
    return region;
}

static bool named(xmlNode *node, const char *key)
{
    xmlChar *value = xmlGetProp(node, (const xmlChar *)"name");
    if (!value) return false;
    assetName_t name; copy(name, sizeof(name), (char *)value); xmlFree(value); lower(name);
    for (char *p = name; *p; ++p) if (*p == '_') *p = '-';
    return !strcmp(name, key);
}

static xmlNode *find_node(xmlNode *node, const char *key, bool is_camera)
{
    xmlNode *found = NULL;
    for (; node; node = node->next) {
        if (node->type != XML_ELEMENT_NODE) continue;
        if (xml_name(node,"camera") == is_camera && named(node,key)) found = node;
        xmlNode *child = find_node(node->children,key,is_camera);
        if (child) {
            if (found) fail("ambiguous scene anchor: %s", key);
            found = child;
        }
        if (found) {
            if (find_node(node->next,key,is_camera)) fail("duplicate scene name: %s", key);
            return found;
        }
    }
    return NULL;
}

void scene_load(const char *rooms, const char *camera_name)
{
    if (!strcmp(loaded_camera, camera_name) && !strcmp(loaded_rooms, rooms)) return;
    xmlFreeDoc(scene_doc); scene_doc = NULL;
    camera=(struct Camera){0};
    copy(loaded_camera, sizeof(loaded_camera), camera_name);
    copy(loaded_rooms, sizeof(loaded_rooms), rooms);
    if (!*camera_name) return;
    struct dirent **entries;
    int count = scandir(rooms, &entries, NULL, alphasort);
    if (count < 0) return; /* Metadata is optional when no projected markers exist. */
    for (int i = 0; i < count; ++i) {
        const char *name = entries[i]->d_name; size_t n = strlen(name);
        if (n > 5 && !strcmp(name+n-5,".blks")) {
            filePath_t path; snprintf(path,sizeof(path),"%s/%s",rooms,name);
            xmlDoc *doc = xmlReadFile(path,NULL,XML_PARSE_NONET);
            if (!doc) fail("cannot read camera metadata: %s",path);
            xmlNode *root = xmlDocGetRootElement(doc);
            xmlNode *node = find_node(root,camera_name,true);
            if (node) {
                if (scene_doc) fail("camera %s occurs in multiple .blks files",camera_name);
                if (!xml_name(root,"scene") || node->parent != root) fail("camera must be a direct scene child");
                camera.pos=xml_vec(node,"pos",(struct Vec){0,160,500});
                camera.look=xml_vec(node,"look",(struct Vec){0,120,0});
                camera.text=read_text_region(node);
                xmlChar *fov=xmlGetProp(node,(const xmlChar *)"fov");
                camera.fov=fov ? strtod((char *)fov,NULL) : 60; xmlFree(fov);
                if (!(camera.fov>0 && camera.fov<180)) fail("invalid camera FOV");
                xmlChar *up=xmlGetProp(root,(const xmlChar *)"up");
                if (up && xmlStrcmp(up,(const xmlChar *)"z") && xmlStrcmp(up,(const xmlChar *)"y")) fail("invalid scene up axis");
                camera.zup=up && !xmlStrcmp(up,(const xmlChar *)"z"); xmlFree(up);
                scene_doc=doc;
            } else xmlFreeDoc(doc);
        }
        free(entries[i]);
    }
    free(entries);
}

static bool anchor_point(const char *key, struct Vec *point)
{
    if (!scene_doc) return false;
    xmlNode *node=find_node(xmlDocGetRootElement(scene_doc),key,false);
    if (!node) return false;
    *point=(struct Vec){0,0,0};
    for (; node && !xml_name(node,"scene"); node=node->parent) {
        if (xmlHasProp(node,(const xmlChar *)"attach") || xmlHasProp(node,(const xmlChar *)"pivotOffset")) return false;
        if (node->parent && !xml_name(node->parent,"group") && !xml_name(node->parent,"scene")) return false;
        struct Vec p=xml_vec(node,"pos",(struct Vec){0,0,0});
        struct Vec s=xml_vec(node,"scale",(struct Vec){1,1,1});
        struct Vec rot=xml_vec(node,"rot",(struct Vec){0,0,0});
        double x=point->x*s.x,y=point->y*s.y,z=point->z*s.z,t;
        double radians=acos(-1)/180, c=cos(rot.x*radians),sn=sin(rot.x*radians);
        t=c*y-sn*z; z=sn*y+c*z; y=t;
        c=cos(rot.y*radians); sn=sin(rot.y*radians); t=c*x+sn*z; z=-sn*x+c*z; x=t;
        c=cos(rot.z*radians); sn=sin(rot.z*radians); t=c*x-sn*y; y=sn*x+c*y; x=t;
        *point=(struct Vec){x+p.x,y+p.y,z+p.z};
    }
    return true;
}

static bool project(struct Camera cam, struct Vec point, isize2_t image, fsize2_t viewport, fvec2_t *screen)
{
    if (isize2_is_empty(image) || fsize2_is_empty(viewport)) return false;
    /* Keep camera and perspective arithmetic in double precision until the screen result. */
    double iw=image.width, ih=image.height, width=viewport.width, height=viewport.height;
    struct Vec forward=normal(sub(cam.look,cam.pos));
    struct Vec right=normal(cross(forward,cam.zup ? (struct Vec){0,0,1} : (struct Vec){0,1,0}));
    struct Vec up=cross(right,forward),delta=sub(point,cam.pos);
    double depth=dot(delta,forward);
    if (depth<=10) return false; /* Scener centimetres; matching 0.1 m near plane. */
    double focal=ih/(2*tan(cam.fov*acos(-1)/360));
    double sx=iw/2+dot(delta,right)*focal/depth, sy=ih/2-dot(delta,up)*focal/depth;
    if (sx<0 || sx>iw || sy<0 || sy>ih) return false;
    double scale=fmax(width/iw,height/ih);
    *screen=fvec2((float)(sx*scale+(width-iw*scale)/2),(float)(sy*scale+(height-ih*scale)/2));
    return frect_covers_point(frect_from_size(viewport),*screen);
}

bool scene_project_anchor(const char *key, isize2_t image, fsize2_t viewport, fvec2_t *screen)
{
    struct Vec point;
    return anchor_point(key, &point) && project(camera, point, image, viewport, screen);
}

struct TextRegion scene_text_region(isize2_t image, fsize2_t viewport)
{
    float margin=fminf(TEXT_REGION_MARGIN,viewport.width*TEXT_REGION_MARGIN_RATIO);
    frect_t safe=frect_inset(frect_from_size(viewport),fvec2(margin,margin));
    if (!scene_doc || !camera.text.authored || isize2_is_empty(image))
        return (struct TextRegion){frect(safe.origin,fsize2(viewport.width*.70f,safe.size.height)),TEXT_BASE_SIZE,false};
    frect_t cover=frect_cover(isize2_to_float(image),frect_from_size(viewport));
    return (struct TextRegion){frect_intersection(frect_relative(camera.text.bounds,cover),safe),
                               camera.text.font_size*cover.size.height/UI_HEIGHT,true};
}

int scene_layout_hotspots(isize2_t image, fsize2_t viewport, const struct HotspotTarget *targets,
                          int target_count, bool has_text, hotspotList_t spots)
{
    int count=0;
    frect_t safe=frect_inset(frect_from_size(viewport),fvec2(HOTSPOT_DIAMETER/2,HOTSPOT_DIAMETER/2));
    for (int i=0;i<target_count;++i) {
        fvec2_t anchor;
        if (scene_project_anchor(targets[i].key,image,viewport,&anchor) && frect_covers_point(safe,anchor))
            spots[count++]=(struct Hotspot){anchor,anchor,targets[i].choice};
    }
    struct TextRegion text=scene_text_region(image,viewport);
    /* Legacy text covers most of the page; only authored reading fields are reserved. */
    frect_t prose=text.authored && has_text ? text.bounds : frect_from_size(fsize2(0,0));
    if (!hotspots_place(spots,count,viewport,prose))
        fail("camera %s cannot fit its interaction circles; recompose with more space",loaded_camera);
    return count;
}

void scene_shutdown(void)
{
    xmlFreeDoc(scene_doc);
    scene_doc = NULL;
    loaded_camera[0] = loaded_rooms[0] = 0;
}
