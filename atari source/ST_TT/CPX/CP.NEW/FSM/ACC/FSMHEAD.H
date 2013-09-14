/* FSMHEAD.H
 * ====================================================================
 * Contains structures and misc #defines for the FSM CPX/ACC
 *
 * CREATED:  Dec  27, 1989 k.soohoo
 * Modified: June 26, 1991 cjg
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

#define ONLY_WIDTH	99

#define MAX_DEV		100	/* MAX # of point sizes per font */
#define MAX_FONTS	250	/* Max # fonts allowed */

#define MAX_FONT_SIZE	999
#define MIN_FONT_SIZE	1

#define MAX_NAME 	30
#define MAX_DRIVERS	64

#define NUM_NAMES	7
#define NUM_FSM_NAMES	16
#define NUM_DEV_NAMES	6

#define E_OK 		0

#define TRUE		1
#define FALSE		0

#define FSM_FONT	1

#define WIND_H		10

#define mouse_on()	graf_mouse(M_ON, 0L)
#define mouse_off()	graf_mouse(M_OFF, 0L)
#define mouse_busy()	graf_mouse(BUSY_BEE, 0L)
#define mouse_arrow()	graf_mouse(ARROW, 0L)

#define find_newline(x)	while ((abuf[x] != '\n') && (x < alen)) {++x;}


/* STRUCTURES
 * ====================================================================
 */
typedef struct f_node
{
	char font_name[28];	/* Pointer to name of the font  was 32*/
				/* Our RSC allows only 27 characters*/
	char long_font_name[35];/* Full font name */			
	char font_file[16];	/* File name this font obeys + .QFM */
	int  font_id;		/* font id number */
	long select;		/* Each bit here is for a device */
	long fsize;		/* Size of file in bytes */
	long type;		/* Type of font */
	BOOLEAN aflag;		/* 0 - Deselect/ 1 = Selected      
   				 * This is the actual state visible on 
   				 * the screen of the filename node.
   				 */
   	BOOLEAN sflag;		/* The Shadow flag, this is what the Action
   				 * Flag 'WAS' before it was toggled.
   				 * It is used for the scrolling toggle
   				 * routines.
   				 */
	struct f_node *fnext;	/* Link to next font in alpha order */
	struct f_node *fprev;	/* Link to previous font in alpha order */
	int points[ MAX_DEV ];	/* Point Sizes for this font */					
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
#define FLNAME(ptr)	ptr->long_font_name
#define FSIZE(ptr)	ptr->fsize
#define AFLAG(ptr)	ptr->aflag
#define SFLAG(ptr)	ptr->sflag

#define POINT_SIZE(ptr) ptr->font_id
#define FONTID(ptr)	ptr->font_id
#define POINTS(ptr)	ptr->points

