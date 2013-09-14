/* FONT_HEAD.H
 * ====================================================================
 * Contains structures and misc #defines for the Fonts ACC
 *
 * CREATED:  Dec  27, 1989 k.soohoo
 * Modified: June 26, 1991 cjg
 * 	     Dec   7, 1992 cjg - still not shipped...
 *	     Dec  15, 1992 cjg - Merry Christmas
 *			       - Remove Bitmap Fonts
 *			       - Remove Devices
 */

/* INCLUDES
 * ====================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <ext.h>
#include <errno.h>

#define MAX_POINTS	10	/* Maximum # of point sizes per font */
				/* This is the predefined ones in the*/
				/* extend.sys file.		     */
#define MAX_FONTS	400	/* Max # fonts allowed - Bitmap + outline*/

#define MAX_FONT_SIZE	999	/* Largest predefined point size allowed */
#define MIN_FONT_SIZE	1	/* Minimum predefined point size allowed */
#define FRONT_LENGTH    32	/* # of characters across do display     */

#define E_OK 		0

#define TRUE		1
#define FALSE		0

#define SPD_FONT	1
#define BITMAP_FONT     2

#define WIND_H		10

#if 0
#define mouse_on()	graf_mouse(M_ON, 0L)
#define mouse_off()	graf_mouse(M_OFF, 0L)
#define mouse_busy()	graf_mouse(BUSY_BEE, 0L)
#define mouse_arrow()	graf_mouse(ARROW, 0L)
#endif

#define find_newline(x)	while ((bufptr[x] != '\n') && (x < alen)) {++x;}




/* STRUCTURES
 * ====================================================================
 */

/* FONT STRUCTURE
 * ====================================================================
 * 99 bytes per node - 9900 bytes for 100 nodes
 *		      34650 bytes for 350 nodes
 *		      39600 bytes for 400 nodes
 *		      45540 bytes for 450 nodes
 *		      49500 bytes for 500 nodes
 */
typedef struct f_node
{
	char font_name[33];	/* Pointer to name of the font */
	char font_file[16];	/* File name this font obeys + .SPD */
	int  font_id;		/* font id number   */
	char font_set[2];	/* Character Set ID */
	BOOLEAN select;		/* TRUE - INSTALLED FONT, FALSE - AVAILABLE*/
	long fsize;		/* Size of file in bytes */
	int  type;		/* Type of font 1 - SPD, 2 - BitMap*/
	BOOLEAN aflag;		/* 0 - Deselect/ 1 = Selected      
   				 * This is the actual state visible on 
   				 * the screen of the filename node.
   				 */
   	BOOLEAN sflag;		/* The Shadow flag, this is what the Action
   				 * Flag 'WAS' before it was toggled.
   				 * It is used for the scrolling toggle
   				 * routines.
   				 */
   	long   FBuffSize;	/* Minimum Font Buffer Size      */
   	long   CBuffSize;	/* Minimum Character Buffer Size */			 

	struct f_node *fnext;	/* Link to next font in alpha order */
	struct f_node *fprev;	/* Link to previous font in alpha order */
	int points[ MAX_POINTS ];/* Point Sizes for this font */					
} FON, *FON_PTR;


/* MACROS
 * ====================================================================
 */
#define FNEXT(ptr)	ptr->fnext
#define FPREV(ptr)	ptr->fprev
#define FTYPE(ptr)	ptr->type
#define SEL(ptr)	ptr->select
#define FNAME(ptr)	ptr->font_name
#define FFNAME(ptr)	ptr->font_file
#define FSIZE(ptr)	ptr->fsize
#define AFLAG(ptr)	ptr->aflag
#define SFLAG(ptr)	ptr->sflag

#define POINT_SIZE(ptr) ptr->font_id
#define FONTID(ptr)	ptr->font_id
#define POINTS(ptr)	ptr->points

#define FBUFF_SIZE(ptr) ptr->FBuffSize
#define CBUFF_SIZE(ptr) ptr->CBuffSize
#define FCHARSET(ptr)   ptr->font_set


