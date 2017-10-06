#ifndef	__GLOBAL__
#define	__GLOBAL__

#include	"types.h"

#define	STKSIZE	4096

typedef struct globalvars {
	WORD    vid;	      /* physical vdi id of the screen */
	WORD    rez;
	RECT    screen;     /* size of physical screen */	
	WORD    num_planes; /* number of bitplanes in the display */

	WORD    realmove;   /* if set realtime moving of windows is enabled */
	WORD    realsize;
  WORD    realslide;  /* if set realtime sliding of windows is enabled */
	WORD    wind_appl;  /* show application name in window mover */

	WORD    num_pens;   /* number of available vdi pens */

	AP_LIST	*ap_pri;
	AP_LIST *applmenu;
	AP_LIST *accmenu;

	WINLIST *win_vis;
	
	WORD    mouse_x;
	WORD    mouse_y;
	WORD    mouse_button;
	
	WORD    arrowrepeat;
	ULONG   time;
	
	WORD    cswidth;
	WORD    csheight;
	WORD    bswidth;
	WORD    bsheight;

	WORD    clwidth;
	WORD    clheight;
	WORD    blwidth;
	WORD    blheight;

	WORD    fnt_small_id; /* id & size of system fonts */
	WORD    fnt_small_sz;
	WORD    fnt_regul_id;
	WORD    fnt_regul_sz;

	WORD    icon_width;   /* Width of iconified window */
	WORD    icon_height;  /* Height of iconified window */

	OBJECT  *aiconstad;
	OBJECT  *alerttad;
	OBJECT  *deskbgtad;
	OBJECT  *fiseltad;
	OBJECT  *informtad;
	OBJECT  *menutad;
	OBJECT  *mouseformstad;
	OBJECT  *pmenutad;
	OBJECT  *windowtad;
	BYTE    **fr_string;

	BYTE    mousename[30];
}GLOBALVARS;

extern GLOBALVARS	globals;

void	init_global(WORD physical);
void	exit_global(void);

#endif

