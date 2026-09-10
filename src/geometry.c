#include "book.h"

#include <math.h>

fvec2_t fvec2(float x, float y) { return (fvec2_t){x, y}; }
fvec2_t fvec2_add(fvec2_t a, fvec2_t b) { return fvec2(a.x + b.x, a.y + b.y); }
fvec2_t fvec2_sub(fvec2_t a, fvec2_t b) { return fvec2(a.x - b.x, a.y - b.y); }
fvec2_t fvec2_scale(fvec2_t v, float scale) { return fvec2(v.x * scale, v.y * scale); }
fsize2_t fsize2(float width, float height) { return (fsize2_t){width, height}; }
fsize2_t fsize2_scale(fsize2_t size, float scale) { return fsize2(size.width * scale, size.height * scale); }
fsize2_t fsize2_max(fsize2_t a, fsize2_t b) { return fsize2(fmaxf(a.width, b.width), fmaxf(a.height, b.height)); }
bool fsize2_is_empty(fsize2_t size) { return size.width <= 0 || size.height <= 0; }
frect_t frect(fvec2_t origin, fsize2_t size) { return (frect_t){origin, size}; }
frect_t frect_from_size(fsize2_t size) { return frect(fvec2(0, 0), size); }
frect_t frect_translate(frect_t rect, fvec2_t offset) { return frect(fvec2_add(rect.origin, offset), rect.size); }
frect_t frect_inset(frect_t rect, fvec2_t inset)
{
    return frect(fvec2_add(rect.origin, inset),
                 fsize2(rect.size.width - 2 * inset.x, rect.size.height - 2 * inset.y));
}

frect_t frect_intersection(frect_t a, frect_t b)
{
    fvec2_t origin = fvec2(fmaxf(a.origin.x, b.origin.x), fmaxf(a.origin.y, b.origin.y));
    if (fsize2_is_empty(a.size) || fsize2_is_empty(b.size)) return frect(origin, fsize2(0, 0));
    float right = fminf(a.origin.x + a.size.width, b.origin.x + b.size.width);
    float bottom = fminf(a.origin.y + a.size.height, b.origin.y + b.size.height);
    return frect(origin, fsize2(fmaxf(0, right - origin.x), fmaxf(0, bottom - origin.y)));
}

bool frect_contains_point(frect_t rect, fvec2_t point)
{
    return !fsize2_is_empty(rect.size) &&
        point.x >= rect.origin.x && point.x < rect.origin.x + rect.size.width &&
        point.y >= rect.origin.y && point.y < rect.origin.y + rect.size.height;
}

bool frect_covers_point(frect_t rect, fvec2_t point)
{
    return rect.size.width >= 0 && rect.size.height >= 0 &&
        point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width &&
        point.y >= rect.origin.y && point.y <= rect.origin.y + rect.size.height;
}

bool frect_overlaps(frect_t a, frect_t b) { return !fsize2_is_empty(frect_intersection(a, b).size); }

static int imin(int a, int b) { return a < b ? a : b; }
static int imax(int a, int b) { return a > b ? a : b; }

ivec2_t ivec2(int x, int y) { return (ivec2_t){x, y}; }
ivec2_t ivec2_add(ivec2_t a, ivec2_t b) { return ivec2(a.x + b.x, a.y + b.y); }
ivec2_t ivec2_sub(ivec2_t a, ivec2_t b) { return ivec2(a.x - b.x, a.y - b.y); }
ivec2_t ivec2_scale(ivec2_t v, int scale) { return ivec2(v.x * scale, v.y * scale); }
isize2_t isize2(int width, int height) { return (isize2_t){width, height}; }
isize2_t isize2_scale(isize2_t size, int scale) { return isize2(size.width * scale, size.height * scale); }
isize2_t isize2_max(isize2_t a, isize2_t b) { return isize2(imax(a.width, b.width), imax(a.height, b.height)); }
bool isize2_is_empty(isize2_t size) { return size.width <= 0 || size.height <= 0; }
irect_t irect(ivec2_t origin, isize2_t size) { return (irect_t){origin, size}; }
irect_t irect_from_size(isize2_t size) { return irect(ivec2(0, 0), size); }
irect_t irect_translate(irect_t rect, ivec2_t offset) { return irect(ivec2_add(rect.origin, offset), rect.size); }
irect_t irect_inset(irect_t rect, ivec2_t inset)
{
    return irect(ivec2_add(rect.origin, inset),
                 isize2(rect.size.width - 2 * inset.x, rect.size.height - 2 * inset.y));
}

irect_t irect_intersection(irect_t a, irect_t b)
{
    ivec2_t origin = ivec2(imax(a.origin.x, b.origin.x), imax(a.origin.y, b.origin.y));
    if (isize2_is_empty(a.size) || isize2_is_empty(b.size)) return irect(origin, isize2(0, 0));
    int right = imin(a.origin.x + a.size.width, b.origin.x + b.size.width);
    int bottom = imin(a.origin.y + a.size.height, b.origin.y + b.size.height);
    return irect(origin, isize2(imax(0, right - origin.x), imax(0, bottom - origin.y)));
}

bool irect_contains_point(irect_t rect, ivec2_t point)
{
    return !isize2_is_empty(rect.size) &&
        point.x >= rect.origin.x && point.x < rect.origin.x + rect.size.width &&
        point.y >= rect.origin.y && point.y < rect.origin.y + rect.size.height;
}

bool irect_covers_point(irect_t rect, ivec2_t point)
{
    return rect.size.width >= 0 && rect.size.height >= 0 &&
        point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width &&
        point.y >= rect.origin.y && point.y <= rect.origin.y + rect.size.height;
}

bool irect_overlaps(irect_t a, irect_t b) { return !isize2_is_empty(irect_intersection(a, b).size); }

fvec2_t ivec2_to_float(ivec2_t v) { return fvec2((float)v.x, (float)v.y); }
fsize2_t isize2_to_float(isize2_t size) { return fsize2((float)size.width, (float)size.height); }
frect_t irect_to_float(irect_t rect) { return frect(ivec2_to_float(rect.origin), isize2_to_float(rect.size)); }
ivec2_t fvec2_floor(fvec2_t v) { return ivec2((int)floorf(v.x), (int)floorf(v.y)); }
isize2_t fsize2_ceil(fsize2_t size) { return isize2((int)ceilf(size.width), (int)ceilf(size.height)); }
isize2_t fsize2_round(fsize2_t size) { return isize2((int)lroundf(size.width), (int)lroundf(size.height)); }
fvec2_t fvec2_with_x(fvec2_t v, float x) { return fvec2(x, v.y); }
fvec2_t fvec2_with_y(fvec2_t v, float y) { return fvec2(v.x, y); }
float fvec2_length_squared(fvec2_t v) { return v.x * v.x + v.y * v.y; }
fvec2_t frect_bottom_right(frect_t rect) { return fvec2_add(rect.origin, fvec2(rect.size.width, rect.size.height)); }
fvec2_t frect_center(frect_t rect) { return fvec2_add(rect.origin, fvec2(rect.size.width / 2, rect.size.height / 2)); }
frect_t frect_center_at(frect_t rect, fvec2_t center)
{
    return frect(fvec2_sub(center, fvec2(rect.size.width / 2, rect.size.height / 2)), rect.size);
}

frect_t frect_scale(frect_t rect, float scale) { return frect(fvec2_scale(rect.origin, scale), fsize2_scale(rect.size, scale)); }
frect_t frect_expand(frect_t rect, fsize2_t extra)
{
    return frect(rect.origin, fsize2(rect.size.width + extra.width, rect.size.height + extra.height));
}

frect_t frect_flip_y(frect_t rect, float height)
{
    return frect(fvec2(rect.origin.x, height - rect.origin.y - rect.size.height), rect.size);
}

frect_t frect_cover(fsize2_t image, frect_t bounds)
{
    if (fsize2_is_empty(image) || fsize2_is_empty(bounds.size)) return frect(bounds.origin, fsize2(0, 0));
    float scale = fmaxf(bounds.size.width / image.width, bounds.size.height / image.height);
    fsize2_t size = fsize2_scale(image, scale);
    return frect(fvec2_add(bounds.origin, fvec2((bounds.size.width - size.width) / 2,
                                               (bounds.size.height - size.height) / 2)), size);
}

bool frect_ellipse_contains_point(frect_t rect, fvec2_t point)
{
    if (fsize2_is_empty(rect.size)) return false;
    fvec2_t delta = fvec2_sub(point, frect_center(rect));
    return fvec2_length_squared(fvec2(delta.x / (rect.size.width / 2), delta.y / (rect.size.height / 2))) <= 1;
}
