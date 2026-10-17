#include "book.h"

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

_Noreturn void fail(const char *format, ...)
{
    va_list args; va_start(args, format);
    fputs("Book: ", stderr); vfprintf(stderr, format, args); fputc('\n', stderr);
    va_end(args); exit(EXIT_FAILURE);
}

void copy(char *dst, size_t size, const char *src)
{
    if (!src) src = "";
    if (strlen(src) >= size) fail("text exceeds buffer capacity (%zu)", size);
    memcpy(dst, src, strlen(src) + 1);
}

void json_string(const char *s)
{
    putchar('"');
    for (const unsigned char *p = (const unsigned char *)(s ? s : ""); *p; ++p) {
        if (*p == '"' || *p == '\\') printf("\\%c", *p);
        else if (*p < 32) printf("\\u%04x", *p);
        else putchar(*p);
    }
    putchar('"');
}

void lower(char *s)
{
    for (; *s; ++s) *s = (char)tolower((unsigned char)*s);
}
