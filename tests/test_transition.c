#include "book.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

int main(void)
{
    struct Transition transition = {0};
    fsize2_t viewport = fsize2(1100, 800);
    struct TransitionFrame frame = transition_sample(&transition, 0, viewport);
    assert(!frame.active && frame.overlay_opacity == 1);
    transition_start(&transition, 10, fvec2(40, 60), viewport, HOTSPOT_DIAMETER / 2, true);
    frame = transition_sample(&transition, 10, viewport);
    assert(frame.active && frame.revealing && frame.radius == HOTSPOT_DIAMETER / 2);
    assert(frame.overlay_opacity == 0);
    float previous = frame.radius;
    for (int ms = 1; ms < 550; ++ms) {
        frame = transition_sample(&transition, 10 + ms / 1000.0, viewport);
        assert(frame.active && frame.revealing && frame.radius >= previous);
        assert(frame.overlay_opacity == 0);
        previous = frame.radius;
    }
    /* Every corner must be covered before overlays can appear. */
    frame = transition_sample(&transition, 10.551, viewport);
    assert(!frame.revealing && frame.active);
    assert(frame.radius > hypotf(1060, 740));
    frame = transition_sample(&transition, 10.7, viewport);
    assert(!frame.revealing && frame.overlay_opacity > .49f && frame.overlay_opacity < .51f);
    frame = transition_sample(&transition, 11, viewport);
    assert(!frame.active && !transition.active && frame.overlay_opacity == 1);

    /* Resize keeps the origin attached to the same relative point and covers new corners. */
    transition_start(&transition, 0, fvec2(40, 60), viewport, 24, true);
    frame = transition_sample(&transition, .551, fsize2_scale(viewport, 2));
    assert(fabsf(frame.center.x - 80) < .001f && fabsf(frame.center.y - 120) < .001f);
    assert(frame.radius > hypotf(2120, 1480));
    /* A delayed frame completes both phases, and same-art actions fade immediately. */
    frame = transition_sample(&transition, 60, viewport);
    assert(!frame.active && frame.overlay_opacity == 1);
    transition_start(&transition, 1, fvec2(0, 0), viewport, 0, false);
    frame = transition_sample(&transition, 1.15, viewport);
    assert(!frame.revealing && frame.active && frame.overlay_opacity > .49f);
    frame = transition_sample(&transition, 1.31, viewport);
    assert(!frame.active && frame.overlay_opacity == 1);
    puts("Book: reveal coverage, resize, phase ordering, delayed frames and same-art fade passed");
}
