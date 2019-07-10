/* header file with various definitions
 */

/* this one should really be in stdio.h ...
 */

#ifndef NULL
#define NULL ((char *) 0)
#endif

#define TRUE 1
#define FALSE 0

/* constants
 */

#define ALTINDICATOR '\05'
#define MAXFUNCLEN 41  /* Maximum length of function key string */
#define BREAK_TICKS 20 /* length of break in clock() ticks (5ms * 20 = .1s) */
#define MAXSCROLLED 8
#define MAX_WIND 8
#define NFSTRINGS 42			/* number of function keys */
#define WI_WITHSLD (SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define WI_NOSLD (NAME|MOVER|CLOSER|FULLER)


#define WI_ROWS 80
#define WI_LINES 24
#define WI_WCHAR 8
#define WI_HCHAR 16
#define WI_WPIX (WI_ROWS*WI_WCHAR+16)
#define WI_WWORDS ((WI_WPIX+15)/16)
#define WI_HPIX (WI_LINES*WI_HCHAR)
#define WI_SIZE ((long)WI_WWORDS*WI_HPIX*2)
#define XON '\021'
#define XOFF '\023'

#define xmitcmd(x)	{ Bconout(1, IAC); Bconout(1, CB_DIR_MTOH|x); }

#define MINMAX(x, y, z) ( x<y ? y : (x>z ? z :x) )

#define HASHBITS 9		/* number of bits of hash for character lookup*/

#define FM_INVERT 12		/* logic parameter to copy_fm */
#define FM_COPY    3		/* copy source to dest	*/

#define X0 1
#define Y0 1

/* emulation FSM states
 */

#define S_NORMAL	0
#define S_ESC		1
#define S_ESC1		2
#define S_ESC2		3
#define S_ESC3		4
#define S_STATUS	5
#define S_ESCA		6

#define min(a,b) ( a < b ? a : b )
#define max(a,b) ( a > b ? a : b )
/* data types used
 */

typedef struct mfdb {
  short *ptr;			/* ptr to memory holding the image */
  short wpix;			/* width in pixels */
  short hpix;			/* height in pixels */
  short wwords;			/* width in words */
  short format;			/* 0 for machine-dependent */
  short planes;			/* 1 for hires screen */
} MFDB;

typedef struct {
  unsigned char h_t[1<<HASHBITS];	/* hash table */
  struct {
    char h_try;				/* try this character next */
    char h_next;			/* index of next entry in table */
  } h_colision[128];			/* colision lists formed here */
} HTBL;

typedef struct fnt {
  int inc_x, inc_y;		/* real size of one char */
  int def_win_x, def_win_y;	/* default window size in chars for this font */
  HTBL f_hash;			/* hash table for this font */
  char f_data[2048];		/* character data */
} FNT;

typedef struct wi_str {
  int port;			/* the UW port identifier */
  int fulled,used;		/* flags */
  int inverse;			/* inverse chars */
  int insmode;			/* insert mode on */
  int curstate;			/* state of the cursor */
  int x, y, w, h;		/* work area on screen */
  int px, py, pw, ph;		/* previous location of entire window */
  int x_off, y_off;		/* offset for visible part */
  int px_off, py_off;		/* previous offset */
  int m_off;			/* memory offset */
  int wi_w, wi_h;		/* max w,h */
  int cur_x, cur_y;		/* current cursor position */
  int top_y;			/* position of top of circular window buffer */
  int state;			/* state for the emulation FSM */
  FNT *font;			/* the font in use */
  MFDB wi_mf;			/* memory form for this window */
  char name[80];		/* name of this window */
  char nuname[80];		/* new name under construction */
  char dname[80];		/* name actually displayed (w/ flags, etc.) */
				/* (dname is set in w_rename) */
  int nuptr;			/* curr. len of new name or parameter assembly*/
  int ptr_status;		/* status of print loging for window */
  int x_chrs, y_chrs;		/* size of terminal emulation */
  int top_age;			/* number of windows topped after this window */
  int wi_style;			/* style of window (see WI_*SLD) */
  char wi_fpath[80];		/* log file path */
  char wi_fname[20];		/* log file name */
  FILE *wi_lfd;			/* log file descriptor */
  int kerm_act;			/* is this a kermit window? */
  int w_local;			/* is this a local window? */
} WI_STR;

#define LOG_BOTOM	1	/* print incoming characters */
#define LOG_TOP		2	/* print lines which scroll off screen top */
#define LOG_NONE	0	/* no printer output for this window */

typedef struct gemfont {
	short	ft_id;
	short	ft_psize;
	char	ft_name[32];
	short	ft_l_ade;
	short	ft_h_ade;
	short	ft_topl;
	short	ft_ascl;
	short	ft_halfl;
	short	ft_descl;
	short	ft_botl;
	short	ft_chwidth;
	short	ft_clwidth;
	short	ft_lf_off;
	short	ft_rt_off;
	short	ft_thick;
	short	ft_ul;
	short	ft_light;
	short	ft_skew;
	short	ft_flags;
	short	*ft_h_off;
	short	*ft_c_off;
	short	*ft_data;
	short	ft_fwidth;
	short	ft_fheight;
	struct gemfont *ft_next;
} GEMFONT;

typedef char FUNCSTRING[MAXFUNCLEN];

