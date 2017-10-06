/***************************************************************

        bwb_par.c       Parallel Action (Multitasking) Routines
                        for Bywater BASIC Interpreter

			Currently UNDER CONSTRUCTION

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#include <stdio.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#if PARACT			/* this whole file ignored if FALSE */

/***************************************************************

        FUNCTION:       bwb_newtask()

        DESCRIPTION:    This C function allocates and initializes
        		memory for a new task.

***************************************************************/

#if ANSI_C
int
bwb_newtask( int task_requested )
#else
int
bwb_newtask( task_requested )
   int task_requested;
#endif
   {
   static char start_buf[] = "\0";
   static char end_buf[] = "\0";
   register int c;

   /* find if requested task slot is available */ 

   if ( bwb_tasks[ task_requested ] != NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_newtask(): Slot requested is already in use" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
      return -1;
#endif
      }

   /* get memory for task structure */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( bwb_tasks[ task_requested ] = CALLOC( 1, sizeof( struct bwb_task ), "bwb_newtask" ) )
      == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_newtask(): failed to find memory for task structure" );
#else
      bwb_error( err_getmem );
#endif
      }

   /* set some initial variables */

   bwb_tasks[ task_requested ]->bwb_start.number = 0;
   bwb_tasks[ task_requested ]->bwb_start.next = &bwb_tasks[ task_requested ]->bwb_end;
   bwb_tasks[ task_requested ]->bwb_end.number = MAXLINENO + 1;
   bwb_tasks[ task_requested ]->bwb_end.next = &bwb_tasks[ task_requested ]->bwb_end;
   bwb_tasks[ task_requested ]->bwb_start.buffer = start_buf;
   bwb_tasks[ task_requested ]->bwb_end.buffer = end_buf;
   bwb_tasks[ task_requested ]->data_line = &bwb_tasks[ task_requested ]->bwb_start;
   bwb_tasks[ task_requested ]->data_pos = 0;
   bwb_tasks[ task_requested ]->rescan = TRUE;
   bwb_tasks[ task_requested ]->exsc = -1;
   bwb_tasks[ task_requested ]->expsc = 0;
   bwb_tasks[ task_requested ]->xtxtsc = 0;

   /* Variable and function table initializations */

   var_init( task_requested );             /* initialize variable chain */
   fnc_init( task_requested );             /* initialize function chain */
   fslt_init( task_requested );		/* initialize funtion-sub  chain */

   return task_requested;

   }

#endif


