/*
	ue.h of Gulam/uE

This file is the general header file for all parts of the MicroEMACS
display editor.  It contains definitions used by everyone, and it
contains the stuff you have to edit to create a version of the editor
for a specific operating system and terminal.  */


#define	local	static		/* prefix to rtns internal to a module */
				/* changed to '#define local' while dbg	*/

#define	FALSE	0
#define	TRUE	(!FALSE)
#define ABORT   2		/* Death, ^G, abort, etc.       */
#ifndef NULL
#define	NULL	0L
#endif

#ifndef	GU

typedef	unsigned int	uint;
typedef	unsigned char	uchar;

#include "sysdpend.h"		/* this should come after OS #define	*/

typedef struct
{	int	nc;
	int	sz;
	int	ns;
	uchar 	*ps;
}	WS;

typedef	struct	TBLE
{
	uchar *		key;
	uchar *		elm;
	struct TBLE *	next;
}	TBLE;

extern	long	valu;
extern	uchar	*emsg;
extern	uchar	*strg;
extern	uchar	ES[];			/* "", empty string		*/
extern	uchar	CRLF[];			/* "\r\n"			*/

extern	WS	*initws();
extern	WS	*lex();
extern	WS	*useuplexws();
extern	uchar	*lexgetword();

#else
#undef	CTRLQ
#undef	CTRLS
#endif	GU

#define NFILEN  80			/* # of bytes, file name        */
#define NBUFN   16			/* # of bytes, buffer name      */
#define NLINE   256			/* # of bytes, line             */
#define NKBDM   4*256			/* # of strokes, keyboard macro */
#define NPAT    80			/* # of bytes, pattern          */
#define HUGE    1000			/* Huge number                  */

#define AGRAVE  0x60			/* M- prefix,   Grave (LK201)   */
#define METACH  0x1B			/* M- prefix,   Control-[, ESC  */
#define CTMECH  0x1C			/* C-M- prefix, Control-\       */
#define EXITCH  0x1D			/* Exit level,  Control-]       */
#define CTRLCH  0x1E			/* C- prefix,   Control-^       */
#define HELPCH  0x1F			/* Help key,    Control-_       */
#define	KRANDOM	0xFF			/* A "no key" code. pm		*/
#define	KCHAR	0x00FF			/* The basic character code.	*/

#define	_W	0x01			/* Word.			*/
#define	_U	0x02			/* Upper case letter.		*/
#define	_L	0x04			/* Lower case letter.		*/
#define	_C	0x08			/* Control.			*/
#define _P	0x10			/* end of sentence punctuation	*/

#define BEL		007
#define	CTRLQ		021
#define	CTRLR		022
#define	CTRLS		023
#define	CCHR(c)		(c & 0x1F)
#define	ISLOWER(c)	(('a' <= c) && (c <= 'z'))
#define	ISUPPER(c)	(('A' <= c) && (c <= 'Z'))
#define	TOUPPER(c)	(c + 'A' - 'a')

#define FIOSUC  0			/* File I/O, success.           */
#define FIOFNF  1			/* File I/O, file not found.    */
#define FIOEOF  2			/* File I/O, end of file.       */
#define FIOERR  3			/* File I/O, error.             */

#define CFCPCN  0x0001			/* Last command was C-P, C-N    */
#define CFKILL  0x0002			/* Last command was a kill      */

#define KNONE	0			/* Flags for "ldelete"/"kinsert" */
#define KFORW	1
#define KBACK	2
#define	KEOTBL	0xFFFF			/* no key code matches this	*/

					/* key-to-fn bindings		*/
#define	REGKB	0
#define	GUKB	1
#define	MINKB	2
#define	TEKB	3
	
typedef	int	KEY;
typedef struct
{	KEY	k_code;			/* Key code                     */
	int	k_fx;			/* corresp fn index into FPFS	*/
}       KB;

typedef	int	(*FPFS)();		/* ptr to function		*/

/* All text is kept in circularly linked lists of LINE structures.
These begin at the header line (which is the blank line beyond the end
of the buffer).  This line is pointed to by the BUFFER.  Each line
contains a the number of bytes in the line (the "used" size), the size
of the text array, and the text.  The end of line is not stored as a
byte; it's implied.  Future additions will include update hints, and a
list of marks into the line.  */


typedef struct  LINE
{	struct	LINE *l_fp;		/* Link to the next line        */
        struct	LINE *l_bp;		/* Link to the previous line    */
#ifndef	PMMALLOC
 	int	l_zsize;		/* Allocated size               */
#endif
        int	l_used;			/* Used size                    */
	uchar	l_text[MINELM];		/* A bunch of characters.       */
}       LINE;	

#define lforw(lp)       ((lp)->l_fp)
#define lback(lp)       ((lp)->l_bp)
#define lgetc(lp, n)    ((lp)->l_text[(n)]&0xFF)
#define lputc(lp, n, c) ((lp)->l_text[(n)]=(c))
#define llength(lp)     ((lp)->l_used)

#ifdef	PMMALLOC
#define	lsize(lp) ((int)(((int *)lp)[-1]) - ((uint)sizeof(LINE)) - 3)
#else
#define	lsize(lp) (lp->l_zsize)
#endif

/* There is a WINDOW structure allocated for every active display
window.  The windows are kept in a big list, in top to bottom screen
order, with the listhead at "wheadp".  Each window contains its own
values of dot and mark.  The flag field contains some bits that are
set by commands to guide redisplay; although this is a bit of a
compromise in terms of decoupling, the full blown redisplay is just
too expensive to run for every input character.  */


typedef struct  WINDOW
{	LINE	*w_dotp;		/* Line containing "."          */
	LINE	*w_markp;		/* Line containing "mark"       */
	int	w_doto;			/* Byte offset for "."          */
	int	w_marko;		/* Byte offset for "mark"       */
	struct	WINDOW *w_wndp;		/* Next window                  */
	struct	BUFFER *w_bufp;		/* Buffer displayed in window   */
	LINE	*w_linep;		/* Top line in the window       */
	uchar	w_toprow;		/* Origin 0 top row of window   */
	uchar	w_ntrows;		/* # of rows of text in window  */
	uchar	w_force;		/* If NZ, forcing row.          */
	uchar	w_flag;			/* Flags.                       */
}       WINDOW;	

#define WFFORCE 0x01			/* Window needs forced reframe  */
#define WFMOVE  0x02			/* Movement from line to line   */
#define WFEDIT  0x04			/* Editing within a line        */
#define WFHARD  0x08			/* Better to a full display     */
#define WFMODE  0x10			/* Update mode line.            */

/* Text is kept in buffers.  A buffer header, described below, exists
for every buffer in the system.  The buffers are kept in a big list,
so that commands that search for a buffer by name can find the buffer
header.  There is a safe store for the dot and mark in the header, but
this is only valid if the buffer is not being displayed (that is, if
"b_nwnd" is 0).  The text for the buffer is kept in a circularly
linked list of lines, with a pointer to the header line in "b_linep".
*/

typedef struct  BUFFER
{	LINE	*b_dotp;		/* Link to "." LINE structure   */
	LINE	*b_markp;		/* The same as the above two,   */
	int	b_doto;			/* Offset of "." in above LINE  */
	int	b_marko;		/* but for the "mark"           */
	struct	BUFFER *b_bufp;		/* Link to next BUFFER          */	
	LINE	*b_linep;		/* Link to the header LINE      */
	uchar	b_nwnd;			/* Count of windows on buffer   */
	uchar	b_flag;			/* Flags                        */
	uchar	b_fname[NFILEN];	/* File name                    */
	uchar	b_bname[NBUFN];		/* Buffer name                  */
	int	b_kbn;			/* key-to-fn bindings		*/
	uchar	b_modec;		/* char for this bufs modeline	*/
}       BUFFER;	

#define BFTEMP  0x01			/* Internal temporary buffer    */
#define BFCHG   0x02			/* Changed since last write     */
#define	BFRDO	0x04			/* Buffer is read-only		*/

#ifdef	AtariST

/* Code Tuning Tweak: The <dotp, markp, doto, marko> of WINDOW and
BUFFER are at the very top of these structs.  Together they are 3
longs.  This tweak is used in buffer.c.  */


#define	DM	1
#define	wwdotmark(pp, qq) cpdotmark(pp, qq)
#define	wbdotmark(pp, qq) cpdotmark(pp, qq)
#define	bwdotmark(pp, qq) cpdotmark(pp, qq)
#else
#undef	DM
#endif

typedef	int	RSIZE;

/* The starting position of a region, and the size of the region in
characters, is kept in a region structure.  Used by the region
commands.  */


typedef struct
{	LINE	*r_linep;		/* Origin LINE address.         */
	RSIZE	r_offset;		/* Origin LINE offset.          */
	RSIZE	r_size;			/* Length in characters.        */
}       REGION;	


/* The editor communicates with the display using a high level
interface.  A TERM structure holds useful variables, and indirect
pointers to routines that do useful operations.  The low level get and
put routines are here too.  This lets a terminal, in addition to
having non standard commands, have funny get and put character code
too.  The calls might get changed to "termp->t_field" style in the
future, to make it possible to run more than one terminal type.  */


typedef struct
{	int   t_nrow;                 /* Number of rows.              */
        int   t_ncol;                 /* Number of columns.           */
#ifndef	AtariST
        int     (*t_open)();            /* Open terminal at the start.  */
        int     (*t_close)();           /* Close terminal at end.       */
        int     (*t_getchar)();         /* Get character from keyboard. */
        int     (*t_putchar)();         /* Put character to display.    */
        int     (*t_flush)();           /* Flush output buffers.        */
        int     (*t_move)();            /* Move the cursor, origin 0.   */
        int     (*t_eeol)();            /* Erase to end of line.        */
        int     (*t_eeop)();            /* Erase to end of page.        */
        int     (*t_beep)();            /* Beep.                        */
#endif
}       TERM;

typedef struct  VIDEO
{	int	v_flag;                 /* Flags */
        uchar	v_text[1];              /* Screen data. */
}       VIDEO;


extern  uchar	pat[];                  /* Search pattern               */
extern  uchar	msginit[];		/* my ego!			*/
extern  int	exitue;			/* indicates where control is	*/
extern  int	fillcol;                /* Fill column                  */
extern  int	currow;                 /* Cursor row                   */
extern  int	curcol;                 /* Cursor column                */
extern  int	thisflag;               /* Flags, this command          */
extern  int	lastflag;               /* Flags, last command          */
extern  int	curgoal;                /* Goal for C-P, C-N            */
extern  int	mpresf;                 /* Stuff in message line        */
extern  int	sgarbf;                 /* State of screen unknown      */
extern  WINDOW	*wheadp;                /* Head of list of windows      */
extern  WINDOW	*curwp;                 /* Current window               */
extern  WINDOW	*mlwp;			/* message line window		*/
extern  BUFFER	*curbp;                 /* Current buffer               */
extern  BUFFER	*bheadp;                /* Head of list of buffers      */
extern  BUFFER	*gulambp;               /* gulam buffer                 */
extern  BUFFER	*minibp;		/* mini buffer			*/
extern  TERM	term;                   /* Terminal information.        */

extern  BUFFER  *bfind();               /* Lookup a buffer by name      */
extern  BUFFER	*nextbuffer();
extern  BUFFER	*setgulambp();
extern  WINDOW	*wpopup();              /* Pop up window creation       */
extern  WINDOW	*popbuf();
extern  WINDOW	*makewind();
extern	LINE	*lnlink();
extern  LINE	*lalloc();              /* Allocate a line              */
extern	uchar	*malloc();
extern	uchar	*gmalloc();
extern	uchar	*maxalloc();
#ifndef __GNUC__
extern	uchar	*index();
extern	uchar	*rindex();
extern	uchar	*strdup();
#endif
extern	uchar	*str3cat();
extern	uchar	*gfgetcwd();
extern	uchar	*makelnstr();
extern	uchar	*itoar();
extern	uchar	*itoa();
extern	uchar	*sprintp();
extern	long	atoir();

extern	unsigned int	getusrinput();
extern	unsigned int	userfnminput();

/* -eof- */
