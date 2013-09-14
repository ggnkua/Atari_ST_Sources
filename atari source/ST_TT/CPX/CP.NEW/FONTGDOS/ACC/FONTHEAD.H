/* FONTHEAD.H
 * ======================================================================
 *  Contains structures, and misc #defines for FONTACC, FONTGDOS.CPX
 *
 *  Kenneth Soohoo
 *  December 27, 1989	Copyright 1989 Atari Corporation
 *
 *  CJG - for CPXs
 *  Modified: December 21, 1990
 *  Modified: January   8, 1991 for BITMAP CPX
 */


/* INCLUDES
 * ======================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <ext.h>
#include <errno.h>


/* DEFINES
 * ======================================================================
 */
#define MAX_NUM_DEV	100	/* Upper limit of the highest device number possible. */
#define MAX_DEV		50      /* # of device that we can use */

#define MAX_DRIVERS	50	/* Maximum Number of Drivers Allowed */

#define MAX_FONTS	250	/* Max # fonts allowed - 250*/

#define E_OK 		0

#define TRUE		1
#define FALSE		0
#define find_newline(x)	while ((bufptr[x] != '\n') && (x < alen)) {++x;}



/* TYPE DEFINE STRUCTURES
 * ======================================================================
 */


/* FONT STRUCTURE FOR BITMAP FONTS 
 * ======================================================================
 * Current size for one node:
 *    28 + 16 + 2 + 4 + 2 + 2 + 4 + 4 = 66 bytes per structure.
 *    Array of 100 font structures == 6600 bytes.
 */
typedef struct f_node {
	char font_name[28];	/* Pointer to name of the font  was 32*/
				/* Our RSC allows only 27 characters*/
	char font_file[16];	/* File name this font obeys + .FNT */
	int  font_id;		/* font id number */
	long fsize;		/* Size of file in bytes */
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
	} FON, *FON_PTR;

#define FNEXT(ptr)	ptr->fnext
#define FPREV(ptr)	ptr->fprev
#define FNAME(ptr)	ptr->font_name
#define FFNAME(ptr)	ptr->font_file
#define FSIZE(ptr)	ptr->fsize
#define AFLAG(ptr)	ptr->aflag
#define SFLAG(ptr)	ptr->sflag

#define POINT_SIZE(ptr) ptr->font_id
#define FONTID(ptr)	ptr->font_id




/* DEVICE STRUCTURE
 * ======================================================================
 * Current size for one node.
 * 2 + 2 + 1 + 2 + ( 4 * number of fonts [ MAX_FONTS ] ) = 
 *      MAX_FONTS == 200  ---->    800 + 7  per structure.
 *      MAX_FONTS == 100  ---->    400 + 7  per structure.
 *      MAX_FONTS ==  50  ---->    200 + 7  per structure.
 */
typedef struct d_node {		    /* Driver data structure 	     */
	int driver_name;	    /* Driver's name 		     */
	int device;		    /* Device number 		     */
	char type;		    /* (r) resident, (p) permenant   */
	int font_count;		    /* # fonts with this device      */
	FON_PTR fonts[ MAX_FONTS ]; /* Array of Font Pointers to the */
				    /* Font Arena symbolizing which  */
				    /* fonts are being used by this  */
				    /* driver.			     */
	struct d_node *next;	    /* Pointer to next device.       */			    
	struct d_node *prev;	    /* Pointer to previous device    */
	} DEV, *DEV_PTR;

#define DNAME(x)	x->driver_name
#define DDEV(x)		x->device
#define DFCOUNT(x)	x->font_count
#define DTYPE(x)	x->type
#define DFONT(x)	( FON_PTR )( x->fonts )
#define DNEXT(x)	( DEV_PTR )( x->next )
#define DPREV(x)	( DEV_PTR )( x->prev )
