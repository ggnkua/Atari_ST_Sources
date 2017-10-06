/*
 *	Vdi output functions library interface
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


void v_arc(int handle, int x, int y, int radius, int begang, int endang)
{
	vdi_intin[0] = begang;
	vdi_intin[1] = endang;
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = 0;
	vdi_ptsin[3] = 0;
	vdi_ptsin[4] = 0;
	vdi_ptsin[5] = 0;
	vdi_ptsin[6] = radius;
	vdi_ptsin[7] = 0;
	
	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = 2;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_bar(int handle, int pxyarray[])
{
	register int i;
	 
	for(i = 0; i < 4; i++)
		vdi_ptsin[i] = pxyarray[i];

	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_cellarray(int handle, int pxyarray[], int row_length, int elements, int nrows, int write_mode, int colarray[])
{
	short *wptr, *end;
	
	wptr = vdi_intin;
	end = wptr + (short)nrows * (short)elements;
	while (wptr < end)
		*wptr++ = *colarray++;

	vdi_ptsin[0] = pxyarray[0];
	vdi_ptsin[1] = pxyarray[1];
	vdi_ptsin[2] = pxyarray[2];
	vdi_ptsin[3] = pxyarray[3];
	 
	vdi_control[0] = 10;
	vdi_control[1] = 2;
	vdi_control[3] = (int)(wptr - vdi_intin);
	vdi_control[6] = handle;
	vdi_control[7] = row_length;
	vdi_control[8] = elements;
	vdi_control[9] = nrows;
	vdi_control[10] = write_mode;
	vdi(&vdi_params);
}

void v_circle(int handle, int x, int y, int radius)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = 0;
	vdi_ptsin[3] = 0;
	vdi_ptsin[4] = radius;
	vdi_ptsin[5] = 0;
	
	vdi_control[0] = 11;
	vdi_control[1] = 3;
	vdi_control[3] = 0;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_contourfill(int handle, int x, int y, int index)
{
	vdi_intin[0] = index;
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_control[0] = 103;
	vdi_control[1] = 1;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_ellarc(int handle, int x, int y, int xrad, int yrad, int begang, int endang)
{
	vdi_intin[0] = begang;
	vdi_intin[1] = endang;
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = xrad;
	vdi_ptsin[3] = yrad;
	
	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 2;
	vdi_control[5] = 6;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_ellipse(int handle, int x, int y, int xrad, int yrad)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = xrad;
	vdi_ptsin[3] = yrad;
	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 5;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_ellpie(int handle, int x, int y, int xrad, int yrad, int begang, int endang)
{
	vdi_intin[0] = begang;
	vdi_intin[1] = endang;
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = xrad;
	vdi_ptsin[3] = yrad;
	
	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 2;
	vdi_control[5] = 7;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_fillarea(int handle, int count, int pxyarray[])
{
	register short i;
	register short *pts = &vdi_ptsin[0];
	register int	*pxy = &pxyarray[0];
	
	for(i = count; i != 0; i-- )
	{
		*pts++ = *pxy++;
		*pts++ = *pxy++;
	}

	vdi_control[0] = 9;
	vdi_control[1] = count;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_gtext(int handle, int x, int y, char *str) 
{
	short i;
	
	i = vdi_str2array(str, vdi_intin);
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	
	vdi_control[0] = 8;
	vdi_control[1] = 2;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_justified(int handle, int x, int y, char *str, int len, int word_space, int char_space)
{
	short i;
	
	vdi_intin[0] = word_space;
	vdi_intin[1] = char_space;
	i = vdi_str2array(str, vdi_intin+2);

	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = len;
	vdi_ptsin[3] = 0;
	
	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = i + 2;
	vdi_control[5] = 10;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_pieslice(int handle, int x, int y, int radius, int begang, int endang)
{
	vdi_intin[0] = begang;
	vdi_intin[1] = endang;
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_ptsin[2] = 0;
	vdi_ptsin[3] = 0;
	vdi_ptsin[4] = 0;
	vdi_ptsin[5] = 0;
	vdi_ptsin[6] = radius;
	vdi_ptsin[7] = 0;
	
	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = 2;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_pline(int handle, int count, int pxyarray[])
{
	register short	i;
	register short *pts = &vdi_ptsin[0];
	register int	*pxy = &pxyarray[0];
	
	for(i = count; i != 0; i-- )
	{
		*pts++ = *pxy++;
		*pts++ = *pxy++;
	}

	vdi_control[0] = 6;
	vdi_control[1] = count;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_pmarker(int handle, int count, int pxyarray[])
{
	register short i;
	register short *pts = &vdi_ptsin[0];
	register int	*pxy = &pxyarray[0];

	for(i = count; i != 0; i-- )
	{
		*pts++ = *pxy++;
		*pts++ = *pxy++;
	}

	vdi_control[0] = 7;
	vdi_control[1] = count;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_rbox(int handle, int pxyarray[])
{
	register int i;
	
	for(i = 0; i < 4; i++)
		vdi_ptsin[i] = pxyarray[i];
	
	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = 0;
	vdi_control[5] = 8;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_rfbox(int handle, int pxyarray[])
{
	register int i;
	
	for(i = 0; i < 4; i++)
		vdi_ptsin[i] = pxyarray[i];
	
	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = 0;
	vdi_control[5] = 9;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vr_recfl(int handle, int pxyarray[])
{
	register int i;
	
	for(i = 0; i < 4; i++)
		vdi_ptsin[i] = pxyarray[i];

	vdi_control[0] = 114;
	vdi_control[1] = 4;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}
