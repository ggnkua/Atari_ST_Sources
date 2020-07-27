/*
	gu.h -- include file for the shell 'gulam'  7/20/86

	copyright (c) 1986 pm@cwru.edu
*/

#define	local	static		/* prefix to rtns internal to a module */
				/* changed to '#define local' while dbg	*/

#define	GU	1

typedef	unsigned int	uint;
typedef	unsigned char	uchar;

#include "sysdpend.h"		/* this should come after OS #define	*/

#define	FALSE	0
#define	TRUE	(!FALSE)
#define ABORT   2		/* Death, ^G, abort, etc.       */
#define	NULL	0L

				/* some std ascii chars		*/
#define	CTRLC	'\003'
#define	CTRLD	'\004'
#define	CTRLG	'\007'
#define	CTRLQ	'\021'
#define	CTRLS	'\023'
#define	CTRLO	'\017'
#define	ESC	'\033'

#define	Iwssz	100
typedef struct
{	int	nc;
	int	sz;
	int	ns;
	uchar 	*ps;
}	WS;

typedef	uchar	*WSPS;

typedef	struct	GA
{	int	sz;		/* size (in bytes) of an element	*/
	int	ne;		/* #elements in the array		*/
	int	na;		/* #elements allocated			*/
	int	ni;		/* increment for re allocation		*/
	uchar	el[MINELM];	/* elements themselves			*/
}	GA;

typedef	struct	TBLE
{	uchar *		key;
	uchar *		elm;
	struct TBLE *	next;
}	TBLE;

extern	uchar	ID[];		/* gulam's id			*/
extern	uchar	CRLF[];		/* "\r\n"			*/
extern	uchar	ES[];		/* "\0", used as empty string	*/
extern	uchar	GulamHelp[];	/* = "gulam_help_file";		*/
extern	uchar	Nrows[];	/* = "nrows"			*/
extern	uchar	OwnFonts[];
extern	uchar	History[];
extern	uchar	Home[];
extern	uchar	Rgb[];
extern	uchar	Cwd[];

extern	uchar	WHITE[];	/* ==1 for white chars, 0 ow	*/
extern	uchar	WHITEDELIMS[],DELIMS[],SUBDELIMS[],COMMA[],BTRNQD[]; /* 0/1*/
extern	uchar	TKN2[],	EMPTY2[];	/* 0/1 vectors		*/

extern	uchar *	emsg;
extern	uchar *	strg;
extern	long	valu;

extern	int	state;
extern	uchar	cnmcomplete;	/* name completion key char	*/
extern	uchar	cnmshow;

extern	uchar	negopts[], posopts[];

#define	lowercase(xx)	chcase(xx, 0)
#define	uppercase(xx)	chcase(xx, 1)

extern	WS	*initws();
extern	WS	*dupws();
extern	WS	*prefixws();
extern	WS 	*lex();
extern	WS 	*useuplexws();
extern	WS 	*expand();
extern	WS 	*metaexpand();
extern	WS 	*fullmetaexpand();
extern	WS 	*aliasexp();
extern	WS	*dupenvws();
extern	WS	*tblws();
extern	GA	*initga();
extern	GA	*addelga();
extern	TBLE 	*tblfind();
extern	TBLE	*tblcreate();

extern	unsigned int	getusrinput();
extern	unsigned int	userfnminput();

extern uchar *	execcmd();
extern uchar *	getoneline();
extern uchar *	csexp();
extern uchar *	fnmpred();
extern uchar *	substhist();
extern uchar *	tblstr();
extern uchar *	varstr();
extern uchar *	ggetenv();
extern uchar *	escexpand();
extern uchar *	fnmsinparent();
extern uchar *	getalias();
extern uchar *	gfgetcwd();
extern uchar *	hashlookup();
extern uchar *	lexsemicol();
extern uchar *	lexgetword();
extern uchar *	lexhead();
extern uchar *	lextail();
extern uchar *	lexlastword();
extern uchar *	lexargvprev();
extern uchar *	gmalloc();
extern uchar *	maxalloc();
extern uchar *	rindex();
extern uchar *	catall();
extern uchar *	pscolumnize();
extern uchar *	nthstr();
extern uchar *	str3cat();
extern uchar *	strdup();
extern uchar *	strsub();
extern uchar *	unquote();
extern uchar *	strcpy();
extern uchar *	rebuildstrg();
extern uchar *	chcase();
extern uchar *	strlwr();
extern uchar *	itoar();
extern uchar *	itoa();
extern uchar *	sprintp();
extern uchar *	index();
extern long	atoir();


/* -eof- */
