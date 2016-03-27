/*
 * jrd_mrgb.c
 *
 */

#include "jinclude.h"
#include "j_video.h"
#include "jrd_mrgb.h"

WINDOW mrgb_cwind = DEFAULTwindow ;

/*---------------------------------------- set_compression_size ---*/
void set_compression_size ( char *start, int w, int h )
{
	mrgb_cwind.start = start ;
	mrgb_cwind.pos = mrgb_cwind.start ;
	mrgb_cwind.w = w ;
	mrgb_cwind.h = h ;
}


METHODDEF void
input_init (compress_info_ptr cinfo)
{
	UNUSED (cinfo) ;

	cinfo->input_components = 3;
	cinfo->in_color_space = CS_RGB;
	
	cinfo->image_width = mrgb_cwind.w ;
	cinfo->image_height = mrgb_cwind.h ;
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
  
  vram = mrgb_cwind.pos ;
 
    ptr0 = pixel_row[0];
    ptr1 = pixel_row[1];
    ptr2 = pixel_row[2];
    for (col = cinfo->image_width; col > 0; col--)
    {
      *ptr0++ = *vram++ ;
      *ptr1++ = *vram++ ;
      *ptr2++ = *vram++ ;
    }
    mrgb_cwind.pos = vram ;
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
jselrmemrgb (compress_info_ptr cinfo)
{
  cinfo->methods->input_init = input_init;
  cinfo->methods->get_input_row = get_input_row;
  cinfo->methods->input_term = input_term;
}
