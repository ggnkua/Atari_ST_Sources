/*
 * jwr_ntc.c
 *
 */

#include "jinclude.h"
#include "j_video.h"
#include "jwr_ntc.h"

static JSAMPARRAY color_map;	/* saves color map passed by quantizer */

WINDOW dntcwind = DEFAULTwindow ;

/*---------------------------------------- set_ntc_decompress_window ---*/
void set_ntc_decompress_window ( unsigned short *start,
							 	 int x, int y, int w, int h, int bpl )
{
	dntcwind.start = start ;
	dntcwind.pos = start + (long)y * (long)bpl + 2 * (long)x  ;
	dntcwind.x = x ;
	dntcwind.y = y ;
	dntcwind.w = w ;
	dntcwind.h = h ;
	dntcwind.bpl = bpl ;
}

METHODDEF void
output_init (decompress_info_ptr cinfo)
{
}


/*
 * Write some pixel data.
 */

METHODDEF void
put_pixel_rows (decompress_info_ptr cinfo, int num_rows,
		JSAMPIMAGE pixel_data)
{
  register JSAMPROW ptr0, ptr1, ptr2;
  register long col;
  register long width = cinfo->image_width;
  register int row;
  unsigned short *vram, r, g, b ;
  long offset ;
  
  offset = dntcwind.bpl - width * 2 ;
  vram = dntcwind.pos ;
    for (row = 0; row < num_rows; row++) {
      ptr0 = pixel_data[0][row];
      ptr1 = pixel_data[1][row];
      ptr2 = pixel_data[2][row];
      for ( col = width; col > 0; col-- )
      {
# if 0
		r = GETJSAMPLE(*ptr0++) ; if ( r > 31 ) r = 31 ;
		g = GETJSAMPLE(*ptr1++) ; if ( g > 31 ) g = 31 ;
		b = GETJSAMPLE(*ptr2++) ; if ( b > 31 ) b = 31 ;
		*vram++ = ( r << 11 ) | ( g <<  6 )	| b ;
# else
		r = GETJSAMPLE(*ptr0++) & 0xf8 ;
		g = GETJSAMPLE(*ptr1++) & 0xf8 ;
		b = GETJSAMPLE(*ptr2++) & 0xf8 ;
		*vram++ = ( r << 8 ) | ( g <<  3 ) | ( b >> 3 ) ;
# endif
	  }
	  vram += offset ;
    }
    dntcwind.pos = vram ;
}


/*
 * Write some pixel data when color quantization is in effect.
 */

METHODDEF void
put_demapped_rows (decompress_info_ptr cinfo, int num_rows,
		   JSAMPIMAGE pixel_data)
{
  register JSAMPROW ptr;
  register long col;
  register long width = cinfo->image_width;
  register int row;
  unsigned short *vram, r, g, b ;
  long offset ;
  
  offset = dntcwind.bpl - width * 2 ;
  vram = dntcwind.pos ;
  
    for (row = 0; row < num_rows; row++) {
      ptr = pixel_data[0][row];
      for (col = width; col > 0; col--) {
	register int pixval = GETJSAMPLE(*ptr);
# if 0
		r = GETJSAMPLE(color_map[0][pixval]) ; if ( r > 31 ) r = 31 ;
		g = GETJSAMPLE(color_map[1][pixval]) ; if ( g > 31 ) g = 31 ;
		b = GETJSAMPLE(color_map[2][pixval]) ; if ( b > 31 ) b = 31 ;
		*vram++ = ( r << 11 ) | ( g <<  6 )	| b ;
# else
		r = GETJSAMPLE(color_map[0][pixval]) & 0xf8 ;
		g = GETJSAMPLE(color_map[1][pixval]) & 0xf8 ;
		b = GETJSAMPLE(color_map[2][pixval]) & 0xf8 ;
		*vram++ = ( r << 8 ) | ( g <<  3 ) | ( b >> 3 ) ;
# endif
		ptr++;
      }
	  vram += offset ;
    }
    dntcwind.pos = vram ;
}


/*
 * Write the color map.
 * For PPM output, we just demap the output data!
 */

METHODDEF void
put_color_map (decompress_info_ptr cinfo, int num_colors, JSAMPARRAY colormap)
{
  color_map = colormap;		/* save for use in output */
  cinfo->methods->put_pixel_rows = put_demapped_rows;
}


/*
 * Finish up at the end of the file.
 */

METHODDEF void
output_term (decompress_info_ptr cinfo)
{
}


/*
 * The method selection routine for PPM format output.
 * This should be called from d_ui_method_selection if PPM output is wanted.
 */

GLOBAL void
jselw_ntc (decompress_info_ptr cinfo)
{
  cinfo->methods->output_init	 = output_init;
  cinfo->methods->put_color_map  = put_color_map;
  cinfo->methods->put_pixel_rows = put_pixel_rows;
  cinfo->methods->output_term	 = output_term;
}
