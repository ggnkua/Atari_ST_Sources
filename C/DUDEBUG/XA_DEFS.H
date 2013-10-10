/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_DEFS_H_
#define _XA_DEFS_H_

/*----------------------------------------------------------------- */
/* COMPILE TIME SWITCHES */
/* - define as 1 to turn on, 0 to turn off */
/*----------------------------------------------------------------- */
/*#define GENERATE_DIAGS		0		 Make the DIAGS macro print out diagnostics (defined in the .prj file now) */

#define USE_DEBUG_VECTOR		0		/* Hook trap3 instead of trap2 to allow debugging under GEM */

#define FORCE_WINDOWS			0		/* Force windows to do what the user says instead of just */
										/* sending a WM_ message to the client (eg. if a window is topped */
										/* do it straight away, and then send the client a message about it) */

#define SOLID_BOXES				0		/* Do graf_dragbox, graf_rubberbox, etc using a solid box instead of */
										/* an outline */

#define DISPLAY_LOGO_IN_TITLE_BAR	0	/* Display the XaAES logo in the title bar of each window */

#define POINT_TO_TYPE			0		/* 0=Keyboard input goes to topped application */
										/* 1=Keyboard input goes to application whose window is pointed at */

#define ALT_CTRL_APP_OPS		1		/* Some ALT+CTRL+key combo's will perform functions relating to */
                       					/* the XaAES system */

#define USE_TMALARM				1		/* Use the 'un-official' Tmalarm() call to get better timing */

#define USE_CALL_DIRECT			1		/* Bypass the command pipe for certain op-codes */

#define SHOW_LOGO_AT_STARTUP	0		/* Run the XaAES logo program at startup */

#define EMULATE_AES4_1			1		/* 1=Emulate AES4.1, 0=Emulate AES1.4 */

#define AVOID_MINT_PIPES_BUG	1		/* Avoid a bug in MiNT pipes by opening as O_RDWR instead of O_RDONLY */
										/* - disadvantage os that it uses double the memory for pipe buffers */

#define DODGY_MEMORY_PROTECTION	1		/* Enable patches to help with memory protection - these don't work,*/
										/* so I recomend you leave them off */

#define DEBUG_MALLOCS			0		/* Use cmalloc() instead of malloc() for debugging purposes */

#define PRESERVE_DIALOG_BGD		0		/* Preserve the background of dialogs */

#define REALTIME_SCROLL			1		/* Realtime scroll bars */

#define DYNAMIC_CLIENT_STRUCTURE 0		/* Use a dynamic structure for the clients database */

#define OLD_NVDI				0		/* Compatible with NVDI2.5 (set to 0 for NVDI4 compatibility) */

#define FILESELECTOR_QSORT 1	/* Call the standard qsort() for fileselector listings */
															/* - this slows down big directorys a lot */
															
/*----------------------------------------------------------------- */
/* CONFIGURABLE PARAMETERS */
#define WIDGET_SIZE			20			/* Default size of window widgets in pixels (for drawn widgets) */
#define MAX_PID				500			/* Max number of client process' */
#define AES_PRIORITY		-20			/* The process priority for the XaAES server (-20 is high priority) */

#define DU_RSX_CONV 		8			/* Resource char to pixel coord conversion constants. */
#define DU_RSY_CONV 		16			/* If you are designing your resources in ST-Low res,  */
										/*  change DU_RSY_CONV to 8 */
#define STANDARD_FONT_POINT	10			/* Size of the 'standard' AES font (for window titles, etc) */
#define SMALL_FONT_POINT	8			/* Size of the 'small' AES font. */
#define STANDARD_AES_FONTID	1			/* Standard GDOS fontid for windows & stuff (set to 1 for no GDOS) */

#define GRAF_STEPS			10			/* Number of intermediate steps in a graf_growbox(), etc */

#define PUSH3D_DISTANCE		1			/* Distance text on selected (pushed in) 3D objects will move */
#define SHADOW_OFFSET		2			/* Offset used for shadowing objects */

#define ICONIFIED_W			80			/* Size of an iconified window */
#define ICONIFIED_H			80

#define DOUBLE_CLICK_TIME	50			/* Default double click time in milliseconds (0-200) */

#define RT_SCROLL_STEP		10			/* Step when doing a real-time scroll (0-1000) */

/*----------------------------------------------------------------- */
/* VERSION NUMBER */
#define XA_VERSION	"v0.6"				/* Version number */
#define XA_AES_VERSION	0x0500			/* AES version number we are going to use */

/*----------------------------------------------------------------- */
/* General Definitions  */
#define TRUE	1
#define FALSE	0

#ifndef NULL
#define NULL	((void *)0)
#endif

/*----------------------------------------------------------------- */
/* Return codes in the clients reply pipe */
#define XA_OK				0L	/* Ok, op-code done */
#define XA_UNIMPLEMENTED	1L	/* Unimpemented but valid op-code */
#define XA_ILLEGAL			2L	/* Illegal op-code */
#define XA_T_WAIT			3L	/* Re-select for a evnt_timer format timeout */
#define XA_M_WAIT			4L	/* Re-select for a evnt_multi format timeout */
#define XA_TVAL			0xffff0000L	/* Mask to get the timeout value */

/*----------------------------------------------------------------- */
/* Return codes from op-code service functions */
#define XAC_BLOCK			0L	/* Block the client indefinitely */
#define XAC_DONE			1L	/* Function completed - release client immediately */
#define XAC_T_TIMEOUT		2L	/* Block client, but timeout (evnt_timer format) */
#define XAC_M_TIMEOUT		3L	/* Block client, but timeout (evnt_multi format) */
#define XAC_TVAL		0xffff0000L	/* Mask to get the timeout value */

/*----------------------------------------------------------------- */
/* Define the semaphores used in various places.... */

#define APPL_INIT_SEMAPHORE	'XA:I'		/* Semaphore id for appl_init() routine access */
#define TRAP_HANDLER_SEMAPHORE	'XA:H'	/* Semaphore for access to part of the trap handler routine */
#define WIN_LIST_SEMAPHORE	'XA:W'		/* Semaphore for order modify / entry delete access to the window list */
#define ROOT_SEMAPHORE		'XA:R'		/* Semaphore for access to the root window */
#define CLIENTS_SEMAPHORE	'XA:C'		/* Semaphore for access to the clients structure */
#define FSELECT_SEMAPHORE	'XA:F'		/* Semaphore for access to the file selector */

#define UPDATE_LOCK			'XA:U'		/* Semaphore id for BEG_UPDATE */
#define MOUSE_LOCK			'XA:M'		/* Semaphore id for BEG_MCTRL */

/*----------------------------------------------------------------- */
/* Diagnostics */
#if GENERATE_DIAGS
#include <stdio.h>
#define DIAGS(x) { printf("%s:%d:",__FILE__,__LINE__); printf x ; fflush(stdout); }
#else
#define DIAGS(x)
#endif

/*----------------------------------------------------------------- */
/* For debugging, I use trap 3 for XaAES so I can run it in tandem with multiTOS. */
#if USE_DEBUG_VECTOR
#define AES_TRAP		3
#else
#define AES_TRAP		2
#endif

/*----------------------------------------------------------------- */
/* Direct call interface enable */
#if USE_CALL_DIRECT
#define CALL_DIRECT(x) Kcall_direct[(x)]=TRUE
#else
#define CALL_DIRECT(x) Kcall_direct[(x)]=FALSE
#endif

/*----------------------------------------------------------------- */
/* MiNT Memory Allocation Stuff */
#ifndef MX_STRAM
#define MX_STRAM 		0
#define MX_TTRAM		1
#define MX_PREFSTRAM	2
#define MX_PREFTTRAM 	3
#define MX_HEADER		(1<<3)
#define MX_PRIVATE		((1<<3)|(1<<4))
#define MX_GLOBAL		((1<<3)|(2<<4))
#define MX_SUPERVISOR	((1<<3)|(3<<4))
#define MX_READABLE		((1<<3)|(4<<4))
#endif

/* for debugging purposes */
#if DEBUG_MALLOCS
#define malloc(m) calloc(m,1)
#endif

#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)	__builtin_abs(i)
#endif

#endif
