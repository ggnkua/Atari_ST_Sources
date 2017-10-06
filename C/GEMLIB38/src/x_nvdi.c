/*
 * All functions of NVDI 2.x, 3.x, 4.x, 5.x
 *
*/
#include "gemx.h"

/*
 * The following functions requires EdDI version 1.x or higher
*/
void v_clsbm(int handle)
{
	vdi_control[0] = 101;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_opnbm(int *work_in, MFDB *bitmap, int *handle, int *work_out)
{
#ifndef __MSHORT__
	register int	i;

	for (i = 0; i<20; i++)
		vdi_intin[i] = work_in[i];
#else
	vdi_params.intin = (short *)&work_in[0];
	*((MFDB **)(&vdi_control[7])) = bitmap;
	vdi_params.intout = (short *)&work_out[0];
	vdi_params.ptsout = (short *)&work_out[45];
#endif

	*((MFDB **)(&vdi_control[7])) = bitmap;

	vdi_control[0] = 100;
	vdi_control[1] = 0;
	vdi_control[3] = 20;
	vdi_control[5] = 1;
	vdi_control[6] = *handle;
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

void vq_scrninfo(int handle, int *work_out)
{
#ifndef __MSHORT__
	register short	i;
#else
	vdi_params.intout = (short *)&work_out[0];
#endif

	vdi_intin[0] = 2;
	vdi_control[0] = 102;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

#ifndef __MSHORT__
	for (i = 0; i<273; i++)
		work_out[i] = vdi_intout[i];
#else
	vdi_params.intout = &vdi_intout[0];
#endif
}


/*
 * The following functions requires NVDI version 2.x or higher
*/
int v_bez_on(int handle)
{
	vdi_control[0] = 11;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[5] = 13;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void v_bez_off(int handle)
{
	vdi_control[0] = 11;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 13;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

static void _v_bez(int ctrl0, int handle, int count, int  *xyarr, char *bezarr, int *extent, int *totpts, int *totmoves)
{
	short	*end;
	char	*pbd = bezarr;
	char	*opbd = (char *)vdi_intin;
	short	*optr;

	end = (short *)(pbd + count);
	while (pbd < (char *)end)
	{
		*(opbd + 1) = *pbd++;
		if (pbd >= (char *)end)
			break;
		*opbd = *pbd++;
		opbd += 2;
	}
	optr = vdi_ptsin;
	end	= optr + count + count;
	while (optr < end)
		*optr++ = *xyarr++;

	vdi_control[0] = ctrl0;
	vdi_control[1] = count;
	vdi_control[3] = ((count + 1) >> 1);
	vdi_control[5] = 13;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	extent[0] = vdi_ptsout[0];
	extent[1] = vdi_ptsout[1];
	extent[2] = vdi_ptsout[2];
	extent[3] = vdi_ptsout[3];
	*totpts = vdi_intout[0];
	*totmoves = vdi_intout[1];
}

void v_bez(int handle, int count, int *xyarr, char *bezarr, int *extent, int *totpts, int *totmoves)
{
	_v_bez(6, handle, count, xyarr, bezarr, extent, totpts, totmoves);
}

void v_bez_fill(int handle, int count, int *xyarr, char *bezarr, int *extent, int *totpts, int *totmoves)
{
	_v_bez(9, handle, count, xyarr, bezarr, extent, totpts, totmoves);
}

void v_bez_qual(int handle, int percent, int *actual)
{
	vdi_intin[0] = 32;
	vdi_intin[1] = 1;
	vdi_intin[2] = percent;
	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 99;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*actual = vdi_intout[0];
}


/*
 * The following functions requires NVDI version 3.x or higher
*/
void v_ftext(int handle, int x, int y, char *str)
{
	short i;

	i = vdi_str2array(str, vdi_intin);
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;

	vdi_control[0] = 241;
	vdi_control[1] = 2;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_ftext_offset(int handle, int x, int y, char *str, int *offset)
{
	short *ptr = vdi_intin;
	short i;

	i = vdi_str2array(str, vdi_intin);
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	ptr = &vdi_ptsin[2];
	for(i *= 2; i > 0; i--)
		*ptr++ = *offset++;

	vdi_control[0] = 241;
	vdi_control[1] = 1 + i;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

void v_getbitmap_info(int handle, int ch, long *advancex, long *advancey,
							long *xoffset, long *yoffset, int *width, int *height,
							short **bitmap)
{
	vdi_intin[0] = ch;
	vdi_control[0] = 239;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*width = vdi_intout[0];
	*height = vdi_intout[1];
	*advancex = *((long *)(&vdi_intout[2]));
	*advancey = *((long *)(&vdi_intout[4]));
	*xoffset = *((long *)(&vdi_intout[6]));
	*yoffset = *((long *)(&vdi_intout[8]));
	*bitmap = *((short **)(&vdi_intout[10]));
}

void v_getoutline(int handle, int ch, int *xyarray, char *bezarray, int maxverts, int *numverts)
{
	vdi_intin[0] = ch;
	vdi_intin[1] = maxverts;
	*((int **)(&vdi_intin[2])) = xyarray;
	*((char **)(&vdi_intin[4])) = bezarray;
	vdi_control[0] = 243;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*numverts = vdi_intout[0];
}

void vq_devinfo(int handle, int device, int *dev_open, char *file_name, char *device_name)
{
	short	len, i;

	vdi_intin[0] = device;
	vdi_control[0] = 248;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout, file_name, vdi_control[4]);
	*dev_open = vdi_ptsout[0];

	/* Name in ptsout als C-String, d.h. pro ptsout[] 2 Buchstaben!! */
	if ((vdi_control[2] == 1 ) && (vdi_control[1] > 0 )) /* steht so in NVDI4-Doku */
		len = vdi_control[1];
	else
		len = vdi_control[2] - 1;
	for (i = 1; i <= len; i++)
		*((short *)device_name)++ = vdi_ptsout[i];
	*device_name++ = 0;
}

int vq_ext_devinfo (int handle, int device, int *dev_exists,
							char *file_path, char *file_name, char *name)
{
	vdi_intin[0] = device;
	*((char **)(&vdi_intin[1])) = file_path;
	*((char **)(&vdi_intin[3])) = file_name;
	*((char **)(&vdi_intin[5])) = name;
	vdi_control[0] = 248;
	vdi_control[1] = 0;
	vdi_control[3] = 7;
	vdi_control[5] = 4242;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*dev_exists = vdi_intout[0];
	return vdi_intout[1];
}

void vqt_advance(int handle, int ch, long *advx, long *advy)
{
	vdi_intin[0] = ch;
	vdi_control[0] = 247;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*advx = *((long *)(&vdi_ptsout[4]));
	*advy = *((long *)(&vdi_ptsout[6]));
}

int vqt_ext_name (int handle, int index, char *name, int *font_format, int *flags)
{
	vdi_intin[0] = index;
	vdi_intin[1] = 0;
	vdi_control[0] = 130;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout+1, name, 32);
	name[32]	= vdi_intout[33];
	*flags = (vdi_intout[34] >> 8) & 0xff;
	*font_format = vdi_intout[34] & 0xff;
 	return vdi_intout[0];
}

void vqt_f_extent(int handle, char *str, int extent[])
{
	short	i;

	i = vdi_str2array(str, vdi_intin);
	vdi_control[0] = 240;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	for (i = 0; i<8; i++)
		extent[i] = vdi_ptsout[i];
}

void vqt_fontheader(int handle, char *buffer, char *pathname)
{
	*((char **)(&vdi_intin[0])) = buffer;
 	vdi_control[0] = 232;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout, pathname, vdi_control[4]);
}

int vqt_name_and_id (int handle, int font_format, char *font_name, char *ret_name)
{
	short	i;

	vdi_intin[0] = font_format;
	i = vdi_str2array(font_name, vdi_intin);
 	vdi_control[0] = 230;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[5] = 100;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intin, ret_name, vdi_control[4]);
	return vdi_intout[0];
}

void vqt_pairkern(int handle, int ch1, int ch2, long *x, long *y)
{
	vdi_intin[0] = ch1;
	vdi_intin[1] = ch2;
 	vdi_control[0] = 235;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*x = *((long *)(&vdi_ptsout[0]));
	*y = *((long *)(&vdi_ptsout[2]));
}

void vqt_real_extent(int handle, int x, int y, char *string, int extent[])
{
	short	i;

	i = vdi_str2array(string, vdi_intin);
	vdi_ptsin[0] = x;
	vdi_ptsin[1] = y;
	vdi_control[0] = 240;
	vdi_control[1] = 1;
	vdi_control[3] = i;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	for (i = 0; i<8; i++)
		extent[i] = vdi_ptsout[i];
}

void vqt_trackkern(int handle, long *x, long *y)
{
 	vdi_control[0] = 234;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*x = *((long *)(&vdi_ptsout[0]));
	*y = *((long *)(&vdi_ptsout[2]));
}

int vqt_xfntinfo(int handle, int flags, int id, int index, XFNT_INFO *info)
{
	info->size = (long) sizeof(XFNT_INFO);
	vdi_intin[0] = flags;
	vdi_intin[1] = id;
	vdi_intin[2] = index;
	*((XFNT_INFO **)(&vdi_intin[3])) = info;
	vdi_control[0] = 229;
	vdi_control[1] = 0;
	vdi_control[3] = 5;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[1];
}

long vst_arbpt(int handle, long point, int *wchar, int *hchar, int *wcell, int *hcell)
{
	*((long *)(&vdi_intin[0])) = point;
	vdi_control[0] = 246;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*wchar = vdi_ptsout[0];
	*hchar = vdi_ptsout[1];
	*wcell = vdi_ptsout[2];
	*hcell = vdi_ptsout[3];
	return *((long *)(&vdi_intout[0]));
}

int vst_charmap(int handle, int mode)
{
	vdi_intin[0] = mode;
	vdi_intin[1] = 1;
	vdi_control[0] = 236;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return (int)vdi_intout[0];
}

void vst_kern(int handle, int tmode, int pmode, int *tracks, int *pairs)
{
	vdi_intin[0] = tmode;
	vdi_intin[1] = pmode;
	vdi_control[0] = 237;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*tracks = vdi_intout[0];
	*pairs = vdi_intout[1];
}

int vst_name(int handle, int font_format, char *font_name, char *ret_name)
{
	short	i;

	vdi_intin[0] = font_format;
	i = vdi_str2array(font_name, vdi_intin+1);
	vdi_control[0] = 230;
	vdi_control[1] = 0;
	vdi_control[3] = i;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	vdi_array2str(vdi_intout, ret_name, vdi_control[4]);
	return vdi_intout[0];
}

long vst_setsize(int handle, long point, int *wchar, int *hchar, int *wcell, int *hcell)
{
	*((long *)(&vdi_intin[0])) = point;
	vdi_control[0] = 252;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*wchar = vdi_ptsout[0];
	*hchar = vdi_ptsout[1];
	*wcell = vdi_ptsout[2];
	*hcell = vdi_ptsout[3];
	return *((long *)(&vdi_intout[0]));
}

int vst_skew(int handle, int skew)
{
	vdi_intin[0] = skew;
	vdi_control[0] = 253;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void vst_track_offset(int handle, long offset, int pairmode, int *tracks, int *pairs)
{
	vdi_intin[0] = 255;
	vdi_intin[1] = pairmode;
	*((long *)(&vdi_intin[2])) = offset;
	vdi_control[0] = 237;
	vdi_control[1] = 0;
	vdi_control[3] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*tracks = vdi_intout[0];
	*pairs  = vdi_intout[1];
}

void vst_width(int handle, int width, int *char_width, int *char_height, int *cell_width, int *cell_height)
{
	vdi_ptsin[0] = width;
	vdi_control[0] = 231;
	vdi_control[1] = 1;
	vdi_control[3] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	*char_width  = vdi_ptsout[0];
	*char_height = vdi_ptsout[1];
	*cell_width  = vdi_ptsout[2];
	*cell_height = vdi_ptsout[3];
}



/*
 * The following functions requires NVDI version 4.x or higher
*/
int vqt_char_index(int handle, int scr_index, int scr_mode, int dst_mode)
{
	vdi_intin[0] = scr_index;
	vdi_intin[1] = scr_mode;
	vdi_intin[2] = dst_mode;
	vdi_control[0] = 190;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}


/*
 * The following functions requires NVDI version 5.x or higher
*/
long v_color2nearest(int handle, long color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *color;

	vdi_control[0] = 204;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*nearest_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

unsigned long v_color2value(int handle, long color_space, COLOR_ENTRY *color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *color;

	vdi_control[0] = 204;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(unsigned long*)&vdi_intout[0]);
}

COLOR_TAB *v_create_ctab(int handle, long color_space, unsigned long px_format)
{
	*(long *) &vdi_intin[0] = color_space;
	*(unsigned long *) &vdi_intin[2] = px_format;

	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 4;
	vdi_control[5] = 8;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(COLOR_TAB **) &vdi_intout[0]);							
}

ITAB_REF	v_create_itab( int handle, COLOR_TAB *ctab, int bits )
{
	*(COLOR_TAB **) &vdi_intin[0] = ctab;
	vdi_intin[2] = bits;
	vdi_intin[3] = 0;
	vdi_intin[4] = 0;

	vdi_control[0] = 208;
	vdi_control[1] = 0;
	vdi_control[3] = 5;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(ITAB_REF *) &vdi_intout[0]);
}

unsigned long	v_ctab_idx2value( int handle, int index )
{
	vdi_intin[0] = index;

	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 5;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(unsigned long *) &vdi_intout[0]);								
}

int v_ctab_idx2vdi(int handle, int index)
{
	vdi_intin[0] = index;
	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int v_ctab_vdi2idx(int handle, int vdi_index)
{
	vdi_intin[0] = vdi_index;

	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];													
}

int v_delete_ctab(int handle, COLOR_TAB *ctab)
{
	*(COLOR_TAB **) &vdi_intin[0] = ctab;

	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 9;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int v_delete_itab(int handle, ITAB_REF itab)
{
	*(ITAB_REF *) &vdi_intin[0] = itab;

	vdi_control[0] = 208;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

long v_get_ctab_id(int handle)
{
	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 6;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(long *) &vdi_intout[0]);
}

int v_get_outline(int handle, int index, int x_offset, int y_offset, short *pts, char *flags, int max_pts)
{
	vdi_intin[0] = index;
	vdi_intin[1] = max_pts;
	*(short **) &vdi_intin[2] = pts;
	*(char **) &vdi_intin[4] = flags;
	vdi_intin[6] = x_offset;
	vdi_intin[7] = y_offset;

	vdi_control[0] = 243;
	vdi_control[1] = 0;
	vdi_control[3] = 8;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int v_open_bm(int base_handle, GCBITMAP *bitmap, int color_flags, int unit_flags, int pixel_width, int pixel_height)
{
	vdi_intin[0] = color_flags;
	vdi_intin[1] = unit_flags;
	vdi_intin[2] = pixel_width;
	vdi_intin[3] = pixel_height;

	vdi_control[0] = 100;
	vdi_control[1] = 0;
	vdi_control[3] = 4;
	vdi_control[5] = 3;
	vdi_control[6] = base_handle;
	*(GCBITMAP **) &vdi_control[7] = bitmap;
	vdi(&vdi_params);

	return vdi_control[6];
}

int v_opnprn(int aes_handle, PRN_SETTINGS *settings, int work_out[])
{
	register int	i;

	vdi_intin[0] = settings->driver_id;
	for(i = 1; i < 10; i++)
		vdi_intin[i] = 1;
	vdi_intin[10] = 2;
	vdi_intin[11] = settings->size_id;

	*(char **)&vdi_intin[12] = settings->device;
	*(PRN_SETTINGS **)&vdi_intin[14] = settings;

#ifdef __MSHORT___
	vdi_params.intout = &work_out[0];
	vdi_params.ptsout = &work_out[45];
#endif

	vdi_control[0] = 1;
	vdi_control[1] = 0;
	vdi_control[3] = 16;
	vdi_control[5] = 0;
	vdi_control[6] = aes_handle;
	vdi(&vdi_params);

#ifdef __MSHORT___
	vdi_params.intout = (void *)&vdi_intout[0];
	vdi_params.ptsout = (void *)&vdi_ptsout[0];
#else
	for (i = 0; i<45; i++)
		work_out[i] = vdi_intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdi_ptsout[i];
#endif
	return vdi_control[6];
}

int v_resize_bm(int handle, int width, int height, long byte_width, unsigned char *addr)
{
	vdi_intin[0] = width;
	vdi_intin[1] = height;
	*(long *) &vdi_intin[2] = byte_width;
	*(unsigned char **) &vdi_intin[4] = addr;

	vdi_control[0] = 100;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

void v_setrgb(int handle, int type, int r, int g, int b)
{
	vdi_intin[0] = r;
	vdi_intin[1] = g;
	vdi_intin[2] = b;

	vdi_control[0] = 138;
	vdi_control[1] = 0;
	vdi_control[3] = 3;
	vdi_control[5] = type;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

long v_value2color(int handle, unsigned long value, COLOR_ENTRY *color)
{
	*(unsigned long *)&vdi_intin[0] = value;
	vdi_control[0] = 204;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

int vq_ctab(int handle, long ctab_length, COLOR_TAB *ctab)
{
	*(long *) &vdi_intin[0] = ctab_length;
	vdi_params.intout = (short *)ctab;
	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	vdi_params.intout = vdi_intout;

	if (vdi_control[4])
		return 1;
	else
		return 0;
}

long vq_ctab_entry(int handle, int index, COLOR_ENTRY *color)
{
	vdi_intin[0] = index;

	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 1;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vq_ctab_id(int handle)
{
	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return (*(long*) &vdi_intout[0]);
}

int vq_dflt_ctab(int handle, long ctab_length, COLOR_TAB *ctab)
{
	*(long *) &vdi_intin[0] = ctab_length;								
	vdi_params.intout = (short *)ctab;										
	
	vdi_control[0] = 206;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[5] = 7;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	vdi_params.intout = vdi_intout;									

	if (vdi_control[4])
		return 1;
	else
		return 0;
}

long vq_hilite_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdi_control[0] = 209;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi( &vdi_params );

	*hilite_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return( *(long *) vdi_intout );
}

int vq_margins(int handle, int *top_margin, int *bottom_margin, int *left_margin, int *right_margin, int *hdpi, int *vdpi)
{
	vdi_intout[0] = 0;
	
	vdi_control[0] = 5;	 
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2100;
	vdi_control[6] = handle;	
	vdi(&vdi_params);
	
	*top_margin = vdi_intout[1];											
	*bottom_margin = vdi_intout[2];										
	*left_margin = vdi_intout[3];											
	*right_margin = vdi_intout[4];											
	*hdpi = vdi_intout[5];													
	*vdpi = vdi_intout[6];													

	return vdi_intout[0];
}

long vq_max_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdi_control[0] = 209;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi( &vdi_params );

	*hilite_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return( *(long *) vdi_intout );
}

long vq_min_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdi_control[0] = 209;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi( &vdi_params );

	*hilite_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return( *(long *) vdi_intout );
}

long vq_prn_scaling(int handle)
{
	vdi_intin[0] = -1;
	vdi_intin[1] = -1;

	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 2;
	vdi_control[4] = 0;
	vdi_control[5] = 39;
	vdi_control[6] = handle;

	vdi(&vdi_params);
	
	if (vdi_control[4] == 2)												
		return (*(long *) vdi_intout);
	else
		return -1L;
}

long vq_px_format(int handle, unsigned long *px_format)
{
	vdi( &vdi_params );
	vdi_control[0] = 204;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 3;
	vdi_control[6] = handle;

	*px_format = *(unsigned long *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vq_weight_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdi_control[0] = 209;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi( &vdi_params );

	*hilite_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return( *(long *) vdi_intout );
}

long vqf_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 203;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqf_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 202;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vql_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 203;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vql_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 202;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqm_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 203;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqm_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 202;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqr_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 203;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqr_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 202;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqt_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 203;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

long vqt_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdi_control[0] = 202;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	*fg_color = *(COLOR_ENTRY *) &vdi_intout[2];
	return (*(long*) &vdi_intout[0]);
}

void vr_transfer_bits(int handle, GCBITMAP *src_bm, GCBITMAP *dst_bm, int *src_rect, int *dst_rect, int mode)
{
	vdi_intin[0] = mode;
	vdi_intin[1] = 0;
	vdi_intin[2] = 0;
	vdi_intin[3] = 0;

	vdi_ptsin[0] = src_rect[0];
	vdi_ptsin[1] = src_rect[1];
	vdi_ptsin[2] = src_rect[2];
	vdi_ptsin[3] = src_rect[3];

	vdi_ptsin[4] = dst_rect[0];
	vdi_ptsin[5] = dst_rect[1];
	vdi_ptsin[6] = dst_rect[2];
	vdi_ptsin[7] = dst_rect[3];

	*(GCBITMAP **) &vdi_control[7] = src_bm;
	*(GCBITMAP **) &vdi_control[9] = dst_bm;
	*(GCBITMAP **) &vdi_control[11] = 0L;
	
	vdi_control[0] = 170;
	vdi_control[1] = 4;
	vdi_control[3] = 4;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);
}

int vs_ctab(int handle, COLOR_TAB *ctab)
{
	vdi_params.intin = (short *)ctab;

	vdi_control[0] = 205;
	vdi_control[1] = 0;
	vdi_control[3] = (short)(ctab->length / 2);
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	vdi_params.intin = vdi_intin;

	return (vdi_intout[0]);
}

int vs_ctab_entry(int handle, int index, long color_space, COLOR_ENTRY *color)
{
	vdi_intin[0] = index;
	*(long *) &vdi_intin[1] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[3] = *color;

	vdi_control[0] = 205;
	vdi_control[1] = 0;
	vdi_control[3] = 7;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi( &vdi_params );

	return vdi_intout[0];
}

int vs_dflt_ctab(int handle)
{
	vdi_control[0] = 205;
	vdi_control[1] = 0;
	vdi_control[3] = 0;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vs_document_info(int vdi_handle, int type, char *s, int wchar)
{
	int	cnt;

	vdi_intout[0] = 0;
	vdi_intin[0] = type;
	if (wchar)
	{
		/* 16bit strings not yet supported! */
		return 0;
	}
	else
		cnt = vdi_str2array(s, vdi_intin+1);

	vdi_control[0] = 5;
	vdi_control[1] = 0;
	vdi_control[3] = 1 + cnt;
	vdi_control[5] = 2103;
	vdi_control[6] = vdi_handle;
	vdi(&vdi_params);
	return vdi_intout[0];
}

int vs_hilite_color(int handle, long color_space, COLOR_ENTRY *hilite_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *hilite_color;

	vdi_control[0] = 207;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vs_max_color(int handle, long color_space, COLOR_ENTRY *min_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *min_color;

	vdi_control[0] = 207;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vs_min_color(int handle, long color_space, COLOR_ENTRY *min_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *min_color;

	vdi_control[0] = 207;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vs_weight_color(int handle, long color_space, COLOR_ENTRY *weight_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *weight_color;

	vdi_control[0] = 207;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsf_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *bg_color;

	vdi_control[0] = 201;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params );

	return vdi_intout[0];
}

int vsf_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *fg_color;

	vdi_control[0] = 200;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 1;
	vdi_control[6] = handle;
	vdi(&vdi_params );

	return vdi_intout[0];
}

int vsl_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{

	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *bg_color;

	vdi_control[0] = 201;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsl_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{

	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *fg_color;

	vdi_control[0] = 200;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 2;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsm_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *bg_color;

	vdi_control[0] = 201;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsm_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *fg_color;

	vdi_control[0] = 200;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 3;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsr_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *bg_color;

	vdi_control[0] = 201;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vsr_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdi_intin[0] = color_space;
	*(COLOR_ENTRY *) &vdi_intin[2] = *fg_color;

	vdi_control[0] = 200;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 4;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vst_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *)&vdi_intin[0] = color_space;
	*(COLOR_ENTRY *)&vdi_intin[2] = *bg_color;

	vdi_control[0] = 201;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}

int vst_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *)&vdi_intin[0] = color_space;
	*(COLOR_ENTRY *)&vdi_intin[2] = *fg_color;

	vdi_control[0] = 200;
	vdi_control[1] = 0;
	vdi_control[3] = 6;
	vdi_control[5] = 0;
	vdi_control[6] = handle;
	vdi(&vdi_params);

	return vdi_intout[0];
}
