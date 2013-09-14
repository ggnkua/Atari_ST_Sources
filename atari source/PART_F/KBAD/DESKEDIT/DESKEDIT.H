/* deskedit.h - declarations for desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900125 kbad Added VST_xxx text alignment defines
 * 890723 kbad Created
 */

#define MAX_LINE 		32000	/* not a bad max line length... */

#define FX_BOLD			0x01
#define FX_LITE			0x02
#define FX_SKEW			0x04
#define FX_UL			0x08
#define FX_OUTLINE		0x10
#define FX_SHADOW		0x20

#define VST_LEFT		0
#define VST_CENTER		1
#define VST_RIGHT		2
#define VST_BASE		0
#define VST_HALF		1
#define VST_ASCENT		2
#define VST_BOTTOM		3
#define VST_DESCENT		4
#define VST_TOP			5

typedef struct vstring {	/* VDI string */
		struct vstring	*next;	/* next segment of line, or NULL */
		int 			fx;		/* text effects */
		int				len;	/* length of string */
		char			s[1];	/* string data */
} VSTRING;

typedef struct tline {		/* line of text */
		struct tline	*next;
		struct tline	*prev;
		VSTRING			*vs;		/* start of data */
} TLINE;

typedef struct wx {
		char	name[128];	/* full pathname */
		int 	tabs;		/* tabsize */
		int 	font;		/* font (9 or 10) */
		TLINE	*line0;		/* first TLINE in this window */
		int		edx, edy;	/* current edit coordinates */
		TLINE	*curline;	/* current line data */
		VSTRING	*curvs;		/* current VSTRING in curline */
} WX; /* window xtras */
#define WXname(w)	( ((WX *)(w)->x)->name )
#define WXtabs(w)	( ((WX *)(w)->x)->tabs )
#define WXfont(w)	( ((WX *)(w)->x)->font )
#define WXline0(w)	( ((WX *)(w)->x)->line0 )
#define WXedx(w)	( ((WX *)(w)->x)->edx )
#define WXedy(w)	( ((WX *)(w)->x)->edy )
#define WXcurline(w) ( ((WX *)(w)->x)->curline )
#define WXcurvs(w)	( ((WX *)(w)->x)->curvs )

/* Global routines - deskedit.c
 * ================================================================
 */
void	draw_cursor( const WINFO *w, GRECT *clip );


/* Global routines - lines.c
 * ================================================================
 */
void	vs_draw( int x, int y, VSTRING *vs, int wchar,
				int startcol, int maxcol, int rightcol );
/* Draw the remainder of the vstring `vs' at x, y, constrained by
 * the `col' parameters.
 */
TLINE	*vy_2line( const WINFO *w, int vy );
/* Return the address of the TLINE in `w' corresponding to virtual row `vy'.
 */
VSTRING *vs_alloc( int fx, int len, char *s );
/* Allocate a VSTRING and fill it in.
 * `s == NULL' implies a special VSTRING (e.g. a tab VSTRING).
 * Returns address of VSTRING or NULL on an allocation error.
 */
void	vs_link( VSTRING *new, TLINE *l, VSTRING *prev );
/* Link `new' into `l' before `prev'.
 */
void	free_tlines( TLINE *l );
/* Free all TLINEs and VSTRINGs including and following `l'
 */
int		tlen( TLINE *l );
/* Return the length in characters of l
 */

/* Global routines - files.c
 * ================================================================
 */
int		open_file( WX **pwx, int *pvw, int *pvh );
/* open a file, parse it, and fill in its WX struct
 */
int		parse_buf( char *buf, long len, int tabsize,
					TLINE **firstline, int *pwidth, int *pheight );
/* Parse a file buffer, create a linked list of LINE structs for it.
 * Set *firstline to address of 1st TLINE struct allocated,
 * *pwidth to length of widest (detabbed) line, and
 * *pheight to number of lines.
 * Return AE_OK or AENSMEM.
 */

/* Global routines - editfunc.c
 * ================================================================
 */
void	insert_char( int key, WINFO *w );

