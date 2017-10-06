/*
 * All functions of NVDI 2.x, 3.x, 4.x, 5.x
 *
 */

#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

extern VDIPB vdipb;
void vdi( VDIPB *);
void vdi_array2str		(int *src, char *des, int len);int	 vdi_str2array		(char *src, int *des);
/*
 * The following functions requires EdDI version 1.x or higher
 */

void v_clsbm(int handle)
{
	vdipb.contrl[0] = 101;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
}

void v_opnbm(int *work_in, MFDB *bitmap, int *handle, int *work_out)
{
#ifndef __MSHORT__
	register int	i;

	for (i = 0; i<20; i++)
		vdipb.intin[i] = work_in[i];
#else
	vdipb.intin = (short *)&work_in[0];
	*((MFDB **)(&vdipb.contrl[7])) = bitmap;
	vdipb.intout = (short *)&work_out[0];
	vdipb.ptsout = (short *)&work_out[45];
#endif

	*((MFDB **)(&vdipb.contrl[7])) = bitmap;

	vdipb.contrl[0] = 100;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 20;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = *handle;
	vdi( &vdipb);

#ifndef __MSHORT__
	for (i = 0; i<45; i++)
		work_out[i] = vdipb.intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdipb.ptsout[i];
#else
	vdipb.intin = &vdipb.intin[0];
	vdipb.intout = &vdipb.intout[0];
	vdipb.ptsout = &vdipb.ptsout[0];
#endif
	*handle = vdipb.contrl[6];
}

void vq_scrninfo(int handle, int *work_out)
{
#ifndef __MSHORT__
	register short	i;
#else
	vdipb.intout = (short *)&work_out[0];
#endif

	vdipb.intin[0] = 2;
	vdipb.contrl[0] = 102;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

#ifndef __MSHORT__
	for (i = 0; i<273; i++)
		work_out[i] = vdipb.intout[i];
#else
	vdipb.intout = &vdipb.intout[0];
#endif
}

/*
 * The following functions requires NVDI version 3.x or higher
 */

void v_ftext_offset(int handle, int x, int y, char *str, int *offset)
{
	int *ptr = vdipb.intin;
	int i;

	i = vdi_str2array(str, vdipb.intin);
	vdipb.ptsin[0] = x;
	vdipb.ptsin[1] = y;
	ptr = &vdipb.ptsin[2];
	for(i *= 2; i > 0; i--)
		*ptr++ = *offset++;

	vdipb.contrl[0] = 241;
	vdipb.contrl[1] = 1 + i;
	vdipb.contrl[3] = i;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
}

void v_getbitmap_info(int handle, int ch, long *advancex, long *advancey,
							long *xoffset, long *yoffset, int *width, int *height,
							short **bitmap)
{
	vdipb.intin[0] = ch;
	vdipb.contrl[0] = 239;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*width = vdipb.intout[0];
	*height = vdipb.intout[1];
	*advancex = *((long *)(&vdipb.intout[2]));
	*advancey = *((long *)(&vdipb.intout[4]));
	*xoffset = *((long *)(&vdipb.intout[6]));
	*yoffset = *((long *)(&vdipb.intout[8]));
	*bitmap = *((short **)(&vdipb.intout[10]));
}

void vq_devinfo(int handle, int device, int *dev_open, char *file_name, char *device_name)
{
	short	len, i;

	vdipb.intin[0] = device;
	vdipb.contrl[0] = 248;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	vdi_array2str(vdipb.intout, file_name, vdipb.contrl[4]);
	*dev_open = vdipb.ptsout[0];

	/* Name in ptsout als C-String, d.h. pro ptsout[] 2 Buchstaben!! */
	if ((vdipb.contrl[2] == 1 ) && (vdipb.contrl[1] > 0 )) /* steht so in NVDI4-Doku */
		len = vdipb.contrl[1];
	else
		len = vdipb.contrl[2] - 1;
	for (i = 1; i <= len; i++)
		*((short *)device_name)++ = vdipb.ptsout[i];
	*device_name++ = 0;
}

int vq_ext_devinfo (int handle, int device, int *dev_exists,
							char *file_path, char *file_name, char *name)
{
	vdipb.intin[0] = device;
	*((char **)(&vdipb.intin[1])) = file_path;
	*((char **)(&vdipb.intin[3])) = file_name;
	*((char **)(&vdipb.intin[5])) = name;
	vdipb.contrl[0] = 248;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 7;
	vdipb.contrl[5] = 4242;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*dev_exists = vdipb.intout[0];
	return vdipb.intout[1];
}

int vqt_ext_name (int handle, int index, char *name, int *font_format, int *flags)
{
	vdipb.intin[0] = index;
	vdipb.intin[1] = 0;
	vdipb.contrl[0] = 130;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	vdi_array2str(vdipb.intout+1, name, 32);
	name[32]	= vdipb.intout[33];
	*flags = (vdipb.intout[34] >> 8) & 0xff;
	*font_format = vdipb.intout[34] & 0xff;
 	return vdipb.intout[0];
}

void vqt_f_extent(int handle, char *str, int extent[])
{
	short	i;

	i = vdi_str2array(str, vdipb.intin);
	vdipb.contrl[0] = 240;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = i;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	for (i = 0; i<8; i++)
		extent[i] = vdipb.ptsout[i];
}

void vqt_fontheader(int handle, char *buffer, char *pathname)
{
	*((char **)(&vdipb.intin[0])) = buffer;
 	vdipb.contrl[0] = 232;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	vdi_array2str(vdipb.intout, pathname, vdipb.contrl[4]);
}

int vqt_name_and_id (int handle, int font_format, char *font_name, char *ret_name)
{
	short	i;

	vdipb.intin[0] = font_format;
	i = vdi_str2array(font_name, vdipb.intin);
 	vdipb.contrl[0] = 230;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = i;
	vdipb.contrl[5] = 100;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	vdi_array2str(vdipb.intin, ret_name, vdipb.contrl[4]);
	return vdipb.intout[0];
}

void vqt_pairkern(int handle, int ch1, int ch2, long *x, long *y)
{
	vdipb.intin[0] = ch1;
	vdipb.intin[1] = ch2;
 	vdipb.contrl[0] = 235;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*x = *((long *)(&vdipb.ptsout[0]));
	*y = *((long *)(&vdipb.ptsout[2]));
}

void vqt_real_extent(int handle, int x, int y, char *string, int extent[])
{
	short	i;

	i = vdi_str2array(string, vdipb.intin);
	vdipb.ptsin[0] = x;
	vdipb.ptsin[1] = y;
	vdipb.contrl[0] = 240;
	vdipb.contrl[1] = 1;
	vdipb.contrl[3] = i;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	for (i = 0; i<8; i++)
		extent[i] = vdipb.ptsout[i];
}

void vqt_trackkern(int handle, long *x, long *y)
{
 	vdipb.contrl[0] = 234;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*x = *((long *)(&vdipb.ptsout[0]));
	*y = *((long *)(&vdipb.ptsout[2]));
}

int vqt_xfntinfo(int handle, int flags, int id, int index, XFNT_INFO *info)
{
	info->size = (long) sizeof(XFNT_INFO);
	vdipb.intin[0] = flags;
	vdipb.intin[1] = id;
	vdipb.intin[2] = index;
	*((XFNT_INFO **)(&vdipb.intin[3])) = info;
	vdipb.contrl[0] = 229;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 5;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	return vdipb.intout[1];
}

int vst_charmap(int handle, int mode)
{
	vdipb.intin[0] = mode;
	vdipb.intin[1] = 1;
	vdipb.contrl[0] = 236;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	return (int)vdipb.intout[0];
}

void vst_kern(int handle, int tmode, int pmode, int *tracks, int *pairs)
{
	vdipb.intin[0] = tmode;
	vdipb.intin[1] = pmode;
	vdipb.contrl[0] = 237;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*tracks = vdipb.intout[0];
	*pairs = vdipb.intout[1];
}

int vst_name(int handle, int font_format, char *font_name, char *ret_name)
{
	short	i;

	vdipb.intin[0] = font_format;
	i = vdi_str2array(font_name, vdipb.intin+1);
	vdipb.contrl[0] = 230;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = i;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	vdi_array2str(vdipb.intout, ret_name, vdipb.contrl[4]);
	return vdipb.intout[0];
}

void vst_track_offset(int handle, long offset, int pairmode, int *tracks, int *pairs)
{
	vdipb.intin[0] = 255;
	vdipb.intin[1] = pairmode;
	*((long *)(&vdipb.intin[2])) = offset;
	vdipb.contrl[0] = 237;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*tracks = vdipb.intout[0];
	*pairs  = vdipb.intout[1];
}

void vst_width(int handle, int width, int *char_width, int *char_height, int *cell_width, int *cell_height)
{
	vdipb.ptsin[0] = width;
	vdipb.contrl[0] = 231;
	vdipb.contrl[1] = 1;
	vdipb.contrl[3] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	*char_width  = vdipb.ptsout[0];
	*char_height = vdipb.ptsout[1];
	*cell_width  = vdipb.ptsout[2];
	*cell_height = vdipb.ptsout[3];
}



/*
 * The following functions requires NVDI version 4.x or higher
*/
int vqt_char_index(int handle, int scr_index, int scr_mode, int dst_mode)
{
	vdipb.intin[0] = scr_index;
	vdipb.intin[1] = scr_mode;
	vdipb.intin[2] = dst_mode;
	vdipb.contrl[0] = 190;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 3;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	return vdipb.intout[0];
}


/*
 * The following functions requires NVDI version 5.x or higher
*/
long v_color2nearest(int handle, long color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *color;

	vdipb.contrl[0] = 204;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*nearest_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

unsigned long v_color2value(int handle, long color_space, COLOR_ENTRY *color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *color;

	vdipb.contrl[0] = 204;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(unsigned long*)&vdipb.intout[0]);
}

COLOR_TAB *v_create_ctab(int handle, long color_space, unsigned long px_format)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(unsigned long *) &vdipb.intin[2] = px_format;

	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 4;
	vdipb.contrl[5] = 8;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(COLOR_TAB **) &vdipb.intout[0]);							
}

ITAB_REF	v_create_itab( int handle, COLOR_TAB *ctab, int bits )
{
	*(COLOR_TAB **) &vdipb.intin[0] = ctab;
	vdipb.intin[2] = bits;
	vdipb.intin[3] = 0;
	vdipb.intin[4] = 0;

	vdipb.contrl[0] = 208;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 5;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(ITAB_REF *) &vdipb.intout[0]);
}

unsigned long	v_ctab_idx2value( int handle, int index )
{
	vdipb.intin[0] = index;

	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 5;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(unsigned long *) &vdipb.intout[0]);								
}

int v_ctab_idx2vdi(int handle, int index)
{
	vdipb.intin[0] = index;
	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int v_ctab_vdi2idx(int handle, int index)
{
	vdipb.intin[0] = index;

	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];													
}

int v_delete_ctab(int handle, COLOR_TAB *ctab)
{
	*(COLOR_TAB **) &vdipb.intin[0] = ctab;

	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 9;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int v_delete_itab(int handle, ITAB_REF itab)
{
	*(ITAB_REF *) &vdipb.intin[0] = itab;

	vdipb.contrl[0] = 208;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

long v_get_ctab_id(int handle)
{
	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 6;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(long *) &vdipb.intout[0]);
}

int v_get_outline(int handle, int index, int x_offset, int y_offset, short *pts, char *flags, int max_pts)
{
	vdipb.intin[0] = index;
	vdipb.intin[1] = max_pts;
	*(short **) &vdipb.intin[2] = pts;
	*(char **) &vdipb.intin[4] = flags;
	vdipb.intin[6] = x_offset;
	vdipb.intin[7] = y_offset;

	vdipb.contrl[0] = 243;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 8;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int v_open_bm(int base_handle, GCBITMAP *bitmap, int color_flags, int unit_flags, int pixel_width, int pixel_height)
{
	vdipb.intin[0] = color_flags;
	vdipb.intin[1] = unit_flags;
	vdipb.intin[2] = pixel_width;
	vdipb.intin[3] = pixel_height;

	vdipb.contrl[0] = 100;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 4;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = base_handle;
	*(GCBITMAP **) &vdipb.contrl[7] = bitmap;
	vdi( &vdipb);

	return vdipb.contrl[6];
}

int v_opnprn(int aes_handle, PRN_SETTINGS *settings, int work_out[])
{
	register int	i;

	vdipb.intin[0] = (int)settings->driver_id;
	for(i = 1; i < 10; i++)
		vdipb.intin[i] = 1;
	vdipb.intin[10] = 2;
	vdipb.intin[11] = (int)settings->size_id;

	*(char **)&vdipb.intin[12] = settings->device;
	*(PRN_SETTINGS **)&vdipb.intin[14] = settings;

#ifdef __MSHORT___
	vdipb.params.intout = &work_out[0];
	vdipb.params.ptsout = &work_out[45];
#endif

	vdipb.contrl[0] = 1;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 16;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = aes_handle;
	vdi( &vdipb);

#ifdef __MSHORT___
	vdipb.params.intout = (void *)&vdipb.intout[0];
	vdipb.params.ptsout = (void *)&vdipb.ptsout[0];
#else
	for (i = 0; i<45; i++)
		work_out[i] = vdipb.intout[i];
	for (i = 0; i<12; i++)
		work_out[i+45] = vdipb.ptsout[i];
#endif
	return vdipb.contrl[6];
}

int v_resize_bm(int handle, int width, int height, long byte_width, unsigned char *addr)
{
	vdipb.intin[0] = width;
	vdipb.intin[1] = height;
	*(long *) &vdipb.intin[2] = byte_width;
	*(unsigned char **) &vdipb.intin[4] = addr;

	vdipb.contrl[0] = 100;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
	return vdipb.intout[0];
}

void v_setrgb(int handle, int type, int r, int g, int b)
{
	vdipb.intin[0] = r;
	vdipb.intin[1] = g;
	vdipb.intin[2] = b;

	vdipb.contrl[0] = 138;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 3;
	vdipb.contrl[5] = type;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
}

long v_value2color(int handle, unsigned long value, COLOR_ENTRY *color)
{
	*(unsigned long *)&vdipb.intin[0] = value;
	vdipb.contrl[0] = 204;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

int vq_ctab(int handle, long ctab_length, COLOR_TAB *ctab)
{
	*(long *) &vdipb.intin[0] = ctab_length;
	vdipb.intout = (int *)ctab;
	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	vdipb.intout = vdipb.intout;

	if (vdipb.contrl[4])
		return 1;
	else
		return 0;
}

long vq_ctab_entry(int handle, int index, COLOR_ENTRY *color)
{
	vdipb.intin[0] = index;

	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vq_ctab_id(int handle)
{
	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return (*(long*) &vdipb.intout[0]);
}

int vq_dflt_ctab(int handle, long ctab_length, COLOR_TAB *ctab)
{
	*(long *) &vdipb.intin[0] = ctab_length;								
	vdipb.intout = (int *)ctab;										
	
	vdipb.contrl[0] = 206;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[5] = 7;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	vdipb.intout = vdipb.intout;									

	if (vdipb.contrl[4])
		return 1;
	else
		return 0;
}

long vq_hilite_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdipb.contrl[0] = 209;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb );

	*hilite_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return( *(long *) vdipb.intout );
}

int vq_margins(int handle, int *top_margin, int *bottom_margin, int *left_margin, int *right_margin, int *hdpi, int *vdpi)
{
	vdipb.intout[0] = 0;
	
	vdipb.contrl[0] = 5;	 
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2100;
	vdipb.contrl[6] = handle;	
	vdi( &vdipb);
	
	*top_margin = vdipb.intout[1];											
	*bottom_margin = vdipb.intout[2];										
	*left_margin = vdipb.intout[3];											
	*right_margin = vdipb.intout[4];											
	*hdpi = vdipb.intout[5];													
	*vdpi = vdipb.intout[6];													

	return vdipb.intout[0];
}

long vq_max_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdipb.contrl[0] = 209;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb );

	*hilite_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return( *(long *) vdipb.intout );
}

long vq_min_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdipb.contrl[0] = 209;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb );

	*hilite_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return( *(long *) vdipb.intout );
}

long vq_prn_scaling(int handle)
{
	vdipb.intin[0] = -1;
	vdipb.intin[1] = -1;

	vdipb.contrl[0] = 5;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 2;
	vdipb.contrl[4] = 0;
	vdipb.contrl[5] = 39;
	vdipb.contrl[6] = handle;

	vdi( &vdipb);
	
	if (vdipb.contrl[4] == 2)												
		return (*(long *) vdipb.intout);
	else
		return -1L;
}

long vq_px_format(int handle, unsigned long *px_format)
{
	vdi( &vdipb );
	vdipb.contrl[0] = 204;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;

	*px_format = *(unsigned long *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vq_weight_color(int handle, COLOR_ENTRY *hilite_color)
{
	vdipb.contrl[0] = 209;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb );

	*hilite_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return( *(long *) vdipb.intout );
}

long vqf_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 203;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqf_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 202;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vql_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 203;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vql_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 202;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqm_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 203;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqm_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 202;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqr_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 203;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqr_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 202;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqt_bg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 203;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

long vqt_fg_color(int handle, COLOR_ENTRY *fg_color)
{
	vdipb.contrl[0] = 202;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	*fg_color = *(COLOR_ENTRY *) &vdipb.intout[2];
	return (*(long*) &vdipb.intout[0]);
}

void vr_transfer_bits(int handle, GCBITMAP *src_bm, GCBITMAP *dst_bm, int *src_rect, int *dst_rect, int mode)
{
	vdipb.intin[0] = mode;
	vdipb.intin[1] = 0;
	vdipb.intin[2] = 0;
	vdipb.intin[3] = 0;

	vdipb.ptsin[0] = src_rect[0];
	vdipb.ptsin[1] = src_rect[1];
	vdipb.ptsin[2] = src_rect[2];
	vdipb.ptsin[3] = src_rect[3];

	vdipb.ptsin[4] = dst_rect[0];
	vdipb.ptsin[5] = dst_rect[1];
	vdipb.ptsin[6] = dst_rect[2];
	vdipb.ptsin[7] = dst_rect[3];

	*(GCBITMAP **) &vdipb.contrl[7] = src_bm;
	*(GCBITMAP **) &vdipb.contrl[9] = dst_bm;
	*(GCBITMAP **) &vdipb.contrl[11] = 0L;
	
	vdipb.contrl[0] = 170;
	vdipb.contrl[1] = 4;
	vdipb.contrl[3] = 4;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);
}

int vs_ctab(int handle, COLOR_TAB *ctab)
{
	vdipb.intin = (int *)ctab;

	vdipb.contrl[0] = 205;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = (short)(ctab->length / 2);
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	vdipb.intin = vdipb.intin;

	return (vdipb.intout[0]);
}

int vs_ctab_entry(int handle, int index, long color_space, COLOR_ENTRY *color)
{
	vdipb.intin[0] = index;
	*(long *) &vdipb.intin[1] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[3] = *color;

	vdipb.contrl[0] = 205;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 7;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb );

	return vdipb.intout[0];
}

int vs_dflt_ctab(int handle)
{
	vdipb.contrl[0] = 205;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 0;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vs_document_info(int vdi_handle, int type, char *s, int wchar)
{
	int	cnt;

	vdipb.intout[0] = 0;
	vdipb.intin[0] = type;
	if (wchar)
	{
		/* 16bit strings not yet supported! */
		return 0;
	}
	else
		cnt = vdi_str2array(s, vdipb.intin+1);

	vdipb.contrl[0] = 5;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 1 + cnt;
	vdipb.contrl[5] = 2103;
	vdipb.contrl[6] = vdi_handle;
	vdi( &vdipb);
	return vdipb.intout[0];
}

int vs_hilite_color(int handle, long color_space, COLOR_ENTRY *hilite_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *hilite_color;

	vdipb.contrl[0] = 207;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vs_max_color(int handle, long color_space, COLOR_ENTRY *min_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *min_color;

	vdipb.contrl[0] = 207;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vs_min_color(int handle, long color_space, COLOR_ENTRY *min_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *min_color;

	vdipb.contrl[0] = 207;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vs_weight_color(int handle, long color_space, COLOR_ENTRY *weight_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *weight_color;

	vdipb.contrl[0] = 207;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsf_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *bg_color;

	vdipb.contrl[0] = 201;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi(&vdipb );

	return vdipb.intout[0];
}

int vsf_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *fg_color;

	vdipb.contrl[0] = 200;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 1;
	vdipb.contrl[6] = handle;
	vdi(&vdipb);

	return vdipb.intout[0];
}

int vsl_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{

	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *bg_color;

	vdipb.contrl[0] = 201;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsl_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{

	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *fg_color;

	vdipb.contrl[0] = 200;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 2;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsm_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *bg_color;

	vdipb.contrl[0] = 201;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsm_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *fg_color;

	vdipb.contrl[0] = 200;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 3;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsr_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *bg_color;

	vdipb.contrl[0] = 201;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vsr_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *) &vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *) &vdipb.intin[2] = *fg_color;

	vdipb.contrl[0] = 200;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 4;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vst_bg_color(int handle, long color_space, COLOR_ENTRY *bg_color)
{
	*(long *)&vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *)&vdipb.intin[2] = *bg_color;

	vdipb.contrl[0] = 201;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}

int vst_fg_color(int handle, long color_space, COLOR_ENTRY *fg_color)
{
	*(long *)&vdipb.intin[0] = color_space;
	*(COLOR_ENTRY *)&vdipb.intin[2] = *fg_color;

	vdipb.contrl[0] = 200;
	vdipb.contrl[1] = 0;
	vdipb.contrl[3] = 6;
	vdipb.contrl[5] = 0;
	vdipb.contrl[6] = handle;
	vdi( &vdipb);

	return vdipb.intout[0];
}
