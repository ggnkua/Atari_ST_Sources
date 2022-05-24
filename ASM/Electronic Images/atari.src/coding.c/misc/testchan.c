/* testchan.c   test functionality of chain.c */

#include "chain.h"

main()
{
    struct strchain *screen;
    
    screen = inpchain("ajuno1.scr",81);
    dispchain(screen);
    dechain(screen);
    exit();
}

