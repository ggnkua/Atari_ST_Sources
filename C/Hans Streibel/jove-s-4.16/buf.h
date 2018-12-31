/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* maximum length of a line (including '\0').  Currently cannot
   be larger than a logical disk block. */
#define	LBSIZE		JBUFSIZ

/* buffer types */
#define B_SCRATCH	1	/* for internal things, e.g. minibuffer ... */
#define B_FILE		2	/* normal file (we auto-save these.) */
#define B_PROCESS	3	/* unix process output in this buffer */

/* major modes */
#define FUNDAMENTAL	0	/* Fundamental mode */
#define TEXTMODE	1	/* Text mode */
#define CMODE		2	/* C mode */
#ifdef LISP
# define LISPMODE	3	/* Lisp mode */
# define NMAJORS	4
#else
# define NMAJORS	3
#endif

#define MajorMode(x)	(curbuf->b_major == (x))
#define SetMajor(x)	{ curbuf->b_major = (x); UpdModLine = YES; }

/* minor modes */
#define Indent		(1 << 0)	/* indent same as previous line after return */
#define ShowMatch	(1 << 1)	/* paren flash mode */
#define Fill		(1 << 2)	/* text fill mode */
#define OverWrite	(1 << 3)	/* over write mode */
#define Abbrev		(1 << 4)	/* abbrev mode */
#define ReadOnly	(1 << 5)	/* buffer is read only */

#define BufMinorMode(b, x)	(((b)->b_minor & (x)) != 0)
#define MinorMode(x)		BufMinorMode(curbuf, (x))

/* global line scratch buffers */
#ifdef AUTO_BUFS
extern char	*genbuf,	/* scratch pad points at s_genbuf (see main()) */
		*linebuf,	/* points at s_linebuf */
		*iobuff;	/* for file reading ... points at s_iobuff */
#else
extern char	genbuf[LBSIZE],
		linebuf[LBSIZE],
		iobuff[LBSIZE];
#endif

/* typedef struct line *LinePtr in jove.h */

struct line {
	LinePtr	l_prev,		/* pointer to prev */
		l_next;		/* pointer to next */
	daddr	l_dline;		/* pointer to disk location */
};

/* typedef struct mark Mark in jove.h */

struct mark {
	LinePtr	m_line;
	int	m_char;
	bool	m_big_delete;	/* mark was within the range of a multi-line delete */
	Mark	*m_next;	/* list of marks */
};

/* typedef struct buffer Buffer in jove.h */

struct buffer {
#ifdef MAC
	int Type;		/* kludge... to look like a data_obj */
	char *Name;		/* Name will not be used */
#endif
	Buffer	*b_next;		/* next buffer in chain */
	char	*b_name,		/* buffer name */
		*b_fname;		/* file name associated with buffer */
#ifdef USE_INO
	/* unique identification of file */
	dev_t	b_dev;			/* device of file name. */
	ino_t	b_ino;			/* inode of file name */
#endif
	time_t	b_mtime;		/* last modify time ...
					   to detect two people writing
					   to the same file */
	LinePtr	b_first,		/* pointer to first line in list */
		b_dot,			/* current line */
		b_last;		/* last line in list */
	int	b_char;			/* current character in line */

#define NMARKS	8			/* number of marks in the ring */

	Mark	*b_markring[NMARKS],	/* new marks are pushed here */
#define b_curmark(b)	((b)->b_markring[(b)->b_themark])
#define curmark		b_curmark(curbuf)
		*b_marks;		/* all the marks for this buffer */
	char	b_themark,		/* current mark (in b_markring) */
		b_type,			/* file, scratch, process, iprocess */
		b_ntbf,			/* (bool) needs to be found when we
					   first select? */
		b_modified,		/* (bool) is the buffer modified? */
		b_diverged;		/* (bool) has the underlying file been changed behind our back? */
	int	b_major,		/* major mode */
		b_minor;		/* and minor mode */
	struct keymap	*b_map;		/* local bindings (if any) */
#ifdef IPROCS
	struct process	*b_process;		/* process we're attached to */
#endif
};

extern Buffer
	*world,		/* first buffer */
	*curbuf,	/* pointer into world for current buffer */
	*lastbuf,	/* Last buffer we were in so we have a default
			   buffer during a select buffer. */
	*perr_buf;	/* Buffer with error messages */

#define curline	(curbuf->b_dot)
#define curchar (curbuf->b_char)

/* typedef struct position Bufpos in jove.h */

struct position {
	LinePtr	p_line;
	int	p_char;
};

extern bool
	valid_bp proto((Buffer	*bp));

extern Buffer
	*buf_exists proto((char *name)),
	*do_find proto((Window *w, char *fname, bool force, bool do_macros)),
	*do_select proto((Window *w,char *name)),
	*do_stat proto((char *name, Buffer *target, int flags));

/* flags to do_stat */
#define DS_NONE	0
#define DS_SET	1	/* set target buffers stat fields */
#define DS_REUSE	2	/* reuse result of last stat */
#define DS_DIR	4	/* directory OK as result */

extern bool
	was_dir,	/* do_stat found a directory */
	was_file;	/* do_stat found a (plain) file */

extern char
	*ask_buf proto((Buffer *def, int flags));

#ifdef USE_PROTOTYPES
struct macro;	/* forward declaration preventing prototype scoping */
#endif /* USE_PROTOTYPES */

extern void
	TogMinor proto((int bit)),
	buf_clear proto((Buffer *b)),
	setfname proto((Buffer *b,char *name)),
	SetABuf proto((Buffer *b)),
	SetBuf proto((Buffer *newbuf)),
	buf_init proto((void));

extern LinePtr
	lastline proto((LinePtr lp)),
	listput proto((Buffer *buf,LinePtr after)),
	next_line proto((LinePtr line,int num)),
	prev_line proto((LinePtr line,int num));

/* Commands: */

extern void
	BufErase proto((void)),
	BufKill proto((void)),
	BufList proto((void)),
	BufSelect proto((void)),
	FindFile proto((void)),
	KillSome proto((void)),
	ReNamBuf proto((void));

extern void
	Buf1Select proto((void)),
	Buf2Select proto((void)),
	Buf3Select proto((void)),
	Buf4Select proto((void)),
	Buf5Select proto((void)),
	Buf6Select proto((void)),
	Buf7Select proto((void)),
	Buf8Select proto((void)),
	Buf9Select proto((void)),
	Buf10Select proto((void));
