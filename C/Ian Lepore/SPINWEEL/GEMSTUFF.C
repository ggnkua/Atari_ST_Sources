
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/***********************************************************************
 *
 * Common GEM support routines for SPINWEEL.
 *
 ***********************************************************************/

#include "datadefs.h"
#include "fastplot.h"

/***********************************************************************
 *
 * prg_init - GEM and program-specific initialization stuff.
 *
 ***********************************************************************/

void
prg_init()
{
	float	work;
	int 	dmy,
			counter;
			
/*-------------------------------------------------------------------------
 * Init some pre-set conditions...
 *-----------------------------------------------------------------------*/

	menu_displayed = FALSE;
	rsrc_is_loaded = FALSE;
	new_shape	   = TRUE;
	pen_color	   = 1;
	wi_handle	   = NO_WINDOW;

/*-------------------------------------------------------------------------
 * Save the original color pallete.  Doing this first lets us exit the
 * program at any point from here on out with the assurance that the
 * color pallete can be restored correctly.
 *-----------------------------------------------------------------------*/

	for (counter = 0; counter < 16; counter++)
		save_pallete[counter] = (int)Setcolor(counter, -1);

/*-------------------------------------------------------------------------
 * AES and VDI init.
 *	v1.3 - Added Getrez() call for GDOS compatibility, per Atari specs.
 *-----------------------------------------------------------------------*/

	appl_init();
	vdi_handle = graf_handle(&dmy, &dmy, &dmy, &dmy);
	work_in[0] = Getrez() + 2;
	v_opnvwk(work_in, &vdi_handle, work_out);

/*-------------------------------------------------------------------------
 * Allocate a screen buffer, complain and die if there's not enough memory.
 *-----------------------------------------------------------------------*/

	if (NULL == (scrnbuffer = (char *)Malloc(32000L))) {
		form_alert(1,no_mem_alert);
		prg_exit();
	}

/*-------------------------------------------------------------------------
 * Load the RSC file, complain and die if the load fails.
 *-----------------------------------------------------------------------*/
	 
	if (!rsrc_load(RSRCFILE)) {
		form_alert(1, no_rsrc_alert);
		prg_exit();
	}
	else {
		rsrc_is_loaded = TRUE;
	}

/*-------------------------------------------------------------------------
 * Get object tree addresses...
 *-----------------------------------------------------------------------*/
	
	rsrc_gaddr(R_TREE, MENUTREE, &menutree);	/* menubar */
	rsrc_gaddr(R_TREE, INFOTREE, &infotree);	/* About Spinweel */
	rsrc_gaddr(R_TREE, COLRTREE, &colrtree);	/* Select pen color */
	rsrc_gaddr(R_TREE, SPEDTREE, &spedtree);	/* Set drawing speed */
	rsrc_gaddr(R_TREE, SIZETREE, &sizetree);	/* Buttons for sizing gears */
	rsrc_gaddr(R_TREE, SMTHTREE, &smthtree);	/* Set smoothness */
	rsrc_gaddr(R_TREE, HELPTREE, &helptree);	/* Set smoothness */
	rsrc_gaddr(R_TREE, SSAMTREE, &ssamtree);	/* Set screen access method */

/*-------------------------------------------------------------------------
 * Center object trees that display as centered, tweak the x/y coords
 * of those that don't...
 *-----------------------------------------------------------------------*/

	form_center(colrtree, &dmy, &dmy, &dmy, &dmy); 
	form_center(spedtree, &dmy, &dmy, &dmy, &dmy);
	form_center(smthtree, &dmy, &dmy, &dmy, &dmy);
	
	sizetree->ob_x = 1; 	/* Buttons for sizing the gears (new shape	  */
	sizetree->ob_y = 1; 	/* dialogs) always appear in upperleft corner */

	spedtree->ob_x = 2; 	/* Set speed display always appears centerleft*/

/*-------------------------------------------------------------------------
 * Set up some screen-specific stuff...
 *	The y_scale is calc'd from the pixel aspect ratio (VDI work_out[3/4]).
 *-----------------------------------------------------------------------*/

	max_col = work_out[0];
	max_row = work_out[1];
	mid_col = max_col / 2;
	mid_row = max_row / 2;

	scrnrect.g_x = 0;
	scrnrect.g_y = 0;
	scrnrect.g_w = max_col;
	scrnrect.g_h = max_row;

	y_scale  = (float)work_out[3] / (float)work_out[4];

/*-------------------------------------------------------------------------
 * Set up clipping and output options for VDI and FastPlot. 
 *-----------------------------------------------------------------------*/

	vs_clip(vdi_handle, TRUE, &scrnrect);

	vsf_interior(vdi_handle,  FALSE);
	vsf_perimeter(vdi_handle, TRUE);

	fpl_sclip(&scrnrect);		  /* Set FastPlot clipping rectangle. */
	fpl_sxlate(FPL_VDIXLATE);	  /* Set FastPlot color xlation to VDI mode.*/

/*-------------------------------------------------------------------------
 * Set up a few rez-dependant things...
 * If Getrez() returns one of the standard system rez values, set the 
 * screen access method to FASTPLOT, and set the dialog button for 
 * FASTPLOT to SELECTED.  If we get an unknown rez value back, set the 
 * access method to VDI, and disable the dialog button for FASTPLOT.
 *
 * v1.6: Disable the color-related menu items if running in high rez.
 *-----------------------------------------------------------------------*/

	scrnbase	= (char *)Logbase();
	resolution	= (int)Getrez();
	num_colors	= work_out[13];
	idx_bgcolor = num_colors - 1;
	
	switch (resolution) {
	 case 2:
		menu_ienable(menutree, MOPTPALT, FALSE);
		menu_ienable(menutree, MOPTSPEN, FALSE);
		/* fall thru */
	 case 0:
	 case 1:
		scrnaccess = FASTPLOT;
		ssamtree[SSAMBRFP].ob_state = SELECTED;
		ssamtree[SSAMBRVP].ob_state = NORMAL;
		break;
	 default:
		scrnaccess = VDIPLOT;
		ssamtree[SSAMBRFP].ob_state = DISABLED;
		ssamtree[SSAMBRVP].ob_state = SELECTED;
		break;
	 }

/*-------------------------------------------------------------------------
 * Set up a blit MFDB for saving and restoring the screen via blits.
 *	vq_extend gives the number of bit planes, other values can be calc'd.
 *-----------------------------------------------------------------------*/

	vq_extnd(vdi_handle, 1, work_out);
	
	ssavefdb.fd_nplanes = work_out[4];
	ssavefdb.fd_stand	= 0;
	ssavefdb.fd_w		= 1 + max_col;
	ssavefdb.fd_h		= 1 + max_row;	 
	ssavefdb.fd_wdwidth = (ssavefdb.fd_w + 15) / 16;
	ssavefdb.fd_addr	= (FDADDR)scrnbuffer;

/*-------------------------------------------------------------------------
 * Set up and open the window...
 *-----------------------------------------------------------------------*/

	wind_get(0, WF_WORKXYWH, 
		  &deskrect.g_x, &deskrect.g_y, &deskrect.g_w, &deskrect.g_h);
		  
	wi_handle = wind_create(0,deskrect);  /* WI_KIND = 0 */
	wind_open(wi_handle,deskrect);		  /* open to full desktop size */

/*-------------------------------------------------------------------------
 * Set up the polyline indicies for outlining the window...
 *-----------------------------------------------------------------------*/

	pl_desk[0] = pl_desk[10] = pl_desk[12] = pl_desk[14] = deskrect.g_x;
	pl_desk[1] = pl_desk[3]  = pl_desk[5]  = pl_desk[15] = deskrect.g_y;
	
	pl_desk[2] = pl_desk[4]  = pl_desk[6]  = pl_desk[8]  = 
										deskrect.g_x + deskrect.g_w - 1;
										
	pl_desk[7] = pl_desk[9]  = pl_desk[11] = pl_desk[13] = 
										deskrect.g_y + deskrect.g_h - 1;

/*-------------------------------------------------------------------------
 * If the background color isn't black, swap FG<->BG colors.
 *-----------------------------------------------------------------------*/

	if (save_pallete[idx_bgcolor] == 0) {
		Setcolor(0, 0);
		Setcolor(idx_bgcolor, save_pallete[0]);
	}

/*-------------------------------------------------------------------------
 * Set up default gears and pen position, so that we don't crash if the
 * user selects 'draw' before selecting 'new shape'.
 *-----------------------------------------------------------------------*/

	fix_irad = 30;
	fix_col  = mid_col;
	fix_row  = mid_row;

	rol_irad = 12;
	rol_col  = fix_col + fix_irad + rol_irad;
	rol_row  = fix_row;

	pen_pos  = 25;

/*-------------------------------------------------------------------------
 * All done, clear the screen, put up the menu, and return to main routine.
 *-----------------------------------------------------------------------*/

	clr_scrn();
	menu_on();
	graf_mouse(ARROW,0L);
}

/***********************************************************************
 *
 * prg_exit - Cleanup and exit progam.
 *
 ***********************************************************************/

void
prg_exit()
{
	Setpallete(save_pallete);		/* Restore the original color pallete */

	if (wi_handle != NO_WINDOW) {	/* If a window has been opened, shut  */
		wind_update(FALSE); 		/* it down gracefully.				  */
		wind_close(wi_handle);
		wind_delete(wi_handle);
	}

	if (menu_displayed) 			/* If a menu bar is displayed,		 */
		menu_bar(menutree,0);		/* remove it.						 */

	if (rsrc_is_loaded) 			/* If the RSC file got loaded,		 */
		rsrc_free();				/* unload it.						 */
	
	v_clsvwk(vdi_handle);			/* Close workstation.				 */
	appl_exit();					/* Say Goodbye to AES.				 */
	Pterm(0);

}

/***********************************************************************
 *
 * do_redraw - Standard redraw message handler.
 *	The screen blitting routine is called for each rectangle in the 
 *	redraw list.
 *
 ***********************************************************************/

void
do_redraw(t2)
	register GRECT *t2;
{
	register int   calltype;
	GRECT		   t1;

	calltype = WF_FIRSTXYWH;
	
	do	{
		wind_get(wi_handle, calltype, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
		if (t1.g_w && t1.g_h && rc_intersect(t2, &t1)) {
			t1.g_w--;
			t1.g_h--;
			scrn_blit(BLIT_RSTRSCRN, &t1);
		}
		calltype = WF_NEXTXYWH;
	} while (t1.g_w && t1.g_h);

}

/***********************************************************************
 *
 * clr_screen - Clear the screen, using the appropriate routine.
 *
 ***********************************************************************/

void
clr_screen()
{
	graf_mouse(M_OFF,0L);
	if (scrnaccess == VDIPLOT) {
		v_clrwk(vdi_handle);
	} else {
		fpl_clrscrn();				/* FastPlot clear routine */
	}
	graf_mouse(M_ON,0L);
}

/***********************************************************************
 *
 * scrn_blit - Blit the screen contents to/from the screen buffer.
 *
 ***********************************************************************/

void
scrn_blit(dirflag, blitrect)
	int 			dirflag;
	register GRECT	*blitrect;
{
	long			dmyfdb = 0L;
	struct	{
			VRECT	srce;
			VRECT	dest;
			} blitcntl;

	graf_mouse(M_OFF, 0L);

	rc_gtov(blitrect, &blitcntl.srce);
	rc_gtov(blitrect, &blitcntl.dest);

	if (dirflag == BLIT_SAVESCRN) 
		vro_cpyfm(vdi_handle, S_ONLY, &blitcntl, &dmyfdb, &ssavefdb);
	else
		vro_cpyfm(vdi_handle, S_ONLY, &blitcntl, &ssavefdb, &dmyfdb);

	graf_mouse(M_ON, 0L);
	
}

/***********************************************************************
 *
 * Outline the window (desk area) in current pen color, if menu is on.
 *
 *	Oddly enough, it's much faster to do this with a polyline call than
 *	by using one of the rectangle/box calls.
 ***********************************************************************/

void
wind_outline()
{
	if (menu_displayed) {
		graf_mouse(M_OFF, 0L);
		vswr_mode(vdi_handle, MD_REPLACE);
		vsl_type(vdi_handle, 1);
		vsl_color(vdi_handle, pen_color);
		v_pline(vdi_handle, 8, pl_desk);
		graf_mouse(M_ON, 0L);
	}
}

/***********************************************************************
 *
 * turn menu bar on/off.
 *
 ***********************************************************************/

void
menu_on()
{
	if (!menu_displayed) {
		scrn_blit(BLIT_SAVESCRN, &scrnrect);
		menu_bar(menutree, TRUE);
		menu_displayed = TRUE;
	}
}

void
menu_off()
{
	if (menu_displayed) {
		menu_bar(menutree, FALSE);
		scrn_blit(BLIT_RSTRSCRN, &scrnrect);
		menu_displayed = FALSE;
	}
}

/**************************************************************************
 *
 * find_boxchar - Return the object index of a child boxchar with a given
 *				  letter in its box, or -1 if no matching object is found.
 *
 *	Say what?  Well, this routine cruises through all the children of a 
 *	given parent object, and for every boxchar type object found the char
 *	in the box is compared to the char passed to this routine.	On the 
 *	first match found, the object index of the matching object is returned.
 *	(Note that the object type is masked with 0x00FF to strip out any
 *	extended object type info, so that the object type compare will work).
 *	
 *	Why do this, you wonder?  Well, boxchar objects make great radio
 *	buttons, especially for things like selecting a device, or a color
 *	intensity from 0-7, or whatever.  In the case of device selection, 
 *	you need to have buttons for A-P, but on most systems, there won't
 *	be this many devices, and you'll need to set some of the buttons
 *	(boxchars) to DISABLED.  Since you'll be doing this at runtime, you
 *	need a way to find the corresponding button for each device.  It is
 *	AN ABSOLUTE NO-NO to hard-code object indicies (names) or treat the 
 *	objects as an array, because as soon as you do some user will come	
 *	along with a resouce editor & re-sort your objects.  Then the user will
 *	complain when s/he clicks on the drive A button, and drive B gets
 *	formatted instead.
 *
 *************************************************************************/

int
find_boxchar(tree, parent, boxchar)
	register OBJECT *tree;
	register int	parent;
	register char	boxchar;
{
	register int kid;

	kid = tree[parent].ob_head;

	while ( (kid != parent) && (kid >= R_TREE) ) {
		if ((0x00FF & tree[kid].ob_type) == G_BOXCHAR) {
			if (boxchar == (char)(tree[kid].ob_spec >> 24)) {
				return(kid);
			}
		}
		kid = tree[kid].ob_next;
	}
	return(-1);
}
