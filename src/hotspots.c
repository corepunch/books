#include "book.h"

#include <math.h>

#define HOTSPOT_SEARCH_STEP 2.0f
#define MAX_HOTSPOT_ANGLES 512
#define MIN_HOTSPOT_ANGLES 32

static bool available(fvec2_t point, const struct Hotspot *spots, int count,
                      frect_t safe, const struct TextRegion *regions, int region_count)
{
    if (!frect_covers_point(safe,point)) return false;
    for (int i=0;i<region_count;++i) {
        if (!regions[i].authored || fsize2_is_empty(regions[i].bounds.size)) continue;
        frect_t excluded=frect_inset(regions[i].bounds,
            fvec2(-HOTSPOT_DIAMETER/2-HOTSPOT_TEXT_GAP,-HOTSPOT_DIAMETER/2-HOTSPOT_TEXT_GAP));
        if (frect_contains_point(excluded,point)) return false;
    }
    float distance=HOTSPOT_DIAMETER+HOTSPOT_GAP;
    for (int i=0;i<count;++i)
        if (fvec2_length_squared(fvec2_sub(point,spots[i].center))<distance*distance) return false;
    return true;
}

bool hotspots_place_regions(struct Hotspot *spots, int count, fsize2_t viewport,
                            const struct TextRegion *regions, int region_count)
{
    float radius=HOTSPOT_DIAMETER/2;
    frect_t safe=frect_inset(frect_from_size(viewport),fvec2(radius,radius));
    if (count<0 || count>MAX_CHOICES || (count && fsize2_is_empty(safe.size))) return false;
    float limit=hypotf(viewport.width,viewport.height);
    /* Stable choice order, nearest available sampled point. Keep isolated anchors exact. */
    for (int i=0;i<count;++i) {
        spots[i].center=spots[i].anchor;
        if (available(spots[i].center,spots,i,safe,regions,region_count)) continue;
        bool found=false;
        for (float offset=HOTSPOT_SEARCH_STEP; offset<=limit && !found; offset+=HOTSPOT_SEARCH_STEP) {
            int angles=(int)ceilf(2*acosf(-1)*offset/HOTSPOT_SEARCH_STEP);
            if (angles<MIN_HOTSPOT_ANGLES) angles=MIN_HOTSPOT_ANGLES;
            if (angles>MAX_HOTSPOT_ANGLES) angles=MAX_HOTSPOT_ANGLES;
            for (int j=0;j<angles;++j) {
                float angle=2*acosf(-1)*j/angles;
                fvec2_t candidate=fvec2_add(spots[i].anchor,fvec2(offset*cosf(angle),offset*sinf(angle)));
                if (!available(candidate,spots,i,safe,regions,region_count)) continue;
                spots[i].center=candidate; found=true; break;
            }
        }
        if (!found) return false;
    }
    return true;
}

bool hotspots_place(struct Hotspot *spots, int count, fsize2_t viewport, frect_t prose)
{
    struct TextRegion region={prose,0,true};
    return hotspots_place_regions(spots,count,viewport,&region,1);
}
