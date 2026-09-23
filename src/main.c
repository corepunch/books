#include "book.h"

#include <string.h>
#include <stdlib.h>
#include <math.h>

int main(int argc,char **argv)
{
    const char *root=".",*adventure="three-stars",*screenshot_path=NULL;
    bool smoke=false,headless=false,check=false,list=false;
    double smoke_transition=-1;
    for (int i=1;i<argc;++i) {
        if (!strcmp(argv[i],"--root") && i+1<argc) root=argv[++i];
        else if (!strcmp(argv[i],"--book") && i+1<argc) adventure=argv[++i];
        else if (!strcmp(argv[i],"--check")) check=true;
        else if (!strcmp(argv[i],"--catalog")) list=true;
        else if (!strcmp(argv[i],"--headless")) headless=true;
        else if (!strcmp(argv[i],"--smoke")) smoke=true;
        else if (!strcmp(argv[i],"--smoke-transition") && i+1<argc) {
            char *end;
            smoke_transition=strtod(argv[++i],&end)/1000.0;
            if (end==argv[i] || *end || !isfinite(smoke_transition) || smoke_transition<0)
                fail("--smoke-transition requires nonnegative milliseconds");
            smoke=true;
        }
        else if (!strcmp(argv[i],"--screenshot") && i+1<argc) screenshot_path=argv[++i];
        else fail("usage: book [--root PATH] [--book NAME] [--check | --headless | --smoke | --smoke-transition MS | --catalog] [--screenshot PATH]");
    }
    book_init(root,adventure);
    if (list) headless_catalog();
    else if (check || headless) headless_run(headless);
    else ui_run(smoke,screenshot_path,smoke_transition);
    scene_shutdown(); book_shutdown();
    return 0;
}
