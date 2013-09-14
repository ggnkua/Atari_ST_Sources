/* xform_do.c - enhanced form_do() handler
 * 890123 kbad
 */

#include <alt\aesalt.h>
#include <sys\vdikeys.h>

void	Bconout( int dev, int c );
void	do_windows( int *msg, int *event );


typedef enum {
	NODIR=-1,
	FORWARD,
	BACKWARD,
	DEFAULTDIR
} DIRS;


/* ................................................................
 * Find the previous, next, or default object in tree, based on
 * `direction'.
 */
static WORD
find_obj( OBJECT *tree, WORD startob, DIRS direction )
{
	WORD	obj, searchflag, curflag, inc;
/*	WORD	last_obj;*/

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
fm_button( WINFO *w, WORD obj, WORD clicks, WORD *pobj )
{
	OBJECT	*tree;
	WORD	state, flags, parent, tobj;
	BOOLEAN	cont;
	MRETS	m;

	cont = TRUE;
	tree = w->x;
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
					( (state & SELECTED) || (tobj == obj) ) ) {
					if( tobj == obj )
						state |= SELECTED;
					else
						state &= ~SELECTED;
					Objc_change( tree, tobj, &w->work, state, TRUE );
				}
			}

		} else { /* not an RBUTTON */
			graf_watchbox( tree, obj, state^SELECTED, state );

		}

		if( cont && (flags & (SELECTABLE|EDITABLE)) )
			Evnt_button( 1, 1, 0, &m );

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
 * return TRUE if the extent of `obj' lies entirely within w->work
 */
BOOLEAN
can_edit( WINFO *w, WORD obj )
{
	OBJECT	*tree;
	GRECT	r;
	WORD	xy[4];

	tree = (OBJECT *)(w->x);

	r = ObRect(obj);
	objc_offset( tree, obj, &r.g_x, &r.g_y );
	rc_2xy( &r, xy );
	return ( xy_inrect( xy[0], xy[1], &w->work ) &&
			xy_inrect( xy[2], xy[3], &w->work ) );
}


/* ................................................................
 * Handle user interaction with a form in open window `w'.
 *
 * Initial conditions are as follows:
 *		w->x is the address of the form.
 *		window is open, with appropriate WINFO rects & coordinates set
 *		form is drawn within window, at correct virtual coordinates
 *		ROOT object of form has correct x,y coordinates
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
xform_do( WINFO *w, WORD start_field, WORD puntmsg[] )
{
	OBJECT	*tree;
	WORD	next_obj, edit_obj, idx;
	BOOLEAN	cont, doedit;
	WORD	event;
	MRETS	m;
	WORD	msg[8], key, clicks;

	DIRS	direction; /* form_keybd */

	tree = (OBJECT *)(w->x);

	/*
	 * Get the next editable object
	 */
	if( start_field == 0 )
		next_obj = find_obj( tree, 0, FORWARD );
	else
		next_obj = start_field;

	edit_obj = 0;
	cont = TRUE;

	while( cont ) {

		/*
		 * Put the cursor in the edit field
		 */
		if( (next_obj != 0) && (edit_obj != next_obj) ) {
			edit_obj = next_obj;
			next_obj = 0;
			doedit = can_edit( w, edit_obj );
			if( doedit )
				objc_edit( tree, edit_obj, 0, (int *)&idx, ED_INIT );
		}

		wind_update( FALSE );
		/*
		 * Wait...
		 */
		event = Evnt_multi( MU_KEYBD|MU_BUTTON|MU_MESAG, 1, 1, 1,
							NULL, NULL, msg, 0L, &m, &key, &clicks );
		wind_update( TRUE );

		if( EvMessage() ) {
			switch( MsgType(msg) ) {
				case WM_SIZED:
					doedit = can_edit( w, edit_obj );
				/* fall through */
				case WM_REDRAW:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_MOVED:
				/* redraw 'n' shit */
					if( doedit )
						objc_edit( tree, edit_obj, 0, (int *)&idx, ED_END );
					do_windows( (int *)msg, (int *)&event );

					doedit = can_edit( w, edit_obj );
					if( doedit )
						objc_edit( tree, edit_obj, 0, (int *)&idx, ED_END );
				break;

				default:
					for( idx = 0; idx < 8; idx++ )
						puntmsg[idx] = msg[idx];
					return -1;
			}
		}


/*
 * What about hot keys?? AIEEE!!
 */
		if( EvKey() ) {

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

			if( direction != NODIR ) {
				key = 0;
				next_obj = find_obj( tree, edit_obj, direction );
				if( (direction == DEFAULTDIR) && (next_obj != 0) ) {
					Objc_change( tree, next_obj, &w->work,
								 ObState(next_obj)|SELECTED, TRUE );
					cont = FALSE;
				}
			}
			/*
			 * End of form_keybd()
			 */

			if( key && doedit )
				objc_edit( tree, edit_obj, key, (int *)&idx, ED_CHAR );
		}

		if( EvButton() ) {
			next_obj = objc_find( tree, ROOT, MAX_DEPTH, m.x, m.y );
			if( next_obj == NIL ) {
				Bconout( 2, 7 );
				next_obj = 0;
			} else {
				cont = fm_button( w, next_obj, clicks, &next_obj );
			}
		}

		if( doedit &&
			(!cont || (next_obj != 0)) &&
			(next_obj != edit_obj) )
			objc_edit( tree, edit_obj, 0, (int *)&idx, ED_END );
	}

	return next_obj;
}
