/* functions.c of gulam+ue -- key to function bindings

  Most of this file is borrowed from MicroGnuEmacs.  Many thanks. -- pm
*/

#include	"ue.h"

/*
 * Defined by "ue.c".
 */
extern	int	ctrlg();		/* Abort out of things		*/
extern	int	quit();			/* Quit				*/
extern	int	ctlxlp();		/* Begin macro			*/
extern	int	ctlxrp();		/* End macro			*/
extern	int	ctlxe();		/* Execute macro		*/

/*
 * Defined by "search.c".
 */
extern	int	forwsearch();		/* Search forward		*/
extern	int	backsearch();		/* Search backwards		*/
extern  int	searchagain();		/* Repeat last search command	*/
extern  int	queryrepl();		/* Query replace		*/

/*
 * Defined by "basic.c".
 */
extern	int	gotobol();		/* Move to start of line	*/
extern	int	backchar();		/* Move backward by characters	*/
extern	int	gotoeol();		/* Move to end of line		*/
extern	int	forwchar();		/* Move forward by characters	*/
extern	int	gotobob();		/* Move to start of buffer	*/
extern	int	gotoeob();		/* Move to end of buffer	*/
extern	int	forwline();		/* Move forward by lines	*/
extern	int	backline();		/* Move backward by lines	*/
extern	int	forwpage();		/* Move forward by pages	*/
extern	int	backpage();		/* Move backward by pages	*/
extern	int	pagenext();		/* Page forward next window	*/
extern	int	setmark();		/* Set mark			*/
extern	int	swapmark();		/* Swap "." and mark		*/
extern	int	gotoline();		/* Go to a specified line.	*/

/*
 * Defined by "buffer.c".
 */
extern	int	listbuffers();		/* Display list of buffers	*/
extern	int	usebuffer();		/* Switch a window to a buffer	*/
extern	int	poptobuffer();		/* Other window to a buffer	*/
extern	int	killbuffer();		/* Make a buffer go away.	*/
extern	int	savebuffers();		/* Save unmodified buffers	*/
extern	int	bufferinsert();		/* Insert buffer into another	*/

/*
 * Defined by "error.c".
 */
extern	int	errfwd();		/* Find an error forward	*/

/*
 * Defined by "file.c".
 */
extern	int	filevisit();		/* Get a file, read write	*/
extern	int	filewrite();		/* Write a file			*/
extern	int	filesave();		/* Save current file		*/
extern	int	fileinsert();		/* Insert file into buffer	*/

/*
 * Defined by "match.c"
 */
extern	int	blinkparen();		/* Fake blink-matching-paren var */
extern	int	showmatch();		/* Hack to show matching paren	 */

/*
 * Defined by "random.c".
 */
extern	int	selfinsert();		/* Insert character		*/
extern	int	showcpos();		/* Show the cursor position	*/
extern	int	twiddle();		/* Twiddle characters		*/
extern	int	quote();		/* Insert literal		*/
extern	int	openline();		/* Open up a blank line		*/
extern	int	newline();		/* Insert CR-LF			*/
extern	int	deblank();		/* Delete blank lines		*/
extern	int	delwhite();		/* Delete extra whitespace	*/
extern	int	indent();		/* Insert CR-LF, then indent	*/
extern	int	tab();			/* insert \t; or, set tabsize	*/
extern	int	forwdel();		/* Forward delete		*/
extern	int	backdel();		/* Backward delete in		*/
extern	int	lbackdel();		/* line-backward-delete		*/
extern	int	lbackchar();		/* line-backward-character	*/
extern	int	lforwdel();		/* line-delete-next-character	*/
extern	int	lforwchar();		/* line-forward-character	*/
extern	int	kill();			/* Kill forward			*/
extern	int	yank();			/* Yank back from killbuffer.	*/

/*
 * Defined by "region.c".
 */
extern	int	killregion();		/* Kill region.			*/
extern	int	copyregion();		/* Copy region to kill buffer.	*/
extern	int	lowerregion();		/* Lower case region.		*/
extern	int	upperregion();		/* Upper case region.		*/
extern	int	prefixregion();		/* Prefix all lines in region	*/
extern	int	setprefix();		/* Set line prefix string	*/

/*
 * Defined by "window.c".
 */
extern	int	reposition();		/* Reposition window		*/
extern	int	refresh();		/* Refresh the screen		*/
extern	int	nextwind();		/* Move to the next window	*/
extern  int	prevwind();		/* Move to the previous window	*/
extern	int	onlywind();		/* Make current window only one	*/
extern	int	splitwind();		/* Split current window		*/
extern	int	delwind();		/* Delete current window	*/
extern	int	enlargewind();		/* Enlarge display window.	*/
extern	int	shrinkwind();		/* Shrink window.		*/


/*
 * defined by "paragraph.c" - the paragraph justification code.
 */
extern	int	gotobop();		/* Move to start of paragraph.	*/
extern	int	gotoeop();		/* Move to end of paragraph.	*/
extern	int	fillpara();		/* Justify a paragraph.		*/
extern	int	killpara();		/* Delete a paragraph.		*/
extern	int	setfillcol();		/* Set fill column for justify.	*/
extern	int	fillword();		/* Insert char with word wrap.	*/
/*
 * Defined by "word.c".
 */
extern	int	backword();		/* Backup by words		*/
extern	int	forwword();		/* Advance by words		*/
extern	int	upperword();		/* Upper case word.		*/
extern	int	lowerword();		/* Lower case word.		*/
extern	int	capword();		/* Initial capitalize word.	*/
extern	int	delfword();		/* Delete forward word.		*/
extern	int	delbword();		/* Delete backward word.	*/

/*
 * Defined by "extend.c".
 */
extern	int	extend();		/* Extended commands.		*/
extern	int	desckey();		/* Help key.			*/
extern	int	bindtokey();		/* Modify key bindings.		*/
extern	int	unsetkey();		/* Unbind a key.		*/
extern	int	wallchart();		/* Make wall chart.		*/

/*
 * defined by prefix.c
 */
extern	int	help();			/* Parse help key.		*/
extern	int	ctlx4hack();		/* Parse a pop-to key.		*/

extern int	escctrld();
extern int	escesc();
extern int	miniterm();
extern int	filename();
extern int	gxpand();
extern int	gxpshow();
extern int	togulambuf();
extern int	execbuf();
extern int	fileread();
extern int	showkbdmacro();
extern int	temul();
extern int	totebuf();
extern int	tenewline();
extern int	tesendtext();
extern int	mvupwind();
extern int	mvdnwind();
extern int	quickexit();
extern int	tempexit();
extern int	gforwline();
extern int	gulam();
extern int	quit();
extern int	ctrlg();
extern int	ctlxlp();
extern int	ctlxrp();
extern int	spawn();
extern int	keyreset();		/* keymap.c	*/
extern int	semireset();
extern int	killtobln();
extern int	getarg();
extern int	metanext();
extern int	ctlxnext();

static char	snoop[] = "no-op";

noop()
{
}

/* function-code-ptr : function-string0name table ::= Ideally there should
 be no duplicates; but, it does not hurt.  The order of these functions
 has no effect on efficiency; they are grouped for their logical togetherness.
 DO NOT change the content, or order of these by hand.  This is generated by
 kbgen.tos from data in kbin.000, and is coupled to the #defines used in kb.c
*/
#if	00
typedef	struct
{	int	(*funcp)();		/* ptr to function		*/
/**	char	*funcname;		**/
}	FPFS;
#endif

FPFS	fpfs[] 
= {
/* 00 */	noop,		/* snoop,	*/
		escctrld,	/* "show-possible-expansions", */
		escesc,		/* "expand-name", */
		miniterm,	/* "terminate-mini-buffer", */
		filename,	/* "file-name", */
		gxpand,		/* "expand-name-gulam-style", */
		togulambuf,	/* "switch-to-gulam-buffer", */
		execbuf,	/* "execute-buffer", */
		fileread,	/* "read-file", */
		showkbdmacro,	/* "show-key-board-macro", */
/* 10 */	temul,		/* "terminal-emulator", */
		mvupwind,	/* "move-window-up", */
		mvdnwind,	/* "move-window-dn", */
		quickexit,	/* "quick-exit", */
		tempexit,	/* "temporary-exit", */
		gforwline,	/* "gulam-forward-line", */
		gulam,		/* "gulam-do-newline", */
		tab,		/* "goto-next-tab", */
		quit,		/* "save-buffers-kill-emacs", */
		ctrlg,		/* "keyboard-quit", */
/* 20 */	help,		/* "help", */
		ctlxlp,		/* "start-kbd-macro", */
		ctlxrp,		/* "end-kbd-macro", */
		ctlxe,		/* "call-last-kbd-macro", */
		setfillcol,	/* , */
		refresh,	/* "redraw-display", */
		backchar,	/* "backward-char", */
		forwchar,	/* "forward-char", */
		backdel,	/* "backward-delete-char", */
		forwdel,	/* "delete-char", */
/* 30 */	gotobol,	/* "beginning-of-line", */
		gotoeol,	/* "end-of-line", */
		kill,		/* "kill-line", */
		forwline,	/* "next-line", */
		openline,	/* "open-line", */
		backline,	/* "previous-line", */
		newline,	/* "insert-newline", */
		indent,		/* "newline-and-indent", */
		gotoline,	/* "goto-line", */
		spawn,		/* "execute-one-Gulam-cmd", */
/* 40 */	killtobln,	/* */
		fillpara,	/* */
		noop,		/* snoop, */
		backsearch,	/* "search-backward", */
		forwsearch,	/* "search-forward", */
		lforwchar,	/* "line-forward-char", */
		lforwdel,	/* "line-delete-next-char", */
		queryrepl,	/* "query-replace", */
		setmark,	/* "set-mark-command", */
		selfinsert,	/* "self-insert", */
/* 50 */	reposition,	/* "recenter", */
		quote,		/* "quoted-insert", */
		twiddle,	/* "transpose-chars", */
		copyregion,	/* "copy-region-as-kill", */
		killregion,	/* "kill-region", */
		keyreset,	/* "keys-reset", */
		semireset,	/* */
		noop,		/* snoop, */
		noop,		/* snoop, */
		yank,		/* "yank", */
/* 60 */	fileinsert,	/* "insert-file", */
		filevisit,	/* "find-file", */
		filesave,	/* "save-buffer", */
		filewrite,	/* "write-file", */
		noop,		/* snoop, */
		deblank,	/* "delete-blank-lines", */
		swapmark,	/* "exchange-point-and-mark", */
		showcpos,	/* "what-cursor-position", */
		nextwind,	/* "next-window", */
		prevwind,	/* "previous-window", */
/* 70 */	shrinkwind,	/* "shrink-window", */
		enlargewind,	/* "enlarge-window", */
		noop,		/* snoop, */
		onlywind,	/* "delete-other-windows", */
		splitwind,	/* "split-window-vertically", */
		noop,		/* snoop */
		noop,		/* snoop, */
		bufferinsert,	/* "insert-buffer", */
		usebuffer,	/* "switch-to-buffer", */
/*
 * 79 was noop, now lbackdel, something I cooked up to backspace without
 * wrapping at the beginning of the line.  
 */
		lbackdel,	/* "line-backward-delete-char", */

/* 80 */	listbuffers,	/* "list-buffers", */
		killbuffer,	/* "kill-buffer", */
		savebuffers,	/* "save-some-buffers", */
/*
 * 83 was noop, now lbackchar, something I cooked up to go backwards
 * without wrapping at the beginning of the line.
 */
		lbackchar,	/* "line-backward-character", */
		gotoeob,	/* "end-of-buffer", */
		gotobob,	/* "beginning-of-buffer", */
		gotobop,	/* , */
		gotoeop,	/* , */
		noop,		/* , */
		delwhite,	/* "just-one-space", */
/* 90 */	backword,	/* "backward-word", */
		capword,	/* "capitalize-word", */
		delbword,	/* "kill-backward-word", */
		delfword,	/* "kill-word", */
		forwword,	/* "forward-word", */
		lowerword,	/* "downcase-word", */
		upperword,	/* "upcase-word", */
		forwpage,	/* "scroll-up", */
		backpage,	/* "scroll-down", */
		gxpshow,	/* "show-possible-completions", */
/* 100*/ 	noop,		/* snoop, */
		noop,		/* snoop, */
		noop,		/* snoop, */
		noop,		/* snoop, */
		noop,		/* snoop, */
		noop,		/* snoop, */
		noop,		/* snoop, */
		showmatch,	/* "blink-matching-paren-hack", */
		noop,		/* snoop, */
		noop, 		/* snoop, */
/* 110*/	desckey,	/* "describe-key-briefly", */
		wallchart,	/* "describe-bindings", */
		getarg,
		metanext,
		ctlxnext,
		tenewline,
		totebuf,
		tesendtext,
		errfwd,		/* "error-forward", */
		NULL,		/* NULL, */
};

/* -eof- */
