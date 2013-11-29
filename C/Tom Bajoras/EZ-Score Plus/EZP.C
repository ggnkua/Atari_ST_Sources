/* EZ-Score Plus 1.1
 * Printer output main module (ezp.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1987, 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   26 June 1987
 * Last modified: 29 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>
#include <tos.h>

/* Resist the temptation to alphabetically sort the #include's; there are  */
/* some dependencies between them that make this order necessary.          */

#include "ezp.h"
#include "ezprsc.h"
#include "structs.h"
#include "prtcnf.h"
#include "symbdefs.h"
#include "text.h"
#include "extern.h"
#include "header.h"

extern int  *bars[],          /* declared in newjust.c   */
            endings[];
extern int  gl_hand;          /* Tom's vdi handle  */

/* my globals  */
int   abortp,                 /* abort if this ever goes TRUE              */
      ahite,                  /* height of image buffer                    */
      bitln,                  /* bits per line in printout                 */
      bm,                     /* permanent bottom margin                   */
      bmarg,                  /* bottom margin, gets messed with           */
      bufsz,                  /* size of image buffer in bytes             */
      bytln,                  /* bytes per line in printout                */
#if DEBUG
      dbug,                   /* boolean flag: are we in debug mode?       */
#endif
      eb,                     /* end block number (last symbol to print)   */
      ep,                     /* end packet number                         */
      lastb,                  /* block # of last symbol in prev currsc.    */
      lastp,                  /* packet # of last symbol in prev currsc.   */
      lm,                     /* permanent left margin                     */
      lmarg,                  /* left margin, gets messed with             */
      *measnum,               /* array of y positions for measure numbers  */
      page,                   /* current page number                       */
      rm,                     /* permanent right margin                    */
      rmarg,                  /* right margin, gets messed with            */
      rasys,                  /* raster lines per system                   */
      sb,                     /* starting block number                     */
      sp,                     /* starting packet number                    */
      *staffy,                /* an array of page y-offsets for each staff */
      stasys,                 /* staves per system - not all visible?      */
      sysmax,                 /* program's idea of max systems per page    */
      syspg,                  /* systems per page                          */
      sysrec,                 /* program's recommendation for syspg        */
      tm,                     /* permanent top margin                      */
      tmarg,                  /* top margin, gets messed with              */
      visys,                  /* number of visible staves per system       */
      voff,                   /* y position of top of current image        */
      yntrvl;                 /* size of vertical area for each system     */

short *s_image;      /* image buffer -- draw here & send it out to printer */

char  *cancan, *set_1_216, *set_22_216, *set_8_72, *reset_1_6, *fmode, *dmode;

GRECT    desk;                         /* desktop coordinates  */

LBRACE   *braces;             /* vertical domains for each brace     */
LBRACK   *brackets;           /*     "       "     "   "   bracket   */
SYSDOM   *systems,            /*     "       "     "   "   system    */
         *liney;              /*     "       "     "  title lines    */

PRINTER  *printer;

PSYM  bracei[14];


ezp()                   /* This is Tom's entry point  */
{
   int   *adr, *ezpstart();

#if DEBUG
   if (Kbshift( -1 ) & 0x04) {      /* hold Control key for debugging */
      dbug = TRUE;
      Bconout( 2, 7 );              /* a little bell as acknowledgement */
   } else
      dbug = FALSE;
#endif
   if (check_prt() && get_range( PRTSEC, &sb, &sp, &eb, &ep, 1 )) {
      waitmouse();
      prt_or_scr( 1 );
      adr = ezpstart();
      currscreen = (int*)((long)currscreen + 8);
      maxnsymb -= 1;
      score_it();
      maxnsymb += 1;
      currscreen = (int*)((long)currscreen - 8);
      ezpfin( adr );
      prt_or_scr( 0 );
      waitmouse();
      return TRUE;
   } else {
      waitmouse();
      return FALSE;
   }
}


check_prt()
{
   for (;;) {
      if (Bcostat( PRT ))
         return TRUE;
      else if (form_alert( 1, NO_PRINTER ) == 2)
         return FALSE;
   }
}


score_it()
{
   int   done;

   set_params();
   prtstring( cancan[0], 1, &cancan[1] );
   set_start();
   do {
      top_of_page();
      done = body_of_page();
      prtchar( 0x0c );	/* ff */
   } while (!abortp && !done);
   prtstring( reset_1_6[0], 1, &reset_1_6[1] );   /* done */
}


set_params()
{
   init_margins();
   page = 0;
   if (is_magic())
      size_systems();
   else
      pinfo_init();
   setup_liney();
   syspg = max( sysrec, (bmarg - tmarg) / ((bm - tm) / pageptr[PSYSUSR]) );
   if (syspg > pageptr[PSYSUSR])
      syspg = pageptr[PSYSUSR];
   setup_systems();
   mod_liney();
   rez = 2;
   skip_rehr = pageptr[HRMHID];
   gr_clip = skip_lrehr = TRUE;
   bytesperline = bytln;
   x_left = lm;
   x_right = rm;
   clr_domain();
}


size_systems()
{
   register int   h, i, j, sysize;

   stasys = (int)N_STAVES;
   init_symb_structs();
   h = staff.height;
   sysize = j = 0;
   for (i = 0; i < stasys; i++) {   /* determine rasters per system  */
      if (!invisible( i )) {
         sysize += h + ONESPACE * (leg_above( i ) + leg_below( i ));
         j++;
      }
   }
   sysize += ONESPACE * j;          /* the extra space between staves   */
   rasys = sysize;
   visys = j;
   sysmax = (bmarg - tmarg) / rasys;
   sysrec = (bmarg - tmarg) / (rasys + SYSTOPX + SYSBOTX);
}


setup_systems()
{
   int   bracidx, brktidx, first, lastvis;
   register int   edge, i, j, sys;

   yntrvl = (bmarg - tmarg) / syspg;
   bracidx = brktidx = 0;
   for (sys = 0; sys < syspg; sys++) {
      i = sys * stasys;
      first = TRUE;
      for (j = 0; j < stasys; j++) {
         if (invisible( j ))
            staffy[i+j] = 0;
         else {
            if (first) {
               first = FALSE;
               systems[sys].top = yntrvl * sys + tmarg;
               systems[sys].size = yntrvl - 1;
               staffy[i+j] = systems[sys].top + (yntrvl - rasys >> 1) +
                     ONESPACE * leg_above( j );
               measnum[sys] = staffy[i+j] - 60;
            } else
               staffy[i+j] = staffy[i+lastvis] + staff.height + ONESPACE +
                     ONESPACE * (leg_above( j ) + leg_below( lastvis ));
            lastvis = j;
            edge = edge_conn( j );
            if (bracidx < MAXCON) {          /* map left edge connectors   */
               if (edge & DNBRACE) {
                  braces[bracidx].size = (staffy[i+j] + staff.height) -
                     braces[bracidx].top;
                  bracidx++;
               } else if (edge & UPBRACE)
                  braces[bracidx].top = staffy[i+j];
            }
            if (brktidx < MAXCON) {
               if (edge & DNBRACK) {
                  brackets[brktidx].size = (staffy[i+j] + staff.height +
                        brackb.height) - brackets[brktidx].top;
                  brktidx++;
               } else if (edge & UPBRACK)
                  brackets[brktidx].top = staffy[i+j] - brackt.height - 1;
            }
         }
      }
   }
   /* determines which brace image to use for each, adjust positions */
   for (i = 0; i < MAXCON && braces[i].top; i++) {
      j = braces[i].size;
      braces[i].psym = (j <= 182)? &bracei[0]: &bracei[(j - 168) / 45 + 1];
      if (j != (braces[i].psym)->height) {
         j = (braces[i].psym)->height - j;
         braces[i].top -= j >> 1;
         braces[i].size += j;
      }
   }
   for (i = 0; i < stasys; i++) {      /* set up Tom's staff_y array */
      if (staffy[i]) {
         staff_y[i] = staffy[i] - systems[0].top;
         staffview[i] = TRUE;
      } else {
         staff_y[i] = 0;
         staffview[i] = FALSE;
      }
   }
}


top_of_page()
{
   if (page == 1) {
      init_margins();
      erase_liney();
      syspg = pageptr[PSYSUSR];
      setup_systems();
   }
   if (!abortp && pageptr[HSINGLE] && page)
      form_alert( 1, NEXT_SHEET );
   page++;
}


body_of_page()
{
   int   b, *flastbar(), indent, more, nl, p, y;
   register int   i, retval, runoff, sys;
   long  fl;

   sys = 0;
   indent = FALSE;
   if (page == 1) {
      if (pageptr[HINDFSY]) {
         lmarg += INDENT;
         x_left = lmarg;
         indent = TRUE;
      }
   }
   retval = make_system();
   if (nsymbonscr) {
      do {
         for (i = 0; i < bufsz; s_image[i++] = 0)        /* clear image */
            ;
         if (page == 1 && pageptr[HTISHOWN])
            print_titcop();
         if (pageptr[HPNSHOWN])
            print_pagenum( page );
         more = TRUE;
         while (!abortp && more && nsymbonscr) {
            if (clip_img( systems[sys].top, yntrvl, &fl, &nl, &y )) {
               gr_clipx1 = lm;
               gr_clipy1 = (int)fl;
               gr_clipx2 = rm;
               gr_clipy2 = gr_clipy1 + nl - 1;
               scrbase = (long)s_image + (y? (bytln * (long)y):
                     (-(bytln * fl)));
               show_symbs( gr_clipx1, gr_clipx2 );
               if (endings[0]) {
                  currscreen = (int*)((long)currscreen - 8);
                  nsymbonscr += 1;
                  ptr_to_bp( bars[0], &b, &p );
                  putending( b, p );
                  nsymbonscr -= 1;
                  currscreen = (int*)((long)currscreen + 8);
               }
               if (lastb > 0 && pageptr[HRMSHOWN])
                  putrehear( (long)flastbar( lastb, lastp ) + 8,
                        lmarg + (rehearw >> 1) );
               draw_staves( sys );
            }
            if (sys < syspg - 1 && fl + nl >= yntrvl) {
               if (indent) {
                  indent = FALSE;
                  lmarg -= INDENT;
                  x_left = lmarg;
               }
               lastb = currscreen[((nsymbonscr-1) << 2) + 2];
               lastp = currscreen[((nsymbonscr-1) << 2) + 3];
               sys++;
               retval = make_system();
               more = nsymbonscr? TRUE: FALSE;
            } else
               more = FALSE;
         }
         if (!abortp)
            runoff = print_img();
      } while (!(abortp || runoff));
      if (nsymbonscr) {
         lastb = currscreen[((nsymbonscr-1) << 2) + 2];
         lastp = currscreen[((nsymbonscr-1) << 2) + 3];
      }
   } else
      retval = TRUE;
   return retval;
}


clip_img( top, size, fl, nl, y )
register int top;
register int size;
register long *fl;
register int *nl;
int *y;
{
   register int   diff, test;

   if (top + size) {
      diff = top - voff;
      test = diff >= 0;
      if (test? diff < ahite: -diff < size) {
         if (test) {
            *fl = 0L;
            *nl = min( size, ahite - diff );
            *y = diff;
         } else {
            *fl = (-diff);
            *nl = min( size + diff, ahite );
            *y = 0;
         }
         return TRUE;
      }
   }
   *fl = 0L;
   *nl = 0;
   *y = 0;
   return FALSE;
}


/* Return block and packet values based on a pointer to the packet */
ptr_to_bp( ptr, b, p )
register long ptr;
register int *b;
register int *p;
{
   ptr -= (long)dataptr;
   *b = (int)(ptr >> 10);              /*  *b = (int)(ptr / 1024);         */
   *p = (int)((ptr & 0x3FF) >> 4);     /*  *p = (int)((ptr % 1024) / 16);  */
}


int *flastbar( b, p )
int b, p;
{
   int   *fetchbp();
   register int   *ptr, sym;

   do {
      ptr = fetchbp( b, p );
      sym = *ptr;
      prevpacket( b, p, &b, &p );
   } while (sym < S_BAR || sym > S_STARTEND);
   return ptr;
}


print_img()
{
   if (printer->pins == 9)
      prt_img09();
   else
      prt_img24();
}


#if DEBUG
blit_it()
{
   int   pxy[8];
   FDB   scr, sim;

   scr.fd_addr = Physbase();           sim.fd_addr = (long)s_image;
   scr.fd_w = 640;                     sim.fd_w = 960;
   scr.fd_h = 400;                     sim.fd_h = 240;
   scr.fd_wdwidth = 40;                sim.fd_wdwidth = 60;
   scr.fd_stand =                      sim.fd_stand = 0;
   scr.fd_nplanes =                    sim.fd_nplanes = 1;
   scr.fd_r1 = scr.fd_r2 = scr.fd_r3 = sim.fd_r1 = sim.fd_r2 = sim.fd_r3 = 0;
   pxy[0] = pxy[1] =                   pxy[4] = pxy[5] = 0;
   pxy[2] =                            pxy[6] = 639;
   pxy[3] =                            pxy[7] = 239;
   vro_cpyfm( gl_hand, S_ONLY, pxy, &sim, &scr );
}
#endif

/* EOF */
