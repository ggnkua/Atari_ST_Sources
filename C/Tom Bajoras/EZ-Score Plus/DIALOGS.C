/* EZ-Score Plus 1.1
 * Printer-related dialog control module (dialogs.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   07 February 1988
 * Last modified: 18 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>
#include <string.h>
#include <tos.h>

#include "ezp.h"
#include "ezprsc.h"
#include "structs.h"
#include "prtcnf.h"
#include "text.h"
#include "extern.h"
#include "header.h"
#include "cextern.h"

int   hoptradio[] = { 17, HROUGH, HDRAFT, HFINAL, HSINGLE, HFEED,
         HTIHID, HTISHOWN, HPNHID, HPNSHOWN, HMNSHOWN, HMNHID,
         HRMHID, HRMSHOWN, HDSTRKON, HDSTRKOF, HINDFSN, HINDFSY };

int   doptradio[] = { 17, ROUGH, DRAFT, FINAL, SINGLE, FEED,
         TIHIDDEN, TISHOWN, PNHIDDEN, PNSHOWN, MNSHOWN, MNHIDDEN,
         RMHIDDEN, RMSHOWN, DSTRKON, DSTRKOFF, INDFSNO, INDFSYES };

int   hpgline[] = { 7, PGLINE1, PGLINE2, PGLINE3, PGLINE4, PGLINE5,
         PGLINE6, PGLINE7 };

int   dpgline[] = { 7, LINE1, LINE2, LINE3, LINE4, LINE5, LINE6, LINE7 };

int   hpnpos[] = { 6, HPNPTOP, HPNPBOT, HPNPALT, HPNPLEFT, HPNPCENT,
         HPNPRIGT };

int   dpnpos[] = { 6, PNPTOP, PNPBOT, PNPALT, PNPLEFT, PNPCENT, PNPRIGT };

int   dpgattr[] = { 10, CENTER1, CENTER2, CENTER3, CENTER4, CENTER5,
         LARGE1, LARGE2, LARGE3, LARGE4, LARGE5 };

pinfo_init()
{
   register int   end, i;

   if (!is_magic()) {
      end = dpgline[0];
      for (i = 1; i <= end; i++)
         pageptr[(hpgline[i])] = '\0';
      end = dpgattr[0] >> 1;
      for (i = 0; i < end; i++) {
         pageptr[PGTLRG+i] = (char)FALSE;
         pageptr[PGTCNT+i] = (char)FALSE;
      }
      pageptr[HPNPBOT] = pageptr[HPNPCENT] = (char)TRUE;
      pageptr[HPNPTOP] = pageptr[HPNPALT] = pageptr[HPNPLEFT] =
            pageptr[HPNPRIGT] = (char)FALSE;
      ((int*)pageptr)[HPNOFF] = ((int*)pageptr)[HMNOFF] = 0;
      pageptr[HROUGH] = (char)FALSE;
      end = doptradio[0];
      for (i = 2; i <= end; i += 2) {
         pageptr[(hoptradio[i])] = (char)FALSE;
         pageptr[(hoptradio[i+1])] = (char)TRUE;
      }
      size_systems();
      pageptr[PSYSUSR] = (char)sysrec;
      set_magic();
   }
}


ex_page()
{
   register int   badstat, end, i, val;
   char  buf[2];
   register char  *str;
	char  *palerts[8];

	palerts[0]= BAD_MISTAKE;
	palerts[1]= BAD_MEASOFF;
	palerts[2]= BAD_PAGEOFF;
	palerts[3]= BAD_PM;
	palerts[4]= BAD_SYSCOUNT;
	palerts[5]= BAD_SM;
	palerts[6]= BAD_SP;
	palerts[7]= BAD_SPM;

   gr_device = 1;
   setup_page();
   if (pageaddr[LARGE1].ob_height == pageaddr[PNPTOP].ob_height) {
      end = dpgattr[0];
      for (i = 1; i <= end; i++)
         pageaddr[(dpgattr[i])].ob_height -= 1;
   }
   if (is_magic()) {
      size_systems();
      if (pageptr[PSYSUSR] <= 0 || pageptr[PSYSUSR] > sysmax)
         pageptr[PSYSUSR] = (char)sysrec;
   } else
      pinfo_init();
   do {
      badstat = 0;
      str = textptr( pageaddr, DMAXSYS );
      itoa( sysmax, &str[24], 2 );
      str = textptr( pageaddr, DRECSYS );
      itoa( sysrec, &str[13], 2 );
      str = textptr( pageaddr, DSYSPG );
      itoa( pageptr[PSYSUSR], str, 2 );
      str = textptr( pageaddr, MNOFFSET );
      val = ((int*)pageptr)[HMNOFF];
      if (val >= 0)
         itoa( val, str, 5 );
      else {
         *str++ = '-';
         itoa( -val, str, 4 );
      }
      str = textptr( pageaddr, PNOFFSET );
      itoa( ((int*)pageptr)[HPNOFF], str, 3 );
      end = dpgline[0];
      for (i = 1; i <= end; i++)
         strncpy( textptr( pageaddr, dpgline[i] ), &pageptr[(hpgline[i])],
               61 );
      end = dpgattr[0] >> 1;
      for (i = 1; i <= end; i++) {
         pageaddr[(dpgattr[i])].ob_state = pageptr[PGTCNT+i-1];
         pageaddr[(dpgattr[i+end])].ob_state = pageptr[PGTLRG+i-1];
      }
      end = dpnpos[0];
      for (i = 1; i <= end; i++)
         pageaddr[(dpnpos[i])].ob_state = pageptr[(hpnpos[i])];
      if (do_dial( pageaddr, 0 ) == PAGEOK) {
         for (i = 1; i <= end; i++)
            pageptr[(hpnpos[i])] = pageaddr[(dpnpos[i])].ob_state;
         end = dpgattr[0] >> 1;
         for (i = 1; i <= end; i++) {
            pageptr[PGTCNT+i-1] = pageaddr[(dpgattr[i])].ob_state;
            pageptr[PGTLRG+i-1] = pageaddr[(dpgattr[i+end])].ob_state;
         }
         end = dpgline[0];
         for (i = 1; i <= end; i++) {
            strncpy( &pageptr[(hpgline[i])], textptr( pageaddr, dpgline[i] ),
                  61 );
            if (i <= (dpgattr[0] >> 1)) {
               val = strprolen( &pageptr[(hpgline[i])],
                     (pageptr[PGTLRG+i-1])? MYLFONT: MYSFONT );
               if (val > rm - lm) {
                  itoa( i, buf, 1 );
                  if (!big_alert( 1, TOO_LONG1, buf, TOO_LONG2, 0L, 0L ))
                     badstat |= 0x100;
               }
            }
         }
         str = textptr( pageaddr, MNOFFSET );
         val = get_measoff( str );
         if (val >= (-1))
            ((int*)pageptr)[HMNOFF] = val;
         else
            badstat |= 0x01;
         str = textptr( pageaddr, PNOFFSET );
         val = atoi( str );
         if (val >= 0)
            ((int*)pageptr)[HPNOFF] = val;
         else
            badstat |= 0x02;
         str = textptr( pageaddr, DSYSPG );
         val = atoi( str );
         if (val > 0 && val <= sysmax)
            pageptr[PSYSUSR] = (char)val;
         else
            badstat |= 0x04;
         if (badstat && badstat < 0x100)
            form_alert( 1, palerts[badstat & 0xFF] );
      }
   } while (badstat);
   gr_device = 0;
}


get_measoff( str )
register char *str;
{
   register int   sflag, val;
   register char  ch;

   sflag = FALSE;
   val = 0;
   do                                        /* skip whitespace */
      ch = *str++;
   while (ch == ' ' || ch == '_');
   if (ch == '-') {                          /* sign? */
      sflag = TRUE;
      ch = *str++;
   } else if (ch == '+')                     /* skip over */
      ch = *str++;
   do {                                      /* make number */
      if (ch >= '0' && ch <= '9')
         val = val * 10 + (ch - 48);
      else                                   /* return error on non-digit */
         return (-32000);
      ch = *str++;
   } while (ch != '\0');
   return (sflag? -val: val);
}


ex_prtopt()
{
   register int   end, i;

   setup_page();
   if (!is_magic())
      pinfo_init();
   end = doptradio[0];
   for (i = 1; i <= end; i++)
      poptaddr[(doptradio[i])].ob_state = pageptr[(hoptradio[i])];
   if (do_dial( poptaddr, 0 ) == OKAY) {
      for (i = 1; i <= end; i++)
         pageptr[(hoptradio[i])] = (char)(poptaddr[(doptradio[i])].ob_state);
   }
}

/* EOF */
