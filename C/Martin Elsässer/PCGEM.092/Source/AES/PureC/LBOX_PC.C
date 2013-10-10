/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - LBOX-Bibliothek kompatibel zu PureC							*/
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
/* AES 175:	lbox_ascroll_to																	*/
/*																										*/
/******************************************************************************/

void lbox_ascroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect )
{
	mt_lbox_ascroll_to(box, first, box_rect, slider_rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_scroll_to																		*/
/*																										*/
/******************************************************************************/

void lbox_scroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect )
{
	mt_lbox_scroll_to(box, first, box_rect, slider_rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_bscroll_to																	*/
/*																										*/
/******************************************************************************/

void lbox_bscroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, GRECT *slider_rect )
{
	mt_lbox_bscroll_to(box, first, box_rect, slider_rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_cnt_items																		*/
/*																										*/
/******************************************************************************/

int16 lbox_cnt_items( LIST_BOX *box )
{
	return mt_lbox_cnt_items(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 170:	lbox_create																			*/
/*																										*/
/******************************************************************************/

LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items,
				const int16 visible_a, const int16 first_a, const int16 *ctrl_objs,
				const int16 *objs, const int16 flags, const int16 pause_a, void *user_data,
				DIALOG *dialog, const int16 visible_b, const int16 first_b, const int16 entries_b,
				const int16 pause_b )
{
	return mt_lbox_create(tree, slct, set, items, visible_a, first_a, ctrl_objs, objs, flags,
		pause_a, user_data, dialog, visible_b, first_b, entries_b, pause_b, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 173:	lbox_delete																			*/
/*																										*/
/******************************************************************************/

int16 lbox_delete( LIST_BOX *box )
{
	return mt_lbox_delete(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 172:	lbox_do																				*/
/*																										*/
/******************************************************************************/

int16 lbox_do( LIST_BOX *box, const int16 obj )
{
	return mt_lbox_do(box, obj, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_items																	*/
/*																										*/
/******************************************************************************/

void lbox_free_items( LIST_BOX *box )
{
	mt_lbox_free_items(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_free_list																		*/
/*																										*/
/******************************************************************************/

void lbox_free_list( LBOX_ITEM *items )
{
	mt_lbox_free_list(items, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_afirst																	*/
/*																										*/
/******************************************************************************/

int16 lbox_get_afirst( LIST_BOX *box )
{
	return mt_lbox_get_afirst(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_first																		*/
/*																										*/
/******************************************************************************/

int16 lbox_get_first( LIST_BOX *box )
{
	return mt_lbox_get_first(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_avis																		*/
/*																										*/
/******************************************************************************/

int16 lbox_get_avis( LIST_BOX *box )
{
	return mt_lbox_get_avis(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_visible																	*/
/*																										*/
/******************************************************************************/

int16 lbox_get_visible( LIST_BOX *box )
{
	return mt_lbox_get_visible(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bentries																	*/
/*																										*/
/******************************************************************************/

int16 lbox_get_bentries( LIST_BOX *box )
{
	return mt_lbox_get_bentries(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bfirst																	*/
/*																										*/
/******************************************************************************/

int16 lbox_get_bfirst( LIST_BOX *box )
{
	return mt_lbox_get_bfirst(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_bvis																		*/
/*																										*/
/******************************************************************************/

int16 lbox_get_bvis( LIST_BOX *box )
{
	return mt_lbox_get_bvis(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_idx																		*/
/*																										*/
/******************************************************************************/

int16 lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search )
{
	return mt_lbox_get_idx(items, search, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_item																		*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *lbox_get_item( LIST_BOX *box, const int16 n )
{
	return mt_lbox_get_item(box, n, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_items																		*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *lbox_get_items( LIST_BOX *box )
{
	return mt_lbox_get_items(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_idx																	*/
/*																										*/
/******************************************************************************/

int16 lbox_get_slct_idx( LIST_BOX *box )
{
	return mt_lbox_get_slct_idx(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_slct_item																*/
/*																										*/
/******************************************************************************/

LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box )
{
	return mt_lbox_get_slct_item(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_tree																		*/
/*																										*/
/******************************************************************************/

OBJECT *lbox_get_tree( LIST_BOX *box )
{
	return mt_lbox_get_tree(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 174:	lbox_get_udata																		*/
/*																										*/
/******************************************************************************/

void *lbox_get_udata( LIST_BOX *box )
{
	return mt_lbox_get_udata(box, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_asldr																		*/
/*																										*/
/******************************************************************************/

void lbox_set_asldr( LIST_BOX *box, const int16 first, GRECT *rect )
{
	mt_lbox_set_asldr(box, first, rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_slider																		*/
/*																										*/
/******************************************************************************/

void lbox_set_slider( LIST_BOX *box, const int16 first, GRECT *rect )
{
	mt_lbox_set_slider(box, first, rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bentries																	*/
/*																										*/
/******************************************************************************/

void lbox_set_bentries( LIST_BOX *box, const int16 entries )
{
	mt_lbox_set_bentries(box, entries, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_bsldr																		*/
/*																										*/
/******************************************************************************/

void lbox_set_bsldr( LIST_BOX *box, const int16 first, GRECT *rect )
{
	mt_lbox_set_bsldr(box, first, rect, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 175:	lbox_set_items																		*/
/*																										*/
/******************************************************************************/

void lbox_set_items( LIST_BOX *box, LBOX_ITEM *items )
{
	mt_lbox_set_items(box, items, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 171:	lbox_update																			*/
/*																										*/
/******************************************************************************/

void lbox_update( LIST_BOX *box, GRECT *rect )
{
	mt_lbox_update(box, rect, _globl);
}
