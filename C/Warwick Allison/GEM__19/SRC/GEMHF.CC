/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include <values.h>
#include "gemhf.h"
#include "gemrawo.h"
#include "grect.h"


static int FindEdit(GEMrawobject* o, int i)
{
	return o[i].Editable() ? i : -1;
}

GEMhotform::GEMhotform(const GEMrsc& in, int RSCindex) :
	GEMform(in,RSCindex)
{
	curedit=Map(FindEdit);
	Zooms(FALSE);
}

GEMhotform::GEMhotform(const GEMhotform& copy) :
	GEMform(copy)
{
	curedit=Map(FindEdit);
	Zooms(FALSE);
}

int GEMhotform::DoKey(int meta, int key)
{
	return Ignore;
}

int GEMhotform::DoOff()
{
	return NoObject;
}

int GEMhotform::DoHot(int ob, bool inside)
{
	static void objc_toggle(GEMrawobject* tree, int obj);

	objc_toggle(Obj,ob);

	// Could use this, but G_STRING objects are transparent, so do not
	// Redraw well when selected.
	//
	// Obj[ob].Selected(inside);
	// RedrawObject(ob);

	return Ignore;
}

// "Hot" version from Profesional GEM, by Tim Oren.
//
// The following code is based on the file "gemcl13.c" in the
// source code provided with the Professional GEM series.
// Available in the /atari/Programming directory of atari.archive.umich.edu.
//
// Changes include:
//
//      - Ported to C++ (ie. uses ANSI prototypes).
//      - Uses current bindings.
//      - Added "machine" macros #defines at start.
//      - Clicking off form detected.
//      - Unprocessed keys passed to DoKey() method.

#define NIL -1

#define	M1_ENTER	0x0000
#define	M1_EXIT		0x0001

#define BS   0x0008
#define	TAB  0x0009
#define	CR   0x000D
#define ESC  0x001B
#define	BTAB 0x0f00
#define	UP   0x4800
#define	DOWN 0x5000
#define	DEL  0x5300

/* Global variables used by */
/* 'mapped' functions	    */

static	GRect	br_rect;		/* Current break rectangle  */
static	int	br_mx, br_my, br_togl;	/* Break mouse posn & flag  */ 
static	int	fn_obj;			/* Found tabable object	    */
static	int	fn_last;		/* Object tabbing from	    */
static	int	fn_prev;		/* Last EDITABLE obj seen   */
static	int	fn_dir;			/* 1 = TAB, 0 = BACKTAB	    */

/************* Utility routines for new forms manager ***************/

/* Return the object's GRect through 'p' */
static void objc_xywh(GEMrawobject* tree, int obj, GRect *p)
{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = tree[obj].Width();
	p->g_h = tree[obj].Height();
}

/* Reverse the SELECT state */
static void objc_toggle(GEMrawobject* tree, int obj)
{
	int	state, newstate;
	GRect	root;

	objc_xywh(tree, ROOT, &root);
	state = tree[obj].States();
	newstate = state ^ SELECTED;
	objc_change(tree, obj, 0, root.g_x, root.g_y, 
		root.g_w, root.g_h, newstate, 1);
}

/* If the object is not already SELECTED, make it so. */
static void objc_sel(GEMrawobject* tree, int obj)
{
	if ( !(tree[obj].States() & SELECTED) )
		objc_toggle(tree, obj);
}

/* If the object is SELECTED, deselect it. */
static void objc_dsel(GEMrawobject* tree, int obj)
{
	if (tree[obj].States() & SELECTED)
		objc_toggle(tree, obj);
}

/* Non-cursive traverse of an object tree. */
static void map_tree(GEMrawobject* tree, int this1, int last, int routine(GEMrawobject*,int))
{
	int		tmp1;

	tmp1 = this1;		/* Initialize to impossible value: */
				/* TAIL won't point to self!	   */
				/* Look until final node, or off   */
				/* the end of tree		   */ 
	while (this1 != last && this1 != NIL)
				/* Did we 'pop' into this1 node	   */
				/* for the second time?		   */
		if (tree[this1].Tail() != tmp1)
			{
			tmp1 = this1;	/* This is a new node       */
			this1 = NIL;
					/* Apply operation, testing  */
					/* for rejection of sub-tree */
			if (!tree[tmp1].HideTree())
				if (routine(tree, tmp1))
					this1 = tree[tmp1].Head();
					/* Subtree path not taken,   */
					/* so traverse right	     */	
			if (this1 == NIL)
				this1 = tree[tmp1].Next();
			}
		else			/* Revisiting parent: 	     */
					/* No operation, move right  */
			{
			tmp1 = this1;
			this1 = tree[tmp1].Next();
			}
}

/* Find the parent of an object of by traversing right */
static int get_parent(GEMrawobject* tree, int obj)
{
	int		pobj;

	if (obj == NIL)
		return (NIL);
	pobj = tree[obj].Next();
	if (pobj != NIL)
	{
	  while( tree[pobj].Tail() != obj ) 
	  {
	    obj = pobj;
	    pobj = tree[obj].Next();
	  }
	}
	return(pobj);
} 

/* determine if x,y is in rectangle	*/
static int inside(int x, int y, GRect *pt)	
{
	if ( (x >= pt->g_x) && (y >= pt->g_y) &&
	    (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
		return(TRUE);
	else
		return(FALSE);
} 

/************* "Hot-spot" manager and subroutines  ***************/

static int break_x(int *pxy)
{				/* Breaking object is right of	*/
	if (br_mx < pxy[0])		/* mouse.  Reduce width of 	*/
		{			/* bounding rectangle.		*/
		br_rect.g_w = pxy[0] - br_rect.g_x;
		return (TRUE);
		}
	if (br_mx > pxy[2])		/* Object to left.  Reduce width*/
		{			/* and move rect. to right	*/
		br_rect.g_w += br_rect.g_x - pxy[2] - 1;
		br_rect.g_x = pxy[2] + 1;
		return (TRUE);
		}
	return (FALSE);			/* Mouse within object segment.	*/
}				/* Break attempt fails.		*/

static int break_y(int *pxy)
{
	if (br_my < pxy[1])		/* Object below mouse.  Reduce	*/
		{			/* height of bounding rect.	*/
		br_rect.g_h = pxy[1] - br_rect.g_y;
		return (TRUE);
		}
	if (br_my > pxy[3])		/* Object above mouse.  Reduce	*/
		{			/* height and shift downward.	*/
		br_rect.g_h += br_rect.g_y - pxy[3] - 1;
		br_rect.g_y = pxy[3] + 1;
		return (TRUE); 
		}
	/* Emergency escape test! Protection vs. turkeys who nest */
	/* non-selectable objects inside of selectables.          */
	if (br_mx >= pxy[0] && br_mx <= pxy[1])
		{				/* Will X break fail?	  */
		br_rect.g_x = br_mx;		/* If so, punt!		  */
		br_rect.g_y = br_my;
		br_rect.g_w = br_rect.g_h = 1;
		return (TRUE);
		}
	return (FALSE);
}

/* Called once per object to	*/
static int break_obj(GEMrawobject* tree, int obj)
{
	GRect	s;
	int	flags, broken, pxy[4];

	objc_xywh(tree, obj, &s);
	grect_to_array(&s, pxy);
	if (!rc_intersect(&br_rect, &s))
		return (FALSE);		/* Trivial rejection case 	*/

	flags = tree[obj].Flags();	/* Is this1 object a potential	*/
	if (flags & HIDETREE)		/* hot-spot?		     	*/
		return (FALSE);
	if ( !(flags & SELECTABLE) )
		return (TRUE);
	if (tree[obj].States() & DISABLED)
		return (TRUE);

	for (broken = FALSE; !broken; ) /* This could take two passes 	*/
		{			/* if the first break fails.   	*/
		if (br_togl)
			broken = break_x(pxy);
		else
			broken = break_y(pxy);
		br_togl = !br_togl;
		}
	return (TRUE);
}

/* Manages mouse rectangle events */
static int form_hot(GEMrawobject* tree, int hot_obj, int mx, int my, GRect *rect, int *mode)
{
	GRect	root;
	int	state;

	objc_xywh(tree, ROOT, &root);	/* If there is already a hot-spot */

	if (!(inside(mx, my, &root)) )	/* Mouse has moved outside of 	  */
		{			/* the dialog.  Wait for return.  */
		*mode = M1_ENTER;
		rc_copy(&root, rect);
		return (NIL);
		}
					/* What object is mouse over?	  */
					/* (Hit is guaranteed.)           */
	hot_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
					/* Is this object a hot-spot?	  */
	state = tree[hot_obj].States();
	if (tree[hot_obj].Flags() & SELECTABLE)
	if ( !(state & DISABLED) )
		{			/* Yes!  Set up wait state.	  */
		*mode = M1_EXIT;
		objc_xywh(tree, hot_obj, rect);
		if (state & SELECTED)	/* But only toggle if it's not	  */
			return (NIL);	/* already SELECTED!		  */
		else
			{
			return (hot_obj);
			}
		}

	rc_copy(&root, &br_rect);	/* No hot object, so compute	*/
	br_mx = mx;			/* mouse bounding rectangle.	*/
	br_my = my;
	br_togl = 0;
	map_tree(tree, ROOT, NIL, break_obj);
	rc_copy(&br_rect, rect);	/* Then return to wait state.	*/
	*mode = M1_EXIT;
	return (NIL);
}

/************* Keyboard manager and subroutines ***************/

/* Check if the object is DEFAULT	*/
static int find_def(GEMrawobject* tree, int obj)
	{			/* Is sub-tree hidden?			*/
	if (HIDETREE & tree[obj].Flags())
		return (FALSE);
				/* Must be DEFAULT and not DISABLED	*/
	if (DEFAULT & tree[obj].Flags())
	if ( !(DISABLED & tree[obj].States()) )
		fn_obj = obj;	/* Record object number			*/
	return (TRUE);
}

/* Look for target of TAB operation.	*/
static int find_tab(GEMrawobject* tree, int obj)
	{			/* Check for hiddens subtree.		*/
	if (HIDETREE & tree[obj].Flags())
		return (FALSE);
				/* If not EDITABLE, who cares?		*/
	if ( !(EDITABLE & tree[obj].Flags()) )
		return (TRUE);
				/* Check for forward tab match		*/
	if (fn_dir && fn_prev == fn_last)
		fn_obj = obj;
				/* Check for backward tab match		*/
	if (!fn_dir && obj == fn_last)
		fn_obj = fn_prev;
	fn_prev = obj;		/* Record object for next call.		*/
	return (TRUE);
}	

static int form_keyboard(GEMrawobject* tree, int edit_obj, int next_obj, int kr, int *out_obj, int *okr)
{
	if (kr&0xff)		/* If lower byte valid, mask out	*/
		kr &= 0xff;	/* extended code byte.			*/
	fn_dir = 0;		/* Default tab direction if backward.	*/
	switch (kr) {
		case CR:
				/* Look for a DEFAULT object.		*/
			fn_obj = NIL;
			map_tree(tree, ROOT, NIL, find_def);
				/* If found, SELECT and force exit.	*/
			if (fn_obj != NIL) {
				*okr = 0;	/* Zap character.			*/
				objc_sel(tree, fn_obj);
				*out_obj = fn_obj;
				return (FALSE);
			}		/* Falls through to 	*/ 
		case TAB:			/* tab if no default 	*/
		case DOWN:	
			fn_dir = 1;		/* Set fwd direction 	*/
		case BTAB:
		case UP:
			fn_last = edit_obj;
			fn_prev = fn_obj = NIL; /* Look for TAB object	*/
			map_tree(tree, ROOT, NIL, find_tab);
			if (fn_obj == NIL)	/* try to wrap around 	*/
				map_tree(tree, ROOT, NIL, find_tab);
			if (fn_obj != NIL) {
				*out_obj = fn_obj;
				*okr = 0;		/* Zap character	*/
			}
			break;
		default:			/* Pass other chars	*/
			return (TRUE);
		}
	return (TRUE);
}

/************* Mouse button manager and subroutines ***************/

static void do_radio(GEMrawobject* tree, int obj)
{
	GRect	root;
	int	pobj, sobj;

	objc_xywh(tree, ROOT, &root);
	pobj = get_parent(tree, obj);		/* Get the object's parent */

	for (sobj = tree[pobj].Head(); sobj != pobj;
		sobj = tree[sobj].Next() )
		{				/* Deselect all but...	   */
		if (sobj != obj)
			objc_dsel(tree, sobj);
		}
	objc_sel(tree, obj);			/* the one being SELECTED  */
}

/* Mouse button handler	   */
static int form_butn(GEMrawobject* tree, int obj, int clicks, int *next_obj, int *hot_obj)
{
	int	flags, state, hibit, texit, sble, dsbld, edit;
	int	in_state;

	flags = tree[obj].Flags();		/* Get flags and states   */
	state = tree[obj].States();
	texit = flags & TOUCHEXIT;
	sble = flags & SELECTABLE;
	dsbld = state & DISABLED;
	edit = flags & EDITABLE;

	if (!texit && (!sble || dsbld) && !edit) /* This is not an  	*/
		{				 /* interesting object	*/
		*next_obj = 0;
		return (TRUE);
		}

	if (texit && clicks == 2)		/* Preset special flag	*/
		hibit = 0x8000;
	else
		hibit = 0x0;

	if (sble && !dsbld)			/* Hot stuff!		*/
		{
		if (flags & RBUTTON)		/* Process radio buttons*/
			do_radio(tree, obj);	/* immediately!		*/ 
		else if (!texit)
			{
			in_state = (obj == *hot_obj)?	/* Already toggled ? */
			state: state ^ SELECTED;	

			if (!graf_watchbox(tree, obj, in_state, 
				in_state ^ SELECTED))
				{			/* He gave up...  */
				*next_obj = 0;
				*hot_obj = NIL;
				return (TRUE);
				}
			}
		else /* if (texit) */
			if (obj != *hot_obj)	/* Force SELECTED	*/
				objc_toggle(tree, obj);
		}

	if (obj == *hot_obj)		/* We're gonna do it! So don't	*/
		*hot_obj = NIL;		/* turn it off later.		*/

	if (texit || (flags & EXIT) )	/* Exit conditions.		*/
		{
		*next_obj = obj | hibit;
		return (FALSE);		/* Time to leave!		*/
		}
	else if (!edit)			/* Clear object unless tabbing	*/
		*next_obj = 0;

	return (TRUE);
}

static int to_find;
static int FindToFind(GEMrawobject* o, int i)
{
	return i==to_find ? i : -1;
}


/************* New forms manager: main loop *************/

int GEMhotform::FormDo()
{
	int	edit_obj;
	int		next_obj, hot_obj, hot_mode;
	int		which, cont;
	int		idx;
	int		mx, my, mb, meta, kr, br;
	GRect		hot_rect;

	wind_update(BEG_MCTRL);

	/* Init. editing	*/
	to_find=curedit;
	if (Map(FindToFind)!=to_find) // Is it hidden?
		curedit=Map(FindEdit);
	next_obj = curedit;
	edit_obj = 0;
						/* Initial hotspot cndx */
	hot_obj = NIL; hot_mode = M1_ENTER;
	objc_xywh(Obj, ROOT, &hot_rect);
						/* Main event loop	*/
	cont = TRUE;
	while (cont) {
						/* position cursor on	*/
						/*   the selected 	*/
						/*   editting field	*/
		if (edit_obj!=next_obj && next_obj!=0) {
			edit_obj = next_obj;
			next_obj = 0;
			objc_edit(Obj, edit_obj, 0, idx, EDINIT, &idx);
		}
						/* wait for button or   */
						/* key or rectangle	*/
		which = evnt_multi(MU_KEYBD | MU_BUTTON | MU_M1, 
			0x01, // WWA - Only single click - else race can occur between clicks
			0x01, 0x01,
			hot_mode, hot_rect.g_x, hot_rect.g_y, 
				hot_rect.g_w, hot_rect.g_h, 
			0, 0, 0, 0, 0,
			0x0L,
			0,
			&mx, &my, &mb, &meta, &kr, &br);

		if (which & MU_M1) {			/* handle rect. event 	*/
			if (hot_obj != NIL) {
				int h=DoHot(hot_obj,FALSE);
				if (h!=Ignore) {
					next_obj=h;
					cont=FALSE;
				}
			}

			if (cont) {
				hot_obj = form_hot(Obj, hot_obj, mx, my, &hot_rect, &hot_mode);

				if (hot_obj != NIL) {
					int h=DoHot(hot_obj,TRUE);
					if (h!=Ignore) {
						next_obj=h;
						cont=FALSE;
					}
				}
			}
		}

		if (which & MU_KEYBD) { /* handle keyboard event*/
			/* Control char filter	*/
	    	cont = form_keyboard(Obj, edit_obj, next_obj, kr, &next_obj, &kr);
			if (kr) {
				int k=DoKey(meta,kr);
				if (k!=Ignore) {
					next_obj=k;
					cont=FALSE;
				} else {
					if (edit_obj>0) {
						objc_edit(Obj, edit_obj, kr, idx, EDCHAR, &idx);
					}
				}
			}
	  	}
						/* handle button event	*/
		if (which & MU_BUTTON) {
			/* Which object hit?	*/
	    	next_obj = objc_find(Obj, ROOT, MAX_DEPTH, mx, my);
 	    	if (next_obj == NIL) {
				next_obj = DoOff();
				if (next_obj==NoObject) {
					cont = FALSE; // We want non-form click to cancel form
				}
	    	} else {
					/* Process a click	*/
				// UnHot the object, rather than expecting form_butn to deal with it.
				if (hot_obj != NIL) {
					DoHot(hot_obj,FALSE);
					hot_obj=NIL;
				}
				cont = form_butn(Obj, next_obj, br, &next_obj, &hot_obj);
			}
	  	}
						/* handle end of field	*/
						/*   clean up		*/
		if (!cont || (next_obj != edit_obj && next_obj != 0))
		if (edit_obj != 0) 
	  	objc_edit(Obj, edit_obj, 0, idx, EDEND, &idx);
	}
						/* If defaulted, may	*/
						/* need to clear hotspot*/
	if (hot_obj != (next_obj & 0x7fff))
		if (hot_obj != NIL)
			DoHot(hot_obj,FALSE);
						/* return exit object	*/
						/*   hi bit may be set	*/
						/*   if exit obj. was	*/
						/*   double-clicked	*/
	curedit = edit_obj;

	wind_update(END_MCTRL);

	return(next_obj);
}
