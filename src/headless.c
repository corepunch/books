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

/* The headless interface exercises exactly the same C page/actions as the UI. */
static void dump(void)
{
    printf("{\"room\":"); json_string(book.objects[book.room].key);
    printf(",\"focus\":"); json_string(book.objects[book.focus].key);
    printf(",\"kind\":"); json_string(book.ended ? "ended" : book.beat ? "beat" : book.focus ? "focus" : "room");
    printf(",\"image\":"); json_string(book.image);
    printf(",\"text\":"); json_string(book.text);
    printf(",\"choices\":[");
    for (int i=0;i<book.choice_count;++i) {
        struct Choice *c=&book.choices[i];
        printf("%s{\"label\":",i ? "," : ""); json_string(c->label);
        printf(",\"command\":"); json_string(c->command);
        printf(",\"object\":"); json_string(book.objects[c->object].key); printf("}");
    }
    printf("],\"hotspots\":[");
    scene_load(book.rooms,book.camera);
    isize2_t image=isize2(0,0);
    fsize2_t viewport=fsize2(UI_WIDTH,UI_HEIGHT);
    frect_t safe=frect_inset(frect_from_size(viewport),fvec2(HOTSPOT_DIAMETER/2,HOTSPOT_DIAMETER/2));
    int channels=0,count=0;
    if (*book.image && !stbi_info(book.image,&image.width,&image.height,&channels)) fail("cannot inspect JPEG: %s",book.image);
    if (!book.beat && !book.focus) {
        for (int i=0;i<book.choice_count;++i) {
            struct Choice *c=&book.choices[i]; fvec2_t point;
            if (c->focus && scene_project_anchor(book.objects[c->object].key,image,viewport,&point) &&
                frect_covers_point(safe,point)) {
                printf("%s{\"object\":",count++ ? "," : ""); json_string(book.objects[c->object].key);
                printf(",\"x\":%.6f,\"y\":%.6f}",point.x,point.y);
            }
        }
    }
    printf("]}\n"); fflush(stdout);
}

void headless_catalog(void)
{
    putchar('['); int count=0;
    for (int i=1;i<MAX_OBJECTS;++i) {
        if (!*book.objects[i].key) continue;
        int room=book_object_room(i);
        if (!room) continue;
        printf("%s{\"id\":",count++ ? "," : ""); json_string(book.objects[i].key);
        printf(",\"room\":"); json_string(book.objects[room].key); putchar('}');
    }
    puts("]");
}

void headless_run(bool interactive)
{
    dump();
    command_t line;
    while (interactive && fgets(line,sizeof(line),stdin)) {
        line[strcspn(line,"\r\n")]=0;
        if (!strcmp(line,":back") || !strcmp(line,":continue")) book_back();
        else if (!strcmp(line,":reload")) { scene_shutdown(); book_reload(); }
        else if (!strncmp(line,":choose ",8)) book_action(atoi(line+8));
        else if (!strncmp(line,":focus ",7)) {
            for (int i=1;i<MAX_OBJECTS;++i) if (!strcmp(book.objects[i].key,line+7)) { book_focus_object(i); break; }
        } else book_command(line,0);
        dump();
    }
}
