#include "book.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STB_TRUETYPE_IMPLEMENTATION
#include <stb_truetype.h>

#define FONT_PIXELS 72.0f
#define MAX_TEXT_FIT_STEPS 12

struct Glyph {
    int codepoint;
    irect_t bounds;
    float advance;
    texture_t texture;
};

static struct {
    unsigned char *font_data;
    stbtt_fontinfo font;
    float font_scale, ascent, line_height, cap_height;
    int glyph_count;
    struct Glyph glyphs[MAX_GLYPHS];
} t;

bool text_init(const char *font_path)
{
    FILE *file = fopen(font_path, "rb");
    if (!file) return fprintf(stderr, "Cannot open font: %s\n", font_path), false;
    fseek(file, 0, SEEK_END);
    long bytes = ftell(file);
    rewind(file);
    t.font_data = bytes > 0 ? malloc((size_t)bytes) : NULL;
    bool loaded = t.font_data && fread(t.font_data, 1, (size_t)bytes, file) == (size_t)bytes;
    fclose(file);
    if (!loaded || !stbtt_InitFont(&t.font, t.font_data, 0)) {
        text_shutdown();
        return false;
    }
    t.font_scale = stbtt_ScaleForPixelHeight(&t.font, FONT_PIXELS);
    int ascent, descent, gap;
    stbtt_GetFontVMetrics(&t.font, &ascent, &descent, &gap);
    t.ascent = ascent * t.font_scale;
    t.line_height = (ascent - descent + gap) * t.font_scale;
    int x0, y0, x1, y1;
    /* Capital height centres labels by the letters' visual band, not the font's ascent. */
    t.cap_height = stbtt_GetCodepointBox(&t.font, 'H', &x0, &y0, &x1, &y1) ? y1 * t.font_scale : t.ascent * .7f;
    return true;
}

static struct Glyph *glyph_get(int codepoint)
{
    for (int i = 0; i < t.glyph_count; ++i)
        if (t.glyphs[i].codepoint == codepoint) return &t.glyphs[i];
    int index = t.glyph_count < MAX_GLYPHS ? t.glyph_count++ : codepoint % MAX_GLYPHS;
    struct Glyph *g = &t.glyphs[index];
    renderer_texture_destroy(g->texture);
    memset(g, 0, sizeof(*g));
    g->codepoint = codepoint;
    int advance;
    stbtt_GetCodepointHMetrics(&t.font, codepoint, &advance, NULL);
    g->advance = advance * t.font_scale;
    unsigned char *bitmap = stbtt_GetCodepointBitmap(&t.font, 0, t.font_scale,
        codepoint, &g->bounds.size.width, &g->bounds.size.height, &g->bounds.origin.x, &g->bounds.origin.y);
    if (bitmap && !isize2_is_empty(g->bounds.size))
        g->texture = renderer_texture_create(g->bounds.size, true, bitmap);
    stbtt_FreeBitmap(bitmap, NULL);
    return g;
}

static int utf8_next(const char **cursor)
{
    const unsigned char *p = (const unsigned char *)*cursor;
    int codepoint = *p++;
    int count = codepoint < 0x80 ? 0 : codepoint >= 0xc2 && codepoint < 0xe0 ? 1 :
                codepoint >= 0xe0 && codepoint < 0xf0 ? 2 : codepoint >= 0xf0 && codepoint < 0xf5 ? 3 : -1;
    if (count < 0) { *cursor = (const char *)p; return 0xfffd; }
    if (count) codepoint &= (1 << (6 - count)) - 1;
    for (int i = 0; i < count; ++i) {
        if ((*p & 0xc0) != 0x80) { *cursor = (const char *)p; return 0xfffd; }
        codepoint = (codepoint << 6) | (*p++ & 0x3f);
    }
    *cursor = (const char *)p;
    return codepoint > 0x10ffff || (codepoint >= 0xd800 && codepoint <= 0xdfff) ? 0xfffd : codepoint;
}

static float advance_for(int codepoint)
{
    int advance;
    stbtt_GetCodepointHMetrics(&t.font, codepoint, &advance, NULL);
    return advance * t.font_scale;
}

static float text_layout(const char *text, fvec2_t origin, float size, float max_width, uint32_t rgba, bool draw,
                         float *widest)
{
    if (widest) *widest = 0;
    if (!text || !*text || size <= 0) return origin.y;
    float scale = size / FONT_PIXELS;
    fvec2_t pen = origin;
    float line = fmaxf(t.line_height * scale, size * 1.3f) * TEXT_SPACING_SCALE;
    bool word_start = true;
    while (*text) {
        if (word_start && *text != ' ' && *text != '\n' && *text != '\t') {
            const char *word = text;
            float width = 0;
            while (*word && *word != ' ' && *word != '\n' && *word != '\t')
                width += advance_for(utf8_next(&word)) * scale;
            if (max_width > 0 && pen.x > origin.x && pen.x + width > origin.x + max_width)
                pen = fvec2_add(fvec2_with_x(pen, origin.x), fvec2(0, line));
        }
        int cp = utf8_next(&text);
        word_start = cp == ' ' || cp == '\t' || cp == '\n';
        if (cp == '\r') continue;
        if (cp == '\n') {
            /* Explicit story paragraphs breathe more than wrapped lines. */
            pen = fvec2_add(fvec2_with_x(pen, origin.x), fvec2(0, line + size * .35f));
            continue;
        }
        float advance = advance_for(cp == '\t' ? ' ' : cp) * scale * (cp == '\t' ? 4 : 1);
        if (max_width > 0 && pen.x > origin.x && pen.x + advance > origin.x + max_width) {
            pen = fvec2_add(fvec2_with_x(pen, origin.x), fvec2(0, line));
            if (cp == ' ' || cp == '\t') continue;
        }
        if (draw && cp != ' ' && cp != '\t' && pen.y + line > 0 && pen.y < renderer_bounds().size.height) {
            struct Glyph *g = glyph_get(cp);
            frect_t glyph = frect_translate(
                frect_scale(frect_translate(irect_to_float(g->bounds), fvec2(0, t.ascent)), scale), pen);
            if (g->texture) renderer_quad(glyph, rgba, g->texture, true);
        }
        pen = fvec2_add(pen, fvec2(advance, 0));
        if (widest) *widest = fmaxf(*widest, pen.x - origin.x);
    }
    return pen.y + line;
}

float text_draw(const char *text, fvec2_t origin, float size, float max_width, uint32_t rgba)
{
    return text_layout(text, origin, size, max_width, rgba, true, NULL);
}

struct TextMetrics text_metrics(float size)
{
    float scale = size / FONT_PIXELS;
    return (struct TextMetrics){fmaxf(t.line_height * scale, size * 1.3f) * TEXT_SPACING_SCALE,
                                t.ascent * scale, t.cap_height * scale};
}

frect_t text_label_box(const char *text, float size, float max_width, fvec2_t padding)
{
    struct TextMetrics metrics = text_metrics(size);
    fsize2_t content = text_size(text, size, max_width);
    int lines = (int)lroundf(content.height / metrics.line);
    float band = (lines > 0 ? lines - 1 : 0) * metrics.line + metrics.cap_height;
    return frect(fvec2(0, 0), fsize2(content.width + 2 * padding.x, band + 2 * padding.y));
}

float text_draw_centered(const char *text, frect_t box, float size, uint32_t rgba)
{
    struct TextMetrics metrics = text_metrics(size);
    fsize2_t content = text_size(text, size, box.size.width);
    int lines = (int)lroundf(content.height / metrics.line);
    float band = (lines > 0 ? lines - 1 : 0) * metrics.line + metrics.cap_height;
    /* Put the capital-height band of all lines in the middle of the box. */
    fvec2_t origin = fvec2(box.origin.x + (box.size.width - content.width) / 2,
                           box.origin.y + (box.size.height - band) / 2 + metrics.cap_height - metrics.baseline);
    return text_draw(text, origin, size, content.width + 1, rgba);
}

float text_height(const char *text, float size, float max_width)
{
    return text_layout(text, fvec2(0, 0), size, max_width, 0, false, NULL);
}

fsize2_t text_size(const char *text, float size, float max_width)
{
    float width;
    float height = text_layout(text, fvec2(0, 0), size, max_width, 0, false, &width);
    return fsize2(width, height);
}

float text_fit_size(const char *text, float preferred_size, fsize2_t bounds)
{
    if (preferred_size<=0 || fsize2_is_empty(bounds)) return 0;
    if (text_height(text,preferred_size,bounds.width)<=bounds.height) return preferred_size;
    float low=preferred_size*TEXT_MIN_FIT_RATIO,high=preferred_size;
    /* Preserve a readable floor; longer story states scroll within the same region. */
    for (int i=0;i<MAX_TEXT_FIT_STEPS;++i) {
        float middle=(low+high)/2;
        if (text_height(text,middle,bounds.width)<=bounds.height) low=middle;
        else high=middle;
    }
    return low;
}

void text_shutdown(void)
{
    for (int i = 0; i < t.glyph_count; ++i) renderer_texture_destroy(t.glyphs[i].texture);
    free(t.font_data);
    memset(&t, 0, sizeof(t));
}
