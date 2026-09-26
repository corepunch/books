#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stb_image.h>

static void json_string(const char *s)
{
    putchar('"');
    for (const unsigned char *p=(const unsigned char *)s; *p; ++p) {
        if (*p=='"' || *p=='\\') printf("\\%c",*p);
        else if (*p<32) printf("\\u%04x",*p);
        else putchar(*p);
    }
    putchar('"');
}

static struct PageLayout layout;

/* The same immutable page, layout and dispatcher used by the native UI. */
static void dump(fsize2_t viewport)
{
    const struct BookPage *page = book_page();
    printf("{\"room\":"); json_string(book_object(page->room)->key);
    printf(",\"focus\":\"\""); /* Compatibility with earlier snapshots. */
    printf(",\"kind\":"); json_string(book_page_kind_name(page->kind));
    printf(",\"ending\":"); json_string(book_ending_kind_name(page->ending));
    printf(",\"image\":"); json_string(page->image);
    printf(",\"text\":"); json_string(page->text);
    printf(",\"choices\":[");
    for (int i = 0; i < page->choice_count; ++i) {
        const struct Choice *choice = &page->choices[i];
        printf("%s{\"kind\":", i ? "," : ""); json_string(book_choice_kind_name(choice->kind));
        printf(",\"label\":"); json_string(choice->label);
        printf(",\"command\":"); json_string(choice->command);
        printf(",\"object\":"); json_string(book_object(choice->object)->key); printf("}");
    }
    isize2_t image = isize2(0, 0);
    int channels = 0;
    if (*page->image && !stbi_info(page->image, &image.width, &image.height, &channels))
        fail("cannot inspect image: %s", page->image);
    page_layout(page, image, viewport, &layout);
    printf("],\"hotspots\":[");
    for (int i = 0; i < layout.spot_count; ++i) {
        const struct Hotspot *spot = &layout.spots[i];
        printf("%s{\"object\":", i ? "," : "");
        json_string(book_object(page->choices[spot->choice].object)->key);
        printf(",\"choice\":%d,\"x\":%.6f,\"y\":%.6f,\"anchor_x\":%.6f,\"anchor_y\":%.6f}",
               spot->choice, spot->center.x, spot->center.y, spot->anchor.x, spot->anchor.y);
    }
    printf("],\"controls\":[");
    for (int i = 0; i < layout.control_count; ++i) {
        const struct PageControl *control = &layout.controls[i];
        const struct Choice *choice = &page->choices[control->choice];
        printf("%s{\"choice\":%d,\"kind\":", i ? "," : "", control->choice);
        json_string(book_choice_kind_name(choice->kind));
        printf(",\"label\":"); json_string(choice->label);
        printf(",\"circle\":%s,\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f",
               control->circle ? "true" : "false", control->bounds.origin.x, control->bounds.origin.y,
               control->bounds.size.width, control->bounds.size.height);
        printf(",\"caption\":{\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f}}",
               control->caption.origin.x, control->caption.origin.y,
               control->caption.size.width, control->caption.size.height);
    }
    printf("],\"text_regions\":[");
    for (int i = 0; i < layout.prose_count; ++i) {
        const struct ProseLayout *block = &layout.prose[i];
        struct TextRegion r = block->region;
        printf("%s{\"authored\":%s,\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f,"
               "\"font_size\":%.6f,\"content_height\":%.6f,\"text\":", i ? "," : "", r.authored ? "true" : "false",
               r.bounds.origin.x, r.bounds.origin.y, r.bounds.size.width, r.bounds.size.height,
               r.font_size, block->content_height);
        json_string(block->text); putchar('}');
    }
    struct TextRegion region = layout.prose[0].region;
    printf("],\"text_region\":{\"authored\":%s,\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f,"
           "\"preferred_size\":%.6f,\"font_size\":%.6f,\"content_height\":%.6f}}\n",
           region.authored ? "true" : "false", region.bounds.origin.x, region.bounds.origin.y,
           region.bounds.size.width, region.bounds.size.height, region.font_size, region.font_size,
           layout.prose_count ? layout.prose[0].content_height : 0);
    fflush(stdout);
}

void headless_catalog(void)
{
    putchar('['); int count=0;
    for (int i=1;i<MAX_OBJECTS;++i) {
        if (!*book_object(i)->key) continue;
        int room=book_object_room(i);
        if (!room) continue;
        printf("%s{\"id\":",count++ ? "," : ""); json_string(book_object(i)->key);
        printf(",\"room\":"); json_string(book_object(room)->key); putchar('}');
    }
    puts("]");
}

void headless_run(bool interactive, fsize2_t viewport)
{
    ui_init(); /* Font metrics only; measuring text never creates GPU textures. */
    dump(viewport);
    command_t line;
    while (interactive && fgets(line,sizeof(line),stdin)) {
        line[strcspn(line,"\r\n")]=0;
        if (!strcmp(line,":back") || !strcmp(line,":continue")) book_continue();
        else if (!strcmp(line,":reload")) { scene_shutdown(); book_reload(); }
        else if (!strncmp(line,":choose ",8)) {
            char *end;
            long index = strtol(line + 8, &end, 10);
            if (end != line + 8 && !*end && index >= 0 && index < MAX_CHOICES) book_action((int)index);
        }
        else if (!strncmp(line,":tap ",5)) {
            fvec2_t point;
            if (sscanf(line + 5, "%f %f", &point.x, &point.y) == 2) {
                const struct PageControl *control = page_hit_test(&layout, point);
                if (control) book_action(control->choice);
            }
        }
        else if (!strncmp(line,":focus ",7)) book_choose_object(line + 7);
        else book_command(line);
        dump(viewport);
    }
    text_shutdown();
}
