/* GLOBDECL.H for GEM Panic */
#ifndef _GLOBDECL_H_
#define _GLOBDECL_H_

/* Game specific declarations */

#define BONUS 5000

#ifndef MAX_NUMSPRITES
#define MAX_NUMSPRITES 50
#define MAX_NUMMISSILES 10
#define MAX_NUMBOMBS 20 
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef GLOBAL
#define GLOBAL    0x0020
#endif

#ifndef ALLOCMODE
#define ALLOCMODE 3|GLOBAL
#endif


#ifndef min
#define min(a, b)             ((a) < (b) ? (a) : (b))
#endif

#ifndef max
#define max(a, b)             ((a) > (b) ? (a) : (b))
#endif

/* AES defs */
/* Definitions a plenty */

#define 	MagX_cookie		0x4D616758
#define	AES_single	0
#define	AES_MagiC	1
#define	AES_Geneva	2
#define	AES_MTOS	3
#define	AES_nAES	4

/* a couple of externs that are standard */
extern int AES_type;
extern int app_id;

/* Define the struct for all graphics */
typedef struct {
	int	bit;
	int	xspeed;
	int	yspeed;
	int	xpos;
	int	ypos;
} CORDS;

typedef struct {
	int			id;
	int			frame;
	MFDB		*surface;
	MFDB		*mask;
	GRECT		dCurrent;
	GRECT		dPrev;
	CORDS		cords;
} GRAPHIC;

#ifndef _GEMLIB_H_
typedef struct
{
   int  red;         /* red intensity in per mille */
   int  green;      /* green intensity in per mille */
   int  blue;        /* blue intensity in per mille */
} RGB1000;
#endif

/* These are the defines for the default window size */
#define WIDTH 448
#define HEIGHT 362

/* defines for default window type and game status */
#define NO_WINDOW (-1)

#define MAX_WINDOWS 6

#define GAME_WIN 0
#define ABOUT_WIN 1
#define LOADING_WIN 2
#define SCORE_WIN 3
#define SPRITES_WIN 4
#define SOUND_WIN 4

#define MAX_RECTS 85

/* macros to pass parameters */
#ifndef PTRS
#define PTRS(r) (r)->g_x, (r)->g_y, (r)->g_w, (r)->g_h
#endif

#ifndef ELTS
#define ELTS(r) (r).g_x, (r).g_y, (r).g_w, (r).g_h
#endif

#ifndef ELTR
#define ELTR(r) &(r).g_x, &(r).g_y, &(r).g_w, &(r).g_h
#endif

#if 1
#define HIDE_MOUSE graf_mouse(M_OFF,0L);
#define SHOW_MOUSE graf_mouse(M_ON,0L);
#else
#define HIDE_MOUSE v_hide_c(handle);
#define SHOW_MOUSE v_show_c(handle, 1);
#endif

#define WI_KIND	(MOVER|CLOSER|NAME)

#include "win.h"

#endif