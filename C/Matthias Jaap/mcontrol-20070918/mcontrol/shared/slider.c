/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<types2b.h>
#include <cflib.h>
#include <mt_aes.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include "slider.h"
#include "rect.h"

#ifndef min
#define min(a, b)             ((a) < (b) ? (a) : (b))
#endif

#ifndef max
#define max(a, b)             ((a) > (b) ? (a) : (b))
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* function definitions																							*/
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
/* changes object state and redraws it, if needed														*/
/* return:		-																									*/
/*----------------------------------------------------------------------------------------*/
void	wdset_state( WDIALOG *wd, int16 obj, int16 state, int16 set )
{
	int16 already = get_state( wd->tree, obj, state );
	set_state( wd->tree, obj, state, set );

	if( (set && !already) || (!set && already) )
		redraw_wdobj( wd, obj );
}


/*----------------------------------------------------------------------------------------*/
/* intialize slider																			 					*/
/* return:		0 (always)																						*/
/*----------------------------------------------------------------------------------------*/
int16	sld_create( SLD *slider, WDIALOG *wd, int16 up, int16 down, int16 back, int16 white, SLIDE_SCB scroll )
{
	slider->wd = wd;
	slider->up = up;
	slider->down = down;
	slider->back = back;
	slider->white = white;
	slider->scroll = scroll;

	slider->pos_old = -1;
	sld_setpos( slider, 0 );
	
	slider->size_old = -2;
	sld_setsize( slider, 1000 );

	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* scroll function for arrow buttons													 					*/
/* return:		-																									*/
/*----------------------------------------------------------------------------------------*/
void	sld_arrow( SLD *slider, int16 scroll, int16 val )
{
	EVNTDATA	ev;
	GRECT		rect;
	int16		pos;

	switch( scroll )
	{
	case  SCROLL_LINE:
		wdset_state( slider->wd, ( val < 0 ? slider->up : slider->down ), SELECTED, TRUE );
		break;
	case	SCROLL_PAGE:
		graf_mkstate( &ev );
		objc_rect( slider->wd->tree, slider->white, &rect );
		if( !val ) /* new */
			val = ev.y < rect.g_y ? -1 : 1;
		break;
	}

	do
	{
		pos = slider->scroll( slider->wd, scroll, val );
		sld_setpos( slider, pos );
		sld_redraw( slider );
		graf_mkstate( &ev );
		evnt_timer(20);
	} while ( ev.bstate & 0x01 );

	wdset_state( slider->wd, ( val < 0 ? slider->up : slider->down ), SELECTED, FALSE );
}


/*----------------------------------------------------------------------------------------*/
/* live scroll function																							*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	sld_lscroll( SLD *sld )
{
	OBJECT	*tree = sld->wd->tree;
	EVNTDATA	ev;
	GRECT 	rect1;
	GRECT 	rect2;
	GRECT		rect3;
	int16		newy = 0;
	int16		oldy = 0;
	int16		mmin, mmax;

	graf_mkstate( &ev );

	newy = oldy = ev.y;

	objc_rect( tree, sld->white, &rect1 );
	objc_rect( tree, sld->back, &rect2 );

	mmin = oldy - tree[sld->white].ob_y;
	mmax = oldy + (tree[sld->back].ob_height - tree[sld->white].ob_y - tree[sld->white].ob_height);

	graf_mouse( FLAT_HAND, NULL );

	do
	{
		objc_rect( tree, sld->white, &rect2 );
		tree[sld->white].ob_y += ( newy-oldy );
		objc_rect( tree, sld->white, &rect1 );
		
		rect3.g_x = rect1.g_x;
		rect3.g_y = min( rect1.g_y, rect2.g_y );
		rect3.g_w = rect1.g_w;
		rect3.g_h = (( (newy-oldy) < 0 ) ? -(newy-oldy) : (newy-oldy) ) + rect1.g_h;
		
		if(newy-oldy != 0)
		{
			hide_mouse();
			if( gl_naes )
			{
				rect3.g_x-=2;
				rect3.g_y-=2;
				rect3.g_w+=4;
				rect3.g_h+=4;
			}
			
			objc_draw( tree, sld->back, MAX_DEPTH, &rect3 );
			sld->pos_old = sld->pos_new = sld_getpos(sld);
			
     		if( sld->scroll )
            sld->scroll( sld->wd, SCROLL_LIVE, sld->pos_new );
			
			show_mouse();
		}

		graf_mkstate( &ev );
		oldy = newy;
		newy = min( mmax, ev.y );
		newy = max( mmin, newy );
		evnt_timer(20);
	} while ( ev.bstate & 0x01 );
	
	graf_mouse( ARROW, NULL );
}


/*----------------------------------------------------------------------------------------*/
/* handles mouse actions in slider														 					*/
/* return:		TRUE if obj is a part of the slider, else FALSE										*/
/*----------------------------------------------------------------------------------------*/
int16	sld_event( SLD *slider, int16 obj )
{
	int16 ret = TRUE;

	if( obj == slider->up )
	{
		sld_arrow( slider, SCROLL_LINE, -1 );
	}
	else if( obj == slider->down )
	{
		sld_arrow( slider, SCROLL_LINE, 1 );
	}
	else if( obj == slider->back )
	{
		sld_arrow( slider, SCROLL_PAGE, 0 );
	}
	else if( obj == slider->white )
	{
		sld_lscroll( slider );
	}
	else
		ret = FALSE;

	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* redraw function for a slider															 					*/
/* return:		TRUE a redraw was needed, else FALSE													*/
/*----------------------------------------------------------------------------------------*/
int16	sld_redraw( SLD *slider )
{
	int16 ret;
	
	if( ( slider->pos_old != slider->pos_new ) || ( slider->size_old != slider->size_new ) )
	{
		redraw_wdobj( slider->wd, slider->back );
		ret = TRUE;
	}
	else
		ret = FALSE;
		
	slider->pos_old = slider->pos_new;
	slider->size_old = slider->size_new;
	
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* sets the slider size																		 					*/
/* return:		size in pixel																					*/
/*----------------------------------------------------------------------------------------*/
int16	sld_setsize( SLD *slider, int16 size )
{
	OBJECT	*tree = slider->wd->tree;
	int16		height;

	size = min( size, 1000 );

	if( size >= 0 )
	{
		height = (int16)( (int32)size * (int32)(tree[slider->back].ob_height) / 1000l );
		height = max( 18, height );
	}
	else if( size == -1 )
		height = 16;
	else
		return -2;

	tree[slider->white].ob_height	= height;
	slider->size_new = size;
	sld_setpos( slider, -1 );			/* maybe a new position is needed */

	return height;
}


/*----------------------------------------------------------------------------------------*/
/* gets the slider size																		 					*/
/* return:		size in pixel																					*/
/*----------------------------------------------------------------------------------------*/
int16	sld_getsize( SLD *slider )
{
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* sets the slider position																					*/
/* return:		position in pixel																				*/
/*----------------------------------------------------------------------------------------*/
int16	sld_setpos( SLD *slider, int16 pos )
{
	OBJECT	*tree = slider->wd->tree;
	int16		posx;

	if( pos >= 0 && pos <= 1000 )
		slider->pos_new = pos;
	else
		pos = slider->pos_new;

	posx = (int16)( (int32)pos * (int32)(tree[slider->back].ob_height - tree[slider->white].ob_height) / 1000l );
	tree[slider->white].ob_y = posx;

	return posx;
}


/*----------------------------------------------------------------------------------------*/
/* gets the slider position																					*/
/* return:		position in pixel																				*/
/*----------------------------------------------------------------------------------------*/
int16	sld_getpos( SLD *slider )
{
	OBJECT	*tree = slider->wd->tree;
	int16 	pos;

	pos = (int16)(1000l * (int32)tree[slider->white].ob_y / (int32)(max(1, tree[slider->back].ob_height - tree[slider->white].ob_height)) );

	return pos;
}


/*----------------------------------------------------------------------------------------*/ 
/* scroll handling for any object																			*/
/* return:		-																									*/
/*----------------------------------------------------------------------------------------*/
int16	objc_scroll( OBJECT *tree, int16 vdihandle, int16 obj, int16 whdl, int32 yscroll, int16 xscroll, int16 ydraw )
{
	MFDB		s, d;
	GRECT		r, w, obr;
	int16		xy[8];
	int16		ca[8];
	int16		dy;
	boolean	draw;

	draw = FALSE;
	wind_get_grect( whdl, WF_FIRSTXYWH, &r );
	wind_get_grect( whdl, WF_WORKXYWH, &w );
	objc_rect( tree, obj, &obr );

	if( !rc_intersect( &obr, &r ) || !rc_intersect( &gl_desk, &r ) )
		return 0;

	if( r.g_w != obr.g_w || r.g_h != obr.g_h )
		draw = TRUE;

	if( labs(yscroll) >= (int32)obr.g_h || abs(xscroll) >= obr.g_w )
		draw = TRUE;

	if( !draw )
	{
		grect_to_array( &r, xy );						/* Quelle fÅr vro_cpyfm */
		grect_to_array( &w, ca );						/* Array fÅr clipping */
		xy[4] = xy[0];										/* Ziel fÅr vro_cpyfm */
		xy[5] = xy[1];
		xy[6] = xy[2];
		xy[7] = xy[3];

		if( xscroll )										/* Horizontales Scrolling */
		{
			if( xscroll > 0 )								/* Links Scrolling */
			{
				xy[0] += (int16) xscroll;
				xy[6] -= (int16) xscroll;

				r.g_x += r.g_w - (int16)xscroll;		/* Rechter Bereich nicht gescrollt, */
				r.g_w  = (int16)xscroll;				/* muû neu gezeichnet werden */
			}
			else												/* Rechts Scrolling */
			{
				xy[2] += (int16)xscroll;
				xy[4] -= (int16)xscroll;

				r.g_w = (int16)(-xscroll);				/* Linken Bereich noch neu zeichnen */
			}
		}
	
		dy = (int16)yscroll;
		dy = -dy;
	
		if( dy )												/* Vertikales Scrolling */
		{
			if( dy > 0 )									/* AufwÑrts Scrolling */
			{
				xy[1] += (int16)dy;						/* Werte fÅr vro_cpyfm */
				xy[7] -= (int16)dy;

				r.g_y += r.g_h - (int16)dy - ydraw;	/* Unterer Bereich nicht gescrollt, */
				r.g_h  = (int16)dy + ydraw;			/* muû neu gezeichnet werden */
			}
			else												/* AbwÑrts Scrolling */
			{
				xy[3] += (int16)dy;						/* Werte fÅr vro_cpyfm */
				xy[5] -= (int16)dy;

				r.g_h = (int)(-dy) + ydraw;			/* Oberen Bereich noch neu zeichnen */
			}
		}
		s.fd_addr = d.fd_addr = NULL;					/* Erzwinge Bildschirmadresse */
		vs_clip( vdihandle, 1, ca );
		hide_mouse();
		vro_cpyfm(vdihandle, S_ONLY, xy, &s, &d);
		show_mouse();
		objc_draw( tree, 0, MAX_DEPTH, &r );
	}

	return !draw;
}