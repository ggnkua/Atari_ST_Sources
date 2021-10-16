/****************************************************
*
*  $Id: tv5.c 3331 2021-10-13 10:39:45Z trevor $
*  
*  timing test program for gdos
*  open & close a virtual workstation 1000 times
*
*  results are (ticks, TOS 1.62):
*  - no gdos      646
*  - ttf-gdos 1.0 740
*  - ttf-gdos 0.1 758
*  - ttf-gdos 2.3 770  (hatari emulator)
*  - g+plus       844  (???)
*  - tbb-gdos     876
*  - fontgdos    2268
*
***************************************************/

#include <stdio.h>
#include <time.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>

typedef int int16;

int work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
int work_out[57];

int main( void )
{
clock_t t0;
int16 h0, h;
int dummy;
int r;
   register int i = 1000;
   r = appl_init();
   h0 = graf_handle( &dummy, &dummy, &dummy, &dummy );
   r = appl_exit();
   work_in[0] = 2+Getrez();
   printf( "timing test: start time is %ld\n", (long)(t0 = clock()) );
   while( i-- > 0 ) {
       h = h0;
       v_opnvwk( work_in, &h, work_out );
       v_clsvwk( h );
   } /* while */
   printf( "time for 1k ops is %ld\n", (long)(clock() - t0) );

} /* main() */

/************************ end of tv5.c ******************/

