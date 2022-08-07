
#define	XMIN	0
#define	YMIN	0
#define	XMAX	320
#define	YMAX	200
#define HEIGHT (YMAX - YMIN)
#define WIDTH (XMAX - XMIN)
#define BITPLANES 4
#define S_WIDTH 22
#define S_HEIGHT 16
#define CHAR_WIDTH 6
#define CHAR_HEIGHT 10
#define M_WIDTH (S_WIDTH*9)
#define M_HEIGHT (S_HEIGHT*5)


#define VRES	1
#define VXMAX (XMAX*VRES)
#define VYMAX (YMAX*VRES)
/* keeping a few extra bits to the right for better arithmetic */

#define MARGIN (1)

#define COL_XDIV 16
#define COL_YDIV 1
/*these are used by the color display function in the menu */

#define SWX (XMAX/4)
#define SWY (YMAX/4)
/*dimensions of story*/

#define SPX ((XMAX/4)/4)
#define SPY ((YMAX/4)/4)
/*space between stories*/

