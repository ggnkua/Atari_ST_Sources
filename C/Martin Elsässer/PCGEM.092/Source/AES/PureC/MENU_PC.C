/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - MENU-Bibliothek kompatibel zu PureC							*/
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
/* AES 30:	menu_bar																				*/
/*																										*/
/******************************************************************************/

int16 menu_bar( OBJECT *tree, const int16 show )
{
	return mt_menu_bar(tree, show, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 31:	menu_icheck																			*/
/*																										*/
/******************************************************************************/

int16 menu_icheck( OBJECT *tree, const int16 item, const int16 check )
{
	return mt_menu_icheck(tree, item, check, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 32:	menu_ienable																		*/
/*																										*/
/******************************************************************************/

int16 menu_ienable( OBJECT *tree, const int16 item, const int16 enable )
{
	return mt_menu_ienable(tree, item, enable, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 33:	menu_tnormal																		*/
/*																										*/
/******************************************************************************/

int16 menu_tnormal( OBJECT *tree, const int16 title, const int16 normal )
{
	return mt_menu_tnormal(tree, title, normal, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 34:	menu_text																			*/
/*																										*/
/******************************************************************************/

int16 menu_text( OBJECT *tree, const int16 item, char *text )
{
	return mt_menu_text(tree, item, text, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 35:	menu_register																		*/
/*																										*/
/******************************************************************************/

int16 menu_register( const int16 apid, char *string )
{
	return mt_menu_register(apid, string, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 36:	menu_unregister																	*/
/*																										*/
/******************************************************************************/

int16 menu_unregister( const int16 apid )
{
	return mt_menu_unregister(apid, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 37:	menu_click																			*/
/*																										*/
/******************************************************************************/

int16 menu_click( const int16 click, const int16 setit )
{
	return mt_menu_click(click, setit, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 37:	menu_attach																			*/
/*																										*/
/******************************************************************************/

int16 menu_attach( const int16 flag, OBJECT *tree, const int16 item, MENU *mdata )
{
	return mt_menu_attach(flag, tree, item, mdata, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 38:	menu_istart																			*/
/*																										*/
/******************************************************************************/

int16 menu_istart( const int16 flag, OBJECT *tree, const int16 imenu, const int16 item )
{
	return mt_menu_istart(flag, tree, imenu, item, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 36:	menu_popup																			*/
/*																										*/
/******************************************************************************/

int16 menu_popup( MENU *menu, const int16 xpos, const int16 ypos, MENU *mdata )
{
	return mt_menu_popup(menu, xpos, ypos, mdata, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 39:	menu_settings																		*/
/*																										*/
/******************************************************************************/

int16 menu_settings( const int16 flag, MN_SET *set )
{
	return mt_menu_settings(flag, set, _globl);
}
