/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - PDLG-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_add_printers																	*/
/*																										*/
/******************************************************************************/

int16 pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info )
{
	return mt_pdlg_add_printers(prn_dialog, drv_info, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_add_sub_dialogs																*/
/*																										*/
/******************************************************************************/

int16 pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog )
{
	return mt_pdlg_add_sub_dialogs(prn_dialog, sub_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 203:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

int16 pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y )
{
	return mt_pdlg_close(prn_dialog, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 200:	pdlg_close																			*/
/*																										*/
/******************************************************************************/

PRN_DIALOG *pdlg_create( const int16 dialog_flags )
{
	return mt_pdlg_create(dialog_flags, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 201:	pdlg_delete																			*/
/*																										*/
/******************************************************************************/

int16 pdlg_delete( PRN_DIALOG *prn_dialog )
{
	return mt_pdlg_delete(prn_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_dflt_settings																*/
/*																										*/
/******************************************************************************/

int16 pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
{
	return mt_pdlg_dflt_settings(prn_dialog, settings, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 207:	pdlg_do																				*/
/*																										*/
/******************************************************************************/

int16 pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags )
{
	return mt_pdlg_do(prn_dialog, settings, document_name, option_flags, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 206:	pdlg_evnt																			*/
/*																										*/
/******************************************************************************/

int16 pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *evnt, int16 *button )
{
	return mt_pdlg_evnt(prn_dialog, settings, evnt, button, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_free_settings																*/
/*																										*/
/******************************************************************************/

int16 pdlg_free_settings( PRN_SETTINGS *settings )
{
	return mt_pdlg_free_settings(settings, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 204:	pdlg_get_setsize																	*/
/*																										*/
/******************************************************************************/

int32 pdlg_get_setsize( void )
{
	return mt_pdlg_get_setsize(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_new_settings																	*/
/*																										*/
/******************************************************************************/

PRN_SETTINGS *pdlg_new_settings( PRN_DIALOG *prn_dialog )
{
	return mt_pdlg_new_settings(prn_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 202:	pdlg_open																			*/
/*																										*/
/******************************************************************************/

int16 pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, const int16 x, const int16 y )
{
	return mt_pdlg_open(prn_dialog, settings, document_name, option_flags, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_printers																*/
/*																										*/
/******************************************************************************/

int16 pdlg_remove_printers( PRN_DIALOG *prn_dialog )
{
	return mt_pdlg_remove_printers(prn_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_remove_sub_dialogs															*/
/*																										*/
/******************************************************************************/

int16 pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog )
{
	return mt_pdlg_remove_sub_dialogs(prn_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_update																			*/
/*																										*/
/******************************************************************************/

int16 pdlg_update( PRN_DIALOG *prn_dialog, char *document_name )
{
	return mt_pdlg_update(prn_dialog, document_name, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_use_settings																	*/
/*																										*/
/******************************************************************************/

int16 pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
{
	return mt_pdlg_use_settings(prn_dialog, settings, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 205:	pdlg_validate_settings															*/
/*																										*/
/******************************************************************************/

int16 pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings )
{
	return mt_pdlg_validate_settings(prn_dialog, settings, _globl);
}
