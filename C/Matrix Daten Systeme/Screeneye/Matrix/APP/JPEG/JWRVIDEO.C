/*
 * jwrvideo.c
 *
 */

#include "jinclude.h"
#include "j_video.h"
#include "jwrvideo.h"

static JSAMPARRAY color_map;	/* saves color map passed by quantizer */

WINDOW dwind = DEFAULTwindow ;

/*---------------------------------------- set_decompress_window ---*/
void set_decompress_window ( char *start,
							 int x, int y, int w, int h, int bpl )
{
	dwind.start = start ;
	dwind.pos = start + (long)y * (long)bpl + 4*(long)x  ;
	dwind.x = x ;
	dwind.y = y ;
	dwind.w = w ;
	dwind.h = h ;
	dwind.bpl = bpl ;
}

METHODDEF void
output_init (decompress_info_ptr cinfo)
{
	UNUSED (cinfo) ;
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
  unsigned char *vram ;
  long offset ;
  
  offset = dwind.bpl - width * 4 ;
  vram = dwind.pos ;
    for (row = 0; row < num_rows; row++) {
      ptr0 = pixel_data[0][row];
      ptr1 = pixel_data[1][row];
      ptr2 = pixel_data[2][row];
      for (col = width; col > 0; col--)
      {
		*vram++ = 0 ;
		*vram++ = GETJSAMPLE(*ptr0++) ;
		*vram++ = GETJSAMPLE(*ptr1++) ;
		*vram++ = GETJSAMPLE(*ptr2++) ;
	  }
	  vram += offset ;
    }
    dwind.pos = vram ;
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
  unsigned char *vram ;
  long offset ;
  
  offset = dwind.bpl - width * 4 ;
  vram = dwind.pos ;
  
    for (row = 0; row < num_rows; row++) {
      ptr = pixel_data[0][row];
      for (col = width; col > 0; col--) {
	register int pixval = GETJSAMPLE(*ptr);

		*vram++ = 0 ;
		*vram++ = GETJSAMPLE(color_map[0][pixval]) ;
		*vram++ = GETJSAMPLE(color_map[1][pixval]) ;
		*vram++ = GETJSAMPLE(color_map[2][pixval]) ;
		ptr++;
      }
	  vram += offset ;
    }
    dwind.pos = vram ;
}


/*
 * Write the color map.
 * For PPM output, we just demap the output data!
 */

METHODDEF void
put_color_map (decompress_info_ptr cinfo, int num_colors, JSAMPARRAY colormap)
{
  UNUSED(num_colors) ;
  color_map = colormap;		/* save for use in output */
  cinfo->methods->put_pixel_rows = put_demapped_rows;
}


/*
 * Finish up at the end of the file.
 */

METHODDEF void
output_term (decompress_info_ptr cinfo)
{
	UNUSED(cinfo);
}


/*
 * The method selection routine for PPM format output.
 * This should be called from d_ui_method_selection if PPM output is wanted.
 */

GLOBAL void
jselwvideo (decompress_info_ptr cinfo)
{
  cinfo->methods->output_init	 = output_init;
  cinfo->methods->put_color_map  = put_color_map;
  cinfo->methods->put_pixel_rows = put_pixel_rows;
  cinfo->methods->output_term	 = output_term;
}
