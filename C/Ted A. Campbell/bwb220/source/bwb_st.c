/***************************************************************

        bwx_st.c       Environment-dependent implementation
                        of Bywater BASIC Interpreter
			for Atari ST using PureC

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
/*                                                               */
/* Those additionally marked with "DD" were at the suggestion of */
/* Dale DePriest (daled@cadence.com).                            */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

#include "bwbasic.h"
#include "bwb_mes.h"

extern int prn_col;
int reset_mode = FALSE;
/*static jmp_buf mark;*/

static int iqc_setpos( void );

/***************************************************************

        FUNCTION:       main()

        DESCRIPTION:    As in any C program, main() is the basic
                        function from which the rest of the
                        program is called. Some environments,
			however, provide their own main() functions
			(Microsoft Windows (tm) is an example).
			In these cases, the following code will
			have to be included in the initialization
			function that is called by the environment.

***************************************************************/

void
main( int argc, char **argv )
   {
   bwb_init( argc, argv );

#if INTERACTIVE
   setjmp( mark );
#endif

   /* now set the number of colors available */


   /* main program loop */

   while( !feof( stdin ) )		/* condition !feof( stdin ) added in v1.11 */
      {
      bwb_mainloop();
      }

   }
  