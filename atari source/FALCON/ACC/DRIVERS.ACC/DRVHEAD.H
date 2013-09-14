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
 *  Modified: December  4, 1992 for DRIVERS.ACC
 *			        Note- It STILL hasn't shipped yet.
 *  Modified: December 15, 1992
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
#define MAX_DEV		30      /* # of device that we can use */

#define MAX_DRIVERS	40	/* Maximum Number of Drivers Allowed  */

#define MAX_FONTS	50	/* Max # different fonts allowed - USED IN ASSIGN.SYS*/

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
 *    16 + 4 + 4 = 24 bytes per structure.
 *    Array of 100 font structures == 2400 bytes.
 */
typedef struct f_node {
	char font_file[16];	/* File name this font obeys + .FNT */
	struct f_node *fnext;	/* Link to next font in alpha order */
	struct f_node *fprev;	/* Link to previous font in alpha order */
	} FON, *FON_PTR;

#define FNEXT(ptr)	ptr->fnext
#define FPREV(ptr)	ptr->fprev
#define FFNAME(ptr)	ptr->font_file


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
	BOOLEAN dflag;
	} DEV, *DEV_PTR;

#define DNAME(x)	x->driver_name
#define DDEV(x)		x->device
#define DFCOUNT(x)	x->font_count
#define DTYPE(x)	x->type
#define DFONT(x)	( FON_PTR )( x->fonts )
#define DNEXT(x)	( DEV_PTR )( x->next )
#define DPREV(x)	( DEV_PTR )( x->prev )
#define DFLAG(x)	x->dflag



/* Structure for displaying the FULL Printer Name
 * Memory used is MAX_DRIVERS
 *   ( 2 + 2 + 4 ) * MAX_DRIVERS = NUMBYTES est. 400 bytes.
 */
typedef struct h_node {
	int hindex;	/* into cdriver_name */
	int hflag;
	struct h_node *hnext;
	} HDEVICE, *HDEVICE_PTR;
	
#define HNAME(x)	x->hindex
#define HNEXT(x)	( HDEVICE_PTR )( x->hnext )	
#define HFLAG(x)	x->hflag



/* FSM/SPEEDO printer driver header*/
typedef struct _header
{
    long header[2];	/* Should always be _FSM_HDR */
    
    int	 quality;
    int  config_map;
    int  nplanes;
    int  total_planes;
    
    int  Plane[4];
    int  X_PIXEL[4];
    int  Y_PIXEL[4];
    
    int	 PageSize;
    int  xres;
    int  yres;
    int  port;
    int  paper_feed;
    char fname[ 26 ];
    int  pgsz_table[8];
    int  pgsz2_table[8];
    int	 TopMargin;
    int  BottomMargin;
    int  LeftMargin;
    int  RightMargin;
    int  Margin[32];
}HEADER;


typedef struct _margin
{
    int	 TopMargin;
    int  BottomMargin;
    int  LeftMargin;
    int  RightMargin;
    int  Margin[32];
}MARGIN;
