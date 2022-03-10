/*--------------------------------------------------------------------------*/
/* 																								 */
/* 																								 */
/* 	  ------------ 		  Bit-Bucket Software, Co. 							 */
/* 	  \ 10001101 / 		  Writers and Distributors of 						 */
/* 		\ 011110 /			  Freely Available<tm> Software. 					 */
/* 		 \ 1011 /																			 */
/* 		  ------ 																			 */
/* 																								 */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/* 																								 */
/* 																								 */
/* 					 This module was written by Bob Hartman						 */
/* 																								 */
/* 																								 */
/* 						  BinkleyTerm Scheduler Routines 							 */
/* 																								 */
/* 																								 */
/* 	For complete  details  of the licensing restrictions, please refer	 */
/* 	to the License  agreement,  which  is published in its entirety in	 */
/* 	the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	 */
/* 																								 */
/* 	USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	 */
/* 	BINKLEYTERM  LICENSING	AGREEMENT.	IF YOU DO NOT FIND THE TEXT OF	 */
/* 	THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	 */
/* 	NOT HAVE THESE FILES,  YOU  SHOULD	IMMEDIATELY CONTACT BIT BUCKET	 */
/* 	SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	 */
/* 	SHOULD YOU	PROCEED TO USE THIS FILE  WITHOUT HAVING	ACCEPTED THE	 */
/* 	TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	 */
/* 	AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		 */
/* 																								 */
/* 																								 */
/* You can contact Bit Bucket Software Co. at any one of the following		 */
/* addresses:																					 */
/* 																								 */
/* Bit Bucket Software Co. 		 FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398					 AlterNet 7:491/0 								 */
/* Aurora, CO 80046					 BBS-Net  86:2030/1								 */
/* 										 Internet f491.n132.z1.fidonet.org			 */
/* 																								 */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.											 */
/* 																								 */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#ifndef LATTICE
#include <process.h>
#endif
#include <time.h>

#ifdef __TURBOC__
 #include "tc_utime.h"
 #ifndef __TOS__
  #include <alloc.h>
  #include <mem.h>
 #endif
#else
 #ifdef LATTICE
  #include <utime.h>
 #else
  #include <sys/utime.h>
  #include <malloc.h>
  #include <memory.h>
 #endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "sched.h"
#include "com.h"
#include "vfossil.h"

/**************************************************************************/
/*** This MUST be exactly 16 total bytes including the terminating null ***/
/*** or the routines read_sched() and write_sched() must be changed!!!! ***/
/**************************************************************************/

static char *BinkSched = "BinkSched 3.11d";		 /* Version of scheduler	*/


void find_event( void )
{
	int cur_day;
	int cur_hour;
	int cur_minute;
	int cur_mday;
	int cur_mon;
	int cur_year;
	int junk;
	int our_time;
	int i;
	char cmds[150];

	/* Get the current day of the week */
	dosdate (&cur_mon, &cur_mday, &cur_year, &cur_day);

	cur_day = 1 << cur_day;

	/* Get the current time in minutes */
	dostime (&cur_hour, &cur_minute, &junk, &junk);
	our_time = (cur_hour % 24) * 60 + (cur_minute % 60);

	cur_event = -1;

	if (cur_mday != hist.which_day)
	{
		write_stats ();
		(void) memset (&hist, 0, sizeof (HISTORY));
		hist.which_day = cur_mday;
		if (un_attended && fullscreen)
		{
			do_today ();
			sb_show ();
		}
	}

	/* Go through the events from top to bottom */
	for (i = 0; i < num_events; i++)
	{
		if (our_time >= e_ptrs[i]->minute)
		{
			if ((cur_day & e_ptrs[i]->days) &&
			  ((!e_ptrs[i]->day) || (e_ptrs[i]->day == (char)cur_mday)) &&
	  		  ((!e_ptrs[i]->month) || (e_ptrs[i]->month == (char)cur_mon)))
			{
				if (((our_time - e_ptrs[i]->minute) < e_ptrs[i]->length) ||
					((our_time == e_ptrs[i]->minute) && (e_ptrs[i]->length == 0)) ||
					 ((e_ptrs[i]->behavior & MAT_FORCED) && (e_ptrs[i]->last_ran != cur_mday)))
				{
					/* Are we not supposed to force old events */
					if (((our_time - e_ptrs[i]->minute) > e_ptrs[i]->length) && (noforce))
					{
						e_ptrs[i]->last_ran = cur_mday;
						continue;
					}

					if (e_ptrs[i]->last_ran != cur_mday)
					{
						cur_event = i;
						do_ready (msgtxt[M_READY_WAITING]);
						status_line (msgtxt[M_STARTING_EVENT], i + 1);

						if (!blank_on_key)
							screen_blank = 0;

						more_mail = 1;

						/* Mark that this one is running */
						e_ptrs[i]->last_ran = cur_mday;

						/*
						 * Mark that we have not yet skipped it. After all, it just
						 * started! 
						 */
						e_ptrs[i]->behavior &= ~MAT_SKIP;

						/* Write out the schedule */
						write_sched ();

#ifdef NEW
						if(e_ptrs[i]->behavior & MAT_KILLBAD)
							kill_bad();
#endif

						/* If we are supposed to exit, then do it */
						if (e_ptrs[i]->errlevel[0])
						{
							status_line (msgtxt[M_EVENT_EXIT], e_ptrs[i]->errlevel[0]);

							screen_blank = 0;
							errl_exit (e_ptrs[i]->errlevel[0]);
						}
#ifdef NEW	/* cleanup doesn't need packer */
						else if(packer || cleanup)
#else
						else if (packer != NULL)
#endif
						{
							if (!blank_on_key)
								 screen_blank = 0;
							status_line (msgtxt[M_CLEAN_PACK]);
							mdm_init (modem_busy);
							exit_DTR ();
							screen_clear ();
							vfossil_cursor (1);
							if (cleanup != NULL)
							{
								 (void) strcpy (cmds, cleanup);
								 if (i >= 0)
									  (void) strcat (cmds, e_ptrs[i]->cmd);
								 b_spawn (cmds);
							}
#ifdef NEW
							if(packer != NULL)
							{
#endif								
								 strcpy (cmds, packer);
								 if (i >= 0)
									  strcat (cmds, e_ptrs[i]->cmd);
								 b_spawn (cmds);
#ifdef NEW                  
							}
#endif
							if (fullscreen)
							{
								 screen_clear ();
								 sb_dirty ();
								 opening_banner ();
								 mailer_banner ();
							}
							DTR_ON ();
							mdm_init (modem_init);
							status_line (msgtxt[M_AFTER_CLEAN_PACK]);
					  	}

						cur_event = i;
						max_connects = e_ptrs[i]->with_connect;
						max_noconnects = e_ptrs[i]->no_connect;
						set_up_outbound ();
					}
					else
					{
						/* Don't do events that have been exited already */
						if (e_ptrs[i]->behavior & MAT_SKIP)
							continue;
					}

					cur_event = i;

					if (e_ptrs[i]->behavior & MAT_NOREQ)
					{
						matrix_mask &= ~TAKE_REQ;
						no_requests = 1;
					}
					else
					{
						matrix_mask |= TAKE_REQ;
						no_requests = 0;
					}

					if (e_ptrs[i]->behavior & MAT_NOOUTREQ)
					{
						requests_ok = 0;
					}
					else
					{
						requests_ok = 1;
					}

					max_connects = e_ptrs[i]->with_connect;
					max_noconnects = e_ptrs[i]->no_connect;

					break;
				}
			}
		}
	}
}

void read_sched( void )
{
	char temp1[80], temp2[80];
	BTEVENT *sptr;
	struct stat buffer1, buffer2;
	FILE *f;
	int i;

	(void) strcpy (temp1, BINKpath);
	(void) strcpy (temp2, BINKpath);
	(void) strcat (temp1, "Binkley.Scd");
	(void) strcat (temp2, "Binkley.Evt");

	if (stat (temp1, &buffer1))
		{
		return;
		}

	if (stat (temp2, &buffer2))
		{
		(void) strcpy (temp2, BINKpath);
		(void) strcat (temp2, config_name);
		if (stat (temp2, &buffer2))
			{
			return;
			}
		}

	if ((buffer1.st_atime < buffer2.st_atime) ||
		 (buffer1.st_size < sizeof (BTEVENT)))
		{
		return;
		}

	if ((sptr = (BTEVENT *) malloc (buffer1.st_size - 16 - sizeof (HISTORY))) == NULL)
		{
		return;
		}
	if ((f = fopen (temp1, read_binary)) == NULL)
		{
		return;
		}

	temp1[0] = '\0';
	(void) fread (temp1, 16, 1, f);
	if (strcmp (temp1, BinkSched) != 0)
		{
		(void) fclose (f);
		return;
		}

	(void) fread (&hist, (int) sizeof (HISTORY), 1, f);
	(void) fread (sptr, buffer1.st_size - 16 - sizeof (HISTORY), 1, f);
	got_sched = 1;

	num_events = (int) ((buffer1.st_size - 16 - sizeof (HISTORY)) / sizeof (BTEVENT));
	for (i = 0; i < num_events; i++)
		{
		e_ptrs[i] = sptr++;
		}

	(void) fclose (f);
	return;
}

void write_sched( void )
{
	char temp1[80], temp2[80];
	FILE *f;
	int i;
	struct stat buffer1;
	struct utimbuf times;
	long t;

	/* Get the current time */
	t = time (NULL);

	(void) strcpy (temp1, BINKpath);
	(void) strcpy (temp2, BINKpath);
	(void) strcat (temp1, "Binkley.Scd");
	(void) strcat (temp2, "Binkley.Evt");

	/* Get the current stat for .Evt file */
	if (!stat (temp2, &buffer1))
		{

		/*
		 * If it is newer than current time, we have a problem and we must
		 * reset the file date - yucky, but it will probably work 
		 */
		if (t < buffer1.st_atime)
			{
			times.actime = buffer1.st_atime;
			times.modtime = buffer1.st_atime;
			status_line (msgtxt[M_DATE_PROBLEM]);
			}
		else
			{
			times.actime = t;
			times.modtime = t;
			}
		}

	if ((f = fopen (temp1, write_binary)) == NULL)
		{
		return;
		}

	(void) fwrite (BinkSched, 16, 1, f);
	(void) fwrite (&hist, (int) sizeof (HISTORY), 1, f);

	for (i = 0; i < num_events; i++)
		{
		/* If it is skipped, but not dynamic, reset it */
		if ((e_ptrs[i]->behavior & MAT_SKIP) &&
			 (!(e_ptrs[i]->behavior & MAT_DYNAM)))
			{
			e_ptrs[i]->behavior &= ~MAT_SKIP;
			}

		/* Write this one out */
		(void) fwrite (e_ptrs[i], sizeof (BTEVENT), 1, f);
		}

	(void) fclose (f);

	(void) utime (temp1, &times);

	return;
}

void write_stats( void )
{
	char temp1[80];
	FILE *f;

	(void) strcpy (temp1, BINKpath);
	(void) strcat (temp1, "Binkley.Day");

	if ((f = fopen (temp1, write_binary)) == NULL)
		{
		return;
		}

	(void) fwrite (&hist, (int) sizeof (HISTORY), 1, f);

	(void) fclose (f);

	return;
}

int time_to_next ( int skip_bbs)
{
	int cur_day;
	int cur_hour;
	int cur_minute;
	int cur_mday;
	int cur_mon;
	int cur_year;
	int junk;
	int our_time;
	int i;
	int time_to;
	int guess;
	int nmin;

	/* Get the current time in minutes */
	dostime (&cur_hour, &cur_minute, &junk, &junk);
	our_time = cur_hour * 60 + cur_minute;

	/* Get the current day of the week */
	dosdate (&cur_mon, &cur_mday, &cur_year, &cur_day);

	next_event = -1;
	cur_day = 1 << cur_day;

	/* A ridiculous number */
	time_to = 3000;

	/* Go through the events from top to bottom */
	for (i = 0; i < num_events; i++)
		{
		/* If it is the current event, skip it */
		if (cur_event == i)
			continue;

		/* If it is a BBS event, skip it */
		if (skip_bbs && e_ptrs[i]->behavior & MAT_BBS)
			continue;

		/* If it was already run today, skip it */
		if (e_ptrs[i]->last_ran == cur_mday)
			continue;

		/* If it doesn't happen today, skip it */
		if (!(e_ptrs[i]->days & cur_day))
			continue;

		/* If not this day of the month, skip it */
		if ((e_ptrs[i]->day) && (e_ptrs[i]->day != (char)cur_mday))
			continue;
		
		/* If not this month of the year, skip it */
		if ((e_ptrs[i]->month) && (e_ptrs[i]->month != (char)cur_mon))
			continue;

		/* If it is earlier than now, skip it unless it is forced */
		if (e_ptrs[i]->minute <= our_time)
			{
			if (!(e_ptrs[i]->behavior & MAT_FORCED))
				{
				continue;
				}

			/* Hmm, found a forced event that has not executed yet */
			/* Give the guy 2 minutes and call it quits */
			guess = 2;
			}
		else
			{
			/* Calculate how far it is from now */
			guess = e_ptrs[i]->minute - our_time;
			}

		/* If less than closest so far, keep it */
		if (time_to > guess)
			{
			time_to = guess;
			next_event = i;
			}
		}

	/* If we still have nothing, then do it again, starting at midnight */
	if (time_to >= 1441)
		{
		/* Calculate here to midnight */
		nmin = 1440 - our_time;

		/* Go to midnight */
		our_time = 0;

		/* Go to the next possible day */
		cur_day = (int) (((unsigned) cur_day) << 1);
		if (cur_day > DAY_SATURDAY)
			cur_day = DAY_SUNDAY;

		/* Go through the events from top to bottom */
		for (i = 0; i < num_events; i++)
			{
			/* If it is a BBS event, skip it */
			if (skip_bbs && e_ptrs[i]->behavior & MAT_BBS)
				continue;

			/* If it doesn't happen today, skip it */
			if (!(e_ptrs[i]->days & cur_day))
				continue;

			/* If not this day of the month, skip it */
			if ((e_ptrs[i]->day) && (e_ptrs[i]->day != (char)cur_mday))
				continue;
		
			/* If not this month of the year, skip it */
			if ((e_ptrs[i]->month) && (e_ptrs[i]->month != (char)cur_mon))
				continue;

			/* Calculate how far it is from now */
			guess = e_ptrs[i]->minute + nmin;

			/* If less than closest so far, keep it */
			if (time_to > guess)
				{
				time_to = guess;
				next_event = i;
				}
			}
		}

	if (time_to > 1440)
		time_to = 1440;

	if (skip_bbs && (time_to < 1))
		time_to = 1;

	return (time_to);
}
