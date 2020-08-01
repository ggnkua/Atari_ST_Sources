/********************************************************************
 *																1.00*
 *	XAES: Image manipulation module									*
 *	Code by Ken Hollis and Karl Anders 0ygard						*
 *																	*
 *	This modules deals with all image transforming and scaling etc.	*
 *	These routines don't like XAES too much.  I will go ahead		*
 *	and add Christian Grunenberg's routines from E_GEM.				*
 *																	*
 ********************************************************************/

#include <vdi.h>

#include "xaes.h"

#ifndef __IMAGES__
#define __IMAGES__
#endif

/*
 *	Scale coordinates
 */
LOCAL void scale_coords(int *w, int *h)
{
	*w = (((*w) * image_w) + 7) >> 4;
	*h = (((*h) * image_h) + 7) >> 4;
}

/*
 *	Initialize mfdb block
 *
 *	*fm = mfdb to initialize
 *	w = width of mfdb
 *	h = height of mfdb
 *	st = 0/1 - standardformat/dependent
 *	pl = bitplanes
 */
GLOBAL void init_mfdb(MFDB *fm, int *adr, int w, int h, int st, int pl)
{
	fm->fd_addr		= adr;
	fm->fd_w		= (w + 15) & 0xfff0;
	fm->fd_h		= h;
	fm->fd_wdwidth	= fm->fd_w >> 4;
	fm->fd_stand	= st;
	fm->fd_nplanes	= pl;
}

/*
 *	Scale image
 *
 *	*src = pointer to image to scale
 *	w, h = width and heigth of image
 *	mode = scaling mode
 *	*b_w, *b_h = pointers to integers to contain new width and height
 *
 *	Returns: nothing
 */
GLOBAL void scale_img(int *src, int w, int h, int mode, int *b_w, int *b_h)
{
	if (src && big_img != TRUE) {
		int pxy[8], dark = mode & DARK_SCALING, vr_mode = dark ? S_OR_D : S_ONLY;
		MFDB image;
		int n_w = w, n_h = h;

		scale_coords(&n_w, &n_h);
		*b_w = n_w;
		*b_h = n_h;

		init_mfdb(&image, src, w, h, 0, 1);

		if (n_h < h) {
			int y, n_y, l_y, flag = TRUE;

			pxy[0] = pxy[4] = l_y = n_y = y = 0;
			pxy[2] = pxy[6] = w - 1;

			for (; y < h; y++) {
				if (n_y >= h || dark || y == (h - 1)) {
					pxy[1] = pxy[3] = y;
					pxy[5] = pxy[7] = l_y;
					vro_cpyfm(VDIhandle, flag ? 3 : vr_mode, pxy, &image, &image);
					if (n_y >= h) {
						n_y -= h;
						l_y++;
						flag = TRUE;
					}
					else
						flag = FALSE;
				}
				n_y += n_h;
			}

			for (y = n_h - 1; y < h; y++) {
				pxy[1] = pxy[3] = pxy[5] = pxy[7] = y;
				vro_cpyfm(VDIhandle, 0, pxy, &image, &image);
			}
			h = n_h;
		}

		if (n_w < w) {
			int x, n_x, l_x, flag = TRUE;

			pxy[1] = pxy[5] = l_x = n_x = x = 0;
			pxy[3] = pxy[7] = h - 1;

			for (; x < w; x++) {
				if (n_x >= w || dark || x == (w - 1)) {
					pxy[0] = pxy[2] = x;
					pxy[4] = pxy[6] = l_x;
					vro_cpyfm(VDIhandle, (flag) ? 3 : vr_mode, pxy, &image, &image);

					if (n_x >= w) {
						n_x -= w;
						l_x++;
						flag = TRUE;
					} else
						flag = FALSE;
				}
				n_x += n_w;
			}

			for (x = n_w - 1; x < w; x++) {
				pxy[0] = pxy[2] = pxy[4] = pxy[6] = x;
				vro_cpyfm(VDIhandle, 0, pxy, &image, &image);
			}
		}
	}
}


/*
 *	Scale image/bitmap object
 *
 *	*obj = pointer to object to transform
 *	mode = scaling mode (NO_SCALING/SCALING, TEST_SCALING/DARK_SCALING)
 *
 *	Returns: nothing
 */
GLOBAL void scale_image(OBJECT *obj, int mode)
{
	if (mode & SCALING) {
		int dummy;

		if (big_img) {
			obj->ob_x += ((gr_cw - (image_w >> 1)) * (obj->ob_width / gr_cw)) >> 1;
			obj->ob_y += ((gr_ch - image_h) * (obj->ob_height / gr_ch)) >> 1;
		} else
			if (obj->ob_type == G_ICON) {
				ICONBLK *icn = obj->ob_spec.iconblk;
	
				if (icn->ib_hicon > 3) {
					scale_img(icn->ib_pdata, icn->ib_wicon, icn->ib_hicon, mode, &dummy, &dummy);
					scale_img(icn->ib_pmask, icn->ib_wicon, icn->ib_hicon, mode, &dummy, &icn->ib_hicon);
					scale_coords(&icn->ib_xicon, &icn->ib_yicon);
					scale_coords(&icn->ib_xtext, &icn->ib_ytext);
					scale_coords(&icn->ib_xchar, &icn->ib_ychar);
				}
			} else {
				BITBLK *blk = obj->ob_spec.bitblk;
	
				if (blk->bi_hl > 3) {
					scale_img(blk->bi_pdata, blk->bi_wb << 3, blk->bi_hl, mode, &dummy, &blk->bi_hl);
					scale_coords(&blk->bi_x, &blk->bi_y);
				}
			}
	}
}


/*
 *	Transforms standard raster into device dependent raster
 *
 *	w = width of raster
 *	h = height of raster
 *	*data = pointer to raster data
 */
GLOBAL void vdi_trans(int w, int h, void *data)
{
	if (data) {
		MFDB src, dst;

		init_mfdb(&src, (int *) data, w, h, 1, 1);
		init_mfdb(&dst, (int *) data, w, h, 0, 1);

		vr_trnfm(VDIhandle, &src, &dst);
	}
}


/*
 *	Transform icon or bitmap into device dependent raster
 *
 *	*obj = pointer to object
 */
GLOBAL void trans_image(OBJECT *obj)
{
	if (obj->ob_type == G_ICON) {
		ICONBLK *icn = obj->ob_spec.iconblk;

		vdi_trans(icn->ib_wicon, icn->ib_hicon, icn->ib_pmask);
		vdi_trans(icn->ib_wicon, icn->ib_hicon, icn->ib_pdata);
	} else {
		BITBLK *img = obj->ob_spec.bitblk;

		vdi_trans(img->bi_wb << 3, img->bi_hl, img->bi_pdata);
	}
}
