
/* token.h */

/*
 *  Tunable definitions
 *
 */
#define	LNSIZ		256	/* maximum size of a line of text */
#define	TOKBUFSIZE	400	/* size of token-line buffer */
#define	QUANTUM		4096L	/* #bytes to eat at a time from a file */
#define	LNBUFSIZ	(QUANTUM*2) /* size of file's buffer */
#define	KWSIZE		3	/* maximum size of keyword in kwtab.h */


/*
 *  Conditional assembly structures
 */
#define IFENT struct _ifent
IFENT {
	IFENT *if_prev;		/* -> previous .if state block (or NULL) */
	WORD if_state;		/* 0:enabled, 1=disabled */
};


/*
 * Include Files and Macros
 */
#define SRC_IFILE	0	/* input source is IFILE */
#define SRC_IMACRO	1	/* input source is IMACRO */
#define	SRC_IREPT	2	/* input source is IREPT */


#define IFILE struct _incldfile
#define IMACRO struct _imacro
#define	IREPT struct _irept
#define IUNION union _iunion

/*
 *  Pointer to IFILE or IMACRO
 */
IUNION {
	IFILE *ifile;
	IMACRO *imacro;
	IREPT *irept;
};


/*
 *  Ptr to IFILEs, IMACROs, and so on;
 *  back-ptr to previous input objects.
 */
#define INOBJ struct _inobj
INOBJ {
	WORD in_type;			/* 0=IFILE, 1=IMACRO ... */
	IFENT *in_ifent;		/* -> .if context on entry */
	INOBJ *in_link;		/* -> previous INOBJ */
	TOKEN *in_otok;		/* old `tok' value */
	TOKEN *in_etok;		/* old `etok' value */
	IUNION inobj;			/* IFILE or IMACRO ... */
};


/*
 *  Information about a file
 */
IFILE {
	IFILE *if_link;		/* -> ancient IFILEs */
	char *ifoldfname;		/* old file's name */
	int ifoldlineno;		/* old line number */
	int ifind;			/* = position in file buffer */
	int ifcnt;			/* = #chars left in file buffer */
	int ifhandle;			/* file's descriptor */
	WORD ifno;			/* file number */
	char ifbuf[LNBUFSIZ];		/* line buffer */
};


/*
 *  Information about a macro invocation
 *
 */
IMACRO {
	IMACRO *im_link;		/* -> ancient IMACROs */
	LONG *im_nextln;		/* -> next line to include */
	WORD im_nargs;		/* # of arguments supplied on invocation */
	WORD im_siz;			/* size suffix supplied on invocation */
	LONG im_olduniq;		/* old value of 'macuniq' */
	SYM *im_macro;		/* -> macro we're in */
	char im_lnbuf[LNSIZ];		/* line buffer */
};


/*
 *  Information about a .rept invocation
 *
 */
IREPT {
	LONG *ir_firstln;		/* -> first line */
	LONG *ir_nextln;		/* -> next line */
	VALUE ir_count;		/* repeat count (decrements) */
};
