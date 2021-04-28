
/**************************************************************************
 *
 * THERMO.C -   Routines to display a 'thermometer' progress box.
 *
 * AUTHOR:      Ian Lepore (released to PD 01/02/90).
 *
 * DESCRIPTION:
 *
 *              These routines will help manage a 'thermometer' progress
 *              display similar to those used by the GEM desktop in format
 *              and copy operations.  Only one thermometer is allowed 
 *              onscreen at a time with the current code, multiple 
 *              concurrent displays would take radical modifications.
 *              
 *              These routines do NOT save and/or restore the screen area
 *              under the progress display.  Since the caller provides a
 *              GRECT describing the area on the screen in which the 
 *              display is to appear, it is assumed that the caller can
 *              recreate that portion of the screen when the time comes
 *              to remove the progress display.  If asynchronous event
 *              processing is done while the display is on the screen
 *              (such that a redraw of the progress display is needed), it
 *              is the caller's responsibility to detect redraw messages,
 *              handle the calculation of intersections between the redraw
 *              area and the progress display, and call the thmo_redraw()
 *              routine herein with the appropriate clipping rectangle.
 *
 *              This module contains 4 globally-visable names, each being
 *              the name of a function that can be called from the external
 *              world.  No variables are imported or exported.  The four
 *              available functions are:
 *              
 *                  thmo_redraw - Redraw a portion of the progress display.
 *                  thmo_incr   - Add an increment to the onscreen display.
 *                  thmo_start  - Set up and show initial (empty) display.
 *                  thmo_attr   - Set height and fill pattern for display.
 *                  
 *             A typical calling sequence might be:
 *             
 *                  thmo_attr(0, 5);
 *                  thmo_start(80, display_rect); 
 *                  for (i=0; i< 80; i++) {
 *                      do_something(i);
 *                      thmo_incr();
 *                  }
 *
 *              This would set up a display with the default height (one
 *              character height), and a dark fill pattern; it would init
 *              the display for 80 increments between start and completion,
 *              specifying that the display be shown within the rectangle
 *              described by 'display_rect'.  It would then perform some
 *              action 80 times, showing one progress increment after each
 *              iteration of the action.
 *              
 * MAINENANCE:
 *  01/02/90    v1.0
 *              Formalized as a 'canned source' library routine.
 *
 * NOTES:
 *
 *  Throughtout this code, the following naming standards are used:
 *    ptree  - pointer to thmotree OBJECT tree.
 *    pptree - pointer to parent object in tree (effectively same as ptree).
 *    pctree - pointer to child object in tree (the filled progress box).
 *
 *************************************************************************/

#include <gemfast.h>    /* equivelent to obdefs.h + gemdefs.h */

/*-------------------------------------------------------------------------
 * The object tree for the display, and a couple variables.
 *-----------------------------------------------------------------------*/
 
static OBJECT thmotree[] = {
-1,  1,  1, G_BOX, NONE,   NORMAL, 0xFF1100L, 0, 0, 0, 0, /* parent   box */
 0, -1, -1, G_BOX, LASTOB, NORMAL, 0xFF1121L, 0, 0, 0, 0  /* progress box */
};

static int  incrwidth;   /* The pixel width of 1 progress increment.      */

/**************************************************************************
 *
 * rc_gadjust - Adjust a GRECT-type rectangle in the x and/or y coordinate.
 *
 *  Positive adjustments increase the rectangle's area, negative 
 *  adjustments shrink it.  This routine guarantees that none of the
 *  resulting x/y/w/h values will be negative after adjustment. 
 *
 *  This routine lives in the AESFAST bindings library.  For those who
 *  don't have AESFAST, the #ifndef will cause this C version of the 
 *  rc_gadjust function to be compiled.
 *************************************************************************/
 
#ifndef GEMFAST_H

static void
rc_gadjust(prect, xadjust, yadjust)
    register GRECT  *prect;
    int             xadjust;
    int             yadjust;
{
    prect->g_x -= xadjust;
    prect->g_y -= yadjust;
    prect->g_w += xadjust * 2;
    prect->g_h += yadjust * 2;
    
    if (prect->g_x < 0) {
        prect->g_x = 0;
    }
    
    if (prect->g_y < 0) {
        prect->g_y = 0;
    }
    
    if (prect->g_w < 0) {
        prect->g_w = 0;
    }
    
    if (prect->g_h < 0) {
        prect->g_h = 0;
    }
} 
#endif

/**************************************************************************
 *
 * thmo_redraw - Redraw the progress display, or a portion thereof.
 *
 *  This routine is used internally to put up the initial (empty) display.
 *  It can also be used by the main application when redraws of the 
 *  progress display area on the screen are needed.
 *
 *  The 'prect' parm is a pointer to a GRECT-type clipping rectangle.
 *
 *************************************************************************/

void
thmo_redraw(prect)
    GRECT   *prect;
{
    objc_draw(thmotree, 9L, *prect);          /* 9L == R_TREE, MAX_DEPTH */
}

/**************************************************************************
 *
 * thmo_incr - Increment the progress marker on the screen.
 *
 *  Each call to this routine causes the progress box to advance by
 *  one increment.  If called too many times, the progress display will
 *  NOT advance out of the parent box.
 *
 *  Note that for drawing we calculate a clipping rectangle which is
 *  just wide enough in the horizontal coordinate to encompass the area
 *  in which the new increment will be drawn.  Also, the redraw is done
 *  starting with the child box (not R_TREE).  These two factors combine
 *  to help eliminate some of the ugly graphic flashing on the screen.
 *
 *************************************************************************/

void
thmo_incr()
{
    register int    iwidth  = incrwidth;
    register OBJECT *pptree = thmotree;
    register OBJECT *pctree = &pptree[1];
    GRECT           cliprect;
    
    if (pctree->ob_width < pptree->ob_width) {
    
        rc_copy(&pptree->ob_x, &cliprect);
        cliprect.g_x += pctree->ob_width;
        cliprect.g_w  = iwidth;
        rc_gadjust(&cliprect, 2, 0);

        pctree->ob_width += iwidth;
        
        objc_draw(pptree, 0x00010009L, cliprect);
    }    
}

/**************************************************************************
 *
 * thmo_start - Init and display the thermometer progress box.
 *
 *   This routine sets up and displays the initial progress display.
 *
 *   The first parameter, 'nincr', is the number of increments that will
 *   happen between the start and completion of the task being tracked.
 *   (EG, for a disk formatter, this would be the number of tracks to 
 *   be formatted.)  
 *
 *   The second parameter, 'pprect', is a pointer to a GRECT-type 
 *   rectangle which describes the 'parent' area on the screen.  If the
 *   progress box is to be displayed within a dialog box on the screen,
 *   an empty BOX object can be included in the tree.  The coordinates 
 *   of this empty box can then be obtained (using objc_offset() for 
 *   example), and passed to this routine, to cause the progress display
 *   to appear in the proper area of the main dialog box.
 *
 *   The progress display will be scaled to the parent area (based on the
 *   number of increments to be displayed), and the resulting progress
 *   display will be centered within the parent area in both coordinates.
 *
 *   This routine will return 0 on good completion, -2 if the display
 *   won't fit in the parent size given.  (This implies that one increment
 *   width would be less than one pixel wide.)
 *************************************************************************/

int
thmo_start(nincr, pprect, drawflag)
    register int    nincr;
    register GRECT  *pprect;
    int             drawflag;
{
    int             dmy;
    int             hchar;
    register int    iwidth;
    GRECT           cliprect;
    register OBJECT *pptree  = thmotree;
    register OBJECT *pctree  = &pptree[1];

/*-------------------------------------------------------------------------
 * If the parent ob_height is zero, init the height for both objects.
 *-----------------------------------------------------------------------*/
 
    if (pptree->ob_height == 0) {
        graf_handle(&dmy, &hchar, &dmy, &dmy);
        pptree->ob_height = hchar;
        pctree->ob_height = hchar;
    }

/*-------------------------------------------------------------------------
 * Check for zero increments to prevent div-by-zero errors.
 * Calc the pixel width of one increment.
 *-----------------------------------------------------------------------*/
    
    if (nincr == 0) 
        return -1;

    iwidth = pprect->g_w / nincr;

    if (iwidth == 0)
        return -2;

/*-------------------------------------------------------------------------
 * Set the width of the progress display, and center the display
 * within the parent area of the screen.
 *-----------------------------------------------------------------------*/
 
    incrwidth = iwidth;
    pptree->ob_width = nincr * iwidth;
    pctree->ob_width = 0;
    
    pptree->ob_x = pprect->g_x + ((pprect->g_w - pptree->ob_width)  / 2);
    pptree->ob_y = pprect->g_y + ((pprect->g_h - pptree->ob_height) / 2);

/*-------------------------------------------------------------------------
 * Draw the intial display, then return success.
 *-----------------------------------------------------------------------*/
 
    if (drawflag) {
        rc_copy(&pptree->ob_x, &cliprect);
        rc_gadjust(&cliprect, 2, 2);
        thmo_redraw(&cliprect);
    }
    
    return 0;
}

/**************************************************************************
 *
 * thmo_attr - Set the height and fill pattern used in the progress box.
 *
 *  If the 'height' parm is zero, the default height (1 character height)
 *  - or the last height set - will be used.  The fill pattern is the
 *  same as those used by BOX objects in GEM, values 1-7 give increasing
 *  degrees of solidity in the fill pattern.
 *
 *************************************************************************/

thmo_attr(height, fillpattern)
{
    register OBJECT *ptree = thmotree;

    if (height != 0) {                  /* set display height if non-zero */
        ptree->ob_height   = height;
        ptree[1].ob_height = height;
    }
    
    ptree[1].ob_spec &= 0xFFFFFF0F;                    /* mask out old    */
    ptree[1].ob_spec |= ((fillpattern & 0x0007) << 4); /* plug in new     */
}   

