/*******************************************************
 * Various functions on resources                      *
 *******************************************************/

#include <stdarg.h>
#include "gemf.h"
#include "vdi.h"

#ifndef NULL
  #define NULL 0L
#endif

typedef struct {
    int wchar;
    int hchar;
    int outer_radius;
    int inner_radius;
    int text_xoffs;
    int text_yoffs;
    int circle_xoffs;
    int circle_yoffs;
    int box_xoffs;
    int box_yoffs;
    int box_xsize;
    int box_ysize;
} PreCalcs;

static PreCalcs precalcs;

/*-------------------------------------------------------------------------
 * init_precalcs - Fill in the precalculated values structure.
 *-----------------------------------------------------------------------*/

static void init_precalcs(void)
{
	PreCalcs  *pc      = &precalcs;
	int 	   wchar   = gl_wchar;
	int 	   hchar   = gl_hchar;
	int 	   h8      = hchar / 8;
	int 	   aspectx = gl_vwout[3];
	int 	   aspecty = gl_vwout[4];

	pc->wchar   	 = wchar;
	pc->hchar   	 = hchar;

	pc->text_xoffs   = wchar * 3;
	pc->text_yoffs   = 0;

	pc->box_ysize    = hchar - h8;
	pc->box_xsize    = (pc->box_ysize * aspecty) / aspectx;
	pc->box_xoffs    = 1;
	pc->box_yoffs    = 0;

	pc->outer_radius = ((hchar * aspecty) / aspectx) / 2;
	pc->inner_radius = pc->outer_radius / 2;
	pc->circle_xoffs = pc->outer_radius + pc->box_xoffs;
	pc->circle_yoffs = (hchar / 2) - h8;

}

/*-------------------------------------------------------------------------
 * cua_draw - Draw a CUA-style button.  This routine is called by
 *            the AES whenever a CUA-style button needs to be drawn
 *            or to have its state changed.  (Note that this routine
 *            gets control in supervisor mode.  Some runtime libraries
 *            will crash on stack overlow problems if you make calls
 *            to DOS, BIOS, or XBIOS from in here.)
 *
 *            We handle SELECTED, CROSSED, OUTLINED, and DISABLED states
 *            here, but other states are handled by the AES because we
 *            pass the states we didn't do back to the AES as the return
 *            value from this routine.
 *-----------------------------------------------------------------------*/

static long cdecl cua_draw(XPARMBLK  *parmblk)
{
	PreCalcs  *pc = &precalcs;
	int 				dmy;
	int 	   xpos;
	int 	   ypos;
	int 	   vdi_handle;
	int 	   objstate;
	VRECT   			boxrect;
	VRECT   			cliprect;

	if (0 == (vdi_handle = apl_vshared()))
		return 0;   /* oh well, so sorry */

	objstate = parmblk->currstate;

	rc_gtov(&parmblk->cliprect, &cliprect);
	vs_clip(vdi_handle, 1, (int *)&cliprect);
	vsf_interior(vdi_handle, IS_HOLLOW);

	xpos = parmblk->drawrect.g_x;
	ypos = parmblk->drawrect.g_y + ((parmblk->drawrect.g_h - pc->hchar) / 2);

	if (objstate & DISABLED)
		vst_effects(vdi_handle, 0x0002);

	vst_alignment(vdi_handle, 0, 5, &dmy, &dmy);
	v_gtext(vdi_handle, (xpos + pc->text_xoffs), (ypos + pc->text_yoffs),
			(char *)parmblk->pub->ob_spec);
	vst_alignment(vdi_handle, 0, 0, &dmy, &dmy);

	if (objstate & DISABLED)
		vst_effects(vdi_handle, 0x0000);

	if (parmblk->ptree[parmblk->obj].ob_flags & RBUTTON)
	{
		xpos += pc->circle_xoffs;
		ypos += pc->circle_yoffs;
		v_circle(vdi_handle, xpos, ypos, pc->outer_radius);
		if (objstate & (SELECTED|CROSSED))
		{
			vsf_interior(vdi_handle, IS_SOLID);
			v_circle(vdi_handle, xpos, ypos, pc->inner_radius);
			vsf_interior(vdi_handle, IS_HOLLOW);
		}
	} else
	{
		boxrect.v_x1 = xpos + pc->box_xoffs;
		boxrect.v_y1 = ypos + pc->box_yoffs;
		boxrect.v_x2 = boxrect.v_x1 + pc->box_xsize;
		boxrect.v_y2 = boxrect.v_y1 + pc->box_ysize;
		v_bar(vdi_handle, (int *)&boxrect);
		if (objstate & (SELECTED|CROSSED))
		{
			int temp;
			v_pline(vdi_handle, 2, (int *)&boxrect);
			temp		 = boxrect.v_x1;
			boxrect.v_x1 = boxrect.v_x2;
			boxrect.v_x2 = temp;
			v_pline(vdi_handle, 2, (int *)&boxrect);
		}
	}

	if (objstate & OUTLINED)
	{
		rc_gtov(&parmblk->drawrect, &boxrect);
		rc_vadjust(&boxrect, 3, 3);
		vswr_mode(vdi_handle, MD_TRANS);
		v_bar(vdi_handle, (int *)&boxrect);
		vswr_mode(vdi_handle, MD_REPLACE);
	}

	vsf_interior(vdi_handle, IS_SOLID);
	vs_clip(vdi_handle, 0, (int *)&cliprect);

	return (objstate & ~(SELECTED|DISABLED|OUTLINED|CROSSED));
}

/*-------------------------------------------------------------------------
 * rsc_cubuttons - Transform all non-exit buttons in a tree to CUA-style.
 *-----------------------------------------------------------------------*/

int rsc_cubuttons(OBJECT *ptree)
{
	OBJECT   *pobj;
	XUSERBLK *pblk;
	int 	  obflags;
	int 	  numobj = 0;

/*
 * do setup stuff...
 */

	if (0 == apl_vshared()) 	/* force open shared workstation, also  */
		return -35; 			/* tests to make sure one is available. */

	if (precalcs.outer_radius == 0) 	/* this must follow apl_vshared() */
		init_precalcs();

/*
 * count the number of button objects we'll be transforming...
 */

	for (pobj = ptree; ; ++pobj)
	{
		obflags = pobj->ob_flags;
		if (	(pobj->ob_type & 0x00FF) == G_BUTTON
			&& !(obflags & (EXIT|DEFAULT))
		   )
			++numobj;

		if (obflags & LASTOB)   		/* stop after doing last	*/
			break;  					/* object in the tree.  	*/
	}


/*
 * allocate a chunk of memory to hold all the XUSERBLKs we're going
 * to attach to the objects.
 */

	if (NULL == (pblk = apl_malloc((long)(numobj * sizeof(*pblk)))))
		return -39;

/*
 * now go through and change each non-exit button object into a USERDEF.
 */

	for (pobj = ptree; ; ++pobj)
	{
		obflags = pobj->ob_flags;
		if (	(pobj->ob_type & 0x00FF) == G_BUTTON
			&& !(obflags & (EXIT|DEFAULT))
		   )
			obj_mxuserdef(pblk++, pobj, cua_draw);

		if (obflags & LASTOB)   		/* stop after doing last	*/
			break;  					/* object in the tree.  	*/
	}

	return 0;
}

/**************************************************************************
 * RSCRRBTN.C - The obj_rrbuttons() routine.
 *   This changes the specified objects into rounded-rectangle radio
 *   buttons (by making them USERDEF objects), and supplies the drawing
 *   routine for the buttons.
 *************************************************************************/

/*-------------------------------------------------------------------------
 * rr_draw - Draw a rounded rectangle radio button.  This routine is
 *           called by the AES whenever a rrbutton needs to be drawn
 *           or to have its state changed.  (Note that this routine
 *           gets control in supervisor mode.  Some runtime libraries
 *           will crash on stack overlow problems if you make calls
 *           to DOS, BIOS, or XBIOS from in here.)
 *
 *           We handle SELECTED and DISABLED states here, but other
 *           states are handled by the AES because we pass the states we
 *           didn't do back to the AES as the retval from this routine.
 *-----------------------------------------------------------------------*/

static long cdecl rr_draw(XPARMBLK *parmblk)
{
	int vdi_handle;
	int xpos;
	int ypos;
	int dmy;
	int len;
	int objstate;
	VRECT cliprect;
	VRECT boxrect;

	if (0 == (vdi_handle = apl_vshared()))
		return 0;   					/* oh well, so sorry */

	objstate = parmblk->currstate;

	rc_gtov(&parmblk->cliprect, &cliprect);
	vs_clip(vdi_handle, 1, (int *)&cliprect);

	rc_gtov(&parmblk->drawrect, &boxrect);
	rc_vadjust(&boxrect, 1, 1);

	len = strlen((char *)parmblk->pub->ob_spec);

	xpos = parmblk->drawrect.g_x +
				((parmblk->drawrect.g_w - gl_wchar * len) / 2);
	ypos = parmblk->drawrect.g_y +
				((parmblk->drawrect.g_h - gl_hchar) / 2);

	if (objstate & SELECTED)
	{
		v_rfbox(vdi_handle, (int *)&boxrect);
		vswr_mode(vdi_handle, MD_TRANS);
		vst_color(vdi_handle, 0);
	} else
	{
		vsf_interior(vdi_handle, IS_HOLLOW);
		v_rfbox(vdi_handle, (int *)&boxrect);
		vsf_interior(vdi_handle, IS_SOLID);
	}

	if (objstate & DISABLED)
		vst_effects(vdi_handle, 0x0002); /* lightened text */

	vst_alignment(vdi_handle, 0, 5, &dmy, &dmy);
	v_gtext(vdi_handle, xpos, ypos, (char *)parmblk->pub->ob_spec);
	vst_alignment(vdi_handle, 0, 0, &dmy, &dmy);
	if (objstate & DISABLED)
		vst_effects(vdi_handle, 0x0000); /* normal text */

	if (objstate & SELECTED)
	{
		vst_color(vdi_handle, 1);
		vswr_mode(vdi_handle, MD_REPLACE);
	}

	vs_clip(vdi_handle, 0, (int *)&cliprect);

	return (objstate & ~(SELECTED|DISABLED));
}

/*-------------------------------------------------------------------------
 * rsc_rrbuttons - Transform all radio buttons into rounded radio buttons.
 *-----------------------------------------------------------------------*/

int rsc_rrbuttons(OBJECT *ptree)
{
	OBJECT   *pobj;
	XUSERBLK *pblk;
	int  obflags;
	int  numobj = 0;

	if (0 == apl_vshared())
		return -35; 			/* no more handles */

/*
 * count the number of button objects we'll be transforming...
 */

	for (pobj = ptree; ; ++pobj)
	{
		obflags = pobj->ob_flags;
		if ((pobj->ob_type & 0x00FF) == G_BUTTON && (obflags & RBUTTON))
			++numobj;

		if (obflags & LASTOB)   		/* stop after doing last	*/
			break;  					/* object in the tree.  	*/
	}

/*
 * allocate a chunk of memory to hold all the XUSERBLKs we're going
 * to attach to the objects.
 */

	if (NULL == (pblk = apl_malloc((long)(numobj * sizeof(*pblk)))))
		return -39;

/*
 * now go through and change each radio button object into a USERDEF.
 */

	for (pobj = ptree; ; ++pobj)
	{
		obflags = pobj->ob_flags;
		if ((pobj->ob_type & 0x00FF) == G_BUTTON && (obflags & RBUTTON))
			obj_mxuserdef(pblk++, pobj, rr_draw);

		if (obflags & LASTOB)   		/* stop after doing last	*/
			break;  					/* object in the tree.  	*/

	}

	return 0;
}

/**************************************************************************
 * RSCSXTYP.C - Set extended object types within a tree.
 *************************************************************************/

void rsc_sxtypes( OBJECT *thetree, ...)
{
	OBJECT *ptree;
	int thisobj;
	int thistype;
	va_list args;

	va_start(args, thetree);
	ptree = thetree;
	for (;;)
	{
		thisobj = va_arg(args, int);
		if (thisobj < 0)
			break;

		thistype = va_arg(args, int);
		ptree[thisobj].ob_type |= thistype << 8;
	}

	va_end(args);
}

/**************************************************************************
 * RSCGSTR.C - Get pointers to object strings from within a tree.
 *************************************************************************/

void rsc_gstrings(OBJECT *thetree, ...)
{
	OBJECT *ptree;
	char  **ppobjstr;
	char  **ppretstr;
	int     thisobj;
	va_list args;

	va_start(args, thetree);
	ptree = thetree;

	for (;;)
	{
		thisobj = va_arg(args, int);
		if (thisobj < 0)
			break;
		ppobjstr  = obj_ppstring(&ptree[thisobj]);
		ppretstr  = va_arg(args, char **);
		*ppretstr = *ppobjstr;
	}

	va_end(args);
}

/**************************************************************************
 * RSCSSTR.C - Set pointers to object strings from within a tree.
 *************************************************************************/

void rsc_sstrings(OBJECT *thetree, ...)
{
	OBJECT *ptree;
	char  **ppstr;
	int    thisobj;
	va_list args;

	va_start(args, thetree);
	ptree = thetree;
	for (;;)
	{
		thisobj = va_arg(args, int);
		if (thisobj < 0)
			break;
		ppstr  = obj_ppstring(&ptree[thisobj]);
		*ppstr = va_arg(args, char *);
	}

	va_end(args);
}

/**************************************************************************
 * RSCGTREE.C - rsc_gtrees() function.
 *************************************************************************/

void cdecl rsc_gtrees(int firstparm, ...)
{
	Parms  *pparm = (Parms *)&firstparm;

	while (pparm->idx >= 0)
	{
		rsrc_gaddr(R_TREE, pparm->idx, pparm->pptree);
		++pparm;
	}
}

/**************************************************************************
 * RSCTRFIX.C - Do rsrc_obfix() for all objects in a tree.
 *************************************************************************/

void rsc_treefix(OBJECT *ptree)
{
	int objcounter = -1;

	do {
		rsrc_obfix(ptree, ++objcounter);
	} while (!(ptree[objcounter].ob_flags & LASTOB));
}
