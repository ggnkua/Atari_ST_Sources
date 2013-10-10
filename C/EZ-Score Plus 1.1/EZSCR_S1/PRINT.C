/* EZ-Score Plus 1.1
 * Output to printer module (print.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   07 February 1988
 * Last modified: 06 March 1988
 */

overlay "ezp"

#include <misc.h>
#include <tos.h>

#include "ezp.h"

extern int  voff;

int   voffamt;


setvoff( amt )
int amt;
{
   voffamt = amt;
}


prtstring( count, loop, pdata )
register int count, loop;
register char *pdata;
{
   register int   cnt;
   register char  *line;

   for (; loop; loop--) {
      line = pdata;
      for (cnt = count; cnt; cnt--)
         Bconout( PRT, *line++ );
   }
}


prtchar( ch )
register char ch;
{
   Bconout( PRT, ch );     /* Sendeth thou all the linefeeds and formfeeds */
   if (ch == 0x0a)         /* that thou hast through this most holy of     */
      voff += voffamt;     /* subroutines, lest Voff become wrathful and   */
   else if (ch == 0x0c)    /* smite thee, wherefore wilt thou suffer.      */
      voff = 0;
}


prtcrlf()
{
   prtchar( 0x0d );
   prtchar( 0x0a );
}

/* EOF */
