#include "book.h"

#include <string.h>

int main(int argc,char **argv)
{
    const char *root=".",*adventure="wondertown",*screenshot_path=NULL;
    bool smoke=false,headless=false,check=false,list=false;
    for (int i=1;i<argc;++i) {
        if (!strcmp(argv[i],"--root") && i+1<argc) root=argv[++i];
        else if (!strcmp(argv[i],"--book") && i+1<argc) adventure=argv[++i];
        else if (!strcmp(argv[i],"--check")) check=true;
        else if (!strcmp(argv[i],"--catalog")) list=true;
        else if (!strcmp(argv[i],"--headless")) headless=true;
        else if (!strcmp(argv[i],"--smoke")) smoke=true;
        else if (!strcmp(argv[i],"--screenshot") && i+1<argc) screenshot_path=argv[++i];
        else fail("usage: book [--root PATH] [--book NAME] [--check | --headless | --smoke | --catalog] [--screenshot PATH]");
    }
    book_init(root,adventure);
    if (list) headless_catalog();
    else if (check || headless) headless_run(headless);
    else ui_run(smoke,screenshot_path);
    scene_shutdown(); book_shutdown();
    return 0;
}
