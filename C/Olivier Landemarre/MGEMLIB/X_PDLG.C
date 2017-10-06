/*
 * Aes printer configuration dialogs (WDIALOG only)
 * modified: ol -- olivier.landemarre.free.fr
 *
 */
#include "mgemx.h"


int mt_pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)drv_info;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info)
{
	return(mt_pdlg_add_printers(prn_dialog, drv_info, aes_global));
}

int mt_pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)sub_dialogs;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs)
{
	return(mt_pdlg_add_sub_dialogs(prn_dialog, sub_dialogs,aes_global));
}

int mt_pdlg_close(PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={203,0,3,1,0};
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

	aes_intout[1] = -1;
	aes_intout[2] = -1;
	aes_addrin[0] = (long)prn_dialog;

	aes(&aes_params);

	*x = aes_intout[1];
	*y = aes_intout[2];
	return aes_intout[0];
}

int pdlg_close(PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y)
{
	return(mt_pdlg_close(prn_dialog, x, y, aes_global));
}

PRN_DIALOG*	mt_pdlg_create(int dialog_flags, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={200,1,0,0,1};
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

	aes_intin[0] = dialog_flags;

	aes(&aes_params);

	return (void *)aes_addrout[0];
}

PRN_DIALOG*	pdlg_create(int dialog_flags)
{
	return(mt_pdlg_create(dialog_flags, aes_global));
}

int mt_pdlg_delete(PRN_DIALOG *prn_dialog, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={201,0,1,1,0};
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

	aes_addrin[0] = (long)prn_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_delete(PRN_DIALOG *prn_dialog)
{
	return(mt_pdlg_delete(prn_dialog, aes_global));
}

int mt_pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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

	aes_intin[0] = 7;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	return(mt_pdlg_dflt_settings(prn_dialog, settings, aes_global));
}

int mt_pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={207,1,1,3,0};
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

	aes_intin[0] = option_flags;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[3] = (long)document_name;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags)
{
	return(mt_pdlg_do(prn_dialog, settings, document_name, option_flags, aes_global));
}

int mt_pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, INT16 *button, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={206,0,2,3,0};
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

	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[2] = (long)events;

	aes(&aes_params);

	*button = aes_intout[1];
	return aes_intout[0];
}

int pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, INT16 *button)
{
	return(mt_pdlg_evnt(prn_dialog, settings, events, button, aes_global));
}

int mt_pdlg_free_settings(PRN_SETTINGS *settings, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,1,0};
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

	aes_intin[0] = 6;
	aes_addrin[0] = (long)settings;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_free_settings(PRN_SETTINGS *settings)
{
	return(mt_pdlg_free_settings(settings, aes_global));
}

long mt_pdlg_get_setsize(INT16 *global_aes)
{
	long	l;
	static INT16 	aes_control[AES_CTRLMAX]={204,1,2,0,0};
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

	aes(&aes_params);

	l = *(long *)&aes_intout[0];
	return l;
}

long pdlg_get_setsize(void)
{
	return(mt_pdlg_get_setsize(aes_global));
}

PRN_SETTINGS* mt_pdlg_new_settings(PRN_DIALOG *prn_dialog, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,0,1,1};
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

	aes_intin[0] = 5;
	aes_addrin[0] = (long)prn_dialog;

	aes(&aes_params);
	return (PRN_SETTINGS*)aes_addrout[0];
}

PRN_SETTINGS* pdlg_new_settings(PRN_DIALOG *prn_dialog)
{
	return(mt_pdlg_new_settings(prn_dialog, aes_global));
}


int mt_pdlg_open(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={202,3,1,3,0};
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

	aes_intin[0] = option_flags;
	aes_intin[1] = x;
	aes_intin[2] = y;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[2] = (long)document_name;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_open(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y)
{
	return(mt_pdlg_open(prn_dialog, settings, document_name, option_flags, x, y, aes_global));
}

int mt_pdlg_remove_printers(PRN_DIALOG *prn_dialog, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,1,0};
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
	aes_addrin[0] = (long)prn_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_remove_printers(PRN_DIALOG *prn_dialog)
{
	return(mt_pdlg_remove_printers(prn_dialog, aes_global));
}

int mt_pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,1,0};
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

	aes_intin[0] = 4;
	aes_addrin[0] = (long)prn_dialog;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog)
{
	return(mt_pdlg_remove_sub_dialogs(prn_dialog, aes_global));
}

int mt_pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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

	aes_intin[0] = 10;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	return(mt_pdlg_save_default_settings(prn_dialog, settings, aes_global));
}


int mt_pdlg_update(PRN_DIALOG *prn_dialog, char *document_name, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,3,0};
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
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = 0L;
	aes_addrin[2] = (long)document_name;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_update(PRN_DIALOG *prn_dialog, char *document_name)
{
	return(mt_pdlg_update(prn_dialog, document_name, aes_global));
}

int mt_pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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

	aes_intin[0] = 9;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	return(mt_pdlg_use_settings(prn_dialog,settings, aes_global));
}

int mt_pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={205,1,1,2,0};
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

	aes_intin[0] = 8;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;

	aes(&aes_params);

	return aes_intout[0];
}

int pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	return(mt_pdlg_validate_settings(prn_dialog, settings, aes_global));
}
