#include "book.h"

#include <math.h>

/* Tune the choreography here; rendering consumes only the sampled frame. */
static const struct {
    double reveal_seconds, fade_seconds;
} timing = {0.55, 0.30};

static float smooth_progress(double elapsed, double duration)
{
    float t = (float)fmin(1, fmax(0, elapsed / duration));
    return t * t * (3 - 2 * t);
}

void transition_start(struct Transition *transition, double now, fvec2_t point,
                      fsize2_t viewport, float initial_radius, bool reveal)
{
    *transition = (struct Transition){
        .started = now,
        .origin = fvec2(point.x / fmaxf(1, viewport.width),
                        point.y / fmaxf(1, viewport.height)),
        .initial_radius = fmaxf(0, initial_radius),
        .active = true, .reveal = reveal
    };
}

struct TransitionFrame transition_sample(struct Transition *transition, double now,
                                         fsize2_t viewport)
{
    struct TransitionFrame frame = {.overlay_opacity = 1};
    if (!transition->active) return frame;
    double elapsed = fmax(0, now - transition->started);
    double reveal_seconds = transition->reveal ? timing.reveal_seconds : 0;
    frame.center = fvec2(transition->origin.x * viewport.width,
                         transition->origin.y * viewport.height);
    /* Recompute coverage on resize, including origins near any window edge. */
    float dx = fmaxf(fabsf(frame.center.x), fabsf(viewport.width - frame.center.x));
    float dy = fmaxf(fabsf(frame.center.y), fabsf(viewport.height - frame.center.y));
    float end_radius = fmaxf(transition->initial_radius, hypotf(dx, dy) + 1);
    frame.revealing = elapsed < reveal_seconds;
    frame.radius = transition->initial_radius + (end_radius - transition->initial_radius) *
                   smooth_progress(elapsed, timing.reveal_seconds);
    frame.overlay_opacity = smooth_progress(elapsed - reveal_seconds, timing.fade_seconds);
    frame.active = elapsed < reveal_seconds + timing.fade_seconds;
    transition->active = frame.active;
    return frame;
}
