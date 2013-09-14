/* FSMHEAD.H
   Contains structures, and misc #defines for FSMACC, the FSM.SYS and
   ASSIGN.SYS handler.

   Kenneth Soohoo
   December 27, 1989	Copyright 1989 Atari Corporation
*/

#include "fontman.h"		/* Resource */

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <xbios.h>
#include <aesbind.h>
#include <bios.h>
#include <stat.h>
#include <ctype.h>

#define ONLY_WIDTH	99

#define MAX_DEV		16
#define NULL		(char *)0L
#define MAX_NAME 	30
#define MAX_DRIVERS	64
#define MAX_FONTS	200		/* Max # fonts allowed */

#define NUM_NAMES	7
#define NUM_FSM_NAMES	16
#define NUM_DEV_NAMES	6

#define E_OK 		0

#define TRUE		1
#define FALSE		0

#define BITMAP_FONT	0
#define FSM_FONT	1
#define FSM_FONT_PREV	2

#define WIND_H		10

#define PIXELS		0
#define POINTS		1
#define GDOSFILE	1
#define METAFILE	2

#define UP		1
#define DOWN		2

#define mouse_on()	graf_mouse(M_ON, 0L)
#define mouse_off()	graf_mouse(M_OFF, 0L)
#define mouse_busy()	graf_mouse(BUSY_BEE, 0L)
#define mouse_arrow()	graf_mouse(ARROW, 0L)

#define find_newline(x)	while ((abuf[x] != '\n') && (x < alen)) {++x;}

typedef struct f_node {
	char font_name[32];	/* Pointer to name of the font */
	char font_file[16];	/* File name this font obeys */
	long select;		/* Each bit here is for a device */
	long fsize;		/* Size of file in bytes */
	long type;		/* Type of font */

	struct f_node *fnext;	/* Link to previous in alpha order */
	struct f_node *fprev;	/* Link to next font in alpha order */
	struct f_node *dlink[MAX_DEV];	/* Link for devices */
	} FON, *FON_PTR;

#define FNEXT(ptr)	ptr->fnext
#define FPREV(ptr)	ptr->fprev
#define DLINK(ptr)	ptr->dlink
#define FTYPE(ptr)	ptr->type
#define SEL(ptr)	ptr->select
#define FNAME(ptr)	ptr->font_name
#define FFNAME(ptr)	ptr->font_file
#define FSIZE(ptr)	ptr->fsize

typedef struct d_node {		/* Driver data structure */
	int driver_name;	/* Driver's name */
	int device;		/* Device number */
	char type;		/* (r) resident, (p) permenant */
	int font_count;		/* # fonts with this device */
	FON_PTR first_font;	/* First font in the driver's font chain */
	FON_PTR top_font;	/* Font that we're showing now */
	int top_num;		/* Index of top font */
	} DEV, *DEV_PTR;

#define DNAME(x)	x->driver_name
#define DFONT(x)	(FON_PTR )(x->first_font)
#define DDEV(x)		x->device
#define DTFONT(x)	(FON_PTR )x->top_font
#define DFCOUNT(x)	x->font_count
#define DTOP(x)		x->top_num
#define DTYPE(x)	x->type
