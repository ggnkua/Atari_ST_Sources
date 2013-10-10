/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - OBJC-Bibliothek kompatibel zu PureC							*/
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
/* AES 40:	objc_add																				*/
/*																										*/
/******************************************************************************/

int16 objc_add( OBJECT *tree, const int16 parent, const int16 child )
{
	return mt_objc_add(tree, parent, child, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 41:	objc_delete																			*/
/*																										*/
/******************************************************************************/

int16 objc_delete( OBJECT *tree, const int16 objnr )
{
	return mt_objc_delete(tree, objnr, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_draw																			*/
/*																										*/
/******************************************************************************/

int16 objc_draw( OBJECT *tree, const int16 start, const int16 depth, const int16 xclip,
				const int16 yclip, const int16 wclip, const int16 hclip )
{
	return mt_objc_draw(tree, start, depth, xclip, yclip, wclip, hclip, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_wdraw																			*/
/*																										*/
/******************************************************************************/

void objc_wdraw( OBJECT *tree, const int16 start, const int16 depth, GRECT *clip,
				const int16 whandle )
{
	mt_objc_wdraw(tree, start, depth, clip, whandle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 43:	objc_find																			*/
/*																										*/
/******************************************************************************/

int16 objc_find( OBJECT *tree, const int16 start, const int16 depth,
				const int16 mx, const int16 my )
{
	return mt_objc_find(tree, start, depth, mx, my, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 44:	objc_offset																			*/
/*																										*/
/******************************************************************************/

int16 objc_offset( OBJECT *tree, const int16 objnr, int16 *x, int16 *y )
{
	return mt_objc_offset(tree, objnr, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 45:	objc_order																			*/
/*																										*/
/******************************************************************************/

int16 objc_order( OBJECT *tree, const int16 objnr, const int16 new_nr )
{
	return mt_objc_order(tree, objnr, new_nr, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_edit																			*/
/*																										*/
/******************************************************************************/

int16 objc_edit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				const int16 kind )
{
	return mt_objc_edit(tree, objnr, inchar, idx, kind, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_xedit																			*/
/*																										*/
/******************************************************************************/

int16 objc_xedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				int16 kind, GRECT *r )
{
	return mt_objc_xedit(tree, objnr, inchar, idx, kind, r, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 65:	objc_wedit																			*/
/*																										*/
/******************************************************************************/

int16 objc_wedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				const int16 kind, const int16 whandle )
{
	return mt_objc_wedit(tree, objnr, inchar, idx, kind, whandle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 47:	objc_change																			*/
/*																										*/
/******************************************************************************/

int16 objc_change( OBJECT *tree, const int16 objnr, const int16 reserved, 
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip,
				const int16 newstate, const int16 redraw )
{
	return mt_objc_change(tree, objnr, reserved,  xclip, yclip, wclip, hclip, newstate,
					redraw, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 47:	objc_wchange																		*/
/*																										*/
/******************************************************************************/

void objc_wchange( OBJECT *tree, const int16 objnr, const int16 newstate,
				GRECT *clip, const int16 whandle )
{
	mt_objc_wchange(tree, objnr, newstate, clip, whandle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 48:	objc_sysvar																			*/
/*																										*/
/******************************************************************************/

int16 objc_sysvar( const int16 mode, const int16 which, const int16 in1, const int16 in2,
				int16 *out1, int16 *out2 )
{
	return mt_objc_sysvar(mode, which, in1, in2, out1, out2, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 49:	objc_xfind																			*/
/*																										*/
/******************************************************************************/

int16 objc_xfind( OBJECT *obj, const int16 start, const int16 depth,
				const int16 x, const int16 y )
{
	return mt_objc_xfind(obj, start, depth, x, y, _globl);
}
