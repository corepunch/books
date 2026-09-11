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
static int hit_count,scroll,max_scroll;
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

static void navigate(int action,fvec2_t origin,float radius)
{
    copy(outgoing_image,sizeof(outgoing_image),book.image);
    book_action(action);
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
    hotspotList_t spots;
    int count=scene_hotspots(image,window,spots);
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
        add_hit(marker,spots[i].choice,true);
    }
    max_scroll=0;
    {
        float margin=fminf(32,window.width*.03f),limit=window.height-margin;
        struct TextRegion region=scene_text_region(image,window);
        frect_t prose=region.bounds;
        float font_size=region.authored ? text_fit_size(book.text,region.font_size,prose.size) : region.font_size;
        float prose_height=text_height(book.text,font_size,prose.size.width);
        int prose_scroll=MAX(0,(int)ceilf(prose_height-prose.size.height));
        max_scroll=prose_scroll; scroll=MIN(scroll,max_scroll);
        renderer_clip(frect_expand(prose,fsize2(2,0)));
        story_text(book.text,fvec2_add(prose.origin,fvec2(0,-MIN(scroll,prose_scroll))),font_size,prose.size.width);
        renderer_unclip();
#if 0 /* Text action list hidden for the visual pass, including its hit regions. */
        float choice_width=window.width*.40f,choice_x=window.width-margin-choice_width;
        float choice_size=33,gap=16*TEXT_SPACING_SCALE;
        float choice_top=window.height*.52f,total=0;
        for (int i=0;i<book.choice_count;++i)
            total+=text_height(book.choices[i].label,choice_size,choice_width)+gap;
        total=fmaxf(0,total-gap); choice_top=fmaxf(choice_top,limit-total);
        frect_t choices=frect(fvec2(choice_x,choice_top),fsize2(choice_width,limit-choice_top));
        int choice_scroll=MAX(0,(int)ceilf(total-choices.size.height));
        max_scroll=MAX(choice_scroll,prose_scroll);
        renderer_clip(frect_expand(choices,fsize2(2,0)));
        fvec2_t cursor=fvec2_add(choices.origin,fvec2(0,-MIN(scroll,choice_scroll)));
        for (int i=0;i<book.choice_count;++i) {
            float end=story_text(book.choices[i].label,cursor,choice_size,choices.size.width);
            frect_t row=frect(cursor,fsize2(choices.size.width,end-cursor.y));
            add_hit(frect_intersection(row,choices),i,false);
            cursor=fvec2_with_y(cursor,end+gap);
        }
        renderer_unclip();
        if (choice_scroll>scroll) story_text("↓",fvec2(window.width-margin-27,limit),27,30);
#endif
        for (int i=0;i<book.choice_count;++i) {
            const struct Choice *choice=&book.choices[i];
            /* The empty-command action returns from focus; beats use Continue. */
            if (book.beat || choice->focus || *choice->command) continue;
            frect_t button=frect(fvec2(window.width-margin-BACK_BUTTON_DIAMETER,
                                       limit-BACK_BUTTON_DIAMETER),
                                 fsize2(BACK_BUTTON_DIAMETER,BACK_BUTTON_DIAMETER));
            filePath_t icon;
            snprintf(icon,sizeof(icon),"%s/assets/back-button.png",book.root);
            if (!renderer_image(icon,button)) fail("cannot decode %s",icon);
            add_hit(button,i,true);
            break;
        }
    }
    renderer_opacity(1);
}

void ui_reload(void)
{
    transition.active=false;
    hit_count=0;
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
    if (!transition.active) scroll=MIN(max_scroll,MAX(0,(int)roundf(scroll-delta)));
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
