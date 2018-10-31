/*
 *   GEMPANIC.C
 * December, 2004
 * 
 * Dan Ackerman baldrick@columbus.rr.com
 * http://www.gemcandy.org/
 */

/* 
 * PHD: I used latest GEMLIB from internet and "adapted" the
 * source files (="ifdef _GEMLIB_H_" or "ifdef USE_GEMLIB").
 * To compile with GEMLIB you have to set "USE_GEMLIB" in Pure C
 * compiler options: "define macro: USE_GEMLIB"
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "global.h"

/* This is PureC's way of knowing if we are an ACC or APP */
extern int _app;

/* our way of knowing what we are running under */
int AES_type;

/* a test to see if this is the first time prg has run */
int config_loaded = 0;

/* Declare all functions */
void		InitVideo();
int 		Collide (GRAPHIC *sprite1, GRAPHIC *sprite2); 
void		redraw_player(void);
void		redraw_sprites(void);
void		setup_game(void);
void		next_wave(void);
void		new_game(void);
void		m_timing_event(void);
void		full_multi(void);

int player1_digit1 = 0;
int player1_digit2 = 0; 

int player2_digit1 = 0;
int player2_digit2 = 0;


GRAPHIC		player;

CORDS			remote;

MFDB screen;
int event;
short *keys;

OBJECT *about_dial,*menu_ptr,*timing_dial,*loading_dial,*icons_dial,*game_dial,
*highscore_dial,*spritenum_dial,*scorelist_dial,*snd_dial;

char *alert_cantcreate, *alert_cantfind, *alert_noscore;

MFDB title_pic;
MFDB back_pic;
MFDB picsource;
MFDB player_pic;
MFDB player_mask;
MFDB bomb_pic;
MFDB bomb_mask;
MFDB drone_pic;
MFDB drone_mask;
MFDB bomber_pic;
MFDB bomber_mask;
MFDB explani_pic;
MFDB explani_mask;
MFDB missile_pic;
MFDB missile_mask;
MFDB ready_pic;
MFDB ready_mask;
MFDB gameover_pic;
MFDB gameover_mask;
MFDB bonusmsg_pic;
MFDB bonusmsg_mask;

/* colision MFDB's */
MFDB colision;
MFDB colision1;
long colision_size;

/* Program version */
char title_bar[] = "  GEM PANIC 0.90  ";
char *app_version = "0.90";


int menu_id, app_id;
int	phys_handle;	/* physical workstation handle */
int	vdi_handle;			/* virtual workstation handle */
int	game_win;			/* game window handle for speed */

int	gl_hchar, gl_wchar, gl_wbox, gl_hbox;	/* sizes of system characters */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];

GRECT desk;
GRECT old;
GRECT work;			/* desktop and work areas */
int planes;			/* number of bit planes */
int screen_colors;

int old_mousex = 0;
int old_mousey = 0;
int hidden_mouse = 0;
int n_rects;
GRECT rect[MAX_RECTS];		/*9 a list of redraw regions */
GRECT trect[MAX_RECTS];		/*9 I'm not sure why a list of redraw regions */

int work_in[11], work_out[57], vwork_out[57];
int	maxx, maxy, maxw, maxh;
RGB1000 temp_colortab[256]; /* used to save colors */
RGB1000 screen_colortab[256]; /* used to save colors */

int colors[2];    

int	win_kind = WI_KIND;
int win_width = 448;
int win_height = 344;
int win_ht = HEIGHT;
win_info win[MAX_WINDOWS];

int timer = 0;
int ttimer, event_kind = MU_KEYBD | MU_MESAG | MU_BUTTON;

int done = FALSE;

char path[PATH_MAX], name[FILENAME_MAX], lpath[FILENAME_MAX], spath[FILENAME_MAX];
char score_file[FILENAME_MAX];
char config_file[FILENAME_MAX];
char snd_path[FILENAME_MAX];

#define STARTTIME 30
#define SPEEDUP 2500

int debugvalue = 9999;
long score = 0, bonus_ship;

clock_t tout;
int gameinplay = 0;
int paused = 0;

int ships = 3;
int wave = 0;
int death_toll=0;
int death_total = 0;
int speed;
int shots;

int sprite_mode = 0;
int max_sprites = 10;
int num_drones = 0;
int num_bombers = 0;
int cur_bombers = 0;

int total_enemies = 0;
int num_shots = 0;
int num_bombs = 0;

int drone_max[2];

GRAPHIC missile[MAX_NUMMISSILES];
GRAPHIC bombs[MAX_NUMBOMBS];

GRAPHIC sprite[MAX_NUMSPRITES];

/******* sprite id's *********/
#define UNUSED		0
#define DRONE		1
#define BOMBER		2
#define EXPLSTART	3
#define EXPLANIMA	4
#define EXPLEND  	5
#define MISSILE		6
#define BOMB		7

char sprite_list[] = 
{UNUSED,DRONE,BOMBER,EXPLSTART,EXPLANIMA,EXPLEND,MISSILE,BOMB};

int randomize;

int y_speed = 4;
int y_minspeed = 0;
int y_maxspeed = 30;

int last_x = 0;

/* sound buffers */
SND shot_snd; /* missile fired */
SND expl_snd; /* enemy hit */
SND bomb_snd; /* enemy bomb */
SND boom_snd; /* player hit */
SND last_snd; /* last ship */
SND next_snd; /* next ship */
SND perf_snd; /* perfect accuracy */
SND good_snd; /* good accuracy */
SND badd_snd; /* bad accuracy */
SND done_snd; /* average accuracy */
SND tada_snd; /* highscore */
SND warn_snd; /* warning siren */
SND exit_snd; /* play on close - resets chip in chip sound */

/* InitVideo()
 *
 * starts up the vdi info and gets some display
 * information for use elsewhere
 */
 
void
InitVideo(void) 
{
	register int i;
	int junk;

/* Ok we are going to need to init the MFDB for the screen here,
 * not really all that bad to do.  Just need to do it */

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	vdi_handle = graf_handle( &junk, &junk, &junk, &junk );
	v_opnvwk(work_in,&vdi_handle,work_out);

	vq_extnd(vdi_handle, 1, vwork_out);
	screen_colors = work_out[13];
	planes = vwork_out[4];

	screen.fd_addr	=  Logbase();
	screen.fd_w		= work_out[0] + 1;
	screen.fd_h		= work_out[1] + 1;
	screen.fd_wdwidth= (screen.fd_w + 15) >> 4;
	screen.fd_stand	= 0;
	screen.fd_nplanes = planes;

	save_colors(&screen_colortab);
}

/* Collide()
 * 
 * does a collsion detection between two sprites
 * returns 0 if not collision	
 * returns 1 if there is a collision detected
 */
 
int
Collide (GRAPHIC *sprite1, GRAPHIC *sprite2) 
{
	int max_x,max_y;		/* PHD: for rect. intersection */
	int x, y, w, h;
	GRECT *r1,*r2;
	long dtest=-1;			/* PHD: don't forget to initialize! */
	int pxy[8];

	r1 = (GRECT *)&sprite1->dCurrent;
 	r2 = (GRECT *)&sprite2->dCurrent;

   x = min( r2->g_x, r1->g_x );
   y = min( r2->g_y, r1->g_y );
	w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

	/* PHD: abort calulations if sprite RECTs don't intersect: */
   max_x = max( r2->g_x, r1->g_x );		/* PHD: intersection calculations (see rc_intersect) */
   max_y = max( r2->g_y, r1->g_y );		/* PHD: intersection calculations */
   if(!(((w > max_x) && (h > max_y))))
   	return(0);

	pxy[0] = pxy[1] = 0;
	pxy[2] = r1->g_w - 1; 
	pxy[3] = r1->g_h - 1;
	pxy[4] = r1->g_x - x;
	pxy[5] = r1->g_y - y;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];
	vro_cpyfm(vdi_handle,S_ONLY,pxy,sprite1->mask,&colision);	/* PHD: Beware pointers! */

	pxy[0] = pxy[1] = 0;
	pxy[2] = r2->g_w - 1; 
	pxy[3] = r2->g_h - 1;
	pxy[4] = r2->g_x - x;
	pxy[5] = r2->g_y - y;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];
	vro_cpyfm(vdi_handle,S_ONLY,pxy,sprite2->mask,&colision1);	/* PHD: Beware pointers! */

	pxy[0] = pxy[1] = pxy[4] = pxy[5] = 0;
	pxy[2] = pxy[6] = colision.fd_w-1;
	pxy[3] = pxy[7] = colision.fd_h-1;
	vro_cpyfm(vdi_handle,S_AND_D,pxy,&colision1,&colision);
 
	dtest = get_point(&colision);
	
	pxy[0] = pxy[1] = pxy[4] = pxy[5] = 0;
	pxy[2] = pxy[6] = colision.fd_w - 1;	
	pxy[3] = pxy[7] = colision.fd_h - 1;

	memset(colision.fd_addr,0,colision_size);		/* PHD: memset(ptr,val,len) !!!! */
	memset(colision1.fd_addr,0,colision_size);	/* PHD: memset(ptr,val,len) !!!! */
	
	if (dtest != (long)-1)
		return(1);
	else
		return(0);
}

/* Collidehotpoint()
 * 
 * detects if coordinates hotx and hoty would intersect
 * with the bounding box for the sprite.
 * Not the best collision detection, but it's fast and
 * can be used sometimes with only minimal irritation to
 * the player.
 * It's used in this program to get the speed to the point
 * it will run on a stock falcon
 */
 
int 
Collidehotpoint (GRAPHIC *sprite1, int hotx, int hoty) 
{
  GRECT *r1;
  int width;
 
  	r1 = (GRECT *)&sprite1->dCurrent;

	/* this determines the width for animated sprites */
	if (r1->g_w > r1->g_h)
		width = r1->g_h;
	else
		width = r1->g_w;
	
	if((hotx < r1->g_x + width)
	&&(hotx > r1->g_x)
	&&(hoty > r1->g_y)
	&&(hoty < r1->g_y + r1->g_h))
		return(1);
	else
		return(0); 
}

/* add_sprite()
 * 
 * adds a new enemy sprite to the screen.
 * sprite_idx is the slot to put the sprite into in the list
 * type is what sprite we are adding
 * x_pos is it's starting location. 
 * In GemPanic all sprites start at the same y offset
 */
void
add_sprite(int sprite_idx, int type, int x_pos)
{
	register GRAPHIC *p;

	p = &sprite[sprite_idx];

	switch(sprite_list[type])
	{
		case DRONE:
			p->id = DRONE;
			p->frame = 0;
			p->surface = (MFDB *)&drone_pic;
			p->mask = (MFDB *)&drone_mask;

			while (p->cords.xspeed==0)
				p->cords.xspeed = (int)random(5)+speed;

			while (p->cords.yspeed==0)
				p->cords.yspeed=(int)random(5)+speed;

			break;

		case BOMBER:
			p->id = BOMBER;
			p->frame = 0;
			p->surface = (MFDB *)&bomber_pic;
			p->mask = (MFDB *)&bomber_mask;
		
			while (p->cords.xspeed==0)
				p->cords.xspeed = (int)random(5)+speed;

			while (p->cords.yspeed==0)
				p->cords.yspeed=(int)random(5)+speed;
		
			break;
	}

	p->cords.bit = 0;
	p->cords.xpos = x_pos * (p->surface->fd_w / 2); 
	p->cords.ypos = 0; /*ROWOFF;*/
	
	p->dCurrent.g_x = p->cords.xpos;
	p->dCurrent.g_y = p->cords.ypos;
	p->dCurrent.g_w = p->surface->fd_w;
	p->dCurrent.g_h = p->surface->fd_h;
	
	p->dPrev = p->dCurrent;
}

/* add_bomb()
 *
 * starts a new bomb sprite on it's trek to the bottom of
 * the play area
 */
 
void
add_bomb(int x_pos, int y_pos)
{
	register GRAPHIC *p;
	int ndx;

	/* if too many bombs return */
	if (num_bombs > MAX_NUMBOMBS)
		return;
		
	for (ndx=0;ndx<MAX_NUMBOMBS;ndx++)
	{
		p = &bombs[ndx];

		if (p->id == UNUSED)
		{
			p->id = BOMB;
			p->frame = 0;
			p->surface = (MFDB *)&bomb_pic;
			p->mask = (MFDB *)&bomb_mask;
				
			p->cords.xspeed = 0;
			p->cords.yspeed = 6;
	
			p->cords.bit = 0;
			p->cords.xpos = x_pos;
			p->cords.ypos = y_pos;
	
			p->dCurrent.g_x = p->cords.xpos;
			p->dCurrent.g_y = p->cords.ypos;
			p->dCurrent.g_w = p->surface->fd_w;
			p->dCurrent.g_h = p->surface->fd_h;
	
			p->dPrev = p->dCurrent;

			sound_play(&bomb_snd, 2, PLAY_ENABLE);
	
			num_bombs++;
			break;
		}
	}
}

/* add_missile()
 *
 * starts a new missile sprite on it's trek to the top
 * of the play area.
 */
 
void
add_missile(int button, int x, int y)
{
	register GRAPHIC *p;
	int ndx;
	static int released = TRUE;

	if (num_shots > MAX_NUMMISSILES)
		 return;

	if ((button&2)||(button&1))
	{		
		if (released == TRUE)
		{
			for (ndx=0;ndx<MAX_NUMMISSILES;ndx++)
			{
				p = &missile[ndx];

				if (p->id == UNUSED)
				{
					p->id = MISSILE;
					p->frame = 0;
					p->surface = (MFDB *)&missile_pic;
					p->mask = (MFDB *)&missile_mask;
				
					p->cords.xspeed = 0;
					p->cords.yspeed = -8;
	
					num_shots++;

					sound_play(&shot_snd, 2, PLAY_ENABLE);

					break;
				}
			}

			shots++;

			p->cords.bit = 0;
			p->cords.xpos = x+8;
			p->cords.ypos = y;
	
			p->dCurrent.g_x = p->cords.xpos;
			p->dCurrent.g_y = p->cords.ypos;
			p->dCurrent.g_w = p->surface->fd_w;
			p->dCurrent.g_h = p->surface->fd_h;
	
			p->dPrev = p->dCurrent;
	
			released = FALSE;
		}
	}
	else
		released = TRUE;
}

/* init_enemy()
 *
 * init positions and vectors for drones 
 */
 
void
init_enemy(void)
{
	int temp;

	death_toll=0; /* no sprites dead yet */

	for (temp=0;temp<num_bombers;temp++)
		add_sprite(num_drones + temp, BOMBER, 1);

	for (temp=0;temp<num_drones;temp++)
		add_sprite(temp, DRONE, 1);
}


/* open_window()
 *
 * handles opening the game window if we are running as an ACC
 */

int
open_window(void)
{
	if ((game_win=wind_create(win_kind,desk.g_x,desk.g_y,maxw,maxh)) < 0)
		return -1;

	#ifdef _GEMLIB_H_
		wind_set_str(game_win, WF_NAME,title_bar);
	#else
		wind_set(game_win, WF_NAME,title_bar,0,0);
	#endif
	
	graf_growbox(desk.g_x,desk.g_y,gl_wbox,gl_hbox,old.g_x,old.g_y,old.g_w,old.g_h);
	wind_open(game_win,old.g_x,old.g_y,old.g_w,old.g_h);
	wind_get(game_win,WF_WORKXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
	
	event_kind = MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON;

	return (1);
}


/* rsrc_init()
 * 
 * inits all of our object pointers
 */
 
void 
rsrc_init(void)
{
	rsrc_gaddr(0, MENU,&menu_ptr); 	
	rsrc_gaddr(0, ABOUT,&about_dial);
	rsrc_gaddr(0, LOADING,&loading_dial);
	rsrc_gaddr(0, ICONS,&icons_dial);
	rsrc_gaddr(0, GAME,&game_dial);
	rsrc_gaddr(0, HIGHSCORE,&highscore_dial);
	rsrc_gaddr(0, SCORELIST,&scorelist_dial);
	rsrc_gaddr(0, SPRITENUM,&spritenum_dial);
	rsrc_gaddr(0, TIMING,&timing_dial);
	rsrc_gaddr(0, SOUND,&snd_dial);
	rsrc_gaddr(R_STRING,ALERT_CANTCREATE,&alert_cantcreate);
	rsrc_gaddr(R_STRING,ALERT_CANTFIND,&alert_cantfind);
	rsrc_gaddr(R_STRING,ALERT_NOSCOR,&alert_noscore);
}

/* m_new_event()
 *
 * starts a new game, opens game widow if not already open
 */
 
int
m_new_event(void)
{
	int wh;
	
	wh = new_window(game_dial,title_bar,0);

	if (wh >= 0)
	{
		win[GAME_WIN].handle = wh;
		win[GAME_WIN].window_obj = game_dial;
		win[GAME_WIN].title = title_bar;
		win[GAME_WIN].cur_item = -1;
		win[GAME_WIN].status = 1;
		win[GAME_WIN].image = back_pic;
		win[GAME_WIN].edit = 0;
		win[GAME_WIN].type = 0;
		
		win[GAME_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[GAME_WIN].current));

		wind_calc(WC_WORK, W_TYPE, ELTS(win[GAME_WIN].current),
						  ELTR(win[GAME_WIN].current));

		win[GAME_WIN].window_obj[ROOT].ob_x = win[GAME_WIN].current.g_x;
		win[GAME_WIN].window_obj[ROOT].ob_y = win[GAME_WIN].current.g_y;
		win[GAME_WIN].window_obj[ROOT].ob_width = win[GAME_WIN].current.g_w;
		win[GAME_WIN].window_obj[ROOT].ob_height = win[GAME_WIN].current.g_h;

	}

	old.g_x = win[GAME_WIN].window_obj[ROOT].ob_x;
	old.g_y = win[GAME_WIN].window_obj[ROOT].ob_y;
		
	return(wh);
}

/* m_quit_event()
 * 
 * tells program to stop
 */
void
m_quit_event(void)
{
	gameinplay = 0; 

	done = TRUE;
}

/* do_scorelist()
 *
 * init's the scorelist window struct and opens it
 */
 
int
do_scorelist(void)
{
	int wh;

	wh = new_window(scorelist_dial,title_bar,0);

	if (wh >= 0)
	{
		win[SCORE_WIN].handle = wh;		
		win[SCORE_WIN].window_obj = scorelist_dial;
		win[SCORE_WIN].title = title_bar;
		win[SCORE_WIN].cur_item = -1;
		win[SCORE_WIN].status = 1;
		win[SCORE_WIN].image = title_pic;
		win[SCORE_WIN].edit = 0;
		win[SCORE_WIN].type = 0;
		
		win[SCORE_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[SCORE_WIN].current));

		win[SCORE_WIN].window_obj[ROOT].ob_x = win[SCORE_WIN].current.g_x;
		win[SCORE_WIN].window_obj[ROOT].ob_y = win[SCORE_WIN].current.g_y;
		win[SCORE_WIN].window_obj[ROOT].ob_width = win[SCORE_WIN].current.g_w;
		win[SCORE_WIN].window_obj[ROOT].ob_height = win[SCORE_WIN].current.g_h;		
	}

	return(wh);
}

/* do_sndconfig()
 *
 * inits the sound config window and opens it
 */
 
int
do_sndconfig(void)
{
	int wh;

	wh = new_window(snd_dial,title_bar,0);

	if (wh >= 0)
	{
		win[SOUND_WIN].handle = wh;		
		win[SOUND_WIN].window_obj = snd_dial;
		win[SOUND_WIN].title = title_bar;
		win[SOUND_WIN].cur_item = -1;
		win[SOUND_WIN].status = 1;
		win[SOUND_WIN].image = title_pic;
		win[SOUND_WIN].edit = 0;
		win[SOUND_WIN].type = 0;
		
		win[SOUND_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[SOUND_WIN].current));

		win[SOUND_WIN].window_obj[ROOT].ob_x = win[SOUND_WIN].current.g_x;
		win[SOUND_WIN].window_obj[ROOT].ob_y = win[SOUND_WIN].current.g_y;
		win[SOUND_WIN].window_obj[ROOT].ob_width = win[SOUND_WIN].current.g_w;
		win[SOUND_WIN].window_obj[ROOT].ob_height = win[SOUND_WIN].current.g_h;
		
		/* Now init the buttons */
		if (sound_sys == FLC_SOUND)
			objc_change(win[SOUND_WIN].window_obj,B_SND_XBIOS,0,ELTS(win[SOUND_WIN].current),0x0000,0);

		if(gemjing_id>=0)
			objc_change(win[SOUND_WIN].window_obj,B_SND_GEMJING,0,ELTS(win[SOUND_WIN].current),0x0000,0);			

		/* set the configured button to selected */
		switch (snd_flag)
		{
			case SND_OFF:
				objc_change(win[SOUND_WIN].window_obj,B_SND_NONE,0,ELTS(win[SOUND_WIN].current),0x0001,1);
				break;
			case SND_CHIP:
				objc_change(win[SOUND_WIN].window_obj,B_SND_CHIP,0,ELTS(win[SOUND_WIN].current),0x0001,1);
				break;
			case SND_XBIOS:
				objc_change(win[SOUND_WIN].window_obj,B_SND_XBIOS,0,ELTS(win[SOUND_WIN].current),0x0001,1);
				break;
			case SND_GEMJING:
				objc_change(win[SOUND_WIN].window_obj,B_SND_GEMJING,0,ELTS(win[SOUND_WIN].current),0x0001,1);
				break;	
		}
	}

	return(wh);
}

/* sndconfig_drive()
 * 
 * handles mouse button events into the sndconfig window
 */
 
int
sndconfig_drive(int which_obj)
{
	GRECT p;
	
	wind_get(win[SOUND_WIN].handle,WF_WORKXYWH,ELTR(p));

	if (win[SOUND_WIN].window_obj[which_obj].ob_state == DISABLED)
		return(0);

	if(which_obj == B_SND_SET)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0000,0);

		wind_close(win[SOUND_WIN].handle);
		wind_delete(win[SOUND_WIN].handle);
		win[SOUND_WIN].handle = NO_WINDOW;
		
		snd_flag = temp_snd_flag;
	}
	else if(which_obj == B_SND_CANCEL)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0000,0);

		wind_close(win[SOUND_WIN].handle);
		wind_delete(win[SOUND_WIN].handle);
		win[SOUND_WIN].handle = NO_WINDOW;
		
		temp_snd_flag = snd_flag;
	}	
	else if(which_obj == B_SND_NONE)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_CHIP,0,ELTS(p),0x0000,1);

		if (win[SOUND_WIN].window_obj[B_SND_XBIOS].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_XBIOS,0,ELTS(p),0x0000,1);
		if (win[SOUND_WIN].window_obj[B_SND_GEMJING].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_GEMJING,0,ELTS(p),0x0000,1);

		temp_snd_flag = SND_OFF;
	}
	else if(which_obj == B_SND_CHIP)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_NONE,0,ELTS(p),0x0000,1);

		if (win[SOUND_WIN].window_obj[B_SND_XBIOS].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_XBIOS,0,ELTS(p),0x0000,1);
		if (win[SOUND_WIN].window_obj[B_SND_GEMJING].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_GEMJING,0,ELTS(p),0x0000,1);

		temp_snd_flag = SND_CHIP;
	}
	else if(which_obj == B_SND_XBIOS)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_NONE,0,ELTS(p),0x0000,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_CHIP,0,ELTS(p),0x0000,1);

		if (win[SOUND_WIN].window_obj[B_SND_GEMJING].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_GEMJING,0,ELTS(p),0x0000,1);

		temp_snd_flag = SND_XBIOS;
	}
	else if(which_obj == B_SND_GEMJING)
	{
		objc_change(win[SOUND_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_NONE,0,ELTS(p),0x0000,1);
		objc_change(win[SOUND_WIN].window_obj,B_SND_CHIP,0,ELTS(p),0x0000,1);

		if (win[SOUND_WIN].window_obj[B_SND_XBIOS].ob_state != DISABLED)
			objc_change(win[SOUND_WIN].window_obj,B_SND_XBIOS,0,ELTS(p),0x0000,1);

		temp_snd_flag = SND_GEMJING;
	}
	
	return(1);
}

/* do_title()
 * 
 * inits about window and opens it
 */
int
do_title(void)
{
	int wh;

	wh = new_window(about_dial,title_bar,0);

	if (wh >= 0)
	{
		win[ABOUT_WIN].handle = wh;
		win[ABOUT_WIN].window_obj = about_dial;
		win[ABOUT_WIN].title = title_bar;
		win[ABOUT_WIN].cur_item = -1;
		win[ABOUT_WIN].status = 1;
		win[ABOUT_WIN].image = title_pic;
		win[ABOUT_WIN].edit = 0;
		win[ABOUT_WIN].type = 0;
			
		win[ABOUT_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[ABOUT_WIN].current));

		win[ABOUT_WIN].window_obj[ROOT].ob_x = win[ABOUT_WIN].current.g_x;
		win[ABOUT_WIN].window_obj[ROOT].ob_y = win[ABOUT_WIN].current.g_y;
		win[ABOUT_WIN].window_obj[ROOT].ob_width = win[ABOUT_WIN].current.g_w;
		win[ABOUT_WIN].window_obj[ROOT].ob_height = win[ABOUT_WIN].current.g_h;		
	}
	
	return(wh);
}

/* do_loading()
 * 
 * inits loading window and opens it
 * Loading window is opened at game start to show the progress
 * of the game data being loaded. So the user knows that something
 * is actually happening
 */

int
do_loading(void)
{
	int wh;

	wh = new_window(loading_dial,title_bar,2);

	if (wh >= 0)
	{
		win[LOADING_WIN].handle = wh;
		win[LOADING_WIN].window_obj = loading_dial;
		win[LOADING_WIN].title = title_bar;
		win[LOADING_WIN].cur_item = -1;
		win[LOADING_WIN].status = 1;
		win[LOADING_WIN].image = title_pic;
		win[LOADING_WIN].edit = 0;
		win[LOADING_WIN].type = 2;
			
		win[LOADING_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[LOADING_WIN].current));
	}

	return(wh);
}

/* do_getready()
 *
 * Display GET READY image in play area
 */
 
void
do_getready(void)
{
	int array[8];

	array[0] = 0;
	array[1] = 0;
	array[2] = back_pic.fd_w - 1;
	array[3] = back_pic.fd_h - 1;
	array[4] = array[0];
	array[5] = array[1];
	array[6] = array[2];
	array[7] = array[3];

	clear_back(array);

	array[0] = 0;
	array[1] = 0;
	array[2] = ready_pic.fd_w - 1;
	array[3] = ready_pic.fd_h - 1;
	array[4] = 104 + array[0];
	array[5] = 84 +array[1];
	array[6] = 104 +array[2] - 1;
	array[7] = 84 +array[3] - 1;
		
	cpy_2_back(array, &ready_pic, &ready_mask);
	
	show_score();
	show_wave();
	show_ships();

	/* display window */
    do_wind_redraw(win[GAME_WIN].handle,(GRECT *)&win[GAME_WIN].current);

	/* wait 2 seconds */
	tout = clock() + (2 * CLK_TCK);
	
    while (clock() < tout) 
		;
		
	array[0] = 0;
	array[1] = 0;
	array[2] = ready_pic.fd_w - 1;
	array[3] = ready_pic.fd_h - 1;
	array[4] = 104 + array[0];
	array[5] = 84 +array[1];
	array[6] = 104 +array[2] - 1;
	array[7] = 84 +array[3] - 1;

	clear_back(array);
}

/* game routines */

/* reset_wave()
 *
 * clears out last wave and restarts wave
 */

void
reset_wave(void)
{
	int i;

	do_getready();
		
	/* clear sprite array */
	for (i=0;i<max_sprites;i++)
		sprite[i].id = UNUSED;

	/* clear missile array */
	for (i=0;i<MAX_NUMMISSILES;i++)
		missile[i].id = UNUSED;

	/* clear bomb array */
	for (i=0;i<MAX_NUMBOMBS;i++)
		bombs[i].id = UNUSED;

	num_shots = 0;
	num_bombs = 0;
	
	init_enemy();
}

/* next_wave()
 * 
 * calculates accuracy bonus
 * and starts the next wave
 */
 
void
next_wave(void)
{
	extern void prinl(register long num,int x,int y,int fill);
	int array[8];
	int i;
	int accuracy;
	long bonus, bonustemp;

    /* determine bonus */

	accuracy =  (death_total * 100)/shots;

	if ( accuracy > 75) 
	{
		if (accuracy == 100)
			sound_play(&perf_snd, 2, PLAY_ENABLE);
		else
			sound_play(&good_snd, 2, PLAY_ENABLE);

		bonustemp = ((score * accuracy)/100);
		
		bonustemp = bonustemp / 10;
		bonustemp = bonustemp * 10;

		bonus = (bonustemp)/10;

		score=score+bonus;
	}
	else if ( accuracy < 25) 
	{
		sound_play(&badd_snd, 2, PLAY_ENABLE);

		bonustemp = ((score * (100 - accuracy))/100);

		bonustemp = bonustemp / 10;
		bonustemp = bonustemp * 10;

		bonus = 0-((bonustemp)/10);

		score=score+bonus;
	}
	else
	{
		sound_play(&done_snd, 2, PLAY_ENABLE);

		bonus = 0;
	}
		
	array[0] = 0;
	array[1] = 0;
	array[2] = back_pic.fd_w - 1;
	array[3] = back_pic.fd_h - 1;
	array[4] = array[0];
	array[5] = array[1];
	array[6] = array[2];
	array[7] = array[3];

	clear_back(array);

	show_score();
	show_wave();
	show_ships();

	array[0] = 0;
	array[1] = 0;
	array[2] = bonusmsg_pic.fd_w - 1;
	array[3] = bonusmsg_pic.fd_h - 1;
	array[4] = 144 + array[0];
	array[5] = 94 +array[1];
	array[6] = 144 +array[2] - 1;
	array[7] = 94 +array[3] - 1;
		
	cpy_2_back(array, &bonusmsg_pic, &bonusmsg_mask);

	prinl(accuracy,array[6]-30,array[5]+6,TRUE);
	prinl(bonus,array[6]-20,array[7]-14,TRUE);

	show_score();
	
	/* display window */
    do_wind_redraw(win[GAME_WIN].handle,(GRECT *)&win[GAME_WIN].current);

	/* wait for the sound to end */
	sound_wait();

	do_getready();
		
	/* clear sprite array */
	for (i=0;i<max_sprites;i++)
		sprite[i].id = UNUSED;

	/* clear missile array */
	for (i=0;i<MAX_NUMMISSILES;i++)
		missile[i].id = UNUSED;

	/* clear bomb array */
	for (i=0;i<MAX_NUMBOMBS;i++)
		bombs[i].id = UNUSED;

	num_shots = 0;
	num_bombs = 0;
	death_total = 0;
	shots = 0;
	
	wave += 1;

	num_drones = 4 + wave;

	if ((wave % 3) == 0)
	{
		cur_bombers = cur_bombers + 1;
		num_drones = num_drones - 3;
	}

	num_bombers = cur_bombers;

	if (num_drones > max_sprites)
		num_drones = max_sprites;
	
	total_enemies = num_drones + num_bombers;
	
	/*	printf("\r\ndrones = %d bombers = %d total = %d\r\n",num_drones,num_bombers,total_enemies);*/
	
	init_enemy();
}

/* Get_key()
 *
 * Checks if the control key is pressed and if it is 
 * attempts to see if the player wants to pause/quit/etc
 * with the number and color depth of the sprites using
 * a full_multi() for normal game play as I often would
 * completely bogs the system down.
 *
 * return ASCII-keycode if available or zero 
 */

int 
Get_key(void)
{
	int status;
 	int key = 0;
	int which;
	int junk;
 
	vq_key_s(vdi_handle,&status);

	if (status == 4)
	{
		#ifdef _GEMLIB_H_
			which=evnt_multi(MU_KEYBD | MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,&junk,	
				timer,
				&junk,&junk,&junk,&junk,&key,&junk);	
		#else
			which=evnt_multi(MU_KEYBD | MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,&junk,
				timer,0,
				&junk,&junk,&junk,&junk,&key,&junk);	
		#endif

		/*printf("key = %d\r\n",key);*/

		if (which & MU_KEYBD)
		{
			switch(key)
			{
			case 0:
				break;
				
			case 12558: 
				/* Control N */
				handle_win(GAME_WIN,m_new_event);
				new_game();
				break;

			case 4113:
				/* Control Q */
				m_quit_event();
				
				/* we have to shut off gameinplay as well from here or
				 * the game will not stop
				 */
				 
				break;

			case 5140: 
				/* Control T */

				SHOW_MOUSE
				wind_update(END_MCTRL);

				m_timing_event();				

				wind_update(BEG_MCTRL);
				HIDE_MOUSE
				
				break;
				
			case 6416:
				/* Control P */
			case '\033':
			case 283: 
				/* Esc */

				SHOW_MOUSE
				wind_update(END_MCTRL);

				paused = 1;
				
				while ((paused)&&(!done))
					full_multi();

				wind_update(BEG_MCTRL);
				HIDE_MOUSE

				break;

			}
		}
	}
/*	printf("status = %d\r\n",status);*/
  
	return(status);
}

/* GEMJing_Get_key(void)
 *
 *  a slower version of the above
 * this tracks evnt messages as well
 * as the others.  However it only
 * tracks a few.
 * This makes it faster than full_multi()
 * but much slower than the normal get_key()
 *
 *return ASCII-keycode if available or zero 
 */
int GEMJing_Get_key(void)
{
	int status = 0;
 	int key = 0;
	int	msg[8];					/* event message buffer */
	int which;
	int junk;
 
	#ifdef _GEMLIB_H_
		which=evnt_multi(MU_KEYBD | MU_TIMER | MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,
			&msg,
			timer,
			&junk,&junk,&junk,&junk,&key,&junk);	
	#else
		which=evnt_multi(MU_KEYBD | MU_TIMER | MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,
			&msg,
			timer,0,
			&junk,&junk,&junk,&junk,&key,&junk);	
	#endif

	/*printf("key = %d\r\n",key);*/

	if (which & MU_MESAG) 
	{
		switch (msg[0])
		{
			/* GEMJing return */
			case 0x7407:
				sample_playing -= 1;
				break;
		}
	}

	if (which & MU_KEYBD)
	{
		switch(key)
		{
			case 0:
				break;
				
			case 12558: 
				/* Control N */
				handle_win(GAME_WIN,m_new_event);
				new_game();
				break;

			case 4113:
				/* Control Q */
				m_quit_event();
				
				/* we have to shut off gameinplay as well from here or
				 * the game will not stop
				 */
				 
				break;

			case 5140: 
				/* Control T */

				SHOW_MOUSE
				wind_update(END_MCTRL);

				m_timing_event();				

				wind_update(BEG_MCTRL);
				HIDE_MOUSE
				
				break;
				
			case 6416:
				/* Control P */
			case '\033':
			case 283: 
				/* Esc */

				SHOW_MOUSE
				wind_update(END_MCTRL);

				paused = 1;
				
				while ((paused)&&(!done))
					full_multi();

				wind_update(BEG_MCTRL);
				HIDE_MOUSE

				break;

		}
	}
/*	printf("status = %d\r\n",status);*/
  
	return(status);
}


/* check_for_pause()
 *
 * allow player to pause game by pressing a key 
 * dispatches get key test based on if we are using
 * GEMJing or not.  If we don't give GEMJing a bit of 
 * time it gets out of sequence
 *
 * also handles the evnt_timer() which slows down the
 * game on really fast machines.  Based on value from
 * timing dialog
 */

void
check_for_pause(void)
{
	int key = 0;

	if (snd_flag == SND_GEMJING)
		key = GEMJing_Get_key();
	else
		key = Get_key();
		
	if (timer > 0)
	{
		#ifdef _GEMLIB_H_
			evnt_timer(timer);
		#else
			evnt_timer(timer,0);
		#endif
	}
}

/* new_game()
 *
 * this starts up the actual game
 * this is really the core of the program
 * the upper level full_multi() is really 
 * just a wrapper for when the game is not in play
 */
 
void
new_game(void)
{
	int array[8];
	int i;

	/* srand(time(NULL)); Initialize the random number generator ( for rand() )*/
	srand((int)clock);
	
	event_kind = MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON;

	do_getready();	

	gameinplay = 1;

	randomize = 5;

	max_sprites = 30;
		
	/* clear sprite array */
	for (i=0;i<max_sprites;i++)
		sprite[i].id = UNUSED;

	/* clear missile array */
	for (i=0;i<MAX_NUMMISSILES;i++)
		missile[i].id = UNUSED;

	/* clear bomb array */
	for (i=0;i<MAX_NUMBOMBS;i++)
		bombs[i].id = UNUSED;

	num_shots = 0;
	num_bombs = 0;
	num_drones = 5;
	num_bombers = 0;
	cur_bombers = 0;

	total_enemies = 5;
	wave = 1;
	ships = 3;
	score = 0;
	bonus_ship = BONUS;
	
	tout = clock() + (STARTTIME * CLK_TCK);

	setup_game();

	y_speed = 4;
	y_minspeed = 0;
	
	speed = 1;
	
	i = (int)(rand() & randomize);

	init_enemy();
	
	wind_update(BEG_MCTRL);
	HIDE_MOUSE

	while(gameinplay)
	{
		redraw_sprites();
		update_rects();

		check_for_pause();
	}

	SHOW_MOUSE
	wind_update(END_MCTRL);
}

/* redraw_player()
 *
 * handles player sprite movement and drawing
 * to our backing store
 * also tests if the player is firing a new shot
 */
void
redraw_player(void)
{
	int button;
    int temp_pos = 0;
    int mouse_x, mouse_y;
	
	temp_pos = win[GAME_WIN].current.g_x + player.cords.xpos;
	
	vq_mouse(vdi_handle,&button,&mouse_x,&mouse_y);

    if ((mouse_x == old_mousex)
    && (mouse_x == player.cords.xpos))
 	{
		update_player();
    	return;
    }
    
    old_mousex = mouse_x;
    old_mousey = mouse_y;
	
    if (temp_pos - mouse_x < 16)
        player.cords.xpos -= (temp_pos - mouse_x);
    else if (mouse_x - temp_pos < 16)
		player.cords.xpos += (mouse_x - temp_pos);
	else if (mouse_x < temp_pos)
    {
    	if (player.cords.xpos > 16)
			player.cords.xpos -= 16;
		else
			player.cords.xpos = 0;
	}
	else if ( mouse_x > temp_pos)
		player.cords.xpos += 16;
		
	if(player.cords.xpos > (win[GAME_WIN].window_obj[ROOT].ob_width - player.surface->fd_w))
		player.cords.xpos = (win[GAME_WIN].window_obj[ROOT].ob_width - player.surface->fd_w);

    if (player.cords.xpos < 0)
    	player.cords.xpos = 0;
    	
    /* Move the player */
	player.dPrev = player.dCurrent;
	player.dCurrent.g_x = (int)(player.cords.xpos); 

	update_player();

	add_missile(button, player.cords.xpos, player.cords.ypos);
}

/* update_score()
 *
 * adds points to the score and
 * has it redrawn to the screen
 */
 
void
update_score(long new_score)
{
	score = score + new_score;

	show_score();
}

/* end_game()
 *
 * detects if the game play is over
 * called whenever the player loses a ship
 */
 
void
end_game(void)
{
	int array[8];
	int score_loop,junk;

	ships -= 1;
	sound_play(&boom_snd, 2, PLAY_ENABLE);

	sound_wait();
	
	show_ships();

	if (ships == 0)
	{
		array[0] = 0;
		array[1] = 0;
		array[2] = gameover_pic.fd_w - 1;
		array[3] = gameover_pic.fd_h - 1;
		array[4] = 104 + array[0];
		array[5] = 84 +array[1];
		array[6] = 104 +array[2] - 1;
		array[7] = 84 +array[3] - 1;

		cpy_2_back(array, &gameover_pic, &gameover_mask);

		/* display window */
   		do_wind_redraw(win[GAME_WIN].handle,(GRECT *)&win[GAME_WIN].current);

		gameinplay = 0;

		/* check highscores */
		for (score_loop = 0; score_loop < 10; score_loop++)
		{
			if (score > scores[score_loop].score)
			{
				for (junk = 9; junk > score_loop; junk--)
				{
					strcpy(scores[junk].name,scores[junk-1].name);
					scores[junk].score = scores[junk-1].score;
				}

				sound_play(&tada_snd, 2, PLAY_ENABLE);
										
				get_high_name(score_loop);
									
				break;
			}		
		}
	}
	else
	{
		/* melt play area */
		disp_fx_field_melt(game_win);
		
		if (ships == 1)
			sound_play(&last_snd, 2, PLAY_ENABLE);
		else
			sound_play(&next_snd, 2, PLAY_ENABLE);

		sound_wait();

		/* restart level */
		reset_wave();
	}
}

/* update_player()
 * 
 * copies player sprite in it's new location
 * to the backing store
 */
 
void
update_player(void)
{
	int array[8];

	array[0] = 0;
	array[1] = 0;
	array[2] = player.surface->fd_w - 1;
	array[3] = player.surface->fd_h - 1;
	array[4] = player.dCurrent.g_x;
	array[5] = player.dCurrent.g_y;
	array[6] = array[4] + player.dCurrent.g_w - 1;
	array[7] = array[5] + player.dCurrent.g_h - 1;
	
	cpy_2_back(array, &player_pic, &player_mask);
}

/* reset_sprite()
 * 
 * removes a sprite from the backing store
 */
 
void
reset_sprite(int idx)
{
	int array[8];
	register GRAPHIC *p;
	int temp_w;

	p = &sprite[idx];

	if (p->dPrev.g_w > p->dPrev.g_h)
		temp_w = p->dPrev.g_h;
	else
		temp_w = p->dPrev.g_w;

	array[0] = 0;
	array[1] = 0;
	array[2] = p->surface->fd_w - 1;
	array[3] = p->surface->fd_h - 1;
	array[4] = p->dPrev.g_x;
	array[5] = p->dPrev.g_y;
	array[6] = array[4] + temp_w - 1;
	array[7] = array[5] + p->dPrev.g_h - 1;

	clear_back(array);

	p->id = UNUSED;	
}

/* reset_missile()
 *
 * called when a missile sprite has completed its
 * trek to the top of the play area
 */
 
void
reset_missile(int idx)
{
	register GRAPHIC *p;

	p = &missile[idx];

	num_shots -= 1;

	p->id = UNUSED;	
}

/* reset_bomb()
 *
 * resets a bomb index when a bomb has completed
 * it's trek to the bottom of the play area
 */
 
void
reset_bomb(int idx)
{
	register GRAPHIC *p;

	p = &bombs[idx];

	num_bombs -= 1;

	p->id = UNUSED;	
}

/* finish_ani()
 *
 * completes the explosion animations at the end of
 * a wave before moving on.
 */
void
finish_ani(void)
{
	register GRAPHIC *p;
	register int i;
	register int last;
	int array[8];
	int temp_x, temp_w;
	int ani_count = 0;

	/* count remaining animations */
	for (i=0; i<max_sprites; i++)
	{
		p = &sprite[i];

		if (p->id != UNUSED)
			ani_count += 1;
	}

	/* Remove Missiles */
	for (i=0; i<MAX_NUMMISSILES; i++)
	{
		p = &missile[i];

		if (p->id != UNUSED)
		{
			/* missiles are an odd case because gem view
			 * has a problem with images that are too small
			 */
			array[4] = p->dCurrent.g_x;
			array[5] = p->dCurrent.g_y;
			array[6] = array[4] + p->dCurrent.g_w;
			array[7] = array[5] + p->dCurrent.g_h;

			clear_back(array);		
		}
	}

	/* Remove bombs */
	for (i=0; i<MAX_NUMBOMBS; i++)
	{
		p = &bombs[i];

		if (p->id != UNUSED)
		{
			array[4] = p->dCurrent.g_x;
			array[5] = p->dCurrent.g_y;
			array[6] = array[4] + p->dCurrent.g_w;
			array[7] = array[5] + p->dCurrent.g_h;

			clear_back(array);		
		}
	}

	while (ani_count > 0)
	{
		/* remove old sprites from window */
		for (i=0; i<max_sprites; i++)
		{
			p = &sprite[i];

			if (p->id != UNUSED)
			{
				if (p->dPrev.g_w > p->dPrev.g_h)
					temp_w = p->dPrev.g_h;
				else
					temp_w = p->dPrev.g_w;

				array[4] = p->dPrev.g_x;
				array[5] = p->dPrev.g_y;
				array[6] = array[4] + temp_w - 1;
				array[7] = array[5] + p->dPrev.g_h - 1;

				clear_back(array);
			}
		}

		/* Update Enemy positions and detect colisions */			
		for (i=0; i<max_sprites; i++)
		{
			p = &sprite[i];

			if (p->id != UNUSED)
			{
				p->dPrev = p->dCurrent;
			
				p->cords.xpos += p->cords.xspeed;
				p->cords.ypos += p->cords.yspeed;

				switch (p->id)
				{
					case EXPLSTART:
						p->id = EXPLANIMA;
						p->frame = 0;
						p->surface = &explani_pic;
						p->mask = &explani_mask;
					
						p->cords.xspeed = 0;
						p->cords.yspeed = 0;
						break;
			
					case EXPLANIMA:
						p->frame = p->frame + 1;
	
						if (p->frame < 9)
							break;

					case EXPLEND:
						reset_sprite(i);
						ani_count -= 1;
						break;
				}

			
				/* could be a dead explosion */
				/* Draw Updated sprite on back and window */
				if (p->id != UNUSED)
				{
					p->dCurrent.g_x = p->cords.xpos;
					p->dCurrent.g_y = p->cords.ypos;
		
					if (p->id == EXPLANIMA)
						temp_x = p->surface->fd_h;
					else
						temp_x = p->surface->fd_w;
						
					array[0] = (p->frame * temp_x);			
					array[1] = 0;
					array[2] = array[0] + temp_x - 1;
					array[3] = p->surface->fd_h - 1;
					array[4] = p->dCurrent.g_x;
					array[5] = p->dCurrent.g_y;
					array[6] = array[4] + temp_x - 1;
					array[7] = array[5] + p->surface->fd_h - 1;
					cpy_2_back(array, p->surface, p->mask);

					/* track last active sprite index + 1*/
					last = i + 1;
				}
			}
		}

		/* don't forget to display them */
		update_rects();

		/* slow it down on fast machines */
		if (timer > 0) {
			#ifdef _GEMLIB_H_
				evnt_timer(timer);
			#else
				evnt_timer(timer,0);
			#endif
		}
	}
}

/* redraw_sprites()
 *
 * the real heart of the game engine
 * this handles ...
 * clearing the backing store
 * moving all the sprites
 * running collsion detections
 * tracking end of wave and end of game
 * updating scores and statistics
 *
 * It's all happening here ;)
 */
 
void
redraw_sprites(void)
{
	register GRAPHIC *p;
	register GRAPHIC *p2;
	register int last;
	register int i;
	int array[8];
	int j;
	int temp_x, temp_y, temp_val;
	int temp_w;

	array[0] = 0;
	array[1] = 0;
	array[2] = player.surface->fd_w - 1;
	array[3] = player.surface->fd_h - 1;
	array[4] = player.dPrev.g_x;
	array[5] = player.dPrev.g_y;
	array[6] = array[4] + player.dPrev.g_w - 1;
	/* Ok There is an oddity here
	 * This should be -1, but if we do that then
	 * we have screen garbage appear below our player
	 * This should be tracked down and fixed
	 */
	array[7] = array[5] + player.dPrev.g_h; /* - 1;*/

	clear_back(array);

	/* remove old sprites from window */
	for (i=0; i<max_sprites; i++)
	{
		p = &sprite[i];

		if (p->id != UNUSED)
		{
			if (p->dPrev.g_w > p->dPrev.g_h)
				temp_w = p->dPrev.g_h;
			else
				temp_w = p->dPrev.g_w;

			array[4] = p->dPrev.g_x;
			array[5] = p->dPrev.g_y;
			array[6] = array[4] + temp_w - 1;
			array[7] = array[5] + p->dPrev.g_h - 1;

			clear_back(array);
		}
	}

	/* Remove Missiles */
	for (i=0; i<MAX_NUMMISSILES; i++)
	{
		p = &missile[i];

		if (p->id != UNUSED)
		{
			/* missiles are an odd case because gem view
			 * has a problem with images that are too small
			 */
			array[4] = p->dCurrent.g_x;
			array[5] = p->dCurrent.g_y;
			array[6] = array[4] + p->dCurrent.g_w;
			array[7] = array[5] + p->dCurrent.g_h;

			clear_back(array);		
		}
	}

	/* Remove bombs */
	for (i=0; i<MAX_NUMBOMBS; i++)
	{
		p = &bombs[i];

		if (p->id != UNUSED)
		{
			array[4] = p->dCurrent.g_x;
			array[5] = p->dCurrent.g_y;
			array[6] = array[4] + p->dCurrent.g_w;
			array[7] = array[5] + p->dCurrent.g_h;

			clear_back(array);		
		}
	}
	
	/* Update Enemy positions and detect colisions */			
	for (i=0; i<max_sprites; i++)
	{
		p = &sprite[i];

		if (p->id != UNUSED)
		{
			p->dPrev = p->dCurrent;
			
			p->cords.xpos += p->cords.xspeed;
			p->cords.ypos += p->cords.yspeed;

			if (p->id == DRONE)
			{
				/* handle drone movement boundaries */
	
				if (p->cords.xpos < 0 ||
					 p->cords.xpos > drone_max[0])
				{
					p->cords.xspeed = -p->cords.xspeed;
					p->cords.xpos += p->cords.xspeed;
				}
				
				if (p->cords.ypos < 0 || 
					p->cords.ypos > drone_max[1])
				{
					p->cords.yspeed = -p->cords.yspeed;
					p->cords.ypos += p->cords.yspeed;
				}

				/* Drones try to ram check colission in here */
				if (p->cords.ypos > 280)
				{
					if ( Collide(p, &player) == TRUE) 
						end_game();
				}

			}
			else if (p->id == BOMBER)
			{
				/* handle bomber movement boundaries */

				/* note bombers are animated so use height instead
				 * of width.  This works because this program expects
				 * the sprites to have the same height and width
				 */
				if (p->cords.xpos < 0 ||
					 p->cords.xpos > (win_width - p->surface->fd_h - 1))
				{
					p->cords.xspeed = -p->cords.xspeed;
					p->cords.xpos += p->cords.xspeed;
				}
				
				if (p->cords.ypos < 0 || 
					p->cords.ypos > 250)
				{
					p->cords.yspeed = -p->cords.yspeed;
					p->cords.ypos += p->cords.yspeed;
				}
				
				/* get our angle */
				temp_x = abs(p->cords.xspeed);
				temp_y = abs(p->cords.yspeed);		
		
				if (temp_y > (2 * temp_x))
					temp_val = 1;
				else if (temp_x > (2 * temp_y))
					temp_val = 3;
				else
					temp_val = 2;
					
				if (p->cords.yspeed < 0)
				{
					if (p->cords.xspeed < 0)
					{
						switch (temp_val)
						{
							case 1:
							p->frame = 4;
								break;
							case 2:
							p->frame = 5;
								break;
							case 3:
							p->frame = 6;
								break;
						}
					}
					else
					{
						switch (temp_val)
						{
							case 1:
							p->frame = 4;
								break;
							case 2:
							p->frame = 3;
								break;
							case 3:
							p->frame = 2;
								break;
						}
					}

				}
				else
				{
					if (p->cords.xspeed < 0)
					{
						switch (temp_val)
						{
							case 1:
							p->frame = 0;
								break;
							case 2:
							p->frame = 7;
								break;
							case 3:
							p->frame = 6;
								break;
						}
					}
					else
					{
						switch (temp_val)
						{
							case 1:
							p->frame = 0;
								break;
							case 2:
							p->frame = 1;
								break;
							case 3:
							p->frame = 2;
								break;
						}
					}
				}					

				/* see if it is going to drop a bomb */
				if ((rand()%27 == 0) && (num_bombs < MAX_NUMBOMBS))
					add_bomb(p->cords.xpos,p->cords.ypos); /*(p->cords.ypos + p->surface->fd_h));*/
			}		
						

			switch (p->id)
			{
				case EXPLSTART:
					p->id = EXPLANIMA;
					p->frame = 0;
					p->surface = &explani_pic;
					p->mask = &explani_mask;
					
					p->cords.xspeed = 0;
					p->cords.yspeed = 0;
					break;
			
				case EXPLANIMA:
					p->frame = p->frame + 1;

					if (p->frame < 9)
						break;

				case EXPLEND:
					reset_sprite(i);
					break;
			}

			
			/* could be a dead explosion */
			/* Draw Updated sprite on back and window */
			if (p->id != UNUSED)
			{
				p->dCurrent.g_x = p->cords.xpos;
				p->dCurrent.g_y = p->cords.ypos;
	
				if (p->id == EXPLANIMA)
					temp_x = p->surface->fd_h;
				else if (p->id == BOMBER)
					temp_x = p->surface->fd_h;
				else
					temp_x = p->surface->fd_w;
					
				array[0] = (p->frame * temp_x);			
				array[1] = 0;
				array[2] = array[0] + temp_x - 1;
				array[3] = p->surface->fd_h - 1;
				array[4] = p->dCurrent.g_x;
				array[5] = p->dCurrent.g_y;
				array[6] = array[4] + temp_x - 1;
				array[7] = array[5] + p->surface->fd_h - 1;
				cpy_2_back(array, p->surface, p->mask);

				/* track last active sprite index + 1*/
				last = i + 1;
			}
		}
	}

	/* Update Missiles */
	for (i=0; i<MAX_NUMMISSILES; i++)
	{
		p = &missile[i];

		if (p->id != UNUSED)
		{
			p->dPrev = p->dCurrent;
		
			p->cords.xpos += p->cords.xspeed;
			p->cords.ypos += p->cords.yspeed;

			for (j = 0; j < last; j++)
			{
				p2 = &sprite[j];
				
				if (p2->id < EXPLSTART)
				{
					/*if ( Collide(p, p2) == TRUE) better but slows down the game */
					if (Collidehotpoint(p2, p->cords.xpos + 16, p->cords.ypos + 16) == TRUE)
					{							
						switch(p2->id)
						{
							case DRONE:
								p2->id = EXPLSTART;
								p2->frame = 0;
								p2->surface = &explani_pic;
								p2->mask = &explani_mask;

								p2->cords.xspeed = 0;
								p2->cords.yspeed = 0;

								update_score(p2->cords.ypos<<1);
								num_drones -= 1;
								total_enemies = total_enemies - 1;
								death_total += 1;

								sound_play(&expl_snd, 2, PLAY_ENABLE);

								reset_missile(i);
								goto after_missile_loop;
								break;

							case BOMBER:
								p2->id = EXPLSTART;
								p2->frame = 0;
								p2->surface = &explani_pic;
								p2->mask = &explani_mask;

								update_score(2*(p2->cords.ypos<<1));
	
								p2->cords.xspeed = 0;
								p2->cords.yspeed = 0;
	
								num_bombers -= 1;
								total_enemies = total_enemies - 1;
								death_total += 1;

								sound_play(&expl_snd, 2, PLAY_ENABLE);

								reset_missile(i);
								goto after_missile_loop;
								break;
		
						}

					}
				}		
			}
			
			/* now check if it's still in window */
			if (p->cords.ypos  < 0)
				reset_missile(i);
			else
			{
				p->dCurrent.g_x = p->cords.xpos;
				p->dCurrent.g_y = p->cords.ypos;
	
				array[0] = 0;			
				array[1] = 0;
				array[2] = p->surface->fd_w - 1;
				array[3] = p->surface->fd_h - 1;
				array[4] = p->dCurrent.g_x;
				array[5] = p->dCurrent.g_y;
				array[6] = array[4] + p->surface->fd_w - 1;
				array[7] = array[5] + p->surface->fd_h - 1;

				cpy_2_back(array, p->surface, p->mask);
			}

			after_missile_loop:

			;
		}
	}

	/* Update bombs */
	for (i=0; i<MAX_NUMBOMBS; i++)
	{
		p = &bombs[i];

		if (p->id != UNUSED)
		{
			p->dPrev = p->dCurrent;
		
			p->cords.xpos += p->cords.xspeed;
			p->cords.ypos += p->cords.yspeed;

			/* check bomb colission in here */
			if (p->cords.ypos > 280)
			{
				if (Collidehotpoint(&player, p->cords.xpos + 8, p->cords.ypos + 8) == TRUE)
				{							
					reset_bomb(i);
					end_game();
				}
			}
			
			/* now check if it's still in window */
			if (p->cords.ypos > (back_pic.fd_h - p->surface->fd_h))
				reset_bomb(i);
			else
			{
				p->dCurrent.g_x = p->cords.xpos;
				p->dCurrent.g_y = p->cords.ypos;
	
				array[0] = 0;			
				array[1] = 0;
				array[2] = p->surface->fd_w - 1;
				array[3] = p->surface->fd_h - 1;
				array[4] = p->dCurrent.g_x;
				array[5] = p->dCurrent.g_y;
				array[6] = array[4] + p->surface->fd_w - 1;
				array[7] = array[5] + p->surface->fd_h - 1;

				cpy_2_back(array, p->surface, p->mask);
			}

			after_bomb_loop:

			;
		}
	}

	/* Check for wave end */
	if (total_enemies == 0)
	{
		finish_ani();
		next_wave();	
	}

    /* update stats */
	show_wave();
	show_score();
	show_ships();

	/* show_debug(total_enemies);
	*/

	/* restore player graphic */
	redraw_player();
}

/* setup_game()
 *
 * a misnomer really just inits the player graphic
 * and gets the drone max values
 */
 
void
setup_game(void)
{
	int array[8];

    colors[0] = 0;
    colors[1] = 1; 
	
	player.surface = (MFDB *)&player_pic;
	player.mask = (MFDB *)&player_mask;			/* PHD: Needed for collision detection! */
	player.cords.bit = 0;
	player.cords.xspeed = 0;
	player.cords.yspeed = 0;
	player.cords.xpos = 180;
	player.cords.ypos = 300;

	player.dCurrent.g_x = player.cords.xpos;
	player.dCurrent.g_y = player.cords.ypos;
	player.dCurrent.g_w = player.surface->fd_w;
	player.dCurrent.g_h = player.surface->fd_h;

	player.dPrev = player.dCurrent;

	array[0] = 0;
	array[1] = 0;
	array[2] = player.surface->fd_w - 1;
	array[3] = player.surface->fd_h - 1;
	array[4] = player.dCurrent.g_x;
	array[5] = player.dCurrent.g_y;
	array[6] = array[4] + player.dCurrent.g_w - 1;
	array[7] = array[5] + player.dCurrent.g_h - 1;

	cpy_2_back(array, &player_pic, &player_mask);
	
	/* store our drone max x and y's for later faster use */

	drone_max[0] = (back_pic.fd_w - 1) - drone_pic.fd_w;
	drone_max[1] = (back_pic.fd_h - 1) - drone_pic.fd_h;
}

/* m_timing_event()
 *
 * modal dialog.  Just grabs a time delay value
 * from the user.  This is the value that is used
 * in the check_for_pause() routine.
 */
 
void
m_timing_event(void)
{
	int xchoice;
	GRECT dial;
	char tempstr[4];

	sprintf(tempstr,"%d",timer);

	set_tedinfo(timing_dial, R_SPEED, tempstr);

	form_center(timing_dial,ELTR(dial));
	form_dial(FMD_START,0,0,10,10,ELTS(dial));
	objc_draw(timing_dial,0,3,ELTS(dial));

	xchoice = (form_do(timing_dial, 0) & 0x7fff);

	form_dial(FMD_FINISH,0,0,10,10,ELTS(dial));

	timing_dial[xchoice].ob_state &= ~SELECTED;

	if (xchoice == TIME_SET)
	{
		get_tedinfo(timing_dial,R_SPEED,tempstr);
		timer = atoi(tempstr);
	}
}

/* full_multi()
 * 
 * this is our fully loaded event_multi() routine
 * it handles all user interaction when game is not
 * in play.  Most simple games this would be the only
 * routine we would need.  But there isn't enough
 * processor time to effectively play this game.
 */
 
void
full_multi(void)
{
	
	int event, scan;
	int ret;
	int	msg[8];					/* event message buffer */
	int junk, w_info, top_window;
	int button = 0, clicks = 0;
	int mousex, mousey;	
	int which_obj;

	#ifdef _GEMLIB_H_	
		event = evnt_multi(event_kind,
			1,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,
			200L,
			&mousex,&mousey,&button,&ret,&scan,&clicks);
	#else
		event = evnt_multi(event_kind,
			1,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,
			200,0,
			&mousex,&mousey,&button,&ret,&scan,&clicks);
	#endif

	if (event & MU_MESAG) switch (msg[0])
	{
		/* GEMJing return */
		case 0x7407:
			sample_playing -= 1; 
			break;

		case MN_SELECTED:

		/* menu functions, program only */
		switch(msg[4])
		{
			case ABOUT_GAME:
			    handle_win(ABOUT_WIN, do_title);
				break;

			case M_NEW:
				handle_win(GAME_WIN,m_new_event);
				new_game();
				break;

			case M_PAUSE:
				if (paused)
					paused = 0;
				else
					paused = 1; /* should never be this here */

				break;
				
			case M_QUIT:
				m_quit_event();
				break;

			case M_TIMING:
				m_timing_event();
				break;

			case M_SOUND:
				handle_win(SOUND_WIN, do_sndconfig);
				break;
				
			case M_VIEWHIGHSCORE:
				high_score();
				break;
				
			case M_SAVEPREF:
				write_cfg_file(config_file);
				break;

			case M_HELP:
				do_help("Main");
				break;				
		}
		menu_tnormal(menu_ptr, msg[3], TRUE ); /* deselect menubar */
		break;

		case WM_REDRAW:
			w_info = get_wininfo_from_handle(msg[3]);
		
			if (w_info != -1)
			{
				do_wind_redraw(win[w_info].handle,(GRECT *)&msg[4]);
			}    	
		break;

		case WM_NEWTOP:
		case WM_TOPPED:
			#ifdef _GEMLIB_H_
				wind_set(msg[3], WF_TOP, msg[3],0,0,0);
			#else
				wind_set(msg[3], WF_TOP, msg[3]);
			#endif

	    	break;

		#if 0
		/* if you are wondering why these are REM'd out
		 * under MagicPC and Jinnee, I don't get the windows
		 * redrawn when they are unshaded if I intercept the
		 * messages
		 */
			case WM_SHADED:
				w_info = get_wininfo_from_handle(msg[3]);

				if (w_info != -1)
					win[w_info].status = 2;

				break;

			case WM_UNSHADED:
				w_info = get_wininfo_from_handle(msg[3]);

				if (w_info != -1)
					win[w_info].status = 0;
				break;
		#endif

		case WM_CLOSED:
			wind_close(msg[3]);
			wind_delete(msg[3]);

			w_info = get_wininfo_from_handle(msg[3]);

			if(w_info == GAME_WIN)
				event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;
			
			win[w_info].handle = NO_WINDOW;
			break;

		case WM_MOVED:
			wind_set(msg[3], WF_CURRXYWH, PTRS((GRECT *)&msg[4]));

			w_info = get_wininfo_from_handle(msg[3]);

			switch(win[w_info].status)
			{
				case 1:
					/* Normal */
							
					if (win[w_info].type == 0)
						wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
						  ELTR(win[w_info].current));
					else
						wind_calc(WC_WORK, W_T2, PTRS((GRECT *)&msg[4]),
						  ELTR(win[w_info].current));

					win[w_info].window_obj[ROOT].ob_x = win[w_info].current.g_x;
					win[w_info].window_obj[ROOT].ob_y = win[w_info].current.g_y;
					win[w_info].window_obj[ROOT].ob_width = win[w_info].current.g_w;
					win[w_info].window_obj[ROOT].ob_height = win[w_info].current.g_h;
					break;
							
				case 2:
					/* Rolled up */						

					wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
					  &win[w_info].current.g_x,
					  &win[w_info].current.g_y,
					  &junk,
					  &junk);

				case 3:
					/* Iconified */

					wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
					  ELTR(win[w_info].icon));

					win[w_info].icon_obj[ROOT].ob_x = win[w_info].icon.g_x;
					win[w_info].icon_obj[ROOT].ob_y = win[w_info].icon.g_y;
					win[w_info].icon_obj[ROOT].ob_width = win[w_info].icon.g_w;
					win[w_info].icon_obj[ROOT].ob_height = win[w_info].icon.g_h;
					break;
			}

			if(msg[3] == win[GAME_WIN].handle) 
			{
			  old.g_x = msg[4];
			  old.g_y = msg[5];
			}

		    break;

		case WM_ICONIFY:
			w_info = get_wininfo_from_handle(msg[3]);
			
			if (w_info != -1)			
				iconify(w_info,((GRECT *)&msg[4]));

			if (w_info == GAME_WIN)
				event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;

			break;

		case WM_UNICONIFY:
			w_info = get_wininfo_from_handle(msg[3]);

			if (w_info != -1)
			{
				un_iconify(w_info,((GRECT *)&msg[4]));

				#ifdef _GEMLIB_H_
					wind_set(msg[3], WF_TOP, msg[3],0,0,0);
				#else
					wind_set(msg[3], WF_TOP, msg[3]);
				#endif
							
				if(w_info == GAME_WIN)
					event_kind = MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON;
			}
				
			break;
			
		case AC_CLOSE:
			if((msg[3] == menu_id) && (game_win != NO_WINDOW))
			{
				wind_update(TRUE);

				v_clsvwk(vdi_handle);

				game_win = NO_WINDOW;
				sound_play(&exit_snd, 2, PLAY_ENABLE);

				event_kind = MU_MESAG | MU_KEYBD;
				wind_update(FALSE);
			}
			break;
						
		case AC_OPEN:
		    if (msg[4] == menu_id)
			{
				if (game_win == NO_WINDOW)
				{
					InitVideo();

					if (open_window() < 0)
					{
						v_clsvwk(vdi_handle);
						break;
					}
				}
			}
			break;


		case AP_TERM:
			if (_app)
				m_quit_event();
			break;
			
			
	} /* switch (msg[0]) */

	/* Grab those fabulous hot keys */
	if (event & MU_KEYBD)
	{
		/*printf("key = %d\r\n",scan);*/

		switch(scan)
		{
			case 0x4800:
				/* up arrow */
				break;

			case 0x5000:
				/* down arrow */
				break;

			case 0x4B00:
				/* left arrow */
				/*player.cords.xpos = player.cords.xpos - 16;*/
				break;

			case 0x4D00:
				/* right arrow */
				/*player.cords.xpos = player.cords.xpos + 16;*/
				break;

			case 12558:
				/* Control N */
				handle_win(GAME_WIN,m_new_event);
				new_game();
				break;

			case 4113:
				/* Control Q */
				m_quit_event();
				break;

			case 5140:
				/* Control T */
				m_timing_event();				
				break;

			case 25088: /* Help Key */
				do_help("Main");
				break;				

			case 6416:
				/* Control P */
			case 283:
				/* Esc */
				if (paused)
					paused = 0;
				else
					paused = 1; /* should never be this here */
					
				break;

		}

	}
		
	/* Get Mouse Button Events */
	if (event & MU_BUTTON)
	{
		junk = wind_find(mousex,mousey);

		top_window = get_topwindow(junk);
		
		if (top_window == junk) /* don't do anything unless top window */
		{	
			w_info = get_wininfo_from_handle(junk);
						
			if (win[w_info].status == 1) /* don't do anything if iconified */
			{
				which_obj = objc_find(win[w_info].window_obj,0,MAX_DEPTH,mousex,mousey);
		
				if (w_info == SOUND_WIN)
					sndconfig_drive(which_obj);
			}
		}
	}
}

/* event_loop()
 *
 * runs full_multi() until done is TRUE
 */
 
void
event_loop(void)
{
	ttimer = 1; /*1;*/
	done = FALSE;

	if (config_loaded == -1)
		handle_win(SOUND_WIN, do_sndconfig);

	while ( (!_app) || !done)
	{
		full_multi();
	} /* end of while (!_app || !done) */
}

/*
 * load_sounds()
 *
 * Loads all the AVR's for use in the game
 * init the pointers to the alt chip sounds
 */
 
void
load_sounds(void)
{
	/* setup chip sounds first
	 * in case the player has deleted
	 * their sound files, this way game
	 * can at least have some sound
	 */

	shot_snd.alt_chip = S_TOP;
	expl_snd.alt_chip = S_SIDE;
	bomb_snd.alt_chip = S_PERMBRICKSOUND;
	boom_snd.alt_chip = S_DEATH;
	last_snd.alt_chip = S_LOSTBALL;
	next_snd.alt_chip = S_APPEAR;
	perf_snd.alt_chip = S_MAGICBELL;
	good_snd.alt_chip = S_BONUS;
	badd_snd.alt_chip = S_BRICKSOUND;
	done_snd.alt_chip = S_LOSTBALL;
	tada_snd.alt_chip = S_MAGICBELL;
	warn_snd.alt_chip = S_APPEAR;
	exit_snd.alt_chip = S_LOSTBALL;

	/* really should have more checking going
	 * on.  This is basically a test to see
	 * if the sound files exist.  If they
	 * can not be loaded the sound system is
	 * set to not use them.
	 */
	if((shot_snd.snd_data = load_avr("shot.avr"))==NULL)
	{
		sound_sys = ST_SOUND;
		return;
	}

	expl_snd.snd_data = load_avr("expl.avr");
	bomb_snd.snd_data = load_avr("bomb.avr");
	boom_snd.snd_data = load_avr("boom.avr");
	last_snd.snd_data = load_avr("last.avr");
	next_snd.snd_data = load_avr("next.avr");
	perf_snd.snd_data = load_avr("perf.avr");
	good_snd.snd_data = load_avr("good.avr");
	badd_snd.snd_data = load_avr("badd.avr");
	done_snd.snd_data = load_avr("done.avr");
	tada_snd.snd_data = load_avr("tada.avr");
	warn_snd.snd_data = load_avr("warning.avr");
	exit_snd.snd_data = load_avr("over.avr");
}

/*
 * unload_sounds()
 *
 * free's all the AVR's for use in the game
 */
 
void
unload_sounds(void)
{
	free_avr(shot_snd.snd_data);
	free_avr(expl_snd.snd_data);
	free_avr(bomb_snd.snd_data);
	free_avr(boom_snd.snd_data);
	free_avr(last_snd.snd_data);
	free_avr(next_snd.snd_data);
	free_avr(perf_snd.snd_data);
	free_avr(good_snd.snd_data);
	free_avr(badd_snd.snd_data);
	free_avr(done_snd.snd_data);
	free_avr(tada_snd.snd_data);
	free_avr(warn_snd.snd_data);

	/* closes out sound system */
	sound_exit();
}

/*
 * init_graphics()
 *
 * handles initialization of all the MFDBs
 * that are used in the game
 */
 
 void
 init_graphics(char *filepath)
 {
	int array[8];
	char titlename[FILENAME_MAX];
	char backname[FILENAME_MAX];
	char playername[FILENAME_MAX];
	char loadname[FILENAME_MAX];
	GRECT temp_clip; /* Used during loading */

	strcpy(titlename,filepath);
	strcpy(backname,filepath);
	strcpy(playername,filepath);
	strcpy(loadname,filepath);

	/* some preconverted backgrounds and abouts for people
	 * running in 16 colors or less
	 */
	if (planes < 8)
	{
		strcat(backname,"backmono.img");
		strcat(titlename,"aboutmon.img");
	}
	else
	{
		strcat(backname,"back.img");
		strcat(titlename,"about.img");
	}

	strcat(playername,"player.img");

	if (_app)
	{
		do_loading();
		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&win[LOADING_WIN].current);
	}

	img_load(&title_pic,titlename,0,(MFDB *)NULL,0);

	if (_app)
	{
		/* Init the graphic we just loaded for dialog*/
		win[LOADING_WIN].image = title_pic;
		
		set_tedinfo(loading_dial, RIMG_COUNT, "(2/11)");
		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&win[LOADING_WIN].current);
	}
	
	img_load(&player_pic,playername,0,&player_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"drone.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(3/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}

	img_load(&drone_pic,loadname,0,&drone_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"bomb.img");
	
	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(4/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}
	img_load(&bomb_pic,loadname,0,&bomb_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"bombers.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(5/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}
	img_load(&bomber_pic,loadname,0,&bomber_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"ready.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(6/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}
	img_load(&ready_pic,loadname,0,&ready_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"gameover.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(7/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}

	img_load(&gameover_pic,loadname,0,&gameover_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"bonusmsg.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(8/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);

	}
	img_load(&bonusmsg_pic,loadname,0,&bonusmsg_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"explani.img");

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(9/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}
	img_load(&explani_pic,loadname,0,&explani_mask,0);

	strcpy(loadname,filepath);
	strcat(loadname,"missile.img"); /* was missile */ 
	
	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(10/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}

	img_load(&missile_pic,loadname,0,&missile_mask,1);

	/* Fix back_pic MFDB to be the size of our game area */
  	back_pic.fd_w = 448;                /* width        */
  	back_pic.fd_wdwidth = (back_pic.fd_w + 15) >> 4;    /* (words)      */
	back_pic.fd_h = 339;

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(11/11)");

		objc_offset(loading_dial,RIMG_COUNT,&temp_clip.g_x,&temp_clip.g_y);
		temp_clip.g_w = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_width;
		temp_clip.g_h = win[LOADING_WIN].window_obj[RIMG_COUNT].ob_height;		

		do_wind_redraw(win[LOADING_WIN].handle,(GRECT *)&temp_clip);
	}
	
	img_load(&back_pic,backname,1,(MFDB *)NULL,0);
 
 	/* Set up backing store */
	picsource.fd_w = back_pic.fd_w;
	picsource.fd_wdwidth = back_pic.fd_wdwidth;
	picsource.fd_h = back_pic.fd_h;
	picsource.fd_nplanes = back_pic.fd_nplanes;
	picsource.fd_stand = 0;

	if(( picsource.fd_addr = (short *) Malloc(2L*(long)back_pic.fd_wdwidth*(long)back_pic.fd_nplanes*(long)back_pic.fd_h))== NULL)
		printf("No memory for window buffer\r\n");

	/* copy our clear window buffer to our backing store */
	array[0] = array[4] = 0;
	array[1] = array[5] = 0;
	array[2] = array[6] = back_pic.fd_w - 1;
	array[3] = array[7] = back_pic.fd_h - 1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&back_pic,&picsource);
 
 	/* convert our numbers to current display*/
	convert_numbers();
	
	/* setup our colision detection areas */
	colision.fd_w = colision1.fd_w = 64; /*((player_pic.fd_w + drone_pic.fd_w)+7) & -8;*/ /* was 32 width in pixels */
	colision.fd_h = colision1.fd_h = 64; /*((player_pic.fd_h + drone_pic.fd_h)+7) & -8;*/ /* was 24 height in rows */
	colision.fd_wdwidth = colision1.fd_wdwidth = (colision.fd_w  + 15) >> 4; /*((player_pic.fd_w + drone_pic.fd_w) + 15) >> 4;*/  /* width in words */
	colision.fd_stand = colision1.fd_stand = 0; /* a standard FDB */
	colision.fd_nplanes = colision1.fd_nplanes = 1; /* monochrome */
	colision_size = (2L*(long)colision.fd_wdwidth*(long)colision.fd_h*(long)colision.fd_nplanes);

	colision.fd_addr = malloc(colision_size);
	colision1.fd_addr = malloc(colision_size);

	memset(colision.fd_addr,0,colision_size);			/* PHD: memset(ptr,val,len) !!!! */
	memset(colision1.fd_addr,0,colision_size);		/* PHD: memset(ptr,val,len) !!!! */
 }

/*
 * free_graphics()
 *
 * free's all the MFDB's for use in the game
 */
 
 void
 free_graphics(void)
 {
 	Mfree(title_pic.fd_addr);
	Mfree(back_pic.fd_addr);
	Mfree(player_pic.fd_addr);
	Mfree(player_mask.fd_addr);

	Mfree(bomber_pic.fd_addr);
	Mfree(bomber_mask.fd_addr);
	Mfree(drone_pic.fd_addr);
	Mfree(drone_mask.fd_addr);
	Mfree(bomb_pic.fd_addr);
	Mfree(bomb_mask.fd_addr);
	Mfree(explani_pic.fd_addr);
	Mfree(explani_mask.fd_addr);
	Mfree(missile_pic.fd_addr);
	Mfree(missile_mask.fd_addr);

	Mfree(ready_pic.fd_addr);
	Mfree(ready_mask.fd_addr);
	Mfree(gameover_pic.fd_addr);
	Mfree(gameover_mask.fd_addr);
	Mfree(bonusmsg_pic.fd_addr);
	Mfree(bonusmsg_mask.fd_addr);

	Mfree(digitsource.fd_addr);

	Mfree(picsource.fd_addr);

	free(colision.fd_addr);
	free(colision1.fd_addr);
 }

/* main()
 * 
 * Handles calling all of the setup routines
 * starting the event_loop() routine
 * and releases all of the memory when game
 * exits
 */
 
void
main (void)
{
	int i;
	char tempname[FILENAME_MAX];

	app_id = appl_init();

	AES_type = identify_AES();

	if (_app != 0)
	{
		if( AES_type != AES_single ) 
		{
			shel_write(9,1,1,"","");
				
			if ( (AES_type == AES_MTOS)||(AES_type == AES_nAES))
	    		menu_register(app_id,"  GEMPANIC  ");
		}
	}
	else
	    menu_id=menu_register(app_id,"  GEMPANIC  ");

	/* start up the AV system */
	start_avsystem();

	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	wind_get(0, WF_WORKXYWH, ELTR(desk));
	
	old.g_x = desk.g_x + (desk.g_w - WIDTH) / 2;
	old.g_y = desk.g_y + (desk.g_h - win_ht) / 3;
	old.g_w = WIDTH;
	old.g_h = win_ht;

	maxx = desk.g_x + desk.g_w;
	maxy = desk.g_y + desk.g_h;

	/* Load ST RSC */
	if (!rsrc_load("gempanic.rsc"))
	{
		form_alert(1, "[1][Error Loading Resource!][Quit]");
		exit(EXIT_FAILURE);
	}
		
	rsrc_init();

	/* put our version number into About window */
	set_tedinfo(about_dial, ABOUT_VERSION, app_version);

	if (_app)
	{
		/* Startup VDI etc */
		InitVideo();

		graf_mouse( ARROW, 0L);
		menu_bar(menu_ptr, 1);	/* display the menu */
	}

	/*	Init win array handles */
	for(i=0;i<MAX_WINDOWS;i++)
		win[i].handle = NO_WINDOW;

	/*	Set up the paths for data files */

	path[0] = Dgetdrv() + 'A';
	path[1] = ':';
	Dgetpath(path+2,Dgetdrv() + 1);

	strcpy(tempname,path);
	strcat(tempname,"\\data\\img\\");

	strcpy(config_file,path);
	strcat(config_file,"\\data\\gempanic.cfg");

	strcpy(score_file,path);
	strcat(score_file,"\\data\\gempanic.hgh");

	strcpy(snd_path,path);
	strcat(snd_path,"\\data\\snd\\");

	/* load the configuration file if present */
	config_loaded = read_cfg_file(config_file);

	/* Initialize sound system */
	sound_init();

	/* Load all the graphics and init the MFDBs */
	init_graphics(tempname);

	/* Load the high score list */
	read_highscore();

	/* So we don't lose the screen colors for display */
	reset_colors(screen_colortab); 

	/* Close the loading window if it's open */
	if (_app)
	{
		wind_close(win[LOADING_WIN].handle);
		wind_delete(win[LOADING_WIN].handle);

		win[LOADING_WIN].handle = NO_WINDOW;
	}

	/* init all the sounds for the game */
	load_sounds();

	sound_play(&warn_snd, 2, PLAY_ENABLE);

	setup_game();

	event_loop();

	sound_play(&exit_snd, 2, PLAY_ENABLE);
	
	/* release all the sound buffers */
	unload_sounds();

	/* release all the graphic buffers */
	free_graphics();

	/* close out AV system */
	exit_avsystem();

	/* erase the menu bar */
	menu_bar(menu_ptr, 0);	

	/* close the vdi handle */
	v_clsvwk(vdi_handle);	
	
	appl_exit();
}
