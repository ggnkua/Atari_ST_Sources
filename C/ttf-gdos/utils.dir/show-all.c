/***************************************
*
* show-all.c
* show every char of every font at all point sizes
*
* usage:
*        show-all <dev>
* where <dev> is device number, assumed 3 if not entered
*
***************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vdibind.h>
#include <osbind.h>

#define DEBUG 0
#define DEF_WKSTN 3
#define ADE_MAX 255

#if !DEBUG
#define dprintf
#else
#define dprintf printf
#endif

#define YMARGIN   (10000/dot_height)	/* 10 mm */
#define XMARGIN   (10000/dot_width)

char out_str[256];
int y;	/* page position, in dots */
int page_width, page_height;    /* in dots */
int dot_width, dot_height;      /* in micrometers */
int w, h;                       /* cell height */
int handle;
int inc_flag;
int wkstn;

/****************************
* output a new line of text
* start new page if at end of current one
*/
void pr_line( int justify )
{
   y += h;  /* advance text alignment point for bottom of text */
   if( y > page_height-YMARGIN ) {
      /** reached end of page **/
      v_updwk( handle );
      if( wkstn<10 ) {
         Cconout( '\a' );  /* beep */
         while( Cconis() == 0 );  /* wait for keypress before proceeding **/
         Cconin();
      } /* if */
      v_clrwk( handle );
      y = YMARGIN+h;
   } /* if */

   /* now print the line */
   if( justify ) {
      v_justified( handle, XMARGIN, y, out_str, page_width-2*XMARGIN, 0, 1 );
   }
   else {
      v_gtext( handle, XMARGIN, y, out_str );
   } /* if */
} /* pr_line() */


void print_font( int psize )
{
int ADE_first, ADE_last, maxwidth;
int c;
register char *s;
int extent[8];
int distances[5];
int effects[3];
   if( psize == vst_point( handle, psize, &w, &w, &w, &h ) ) {
      if( wkstn >= 10 ) printf( "size %d\n", psize );
      vqt_font_info( handle, &ADE_first, &ADE_last, distances, &maxwidth, effects );

      /******************
      *  loop to construct a string to display
      *  check string width as it grows,
      *  display when as large as possible
      ******************/
      for( c=ADE_last, s=out_str; c>=ADE_first; c--, s++ ) {
         *s = c; s[1] = '\0';
         dprintf( "string is now\"%s\", len is %d\n", out_str, strlen( out_str ) );
         vqt_extent( handle, out_str, extent );
         dprintf( "extent is (%d,%d), (%d,%d), (%d,%d), (%d,%d)\n", extent[0], extent[1], extent[2], extent[3], extent[4], extent[5], extent[6], extent[7] );
         dprintf( "x extent is %d, %d\n", extent[2], extent[4] );
         if( extent[2] >= page_width-2*XMARGIN ) {
            dprintf( "string reaches screen limit, extent < %d\n", extent[2] );
            *s = '\0';
            pr_line( 1 );  /* print line justified */
            s = out_str; *s = c; s[1] = '\0';
         } /* if */
      } /* for all chars */
      pr_line( 0 ); /* print last line unjustified */
      
   } /* if */

} /* print_font() */



void print_sizes( int font_index )
{
int id;
char name[33];
int psize;
   id = vqt_name( handle, font_index, name );
   if( wkstn >= 10 ) printf( "font[%d]: name is %s, id is %d\n", font_index, name, id );
   else dprintf( "font[%d]: name is %s, id is %d\n", font_index, name, id );
   if( id > 1 ) {
      vst_font( handle, id );
      dprintf( "selecting font %s\n", name );
      if( inc_flag ) {
         for( psize=8; psize<=100; psize++ ) {
            print_font( psize );
         } /* for point sizes */
      }
      else {
         for( psize=100; psize>=8; psize-- ) {
            print_font( psize );
         } /* for point sizes */
      } /* if */
      inc_flag = !inc_flag;

   } /* if not system font */
      
} /* print_sizes() */



int main( int argc, char *argv[] )
{
int work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
int work_out[57];
int nr_fonts;
register int i;
int hor_out, vert_out;
int clip_array[4];
long mem0 = Malloc(-1);

   if( !vq_gdos() ) {
      fprintf( stderr, "gdos must be resident\n" );
      exit( -1 );
   } /* if */

   wkstn = argc < 2? DEF_WKSTN: atoi( argv[1]);

   work_in[0] = wkstn;
   handle = 0;
   if( wkstn < 10 ) {
      v_opnvwk( work_in, &handle, work_out );
   }
   else {
      v_opnwk( work_in, &handle, work_out );
   } /* if */
   if( handle == 0 ) {
      fprintf( stderr, "wkstn %d could not be opened\n", wkstn );
      exit( -1 );
   }
   else {
      dprintf( "work station %d opened sucessfully, handle is %d\n", wkstn, handle );
   } /* if */

   clip_array[0] = 0;
   clip_array[1] = 0;
   clip_array[2] = work_out[0];
   clip_array[3] = work_out[1];
   vs_clip( handle, 1, clip_array );

   page_width = work_out[0]+1;
   page_height = work_out[1]+1;
   dot_width = work_out[3];
   dot_height = work_out[4];

   fprintf( stdout, "page width is %d, margin is %d dots\n", page_width, XMARGIN );
   fprintf( stdout, "page height is %d, margin is %d dots\n", page_height, YMARGIN );

   nr_fonts = vst_load_fonts( handle, 0 );
   dprintf( "there are %d new fonts loaded\n", nr_fonts );

   vst_alignment( handle, 0, 3 /* bottom */, &hor_out, &vert_out );
   y = YMARGIN;

   v_clrwk( handle );
   for( i=1; i<=nr_fonts+1; i++ ) {
      print_sizes( i );
   } /* for each font */

   v_updwk( handle );

   if( wkstn<10 ) {
      Cconout( '\a' );  /* beep */
      while( Cconis() == 0 );  /* wait for keypress before proceeding **/
      Cconin();
   } /* if */
   /** test that font data is accessed after it has been moved in the cache
   **  assume font cache is slightly larger than 36 point font ~ 32k Bytes
   **  (for screen) **/
   vst_font( handle, 2 );  /* set standard font */
   vst_point( handle, 24, &w, &w, &w, &h );
   v_gtext( handle, XMARGIN, 50, "text at 24 points" );	/* data at start of cache */
   vst_point( handle, 18, &w, &w, &w, &h );
   v_gtext( handle, XMARGIN, 100, "text at 18 points" );
   vst_point( handle, 12, &w, &w, &w, &h );
   v_gtext( handle, XMARGIN, 150, "text at 12 points" );	/* data in middle of cache */

   /* 18 & 24 point data released, 12 point data moved for 36 point font */
   vst_point( handle, 36, &w, &w, &w, &h );
   v_gtext( handle, XMARGIN, 200, "text at 36 points" );
   vst_point( handle, 12, &w, &w, &w, &h );
   v_gtext( handle, XMARGIN, 250, "text at 12 points" ); /* print relocated font data */

   vst_unload_fonts( handle, 0 );
   
   if( wkstn < 10 ) {
      v_clsvwk( handle );
   }
   else {
      v_clswk( handle );
   } /* if */

   if( mem0 != Malloc(-1) ) {
      fprintf( stderr,
            "show-all: memory error, initial free %ld bytes, final %ld\n",
            mem0, Malloc(-1) );
      getchar();
   } /* if */

   Cconws( "finished, press a key" );
   (void)Cnecin();
   Cconout( '\n' );
   exit( 0 );

} /* main */

/**************** end of show-all.c ********************/
