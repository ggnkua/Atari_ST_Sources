/*
 *	Vdi raster funcs library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 *
 * -------------------------------------
 * 12.07.97 cf (felsch@tu-harburg.de)
 *		modified for new control arrays
 *
 * 15.06.98
 *		- restructured, new bindings for all functions
 *
 * 11.01.2001 ol (olivier.landemarre@utbm.fr)
 *		speed optimisation for: v_raster(), vrt_cpyfm()
 *
 * 30.01.2001 er (Eric Reboux: ers@free.fr)
 *		little speed optimisation (for Pure C) for: v_get_pixel (), vr_trnfm ().
 *
 */

#include "mgem.h"


void v_get_pixel(int handle, int x, int y, INT16 *pel, INT16 *index)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	
	vdi_control[0] = 105;
	vdi_control[1] = 1;
	vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*pel = vdi_intout[0];
	*index = vdi_intout[1];
}


void vr_trnfm (int handle, MFDB *src, MFDB *dst)
{
	*((MFDB **)(&vdi_control[7])) = src;
	*((MFDB **)(&vdi_control[9])) = dst;

	vdi_control[0] = 110;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void vro_cpyfm (int handle, int mode, INT16 pxyarray[], MFDB *src, MFDB *dst)
{
	vdi_params.ptsin = pxyarray;

	vdi_intin[0] = mode;

	*((MFDB **)(&vdi_control[7])) = src;
	*((MFDB **)(&vdi_control[9])) = dst;

	vdi_control[0] = 109;
	vdi_control[1] = 4;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void vrt_cpyfm (int handle, int mode, INT16 pxyarray[], MFDB *src, MFDB *dst, INT16 color[])
{
	vdi_params.ptsin = pxyarray;

	vdi_intin[0] = mode;
	vdi_intin[1] = color[0];
	vdi_intin[2] = color[1];

	*((MFDB **)(&vdi_control[7])) = src;
	*((MFDB **)(&vdi_control[9])) = dst;

	vdi_control[0] = 121;
	vdi_control[1] = 4;
	vdi_control[3] = 3;
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}
