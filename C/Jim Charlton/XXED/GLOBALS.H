
#ifndef TRUE
#define TRUE		1
#define FALSE		0
#define NULL		0L
#endif 

#define WORKSIZE	1
#define BORDSIZE	0

#define	min(a, b)	((a < b)? a : b)
#define max(a, b)	((a > b)? a : b)

/*
	Each window will have a grafport so that it is easy to maintain 
	drawing environments accross windows.
*/
typedef struct _grafport {
	int		handle;		/*  Virtual workstation handle  					*/
	MFDB	mfdb;		/*  memory definition block for virtual workstation	*/
} grafport;


/*
	Window definition.
*/
typedef struct _windowrec {
	struct _windowrec	*next;		/*  Window link						*/
	int					handle;		/* Window Handle					*/
	int					kind;		/* The windows type					*/
	int					fullsize;	/* In full-screen mode				*/
	int					vslidepos;	/* vertical slider position			*/
	char				title[30];	/* Title of window					*/
	GRECT				box;		/* Window Box dimensions			*/
	GRECT				work;		/* Window content region dimensions	*/
	grafport			graf;		/* Window graphics port definition  */
	int					(*updateproc)(); /* Pointer to update procedure */
/************************************************************************/
/* the following are specific to the program XXED                      */

	struct _linkbuf		*headptr;
	long				startmark;
	long				endmark;
	int					markson;
	int 				xcur;		/* xpos of cursor on screen			*/
	int					ycur;       /* ypos of cursor on screen			*/
	long				topchar;	/* number of char at top left 		*/
	long				flen;		/* length of file in total			*/
	long				position;	/* position of cursor in file		*/
	char				input[2];	/* input buffer						*/
	int					icount;		/* input buffer end pointer			*/
	int					changed;
	int					prot;
/************************************************************************/		
} windowrec;
typedef windowrec *windowptr;


/*
	Declare the GEM specific variables required by the ROM routines.
*/

extern int contrl[12];
extern int intin[256],  ptsin[256];
extern int intout[256], ptsout[256];
extern gl_apid;


/*
	Application Global Variables.
*/
extern OBJECT		*menubar;
extern OBJECT		*dialog2;
extern OBJECT		*dialog1;
extern OBJECT		*dialog3;
extern OBJECT		*dialog4;
extern OBJECT		*dialog5;
extern OBJECT		*dialog6;
extern int			phys_handle1;
extern int			phys_handle2;
extern char			table[600];
extern int			gl_hchar;
extern int			gl_wchar;

#ifdef extern
windowptr	firstwindow = NULL;       /* in MAIN.C these lines used  */
windowptr	thefrontwin = NULL;
#else
extern windowptr	firstwindow;
extern windowptr	thefrontwin;
#endif

/*
	Functions
*/
extern char 		*malloc();
extern windowptr	new_window();
extern windowptr	frontwindow();
extern windowptr	findwindowptr();

/* globals for HEXED      */

#define BLOCKSIZE 4096
typedef struct  _linkbuf {
	struct  _linkbuf	*next;
	char			 	block[BLOCKSIZE];
	long				inuse;
} linkbuf;
typedef linkbuf *linkbufptr; 

extern linkbufptr addmember();
extern linkbufptr add_cutmem();
extern int read_file();
extern long calc_pos();

#ifdef extern
	char	fsize_str[32]={" File size:"};
	char	pos_str[32]={" Position:"};
	char	s_str[32];
	char	r_str[32];
	char	dr_str[32]={""};
	int	xoffset[33]={0,2,6,8,12,14,18,20,24,26,30,32,36,38,42,44,
					 48,50,54,56,60,62,66,68,72,74,78,80,84,86,90,92,96};
	char	lastpath[64];
	char	fs_insel[40];
	char	fs_inpath[40];
	char	*cutbuffer = NULL;
	long	cutlength = 0L;
	int		ins	= FALSE;
	int		inhex = TRUE;
	int		partial = FALSE;
	int		draw_flag = FALSE;
	int		slid_flag = FALSE;
	int		arro_flag = FALSE;
#else
extern		char	fsize_str[];
extern		char	pos_str[];
extern		char	s_str[];
extern		char	r_str[];
extern		char	dr_str[];
extern		int		ins;
extern		int		inhex;
extern		int		partial;
extern		int		draw_flag;
extern		int		slid_flag;
extern		int		arro_flag;
extern		char	*cutbuffer;
extern		long	cutlength;		/* markbuf end pointer			*/
extern 		int 	xoffset[];
extern 		char 	lastpath[];
extern		char	fs_insel[];
extern		char	fs_inpath[];
#endif
