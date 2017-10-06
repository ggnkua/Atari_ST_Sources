/********************************************
*		Boinkout program and acc			*
*											*
*		Based Upon code by					*
*		Samuel Streeper 90/02/26			*
*											*
*	Original Version						*
*	Copyright 1990 by Antic Publishing Inc.	*
*											*
* "what to do with all that wasted			*
*	CPU time Part III"						*
********************************************/

/* edited with tabsize = 4 */

/*  Updating Notes:
	Well Antic went belly up shortly after running this article and
	code.  There were numerous stories at the time of them not actually
	paying authors for code/articles that they had written.
	I DO NOT KNOW IF THIS WAS THE CASE WITH BOINKOUT!
	However, Mr. Streeper ported it to the next station,
	that he worked on shortly after this.  In fact it became
	a hit there (being one of the few initial games for that 
	platform).  Since then it has seen a few incarnations most
	recently in JAVA.   I thought it was kind of irritating that
	this great game, no longer ran on many modern atari systems
	due to some programming conflicts that have arisen since its
	initial release.  While I was in here I made a few more changes,
	such as the XIMG backdrop support.  There are probably more
	errors running around in here.  Don't try to use the linea support
	unless you put it all back in.  I ripped most of it out.  I know
	that there are some people that can still use linea.  However In
	almost all cases I beleive they can use the initial game as well.
	
		- Dan Ackerman    August 1999
		baldrick@netset.com
		

	I spoke with Mr. Streeper via email one day.  He was very happy to
	see BoinkOut2.  Whew!  One worry gone :)
*/

/*	Compiler notes:		*/
/*	---------------		*/
/*	This code compiles with Laser C and Mark Williams C					*/
/*	version 2.0. It shouldn't be tough to get it to compile with other	*/
/*	things... 															*/
/*	There are just a few things to look out for when porting this		*/
/*	between compilers:													*/

/*	The blitter routines require a structure known as a memory form		*/
/*	descriptor block. Laser C and Alcyon C call this structure a		*/
/*	MFDB, while MWC calls this a FDB.									*/

/*	This code will work as both a desk accessory or a program if you	*/
/*	link it with the proper startup module. The default Laser startup	*/
/*	module works ok. I recommend linking to the laser or				*/
/*	MWC startup code supplied with Start magazine October 89. This code	*/
/*	gives the smallest executable file, and will work as a program or	*/
/*	DA just by changing the file's extention from .prg to .acc			*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "boink.h"

#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif


/** _app should be FALSE if boinkout is started as an accessory  **/
/** This is an compiler dependant variable, so adapt it to yours **/
#if OS_TOS
#ifdef __TURBOC__
extern int _app;
#endif
#endif
#if OS_DOS
int _app=1;
#endif

/* prototypes */
void rsrc_init(void);
void do_redraw(void);
void new_game(void);
void add_region(int x,int y,int w,int h);
void clear(int x,int y,int w,int h);
void restart_level(void);
void boink_dial(void);
void load_levels(void);
void load_pic(void);
void multi(void);
int open_game_window(void);
void open_vwork(void);
void open_jump(void);
int do_jumpdial(void);

/* External variables */
extern int monoballs[], monobricks[], mono_perm_bricks[], monopaddle[];
extern int mono_digits[], mono_fuji[], monofuji_mask[], mono_eye[];
extern int mono_leveltext[], mono_twobrick[], invis, magic_bottom;
extern int medballs[], medbricks[], med_perm_bricks[], medpaddle[];
extern int med_digits[], med_fuji[], medfuji_mask[], med_eye[];
extern int med_leveltext[], med_twobrick[], gravity;

extern long snd_system;
extern int sound_switch;


/* Variables */
int n_redraws;
GRECT region[MAX_ANI];		/* a list of redraw regions */
GRECT tregion [MAX_ANI];		/* temporary clipping region */
BALL_STRUCT bs[MAX_BALLS];

int num_balls;
int done = FALSE; /* Tests whether users wants to quit program under application mode */

/*char null[] = "";*/

#define WI_KIND	(MOVER|CLOSER|NAME)

OBJECT *about_dial,*menu_ptr,*timing_dial,*highscore_dial,*scorelist_dial,
		*loading_dial,*icons_dial,*jump_dial, *objcolor_dial;
char *alert_noscore, *alert_cantcreate, *alert_cantfind, *alert_invalid;

int	aes_id;

int	gl_hchar, gl_wchar, gl_wbox, gl_hbox;	/* sizes of system characters */

int	win_kind = WI_KIND;
int	menu_id, paddle_x, paddle_y, pad_y_min, pad_y_max, pad_y_top;

int	phys_handle;	/* physical workstation handle */
int	vdi_handle;			/* virtual workstation handle */

struct win_info win[MAX_WINDOWS]; /* 1 win_info struct for each window */

SCORE_ENTRY scores[10] =
{ 
	"Mr. Humphries", 10, 5000L,
	"Mr. Grace Jr.", 9, 4000L,
	"Mr. Lucas", 8, 3500L,
	"Cpt. Peacock", 7, 3000L,
	"Mr. Rumbold", 6, 2500L,
	"Mr. Granger", 5, 2000L,
	"Mrs. Slocumb", 4, 1500L,
	"Mr. Harmon", 3, 1000L,
	"Ms. Brahms", 2, 750L,
	"Mr. Tebbs", 1, 500L
} ; /* This is our highscore list */

GRECT desk;
GRECT old;
GRECT work;	/* desktop and work areas */
GRECT max;

int	msg[8];					/* event message buffer */
int	ret;

int win_width = 448;
int win_height = 344;

extern char intbrickmask[36][63];
char brickmask[99][63];
int level;
int file_levels = 36; /* Number of levels in current file */

extern int mode;
int ani_count, num_bricks, cheat;
int	ball_ht = 20; /* Was 21; for some reason */
int win_ht = HEIGHT;
int max_xspeed = 8;
int min_yspeed = -8;
int planes;			/* number of bit planes */

int btop = 44;		/* actual top of block of bricks */
int btopm = 39;		/* measured top of bricks */
int bth = 26;		/* total brick height, including space */
int bh = 16;		/* brick height */
int block_bot = 221;	/* block_top = btopm + 7 * bth */
int bleft = 6;
int btw = 48;
int pady_offset = 25;
int max_pad_dy = 16;
int pad_ht = 19; 	/* paddle height */
int fuji_ht = 13;
int fmask_ht = 15;
int text_ht = 12;

char brickcount[63];
int objcolors[6] = {1,1,1,1,1,1};
int curr_colorobj = -1;

char title_bar[] = " BoinkOut2 ";

long score, old_score, bonus_life, old_bonus;
int lives, old_lives;

int	timer = 0;
int ttimer, event_kind = MU_KEYBD | MU_MESAG | MU_BUTTON;

int remap_pal = 1;  /* If this is off the screen colors will be modified by window */

int screen_colors;
int junkcolors[2] = {0,1};

int ballarray[8];			/* ball blit array */
int paddlearray[8];			/* paddle blit array */
int brickarray[8];

long mfdb_buffersize;

MFDB ballsource = {0L,144,20,144/16,0,1,0,0,0};
MFDB ballmask = {0L,144,20,144/16,0,1,0,0,0};
MFDB paddlesource = {0L,64,19,64/16,0,1,0,0,0};
MFDB paddlemask = {0L,64,19,64/16,0,1,0,0,0};
MFDB bricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB nbrickmask = {0L,192,16,192/16,0,1,0,0,0};
MFDB twobricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB magicbricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB twobrickmask = {0L,192,16,192/16,0,1,0,0,0};
MFDB permbricksource = {0L,192,16,192/16,0,1,0,0,0};
MFDB permbrickmask = {0L,192,16,192/16,0,1,0,0,0};
MFDB windsource = {0L,448,344,448/16,0,1,0,0,0};
MFDB pic_buf = {0L,448,344,448/16,0,1,0,0,0};
MFDB tit_buf = {0L,474,77,474/16,0,1,0,0,0};
MFDB digitsource = {0L,5*16,12,5,0,1,0,0,0};
MFDB fujisource = {0L,7*16,13,7,0,1,0,0,0};
MFDB fmasksource = {0L,7*16,15,7,0,1,0,0,0};
MFDB eyesource = {0L,144,20,144/16,0,1,0,0,0};
MFDB eyemask = {0L,144,20,144/16,0,1,0,0,0};
MFDB levelsource = {0L,3*16,12,3,0,1,0,0,0};
MFDB screen_fdb;

char path[PATH_MAX], name[FILENAME_MAX], lpath[PATH_MAX], spath[PATH_MAX], image_name[FILENAME_MAX];
char config_file[FILENAME_MAX];
char score_file[FILENAME_MAX];

RGB1000 screen_colortab[256]; /* used to save colors */
RGB1000 imgcolortab[256]; /* used to save colors */
RGB1000 aboutcolortab[256]; /* used to save colors */


char *boinkout_version = "This version FREEWARE  Ver: 2.0";

#if OS_TOS
	int	AES_type; /* We might want this to be global */
#endif

/****************************************************************/
/* open virtual workstation										*/
/****************************************************************/
void
open_vwork(void)
{
	register int i;
	int work_in[11], work_out[57], vwork_out[57];

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	vdi_handle=phys_handle;
	v_opnvwk(work_in,&vdi_handle,work_out);

	vq_extnd(vdi_handle, 1, vwork_out);
	screen_colors = work_out[13];
	planes = vwork_out[4];

	screen_fdb.fd_addr = 0L; /* This is the official way for the screen FDB */
}




int hidden;		/* = FALSE */
/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
void
do_redraw(void)
{
	register GRECT *p;
	GRECT t;
	register int i;
	int array[8];
	int x_pos,y_pos, mxmin, mxmax, mymin, mymax;
	int mbut,kstate;
	
	graf_mkstate(&x_pos,&y_pos,&mbut,&kstate);

	if (mbut == 0)
		ttimer = timer;
	else
		ttimer = 200;
		
	mxmin = x_pos - 20;
	mxmax = x_pos + 20;
	mymin = y_pos - 20;
	mymax = y_pos + 20;

	wind_update(TRUE);

	/* check all redraw regions for mouse interference */
	for (i=0; i<n_redraws; i++)
	{
		p = &region[i];
		if ((p->g_x < mxmax) && ((p->g_x + p->g_w) > mxmin) &&
			(p->g_y < mymax) && ((p->g_y + p->g_h) > mymin))
		{	
			HIDE_MOUSE;
			hidden = TRUE;
			break;
		}
	}

	/* clip all regions to screen size */
	for (i=0; i<n_redraws; i++)
	{
		p = &region[i];

		if (p->g_x < 0) 
			p->g_x = 0;

		if ((p->g_x+p->g_w) > desk.g_w) p->g_w = desk.g_w - p->g_x;
		if ((p->g_y+p->g_h) > max.g_y) p->g_h =max.g_y-p->g_y;
	}

	wind_get(win[GAME_WIN].handle,WF_FIRSTXYWH,ELTR(t));

	while (t.g_w && t.g_h)
	{
		for (i=0; i<n_redraws; i++)
		{
			p = &tregion[i];
			*p = t;				/* copy this window rect */

			if (rc_intersect(&region[i],p))
			/* tregion[i] clipped to my redraw region */
			{
				array[0] = p->g_x - work.g_x;
				array[1] = p->g_y - work.g_y;
				array[2] = p->g_x - work.g_x + p->g_w - 1;
				array[3] = p->g_y - work.g_y + p->g_h - 1;
				array[4] = p->g_x;
				array[5] = p->g_y;
				array[6] = p->g_x + p->g_w - 1;
				array[7] = p->g_y + p->g_h - 1;

				vro_cpyfm(vdi_handle,S_ONLY,array,&windsource,&screen_fdb);
			}
		}
		wind_get(win[GAME_WIN].handle,WF_NEXTXYWH,ELTR(t));
	}

	if (hidden)
	{	
		hidden = FALSE;
		SHOW_MOUSE;
	}

	wind_update(FALSE);
	n_redraws = 0;
}

/********************************/
/*		MAIN() 					*/
/********************************/
int
main()
{
	char tempname[FILENAME_MAX];
	char titname[FILENAME_MAX];

	srand(time(NULL)); /* Initialize the random number generator ( for rand() )*/

	aes_id = appl_init(); /* aes_id wasn't being set?  - DAN */

#if OS_TOS
	AES_type = identify_AES();

	if (_app != 0)
	{
		if( AES_type != AES_single ) 
		{
			shel_write(9,1,1,"","");
				
			if ( (AES_type == AES_MTOS)||(AES_type == AES_nAES))
	    		menu_register(aes_id, "  BoinkOut2  ");
		}
	}
	else
	    menu_id = menu_register(aes_id, "  BoinkOut2  ");
#else
	if (!_app) menu_id=menu_register(aes_id,"  BoinkOut2  ");
#endif


  	if( AES_type == AES_single ) 
   	{
   		if (_app != 0)
			va_helpbuf = (char *) Malloc(250);
		else
			va_helpbuf = (char *) malloc(250);
	}
	else
		va_helpbuf = (char *) Mxalloc(250,ALLOCMODE);

	va_helpbuf[0] = 0;

	send_avprot();
	
	phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	wind_get(0, WF_WORKXYWH, ELTR(desk));

	old.g_x = desk.g_x + (desk.g_w - WIDTH) / 2;
	old.g_y = desk.g_y + (desk.g_h - win_ht) / 3;
	old.g_w = WIDTH;
	old.g_h = win_ht;

	max.g_x = desk.g_x + desk.g_w;
	max.g_y = desk.g_y + desk.g_h;

/*	Set up the path for the background picture*/
#if OS_TOS
	path[0] = Dgetdrv() + 'A';
	path[1] = ':';
	Dgetpath(path+2, 0);
#endif
#if OS_DOS
	path[0] = dos_gdrv() + 'A';
	path[1] = ':';
	path[2] = '\\';
	dos_gdir(0, path+3);
#endif
#if OS_UNIX
	getcwd(path, PATH_MAX); /* Will most probably not work */
#endif
	if(path[strlen(path)-1]=='\\')  path[strlen(path)-1]=0;

	strcpy(tempname,path);
	strcpy(titname,path);
	strcpy(config_file,path);
	strcpy(score_file,path);
	strcpy(lpath,path);
	strcpy(spath,path);

#if OS_TOS
	if( AES_type != AES_single ) 
	{
#endif
		strcat(lpath,"\\data\\levels\\*.lvl");
		strcat(path,"\\data\\img\\*.img");
		strcat(spath,"\\data\\snd\\*.avr");
		strcpy(name,"BOINKOUT.LVL"/*null*/);
#if OS_TOS
	}
	else
	{
		strcat(lpath,"\\data\\levels\\*.LVL");
		strcat(path,"\\data\\img\\*.IMG");
		strcat(spath,"\\data\\snd\\*.AVR");
		strcpy(name,"BOINKOUT.LVL"/*null*/);	
	}
#endif

	win[GAME_WIN].handle = NO_WINDOW;
	win[ABOUT_WIN].handle = NO_WINDOW;
	win[JUMP_WIN].handle = NO_WINDOW;
	win[SCORE_WIN].handle = NO_WINDOW;

	if (_app)
	{
		open_vwork();
	}

	strcat(config_file,"\\data\\boinkout.cfg");
	read_cfg_file(config_file);

	if(desk.g_h>300)			/* new monitor */
	{
		windsource.fd_nplanes = planes;
		pic_buf.fd_nplanes = planes;
		tit_buf.fd_nplanes = planes;
 		pic_buf.fd_w = windsource.fd_w = win_width;   /* width        */
		windsource.fd_wdwidth = pic_buf.fd_wdwidth = (pic_buf.fd_w + 15) >> 4;
		tit_buf.fd_wdwidth = (tit_buf.fd_w + 15) >> 4;
		windsource.fd_h = pic_buf.fd_h = win_height;     /* height       */
		windsource.fd_stand = pic_buf.fd_stand = 0;                     /* raster format = device */
 
		ballsource.fd_addr = monoballs; 
		ballmask.fd_addr = monoballs; 
		paddlesource.fd_addr = monopaddle;
		paddlemask.fd_addr = monopaddle;
		bricksource.fd_addr = monobricks;
		nbrickmask.fd_addr = monobricks;
		twobricksource.fd_addr = mono_twobrick;
		magicbricksource.fd_addr = mono_twobrick;
		twobrickmask.fd_addr = mono_twobrick;
		permbricksource.fd_addr = mono_perm_bricks;
		permbrickmask.fd_addr = mono_perm_bricks;
		digitsource.fd_addr = mono_digits;
		fujisource.fd_addr = mono_fuji;
		fmasksource.fd_addr = monofuji_mask;
		eyesource.fd_addr = mono_eye;
		eyemask.fd_addr = mono_eye;
		levelsource.fd_addr = mono_leveltext;

		fix_image(&ballsource,objcolors[1]);
		fix_image(&paddlesource,objcolors[0]);
		fix_image(&bricksource,objcolors[2]);
		fix_image(&twobricksource,objcolors[5]);
		fix_image(&magicbricksource,objcolors[4]);
		fix_image(&permbricksource,objcolors[3]);
		fix_image(&digitsource,1);
		fix_image(&fujisource,objcolors[1]);
		fix_image(&eyesource,objcolors[1]);
		fix_image(&levelsource,1);

		pad_y_min = 247;
		pad_y_max = 323;
	}
	else
	{
		win_height=win_height/2;
		windsource.fd_nplanes = planes;
		pic_buf.fd_nplanes = planes;
		tit_buf.fd_nplanes = planes;
 		pic_buf.fd_w = windsource.fd_w = win_width;   /* width        */
		windsource.fd_wdwidth = pic_buf.fd_wdwidth = (pic_buf.fd_w + 15) >> 4;
		tit_buf.fd_wdwidth = (tit_buf.fd_w + 15) >> 4;
		windsource.fd_h = pic_buf.fd_h = win_height;     /* height       */
		windsource.fd_stand = pic_buf.fd_stand = 0;                     /* raster format = device */

		ball_ht = 10;
		win_ht = HEIGHT/2;
		min_yspeed = -4;
		btop = 22;
		btopm = 20;
		bth = 13;
		bh = 8;
		block_bot = 111;
		pady_offset = 12;
		max_pad_dy = 8;
		pad_ht = 10;
		fuji_ht = 6;
		fmask_ht = 8;
		text_ht = 6;

		pad_y_min = 122;
		pad_y_max = 159;

		ballsource.fd_addr = medballs;
		paddlesource.fd_addr = medpaddle;
		paddlemask.fd_addr = medpaddle;
		bricksource.fd_addr = medbricks;
		nbrickmask.fd_addr = medbricks;
		twobricksource.fd_addr = med_twobrick;
		magicbricksource.fd_addr = med_twobrick;
		twobrickmask.fd_addr = med_twobrick;
		permbricksource.fd_addr = med_perm_bricks;
		permbrickmask.fd_addr = med_perm_bricks;
		digitsource.fd_addr = med_digits;
		fujisource.fd_addr = med_fuji;
		fmasksource.fd_addr = medfuji_mask;
		eyesource.fd_addr = med_eye;
		eyemask.fd_addr = med_eye;
		levelsource.fd_addr = med_leveltext;

	}

	mfdb_buffersize = 2L*(long)pic_buf.fd_wdwidth*(long)pic_buf.fd_nplanes*(long)pic_buf.fd_h;

	if(( windsource.fd_addr = (short *) malloc(mfdb_buffersize ))== NULL)
		printf("No memory for window buffer\r\n");
	if(( pic_buf.fd_addr = (short *) malloc(mfdb_buffersize )) == NULL)
		printf("No memory for off screen buffer\r\n");

	/* Now load the title picture */

	mfdb_buffersize = 2L*(long)tit_buf.fd_wdwidth*(long)tit_buf.fd_nplanes*(long)tit_buf.fd_h;

	/* Not being able to load the title image should NOT be fatal 
		however it is at the moment */

	if(( tit_buf.fd_addr = (short *) malloc(mfdb_buffersize )) == NULL)
		printf("No memory for title buffer\r\n");

	/* Load RSC */
	if (!rsrc_load("boinkout.rsc"))
	{
		form_alert(1, "[1][Error Loading Resource!][Quit]");
		exit(EXIT_FAILURE);
	}
		
	rsrc_init();
	
	set_tedinfo(about_dial, R_VERSION, boinkout_version);
	
	if (_app)
	{
		graf_mouse( ARROW, 0L);

		menu_bar(menu_ptr, 1);	/* display the menu */
	}

	save_colors();

	if (_app)
	{
		do_loading();

		do_wind_redraw(win[LOADING_WIN].handle,&win[LOADING_WIN].curr);
	}

	strcat(titname,"\\data\\img\\title.img");
	img_load(&tit_buf, titname);

	save_about_colors();

	if (_app)
	{
		set_tedinfo(loading_dial, RIMG_COUNT, "(2/2)");
		
		do_wind_redraw(win[LOADING_WIN].handle,&win[LOADING_WIN].curr);
	}

	strcat(tempname,"\\data\\img\\back.img");
	img_load(&pic_buf, tempname);

	save_image_colors();

	if (_app)
	{
		wind_close(win[LOADING_WIN].handle);
		wind_delete(win[LOADING_WIN].handle);

		win[LOADING_WIN].handle = NO_WINDOW;
	}

	reset_colors();

	strcat(score_file,"\\data\\boinkout.hgh");
	read_highscore();

	memcpy(brickmask,intbrickmask,sizeof(intbrickmask));

	sound_init();

	multi();			/* accessory will not return, program will */

	sound_exit();

	menu_bar(menu_ptr, 0);	/* erase the menu bar */

	if (remap_pal == 0)
		reset_colors();

	v_clsvwk(vdi_handle);	/* close the vdi handle */

	if (planes > 2)
	{
		free(ballsource.fd_addr); 
		free(paddlesource.fd_addr);
		free(bricksource.fd_addr);
		free(twobricksource.fd_addr);
		free(magicbricksource.fd_addr);
		free(permbricksource.fd_addr);
		free(digitsource.fd_addr);
		free(fujisource.fd_addr);
		free(eyesource.fd_addr);
		free(levelsource.fd_addr);
	}

	free(pic_buf.fd_addr);
	free(tit_buf.fd_addr);
	free(windsource.fd_addr);

	send_avexit();
	
	Mfree(va_helpbuf);

	rsrc_free();
	appl_exit();
	
	exit(1);
}

void
m_timing_event(void)
{
	int xchoice;
	GRECT dial;
	char tempstr[4];

	if (remap_pal == 0)
		reset_colors();

	sprintf(tempstr,"%d",timer);

	set_tedinfo(timing_dial, TIMING_VALUE, tempstr);

	form_center(timing_dial,ELTR(dial));
	form_dial(FMD_START,0,0,10,10,ELTS(dial));
	objc_draw(timing_dial,0,3,ELTS(dial));

	xchoice = (form_do(timing_dial, 0) & 0x7fff);

	form_dial(FMD_FINISH,0,0,10,10,ELTS(dial));

	timing_dial[xchoice].ob_state &= ~SELECTED;

	if (xchoice == B_SETTIME)
	{
		get_tedinfo(timing_dial,TIMING_VALUE,tempstr);
		timer = atoi(tempstr);
	}

	if (remap_pal == 0)
		load_image_colors();
}

void
get_high_name(int x)
{
	int xchoice;
	GRECT dial;
	static char tempstr[14]="";

	if (remap_pal == 0)
		reset_colors();

	set_tedinfo(highscore_dial, D_ENTERNAME, tempstr);

	form_center(highscore_dial,ELTR(dial));
	form_dial(FMD_START,0,0,10,10,ELTS(dial));
	objc_draw(highscore_dial,0,3,ELTS(dial));
	xchoice = (form_do(highscore_dial, 0) & 0x7fff);
	form_dial(FMD_FINISH,0,0,10,10,ELTS(dial));

	highscore_dial[xchoice].ob_state &= ~SELECTED;

	get_tedinfo(highscore_dial,D_ENTERNAME,tempstr);

	strcpy(scores[x].name,tempstr);
	scores[x].level = level + 1;
	scores[x].score = score;	/* MAR -- .score is now long  */

	write_score();
	read_highscore();

	if (remap_pal == 0)
		load_image_colors();
}

void
m_load_event(void)
{
	if (remap_pal == 0)
		reset_colors();

	load_pic();
}

void
m_quit_event(void)
{
	if (win[GAME_WIN].handle != NO_WINDOW)
	{	
		wind_close(win[GAME_WIN].handle);
		wind_delete(win[GAME_WIN].handle);
	}

	done = TRUE;
}

void
m_new_event(void)
{
	if (win[GAME_WIN].handle != NO_WINDOW)
	{	
		if (win[GAME_WIN].status == 3) /* iconified */
			un_iconify(GAME_WIN,(GRECT *)&win[GAME_WIN].curr);

		wind_set(win[GAME_WIN].handle,WF_TOP,0,0,0,0);

		if (lives <= 0)
		{
			new_game();
			restart_level();
			event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
		}
	}
	else open_game_window();
}

/*
 *  This routine handles all keyboard input
 */
void
handle_key_evnts(int key,int mousex,int mousey)
{
	int cont, next, state, scan;
	int w_info, top_window;
	GRECT p;

	top_window = get_topwindow(0);

	wind_get(top_window,WF_WORKXYWH,ELTR(p));

	w_info = get_wininfo_from_handle(top_window);

	if ((w_info != -1) && (win[w_info].status == 1))
	{			
		if(w_info == JUMP_WIN)
		{
			cont = form_keybd(win[JUMP_WIN].window_obj, win[JUMP_WIN].cur_item, 0, key, &next, &scan);

			if (scan)
			{
				/* if not special the edit the form */
					
				objc_edit(win[JUMP_WIN].window_obj, win[JUMP_WIN].cur_item, scan, (int *)win[JUMP_WIN].edit_pos, ED_CHAR,(int *)&win[JUMP_WIN].edit_pos);
				return;
			}

			if ((cont != 1) || (next!=0 && next != win[w_info].cur_item))
			{	
				objc_edit(win[JUMP_WIN].window_obj, win[JUMP_WIN].cur_item, 0, win[JUMP_WIN].edit_pos, ED_END,&win[JUMP_WIN].edit_pos);

				if (next == JUMP_GO)
					jump_drive(next);
				else
				{
					win[JUMP_WIN].cur_item = next;

					objc_edit(win[JUMP_WIN].window_obj,win[JUMP_WIN].cur_item,0, win[JUMP_WIN].edit_pos,ED_INIT,&win[JUMP_WIN].edit_pos);
				}
				return;
			}				
		}			
	}				
/*printf("%d\r\n",key);
*/			
	switch (key)
	{
		case 283:  /* Esc key */
			if(w_info == GAME_WIN)
			{
				if(win[w_info].status == 1)
				{
					/* Esc - Pause */
					if (event_kind == (MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD))
						event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;
					else
						event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
				}
			}
			break;
					
		case 9740:
			/* Control L */
			m_load_event();
			break;
					
		case 4113:
			/* Control Q */
			m_quit_event();
			break;
					
		case 6159:
			/* Control O */
			m_new_event();
			break;
					
		case 9226:
			/* Control J */
			open_jump();	
			break;

		case 11779:
			/* Control C - copy */
			if ((w_info != -1) && (win[w_info].status == 1)&&
				(win[w_info].edit == 1) && (win[w_info].cur_item != -1))
				copy_paste(w_info);
			break;
		case 12054:
			/* Control V - Paste */
			if ((w_info != -1) && (win[w_info].status == 1))
				paste_text(w_info);
			break;
					
		case 12558:
			/* Control N */
			m_new_event();
			break;

		case 25088: /* Help Key */

#if 0			
			switch(w_info)
			{
				case INBOX_WIN:
					do_help("INBOX Window");
					break;
				case OUTBOX_WIN:
					do_help("OUTBOX Window");
					break;
				case ABOUT_WIN:
					do_help("Contents");
					break;
				default:
					do_help("Main");
					break;
			}
#endif
			do_help("Main");
			break;
			
		default:
sendkey:
			state = (int)Kbshift(-1);
					
			msg[0] = AV_SENDKEY;

#ifdef __GNUC__
 			msg[1] = _global[2];  /* my apps id */ 
#else
  			msg[1] = _GemParBlk.global[2];  /* my apps id */ 
#endif
			msg[2] = 0;
			msg[3] = state;
			msg[4] = key;
			msg[5] = msg[6] = msg[7] = 0;
    		appl_write(get_avserver(), 16, &msg);
			break;     
	}
						
	return;
}

/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
void
multi(void)
{
	int event, scan;
	int junk, k, w_info, top_window;
	int button = 0, clicks = 0;
	int mousex, mousey;	
	int which_obj;

/*	The accessory will loop forever, the program loops until	*/
/*	the done variable is set to TRUE.							*/

	while ((!_app) || !done)
	{
		event = evnt_multi(event_kind,
/*			1,0,0,*/
			2,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,
			ttimer,0,
			&mousex,&mousey,&button,&ret,&scan,&clicks);

		if (event & MU_MESAG) switch (msg[0])
		{

		case MN_SELECTED:

		/* menu functions, program only */

			switch(msg[4])
			{

			case ABOUT_BOINK:
				boink_dial();
				break;

			case M_NEW:
				m_new_event();
				break;

			case M_PAUSE:
				if (event_kind == (MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD))
					event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;
				else
					event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
				break;

			case M_LEVEL:
				load_levels();
				break;
				
			case M_JUMP:
				open_jump();
				break;
				
			case M_LOAD:
				m_load_event();
				break;

			case M_QUIT:
				m_quit_event();
				break;
				
			case M_SOUNDSWITCH:
				sound_switch=!sound_switch;
				break;
#if 0
	I removed this option right now
					
			case M_REMAPPALETTE:
				remap_pal=!remap_pal;
				break;
#endif 
			
			case M_SETCOLORS:
				open_objcolors();
				break;
				
			case M_TIMING:
				m_timing_event();
				break;
				
			case M_VIEWSCORES:
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
		    	if ((w_info == GAME_WIN)&&
		    		(win[w_info].status == 1))
		    	{
					add_region(msg[4],msg[5],msg[6],msg[7]);
					do_redraw();
				}
				else
					do_wind_redraw(win[w_info].handle,(GRECT *)&msg[4]);
			}
	    	break;

		case WM_NEWTOP:
		case WM_TOPPED:
			wind_set(msg[3], WF_TOP, msg[3], 0,0,0);
			/* Nasty hack for lower resolutions
				and to deal with my nasty programming */

			if (remap_pal == 0)
			{
				if (msg[3] == win[GAME_WIN].handle)
					load_image_colors();
				else if (msg[3] == win[OBJCOLOR_WIN].handle)
					load_image_colors();
				else if (msg[3] == win[ABOUT_WIN].handle)		
					load_about_colors();
				else 
					reset_colors();
			}
					
	    	break;

		case AC_CLOSE:
			if((msg[3] == menu_id) && (win[GAME_WIN].handle != NO_WINDOW))
			{
				wind_update(TRUE);

				v_clsvwk(vdi_handle);

				win[GAME_WIN].handle = NO_WINDOW;
				sound_exit();
				event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;
				wind_update(FALSE);
			}
			break;

#if OS_TOS
		case AP_TERM:
			if (_app)
				done = 1;
			break;
#endif
		case WM_CLOSED:
			if(msg[3] == win[GAME_WIN].handle)
			{	wind_close(win[GAME_WIN].handle);
				graf_shrinkbox(desk.g_x,desk.g_y,gl_wbox,gl_hbox,ELTS(old));
				wind_delete(win[GAME_WIN].handle);

				if (!_app) v_clsvwk(vdi_handle);

				win[GAME_WIN].handle = NO_WINDOW;
				sound_exit();
				event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;
			}
			else
			{
				wind_close(msg[3]);
				wind_delete(msg[3]);

				w_info = get_wininfo_from_handle(msg[3]);
			
				win[w_info].handle = NO_WINDOW;			

				if (remap_pal == 0)
				{
					if (win[GAME_WIN].handle == get_topwindow(msg[3]))					
						load_image_colors();
					else if (win[ABOUT_WIN].handle == get_topwindow(msg[3]))
						load_about_colors();
					else
						reset_colors();
				}
			}
			break;

#if OS_TOS
		case WM_ICONIFY:
			w_info = get_wininfo_from_handle(msg[3]);
			
			if (w_info != -1)			
				iconify(w_info,((GRECT *)&msg[4]));

			if (w_info == GAME_WIN)
				event_kind = MU_MESAG | MU_KEYBD | MU_BUTTON;

			if (remap_pal == 0)
			{
				if (win[GAME_WIN].handle == get_topwindow(msg[3]))			
					load_image_colors();
				else
					reset_colors();
			}
			break;

		case WM_UNICONIFY:
			w_info = get_wininfo_from_handle(msg[3]);

			if (w_info != -1)
			{
				un_iconify(w_info,((GRECT *)&msg[4]));

				wind_set(msg[3], WF_TOP, msg[3]);
			
				if (remap_pal == 0)
				{
					if (w_info == GAME_WIN)
						load_image_colors();
					else if (w_info == ABOUT_WIN)
						load_about_colors();
					else 
						reset_colors();
				}
			}
				
			break;
#endif /* OS_TOS */

		case WM_MOVED:
			if(msg[3] == win[GAME_WIN].handle) 
			{
				old.g_x = msg[4];
				old.g_y = msg[5];

				wind_set(win[GAME_WIN].handle,WF_CURRXYWH,msg[4],
					msg[5],old.g_w,old.g_h);
				wind_get(win[GAME_WIN].handle,WF_WORKXYWH,ELTR(work));
			}
			else
			{
				wind_set(msg[3], WF_CURRXYWH, PTRS((GRECT *)&msg[4]));

				w_info = get_wininfo_from_handle(msg[3]);

				switch(win[w_info].status)
				{
					case 1:
						/* Normal */
							
						if (win[w_info].type == 0)
							wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
							  ELTR(win[w_info].curr));
						else
							wind_calc(WC_WORK, W_T2, PTRS((GRECT *)&msg[4]),
							  ELTR(win[w_info].curr));

						win[w_info].window_obj[ROOT].ob_x = win[w_info].curr.g_x;
						win[w_info].window_obj[ROOT].ob_y = win[w_info].curr.g_y;
						win[w_info].window_obj[ROOT].ob_width = win[w_info].curr.g_w;
						win[w_info].window_obj[ROOT].ob_height = win[w_info].curr.g_h;
						break;
							
					case 2:
						/* Rolled up */						

						wind_calc(WC_WORK, W_TYPE, PTRS((GRECT *)&msg[4]),
						  &win[w_info].curr.g_x,
						  &win[w_info].curr.g_y,
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
			}

		    break;

		case AC_OPEN:
		    if (msg[4] == menu_id)
			{
				graf_mkstate(&junk, &junk, &junk, &k);
				if(k & 3)
				{
					boink_dial();
					break;
				}

				if (win[GAME_WIN].handle == NO_WINDOW)
				{	
					open_vwork();

					if (open_game_window() < 0)
					{
						v_clsvwk(vdi_handle);
						break;
					}
				}
				else
				{
					if (win[GAME_WIN].status == 3) /* iconified */
						un_iconify(GAME_WIN,(GRECT *)&win[GAME_WIN].curr);

					wind_set(win[GAME_WIN].handle,WF_TOP,0,0,0,0);
					if (lives <= 0)
					{
						new_game();
						restart_level();
						event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
					}
				}
			}
			break;

		} /* switch (msg[0]) */


		
		/* Grab those fabulous hot keys */
		if (event & MU_KEYBD)
			handle_key_evnts(scan, mousex, mousey);
		
		if (event & MU_TIMER)
		{	if (win[GAME_WIN].handle != NO_WINDOW)
			{
				new_ball();
			}
		}

		/* Get Mouse Button Events */
		if (event & MU_BUTTON)
		{
			if (button == 1)
			{
				junk = wind_find(mousex,mousey);

				top_window = get_topwindow(junk);
		
				if (top_window == junk) /* don't do anything unless top window */
				{	
					w_info = get_wininfo_from_handle(junk);
						
					if (win[w_info].status == 1) /* don't do anything if iconified */
					{
						which_obj = objc_find(win[w_info].window_obj,0,MAX_DEPTH,mousex,mousey);
	
						if (w_info == JUMP_WIN)
							jump_drive(which_obj);
						else if (w_info == OBJCOLOR_WIN)
							objcolors_drive(which_obj);
						else if (w_info == ABOUT_WIN)
							about_drive(which_obj);
					}
				}
			}
		}
		
	} /* while (!_app || !done) */
}

/* put up high score list window */
void
high_score(void)
{

	if (win[SCORE_WIN].handle == NO_WINDOW)
	{
		do_scorelist();
		return;
	}

	if (win[SCORE_WIN].status == 3) /* iconified */
	{
		un_iconify(SCORE_WIN, (GRECT *)&win[SCORE_WIN].curr);
		wind_set(win[SCORE_WIN].handle, WF_TOP, win[SCORE_WIN].handle,0,0,0);
	}
	else if (win[SCORE_WIN].status == 1) /* normal */
	{
		wind_set(win[SCORE_WIN].handle, WF_TOP, win[SCORE_WIN].handle,0,0,0);
	}
	else
		do_scorelist();

	return;
}

/* put up about window */
void
boink_dial(void)
{
	if (win[ABOUT_WIN].handle == NO_WINDOW)
	{
		do_title();
		return;
	}

	if (win[ABOUT_WIN].status == 3) /* iconified */
	{
		un_iconify(ABOUT_WIN,(GRECT *)&win[ABOUT_WIN].curr);
		wind_set(win[ABOUT_WIN].handle, WF_TOP, win[ABOUT_WIN].handle,0,0,0);
	}
	else if (win[ABOUT_WIN].status == 1) /* normal */
	{
		wind_set(win[ABOUT_WIN].handle, WF_TOP, win[ABOUT_WIN].handle,0,0,0);
	}
	else
		do_title();

	return;
}

/* put up jump window dialog */
void
open_jump(void)
{
	if (win[JUMP_WIN].handle == NO_WINDOW)
	{
		do_jumpdial();
		return;
	}

	if (win[JUMP_WIN].status == 3) /* iconified */
	{
		un_iconify(JUMP_WIN,(GRECT *)&win[JUMP_WIN].curr);
		wind_set(win[JUMP_WIN].handle, WF_TOP, win[JUMP_WIN].handle,0,0,0);
	}
	else if (win[JUMP_WIN].status == 1) /* normal */
	{
		wind_set(win[JUMP_WIN].handle, WF_TOP, win[JUMP_WIN].handle,0,0,0);
	}
	else
		do_jumpdial();

	return;
}

int
about_drive(int which_obj)
{
	GRECT p;
	int x_pos,y_pos;
	int mbut,kstate;

	
	wind_get(win[ABOUT_WIN].handle,WF_WORKXYWH,ELTR(p));

	if(which_obj == R_URL)
	{
		objc_change(win[ABOUT_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);

		objc_change(win[ABOUT_WIN].window_obj,which_obj,0,ELTS(p),0x0000,1);

		run_web_browser("*http://www.netset.com/~baldrick/boinkout2.html");
		
		while(TRUE)
		{
			graf_mkstate(&x_pos,&y_pos,&mbut,&kstate);
			
			if (mbut == 0)
				break;
		}
	}
		
	return(1);
}

int
jump_drive(int which_obj)
{
	GRECT p;
	char ft[100] = "";
	int jump_lvl;
	
	set_tedinfo(win[JUMP_WIN].window_obj, JUMP_LEVEL_NAME, name);
	sprintf(ft,"%d",file_levels);
	set_tedinfo(win[JUMP_WIN].window_obj, JUMP_LEVEL_NUM, ft);

	wind_get(win[JUMP_WIN].handle,WF_WORKXYWH,ELTR(p));

	if(which_obj == JUMP_GO)
	{
		objc_change(win[JUMP_WIN].window_obj,which_obj,0,ELTS(p),0x0001,1);

		objc_change(win[JUMP_WIN].window_obj,which_obj,0,ELTS(p),0x0000,1);

		jump_lvl = atoi(win[JUMP_WIN].window_obj[JUMP_SELECT].ob_spec.tedinfo->te_ptext);

		if ((jump_lvl > file_levels)||
			(jump_lvl < 1)) /* make sure it's in range and the user isn't a joker */
		{
			form_alert(1,alert_invalid);
			return(0);
		}
		
		if (win[GAME_WIN].handle != NO_WINDOW)
		{
			lives = old_lives = 3;
			score = old_score = 0;
			bonus_life = old_bonus = BONUS;
			pad_y_top = pad_y_min;
			level = jump_lvl - 1;

			/* Close the jump window */
			wind_close(win[JUMP_WIN].handle);
			wind_delete(win[JUMP_WIN].handle);

			/* clear JUMP_WIN handle */
			win[JUMP_WIN].handle = NO_WINDOW;

			/* If GAME_WIN is iconified, uniconify it */
			if (win[GAME_WIN].status == 3) /* iconified */
				un_iconify(GAME_WIN,(GRECT *)&win[GAME_WIN].curr);

			/* Top the Game window */
			wind_set(win[GAME_WIN].handle, WF_TOP, win[GAME_WIN].handle,0,0,0);

			/* Set the colors to the Game Window colors */
			if (remap_pal == 0)
				load_image_colors();

			restart_level();
			event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
		}
	}
	else if (which_obj == JUMP_SELECT)
	{
		/* Disable old edit field */

		objc_edit(win[JUMP_WIN].window_obj, win[JUMP_WIN].cur_item, 0, &win[JUMP_WIN].edit_pos, ED_END, &win[JUMP_WIN].edit_pos);
		objc_draw(win[JUMP_WIN].window_obj, ROOT, MAX_DEPTH, ELTS(p));

		/* Enable Level selection edit field */
		objc_edit(win[JUMP_WIN].window_obj,win[JUMP_WIN].cur_item,0, win[JUMP_WIN].edit_pos,ED_INIT, &win[JUMP_WIN].edit_pos);
		objc_draw(win[JUMP_WIN].window_obj, JUMP_SELECT, MAX_DEPTH, ELTS(p));
	}
		
	return(1);
}

int
redraw_objcolors(void)
{
	int x,y,x1;
	int loop,size,tot_colors;
	
		
	HIDE_MOUSE;
	wind_update(TRUE);

	/* First reset the color pallete in the window */

	objc_offset(objcolor_dial,COLOR1,&x,&y);
	color_square(vdi_handle, objcolors[0], x, y, 16);

	objc_offset(objcolor_dial,COLOR2,&x,&y);
	color_square(vdi_handle, objcolors[1], x, y, 16);
			
	objc_offset(objcolor_dial,COLOR3,&x,&y);
	color_square(vdi_handle, objcolors[2], x, y, 16);

	objc_offset(objcolor_dial,COLOR4,&x,&y);
	color_square(vdi_handle, objcolors[3], x, y, 16);

	objc_offset(objcolor_dial,COLOR5,&x,&y);
	color_square(vdi_handle, objcolors[4], x, y, 16);

	objc_offset(objcolor_dial,COLOR6,&x,&y);
	color_square(vdi_handle, objcolors[5], x, y, 16);

	/* Now draw the color selection box */
	if (planes >= 8)
		tot_colors = 256;
	else
		tot_colors = (1 << planes);

	/* I'm tired and the following is crap but it's 
	 * working crap
	 */
	 
	switch(tot_colors)
	{
		case 1:
		case 4:
			size = 64;
			break;
		case 16:
			size = 32;
			break;
		case 256:
			size = 8;
			break;
	}
	
	objc_offset(objcolor_dial,DCOLORBOX,&x1,&y);

	x = x1; /* Store real offsets for later */
	
	for (loop=0;loop < tot_colors;loop++)
	{
		color_square(vdi_handle, loop, x, y, size);
		
		x = x + size;

		if (x >= (x1 + 128))
		{
			x = x1;
			y = y + size;
		}
	}

	wind_update(FALSE);
	SHOW_MOUSE;

	return(1);
}

/* put up jump window dialog */
void
open_objcolors(void)
{
	if (win[OBJCOLOR_WIN].handle == NO_WINDOW)
	{
		do_objcolorsdial();
		return;
	}

	if (win[OBJCOLOR_WIN].status == 3) /* iconified */
	{
		un_iconify(OBJCOLOR_WIN,(GRECT *)&win[OBJCOLOR_WIN].curr);
		wind_set(win[OBJCOLOR_WIN].handle, WF_TOP, win[OBJCOLOR_WIN].handle,0,0,0);
	}
	else if (win[OBJCOLOR_WIN].status == 1) /* normal */
	{
		wind_set(win[OBJCOLOR_WIN].handle, WF_TOP, win[OBJCOLOR_WIN].handle,0,0,0);
	}
	else
		do_objcolorsdial();

	return;
}

int
objcolors_drive(int which_obj)
{
	GRECT p;
	int x,y,x1,y1,x2,y2,junk;
	int hardware_color, vdi_color ;	
	int tot_colors, size;

	redraw_objcolors();

	wind_get(win[OBJCOLOR_WIN].handle,WF_WORKXYWH,ELTR(p));

	if(which_obj == DPADCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DPADCOLOR;
	}
	else if(which_obj == DBALLCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DBALLCOLOR;
	}
	else if(which_obj == DBRICKCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DBRICKCOLOR;
	}
	else if(which_obj == DPERMCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DPERMCOLOR;
	}
	else if(which_obj == DMAGICCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DMAGICCOLOR;
	}		
	else if(which_obj == DSPINCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,curr_colorobj,0,ELTS(p),0x0000,1);
		curr_colorobj = DSPINCOLOR;
	}	
	else if(which_obj == DCOLORBOX)
	{
		graf_mkstate(&x,&y,&junk,&junk);
		
		v_get_pixel(vdi_handle, x-1, y-1, &hardware_color, &vdi_color);

		/* If we are in TrueColor modes then we need to track down
		 * which color we want - Yuck!
		 *
		 * If this were really nice for true color we wouldn't 
		 * mess with the pens and would just display a wide color
		 * map that the user could select from.
		 *
		 * However I have too many projects to work on that people
		 * are asking for fixes to spend another week working this out
		 * right now.  So I am going to be cheap and track the pen by the physical
		 * location on the screen from where I drew the color boxes.
		 */

		if (planes > 8)
		{
			/* Get the size of color selection box */
			if (planes >= 8)
				tot_colors = 256;
			else
				tot_colors = (1 << planes);

			/* Copied from redraw_objcolors above.
			 * working crap
			 */
	 
			switch(tot_colors)
			{
				case 1:
				case 4:
					size = 64;
				break;
				case 16:
					size = 32;
					break;
				case 256:
					size = 8;
					break;
			}
		
			/* Get x and y of color box object */
			objc_offset(objcolor_dial,DCOLORBOX,&x1,&y1);

			x2 = x - x1;
			y2 = y - y1;

			x2 = x2/size;
			y2 = y2/size;
			
			vdi_color = x2 + (y2 * (128/size));
		}
		
		switch(curr_colorobj)
		{
			case DPADCOLOR:
				objcolors[0] = vdi_color;
				break;
			case DBALLCOLOR:
				objcolors[1] = vdi_color;
				break;
			case DBRICKCOLOR:
				objcolors[2] = vdi_color;
				break;
			case DPERMCOLOR:
				objcolors[3] = vdi_color;
				break;
			case DMAGICCOLOR:
				objcolors[4] = vdi_color;
				break;
			case DSPINCOLOR:
				objcolors[5] = vdi_color;
				break;
		}
		
		redraw_objcolors();
	}
	else if(which_obj == DSETCOLOR)
	{
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0001,1);
		objc_change(objcolor_dial,which_obj,0,ELTS(p),0x0000,1);
		curr_colorobj = -1;

		free(ballsource.fd_addr); 
		free(paddlesource.fd_addr);
		free(bricksource.fd_addr);
		free(twobricksource.fd_addr);
		free(magicbricksource.fd_addr);
		free(permbricksource.fd_addr);
		free(fujisource.fd_addr);
		free(eyesource.fd_addr);
		
		ballsource.fd_addr = monoballs; 
		paddlesource.fd_addr = monopaddle;
		bricksource.fd_addr = monobricks;
		twobricksource.fd_addr = mono_twobrick;
		magicbricksource.fd_addr = mono_twobrick;
		permbricksource.fd_addr = mono_perm_bricks;
		fujisource.fd_addr = mono_fuji;
		eyesource.fd_addr = mono_eye;

		fix_image(&paddlesource,objcolors[0]);
		fix_image(&ballsource,objcolors[1]);
		fix_image(&fujisource,objcolors[1]);
		fix_image(&eyesource,objcolors[1]);
		fix_image(&bricksource,objcolors[2]);
		fix_image(&permbricksource,objcolors[3]);
		fix_image(&magicbricksource,objcolors[4]);
		fix_image(&twobricksource,objcolors[5]);

		wind_set(win[GAME_WIN].handle, WF_TOP, win[GAME_WIN].handle,0,0,0);

		restart_level();
		event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
	}
			
	return(1);
}

void 
rsrc_init(void)
{
	rsrc_gaddr(0, MENU,&menu_ptr); 	
	rsrc_gaddr(0, ABOUT,&about_dial);
	rsrc_gaddr(0, TIMING,&timing_dial);
	rsrc_gaddr(0, HIGHSCORE,&highscore_dial);
	rsrc_gaddr(0, SCORELIST,&scorelist_dial);
	rsrc_gaddr(0, LOADING,&loading_dial);
	rsrc_gaddr(0, JUMPLEVEL,&jump_dial);
	rsrc_gaddr(0, ICONS,&icons_dial);
	rsrc_gaddr(0, OBJCOLORS,&objcolor_dial);
	rsrc_gaddr(R_STRING,ALERT_NOSCOR,&alert_noscore);
	rsrc_gaddr(R_STRING,ALERT_CANTCREATE,&alert_cantcreate);
	rsrc_gaddr(R_STRING,ALERT_CANTFIND,&alert_cantfind);
	rsrc_gaddr(R_STRING,ALERT_INVALID,&alert_invalid);
}



/* Allow the user access to a Gem file selector to pick a new */
/* level file */

void
load_levels(void)
{
	register int i;
	FILE *fd;
	int button;
	char complete[80];

	if (remap_pal == 0)
		reset_colors();

	wind_update(TRUE);
	fsel_input(lpath,name,&button);
	if (!button) goto end;

	i = (int)strlen(lpath) - 1;
	while (i > 0 && (lpath[i] != '\\') && (lpath[i] != ':'))
		i--;
	strcpy(complete,lpath);
	strcpy(&complete[i+1],name);

	fd = fopen(complete, "r");
	if (fd == NULL) goto end;

	fclose(fd);
	
	read_level_file(complete);

	if (remap_pal == 0)
		load_image_colors();

	if (win[GAME_WIN].handle != NO_WINDOW)
	{
		if (lives <= 0) new_game();
		restart_level();
		event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
	}

end:
	wind_update(FALSE);
}

/* Allow the user access to a Gem file selector to pick a new */
/* background picture */

void
load_pic(void)
{
	register int i;
	FILE *fd;
	int button;
	char complete[80];

	wind_update(TRUE);
	fsel_input(path,image_name,&button);
	if (!button) goto end;

	i = (int)strlen(path) - 1;
	while (i > 0 && (path[i] != '\\') && (path[i] != ':'))
		i--;
	strcpy(complete,path);
	strcpy(&complete[i+1],image_name);

	fd = fopen(complete, "r");
	if (fd == NULL) goto end;

	fclose(fd);

	if (remap_pal == 0)
		reset_colors();

	wind_update(FALSE);

	if (_app)
	{
		do_loading();

		set_tedinfo(loading_dial, RIMG_COUNT, "(1/1)");

		do_wind_redraw(win[LOADING_WIN].handle,&win[LOADING_WIN].curr);
	}

	img_load(&pic_buf, complete);

	save_image_colors();

	reset_colors();

	if (_app)
	{
		wind_close(win[LOADING_WIN].handle);
		wind_delete(win[LOADING_WIN].handle);
		win[LOADING_WIN].handle = NO_WINDOW;
	}	

	wind_update(TRUE);

	if (win[GAME_WIN].handle != NO_WINDOW)
	{
		if (lives <= 0) new_game();
		restart_level();
		event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;
	}

end:
	wind_update(FALSE);
}

void
restart_level(void)
{
	register int x, y, image, ndx;
	int ltemp = level % file_levels;

    int colors[2];
    
    colors[0] = 0;
    colors[1] = 1;
    
	if (win[GAME_WIN].handle == NO_WINDOW) return;

	magic_bottom = 0;
 	gravity = 0;
	score = old_score;
	lives = old_lives;
	bonus_life = old_bonus;
	invis = FALSE;

	clear_areas();

	num_bricks = 0;

	brickarray[0] = brickarray[1] = brickarray[4] = brickarray[5] = 0;
	brickarray[2] = brickarray[6] = pic_buf.fd_w - 1;
	brickarray[3] = brickarray[7] = pic_buf.fd_h - 1;
	vro_cpyfm(vdi_handle,S_ONLY,brickarray,&pic_buf,&windsource); /* windsource */

	show_lives();
	show_level();
	show_score();

	brickarray[1] = 0;
	brickarray[3] = bh-1;

	ndx = 0;
	for (y=0; y<7; y++)
	{
		for (x=0; x < 9; x++)
		{
			brickarray[0] = 0;
			brickarray[2] = 43;
			brickarray[4] = bleft + x * btw;
			brickarray[5] = btop + y * bth;
			brickarray[6] = brickarray[4] + 43;
			brickarray[7] = brickarray[5] + bh - 1;

			switch(brickmask[ltemp][ndx])
			{
				case 9:		/* permanent */
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&permbrickmask,&windsource,colors);	
					vro_notcpy(brickarray, &permbricksource, &windsource);
					break;

				case 1:			/* normal */
					num_bricks++;
					break;

				case 2:			/* magic */
					vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,colors);
					vro_notcpy(brickarray, &magicbricksource, &windsource);

					num_bricks++;
					break;

				case 3:
				case 4:
				case 5:
				case 6:
					num_bricks++;
					break;
			}
			ndx++;
		}
	}

	n_redraws = 0;
	add_region(work.g_x,work.g_y,work.g_w,work.g_h);
	do_redraw();

	evnt_timer(150,0);

	sound_play(S_APPEAR);
	
	evnt_timer(350,0);

	for (image = 3; image >= 0; image--)
	{
		ndx = 0;
		brickarray[0] = image * btw;
		brickarray[2] = brickarray[0] + btw - 1;

		for (y=0; y<7; y++)
		{
			for (x=0; x < 9; x++)
			{
				brickarray[4] = bleft + x * btw;
				brickarray[5] = btop + y * bth;
				brickarray[6] = brickarray[4] + btw - 1;
				brickarray[7] = brickarray[5] + bh - 1;

				switch(brickmask[ltemp][ndx++])
				{
					case 1:
						vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&nbrickmask,&windsource,junkcolors);
						vro_notcpy(brickarray, &bricksource, &windsource);
						break;
				case 3:
				case 4:
				case 5:
				case 6:
					if (image > 0)
					{
						vrt_cpyfm(vdi_handle, MD_TRANS, brickarray,&twobrickmask,&windsource,junkcolors);
						vro_notcpy(brickarray, &twobricksource, &windsource);
					}
					break;
				}
			}
		}
		add_region(work.g_x,work.g_y,work.g_w,work.g_h);
		do_redraw();
	}
	evnt_timer(500,0);

	ani_count = 0;
	paddle_x = 0;
	paddle_y = pad_y_max;
	paddlearray[4] = 0;
	paddlearray[5] = pad_y_max;
	paddlearray[6] = 52;
	paddlearray[7] = paddlearray[5] + pad_ht - 1;

	num_balls = 0;

	if (cheat)
	{
		for (x=0; x<3; x++)
			add_ball(0,pad_y_min - ball_ht,max_xspeed-x,-min_yspeed, TRUE);
	}
	else add_ball(0,pad_y_min - ball_ht,2,2, FALSE);

	mode = BNORMAL;

	for (x=0; x < 63; x++) brickcount[x] = brickmask[ltemp][x];
}

void
add_region(int x,int y,int w,int h)
{
	register GRECT *p;

	/* this should never happen... */
	if (n_redraws >= MAX_ANI) return;

	p = &region[n_redraws];
	p->g_x = x;
	p->g_y = y;
	p->g_w = w;
	p->g_h = h;
	n_redraws++;
}

void
new_game(void)
{
	lives = old_lives = 3;
	score = old_score = 0;
	bonus_life = old_bonus = BONUS;
	pad_y_top = pad_y_min;
	level = 0;
}

void
clear(int x,int y,int w,int h)
{
	int pxy[8];
	
	pxy[0] = pxy[1] = 0;
	pxy[2] = w-1;
	pxy[3] = h-1;
	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = x + w - 1;
	pxy[7] = y + h - 1;

	vro_cpyfm(vdi_handle,(planes>9)?ALL_BLACK:ALL_WHITE,pxy,&pic_buf,&pic_buf);
}

/* Saves colors in global array screen_colortab[] */
void
save_colors(void)
{
	int i;
	int coltab[3];
	
	for (i=0;i<screen_colors;i++)
	{
		vq_color(vdi_handle,i,0,coltab);

		screen_colortab[i].red = coltab[0];
		screen_colortab[i].green = coltab[1];
		screen_colortab[i].blue = coltab[2];			
	}
}

void
reset_colors(void)
{
	int i;
	int coltab[3];

#if OS_DOS
	if( planes == 1 )  return;  /* Looks better */
#endif

	for (i=0;i<screen_colors;i++)
	{
		coltab[0] = screen_colortab[i].red;
		coltab[1] = screen_colortab[i].green;
		coltab[2] = screen_colortab[i].blue;

		vs_color(vdi_handle,i,coltab);
	}
}

/* These 2 would be better stored in the window
	structure.  However I don't have the time
	at the moment if I want to meet the deadline
	I've agreed to. To make this modification.
	
	It would be fairly simple to do.
	
	All one needs to do is create all the windows you
	might want to use at the startup of the program.
	
	Then if the window contains an image.
	Set the colortab for that window to be equal to that
	image.  voila!
	
	*/


void
save_image_colors(void)
{
	int i;
	int coltab[3];

	for (i=0;i<screen_colors;i++)
		{
			vq_color(vdi_handle,i,0,coltab);

			imgcolortab[i].red = coltab[0];
			imgcolortab[i].green = coltab[1];
			imgcolortab[i].blue = coltab[2];			
		}
}
	
void
load_image_colors(void)
{
	int i;
	int coltab[3];

#if OS_DOS
	if( planes == 1 )  return;  /* Looks better */
#endif
	
	for (i=0;i<screen_colors;i++)
	{
		coltab[0] = imgcolortab[i].red;
		coltab[1] = imgcolortab[i].green;
		coltab[2] = imgcolortab[i].blue;
			
		vs_color(vdi_handle,i,coltab);
	}
}

void
save_about_colors(void)
{
	int i;
	int coltab[3];

	for (i=0;i<screen_colors;i++)
	{
		vq_color(vdi_handle,i,0,coltab);

		aboutcolortab[i].red = coltab[0];
		aboutcolortab[i].green = coltab[1];
		aboutcolortab[i].blue = coltab[2];			
	}
}
	
void
load_about_colors(void)
{
	int i;
	int coltab[3];

#if OS_DOS
	if( planes == 1 )  return;  /* Looks better */
#endif

	for (i=0;i<screen_colors;i++)
	{
		coltab[0] = aboutcolortab[i].red;
		coltab[1] = aboutcolortab[i].green;
		coltab[2] = aboutcolortab[i].blue;

		vs_color(vdi_handle,i,coltab);
	}
}

/* waits for a period of time */
void
delay(int period)
{
	evnt_timer(period,0);
}

/********************************************/
/*		open game window					*/
/********************************************/
int 
open_game_window(void)
{
	int i, k;

	if ((win[GAME_WIN].handle=wind_create(W_TYPE,desk.g_x,desk.g_y,max.g_w,max.g_h)) < 0)
		return -1;

	graf_mkstate(&i, &i, &i, &k);
	cheat = (k & 3);

#if OS_DOS
	wind_set(win[GAME_WIN].handle, WF_NAME, LLOWD(title_bar), LHIWD(title_bar), 0,0);
#else
	wind_set(win[GAME_WIN].handle, WF_NAME,title_bar);
#endif
	graf_growbox(desk.g_x,desk.g_y,gl_wbox,gl_hbox,ELTS(old));

	wind_open(win[GAME_WIN].handle,ELTS(old));

	wind_get(win[GAME_WIN].handle,WF_WORKXYWH,ELTR(work));

		win[GAME_WIN].window_obj = (OBJECT *)NULL;
		win[GAME_WIN].title = title_bar;
		win[GAME_WIN].cur_item = -1;
		win[GAME_WIN].text_block = NULL;
		win[GAME_WIN].buf_size = 0;
		win[GAME_WIN].status = 1;
		win[GAME_WIN].edit = 0;
		win[GAME_WIN].type = 0;
		
		win[GAME_WIN].icon_obj = icons_dial;

		wind_get(win[GAME_WIN].handle, WF_CURRXYWH, ELTR(win[GAME_WIN].curr));

	if (remap_pal == 0)
		load_image_colors();
	
	/*if (lives <= 0) */
	new_game();
	restart_level();

	event_kind = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;

	ttimer = timer;

	return 0;
}

