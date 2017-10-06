/*
 *	Vdi input funcs library interface
 *
 *	++jrb	bammi@cadence.com
 *	modified: mj -- ntomczak@vm.ucs.ualberta.ca
 *
 * whoever at atari/dri designed this part was
 * definitely *not* on over-the-counter drugs
 *
 * -------------------------------------
 * 12.07.97 cf (felsch@tu-harburg.de)
 *		modified for new control arrays
 *
 * 15.06.98
 *		- restructured, new bindings for all functions
 */
#include "gem.h"

void v_hide_c(int handle)
{
	vdi_control[0] = 123;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_show_c(int handle, int reset)
{
	vdi_intin[0] = reset;
	vdi_control[0] = 122;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vex_butv(int handle, void *new, void **old)
{
	*((void **)(&vdi_control[7])) = new;
	vdi_control[0] = 125;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*old = *((void **)(&vdi_control[9]));
}

void vex_curv(int handle, void *new, void **old)
{
	*((void **)(&vdi_control[7])) = new;
	vdi_control[0] = 127;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*old = *((void **)(&vdi_control[9]));
}

void vex_motv(int handle, void *new, void **old)
{
	*((void **)(&vdi_control[7])) = new;
	vdi_control[0] = 126;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*old = *((void **)(&vdi_control[9]));
}

void vex_timv(int handle, void *time_addr, void **otime_addr, int *time_conv)
{
	*((void **)(&vdi_control[7])) = time_addr;
	vdi_control[0] = 118;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*otime_addr = *((void **)(&vdi_control[9]));
	*time_conv  = vdi_intout[0];
}

void vq_key_s(int handle, int *state)
{
	vdi_control[0] = 128;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*state = vdi_intout[0];
}

void vq_mouse(int handle, int *pstatus, int *x, int *y)
{
	vdi_control[0] = 124;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*pstatus = vdi_intout[0];
	*x = vdi_ptsout[0];
	*y = vdi_ptsout[1];
}

void vrq_choice(int handle, int cin, int *cout)
{
	vdi_intin[0] = cin;
	vdi_control[0] = 30;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*cout = vdi_intout[0];
}

void vrq_locator(int handle, int x, int y, int *xout, int *yout, int *term)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_control[0] = 28;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*xout = vdi_ptsout[0];
	*yout = vdi_ptsout[1];
	*term = vdi_intout[0];
}

void vrq_string(int handle, int len, int echo, int echoxy[], char *str)
{
	vdi_intin[0] = len;
	vdi_intin[1] = echo;
	vdi_ptsin[0] = echoxy[0];
	vdi_ptsin[1] = echoxy[1];
	vdi_control[0] = 31;
	vdi_control[1] = 1;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout, str, vdi_control[4]);
}

void vrq_valuator(int handle, int in, int *out, int *term)
{
	vdi_intin[0] = in;
	vdi_control[0] = 29;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*out = vdi_intout[0];
	*term = vdi_intout[1];
}

void vsc_form(int handle, int form[])
{
#ifndef __MSHORT__
	short	i;

	for (i = 0; i<37; i++)
		vdi_intin[i] = form[i];
#else
	vdi_params.intin = (short *)&form[0];
#endif

	vdi_control[0] = 111;
	vdi_control[1] = 0;
	vdi_control[3] = 37;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

#ifdef __MSHORT__
	vdi_params.intin = (short *)&vdi_intin[0];
#endif
}

int vsin_mode(int handle, int dev, int mode)
{
	vdi_intin[0] = dev;
	vdi_intin[1] = mode;
	vdi_control[0] = 33;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

int vsm_choice(int handle, int *choice)
{
	vdi_control[0] = 30;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*choice = vdi_intout[0];
	return vdi_control[4];
}

int vsm_locator(int handle, int x, int y, int *xout, int *yout, int *term)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_control[0] = 28;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*xout = vdi_ptsout[0];
	*yout = vdi_ptsout[1];
	*term = vdi_intout[0];
	return ((vdi_control[4] << 1) | vdi_control[2]);
}

int vsm_string(int handle, int len, int echo, int echoxy[], char *str)
{
	vdi_intin[0] = len;
	vdi_intin[1] = echo;
	vdi_ptsin[0] = echoxy[0];
	vdi_ptsin[1] = echoxy[1];
	vdi_control[0] = 31;
	vdi_control[1] = 1;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout, str, vdi_control[4]);
	return vdi_control[4]; 
}

void vsm_valuator(int handle, int in, int *out, int *term, int *status)
{
	vdi_intin[0] = in;
	vdi_control[0] = 29;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*out = vdi_intout[0];
	*term = vdi_intout[1];
	*status = vdi_control[4];
}
