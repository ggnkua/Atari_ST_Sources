/*
 *	setbtgem.h
 *
 */

#define GEMLIB	1

/*
 *	language for (err) messages
 *	at the moment only English is supported
 */
 
#define ENGLISH	1

/*
 *	include files
 */
 
#include <gemdefs.h>	
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
#include "portab.h"


#ifdef MWC
#include <aesbind.h>
#include <vdibind.h>
#endif

/*
 *	GEM's global arrays
 *	define them for all modulea except asvgem.c as externals
 */

#ifdef GEMLIBINIT

WORD contrl[12];
WORD intin[512];
WORD ptsin[512];
WORD intout[512];
WORD ptsout[512];

WORD work_in[12];	
WORD work_out[57];

WORD vdi_handle;		/* for aborting after errors */

WORD 	acc;			/* if desk acc, set acc = TRUE */	
BYTE 	*accname;		/* menu name of acc */	

#else

extern WORD contrl[12];
extern WORD intin[512];
extern WORD ptsin[512];
extern WORD intout[512];
extern WORD ptsout[512];

extern WORD work_in[12];	
extern WORD work_out[57];

extern WORD vdi_handle;		/* for aborting after errors */


#endif

#ifdef MWC
extern WORD gl_apid;
#endif

/*
 *	d e f i n e s
 */

/*
 *	screen resolutions
 */
  
#define HIRES 		2
#define MIRES 		1
#define LORES 		0      

/*
 *	coordinate systems
 */
 
#define NC 0	/* mormelized */
#define RC 2 	/* raster */

/*
 *	GEMBUF holds infos about the appl & the env it's running in
 */

typedef struct gembuf {
	WORD 	ap_id;		/* ID of zhe appl */
	WORD	acc;		/* TRUE, if desk acc */
	WORD 	menu_id;	/* if acc, ID of the menu title  */
	WORD 	handle;		/* vdi handle */
	GRECT 	desk;		/* desktop size*/	
	GRECT 	scrn;		/* screen */
	WORD 	scrn_planes;	/* planes */
	FDB  	scrn_fdb;	/* screen save area */		
	WORD	res;		/* screen resolution */
	WORD	blitter;	/* blitter chip status */
	WORD 	gl_wchar;	/* width of a char */
	WORD	gl_hchar;	/* heigth of a char */
	WORD	gl_wbox;	/* width of a char box */
	WORD	gl_hbox;	/* heigth of a char box */
	WORD 	update;		/* status of wind_update */
	WORD	mouse;		/* mouse status */			
	OBJECT	*menu_addr;	/* addr of the menu bar tree */
	WORD	menu_titles[64];/* index of menu titles */
	WORD	wind_count;	/* internal window counter */
	WORD	open_wind;	/* # of open windows */
	WORD	txtoff;		/* window vert. text offset (3 or 2) ??? */
	OBJECT	*desktop;	/* new desktop addr */
	WORD	wuser;		/* for the user */
	LONG	luser;
	BYTE	*puser1;		
	BYTE	*puser2;
	BYTE	*puser3;
	BYTE	resvd[256];	/* reserved */
} GEMBUF;


/*
 *	std c fcts used
 */

extern BYTE *malloc();
extern BYTE *lmalloc();
extern BYTE *calloc();
extern VOID free();

/* 
 *	gemlib functions
 */
 
/*
 *	fcts in setbtgem.c
 */
 
GEMBUF	*init_appl();		/* intializes the application */
WORD 	exit_appl();		/* exit the app */
VOID	draw_std_desk();	/* draws the std desktop */
VOID	show_mouse();		/* show mouse */
VOID	hide_mouse();		/* hide mouse */
VOID	begin_update();		/* start window update & block events */ 
VOID 	end_update();		/* end ... */
WORD	evnt();			/* main event loop */
WORD	init_menu();		/* init & show menu bar */

