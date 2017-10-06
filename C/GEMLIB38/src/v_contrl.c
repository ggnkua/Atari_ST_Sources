/*
 *	Vdi contrl functions library interface (part 1)
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
 */
#include "gem.h"

void v_clrwk(int handle)
{
	vdi_control[0] = 3;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_clsvwk(int handle)
{
	vdi_control[0] = 101;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_clswk(int handle)
{
	vdi_control[0] = 2;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int v_flushcache(int handle)
{
	vdi_control[0] = 251;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

int v_loadcache(int handle, char *filename, int mode)
{
	short i;
	
	vdi_intin[0] = mode;
	i = vdi_str2array(filename, vdi_intin+1);
	vdi_control[0] = 250;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void v_opnvwk(int work_in[], int *handle, int work_out[])
{
#ifndef __MSHORT___
	register int	i;
	
	for (i = 0; i<11; i++)
		vdi_intin[i] = work_in[i];
#else
	vdi_params.intin = &work_in[0];
	vdi_params.intout = &work_out[0];
	vdi_params.ptsout = &work_out[45];
#endif
	
	vdi_control[0] = 100;
	vdi_control[1] = 0;
	vdi_control[3] = 11;
	vdi_control[5] = 0;
	vdi_control[6] = *handle;
	vdi(&vdi_params);
	
#ifndef __MSHORT___
	for (i = 0; i<45; i++)
		work_out[i] = vdi_intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdi_ptsout[i];
#else
	vdi_params.intin = &vdi_intin[0];
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
#endif
	*handle = vdi_control[6];
}

void v_opnwk(int work_in[], int *handle, int work_out[])
{
#ifndef __MSHORT__
	register int	i;
	
	for (i = 0; i<16; i++)
		vdi_intin[i] = work_in[i];
#else
	vdi_params.intin = (short *)&work_in[0];
	vdi_params.intout = (short *)&work_out[0];
	vdi_params.ptsout = (short *)&work_out[45];
#endif
	
	vdi_control[0] = 1;
	vdi_control[1] = 0;
	vdi_control[3] = 16;
	vdi_control[5] = 0;
	vdi_control[6] = 0;
	vdi(&vdi_params);
	
#ifndef __MSHORT__
	for (i = 0; i<45; i++)
		work_out[i] = vdi_intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdi_ptsout[i];
#else
	vdi_params.intin = &vdi_intin[0];
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];
#endif
	*handle = vdi_control[6];
}

int v_savecache(int handle, char *filename)
{
	short i;
	
	i = vdi_str2array(filename, vdi_intin);
	vdi_control[0] = 249;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void v_set_app_buff(int handle, void *buf_p, int size)
{
	*((void **)(&vdi_intin[0])) = buf_p;
	vdi_intin[3] = size;
	vdi_control[0] = -1;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 6;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_updwk(int handle)
{
	vdi_control[0] = 4;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vs_clip(int handle, int clip_flag, int pxyarray[])
{
	register int i;
	
	vdi_intin[0] = clip_flag;
	for(i = 0; i < 4; i++)
		vdi_ptsin[i] = pxyarray[i];
	vdi_control[0] = 129;
	vdi_control[1] = 2;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vst_load_fonts(int handle, int select)
{
	vdi_intin[0] = select;
	vdi_control[0] = 119;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void vst_unload_fonts(int handle, int select)
{
	vdi_intin[0] = select;
	vdi_control[0] = 120;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}
