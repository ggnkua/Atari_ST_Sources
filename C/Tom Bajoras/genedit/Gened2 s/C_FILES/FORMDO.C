/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras
 
	module FORMDO :  replacements for GEM functions

	my_form_do, form_alert

******************************************************************************/

overlay "gem"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "externs.h"		/* global variables */

/* local globals ............................................................*/

int fn_obj;			/* Found tabable object	    */
int fn_last;		/* Object tabbing from	    */
int fn_prev;		/* Last EDITABLE obj seen   */
int fn_dir;			/* 1 = TAB, 0 = BACKTAB	    */
int form_repeat;

/* extern ...................................................................*/

	/* declared in AESBIND (in syslib) */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

/* custom form_do ...........................................................*/
/* returns exit object #, exit_but= 1 for right click, -1 for left click */

my_form_do(tree,start_fld,exit_but,key,exitkey)
OBJECT *tree;
register int *start_fld,*exit_but;
int key;			/* non-0 for keyboard exit option */
int *exitkey;	/* key causing exit */
	/* note: for keyboard exit option, the dialog box can't have editable
		objects or a default exit object */
{
	register int edit_obj;
	register int mstate,oldmstate=0;
	int next_obj,cont,idx,mx,my,mb,kr;
	long templong;

	if (!form_repeat) waitmouse();

	next_obj= *start_fld;
	if (!next_obj) next_obj=find_edit(tree);
	edit_obj = 0;
	cont=1;
	while (cont)
	{
		if ( next_obj && (edit_obj != next_obj) )
		{
	   	edit_obj = next_obj;
			next_obj = 0;
			objc_edit(tree, edit_obj, 0, &idx, EDINIT);
		}
		if (*keyb_head != *keyb_tail)
		{
			templong= Crawcin();
			kr= templong | (templong>>8);
		}
		else
			kr=0;

		mstate= getwmouse(&mx,&my);

		if (kr)
		{
			if (key)
			{
				*exitkey= kr;
				cont=0;
			}
			else
			{
				cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
				if (kr) objc_edit(tree, edit_obj, kr, &idx, EDCHAR);
			}
		}

		if (mstate&&!oldmstate)
		{
			/* button state for L/R editing */
			*exit_but= mstate>1 ? 1 : -1 ;

			next_obj= objc_find(tree, ROOT, MAX_DEPTH, mx, my);
			if ( next_obj < 0 )
				next_obj= 0;
			else
				cont= form_button(tree, next_obj, &next_obj);
		}
		oldmstate=mstate;

		if ( (!cont) || (next_obj && (next_obj != edit_obj)) )
			objc_edit(tree, edit_obj, 0, &idx, EDEND);
	}	/* end while (cont) */

	*start_fld= edit_obj;		/* last object to be edited */

	form_repeat= tree[next_obj].ob_flags & TOUCHEXIT ;

	return next_obj;

}	/* end my_form_do() */

find_edit(tree)       /* routine to find the next editable text field */
OBJECT *tree;
{
	register int obj, flags;

	obj = 1;

	do
	{
		flags= tree[obj].ob_flags;
		if ( (flags&EDITABLE) && !(flags&HIDETREE) ) return obj;
		obj++;
	}
	while ( !(flags&LASTOB) );
	return 0;
}	/* end find_edit(tree) */

find_def(tree, obj)		/* Check if the object is DEFAULT	*/
register OBJECT *tree;
register int	obj;
{
	/* assumes a default object is never hidden or disabled */
	if ( tree[obj].ob_flags & DEFAULT )	fn_obj=obj;
	return 1;
}	/* end find_def() */

find_tab(tree, obj)		/* Look for target of TAB operation.	*/
register OBJECT *tree;
register int	obj;
{
	int flags;

	flags= tree[obj].ob_flags;

	/* can't tab to non-editable or hidden object */
	if ( !(flags&EDITABLE) || (flags&HIDETREE) ) return 1;

	/* Check for forward tab match		*/
	if (fn_dir && fn_prev == fn_last) fn_obj= obj;
	/* Check for backward tab match		*/
	if (!fn_dir && obj == fn_last) fn_obj= fn_prev;
	fn_prev = obj;		/* Record object for next call.		*/
	return 1;
}	/* end find_tab() */

/* keys used in form_keybd() */

#define  BS		0x0008
#define	TAB	0x0009
#define	CR		0x000D
#define  ESC	0x001B
#define	UP		0x4800
#define	DOWN	0x5000
#define	DEL	0x5300

form_keybd(tree, edit_obj, next_obj, kr, out_obj, okr)
register OBJECT *tree;
register int	edit_obj, next_obj, kr, *out_obj, *okr;
{
	if ((char)(kr)) kr &= 0xff; /* If lower byte valid, mask out extended byte */

	fn_dir = 0;		/* Default tab direction if backward.	*/
	switch (kr) 
	{
		case CR:
			*okr = 0;
			fn_obj = (-1);				/* Look for a DEFAULT object.		*/
			map_tree(tree, ROOT, (-1), find_def);
			/* If found, SELECT and force exit.	*/
			if (fn_obj != (-1))
			{
				kr= tree[fn_obj].ob_state | SELECTED;
				objc_change(tree, fn_obj, 0, 0,0,640,200*rez, kr,1);
				*out_obj = fn_obj;
				return 0;
			}		/* Falls through to 	*/ 
		case TAB:			/* tab if no default 	*/
		case DOWN:	
			fn_dir = 1;		/* Set fwd direction 	*/
		case UP:
			*okr = 0;		/* Zap character	*/
			fn_last = edit_obj;
			fn_prev = fn_obj = (-1); /* Look for TAB object	*/
			map_tree(tree, ROOT, (-1), find_tab);
			if (fn_obj == (-1))	/* try to wrap around 	*/
				map_tree(tree, ROOT, (-1), find_tab);
			if (fn_obj != (-1))
				*out_obj = fn_obj;
			break;
		default:			/* Pass other chars	*/
			return 1;
		}
	return 1;
}	/* end form_keybd() */

/* Non-cursive traverse of an	object tree */
map_tree(tree, this, last, routine)
register OBJECT *tree;
register int this, last;
int (*routine)();
{
	register int tmp1;

	tmp1 = this;		/* Initialize to impossible value: */
				/* TAIL won't point to self!	   */
				/* Look until final node, or off the end of tree */
	while (this != last && this != (-1))
	{
		/* Did we 'pop' into this node for the second time? */
		if ( tree[this].ob_tail != tmp1 )
		{
			tmp1 = this;	/* This is a new node */
			this = (-1);
			/* Apply operation, testing for rejection of sub-tree */
			if ((*routine)(tree, tmp1)) this = tree[tmp1].ob_head;
			/* Subtree path not taken, so traverse right */	
			if (this == (-1))	this = tree[tmp1].ob_next;
		}
		else			/* Revisiting parent: No operation, move right  */
		{
			tmp1 = this;
			this = tree[tmp1].ob_next;
		}
	}
}	/* end map_tree(tree, this, last, routine) */

/* reverse select state of an object and redraw */
objc_toggle(tree, obj)
OBJECT *tree;
int obj;
{
	GRECT	root, ob_rect;

	objc_xywh(tree, ROOT, &root);
	objc_change(tree, obj, 0, root.g_x, root.g_y, 
			root.g_w, root.g_h, (tree[obj].ob_state)^SELECTED, 1);
}	/* end objc_toggle() */

/* If the object is not already selected, make it so. */
objc_sel(tree, obj)
OBJECT *tree;
int obj;
{
	if ( !(tree[obj].ob_state & SELECTED) ) objc_toggle(tree, obj);
}	/* end objc_sel() */

/* If the object is already selected, de-select it. */
objc_dsel(tree, obj)
OBJECT *tree;
int obj;
{
	if ( tree[obj].ob_state & SELECTED ) objc_toggle(tree, obj);
}	/* end objc_dsel() */

/* Return an object's GRECT */
objc_xywh(tree, obj, p)
OBJECT *tree;
int obj;
GRECT	*p;
{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = tree[obj].ob_width;
	p->g_h = tree[obj].ob_height;
}	/* end objc_xywh() */

/* Find an object's parent */
get_parent(tree, obj)
OBJECT *tree;
int obj;
{
	register int pobj;

	if (!obj) return 0;

	pobj = tree[obj].ob_next;
	if (pobj)
	{
	  while( tree[pobj].ob_tail != obj )
	  {
	    obj = pobj;
	    pobj = tree[obj].ob_next;
	  }
	}
	return pobj;
} 	/* end get_parent() */

do_radio(tree, obj)
OBJECT *tree;
register int obj;
{
	GRECT	root;
	register int pobj, sobj;

	objc_xywh(tree, ROOT, &root);
	pobj = get_parent(tree, obj);		/* Get the object's parent */

	for ( sobj= tree[pobj].ob_head; sobj != pobj; sobj= tree[sobj].ob_next )
		if (sobj != obj) objc_dsel(tree, sobj);
	objc_sel(tree, obj);
}	/* end do_radio() */

/* mouse button handler */
form_button(tree, obj, next_obj)
register OBJECT *tree;
register int obj, *next_obj;
{
	int flags, state, texit, sble, edit;

	flags = tree[obj].ob_flags;
	state = tree[obj].ob_state;

	/* can't click on disabled or hidden object */
	if ((state&DISABLED)||(flags&HIDETREE))
	{
		*next_obj= 0;
		return 1;
	}

	texit = flags & TOUCHEXIT;
	sble =  flags & SELECTABLE;
	edit =  flags & EDITABLE;

	if (!texit && (!sble) && !edit) /* Who cares? */
	{
		*next_obj= 0;
		return 1;
	}

	if (sble)
	{
		if (flags & RBUTTON)
			do_radio(tree, obj);
		else
			objc_toggle(tree,obj);
	}

	if (texit || (flags & EXIT) )	/* Exit conditions.		*/
	{
		*next_obj= obj;
		return 0;
	}
	else
		if (!edit) *next_obj = 0;

	return 1;
}	/* end form_button() */

/* alert box: save/restore mouse icon .......................................*/

form_alert(defbut, astring)
int defbut;
long astring;
{
	int exit_obj,savemouse[37];
	char conterm;

	if (no_alerts) return 1;

	conterm= *(char*)(0x484L);					/* save console sys byte */
	*(char*)(0x484L) &= 11;						/* disable bell */
	midi_motv(1);									/* enable GEM */

	waitmouse();	/* wait for button up */

	/* swap in arrow mouse */
	copy_words(Abase-856,savemouse,37L);
	graf_mouse(ARROWMOUSE);

	int_in[0]= defbut;
	addr_in[0]= astring;
	exit_obj= crys_if(52);

	/* restore mouse icon */
	copy_words(savemouse,Abase-856,37L);
	HIDEMOUSE; SHOWMOUSE;

	*(char*)(0x484L) = conterm;				/* restore console sys byte */
	midi_motv(0);									/* disable GEM */

	return exit_obj;

}	/* end form_alert() */

/* EOF */
