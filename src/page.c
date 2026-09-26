#include "book.h"

#include <math.h>
#include <string.h>

#define CONTINUE_BUTTON_WIDTH 248.0f
#define CONTINUE_BUTTON_HEIGHT 80.0f
#define BUTTON_TEXT_SIZE 36.0f
#define BUTTON_TEXT_INSET 36.0f
#define CAPTION_SEARCH_STEP 12.0f
#define MAX_CAPTION_SEARCH_ANGLES 96

static void add_control(struct PageLayout *layout, frect_t bounds, int choice, bool circle)
{
    if (layout->control_count >= MAX_CHOICES) fail("too many page controls");
    layout->controls[layout->control_count++] = (struct PageControl){bounds, frect(fvec2(0, 0), fsize2(0, 0)),
                                                                     choice, circle};
}

static bool caption_fits(const struct PageLayout *layout, int index, frect_t caption, frect_t safe)
{
    if (!frect_covers_point(safe, caption.origin) ||
        !frect_covers_point(safe, frect_bottom_right(caption))) return false;
    for (int i = 0; i < layout->prose_count; ++i)
        if (frect_overlaps(caption, frect_inset(layout->prose[i].region.bounds,
                           fvec2(-HOTSPOT_TEXT_GAP, -HOTSPOT_TEXT_GAP)))) return false;
    for (int i = 0; i < layout->control_count; ++i) {
        const struct PageControl *other = &layout->controls[i];
        if (i != index && frect_overlaps(caption, other->bounds)) return false;
        if (i < index && other->circle && frect_overlaps(caption, other->caption)) return false;
    }
    return true;
}

/* Put each label below its circle when possible, else above, right or left; captions
   never cover the prose, another circle or an earlier caption. */
static bool place_caption(struct PageLayout *layout, int index, const char *label, fsize2_t viewport)
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
    control->caption = candidates[0];
    for (size_t i = 0; i < sizeof(candidates) / sizeof(candidates[0]); ++i)
        if (caption_fits(layout, index, candidates[i], safe)) { control->caption = candidates[i]; return true; }
    control->caption = frect_from_size(fsize2(0, 0));
    return false;
}

void page_layout(const struct BookPage *page, isize2_t image, fsize2_t viewport,
                 struct PageLayout *layout)
{
    memset(layout, 0, sizeof(*layout));
    scene_load(book_rooms(), page->camera);
    textRegionList_t regions;
    int count = scene_text_regions(image, viewport, regions);
    const char *cursor = page->text;
    for (int i = 0; i < count && *cursor; ++i) {
        struct ProseLayout *block = &layout->prose[layout->prose_count++];
        block->region = regions[i];
        const char *end = strchr(cursor, '\f');
        size_t length = end ? (size_t)(end - cursor) : strlen(cursor);
        if (length >= sizeof(block->text)) fail("prose block too long");
        memcpy(block->text, cursor, length);
        block->text[length] = 0;
        /* Authored type is a reading size, never a request to shrink the prose. */
        block->content_height = text_height(block->text, block->region.font_size,
                                           block->region.bounds.size.width);
        layout->max_scroll = (int)fmaxf(layout->max_scroll,
            ceilf(block->content_height - block->region.bounds.size.height));
        block->region.bounds.size.height = fminf(block->region.bounds.size.height, block->content_height);
        cursor += length;
        if (*cursor == '\f') ++cursor;
    }
    if (*cursor) fail("camera %s needs another reading region", page->camera);
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
    /* Wide iPads crop more of the image vertically. Keep the reading block
       above the fixed-size Continue control without changing its type size. */
    for (int i = 0; i < layout->prose_count; ++i) {
        frect_t *bounds = &layout->prose[i].region.bounds;
        for (int j = 0; j < layout->control_count; ++j) {
            const struct PageControl *control = &layout->controls[j];
            if (!control->circle && frect_overlaps(*bounds, control->bounds))
                *bounds = frect_translate(*bounds, fvec2(0, control->bounds.origin.y - HOTSPOT_TEXT_GAP
                                                        - frect_bottom_right(*bounds).y));
        }
    }
    for (int i = 0; i < layout->prose_count; ++i) regions[i] = layout->prose[i].region;
    layout->spot_count = scene_layout_hotspots(image, viewport, targets, target_count,
                                               regions, layout->prose_count, layout->spots);
    for (int i = 0; i < layout->spot_count; ++i) {
        const struct Hotspot *spot = &layout->spots[i];
        frect_t bounds = frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER, HOTSPOT_DIAMETER)), spot->center);
        add_control(layout, bounds, spot->choice, true);
    }
    for (int i = 0; i < layout->control_count; ++i) {
        struct PageControl *control = &layout->controls[i];
        if (!control->circle) continue;
        const char *label = page->choices[control->choice].label;
        if (place_caption(layout, i, label, viewport)) continue;
        /* A caption needs more room than its circle. Move the pair together,
           retaining the exact scene anchor for the connecting line. */
        bool placed = false;
        fvec2_t origin = frect_center(control->bounds);
        frect_t safe = frect_inset(frect_from_size(viewport),
                                   fvec2(HOTSPOT_DIAMETER/2, HOTSPOT_DIAMETER/2));
        for (float radius = CAPTION_SEARCH_STEP; radius < hypotf(viewport.width, viewport.height) && !placed;
             radius += CAPTION_SEARCH_STEP) {
            for (int angle = 0; angle < MAX_CAPTION_SEARCH_ANGLES && !placed; ++angle) {
                float theta = angle * 2 * acosf(-1) / MAX_CAPTION_SEARCH_ANGLES;
                fvec2_t center = fvec2_add(origin, fvec2(radius*cosf(theta), radius*sinf(theta)));
                if (!frect_covers_point(safe, center)) continue;
                frect_t bounds = frect_center_at(control->bounds, center);
                bool clear = true;
                for (int j = 0; j < layout->prose_count; ++j)
                    if (frect_overlaps(bounds, frect_inset(layout->prose[j].region.bounds,
                                       fvec2(-HOTSPOT_TEXT_GAP, -HOTSPOT_TEXT_GAP)))) clear = false;
                for (int j = 0; j < layout->control_count; ++j) {
                    if (j == i) continue;
                    const struct PageControl *other = &layout->controls[j];
                    if (frect_overlaps(bounds, other->caption) || frect_overlaps(bounds, other->bounds)) clear = false;
                    if (other->circle && fvec2_length_squared(fvec2_sub(center, frect_center(other->bounds))) <
                        (HOTSPOT_DIAMETER+HOTSPOT_GAP)*(HOTSPOT_DIAMETER+HOTSPOT_GAP)) clear = false;
                }
                if (!clear) continue;
                control->bounds = bounds;
                placed = place_caption(layout, i, label, viewport);
            }
        }
        if (!placed) fail("camera %s cannot fit choice caption %s", page->camera, label);
        for (int j = 0; j < layout->spot_count; ++j)
            if (layout->spots[j].choice == control->choice) layout->spots[j].center = frect_center(control->bounds);
    }
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
