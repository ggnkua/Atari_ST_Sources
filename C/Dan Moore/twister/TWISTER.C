/********************************************************************
 *                                                                  *
 *                           The Twister                            *
 *                               by                                 *
 *                           David Small                            *
 *                               and                                *
 *                            Dan Moore                             *
 *                                                                  *
 *                                                                  *
 *                             version 2                            *
 *                                                                  *
 *  Copyright (c) 1986 David Small and Daniel Moore for STart Mag.  *
 *                                                                  *
 ********************************************************************
 *                                                                  *
 *    Dedication:                                                   *
 *       To Bill and all the other twisted cats in the world        *
 *                                                                  *
 ********************************************************************/

#include <portab.h>
#include <gemdefs.h>
#include <osbind.h>
#include <obdefs.h>
#include "twister.h"
#include "twster.rsh"

/* something that should be in the compiler but isn't */
#define void /* */

/* misc. defines */
#define DESK      0
#define WF_WXYWH  4

/* Stuff to call AES.  */
WORD   contrl[12];
WORD   intin[80];
WORD   ptsin[256];
WORD   intout[45];
WORD   ptsout[12];
WORD   msgbuf[8];
WORD   VDIhandle;

/* external variables (defined in system library) */
extern WORD gl_apid;

/* 
 * hooks into the twister formatter code.
 * These are passed as globals to avoid problems with
 * passing params via Supexec().
 *
 * The actual twister format code is in mmtwst.c.  This file
 * is common to both backup.prg and twister.prg. It is 
 * located in the twister directory on the disk.
 */ 
extern twister();        /* the formatter, obviously          */

extern int thedisk,      /* drive number to format (A=0, B=1) */
           dblsided,     /* sides (0 = single, -1 = double)   */
           sectoroffset; /* offset for physical sector numbering */
extern long buffer;      /* Track buffer for format.          */
extern int badflag;      /* non-zero means a verify error     */

/* misc support routines */
void
setmem(p, n, c)
register unsigned char *p;
register unsigned int   n;
register unsigned char  c;
{
     for (; n; n--)
          *(p++) = c;
}

void
put_word(addr, val)
register unsigned char *addr;
register unsigned int   val;
/* 
 * Store val at the word at addr.  The data will be stored in low-high
 * order, so it will be stored one byte at a time.
 */
{
     *(addr++) = val & 0xff;
     *addr     = (val >> 8) & 0xff;
}

/* now the GEM supprot stuff */
void
init_gem()
/* 
 * setup the "resource" and the pointers to it.  Doing it here saves us from
 * having a .rsc file on the disk which the user can forget to copy.       
 */
{
     register int i, j;
     WORD     work_in[11], work_out[57];
     WORD     x, y, w, h;

     appl_init();   /* be trusting, assume it won't fail. (haha) */

     for (i = 0; i < 10; i++)
          work_in[i] = 1;
     work_in[10] = 2;

          /* don't want the char and box sizes */
     VDIhandle = graf_handle(&x, &y, &w, &h);

     v_opnvwk(work_in, &VDIhandle, work_out); /* open virtual work stn */

     /* clear the screen, and then force a redraw of the dither */
     v_clrwk(VDIhandle);
     wind_get(DESK, WF_WXYWH, &x, &y, &w, &h);
     form_dial(FMD_FINISH, 0L, 0L, x, y, w, h);

     /* 
      * Now  adjust the object coordinates from character based to pixel
      * based.  Also hook the strings to the string objects and buttons.  
      */
     for (i = j = 0; j < NUM_OBS; j++) {
          rsrc_obfix(rs_object, j);           /* fix the coordinates system */
          if (rs_object[j].type == G_STRING || rs_object[j].type == G_BUTTON)
               rs_object[j].spec = rs_strings[i++];
     }
}

void
cleartrack(num)
int num;
{
     /* 
      * clear a track.  Use buffer as a scratch area.
      */
     setmem(buffer, (512 * 10), 0);

     Flopwr(buffer, 0L, thedisk, 1, num, 0, 10);  /* write 10 sectors */
     
     if (dblsided)
          Flopwr(buffer, 0L, thedisk, 1, num, 1, 10); /* 10 more on the back */
}

extern exit();
asm {
exit:     dc.w 0         /* just a place holder to fool the linker */
}

void
main() 
{
     WORD x, y, w, h, which;

     /*
      * tell GEM hello.
      * we're glad to see him too.
      */
     init_gem();

     /* 
      * Next allocate the track buffer.
      * Give it 16K.  We "should" only need a little less than 
      * 8K, but it never hurts to have to much.
      */
     buffer = Malloc(0x4000L);

     sectoroffset = 0;   /* number sectors 1 to 10 not 11 to 20 */

     /* set the default buttons */
     rs_object[LONELY].state |= SELECTED;
     rs_object[DRIVE0].state |= SELECTED;

     /* put up the dialog */
     form_center(rs_object, &x, &y, &w, &h);
     form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
     objc_draw(rs_object, ROOT, 9, x-1, y-1, w+2, h+2);

     for(;;) {
          graf_mouse(0, 0L);  /* arrow */

          /* 
           * As you may gather, this isn't the normal form_do.
           * If you are using the normal one (highly likely 
           * since you don't have mine) just remove the 
           * ", 0L, 0L" from the call.  
           */
          which = form_do(rs_object, 0, 0L, 0L);

          if (which == RUNAWAY)
               break;         /* they don't want us.  boo hoo */

          graf_mouse(2, 0L);  /* busy bee */
 
          /* 
           * setup the input parameters for the format.
           */
          if (rs_object[DRIVE0].state & SELECTED)
               thedisk = 0;        /* format drive A */
          else 
               thedisk = 1;        /* otherwise drive B */

          if (rs_object[MARRIED].state & SELECTED)
               dblsided = -1;      /* double sided   */
          else
               dblsided = 0;       /* single sided   */

          Supexec(twister);   /* run the formatter in super mode */

          if (!badflag) {     /* good disk? */
               /*
                * Yes, now set it up as a GEMDOS disk.
                *
                * First clear the fat and directory sectors.
                * Simpliest is to just clear the first few tracks 
                */
               cleartrack(0);
               cleartrack(1);

               /* now prototype the boot sector */
	       /* this is where version 1.0 had a bug, it wrote the
                * same serial number on all disks
	        */
               Protobt(buffer, 0x02000000L, (dblsided ? 3 : 2), 0);

               /* now change the sectors per track entry.  (10 not 9) */
               put_word(buffer + 0x18, 10);

               /* next is the sectors on media entry. */
               put_word(buffer + 0x13, (dblsided ? 1600 : 800));

               /* and finally write the boot sector */
               Flopwr(buffer, 0L, thedisk, 1, 0, 0, 1);
          }
          else {
               graf_mouse(0, 0L);  /* arrow */
               form_alert(1, "[3][There was error formatting|the disk.][Abort]");  
          }

          /* deslect the format button */
          rs_object[TWISTIT].state &= ~SELECTED;
          objc_draw(rs_object, TWISTIT, MAX_DEPTH, x, y, w, h);
     }

     Mfree(buffer);      /* give it back to TOS */

     /* tell GEM bye, bye */
     form_dial(FMD_FINISH, 0L, 0L, x, y, w, h); /* force a redraw */
     v_clsvwk(VDIhandle);
     appl_exit();

     _exit(0);       /* wave bye, bye to the nice user */
}    

