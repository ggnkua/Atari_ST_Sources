/********************************************
*    blitter example prg/acc                *
*    Samuel Streeper 90/03/22               *
*                                           *
*    COPYRIGHT 1990 by Antic Publishing Inc.*
*                                           *
*    This program/accessory reads a         *
*    degas picture into a buffer,           *
*    and uses the buffer to redraw          *
*    a gem window.                          *
********************************************/

/* edited with tabsize = 4 */

extern int _app;


/*    Compiler notes:        */
/*    ---------------        */
/*    This code compiles with Megamax C, Laser C, and Mark Williams C    */
/*    version 2.0. It shouldn't be tough to get it to compile with other */
/*    things...                                                          */
/*    There are just a few things to look out for when porting this      */
/*    between compilers:                                                 */

/*    The blitter routines require a structure known as a memory form    */
/*    descriptor block. Laser C and Alcyon C call this structure a       */
/*    MFDB, while Megamax C and MWC call this a FDB.                     */

/*    This code will work as both a desk accessory or a program if you    */
/*    link it with the proper startup module. The default Laser startup   */
/*    module works ok. I recommend linking to the megamax, laser, or      */
/*    MWC startup code supplied with START magazine October 89. This code */
/*    gives the smallest executable file, and will work as a program or   */
/*    DA just by changing the file's extention from .prg to .acc          */

/*    You should define one and only one of the following entries as a    */
/*    non-zero value depending on which compiler you are using.           */

#define MEGAMAX 0            /* 1 if megamax, 0 if other */
#define LASER 1              /* 1 if laser c, 0 if other */
#define MWC 0                /* 1 if mark williams c, 0 if other */

#define Blit(a)        xbios(0x40,a)

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>

#if (MEGAMAX | MWC)
#define MFDB FDB
#endif

#if MWC
#define Kbshift(a) Getshift(a)
#endif

/* The following arrays of gem OBJECTS were dumped from a resource   */
/* file using the resource dumper from the START magazine            */
/* October 89 issue. By including the resource file in the code      */
/* we don't need to load it in at run-time (which is a bad idea      */
/* for desk accessories...)                                          */

char null[] = "";

#define ABTEX 7
#define WINDOPEN 16
#define LOADPIC 17
#define FILEQUIT 18

OBJECT menu[] = {
-1,1,5,G_IBOX,0,0,0x0L,0,0,80,25,
5,2,2,G_BOX,0,0,0x1100L,0,0,80,513,
1,3,4,G_IBOX,0,0,0x0L,2,0,10,769,
4,-1,-1,G_TITLE,0,0," \16\17",0,0,4,769,
2,-1,-1,G_TITLE,0,0," File",4,0,6,769,
0,6,15,G_IBOX,0,0,0x0L,0,769,80,19,
15,7,14,G_BOX,0,0,0xff1100L,2,0,20,8,
8,-1,-1,G_STRING,0,0,"  About Example...",0,0,20,1,
9,-1,-1,G_STRING,0,0x8,"--------------------",0,1,20,1,
10,-1,-1,G_STRING,0,0,null,0,2,20,1,
11,-1,-1,G_STRING,0,0,null,0,3,20,1,
12,-1,-1,G_STRING,0,0,null,0,4,20,1,
13,-1,-1,G_STRING,0,0,null,0,5,20,1,
14,-1,-1,G_STRING,0,0,null,0,6,20,1,
6,-1,-1,G_STRING,0,0,null,0,7,20,1,
5,16,18,G_BOX,0,0,0xff1100L,6,0,15,3,
17,-1,-1,G_STRING,0,0,"  Open Window",0,0,15,1,
18,-1,-1,G_STRING,0,0,"  Load Pic...",0,1,15,1,
15,-1,-1,G_STRING,0x20,0,"  Quit",0,2,15,1
};

TEDINFO ted0 = {
    "by Samuel Streeper",
    "",
    "",
    5, 6, 0, 0x1180, 0, 0xff, 19, 1        };

#define DIALOK 7
#define DIALLOAD 8

OBJECT dial[] = {
-1,1,1,G_BOX,0x0,0x10,0x11142L,0,0,29,17,
0,2,8,G_BOX,0x0,0x20,0xff1100L,1,1,27,15,
3,-1,-1,G_STRING,0x0,0x0,"Blitter Example",6,1,15,1,
4,-1,-1,G_TEXT,0x0,0x0,&ted0,7,2,14,1,
5,-1,-1,G_STRING,0x0,0x0,"COPYRIGHT 1990",6,4,14,1,
6,-1,-1,G_STRING,0x0,0x0,"by Antic Publishing, Inc.",1,5,25,1,
7,-1,-1,G_STRING,0x0,0x0,"Runs as .prg or .acc",3,7,20,1,
8,-1,-1,G_BUTTON,0x7,0x0,"OK",8,10,10,2,
1,-1,-1,G_BUTTON,0x65,0x0,"Load Pic...",4,13,18,1,
};


/* A monochrome bitmap of the rotating fuji from FUJI.PI3 */

int mono_fuji[] = {
0x05a0,0x07e0,0x07e0,0x03e0,0x01e0,0x01e0,0x01e0,
0x05a0,0x07e0,0x07e0,0x03e0,0x01e0,0x01e0,0x01e0,
0x05a0,0x07e0,0x07e0,0x03e0,0x01e0,0x01e0,0x01e0,
0x05a0,0x07e0,0x07e0,0x03e0,0x01e0,0x01e0,0x01e0,
0x0db0,0x0ff0,0x07e0,0x03e0,0x03f0,0x01e0,0x01e0,
0x0db0,0x0ff0,0x0ff0,0x07f0,0x03f0,0x03f0,0x01e0,
0x1db8,0x1ff8,0x0ff0,0x07f0,0x03f0,0x03f0,0x01e0,
0x399c,0x1db8,0x1ff8,0x0ff8,0x07f8,0x03f0,0x01e0,
0x799e,0x3dbc,0x1ff8,0x0ff8,0x07f8,0x03f0,0x01e0,
0x718e,0x399c,0x1db8,0x0ff8,0x07f8,0x03f0,0x01e0,
0x718e,0x399c,0x1db8,0x0ff8,0x07f8,0x03f0,0x01e0,
0x6186,0x318c,0x1998,0x0ff8,0x07f8,0x03f0,0x01e0,
0x4182,0x318c,0x1998,0x0dd8,0x07f8,0x03f0,0x01e0,
    };

int med_fuji[] = {
0x05a0,0x05a0,0x07e0,0x07e0,0x07e0,0x07e0,0x03e0,0x03e0,
    0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,
0x05a0,0x05a0,0x07e0,0x07e0,0x07e0,0x07e0,0x03e0,0x03e0,
    0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,
0x05a0,0x05a0,0x07e0,0x07e0,0x07e0,0x07e0,0x03e0,0x03e0,
    0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,0x01e0,
0x0db0,0x0db0,0x0ff0,0x0ff0,0x0ff0,0x0ff0,0x07f0,0x07f0,
    0x03f0,0x03f0,0x03f0,0x03f0,0x01e0,0x01e0,
0x0db0,0x0db0,0x0ff0,0x0ff0,0x0ff0,0x0ff0,0x07f0,0x07f0,
    0x03f0,0x03f0,0x03f0,0x03f0,0x01e0,0x01e0,
0x3dbc,0x3dbc,0x1db8,0x1db8,0x1ff8,0x1ff8,0x0ff8,0x0ff8,
    0x07f8,0x07f8,0x03f0,0x03f0,0x01e0,0x01e0,
0x799e,0x799e,0x399c,0x399c,0x1db8,0x1db8,0x0ff8,0x0ff8,
    0x07f8,0x07f8,0x03f0,0x03f0,0x01e0,0x01e0,
0x6186,0x6186,0x318c,0x318c,0x1998,0x1998,0x0ff8,0x0ff8,
    0x07f8,0x07f8,0x03f0,0x03f0,0x01e0,0x01e0,
};

#define TRUE 1
#define FALSE 0
#define WI_KIND    (SIZER|MOVER|FULLER|CLOSER|NAME)

#define HIDE_MOUSE graf_mouse(M_OFF,0L);
#define SHOW_MOUSE graf_mouse(M_ON,0L);

#define NO_WINDOW (-1)

#define MIN_WIDTH  (gl_wbox)
#define MIN_HEIGHT (gl_hbox)

extern int    gl_apid;

int    gl_hchar;
int    gl_wchar;
int    gl_wbox;
int    gl_hbox;        /* sizes of system characters */

int maxx, maxy, maxw, maxh;

int    win_kind = WI_KIND;
int    menu_id, timer;

int    phys_handle;       /* physical workstation handle */
int    handle;            /* virtual workstation handle */
int    w_hand;            /* window handle */

int    xdesk,ydesk,hdesk,wdesk;
int    xold,yold,hold,wold;
int    xwork,ywork,hwork,wwork;       /* desktop and work areas */

int    msgbuff[8];                    /* event message buffer */
int    ret;

int    fulled;                        /* current state of window */
int    planes;                        /* number of bit planes */
int    *lineaptr;

char *title_bar = " Picture Window ";

extern int int_in[], addr_in[], control[], int_out[];

int    contrl[12];
int    intin[128];
int    ptsin[128];
int    intout[128];
int    ptsout[128];

int work_in[11];
int work_out[57];
int pxyarray[10];                        /* input point array */

#if MEGAMAX
char *warray;
#else
char warray[27520];
#endif

int fujiarray[8] = {0,0,15,12,24,2,39,14};
int fuji_ht;

/* describe the fuji bitmap */
MFDB fujisource = {0L,112,13,112/16,0,1,0,0,0};

/* describe the degas bitmap */
MFDB windsource = {0L,640,344,640/16,0,1,0,0,0};

/* Let gem fill in the screen description */
MFDB screen_fdb;

char path[80], name[14];


                /*     0123456789012345678901234    */
char *no_picture =    "Unable to open SBLIT.PI3 degas picture\r\n";

                /*   012345678    */
char *picture =     "sblit.pi3";

/****************************************************************/
/* open virtual workstation                                     */
/****************************************************************/
open_vwork()
{
    register int i;

    for(i=0;i<10;work_in[i++]=1);
    work_in[10]=2;
    handle=phys_handle;
    v_opnvwk(work_in,&handle,work_out);

    init_fdb();
}

/********************************************/
/*        open window                       */
/********************************************/
int open_window()
{
    if ((w_hand=wind_create(win_kind,xdesk,ydesk,maxw,maxh)) < 0)
        return -1;

    wind_set(w_hand, WF_NAME,title_bar,0,0);

    if (fulled) graf_growbox(xdesk,ydesk,gl_wbox,gl_hbox,xdesk,
                 ydesk,maxw,maxh);
      else graf_growbox(xdesk,ydesk,gl_wbox,gl_hbox,xold,yold,wold,hold);
    if (fulled) wind_open(w_hand,xdesk,ydesk,maxw,maxh);
        else wind_open(w_hand,xold,yold,wold,hold);
    wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);

    return 0;
}

/****************************************************************/
/* find and redraw all clipping rectangles                      */
/****************************************************************/
do_redraw(xc,yc,wc,hc)
register int xc,yc,wc,hc;
{
    GRECT t1,t2;
    int pxyarray[8];

    HIDE_MOUSE;
    wind_update(TRUE);

    if ((xc+wc) > wdesk) wc = wdesk - xc;
    if ((yc+hc) > maxy) hc =maxy-yc; /* otherwise will blit into ramdisk! */
    t2.g_x=xc;
    t2.g_y=yc;
    t2.g_w=wc;
    t2.g_h=hc;
    wind_get(w_hand,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);


    /* check every rectangle in rectangle list */
    while (t1.g_w && t1.g_h)
    {
        /* redraw the rectangle only if this rectangle intersects    */
        /* the area we need to redraw.                               */

        if (rc_intersect(&t2,&t1)) 
        {
            pxyarray[0] = t1.g_x - xwork;
            pxyarray[1] = t1.g_y - ywork;
            pxyarray[2] = t1.g_x - xwork + t1.g_w - 1;
            pxyarray[3] = t1.g_y - ywork + t1.g_h - 1;
            pxyarray[4] = t1.g_x;
            pxyarray[5] = t1.g_y;
            pxyarray[6] = t1.g_x + t1.g_w - 1;
            pxyarray[7] = t1.g_y + t1.g_h - 1;

            /*    Now do the blit.    */
            vro_cpyfm(handle,3,pxyarray,&windsource,&screen_fdb);
        }

        /* get the next rectangle in the list */
        wind_get(w_hand,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);

    }

    wind_update(FALSE);
    SHOW_MOUSE;
}

/********************************/
/*        MAIN()                */
/********************************/
main()
{
    register int temp, dw, dh;
    int fd, wx,wy,ww,wh;

/* We need to allocate space for the background picture.                  */
/* The best way to do this would be to declare a character                */
/* array, but Megamax compiler will only let me have 32K of global        */
/* variables. (yuck!) The things I put up with for PC relative code       */
/* generation...                                                          */

/* Memo: if desk accessories MUST Malloc(), they should only do one,      */
/* and do it before any AES calls.                                        */
/* Also, you should check for the success of the Malloc...                */

#if MEGAMAX
    warray = (char *)Malloc(27520L);
    asm{    dc.w 0xa000
            move.l D0,lineaptr(A4)
       }
#endif

#if LASER
    asm{    dc.w 0xa000
            move.l D0,lineaptr
       }
#endif

#if MWC
    lineaptr = a_init();
#endif                        /* mwc */


    planes = *lineaptr;

    if (planes == 2)        /* color monitor */
    {
        windsource.fd_nplanes = 2;
        fujisource.fd_nplanes = 2;
        no_picture[23] = '2';
        picture[8] = '2';
        fuji_ht = 7;
        fujiarray[3] = fuji_ht;
        fujiarray[5] = 1;
        fujiarray[7] = fujiarray[5] + fuji_ht;
        fujisource.fd_addr = (long)med_fuji;
    }
    else
    {
        fuji_ht = 12;
        fujisource.fd_addr = (long)mono_fuji;
    }

    fd = Fopen(picture,0);

    if (fd > 0)
    {    Fseek(34L,fd,0);
        Fread(fd,27520L,warray);
        Fclose(fd);
    }
    else
    {    Cconws(no_picture);
        wait();
    }

    appl_init();

    if (!_app) menu_id=menu_register(gl_apid,"  Picture ");

    phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);


    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    wind_calc(1,win_kind,xdesk,ydesk,wdesk,hdesk,&wx,&wy,&ww,&wh);
    dw = wdesk - ww;
    dh = hdesk - wh;

    /* set up window to open to full size. Full size will be    */
    /* the size of the screen or the size of the degas bitmap,  */
    /* whichever is smaller.                                    */

    maxw = (wdesk < (temp=(windsource.fd_w + dw))) ? wdesk : temp;
    maxh = (hdesk < (temp=(windsource.fd_h + dh))) ? hdesk : temp;
    xold = xdesk;
    yold = ydesk;
    wold = maxw;
    hold = maxh;

    maxx = xdesk + wdesk;
    maxy = ydesk + hdesk;


    /* set up the file selector variables */

    path[0] = Dgetdrv() + 'A';
    path[1] = ':';
    Dgetpath(path+2,Dgetdrv() + 1);
    strcat(path,"\\*.PI?");
    strcpy(name,null);

    w_hand=NO_WINDOW;
    fulled=FALSE;


    windsource.fd_addr = (long)&warray[0];

    if (_app)
    {
        open_vwork();

        dial[DIALLOAD].ob_flags = (LASTOB | HIDETREE);
        dial[DIALOK].ob_height = 3;

        graf_mouse(ARROW, 0L);

        convert_resource(menu);

        menu_bar(menu, 1);            /* display the menu */
    }

    convert_resource(dial);

    multi();                          /* acc will not return */

    menu_bar(menu, 0);                /* erase the menu bar */

    v_clsvwk(handle);                 /* close the workstation */

    appl_exit();
}


/****************************************************************/
/* dispatches all accessory tasks                               */
/****************************************************************/
multi()
{
    register int i = -1, dir = 1;
    int skip = 0, timer = 25;
    int    ret;

    int event, newx, newy;
    int sized = FALSE, done = FALSE;
    int flags = MU_MESAG;

    if (_app && (planes == 1 || planes == 2))
    {
        if (open_window() < 0)
        {    return;
        }

        flags |= MU_TIMER;
    }

    while ((!_app) || !done)
    {

        event = evnt_multi(flags,
            1,0,0,
            0,0,0,0,0,
            0,0,0,0,0,
            msgbuff,timer,0,&ret,&ret,&ret,&ret,&ret,&ret);


        if (event & MU_MESAG) switch (msgbuff[0])
        {

        case MN_SELECTED:

        /* menu functions, program only */

            switch(msgbuff[4])
            {

            case ABTEX:    blit_dial();
                    break;

            case WINDOPEN:
                if (planes != 1 && planes != 2) break;
                if (w_hand != NO_WINDOW)
                    wind_set(w_hand,WF_TOP,0,0,0,0);
                else open_window();
                break;

            case LOADPIC:
                load_pic();
                break;

            case FILEQUIT:
                if (w_hand != NO_WINDOW)
                {    wind_close(w_hand);
                    wind_delete(w_hand);
                }
                done = TRUE;
                break;
            }

            menu_tnormal(menu, msgbuff[3], TRUE ); /* deselect menubar */
            break;

        case WM_REDRAW:
            if (msgbuff[3] == w_hand)
            do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            break;

        case WM_NEWTOP:
        case WM_TOPPED:
            if (msgbuff[3] == w_hand)
            {    wind_set(w_hand,WF_TOP,0,0,0,0);
                timer = 0;
            }
            break;

        case AC_CLOSE:
            if((msgbuff[3] == menu_id) && (w_hand != NO_WINDOW))
            {
                wind_update(TRUE);

                v_clsvwk(handle);

                w_hand = NO_WINDOW;
                wind_update(FALSE);
            }
            break;

        case WM_CLOSED:
            if(msgbuff[3] == w_hand)
            {    wind_close(w_hand);
                graf_shrinkbox(xdesk,ydesk,gl_wbox,gl_hbox,
                    xold,yold,wold,hold);
                wind_delete(w_hand);

                if (!_app) v_clsvwk(handle);

                w_hand = NO_WINDOW;
            }
            break;

        case WM_SIZED:
        case WM_MOVED:
            if(msgbuff[3] != w_hand) break;
            if(msgbuff[6] < MIN_WIDTH) msgbuff[6] = MIN_WIDTH;
            if(msgbuff[7] < MIN_HEIGHT) msgbuff[7] = MIN_HEIGHT;
            if(msgbuff[6] > maxw) msgbuff[6] = maxw;
            if(msgbuff[7] > maxh) msgbuff[7] = maxh;

            xold = msgbuff[4];
            yold = msgbuff[5];
            wold = msgbuff[6];
            hold = msgbuff[7];

            wind_set(w_hand,WF_CURRXYWH,msgbuff[4],
                msgbuff[5],msgbuff[6],msgbuff[7]);
            wind_get(w_hand,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);

            if (msgbuff[4] != xdesk || msgbuff[5] != ydesk ||
                msgbuff[6] !=maxw || msgbuff[7]!=maxh) fulled = FALSE;
            else fulled = TRUE;

            break;

        case AC_OPEN:
            if (msgbuff[4] == menu_id)
            {
                if (Kbshift(-1) & 2)
                {    blit_dial();
                    break;
                }
                if (planes != 1 && planes != 2) break;

                if (w_hand == NO_WINDOW)
                {    open_vwork();

                    if (open_window() < 0)
                    {
                        v_clsvwk(handle);
                        break;
                    }
                }
                else wind_set(w_hand,WF_TOP,0,0,0,0);
            }
            break;

        case WM_FULLED:
            if(fulled)
            {
                wind_calc(WC_WORK,WI_KIND,xold,yold,wold,hold,
                        &xwork,&ywork,&wwork,&hwork);
                wind_set(w_hand,WF_CURRXYWH,xold,yold,wold,hold);
            }
            else
            {
                wind_calc(WC_BORDER,WI_KIND,xwork,ywork,wwork,hwork,
                        &xold,&yold,&wold,&hold);
                newx = ((xold+maxw) < maxx) ? xold : (maxx - maxw);
                newy = ((yold+maxh) < maxy) ? yold : (maxy - maxh);
                wind_calc(WC_WORK,WI_KIND,newx,newy,maxw,maxh,
                        &xwork,&ywork,&wwork,&hwork);
                wind_set(w_hand,WF_CURRXYWH,newx,newy,maxw,maxh);
            }
            fulled ^= TRUE;
            break;

        } /* switch (msgbuff[0]) */

        if (event & MU_TIMER)
        {
            i += dir;
            if (i > 6)
            {    i = 5;
                dir = -dir;
            }
            else if (i < 0)
            {    i = 0;
                dir = -dir;
                if (skip > 2) skip = 0;
            }

            fujiarray[0] = 16 * i;
            fujiarray[2] = fujiarray[0] + 15;
            wind_update(TRUE);
            vro_cpyfm(handle,3,fujiarray,&fujisource,&screen_fdb);
            wind_update(FALSE);
            if (i == 0 && !(skip++)) timer = 3000;
            else timer = 45;
        }

    } /* while (!_app || !done) */

}


wait()
{    long i;
    for (i = 0; i < 320000L; i++);
}


/* put up dialog box */

blit_dial()
{
    int xchoice,dial_x,dial_y,dial_w,dial_h;

    form_center(dial,&dial_x,&dial_y,&dial_w,&dial_h);
    wind_update(TRUE);
    objc_draw(dial,0,3,dial_x,dial_y,dial_w,dial_h);
    xchoice = (form_do(dial, 0) & 0x7fff);
    wind_update(FALSE);
    dial[xchoice].ob_state &= ~SELECTED;

    /* accessory only */
    if (xchoice == DIALLOAD) load_pic();

    form_dial(FMD_FINISH,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
}


/* change an object array from character coordinates to pixel coordinates */

convert_resource(p)
register OBJECT *p;
{    register OBJECT *p2 = p;
    register int ndx = 0;

    for (;;)
    {    rsrc_obfix(p,ndx);
        if (p2->ob_flags & 0x20) break;
        ndx++;
        p2++;
    }
}


/*********************************************
INIT_FDB() - init screen memory form definition block.
In order to blit from one rectangle (our background picture)
to another (the screen) we need to to give gem a memory form
definition block for each rectangle. This structure describes the
location of the rectangle, its width, height, and number of bit
planes. For the background picture, the parameters are hard wired
to the size of a Degas picture. We must ask gem to tell us the screen
parameters so that the program will work on any monitor including
large screen monitors.
*********************************************/
init_fdb()
{
    register MFDB *fdbp = &screen_fdb;
    register int temp;

    fdbp->fd_addr    = Logbase();
    fdbp->fd_w    = work_out[0] + 1;
    fdbp->fd_h    = work_out[1] + 1;
    fdbp->fd_wdwidth    = fdbp->fd_w/16;
    fdbp->fd_stand    = 0;

    switch(work_out[13])
    {
        case 16: temp = 4; break;
        case 08: temp = 3; break;
        case 04: temp = 2; break;
        default: temp = 1; break;
    }
    fdbp->fd_nplanes = temp;
}


/* Allow the user access to a Gem file selector to pick a new */
/* background picture */

load_pic()
{    register int i, fd;
    int button;
    char complete[80];

    wind_update(TRUE);
    fsel_input(path,name,&button);
    if (!button) goto end;

    i = strlen(path) - 1;
    while (i > 0 && (path[i] != '\\') && (path[i] != ':'))
        i--;
    strcpy(complete,path);
    strcpy(&complete[i+1],name);

    fd = Fopen(complete,0);
    if (fd <= 0) goto end;

    Fseek(34L,fd,0);            /* skip degas header info    */
    Fread(fd,27520L,warray);
    Fclose(fd);

    if (w_hand != NO_WINDOW) do_redraw(xwork,ywork,wwork,hwork);
end:
    wind_update(FALSE);
}


/* Handy C string functions */

strlen(a)
register char *a;
{    register int n = 0;
    while (*a++) n++;
    return n;
}

strcpy(a,b)
register char *a, *b;
{    while (*a++ = *b++);
}

strcat(a,b)
register char *a, *b;
{    while (*a) a++;
    while (*a++ = *b++);
}
