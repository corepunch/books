#include "book.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))
#define BACK_BUTTON_DIAMETER 96.0f

struct Hit { frect_t bounds; int action; bool circle; };
static struct Hit hits[MAX_HITS];
/* A page owns its presentation so navigation cannot change the outgoing view. */
struct Page {
    filePath_t image, rooms, back_icon;
    assetName_t camera;
    storyText_t text;
    hotspotTargetList_t targets;
    int target_count, back_action;
    hotspotList_t spots;
    int spot_count, scroll, max_scroll;
    struct TextRegion region;
    float font_size;
    fsize2_t viewport;
    frect_t back_button;
};
static struct Page current_page, outgoing_page;
static int hit_count;
static bool page_ready;
static struct Transition transition;
static double preview_time = -1;

static double now(void)
{
    struct timespec time;
    clock_gettime(CLOCK_MONOTONIC, &time);
    return time.tv_sec + time.tv_nsec / 1e9;
}

static fsize2_t window_size(void) { return renderer_bounds().size; }

static void layout_page(struct Page *page, fsize2_t window)
{
    isize2_t image=renderer_image_size(page->image);
    if (*page->image && isize2_is_empty(image)) fail("cannot decode %s",page->image);
    scene_load(page->rooms,page->camera);
    page->region=scene_text_region(image,window);
    page->spot_count=scene_layout_hotspots(image,window,page->targets,page->target_count,
                                          *page->text!=0,page->spots);
    frect_t prose=page->region.bounds;
    page->font_size=page->region.authored ? text_fit_size(page->text,page->region.font_size,prose.size)
                                        : page->region.font_size;
    page->max_scroll=MAX(0,(int)ceilf(text_height(page->text,page->font_size,prose.size.width)-prose.size.height));
    page->scroll=MIN(page->scroll,page->max_scroll);
    float margin=fminf(32,window.width*.03f);
    page->back_button=frect(fvec2(window.width-margin-BACK_BUTTON_DIAMETER,
                                  window.height-margin-BACK_BUTTON_DIAMETER),
                            fsize2(BACK_BUTTON_DIAMETER,BACK_BUTTON_DIAMETER));
    page->viewport=window;
}

static void capture_page(struct Page *page)
{
    copy(page->image,sizeof(page->image),book.image);
    copy(page->rooms,sizeof(page->rooms),book.rooms);
    copy(page->camera,sizeof(page->camera),book.camera);
    copy(page->text,sizeof(page->text),book.text);
    page->target_count=scene_hotspot_targets(page->targets);
    page->back_action=-1;
    for (int i=0;i<book.choice_count;++i) {
        const struct Choice *choice=&book.choices[i];
        if (book.beat || choice->focus || *choice->command) continue;
        page->back_action=i;
        break;
    }
    snprintf(page->back_icon,sizeof(page->back_icon),"%s/assets/back-button.png",book.root);
    page->scroll=0;
    layout_page(page,window_size());
}

static void navigate(int action,fvec2_t origin,float radius)
{
    outgoing_page=current_page;
    book_action(action);
    /* Resolve and upload the new page before the animation clock starts. */
    capture_page(&current_page);
    transition_start(&transition,now(),origin,window_size(),radius,
                     strcmp(outgoing_page.image,current_page.image)!=0);
    hit_count=0;
}

static float story_text(const char *text,fvec2_t origin,float size,float width)
{
    text_draw(text,fvec2_add(origin,fvec2(1,2)),size,width,0x120B07E6);
    return text_draw(text,origin,size,width,0xF4E6CAFF);
}

static void add_hit(frect_t bounds,int action,bool circle)
{
    if (!transition.active && !fsize2_is_empty(bounds.size) && hit_count<MAX_HITS)
        hits[hit_count++]=(struct Hit){bounds,action,circle};
}

static void draw_image(const char *path,frect_t viewport)
{
    isize2_t image=renderer_image_size(path);
    if (*path) {
        if (isize2_is_empty(image)) fail("cannot decode %s",path);
        renderer_image(path,frect_cover(isize2_to_float(image),viewport));
    } else renderer_rect(viewport,0x211C18FF);
}

static void draw_overlays(const struct Page *page, bool interactive)
{
    const struct Hotspot *spots=page->spots;
    int count=page->spot_count;
    for (int i=0;i<count;++i) {
        struct Hotspot spot=spots[i];
        fvec2_t delta=fvec2_sub(spot.anchor,spot.center);
        float distance=sqrtf(fvec2_length_squared(delta));
        if (distance>HOTSPOT_DIAMETER/2) {
            fvec2_t edge=fvec2_add(spot.center,fvec2_scale(delta,(HOTSPOT_DIAMETER/2)/distance));
            renderer_line(fvec2_add(edge,fvec2(0,2)),fvec2_add(spot.anchor,fvec2(0,2)),0x120B0780);
            renderer_line(edge,spot.anchor,0xFFFFFFB0);
        }
    }
    for (int i=0;i<count;++i) {
        frect_t marker=frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER,HOTSPOT_DIAMETER)),spots[i].center);
        renderer_ring(frect_translate(marker,fvec2(0,2)),0x120B0780);
        renderer_ring(marker,0xFFFFFFFF);
        if (interactive) add_hit(marker,spots[i].choice,true);
    }
    frect_t prose=page->region.bounds;
    renderer_clip(frect_expand(prose,fsize2(2,0)));
    story_text(page->text,fvec2_add(prose.origin,fvec2(0,-page->scroll)),page->font_size,prose.size.width);
    renderer_unclip();
    if (page->back_action>=0) {
        if (!renderer_image(page->back_icon,page->back_button)) fail("cannot decode %s",page->back_icon);
        if (interactive) add_hit(page->back_button,page->back_action,true);
    }
}

void ui_draw(void)
{
    fsize2_t window=window_size();
    frect_t viewport=frect_from_size(window);
    if (!page_ready) {
        capture_page(&current_page);
        page_ready=true;
    }
    if (current_page.viewport.width!=window.width || current_page.viewport.height!=window.height)
        layout_page(&current_page,window);
    hit_count=0;
    struct TransitionFrame frame=transition_sample(&transition,
        preview_time>=0 ? transition.started+preview_time : now(),window);
    if (frame.revealing) {
        if (outgoing_page.viewport.width!=window.width || outgoing_page.viewport.height!=window.height)
            layout_page(&outgoing_page,window);
        draw_image(outgoing_page.image,viewport);
        draw_overlays(&outgoing_page,false);
        renderer_reveal_begin(frame.center,frame.radius);
    }
    draw_image(current_page.image,viewport);
    renderer_reveal_end();
    /* Same-art responses crossfade their overlays without an empty-text frame. */
    if (frame.active && !transition.reveal) {
        if (outgoing_page.viewport.width!=window.width || outgoing_page.viewport.height!=window.height)
            layout_page(&outgoing_page,window);
        renderer_opacity(1-frame.overlay_opacity);
        draw_overlays(&outgoing_page,false);
    }
    renderer_opacity(frame.overlay_opacity);
    draw_overlays(&current_page,!frame.active);
    renderer_opacity(1);
}

void ui_reload(void)
{
    transition.active=false;
    hit_count=0;
    page_ready=false;
    preview_time=-1;
    scene_shutdown();
    renderer_invalidate_image();
    book_reload();
    scene_load(book.rooms,book.camera);
}

void ui_click(fvec2_t point)
{
    if (transition.active) return;
    for (int i=hit_count-1;i>=0;--i) {
        struct Hit h=hits[i];
        if (!frect_contains_point(h.bounds,point)) continue;
        if (h.circle && !frect_ellipse_contains_point(h.bounds,point)) continue;
        navigate(h.action,h.circle ? frect_center(h.bounds) : point,
                 h.circle ? fminf(h.bounds.size.width,h.bounds.size.height)/2 : 0);
        break;
    }
}

void ui_scroll(float delta)
{
    if (!transition.active) current_page.scroll=MIN(current_page.max_scroll,MAX(0,(int)roundf(current_page.scroll-delta)));
}

bool ui_animating(void) { return transition.active; }

void ui_preview(double seconds)
{
    for (int i=0;i<hit_count;++i) if (hits[i].circle) {
        struct Hit h=hits[i];
        navigate(h.action,frect_center(h.bounds),fminf(h.bounds.size.width,h.bounds.size.height)/2);
        preview_time=seconds;
        return;
    }
    fail("transition smoke requires a projected hotspot");
}

void ui_init(void)
{
    filePath_t font; snprintf(font,sizeof(font),"%s/fonts/Literata-VariableFont_opsz,wght.ttf",book.root);
    if (!text_init(font)) fail("cannot load Literata");
}
