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
 *
 * 06.01.2001 flc (Francois Le Coat)
 *		Correction binding of v_gtext(), v_rbox(), v_rfbox(), vr_recfl()
 *		New function v_gtext16()
 *
 * 11.01.2001 ol (olivier.landemarre@utbm.fr)
 *		speed optimisation for: v_bar(), v_fillarea(), v_pline(), v_pmarker()
 *		v_rbox(), v_rfbox(), vr_recfl() 
 *
 * 28.01.2001 er (Eric Reboux: ers@free.fr)
 *		litle speed & size optimisation for: v_arc (), v_circle (), v_contourfill (),
 *		v_ellarc (), v_ellipse (), v_ellpie (), v_fillarea (), v_justified (),
 *		v_pieslice (), v_pline (), v_pmarker (), vr_recfl ().
 *
 * 11.02.2001 ol
 *		binding correction of v_cellaray()
 */

#include "mgem.h"


void v_arc (int handle, int x, int y, int radius, int begang, int endang)
{
	INT16 *ptr;

	vdi_intin[0] = begang;
	vdi_intin[1] = endang;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = *(ptr ++) = *(ptr ++) = *(ptr ++) = 0;	/* [2,3,4,5] */
	*(ptr ++) = radius;									/* [6] */
	*(ptr) = 0;											/* [7] */

	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = vdi_control[5] = 2;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_bar (int handle, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void v_cellarray (int handle, INT16 pxyarray[], int row_length, int elements, int nrows, int write_mode, INT16 colarray[])
{
	INT16 *wptr, *end;
	
	wptr = vdi_intin;
	end = (INT16 *)((long)wptr + (long)nrows * (long)elements);
	while (wptr < end)
		*wptr++ = *colarray++;

	vdi_ptsin[0] = pxyarray[0];
	vdi_ptsin[1] = pxyarray[1];
	vdi_ptsin[2] = pxyarray[2];
	vdi_ptsin[3] = pxyarray[3];
	 
	vdi_control[0] = 10;
	vdi_control[1] = 2;
	vdi_control[3] = (int)(wptr - vdi_intin);
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi_control[7] = row_length;
	vdi_control[8] = elements;
	vdi_control[9] = nrows;
	vdi_control[10] = write_mode;
	vdi(&vdi_params);
}


void v_circle (int handle, int x, int y, int radius)
{
	INT16 *ptr;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = *(ptr ++) = 0;							/* [2,3] */
	*(ptr ++) = radius;									/* [4] */
	*(ptr) = 0;											/* [5] */
	
	vdi_control[0] = 11;
	vdi_control[1] = 3;
	vdi_control[3] = 0;
	vdi_control[5] = 4;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_contourfill (int handle, int x, int y, int index)
{
	vdi_intin[0] = index;

	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;

	vdi_control[0] = 103;
	vdi_control[1] = vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi(&vdi_params);
}


void v_ellarc (int handle, int x, int y, int xrad, int yrad, int begang, int endang)
{
	INT16 *ptr;

	vdi_intin[0] = begang;
	vdi_intin[1] = endang;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = xrad;									/* [2] */
	*(ptr) = yrad;										/* [3] */

	vdi_control[0] = 11;
	vdi_control[1] = vdi_control[3] = 2;
	vdi_control[5] = 6;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_ellipse (int handle, int x, int y, int xrad, int yrad)
{
	INT16 *ptr;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = xrad;									/* [2] */
	*(ptr) = yrad;										/* [3] */

	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 5;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_ellpie (int handle, int x, int y, int xrad, int yrad, int begang, int endang)
{
	INT16 *ptr;

	vdi_intin[0] = begang;
	vdi_intin[1] = endang;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = xrad;									/* [2] */
	*(ptr) = yrad;										/* [3] */
	
	vdi_control[0] = 11;
	vdi_control[1] = vdi_control[3] = 2;
	vdi_control[5] = 7;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_fillarea (int handle, int count, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 9;
	vdi_control[1] = count;
	vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void v_gtext (int handle, int x, int y, char *str) 
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	
	vdi_control[0] = 8;
	vdi_control[1] = 1;									/* mod not 2 */
	vdi_control[3] = vdi_str2array (str, vdi_intin);
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_gtext16(int handle, int x, int y, INT16 *wstr,int wstrlen) 
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;

	vdi_params.intin = wstr;
	
	vdi_control[0] = 8;
	vdi_control[1] = 1; 
	vdi_control[3] = wstrlen;
	vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.intin = &vdi_intin[0];
}


void v_justified (int handle, int x, int y, char *str, int len, int word_space, int char_space)
{
	INT16 *ptr;

	vdi_intin[0] = word_space;
	vdi_intin[1] = char_space;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;
	*(ptr ++) = len;
	*(ptr) = 0;
	
	vdi_control[0] = 11;
	vdi_control[1] = 2;
	vdi_control[3] = vdi_str2array (str, vdi_intin + 2) + 2;
	vdi_control[5] = 10;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_pieslice (int handle, int x, int y, int radius, int begang, int endang)
{
	INT16 *ptr;

	vdi_intin[0] = begang;
	vdi_intin[1] = endang;

	ptr = vdi_ptsin;
	*(ptr ++) = x;										/* [0] */
	*(ptr ++) = y;										/* [1] */
	*(ptr ++) = *(ptr ++) = *(ptr ++) = *(ptr ++) = 0;	/* [2,3,4,5] */
	*(ptr ++) = radius;									/* [6] */
	*(ptr) = 0;											/* [7] */

	vdi_control[0] = 11;
	vdi_control[1] = 4;
	vdi_control[3] = 2;
	vdi_control[5] = 3;
	vdi_control[6] = handle;

	vdi (&vdi_params);
}


void v_pline (int handle, int count, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 6;
	vdi_control[1] = count;
	vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void v_pmarker (int handle, int count, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 7;
	vdi_control[1] = count;
	vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void v_rbox (int handle, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 11;
	vdi_control[1] = 2;									/* mod not 4 */
	vdi_control[3] = 0;
	vdi_control[5] = 8;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void v_rfbox (int handle, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 11;
	vdi_control[1] = 2;									/* mod not 4 */
	vdi_control[3] = 0;
	vdi_control[5] = 9;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}


void vr_recfl (int handle, INT16 pxyarray[])
{
	vdi_params.ptsin = pxyarray;

	vdi_control[0] = 114;
	vdi_control[1] = 2;
	vdi_control[3] = vdi_control[5] = 0;
	vdi_control[6] = handle;

	vdi (&vdi_params);

	vdi_params.ptsin = vdi_ptsin;
}
