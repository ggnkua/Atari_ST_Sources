/****************************************************************/
/* PRTSHELL.C - Driver Shell for PRINTOUT.C                     */
/* Copyright 1986 Daniel Matejka                                */
/****************************************************************/

#include <gemdefs.h>
#include <obdefs.h>

int contrl[12],
    intin[128],
    intout[128],
    ptsin[128],
    ptsout[128],    /* these five variables to satisfy GEM gluttony */
    message[8],     /* GEM message pipe */
    schandle,       /* screen (workstation) handle */
    cellheight,
    cellwidth,      /* character size */
    colors,         /* number of colors supported by the screen */
    scrxmax,
    scrymax,        /* screen size */
    trash;          /* for those not too useful returns ... */

/* Menu and Item numbers */
#define DESKMENU         3
#define HELPMENU         4

#define QUIT            16
#define FIRSTHELP       18

/********** (the menu) **********/
OBJECT menudata[] = {

/* menu owner */
-1, 1, 5, G_IBOX, NONE, NORMAL, 0x0L,16,0,240,64,

/* titles parent and other miscellaneous garbage */
5, 2, 2, G_BOX, NONE, NORMAL, 0x1100L,0,0,96,11,
1, 3, 4, G_IBOX, NONE, NORMAL, 0x0L,0,0,96,11,

/* menu titles */
4, -1, -1, G_TITLE, NONE, NORMAL," Desk ",0,0,48,11,
2, -1, -1, G_TITLE, NONE, NORMAL," Help",48,0,48,11,

/* items parent */
0, 6, 15, G_IBOX, NONE, NORMAL, 0x0L,0,11,432,64,

/* desk menu */
15, 7, 14, G_BOX, NONE, NORMAL, 0xFF1100L,0,0,160,64,
 8, -1, -1, G_STRING, NONE, NORMAL,"  About Printout",      0, 0,160,8,
 9, -1, -1, G_STRING, NONE, DISABLED,"--------------------",0, 8,160,8,
10, -1, -1, G_STRING, NONE, NORMAL,"",                      0,16,160,8,
11, -1, -1, G_STRING, NONE, NORMAL,"",                      0,24,160,8,
12, -1, -1, G_STRING, NONE, NORMAL,"",                      0,32,160,8,
13, -1, -1, G_STRING, NONE, NORMAL,"",                      0,40,160,8,
14, -1, -1, G_STRING, NONE, NORMAL,"",                      0,48,160,8,
 6, -1, -1, G_STRING, NONE, NORMAL,"",                      0,56,160,8,

/* combination file/help menu */
 5, 16, 19, G_BOX,   NONE, NORMAL, 0xFF1100L,                48, 0,192,32,
17, -1, -1, G_STRING,NONE, NORMAL,"  (Quit)",                 0, 0,192,8,
18, -1, -1, G_STRING,NONE,DISABLED,"------------------------",0, 8,192,8,
19, -1, -1, G_STRING,NONE, NORMAL,"  About Something",        0,16,192,8,
15, -1, -1, G_STRING,LASTOB, NORMAL,"  About Something Else", 0,24,192,8,
};

/********* startup up the GEM workstation *********/
initialize() {

    int ctr;

    /* initialize GEM virtual workstation */
    appl_init();
    schandle = graf_handle(&cellwidth,&cellheight,&trash,&trash);
    for (ctr = 0; ctr < 10; ctr++)
        intin[ctr] = 1;
    intin[10] = 2;
    v_opnvwk(intin,&schandle,intout);
    scrxmax = intout[0];
    scrymax = intout[1];
    colors = intout[13];

    /* set some fill parameters:  this could be done in v_opnvwk(),
       but I find it somewhat less cryptic here, myself */
    vsf_interior(schandle,0);

    /* so we really know where text is going */
    vst_alignment(schandle,0,3,&trash,&trash);

    /* adjust menu for high resolution screen (text is double height) */
    if (colors == 2) { /* black & white screen */
        ctr = 0;
        do {
            menudata[ctr].ob_y *= 2;
            menudata[ctr].ob_height *= 2;
        } while (!(menudata[ctr++].ob_flags & LASTOB));
    }

    /* clear menu bar, then draw menu bar */
    v_hide_c(schandle);
    ptsin[0] = 0;
    ptsin[1] = 0;
    ptsin[2] = scrxmax;
    ptsin[3] = menudata[1].ob_height - 1;
    vr_recfl(schandle,ptsin);
    menu_bar(menudata,1);

    /* initialize mouse */
    graf_mouse(0,0);
    v_show_c(schandle,0);
} /* end initialize */

/********** handle menu selections by human **********/
int menuselect(menu,item)
    int menu,item; {

    static char *fnames[] = {      /* list of file names */
        "file.one",
        "file.two",
        "etc"
    };

    int tuesday = 1;

    switch (menu) {
        case DESKMENU :
            form_alert(1,
                "[1][PRINTOUT:|Read & Display Files| |(C) 1986 Daniel Matejka][OK|Not OK]");
            break;
        case HELPMENU :
            if (item == QUIT)
                tuesday = 0;
            else
                showfile(fnames[item-FIRSTHELP]);
    } /* end switch(menu) */

    menu_tnormal(menudata,menu,1);
    return tuesday;
} /* end menuselect */

/********** handle window events **********/
int dowindows() {

    if (message[0] == MN_SELECTED) /* just in case */
        return menuselect(message[3],message[4]);
    return 1;
} /* end dowindows */

/********** the program **********/
main() {

    /* open the GEM workstation */
    initialize();

    do { /* for the life of the program */
        evnt_multi(MU_MESAG,            /* just window messages */
            0,1,1,                      /* leftmost button */
            0,0,0,0,0,                  /* ignore mouse movement */
            0,0,0,0,0,                  /* continue doing so */
            message,                    /* GEM message pipe address */
            0,0,                        /* no timer events */
            &trash,&trash,              /* mouse position */
            &trash,                     /* mouse button status */
            &trash,                     /* special keys status */
            &trash,                     /* keyboard events */
            &trash);                    /* number of button clicks */

        /* at this point we of course have a window message */
    } while (dowindows());

    /* close the GEM workstation and exit */
    v_clsvwk(schandle);
    appl_exit();
} /* end main */

