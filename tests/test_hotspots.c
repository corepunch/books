#include "book.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

#define MAX_TEST_HOTSPOTS 6
#define MAX_TEST_VIEWPORTS 3
#define TEST_EPSILON .001f

static void check_layout(const struct Hotspot *spots, int count, fsize2_t viewport, frect_t prose)
{
    float radius=HOTSPOT_DIAMETER/2;
    frect_t safe=frect_inset(frect_from_size(viewport),fvec2(radius,radius));
    frect_t excluded=frect_inset(prose,fvec2(-radius-HOTSPOT_TEXT_GAP,-radius-HOTSPOT_TEXT_GAP));
    for (int i=0;i<count;++i) {
        assert(frect_covers_point(safe,spots[i].center));
        assert(!frect_contains_point(excluded,spots[i].center));
        assert(spots[i].choice==i); /* Layout must not remap actions. */
        for (int j=0;j<i;++j)
            assert(sqrtf(fvec2_length_squared(fvec2_sub(spots[i].center,spots[j].center))) >=
                   HOTSPOT_DIAMETER+HOTSPOT_GAP-TEST_EPSILON);
    }
}

int main(void)
{
    fsize2_t viewports[MAX_TEST_VIEWPORTS]={fsize2(1100,800),fsize2(1024,768),fsize2(1194,834)};
    for (int v=0;v<MAX_TEST_VIEWPORTS;++v) {
        fsize2_t viewport=viewports[v];
        frect_t prose=frect(fvec2(32,viewport.height*.66f),fsize2(viewport.width*.56f,viewport.height*.30f));
        struct Hotspot spots[MAX_TEST_HOTSPOTS]={
            {fvec2(24,24),{0},0}, {fvec2(24,24),{0},1},
            {fvec2(24,24),{0},2}, {fvec2(100,100),{0},3},
            {fvec2(100,viewport.height*.7f),{0},4}, {fvec2(700,300),{0},5}
        };
        fvec2_t anchors[MAX_TEST_HOTSPOTS];
        for (int i=0;i<MAX_TEST_HOTSPOTS;++i) anchors[i]=spots[i].anchor;
        assert(hotspots_place(spots,MAX_TEST_HOTSPOTS,viewport,prose));
        check_layout(spots,MAX_TEST_HOTSPOTS,viewport,prose);
        struct Hotspot again[MAX_TEST_HOTSPOTS];
        for (int i=0;i<MAX_TEST_HOTSPOTS;++i) again[i]=spots[i];
        assert(hotspots_place(again,MAX_TEST_HOTSPOTS,viewport,prose));
        for (int i=0;i<MAX_TEST_HOTSPOTS;++i) {
            assert(fvec2_length_squared(fvec2_sub(spots[i].anchor,anchors[i]))==0);
            assert(fvec2_length_squared(fvec2_sub(spots[i].center,again[i].center))==0);
        }
        assert(fvec2_length_squared(fvec2_sub(spots[5].center,spots[5].anchor))==0);
    }
    struct Hotspot spot={fvec2(50,50),{0},0};
    assert(!hotspots_place(&spot,1,fsize2(100,100),frect_from_size(fsize2(100,100))));
    assert(hotspots_place(NULL,0,fsize2(0,0),frect_from_size(fsize2(0,0))));
    puts("Book: hotspot gaps, coincident anchors, viewport edges, prose exclusion and stable actions passed");
    return 0;
}
