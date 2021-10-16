/************ (c) 1995-2021, Trevor Blight *********
*
*  $Id: tv4.c 3331 2021-10-13 10:39:45Z trevor $
*  
*  ttf-gdos test -  show page area of printer
*
****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <vdibind.h>
#include <aesbind.h>
#include <osbind.h>

#define PRINTER 21

/*
 DEBUG: 0 => no debug
        1 => status messages
        2 => trace vdi calls
*/

#if !defined DEBUG
#define DEBUG 1
#endif
#define dprintf (!DEBUG)? (void)0: printf

#define STEP  if(DEBUG>=2)step(__LINE__)

void step(int line)
{
    printf("at line %d\n", line);
    (void)Cnecin();
} /* step */


void main( void ) {
int handle, h, w, cell_height, n;
int hav_rot;
int work_in[] = { PRINTER,
                  5,   /* dashed lines */
                  1, 1, 1,
                  2, /* font index */
                  1,
                  0, /* hollow fill */
                  1, 1, 2     /* raster */};
int work_out[57];
int psiz, dummy;
char s[100];
int pxyarray[4];  /* 2 coordinate pairs */


   if( !vq_gdos() ) {
      fprintf( stderr, "gdos not present\n" );
      exit(1);
   } /* if */

   v_opnwk( work_in, &handle, work_out );
   if( handle == 0 ) {
       fprintf( stderr, "printer workstation could not be opened\n" );
      exit(1);
   } /* if */

   dprintf( "opened printer wkstn, handle is %d\n", handle );
   w = work_out[0]+1;
   h = work_out[1]+1;
   hav_rot = work_out[36];
   STEP;
   v_ellipse( handle, w/2, h/2, w/2, h/2 );

   STEP;
   n = vst_load_fonts( handle, 0 );
   dprintf( "there are %d new fonts for this workstation\n", n );
   STEP;
   vst_font( handle, 2 ); /* select swiss font */
   STEP;
   psiz = vst_point(handle, 10, &dummy, &dummy, &dummy, &cell_height);

   {
       char driver_name[20];
       char device_name[30];
       STEP;
       vq_devinfo( handle, PRINTER, &dummy, driver_name, device_name );
       sprintf( s, "driver %s, %s\n", driver_name, device_name );
   }
   dprintf(s);
   STEP;
   v_gtext( handle, w/10, h/10, s);

   sprintf( s, "width is %d, height is %d dots\n", w, h );
   dprintf(s);
   STEP;
   v_gtext( handle, w/10, h/10+cell_height, s);

   sprintf( s, "rez is (%d, %d) dpi\n", (25400+work_out[3]/2)/work_out[3],
                                        (25400+work_out[4]/2)/work_out[4] );
   dprintf(s);
   STEP;
   v_gtext( handle, w/10, h/10+2*cell_height, s);

   STEP;
   vsl_ends( handle, 1, 1 ); /* ARROW */
   pxyarray[0] = 0;
   pxyarray[1] = h/2;
   pxyarray[2] = w-1;
   pxyarray[3] = h/2;
   STEP;
   v_pline( handle, 2, pxyarray );

   pxyarray[0] = w/2;
   pxyarray[1] = 0;
   pxyarray[2] = w/2;
   pxyarray[3] = h-1;
   STEP;
   v_pline( handle, 2, pxyarray );

   {
       int wmm = ((long)w*work_out[3]+500)/1000L; /* width in mm */
       int hmm = ((long)h*work_out[4]+500)/1000L;
       sprintf( s, "%d mm\n", wmm );
       STEP;
       v_gtext( handle, 3*w/10, h/2+cell_height/3, s);
       sprintf( s, "%d mm\n", hmm );
       if( hav_rot ) { /* is rotation available? */
           STEP;
           vst_rotation( handle, 900 ); /* vertical text */
       } /* if */
       STEP;
       v_gtext( handle, w/2+cell_height/3, 4*h/10, s);
   }

   STEP;
   v_clswk( handle );  /* should free fonts as well */
   dprintf( "closed printer wkstn\n" );

   printf("press a key to exit \n");
   getchar();
   exit(0);

} /* main */

/*************** end of tv4.c ***************/
