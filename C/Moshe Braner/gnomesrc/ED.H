/*
 * This file is the general header file for
 * all parts of the MicroEMACS display editor. It contains
 * definitions used by everyone, and it contains the stuff
 * you have to edit to create a version of the editor for
 * a specific operating system and terminal.
 * mb: all short's changed to int's, except l_size & l_length
 * which were changed to char.
 */
#define V7      0			/* V7 UN*X or Coherent		*/
#define VMS     0			/* VAX/VMS			*/
#define CPM     0			/* CP/M-86			*/
#define MSDOS   0			/* MS-DOS			*/
					/*   (Turbo C compiler)		*/
					/*   (Compact memory model)	*/
#define AtST    1			/* Atari 520ST or 1040ST	*/
					/*   (Megamax C compiler )	*/

#define TCCONIO 0			/* Turbo C direct console I/O	*/
#define ANSI    0			/* Ansi terminal		*/
#define VT52    1			/* VT52 terminal		*/
#define TERMCAP 0			/* Use TERMCAP                  */

#define VT100   0			/* Handle VT100 style keypad.   */

#if (AtST | MSDOS)
#define	NROW	25
#else
#define	NROW	24			/* Default screen size		*/
#endif
#define	NCOL	80			/* Edit if you want to.		*/

#define WSHIFT	2	/* mb: how much to shift screen	sideways at once.
				2 means by one half, 3 by 1/3, etc.	*/

#define CANLOG	1			/* mb: compile in logfile stuff	*/

#define	LOGIT	  0			/* mb: default: no log		*/
#define LOGFLUSH  256			/* mb: how often flush log file	*/
#define	LOGFILE	  "gnome.log"		/* mb: name of log file		*/
#if V7
#undef	LOGIT
#define	LOGIT	1			/* mb: log keystrokes in a file	*/
#undef	LOGFILE
#define	LOGFILE	".gnomelog"		/* mb: UN*X name of log file	*/
#endif
#if VMS
#undef	LOGIT
#define	LOGIT	1
#endif

#define HELP    1			/* mb: compile built-in help	*/
#define EXTRA   1			/* mb: compile less-used stuff
						(together they add ~9K)	*/
#define CVMVAS  1			/* C-V, M-V arg. in screens.	*/
#define CMODE	0			/* mb: Fancy C-lang features	*/
#define GDEBUG  0			/* mb: General debugging flag	*/

#define BFILES  1			/* mb: Read files in blocks	*/
#define FBLOCK  9216	/* For BFILES: 2 SS tracks. Edit for your system. */

/* mb: on some UNIX systems need to delay on entry & exit, make this 1: */
#define SLEEP	1

#define	PARPORT	0		/* mb: device IDs for hardcopy output */
#define	SERPORT	1

#define INWORDM "$"	/* mb: chars to consider inside a word for moves */
#define INWORDW "*.,+-?!()[]\'\""	/* additional, for word wrap */
			/* (in addition to letters and numbers) */

/* mb: for overflow checks, etc: you may want to edit for your system!	*/
#define MAXSH	0x7F			/* max pos short	*/
#define MAXUS	0xFF			/* max unsigned short	*/
#define MAXINT	0x7FFF			/* max pos int		*/
#define MAXUI	0XFFFF			/* max unsigned int	*/

#define NFILEN  128			/* # of bytes, file name        */
#define NBUFN   128			/* # of bytes, buffer name      */
#define NBLOCK  16			/* # of bytes, line allocation	*/
#define KBLOCK  256			/* # of bytes, kbuf allocation	*/
#define NLINE   256			/* # of bytes, max line	reading	*/
#define NKBDM   256			/* # of strokes, keyboard macro */
#define NPAT    128			/* # of bytes, pattern          */
#define HUGE    1000			/* Huge number			*/

#define HISTORY 16			/* mb: shell commands stored	*/

#define NOKEY	(-1)		/* mb: returned from getkey() on error */

#define METACH  (CNTL|'[')  /* mb: 'CNTL'. M- prefix,   Control-[, ESC  */
#define CNTLCH  (CNTL|'^')		/* C- prefix,   Control-^       */

#define UP	(CNTL|'P')
#define DOWN	(CNTL|'N')
#define LEFT	(CNTL|'B')
#define RIGHT	(CNTL|'F')

#define CANCEL  (CNTL|'U')		/* mb: cancel-input-line key    */

#define WHITESPACE	(0x0D)		/* mb: in search patterns */
#define NEGCHAR		(0xFF)
#define ANYCHAR		(0x1F)

#define CNTL    0x0100			/* Control flag, or'ed in       */
#define META    0x0200			/* Meta flag, or'ed in          */
#define CTLX    0x0400			/* ^X flag, or'ed in            */
#define FUNC    0x0800			/* for function keys, if any    */
#define SHFT    0x1000			/* function keys + Shift        */
#define ALT     0x2000			/* function keys + Alternate    */
#define ED      0x8000			/* flag: cmd changes the file   */

#define FALSE   0			/* False, no, bad, etc.		*/
#define TRUE    1			/* True, yes, good, etc.	*/
#define ABORT   2			/* Death, ^G, abort, etc.	*/

#define FIOSUC   0			/* File I/O, success.		*/
#define FIOFNF   1			/* File I/O, file not found.    */
#define FIOEOF   2			/* File I/O, end of file.       */
#define FIOERR   3			/* File I/O, error.		*/
#define FIOFUNNY 4			/* Funny line at EOF		*/

#define CFCPCN  0x0001			/* Last command was C-P, C-N    */
#define CFKILL  0x0002			/* Last command was a kill      */
#define CFYANK  0x0004			/* mb: Last command was a yank  */
#define CFSPLIT 0x0008			/* mb: Last split the window    */

/*
 * There is a window structure allocated for
 * every active display window. The windows are kept in a
 * big list, in top to bottom screen order, with the listhead at
 * "wheadp". Each window contains its own values of dot and mark.
 * The flag field contains some bits that are set by commands
 * to guide redisplay; although this is a bit of a compromise in
 * terms of decoupling, the full blown redisplay is just too
 * expensive to run for every input character. 
 */
typedef struct  WINDOW {
	struct  WINDOW *w_wndp;		/* Next window			*/
	struct  BUFFER *w_bufp;		/* Buffer displayed in window	*/
	struct  LINE *w_linep;		/* Top line in the window	*/
	struct  LINE *w_dotp;		/* Line containing "."		*/
	int	w_doto;			/* Byte offset for "."		*/
	struct  LINE *w_markp;		/* Line containing "mark"	*/
	int	w_marko;		/* Byte offset for "mark"	*/
	int	w_toprow;		/* Origin 0 top row of window   */
	int	w_ntrows;		/* # of rows of text in window  */
	int	w_offset;		/* mb: col offset from left	*/
	int	w_force;		/* If NZ, forcing row.		*/
	int	w_flag;			/* Flags.			*/
}       WINDOW;

#define WFFORCE 0x01			/* Window needs forced reframe  */
#define WFMOVE  0x02			/* Movement from line to line   */
#define WFEDIT  0x04			/* Editing within a line        */
#define WFHARD  0x08			/* Better do a full display     */
#define WFMODE  0x10			/* Update mode line.            */

/*
 * Text is kept in buffers. A buffer header, described
 * below, exists for every buffer in the system. The buffers are
 * kept in a big list, so that commands that search for a buffer by
 * name can find the buffer header. There is a safe store for the
 * dot and mark in the header, but this is only valid if the buffer
 * is not being displayed (that is, if "b_nwnd" is 0). The text for
 * the buffer is kept in a circularly linked list of lines, with
 * a pointer to the header line in "b_linep".
 */
typedef struct  BUFFER {
	struct  BUFFER *b_bufp;		/* Link to next BUFFER		*/
	struct  LINE *b_dotp;		/* Link to "." LINE structure   */
	int     b_doto;			/* Offset of "." in above LINE  */
	struct  LINE *b_markp;		/* The same as the above two,   */
	int     b_marko;		/* but for the "mark"		*/
	struct  LINE *b_linep;		/* Link to the header LINE      */
	int	b_nwnd;			/* Count of windows on buffer   */
	int	b_flag;			/* Flags			*/
	char	b_fname[NFILEN];	/* File name			*/
	char	b_bname[NBUFN];		/* Buffer name			*/
}       BUFFER;

#define BFTEMP  0x01			/* Internal temporary buffer    */
#define BFCHG   0x02			/* Changed since last write	*/
#define BFEDIT  0x04			/* mb: OK to change (added)	*/

/*
 * The starting position of a
 * region, and the size of the region in
 * characters, is kept in a region structure.
 * Used by the region commands.
 */
typedef struct  {
	struct  LINE *r_linep;		/* Origin LINE address.		*/
	int     r_offset;		/* Origin LINE offset.		*/
	int     r_size;			/* Length in characters.	*/
}       REGION;

/*
 * All text is kept in circularly linked
 * lists of "LINE" structures. These begin at the
 * header line (which is the blank line beyond the
 * end of the buffer). This line is pointed to by
 * the "BUFFER". Each line contains a the number of
 * bytes in the line (the "used" size), the size
 * of the text array, and the text. The end of line
 * is not stored as a byte; it's implied. Future
 * additions will include update hints, and a
 * list of marks into the line.
 */
typedef struct	LINE {
	struct	LINE *l_fp;		/* Link to the next line        */
	struct	LINE *l_bp;		/* Link to the previous line    */
	char	l_size;			/* Allocated size		*/
	char	l_used;			/* Used size			*/
	char	l_text[NLINE];		/* A bunch of characters.	*/
}       LINE;

#define LINESIZE (sizeof(LINE)-NLINE)

#define lforw(lp)	((lp)->l_fp)
#define lback(lp)	((lp)->l_bp)
#define lgetc(lp, n)	(((lp)->l_text[(n)])&0xFF)
#define lputc(lp, n, c)	((lp)->l_text[(n)]=(c))
/* mb: make these behave as unsigned shorts: */
#define llength(lp)	(MAXUS&((int)(lp)->l_used))
#define lsize(lp)	(MAXUS&((int)(lp)->l_size))
/* mb: macro for text formatting with dot commands: */
#define istext(lp)	((lp)->l_used != 0\
			&& (lp)->l_text[0] != '.'\
			&& (lp)->l_text[0] != '\\')

/*
 * The editor communicates with the display
 * using a high level interface. A "TERM" structure
 * holds useful variables, and indirect pointers to
 * routines that do useful operations. The low level get
 * and put routines are here too. This lets a terminal,
 * in addition to having non standard commands, have
 * funny get and put character code too. The calls
 * might get changed to "termp->t_field" style in
 * the future, to make it possible to run more than
 * one terminal type.
 */  
typedef struct  {
	int     t_nrow;			/* Number of rows.		*/
	int     t_ncol;			/* Number of columns.		*/
	int     (*t_open)();		/* Open terminal at the start.  */
	int     (*t_close)();		/* Close terminal at end.	*/
	int     (*t_getchar)();		/* Get character from keyboard. */
	int     (*t_putchar)();		/* Put character to display.    */
	int     (*t_flush)();		/* Flush output buffers.	*/
	int     (*t_move)();		/* Move the cursor, origin 0.   */
	int     (*t_eeol)();		/* Erase to end of line.	*/
	int     (*t_eeop)();		/* Erase to end of page.	*/
	int     (*t_beep)();		/* Beep.			*/
	int     (*t_hglt)();		/* "Highlight" video mode.	*/
	int     (*t_nrml)();		/* normal video mode.		*/
	int	(*t_pend)();		/* input chars pending		*/
}       TERM;

extern	int	logit;			/* mb: log keystrokes		*/
extern	int	playback;		/* mb: playback from log file	*/
extern	int	maxnfiles;		/* mb: max # of fn defaults	*/
extern	char	**clfn;			/* mb: argv but filenames only	*/
extern	int	nfiles;			/* mb: number of file args	*/
extern	int	fileindex;		/* mb: index into filename list	*/
extern	int	casesens;		/* mb: search case-sensitive	*/
extern	int	deldir;			/* mb: <Delete> op direction	*/
extern  int	fillcol;		/* Fill column			*/
extern  int	lmargin;		/* mb: added */
extern  int	tabsize; 		/* mb: added */
extern  int	ovrstrk; 		/* mb: added */
extern  int	currow;  		/* Cursor row			*/
extern  int	curcol;  		/* Cursor column		*/
extern  int	thisflag;		/* Flags, this command		*/
extern  int	lastflag;		/* Flags, last command		*/
extern  int	curgoal; 		/* Goal for C-P, C-N		*/
extern  int	mpresf;  		/* Stuff in message line	*/
extern  int	sgarbf;  		/* State of screen unknown      */
extern  WINDOW	*curwp;  		/* Current window		*/
extern  BUFFER	*curbp;  		/* Current buffer		*/
extern  BUFFER	*oldbp;  		/* mb: previous buffer          */
extern  WINDOW	*wheadp; 		/* Head of list of windows      */
extern  BUFFER	*bheadp; 		/* Head of list of buffers      */
extern  BUFFER	*blistp; 		/* Buffer for C-X-?		*/
extern  BUFFER	*bhelpp; 		/* Buffer for help screens	*/
extern  int	kbdm[];  		/* Holds kayboard macro data    */
extern  int	*kbdmip; 		/* Input pointer for above      */
extern  int	*kbdmop; 		/* Output pointer for above     */
extern  char	pat[];   		/* Search pattern		*/
extern  TERM	term;    		/* Terminal information.	*/

extern  BUFFER	*bfind();		/* Lookup a buffer by name	*/
extern  WINDOW	*wpopup();		/* Pop up window creation	*/
extern  LINE	*lalloc();		/* Allocate a line		*/

extern	char	*malloc();

#if AtST
#include <osbind.h>
#include <strings.h>
#endif

#if MSDOS
#include <string.h>
#endif
