/****************************************************************/
/* NEWMOUSE.C - an example animation program compatible with    */
/*   C.O.L.R. Object Editor sources                             */
/*   Written by Joe Chiazzese                                   */
/*                                                              */
/* Copyright 1986, ANTIC Publishing                             */
/****************************************************************/

#include "osbind.h"

#define BLANKPIX 3
#define MAXX 320
#define MAXY 200
#define OBJW 2
#define OBJH 42
#define COEOBJECT bitimage
#define IMAGESIZE ((OBJW + 1) * 8 * OBJH)

int     contrl[12],
        intin[128],     intout[128],
        ptsin[128],     ptsout[128];

int     v_handle,       offset;

int     def_pallete[16];

int     demopal[] =
        {
        0x000,
        0x555,
        0x743,
        0x070,
        0x007,
        0x077,
        0x770,
        0x707,
        0x777,
        0x333,
        0x732,
        0x040,
        0x337,
        0x055,
        0x550,
        0x505
        };

long    imagebuf[16],   maskbuf[16],    screenbuf[IMAGESIZE],
        abspos,         oldpos,         imagestorage,   scrbase;
extern long     COEOBJECT[];

open_workstation(handle)
int *handle;
{
int dummy;
        appl_init();
        v_handle = graf_handle(&dummy,&dummy,&dummy,&dummy);
        for ( dummy = 0; dummy < 10; ++dummy)
                intin[dummy] = 1;
        intin[10] = 2;
        v_opnvwk(intin,handle,intout);
}

close_workstation(handle)
int handle;
{
        v_clsvwk(handle);
        appl_exit();
}

initialize()
{
int x,pxy[4];
        if (Getrez())           /* if anything but low rez, back to desktop */
        {
                form_alert(1,"[3][This program works ONLY|in low rez.][ OK ]");
                return(0);
        }
        scrbase = xbios(3);
        if (!(imagestorage = Malloc((long)IMAGESIZE * 24)))
                return(0);
        for (x = 0; x < 16; ++x)
                def_pallete[x] = Setcolor(x,-1); /* save default pallete */
        Setpallete(demopal);
        vsf_interior(v_handle,2);       /* set fill index to dotted */
        vsf_style(v_handle,9);          /* set fill style to wall pattern */
        vsf_color(v_handle,15);         /* fill with color 15 */
        pxy[0] = pxy[1] = 0;            /* top left corner */
        pxy[2] = 319;
        pxy[3] = 199;                   /* bottom right corner */
        vr_recfl(v_handle,pxy);         /* fill'er up */
        for (x = 0; x < 16; ++x)
        {
                imagebuf[x] = imagestorage + IMAGESIZE * x;
                maskbuf[x] = imagestorage + IMAGESIZE *  16 + IMAGESIZE * x / 2;
                shift_image(OBJW,OBJH,COEOBJECT,imagebuf[x],x);
                make_mask(OBJW,OBJH,imagebuf[x],maskbuf[x]);
        }
        save_screen(OBJW,OBJH,scrbase,screenbuf);
        oldpos = scrbase;
        return(1);
}

finish_up()
{
        Mfree(imagestorage);
        Setpallete(def_pallete);
}

follow_mouse()
{
int mousex,mousey,dummy,oldx,oldy;
        while(!Bconstat(2))
        {
                do
                {
                        oldx = mousex;
                        oldy = mousey;
                        vq_mouse(v_handle,&dummy,&mousex,&mousey);
                }
                while (oldx == mousex && oldy == mousey && !Bconstat(2));
                if (mousex > (MAXX - ((OBJW * 16) - BLANKPIX)))
                        mousex = MAXX - ((OBJW * 16) - BLANKPIX);
                if (mousey > (MAXY - OBJH))
                        mousey = MAXY - OBJH;
                abspos = scrbase + (mousey * 160) + ((mousex / 16) * 8);
                        /* (y * 160) = absolute offset in lines */
                        /* (x / 16) = which word the pixel lies in */
                        /* x is multiplied by eight to get the nth word */
                        /* from the FIRST plane (remember there are 4 planes */
                        /* 2 bytes per word dividing first removes the remainder */
                offset = mousex % 16;
                xbios(37);      /* wait for vsync */
                if (abspos != oldpos)
                {
                        restore_screen(OBJW,OBJH,oldpos,screenbuf);
                        save_screen(OBJW,OBJH,abspos,screenbuf);
                        oldpos = abspos;
                }
                draw_image(OBJW,OBJH,abspos,imagebuf[offset],screenbuf,
                                maskbuf[offset]);
        }
        Bconin(2);
}

main()
{
        open_workstation(&v_handle);
        v_hide_c(v_handle,0);
        if (initialize())
        {
                follow_mouse();
                finish_up();
        }
        v_show_c(v_handle,0);
        close_workstation(v_handle);
}

