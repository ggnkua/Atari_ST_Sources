/* This file is an ugly hack, but it should work.
 * The definitions in here have been fetched from
 * both GCC and Lattice C includes as well as from
 * the MiNT sources. Some stuff is my own as well.
 * 
 * Craig Graham has nothing to do with this file.
 * All bug reports should be directed to me (after
 * you've fixed the problem of course ;-)
 * 
 * Johan Klockars, 950213
 *
 * When compiling with GCC, use -mshort.
 */

#ifndef _LC2GCC_H
#define _LC2GCC_H

/* Lattice C code used 'far' for some reason, remove */
#define far

/* Below is to make gcc use normal evnt_multi */
#define __OLD_WAY__

/* GCC uses 16 bit ints instead */
#define short		int

#define __regargs

/* Strange Lattice C 3 compatibility thing */
#define ADDR(a)	(a)

/* 'Unofficial' alarm function */
#define tma_trap_1_wl(n, a)							\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long  _a = (long) (a);						\
	    								\
	__asm__ volatile						\
	("\
		movl	%2,sp@-; \
		movw    %1,sp@-; \
		trap    #1;	\
		addqw   #6,sp "						\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a)			/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"    /* clobbered regs */	\
	  AND_MEMORY							\
	);								\
	retvalue;							\
})
#define Tmalarm(sec)		tma_trap_1_wl(0x13d, (long)(sec))

/* Make do without gemfast.h */
#include "k_defs.h"

typedef struct _mn_set
{
    long Display;    /*  the submenu display delay     */
    long Drag;       /*  the submenu drag delay        */
    long Delay;      /*  the single-click scroll delay */
    long Speed;      /*  the continuous scroll delay   */
    short Height;    /*  the menu scroll height        */
} MN_SET;

typedef struct _menu
{
    OBJECT *mn_tree;    /* the object tree of the menu */
    short   mn_menu;    /* the parent object of the menu items */
    short   mn_item;    /* the starting menu item */
    short   mn_scroll;  /* the scroll field status of the menu 
                           0  - The menu will not scroll
                           !0 - The menu will scroll if the number of menu
                                items exceed the menu scroll height. The 
				non-zero value is the object at which 
				scrolling will begin.  This will allow one
				to have a menu in which the scrollable region
				is only a part of the whole menu.  The value
				must be a menu item in the menu.
				
                                menu_settings can be used to change the menu
                                scroll height. 

                         NOTE: If the scroll field status is !0, the menu
                               items must consist entirely of G_STRINGS. */
    short   mn_keystate; /* The CTRL, ALT, SHIFT Key state at the time the
			    mouse button was pressed. */
} MENU_T;

#define __TCC_COMPAT__

typedef struct
{
#ifdef __TCC_COMPAT__
	void		*fd_addr;
#else /* !__TCC_COMPAT__ */
	long		fd_addr;    /* Addrerss of upper left corner of first*/
                                    /* plane of raster area. If NULL then   */
                                    /* MFDB is for a physical device        */
#endif /* !__TCC_COMPAT__ */
	short		fd_w;	    /* Form Width in Pixels                 */
	short		fd_h;       /* Form Height in Pixels                */
	short		fd_wdwidth; /* Form Width in shorts(fd_w/sizeof(int)*/
	short		fd_stand;   /* Form format 0= device spec 1=standard*/
	short		fd_nplanes; /* Number of memory planes              */
	short		fd_r1;      /* Reserved                             */
	short		fd_r2;      /* Reserved                             */
	short		fd_r3;      /* Reserved                             */
} MFDB;

#define S_ONLY 		3
#define S_OR_D 		7

typedef struct mouse_form
	{
	short	mf_xhot;
	short 	mf_yhot;
	short 	mf_nplanes;
	short	mf_bg;
	short 	mf_fg;
	short 	mf_mask[16];
	short 	mf_data[16];
	} MFORM ;

#define MD_REPLACE	1
#define MD_TRANS	2
#define MD_XOR		3
#define MD_ERASE	4

/* Something out of the Lattice C includes */
#define FIS_HOLLOW	0
#define FIS_SOLID	1
#define FIS_PATTERN	2
#define FIS_HATCH	3
#define FIS_USER	4

#define THICKENED	0x0001
#define SHADED		0x0002
#define SKEWED	0x0004
#define UNDERLINED	0x0008
#define OUTLINE	0x0010
#define SHADOW	0x0020

#define _GEMFAST_H
#include <aesbind.h>
#include <vdibind.h>

#define G_CICON	33
  
#define FL3DMASK	0x0600
#define FL3DNONE	0x0000
#define FL3DIND	0x0200
#define FL3DBAK	0x0400
#define FL3DACT	0x0600

#define SPECIAL	0x0040

#define LK3DIND	1
#define LK3DACT	2
#define INDBUTCOL	3
#define ACTBUTCOL	4
#define BACKGRCOL	5
#define AD3DVALUE	6

#define M_SAVE	258
#define M_RESTORE	259
#define M_PREVIOUS	260

#define WF_OWNER	20
#define WF_BEVENT	24
#define WF_BOTTOM	25
#define WF_ICONIFY	26
#define WF_UNICONIFY	27
#define WF_UNICONIFYXYWH	28
#define WF_TOOLBAR	30
#define WF_FTOOLBAR	31
#define WF_NTOOLBAR	32

/* Could not find this definition anywhere but in the MiNT sources! */
#define O_GLOBAL	0x1000
#endif
