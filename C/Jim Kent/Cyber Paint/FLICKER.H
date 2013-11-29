
#define WORD int
#define UWORD unsigned int
#define NULL 0L
typedef int (*Vector)();
extern long pt_to_long();

/* screen format defines */
#define	XMAX	320
#define	YMAX	200
#define COLORS	16
#define BITPLANES 4
#define CH_WIDTH 8
#define CH_HEIGHT 9
#define string_width(s) (strlen(s)*CH_WIDTH)

/* stuff for GEM */
extern char gemctable[];	/* lookup table to go from ST to GEM colors */
extern WORD handle;

extern char bap_line_buf[];	/* a line buffer for byte-a-pixeling */

/* stuff for dynamic memory management */
extern WORD *askmem(), *laskmem(), *begmem(), *lbegmem();
extern WORD *alloc_biggest_chunk();
extern long size_biggest_chunk();
#define Alloc_a(type) (type *)askmem(sizeof(type) )
#define Free_a(pt)	freemem(pt)
#define Array_els(arr) (sizeof(arr)/sizeof(arr[0]))

extern long cel_mem_alloc;	/* how much memory we got */
extern long mem_free;		/* how much is left */

struct mblock	/* structure to keep track of free memory */
	{
	struct mblock *next;
	long size;
	};


/* Stuff to handle the various screens of flicker */
#define MAX_SCREENS (1024*2)
extern WORD screen_ix, screen_ct;	/* which screen we're on and # of screens */
extern WORD *ram_screens[];
extern WORD *ram_dlt;
extern char dirty_frame, dirty_file;
extern WORD *ram_dlt_start;
extern WORD *pscreen;			/* points to physical (visible) screen */
extern WORD *bscreen;			/* points to buffer screen for double-buffer */
extern WORD *uscreen;		/* undo screen */
extern WORD *start_screen;		/* first screen of dlt */
extern WORD *end_screen;		/* last screen of dlt */
extern WORD *next_screen;		/* next screen of dlt */
extern WORD *prev_screen;		/* previous screen of dlt */
extern WORD *cscreen;				/* points to the "drawing/display" screen */
									/* cscreen -> pscreen or bscreen */

/* stuff to keep track of what file's selected */
extern char *title, title_buf[];
/* stuff to implement "virtual" windowing on a larger file than can fit
   into memory */
extern WORD vrd_start_frame;
extern WORD vrd_end_frame;
extern char rd_name[], patch_name[];
extern WORD rd_frames;
extern WORD rd_more;
extern WORD rd_abort;
extern long rd_alloc;
extern long rd_count;


extern WORD sys_cmap[];			/* software echo of color map */
extern WORD init_cmap[];	/* initial flicker colormap */
extern char oppositec[];	/* lookup table for opposite colors */

extern WORD ccolor;		/* the color to draw thing with */
extern WORD nozero_flag;	/* zero-suppress in the copies? */
extern WORD filled_flag;	/* do we do fills or outlines? */
extern WORD connect_mode;	/* for bubbles and rays and things */
#define DISTINCT		0
#define CONNECTED	1
#define CONCENTRIC	2
extern WORD degas;			/* load/save pics in degas or neo format? */
extern WORD zoom_flag;		/* fat bits mode? */
extern WORD zoomx, zoomy;	/* offset of zoom */
extern WORD zscale_cursor;	/* adjust mousex mousey to reflect
								zoom position */
extern WORD cycle_draw;		/* bump colors each time round? */
extern WORD select_mode;
extern WORD tween_mode;

extern WORD firstx, firsty;	/* pen-tools use these to place where first
								pendown was */
extern WORD x_0, y_0, x_1, y_1;	/* first and mouse coordinates sorted */
extern WORD start_frame, stop_frame; /*  beginning and end of time segment */
extern WORD range_frames;	/* # of frames in time segment */

/* convert rgb in range 0-7 to atari color register word format */
#define rgb_to_abs(r, g, b)	(((r)<<8) + ((g)<<4) + (b) )

/* closest fit to menu colors, set by find_colors() */
extern WORD white, black, red;	

extern WORD swhite, sblack, sred;	/* system menu colors (1, 2, and 3 for now*/

extern WORD mouse_on;	/* used by check input to record if mouse is onscreen 
							or not */

/*  These are globals that contain the input state */
extern WORD mouse_button, omouse_button;  /* button state and last state */
extern WORD mouse_x, mouse_y;	/* the xy position of mouse */
extern WORD lastx, lasty;	/* last mouse_x, mouse_y */
extern WORD mouse_moved;	/* new mouse input? */
extern WORD key_hit;			/* 1 if keyboard hit, 0 otherwise */
extern long key_in;				/* What the extended character code 
								   for when key_hit = 1 */

/* These are macros on the mouse buttons */
#define PDN (mouse_button & 0x100)
#define RDN (mouse_button & 0x200)
#define EDN (mouse_button & 0x300)
#define PJSTDN ( (mouse_button & 0x100) && !(omouse_button & 0x100) )
#define RJSTDN ( (mouse_button & 0x200) && !(omouse_button & 0x200) )


extern WORD *brushes[];	/* array of pointers to all our brushes */
extern WORD brush_ix;	/* index of brush, 0 = none */
extern WORD text_cursor, fill_cursor;	
extern WORD use_brush_cursor;	/* messy flag to see if cursor is cross or
									current brush ... depends on current
									pentool */

extern long get60hz();	/* 60 Hz clock */
extern long time_peek();	/* 200 Hz clock */
struct unp_color	/* unpacked color */
	{
	WORD r, g, b;
	WORD pad;
	};
typedef struct unp_color Unp_color;
/* the color map re-arranged a bit for faster computing */
extern Unp_color unp_colors[COLORS];

/* the 512 colors possible in map, and which of the 16 in current map they're
   closest to */
extern char clookup[];


struct cel
	{
	WORD xoff, yoff;
	WORD width, height;
	WORD cmap[16];
	WORD *image;
	long image_size;
	WORD *mask;
	};
typedef struct cel Cel;
extern Cel screen_cel;
extern Cel *init_cel(), *alloc_cel(), *clone_cel();
extern Cel *stretch_byte_cel();	/* byte_cel in cel out stretched a bit */
extern Cel *rot_byte_cel();		/* return a rotated byte cel as a cel */
extern Cel *load_first_frame();
extern Cel *clipping;

struct byte_cel
	{
	WORD width, height;
	WORD xoff, yoff;
	WORD line_bytes;
	long	image_size;
	unsigned char *image;
	WORD cmap[16];
	};
typedef struct byte_cel Byte_cel;
extern Byte_cel *cel_to_byte();

struct seq_header
	{
	WORD magic;		/* == 0xfedc Flicker 0xfedb Cyber Paint */
	WORD version;
	long cel_count;
	WORD speed;
	char resolution; /* 0 lores, 1 medium, 2 hires */
	char flags;
	char reserved[52]; /* extra space all for me */
	char pad[64]; /* extra space I'm not claiming yet */
	};
typedef struct seq_header Seq_header;

/* some bits for seq_header.flags */
#define SEQ_STEREO	1

struct neo_head
{
	int type;  /* 0 for neo, 1 for programmed pictures, 2 for cels? */
	int resolution; /*0 lores, 1 medium, 2 hires*/
	int colormap[16];
	char filename[8+1+3];
	int ramp_seg; /*hibit active, bits 0-3 left arrow, 4-7 right arrow*/
	char ramp_active;  /*hi bit set if actively cycled*/
	char ramp_speed;  /*60hz ticks between cycles*/
	int slide_time;  /*60hz ticks until next picture*/
	int xoff, yoff;  /*upper left corner of cel*/
	int width, height; /*dimensions of cel*/
	char	op;		/* xor this one, copy it? */
	char	compress;	/* compressed? */
	long	data_size;		/* size of data */
	char reserved[30];	/* Please leave this zero, I may expand later */
	char pad[30]; /* You can put some extra info here if you like */
};

/* defines for neo_head.op */
#define NEO_COPY	0
#define NEO_XOR		1

/* defines for neo_head.compress */
#define NEO_UNCOMPRESSED	0
#define NEO_CCOLUMNS	1

struct degas_head
	{
	WORD res;
	WORD colormap[16];
	};
extern char *get_fname();	/* request file name from user */

/* handy macro to find out how much memory a raster line takes up */
#define Mask_line(width) ((((width)+15)>>3)&0xfffe)
#define Mask_block(width, height) (Mask_line(width)*(height))
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)<<2)
#define Raster_block(width, height) (Raster_line(width)*(height))
#define Pixels16(width)	(((width)+15)>>4)
#define copy_line(s, d) copy_lots((s), (d), Raster_line(320L) )


#define SCREEN_LBYTES Raster_line(XMAX)
#define SCREEN_LWORDS (SCREEN_LBYTES/2)


/* This is the tree structure that is the core of the pull-down system */
struct pull
	{
	struct pull *next;
	WORD xoff, yoff, width, height;
	struct pull *children;
	char *data;  /* actually just some old pointer, must agree with see function
				 */
	Vector see;
	};
typedef struct pull Pull;

/* some defines to make it easier to edit skeletal pull data files... */
#define NONEXT NULL
#define NOCHILD NULL
#define NODATA NULL

/*some functions to put into pull->see */
extern pull_block(), pull_color(), pull_oblock(), 
	spull_text(), pull_text(), pull_brush();

/* the amount of memory (estimated) system reserves for pull-downs and other
   stuff ... won't alloc frames if less than this */
#define PULL_MEM	8000

struct cursor 
    {
    WORD type;
    UWORD *image;
    WORD width,height;
    WORD xhot, yhot;
    };

extern Pull *cur_pull;
extern WORD live_top, live_lines;

struct rectangle
	{
	WORD MinX, MinY;
	WORD MaxX, MaxY;
	};

struct point
	{
	WORD x, y;
	};
typedef struct point Point;

struct vertex
	{
	WORD x, y, z;
	};
typedef struct vertex Vertex;

#define GROUND_Z 512
#define BIG_SHORT	0x7fff
#define BIG_INT		0x7fff
#define BIG_LONG	0x7fffffff
#define SCALE_ONE 	(1<<14)
#define GROUND_Z	512
#define TWO_PI		1024

/* structure to save context of Super menu when going from first to
   regular mode and back */
struct super_settings
	{
	WORD movex, movey, movez;
	WORD cenx, ceny, cenz;
	WORD mul, div;
	WORD xax, yax, zax;
	WORD turns, degrees;
	};
typedef struct super_settings Super_settings;

#define ADO_MAGIC 0xAD0
struct ado_settings
	{
	WORD magic; /* == $AD0 */
	Super_settings first, motion;
	WORD path_points;
	};
/* used in rrotate.c */

struct min_max
	{
	WORD xmin, ymin;
	WORD xmax, ymax;
	WORD ymin_ix;
	WORD ymax_ix;
	};
extern struct min_max minmax;


extern long desttime; /* how much to wait for next frame in replay */

extern WORD normal_over_under;	/* tells how to load in a seq file */
#define NOU_NORMAL 0
#define NOU_OVER   1
#define NOU_UNDER  2
#define NOU_SPLICE 3
#define NOU_MASK   4
#define NOU_IMASK  5
#define NOU_MERGE  6

extern WORD save_file_type;
#define SEQ 0
#define NEO 1
#define CEL 2
#define COL 3
#define STR 4
#define DLT 5
#define PI1 6
#define PC1 7
#define BL1 8
#define ADO 9

#define NOMEM	1
#define NOOPEN	2
#define TRUNCATED 3
#define BADFILE 4

struct ops_etc
	{
	char op;
	char compress;
	long size;
	WORD xoff, yoff;
	WORD width, height;
	};
typedef struct ops_etc Ops_etc;

extern WORD *make_lit_deltas();
extern long calc_lit_dlt_size();
extern long calc_compress_length();

extern WORD empty_size;

struct stripe
	{
	WORD colors[3];
	WORD height;
	};
typedef struct stripe Stripe;

extern Stripe *startclist;
extern Stripe stripe1, stripe2, stripe3, stripe4, stripe5;

extern long vbcount;
