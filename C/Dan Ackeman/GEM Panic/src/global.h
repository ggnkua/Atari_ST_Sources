#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#ifdef USE_GEMLIB
	#define __GEMLIB_OLDNAMES
	#include <gem.h>
#else
	#include <aes.h>
	#include <vdi.h>
	#include <tos.h>
#endif

#include "gempanic.h"
#include "globdecl.h"
#include "bo_sound.h"
#include "avfuncs.h"
#include "extras.h"
#include "blit.h"
#include "scores.h"
#include "config.h"
#include "numbers.h"
#include "ximgload.h"

/* This will contain the common externs as well */

/* extern variables */
extern OBJECT *about_dial,*menu_ptr,*loading_dial,*icons_dial,*game_dial,
*highscore_dial,*spritenum_dial,*scorelist_dial;
extern char *alert_cantcreate, *alert_cantfind, *alert_noscore;

extern win_info win[MAX_WINDOWS];
extern int vdi_handle;
extern MFDB screen;
extern MFDB back_pic;
extern MFDB picsource;
extern int	maxx, maxy, maxw, maxh;
extern int colors[2];
extern GRECT desk;
extern MFDB title_pic;
extern MFDB game_pic;
extern RGB1000 screen_colortab[256]; /* used to save colors */
extern int screen_colors;
extern int planes;			/* number of bit planes */
extern int work_in[11], work_out[57], vwork_out[57];

extern int timer;

extern int ships;
extern int wave;
extern int y_speed;
extern int sprite_mode;

extern long score, bonus_ship;
extern char score_file[FILENAME_MAX];

extern int hidden_mouse;

extern int n_rects;
extern GRECT rect[MAX_RECTS];		/*9 a list of redraw regions */
extern GRECT trect[MAX_RECTS];		/*9 a list of redraw regions */

extern char snd_path[FILENAME_MAX];

/* extern routines */
/* in gempanic.c */
void update_player(void);
extern int do_scorelist(void);
extern void check_for_pause(void);
extern void  full_multi(void);

/* in GETPOINT.S */
extern long get_point(MFDB *);

#endif