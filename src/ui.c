#include "book.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))
/* Retain the complete published page for the outgoing animation. */
struct PageView {
    struct BookPage content;
    struct PageLayout layout;
    int scroll;
    fsize2_t viewport;
};
static struct PageView current_page, outgoing_page;
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

static void layout_view(struct PageView *view, fsize2_t window)
{
    isize2_t image = renderer_image_size(view->content.image);
    if (*view->content.image && isize2_is_empty(image)) fail("cannot decode %s", view->content.image);
    page_layout(&view->content, image, window, &view->layout);
    view->scroll = MIN(view->scroll, view->layout.max_scroll);
    view->viewport = window;
}

static void capture_page(struct PageView *view)
{
    view->content = *book_page();
    view->scroll = 0;
    layout_view(view, window_size());
}

static void navigate(int action, fvec2_t origin, float radius)
{
    if (!book_action(action)) return;
    outgoing_page = current_page;
    /* Resolve and upload the new page before the animation clock starts. */
    capture_page(&current_page);
    transition_start(&transition, now(), origin, window_size(), radius,
                     strcmp(outgoing_page.content.image, current_page.content.image) != 0);
    preview_time = -1;
}

static float story_text(const char *text,fvec2_t origin,float size,float width)
{
    text_draw(text,fvec2_add(origin,fvec2(-1,0)),size,width,0x120B07C0);
    text_draw(text,fvec2_add(origin,fvec2(1,0)),size,width,0x120B07C0);
    text_draw(text,fvec2_add(origin,fvec2(0,2)),size,width,0x120B07E6);
    return text_draw(text,origin,size,width,0xF4E6CAFF);
}

static void draw_image(const char *path,frect_t viewport)
{
    isize2_t image=renderer_image_size(path);
    if (*path) {
        if (isize2_is_empty(image)) fail("cannot decode %s",path);
        renderer_image(path,frect_cover(isize2_to_float(image),viewport));
    } else renderer_rect(viewport,0x211C18FF);
}

static void draw_page_image(const struct PageView *view, frect_t viewport)
{
    draw_image(view->content.image, viewport);
}

static void draw_continue(const struct PageControl *control, const char *label)
{
    frect_t button = control->bounds;
    renderer_round_rect(button, BUTTON_CORNER_RADIUS, 0, 0x211C18E8);
    renderer_round_rect(button, BUTTON_CORNER_RADIUS, 1.5f, 0xF4E6CAFF);
    text_draw_centered(label, button, 36, 0xF4E6CAFF);
}

static void draw_overlays(const struct PageView *view)
{
    const struct PageLayout *layout = &view->layout;
    for (int i = 0; i < layout->spot_count; ++i) {
        struct Hotspot spot = layout->spots[i];
        fvec2_t delta = fvec2_sub(spot.anchor, spot.center);
        float distance = sqrtf(fvec2_length_squared(delta));
        if (distance > HOTSPOT_DIAMETER / 2) {
            fvec2_t edge = fvec2_add(spot.center, fvec2_scale(delta, (HOTSPOT_DIAMETER / 2) / distance));
            renderer_line(fvec2_add(edge, fvec2(0, 2)), fvec2_add(spot.anchor, fvec2(0, 2)), 0x120B0780);
            renderer_line(edge, spot.anchor, 0xFFFFFFB0);
        }
    }
    for (int i = 0; i < layout->prose_count; ++i) {
        const struct ProseLayout *block = &layout->prose[i];
        frect_t prose = block->region.bounds;
        renderer_clip(frect_expand(prose, fsize2(4, 0)));
        story_text(block->text, fvec2_add(prose.origin, fvec2(0, -view->scroll)),
                   block->region.font_size, prose.size.width);
        renderer_unclip();
    }
    for (int i = 0; i < layout->control_count; ++i) {
        const struct PageControl *control = &layout->controls[i];
        const struct Choice *choice = &view->content.choices[control->choice];
        switch (choice->kind) {
        case CHOICE_OBJECT:
            renderer_ring(frect_translate(control->bounds, fvec2(0, 2)), 0x120B0780);
            renderer_ring(control->bounds, 0xFFFFFFFF);
            renderer_round_rect(control->caption, CAPTION_CORNER_RADIUS, 0, 0x211C18C8);
            text_draw_centered(choice->label, control->caption, CAPTION_TEXT_SIZE, 0xF4E6CAFF);
            break;
        case CHOICE_CONTINUE:
        case CHOICE_RETRY: draw_continue(control, choice->label); break;
        case CHOICE_INVALID: fail("cannot draw an uninitialized choice");
        }
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
        layout_view(&current_page,window);
    struct TransitionFrame frame=transition_sample(&transition,
        preview_time>=0 ? transition.started+preview_time : now(),window);
    if (frame.revealing) {
        if (outgoing_page.viewport.width!=window.width || outgoing_page.viewport.height!=window.height)
            layout_view(&outgoing_page,window);
        draw_page_image(&outgoing_page,viewport);
        draw_overlays(&outgoing_page);
        renderer_reveal_begin(frame.center,frame.radius);
    }
    draw_page_image(&current_page,viewport);
    renderer_reveal_end();
    /* Same-art responses crossfade their overlays without an empty-text frame. */
    if (frame.active && !transition.reveal) {
        if (outgoing_page.viewport.width!=window.width || outgoing_page.viewport.height!=window.height)
            layout_view(&outgoing_page,window);
        renderer_opacity(1-frame.overlay_opacity);
        draw_overlays(&outgoing_page);
    }
    renderer_opacity(frame.overlay_opacity);
    draw_overlays(&current_page);
    renderer_opacity(1);
}

void ui_reload(void)
{
    transition.active=false;
    page_ready=false;
    preview_time=-1;
    scene_shutdown();
    renderer_invalidate_image();
    book_reload();
}

void ui_click(fvec2_t point)
{
    if (!page_ready || transition.active) return;
    const struct PageControl *control = page_hit_test(&current_page.layout, point);
    if (control) navigate(control->choice, control->circle ? frect_center(control->bounds) : point,
                          control->circle ? fminf(control->bounds.size.width, control->bounds.size.height) / 2 : 0);
}

void ui_scroll(float delta)
{
    if (!transition.active) current_page.scroll=MIN(current_page.layout.max_scroll,MAX(0,(int)roundf(current_page.scroll-delta)));
}

bool ui_animating(void) { return transition.active; }

void ui_preview(double seconds)
{
    /* Prefer a circle, whose reveal grows from its edge; otherwise press the page's button. */
    for (int pass = 0; pass < 2; ++pass)
        for (int i = 0; i < current_page.layout.control_count; ++i) {
            const struct PageControl control = current_page.layout.controls[i];
            if (control.circle != (pass == 0)) continue;
            ui_click(frect_center(control.bounds));
            preview_time = seconds;
            return;
        }
    fail("transition smoke requires a control on the first page");
}

void ui_init(void)
{
    filePath_t font; snprintf(font,sizeof(font),"%s/fonts/Literata-VariableFont_opsz,wght.ttf",book_root());
    if (!text_init(font)) fail("cannot load Literata");
}
