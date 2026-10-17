#include "book.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define MAX_RENDERER_IMAGES 2 /* Both sides of a page transition stay resident. */
#define MAX_RENDERER_ICONS MAX_STORY_ICONS /* Every carried thing's icon stays resident. */
/* Icons are reduced to this shortest side, enough for an item disc on a 4x display. */
#define ICON_TEXTURE_PIXELS ((int)(ITEM_DIAMETER * 4))

struct PageImage {
    texture_t texture;
    isize2_t size;
    char *path;
};
struct ImageCache {
    struct PageImage *slots;
    int capacity, recent, min_side;
};
static struct PageImage page_images[MAX_RENDERER_IMAGES], icon_images[MAX_RENDERER_ICONS];
static struct ImageCache pages = {page_images, MAX_RENDERER_IMAGES, 0, 0};
static struct ImageCache icons = {icon_images, MAX_RENDERER_ICONS, 0, ICON_TEXTURE_PIXELS};

/* Box-filter by a whole factor, weighting colour by alpha so painted edges stay clean. */
static unsigned char *image_reduce(const unsigned char *pixels, isize2_t *size, int min_side)
{
    int factor = min_side > 0 ? (size->width < size->height ? size->width : size->height) / min_side : 1;
    if (factor < 2) return NULL;
    isize2_t reduced = isize2(size->width / factor, size->height / factor);
    unsigned char *out = malloc((size_t)reduced.width * reduced.height * 4);
    if (!out) fail("cannot allocate reduced image");
    for (int y = 0; y < reduced.height; ++y)
        for (int x = 0; x < reduced.width; ++x) {
            unsigned long sum[4] = {0};
            for (int v = 0; v < factor; ++v) {
                const unsigned char *src = pixels + (((size_t)(y * factor + v) * size->width) + x * factor) * 4;
                for (int u = 0; u < factor; ++u, src += 4) {
                    for (int c = 0; c < 3; ++c) sum[c] += (unsigned long)src[c] * src[3];
                    sum[3] += src[3];
                }
            }
            unsigned char *dst = out + ((size_t)y * reduced.width + x) * 4;
            for (int c = 0; c < 3; ++c) dst[c] = sum[3] ? (unsigned char)(sum[c] / sum[3]) : 0;
            dst[3] = (unsigned char)(sum[3] / ((unsigned long)factor * factor));
        }
    *size = reduced;
    return out;
}

static struct PageImage *image_load(struct ImageCache *cache, const char *path)
{
    if (!path || !*path) return NULL;
    for (int i = 0; i < cache->capacity; ++i) {
        if (cache->slots[i].path && !strcmp(path, cache->slots[i].path)) {
            cache->recent = i;
            return cache->slots[i].texture ? &cache->slots[i] : NULL;
        }
    }
    /* Keep every image a frame draws resident; never decode pictures per frame. */
    cache->recent = (cache->recent + 1) % cache->capacity;
    struct PageImage *image = &cache->slots[cache->recent];
    renderer_texture_destroy(image->texture);
    free(image->path);
    *image = (struct PageImage){0};
    image->path = malloc(strlen(path) + 1);
    if (!image->path) fail("cannot allocate image path");
    strcpy(image->path, path);
    int channels;
    unsigned char *pixels = stbi_load(path, &image->size.width, &image->size.height, &channels, 4);
    if (!pixels) return fprintf(stderr, "Cannot load image %s: %s\n", path, stbi_failure_reason()), NULL;
    unsigned char *reduced = image_reduce(pixels, &image->size, cache->min_side);
    image->texture = renderer_texture_create(image->size, false, reduced ? reduced : pixels);
    free(reduced);
    stbi_image_free(pixels);
    return image;
}

isize2_t renderer_image_size(const char *path)
{
    struct PageImage *image = image_load(&pages, path);
    return image ? image->size : isize2(0, 0);
}

bool renderer_image(const char *path, frect_t bounds)
{
    struct PageImage *image = image_load(&pages, path);
    if (!image) return false;
    renderer_quad(bounds, 0xffffffff, image->texture, false);
    return true;
}

bool renderer_icon(const char *path, frect_t bounds)
{
    struct PageImage *image = image_load(&icons, path);
    if (!image) return false;
    renderer_quad(frect_cover(isize2_to_float(image->size), bounds), 0xffffffff, image->texture, false);
    return true;
}

void renderer_shutdown(void)
{
    renderer_invalidate_image();
    metal_shutdown();
}

static void cache_clear(struct ImageCache *cache)
{
    for (int i = 0; i < cache->capacity; ++i) {
        renderer_texture_destroy(cache->slots[i].texture);
        free(cache->slots[i].path);
        cache->slots[i] = (struct PageImage){0};
    }
    cache->recent = 0;
}

void renderer_invalidate_image(void)
{
    cache_clear(&pages);
    cache_clear(&icons);
}
