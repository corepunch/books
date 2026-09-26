#include "book.h"

#include <string.h>
#include <stdlib.h>
#include <math.h>

int main(int argc,char **argv)
{
    const char *root=".",*requested_book=NULL,*screenshot_path=NULL,*smoke_route=NULL;
    bool smoke=false,headless=false,check=false,list=false;
    double smoke_transition=-1;
    fsize2_t viewport=fsize2(UI_WIDTH, UI_HEIGHT);
    for (int i=1;i<argc;++i) {
        if (!strcmp(argv[i],"--root") && i+1<argc) root=argv[++i];
        else if (!strcmp(argv[i],"--book") && i+1<argc) requested_book=argv[++i];
        else if (!strcmp(argv[i],"--check")) check=true;
        else if (!strcmp(argv[i],"--catalog")) list=true;
        else if (!strcmp(argv[i],"--headless")) headless=true;
        else if (!strcmp(argv[i],"--viewport") && i+2<argc) {
            char *end;
            viewport.width=strtof(argv[++i],&end);
            if (*end || !isfinite(viewport.width) || viewport.width<=0) fail("invalid viewport width");
            viewport.height=strtof(argv[++i],&end);
            if (*end || !isfinite(viewport.height) || viewport.height<=0) fail("invalid viewport height");
        }
        else if (!strcmp(argv[i],"--smoke")) smoke=true;
        else if (!strcmp(argv[i],"--smoke-route") && i+1<argc) { smoke_route=argv[++i]; smoke=true; }
        else if (!strcmp(argv[i],"--smoke-transition") && i+1<argc) {
            char *end;
            smoke_transition=strtod(argv[++i],&end)/1000.0;
            if (end==argv[i] || *end || !isfinite(smoke_transition) || smoke_transition<0)
                fail("--smoke-transition requires nonnegative milliseconds");
            smoke=true;
        }
        else if (!strcmp(argv[i],"--screenshot") && i+1<argc) screenshot_path=argv[++i];
        else fail("usage: book [--root PATH] [--book NAME] [--check | --headless | --smoke | --smoke-transition MS | --catalog] [--viewport W H] [--smoke-route STEP,...] [--screenshot PATH]");
    }
    if (requested_book && strcmp(requested_book, book_name()))
        fail("this executable was compiled for book '%s', not '%s'", book_name(), requested_book);
    book_init(root);
    if (smoke_route) {
        command_t route; copy(route, sizeof(route), smoke_route);
        for (char *step = strtok(route, ","); step; step = strtok(NULL, ","))
            if (!(strcmp(step, "continue") ? book_command(step) : book_continue()))
                fail("invalid smoke route step: %s", step);
    }
    if (list) headless_catalog();
    else if (check || headless) headless_run(headless,viewport);
    else ui_run(smoke,screenshot_path,smoke_transition);
    scene_shutdown(); book_shutdown();
    return 0;
}
