/*
 * Original code written by Dave G. Conroy,
 * substantially modified by Moshe Braner, July-December 1986.
 * Further substantial modifications by MB: January, 1988.
 *
 * Parts of the program Copyright (c) 1986, 1988 by Moshe Braner.
 * Program name changed from microEMACS to GNOME.
 *
 * Permission is granted to copy and use this program,
 * provided that this copyright notice and the source
 * code for the program are included in each copy,
 * and that it is not sold for profit.
 */

/*
 * This file contains the
 * main driving routine, and some
 * keyboard processing code, for the
 * MicroEMACS screen editor.
 */
#include	<stdio.h>
#include	"ed.h"

#if	VMS
#include	<ssdef.h>
#define GOOD	(SS$_NORMAL)
#endif

#ifndef GOOD
#define GOOD	0
#endif

#define BASE	0		/* mb: states of the machine */
#define ESC	1
#define ARG	2
#define EXEC	3

int	logit = LOGIT;			/* mb: log keystrokes		*/
int	playback = FALSE;		/* mb: playback from log file	*/
char	**clfn;				/* mb: argv but filenames only	*/
int	nfiles;				/* mb: number of file args	*/
int	maxnfiles;			/* mb: max # of fn defaults	*/
int	fileindex;			/* mb: index into filename list	*/
int	currow;				/* Working cursor row		*/
int	curcol;				/* Working cursor column	*/
int	fillcol = 0;			/* Current fill column		*/
int	lmargin = 0;			/* mb: Current left margin	*/
int	tabsize = 8;			/* mb: added			*/
int	hdev;				/* mb: hard copy device	ID	*/
int	thisflag;			/* Flags, this command		*/
int	lastflag;			/* Flags, last command		*/
int	curgoal;			/* Goal column			*/
int	ovrstrk = FALSE;		/* mb: insert/overstrike flag	*/
int	deldir  = FALSE;		/* mb: <Delete> direction flag	*/
int	casesens = TRUE;		/* mb: search case sensitive	*/
BUFFER  *curbp;				/* Current buffer		*/
BUFFER  *oldbp = NULL;			/* mb: previous buffer		*/
WINDOW  *curwp;				/* Current window		*/
BUFFER  *bheadp;			/* BUFFER listhead		*/
WINDOW  *wheadp;			/* WINDOW listhead		*/
BUFFER  *blistp;			/* Buffer list BUFFER		*/
BUFFER  *bhelpp;			/* Help screens BUFFER		*/
int	kbdm[NKBDM];			/* Macro			*/
int	*kbdmip;			/* Input  for above		*/
int	*kbdmop;			/* Output for above		*/
char	pat[NPAT] = {'\0'};		/* Pattern			*/

#if AtST
int	vidrev	= FALSE;		/* may be changed by cmd line	*/
#endif
#if MSDOS
extern int directvideo;
int	origvidmode;			/* save on entry		*/
int	nrmlvidattr;			/* normal in our vidmode	*/
int	curvidattr;			/* update all along		*/
int	vidrev	  = FALSE;		/* may be changed by cmd line	*/
int	vidmode   = (-1);		/* may be changed by cmd line	*/
#endif

typedef struct  {
	int	k_code;			/* Key code			*/
	int	(*k_fp)();		/* Routine to handle it		*/
}	KEYTAB;

extern  int	mlrelpy();		/* get a string from the user	*/
extern  int	quit();			/* Quit				*/
extern  int	ctlxlp();		/* Begin macro			*/
extern  int	ctlxrp();		/* End macro			*/
extern  int	ctlxe();		/* Execute macro		*/
extern  int	fileread();		/* Get a file, read only	*/
extern  int	filevisit();		/* Get a file, read write	*/
extern  int	filewrite();		/* Write a file			*/
extern  int	filesave();		/* Save current file		*/
extern  int	filename();		/* Adjust file name		*/
extern  int	getccol();		/* Get current column		*/
extern  int	gotobol();		/* Move to start of line	*/
extern  int	forwchar();		/* Move forward by characters	*/
extern  int	gotoeol();		/* Move to end of line		*/
extern  int	backchar();		/* Move backward by characters  */
extern  int	forwline();		/* Move forward by lines	*/
extern  int	backline();		/* Move backward by lines	*/
extern  int	forwpage();		/* Move forward by pages	*/
extern  int	backpage();		/* Move backward by pages	*/
extern  int	gotobob();		/* Move to start of buffer	*/
extern  int	gotoeob();		/* Move to end of buffer	*/
extern  int	setfillcol();		/* Set fill column.		*/
extern  int	setlmargin();		/* mb: added */
extern  int	reformat();		/* mb: added */
extern  int	setmark();		/* Set mark			*/
extern  int	swapmark();		/* Swap "." and mark		*/
extern  int	forwsearch();		/* Search forward		*/
extern  int	backsearch();		/* Search backwards		*/
extern  int	showcpos();		/* Show the cursor position	*/
extern  int	nextwind();		/* Move to the next window	*/
extern  int	prevwind();		/* Move to the previous window  */
extern  int	onlywind();		/* Make current window only one */
extern  int	splitwind();		/* Split current window		*/
extern  int	mvdnwind();		/* Move window down		*/
extern  int	mvupwind();		/* Move window up		*/
extern  int	enlargewind();		/* Enlarge display window.	*/
extern  int	listbuffers();		/* Display list of buffers	*/
extern  int	usebuffer();		/* Switch a window to a buffer  */
extern  int	killbuffer();		/* Make a buffer go away.	*/
extern  int	reposition();		/* Reposition window		*/
extern  int	negrepos();		/* Reposition window other way	*/
extern  int	refresh();		/* Refresh the screen		*/
extern  int	twiddle();		/* Twiddle characters		*/
extern  int	ltwiddle();		/* Twiddle lines - mb: added */
extern  int	tab();			/* Insert tab			*/
extern  int	newline();		/* Insert CR-LF			*/
extern  int	indent();		/* Insert CR-LF, then indent	*/
extern  int	openline();		/* Open up a blank line		*/
extern  int	deblank();		/* Delete blank lines		*/
extern  int	backword();		/* Backup by words		*/
extern  int	forwword();		/* Advance by words		*/
extern  int	forwdel();		/* Forward delete		*/
extern  int	backdel();		/* Backward delete		*/
extern  int	kill();			/* Kill forward			*/
extern  int	yank();			/* Yank back from killbuffer.	*/
extern  int	unyank();		/* mb: added			*/
extern  int	upperword();		/* Upper case word		*/
extern  int	lowerword();		/* Lower case word		*/
extern  int	upperregion();		/* Upper case region		*/
extern  int	lowerregion();		/* Lower case region		*/
extern  int	capword();		/* Initial capitalize word	*/
extern  int	delfword();		/* Delete forward word		*/
extern  int	delbword();		/* Delete backward word		*/
extern  int	killregion();		/* Kill region			*/
extern  int	copyregion();		/* Copy region to kill buffer	*/
extern  int	spawncli();		/* Run CLI in a subjob		*/
extern  int	spawn();		/* Run a command in a subjob	*/
extern  int	quickexit();		/* low keystroke style exit	*/
extern	int	hardcopy();		/* mb: added. Output to printer	*/
extern  int	wrapword();		/* mb: added the rest, 		*/
extern  int	help();			/*   just in case      		*/
extern  int	forw_brace();
extern  int	back_brace();
extern  int	instog();
extern  int	casestog();
extern  int	editog();
extern  int	visitog();
extern  int	gotolinum();
extern  int	forwparag();
extern  int	backparag();
extern  int	renambuf();
extern  int	page_nextw();
extern  int	back_nextw();
extern  int	flush_kbuf();
extern  int	getkey();		/* fwd ref */
extern  int	doplay();		/* fwd ref */
extern  int	emacs_quit();		/* fwd ref */
extern  int	ctrlg();		/* fwd ref */
extern  int	undo();			/* fwd ref */
extern  int	bkill();		/* fwd ref */
extern  int	fbdel();		/* fwd ref */
extern  int	fbwdel();		/* fwd ref */
extern  int	togdeldir();		/* fwd ref */
extern  int	defmacro();		/* fwd ref */

/*
 * Command table.
 * This table  is *roughly* in ASCII
 * order, left to right across the characters
 * of the command. This expains the funny
 * location of the control-X commands.
 */
KEYTAB  keytab[] = {
	CNTL|'@',		setmark,
	CNTL|'A',		gotobol,
	CNTL|'B',		backchar,
	CNTL|'C',		quit,		/* mb: was C-X C-C */
     ED|CNTL|'D',		forwdel,
	CNTL|'E',		gotoeol,
	CNTL|'F',		forwchar,
	CNTL|'G',		undo,
     ED|CNTL|'H',		backdel,
#if MSDOS
     ED|CNTL|0x3F,		bkill,		/* mb: ^BS */
#else
     ED|CNTL|0x3F,		fbdel,		/* mb: DELETE key */
#endif
     ED|CNTL|'I',		tab,
     ED|CNTL|'J',		indent,
     ED|CNTL|'K',		kill,
	CNTL|'L',		refresh,
     ED|CNTL|'M',		newline,
	CNTL|'N',		forwline,
     ED|CNTL|'O',		openline,
	CNTL|'P',		backline,
#if	V7
	/* skip these */
#else
	CNTL|'S',		forwsearch,
#endif
	CNTL|'R',		backsearch,
     ED|CNTL|'T',		twiddle,
	CNTL|'V',		forwpage,
     ED|CNTL|'W',		killregion,
     ED|CNTL|'Y',		yank,
	CNTL|'Z',		quickexit,	/* quick save and exit  */
	CTLX|CNTL|'B',		renambuf,	/* mb: added */
	CTLX|CNTL|'C',		spawncli,	/* Run CLI in subjob.	*/
	CTLX|CNTL|'E',		editog,		/* mb: added */
	CTLX|CNTL|'F',		filename,
	CTLX|CNTL|'R',		fileread,
#if V7
	/* skip */
#else
     ED|CTLX|CNTL|'S',		filesave,
#endif
     ED|CTLX|CNTL|'T',		ltwiddle,	/* mb: added */
	CTLX|CNTL|'V',		filevisit,
     ED|CTLX|CNTL|'W',		filewrite,
	CTLX|CNTL|'X',		swapmark,
     ED|CTLX|CNTL|'Y',		unyank,		/* mb: added */
	CTLX|CNTL|'Z',		emacs_quit,
	CTLX|CNTL|0x3F,		togdeldir,	/* DELETE key dir */
	CTLX|'?',		listbuffers,
	CTLX|'!',		spawn,
#if CANLOG
	CTLX|'&',		doplay,
#endif
	CTLX|'=',		showcpos,
	CTLX|'(',		ctlxlp,
	CTLX|')',		ctlxrp,
	CTLX|'1',		onlywind,
	CTLX|'2',		splitwind,
	CTLX|'B',		usebuffer,
	CTLX|'C',		casestog,
	CTLX|'E',		ctlxe,
     ED|CTLX|'F',		reformat,	/* mb: added */
	CTLX|'K',		killbuffer,
     ED|CTLX|'L',		setlmargin,	/* mb: added */
	CTLX|'M',		defmacro,	/* mb: added */
	CTLX|'N',		nextwind,
	CTLX|'O',		nextwind,	/* mb: EMACS-like */
	CTLX|'P',		prevwind,
	CTLX|'Q',		visitog,	/* mb: added */
     ED|CTLX|'R',		setfillcol,
     ED|CTLX|'S',		filesave,	/* mb: instead of ^X^S  */
	CTLX|'V',		page_nextw,	/* mb: added */
	CTLX|'Z',		back_nextw,	/* mb: added */
	META|'!',		reposition,
#if	VT100
	/* skip this - it clashes with function key codes */
#else
	META|']',		forw_brace,	/* mb: added */
	META|'[',		back_brace,	/* mb: added */
#endif
	META|')',		forw_brace,	/* mb: added */
	META|'}',		forw_brace,	/* mb: added */
	META|'{',		back_brace,	/* mb: added */
	META|'(',		back_brace,	/* mb: added */
	META|'.',		setmark,
	META|' ',		setmark,
	META|'>',		gotoeob,
	META|'<',		gotobob,
	META|'B',		backword,
	META|'F',		forwword,
	META|'G',		gotolinum,	/* mb: added */
     ED|META|'I',		instog,		/* mb: added */
	META|'R',		backsearch,
	META|'S',		forwsearch,
	META|'V',		backpage,
	META|'W',		copyregion,
	META|'Y',		flush_kbuf,

#if	EXTRA

     ED|CTLX|CNTL|'L',		lowerregion,
	CTLX|CNTL|'N',		mvdnwind,
     ED|CTLX|CNTL|'O',		deblank,
	CTLX|CNTL|'P',		mvupwind,
     ED|CTLX|CNTL|'U',		upperregion,
	CTLX|'^',		enlargewind,
     ED|META|CNTL|'H',		delbword,
     ED|META|'C',		capword,
     ED|META|'D',		delfword,
     ED|META|'L',		lowerword,
	META|'N',		forwparag,	/* mb: added */
	META|'P',		backparag,	/* mb: added */
     ED|META|'U',		upperword,
     ED|META|CNTL|0x3F,		fbwdel,

#endif	EXTRA

#if	(AtST | MSDOS)
	CTLX|CNTL|'H',		hardcopy,	/* mb: added */
#endif

#if	AtST					/* mb: added */

	FUNC|0x4B,		backchar,	/* <-- */
	FUNC|SHFT|0x4B,		backword,
	FUNC|SHFT|0x73,		backword,
	FUNC|META|0x4B,		gotobol,
	FUNC|0x4D,		forwchar,	/* --> */
	FUNC|SHFT|0x4D,		forwword,
	FUNC|SHFT|0x74,		forwword,
	FUNC|META|0x4D,		gotoeol,
	FUNC|0x50,		forwline,
	FUNC|0x48,		backline,
#if	EXTRA
	FUNC|SHFT|0x50,		mvdnwind,
	FUNC|SHFT|0x48,		mvupwind,
	FUNC|META|0x50,		forwparag,
	FUNC|META|0x48,		backparag,
#endif
	FUNC|0x61,		undo,   	/* Undo */
	FUNC|SHFT|0x61,		flush_kbuf,
     ED|FUNC|0x53,		fbdel,		/* Del */
     ED|FUNC|SHFT|0x53,		kill,
	CTLX|FUNC|0x53,		togdeldir,
     ED|FUNC|0x0E,		backdel,	/* Backspace */
     ED|FUNC|SHFT|0x0E,		bkill,
#if	EXTRA
     ED|FUNC|META|0x53,		fbwdel,		/* Delete */
     ED|FUNC|META|0x0E,		delbword,	/* Backspace */
#endif
	FUNC|0x47,		reposition,	/* Clr/Home  */
	FUNC|SHFT|0x47,		negrepos,	/* w/shift   */
	FUNC|META|0x47,		gotobob,	/* Esc-Home  */
	FUNC|SHFT|0x77,		gotoeob,	/* Ctrl-Home */
     ED|FUNC|0x52,		openline,	/* Insert */
#if EXTRA
     ED|FUNC|SHFT|0x52,		deblank,
#endif
	FUNC|0x3B,		ctlxe,		/* F1  */
	FUNC|SHFT|0x3B,		defmacro,
	FUNC|0x3C,		usebuffer,	/* F2  */
	FUNC|SHFT|0x3C,		filevisit,
	FUNC|0x3D,		fileread,	/* F3  */
	FUNC|SHFT|0x3D,		filewrite,
     ED|FUNC|0x3E,		kill,		/* F4  */
     ED|FUNC|SHFT|0x3E,		killregion,
     ED|FUNC|0x3F,		yank,		/* F5  */
	FUNC|SHFT|0x3F,		copyregion,
	FUNC|0x40,		backsearch,	/* F6  */
	FUNC|SHFT|0x40,		back_brace,
	FUNC|0x41,		forwsearch,	/* F7  */
	FUNC|SHFT|0x41,		forw_brace,
	FUNC|0x42,		backpage,	/* F8  */
	FUNC|SHFT|0x42,		back_nextw,
	FUNC|0x43,		forwpage,	/* F9  */
	FUNC|SHFT|0x43,		page_nextw,
	FUNC|0x44,		setmark,	/* F10 */
	FUNC|SHFT|0x44,		swapmark,
#if	HELP
	FUNC|0x62,		help,		/* Help */
#else
	FUNC|0x62,		listbuffers,
#endif
	FUNC|SHFT|0x62,		listbuffers,
    /* Alt to act as Ctrl-X-Ctrl: */
	FUNC|SHFT|0x12,		editog,		/* Alt-E */
     ED|FUNC|SHFT|0x14,		ltwiddle,	/* Alt-T */
	FUNC|SHFT|0x2D,		swapmark,	/* Alt-X */
    /* Alt to act as Ctrl-X: */
	FUNC|SHFT|0x83,		showcpos,
	FUNC|SHFT|0x78,		onlywind,
	FUNC|SHFT|0x79,		splitwind,
	FUNC|SHFT|0x30,		usebuffer,
     ED|FUNC|SHFT|0x21,		reformat,
	FUNC|SHFT|0x25,		killbuffer,
     ED|FUNC|SHFT|0x26,		setlmargin,
	FUNC|SHFT|0x32,		defmacro,
	FUNC|SHFT|0x31,		nextwind,
	FUNC|SHFT|0x19,		prevwind,
     ED|FUNC|SHFT|0x13,		setfillcol,
	FUNC|SHFT|0x10,		visitog,
     ED|FUNC|SHFT|0x1F,		filesave,
	FUNC|SHFT|0x2F,		filevisit,
    /* Other Alt- functions: */
	FUNC|SHFT|0x2E,		casestog,	/* Alt-C */
	FUNC|SHFT|0x20,		spawncli,	/* Alt-D */
	FUNC|SHFT|0x22,		gotolinum,	/* Alt-G */
     ED|FUNC|SHFT|0x17,		instog,		/* Alt-I */
     ED|FUNC|SHFT|0x18,		openline,	/* Alt-O */
     ED|FUNC|SHFT|0x11,		copyregion,	/* Alt-W */
     ED|FUNC|SHFT|0x15,		yank,		/* Alt-Y */
	FUNC|SHFT|0x80,		back_brace,	/* Alt-( */
	FUNC|SHFT|0x81,		forw_brace,	/* Alt-) */
#if CANLOG
	FUNC|SHFT|0x7E,		doplay,		/* Alt-7 */
#endif
#if	EXTRA
	FUNC|SHFT|0x7D,		enlargewind,	/* Alt-^ */
#endif
    /* Still available:
	FUNC|SHFT|0x23,		Alt-H
	FUNC|SHFT|0x24,		Alt-J
	FUNC|SHFT|0x16,		Alt-U
	FUNC|SHFT|0x2C,		Alt-Z
	FUNC|SHFT|0x7A,		Alt-3
	FUNC|SHFT|0x7B,		Alt-4
	FUNC|SHFT|0x7C,		Alt-5
	FUNC|SHFT|0x7F,		Alt-8
	FUNC|SHFT|0x82,		Alt '-'

	FUNC|SHFT|0x??,		spawn,		Alt-?
     */
#endif	AtST

#if	MSDOS					/* mb: added */

	FUNC|0x4B,		backchar,	/* <-- */
	FUNC|0x73,		backword,	/* ^<- */
	FUNC|META|0x4B,		gotobol,
	FUNC|0x4D,		forwchar,	/* --> */
	FUNC|0x74,		forwword,	/* ^-> */
	FUNC|META|0x4D,		gotoeol,
	FUNC|0x50,		forwline,
	FUNC|0x48,		backline,
     ED|FUNC|0x53,		fbdel,		/* Del */
	CTLX|FUNC|0x53,		togdeldir,
#if	EXTRA
     ED|FUNC|META|0x53,		fbwdel,		/* Esc-Del */
#endif
	FUNC|0x49,		backpage,	/* PgUp  */
	FUNC|0x84,		back_nextw,	/* ^PgUp */
	FUNC|0x51,		forwpage,	/* PgDn  */
	FUNC|0x76,		page_nextw,	/* ^PgDn */
	FUNC|0x47,		reposition,	/* Home  */
	FUNC|0x4F,		negrepos,	/* End   */
	FUNC|0x77,		gotobob,	/* ^Home    */
	FUNC|0x75,		gotoeob,	/* ^End     */
	FUNC|META|0x47,		gotobob,	/* Esc-Home */
	FUNC|META|0x4F,		gotoeob,	/* Esc-End  */
     ED|FUNC|0x52,		openline,	/* Insert */
#if	HELP
	FUNC|0x3B,		help,		/* F1  */
#else
	FUNC|0x3B,		listbuffers,
#endif
	FUNC|0x54,		listbuffers,	/* shift-F1 */
	FUNC|0x3C,		undo,   	/* F2 */
	FUNC|0x55,		flush_kbuf,
	FUNC|0x3D,		usebuffer,	/* F3  */
	FUNC|0x56,		filevisit,
	FUNC|0x3E,		fileread,	/* F4  */
	FUNC|0x57,		filewrite,
     ED|FUNC|0x3F,		kill,		/* F5  */
     ED|FUNC|0x58,		killregion,
     ED|FUNC|0x40,		yank,		/* F6  */
	FUNC|0x59,		copyregion,
	FUNC|0x41,		backsearch,	/* F7  */
	FUNC|0x5A,		back_brace,
	FUNC|0x42,		forwsearch,	/* F8  */
	FUNC|0x5B,		forw_brace,
	FUNC|0x43,		setmark,	/* F9 */
	FUNC|0x5C,		swapmark,
	FUNC|0x44,		ctlxe,		/* F10 */
	FUNC|0x5D,		defmacro,
    /* Alt to act as Ctrl-X-Ctrl: */
	FUNC|0x12,		editog,		/* Alt-E */
     ED|FUNC|0x14,		ltwiddle,	/* Alt-T */
	FUNC|0x2D,		swapmark,	/* Alt-X */
    /* Alt to act as Ctrl-X: */
	FUNC|0x83,		showcpos,
	FUNC|0x78,		onlywind,
	FUNC|0x79,		splitwind,
	FUNC|0x30,		usebuffer,
     ED|FUNC|0x21,		reformat,
	FUNC|0x25,		killbuffer,
     ED|FUNC|0x26,		setlmargin,
	FUNC|0x32,		defmacro,
	FUNC|0x31,		nextwind,
	FUNC|0x19,		prevwind,
     ED|FUNC|0x13,		setfillcol,
	FUNC|0x10,		visitog,
     ED|FUNC|0x1F,		filesave,
	FUNC|0x2F,		filevisit,
    /* Other Alt- functions: */
	FUNC|0x2E,		casestog,	/* Alt-C */
	FUNC|0x20,		spawncli,	/* Alt-D */
	FUNC|0x22,		gotolinum,	/* Alt-G */
     ED|FUNC|0x17,		instog,		/* Alt-I */
     ED|FUNC|0x18,		openline,	/* Alt-O */
     ED|FUNC|0x11,		copyregion,	/* Alt-W */
     ED|FUNC|0x15,		yank,		/* Alt-Y */
	FUNC|0x2C,		spawn,		/* Alt-Z */
	FUNC|0x80,		back_brace,	/* Alt-( */
	FUNC|0x81,		forw_brace,	/* Alt-) */
#if CANLOG
	FUNC|0x7E,		doplay,		/* Alt-7 */
#endif
#if	EXTRA
	FUNC|0x7D,		enlargewind,	/* Alt-^ */
#endif
    /* Still available:
	FUNC|0x23,		Alt-H
	FUNC|0x24,		Alt-J
	FUNC|0x16,		Alt-U
	FUNC|0x7A,		Alt-3
	FUNC|0x7B,		Alt-4
	FUNC|0x7C,		Alt-5
	FUNC|0x7F,		Alt-8
	FUNC|0x82,		Alt '-'
     */
#endif	MSDOS

#if	HELP					/* mb: added */
	META|'?',		help,
	META|CNTL|'[',		help,
#ifdef	HELPCH
	HELPCH,			help,
#endif
#endif	HELP

	0,			ctrlg
};

#define NKEYTAB (sizeof(keytab)/sizeof(keytab[0]))

usage()
{
#if AtST
	Cconws("\r\nGNOME version 2.1\r\n");
	Cconws("\r\nUsage: gnome [options] [file(s)]\r\n");
	Cconws("\r\nOptions:\r\n");
	Cconws("\t-c #\t# columns\r\n");
	Cconws("\t-f #\tfill column = #\r\n");
	Cconws("\t-f #-#\tleft & right margins\r\n");
	Cconws("\t-g #\tgoto line #\r\n");
	Cconws("\t-i\tinverse video\r\n");
#if CANLOG
#if LOGIT
	Cconws("\t-l\tdon't log keystrokes\r\n");
#else
	Cconws("\t-l\tlog keystrokes\r\n");
#endif
	Cconws("\t-p\tplay back log file\r\n");
#endif CANLOG
	Cconws("\t-r #\t# rows\r\n");
	Cconws("\t-t #\ttabsize = #\r\n");
	Cconws("\t-v\tview-only mode\r\n\n");
	Cconws("\tPress any key ");
	Cnecin();
	_exit(0);
#endif AtST
#if MSDOS
	cputs("\r\nGNOME version 2.1\r\n");
	cputs("\r\nUsage: gnome [options] [file(s)]\r\n");
	cputs("\r\nOptions:\r\n");
	cputs("-c #    # columns\r\n");
	cputs("-d      BIOS, rather than direct, screen output\r\n");
	cputs("-f #    fill column = #\r\n");
	cputs("-f #-#  left & right margins\r\n");
	cputs("-g #    goto line #\r\n");
	cputs("-i      inverse video\r\n");
#if CANLOG
#if LOGIT
	cputs("-l      don't log keystrokes\r\n");
#else
	cputs("-l      log keystrokes\r\n");
#endif
	cputs("-m #    text mode #\r\n");
	cputs("        (0=BW40, 1=C40, 2=BW80, 3=C80, 7=MONO\r\n");
	cputs("-p      play back log file\r\n");
#endif CANLOG
	cputs("-r #    # rows\r\n");
	cputs("-t #    tabsize = #\r\n");
	cputs("-v      view-only mode\r\n\n");
	_exit(0);
#endif
#if (V7 | VMS | CPM)
	puts("\nGNOME version 2.1");
	puts("\nUsage: gnome [options] [file(s)]");
	puts("Options:");
	puts("\t-c #\t# columns");
	puts("\t-f #\tfill column = #");
	puts("\t-f #-#\tleft & right margins");
	puts("\t-g #\tgoto line #");
#if CANLOG
#if LOGIT
	puts("\t-l\tdon't log keystrokes");
#else
	puts("\t-l\tlog keystrokes");
#endif
	puts("\t-p\tplay back log file");
#endif CANLOG
	puts("\t-r #\t# rows");
	puts("\t-t #\ttabsize = #");
	puts("\t-v\tview-only mode");
#if V7
#if CANLOG
	puts("\nSuggested: setenv GNOMELOG /myrootdir/.gnomelog");
#endif
#endif
	exit(0);
#endif
}

main(argc, argv)		/* mb: completely rewritten */
	int	argc;
	char	*argv[];
{
	register int	c;
	register int	f;
	register int	n;
	register int	state;
	int	negarg;
	int	gline = 1;
	int	visitmode = FALSE;
	char	*cp;

	maxnfiles = argc + 32;
	if ((clfn = (char **) malloc (maxnfiles * sizeof(char *))) == NULL)
#if BFILES
		_exit (1);
#else
		exit (1);
#endif
	nfiles = 0;
	while(--argc > 0 && ++argv != NULL) {
		cp = *argv;
		if(*cp == '-') {	/* cmd line parameter */
			f = *(++cp);
			if (f >= 'a' && f <= 'z')
				f += ('A' - 'a');
			if (f && cp[1]=='\0'	/* space before number   */
			 && argc > 1 && argv[1] != NULL
			 && (c=argv[1][0])>='0' && c<='9') {
				if (f=='C' || f=='F' || f=='G'
				 || f=='R' || f=='T') {
					--argc;
					++argv;
					cp = (*argv) - 1;
				}
			}
			n = 0;
			while (f && (c=(*(++cp)))>='0' && c<='9')
				n = 10*n + (c-'0');
			if (f == 'C')
				term.t_ncol = n;
			else if (f == 'F') {
				if (c == '-') {
					lmargin = n;
					n = 0;
					while (f &&
						(c=(*(++cp)))>='0' && c<='9')
							n = 10*n + (c-'0');
				}
				fillcol = n;
				if (lmargin + tabsize > fillcol)
					lmargin = fillcol = 0;
			}
#if MSDOS
			else if (f == 'D')
				directvideo = FALSE;
#endif
			else if (f == 'G')
				gline = n;
#if (AtST | MSDOS)
			else if (f == 'I')
				vidrev = TRUE;
#endif
#if CANLOG
			else if (f == 'L')
				logit = (!logit);
			else if (f == 'P')
				playback = TRUE;
#endif CANLOG
#if MSDOS
			else if (f == 'M') {
				if ((n>=0 && n<=3) || n==7)
					vidmode = n;
			}
#endif
			else if (f == 'R')
				term.t_nrow = n-1;
			else if (f == 'T')
				tabsize = n;
			else if (f == 'V')
				visitmode = TRUE;
			else
				usage();
		} else {		/* a filename */
			clfn[nfiles++] = cp;
		}
	}
#if MSDOS
	if (vidmode==0 || vidmode==1) {
		if (term.t_ncol > 40)
			term.t_ncol = 40;
	}
#endif
	vtinit();
	if (nfiles) {
		cp = clfn[0];
		edinit(cp);
		strcpy(curbp->b_fname, cp);
		update(TRUE);
		if (readin(cp) == FIOFNF)
			mlwrite("[New file]");
		if (visitmode) {
			curbp->b_flag &= (~BFEDIT);
			logit = FALSE;
		}
		fileindex = 1;
		if (nfiles == 2) {
			edmore(clfn[1]);
			fileindex = 2;
		}
	} else {				/* no filename given */
		edinit("main");
		fileindex = 0;
	}
	gotolinum(TRUE,gline);
	kbdm[0] = CTLX|')';			/* Empty macro		*/
	lastflag = 0;				/* Fake last flags.	*/
	f = FALSE;
	n = 1;
	negarg = FALSE;
	update(TRUE);
	c = getkey();
	while (c==(CNTL|'Q') || c==(CNTL|'S'))
		c = getkey();			/* mb: dump handshakes	*/
	if (c != NOKEY)
		mlerase();
	state = BASE;

	for(;;) {				/* main loop */

	if (c == NOKEY) {	/* mb: happens after errors in getkey() */
		update(FALSE);
		c = getkey();
		continue;
	}

	switch (state) {

	case BASE:
		if (c==(CNTL|'U')) {
			n = 4;
			mlwrite("arg: 4");
			c = getkey();
			state = ARG;
			break;
		}
		if (c == METACH) {
			c = getkey();
			state = ESC;
			break;
		}
		if (c == (CNTL|'X')) {
			c = getkey();
#if AtST
			if (c==(FUNC|0x61) || c==(CNTL|'G')) { /* Undo */
#endif
#if MSDOS
			if (c==(FUNC|0x3C) || c==(CNTL|'G')) { /* F2 */
#endif
#if (V7 | VMS | CPM)
			if (c == (CNTL|'G')) {
#endif
				c = getkey();
				break;
			}
			if (c>='a' && c<='z')
				c -= 0x20;	/* force upper case */
			c |= CTLX;
		}
		state = EXEC;
		break;

	case ESC:
		if (c=='-' || (c>='0' && c<='9')) {
			state = ARG;
			break;
		}
#if  VT100
		if (c=='[' || c=='O') {
			state = EXEC;
			c = escseq(c);
			if (! c) {
				c = getkey();
				state = BASE;
			}
			break;
		}
#endif
#if AtST
		if (c==(FUNC|0x61) || c==(CNTL|'G')) {	/* Undo */
#endif
#if MSDOS
		if (c==(FUNC|0x3C) || c==(CNTL|'G')) {  /* F2 */
#endif
#if (V7 | VMS | CPM)
		if (c == (CNTL|'G')) {
#endif
			c = getkey();
			state = BASE;
			break;
		}
		if (c>='a' && c<='z')
			c -= 0x20;		/* force upper case */
		c |= META;
		state = EXEC;
		break;

	case ARG:
		if (c == (CNTL|'U')) {
			n *= 4;
		} else if (c=='-' && f==FALSE) {
			negarg = TRUE;
			n = (-1);
		} else if  (c==(CNTL|'H')  || c==(CNTL|0x3F)
#if AtST
			 || c==(FUNC|0x0E) || c==(FUNC|0x53)
#endif
#if MSDOS
			 || c==(FUNC|0x53)
#endif
							) {
			n /= 10;
			if (n == 0)
				negarg = FALSE;
#if AtST
		} else if (c==(FUNC|0x61) || c==(CNTL|'G')) { /* Undo */
#endif
#if MSDOS
		} else if (c==(FUNC|0x3C) || c==(CNTL|'G')) {  /* F2 */
#endif
#if (V7 | VMS | CPM)
#else
		} else if (c == (CNTL|'G')) {
#endif
			f = FALSE;
			n = 1;
			mlwrite("[aborted]");
			update(FALSE);		/* put cursor back */
			c = getkey();
			state = BASE;
			break;
		} else if (c>='0' && c<='9') {
			if (f == FALSE) {
				n = 0;
				f = TRUE;
			}
			n = 10*n + ((negarg) ? ('0'-c) : (c-'0'));
		} else {
			state = BASE;
			f = TRUE;
			break;
		}
		mlwrite("arg: %d",n);
		c = getkey();
		break;

	case EXEC:
#if V7
		if (c == (META|'Q')) {
			c = getkey();
			if (c & CNTL)
				c ^= 0x40;
			c &= 0xFF;
		}
#else
		if (c == (CNTL|'Q') || c == (META|'Q')) {
			c = getkey();
			if (c & CNTL)
				c ^= 0x40;
			c &= 0xFF;
		}
#endif
		if (kbdmip != NULL) {		/* Save macro strokes.  */
			if (c!=(CTLX|')') && kbdmip>&kbdm[NKBDM-6]) {
				ctrlg();
				c = getkey();
				state = BASE;
				break;
			}
			if (f != FALSE) {
				*kbdmip++ = (CNTL|'U');
				*kbdmip++ = n;
			}
			*kbdmip++ = c;
		}
		execute(c, f, n);		/* Do it, finally */
		f = FALSE;
		n = 1;
		negarg = FALSE;
		update(FALSE);			/* Fix up the screen	*/
		c = getkey();
		if (c != NOKEY && mpresf != FALSE) {
			mlerase();
		}
		state = BASE;
		break;

	default:				/* bug if you're here */

#if BFILES
		_exit(1);
#else
		exit(1);
#endif

	}					/* end of switch */
	}					/* end of for()  */
}						/* end of main() */

/*
 * Initialize all of the buffers
 * and windows. The file name is passed down as
 * an argument, because the main routine may have been
 * told to read in a file by default, and we want the
 * buffer name to be right.
 */
edinit(fname)
	char	fname[];
{
	register BUFFER *bp;
	register WINDOW *wp;
	char	bname[NBUFN];

	makename(bname, fname);
	bp = bfind(bname, TRUE, BFEDIT);	/* First buffer		*/
	blistp = bfind("[List]", TRUE, BFTEMP); /* Buffer list buffer	*/
	bhelpp = bfind("[Help]", TRUE, BFTEMP); /* Help screens buffer	*/
	wp = (WINDOW *) malloc(sizeof(WINDOW)); /* First window		*/
	if (bp==NULL || wp==NULL || blistp==NULL || bhelpp==NULL)
#if BFILES
		_exit(1);
#else
		exit(1);
#endif
	curbp  = bp;				/* Make this current	*/
	wheadp = wp;
	curwp  = wp;
	wp->w_wndp  = NULL;			/* Initialize window	*/
	wp->w_bufp  = bp;
	bp->b_nwnd  = 1;			/* Displayed.		*/
	wp->w_linep = bp->b_linep;
	wp->w_dotp  = bp->b_linep;
	wp->w_doto  = 0;
	wp->w_markp = NULL;
	wp->w_marko = 0;
	wp->w_toprow = 0;
	wp->w_ntrows = term.t_nrow-1;		/* "-1" for mode line.  */
	wp->w_force = 0;
	wp->w_offset = 0;
	wp->w_flag  = WFMODE|WFHARD;		/* Full.		*/
}

/*
 *  mb: Display another file in another window.
 *      Called only if a second filename appears in command line.
 */
edmore(fname)
	char	fname[];
{
	register BUFFER *bp;
	char	bname[NBUFN];

	makename(bname, fname);
	if (bfind(bname, FALSE, 0))	/* buffer with that name exists */
		strcpy (bname, "[same as another]");
	bp = bfind(bname, TRUE, 0);	/* create second buffer 	*/
	if ( bp == NULL
	  || splitwind(0,1) != TRUE	/* display it in a 2nd window	*/
	  || nextwind(0,1)  != TRUE)
		return;
	gotobuf(bp);
	strcpy(bp->b_fname, fname);
	if (readin(fname) == FIOEOF) {
		curwp->w_flag |= WFMODE|WFFORCE|WFHARD;
		mlwrite("[two files]");
	} else
		mlwrite("Error reading second file!");
	prevwind(0,1);
}

#if  VT100
int
escseq(c)
	register int c;
{ 
	if (c=='[' || c=='O') {		/* Arrows and extras.	*/
		c = getkey();
		if (c == 'A')
			return (CNTL | 'P');
		if (c == 'B')
			return (CNTL | 'N');
		if (c == 'C')
			return (CNTL | 'F');
		if (c == 'D')
			return (CNTL | 'B');
		if (c == 'P')	/* PF1 */
			return (META | 'B');
		if (c == 'Q')	/* PF2 */
			return (META | 'F');
		if (c == 'R')	/* PF3 */
			return (META | '.');
		if (c == 'S')	/* PF4 */
			return (CTLX | 'E');
		/* else */
			return (0);
	}
	return (0);
}
#endif

/*
 * This is the general command execution
 * routine. It handles the fake binding of all the
 * keys to "self-insert". It also clears out the "thisflag"
 * word, and arranges to move it to the "lastflag", so that
 * the next command can look at it. Return the status of
 * command.
 * mb: added the BFEDIT / ED stuff.
 */
int
execute(c, f, n)
	register int	c;
{
	register KEYTAB *ktp;
	register int	k;
	register int	d;
	register int	status;

	if ((c & 0xFF00) == 0)
		goto ascii;
	d = c;
	if (curbp->b_flag & BFEDIT)
		d |= ED;
	ktp = &keytab[0];			/* Look in key table.	*/
	while (ktp < &keytab[NKEYTAB]) {
		k = ktp->k_code;
		if (k==c || k==d) {		/* mb: fit, ED| or not */
			thisflag = 0;
			status   = (*ktp->k_fp)(f, n);
			lastflag = thisflag;
			return (status);
		}
		++ktp;
	}
	if (c != d) {
#if GDEBUG
		mlwrite("No such command (code 0x%x)", c);
#else
		mlwrite("No such command");
#endif
		return (FALSE);
	} /* else fall thru to "view-only" message */
ascii:
	if (! (curbp->b_flag & BFEDIT)) {
#if (AtST | MSDOS)
		mlwrite("View-only mode - Alt-E to edit");
#else
		mlwrite("View-only mode - ^X^E to edit");
#endif
		lastflag = 0;			/* Fake last flags.	*/
		return(FALSE);
	}

	/* mb:
	 * If fill column is defined, the argument is positive,
	 * and we are now past fill column, perform word wrap.
	 * Don't insert a space if just wrapped.
	 */
	if (fillcol>0 && n>0 && getccol(FALSE)>=fillcol) {
		wrapword(c);
		if (c == ' ') {
			lastflag = 0;
			return (FALSE);
		}
	}
					/* mb: skipped the ASCII check	*/
	if (n <= 0) {				/* Fenceposts.		*/
		lastflag = 0;
		return (n<0 ? FALSE : TRUE);
	}
	thisflag = 0;				/* For the future.	*/
	status   = linsert(n, c, ovrstrk);	/* mb: added param	*/
	lastflag = thisflag;
	return (status);
}

/*
 * Read in a key.
 * Convert ctrl keys to the internal character set.
 * mb: simplified, but added the log file stuff.
 */
int
getkey() {
	register int c, ub, lb;

#if CANLOG
	if (playback == TRUE) {
		if (ropenlog() == ABORT) {
			playback = ABORT;
			mlwrite("\007Unable to open log file");
			return (NOKEY);
		}
		ub = getlog();
		if (ub != EOF)
			lb = getlog();
		if (ub==EOF || lb==EOF) {
			closelog();
			playback = ABORT;
			mlwrite("[playback done]");
			return (NOKEY);
		}
		c = lb & 0xFF;
		c |= (ub & 0xFF) << 8;
		return (c);
	}

	if (!logit || playback==ABORT)
		goto logok;		/* don't log after playback */

	if (wopenlog() == ABORT) {
		playback = ABORT;
		mlwrite("\007Unable to open log file");
		return (NOKEY);
	}
#endif CANLOG

logok:

	c = (*term.t_getchar)();
#ifdef CNTLCH
	if (c == CNTLCH) {			/* Apply C- prefix	*/
		c = (*term.t_getchar)();
		if (c>='a' && c<='z')		/* Force to upper	*/
			c -= 0x20;
		c |= CNTL;
	}
#endif
#if AtST
	if (c == (FUNC|SHFT|0x1E)) {		/* Alt-A */
		c = (*term.t_getchar)() & 0xFF;
		c |= 0x80;		/* set MSB: alternate char set */
	}
#endif
#if MSDOS
	if (c == (FUNC|0x1E)) {			/* Alt-A */
		c = (*term.t_getchar)() & 0xFF;
		c |= 0x80;		/* set MSB: alternate char set */
	}
#endif
	/* control -> CNTL */
	if ((!(FUNC&c)) && (c<0x20 || c==0x7F))
		c = CNTL | (c ^ 0x40);
#if CANLOG
	if (!logit || playback==ABORT)
		goto nolog;		/* don't log after playback */

	lb = c & 0xFF;
	ub = (c>>8) & 0xFF;
	ub = putlog (ub);
	lb = putlog (lb);
	if (ub==EOF || lb==EOF) {
		closelog();
		playback = ABORT;
		mlwrite("\007Error writing log file");
		return (NOKEY);
	}
	flushlog(FALSE);		/* flushes only when full */
#endif CANLOG
nolog:
	return (c);
}

#if CANLOG
/*
 * mb: turn on playback from inside the editor.
 */
int
doplay(f,n)
{
	register int c, s;
	char buf[80];

	if (playback == TRUE)
		return (FALSE);
	s = mlreply("Playback? (y/n)", "no", buf, 80, FALSE);
	if (s==TRUE && ((c=buf[0])=='y' || c=='Y')) {
		if (logit == TRUE) {
			flushlog();
			closelog();
		}
		logit = FALSE;
		playback = TRUE;
		return (TRUE);
	}
	return (ctrlg());
}
#endif CANLOG

/*
 * Fancy quit command, as implemented
 * by Norm. If the current buffer has changed
 * do a write current buffer and exit emacs,
 * otherwise simply exit.
 */
int
quickexit(f,n)
{
	if ((curbp->b_flag&BFCHG) != 0		/* Changed.		*/
	&& (curbp->b_flag&BFTEMP) == 0)		/* Real.		*/
		if (filesave(f, n) != TRUE)
			return (FALSE);
	return (quit(f, n));			/* conditionally quit	*/
}

/*
 * Quit command. If an argument, always
 * quit. Otherwise confirm if a buffer has been
 * changed and not written out. Normally bound
 * to "C-X C-C".
 */
int
quit(f, n)
{
	register int	s;
#if CANLOG
	if (playback == TRUE)
		return (FALSE);
#endif CANLOG
	if (f != FALSE				/* Argument forces it.  */
	|| anycb() == FALSE			/* All buffers clean.	*/
	|| (s=mlyesno("Discard changes")) == TRUE) {   /* User says OK. */
#if CANLOG
		if (logit == TRUE) {
			flushlog(TRUE);
			closelog();
		}
#endif CANLOG
		vttidy();
#if BFILES
		_exit(0);
#else
		exit(0);
#endif
	}
	mlwrite("[aborted]");	
	return (s);
}

/* mb: added */
int
emacs_quit(f, n) {
	if (f)
		return(quickexit(FALSE, 1));
	else
		return(quit(f, n));
}

/*
 * Begin a keyboard macro.
 * Error if not at the top level
 * in keyboard processing. Set up
 * variables and return.
 */
int
ctlxlp(f, n)
{
	if (kbdmip!=NULL || kbdmop!=NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	mlwrite("[Start macro]");
	kbdmip = &kbdm[0];
	return (TRUE);
}

/*
 * End keyboard macro. Check for
 * the same limit conditions as the
 * above routine. Set up the variables
 * and return to the caller.
 */
int
ctlxrp(f, n)
{
	if (kbdmip == NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	*(--kbdmip) = CTLX|')';		/* in case CTLX|'M' */
	mlwrite("[End macro]");
	kbdmip = NULL;
	return (TRUE);
}

/* mb: added.
 */
int
defmacro(f, n)
{
	if (kbdmip == NULL)
		return (ctlxlp(f, n));
	else
		return (ctlxrp(f, n));
}

/*
 * Execute a macro.
 * The command argument is the
 * number of times to loop. Quit as
 * soon as a command gets an error.
 * Return TRUE if all ok, else
 * FALSE.
 */
int
ctlxe(f, n)
{
	register int	c;
	register int	af;
	register int	an;
	register int	s;

	if (kbdmip!=NULL || kbdmop!=NULL) {
		mlwrite("Not now");
		return (FALSE);
	}
	if (n <= 0) 
		return (TRUE);
	do {
		kbdmop = &kbdm[0];
		do {
			af = FALSE;
			an = 1;
			if ((c = *kbdmop++) == (CNTL|'U')) {
				af = TRUE;
				an = *kbdmop++;
				c  = *kbdmop++;
			}
			s = TRUE;
		} while (c!=(CTLX|')') && (s=execute(c, af, an))==TRUE);
		kbdmop = NULL;
	} while (s==TRUE && --n);
	return (s);
}

/*
 * Abort.
 * Beep the beeper.
 * Kill off any keyboard macro,
 * etc., that is in progress.
 * Sometimes called as a routine,
 * to do general aborting of
 * stuff.
 */
int
ctrlg()
{
	mlwrite("[aborted]");		/* mb: instead of beep */
	if (kbdmip != NULL) {
		kbdm[0] = (CTLX|')');
		kbdmip  = NULL;
	}
	return (ABORT);
}

/* mb: added the following functions */

int
negrepos(f, n)
{
	return (reposition (1, -n));
}

int
togdeldir(f, n)
{
	deldir = (! deldir);
	if (deldir)
		mlwrite("<Delete> backspaces");
	else
		mlwrite("<Delete> deletes forward");
	return (TRUE);
}

int
fbdel(f, n)
{
	if (deldir)
		return (backdel(f, n));
	else
		return (forwdel(f, n));
}

#if EXTRA
int
fbwdel(f, n)
{
	if (deldir)
		return (delbword(f, n));
	else
		return (delfword(f, n));
}
#endif

int
undo(f, n)
{
	if ((lastflag&CFKILL))		/* If last command was Kill */
		return (yank(0, 1));
	if ((lastflag&CFYANK))		/* If last command was Yank */
		return (unyank(0, 1));
	if ((lastflag&CFSPLIT))		/* After help or buflist */
		return (onlywind(0, 1));
	if (kbdmip != NULL)		/* Inside macro definition */
		return (ctrlg(f,n));
	else
		return (ABORT);
}
 
