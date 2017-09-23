/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - EDIT-Bibliothek kompatibel zu PureC							*/
/*								(scrollbare Edit-Felder in MagiC)							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>
#include <StdArg.H>

/******************************************************************************/
/*																										*/
/* AES 210:	edit_create																			*/
/*																										*/
/******************************************************************************/

XEDITINFO *edit_create( void )
{
	return mt_edit_create(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 211:	edit_open																			*/
/*																										*/
/******************************************************************************/

int16 edit_open( OBJECT *tree, const int16 obj )
{
	return mt_edit_open(tree, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 212:	edit_open																			*/
/*																										*/
/******************************************************************************/

void edit_close( OBJECT *tree, const int16 obj )
{
	mt_edit_close(tree, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 213:	edit_delete																			*/
/*																										*/
/******************************************************************************/

void edit_delete( XEDITINFO *editinfo )
{
	mt_edit_delete(editinfo, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 214:	edit_cursor																			*/
/*																										*/
/******************************************************************************/

int16 edit_cursor( OBJECT *tree, const int16 obj, const int16 whdl, const int16 show )
{
	return mt_edit_cursor(tree, obj, whdl, show, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 215:	edit_evnt																			*/
/*																										*/
/******************************************************************************/

int16 edit_evnt( OBJECT *tree, const int16 obj, const int16 whdl,
				EVNT *events, int32 *errcode )
{
	return mt_edit_evnt(tree, obj, whdl, events, errcode, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 0:	edit_get_buf																	*/
/*																										*/
/******************************************************************************/

int16 edit_get_buf( OBJECT *tree, const int16 obj, char **buffer,
				int32 *buflen, int32 *txtlen )
{
	return mt_edit_get_buf(tree, obj, buffer, buflen, txtlen, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 1:	edit_get_format																*/
/*																										*/
/******************************************************************************/

int16 edit_get_format( OBJECT *tree, const int16 obj, int16 *tabwidth, int16 *autowrap )
{
	return mt_edit_get_format(tree, obj, tabwidth, autowrap, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 2:	edit_get_colour																*/
/*																										*/
/******************************************************************************/

int16 edit_get_colour( OBJECT *tree, const int16 obj, int16 *tcolour, int16 *bcolour )
{
	return mt_edit_get_colour(tree, obj, tcolour, bcolour, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 2:	edit_get_color - ein Schreibfeher in der MagiC-Dokumentation?	*/
/*																										*/
/******************************************************************************/

int16 edit_get_color( OBJECT *tree, const int16 obj, int16 *tcolor, int16 *bcolor )
{
	return mt_edit_get_colour(tree, obj, tcolor, bcolor, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 3:	edit_get_font																	*/
/*																										*/
/******************************************************************************/

int16 edit_get_font( OBJECT *tree, const int16 obj, int16 *fontID, int16 *fontH,
				boolean *fontPix, boolean *mono )
{
	return mt_edit_get_font(tree, obj, fontID, fontH, fontPix, mono, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 4:	edit_get_cursor																*/
/*																										*/
/******************************************************************************/

int16 edit_get_cursor( OBJECT *tree, const int16 obj, char **cursorpos )
{
	return mt_edit_get_cursor(tree, obj, cursorpos, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 5:	edit_get_pos																	*/
/*																										*/
/******************************************************************************/

void edit_get_pos( OBJECT *tree, const int16 obj, int16 *xscroll, int32 *yscroll,
				char **cyscroll, char **cursorpos, int16 *cx, int16 *cy )
{
	mt_edit_get_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 7:	edit_get_cursor																*/
/*																										*/
/******************************************************************************/

boolean edit_get_dirty( OBJECT *tree, const int16 obj )
{
	return mt_edit_get_dirty(tree, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 8:	edit_get_sel																	*/
/*																										*/
/******************************************************************************/

void edit_get_sel( OBJECT *tree, const int16 obj, char **bsel, char **esel )
{
	mt_edit_get_sel(tree, obj, bsel, esel, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 216, 9:	edit_get_scrollinfo															*/
/*																										*/
/******************************************************************************/

void edit_get_scrollinfo( OBJECT *tree, const int16 obj, int32 *nlines, int32 *yscroll,
				int16 *yvis, int16 *yval, int16 *ncols, int16 *xscroll, int16 *xvis )
{
	mt_edit_get_scrollinfo(tree, obj, nlines, yscroll, yvis, yval, ncols, xscroll,
					xvis, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 0:	edit_set_buf																	*/
/*																										*/
/******************************************************************************/

void edit_set_buf( OBJECT *tree, const int16 obj, char *buffer, const int32 buflen )
{
	mt_edit_set_buf(tree, obj, buffer, buflen, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 1:	edit_set_format																*/
/*																										*/
/******************************************************************************/

void edit_set_format( OBJECT *tree, const int16 obj, const int16 tabwidth,
				const int16 autowrap )
{
	mt_edit_set_format(tree, obj, tabwidth, autowrap, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 2:	edit_set_colour																*/
/*																										*/
/******************************************************************************/

void edit_set_colour( OBJECT *tree, const int16 obj, const int16 tcolour,
				const int16 bcolour )
{
	mt_edit_set_colour(tree, obj, tcolour, bcolour, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 2:	edit_set_color - ein Schreibfeher in der MagiC-Dokumentation?	*/
/*																										*/
/******************************************************************************/

void edit_set_color( OBJECT *tree, const int16 obj, const int16 tcolor, const int16 bcolor )
{
	mt_edit_set_colour(tree, obj, tcolor, bcolor, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 3:	edit_set_font																	*/
/*																										*/
/******************************************************************************/

void edit_set_font( OBJECT *tree, const int16 obj, const int16 fontID, const int16 fontH,
				const int16 fontPix, const int16 mono )
{
	mt_edit_set_font(tree, obj, fontID, fontH, fontPix, mono, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 4:	edit_set_cursor																	*/
/*																										*/
/******************************************************************************/

void edit_set_cursor( OBJECT *tree, const int16 obj, char *cursorpos )
{
	mt_edit_set_cursor(tree, obj, cursorpos, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 4:	edit_set_cursor																	*/
/*																										*/
/******************************************************************************/

void edit_set_pos( OBJECT *tree, const int16 obj, const int16 xscroll,
				const int32 yscroll, char *cyscroll, char *cursorpos, const int16 cx,
				const int16 cy )
{
	mt_edit_set_pos(tree, obj, xscroll, yscroll, cyscroll, cursorpos, cx, cy, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 6:	edit_resized																	*/
/*																										*/
/******************************************************************************/

int16 edit_resized( OBJECT *tree, const int16 obj, int16 *oldrh, int16 *newrh )
{
	return mt_edit_resized(tree, obj, oldrh, newrh, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 7:	edit_set_dirty																	*/
/*																										*/
/******************************************************************************/

void edit_set_dirty( OBJECT *tree, const int16 obj, const boolean dirty )
{
	mt_edit_set_dirty(tree, obj, dirty, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 217, 9:	edit_scroll																		*/
/*																										*/
/******************************************************************************/

int16 edit_scroll( OBJECT *tree, const int16 obj, const int16 whdl, const int32 yscroll,
				const int16 xscroll )
{
	return mt_edit_scroll(tree, obj, whdl, yscroll, xscroll, _globl);
}
