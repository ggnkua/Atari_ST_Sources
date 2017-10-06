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
 */

#include "gem.h"

void vq_cellarray(int handle, int pxyarray[], int row_len, int nrows,
					  int *el_used, int *rows_used, int *status, int color[])
{
	short i;
	 
	vdi_ptsin[0] = pxyarray[0];
	vdi_ptsin[1] = pxyarray[1];
	vdi_ptsin[2] = pxyarray[2];
	vdi_ptsin[3] = pxyarray[3];
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
}

int vq_color(int handle, int index, int flag, int rgb[])
{
	vdi_intin[0] = index;
	vdi_intin[1] = flag;
	vdi_control[0] = 26;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	rgb[0] = vdi_intout[1];
	rgb[1] = vdi_intout[2];
	rgb[2] = vdi_intout[3];
	return vdi_intout[0];
}

void vq_extnd(int handle, int flag, int work_out[])
{
#ifndef __MSHORT__
	register short i;
#else
	vdi_params.intout = (short *)&work_out[0];
	vdi_params.ptsout = (short *)&work_out[45];
#endif

	vdi_intin[0] = flag;
	vdi_control[0] = 102;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

#ifndef __MSHORT__
	for (i = 0; i<45; i++)
		work_out[i] = vdi_intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdi_ptsout[i];
#else
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
#endif
}

void vqf_attributes(int handle, int atrib[])
{
	vdi_control[0] = 37;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	atrib[0] = vdi_intout[0];	 
	atrib[1] = vdi_intout[1];	 
	atrib[2] = vdi_intout[2];	 
	atrib[3] = vdi_intout[3];	 
}

void vqin_mode(int handle, int dev, int *mode)
{
	vdi_intin[0] = dev;
	vdi_control[0] = 115;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*mode = vdi_intout[0];
}

void vql_attribute(int handle, int atrib[])
{
	vdi_control[0] = 35;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	atrib[0] = vdi_intout[0];	 
	atrib[1] = vdi_intout[1];	 
	atrib[2] = vdi_intout[2];	 
	atrib[3] = vdi_ptsout[0];	 
	atrib[4] = vdi_intout[3];	 
	atrib[5] = vdi_intout[4];	 
}

void vqm_attributes(int handle, int atrib[])
{
	vdi_control[0] = 36;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	atrib[0] = vdi_intout[0];	 
	atrib[1] = vdi_intout[1];	 
	atrib[2] = vdi_intout[2];	 
	atrib[3] = vdi_ptsout[1];	 
	atrib[4] = vdi_ptsout[0];	 
}

void vqt_attributes(int handle, int atrib[])
{
#ifndef __MSHORT__
	short *wptr;
	int	 *end;
#else
	 vdi_params.intout = (short *)&atrib[0];
	 vdi_params.ptsout = (short *)&atrib[6];
#endif
	 
	vdi_control[0] = 38;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

#ifndef __MSHORT__	 
	wptr = &vdi_intout[0];
	end = &atrib[6];
	do 
	{
		*atrib++ = *wptr++;
	} while (atrib < end);
	wptr = &vdi_ptsout[0];
	end += 4;
	do 
	{
		*atrib++ = *wptr++;
	} while (atrib < end);
#else
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
#endif
}

void vqt_cachesize(int handle, int which_cache, long *size)
{
	vdi_intin[0] = which_cache;
	vdi_control[0] = 255;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*size = *((long *)(&vdi_intout[0]));
}

void vqt_extent(int handle, char *str, int extent[])
{
	short	i;
	
	i = vdi_str2array(str, vdi_intin);
	vdi_control[0] = 116;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	
	for (i = 0; i<8; i++)
		extent[i] = vdi_ptsout[i];
}

void vqt_fontinfo(int handle, int *minade, int *maxade, int distances[], int *maxwidth, int effects[])
{
	vdi_control[0] = 131;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*minade = vdi_intout[0];
	*maxade = vdi_intout[1];
	*maxwidth = vdi_ptsout[0];
	distances[0] = vdi_ptsout[1];
	distances[1] = vdi_ptsout[3];
	distances[2] = vdi_ptsout[5];
	distances[3] = vdi_ptsout[7];
	distances[4] = vdi_ptsout[9];
	effects[0] = vdi_ptsout[2];
	effects[1] = vdi_ptsout[4];
	effects[2] = vdi_ptsout[6];	 
}

void vqt_get_table(int handle, short **map)
{
	vdi_control[0] = 254;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*map = *((short **)(&vdi_intout[0]));
}

int vqt_name(int handle, int element, char *name)
{
	vdi_intin[0] = element;
	vdi_control[0] = 130;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout+1, name, 33);
	return vdi_intout[0];
}

int vqt_width(int handle, int chr, int *cw, int *ldelta, int *rdelta)
{
	vdi_intin[0] = chr;
	vdi_control[0] = 117;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*cw = vdi_ptsout[0];
	*ldelta = vdi_ptsout[2];
	*rdelta = vdi_ptsout[4];
	return vdi_intout[0];
}

