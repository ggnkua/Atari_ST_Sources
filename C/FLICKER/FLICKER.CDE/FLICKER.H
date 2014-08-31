
/* screen format defines */
#define	XMAX	320
#define	YMAX	200
#define COLORS	16
#define BITPLANES 4

#define WORD int
typedef int (*Vector)();

#define NULL 0L

/* stuff for dynamic memory management */
extern WORD *alloc();
#define Alloc_a(type) (type *)alloc(sizeof(type) )
#define Free_a(pt)	mfree(pt, sizeof(*(pt) ) )
extern long cel_mem_alloc;	/* how much memory we got */
extern long mem_free;		/* how much is left */

/* Stuff to handle the various screens of flicker */
#define MAX_SCREENS 128
extern WORD screen_ix, screen_ct;	/* which screen we're on and # of screens */
extern WORD *screens[MAX_SCREENS];
extern WORD *pscreen;			/* points to physical (visible) screen */
extern WORD *bscreen;			/* points to buffer screen for double-buffer */
extern WORD *cscreen;				/* points to the "drawing/display" screen */
									/* cscreen -> pscreen or bscreen */

extern WORD sys_cmap[];			/* software echo of color map */
extern char oppositec[];	/* lookup table for opposite colors */

extern WORD ccolor;		/* the color to draw thing with */
extern WORD filled_flag;	/* do we do fills or outlines? */
extern WORD nozero_flag;	/* zero-suppress in the copies? */
extern WORD degas;			/* load/save pics in degas or neo format? */
extern WORD zoom_flag;		/* fat bits mode? */
extern WORD zoomx, zoomy;	/* offset of zoom */
extern WORD zscale_cursor;	/* adjust mousex mousey to reflect
								zoom position */

extern WORD firstx, firsty;	/* pen-tools use these to place where first
								pendown was */
extern WORD x_0, y_0, x_1, y_1;	/* first and mouse coordinates sorted */

extern WORD white, black, red;	/* closest fit to menu colors, set by
									find_colors() */
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
extern WORD use_brush_cursor;	/* messy flag to see if cursor is cross or
									current brush ... depends on current
									pentool */

extern long get60hz();	/* 60 Hz clock */

struct cel
	{
	WORD xoff, yoff;
	WORD width, height;
	WORD cmap[16];
	WORD *image;
	unsigned WORD image_size;
	WORD *mask;
	};
typedef struct cel Cel;
extern Cel *alloc_cel();
extern Cel *clipping;

struct seq_header
	{
	WORD magic;		/* == 0xfedc */
	WORD version;
	long cel_count;
	char pad[120];
	};
typedef struct seq_header Seq_header;

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
	char pad[66]; /*stuff with zeros for now*/
};

struct degas_head
	{
	WORD res;
	WORD colormap[16];
	};
extern char *get_fname();	/* request file name from user */

/* handy macro to find out how much memory a raster line takes up */
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)<<2)
#define Raster_block(width, height) (Raster_line(width)*height)


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
extern pull_block(), pull_color(), pull_oblock(), pull_text(), pull_brush();

