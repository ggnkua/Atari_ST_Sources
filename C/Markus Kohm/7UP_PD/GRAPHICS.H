/*
		GRAPHICS.H

		(c) 1992 Pure Software GmbH
*/


#ifndef __GRAPHX_DEF_
#define __GRAPHX_DEF_

enum graphics_errors
{
	grOk				=   0,
	grNoInitGraph		=  -1,
	grNotDetected		=  -2,
	grFileNotFound		=  -3,
	grInvalidDriver		=  -4,
	grNoLoadMem			=  -5,
	grNoScanMem			=  -6,
	grNoFloodMem		=  -7,
	grFontNotFound		=  -8,
	grNoFontMem			=  -9,
	grInvalidMode		= -10,
	grError				= -11,
	grIOerror			= -12,
	grInvalidFont		= -13,
	grInvalidFontNum	= -14,
	grInvalidVersion	= -18
};

enum graphics_drivers
{
	DETECT,
	CURRENT_DRIVER		= -1,
	CGA,
	MCGA,
	EGA,
	EGA64,
	EGAMONO,
	IBM8514,
	HERCMONO,
	ATT400,
	VGA,
	PC3270,
	VDI					= 256
};

enum graphics_modes
{
	CGAC0				= 0,
	CGAC1				= 1,
	CGAC2				= 2,
	CGAC3				= 3,
	CGAHI				= 4,
	MCGAC0				= 0,
	MCGAC1				= 1,
	MCGAC2				= 2,
	MCGAC3				= 3,
	MCGAMED				= 4,
	MCGAHI				= 5,
	EGALO				= 0,
	EGAHI				= 1,
	EGA64LO				= 0,
	EGA64HI				= 1,
	EGAMONOHI			= 0,
	HERCMONOHI			= 0,
	ATT400C0			= 0,
	ATT400C1			= 1,
	ATT400C2			= 2,
	ATT400C3			= 3,
	ATT400MED			= 4,
	ATT400HI			= 5,
	VGALO				= 0,
	VGAMED				= 1,
	VGAHI				= 2,
	PC3270HI			= 0,
	IBM8514LO			= 0,
	IBM8514HI			= 1,
	VDIMODE				= 0
};

#ifndef __COLORS
#define __COLORS

enum COLORS
{
	BLACK,
	BLUE,
	GREEN,
	CYAN,
	RED,
	MAGENTA,
	BROWN,
	LIGHTGRAY,
	DARKGRAY,
	LIGHTBLUE,
	LIGHTGREEN,
	LIGHTCYAN,
	LIGHTRED,
	LIGHTMAGENTA,
	YELLOW,
	WHITE
};

#endif

enum CGA_COLORS
{
	CGA_GREEN			= 2,
	CGA_CYAN			= 3,
	CGA_RED				= 4,
	CGA_MAGENTA			= 5,
	CGA_BROWN			= 6,
	CGA_LIGHTGRAY		= 7,
	CGA_LIGHTGREEN		= 10,
	CGA_LIGHTCYAN		= 11,
	CGA_LIGHTRED		= 12,
	CGA_LIGHTMAGENTA	= 13,
	CGA_YELLOW			= 14,
	CGA_WHITE			= 15
};

enum EGA_COLORS
{
	EGA_BLACK			= 0,
	EGA_BLUE			= 1,
	EGA_GREEN			= 2,
	EGA_CYAN			= 3,
	EGA_RED				= 4,
	EGA_MAGENTA			= 5,
	EGA_BROWN			= 6,
	EGA_LIGHTGRAY		= 7,
	EGA_DARKGRAY		= 8,
	EGA_LIGHTBLUE		= 9,
	EGA_LIGHTGREEN		= 10,
	EGA_LIGHTCYAN		= 11,
	EGA_LIGHTRED		= 12,
	EGA_LIGHTMAGENTA	= 13,
	EGA_YELLOW			= 14,
	EGA_WHITE			= 15
};

enum line_styles
{
	SOLID_LINE		= 0,
	DOTTED_LINE		= 1,
	CENTER_LINE		= 2,
	DASHED_LINE		= 3,
	USERBIT_LINE	= 4
};

enum line_widths
{
	NORM_WIDTH		= 1,
	THICK_WIDTH		= 3
};


enum font_names
{
	DEFAULT_FONT	= 0,
	TRIPLEX_FONT	= 1,
	SMALL_FONT		= 2,
	SANS_SERIF_FONT	= 3,
	GOTHIC_FONT		= 4
};

#define HORIZ_DIR		0
#define VERT_DIR		1

#define USER_CHAR_SIZE	0

enum fill_patterns
{
	EMPTY_FILL,
	SOLID_FILL,
	LINE_FILL,
	LTSLASH_FILL,
	SLASH_FILL,
	BKSLASH_FILL,
	LTBKSLASH_FILL,
	HATCH_FILL,
	XHATCH_FILL,
	INTERLEAVE_FILL,
	WIDE_DOT_FILL,
	CLOSE_DOT_FILL,
	USER_FILL
};

enum putimage_ops
{
	COPY_PUT,
	XOR_PUT,
	OR_PUT,
	AND_PUT,
	NOT_PUT
};

enum text_just
{
	LEFT_TEXT		= 0,
	CENTER_TEXT		= 1,
	RIGHT_TEXT		= 2,
	BOTTOM_TEXT		= 0,
	TOP_TEXT		= 2
};

#define MAXCOLORS		15

struct palettetype
{
	unsigned char	size;
	signed char		colors[MAXCOLORS+1];
};

struct linesettingstype
{
	int			linestyle;
	unsigned	upattern;
	int			thickness;
};

struct textsettingstype
{
	int		font;
	int		direction;
	int		charsize;
	int		horiz;
	int		vert;
};

struct fillsettingstype
{
	int		pattern;
	int		color;
};

struct pointtype
{
	int		x;
	int		y;
};

struct viewporttype
{
	int		left;
	int		top;
	int		right;
	int		bottom;
	int		clip;
};

struct arccoordstype
{
	int		x;
	int		y;
	int		xstart;
	int		ystart;
	int		xend;
	int		yend;
};

void	arc( int x, int y, int stangle, int endangle, int radius );
void	bar( int left, int top, int right, int bottom );
void	bar3d( int left, int top, int right, int bottom, int depth, int topflag );
void	circle( int x, int y, int radius );
void	cleardevice( void );
void	clearviewport( void );
void	closegraph( void );
void	detectgraph( int *graphdriver,int *graphmode );
void	drawpoly( int numpoints, int *polypoints );
void	ellipse( int x, int y, int stangle, int endangle, int xradius, int yradius );
void	fillellipse( int x, int y, int xradius, int yradius  );
void	fillpoly( int numpoints, int *polypoints );
void	floodfill( int x, int y, int border );
void	getarccoords( struct arccoordstype *arccoords );
void	getaspectratio( int *xasp, int *yasp );
int		getbkcolor( void );
int		getcolor( void );
char	*getdrivername( void  );
void	*getdefaultpalette( void );
void	getfillpattern( char *pattern );
void	getfillsettings( struct fillsettingstype *fillinfo );
int		getgraphmode( void );
void	getimage( int left, int top, int right, int bottom, void *bitmap );
void	getlinesettings( struct linesettingstype *lineinfo );
int		getmaxcolor( void );
int		getmaxmode( void );
int		getmaxx( void );
int		getmaxy( void );
char	*getmodename( int mode_number );
void	getmoderange( int graphdriver, int *lomode, int *himode );
unsigned int	getpixel( int x, int y );
void	getpalette( struct palettetype *palette );
int		getpalettesize( void );
void	gettextsettings( struct textsettingstype *texttypeinfo );
void	getviewsettings( struct viewporttype *viewport );
int		getx( void );
int		gety( void );
void	graphdefaults( void );
char	*grapherrormsg( int errorcode );
void	_graphfreemem( void *ptr, unsigned size );
void	*_graphgetmem( unsigned size );
int		graphresult( void );
unsigned long	imagesize( int left, int top, int right, int bottom );
void	initgraph( int *graphdriver, int *graphmode, char *pathtodriver );
int		installuserdriver( char *name, int (*detect)( void ));
int		installuserfont( char *name );
void	line( int x1, int y1, int x2, int y2 );
void	linerel( int dx, int dy );
void	lineto( int x, int y );
void	moverel( int dx, int dy );
void	moveto( int x, int y );
void	outtext( char *textstring );
void	outtextxy( int x, int y, char *textstring );
void	pieslice( int x, int y, int stangle, int endangle, int radius );
void	putimage( int left, int top, void *bitmap, int op );
void	putpixel( int x, int y, int color );
void	rectangle( int left, int top, int right, int bottom );
int		registerbgidriver( void (*driver)( void ));
int		registerbgifont( void (*font)( void ));
void	restorecrtmode( void );
void	sector( int X, int Y, int StAngle, int EndAngle, int XRadius, int YRadius );
void	setactivepage( int page );
void	setallpalette( struct palettetype *palette );
void	setaspectratio( int xasp, int yasp );
void	setbkcolor( int color );
void	setcolor( int color );
void	setfillpattern( char *upattern, int color );
void	setfillstyle( int pattern, int color );
unsigned int	setgraphbufsize( unsigned bufsize );
void	setgraphmode( int mode );
void	setlinestyle( int linestyle, unsigned upattern, int thickness );
void	setpalette( int index, int color );
void	setrgbpalette( int colornum, int red, int green, int blue );
void	settextjustify( int horiz, int vert );
void	settextstyle( int font, int direction, int charsize );
void	setusercharsize( int multx, int divx, int multy, int divy );
void	setviewport( int left, int top, int right, int bottom, int clip );
void	setvisualpage( int page );
void	setwritemode( int mode );
int		textheight( char *textstring );
int		textwidth( char *textstring );

void	triplex_font( void );
void	small_font( void );
void	sansserif_font( void );
void	gothic_font( void );

#endif
