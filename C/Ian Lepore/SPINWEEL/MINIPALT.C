
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/***********************************************************************
 *
 * mini_pallete - A little control-panel-like color pallete dialog.
 *
 * Usage:
 *		  int mini_pallete();
 *
 * Upon Exit:
 *		  0 	- Indicates success.
 *		 <0 	- Negative returns are bad status values from aes_blit,
 *				  most generally -39 (blit buffer too small, should never 
 *				  happen), or -2 (no VDI handles available).
 * Notes:
 *
 *	This code is completely self-contained, and has no init hook to call.
 *	The only constraint is that the calling application must do the
 *	appl_init() call before the first call to mini_pallete().
 *
 * Related Modules:
 *
 *	  aesblit.c - Screen save/restore routine.
 *	  aesblit.h - Header file for blit routine.
 *
 * 03/30/89 - v1.0
 * 06/18/89 - v1.1 - Screen under the dialog box is now saved/restored
 *					 via bit blit, so the caller doesn't need to have
 *					 any window-redraw logic implemented.
 * 08/23/89 - v1.2 - Added *all* non-standard utils to this source file
 *					 as static functions (objst_change, etc).  At this
 *					 point I'm way more concerned about compiler/library
 *					 compatibility than I am about saving a few hundred
 *					 bytes of program size.
 ***********************************************************************/

#include "gemfast.h"	/* equivelent to standard OBDEFS.H+GEMDEFS.H */
#include <osbind.h>
#include "aesblit.h"

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

#define Getcolor(a) ((int)(Setcolor((a), -1)))

/**************************************************************************
 *
 * palttree - The color pallete dialog tree.
 *
 *	This is NOT the output from a resource editor (it was a long time ago,
 *	but it's been pretty much re-done by hand).
 *
 *	About extended object types... 
 *
 *	The ob_type field is a word, but the AES only uses the lower byte of 
 *	it.  It has become a sort of standard technique for programs to use
 *	the upper byte for their own evil purposes.  (Really, the object 
 *	structure should have had an 'ob_apspec' longword in it for the 
 *	application's use).  
 *
 *	For example, suppose you have 10 strings in a dialog box.  You want to
 *	set the ob_spec pointers at runtime to correspond to the elements in
 *	an array of strings you've defined in your program.  You can code a
 *	lot of C statements using the hard-coded object names, but what if you
 *	have 50 strings instead of 10?	More to the point, what if some hacker
 *	edits the .RSC file and changes the order of the objects? Bombs, that's
 *	what.  So, you can (with most resource editors) set the extended 
 *	object type for the strings to the numbers 1-10, then at runtime you
 *	can scan the tree looking for an object with an extended type of 1,
 *	then set the first string pointer, then scan for 2, and so on.	Now,
 *	no matter where those strings get moved to in the tree structure, they
 *	will be found at runtime and pointers will be assigned properly.
 *
 *	Now that I've described this nifty string-thing, I should mention that
 *	this program doesn't use that techique, as it contains no strings in
 *	the dialog. 
 * 
 *	This program uses the extended object type to hold the TOS color index
 *	value that corresponds to the colored box which is the object.	This
 *	is due to the screwy way the ST maps TOS colors to VDI colors.	If you
 *	compare the VDI/object color number in the ob_spec field to the extended
 *	object type value, you'll see the translation table that maps TOS colors
 *	to GEM colors.	For the ob_type values below which are not described
 *	by name, the format is 0xcc14, where 'cc' is the TOS color number, and
 *	'14' is a box type object.
 *
 *	The ob_spec field for box-like objects maps out as follows:
 *	 0xaabbcdef
 *	   |||||||+-- inside fill color
 *	   ||||||+--- fill pattern and opaque/transparent flag
 *	   |||||+---- text color
 *	   ||||+----- border color
 *	   ||++------ border thickness (neg = outside width, pos = inside width)
 *	   ++-------- ASCII character for boxchar objects, zero for other types
 *
 *************************************************************************/

static char    pal_r[] = "R",
			   pal_g[] = "G",
			   pal_b[] = "B";

#define SELEXIT  (SELECTABLE|EXIT)
#define RBTEXIT  (RBUTTON|TOUCHEXIT)
#define SRBTEXIT (SELECTABLE|RBUTTON|TOUCHEXIT)

OBJECT	palttree[] = {

/*			type	   flags   state   ob_spec	   x	   y	   w		h	*/

-1,  1, 35, G_BOX,	   NONE,	 0, 0x00FF1100L, 0x0000, 0x0000, 0x0212, 0x0607,

 2, -1, -1, G_BOXCHAR, SELEXIT,  0, 0x05FF1100L, 0x0000, 0x0000, 0x0501, 0x0101,
 3, -1, -1, G_BOX,	   TOUCHEXIT,0, 0x00FF1121L, 0x0701, 0x0000, 0x0310, 0x0101,

 7,  4,  6, G_IBOX,    NONE,	 0, 0x00001101L, 0x0100, 0x0301, 0x0401, 0x0703,
 5, -1, -1, G_BOXCHAR, NONE,	 0, 0x52001100L, 0x0200, 0x0100, 0x0001, 0x0001,
 6, -1, -1, G_BOXCHAR, NONE,	 0, 0x47001100L, 0x0200, 0x0401, 0x0001, 0x0001,
 3, -1, -1, G_BOXCHAR, NONE,	 0, 0x42001100L, 0x0200, 0x0702, 0x0001, 0x0001,

35,  8, 26, G_IBOX,    NONE,	 0, 0x00001100L, 0x0501, 0x0401, 0x0210, 0x0603,
	
17,  9, 16, G_IBOX,    NONE,	 0, 0x00001100L, 0x0100, 0x0000, 0x0010, 0x0001,
10, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x30FF1100L,  0, 0, 2, 1,
11, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x31FF1100L,  2, 0, 2, 1,
12, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x32FF1100L,  4, 0, 2, 1,
13, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x33FF1100L,  6, 0, 2, 1,
14, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x34FF1100L,  8, 0, 2, 1,
15, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x35FF1100L, 10, 0, 2, 1,
16, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x36FF1100L, 12, 0, 2, 1,
 8, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x37FF1100L, 14, 0, 2, 1,

26, 18, 25, G_IBOX,    NONE,	 0, 0x00001100L, 0x0100, 0x0301, 0x0010, 0x0001,
19, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x30FF1100L,  0, 0, 2, 1,
20, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x31FF1100L,  2, 0, 2, 1,
21, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x32FF1100L,  4, 0, 2, 1,
22, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x33FF1100L,  6, 0, 2, 1,
23, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x34FF1100L,  8, 0, 2, 1,
24, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x35FF1100L, 10, 0, 2, 1,
25, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x36FF1100L, 12, 0, 2, 1,
17, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x37FF1100L, 14, 0, 2, 1,

 7, 27, 34, G_IBOX,    NONE,	 0, 0x00001100L, 0x0100, 0x0602, 0x0010, 0x0001,
28, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x30FF1100L,  0, 0, 2, 1,
29, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x31FF1100L,  2, 0, 2, 1,
30, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x32FF1100L,  4, 0, 2, 1,
31, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x33FF1100L,  6, 0, 2, 1,
32, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x34FF1100L,  8, 0, 2, 1,
33, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x35FF1100L, 10, 0, 2, 1,
34, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x36FF1100L, 12, 0, 2, 1,
26, -1, -1, G_BOXCHAR, SRBTEXIT, 0, 0x37FF1100L, 14, 0, 2, 1,

 0, 36, 51, G_IBOX,    NONE,	 0, 0x00001100L, 0x0000, 0x0205, 0x0212, 0x0302,
37, -1, -1, 0x0014,    RBTEXIT,  0, 0x00011170L, 512,	 512,	 2, 	 1,
38, -1, -1, 0x0814,    RBTEXIT,  0, 0x00000179L, 512,	 769,	 2, 	 1,
39, -1, -1, 0x0114,    RBTEXIT,  0, 0x00001172L, 1026,	 512,	 2, 	 1,
40, -1, -1, 0x0214,    RBTEXIT,  0, 0x00002173L, 1540,	 512,	 2, 	 1,
41, -1, -1, 0x0314,    RBTEXIT,  0, 0x00003176L, 7, 	 512,	 2, 	 1,
42, -1, -1, 0x0414,    RBTEXIT,  0, 0x00000174L, 521,	 512,	 2, 	 1,
43, -1, -1, 0x0514,    RBTEXIT,  0, 0x00001177L, 1035,	 512,	 2, 	 1,
44, -1, -1, 0x0614,    RBTEXIT,  0, 0x00002175L, 1549,	 512,	 2, 	 1,
45, -1, -1, 0x0A14,    RBTEXIT,  0, 0x0000217BL, 1540,	 769,	 2, 	 1,
46, -1, -1, 0x0B14,    RBTEXIT,  0, 0x0000317EL, 7, 	 769,	 2, 	 1,
47, -1, -1, 0x0C14,    RBTEXIT,  0, 0x0000017CL, 521,	 769,	 2, 	 1,
48, -1, -1, 0x0D14,    RBTEXIT,  0, 0x0000117FL, 1035,	 769,	 2, 	 1,
49, -1, -1, 0x0E14,    RBTEXIT,  0, 0x0000217DL, 1549,	 769,	 2, 	 1,
50, -1, -1, 0x0714,    RBTEXIT,  0, 0x00003178L, 16,	 512,	 2, 	 1,
51, -1, -1, 0x0914,    RBTEXIT,  0, 0x0000117AL, 1026,	 769,	 2, 	 1,
35, -1, -1, 0x0F14,(RBTEXIT|LASTOB),0, 0x00003171L, 16, 	769,	2,		1
}; /* END of palttree[] */

/* resource set indicies (names) for objects in palttree */

#define PALTTREE 0	/* root */
#define PALTBXCL 1	/* Close button 							*/
#define PALTBXMV 2	/* Move bar 								*/	
#define PALTPNUM 7	/* Parent box for all the intensity parents */
#define PALTPRED 8	/* Parent box for the RED intensity numbers */
#define PALTPGRN 17 /* Parent box for the GRN intensity numbers */
#define PALTPBLU 26 /* Parent box for the BLU intensity numbers */
#define PALTPCOL 35 /* Parent box for the color-selection boxes */
#define PALTBRC0 36 /* Color selection box number 0 			*/

/**************************************************************************
 *
 * A few variables...
 *
 *************************************************************************/

static struct rgb_settings {
		char red, 
			 grn, 
			 blu, 
			 filler;
		}	   cur_setting;

static GRECT   dialrect;			/* x/y/w/h of the dialog box		  */
static GRECT   deskrect;			/* x/y/w/h of the desktop			  */

static int	   colorobj = PALTBRC0; /* color object (default is box 0)	  */
static int	   coloridx = 0;		/* color index	(default is # 0 )	  */

#ifndef GEMFAST_H	/* compile the utils only if GEMFAST is not available */

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
 *	buttons, especially for things like selecting a device, or in this 
 *	case, a color intensity from 0-7.  In the case of device selection, 
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

static int
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

/**************************************************************************
 *
 * Find the parent object of any given object.
 *
 *	This walks the chain of sibling links until it finds a sibling which
 *	has a tail pointer pointing back to itself, which indicates that we
 *	found the parent, not a sibling after all. (Don't you just *love* GEM?)
 *
 *************************************************************************/

static int
obj_parent(tree, curobj)
	register OBJECT *tree;
	register int	curobj;
{
	register int	nxtobj;
			 
	if (curobj <= R_TREE)	 /* The root of a tree has no parent */
		return(R_TREE);

	while(1) {
		nxtobj = tree[curobj].ob_next;
		if (tree[nxtobj].ob_tail == curobj)
			return(nxtobj);
		curobj = nxtobj;
	}
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

#define objrb_which(a,b) objxrb_which((a),(b),SELECTED)

static int
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

#endif

/**************************************************************************
 *
 * rgb2color - convert cur_settings structure to a TOS color (0x0rgb).
 *
 *************************************************************************/

static int
rgb2color()
{
	return	((cur_setting.red & 0x000F) << 8) | 
			((cur_setting.grn & 0x000F) << 4) | 
			 (cur_setting.blu & 0x000F);
}

/**************************************************************************
 *
 * color2rgb - convert a TOS color to characters in cur_settings.
 *
 *************************************************************************/

static void
color2rgb(color)
	register int color;
{
	cur_setting.red = '0' + ((color >> 8) & 0x000F);
	cur_setting.grn = '0' + ((color >> 4) & 0x000F);
	cur_setting.blu = '0' +  (color 	  & 0x000F);
} 

/**************************************************************************
 *
 * new_color - Change the current selected color box on the screen (like
 *	a radio button), and set the new settings (numbered boxes) to match
 *	the new active color box.
 *
 *	If 'drawflag' is TRUE, the screen is updated with the state changes
 *	(this is the normal state of affairs).	If the flag is FALSE, the
 *	object states are set, but no screen work is done (this is for
 *	initializing the dialog before it is displayed).
 *************************************************************************/

static void
new_color(newobject, drawflag)
	int newobject;
	int drawflag;
{
	register OBJECT *ptree = palttree;
	register int	curobj;
	int 			dmy;

/*-----------------------------------------------------------------------*
 * de-select the numbered radio buttons that show the
 * settings for the current color...
 *-----------------------------------------------------------------------*/

	if (-1 != (curobj = objrb_which(ptree, PALTPRED)))
		objst_change(ptree, curobj, ~SELECTED, drawflag);
	if (-1 != (curobj = objrb_which(ptree, PALTPGRN)))
		objst_change(ptree, curobj, ~SELECTED, drawflag);
	if (-1 != (curobj = objrb_which(ptree, PALTPBLU)))
		objst_change(ptree, curobj, ~SELECTED, drawflag);

/*-----------------------------------------------------------------------*
 * de-select the current color box, change the 'current' color 
 * to the 'new' color, select the new color box...
 *-----------------------------------------------------------------------*/

	objst_change(ptree, colorobj,  ~CROSSED, drawflag);
	objst_change(ptree, newobject,	CROSSED, drawflag);

/*-----------------------------------------------------------------------*
 * change our picture of what's current...
 * the TOS color index is encoded as the extended object type
 * of the color-box objects.
 *-----------------------------------------------------------------------*/
 
	colorobj = newobject;
	coloridx = (ptree[colorobj].ob_type >> 8) & 0x000F;
	color2rgb(Getcolor(coloridx));

/*-----------------------------------------------------------------------*
 * select the appropriate numbered boxes to represent the color
 * intensity settings for the newly-selected color...
 *-----------------------------------------------------------------------*/
 
	if (-1 != (curobj = find_boxchar(ptree, PALTPRED, cur_setting.red)))
		objst_change(ptree, curobj,  SELECTED, drawflag);
	if (-1 != (curobj = find_boxchar(ptree, PALTPGRN, cur_setting.grn)))	
		objst_change(ptree, curobj,  SELECTED, drawflag);
	if (-1 != (curobj = find_boxchar(ptree, PALTPBLU, cur_setting.blu)))
		objst_change(ptree, curobj,  SELECTED, drawflag);

/* all done */

}
	 
/**************************************************************************
 *
 * new_settings - Process a click in a numbered box of the dialog, and
 *	change the color in the TOS color pallete correspondingly.
 *
 *************************************************************************/

static void
new_settings(newobject)
	int newobject;
{
	char boxchar;

	boxchar = (char)(palttree[newobject].ob_spec >> 24);

	switch (obj_parent(palttree, newobject)) {
		case PALTPRED:
			cur_setting.red = boxchar;
			break;
		case PALTPGRN:
			cur_setting.grn = boxchar;
			break;
		case PALTPBLU:
			cur_setting.blu = boxchar;
			break;
	}
	 
	Setcolor(coloridx, rgb2color());

/* all done */

}

/**************************************************************************
 *
 * move_dbox - Process a click in the movebar of the dialog box.  The
 *	d-box looks like a window, complete with movebar, so this routine
 *	sorta simulates what the AES does to move a window about.
 *
 *************************************************************************/

static void
move_dbox()
{
	register GRECT	*prect = &dialrect;
	register OBJECT *ptree = palttree;

/*-----------------------------------------------------------------------*
 * Get the current x/y/w/h of the displayed dialog box, adjust the 
 * rectangle to be 1 pixel bigger on all sides for blitting.
 *-----------------------------------------------------------------------*/

	objc_xywh(ptree, R_TREE, prect);
	rc_gadjust(prect, 1, 1);

/*-----------------------------------------------------------------------*
 * Call dragbox to let the user move the dialog box like it was a window.
 * Set the mouse-control semaphore so that no mouse events pass through 
 * to the window underneath the dialog box.
 *-----------------------------------------------------------------------*/

	wind_update(BEG_MCTRL);
	graf_dragbox(prect->g_w,  prect->g_h,
				 prect->g_x,  prect->g_y,
				 deskrect,
				 &(ptree->ob_x), &(ptree->ob_y));
	wind_update(END_MCTRL);

/*-----------------------------------------------------------------------*
 * When the user lets go of the mouse button, we have the new dialog box
 * location, so do a blit to restore the screen under the current location,
 * then calc the new x/y/w/h of the box, adjust it, save the screen under
 * the new location, then redraw the dialog box.
 *-----------------------------------------------------------------------*/

	aes_blit(AESBLIT_RSTRSCRN, prect);

	objc_xywh(palttree, R_TREE, prect);
	rc_gadjust(prect, 1, 1);

	aes_blit(AESBLIT_SAVESCRN, prect);
	objc_draw(palttree,  R_TREE, MAX_DEPTH, *prect);

/* all done */

}

/**************************************************************************
 *
 * init_paldialog - One-time setup of pallete dialog stuff.
 *
 *************************************************************************/

static void
init_paldialog()
{
	int dmy;
	register OBJECT *ptree;
	register int	objcounter;
	
	ptree = palttree;
	objcounter = -1;
	do	{
		objcounter++;
		rsrc_obfix(ptree, objcounter);
	} while (!(ptree[objcounter].ob_flags & LASTOB));

	form_center(palttree, &dmy, &dmy, &dmy, &dmy);

	wind_get(0, WF_FULLXYWH, 
			 &deskrect.g_x, &deskrect.g_y, &deskrect.g_w, &deskrect.g_h);

	rc_gadjust(&deskrect, -2, -2);
}
   
/**************************************************************************
 *
 * mini_pallete - The main routine, drives the pallete selection dialog.
 *
 *************************************************************************/

int
mini_pallete()
{
	register OBJECT *ptree = palttree;
	register int	selobject;
	register int	lastobject;
	static	 int	initdone = FALSE;

/*-----------------------------------------------------------------------*
 * If the one-time init hasn't been done yet, do it.
 *
 * On every call, do a 'new_color' to make sure we have the current
 * intensities for the currently selected color box (they could have
 * been changed behind our back, by the control panel for instance).
 *-----------------------------------------------------------------------*/

	if (initdone == FALSE) {
		init_paldialog();
		initdone = TRUE;
	}

	new_color(colorobj, FALSE);

/*-----------------------------------------------------------------------*
 * Calc the x/y/w/h of the dialog box, adjust it to be larger by one
 * pixel on all sides (allows for the fact that the box has an outside
 * width of '1').  Save the contents of the screen under the dialog box,
 * then display the box.
 *-----------------------------------------------------------------------*/

	objc_xywh(ptree, R_TREE, &dialrect);
	rc_gadjust(&dialrect, 1, 1);

	if (0 != aes_blit(AESBLIT_SAVESCRN, &dialrect))
		return -1;
	 
	objc_draw(ptree, R_TREE, MAX_DEPTH, dialrect);

/*-----------------------------------------------------------------------*
 * Main loop.  Call form_do for the pallete dialog.  Process the selected
 * object, and loop until the selected object is the 'close box'.
 *
 * Note that an undocumented 'feature' of form_do causes the high-order
 * bit of the returned object number to be set when the user double-clicks
 * on a TOUCHEXIT type object.	This is very handy, but we don't need it
 * in this application, so we mask off the high bit of the return value.
 *-----------------------------------------------------------------------*/

	lastobject = 0;

	do	{
		selobject = 0x7FFF & form_do(ptree,0);
		switch (selobject) {
		
			case PALTBXCL:		/* process a click on the close button...*/

				objst_change(ptree, selobject, ~SELECTED, FALSE);
				break;

			case PALTBXMV:		/* process a click on the MOVE bar...	 */

				move_dbox();
				break;

			default:			/* process a click some other object...  */

				if (selobject != lastobject) {
					switch (obj_parent(ptree, selobject)) {
					
						case PALTPCOL: /* process click on color box... */

							new_color(selobject, TRUE);
							break;

						case PALTPRED: /* process click on numbered box... */
						case PALTPGRN:								
						case PALTPBLU:

							new_settings(selobject);
							break;
					}
					lastobject = selobject;
				}
				break; 
		} 
	} while (selobject != PALTBXCL);

/*-----------------------------------------------------------------------*
 * Restore the screen under the dialog box and return success.
 *-----------------------------------------------------------------------*/

	aes_blit(AESBLIT_RSTRSCRN, &dialrect);
	return 0;
} 

