#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define MAX_RENDERER_IMAGES 3 /* Two page images plus the Back button asset. */

struct PageImage {
    texture_t texture;
    isize2_t size;
    char *path;
};
static struct {
    struct PageImage images[MAX_RENDERER_IMAGES];
    int recent_image;
} r;

static struct PageImage *image_load(const char *path)
{
    if (!path || !*path) return NULL;
    for (int i = 0; i < MAX_RENDERER_IMAGES; ++i) {
        if (r.images[i].path && !strcmp(path, r.images[i].path)) {
            r.recent_image = i;
            return r.images[i].texture ? &r.images[i] : NULL;
        }
    }
    /* Keep both sides of a reveal resident; never decode alternating page images per frame. */
    r.recent_image = (r.recent_image + 1) % MAX_RENDERER_IMAGES;
    struct PageImage *image = &r.images[r.recent_image];
    renderer_texture_destroy(image->texture);
    free(image->path);
    *image = (struct PageImage){0};
    image->path = malloc(strlen(path) + 1);
    if (!image->path) fail("cannot allocate image path");
    strcpy(image->path, path);
    int channels;
    unsigned char *pixels = stbi_load(path, &image->size.width, &image->size.height, &channels, 4);
    if (!pixels) return fprintf(stderr, "Cannot load image %s: %s\n", path, stbi_failure_reason()), NULL;
    image->texture = renderer_texture_create(image->size, false, pixels);
    stbi_image_free(pixels);
    return image;
}

isize2_t renderer_image_size(const char *path)
{
    struct PageImage *image = image_load(path);
    return image ? image->size : isize2(0, 0);
}

bool renderer_image(const char *path, frect_t bounds)
{
    struct PageImage *image = image_load(path);
    if (!image) return false;
    renderer_quad(bounds, 0xffffffff, image->texture, false);
    return true;
}

void renderer_shutdown(void)
{
    renderer_invalidate_image();
    metal_shutdown();
}

void renderer_invalidate_image(void)
{
    for (int i = 0; i < MAX_RENDERER_IMAGES; ++i) {
        renderer_texture_destroy(r.images[i].texture);
        free(r.images[i].path);
        r.images[i] = (struct PageImage){0};
    }
    r.recent_image = 0;
}
