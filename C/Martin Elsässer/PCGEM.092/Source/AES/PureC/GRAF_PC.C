/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - GRAF-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* AES 70:	graf_rubbox																			*/
/*																										*/
/******************************************************************************/

int16 graf_rubbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end )
{
	return mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 70:	graf_rubberbox - anderer Name fÅr graf_rubbox							*/
/*																										*/
/******************************************************************************/

int16 graf_rubberbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end )
{
	return mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 70:	graf_rubbbox - anderer Name fÅr graf_rubbox								*/
/*																										*/
/******************************************************************************/

int16 graf_rubbbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end )
{
	return mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 71:	graf_dragbox																		*/
/*																										*/
/******************************************************************************/

int16 graf_dragbox( const int16 w, const int16 h, const int16 sx, const int16 sy,
				const int16 xc, const int16 yc, const int16 wc, const int16 hc,
				int16 *x, int16 *y )
{
	return mt_graf_dragbox(w, h, sx, sy, xc, yc, wc, hc, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 72:	graf_mbox																			*/
/*																										*/
/******************************************************************************/

int16 graf_mbox( const int16 w, const int16 h, const int16 start_x, const int16 start_y,
				const int16 ende_x, const int16 ende_y )
{
	return mt_graf_mbox(w, h, start_x, start_y, ende_x, ende_y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 72:	graf_movebox - anderer Name fÅr graf_mbox									*/
/*																										*/
/******************************************************************************/

int16 graf_movebox( const int16 w, const int16 h, const int16 start_x, int16 const start_y,
				const int16 ende_x, const int16 ende_y )
{
	return mt_graf_movebox(w, h, start_x, start_y, ende_x, ende_y, NULL);
}

/******************************************************************************/
/*																										*/
/* AES 73:	graf_growbox																		*/
/*																										*/
/******************************************************************************/

int16 graf_growbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h )
{
	return mt_graf_growbox(start_x, start_y, start_w, start_h,
					ende_x, ende_y, ende_w, ende_h, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 74:	graf_shrinkbox																		*/
/*																										*/
/******************************************************************************/

int16 graf_shrinkbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h )
{
	return mt_graf_shrinkbox(start_x, start_y, start_w, start_h,
					ende_x, ende_y, ende_w, ende_h, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 75:	graf_watchbox																		*/
/*																										*/
/******************************************************************************/

int16 graf_watchbox( OBJECT *tree, const int16 obj_nr, const int16 instate,
				const int16 outstate )
{
	return mt_graf_watchbox(tree, obj_nr, instate, outstate, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 62:	graf_wwatchbox																		*/
/*																										*/
/******************************************************************************/

int16 graf_wwatchbox( const OBJECT *gr_wptree, const int16 gr_wobject,
				const int16 gr_winstate, const int16 gr_woutstate, const int16 whandle )
{
	return mt_graf_wwatchbox(gr_wptree, gr_wobject, gr_winstate,
					gr_woutstate, whandle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 76:	graf_slidebox																		*/
/*																										*/
/******************************************************************************/

int16 graf_slidebox( OBJECT *tree, const int16 parent, const int16 obj_nr,
				const int16 isvert )
{
	return mt_graf_slidebox(tree, parent, obj_nr, isvert, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 77:	graf_handle																			*/
/*																										*/
/******************************************************************************/

int16 graf_handle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox )
{
	return mt_graf_handle(wchar, hchar, wbox, hbox, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 77:	graf_xhandle																		*/
/*																										*/
/******************************************************************************/

int16 graf_xhandle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox, int16 *device )
{
	return mt_graf_xhandle(wchar, hchar, wbox, hbox, device, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 78:	graf_mouse																			*/
/*																										*/
/******************************************************************************/

int16 graf_mouse( const int16 mouse_nr, MFORM *form )
{
	return mt_graf_mouse(mouse_nr, form, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 79:	graf_mkstate																		*/
/*																										*/
/******************************************************************************/

int16 graf_mkstate( int16 *x, int16 *y, int16 *mstate, int16 *kstate )
{
	return mt_graf_mkstate(x, y, mstate, kstate, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 69:	graf_multirubber																	*/
/*																										*/
/******************************************************************************/

int16 graf_multirubber( const int16 x, const int16 y, const int16 minw, const int16 minh,
				GRECT *rec, int16 *outw, int16 *outh )
{
	return mt_graf_multirubber(x, y, minw, minh, rec, outw, outh, _globl);
}
