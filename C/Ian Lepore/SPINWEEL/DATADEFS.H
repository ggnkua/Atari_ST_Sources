
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* tab expansion/compress should be set to '4' in your editor.	*/

/***********************************************************************
 *
 * Storage definitions for SPINWEEL.  
 *
 *	If 'STORAGE' is defined, this module will set aside memory for
 *	the variables within.  If undefined, this file serves as a header
 *	file full of external definitions.
 *
 ***********************************************************************/

#ifndef DATADEFS_H

#define DATADEFS_H 1

#include "gemsystm.h"	 

#include <osbind.h> 						/* DOS, BIOS, etc */

#include "spinweel.h"						/* RSC definitions */

extern	float  sin(), cos();				/* always external */

/*---------------------------------------------------------------------
 * Useful macros and global #defines.
 *-------------------------------------------------------------------*/

#define   RSRCFILE		"SPINWEEL.RSC"
#define   NO_WINDOW 	-1

#ifndef NULL
#define   NULL			0L
#endif

#ifndef TRUE
#define   TRUE			1
#define   FALSE 		0
#endif

#define   ABS(x)		((x) > 0) ? (x) : (-(x))

#define   BLIT_SAVESCRN 0
#define   BLIT_RSTRSCRN 1

#define   FASTPLOT		0
#define   VDIPLOT		1

/*---------------------------------------------------------------------
 * Decide whether to generate storage or external definitions.
 *-------------------------------------------------------------------*/

#ifdef STORAGE
#define  EXTERNAL		/**/
#else
#define  EXTERNAL		extern
#endif

/*---------------------------------------------------------------------
 * Define global BSS type variables.
 *-------------------------------------------------------------------*/

EXTERNAL FDB	ssavefdb;				/* Blit FDB for screen buffer	   */

EXTERNAL OBJECT *menutree,				/* menu bar 					   */
				*infotree,				/* About Spyro						*/
				*colrtree,				/* Set pen color					 */
				*spedtree,				/* Set drawing speed				*/
				*sizetree,				/* Buttons for sizing gears 	   */
				*smthtree,				/* Set smoothness				   */
				*ssamtree,				/* Set screen access method 	   */
				*helptree;				/* Help 						   */

EXTERNAL GRECT	scrnrect,				/* full screen sizes			   */
				deskrect;				/* desktop sizes					*/

EXTERNAL float	y_scale;				/* y axis aspect ratio scaling		 */

EXTERNAL int	vdi_handle, 			/* VDI handle						 */
				work_out[57],			/* VDI v_opnvwk/vq_extnd values    */
				menu_displayed, 		/* flag: is menu currently visible?*/
				rsrc_is_loaded, 		/* flag: has RSC file been loaded? */
				wi_handle,				/* window handle					 */

				scrnaccess, 			/* flag: which screen access method*/

				save_pallete[16],		/* Save area for color pallete.   */

				pl_desk[16],			/* Polyline indices for desk	   */
				max_col, max_row,		/* Max x/y based on scrn res	   */
				mid_col, mid_row,		/* Mid x/y based on scrn res	   */
				num_colors, 			/* # simult colors for res		   */
				pen_color,				/* current pen color for plotting  */
				idx_bgcolor,			/* TOS's idea of BG color number   */
				resolution, 			/* TOS res # (0,1,2)				 */

				fix_col, fix_row,		/* fixed gear center x/y			*/
				fix_irad,				/* fixed gear radius			   */
				rol_col, rol_row,		/* rolling gear center x/y		   */
				rol_irad,				/* rolling gear radius				 */
				pen_pos,				/* pen offset from rolling gear    */
				new_shape,				/* flag: has new shape been set?	 */

				slowfactor, 			/* slowdown factor for draw speed  */
				slowmode;

EXTERNAL char	*scrnbase,				/* screen logbase pointer		   */
				*scrnbuffer;			/* ptr to screen save buffer	   */

/*---------------------------------------------------------------------
 * Define global DATA (pre-initialized) type variables.
 *-------------------------------------------------------------------*/

#ifndef STORAGE

 extern float	smoothness; 			 /* smoothness factor */

 extern int 	work_in[11];			 /* VDI v_opnvwk array */

 extern char	no_rsrc_alert[],
				no_mem_alert[],
				zero_rad_alert[],
				savefail_alert[],
				savegood_alert[],
				loadfail_alert[];
#else

 float			smoothness = 2.0;

 int			work_in[11] = {1,1,1,1,1,1,1,1,1,1,2};

 char			no_rsrc_alert[] = "[3][ | Resource file load failed! | ][ FATAL ]",
				no_mem_alert[]	= "[3][ | Cannot allocate a 32k | screen buffer! | ][ FATAL ]",
				zero_rad_alert[]= "[3][ | You have marked out a | shape with a zero radius | ][ Try Again]",
				savefail_alert[]= "[3][ | Error occurred attempting | to save image file. | ][ Bummer ]",
				savegood_alert[]= "[0][ | Screen image has been | successfully saved. | ][ OK ]",
				loadfail_alert[]= "[3][ | Error occurred attempting | to load image file. | ][ Bummer ]";

#endif			/* END of else of if STORAGE */

/*---------------------------------------------------------------------
 * Declare all globally-visible routines...
 *-------------------------------------------------------------------*/

extern void do_spyro(); 		/* in main.c:	  calc & draw spyro picture   */
extern void main(); 			/* in main.c:	  main routine				 */

extern void prg_init(); 		/* in gemstuff.c: init prog vars and GEM	  */
extern void prg_exit(); 		/* in gemstuff.c: shutdown GEM and Pterm.	   */
extern void do_redraw();		/* in gemstuff.c: process redraw events 	  */
extern void clr_screen();		/* in gemstuff.c: clear the screen			  */
extern void scrn_blit();		/* in gemstuff.c: do screen<->buffer blits	 */
extern void wind_outline(); 	/* in gemstuff.c: outline window in pen color */
extern void menu_on();			/* in gemstuff.c: save screen & activate menu */
extern void menu_off(); 		/* in gemstuff.c: de-act menu & restore screen */

extern void get_shapes();		/* in input.c: do dialogs for new shapes	*/
extern int	get_speed();		/* in input.c: do dialog for speed control */
extern void get_smoothness();	/* in input.c: do dialog for smoothness    */

#endif		/* END of if DATADEFS_H */


