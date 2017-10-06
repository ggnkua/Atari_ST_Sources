/*
 * Aes font selection library interface (MagiC/WDIALOG only)
 * modified: ol -- olivier.landemarre.free.fr
 */
#include "mgemx.h"


int mt_fnts_add(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={185,1,1,2,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 0;
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)user_fonts;

	aes(&aes_params);
	return aes_intout[0];
}

int fnts_add(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts)
{
	return(mt_fnts_add(fnt_dialog, user_fonts, aes_global));
}

int mt_fnts_close(FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={183,0,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)fnt_dialog;
	aes_intout[1] = -1;			/* ab 6: Position kommt zurÅck */
	aes_intout[2] = -1;

	aes(&aes_params);
	*x = aes_intout[1];
	*y = aes_intout[2];
	return aes_intout[0];
}

int fnts_close(FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y)
{
	return(mt_fnts_close(fnt_dialog, x, y, aes_global));
}

FNT_DIALOG *mt_fnts_create(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={180,4,0,4,1};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = vdi_handle;
	aes_intin[1] = no_fonts;
	aes_intin[2] = font_flags;
	aes_intin[3] = dialog_flags;
	aes_addrin[0] = (long)sample;
	aes_addrin[1] = (long)opt_button;

	aes(&aes_params);

	return (FNT_DIALOG*)aes_addrout[0];
}

FNT_DIALOG *fnts_create(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button)
{
	return(mt_fnts_create(vdi_handle, no_fonts, font_flags, dialog_flags, sample, opt_button, aes_global));
}

int mt_fnts_delete(FNT_DIALOG *fnt_dialog, int vdi_handle, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={181,1,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = vdi_handle;
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int fnts_delete(FNT_DIALOG *fnt_dialog, int vdi_handle)
{
	return(mt_fnts_delete(fnt_dialog, vdi_handle, aes_global));
}

int mt_fnts_do(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, 
				long ratio_in, INT16 *check_boxes, long *id, long *pt, long *ratio, INT16 *global_aes)
{
	unsigned INT16 *i;
 	static INT16 	aes_control[AES_CTRLMAX]={187,7,8,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */


	aes_intin[0] = button_flags;
	i = (unsigned INT16 *)&id_in;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	i = (unsigned INT16 *)&pt_in;
	aes_intin[3] = i[0];
	aes_intin[4] = i[1];
	i = (unsigned INT16 *)&ratio_in;
	aes_intin[5] = i[0];
	aes_intin[6] = i[1];
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	*check_boxes = aes_intout[1];
	*id = ((long)aes_intout[2] << 16) | (aes_intout[3]);
	*pt = ((long)aes_intout[4] << 16) | (aes_intout[5]);
	*ratio = ((long)aes_intout[6] << 16) | (aes_intout[7]);
	return aes_intout[0];
}

int fnts_do(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, 
				long ratio_in, INT16 *check_boxes, long *id, long *pt, long *ratio)
{
	return(mt_fnts_do(fnt_dialog, button_flags, id_in, pt_in, ratio_in, check_boxes, id, pt, ratio, aes_global));
}

int mt_fnts_evnt(FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button, INT16 *check_boxes, long *id, long *pt, long *ratio, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={186,0,9,2,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)events;

	aes(&aes_params);

	*button = aes_intout[1];
	*check_boxes = aes_intout[2];
	*id = ((long)aes_intout[3] << 16) | (aes_intout[4]);
	*pt = ((long)aes_intout[5] << 16) | (aes_intout[6]);
	*ratio = ((long)aes_intout[7] << 16) | (aes_intout[8]);
	return aes_intout[0];
}

int fnts_evnt(FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button, INT16 *check_boxes, long *id, long *pt, long *ratio)
{
	return(mt_fnts_evnt(fnt_dialog, events, button, check_boxes, id, pt, ratio, aes_global));
}

int mt_fnts_get_info(FNT_DIALOG *fnt_dialog, long id, INT16 *mono, INT16 *outline, INT16 *global_aes)
{
	unsigned INT16 *i;
	static INT16 	aes_control[AES_CTRLMAX]={184,3,3,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 3;
	i = (unsigned INT16 *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	*mono = aes_intout[1];
	*outline = aes_intout[2];
	return aes_intout[0];
}

int fnts_get_info(FNT_DIALOG *fnt_dialog, long id, INT16 *mono, INT16 *outline)
{
	return(mt_fnts_get_info(fnt_dialog, id, mono, outline, aes_global));
}

int mt_fnts_get_name(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name, INT16 *global_aes)
{
	unsigned INT16 *i;
	static INT16 	aes_control[AES_CTRLMAX]={184,3,1,4,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 2;
	i = (unsigned INT16 *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;
	aes_addrin[1] = (long)full_name;
	aes_addrin[2] = (long)family_name;
	aes_addrin[3] = (long)style_name;

	aes(&aes_params);

	return aes_intout[0];
}

int fnts_get_name(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name)
{
	return(mt_fnts_get_name(fnt_dialog, id, full_name, family_name, style_name, aes_global));
}

int mt_fnts_get_no_styles(FNT_DIALOG *fnt_dialog, long id, INT16 *global_aes)
{
	unsigned INT16 *i;
	static INT16 	aes_control[AES_CTRLMAX]={184,3,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 0;
	i = (unsigned INT16 *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int fnts_get_no_styles(FNT_DIALOG *fnt_dialog, long id)
{
	return(mt_fnts_get_no_styles(fnt_dialog, id, aes_global));
}

long mt_fnts_get_style(FNT_DIALOG *fnt_dialog, long id, int index, INT16 *global_aes)
{
	unsigned INT16 *i;
	static INT16 	aes_control[AES_CTRLMAX]={184,4,2,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 1;
	i = (unsigned INT16 *)&id;
	aes_intin[1] = i[0];
	aes_intin[2] = i[1];
	aes_intin[3] = index;
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	i = (unsigned INT16 *)&aes_intout[0];
	return *(long *)i;
}

long fnts_get_style(FNT_DIALOG *fnt_dialog, long id, int index)
{
	return(mt_fnts_get_style(fnt_dialog, id, index, aes_global));
}

int mt_fnts_open(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio, INT16 *global_aes)
{
	unsigned INT16 *i;
	static INT16 	aes_control[AES_CTRLMAX]={182,9,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = button_flags;
	aes_intin[1] = x;
	aes_intin[2] = y;
	i = (unsigned INT16 *)&id;
	aes_intin[3] = i[0];
	aes_intin[4] = i[1];
	i = (unsigned INT16 *)&pt;
	aes_intin[5] = i[0];
	aes_intin[6] = i[1];
	i = (unsigned INT16 *)&ratio;
	aes_intin[7] = i[0];
	aes_intin[8] = i[1];
	aes_addrin[0] = (long)fnt_dialog;

   aes(&aes_params);

	return aes_intout[0];
}

int fnts_open(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio)
{
	return(mt_fnts_open(fnt_dialog, button_flags, x, y, id, pt, ratio, aes_global));
}

void mt_fnts_remove(FNT_DIALOG *fnt_dialog, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={185,1,0,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_intin[0] = 1;

	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);
}

void fnts_remove(FNT_DIALOG *fnt_dialog)
{
	mt_fnts_remove(fnt_dialog, aes_global);
}

int mt_fnts_update(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio, INT16 *global_aes)
{
	unsigned INT16 *i;
 	static INT16 	aes_control[AES_CTRLMAX]={185,8,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */


	aes_intin[0] = 2;
	aes_intin[1] = button_flags;
	i = (unsigned INT16 *)&id;
	aes_intin[2] = i[0];
	aes_intin[3] = i[1];
	i = (unsigned INT16 *)&pt;
	aes_intin[4] = i[0];
	aes_intin[5] = i[1];
	i = (unsigned INT16 *)&ratio;
	aes_intin[6] = i[0];
	aes_intin[7] = i[1];
	aes_addrin[0] = (long)fnt_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int fnts_update(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio)
{
	return(mt_fnts_update(fnt_dialog, button_flags, id, pt, ratio, aes_global));
}
