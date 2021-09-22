/******************************************************
*
* bezier test program
*
******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

#include <aesbind.h>
#include <vdibind.h>


typedef short int16;  /* 16 bits */
typedef long int32;   /* 32 bits */
typedef char int8;    /* 8 bits */
typedef unsigned short uint16;  /* 16 bits */
typedef unsigned long uint32;   /* 32 bits */
typedef unsigned char uint8;    /* 8 bits */

#define HIGH(a) (sizeof(a)/sizeof(a[0]))
#define MAX_COORD 32000
#define MAX_COORDX 32000
#define MAX_COORDY 32000

int aes_handle = 0;
int handle = 0;
int pr_handle;

void exit_fn( void )
{
   v_clsvwk( handle );
}

/* define a bezier curve */
int xyarr[] = {  150,50, 250,100, 50,250, 200,50,
                300,250, 300,300, 350,300, 350,350, 400,350 };
int8 bezarr[] = {1,0,0,0, 0, 2, 2, 0, 0 };	/* 1 = bez, 2 = jump */

int main( void )
{
int work_in[160];
int work_out[160];
int clarr[] = { 0, 0, 639, 399 };
int16 extent[4];
enum{ xmin, ymin, xmax, ymax };
int16 total_points, total_jumps;
int16 r, r1;
time_t tp;

   /* open screen workstation */
   work_in[0] = 3;    /* device id */
   work_in[1] = 1;
   work_in[2] = 1;
   work_in[3] = 1;
   work_in[4] = 1;
   work_in[5] = 1;
   work_in[6] = 1;
   work_in[7] = 2;	/* fill interior style = pattern */
   work_in[8] = 18;	/* fill pattern = ball-bearings */
   work_in[9] = 1;	/* fill index = black */
   work_in[10] = 2;    /* 0 = nd coords; 2 = raster coords */

   if( !vq_gdos() ) {
      printf( "GDOS not installed!!\n" );
      exit( -1 );
   } /* if */

{
int id;
int dummy;
int r;
   id = appl_init();
   aes_handle = graf_handle( &dummy, &dummy, &dummy, &dummy );
   r = appl_exit();
}

   handle = aes_handle;

   v_opnvwk (work_in, &handle, work_out);
   if( handle == 0 ) {
      printf("failed to open workstation, press CR\n");
      exit(-1);
   }
   else {
      printf("opened workstation, press CR\n");
      atexit( exit_fn);
   } /* if */

   clarr[2] = work_out[0];
   clarr[3] = work_out[1];
   printf( "clipping to (%d, %d) .. (%d, %d)\n", clarr[0], clarr[1], clarr[2], clarr[3] );
   vs_clip( handle, 1, clarr );

   /* check if beziers supported ... */
   r = v_bez_qual( handle, 100, &r1 );
   _intout[0] = 0;
   if( v_bez_on( handle ) == 0 )  {
      printf("this GDOS doesn't support bezier curves. press CR\n");
      exit(-1);
   } /* if */

   /* test various bez quality values */
   {
   int pc, depth=-1;
   for(pc=0; pc<=100; pc++ ) {
      r = v_bez_qual( handle, pc, &r1 );
      r = v_bez_con( handle, 1 );
      if(r!=depth) {
         depth=r;
         v_clrwk( handle );
         v_bez( handle, 4, xyarr, bezarr, extent, &total_points, &total_jumps );

         printf( "\033H%d%% --> depth %d\n", pc, depth);
         printf( "bez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
                  extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
                  total_points, total_jumps );
         getchar();
      } /* if */
   } /* for */
   }

   /* draw a curve with a couple of jump points */
   v_clrwk( handle );
   v_bez( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );

   printf( "\033Hbez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
   getchar();

   /* overlay previous curve with identical curve, but filled **/
   {
   clock_t t0 = clock();
      v_bez_fill( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
      t0 = clock() - t0;
      printf( "time for bez fill is %ld\n", (long)t0 );
      printf( "(filled) x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
      getchar();
   }

   if(1) {
   /* try an unusual shaped curve */
   int xyarr0[] = {  0,0, 213,399/27, 426,-798/9, 639,399 };
   int xyarr1[] = {  0,0, 213,1197, 426,-798, 639,399 };
   int xyarr2[] = {  0,0, 3*639,399/27, -2*639,-798/9, 639,399 };
   int8 bezarr[] = {1,0,0,0 };	/* 1 = bez, 2 = jump */
      v_clrwk( handle );
      v_bez( handle, HIGH(bezarr), xyarr0, bezarr, extent, &total_points, &total_jumps );
      getchar();
   
      /* printf( "\033Hbez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
	       extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
	       total_points, total_jumps ); */
      v_bez( handle, HIGH(bezarr), xyarr1, bezarr, extent, &total_points, &total_jumps );
      /* printf( "bez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
	       extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
	       total_points, total_jumps ); */
      getchar();
      v_bez( handle, HIGH(bezarr), xyarr2, bezarr, extent, &total_points, &total_jumps );
      getchar();
   
   }

   /* curve to extend over whole screen ... */
   {
   int xyarr[] = {  0,0, 3*639,399*4/3, -2*639,399*4/3, 639,0 };
   int8 bezarr[] = {1,0,0,0 };	/* 1 = bez, 2 = jump */
      v_clrwk( handle );
      v_bez( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
      printf( "\033Hbez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
	       extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
	       total_points, total_jumps );
      if( getchar() == 'x' ) exit(0);
   }


   /* test negative ndc control coords ..
   ** make curve in rc coords first, then overlay with filled ndc curve */
   {
   int xyarr[] = {  0,0, 639,399*4/3, -639,399*4/3, 639,0 };
   int8 bezarr[] = {1,0,0,0 };	/* 1 = bez, 2 = jump */
      v_clrwk( handle );
      v_bez( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
      printf( "\033Hbez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
	       extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
	       total_points, total_jumps );
      if( getchar() == 'x' ) exit(0); /* fontgdos needs to exit here */
   }

   v_clsvwk( handle );

   /* re open the screen with ndc coords */
   work_in[10] = 0;    /* 0 = nd coords; 2 = raster coords */
   handle = aes_handle;
   v_opnvwk (work_in, &handle, work_out);
   if( handle == 0 ) {
      printf("failed to workstation, press CR\n");
      exit(-1);
   } /* if */

   clarr[2] = 32767;
   clarr[3] = 32767;
   printf( "clipping to (%d, %d) .. (%d, %d)\n", clarr[0], clarr[1], clarr[2], clarr[3] );
   vs_clip( handle, 1, clarr );

   if(1) {
   /* try max range for -ve ndc coords */
   /* this curve should exactly match the existing curve in rc coords */
   int xyarr[] = {  0,32767, 32767,-32767/3, -32767,-32767/3, 32767,32767 };
   int8 bezarr[] = {1,0,0,0 };	/* 1 = bez, 2 = jump */
      v_bez_fill( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
      printf( "bez x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
	       extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
	       total_points, total_jumps );
      if( getchar() == 'x' ) exit(0);
   }

   work_in[0] = 21;    /* printer device */
   v_opnwk (work_in, &pr_handle, work_out);
   if( pr_handle == 0 ) {
      printf("failed to open printer workstation, press CR\n");
      pr_handle = handle; /* exit(-1); */
   } /* if */


   /** 3 bezier curves, max extent & different shape ... **/
   {
   int xyarr[] = {  0,MAX_COORDY, 0,0, MAX_COORDX,0, MAX_COORDX,MAX_COORDY, 
                    0,0, MAX_COORDX,0, 0,MAX_COORDY,
                    0,0, MAX_COORDX,MAX_COORDY, MAX_COORDX,0 };
   int8 bezarr[] = {3, 0, 0, 1, 0, 0, 1, 0, 0, 3 };	/* 1 = bez, 2 = jump */
   assert( HIGH(xyarr)/2 == HIGH(bezarr) );
   v_clrwk( handle );
   v_bez( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );

   printf( "\033Hmax,screen: x range is [%d..%d], y range is [%d..%d], %d points, %d jumps\n",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
   v_bez( pr_handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );

   printf( "max,printer: x range is [%d..%d], y range is [%d..%d], %d points, %d jumps",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
   getchar();
   }

   /** sequence of polylines & bezier curves 
   **  with different combinations of control points ... **/
   {
   int xyarr[] = {  0,0,
                    2000,0000, 2000,2000, 4000,2000, 4000,4000,
                    6000,4000, 6000,6000, 6000,6000, 8000,8000,
                    10000,8000, 10000,10000, 12000,10000, 12000,12000,
                    14000,12000, 14000,14000, 16000,14000, 16000,16000,
                    18000,16000, 18000,18000, 20000,18000, 20000,20000,
                    22000,20000, 22000,22000, 24000,22000, 24000,24000,
                    26000,24000, 26000,26000, 28000,26000, 28000,28000,
                    30000,28000, 30000,30000, 32000,30000, 32000,32000 };

   int8 bezarr[] = {0, 0, 1, 0, 0, 0, 2, 0, 3, 0, 0, 1, 0, 0, 1, 0, 0, 2, 2, 1, 0, 0, 3, 0, 0, 2, 3, 0, 0, 3, 0, 0, 0 };	/* 1 = bez, 2 = jump */
   assert( HIGH(xyarr)/2 == HIGH(bezarr) );
   v_clrwk( handle );
   v_bez( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
   printf( "\033Hmulti: x range is [%d..%d], y range is [%d..%d], %d points, %d jumps\n",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
   v_bez( pr_handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
   printf( "multi,prn: x range is [%d..%d], y range is [%d..%d], %d points, %d jumps\n",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );

   v_bez_fill( handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
   printf( "multi,fill x range is [%d..%d], y range is [%d..%d], %d points, %d jumps\n",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );
   v_bez_fill( pr_handle, HIGH(bezarr), xyarr, bezarr, extent, &total_points, &total_jumps );
   printf( "multi,fill,prn: x range is [%d..%d], y range is [%d..%d], %d points, %d jumps\n",
            extent[xmin], extent[xmax], extent[ymin], extent[ymax], 
            total_points, total_jumps );

   }
   v_clswk( pr_handle );
   
   printf( "end of bezier tests\n" );

} /* main() */


