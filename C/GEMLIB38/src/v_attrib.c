/*
 *	Vdi attribute funcs library interface
 *
 *		++jrb	bammi@cadence.com
 *		modified: mj -- ntomczak@vm.ucs.ualberta.ca
 *
 * 92/03/10 mmn -- Markus_Nick@mz.maus.de
 *		changed return type of vst_height from void to int
 *		because vst_height returns the selected height
 *	
 * 950313 cg (d2cg@dtek.chalmers,se)
 *		modified for Pure C
 *
 * -------------------------------------
 * 12.07.97 cf (felsch@tu-harburg.de)
 *		modified for new control arrays
 *
 * 15.06.98
 *		- restructured, new bindings for all functions
 */
#include "gem.h"

/*
 * general attributes
*/
void vs_color(int handle, int index, int rgb[])
{
	vdi_intin[0] = index;
	vdi_intin[1] = rgb[0];
	vdi_intin[2] = rgb[1];
	vdi_intin[3] = rgb[2];

	vdi_control[0] = 14;
	vdi_control[1] = 0;
	vdi_control[3] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vswr_mode(int handle, int mode)
{
	vdi_intin[0] = mode;
	
	vdi_control[0] = 32;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}


/*
 * fill attributes
*/
int vsf_color(int handle, int index)
{
	vdi_intin[0] = index;
	vdi_control[0] = 25;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vsf_interior(int handle, int style)
{
	vdi_intin[0] = style;
	vdi_control[0] = 23;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vsf_perimeter(int handle, int vis)
{
	vdi_intin[0] = vis;
	vdi_control[0] = 104;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vsf_style(int handle, int style)
{
	vdi_intin[0] = style;
	vdi_control[0] = 24;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vsf_udpat(int handle, int pat[], int planes)
{
	register int i, j;
	 
	j = planes << 4;
	for(i = 0; i < j; i++)
		vdi_intin[i] = pat[i];
	vdi_control[0] = 112;
	vdi_control[1] = 0;
	vdi_control[3] = j;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}


/*
 * line attributes
*/
int vsl_color(int handle, int index)
{
	vdi_intin[0] = index;
	vdi_control[0] = 17;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vsl_ends(int handle, int begstyle, int endstyle)
{
	vdi_intin[0] = begstyle;
	vdi_intin[1] = endstyle;
	vdi_control[0] = 108;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vsl_type(int handle, int style)
{
	vdi_intin[0] = style;
	vdi_control[0] = 15;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vsl_udsty(int handle, int pat)
{
	vdi_intin[0] = pat;
	vdi_control[0] = 113;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vsl_width(int handle, int width)
{
	vdi_ptsin[0] = width;
	vdi_ptsin[1] = 0;
	vdi_control[0] = 16;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_ptsout[0];
}


/*
 * marker attributes
*/
int vsm_color(int handle, int index)
{
	vdi_intin[0] = index;
	vdi_control[0] = 20;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vsm_height(int handle, int height)
{
	vdi_ptsin[0] = 0;
	vdi_ptsin[1] = height;
	vdi_control[0] = 19;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vsm_type(int handle, int symbol)
{
	vdi_intin[0] = symbol;
	vdi_control[0] = 18;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}


/*
 * text attributes
*/
void vst_alignment(int handle, int hin, int vin, int *hout, int *vout)
{
	vdi_intin[0] = hin;
	vdi_intin[1] = vin;
	vdi_control[0] = 39;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*hout = vdi_intout[0];
	*vout = vdi_intout[1];
}

int vst_color(int handle, int index)
{
	vdi_intin[0] = index;
	vdi_control[0] = 22;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vst_effects(int handle, int effects)
{
	vdi_intin[0] = effects;
	vdi_control[0] = 106;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vst_error(int handle, int mode, short *errorvar)
{
	vdi_intin[0] = mode;
	*(short **)&vdi_intin[1] = (short *)&errorvar;
	vdi_control[0] = 245;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vst_font(int handle, int font)
{
	vdi_intin[0] = font;
	vdi_control[0] = 21;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

int vst_height(int handle, int height,	int *charw, int *charh, int *cellw, int *cellh)
{
	vdi_ptsin[0] = 0;
	vdi_ptsin[1] = height;
	vdi_control[0] = 12;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*charw = vdi_ptsout[0];
	*charh = vdi_ptsout[1];
	*cellw = vdi_ptsout[2];
	*cellh = vdi_ptsout[3];
	return (int)vdi_intout[0];
}	  

int vst_point(int handle, int point, int *charw, int *charh, int *cellw, int *cellh)
{
	vdi_intin[0] = point;
	vdi_control[0] = 107;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*charw = vdi_ptsout[0];
	*charh = vdi_ptsout[1];
	*cellw = vdi_ptsout[2];
	*cellh = vdi_ptsout[3];
	return (int)vdi_intout[0];
}	  

int vst_rotation(int handle, int ang)
{
	vdi_intin[0] = ang;
	vdi_control[0] = 13;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vst_scratch(int handle, int mode)
{
	vdi_intin[0] = mode;
	vdi_control[0] = 244;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}
