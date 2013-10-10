/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - WDLG-Bibliothek kompatibel zu PureC							*/
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
/* AES 160:	wdlg_create																			*/
/*																										*/
/******************************************************************************/

DIALOG *wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data,
				const int16 code, void *data, const int16 flags )
{
	return mt_wdlg_create(handle_exit, tree, user_data, code, data, flags, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 161:	wdlg_open																			*/
/*																										*/
/******************************************************************************/

int16	wdlg_open( DIALOG *dialog, char *title, const int16 kind, const int16 x,
				const int16 y, const int16 code, void *data )
{
	return mt_wdlg_open(dialog, title, kind, x, y, code, data, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 162:	wdlg_close																			*/
/*																										*/
/******************************************************************************/

int16 wdlg_close( DIALOG *dialog, int16 *x, int16 *y )
{
	return mt_wdlg_close(dialog, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 163:	wdlg_delete																			*/
/*																										*/
/******************************************************************************/

int16 wdlg_delete( DIALOG *dialog )
{
	return mt_wdlg_delete(dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 164, 0:	wdlg_get_tree																	*/
/*																										*/
/******************************************************************************/

int16 wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *rect )
{
	return mt_wdlg_get_tree(dialog, tree, rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 164, 1:	wdlg_get_edit																	*/
/*																										*/
/******************************************************************************/

int16 wdlg_get_edit( DIALOG *dialog, int16 *cursor )
{
	return mt_wdlg_get_edit(dialog, cursor, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 164, 2:	wdlg_get_udata																	*/
/*																										*/
/******************************************************************************/

void *wdlg_get_udata( DIALOG *dialog )
{
	return mt_wdlg_get_udata(dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 164, 3:	wdlg_get_handle																*/
/*																										*/
/******************************************************************************/

int16 wdlg_get_handle( DIALOG *dialog )
{
	return mt_wdlg_get_handle(dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 165, 0:	wdlg_set_edit																	*/
/*																										*/
/******************************************************************************/

int16 wdlg_set_edit( DIALOG *dialog, const int16 obj )
{
	return mt_wdlg_set_edit(dialog, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 165, 1:	wdlg_set_tree																	*/
/*																										*/
/******************************************************************************/

int16 wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree )
{
	return mt_wdlg_set_tree(dialog, new_tree, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 165, 2:	wdlg_set_size																	*/
/*																										*/
/******************************************************************************/

int16 wdlg_set_size( DIALOG *dialog, GRECT *new_size )
{
	return mt_wdlg_set_size(dialog, new_size, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 165, 3:	wdlg_set_iconify																*/
/*																										*/
/******************************************************************************/

int16 wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, const int16 obj )
{
	return mt_wdlg_set_iconify(dialog, g, title, tree, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 165, 4:	wdlg_set_uniconify															*/
/*																										*/
/******************************************************************************/

int16 wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree )
{
	return mt_wdlg_set_uniconify(dialog, g, title, tree, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 166:	wdlg_evnt																			*/
/*																										*/
/******************************************************************************/

int16 wdlg_evnt( DIALOG *dialog, EVNT *events )
{
	return mt_wdlg_evnt(dialog, events, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 167:	wdlg_redraw																			*/
/*																										*/
/******************************************************************************/

void wdlg_redraw( DIALOG *dialog, GRECT *rect, const int16 obj, const int16 depth )
{
	mt_wdlg_redraw(dialog, rect, obj, depth, _globl);
}
