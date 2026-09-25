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
static void dump(void)
{
    const struct BookPage *page = book_page();
    printf("{\"room\":"); json_string(book_object(page->room)->key);
    printf(",\"focus\":\"\""); /* Compatibility with earlier snapshots. */
    printf(",\"kind\":"); json_string(book_page_kind_name(page->kind));
    printf(",\"image\":"); json_string(page->image);
    printf(",\"overlay\":"); json_string(page->overlay);
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
    page_layout(page, image, fsize2(UI_WIDTH, UI_HEIGHT), &layout);
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
        printf(",\"circle\":%s,\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f}",
               control->circle ? "true" : "false", control->bounds.origin.x, control->bounds.origin.y,
               control->bounds.size.width, control->bounds.size.height);
    }
    struct TextRegion region = layout.region;
    printf("],\"text_region\":{\"authored\":%s,\"x\":%.6f,\"y\":%.6f,\"width\":%.6f,\"height\":%.6f,"
           "\"preferred_size\":%.6f,\"font_size\":%.6f,\"content_height\":%.6f}}\n",
           region.authored ? "true" : "false", region.bounds.origin.x, region.bounds.origin.y,
           region.bounds.size.width, region.bounds.size.height, region.font_size, layout.font_size,
           text_height(page->text, layout.font_size, region.bounds.size.width));
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

void headless_run(bool interactive)
{
    ui_init(); /* Font metrics only; measuring text never creates GPU textures. */
    dump();
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
        dump();
    }
    text_shutdown();
}
