/* FILE: XFORM_DO.C
 *==========================================================================
 * DATE: 890123 kbad
 *       900208 cgee
 * DESCRIPTION: Enhanded Form_do() Handler
 *       920415 cgee - modified for setup.prg
 * 
 * INCLUDE FILE: XFORM_DO.H
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>
#include <dos.h>
#include <osbind.h>

#include "gemskel.h"
#include "handlers.h"

 
/* DEFINE
 *==========================================================================
 */
#define AP_TERM    50		/* New termination AES message */


/* PROTOTYPES
 *==========================================================================
 */


/* ENUMERATIONS
 *==========================================================================
 */
typedef enum {
	NODIR=-1,
	FORWARD,
	BACKWARD,
	DEFAULTDIR
} DIRS;


/* GLOBALS
 *==========================================================================
 */
WORD      msg[8];				/* mesag buffer           */
GRECT	  XRect;				/* rectangle for redraw   */

BOOLEAN	cursor = FALSE;				/* TRUE - Cursor is ON!
						 * for editable text fields
						 */




/* ................................................................
 * Find the previous, next, or default object in tree, based on
 * `direction'.
 */
static WORD
find_obj( OBJECT *tree, WORD startob, DIRS direction )
{
	WORD	obj, searchflag, curflag, inc;

	obj = 0;
	searchflag = EDITABLE;
	inc = 1;

	switch( direction ) {

		case BACKWARD:
			inc = -1;
			obj = startob + inc;
			break;

		case FORWARD:
			if( !(ObFlags(startob) & LASTOB) )
				obj = startob + inc;
			else
				obj = -1;
			break;

		case DEFAULTDIR:
			searchflag = DEFAULT;
			break;
	}

	while( obj >= 0 ) {
		curflag = ObFlags(obj);

		if( searchflag & curflag )
			return obj;

		if( curflag & LASTOB )
			obj = -1;
		else
			obj += inc;
	}
	return startob;
}


/* ................................................................
 * Handle button clicks on object `obj' in form `tree'.
 * Set `pobj' to 0 if editable, or
 *	|= 0x8000 if double clicked TOUCHEXIT.
 * Return FALSE if `obj' was an exit object, else TRUE to continue.
 */
BOOLEAN
fm_button( OBJECT *tree, WORD obj, WORD clicks, WORD *pobj )
{
	WORD	state, flags, parent, tobj;
	BOOLEAN	cont;
	MRETS	m;

	cont = TRUE;
	flags = ObFlags(obj);
	state = ObState(obj);

	if( flags & TOUCHEXIT ) /* don't wait for button up */
		cont = FALSE;

	/*
	 * SELECTABLE
	 * Handle it, and wait for button up, if it's not TOUCHEXIT
	 */
	if( (flags & SELECTABLE) &&
		!(state & DISABLED) ) {

		/*
		 * Radio button, turn off the currently selected button,
		 * by finding a selected child of obj's parent.
		 * In the mean time, select obj.
		 * NOTE: this assumes that obj is NOT the root object!
		 */
		if( flags & RBUTTON ) {

			parent = obj;
			do {
				tobj = parent;
				parent = ObNext(tobj);
			} while( ObTail(parent) != tobj );

			for(	tobj = ObHead(parent);
					tobj != parent;
					tobj = ObNext(tobj) ) {

				state = ObState(tobj);
				if( (ObFlags(tobj) & RBUTTON) &&
				    ( (state & SELECTED) || (tobj == obj) ) )
				{
				   if( tobj == obj )
					state |= SELECTED;
				   else
					state &= ~SELECTED;
				   objc_change( tree, tobj, 0, gl_work.g_x,
						gl_work.g_y, gl_work.g_w,
						gl_work.g_h, state, TRUE );
				}
			}

		} else { /* not an RBUTTON */
			graf_watchbox( tree, obj, state^SELECTED, state );

		}

		if( cont && (flags & (SELECTABLE|EDITABLE)) )
			evnt_button( 1, 1, 0, &m.x, &m.y, &m.buttons, &m.kstate );

	} /* SELECTABLE */

	/*
	 * Now, find out if we're outta here,
	 * if editable field was clicked, or
	 * if a touchexit was doubleclicked
	 */
	if( IsSelected(obj) && (flags & EXIT) )
		cont = FALSE;
	if( cont && !( flags & EDITABLE ) )
		obj = 0;
	if( (flags & TOUCHEXIT) && (clicks == 2) )
		obj |= 0x8000;


	*pobj = obj;
	return cont;
}


/*
 * return TRUE if the extent of `obj' lies entirely within w.work
 */
BOOLEAN
can_edit( OBJECT *tree, WORD obj )
{
	GRECT	r;
	WORD	xy[4];
	int	top_window;
	int	dummy;
	
	wind_get( wid, WF_TOP, &top_window, &dummy, &dummy, &dummy );
	if( wid == top_window )
	{
	  r = ObRect(obj);
	  objc_offset( tree, obj, &r.g_x, &r.g_y );
	  rc_2xy( &r, xy );
	  return ( xy_inrect( xy[0], xy[1], &gl_work ) &&
			xy_inrect( xy[2], xy[3], &gl_work ) );
	}
	else
	  return( FALSE );		
}



/* ................................................................
 * Handle user interaction with a form in open window `w'.
 *
 * Initial conditions are as follows:
 * w->x is the address of the form.
 * window is open, with appropriate WINFO rects & coordinates set
 * form is drawn within window, at correct virtual coordinates
 * ROOT object of form has correct x,y coordinates
 *
 * This routine works just like form_do, but dispatches window
 * events, redrawing and fixing up the object tree as appropriate,
 * and maintaining the various rects and coordinates in the WINFO struct.
 *
 * Returns exit object selected, |= 0x8000 if double clicked a TOUCHEXIT,
 * OR -1 if a message was received which couldn't be handled.
 * In the latter case, the `puntmsg' array is filled with the message buffer
 * which xform_do() couldn't handle, and the application is responsible for
 * picking up where xform_do() left off.  A cop-out, I know.
 *
 * NOTE: form_dial( FMD_START,... ) and form_dial( FMD_FINISH,... )
 *		should NOT be used with xform_do().
 *
 * User defined objects could cause problems with this routine, as
 * the boundary of the object may lie outside the window coordinates.
 * Caveat programmer.
 */
WORD
xform_do( OBJECT *tree, WORD start_field, WORD puntmsg[] )
{
	WORD	next_obj, edit_obj, idx;
	BOOLEAN	cont, doedit;
	WORD	event;
	MRETS	m;
	WORD	key, clicks;
	DIRS	direction; /* form_keybd */
	GRECT	rect;
		
	/*
	 * Get the next editable object
	 */
	if( start_field == 0 )
		next_obj = find_obj( tree, 0, FORWARD );
	else
		next_obj = start_field;

	edit_obj = 0;
	cont = TRUE;
	
	cursor = FALSE;
	
	while( cont ) {

		/*
		 * Put the cursor in the edit field
		 * Note: This is skipped if there is only one field.
		 */
		if( (next_obj != 0) && (edit_obj != next_obj) )
		{
			edit_obj = next_obj;
			next_obj = 0;
			doedit = can_edit( tree, edit_obj );
			if( doedit && !cursor )
			{
				objc_edit( tree, edit_obj, 0, (int *)&idx, ED_INIT );
				cursor = TRUE;
			}	
		}

/*		wind_update( FALSE );	*/
		/*
		 * Wait...
		 */
	         event = evnt_multi( MU_MESAG | MU_KEYBD | MU_BUTTON,
				     2, 1, 1,
				     0, 0, 0, 0, 0,
				     0, 0, 0, 0, 0,
				     msg,
				     0, 0,
				     &m.x, &m.y,
				     &m.buttons,
				     &m.kstate, &key, &clicks );
	
/*		wind_update( TRUE );	*/

		wind_update( BEG_UPDATE );

		if( event & MU_MESAG ) {
			switch( msg[0] ) {
				case AP_TERM:   wind_update( END_UPDATE );
						Gem_Exit( 0 );
						break;

				case WM_TOPPED:
						wind_set( wid, WF_TOP );
						doedit = can_edit( tree, edit_obj );
					        if( doedit && !cursor )
					        {
					           objc_edit( tree, edit_obj, 0, (int *)&idx, ED_INIT );
						   cursor = TRUE;
					        }
						break;
						
				case WM_MOVED:	/* if moving, that means we are on top, therefore, cursor is already on */
						doedit = can_edit( tree, edit_obj );
						if( !doedit )
							cursor = FALSE;
				case WM_REDRAW:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				/* redraw 'n' shit */
#if 1
				        if( doedit )
					  objc_edit( tree, edit_obj, 0, (int*)&idx, ED_END );
#endif

#if 0						
					if( edit_obj && ( msg[0] == WM_REDRAW ))
					{

					    NoEdit( edit_obj );
					    rect = ObRect( edit_obj );
					    objc_offset( tree, edit_obj, &rect.g_x, &rect.g_y );

					    /* The offsets will take care of the blinking cursor
					     * area that needs to be redraw to erase it.
					     */
					    rect.g_y -= 3;
					    rect.g_w += 3;
					    rect.g_h += 6;

					    /* Clip the rectangle to the work area of the form.*/
					    rc_intersect( &gl_work, &rect ); 

/* The redraw is necessary to turn off the blinking cursor.
 * We are going to need to send a redraw message to the calling
 * cpx in case they have any custom redraws that need to be done.
 */

						
					    Do_Redraw( ad_tree, &rect );
				    
					    if( msg[0] == WM_REDRAW )
					    {	
					       for( idx = 0; idx < 8; idx++ )
						   puntmsg[idx] = msg[idx];
					    }

					}

#endif

					/* Here we redraw/move the area that is dirtied */    
					do_window( (int *)msg, (int *)&event );
#if 0
					if( edit_obj )
					    MakeEditable( edit_obj );
#endif
					doedit = can_edit( tree, edit_obj );
					if( !doedit )
						cursor = FALSE;
					if( msg[0] == WM_REDRAW )
					{	
					   for( idx = 0; idx < 8; idx++ )
						   puntmsg[idx] = msg[idx];
					   wind_update( END_UPDATE );
					   return( -1 );
					}
				break;

				default:
					for( idx = 0; idx < 8; idx++ )
						puntmsg[idx] = msg[idx];
					wind_update( END_UPDATE );
					return( -1 );
					/* Need to look for close window*/
			}
		}


/*
 * What about hot keys?? AIEEE!!
 */
		if( event & MU_KEYBD ) {

			/*
			 * form_keybd() encapsulated here
			 */
			direction = NODIR;
			switch( key ) {

				case K_RETURN:
				case K_ENTER:
					next_obj = 0;
					direction = DEFAULTDIR;
					break;

				case K_BACKTAB:
				case K_UP:
					direction = BACKWARD;
					break;

				case K_TAB:
				case K_DOWN:
					direction = FORWARD;
					break;
			}

			if( direction != NODIR )
			{
				key = 0;
				next_obj = find_obj( tree, edit_obj, direction );
				if( (direction == DEFAULTDIR) && (next_obj != 0) )
				{
				  objc_change( tree, next_obj, 0, gl_work.g_x,
				               gl_work.g_y, gl_work.g_w, gl_work.g_h,
				               ObState(next_obj)|SELECTED, TRUE );

				  cont = FALSE;
				}
			}
			/*
			 * End of form_keybd()
			 */

			/* The above code clears 'key', therefore, we'll
			 * check key FIRST, then test the ASCII and 
			 * scancode
			 */
			if( key && ( !( key & 0xff ) )  )
			{
			  if( ( key != K_UP     )  &&
			      ( key != K_DOWN   )  &&
			      ( key != K_RIGHT  )  &&
			      ( key != K_LEFT   )  &&
			      ( key != K_RETURN )  &&
			      ( key != K_ENTER  )  &&
			      ( key != K_TAB )	   &&
			      ( key != K_BACKTAB)
			    )
			    {
			      puntmsg[0] = CT_KEY;
			      puntmsg[3] = key;
			      wind_update( END_UPDATE );   
			      return( -1 );
			    }  
			}

			if( key && doedit )
				objc_edit( tree, edit_obj, key, (int *)&idx, ED_CHAR );
		}

		if( event & MU_BUTTON ) {
			next_obj = objc_find( tree, ROOT, MAX_DEPTH, m.x, m.y );
			if( next_obj == NIL )
			{
			     Bconout( 2, 7 );
			     next_obj = 0;
			} else {
				cont = fm_button( tree, next_obj, clicks, &next_obj );
			}
		}

		if(  doedit && (!cont || (next_obj != 0)) && ( next_obj != edit_obj) )
		{
		   objc_edit( tree, edit_obj, 0, (int *)&idx, ED_END );
		   cursor = FALSE;
		}   		

	   wind_update( END_UPDATE );
	}

	return next_obj;
}





