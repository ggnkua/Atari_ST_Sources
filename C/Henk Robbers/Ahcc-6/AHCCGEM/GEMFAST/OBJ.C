/*****************************************************************
 * Various functions on OBJECTs                                  *
 *****************************************************************/

#include "gemf.h"

/**************************************************************************
 * OBJXTUTL.C - Functions for dealing with extended object types.
 *************************************************************************/

/*-------------------------------------------------------------------------
 * obj_xtfind - Return index of object with specified extended object type.
 *-----------------------------------------------------------------------*/

int obj_xtfind(OBJECT *ptree, int parent, char xtype)
{
	int curobj;

	curobj = ptree[parent].ob_head;
	while(curobj != parent && curobj != -1)
	{
		if (xtype == *(char *)&(ptree[curobj].ob_type))
			return curobj;

		curobj = ptree[curobj].ob_next;
	}

	return -1;
}

/**************************************************************************
 * OBJOXYWH.C - Return GRECT data from object.
 *************************************************************************/

/*-------------------------------------------------------------------------
 * obj_xywh - Return object's GRECT, not adjusted to screen coordinates.
 *-----------------------------------------------------------------------*/

/* prect really a pointer to a grect */
void obj_xywh(OBJECT *ptree, int object, GRECT *prect)
{
	ptree = &ptree[object];
	prect->g_x = ptree->ob_x;
	prect->g_y = ptree->ob_y;
	prect->g_w = ptree->ob_width;
	prect->g_h = ptree->ob_height;
}

/*-------------------------------------------------------------------------
 * obj_offxywh - Return object's GRECT, adjusted to screen coordinates.
 *-----------------------------------------------------------------------*/

void obj_offxywh(OBJECT *ptree, int object, GRECT *prect)
{
	obj_xywh(ptree, object, prect);
	objc_offset(ptree, object, &prect->g_x, &prect->g_y);
}

/**************************************************************************
 * OBJMXUD.C - Turn a normal object into an XUSERDEF object.
 *
 *  Whenever a library routine wants to supply a custom drawing routine
 *  for a standard GEM object, it calls this to fill in an XUSERDEF
 *  and attach it to the original object.  The difference between an
 *  XUSERDEF object and a regular USERDEF object is the contents of the
 *  USERBLK structure attached to the object.  A regular USERBLK contains
 *  a pointer to the drawing routine followed by a longword of anything
 *  the application wants.  For an XUSERBLK, the ap-specific longword is
 *  a pointer to the XUSERBLK itself, and then there are three more fields,
 *  which contain the original ob_type and the original ob_spec, and a
 *  longword of anything the XUSERBLK creator wants.
 *
 *  All this smoke-and-mirrors lets us transform a standard GEM object
 *  into a new custom type without losing the information from the
 *  original object.  Other library routines (rsc_gstrings, for example)
 *  know how to cope with XUSERBLK objects.
 *
 *  Note that we properly cope with INDIRECT objects (as always), and
 *  we preserve any extended type info in the original object; we only
 *  change the low-order byte when plugging in the G_USERDEF ob_type.
 *************************************************************************/

void obj_mxuserdef(XUSERBLK *pblk, OBJECT *pobj, void *pcode)
{
	long *pspec;

	pspec = &pobj->ob_spec.index;
	if (pobj->ob_flags & INDIRECT)
		pspec = (long *)*pspec;

	pblk->ub_code  = pcode;
	pblk->ub_self  = pblk;
	pblk->ub_size  = sizeof(XUSERBLK);
	pblk->reserved = (void *)0;

	pblk->ob_type  = pobj->ob_type & 0x00FF;
	pobj->ob_type  = G_USERDEF | (pobj->ob_type & 0xFF00);

	pblk->ob_spec  = *pspec;
	*pspec  	   = (long)pblk;
}

/**************************************************************************
 * OBJFLCHG.C - Change object options, with optional redraw.
 *************************************************************************/

#ifndef NULL
  #define NULL 0L
#endif

/* clip present only if drawflag==OBJ_CLIPDRAW */
void obj_flchange(
    OBJECT *ptree,
    int object,
    int newflags,
    int drawflag,
    GRECT *optional_clip)
{
	GRECT clip_rect;

/*
 * check the newflags value. if the high bit is set, AND the newflags
 * with the current options, else OR them.
 */

	if (newflags & 0x8000)
		ptree[object].ob_flags &= newflags;
	else
		ptree[object].ob_flags |= newflags;


/*
 * if drawflag is true, we need to do a redraw starting at the changed
 * object's tree root (this is in case the HIDETREE flag is being changed),
 * but the redraw must be clipped by the object we're trying to update.
 * if the drawflag indicates a clipping rectangle was passed, the object's
 * rectangle is clipped to it.
 */

	if (drawflag)
	{
		obj_clcalc(ptree, object, &clip_rect, NULL);
		if (drawflag == OBJ_CLIPDRAW)
			rc_intersect(optional_clip, &clip_rect);

		objc_draw(ptree, R_TREE, MAX_DEPTH,
					clip_rect.g_x,
					clip_rect.g_y,
					clip_rect.g_w,
					clip_rect.g_h
				);
	}
}

/**************************************************************************
 * OBJSTCHG.C - Change object state, with optional redraw.
 *************************************************************************/

void obj_stchange(
	OBJECT *ptree,
	int object,
	int newstate,
	int drawflag,
	GRECT *optional_clip)
{
	GRECT *pclip;

/*
 * check the newstate value. if the high bit is set, AND the newstate
 * with the current state, else OR them.
 */

	if (newstate & 0x8000)
		newstate &= ptree[object].ob_state;
	else
		newstate |= ptree[object].ob_state;

/*
 * if the drawflag is set, redraw the object.
 * if the drawflag says a clipping rectangle was passed, use it,
 * else use root object as the clipping rectangle for the redraw.
 */

	if (drawflag == OBJ_CLIPDRAW)
	{
		drawflag = OBJ_WITHDRAW;	/* xlate from 2 to 1 */
		pclip = optional_clip;
	}
	else
		pclip = (GRECT *)&ptree->ob_x;

	objc_change(ptree, object, 0,
		pclip->g_x,
		pclip->g_y,
		pclip->g_w,
		pclip->g_h,
		newstate, drawflag);
}

/**************************************************************************
 * OBJPPSTR.C - Return a pointer to an object's string pointer.
 *************************************************************************/

char **obj_ppstring(OBJECT *pobj)
{
	int  ob_type;
	long *pspec;

	ob_type = pobj->ob_type & 0x00FF;
	pspec	= &pobj->ob_spec.index;

	if (pobj->ob_flags & INDIRECT)
		pspec = (long *)(*pspec);

	if (ob_type == G_USERDEF)
	{
		register XUSERBLK *pxub = (XUSERBLK *)(*pspec);
		if (pxub->ub_self == pxub)
		{
			ob_type = pxub->ob_type;
			pspec	= &pxub->ob_spec;
		}
	}

	switch (ob_type)
	{
	  case G_ICON:
		pspec = (long *)(*pspec);
		pspec = &pspec[2];		/* add 12-byte offset to pointer */
		break;
	  case G_TEXT:
	  case G_BOXTEXT:
	  case G_FTEXT:
	  case G_FBOXTEXT:
		pspec = (long *)(*pspec);
		break;
	}

	return (char **)pspec;
}

/**************************************************************************
 * OBJRBUTL.C - Functions for working with radio buttons.
 *************************************************************************/

/*-------------------------------------------------------------------------
 * obj_rbfind - Extended radio button finder.
 *-----------------------------------------------------------------------*/

int obj_rbfind(OBJECT *tree, int parent, int rbstate)
{
	int    kid;
	OBJECT *pobj;

	kid = tree[parent].ob_head;

	while ( (kid != parent) && (kid >= R_TREE) )
	{
		pobj = &tree[kid];
		if ((pobj->ob_flags & RBUTTON) && (pobj->ob_state & rbstate))
			return kid;

		kid = pobj->ob_next;
	}

	return NO_OBJECT;
}

/*-------------------------------------------------------------------------
 * obj_parent - Find the parent of a given child object.
 *-----------------------------------------------------------------------*/

int obj_parent(OBJECT *tree, int curobj)
{
	int nxtobj;

	if (curobj == R_TREE)    /* The root of a tree has no parent */
		return R_TREE;

	for (;;)
	{
		nxtobj = tree[curobj].ob_next;
		if (tree[nxtobj].ob_tail == curobj)
			return nxtobj;
		curobj = nxtobj;
	}
}

/*-------------------------------------------------------------------------
 * obj_rbselect - Set a radio button to SELECTED, de-sel others in the group.
 *-----------------------------------------------------------------------*/

int obj_rbselect(OBJECT *ptree, int selobj, int state)
{
	int oldobj;

	if (selobj <= R_TREE)
		return NO_OBJECT;

	oldobj = obj_rbfind(ptree, obj_parent(ptree, selobj), state);
	if (oldobj != NO_OBJECT)
		ptree[oldobj].ob_state &= ~state;

	ptree[selobj].ob_state |= state;
	return oldobj;
}

/**************************************************************************
 * OBJBMBTN.C - The obj_bmbuttons() function.
 *************************************************************************/

int obj_bmbuttons(OBJECT *ptree, int parent, int selstate, int newbits)
{
	OBJECT *pobj;
	int    state;
	int    xtype;
	int    oldbits = 0;
	int    curobj  = ptree[parent].ob_head;

	while(curobj != parent && curobj != -1)
	{
		pobj  = &ptree[curobj];
		xtype = pobj->ob_type >> 8;
		state = pobj->ob_state;
		if (state & selstate)
			oldbits |= xtype;

		if (newbits != OBJ_BMINQUIRE)
		{
			pobj->ob_state =  (newbits & xtype)
							? (state | selstate)
							: (state & ~selstate);
		}

		curobj = ptree[curobj].ob_next;
	}

	return oldbits;
}

/**************************************************************************
 * OBJCLCAL.C - Calc clipping rectangle(s) for object in a tree.
 *************************************************************************/

int obj_clcalc(OBJECT *ptree, int object, GRECT *pgrect, VRECT *pvrect)
{
	int  adjust;
	long ob_spec;
	int  ob_type;
	int  ob_flags;
	GRECT workrect;

	obj_offxywh(ptree, object, &workrect);  /* get basic placement/sizes */

	ptree    = &ptree[object];  			/* registerize/precalc some  */
	ob_type  = ptree->ob_type & 0x00FF; 	/* miscellanious things we   */
	ob_flags = ptree->ob_flags; 			/* us a lot below.  		 */
	ob_spec  = ptree->ob_spec.index;

	if (ob_flags & INDIRECT)				/* if INDIRECT flag is set,  */
		ob_spec = *(long *)ob_spec; 		/* go get the real ob_spec.  */

	if (ob_type == G_USERDEF)
	{
		XUSERBLK *pxub = (XUSERBLK *)ob_spec;
		if (pxub->ub_self == pxub)
		{
			ob_type = pxub->ob_type;
			ob_spec = pxub->ob_spec;
		}
	}

	/*
	 * deal with objects that can have graphics that extend outside
	 * their ob_width/ob_height values...
	 */

	switch (ob_type)
	{
	  case G_BOXTEXT:
	  case G_FBOXTEXT:
		adjust = ((TEDINFO*)ob_spec)->te_thickness;
		break;
	  case G_BOX:
	  case G_IBOX:
	  case G_BOXCHAR:
		adjust = (int)((char)(ob_spec >> 16));
		break;
	  case G_BUTTON:
		adjust = -1;
		if (ob_flags & EXIT)
			--adjust;
		if (ob_flags & DEFAULT)
			--adjust;
		break;
	  default:
		adjust = 0;
		break;
	}

	if (adjust > 0)			/* if adjust value is positive, object has    */
		adjust = 0; 		/* "inner width" and no adjustment is needed. */
	else					/* negative value implies outer width, invert */
		adjust = -adjust;   /* it to a positive number for rc_gadjust().  */

	if (ptree->ob_state & (OUTLINED|SHADOWED))	/* SHADOWED and OUTLINED */
		adjust = 4; 							 /* get fixed adjustment. */

	rc_gadjust(&workrect, adjust, adjust);  	 /* apply adjustment	  */

	if (pgrect != NULL)							 /* if caller wants GRECT,*/
		*pgrect = workrect; 					 /* copy results to it.   */

	if (pvrect != NULL)							 /* if caller wants VRECT,*/
		rc_gtov(&workrect, pvrect); 			 /* convert results to it.*/

	return adjust;
}

/**************************************************************************
 *
 *************************************************************************/

#define EXTEND_INTERIOR 0x8000

static long cdecl draw_thermo(XPARMBLK *pb)
{
	ThermoInfo *pt = (ThermoInfo *)pb->pub;
	int   vdi_handle;
	int   fillwidth;
	VRECT cliprect;
	VRECT boxrect;
	GRECT objrect;

	if (0 == (vdi_handle = apl_vshared()))
		return 0;

	fillwidth = pt->tick_count * pt->tick_width;
	if (fillwidth > pt->full_width)
		fillwidth = pt->full_width;

	rc_copy(&pb->drawrect, &objrect);
	objrect.g_x += pt->xoffset;
	objrect.g_w  = pt->full_width;

	rc_gtov(&objrect, &boxrect);
	rc_vadjust(&boxrect, 1, 1);

	if (pt->fill_style & EXTEND_INTERIOR)
	{
		objrect.g_x += pt->curr_width - 1;
		rc_intersect(&pb->cliprect, &objrect);
		rc_gtov(&objrect, &cliprect);
		vs_clip(vdi_handle, 1, (int *)&cliprect);
	} else
	{
		rc_gtov(&pb->cliprect, &cliprect);
		vs_clip(vdi_handle, 1, (int *)&cliprect);
		vsf_interior(vdi_handle, IS_HOLLOW);
		v_bar(vdi_handle, (int *)&boxrect);
	}

	boxrect.v_x2 = boxrect.v_x1 + fillwidth;

	vsf_interior(vdi_handle, IS_PATTERN);
	vsf_style(vdi_handle, pt->fill_style & 0x0007);
	v_bar(vdi_handle, (int *)&boxrect);
	vsf_style(vdi_handle, IP_SOLID);
	vsf_interior(vdi_handle, IS_SOLID);

	vs_clip(vdi_handle, 0, (int *)&cliprect);

	pt->curr_width = fillwidth;

	return 0;

}

int obj_mkthermo( OBJECT *ptree, int object, int nincr)
{
	int iwidth;
	OBJECT *pobj = &ptree[object];
	ThermoInfo *pt;

/*-------------------------------------------------------------------------
 * Check for zero increments to prevent div-by-zero errors.
 * Calc the pixel width of one increment.
 * Make sure a VDI workstation is available for later.
 *-----------------------------------------------------------------------*/

	if (0 >= nincr)
		return -1;

	if (0 == (iwidth = pobj->ob_width / nincr))
		return -64;

	if (0 == apl_vshared())
		return -35;

/*-------------------------------------------------------------------------
 * If the object has already been made into a G_THERMO extended object,
 * just get its pointer, else make it into such an object.
 *-----------------------------------------------------------------------*/

	if ((pobj->ob_type & 0x00FF) == G_USERDEF)
	{
		pt = (ThermoInfo *)pobj->ob_spec.index;
		if (pt->xub.ob_type != G_THERMO)
			return -1;
	} else
	{
		if (NULL == (pt = apl_malloc((long)sizeof(*pt))))
			return -39;

		obj_mxuserdef(&pt->xub, pobj, draw_thermo);
		pt->xub.ub_size = sizeof(*pt);
		pt->xub.ob_type = G_THERMO;
	}

/*-------------------------------------------------------------------------
 *-----------------------------------------------------------------------*/

	pt->curr_width = 0;
	pt->tick_limit = nincr;
	pt->tick_count = 0;
	pt->tick_width = iwidth;
	pt->full_width = nincr * iwidth;
	pt->xoffset    = (pobj->ob_width - pt->full_width) / 2;
	pt->fill_style = (pt->xub.ob_spec >> 4) & 0x0007;

	return 0;
}

int obj_udthermo(OBJECT *ptree, int object, int newpos, GRECT *pclip)
{
	ThermoInfo *pt = (ThermoInfo *)ptree[object].ob_spec.index;
	int oldpos;

	if (  (ptree[object].ob_type & 0x00FF) != G_USERDEF
		|| pt->xub.ob_type != G_THERMO
	   )
		return 0;

	oldpos = pt->tick_count;

	if (newpos == OBJ_TINQUIRE)
		return oldpos;
	else if (newpos < 0)
		newpos = pt->tick_count + 1;

	if (newpos > pt->tick_limit)
		newpos = pt->tick_limit;

	if (oldpos == newpos)
		return oldpos;

	pt->tick_count = newpos;

	if (pclip != NULL)
	{
		if (oldpos < newpos)
			pt->fill_style |= EXTEND_INTERIOR;

		objc_draw(ptree, object, MAX_DEPTH,
					pclip->g_x,
					pclip->g_y,
					pclip->g_w,
					pclip->g_h
					);
		pt->fill_style &= ~EXTEND_INTERIOR;
	}

	return oldpos;
}
