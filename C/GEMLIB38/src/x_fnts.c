/*
 * Aes font selection library interface (MagiC/WDIALOG only)
 */
#include "gemx.h"


int fnts_add(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts)
{
	aes_intin[0] = 0;
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)user_fonts;
   aes_control[0] = 185;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

int fnts_close(FNT_DIALOG *fnt_dialog, int *x, int *y)
{
	aes_addrin[0] = (long)fnt_dialog;
	aes_intout[1] = -1;			/* ab 6: Position kommt zurÅck */
	aes_intout[2] = -1;
   aes_control[0] = 183;
   aes_control[1] = 0;
   aes_control[2] = 3;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*x = aes_intout[1];
	*y = aes_intout[2];
	return aes_intout[0];
}

FNT_DIALOG *fnts_create(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button)
{
	aes_intin[0] = vdi_handle;
	aes_intin[1] = no_fonts;
	aes_intin[2] = font_flags;
	aes_intin[3] = dialog_flags;
	aes_addrin[0] = (long)sample;
	aes_addrin[1] = (long)opt_button;
   aes_control[0] = 180;
   aes_control[1] = 4;
   aes_control[2] = 0;
   aes_control[3] = 4;
   aes_control[4] = 1;
   aes(&aes_params);
	return (FNT_DIALOG*)aes_addrout[0];
}

int fnts_delete(FNT_DIALOG *fnt_dialog, int vdi_handle)
{
	aes_intin[0] = vdi_handle;
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 181;
   aes_control[1] = 1;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int fnts_do(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, 
				long ratio_in, int *check_boxes, long *id, long *pt, long *ratio)
{
	unsigned short *i;

	aes_intin[0] = button_flags;
	i = (unsigned short *)&id_in;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	i = (unsigned short *)&pt_in;
	aes_intin[3] = i[0];
	aes_intin[4] = i[1];
	i = (unsigned short *)&ratio_in;
	aes_intin[5] = i[0];
	aes_intin[6] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 187;
   aes_control[1] = 7;
   aes_control[2] = 8;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*check_boxes = aes_intout[1];
	*id = ((long)aes_intout[2] << 16) | (aes_intout[3]);
	*pt = ((long)aes_intout[4] << 16) | (aes_intout[5]);
	*ratio = ((long)aes_intout[6] << 16) | (aes_intout[7]);
	return aes_intout[0];
}

int fnts_evnt(FNT_DIALOG *fnt_dialog, EVNT *events, int *button, int *check_boxes, long *id, long *pt, long *ratio)
{
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)events;
   aes_control[0] = 186;
   aes_control[1] = 0;
   aes_control[2] = 9;
   aes_control[3] = 2;
   aes_control[4] = 0;
   aes(&aes_params);
	*button = aes_intout[1];
	*check_boxes = aes_intout[2];
	*id = ((long)aes_intout[3] << 16) | (aes_intout[4]);
	*pt = ((long)aes_intout[5] << 16) | (aes_intout[6]);
	*ratio = ((long)aes_intout[7] << 16) | (aes_intout[8]);
	return aes_intout[0];
}

int fnts_get_info(FNT_DIALOG *fnt_dialog, long id, int *mono, int *outline)
{
	unsigned short *i;
	
	aes_intin[0] = 3;
	i = (unsigned short *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 184;
   aes_control[1] = 3;
   aes_control[2] = 3;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	*mono = aes_intout[1];
	*outline = aes_intout[2];
	return aes_intout[0];
}

int fnts_get_name(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name)
{
	unsigned short *i;

	aes_intin[0] = 2;
	i = (unsigned short *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)full_name;
	aes_addrin[2] = (long)family_name;
	aes_addrin[3] = (long)style_name;
   aes_control[0] = 184;
   aes_control[1] = 3;
   aes_control[2] = 1;
   aes_control[3] = 4;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

int fnts_get_no_styles(FNT_DIALOG *fnt_dialog, long id)
{
	unsigned short *i;

	aes_intin[0] = 0;
	i = (unsigned short *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 184;
   aes_control[1] = 3;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

long fnts_get_style(FNT_DIALOG *fnt_dialog, long id, int index)
{
	unsigned short *i;

	aes_intin[0] = 1;
	i = (unsigned short *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_intin[3] = index;
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 184;
   aes_control[1] = 4;
   aes_control[2] = 2;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	i = (unsigned short *)&aes_intout[0];
	return *(long *)i;
}

int fnts_open(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio)
{
	unsigned short *i;

	aes_intin[0] = button_flags;
	aes_intin[1] = x;
	aes_intin[2] = y;
	i = (unsigned short *)&id;
	aes_intin[3] = i[0];
	aes_intin[4] = i[1];
	i = (unsigned short *)&pt;
	aes_intin[5] = i[0];
	aes_intin[6] = i[1];
	i = (unsigned short *)&ratio;
	aes_intin[7] = i[0];
	aes_intin[8] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 182;
   aes_control[1] = 9;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}

void fnts_remove(FNT_DIALOG *fnt_dialog)
{
	aes_intin[0] = 1;

	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 185;
   aes_control[1] = 1;
   aes_control[2] = 0;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
}

int fnts_update(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio)
{
	unsigned short *i;

	aes_intin[0] = 2;
	aes_intin[1] = button_flags;
	i = (unsigned short *)&id;
	aes_intin[2] = i[0];
	aes_intin[3] = i[1];
	i = (unsigned short *)&pt;
	aes_intin[4] = i[0];
	aes_intin[5] = i[1];
	i = (unsigned short *)&ratio;
	aes_intin[6] = i[0];
	aes_intin[7] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
   aes_control[0] = 185;
   aes_control[1] = 8;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}
