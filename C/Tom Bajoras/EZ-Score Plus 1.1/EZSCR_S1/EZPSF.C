/* EZ-Score Plus 1.1
 * Startup and cleanup for printout module (ezpsf.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   07 February 1988
 * Last modified: 29 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>
#include <tos.h>

#include "ezp.h"
#include "ezprsc.h"
#include "structs.h"
#include "prtcnf.h"
#include "extern.h"
#include "cextern.h"

/* declare in-line assembly routines */
extern   insuper(), interrupt(), savereg();

GRECT abort;
char  *prname;


int *ezpstart()
{
   register int   i, *adr;
   int   *save_globl();

   setup_page();
   setup_strings();
   liney = (SYSDOM*)scrsave;
   staffy = (int*)&liney[MAXLIN];
   measnum = &staffy[MAXSYS];
   systems = (SYSDOM*)&measnum[MAXSYS];
   brackets = (LBRACK*)&systems[MAXSYS];
   braces = (LBRACE*)&brackets[MAXCON];
   for (i = 0; i < MAXCON; i++) {
      braces[i].top = 0;
      braces[i].psym = (PSYM*)0L;
      braces[i].size = 0;
      brackets[i].top = 0;
      brackets[i].size = 0;
   }
   abortp = voff = FALSE;
   init_symb_structs();
   adr = (int*)&braces[MAXCON];
   s_image = (short*)save_globl( adr );
   calc_bufsize();
   graf_mouse( ARROW );
   wind_get( DESKTOP, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w,
         &desk.g_h );
   prinaddr->ob_x = (desk.g_x + desk.g_w - prinaddr->ob_width) >> 1;
   prinaddr->ob_y = (desk.g_y + desk.g_h - prinaddr->ob_height) >> 1;
   ((TEDINFO*)(prinaddr[PRNTYPE].ob_spec))->te_ptext = prname;
   objc_draw( prinaddr, ROOT, MAX_DEPTH, prinaddr->ob_x - 3,
         prinaddr->ob_y - 3, prinaddr->ob_width + 6, prinaddr->ob_height + 6 );
   objc_offset( prinaddr, ABORT, &abort.g_x, &abort.g_y );
   abort.g_w = prinaddr[ABORT].ob_width;
   abort.g_h = prinaddr[ABORT].ob_height;
   set_interrupt();
   return adr;
}


setup_page()
{
   printer = (PRINTER*)printers;
   bytln = printer->bytes_line;
   bitln = bytln * 8;
   init_margins();
}


init_margins()
{
   tm = tmarg = printer->top_margin;
   lm = lmarg = printer->left_margin;
   rm = rmarg = printer->right_margin;
   bm = bmarg = printer->bottom_margin;
}


setup_strings()
{
   cancan = &printers[STRBASE];
   set_8_72 = &cancan[(cancan[0]+1)];
   set_1_216 = &set_8_72[(set_8_72[0]+1)];
   set_22_216 = &set_1_216[(set_1_216[0]+1)];
   reset_1_6 = &set_22_216[(set_22_216[0]+1)];
   fmode = &reset_1_6[(reset_1_6[0]+1)];
   dmode = &fmode[(fmode[0]+1)];
   prname = &dmode[(dmode[0]+1)];
}


calc_bufsize()
{
   register int   height, space;

   space = (int)((long)(&((short*)scrsave)[TBUF]) - (long)s_image);
   height = space / bytln;
   ahite = (printer->pins == 9)? (height / 24) * 24: (height / 29) * 29;
   bufsz = ahite * bytln;
#if DEBUG
   if (dbug)
      show_addresses( "Top used:", "Top allowed:", &s_image[bufsz],
            &((short*)scrsave)[TBUF] );
#endif
}


#if DEBUG
show_addresses( text1, text2, adr1, adr2 )
char *text1, *text2;
short *adr1, *adr2;
{
   char  buf[60];

   sprintf( buf, "[1][%-15.15s 0x%06lx|%-15.15s 0x%06lx][OK]", text1, adr1,
         text2, adr2 );
   form_alert( 1, buf );
}
#endif


int *save_globl( adr )
register int *adr;
{
   register int   i;

   *adr++ = (int)(scrbase >> 16);  /* save Tom's globals that I will change  */
   *adr++ = (int)(scrbase & 0xFFFF);
   for (i = 0; i < 3; i++)
      *adr++ = staffview[i];
   for (i = 0; i < 3; i++)
      *adr++ = staff_y[i];
   *adr++ = gr_clipx1;
   *adr++ = gr_clipy1;
   *adr++ = gr_clipx2;
   *adr++ = gr_clipy2;
   *adr++ = (int)gr_clip;
   *adr++ = rez;
   *adr++ = bytesperline;
   *adr++ = (int)skip_rehr;
   *adr++ = (int)skip_lrehr;
   *adr++ = (int)nof_endg;
   *adr++ = x_left;
   *adr++ = x_right;
   return adr;
}


set_interrupt()
{
   Supexec( insuper );
   Xbtimer( 0, 7, 0, interrupt );          /* timer A, 47.968 Hz */
}


asm {
insuper:
   lea      savereg(PC),A0       ; save A4 (Megamax data/bss segment pointer)
   move.l   A4,(A0)              ;  so it will be available for the interrupt

   lea      the_rte(PC),A0       ; point spurious interrupt vector at an rte
   move.l   A0,0x60              ;  since it tends to cause trouble
   rts

savereg:
   dc.l  0

interrupt:
   movem.l  D7/A3-A4,-(A7)
   movea.l  savereg(PC),A4       ; restore A4 so we can get at our globals

   movea.l  Mstate(A4),A3        ; get mouse button state
   move.b   (A3),D7
   andi.w   #0x03,D7             ; mask out extraneous bits
   beq.s    nothing

   movea.l  Mousex(A4),A3        ; get mouse x position
   move.w   (A3),D7
   sub.w    abort(A4),D7         ; get x distance from abort box left edge
   cmp.w    abort+4(A4),D7       ; compare to abort box width
   bhi.s    nothing

   movea.l  Mousey(A4),A3        ; get mouse y position
   move.w   (A3),D7
   sub.w    abort+2(A4),D7       ; get y distance from abort box top edge
   cmp.w    abort+6(A4),D7       ; compare to abort box height
   bhi.s    nothing

   move.w   #TRUE,abortp(A4)     ; button pressed inside abort box!

nothing:
   movem.l  (A7)+,D7/A3-A4
   bclr     #5,0xFFFA0F          ; clear ISRA bit - interrupt concluded
the_rte:
   rte
}


ezpfin( adr )
register int *adr;
{
   register int   i;

   Xbtimer( 0, 0, 0, 0L );                   /* shut off timer A  */
   scrbase = ((long)(*adr++)) << 16;      /* restore Tom's globals   */
   scrbase |= ((long)(*adr++)) & 0xFFFF;  /* beware sign extension!! */
   for (i = 0; i < 3; i++)
      staffview[i] = *adr++;
   for (i = 0; i < 3; i++)
      staff_y[i] = *adr++;
   gr_clipx1 = *adr++;
   gr_clipy1 = *adr++;
   gr_clipx2 = *adr++;
   gr_clipy2 = *adr++;
   gr_clip = (char)(*adr++);
   rez = *adr++;
   bytesperline = *adr++;
   skip_rehr = (short)(*adr++);
   skip_lrehr = (short)(*adr++);
   nof_endg = (short)(*adr++);
   x_left = *adr++;
   x_right = *adr;
}

/* EOF */
