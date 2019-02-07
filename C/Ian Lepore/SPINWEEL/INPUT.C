
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/**************************************************************************
 *
 * Input routines for SPINWEEL.
 *
 *************************************************************************/

#include "datadefs.h"
#include "aesblit.h"

/**************************************************************************
 *
 * snap - Snap mouse x/y to nearest grid point.  
 *
 *	 Unfinished: currently forces x/y to screen center.  The point of this
 *	   was to allow shapes to be drawn on arbitrary centers, other than
 *	   just the center of the screen.  Perhaps someone with more energy
 *	   than I have can implement this feature...
 *
 *************************************************************************/

static void
snap(x,y) 
	int *x, *y;
{
	*x = mid_col;
	*y = mid_row;
}

/**************************************************************************
 *
 * drawbox - Convert a box described by a VRECT (diag corners) to a set
 *			 of 8 polyline indicies, then call v_pline to draw the box.
 *			 Oddly enough, this is MUCH faster than calling v_bar to draw
 *			 a hollow box.
 *
 *************************************************************************/

static void
drawbox(boxrect)
	VRECT boxrect;
{
	int box[16];
	
	graf_mouse(M_OFF,0L);
	
	box[0]	= boxrect.v_x1; 		/* left line start point */ 
	box[1]	= boxrect.v_y1; 	
	box[2]	= boxrect.v_x1; 		/* left line end   point */
	box[3]	= boxrect.v_y2; 	
	
	box[4]	= boxrect.v_x1; 		/* bottom line start point */
	box[5]	= boxrect.v_y2; 	
	box[6]	= boxrect.v_x2; 		/* bottom line end	 point */
	box[7]	= boxrect.v_y2;
	
	box[8]	= boxrect.v_x2; 		/* right line start point */
	box[9]	= boxrect.v_y2;
	box[10] = boxrect.v_x2; 		/* right line end	point */
	box[11] = boxrect.v_y1;
	
	box[12] = boxrect.v_x2; 		/* top line start point */
	box[13] = boxrect.v_y1; 
	box[14] = boxrect.v_x1; 		/* top line end   point*/
	box[15] = boxrect.v_y1; 
	
	v_pline(vdi_handle, 8, box);	/* Draw box */

	graf_mouse(M_ON,0L);

}

/**************************************************************************
 *
 * cntr_rubberbox - Like graf_rubberbox, except box remains centered.
 *					
 *	Min width/height not supported, but a zero radius is prevented. 
 *
 *	If fixx or fixy is non-zero, centered box is kept tangent to
 *	fixx or fixy, and is kept centered on the other axis.
 *
 *	The return value may be positive or negative, indicating the 
 *	final x in relation to fixx, or midx if fixx is zero.
 *
 *************************************************************************/

static int
cntr_rubberbox(midx, midy, fixx, fixy, p_endx, p_endy)
	int 	midx, 
			midy, 
			fixx, 
			fixy, 
			*p_endx, 
			*p_endy;
{
	register int	oldx, 
					oldy, 
					wrkx, 
					wrky;
	int 			mousex, 
					mousey, 
					mouseb, 
					radius, 
					dmy;

	vswr_mode(vdi_handle, MD_XOR);			   /* XOR mode */

	do	{									   /* Until non-zero radius */

		wrkx = oldx = midx; 
		wrky = oldy = midy;
		drawbox(oldx, oldy, wrkx, wrky);	   /* Draw initial box */

		do	{								   /* Do centered rubberbox */

			graf_mkstate(&mousex, &mousey, &mouseb, &dmy);
			
			if ((oldx != mousex) || (oldy != mousey)) {
			
				graf_mouse(M_OFF,0L);
				drawbox(oldx, oldy, wrkx, wrky);

				oldx = mousex;
				oldy = mousey;
				wrkx = (fixx) ? fixx : (midx - (oldx - midx));
				wrky = (fixy) ? fixy : (midy - (oldy - midy));

				drawbox(oldx, oldy, wrkx, wrky);
				graf_mouse(M_ON,0L);
			}		   

		} while (mouseb);					/* Until button is released */

		drawbox(oldx, oldy, wrkx, wrky);	/* Erase last box */

		if (fixx)
			radius = (oldx - fixx) / 2;
		else
			radius = oldx - midx;

		if (!radius) {						/* Complain about 0 radius */
			form_alert(1,zero_rad_alert);
			evnt_button(1,1,1,&dmy, &dmy, &dmy, &dmy); /* Wait for hot button after alert */
			graf_mouse(POINT_HAND, 0L);
		}

	} while (radius == 0);				   /* Loop until non-0 radius */

	if (p_endx) 
		*p_endx = oldx; 					 /* Set return values if we */
	if (p_endy) 
		*p_endy = oldy; 					 /* got pointers to them.	*/

	return(radius);
}

/**************************************************************************
 *
 * get_penpos - Get new pen position via a rubberband line.
 *
 *************************************************************************/

static void 
get_penpos(mx, my)
	int mx, my; 	/* Starting mouse x/y */
{
	int mousex, 
		mousey, 	
		mouseb, 
		pxy[4], 
		dmy, 
		oldx, 
		oldy;

	vswr_mode(vdi_handle,MD_XOR);				 /* XOR mode */

	pxy[0] = oldx = mx;
	pxy[1] = oldy = my;
	pxy[2] = rol_col;
	pxy[3] = rol_row;
	
	graf_mouse(M_OFF,0L);
	v_pline(vdi_handle, 2, pxy);		/* draw initial line */
	graf_mouse(M_ON,0L);	

	do	{
		graf_mkstate(&mousex, &mousey, &mouseb, &dmy);
		if ((mouseb == 1) && ((mousex != oldx) || (mousey != oldy))) {
			graf_mouse(M_OFF, 0L);
			v_pline(vdi_handle, 2, pxy);  /* erase current line */
			pxy[0] = oldx = mousex;
			pxy[1] = oldy = mousey;
			v_pline(vdi_handle, 2, pxy);  /* draw new line */
			graf_mouse(M_ON, 0L);
		}
	} while (mouseb == 1);

	pen_pos = rol_col - mousex;
	pen_pos = ABS(pen_pos);
}	 

/**************************************************************************
 *
 * show_shapes - Display shapes and pen position.
 *
 *************************************************************************/

static void
show_shapes()
{
	int  pxy[4];

	scrn_blit(BLIT_RSTRSCRN, &scrnrect);

	pxy[0] = rol_col = fix_col + fix_irad + rol_irad;
	pxy[1] = rol_row = fix_row;
	pxy[2] = rol_col + pen_pos;
	pxy[3] = rol_row;

	graf_mouse(M_OFF,0L);
	vswr_mode(vdi_handle,MD_TRANS);
	v_circle(vdi_handle, fix_col, fix_row, fix_irad);
	v_circle(vdi_handle, rol_col, rol_row, rol_irad);
	v_pline(vdi_handle,2,pxy);
	graf_mouse(M_ON,0L);
}

/**************************************************************************
 *
 * get_shapes - Place and size shape(s).
 *
 *************************************************************************/

void
get_shapes()
{
	int done, 
		cur_option, 
		new_option,
		dmy,
		mousex, 
		mousey, 
		mouseb;

	vsl_color(vdi_handle,1);					 /* Foreground line color */
	vsf_color(vdi_handle,1);					 /* Foreground fill color */
	vsf_interior(vdi_handle, VIP_HOLLOW);
	vsf_perimeter(vdi_handle, TRUE);
	
	show_shapes();

	cur_option = objrb_which(sizetree, R_TREE);
	if (cur_option == -1) {
		cur_option = SIZEBRFX;
		objst_change(sizetree, cur_option, SELECTED, TRUE);
	}

	done = FALSE;
	objc_draw(sizetree, R_TREE, MAX_DEPTH, scrnrect);
	do	{
		evnt_button(1,1,1, &mousex, &mousey, &mouseb, &dmy);
		new_option = objc_find(sizetree, R_TREE, MAX_DEPTH, mousex, mousey);
		if (new_option != -1) {
			if ( ! (sizetree[new_option].ob_state & DISABLED)) {
				objst_change(sizetree, cur_option, ~SELECTED, TRUE);
				objst_change(sizetree, new_option,	SELECTED, TRUE);
				cur_option = new_option;
				evnt_button(1,1,0, &dmy, &dmy, &dmy, &dmy);
				if (new_option == SIZEBXDN) {
					done = TRUE;
					objst_change(sizetree, new_option, ~SELECTED, FALSE);
				}
			}
		}
		else {
			scrn_blit(BLIT_RSTRSCRN, &sizetree->ob_x);
			graf_mouse(POINT_HAND,0L);
			switch(cur_option) {
			case SIZEBRFX:
				fix_col = mousex; 
				fix_row = mousey;
				snap(&fix_col, &fix_row);
				fix_irad = cntr_rubberbox(fix_col, fix_row, 0, 0, 0L, 0L);
				fix_irad = ABS(fix_irad);
				break;
			case SIZEBRRL:
				rol_irad = cntr_rubberbox(fix_col, fix_row, (fix_col + fix_irad), 0, 0L, 0L);
				break;
			case SIZEBRPP:
				get_penpos(mousex, mousey);
				break;
			} /* END switch (cur_option) */

			show_shapes();
			objc_draw(sizetree, R_TREE, MAX_DEPTH, scrnrect);
			graf_mouse(ARROW,0L);

		} /* END not (new_option) */

	} while (!done); 

	new_shape = TRUE;
}

/**************************************************************************
 *
 * get_speed - Get drawing speed via graf_slidebox.
 *
 *************************************************************************/

int
get_speed()
{
	int 		mousex, 
				mousey, 
				mouseb, 
				scal_y,
				scal_h,
				slid_y,
				slid_h,
				dmy, 
				curobj;
	static int	speed = 0;
	GRECT		dialrect;
	
	slid_h = spedtree[SPEDSLID].ob_height;
	scal_h = 100 + slid_h;
	spedtree[SPEDSCAL].ob_height = scal_h;

	objc_offset(spedtree, SPEDSCAL, &dmy, &scal_y);

	objc_xywh(spedtree, R_TREE, &dialrect);
	
	if (0 != aes_blit(AESBLIT_SAVESCRN, &dialrect))
		return(0);

	objc_draw(spedtree, R_TREE, MAX_DEPTH, dialrect);

	graf_mouse(M_ON,0L);

	do	{
		graf_mkstate(&mousex, &mousey, &mouseb, &dmy);
		curobj = objc_find(spedtree, R_TREE, MAX_DEPTH, mousex, mousey);
		if (curobj == SPEDSCAL) {
			slid_y = mousey - scal_y;
			if ((slid_y + slid_h) > scal_h) 
				slid_y -= slid_h;
			spedtree[SPEDSLID].ob_y = slid_y;
			objc_draw(spedtree, SPEDSCAL, MAX_DEPTH, dialrect);
			curobj = SPEDSLID;
		}
	} while ((curobj != SPEDSLID) && (mouseb == 1));

	if (mouseb == 1) 
		speed = graf_slidebox(spedtree, SPEDSCAL, SPEDSLID, 1);
	
	graf_mouse(M_OFF,0L);
	aes_blit(AESBLIT_RSTRSCRN, &dialrect);

	if (speed < 50)
		speed = 0;

	spedtree[SPEDSLID].ob_y = speed / 10;
	return (speed / 5);
}

/**************************************************************************
 *
 * update_smoothpointer - Recalc the location of a pointer within a 
 *	slidebox (for the smoothness dialog), and visually update the pointer
 *	on the screen.
 *
 *************************************************************************/

static void
update_smoothpointer(mx, slideparent, slideobject)
	int 			mx;
	int 			slideparent;
	int 			slideobject;
{
	int 			dmy;
	int 			slid_x,
					slid_w,
					scal_x,
					scal_w;
	register OBJECT *ptree = smthtree;

	objc_offset(ptree, slideparent, &scal_x, &dmy);
	scal_w = ptree[slideparent].ob_width;
	slid_w = ptree[slideobject].ob_width;
	slid_x = mx - scal_x - (slid_w / 2);
	if ((slid_x + slid_w) > scal_w) 
		slid_x = scal_w - slid_w;
	if (slid_x < 0)
		slid_x = 0;
	ptree[slideobject].ob_x = slid_x;
	objc_draw(ptree, slideparent, MAX_DEPTH, deskrect);
	
}

/**************************************************************************
 *
 * int_2_asc - Convert an int to a 2-byte ascii value.	The int must be
 *	in the range of 00-99 or ugly things will happen.
 *
 *************************************************************************/

static void
int_2_asc(string, value)
	register char string[];
	register int  value;
{
	string[2] = 0x00;
	string[1] = '0' + value % 10;
	string[0] = '0' + value / 10;
}

/**************************************************************************
 *
 * get_smoothness - Set the drawing 'smoothness' via slidebox dialogs.
 *
 *	'Smoothness' means the spacing between the dots, and actually 
 *	 translates into the angle-increment value used in the spyro calcs.
 *	 Since this a floating point value in the (practical) range of 
 *	 0.01 - 20.0, we use 2 slideboxes in the dialog: one to set the 
 *	 integer part of the value, one to set the fractional part.  This
 *	 may seem clumsy at first, but it was MUCH easier to code for.
 *
 *************************************************************************/

void
get_smoothness()
{
	int 			position;
	int 			exitobject;
	int 			slideparent;
	int 			slideobject;
	int 			mx, my;
	int 			dmy;
	register OBJECT *ptree = smthtree;
	GRECT			dialrect;
	static int		initdone   = FALSE;
	static int		cadj_value = 2;
	static int		fadj_value = 0;
	static char 	cadj_string[3] = "02";
	static char 	fadj_string[3] = "00";

	if (initdone == FALSE) {
		initdone = TRUE;
		ptree[SMTHSTCA].ob_spec = (long)cadj_string;
		ptree[SMTHSTFA].ob_spec = (long)fadj_string;
	}

	objc_xywh(ptree, R_TREE, &dialrect);
	rc_gadjust(&dialrect, 3, 3);
	form_dial(FMD_START, 0,0,0,0, dialrect);
	
	objc_draw(ptree, R_TREE, MAX_DEPTH, dialrect);
	
	do	{
		exitobject = 0x7FFF & form_do(ptree, 0);
		if (exitobject != SMTHBXOK) {
			graf_mkstate(&mx, &my, &dmy, &dmy);
			
			slideparent = objc_find(ptree, SMTHPBSL, 1, mx, my);

			if (slideparent != -1 && ptree[slideparent].ob_type == G_BOX) {

				slideobject = find_boxchar(ptree, slideparent, '\001');
				if (slideobject != exitobject) {
					update_smoothpointer(mx, slideparent, slideobject);
				}

				position = graf_slidebox(ptree, slideparent, slideobject, 0);

				graf_mkstate(&mx, &my, &dmy, &dmy);
				update_smoothpointer(mx, slideparent, slideobject);

				if (slideobject == SMTHPTCA) {
					cadj_value = (position + 15) / 40;
				}
				else {
					fadj_value = (position + 9) / 10;
					if (fadj_value == 100)
						fadj_value = 99;
				}
				
				smoothness = ((float)cadj_value) + (((float)fadj_value) / 100.0);
				if (smoothness == 0.0) {
					smoothness == 0.01;
					fadj_value = 1;
				}
				int_2_asc(cadj_string, cadj_value);
				int_2_asc(fadj_string, fadj_value);
				objc_draw(ptree, SMTHPBVL, MAX_DEPTH, dialrect);
			}
		}
	} while (exitobject != SMTHBXOK);
	
	ptree[exitobject].ob_state &= ~SELECTED;

	form_dial(FMD_FINISH, 0,0,0,0, dialrect);
}

