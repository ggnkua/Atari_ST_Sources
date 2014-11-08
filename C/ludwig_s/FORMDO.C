/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	form_do -- custom form_do()

	my_form_do and all its children

******************************************************************************/

overlay "formdo"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

/* used by 'mapped' functions */
int fn_obj;			/* Found tabable object	    */
int fn_last;		/* Object tabbing from	    */
int fn_prev;		/* Last EDITABLE obj seen   */
int fn_dir;			/* 1 = TAB, 0 = BACKTAB	    */

/* imported from GEM */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

/* custom form_do ...........................................................*/
/* returns exit object #, exit_but= 1 for right click, -1 for left click */

my_form_do(tree,start_fld,exit_but)
OBJECT *tree;
register int *start_fld,*exit_but;
{
	register int edit_obj;
	register int mstate,oldmstate=0;
	int next_obj,which,cont,idx,mx,my,mb,kr;
	int savedform,savedhide;
	long save_mot,save_but;
	int rts=0x4e75;
	static int re_enter=0;

	/* fixes a GEM bug:  otherwise, if mouse moves into menu bar during
		my_form_do() system goes bye bye */
	if (!re_enter)	while ( graf_mstate() ) ;
	vdi_butv(&rts,&save_but);
	vdi_motv(&rts,&save_mot);

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

		which= evnt_multi(MU_KEYBD|MU_TIMER,
								0,0,0,0,0,0,0,0,0,0,0,0,0,
								&dummy,0,0,&dummy,&dummy,&dummy,&dummy,&kr,&dummy);    
		mstate=getmouse(&mx,&my);

		if (which & MU_KEYBD)
		{
			cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
			if (kr) objc_edit(tree, edit_obj, kr, &idx, EDCHAR);
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

	/* return exit object */
	*start_fld= edit_obj;		/* last object to be edited */

	/* restore GEM's tracking the mouse */
	vdi_butv(save_but,&save_but);
	vdi_motv(save_mot,&save_mot);

	re_enter= tree[next_obj].ob_flags & TOUCHEXIT ? 1 : 0 ;
	return (next_obj);

}	/* end my_form_do() */

find_edit(tree)       /* routine to find the next editable text field */
OBJECT *tree;
{
	register int obj, flags;

	obj = 1;

	do
	{
		flags= tree[obj].ob_flags;
		if (flags & EDITABLE) return(obj);
		obj++;
	}
	while ( !(flags & LASTOB) );
	return(0);
}	/* end find_edit(tree) */

find_def(tree, obj)		/* Check if the object is DEFAULT	*/
register OBJECT *tree;
register int	obj;
{
	/* assumes a default object is never hidden or disabled */
	if ( tree[obj].ob_flags & DEFAULT )	fn_obj=obj;
	return(1);
}	/* end find_def() */

find_tab(tree, obj)		/* Look for target of TAB operation.	*/
register OBJECT *tree;
register int	obj;
{
	/* assumes tabbable object is never hidden */

	/* not EDITABLE */
	if ( !( tree[obj].ob_flags & EDITABLE ) )	return (1);
	/* Check for forward tab match		*/
	if (fn_dir && fn_prev == fn_last) fn_obj= obj;
	/* Check for backward tab match		*/
	if (!fn_dir && obj == fn_last) fn_obj= fn_prev;
	fn_prev = obj;		/* Record object for next call.		*/
	return(1);
}	/* end find_tab() */

/* keys used in form_keybd() */

#define  BS		0x0008
#define	TAB	0x0009
#define	CR		0x000D
#define  ESC	0x001B
#define	UP		0x4800
#define	DOWN	0x5000
#define	DEL	0x5300
#define  UNDERSCORE   0x005F

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
				return (0);
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
		case UNDERSCORE:
			*okr=0;			/* don't allow the famous underscore crash */
		default:			/* Pass other chars	*/
			return (1);
		}
	return (1);
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

/* needed in form_do */
graf_mstate()
{
	crys_if(79);	/* graf_mkstate */
	return(int_out[3]);
}	/* end graf_mstate() */

vdi_butv(usercode, savecode )
long usercode;
long *savecode;
{
    i_ptr( usercode );   

    contrl[0] = 125;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = gl_hand;
    vdi();

    m_lptr2( savecode );
}	/* end vdi_butv() */

vdi_motv(usercode, savecode )
long usercode;
long *savecode;
{
    i_ptr( usercode );

    contrl[0] = 126;
    contrl[1] = 0;
    contrl[3] = 0;
    contrl[6] = gl_hand;
    vdi();

    m_lptr2( savecode );
}	/* end vdi_motv() */

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

	if (!obj) return(0);

	pobj = tree[obj].ob_next;
	if (pobj)
	{
	  while( tree[pobj].ob_tail != obj )
	  {
	    obj = pobj;
	    pobj = tree[obj].ob_next;
	  }
	}
	return(pobj);
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
	int flags, state, texit, sble, dsbld, edit;

	flags = tree[obj].ob_flags;
	state = tree[obj].ob_state;
	texit = flags & TOUCHEXIT;
	sble =  flags & SELECTABLE;
	dsbld = state & DISABLED;
	edit =  flags & EDITABLE;

	if (!texit && (!sble || dsbld) && !edit) /* Who cares? */
	{
		*next_obj = 0;
		return (1);
	}

	if (sble && !dsbld)
		if (flags & RBUTTON)
			do_radio(tree, obj);
		else
			objc_toggle(tree,obj);

	if (texit || (flags & EXIT) )	/* Exit conditions.		*/
	{
		*next_obj= obj;
		return (0);
	}
	else
		if (!edit) *next_obj = 0;

	return (1);
}	/* end form_button() */

/* EOF formdo.c */
