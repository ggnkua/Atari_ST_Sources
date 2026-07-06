#include "portab.h"				/* portable coding conv	*/
#include "machine.h"				/* machine depndnt conv	*/
#include "obdefs.h"				/* object definitions	*/
#include "gembind.h"				/* gem binding structs	*/
#include "taddr.h"

#define	M1_ENTER	0x0000
#define	M1_EXIT		0x0001

#define BS	0x0008
#define	TAB	0x0009
#define	CR	0x000D
#define ESC	0x001B
#define	BTAB	0x0f00
#define	UP	0x4800
#define	DOWN	0x5000
#define	DEL	0x5300
					/* Global variables used by */
					/* 'mapped' functions	    */
MLOCAL	GRECT	br_rect;		/* Current break rectangle  */
MLOCAL	WORD	br_mx, br_my, br_togl;	/* Break mouse posn & flag  */ 
MLOCAL	WORD	fn_obj;			/* Found tabable object	    */
MLOCAL	WORD	fn_last;		/* Object tabbing from	    */
MLOCAL	WORD	fn_prev;		/* Last EDITABLE obj seen   */
MLOCAL	WORD	fn_dir;			/* 1 = TAB, 0 = BACKTAB	    */

/************* Utility routines for new forms manager ***************/

	VOID
objc_toggle(tree, obj)			/* Reverse the SELECT state */
	LONG	tree;			/* of an object, and redraw */
	WORD	obj;			/* it immediately.	    */
	{
	WORD	state, newstate;
	GRECT	root, ob_rect;

	objc_xywh(tree, ROOT, &root);
	state = LWGET(OB_STATE(obj));
	newstate = state ^ SELECTED;
	objc_change(tree, obj, 0, root.g_x, root.g_y, 
		root.g_w, root.g_h, newstate, 1);
	}

	VOID				/* If the object is not already */
objc_sel(tree, obj)			/* SELECTED, make it so.	*/
	LONG	tree;
	WORD	obj;
	{
	if ( !(LWGET(OB_STATE(obj)) & SELECTED) )
		objc_toggle(tree, obj);
	}

	VOID				/* If the object is SELECTED,	*/
objc_dsel(tree, obj)			/* deselect it.			*/
	LONG	tree;
	WORD	obj;
	{
	if (LWGET(OB_STATE(obj)) & SELECTED)
		objc_toggle(tree, obj);
	}

	VOID				/* Return the object's GRECT  	*/
objc_xywh(tree, obj, p)			/* through 'p'			*/
	LONG	tree;
	WORD	obj;
	GRECT	*p;
	{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = LWGET(OB_WIDTH(obj));
	p->g_h = LWGET(OB_HEIGHT(obj));
	}

	VOID				/* Non-cursive traverse of an	*/
map_tree(tree, this, last, routine)	/* object tree.  This routine	*/
	LONG		tree;		/* is described in PRO GEM #5.	*/
	WORD		this, last;
	WORD		(*routine)();
	{
	WORD		tmp1;

	tmp1 = this;		/* Initialize to impossible value: */
				/* TAIL won't point to self!	   */
				/* Look until final node, or off   */
				/* the end of tree		   */ 
	while (this != last && this != NIL)
				/* Did we 'pop' into this node	   */
				/* for the second time?		   */
		if (LWGET(OB_TAIL(this)) != tmp1)
			{
			tmp1 = this;	/* This is a new node       */
			this = NIL;
					/* Apply operation, testing  */
					/* for rejection of sub-tree */
			if ((*routine)(tree, tmp1))
				this = LWGET(OB_HEAD(tmp1));
					/* Subtree path not taken,   */
					/* so traverse right	     */	
			if (this == NIL)
				this = LWGET(OB_NEXT(tmp1));
			}
		else			/* Revisiting parent: 	     */
					/* No operation, move right  */
			{
			tmp1 = this;
			this = LWGET(OB_NEXT(tmp1));
			}
	}

	WORD				/* Find the parent object of 	*/
get_parent(tree, obj)			/* by traversing right until	*/
	LONG		tree;		/* we find nodes whose NEXT	*/
	WORD		obj;		/* and TAIL links point to 	*/
	{				/* each other.			*/
	WORD		pobj;

	if (obj == NIL)
		return (NIL);
	pobj = LWGET(OB_NEXT(obj));
	if (pobj != NIL)
	{
	  while( LWGET(OB_TAIL(pobj)) != obj ) 
	  {
	    obj = pobj;
	    pobj = LWGET(OB_NEXT(obj));
	  }
	}
	return(pobj);
	} 

	WORD
inside(x, y, pt)		/* determine if x,y is in rectangle	*/
	WORD		x, y;
	GRECT		*pt;
	{
	if ( (x >= pt->g_x) && (y >= pt->g_y) &&
	    (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
		return(TRUE);
	else
		return(FALSE);
	} 

	WORD
rc_intersect(p1, p2)		/* compute intersection of two GRECTs	*/
	GRECT		*p1, *p2;
	{
	WORD		tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
	}

	VOID
rc_copy(psbox, pdbox)		/* copy source to destination rectangle	*/
	GRECT	*psbox;
	GRECT	*pdbox;
	{
	pdbox->g_x = psbox->g_x;
	pdbox->g_y = psbox->g_y;
	pdbox->g_w = psbox->g_w;
	pdbox->g_h = psbox->g_h;
	}

/************* "Hot-spot" manager and subroutines  ***************/

	WORD
break_x(pxy)
	WORD	*pxy;
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

	WORD
break_y(pxy)
	WORD	*pxy;
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

	WORD
break_obj(tree, obj)			/* Called once per object to	*/
	LONG	tree;			/* check if the bounding rect.	*/
	WORD	obj;			/* needs to be modified.	*/
	{
	GRECT	s;
	WORD	flags, broken, pxy[4];

	objc_xywh(tree, obj, &s);
	grect_to_array(&s, pxy);
	if (!rc_intersect(&br_rect, &s))
		return (FALSE);		/* Trivial rejection case 	*/

	flags = LWGET(OB_FLAGS(obj));	/* Is this object a potential	*/
	if (flags & HIDETREE)		/* hot-spot?		     	*/
		return (FALSE);
	if ( !(flags & SELECTABLE) )
		return (TRUE);
	if (LWGET(OB_STATE(obj)) & DISABLED)
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

	WORD				/* Manages mouse rectangle events */
form_hot(tree, hot_obj, mx, my, rect, mode)
	LONG	tree;
	WORD	hot_obj, mx, my, *mode;
	GRECT	*rect;
	{
	GRECT	root;
	WORD	state;

	objc_xywh(tree, ROOT, &root);	/* If there is already a hot-spot */
	if (hot_obj != NIL)		/* turn it off.			  */
		objc_toggle(tree, hot_obj);

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
	state = LWGET(OB_STATE(hot_obj));
	if (LWGET(OB_FLAGS(hot_obj)) & SELECTABLE)
	if ( !(state & DISABLED) )
		{			/* Yes!  Set up wait state.	  */
		*mode = M1_EXIT;
		objc_xywh(tree, hot_obj, rect);
		if (state & SELECTED)	/* But only toggle if it's not	  */
			return (NIL);	/* already SELECTED!		  */
		else
			{
			objc_toggle(tree, hot_obj);
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

	WORD
find_def(tree, obj)		/* Check if the object is DEFAULT	*/
	LONG	tree;
	WORD	obj;
	{			/* Is sub-tree hidden?			*/
	if (HIDETREE & LWGET(OB_FLAGS(obj)))
		return (FALSE);
				/* Must be DEFAULT and not DISABLED	*/
	if (DEFAULT & LWGET(OB_FLAGS(obj)))
	if ( !(DISABLED & LWGET(OB_STATE(obj))) )
		fn_obj = obj;	/* Record object number			*/
	return (TRUE);
	}

	WORD
find_tab(tree, obj)		/* Look for target of TAB operation.	*/
	LONG	tree;
	WORD	obj;
	{			/* Check for hiddens subtree.		*/
	if (HIDETREE & LWGET(OB_FLAGS(obj)))
		return (FALSE);
				/* If not EDITABLE, who cares?		*/
	if ( !(EDITABLE & LWGET(OB_FLAGS(obj))) )
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

	WORD
form_keybd(tree, edit_obj, next_obj, kr, out_obj, okr)
	LONG	tree;
	WORD	edit_obj, next_obj, kr, *out_obj, *okr;
	{
	if (LLOBT(kr))		/* If lower byte valid, mask out	*/
		kr &= 0xff;	/* extended code byte.			*/
	fn_dir = 0;		/* Default tab direction if backward.	*/
	switch (kr) {
		case CR:	/* Zap character.			*/
			*okr = 0;
				/* Look for a DEFAULT object.		*/
			fn_obj = NIL;
			map_tree(tree, ROOT, NIL, find_def);
				/* If found, SELECT and force exit.	*/
			if (fn_obj != NIL)
				{
				objc_sel(tree, fn_obj);
				*out_obj = fn_obj;
				return (FALSE);
				}		/* Falls through to 	*/ 
		case TAB:			/* tab if no default 	*/
		case DOWN:	
			fn_dir = 1;		/* Set fwd direction 	*/
		case BTAB:
		case UP:
			*okr = 0;		/* Zap character	*/
			fn_last = edit_obj;
			fn_prev = fn_obj = NIL; /* Look for TAB object	*/
			map_tree(tree, ROOT, NIL, find_tab);
			if (fn_obj == NIL)	/* try to wrap around 	*/
				map_tree(tree, ROOT, NIL, find_tab);
			if (fn_obj != NIL)
				*out_obj = fn_obj;
			break;
		default:			/* Pass other chars	*/
			return (TRUE);
		}
	return (TRUE);
	}

/************* Mouse button manager and subroutines ***************/

	WORD
do_radio(tree, obj)
	LONG	tree;
	WORD	obj;
	{
	GRECT	root;
	WORD	pobj, sobj, state;

	objc_xywh(tree, ROOT, &root);
	pobj = get_parent(tree, obj);		/* Get the object's parent */

	for (sobj = LWGET(OB_HEAD(pobj)); sobj != pobj;
		sobj = LWGET(OB_NEXT(sobj)) )
		{				/* Deselect all but...	   */
		if (sobj != obj)
			objc_dsel(tree, sobj);
		}
	objc_sel(tree, obj);			/* the one being SELECTED  */
	}

	WORD					/* Mouse button handler	   */
form_button(tree, obj, clicks, next_obj, hot_obj)
	LONG	tree;
	WORD	obj, clicks, *next_obj, *hot_obj;
	{
	WORD	flags, state, hibit, texit, sble, dsbld, edit;
	WORD	in_out, in_state;

	flags = LWGET(OB_FLAGS(obj));		/* Get flags and states   */
	state = LWGET(OB_STATE(obj));
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

/************* New forms manager: Entry point and main loop *************/

	WORD
form_do(tree, start_fld)
	REG LONG	tree;
	WORD		*start_fld;
	{
	REG WORD	edit_obj;
	WORD		next_obj, hot_obj, hot_mode;
	WORD		which, cont;
	WORD		idx;
	WORD		mx, my, mb, ks, kr, br;
	GRECT		hot_rect;
	WORD		(*valid)();
						/* Init. editing	*/
	next_obj = *start_fld;
	edit_obj = 0;
						/* Initial hotspot cndx */
	hot_obj = NIL; hot_mode = M1_ENTER;
	objc_xywh(tree, ROOT, &hot_rect);
						/* Main event loop	*/
	cont = TRUE;
	while (cont)
	  {
						/* position cursor on	*/
						/*   the selected 	*/
						/*   editting field	*/
	  if (edit_obj != next_obj)
	  if (next_obj != 0)
	  	{
	    	edit_obj = next_obj;
	    	next_obj = 0;
	    	objc_edit(tree, edit_obj, 0, &idx, EDINIT);
	  	}
						/* wait for button or   */
						/* key or rectangle	*/
	  which = evnt_multi(MU_KEYBD | MU_BUTTON | MU_M1, 
			0x02, 0x01, 0x01,
			hot_mode, hot_rect.g_x, hot_rect.g_y, 
				hot_rect.g_w, hot_rect.g_h, 
			0, 0, 0, 0, 0,
			0x0L,
			0, 0,
			&mx, &my, &mb, &ks, &kr, &br);

	  if (which & MU_M1)			/* handle rect. event 	*/
	  	hot_obj = form_hot(tree, hot_obj, mx, my, &hot_rect, &hot_mode);
						/* handle keyboard event*/
	  if (which & MU_KEYBD)
	  	{				/* Control char filter	*/
	    	cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
	    	if (kr && edit_obj)		/* Add others to object	*/
			objc_edit(tree, edit_obj, kr, &idx, EDCHAR);
	  	}
						/* handle button event	*/
	  if (which & MU_BUTTON)
	  	{				/* Which object hit?	*/
	    	next_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
 	    	if (next_obj == NIL)
		      	next_obj = 0;
	    	else				/* Process a click	*/
	    		cont = form_button(tree, next_obj, br, 
				&next_obj, &hot_obj);
	  	}
						/* handle end of field	*/
						/*   clean up		*/
	  if (!cont || (next_obj != edit_obj && next_obj != 0))
	  if (edit_obj != 0) 
	  	objc_edit(tree, edit_obj, 0, &idx, EDEND);
	  }
						/* If defaulted, may	*/
						/* need to clear hotspot*/
	if (hot_obj != (next_obj & 0x7fff))
	if (hot_obj != NIL)
		objc_toggle(tree, hot_obj);
						/* return exit object	*/
						/*   hi bit may be set	*/
						/*   if exit obj. was	*/
						/*   double-clicked	*/
	*start_fld = edit_obj;
	return(next_obj);
	}
