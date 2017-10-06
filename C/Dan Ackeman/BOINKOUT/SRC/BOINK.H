/******* boink.h ****************
*								*
*  Based on boinkout.h			*
*  by Samuel Streeper 1990		*
*								*
* ammended Dan Ackerman 1999    *
*********************************/

/* We were using these in every file that called BOINK.H */
#include <aes.h>
#include <vdi.h>

#include "bconfig.h"
#include "avproto.h"

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef min
#define min(a, b)             ((a) < (b) ? (a) : (b))
#endif

#ifndef max
#define max(a, b)             ((a) > (b) ? (a) : (b))
#endif

typedef struct score_entry{
	char name[14];
	int  level;
	long  score;	/* MAR -- was int */
 	} SCORE_ENTRY;

typedef struct { int x,y,w,h;	} RECT;

typedef struct {
	int id;
	int (*ani_funct)();
	int x,y;
	int xspeed, yspeed;
	int array[8];
	int l,t,r,b;		/* redraw region */
	int spin_dir;
	int ball_ht, ball_wid;
	int half_ht, half_wid;
	int ball_num;
	} BALL_STRUCT;

/******* ball id's *********/
#define UNUSED 0
#define BALL 1
#define FUJI 2
#define EYE 3

typedef struct {
	int (*ani_funct)(int ax, int ay, int aframe);	/* ptr to the function to do the animation */
	int x,y;				/* position of the animation */
	int frame;				/* the frame number for this animation */
	} ANI_STRUCT;

typedef struct
{
   int  red;        /* red intensity in per mille */
   int  green;      /* green intensity in per mille */
   int  blue;       /* blue intensity in per mille */
} RGB1000;

/*
 * This is the sample list definition. It consists of a doubly linked
 * list of entries containing the samples which are available in the
 * current sample directory.
 *
 * I'm just using it for sample storage and info
 */
typedef struct
{
	char name[128];			/* filename of sample in sample directory */

	struct
	{
		long length;			/* length of sample */
		short rate;				/* sample replay 'rate' */
		short stereo;			/* Is the sample stereo */
		char name[128];			/* 128 character name - 0 padded */
		short resolution;		/* 16 bit or 8 bit */
		short *buffer_loc;		/* location of buffer */
	} h;						/* extracted from file header */
	char zero;					/* a zero since h.name is not guaranteed */
								/* null terminated. */
} samp_list;

#define MAX_BALLS 12
#define MAX_ANI 60

#define WIDTH 440+13
#define HEIGHT 362

#define NO_WINDOW (-1)

#define MIN_WIDTH  (113)
#define MIN_HEIGHT (2*gl_hbox + ball_ht + 1)

#define BONUS 500

#define BNORMAL 3
#define BLACKMODE 15

#define MAX_WINDOWS 	6 /* This is how many win_info structs we are using */
#define GAME_WIN 		0
#define ABOUT_WIN 		1
#define SCORE_WIN 		2
#define LOADING_WIN 	3
#define JUMP_WIN		4
#define OBJCOLOR_WIN	5


#define GLOBAL    0x0020
#define ALLOCMODE 3|GLOBAL

/*#define LEVELS 36*/
extern int file_levels;

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

#define 	MagX_cookie		0x4D616758
#define	AES_single	0
#define	AES_MagiC	1
#define	AES_Geneva	2
#define	AES_MTOS	3
#define	AES_nAES	4

#define	_cookies	((long **) 0x5A0L)
 
typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;

extern int	aes_id;		/* our applications id */
extern short av_id;     /* Is there an AV_ server ? */
extern int planes;  	/* Number of physical planes on the screen */
extern MFDB tit_buf;
extern MFDB screen_fdb;
extern MFDB bricksource, permbricksource, fujisource, fmasksource;
extern MFDB eyesource, twobricksource,magicbricksource;
extern MFDB permbrickmask, twobrickmask, nbrickmask, eyemask;

extern OBJECT *about_dial,*menu_ptr,*timing_dial,*highscore_dial,
				*scorelist_dial,*loading_dial,*icons_dial,*jump_dial,
				*objcolor_dial;
extern char *alert_noscore, *alert_cantcreate, *alert_cantfind, *alert_invalid;

extern char title_bar[];

extern GRECT desk;
extern GRECT max;
extern GRECT work;
extern int timer;

extern char spath[PATH_MAX], name[FILENAME_MAX];
extern char score_file[FILENAME_MAX];
extern struct score_entry scores[10];

extern int junkcolors[2];
extern int sound_switch;
extern int vdi_handle;			/* virtual workstation handle */
extern int screen_colors;		/* number o pens the screen has */

extern short vditodev8[];
extern short vditodev4[];
extern short vditodev2[];
extern int remap_pal;  /* If this is off the screen colors will be modified by window */

extern char	*va_helpbuf;

extern RGB1000 screen_colortab[256]; /* used to save colors */

/*  Some extra .H files that need the above.
	This should pretty much clean up the source code on this front
	*/
#include "boinkout.h"
#include "wins.h"
#include "bo_sound.h"

/* In BOINKOUT.C */
extern void add_region(int x,int y,int w,int h);
extern void bsound(int pitch);
extern void do_redraw(void);
extern void restart_level(void);
extern void save_colors(void);
extern void reset_colors(void);
extern void save_image_colors(void);
extern void load_image_colors(void);
extern void save_about_colors(void);
extern void load_about_colors(void);
extern void do_chipsound(int *snd);
extern void open_objcolors(void);
extern void high_score(void);
extern int send_message(int msg[8]);
extern void get_high_name(int x);
extern int redraw_objcolors(void);

extern int jump_drive(int which_obj);
extern int objcolors_drive(int which_obj);

/* In BOUT2.C */
extern void new_ball(void);
extern void vro_notcpy(int *pxy, MFDB *source, MFDB *dest);

/* In BOUT4.C */
extern void cont_level(void);
extern void magic(int i);
extern void kill_ball(int i);
extern void add_ball(int x,int y,int xspeed,int yspeed,int allow_fuji);
extern void show_score(void);
extern void show_lives(void);
extern void show_level(void);
extern void clear_areas(void);
extern void fast_redraw(void);
extern void add_difficulty(void);

/* In BO_SOUND.C */
extern int sound_init(void);
extern int sound_play(int num);
extern int sound_exit(void);

/* In DIALOGS.C */
extern int do_scorelist(void);
extern int do_title(void);
extern int do_objcolorsdial(void);
extern int do_jumpdial(void);
extern int do_loading(void);

/* In XIMGLOAD.C */
extern void img_load(MFDB *image, char *file);
extern int fix_image(MFDB *image, int color);
extern int color_square( int img_handle, int color, int x, int y, int w );

/* In WINDOW.C */
extern int new_window(OBJECT *tree, const char *title, int type);
extern int do_wind_redraw(int wh, GRECT *p);
extern int get_wininfo_from_handle(int w_hand);
extern int get_topwindow(int window);

/* In FILEIO.C */
extern long read_highscore(void);
extern long write_score(void);
extern long create_file(char *file_to_make);
extern long write_cfg_file(char *file_to_read);
extern long read_cfg_file(char *file_to_read);
extern long read_level_file(char *file_to_read);

/* In EXTRAS.C */
extern int identify_AES(void);
extern void iconify(int w_info,GRECT *new_size);
/*extern void iconify(int w_info,int x,int y,int w,int h);*/
extern void un_iconify(int w_info,GRECT *new_size);
/*extern void un_iconify(int w_info,int x,int y,int w,int h);*/
extern void set_tedinfo(OBJECT *tree,int obj,char *source);
extern void get_tedinfo(OBJECT *tree,int obj,char *dest);

extern int send_extmessage(int extapp, int msg0, int msg2, int msg3, int msg4, int msg5, int msg6, int msg7);

extern void paste_text(int w_info);
extern void copy_paste(int w_info);

#if !GL_RCINTER
extern int rc_intersect( GRECT *r1, GRECT *r2 );
#endif

/* in AVFUNC.C */
extern void do_help(char *pattern);
extern int send_vastart(char *path, char *cmdline);
extern short get_avserver(void);
extern void send_avprot(void);
extern void send_avexit(void);

/* in external.c */
extern int run_web_browser(char *temp_file);