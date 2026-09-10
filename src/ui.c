#include "book.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

struct Hit { frect_t bounds; int action; bool circle; };
static struct Hit hits[MAX_HITS];
static int hit_count,scroll,max_scroll,show_text=1;
static command_t input;
static struct Transition transition;
static filePath_t outgoing_image;
static double preview_time = -1;

static double now(void)
{
    struct timespec time;
    clock_gettime(CLOCK_MONOTONIC, &time);
    return time.tv_sec + time.tv_nsec / 1e9;
}

static fsize2_t window_size(void) { return renderer_bounds().size; }

enum Navigation { NAV_CHOICE, NAV_BACK, NAV_COMMAND };

static void navigate(enum Navigation navigation,int action,fvec2_t origin,float radius)
{
    copy(outgoing_image,sizeof(outgoing_image),book.image);
    if (navigation==NAV_CHOICE) book_action(action);
    else if (navigation==NAV_BACK) book_back();
    else { book_command(input,0); input[0]=0; }
    /* Upload before starting the clock so disk/decode time cannot skip the reveal. */
    if (*book.image && isize2_is_empty(renderer_image_size(book.image)))
        fail("cannot decode %s",book.image);
    transition_start(&transition,now(),origin,window_size(),radius,strcmp(outgoing_image,book.image)!=0);
    scroll=0; hit_count=0;
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

static isize2_t draw_image(const char *path,frect_t viewport)
{
    isize2_t image=renderer_image_size(path);
    if (*path) {
        if (isize2_is_empty(image)) fail("cannot decode %s",path);
        renderer_image(path,frect_cover(isize2_to_float(image),viewport));
    } else renderer_rect(viewport,0x211C18FF);
    return image;
}

void ui_draw(void)
{
    fsize2_t window=window_size();
    frect_t viewport=frect_from_size(window);
    hit_count=0;
    struct TransitionFrame frame=transition_sample(&transition,
        preview_time>=0 ? transition.started+preview_time : now(),window);
    if (frame.revealing) {
        draw_image(outgoing_image,viewport);
        renderer_reveal_begin(frame.center,frame.radius);
    }
    isize2_t image=draw_image(book.image,viewport);
    renderer_reveal_end();
    renderer_opacity(frame.overlay_opacity);
    scene_load(book.rooms,book.camera);
    if (!book.beat && !book.focus) {
        frect_t safe=frect_inset(viewport,fvec2(HOTSPOT_DIAMETER/2,HOTSPOT_DIAMETER/2));
        for (int i=0;i<book.choice_count;++i) {
            struct Choice *c=&book.choices[i]; fvec2_t point;
            if (c->focus && scene_project_anchor(book.objects[c->object].key,image,window,&point) &&
                frect_covers_point(safe,point)) {
                frect_t marker=frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER,HOTSPOT_DIAMETER)),point);
                renderer_ring(frect_translate(marker,fvec2(0,2)),0x120B0780);
                renderer_ring(marker,0xFFFFFFFF);
                add_hit(marker,i,true);
            }
        }
    }
    max_scroll=0;
    if (show_text) {
        float margin=fminf(32,window.width*.03f),prose_width=window.width*.44f;
        float choice_width=window.width*.40f,choice_x=window.width-margin-choice_width;
        float font_size=24,choice_size=22,gap=16,limit=window.height-margin-(*input ? 40 : 0);
        float choice_top=window.height*.52f,total=0;
        for (int i=0;i<book.choice_count;++i)
            total+=text_height(book.choices[i].label,choice_size,choice_width)+gap;
        total=fmaxf(0,total-gap); choice_top=fmaxf(choice_top,limit-total);
        frect_t prose=frect(fvec2(margin,margin),fsize2(prose_width,limit-margin));
        frect_t choices=frect(fvec2(choice_x,choice_top),fsize2(choice_width,limit-choice_top));
        int choice_scroll=MAX(0,(int)ceilf(total-choices.size.height));
        float prose_height=text_height(book.text,font_size,prose.size.width);
        int prose_scroll=MAX(0,(int)ceilf(prose_height-prose.size.height));
        max_scroll=MAX(choice_scroll,prose_scroll); scroll=MIN(scroll,max_scroll);
        renderer_clip(frect_expand(prose,fsize2(2,0)));
        story_text(book.text,fvec2_add(prose.origin,fvec2(0,-MIN(scroll,prose_scroll))),font_size,prose.size.width);
        renderer_unclip();
        renderer_clip(frect_expand(choices,fsize2(2,0)));
        fvec2_t cursor=fvec2_add(choices.origin,fvec2(0,-MIN(scroll,choice_scroll)));
        for (int i=0;i<book.choice_count;++i) {
            float end=story_text(book.choices[i].label,cursor,choice_size,choices.size.width);
            frect_t row=frect(cursor,fsize2(choices.size.width,end-cursor.y));
            add_hit(frect_intersection(row,choices),i,false);
            cursor=fvec2_with_y(cursor,end+gap);
        }
        renderer_unclip();
        if (choice_scroll>scroll) story_text("↓",fvec2(window.width-margin-18,limit),18,20);
    }
    if (*input) {
        prompt_t text; snprintf(text,sizeof(text),"> %s",input);
        frect_t prompt=frect(fvec2(32,window.height-40),fsize2(window.width-64,32));
        renderer_clip(prompt);
        story_text(text,prompt.origin,20,prompt.size.width); renderer_unclip();
    }
    renderer_opacity(1);
}

static void reload(void)
{
    transition.active=false;
    hit_count=0;
    scene_shutdown();
    renderer_invalidate_image();
    book_reload();
    scene_load(book.rooms,book.camera);
}

void ui_key(enum UIKey key)
{
    if (transition.active && key!=UI_KEY_RELOAD) return;
    fvec2_t center=frect_center(frect_from_size(window_size()));
    if (key==UI_KEY_TAB) { show_text=!show_text; hit_count=0; }
    else if (key==UI_KEY_RELOAD) reload();
    else if (key==UI_KEY_ESCAPE) { if (*input) input[0]=0; else navigate(NAV_BACK,0,center,0); }
    else if (key==UI_KEY_ENTER) {
        if (*input) navigate(NAV_COMMAND,0,center,0);
        else if (book.beat) navigate(NAV_BACK,0,center,0);
    } else if (key==UI_KEY_BACKSPACE) {
        size_t n=strlen(input);
        if (n) { do { --n; } while (n && ((unsigned char)input[n]&0xC0)==0x80); input[n]=0; }
    } else if (key==UI_KEY_DOWN) scroll=MIN(max_scroll,scroll+40);
    else if (key==UI_KEY_UP) scroll=MAX(0,scroll-40);
}

void ui_input(const char *utf8)
{
    if (transition.active) return;
    if (utf8 && (unsigned char)utf8[0]>=32 && (unsigned char)utf8[0]!=127 &&
        strlen(input)+strlen(utf8)<sizeof(input)) strcat(input,utf8);
}

void ui_click(fvec2_t point)
{
    if (transition.active) return;
    for (int i=hit_count-1;i>=0;--i) {
        struct Hit h=hits[i];
        if (!frect_contains_point(h.bounds,point)) continue;
        if (h.circle && !frect_ellipse_contains_point(h.bounds,point)) continue;
        navigate(NAV_CHOICE,h.action,h.circle ? frect_center(h.bounds) : point,
                 h.circle ? HOTSPOT_DIAMETER/2 : 0);
        break;
    }
}

void ui_scroll(float delta)
{
    if (!transition.active) scroll=MIN(max_scroll,MAX(0,(int)roundf(scroll-delta)));
}

bool ui_animating(void) { return transition.active; }

void ui_preview(double seconds)
{
    for (int i=0;i<hit_count;++i) if (hits[i].circle) {
        struct Hit h=hits[i];
        navigate(NAV_CHOICE,h.action,frect_center(h.bounds),HOTSPOT_DIAMETER/2);
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
