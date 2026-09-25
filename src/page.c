#include "book.h"

#include <math.h>
#include <string.h>

#define CONTINUE_BUTTON_WIDTH 248.0f
#define CONTINUE_BUTTON_HEIGHT 80.0f
#define BUTTON_TEXT_SIZE 36.0f
#define BUTTON_TEXT_INSET 36.0f

static void add_control(struct PageLayout *layout, frect_t bounds, int choice, bool circle)
{
    if (layout->control_count >= MAX_CHOICES) fail("too many page controls");
    layout->controls[layout->control_count++] = (struct PageControl){bounds, frect(fvec2(0, 0), fsize2(0, 0)),
                                                                     choice, circle};
}

static bool caption_fits(const struct PageLayout *layout, int index, frect_t caption, frect_t safe, frect_t prose)
{
    if (frect_intersection(caption, safe).size.width < caption.size.width ||
        frect_intersection(caption, safe).size.height < caption.size.height) return false;
    if (frect_overlaps(caption, prose)) return false;
    for (int i = 0; i < layout->control_count; ++i) {
        const struct PageControl *other = &layout->controls[i];
        if (i != index && frect_overlaps(caption, other->bounds)) return false;
        if (i < index && other->circle && frect_overlaps(caption, other->caption)) return false;
    }
    return true;
}

/* Put each label below its circle when possible, else above, right or left; captions
   never cover the prose, another circle or an earlier caption. */
static void place_caption(struct PageLayout *layout, int index, const char *label, fsize2_t viewport, frect_t prose)
{
    struct PageControl *control = &layout->controls[index];
    fsize2_t size = text_label_box(label, CAPTION_TEXT_SIZE, CAPTION_MAX_WIDTH,
                                   fvec2(CAPTION_PADDING, CAPTION_PADDING)).size;
    frect_t circle = control->bounds;
    float cx = circle.origin.x + circle.size.width / 2, cy = circle.origin.y + circle.size.height / 2;
    float left = cx - size.width / 2, top = cy - size.height / 2;
    frect_t candidates[] = {
        frect(fvec2(left, circle.origin.y + circle.size.height + CAPTION_GAP), size),
        frect(fvec2(left, circle.origin.y - CAPTION_GAP - size.height), size),
        frect(fvec2(circle.origin.x + circle.size.width + CAPTION_GAP, top), size),
        frect(fvec2(circle.origin.x - CAPTION_GAP - size.width, top), size),
    };
    frect_t safe = frect_inset(frect_from_size(viewport), fvec2(CAPTION_GAP, CAPTION_GAP));
    frect_t excluded = fsize2_is_empty(prose.size) ? prose :
        frect_inset(prose, fvec2(-HOTSPOT_TEXT_GAP, -HOTSPOT_TEXT_GAP));
    control->caption = candidates[0];
    for (size_t i = 0; i < sizeof(candidates) / sizeof(candidates[0]); ++i)
        if (caption_fits(layout, index, candidates[i], safe, excluded)) { control->caption = candidates[i]; return; }
    /* No free side: keep it below, clamped on screen; tests report the collision. */
    control->caption.origin.x = fmaxf(safe.origin.x, fminf(control->caption.origin.x,
                                      safe.origin.x + safe.size.width - size.width));
    control->caption.origin.y = fmaxf(safe.origin.y, fminf(control->caption.origin.y,
                                      safe.origin.y + safe.size.height - size.height));
}

void page_layout(const struct BookPage *page, isize2_t image, fsize2_t viewport,
                 struct PageLayout *layout)
{
    memset(layout, 0, sizeof(*layout));
    scene_load(book_rooms(), page->camera);
    layout->region = scene_text_region(image, viewport);
    struct TextRegion region = layout->region;
    layout->font_size = region.authored ? text_fit_size(page->text, region.font_size, region.bounds.size)
                                       : region.font_size;
    layout->max_scroll = (int)fmaxf(0, ceilf(text_height(page->text, layout->font_size, region.bounds.size.width)
                                           - region.bounds.size.height));
    hotspotTargetList_t targets;
    int target_count = 0;
    float margin = fminf(32, viewport.width * .03f);
    for (int i = 0; i < page->choice_count; ++i) {
        const struct Choice *choice = &page->choices[i];
        switch (choice->kind) {
        case CHOICE_OBJECT:
            copy(targets[target_count].key, sizeof(targets[target_count].key), book_object(choice->object)->key);
            targets[target_count++].choice = i;
            break;
        case CHOICE_CONTINUE:
        case CHOICE_RETRY: {
            /* Continue and "try again" share the lower-right button, widened to fit its label. */
            float width = fmaxf(CONTINUE_BUTTON_WIDTH, text_size(choice->label, BUTTON_TEXT_SIZE,
                                viewport.width).width + 2 * BUTTON_TEXT_INSET);
            frect_t bounds = frect(fvec2(viewport.width - margin - width,
                                        viewport.height - margin - CONTINUE_BUTTON_HEIGHT),
                                  fsize2(width, CONTINUE_BUTTON_HEIGHT));
            add_control(layout, bounds, i, false);
            break;
        }
        case CHOICE_INVALID: fail("cannot lay out an uninitialized choice");
        }
    }
    layout->spot_count = scene_layout_hotspots(image, viewport, targets, target_count,
                                               *page->text != 0, layout->spots);
    for (int i = 0; i < layout->spot_count; ++i) {
        const struct Hotspot *spot = &layout->spots[i];
        frect_t bounds = frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER, HOTSPOT_DIAMETER)), spot->center);
        add_control(layout, bounds, spot->choice, true);
    }
    frect_t prose = region.authored && *page->text ? region.bounds : frect(fvec2(0, 0), fsize2(0, 0));
    for (int i = 0; i < layout->control_count; ++i)
        if (layout->controls[i].circle)
            place_caption(layout, i, page->choices[layout->controls[i].choice].label, viewport, prose);
}

const struct PageControl *page_hit_test(const struct PageLayout *layout, fvec2_t point)
{
    for (int i = layout->control_count - 1; i >= 0; --i) {
        const struct PageControl *control = &layout->controls[i];
        if (control->circle && frect_contains_point(control->caption, point)) return control;
        if (!frect_contains_point(control->bounds, point)) continue;
        if (control->circle && !frect_ellipse_contains_point(control->bounds, point)) continue;
        return control;
    }
    return NULL;
}
