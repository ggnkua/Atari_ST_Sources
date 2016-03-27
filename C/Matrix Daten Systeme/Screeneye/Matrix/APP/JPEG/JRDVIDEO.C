/*
 * jrdvideo.c
 *
 */

#include "jinclude.h"
#include "j_video.h"

#include "jrdvideo.h"

WINDOW cwind = DEFAULTwindow ;

/*---------------------------------------- set_compression_window ---*/
void set_compression_window ( char *start,
							  int x, int y, int w, int h, int bpl, int bpp )
{
	if ( start != NULL )
		cwind.start = start ;
	cwind.pos = (void *)(
			(long)cwind.start + (long)y * (long)bpl + (long)bpp * (long)x / 8L ) ;
	cwind.x = x ;
	cwind.y = y ;
	cwind.w = w ;
	cwind.h = h ;
	if ( bpl != 0 )
		cwind.bpl = bpl ;
}


METHODDEF void
input_init (compress_info_ptr cinfo)
{
	UNUSED (cinfo) ;

	cinfo->input_components = 3;
	cinfo->in_color_space = CS_RGB;
	
	cinfo->image_width = cwind.w ;
	cinfo->image_height = cwind.h ;
	cinfo->data_precision = 8;
}


/*
 * Read one row of pixels.
 */

METHODDEF void
get_input_row (compress_info_ptr cinfo, JSAMPARRAY pixel_row)
{
  register JSAMPROW ptr0, ptr1, ptr2;
  register long col;
  unsigned char *vram ;
  long offset ;
  
  offset = cwind.bpl - cinfo->image_width * 4 ;
  vram = cwind.pos ;
 
    ptr0 = pixel_row[0];
    ptr1 = pixel_row[1];
    ptr2 = pixel_row[2];
    for (col = cinfo->image_width; col > 0; col--)
    {
      vram++ ;
      *ptr0++ = *vram++ ;
      *ptr1++ = *vram++ ;
      *ptr2++ = *vram++ ;
    }
    cwind.pos = vram + offset ;
}


METHODDEF void
input_term (compress_info_ptr cinfo)
{
  UNUSED(cinfo) ;
}


/*
 * The method selection routine for VIDEO format input.
 * Note that this must be called by the user interface before calling
 * jpeg_compress.  If multiple input formats are supported, the
 * user interface is responsible for discovering the input format and
 * calling the appropriate method selection routine.
 */

GLOBAL void
jselrvideo (compress_info_ptr cinfo)
{
  cinfo->methods->input_init = input_init;
  cinfo->methods->get_input_row = get_input_row;
  cinfo->methods->input_term = input_term;
}
