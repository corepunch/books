#include "book.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

#define GEOMETRY_EPSILON 0.0001f

static void expect_rect(frect_t actual, frect_t expected)
{
    assert(fabsf(actual.origin.x - expected.origin.x) < GEOMETRY_EPSILON);
    assert(fabsf(actual.origin.y - expected.origin.y) < GEOMETRY_EPSILON);
    assert(fabsf(actual.size.width - expected.size.width) < GEOMETRY_EPSILON);
    assert(fabsf(actual.size.height - expected.size.height) < GEOMETRY_EPSILON);
}

int main(void)
{
    /* Crop both orientations around the center of an offset viewport. */
    frect_t viewport = frect(fvec2(10, 20), fsize2(100, 100));
    expect_rect(frect_cover(fsize2(200, 100), viewport), frect(fvec2(-40, 20), fsize2(200, 100)));
    expect_rect(frect_cover(fsize2(100, 200), viewport), frect(fvec2(10, -30), fsize2(100, 200)));
    assert(fsize2_is_empty(frect_cover(fsize2(0, 100), viewport).size));
    assert(fsize2_is_empty(frect_cover(fsize2(100, 100), frect_from_size(fsize2(-1, 100))).size));

    /* Authored image regions follow the same centered crop as the artwork. */
    frect_t relative = frect(fvec2(.25f, .25f), fsize2(.5f, .5f));
    expect_rect(frect_relative(relative, frect_cover(fsize2(200, 100), viewport)),
                frect(fvec2(10, 45), fsize2(100, 50)));
    expect_rect(frect_relative(relative, frect_cover(fsize2(100, 200), viewport)),
                frect(fvec2(35, 20), fsize2(50, 100)));

    /* Clipped text rows must not be clickable beyond the visible region. */
    frect_t row = frect_intersection(frect(fvec2(10, 10), fsize2(100, 30)), viewport);
    expect_rect(row, frect(fvec2(10, 20), fsize2(100, 20)));
    assert(frect_contains_point(row, fvec2(10, 20)));
    assert(!frect_contains_point(row, fvec2(110, 20)));
    assert(!frect_contains_point(row, fvec2(10, 40)));
    assert(!frect_contains_point(row, fvec2(10, 19)));
    assert(frect_covers_point(row, fvec2(110, 40)));
    assert(!frect_overlaps(row, frect(fvec2(110, 20), fsize2(20, 20))));
    assert(fsize2_is_empty(frect_intersection(row, frect(fvec2(-20, -20), fsize2(5, 5))).size));
    assert(fsize2_is_empty(frect_intersection(row, frect(fvec2(10, 20), fsize2(-5, 5))).size));
    assert(!frect_contains_point(frect_from_size(fsize2(0, 0)), fvec2(0, 0)));
    assert(!frect_covers_point(frect_inset(viewport, fvec2(60, 60)), frect_center(viewport)));

    /* Circles include their circumference but exclude bounding-box corners. */
    frect_t marker = frect_center_at(frect_from_size(fsize2(48, 48)), fvec2(80, 60));
    assert(frect_ellipse_contains_point(marker, fvec2(80, 60)));
    assert(frect_ellipse_contains_point(marker, fvec2(56, 60)));
    assert(!frect_ellipse_contains_point(marker, fvec2(56, 36)));
    assert(!frect_ellipse_contains_point(frect_from_size(fsize2(0, 48)), fvec2(0, 0)));

    /* Translate, inset and intersect integer pixels before converting to logical coordinates. */
    irect_t pixels = irect_inset(irect_translate(irect_from_size(isize2(100, 80)), ivec2(10, 20)), ivec2(2, 3));
    expect_rect(irect_to_float(pixels), frect(fvec2(12, 23), fsize2(96, 74)));
    assert(irect_contains_point(pixels, ivec2(12, 23)));
    assert(!irect_contains_point(pixels, ivec2(108, 97)));
    assert(irect_covers_point(pixels, ivec2(108, 97)));
    assert(!irect_overlaps(pixels, irect(ivec2(108, 23), isize2(5, 5))));
    assert(isize2_is_empty(irect_intersection(pixels, irect_from_size(isize2(1, 1))).size));

    /* Fractional display scaling must preserve the GL scissor rounding convention. */
    frect_t clip = frect_scale(frect_flip_y(frect(fvec2(0.25f, 20.25f), fsize2(40.25f, 10.25f)), 100), 1.5f);
    irect_t scissor = irect(fvec2_floor(clip.origin), fsize2_ceil(fsize2_max(clip.size, fsize2(0, 0))));
    expect_rect(irect_to_float(scissor), frect(fvec2(0, 104), fsize2(61, 16)));
    assert(fvec2_floor(fvec2(-0.25f, 0)).x == -1);
    isize2_t framebuffer = fsize2_round(fsize2_scale(isize2_to_float(isize2(101, 81)), 1.5f));
    assert(framebuffer.width == 152 && framebuffer.height == 122);

    /* Glyph bearings are applied before font scaling and line placement. */
    frect_t glyph = frect_translate(frect_scale(frect_translate(
        irect_to_float(irect(ivec2(-2, -10), isize2(8, 12))), fvec2(0, 12)), 0.5f), fvec2(20, 30));
    expect_rect(glyph, frect(fvec2(19, 31), fsize2(4, 6)));
    puts("Book: geometry crops, clipping, hit boundaries, pixel scaling and glyph placement passed");
    return 0;
}
