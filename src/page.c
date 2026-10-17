#include "book.h"

#include <math.h>
#include <string.h>

#define CONTINUE_BUTTON_WIDTH 248.0f
#define CONTINUE_BUTTON_HEIGHT 80.0f
#define BUTTON_TEXT_SIZE 36.0f
#define BUTTON_TEXT_INSET 36.0f
#define CAPTION_SEARCH_STEP 12.0f
#define MAX_CAPTION_SEARCH_ANGLES 96

static struct PageControl *add_control(struct PageLayout *layout, frect_t bounds, int choice, bool circle)
{
    if (layout->control_count >= MAX_CHOICES) fail("too many page controls");
    struct PageControl *control = &layout->controls[layout->control_count++];
    *control = (struct PageControl){bounds, frect(fvec2(0, 0), fsize2(0, 0)), choice, circle, false};
    return control;
}

static frect_t frect_union(frect_t a, frect_t b)
{
    if (fsize2_is_empty(a.size)) return b;
    fvec2_t low = fvec2(fminf(a.origin.x, b.origin.x), fminf(a.origin.y, b.origin.y));
    fvec2_t high = fvec2(fmaxf(frect_bottom_right(a).x, frect_bottom_right(b).x),
                         fmaxf(frect_bottom_right(a).y, frect_bottom_right(b).y));
    return frect(low, fsize2(high.x - low.x, high.y - low.y));
}

/* Carried things line up from the bottom-left corner: a disc with its name underneath. Returns
   the row's bounds, which prose and scene circles keep clear of. */
static frect_t layout_items(struct PageLayout *layout, const struct BookPage *page, fsize2_t viewport,
                            float margin, bool top)
{
    frect_t row = frect_from_size(fsize2(0, 0));
    float x = margin, caption_height = 0;
    fvec2_t padding = fvec2(CAPTION_PADDING, CAPTION_PADDING / 2);
    for (int i = 0; i < page->choice_count; ++i)
        if (page->choices[i].kind == CHOICE_ITEM || page->choices[i].kind == CHOICE_MAP)
            caption_height = fmaxf(caption_height, text_label_box(page->choices[i].label, ITEM_CAPTION_TEXT_SIZE,
                                                                  ITEM_CAPTION_MAX_WIDTH, padding).size.height);
    /* Discs share one row; each name hangs from the top of the caption band below them.
       A talk keeps that row in the top corner, clear of the questions. */
    float caption_top = top ? margin + ITEM_DIAMETER + CAPTION_GAP / 2
                            : viewport.height - margin - caption_height;
    for (int i = 0; i < page->choice_count; ++i) {
        const struct Choice *choice = &page->choices[i];
        if (choice->kind != CHOICE_ITEM && choice->kind != CHOICE_MAP) continue;
        fsize2_t caption = text_label_box(choice->label, ITEM_CAPTION_TEXT_SIZE, ITEM_CAPTION_MAX_WIDTH, padding).size;
        float width = fmaxf(ITEM_DIAMETER, caption.width);
        fvec2_t center = fvec2(x + width / 2, caption_top - CAPTION_GAP / 2 - ITEM_DIAMETER / 2);
        struct PageControl *control = add_control(layout,
            frect_center_at(frect_from_size(fsize2(ITEM_DIAMETER, ITEM_DIAMETER)), center), i, false);
        control->item = true;
        control->caption = frect(fvec2(center.x - caption.width / 2, caption_top), caption);
        row = frect_union(row, frect_union(control->bounds, control->caption));
        x += width + ITEM_GAP;
    }
    if (x - ITEM_GAP > viewport.width - margin) fail("too many carried things for the inventory row");
    return row;
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
        if ((other->item || (i < index && other->circle)) && frect_overlaps(caption, other->caption)) return false;
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

/* Questions stack in a darkened band. The line that ends the talk is always last.
   The carried-thing row stays in the top corner so it does not cover the lines. */
static void layout_talk(struct PageLayout *layout, const struct BookPage *page, fsize2_t viewport)
{
    float scale = viewport.height / (float)UI_HEIGHT;
    float margin = fminf(ASK_MARGIN * scale, viewport.width * .04f);
    float width = viewport.width - 2 * margin;
    float type = talk_type_size(viewport.height);
    struct TextMetrics metrics = text_metrics(type);
    float min_row = fmaxf(44 * scale, metrics.line + ASK_ROW_PAD * scale);
    int asks[MAX_CHOICES], ask_count = 0, end_choice = -1, keys[MAX_CHOICES], key_count = 0;
    for (int i = 0; i < page->choice_count; ++i) {
        switch (page->choices[i].kind) {
        case CHOICE_ASK: asks[ask_count++] = i; break;
        case CHOICE_KEY:
            if (!page->keypad) fail("camera %s lays out a key without a keypad", page->camera);
            keys[key_count++] = i;
            break;
        case CHOICE_END:
            if (end_choice >= 0) fail("camera %s has two ways to end the talk", page->camera);
            end_choice = i;
            break;
        case CHOICE_ITEM: break;
        case CHOICE_OBJECT:
        case CHOICE_CONTINUE:
        case CHOICE_RETRY:
        case CHOICE_MAP:
        case CHOICE_INVALID: fail("camera %s lays a talk line out as something else", page->camera);
        }
    }
    if (end_choice < 0) fail("camera %s has no way to end the talk", page->camera);
    if (width <= 0) fail("camera %s has no room for a question", page->camera);

    float line_gap = ASK_LINE_GAP * scale;
    float lines = 0, row_h[MAX_CHOICES];
    /* The keypad's grid takes the place of the question lines. */
    float key_gap = KEY_GAP * scale, key_h = min_row * 1.2f;
    float key_w = fminf(KEY_WIDTH * scale, (width - (KEYPAD_COLUMNS - 1) * key_gap) / KEYPAD_COLUMNS);
    int key_rows = (key_count + KEYPAD_COLUMNS - 1) / KEYPAD_COLUMNS;
    if (key_rows) lines = key_rows * key_h + (key_rows - 1) * key_gap;
    for (int i = 0; i < ask_count; ++i) {
        float height = text_height(page->choices[asks[i]].label, type, width);
        row_h[i] = fmaxf(min_row, height + ASK_ROW_PAD * scale);
        lines += row_h[i];
        if (i + 1 < ask_count) lines += line_gap;
    }
    const char *closing = page->choices[end_choice].label;
    float end_h = fmaxf(min_row, text_height(closing, type, width) + ASK_ROW_PAD * scale);
    bool has_prose = page->text[0] != 0;
    float prose_h = has_prose ? text_height(page->text, type, width) : 0;
    float top_pad = ASK_TOP_PAD * scale, end_gap = ASK_END_GAP * scale;
    float prose_gap = has_prose ? ASK_PROSE_GAP * scale : 0;
    float solid = top_pad + prose_h + prose_gap + lines + end_gap + end_h + margin;
    float solid_top = viewport.height - solid;
    if (solid_top < margin) fail("camera %s cannot fit the questions", page->camera);
    float feather_h = fminf(ASK_VEIL_FEATHER * scale, solid_top);
    layout->feather = frect(fvec2(0, solid_top - feather_h), fsize2(viewport.width, feather_h));
    layout->veil = frect(fvec2(0, solid_top), fsize2(viewport.width, solid));

    if (has_prose) {
        struct ProseLayout *block = &layout->prose[layout->prose_count++];
        block->region.bounds = frect(fvec2(margin, solid_top + top_pad), fsize2(width, prose_h));
        block->region.font_size = type;
        block->region.authored = true;
        copy(block->text, sizeof(block->text), page->text);
        block->content_height = prose_h;
    }

    float y = solid_top + top_pad + prose_h + prose_gap;
    float grid_left = margin + (width - (KEYPAD_COLUMNS * key_w + (KEYPAD_COLUMNS - 1) * key_gap)) / 2;
    for (int i = 0; i < key_count; ++i) {
        int row = i / KEYPAD_COLUMNS, column = i % KEYPAD_COLUMNS;
        add_control(layout, frect(fvec2(grid_left + column * (key_w + key_gap), y + row * (key_h + key_gap)),
                                  fsize2(key_w, key_h)), keys[i], false);
    }
    if (key_rows) y += lines;
    for (int i = 0; i < ask_count; ++i) {
        add_control(layout, frect(fvec2(margin, y), fsize2(width, row_h[i])), asks[i], false);
        y += row_h[i];
        if (i + 1 < ask_count) y += line_gap;
    }
    layout->rule = y + end_gap / 2;
    add_control(layout, frect(fvec2(margin, y + end_gap), fsize2(width, end_h)), end_choice, false);

    frect_t items = layout_items(layout, page, viewport, margin, true);
    if (!fsize2_is_empty(items.size) &&
        (frect_overlaps(items, layout->veil) || frect_overlaps(items, layout->feather)))
        fail("camera %s inventory overlaps the questions", page->camera);
}

void page_layout(const struct BookPage *page, isize2_t image, fsize2_t viewport,
                 struct PageLayout *layout)
{
    memset(layout, 0, sizeof(*layout));
    scene_load(book_rooms(), page->camera);
    if (page->talk) {
        layout_talk(layout, page, viewport);
        return;
    }
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
    int target_count = 0, edges[MAX_CHOICES], edge_count = 0;
    float margin = fminf(32, viewport.width * .03f);
    for (int i = 0; i < page->choice_count; ++i) {
        const struct Choice *choice = &page->choices[i];
        switch (choice->kind) {
        case CHOICE_OBJECT:
            if (choice->edge != CHOICE_EDGE_NONE) {
                edges[edge_count++] = i;
                break;
            }
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
        case CHOICE_ITEM:
        case CHOICE_MAP: break;
        case CHOICE_ASK:
        case CHOICE_END:
        case CHOICE_KEY: fail("camera %s lays out a talk line without a talk", page->camera);
        case CHOICE_INVALID: fail("cannot lay out an uninitialized choice");
        }
    }
    frect_t items = layout_items(layout, page, viewport, margin, false);
    /* Wide iPads crop more of the image vertically. Keep the reading block
       above the fixed-size Continue control without changing its type size. */
    for (int i = 0; i < layout->prose_count; ++i) {
        frect_t *bounds = &layout->prose[i].region.bounds;
        for (int j = 0; j < layout->control_count; ++j) {
            const struct PageControl *control = &layout->controls[j];
            frect_t keep = control->item ? items : control->bounds;
            if (!control->circle && frect_overlaps(*bounds, keep))
                *bounds = frect_translate(*bounds, fvec2(0, keep.origin.y - HOTSPOT_TEXT_GAP
                                                        - frect_bottom_right(*bounds).y));
        }
    }
    /* Scene circles keep clear of the prose and of the inventory row. */
    struct TextRegion avoid[MAX_TEXT_REGIONS + 1];
    int avoid_count = 0;
    for (int i = 0; i < layout->prose_count; ++i) avoid[avoid_count++] = layout->prose[i].region;
    if (!fsize2_is_empty(items.size)) avoid[avoid_count++] = (struct TextRegion){items, 0, true};
    layout->spot_count = scene_layout_hotspots(image, viewport, targets, target_count,
                                               avoid, avoid_count, layout->spots);
    for (int i = 0; i < layout->spot_count; ++i) {
        const struct Hotspot *spot = &layout->spots[i];
        frect_t bounds = frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER, HOTSPOT_DIAMETER)), spot->center);
        add_control(layout, bounds, spot->choice, true);
    }
    /* A turn sits on the picture's edge: left and right at mid-height, back at the foot. */
    for (int i = 0; i < edge_count; ++i) {
        float inset = margin + HOTSPOT_DIAMETER / 2;
        fvec2_t center = fvec2(inset, viewport.height / 2);
        if (page->choices[edges[i]].edge == CHOICE_EDGE_RIGHT) center = fvec2(viewport.width - inset, viewport.height / 2);
        if (page->choices[edges[i]].edge == CHOICE_EDGE_BACK)
            center = fvec2(viewport.width / 2, viewport.height - inset - HOTSPOT_DIAMETER);
        if (layout->spot_count >= MAX_CHOICES) fail("too many circles on camera %s", page->camera);
        layout->spots[layout->spot_count++] = (struct Hotspot){center, center, edges[i]};
        add_control(layout, frect_center_at(frect_from_size(fsize2(HOTSPOT_DIAMETER, HOTSPOT_DIAMETER)), center),
                    edges[i], true);
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
        bool round = control->circle || control->item;
        if (round && frect_contains_point(control->caption, point)) return control;
        if (!frect_contains_point(control->bounds, point)) continue;
        if (round && !frect_ellipse_contains_point(control->bounds, point)) continue;
        return control;
    }
    return NULL;
}
