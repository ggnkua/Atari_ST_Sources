/*
 * jrd_mntc.c
 *
 */

#include "jinclude.h"
#include "j_video.h"
#include "jrd_mntc.h"

WINDOW mntc_cwind = DEFAULTwindow ;

/*---------------------------------------- set_ntc_compression_size ---*/
void set_ntc_compression_size ( NTCpixel *start, int w, int h )
{
	mntc_cwind.start = start ;
	mntc_cwind.pos = mntc_cwind.start ;
	mntc_cwind.w = w ;
	mntc_cwind.h = h ;
}


METHODDEF void
input_init (compress_info_ptr cinfo)
{
	cinfo->input_components = 3;
	cinfo->in_color_space = CS_RGB;
	
	cinfo->image_width = mntc_cwind.w ;
	cinfo->image_height = mntc_cwind.h ;
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
  NTCpixel *vram, pixel ;
  
  vram = mntc_cwind.pos ;
 
    ptr0 = pixel_row[0];
    ptr1 = pixel_row[1];
    ptr2 = pixel_row[2];
    for (col = cinfo->image_width; col > 0; col--)
    {
    	pixel = *vram++ ;
# if 0
      	*ptr0++ = pixel >> 11 ;				/*	R	*/
      	*ptr1++ = ( pixel >> 6 ) & 0x1f ;	/*	G	*/
      	*ptr2++ = pixel & 0x1f ;			/*	B	*/
# else
      	*ptr0++ = ( pixel >> 8 ) & 0xf8 ;	/*	R	*/
      	*ptr1++ = ( pixel >> 3 ) & 0xf8 ;	/*	G	*/
      	*ptr2++ = ( pixel << 3 ) & 0xf8 ;	/*	B	*/
# endif
    }
    mntc_cwind.pos = vram ;
}


METHODDEF void
input_term (compress_info_ptr cinfo)
{
}


/*
 * The method selection routine for VIDEO format input.
 * Note that this must be called by the user interface before calling
 * jpeg_compress.  If multiple input formats are supported, the
 * user interface is responsible for discovering the input format and
 * calling the appropriate method selection routine.
 */

GLOBAL void
jselrmemntc (compress_info_ptr cinfo)
{
  cinfo->methods->input_init = input_init;
  cinfo->methods->get_input_row = get_input_row;
  cinfo->methods->input_term = input_term;
}
