/* EZ-Score Plus 1.1
 * Printout justification module (newjust.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   28 February 1988
 * Last modified: 11 April 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>

#include "ezp.h"
#include "structs.h"
#include "prtcnf.h"
#include "symbdefs.h"
#include "extern.h"
#include "cextern.h"
#include "header.h"

#define ptr_to_packet(a) fetchbp(currscreen[((a)<<2)+2],currscreen[((a)<<2)+3])

extern int  *fetchbp();

int   bartypes[2],
      endings[2],
      laststaff,     /* number of last staff used (always either 0 or 2)   */
      ts_startpt;    /* for Tom's benefit - cut-off point for ties & slurs */

int   *bars[2],      /* queues for current and next line's intro bars      */
      *clefs[MAXSTV],            /* arrays for next line's prelim symbols  */
      *keys[MAXSTV],
      *times[MAXSTV];

double   average;


init_justify()
{
   register int   i;

   for (i = 0; i < MAXSTV; i++)
      clefs[i] = keys[i] = times[i] = (int*)0L;
   bars[0] = bars[1] = (int*)0L;
   bartypes[0] = bartypes[1] = endings[0] = endings[1] = FALSE;
   average = 2.5;
   laststaff = (stasys == 1)? 0: MAXSTV - 1;
}


set_start()
{
   int   b, k, p, *packet, *prevpacket(), staff, t;

   init_justify();
   packet = prevpacket( sb, sp, &b, &p );
   if (packet) {                       /* not beginning at the beginning   */
      lastb = sb;
      lastp = sp;
      keytim_thisbar( sb, sp, TRUE, &k, &t );
      for (; packet; packet = prevpacket( b, p, &b, &p )) {
         switch (*packet) {
            case S_KEYSIG:
               if (!k) {
                  staff = ((short*)packet)[3];
                  if (!keys[staff])
                     keys[staff] = packet;
               }
               break;
            case S_TIMESIG:
               if (!t) {
                  staff = ((short*)packet)[3];
                  if (!times[staff])
                     times[staff] = packet;
               }
               break;
            case S_TREBCLEF:
            case S_BASSCLEF:
               staff = ((short*)packet)[3];
               if (!clefs[staff])
                  clefs[staff] = packet;
         }
      }
   } else {                                  /* beginning at the beginning */
      lastb = (-1);
      lastp = (-1);
   }
}


make_system()
{
   int   done;

   do_calc_data();
   if (nsymbonscr) {
      set_cutoff();
      done = adjust();
   } else
      done = TRUE;
   return done;
}


do_calc_data()
{
   int   b, p, prelim, tampaw, tampax;
   register int   i, j, w, x;

   if (lastb != eb || lastp != ep) {
      j = tampaw = w = 0;
      tampax = x = lmarg;
      domainflgs[6] = TRUE;
      for (i = 0; i < stasys; i++) {
         if (clefs[i]) {
            ptr_to_bp( clefs[i], &b, &p );
            currscreen[j++] = x + 4;
            currscreen[j++] = convert_y( i, ((short*)clefs[i])[4] );
            currscreen[j++] = b;
            currscreen[j++] = p;
            domain_x( currscreen[j-2], currscreen[j-1], &tampax, &tampaw );
            tampax = currscreen[j-4];
         }
      }
      w = tampaw;
      x = tampax;
      for (i = 0; i < stasys; i++) {
         if (keys[i] && ((char*)(keys[i]))[6]) {   /* keysig not natural? */
            ptr_to_bp( keys[i], &b, &p );
            currscreen[j++] = x + w + 4;
            currscreen[j++] = (-1);
            currscreen[j++] = b;
            currscreen[j++] = p;
            domain_x( currscreen[j-2], currscreen[j-1], &tampax, &tampaw );
            tampax = currscreen[j-4];
         }
      }
      w = tampaw;
      x = tampax;
      for (i = 0; i < stasys; i++) {
         if (times[i]) {
            ptr_to_bp( times[i], &b, &p );
            currscreen[j++] = x + w + 4;
            currscreen[j++] = (-1);
            currscreen[j++] = b;
            currscreen[j++] = p;
            domain_x( currscreen[j-2], currscreen[j-1], &tampax, &tampaw );
            tampax = currscreen[j-4];
         }
      }
      w = tampaw;
      x = tampax;
      if (bartypes[1] == S_START || bartypes[1] == S_STARTEND) {
         ptr_to_bp( bars[1], &b, &p );
         currscreen[j++] = (x > lmarg)? x + w + 4: x + w;
         currscreen[j++] = (-1);
         currscreen[j++] = b;
         currscreen[j++] = p;
         domain_x( currscreen[j-2], currscreen[j-1], &tampax, &tampaw );
         w = tampaw;
         x = currscreen[j-4];
      }
      ts_startpt = (x > lmarg)? x + w + 2: x;
      prelim = j >> 2;
      currscreen = (int*)((long)currscreen + (j << 1));
      maxnsymb -= prelim;
      nsymbonscr = calc_data( lastb, lastp, eb, ep, x + w, rmarg );
      maxnsymb += prelim;
      currscreen = (int*)((long)currscreen - (j << 1));
      if (nsymbonscr)
         nsymbonscr += prelim;
   } else
      nsymbonscr = 0;
}


set_cutoff()
{
   register int   bar_last, bar_2last, i, lastsymb, *ptr_key, *ptr_time;
   int   clef_last[MAXSTV], clef_2last[MAXSTV], dummy, key_last[MAXSTV],
         key_2last[MAXSTV], *nextpacket(), *packet, time_last[MAXSTV],
         time_2last[MAXSTV], type;
   short staff;

   bar_last = bar_2last = (-1);                 /* initialize all indices  */
   for (i = 0; i < MAXSTV; i++)
      clef_last[i] = clef_2last[i] = key_last[i] = key_2last[i] =
            time_last[i] = time_2last[i] = (-1);
                  /* find last two of each type of symbol for each staff   */
   for (i = 0; i < nsymbonscr; i++) {
      packet = ptr_to_packet( i );
      type = *packet;
      staff = ((short*)packet)[3];
      switch (type) {
         case S_KEYSIG:
            key_2last[staff] = key_last[staff];
            key_last[staff] = i;
            break;
         case S_TIMESIG:
            time_2last[staff] = time_last[staff];
            time_last[staff] = i;
            break;
         case S_TREBCLEF:
         case S_BASSCLEF:
            clef_2last[staff] = clef_last[staff];
            clef_last[staff] = i;
            break;
         default:
            if (type >= S_BAR && type <= S_STARTEND) {
               bar_2last = bar_last;
               bar_last = i;
            }
      }
   }
            /* whittle out stuff that won't end up in this line after all  */
   i--;
   if (nextpacket( currscreen[(i << 2) + 2], currscreen[(i << 2) + 3], &dummy,
         &dummy )) {
      i = max( key_last[laststaff], time_last[laststaff] ); /* not end of  */
      lastsymb = max( i, bar_last );                        /* score...    */
      if (time_last[laststaff] < lastsymb &&
            keytim_thisbar( currscreen[(lastsymb << 2) + 2],
            currscreen[(lastsymb << 2) + 3], FALSE )) {
         ptr_key = (key_last[laststaff] > bar_last)? key_2last: key_last;
         ptr_time = (time_last[laststaff] > bar_last)? time_2last: time_last;
         if (bar_2last > 0) {
            i = max( ptr_key[laststaff], ptr_time[laststaff] );
            lastsymb = max( i, bar_2last );
         } else
            lastsymb = (bar_last > 0)? bar_last: nsymbonscr - 1;
      } else {
         ptr_key = key_last;
         ptr_time = time_last;
         i = max( ptr_key[laststaff], ptr_time[laststaff] );
         lastsymb = max( i, bar_last );
      }
      if (ptr_time[laststaff] < lastsymb) /* time signatures don't appear on */
         for (i = 0; i < 3; i++)       /* next line unless they're brand new */
            ptr_time[i] = (-1);
      for (i = 0; i < 3; i++) {    /* clefs don't have to all appear at once */
         if (clef_last[i] > lastsymb)
            clef_last[i] = (clef_2last[i] > lastsymb)? (-1): clef_2last[i];
      }
      if (bar_last > lastsymb)
         bar_last = bar_2last;
   } else {                                           /* end of the score  */
      ptr_key = key_last;
      ptr_time = time_last;
      lastsymb = i;
   }
   update_array( clefs, clef_last );      /* update arrays with this info  */
   update_array( keys, ptr_key );
   update_array( times, ptr_time );
   update_barbequeue( bar_last );
   nsymbonscr = ++lastsymb;
}


/* Scan through thread from just after the given symbol to the next bar,   */
/* note, rest, repeat symbol, key signature, or time signature.  If in     */
/* that range we don't find a key or time signature, return FALSE.         */
keytim_thisbar( b, p, flag, k, t )
int b, p, flag, *k, *t;
{
   register int   change, family, *packet, quit, type;
   int   *nextpacket();

   change = quit = FALSE;
   if (flag) *k = *t = FALSE;
   do {                       /* search the thread for important symbols   */
      packet = nextpacket( b, p, &b, &p );
      if (packet) {
         type = *packet;
         switch (type) {
            case S_KEYSIG:
               if (flag)
                  *k = TRUE;
               change = TRUE;
               break;
            case S_TIMESIG:
               if (flag)
                  *t = TRUE;
               change = TRUE;
               break;
            case S_REPEAT1:
            case S_REPEAT2:
               quit = TRUE;
               break;
            default:
               family = getfamily( type );
               if (family == F_NOTES || family == F_RESTS || family == F_BARS)
                  quit = TRUE;
         }
      } else
         quit = TRUE;
   } while (!quit);
   return change;    /* return TRUE if a new key or meter has been found   */
}


update_array( glob, loc )
register int *glob[];
register int *loc;
{
   register int   i;

   for (i = 0; i < MAXSTV; i++)
      glob[i] = (loc[i] >= 0)? ptr_to_packet( loc[i] ): (int*)0L;
}


update_barbequeue( bar )
register int bar;
{
   int   b, p;
   register int   *packet;

   if (bars[0])
      *bars[0] = bartypes[0];
   packet = (bar >= 0)? ptr_to_packet( bar ): (int*)0L;
   bars[0] = bars[1];
   bars[1] = packet;
   bartypes[0] = bartypes[1];
   bartypes[1] = (packet)? *packet: 0;
   switch (bartypes[1]) {
      case S_START: *bars[1] = S_BAR; break;
      case S_STARTEND: *bars[1] = S_END;
   }
   if (bartypes[0] == S_START || bartypes[0] == S_STARTEND)
      *bars[0] = S_START;
   endings[0] = endings[1];
   endings[1] = (packet)? ((((short*)packet)[11] & 0x09) == 0x09): FALSE;
   if (endings[0]) {
      ptr_to_bp( bars[0], &b, &p );
      currscreen = (int*)((long)currscreen - 8);
      currscreen[0] = ts_startpt;
      currscreen[1] = (-1);
      currscreen[2] = b;
      currscreen[3] = p;
      currscreen = (int*)((long)currscreen + 8);
      nof_endg = TRUE;
   } else
      nof_endg = FALSE;
}


adjust()
{
   register int   *cs_packet, i, type;
   int   done, dummy, extra, firstsymb, firstx, justarea, lastfamily, lastsymb,
         lastw, lastx, *nextpacket();
   double   adjustment;

         /* locate first symbol that is not a clef, key sig, or time sig   */
   for (i = 0; i < nsymbonscr; i++) {
      type = *ptr_to_packet( i );
      if (type != S_TREBCLEF && type != S_BASSCLEF && type != S_KEYSIG &&
            type != S_TIMESIG)
         break;
   }
   /* this is the first symbol to be taken into account for justification  */
   firstsymb = i;
   firstx = currscreen[i << 2];
         /* now let's get all sorts of valuable info about the last symbol */
   lastsymb = nsymbonscr - 1;
   cs_packet = &currscreen[lastsymb << 2];
   domainflgs[6] = TRUE;
   domain_x( cs_packet[2], cs_packet[3], &lastx, &lastw );
   lastx = *cs_packet;
   if (lastx <= firstx)
      lastx = rmarg - lastw - 4;
   lastfamily = getfamily( *ptr_to_packet( lastsymb ) );
   extra = (lastfamily == F_BARS)? 0: 4;
               /* now we figure out the multiplication factor to be used   */
   justarea = rmarg - lastw - extra - firstx;
   adjustment = (double)justarea / (double)(lastx - firstx);
            /* if there is no next packet, this will be the last system of */
            /* the score, and it may be worthwhile to re-figure the above  */
   if (!nextpacket( cs_packet[2], cs_packet[3], &dummy, &dummy )) {
      if (adjustment > average) {
         rmarg = ((int)((lastx - firstx) * average) + firstx  | 0x0F) + 1;
         justarea = rmarg - lastw - extra - firstx;
         adjustment = (double)justarea / (double)(lastx - firstx);
      }
      done = TRUE;
   } else
      done = FALSE;
         /* and update the "average" (of this line and previous "average") */
   average = (average + adjustment) / 2.0;
                                       /* and now we justify the symbols!  */
   for (i = firstsymb; i < nsymbonscr; i++) {
      cs_packet = &currscreen[i << 2];
      *cs_packet = (int)((double)(*cs_packet - firstx) * adjustment) + firstx;
   }
      /* to avoid mildly annoying round-off error that is only important   */
      /* when the last symbol is a bar (since in other cases the staff is  */
      /* expected to hang out a little), we add one if lastsymb is a bar   */
   if (lastfamily == F_BARS)
      *cs_packet += 1;
   return done;
}

/* EOF */
