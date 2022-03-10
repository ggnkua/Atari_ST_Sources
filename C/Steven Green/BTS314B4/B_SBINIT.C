/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*			  This module was originally written by Bob Hartman 			*/
/*																			*/
/*																			*/
/*					BinkleyTerm Initial Fullscreen Setup					*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <time.h>
#include <string.h>

#ifdef __TURBOC__
#ifdef __TOS__
#include <stdlib.h>
#else
#include <alloc.h>
#endif
#else
#ifdef LATTICE
#include <stdlib.h>
#else
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "vfossil.h"
#include "sched.h"

/*
 * Data
 */

REGIONP wholewin;
REGIONP settingswin;
REGIONP historywin;
REGIONP holdwin;
REGIONP callwin;
REGIONP filewin;

#ifndef NEW
extern VIOMODEINFO vfos_mode;
#endif

BOOLEAN sb_inited = FALSE;

void b_sbinit( void )
{
   register int r;
#if 0
   char *savep;

   savep = malloc (4096);
#endif
   for (r = 0; r < 132; r++)
	  {
	  blanks[r * 2] = ' ';
	  blanks[r * 2 + 1] = 7;
	  }

#ifdef SWGNEVER
	/* This is done in bt.c */
   vfossil_init ();
#endif   
#ifdef SWGNEVER   
   /*if (vfos_mode.col < 80)
	  vfos_mode.col = 80;
   if (vfos_mode.row < 23)
	  vfos_mode.row = 23;
	*/

   SB_ROWS = (int) vfos_mode.row /* - 1 */ ;
   SB_COLS = (int) vfos_mode.col;
#endif

   screen_clear ();
   sb_init ();
#if 0
   free (savep);
#endif
   wholewin = (REGIONP) sb_new (0, 0, SB_ROWS, SB_COLS);
   settingswin = (REGIONP) sb_new (1, 1, 7, 22);
   historywin = (REGIONP) sb_new (1, 23, 7, 23);
   holdwin = (REGIONP) sb_new (1, 46, 7, SB_COLS - 47);
   callwin = (REGIONP) sb_new (8, 1, SB_ROWS - 13, SB_COLS - 2);
   filewin = (REGIONP) sb_new (SB_ROWS - 5, 1, 4, SB_COLS - 2);

   sb_fill (wholewin, ' ', colors.background);
   sb_fill (settingswin, ' ', colors.settings);
   sb_fill (historywin, ' ', colors.history);
   sb_fill (holdwin, ' ', colors.hold);
   sb_fill (callwin, ' ', colors.call);
   sb_fill (filewin, ' ', colors.file);

#ifdef NEW /* COLORS  22.09.1989 */
   sb_box (settingswin, boxtype, (colors.borders ? colors.borders : colors.settings));
   sb_box (historywin, boxtype, (colors.borders ? colors.borders : colors.history));
   sb_box (holdwin, boxtype, (colors.borders ? colors.borders : colors.hold));
   sb_box (callwin, boxtype, (colors.borders ? colors.borders : colors.call));
   sb_box (filewin, boxtype, (colors.borders ? colors.borders : colors.file));
#else
   sb_box (settingswin, boxtype, colors.settings);
   sb_box (historywin, boxtype, colors.history);
   sb_box (holdwin, boxtype, colors.hold);
   sb_box (callwin, boxtype, colors.call);
   sb_box (filewin, boxtype, colors.file);
#endif

   sb_move (settingswin, 0, 1);
#ifdef NEW /* COLORS  02.09.1990 */
   if (colors.headers) sb_wa(settingswin, colors.headers, (int)strlen (msgtxt[M_CURRENT_SETTINGS]));
#endif
   sb_puts (settingswin, (unsigned char *) msgtxt[M_CURRENT_SETTINGS]);

   sb_move (historywin, 0, 1);
#ifdef NEW /* COLORS  02.09.1990 */
   if (colors.headers) sb_wa(historywin, colors.headers, (int)strlen (msgtxt[M_TODAY_GLANCE]));
#endif
   sb_puts (historywin, (unsigned char *) msgtxt[M_TODAY_GLANCE]);

   sb_move (holdwin, 0, 1);
#ifdef NEW /* COLORS  02.09.1990 */
   if (colors.headers) sb_wa(holdwin, colors.headers, (int)strlen (msgtxt[M_PENDING_OUTBOUND]));
#endif
   sb_puts (holdwin, (unsigned char *) msgtxt[M_PENDING_OUTBOUND]);

   sb_move (holdwin, 3, 7);
   sb_puts (holdwin, (unsigned char *) msgtxt[M_INITIALIZING_SYSTEM]);

   sb_move (callwin, 0, 1);
#ifdef NEW /* COLORS  02.09.1990 */
   if (colors.headers) sb_wa(callwin, colors.headers, (int)strlen (msgtxt[M_RECENT_ACTIVITY]));
#endif
   sb_puts (callwin, (unsigned char *) msgtxt[M_RECENT_ACTIVITY]);

   sb_move (filewin, 0, 1);
#ifdef NEW /* COLORS  02.09.1990 */
   if (colors.headers) sb_wa(filewin, colors.headers, (int)strlen (msgtxt[M_TRANSFER_STATUS]));
#endif
   sb_puts (filewin, (unsigned char *) msgtxt[M_TRANSFER_STATUS]);

	top_line();
   bottom_line ();

   sb_move (settingswin, SET_EVNT_ROW, 2);
   sb_puts (settingswin, (unsigned char *) msgtxt[M_EVENT_COLON]);
   sb_move (settingswin, SET_PORT_ROW, 2);
   sb_puts (settingswin, (unsigned char *) msgtxt[M_PORT_COLON]);
   sb_move (settingswin, SET_STAT_ROW, 2);
   sb_puts (settingswin, (unsigned char *) msgtxt[M_STATUS_INIT]);

   do_today ();

   settingswin->sr0 = settingswin->r0 + 1;
   settingswin->sr1 = settingswin->r1 - 1;
   settingswin->sc0 = settingswin->c0 + 1;
   settingswin->sc1 = settingswin->c1 - 1;

   historywin->sr0 = historywin->r0 + 1;
   historywin->sr1 = historywin->r1 - 1;
   historywin->sc0 = historywin->c0 + 1;
   historywin->sc1 = historywin->c1 - 1;

   holdwin->sr0 = holdwin->r0 + 1;
   holdwin->sr1 = holdwin->r1 - 1;
   holdwin->sc0 = holdwin->c0 + 1;
   holdwin->sc1 = holdwin->c1 - 1;

   callwin->sr0 = callwin->r0 + 1;
   callwin->sr1 = callwin->r1 - 1;
   callwin->sc0 = callwin->c0 + 1;
   callwin->sc1 = callwin->c1 - 1;

   filewin->sr0 = filewin->r0 + 1;
   filewin->sr1 = filewin->r1 - 1;
   filewin->sc0 = filewin->c0 + 1;
   filewin->sc1 = filewin->c1 - 1;

	sb_inited = TRUE;
}

void do_today( void )
{
   char j[30];
   ADDR tmp;

   if (fullscreen)
	  {
	  sb_move (historywin, HIST_BBS_ROW, 2);
	  sb_puts (historywin, (unsigned char *) msgtxt[M_BBS_MAIL]);
	  (void) sprintf (j, "%d/%d/%d",
	  	hist.bbs_calls, hist.mail_calls, hist.extmails);
	  (void) sprintf (junk, "%-8.8s", j);
	  sb_puts (historywin, (unsigned char *) junk);

	  sb_move (historywin, HIST_ATT_ROW, 2);
	  sb_puts (historywin, (unsigned char *) msgtxt[M_CALLS_OUT]);
	  (void) sprintf (junk, "%-6d", hist.calls_made);
	  sb_puts (historywin, (unsigned char *) junk);

	  sb_move (historywin, HIST_CONN_ROW, 2);
	  sb_puts (historywin, (unsigned char *) msgtxt[M_GOOD_COST]);
	  (void) sprintf (j, "%d/%ld", hist.connects, hist.callcost);
	  (void) sprintf (junk, "%-8.8s", j);
	  sb_puts (historywin, (unsigned char *) junk);

	  sb_move (historywin, HIST_FILE_ROW, 2);
	  sb_puts (historywin, (unsigned char *) msgtxt[M_FILES_IO]);
	  (void) sprintf (j, "%d/%d", hist.files_in, hist.files_out);
	  (void) sprintf (junk, "%-8.8s", j);
	  sb_puts (historywin, (unsigned char *) junk);

	  sb_move (historywin, HIST_LAST_ROW, 2);
	  sb_puts (historywin, (unsigned char *) msgtxt[M_LAST]);
	  }

   tmp.Zone = hist.last_zone;
   tmp.Net = hist.last_net;
   tmp.Node = hist.last_node;
#ifdef MULTIPOINT
	tmp.Point = hist.last_point;
#else
	tmp.Point = 0;
#endif
	if(hist.last_Domain[0])
		tmp.Domain = find_domain(hist.last_Domain);
	else
		tmp.Domain = NULL;
   last_type (hist.last_caller, &tmp);
}

void bottom_line( void )
{
   if (fullscreen)
	  {
	  sb_move (wholewin, SB_ROWS - 1, 0);
	  (void) sb_putc (wholewin, ' ');
	  sb_puts (wholewin, (unsigned char *) ANNOUNCE);
#ifdef OVERLAYS
	  sb_puts (wholewin, (unsigned char *) "-Overlay");
#endif
	  sb_move (wholewin, SB_ROWS - 1, SB_COLS - 23);
	  sb_puts (wholewin, (unsigned char *) msgtxt[M_ALTF10]);
#ifdef NEW
	  sb_putc (wholewin, ' ');
#endif
	  }
}

void put_up_time( void )
{
   struct tm *tp;
   time_t ltime;

   if (fullscreen && (un_attended || doing_poll))
	  {
	  (void) time (&ltime);
	  tp = localtime (&ltime);
	  sb_move (settingswin, SET_TIME_ROW, SET_TIME_COL);
	  (void) sprintf (junk, "%s %s %02d @ %02d:%02d",
			   wkday[tp->tm_wday], mtext[tp->tm_mon], tp->tm_mday,
			   tp->tm_hour, tp->tm_min);
	  sb_puts (settingswin, (unsigned char *) junk);
	  sb_show ();
	  }
}

void top_line( void )
{
	size_t i;
	char *s;

   sb_move (wholewin, 0, 1);
#ifdef MULTIPOINT
   sprintf (junk,
   		msgtxt[alias[last_assumed].ad.Point ? M_POINT_COLON : M_NODE_COLON],
   		Pretty_Addr_Str (&alias[last_assumed].ad));
	
#else
   (void) sprintf (junk, msgtxt[M_NODE_COLON], Pretty_Addr_Str (&my_addr.ad));
#endif

	i = strlen(junk);				/* Fill the line with spaces */
	s = junk + i;
	while(i++ < (SB_COLS-1))
		*s++ = ' ';
	*s = 0;

   sb_puts (wholewin, (unsigned char *) junk);
   sb_move (wholewin, 0, SB_COLS - 1 - (int) strlen (system_name));
   sb_puts (wholewin, (unsigned char *) system_name);
}
