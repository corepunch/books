#include "book.h"

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <platform.h>

struct Hit { frect_t bounds; int action; bool circle; };
static struct Hit hits[MAX_HITS];
static int hit_count,scroll,max_scroll,show_text=1;
static command_t input;
static const char *screenshot_path;

static float story_text(const char *text,fvec2_t origin,float size,float width)
{
    text_draw(text,fvec2_add(origin,fvec2(1,2)),size,width,0x120B07E6);
    return text_draw(text,origin,size,width,0xF4E6CAFF);
}

static void add_hit(frect_t bounds,int action,bool circle)
{
    if (!fsize2_is_empty(bounds.size) && hit_count<MAX_HITS)
        hits[hit_count++]=(struct Hit){bounds,action,circle};
}

static void draw(void)
{
    struct AXsize size; axGetSize(&size);
    isize2_t pixels=isize2(size.width,size.height);
    fsize2_t window=isize2_to_float(pixels);
    frect_t viewport=frect_from_size(window);
    axBeginPaint(); renderer_resize(pixels,axGetScaling()); renderer_clear();
    hit_count=0;
    isize2_t image=isize2(0,0);
    if (*book.image) {
        image=renderer_image_size(book.image);
        if (isize2_is_empty(image)) fail("cannot decode %s",book.image);
        renderer_image(book.image,frect_cover(isize2_to_float(image),viewport));
    } else renderer_rect(viewport,0x211C18FF);
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
        char text[sizeof(input)+sizeof("> ")]; snprintf(text,sizeof(text),"> %s",input);
        frect_t prompt=frect(fvec2(32,window.height-40),fsize2(window.width-64,32));
        renderer_clip(prompt);
        story_text(text,prompt.origin,20,prompt.size.width); renderer_unclip();
    }
    if (screenshot_path && !renderer_screenshot(screenshot_path)) fail("cannot write screenshot");
    axEndPaint();
}

static void reload(void)
{
    scene_shutdown();
    renderer_invalidate_image();
    book_reload();
    scene_load(book.rooms,book.camera);
}

static void key(struct AXmessage *event)
{
    if (event->keyCode==AX_KEY_TAB) { show_text=!show_text; hit_count=0; }
    else if (event->keyCode==AX_KEY_F5) reload();
    else if (event->keyCode==AX_KEY_ESCAPE) { if (*input) input[0]=0; else book_back(); }
    else if (event->keyCode==AX_KEY_ENTER) {
        if (*input) { book_command(input,0); input[0]=0; }
        else if (book.beat) book_back();
    } else if (event->keyCode==AX_KEY_BACKSPACE) {
        size_t n=strlen(input);
        if (n) { do { --n; } while (n && ((unsigned char)input[n]&0xC0)==0x80); input[n]=0; }
    } else if (event->keyCode==AX_KEY_DOWNARROW) scroll=MIN(max_scroll,scroll+40);
    else if (event->keyCode==AX_KEY_UPARROW) scroll=MAX(0,scroll-40);
    else {
        char utf8[sizeof(event->lParam)+1]; memcpy(utf8,&event->lParam,sizeof(event->lParam)); utf8[sizeof(event->lParam)]=0;
        if (!(event->wParam&(AX_MOD_CTRL|AX_MOD_CMD|AX_MOD_ALT)) &&
            (unsigned char)utf8[0]>=32 && (unsigned char)utf8[0]!=127 && strlen(input)+strlen(utf8)<sizeof(input)) strcat(input,utf8);
    }
}

void ui_run(bool smoke, const char *screenshot)
{
    screenshot_path = screenshot;
    axInit();
    if (!axCreateWindow("Book",UI_WIDTH,UI_HEIGHT,AX_WINDOW_RESIZABLE|AX_WINDOW_DOUBLEBUFFER)) fail("cannot create window");
    axMakeCurrentContext();
    filePath_t font; snprintf(font,sizeof(font),"%s/fonts/Literata-VariableFont_opsz,wght.ttf",book.root);
    if (!(renderer_init() && text_init(font))) fail("cannot initialize graphics or load Literata");
    bool running=true,dirty=true; int frames=0;
    while (running) {
        struct AXmessage event;
        while (axPeekMessage(&event)) {
            dirty=true;
            if (event.message==kEventWindowClosed) running=false;
            else if (event.message==kEventKeyDown) key(&event);
            else if (event.message==kEventScrollWheel) scroll=CLAMP(scroll-event.dy*30,0,max_scroll);
            else if (event.message==kEventLeftButtonDown) {
                for (int i=hit_count-1;i>=0;--i) {
                    struct Hit h=hits[i];
                    fvec2_t point=fvec2(event.x,event.y);
                    if (frect_contains_point(h.bounds,point)) {
                        if (h.circle && !frect_ellipse_contains_point(h.bounds,point)) continue;
                        book_action(h.action); scroll=0; hit_count=0; break;
                    }
                }
            }
        }
        if (!running) break;
        if (dirty || smoke) { draw(); dirty=false; }
        if (smoke && ++frames>=3) break;
        axWaitMessage(smoke ? 16 : 250);
    }
    text_shutdown(); renderer_shutdown(); axShutdown();
}
