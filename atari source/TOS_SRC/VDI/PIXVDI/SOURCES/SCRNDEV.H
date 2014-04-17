/*
********************************  scrndev.h  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbescape.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/31 12:04:31 $     $Locker:  $
* =============================================================================
*
* $Log:	$
*******************************************************************************
*/

#ifndef _SCRNDEV_H_
#define _SCRNDEV_H_

#include 	"fontdef.h"

typedef struct screendef {
    BYTE	*name;		    /* device identification (name)	     */
    WORD	devId;		    /* device id number			     */
    WORD	planes;		    /* # of planes (bits per pixel)	     */
    WORD	lineWrap;	    /* # of bytes from 1 scan to next	     */
    WORD	xRez;		    /* current horizontal resolution	     */
    WORD	yRez;		    /* current vertical resolution	     */
    WORD	xSize;		    /* width of one pixel in microns	     */
    WORD	ySize;		    /* height of one pixel in microns	     */
    WORD	formId;		    /* scrn form LITERLEAVED, PIXPACKED ...  */
    FONT_HEAD	*fntPtr;	    /* points to the default font	     */
    WORD	maxPen;		    /* # of pens available		     */
    WORD	colFlag;	    /* color cpability flag		     */
    WORD	palSize;	    /* palette size (0 = contiguous)	     */
    WORD	lookupTable;	    /* lookup table supported		     */
    WORD	(**softRoutines)(); /* drawing primitives done in sofwr      */
    WORD	(**hardRoutines)(); /* hardware assisted drawing primitives  */
    WORD	(**curRoutines)();  /* current routines being used	     */
    BYTE	*vidAdr;	    /* video base address		     */
} SCREENDEF;


#define	V_CELL		0	    /* VT52 cell output routines	    */
#define	V_SCRUP		1	    /* VT52 screen up routine		    */
#define	V_SCRDN		2	    /* VT52 screen down routine		    */
#define	V_BLANK		3	    /* VT52 screen blank routine	    */
#define	V_BLAST		4	    /* blit routines			    */
#define	V_MONO		5	    /* monospace font blit routines	    */
#define	V_RECT		6	    /* rectangle draw routines		    */
#define	V_VLINE		7	    /* vertical line draw routines	    */
#define	V_HLINE		8	    /* horizontal line draw routines	    */
#define	V_TEXT		9	    /* text blit routines		    */
#define	V_VQCOLOR	10	    /* color inquire routines		    */
#define	V_VSCOLOR	11	    /* color set routines		    */
#define V_INIT		12	    /* init routine called upon openwk	    */
#define V_SHOWCUR	13	    /* display cursor			    */
#define V_HIDECUR	14	    /* replace cursor with old background   */
#define V_NEGCELL	15	    /* negate alpha cursor		    */
#define V_MOVEACUR	16	    /* move alpha cur to new X,Y (D0, D1)   */
#define V_ABLINE	17	    /* arbitrary line routine		    */
#define V_HABLINE	18	    /* horizontal line routine setup	    */
#define V_RECTFILL	19	    /* routine to do rectangle fill	    */
#define	V_PUTPIX	20	    /* output pixel value to the screen	    */
#define V_GETPIX	21	    /* get pixel value at (X,Y) of screen   */

#define	DEVICEDEP	0	    /* means we're in device dep mode	    */
#define STANDARD	1	    /* flag for standard format		    */
#define INTERLEAVED	2	    /* flag for interlieved planes	    */
#define PIXPACKED	3	    /* flag for pixel packed		    */

#endif
