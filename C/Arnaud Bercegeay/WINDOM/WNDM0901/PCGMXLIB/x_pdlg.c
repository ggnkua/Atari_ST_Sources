/*
 * Aes printer configuration dialogs (WDIALOG only)
 *
 */

#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

int pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info)
{
	aespb.intin[0] = 0;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)drv_info;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs)
{
	aespb.intin[0] = 3;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)sub_dialogs;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_close(PRN_DIALOG *prn_dialog, int *x, int *y)
{
	aespb.intout[1] = -1;
	aespb.intout[2] = -1;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.contrl[0] = 203;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 3;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	*x = aespb.intout[1];
	*y = aespb.intout[2];
	return aespb.intout[0];
}

PRN_DIALOG*	pdlg_create(int dialog_flags)
{
	aespb.intin[0] = dialog_flags;
	aespb.contrl[0] = 200;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 0;
	aespb.contrl[3] = 0;
	aespb.contrl[4] = 1;
	aes( &aespb);
	return (void *)aespb.addrout[0];
}

int pdlg_delete(PRN_DIALOG *prn_dialog)
{
	aespb.addrin[0] = (long)prn_dialog;
	aespb.contrl[0] = 201;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aespb.intin[0] = 7;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags)
{
	aespb.intin[0] = option_flags;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.addrin[3] = (long)document_name;
	aespb.contrl[0] = 207;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 3;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, int *button)
{
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.addrin[2] = (long)events;
	aespb.contrl[0] = 206;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 2;
	aespb.contrl[3] = 3;
	aespb.contrl[4] = 0;
	aes( &aespb);
	*button = aespb.intout[1];
	return aespb.intout[0];
}

int pdlg_free_settings(PRN_SETTINGS *settings)
{
	aespb.intin[0] = 6;
	aespb.addrin[0] = (long)settings;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

long pdlg_get_setsize(void)
{
	long	l;
	
	aespb.intin[0] = 0;
	aespb.contrl[0] = 204;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 2;
	aespb.contrl[3] = 0;
	aespb.contrl[4] = 0;
	aes( &aespb);
	l = *(long *)&aespb.intout[0];
	return l;
}

PRN_SETTINGS* pdlg_new_settings(PRN_DIALOG *prn_dialog)
{
	aespb.intin[0] = 5;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 0;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 1;
	aes( &aespb);
	return (PRN_SETTINGS*)aespb.addrout[0];
}

int pdlg_open(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y)
{
	aespb.intin[0] = option_flags;
	aespb.intin[1] = x;
	aespb.intin[2] = y;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.addrin[2] = (long)document_name;
	aespb.contrl[0] = 202;
	aespb.contrl[1] = 3;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 3;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_remove_printers(PRN_DIALOG *prn_dialog)
{
	aespb.intin[0] = 1;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog)
{
	aespb.intin[0] = 4;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aespb.intin[0] = 10;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_update(PRN_DIALOG *prn_dialog, char *document_name)
{
	aespb.intin[0] = 2;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = 0L;
	aespb.addrin[2] = (long)document_name;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 3;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aespb.intin[0] = 9;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

int pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	aespb.intin[0] = 8;
	aespb.addrin[0] = (long)prn_dialog;
	aespb.addrin[1] = (long)settings;
	aespb.contrl[0] = 205;
	aespb.contrl[1] = 1;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}
