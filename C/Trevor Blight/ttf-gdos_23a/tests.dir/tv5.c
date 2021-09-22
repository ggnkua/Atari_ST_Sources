/****************************************************
*
*  $Id: tv5.c 3274 2021-08-28 13:12:54Z trevor $
*  
*  timing test program for gdos
*
***************************************************/

#include <stdio.h>
#include <time.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>

typedef int int16;

int work_in[] = { 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
int work_out[57];

int main( void )
{
   /**********************
   *  do a timing test 
   *  
   *  results are (ticks):
   *  - no gdos      646
   *  - ttf-gdos 1.0 740
   *  - ttf-gdos 0.1 758
   *  - ttf-gdos 2.3 770  (TOS 1.62, hatari emulator)
   *  - tbb-gdos     876
   *  - g+plus       844 (???)
   *  - fontgdos    2268
   *
   *************************/

clock_t t0;
int16 h0, h;
int dummy;
int r;
   register int i = 1000;
   r = appl_init();
   h0 = graf_handle( &dummy, &dummy, &dummy, &dummy );
   r = appl_exit();
      printf( "timing test: start time is %ld\n", (long)(t0 = clock()) );
      while( i-- > 0 ) {
         h = h0;
         v_opnvwk( work_in, &h, work_out );
	 v_clsvwk( h );
      } /* while */
      printf( "time for 1k ops is %ld\n", (long)(clock() - t0) );

 } /* main() */

/************************ end of tv5.c ******************/

