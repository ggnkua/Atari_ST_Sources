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
 *
 * 04.01.2001
 *		- Binding correction of v_opnwk() flc (Francois Le Coat)
 *
 * 07.01.2001
 *		- Binding correction of v_loadcache() ol (Olivier Landemarre)
 *
 * 19.02.2001
 *		- Little speed & size optimisation of vs_clip () er (Eric Reboux)
 */
#include "mgem.h"

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
	int i;
	
	vdi_intin[0] = mode;
	i = vdi_str2array(filename, vdi_intin+1);
	vdi_control[0] = 250;
	vdi_control[1] = 0;
	vdi_control[3] = i+1;  /* mod i */
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void v_opnvwk(INT16 work_in[], INT16 *handle, INT16 work_out[])
{
	vdi_params.intin  = &work_in[0];
	vdi_params.intout = &work_out[0];
	vdi_params.ptsout = &work_out[45];

	vdi_control[0] = 100;
	vdi_control[1] = 0;
	vdi_control[3] = 11;
	vdi_control[5] = 0;
	vdi_control[6] = *handle; /* mod not *handle */
	vdi(&vdi_params);

	vdi_params.intin  = &vdi_intin[0];
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];

	*handle = vdi_control[6];
}

void v_opnwk (INT16 work_in[], INT16 *handle, INT16 work_out[])
{
	vdi_params.intin = (INT16 *)&work_in[0];
	vdi_params.intout = (INT16 *)&work_out[0];
	vdi_params.ptsout = (INT16 *)&work_out[45];

	vdi_control[0] = 1;
	vdi_control[1] = 0;
	vdi_control[3] = 11; /* 5 mod not 0 */
	vdi_control[5] = 0;

	vdi (&vdi_params);

	vdi_params.intin = &vdi_intin[0];
	vdi_params.intout = &vdi_intout[0];
	vdi_params.ptsout = &vdi_ptsout[0];

	*handle = vdi_control[6];
}

int v_savecache(int handle, char *filename)
{
	int i;
	
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


void vs_clip (int handle, int clip_flag, INT16 pxyarray[])
{
	vdi_intin[0] = clip_flag;

	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 129;
	vdi_control[1] = 2;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


int vst_load_fonts(int handle, int select)
{
	vdi_intin[0] = select;
	vdi_control[0] = 119;
	vdi_control[1] = 0; /* mod erreur francois c'est bien 0 et pas 1!*/
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
