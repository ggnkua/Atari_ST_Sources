
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/***********************************************************************
 *
 * simulate a drop-down menu, and similar things.
 *
 *	The area covered by the parent object of 'tree' will be saved
 *	and restored via bit-blit using the AES menu/alert buffer.
 *
 *	The object tree pointer MUST point to a root object (more accurately,
 *	the first object in the tree pointed to must have x/y values that
 *	represent screen offsets, not offsets from some higher-level object).
 *
 *	The rules for the tree are more or less the same as a standard AES
 *	menu tree -- for an object to be selected, it must be SELECTABLE and
 *	not DISABLED.  The root object will never be selected.	
 *
 *	As the mouse moves across eligible objects, this routine will 'select'
 *	the object by changing its ob_state to 'select_state' as passed by
 *	the caller. This makes it possible to use CROSSED, CHECKED, OUTLINED,
 *	etc, instead of SELECTED to indicate visually which objects are active.
 *	This can be especially handy with colored objects, since setting a
 *	colored object to SELECTED changes its color.
 *
 *	This routine returns after the mouse has been clicked and released.
 *	If a SELECTABLE non-DISABLED object was under the mouse at the time
 *	of the down-click, its object index will be returned, otherwise -1
 *	will be returned.
 ***********************************************************************/

#include "gemfast.h"
#include "aesblit.h"
#include <osbind.h>

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

#define MU_MENTRY 0
#define MU_MEXIT  1

#ifndef GEMFAST_H	/* compile the following only if GEMFAST is unavailable */

/**************************************************************************
 *
 * obj_offxywh - Calc GRECT of object's location adjusted to screen coords.
 *
 *************************************************************************/

static void
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

static void
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
 * rc_gadjust - Adjust a GRECT rectangle by a given width and/or height.
 *
 *	Positive adjust values expand the rectangle, negative values shrink it.
 *
 *************************************************************************/

static void
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

static void
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

#endif	/* end of GEMFAST compatibility code */

/**************************************************************************
 *
 * simu_menu - The simulator routine.
 *
 *************************************************************************/

int
simu_menu(tree, select_state)
	register OBJECT *tree;
	int 			select_state;
{
	int 			mousex, 
					mousey, 
					mouseb, 
					dmy;
	register int	cur_obj, 
					old_obj,
					mu_m1flag,
					event;
	GRECT			mu_m1rect;
	GRECT			cliprect;

	wind_update(BEG_MCTRL);

	objc_xywh(tree, R_TREE, &cliprect);
	rc_gadjust(&cliprect, 1, 1);

	if (0 != aes_blit(AESBLIT_SAVESCRN, &cliprect))
		return(-1);
		
	objc_draw(tree, R_TREE, MAX_DEPTH, cliprect); 

	cur_obj = R_TREE;
	old_obj = -1;

	do	{
		objc_xywh(tree, cur_obj, &mu_m1rect);
		objc_offset(tree, cur_obj, &mu_m1rect.g_x, &mu_m1rect.g_y);

		event  =	evnt_multi(MU_M1 | MU_BUTTON,
							1,1,1,			/* mbclicks, mbmask, mbstate*/
							mu_m1flag,		/* Wait for entry/exit		*/
							mu_m1rect,		/* rectangle x/y/w/y		*/
							0,0,0,0,0,		/* Mouse event rectangle 2	*/
							&dmy,			/* Message buffer			*/
							0,0,			/* timer event, time = 0,0	*/
							&dmy,&dmy,		/* Mouse x & y at event 	*/
							&dmy,			/* Mouse button at event	*/
							&dmy,			/* Keystate at event		*/			 
							&dmy,			/* Keypress at event		*/
							&dmy);			/* Mouse clicks at event	*/

		graf_mkstate(&mousex, &mousey, &mouseb, &dmy);

		if ((event & MU_M1) && (old_obj >= R_TREE))
			objst_change(tree, old_obj, ~select_state, TRUE);

		cur_obj = objc_find(tree, R_TREE, MAX_DEPTH, mousex, mousey);

		if ((cur_obj <= R_TREE) || 
				(!(tree[cur_obj].ob_flags & SELECTABLE)) ||
				((tree[cur_obj].ob_state  & DISABLED))) {
			cur_obj  = R_TREE;
			old_obj  = -1;
			mu_m1flag = MU_MENTRY;
		}
		else {
			mu_m1flag = MU_MEXIT;
			objst_change(tree, cur_obj, select_state, TRUE);
			old_obj = cur_obj;
		}
			
	} while (!(event & MU_BUTTON) );

	if (old_obj >= R_TREE)
		objst_change(tree, old_obj, ~select_state, FALSE);

	aes_blit(AESBLIT_RSTRSCRN, &cliprect);
	evnt_button(1,1,0, &dmy, &dmy, &dmy, &dmy);
	wind_update(END_MCTRL);
	return(old_obj);

}


