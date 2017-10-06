/*
 * vdiesc.c
 * Copyright 1991 Jens Tingleff (uunet!titan.ee.ic.ac.uk!jensting)
 * Dedicated to public domain
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
 * special graphic funkcions
*/
void v_bit_image(int handle, char *filename, int aspect, int x_scale,
						int y_scale, int h_align, int v_align,	int *pxyarray)
{
	short n;

	vdi_intin[0] = aspect;
	vdi_intin[1] = x_scale;
	vdi_intin[2] = y_scale;
	vdi_intin[3] = h_align;
	vdi_intin[4] = v_align;
	n = vdi_str2array(filename, vdi_intin+5);
	vdi_ptsin[0] = pxyarray[0];
	vdi_ptsin[1] = pxyarray[1];
	vdi_ptsin[2] = pxyarray[2];
	vdi_ptsin[3] = pxyarray[3];
	
	vdi_control[0] = 5;
	vdi_control[1] = 2;
	vdi_control[3] = n + 5;
	vdi_control[5] = 23;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_clear_disp_list(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 22;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int v_copies(int handle, int count)
{
	vdi_intin[0] = count;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 28;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
} 

void v_dspcur(int handle, int x, int y)
{
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_control[0] = 5;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[5] = 18;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_form_adv(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 20;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_hardcopy(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 17;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int v_orient(int handle, int orientation)
{
	vdi_intin[0] = orientation;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 27;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
} 

void v_output_window(int handle, int *pxyarray)
{
	vdi_ptsin[0] = pxyarray[0];
	vdi_ptsin[1] = pxyarray[1];
	vdi_ptsin[2] = pxyarray[2];
	vdi_ptsin[3] = pxyarray[3];
	vdi_control[0] = 5;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 21;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int v_page_size(int handle, int page_id)
{
	vdi_intin[0] = page_id;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 37;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0]; 
} 

void v_rmcur(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 19;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_trays(int handle, int input, int output, int *set_input, int *set_output)
{
	vdi_intin[0] = input;
	vdi_intin[1] = output;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 29;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*set_input  = vdi_intout[0];
	*set_output = vdi_intout[1];
} 

int vq_calibrate (int handle, int *flag)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 77;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*flag = vdi_intout[0];
	return vdi_control[4];
} 

int vq_page_name(int handle, int page_id, char *page_name, long *page_width, long *page_height)
{
	vdi_intin[0] = page_id;
	*((char **)(&vdi_intin[1])) = page_name;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 38;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*page_width  = *((long *)(&vdi_intout[1]));
	*page_height = *((long *)(&vdi_intout[3])); 
	return vdi_intout[0];
} 

void vq_scan(int handle, int *g_slice, int *g_page, int *a_slice, int *a_page, int *div_fac)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 24;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*g_slice = vdi_intout[0];
	*g_page  = vdi_intout[1];
	*a_slice = vdi_intout[2];
	*a_page  = vdi_intout[3];
	*div_fac = vdi_intout[4];
}

int vq_tabstatus(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 16;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void vq_tray_names(int handle, char *input_name, char *output_name, int *input, int *output)
{
	*((char **)(&vdi_intin[0])) = input_name;
	*((char **)(&vdi_intin[2])) = output_name;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 4;
	vdi_control[5] = 36;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*input = vdi_intout[0];
	*output = vdi_intout[1]; 
} 

int vs_calibrate (int handle, int flag, int *rgb)
{
	*((int **)(&vdi_intin[0])) = rgb;
	vdi_intin[2] = flag;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 76;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
} 

int vs_palette( int handle, int palette)
{
	vdi_intin[0] = palette;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 60;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}


/*
 * graphic table functions
*/
void vq_tdimensions(int handle, int *xdimension, int *ydimension)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 84;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*xdimension = vdi_intout[0];
	*ydimension = vdi_intout[1]; 
} 

void vt_alignment(int handle, int dx, int dy)
{
	vdi_intin[0] = dx;
	vdi_intin[1] = dy;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 85;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vt_axis(int handle, int xres, int yres, int *xset, int *yset)
{
	vdi_intin[0] = xres;
	vdi_intin[1] = yres;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 82;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*xset = vdi_intout[0];
	*yset = vdi_intout[1];
}

void vt_origin(int handle, int xorigin, int yorigin)
{
	vdi_intin[0] = xorigin;
	vdi_intin[1] = yorigin;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 83;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vt_resolution( int handle, int xres, int yres, int *xset, int *yset)
{
	vdi_intin[0] = xres;
	vdi_intin[1] = yres;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 81;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*xset = vdi_intout[0];
	*yset = vdi_intout[1];
}


/*
 * metfile functions
*/
void v_meta_extents(int handle, int min_x, int min_y, int max_x, int max_y)
{
	vdi_ptsin[0] = min_x;
	vdi_ptsin[1] = min_y;
	vdi_ptsin[2] = max_x;
	vdi_ptsin[3] = max_y;
	vdi_control[0] = 5;
	vdi_control[1] = 2;
	vdi_control[3] = 0;
	vdi_control[5] = 98;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_write_meta(int handle, int numvdi_intin, int *avdi_intin, int num_ptsin, int *a_ptsin)
{
#ifdef __MSHORT__
	vdi_params.intin = (short *) &avdi_intin[0];
	vdi_params.ptsin = (short *) &a_ptsin[0];
#else
	register int i;

	for(i = 0; i < numvdi_intin; i++)
		vdi_intin[i] = avdi_intin[i];

	for(i = 0; i < num_ptsin; i++)
		vdi_ptsin[i] = a_ptsin[i];
#endif
	vdi_control[0] = 5;
	vdi_control[1] = num_ptsin;
	vdi_control[3] = numvdi_intin;
	vdi_control[5] = 99;
	vdi_control[6] = handle;
	vdi(&vdi_params);

#ifdef __MSHORT__
	vdi_params.intin = &vdi_intin[0]; 
	vdi_params.ptsin = &vdi_ptsin[0]; 
#endif
}

void vm_coords(int handle, int llx, int lly, int urx, int ury)
{
	vdi_intin[0] = 1;
	vdi_intin[1] = llx;
	vdi_intin[2] = lly;
	vdi_intin[3] = urx;
	vdi_intin[4] = ury;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 5;
	vdi_control[5] = 99;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vm_filename(int handle, char *filename)
{
	short n;

 	n = vdi_str2array(filename, vdi_intin);
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = n;
	vdi_control[5] = 100;
	vdi_control[6] = handle;
	vdi(&vdi_params);

}

void vm_pagesize(int handle, int pgwidth, int pgheight)
{
	vdi_intin[0] = 0;
	vdi_intin[1] = pgwidth;
	vdi_intin[2] = pgheight;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 99;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}


/*
 * polaroid functions - not complete implemented!
*/
void vsc_expose(int handle, int state)
{
	vdi_intin[0] = state;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 93;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vsp_film(int handle, int index, int lightness)
{
	vdi_intin[0] = index;
	vdi_intin[1] = lightness;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 91;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}


/*
 * special functions
*/
void v_escape2000(int handle, int times)
{
	vdi_intin[0] = times;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 2000;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}


/*
 * text functions
*/
void v_alpha_text(int handle, char *str)
{
	short	n;
	
	n = vdi_str2array(str, vdi_intin);
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = n;
	vdi_control[5] = 25;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curdown(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 5;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curhome(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 8;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curleft(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 7;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curright(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 6;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curtext(int handle, char *str)
{
	short	i;
	
	i = vdi_str2array(str, vdi_intin);
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[5] = 12;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_curup(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_eeol(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 10;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_eeos(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 9;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_enter_cur(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_exit_cur(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_rvoff(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 14;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_rvon(int handle)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 13;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void vq_chcells(int handle, int *n_rows, int *n_cols)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*n_rows = vdi_intout[0];
	*n_cols = vdi_intout[1];
}

void vq_curaddress(int handle, int *cur_row, int *cur_col)
{
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 15;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*cur_row = vdi_intout[0];
	*cur_col = vdi_intout[1];
}

void vs_curaddress(int handle, int row, int col)
{
	vdi_intin[0] = row;
	vdi_intin[1] = col;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 11;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}
