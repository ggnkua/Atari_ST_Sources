/*
 * Aes printer configuration dialogs (WDIALOG only)
 *
 */
#include "gemx.h"


int pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info)
{
	aes_intin[0] = 0;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)drv_info;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs)
{
	aes_intin[0] = 3;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)sub_dialogs;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_close(PRN_DIALOG *prn_dialog, int *x, int *y)
{
	aes_intout[1] = -1;
	aes_intout[2] = -1;
	aes_addrin[0] = (long)prn_dialog;
	aes_control[0] = 203;
	aes_control[1] = 0;
	aes_control[2] = 3;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	*x = aes_intout[1];
	*y = aes_intout[2];
	return aes_intout[0];
}

PRN_DIALOG*	pdlg_create(int dialog_flags)
{
	aes_intin[0] = dialog_flags;
	aes_control[0] = 200;
	aes_control[1] = 1;
	aes_control[2] = 0;
	aes_control[3] = 0;
	aes_control[4] = 1;
	aes(&aes_params);
	return (void *)aes_addrout[0];
}

int pdlg_delete(PRN_DIALOG *prn_dialog)
{
	aes_addrin[0] = (long)prn_dialog;
	aes_control[0] = 201;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aes_intin[0] = 7;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags)
{
	aes_intin[0] = option_flags;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[3] = (long)document_name;
	aes_control[0] = 207;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 3;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, int *button)
{
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[2] = (long)events;
	aes_control[0] = 206;
	aes_control[1] = 0;
	aes_control[2] = 2;
	aes_control[3] = 3;
	aes_control[4] = 0;
	aes(&aes_params);
	*button = aes_intout[1];
	return aes_intout[0];
}

int pdlg_free_settings(PRN_SETTINGS *settings)
{
	aes_intin[0] = 6;
	aes_addrin[0] = (long)settings;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

long pdlg_get_setsize(void)
{
	long	l;
	
	aes_intin[0] = 0;
	aes_control[0] = 204;
	aes_control[1] = 1;
	aes_control[2] = 2;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	l = *(long *)&aes_intout[0];
	return l;
}

PRN_SETTINGS* pdlg_new_settings(PRN_DIALOG *prn_dialog)
{
	aes_intin[0] = 5;
	aes_addrin[0] = (long)prn_dialog;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 0;
	aes_control[3] = 1;
	aes_control[4] = 1;
	aes(&aes_params);
	return (PRN_SETTINGS*)aes_addrout[0];
}

int pdlg_open(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y)
{
	aes_intin[0] = option_flags;
	aes_intin[1] = x;
	aes_intin[2] = y;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_addrin[2] = (long)document_name;
	aes_control[0] = 202;
	aes_control[1] = 3;
	aes_control[2] = 1;
	aes_control[3] = 3;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_remove_printers(PRN_DIALOG *prn_dialog)
{
	aes_intin[0] = 1;
	aes_addrin[0] = (long)prn_dialog;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog)
{
	aes_intin[0] = 4;
	aes_addrin[0] = (long)prn_dialog;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aes_intin[0] = 10;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_update(PRN_DIALOG *prn_dialog, char *document_name)
{
	aes_intin[0] = 2;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = 0L;
	aes_addrin[2] = (long)document_name;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 3;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aes_intin[0] = 9;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

int pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aes_intin[0] = 8;
	aes_addrin[0] = (long)prn_dialog;
	aes_addrin[1] = (long)settings;
	aes_control[0] = 205;
	aes_control[1] = 1;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}
