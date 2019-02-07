
#define WORD int
#define UWORD unsigned int
#define NULL 0L
typedef int (*Vector)();
extern long pt_to_long();

/* screen format defines */
#define	XMAX	640
#define	YMAX	200
#define COLORS	4
#define BITPLANES 2
#define CH_WIDTH 8
#define CH_HEIGHT 9
#define string_width(s) (strlen(s)*CH_WIDTH)

/* stuff for GEM */
extern char gemctable[];	/* lookup table to go from ST to GEM colors */
extern WORD handle;


/* stuff for dynamic memory management */
extern void *askmem(), *laskmem(), *begmem(), *begzeros(),*lbegmem();
extern char *clone_string();
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
extern char dirty_file;
extern WORD *pscreen;			/* points to physical (visible) screen */
extern WORD *cscreen;				/* points to the "drawing/display" screen */
extern WORD *bscreen;		/* points to a screen sized buffer */

/* stuff to keep track of what file's selected */
extern char *title, title_buf[];
/* stuff to implement "virtual" windowing on a larger file than can fit
   into memory */

extern WORD sys_cmap[];			/* software echo of color map */
extern WORD white, black, red, green;

extern WORD firstx, firsty;	/* pen-tools use these to place where first
								pendown was */
extern WORD x_0, y_0, x_1, y_1;	/* first and mouse coordinates sorted */

/* convert rgb in range 0-7 to atari color register word format */
#define rgb_to_abs(r, g, b)	(((r)<<8) + ((g)<<4) + (b) )

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


extern long get60hz();	/* 60 Hz clock */
extern long time_peek();	/* 200 Hz clock */

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
extern char tbuf[];

/* handy macro's to find out how much memory a raster line takes up */
#define Mask_line(width) ((((width)+15)>>3)&0xfffe)
#define Mask_block(width, height) (Mask_line(width)*(height))
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)*BITPLANES)
#define Raster_block(width, height) (Raster_line(width)*(height))
#define LRaster_line(width) (((((width)+15)>>3)&0xfffe)*4)
#define LRaster_block(width, height) (LRaster_line(width)*(height))


struct cursor 
    {
    WORD type;
    UWORD *image;
    WORD width,height;
    WORD xhot, yhot;
    };

struct rectangle
	{
	WORD MinX, MinY;
	WORD MaxX, MaxY;
	};

#define BIG_SHORT	0x7fff
#define BIG_INT		0x7fff
#define BIG_LONG	0x7fffffff
#define SCALE_ONE 	(1<<14)

#define NOMEM	1
#define NOOPEN	2
#define TRUNCATED 3
#define BADFILE 4

struct seq_lib 
	{
	WORD frame_count;
	WORD frames_read;
	WORD flags;
	WORD *first_frame;
	WORD **deltas;
	};


#define TR_ERASE 0
#define TR_SEQ	1
#define	TR_SPL	2
#define TR_NONE	3

struct tlib
	{
	struct tlib *next;
	char *name;
	WORD type;
	long samples;
	WORD default_speed;
	WORD links;
	long bytes;
	void *image;
	};

struct track
	{
	WORD type;
	WORD start;
	long duration;
	WORD speed;
	WORD loops;
	long samples;
	char name[14];
	struct tlib *lib;
	};

#define TRACKS 256
extern struct track track_buf[TRACKS];
extern struct track *tracks[TRACKS];
extern int track_ix;
extern int track_offset;


extern int time_ticks;
extern int video_ticks;
extern int sound_ticks;
#define MAX_TICKS (3600*5+60*59+59)

/* some defines to help format the main track mixing screen */
#define TRACKS_SEEN 14
#define TRACK_YOFF 32
#define TRACK_HEIGHT 12
#define NAME_END	(14*CH_WIDTH)
#define START_END	(21*CH_WIDTH)
#define STOP_END	(28*CH_WIDTH)

#define TBAR_START	(STOP_END+3)
#define TBAR_WIDTH  (XMAX-TBAR_START-3)
