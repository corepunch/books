#include "book.h"

#include <math.h>
#include <string.h>

#define CONTINUE_BUTTON_WIDTH 248.0f
#define CONTINUE_BUTTON_HEIGHT 80.0f

static void add_control(struct PageLayout *layout, frect_t bounds, int choice, bool circle)
{
    if (layout->control_count >= MAX_CHOICES) fail("too many page controls");
    layout->controls[layout->control_count++] = (struct PageControl){bounds, choice, circle};
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
        case CHOICE_CONTINUE: {
            frect_t bounds = frect(fvec2(viewport.width - margin - CONTINUE_BUTTON_WIDTH,
                                        viewport.height - margin - CONTINUE_BUTTON_HEIGHT),
                                  fsize2(CONTINUE_BUTTON_WIDTH, CONTINUE_BUTTON_HEIGHT));
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
}

const struct PageControl *page_hit_test(const struct PageLayout *layout, fvec2_t point)
{
    for (int i = layout->control_count - 1; i >= 0; --i) {
        const struct PageControl *control = &layout->controls[i];
        if (!frect_contains_point(control->bounds, point)) continue;
        if (control->circle && !frect_ellipse_contains_point(control->bounds, point)) continue;
        return control;
    }
    return NULL;
}
