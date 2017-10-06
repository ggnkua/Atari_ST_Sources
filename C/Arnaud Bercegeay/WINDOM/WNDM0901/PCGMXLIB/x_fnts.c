/*
 * Aes font selection library interface (MagiC/WDIALOG only)
 */
#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

int fnts_add(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts) {
    aespb.intin[0] = 0;
	aespb.addrin[0] = (long)fnt_dialog;
	aespb.addrin[1] = (long)user_fonts;
   aespb.contrl[0] = 185;
   aespb.contrl[1] = 1;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 2;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}

int fnts_close(FNT_DIALOG *fnt_dialog, int *x, int *y)
{
	aespb.addrin[0] = (long)fnt_dialog;
	aespb.intout[1] = -1;			/* ab 6: Position kommt zurÅck */
	aespb.intout[2] = -1;
   aespb.contrl[0] = 183;
   aespb.contrl[1] = 0;
   aespb.contrl[2] = 3;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes(&aespb);
	*x = aespb.intout[1];
	*y = aespb.intout[2];
	return aespb.intout[0];
}

FNT_DIALOG *fnts_create(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button)
{
	aespb.intin[0] = vdi_handle;
	aespb.intin[1] = no_fonts;
	aespb.intin[2] = font_flags;
	aespb.intin[3] = dialog_flags;
	aespb.addrin[0] = (long)sample;
	aespb.addrin[1] = (long)opt_button;
   aespb.contrl[0] = 180;
   aespb.contrl[1] = 4;
   aespb.contrl[2] = 0;
   aespb.contrl[3] = 4;
   aespb.contrl[4] = 1;
   aes( &aespb);
	return (FNT_DIALOG*)aespb.addrout[0];
}

int fnts_delete(FNT_DIALOG *fnt_dialog, int vdi_handle)
{
	aespb.intin[0] = vdi_handle;
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 181;
   aespb.contrl[1] = 1;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}


int fnts_do(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, 
				long ratio_in, int *check_boxes, long *id, long *pt, long *ratio)
{
	unsigned short *i;

	aespb.intin[0] = button_flags;
	i = (unsigned short *)&id_in;
	aespb.intin[1] = i[0];
	aespb.intin[2] = i[1];
	i = (unsigned short *)&pt_in;
	aespb.intin[3] = i[0];
	aespb.intin[4] = i[1];
	i = (unsigned short *)&ratio_in;
	aespb.intin[5] = i[0];
	aespb.intin[6] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 187;
   aespb.contrl[1] = 7;
   aespb.contrl[2] = 8;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	*check_boxes = aespb.intout[1];
	*id = ((long)aespb.intout[2] << 16) | (aespb.intout[3]);
	*pt = ((long)aespb.intout[4] << 16) | (aespb.intout[5]);
	*ratio = ((long)aespb.intout[6] << 16) | (aespb.intout[7]);
	return aespb.intout[0];
}

int fnts_evnt(FNT_DIALOG *fnt_dialog, EVNT *events, int *button, int *check_boxes, long *id, long *pt, long *ratio)
{
	aespb.addrin[0] = (long)fnt_dialog;
	aespb.addrin[1] = (long)events;
   aespb.contrl[0] = 186;
   aespb.contrl[1] = 0;
   aespb.contrl[2] = 9;
   aespb.contrl[3] = 2;
   aespb.contrl[4] = 0;
   aes( &aespb);
	*button = aespb.intout[1];
	*check_boxes = aespb.intout[2];
	*id = ((long)aespb.intout[3] << 16) | (aespb.intout[4]);
	*pt = ((long)aespb.intout[5] << 16) | (aespb.intout[6]);
	*ratio = ((long)aespb.intout[7] << 16) | (aespb.intout[8]);
	return aespb.intout[0];
}

int fnts_get_info(FNT_DIALOG *fnt_dialog, long id, int *mono, int *outline)
{
	unsigned short *i;
	
	aespb.intin[0] = 3;
	i = (unsigned short *)&id;
	aespb.intin[1] = i[0];
	aespb.intin[2] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 184;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 3;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	*mono = aespb.intout[1];
	*outline = aespb.intout[2];
	return aespb.intout[0];
}

int fnts_get_name(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name)
{
	unsigned short *i;

	aespb.intin[0] = 2;
	i = (unsigned short *)&id;
	aespb.intin[1] = i[0];
	aespb.intin[2] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
	aespb.addrin[1] = (long)full_name;
	aespb.addrin[2] = (long)family_name;
	aespb.addrin[3] = (long)style_name;
   aespb.contrl[0] = 184;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 4;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}

int fnts_get_no_styles(FNT_DIALOG *fnt_dialog, long id)
{
	unsigned short *i;

	aespb.intin[0] = 0;
	i = (unsigned short *)&id;
	aespb.intin[1] = i[0];
	aespb.intin[2] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 184;
   aespb.contrl[1] = 3;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}

long fnts_get_style(FNT_DIALOG *fnt_dialog, long id, int index)
{
	unsigned short *i;

	aespb.intin[0] = 1;
	i = (unsigned short *)&id;
	aespb.intin[1] = i[0];
	aespb.intin[2] = i[1];
	aespb.intin[3] = index;
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 184;
   aespb.contrl[1] = 4;
   aespb.contrl[2] = 2;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	i = (unsigned short *)&aespb.intout[0];
	return *(long *)i;
}

int fnts_open(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio)
{
	unsigned short *i;

	aespb.intin[0] = button_flags;
	aespb.intin[1] = x;
	aespb.intin[2] = y;
	i = (unsigned short *)&id;
	aespb.intin[3] = i[0];
	aespb.intin[4] = i[1];
	i = (unsigned short *)&pt;
	aespb.intin[5] = i[0];
	aespb.intin[6] = i[1];
	i = (unsigned short *)&ratio;
	aespb.intin[7] = i[0];
	aespb.intin[8] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 182;
   aespb.contrl[1] = 9;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}

void fnts_remove(FNT_DIALOG *fnt_dialog)
{
	aespb.intin[0] = 1;

	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 185;
   aespb.contrl[1] = 1;
   aespb.contrl[2] = 0;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
}

int fnts_update(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio) {
	unsigned short *i;

	aespb.intin[0] = 2;
	aespb.intin[1] = button_flags;
	i = (unsigned short *)&id;
	aespb.intin[2] = i[0];
	aespb.intin[3] = i[1];
	i = (unsigned short *)&pt;
	aespb.intin[4] = i[0];
	aespb.intin[5] = i[1];
	i = (unsigned short *)&ratio;
	aespb.intin[6] = i[0];
	aespb.intin[7] = i[1];
	aespb.addrin[0] = (long)fnt_dialog;
   aespb.contrl[0] = 185;
   aespb.contrl[1] = 8;
   aespb.contrl[2] = 1;
   aespb.contrl[3] = 1;
   aespb.contrl[4] = 0;
   aes( &aespb);
	return aespb.intout[0];
}

