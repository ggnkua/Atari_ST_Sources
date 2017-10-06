/*
 *	Vdi inquiry funcs library interface
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
 * 06.01.2001 ol (olivier landemarre)
 *		correction binding of vqm_attributes()
 *
 * 11.01.2001 ol
 *		speed optimisation for vq_cellarray()
 *
 * 30.01.2001 er (Eric Reboux)
 *      correction binding (intout[4]) for vqf_attributes ().
 *      vql_attribute () is renamed in vql_attributes ()
 *		litle speed & size optimisation for vq_color (), vq_extnd (), vqf_attributes (),
 *		vqin_mode (), vql_attributes (), vqm_attributes (), vqt_attributes (), vqt_cachesize (),
 *		vqt_extent (), vqt_fontinfo (), vqt_get_table (), vqt_name (), vqt_width ().
 *		
 */

#include "mgem.h"


void vq_cellarray (int handle, INT16 pxyarray[], int row_len, int nrows, INT16 *el_used, INT16 *rows_used, INT16 *status, INT16 color[])
{
	int i;
	 
	vdi_params.ptsin = pxyarray;

	vdi_control[7] = row_len;
	vdi_control[8] = nrows;
  	vdi_control[0] = 27;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	for (i = 0; i<vdi_control[4]; i++)
		color[i] = vdi_intout[i];
	*el_used = vdi_control[9];
	*rows_used = vdi_control[10];
	*status 	= vdi_control[11];
	vdi_params.ptsin=vdi_ptsin;
}


int vq_color (int handle, int index, int flag, INT16 rgb[])
{
	vdi_intin[0] = index;
	vdi_intin[1] = flag;

	vdi_control[0] = 26;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*(rgb ++) = vdi_intout[1];
	*(rgb ++) = vdi_intout[2];
	*(rgb) = vdi_intout[3];

	return (vdi_intout[0]);
}


void vq_extnd (int handle, int flag, INT16 work_out[])
{
	vdi_params.intout = (INT16 *)&work_out[0];
	vdi_params.ptsout = (INT16 *)&work_out[45];

	vdi_intin[0] = flag;
	vdi_control[0] = 102;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
}


void vqf_attributes (int handle, INT16 atrib[])
{
	INT16 *ptr;

	vdi_control[0] = 37;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	ptr = vdi_intout;
	*(atrib ++) = *(ptr ++);	 						/* [0] */
	*(atrib ++) = *(ptr ++);	 						/* [1] */
	*(atrib ++) = *(ptr ++);	 						/* [2] */
	*(atrib ++) = *(ptr ++);	 						/* [3] */
 	*(atrib) = *(ptr);									/* [4] */
}


void vqin_mode (int handle, int dev, INT16 *mode)
{
	vdi_intin[0] = dev;

	vdi_control[0] = 115;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*mode = vdi_intout[0];
}


void vql_attributes (int handle, INT16 atrib[])
{
	INT16 *ptr;

	vdi_control[0] = 35;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	ptr = vdi_intout;
	*(atrib ++) = *(ptr ++);	 						/* [0] */
	*(atrib ++) = *(ptr ++);	 						/* [1] */
	*(atrib ++) = *(ptr ++);		 					/* [2] */
	*(atrib ++) = vdi_ptsout[0];	 
	*(atrib ++) = *(ptr ++);		 					/* [3] */
	*(atrib) = *(ptr);	 								/* [4] */
}


void vqm_attributes (int handle, INT16 atrib[])
{
	INT16 *ptr;

	vdi_control[0] = 36;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	ptr = vdi_intout;
	*(atrib ++) = *(ptr ++);	 						/* [0] */ 
	*(atrib ++) = *(ptr ++);	 						/* [1] */	 
	*(atrib ++) = *(ptr);		 						/* [2] */
	*(atrib ++) = vdi_ptsout[0];	 					/* mod inversion 3 and 4 !!*/
	*(atrib) = vdi_ptsout[1];	 
}


void vqt_attributes (int handle, INT16 atrib[])
{
	vdi_params.intout = (INT16 *)&atrib[0];
	vdi_params.ptsout = (INT16 *)&atrib[6];

	vdi_control[0] = 38;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
}


void vqt_cachesize (int handle, int which_cache, long *size)
{
	vdi_intin[0] = which_cache;

	vdi_control[0] = 255;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*size = *((long *)(&vdi_intout[0]));
}


void vqt_extent (int handle, char *str, INT16 extent[])
{
	int i;
	INT16 *ptr;

	vdi_control[0] = 116;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = vdi_str2array (str, vdi_intin);
	vdi_control[6] = handle;

	vdi (&vdi_params);

	ptr = vdi_ptsout;
	i = 8;
	do
	{
		*(extent ++) = *(ptr ++);
	} while (-- i);
}


void vqt_fontinfo (int handle, INT16 *minade, INT16 *maxade, INT16 distances[], INT16 *maxwidth, INT16 effects[])
{
	INT16 *ptr;

	vdi_control[0] = 131;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*minade = vdi_intout[0];
	*maxade = vdi_intout[1];

	ptr = vdi_ptsout;
	*maxwidth = *(ptr ++);								/* *maxwidth = vdi_ptsout[0] */
	*(distances ++) = *(ptr ++);						/* distances[0] = vdi_ptsout[1] */
	*(effects ++) = *(ptr ++);							/* effects[0] = vdi_ptsout[2] */
	*(distances ++) = *(ptr ++);						/* distances[1] = vdi_ptsout[3] */
	*(effects ++) = *(ptr ++);							/* effects[1] = vdi_ptsout[4] */
	*(distances ++) = *(ptr ++);						/* distances[2] = vdi_ptsout[5] */
	*(effects) = *(ptr ++);								/* effects[2] = vdi_ptsout[6] */
	*(distances ++) = *(ptr);							/* distances[3] = vdi_ptsout[7] */
	*(distances) = vdi_ptsout[9];						/* distances[4] = vdi_ptsout[9] */
}


void vqt_get_table (int handle, INT16 **map)
{
	vdi_control[0] = 254;
	vdi_control[1] = vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*map = *((INT16 **)(&vdi_intout[0]));
}


int vqt_name (int handle, int element, char *name)
{
	vdi_intin[0] = element;

	vdi_control[0] = 130;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_array2str (vdi_intout + 1, name, 33);

	return (vdi_intout[0]);
}


int vqt_width (int handle, int chr, INT16 *cw, INT16 *ldelta, INT16 *rdelta)
{
	vdi_intin[0] = chr;

	vdi_control[0] = 117;
	vdi_control[1] = vdi_control[5] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	*cw = vdi_ptsout[0];
	*ldelta = vdi_ptsout[2];
	*rdelta = vdi_ptsout[4];

	return (vdi_intout[0]);
}
