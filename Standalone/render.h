#ifndef BOOK_RENDER_H
#define BOOK_RENDER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

bool renderer_init(const char *font_path);
void renderer_resize(int width, int height, float scale);
void renderer_clip(float x, float y, float width, float height);
void renderer_unclip(void);
bool renderer_screenshot(const char *path);
void renderer_clear(void);
void renderer_rect(float x, float y, float width, float height, uint32_t rgba);
float renderer_text(const char *text, float x, float y, float size,
                    float max_width, uint32_t rgba);
bool renderer_image_size(const char *path, int *width, int *height);
bool renderer_image(const char *path, float x, float y, float width, float height);
void renderer_scene(const float *vertices, size_t vertex_count, const float *view_projection,
                    float x, float y, float width, float height);
void renderer_lighting(const float ambient[3], const float background[3],
                       const float *lights, size_t count);
void renderer_shutdown(void);

#endif
