/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* HR: the word global should really be kept reserved for (future?)
       use as the opposite of auto, local or static. */

#ifndef _XA_DEFS_H_
#define _XA_DEFS_H_

#ifndef PRELUDE_H
#include <prelude.h>
#endif

#define PRELUDE_H

/* HR: Get the stupid slashes out of all the texts */
#define bslash '\\'
#define slash  '/'
#define sbslash "\\"
#define sslash "/"

#define begin_decls __BEGIN_DECLS
#define end_decls __END_DECLS

/*----------------------------------------------------------------- */
/* COMPILE TIME SWITCHES */
/* - define as 1 to turn on, 0 to turn off */
/*----------------------------------------------------------------- */

#define SEPARATE_SCL			1		/* Run xa_scl.prg at bootup */

#define HALF_SCREEN				1		/* Support for WF_SCREEN */

#define MOUSE_KLUDGE			1		/* Still needed including MiNT 1.15.3 */

#define TEAR_OFF				0		/* menu tear off support */
#define USE_DEBUG_VECTOR		0		/* Hook trap3 instead of trap2 to allow debugging under GEM */

#define DISPLAY_LOGO_IN_TITLE_BAR	0		/* Display the XaAES logo in the title bar of each window */

/* HR if defined focus can be dynamically changed in the cfg (see parde*/
#define POINT_TO_TYPE			0

#define ALT_CTRL_APP_OPS		1		/* Some ALT+CTRL+key combo's will perform functions relating to */
                       					/* the XaAES system */
#define USE_CALL_DIRECT			0		/* Bypass the command pipe for certain op-codes */
#define NOSEMA_CALL_DIRECT		1		/* HR 110802: Call direct for small AES functions that do not need the call_direct semaphores. */

#if USE_CALL_DIRECT
#define IFWL(x) x						/* Used for completely leave out winlist locking code. */
#else
#define IFWL(x)
#endif

#define MEMORY_PROTECTION		1		/* Enable patches to help with memory protection */

#define PRESERVE_DIALOG_BGD		0		/* Preserve the background of dialogs */

#define FILESELECTOR			1		/* Build a XaAES with fileselector */

/*----------------------------------------------------------------- */
/* Maximum space for 'nice name' for app's (menu_register) */
#define NICE_NAME				32
/* CONFIGURABLE PARAMETERS */
#define STRINGS					1024		/* HR: number of environment variable allowes in zaaes.cnf */
#define NUM_CB					32		/* HR: table of cancel button texts */
#define CB_L					16
#define CASCADE					16		/* Max depth of cascading menus */

/* Maximum number of windows that can be created concurrently */
#define MAX_WINDOWS 			4096		/* HR: should this be enough? */
#define LBITS					32		/* no of bits in a long */
#define LFULL					0xffffffff

#define MAX_IN_PLACE_TRNFM		128		/* For larger icons a temporary buffer is allocated to speed up vr_trnfm */
										/* 128 = 16*16 icon in 4 planes */
#define MAX_PID			  	 	1000		/* Max number of client process' */
#define MAX_CLIENT         		32

#define DU_RSX_CONV 			8		/* Resource char to pixel coord conversion constants. */
#define DU_RSY_CONV 			16		/* If you are designing your resources in ST-Low res,  */
										/*  change DU_RSY_CONV to 8 */
#define STANDARD_FONT_POINT		10		/* Size of the 'standard' AES font (for window titles, etc) */
#define MEDIUM_FONT_POINT		9		/* The same, but for low resolution screens */
#define SMALL_FONT_POINT		8		/* Size of the 'small' AES font. */
#define STANDARD_AES_FONTID		1		/* Standard GDOS fontid for windows & stuff (set to 1 for no GDOS) */
#define TINY_FONT				6		/* pixelsize of the 6x6 font */

#define ICON_W 0x0010		/* HR (ex widgets.c) */
#define ICON_H 0x0010

#define GRAF_STEPS				10		/* Number of intermediate steps in a graf_growbox(), etc */

#define PUSH3D_DISTANCE			1		/* Distance text on selected (pushed in) 3D objects will move */
#define SHADOW_OFFSET			2		/* Offset used for shadowing objects */

#define ICONIFIED_W				80		/* Size of an iconified window */
#define ICONIFIED_H				80

#define DOUBLE_CLICK_TIME		50		/* Default double click time in milliseconds (0-200) */

#define RT_SCROLL_STEP			10		/* Step when doing a real-time scroll (0-1000) */

#define MENU_H					(screen.c_max_h + 2)	/* HR: Standard hight od a menu bar */
#define MG						2		/* HR: standard frame size for windows */

/*----------------------------------------------------------------- */
/* VERSION NUMBER */
#define ASCII_VERSION			"v0.963"
#define HEX_VERSION				0x0963

/*----------------------------------------------------------------- */
/* Return codes in the clients reply pipe */
#define XA_OK					0L		/* Ok, op-code done */
#define XA_UNIMPLEMENTED		1L		/* Unimpemented but valid op-code */
#define XA_ILLEGAL				2L		/* Illegal op-code */
#define XA_TIMER				3L		/* HR 051201: Unclumsify the timer value passing. */
#define XA_UNLOCK				4L		/* HR 250202: Implies Blocking. unlock the screen and then read the command pipe again. */

/*----------------------------------------------------------------- */
/* HR 090701: codes follow same pattern as above */
/* Return codes from op-code service functions */
#define XAC_BLOCK				0L		/* Block the client indefinitely */
#define XAC_DONE				1L		/* Function completed - release client immediately */
#define XAC_ILLEGAL				2L		/* Illegal address (memory violation detected by Mvalidate) */
#define XAC_TIMER				3L		/* HR 051201: Unclumsify the timer value passing. */
#define XAC_EXIT				4L		/* HR 111201: special block reply for appl_exit.
									              after the waiting Fread, the client_end is closed and cleared.
									              This replaces the (#if 0'd) code in XA_appl_exit */

/*----------------------------------------------------------------- */
/* Define the semaphores used in various places... */

#ifdef __GNUC__
#define APPL_INIT_SEMA			0x58413A49	/* Semaphore id for appl_init() routine access */
/*
#define TRAP_HANDLER_SEMA		0x58413A48 	/* Semaphore for access to part of the trap handler routine */
*/
#define WIN_LIST_SEMA			0x58413A57	/* Semaphore for order modify / entry delete access to the window list */
#define ROOT_SEMA				0x58413A52	/* Semaphore for access to the root window */
#define CLIENTS_SEMA			0x58413A43	/* Semaphore for access to the clients structure */
#define FSELECT_SEMA			0x58413A46	/* Semaphore for access to the file selector */
#define ENV_SEMA				0x58413A45		/* Semaphore for access to the environment strings */

#define UPDATE_LOCK				0x58413A55	/* Semaphore id for BEG_UPDATE */
#define MOUSE_LOCK				0x58413A4D	/* Semaphore id for BEG_MCTRL */

#define PENDING_SEMA			0x58413A50	/* Semaphore id to guard pending button&keybd events */

#else

#define APPL_INIT_SEMA			'XA:I'		/* Semaphore id for appl_init() routine access */
/*
#define TRAP_HANDLER_SEMA		'XA:H'		/* Semaphore for access to part of the trap handler routine */
*/
#define WIN_LIST_SEMA			'XA:W'		/* Semaphore for order modify / entry delete access to the window list */
#define ROOT_SEMA				'XA:R'		/* Semaphore for access to the root window */
#define CLIENTS_SEMA			'XA:C'		/* Semaphore for access to the clients structure */
#define FSELECT_SEMA			'XA:F'		/* Semaphore for access to the file selector */
#define ENV_SEMA				'XA:E'		/* Semaphore for access to the environment strings */

#define UPDATE_LOCK				'XA:U'		/* Semaphore id for BEG_UPDATE */
#define MOUSE_LOCK				'XA:M'		/* Semaphore id for BEG_MCTRL */

#define PENDING_SEMA			'XA:P'		/* Semaphore id to guard pending button&keybd events */
#endif

#define appl_SEMA		APPL_INIT_SEMA
/*#define trap_SEMA		TRAP_HANDLER_SEMA */
#define winlist_SEMA	WIN_LIST_SEMA
#define desk_SEMA		ROOT_SEMA
#define clients_SEMA	CLIENTS_SEMA
#define fsel_SEMA		FSELECT_SEMA
#define envstr_SEMA		ENV_SEMA

#define update_SEMA		UPDATE_LOCK
#define mouse_SEMA		MOUSE_LOCK

#define pending_SEMA	PENDING_SEMA

/*----------------------------------------------------------------- */
/* Diagnostics */
#if GENERATE_DIAGS
#include "debug.h"
#else
#define DIAGS(x)
#define DIAG(x)
#define IFDIAG(x)
#define TRACE(x)
#define CONTROL(a,b,c)
#define MAX_NAMED_DIAG 0		/* HR */
#define Sema_Up(id) if (!(lock&id)) Psemaphore(2,id ## _SEMA,-1)
#define Sema_Dn(id) if (!(lock&id)) Psemaphore(3,id ## _SEMA, 0)
#define NAES3D 0
#endif


/*----------------------------------------------------------------- */
/* For debugging, I use trap 3 for XaAES so I can run it in tandem with MultiTOS. */
#if USE_DEBUG_VECTOR
#define AES_TRAP		3
#else
#define AES_TRAP		2
#endif

/*----------------------------------------------------------------- */
/* MiNT Memory Allocation Stuff */
#ifndef MX_STRAM
#define MX_STRAM 		0
#define MX_TTRAM		1
#define MX_PREFSTRAM	2
#define MX_PREFTTRAM 	3
#define MX_HEADER		(1 << 3)
#define MX_PRIVATE		((1 << 3) | (1 << 4))
#define MX_GLOBAL		((1 << 3) | (2 << 4))
#define MX_SUPERVISOR	((1 << 3) | (3 << 4))
#define MX_READABLE		((1 << 3) | (4 << 4))
#endif

enum		/* Ssystem() codes */
{
	S_OSNAME,
	S_OSXNAME,
	S_OSVERSION,
	S_GETCOOKIE = 8,
	S_SETCOOKIE
};

#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)		__builtin_abs(i)
#endif

#define V_wait(t) {int i=70*t; while (i--) Vsync();}
#define unlocked(a) (!(lock&a))
#endif

void hidem(void);
void showm(void);
void forcem(void);

#define via(x) if (x) (*x)

#if sizeof(short) != 2
#error This complilation will only be successfull when the short integer type is 16 bits
#endif

#define ping Cconout(7)
