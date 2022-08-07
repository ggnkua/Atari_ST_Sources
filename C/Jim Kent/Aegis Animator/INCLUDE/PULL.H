
/* These are macros on the mouse buttons */
#define mouse_x virtual.curx
#define mouse_y virtual.cury

/* handy macro to find out how much memory a raster line takes up */
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)<<2)
#define Raster_block(width, height) (Raster_line(width)*(height))


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
extern pull_block(), pull_color(), pull_oblock(), pull_text();

/* some formatting constants */
#define COLWIDTH 16
#define COLHEIGHT 16
#define CH_WIDTH 8
#define CH_HEIGHT 9
