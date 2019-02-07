
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/**************************************************************************
 *
 * GEMSYSTM.H - A header file to help insure compatibility between
 *				different GEM bindings systems.
 *
 *************************************************************************/

#if 1	/* if you use don't GEMFAST, change this to '#if 0' */

#include <gemfast.h>

#else

#include <obdefs.h>
#include <gemdefs.h>

#endif

/**************************************************************************
 *
 * Now, if the GEMFAST header file did NOT get included, set up the
 *	compatibility stuff.
 *
 *************************************************************************/

#ifndef GEMFAST_H

typedef long FDADDR;	/* old gemdefs file used 'long' fd_addr in FDB	 */
						/* (gemfast uses 'char *', which is what it is.) */

typedef struct {
	int v_x1;
	int v_y1;
	int v_x2;
	int v_y2;
	} VRECT;			/* old gemdefs did not define a VRECT */
	
#define NO_OBJECT -1	/* return value from objc_find, et. al. */

#define objrb_which(a,b) objxrb_which((a),(b), SELECTED)

#ifdef STORAGE			/* include exe code only if generating storage */

/*-------------------------------------------------------------------------
 * If the GEMFAST bindings are not being used, we have to set up the dumb
 * VDI arrays that all the other bindings systems use.
 *-----------------------------------------------------------------------*/

int   contrl[12],
	  intin[128],
	  ptsin[128],
	  intout[128],
	  ptsout[128];

/**************************************************************************
 *
 * rc_gtov - Convert a GRECT (xywh) rectangle to a VRECT (diag corners).
 *
 *************************************************************************/

void
rc_gtov(grect, vrect)
	register GRECT *grect;
	register VRECT *vrect;
{
	vrect->v_x1 = grect->g_x;
	vrect->v_y1 = grect->g_y;
	vrect->v_x2 = grect->g_x + grect->g_w;
	vrect->v_y2 = grect->g_y + grect->g_h;
}

/**************************************************************************
 *
 * rc_gadjust - Adjust a GRECT rectangle by a given width and/or height.
 *
 *	Positive adjust values expand the rectangle, negative values shrink it.
 *
 *************************************************************************/

void
rc_gadjust(prect, hadjust, vadjust)
	register GRECT	*prect;
	int 			hadjust;
	int 			vadjust;
{

	prect->g_x -= hadjust;
	prect->g_y -= vadjust;
	prect->g_w += hadjust * 2;
	prect->g_h += vadjust * 2;
 
}

/**************************************************************************
 *
 * objc_xywh - Get GRECT of object's location NOT adjusted to screen coords.
 *
 *************************************************************************/

void
objc_xywh(ptree, object, prect)
	register OBJECT  *ptree;
	register int	 object;
	register GRECT	 *prect; 
{
	prect->g_x = ptree[object].ob_x;
	prect->g_y = ptree[object].ob_y;
	prect->g_w = ptree[object].ob_width;
	prect->g_h = ptree[object].ob_height;
}

/**************************************************************************
 *
 * obj_offxywh - Calc GRECT of object's location adjusted to screen coords.
 *
 *************************************************************************/

void
obj_offxywh(ptree, object, prect)
	register OBJECT  *ptree;
	register int	 object;
	register GRECT	 *prect; 
{
	objc_offset(ptree, object, &prect->g_x, &prect->g_y);
	prect->g_w = ptree[object].ob_width;
	prect->g_h = ptree[object].ob_height;
}

/**************************************************************************
 *	 
 * objst_change - Change the ob_state of an object.
 *
 *	The entry-time vars are what you'd expect from their names.  The
 *	'newstate' variable works like this:
 *	  - If the high bit of newstate is cleared, the rest of the bits in
 *		newstate are ORed into the current ob_state.
 *	  - If the high bit of newstate is set, the rest of the bits are 
 *		ANDed with the current ob_state.
 *	This allows the following syntax:
 *	  objst_change(tree, obj,  SELECTED, TRUE); [ Select the obj ]
 *	  objst_change(tree, obj, ~SELECTED, TRUE); [ De-Sel the obj ]
 *	  
 *************************************************************************/

void
objst_change(ptree, object, newstate, drawflag)
	register OBJECT *ptree;
	register int	object;
	register int	newstate;
	int 			drawflag;
{
	register int	wrkstate;
	GRECT			clip_rect;
	
	wrkstate = ptree[object].ob_state;
	
	if (newstate & 0x8000) {
		wrkstate &= newstate;
	}
	else {
		wrkstate |= newstate;
	}

	obj_offxywh(ptree, R_TREE, &clip_rect);

	objc_change(ptree, object, 0, clip_rect, wrkstate, drawflag);
}

/**************************************************************************
 *
 * objxrb_which - Extended radio-button-finder... Find the object within
 *	a given parent which has an object state matching the parm passed to
 *	this routine. (A normal rb-finder looks only for SELECTED, this
 *	routine can find CROSSED, etc).
 *
 *	This routine returns the object index of the first object that matches
 *	the requested state, or -1 if no objects match.  Note that the object
 *	does not have to be a radio button, in fact that isn't even checked.
 *
 *	The check is done via a bit-wise AND, so it *is not* possible to find 
 *	an object only if it is both SELECTED and CHECKED (or whatever); in that
 *	case, the routine will find the first object that's in *either* state.
 *************************************************************************/

int
objxrb_which(tree, parent, rbstate)
	register OBJECT *tree;
	register int	parent;
	register char	rbstate;
{
	register int kid;

	kid = tree[parent].ob_head;

	while ( (kid != parent) && (kid >= R_TREE) ) {
		if (tree[kid].ob_state & rbstate) {
			return(kid);
		}
		kid = tree[kid].ob_next;
	}
	return(-1);
}

/**************************************************************************
 *
 * rsc_treefix - Do rez-dependant x/y/w/h fixup on all objects in a tree.
 *
 *************************************************************************/

void
rsc_treefix(ptree)
	register OBJECT *ptree;
{
	register int	objcounter;

	objcounter = -1;
	do	{
		objcounter++;
		rsrc_obfix(ptree, objcounter);
	} while (!(ptree[objcounter].ob_flags & LASTOB));
}

#else	/* if not generating storage, just declare names... */

extern int	contrl[12],
			intin[128],
			ptsin[128],
			intout[128],
			ptsout[128];

extern void rv_gtov();
extern void rc_gadjust();
extern void objc_xywh();
extern void obj_offxywh();
extern void objst_change();
extern int	objxrb_which();
extern void rsc_treefix();

#endif /* end of #ifdef STORAGE */

#endif /* end of #ifndef GEMFAST_H */

