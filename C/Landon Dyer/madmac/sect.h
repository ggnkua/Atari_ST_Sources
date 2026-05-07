#define	NSECTS	16		/* max. number of sections */


/*
 *  Macros to deposit code in the current section
 *
 *    D_rword deposits a "6502" format (low, high) word (01).
 *    D_rlong deposits a MWC "canonical byte order" longword (2301).
 *
 */
#define	D_byte(b) {*chptr++=(char)b; ++sloc; ++chsize;}
#define	D_word(w)	\
	{*chptr++=(char)(w>>8); *chptr++=(char)w;\
	sloc+=2; chsize+=2;}
#define	D_long(lw)	\
	{*chptr++=(char)(lw>>24); *chptr++=(char)(lw>>16);\
	*chptr++=(char)(lw>>8); *chptr++=(char)lw;\
	sloc+=4; chsize += 4;}

#define	D_rword(w)	\
	{*chptr++=(char)w; *chptr++=(char)(w>>8);\
	sloc+=2; chsize+=2;}

#define	D_rlong(lw)	\
	{*chptr++=(char)(lw>>16);*chptr++=(char)(lw>>24);\
	*chptr++=(char)lw;*chptr++=(char)(lw>>8);\
	sloc+=4; chsize += 4;}


/*
 *  Chunks are used to hold generated code
 *  and fixup records.
 *
 */
#define	CHUNK	struct _chunk
CHUNK {
	CHUNK *chnext;		/* -> next, previous chunks in section */
	CHUNK *chprev;
	LONG chloc;			/* base addr of this chunk */
	LONG challoc;			/* #bytes allocated for chunk */
	LONG chsize;			/* #bytes chunk actually uses */
	char *chptr;			/* -> data for this chunk */
};


/*
 *  Section descriptor.
 *
 */
#define	SECT	struct _sect
SECT {
	WORD scattr;			/* section attributes */
	LONG sloc;			/* current loc-in / size-of section */
	CHUNK *sfcode;		/* -> first chunk in section */
	CHUNK *scode;			/* -> last chunk in section */
	CHUNK *sffix;			/* -> first fixup chunk */
	CHUNK *sfix;			/* -> last fixup chunk */
};

/*
 *  Section attributes (.scattr)
 */
#define	SUSED	0x8000		/* section is used (really, valid) */
#define	SBSS	0x4000		/* section can contain no data */
#define	SABS	0x2000		/* section is absolute */
#define	SPIC	0x1000		/* section is position-independent code */


/*
 *  Fixup record
 *  a WORD of these bits, followed by a loc and then a pointer
 *  to a symbol or an ENDEXPR-terminated postfix expression.
 *
 *	SYMBOL		EXPRESSION
 *	------		----------
 *	~FU_EXPR	FU_EXPR		fixup type
 *	loc.L		loc.L		location in section
 *	fileno.W	fileno.W	file number fixup occurred in
 *	lineno.W	lineno.W	line number fixup occurred in
 *	symbol.L	size.W		&symbol  /  size of expression
 *			token.L		expression list
 *			(etc)
 *			ENDEXPR.L	(end of expression)
 *
 */
#define	FUMASK		007	/* mask for fixup cases: */
#define	FU_QUICK	000		/* fixup 3-bit quick instr field */
#define	FU_BYTE		001		/* fixup byte */
#define	FU_WORD		002		/* fixup word */
#define	FU_WBYTE	003		/* fixup byte (at loc+1) */
#define	FU_LONG		004		/* fixup long */
#define	FU_BBRA		005		/* fixup byte branch */
#define	FU_6BRA		007		/* fixup 6502-format branch offset */

#define	FU_SEXT		010	/* ok to sign extend */
#define	FU_PCREL	020	/* subtract PC first */
#define	FU_EXPR		040	/* expression (not symbol) follows */
#define	FU_ISBRA	0x2000	/* word forward fixup is a BRA or DBRA */
#define	FU_LBRA		0x4000	/* long branch, for short branch detection */
#define	FU_DONE		0x8000	/* fixup has been done */



/*
 *  A mark is of the form:
 *
 * .W 	<to+flags>	section mark is relative to, and flags in upper byte
 * .L 	<loc>		location of mark in "from" section
 * .W 	[from]		new from section
 * .L 	[symbol]	symbol involved in external reference
 *
 */
#define MCHUNK struct _mchunk
MCHUNK {
	MCHUNK *mcnext;		/* -> next mark chunk */
	PTR mcptr;			/* -> vector of marks */
	LONG mcalloc;			/* #marks allocted to mark block */
	LONG mcused;			/* #marks used in block */
};

#define	MWORD		0x0000	/* marked word */
#define	MLONG		0x0100	/* marked long */
#define	MCHFROM		0x8000	/* mark includes change-to-from */
#define	MSYMBOL		0x4000	/* mark includes symbol number */
#define	MCHEND		0x2000	/* indicates end of mark chunk */
#define	MPCREL		0x1000	/* mark is PC-relative */



/* global sect and chunk variables */
extern SECT sect[];		/* sections */
extern int cursect;		/* current section number */
extern WORD scattr;		/* section attributes */
extern LONG ssize;		/* section size */
extern LONG sloc;		/* current loc in section */
extern CHUNK *scode;		/* -> current (last) code chunk */
extern LONG challoc;		/* = #bytes alloc'd to code chunk */
extern LONG chsize;		/* = #bytes used in code chunk */
extern char *chptr;		/* -> deposit point in code chunk buffer */
extern CHUNK *sfix;		/* -> current (last) fixup chunk */
extern LONG fchalloc;		/* = #bytes alloc'd to fixup chunk */
extern LONG fchsize;		/* = #bytes used in fixup chunk */
extern PTR fchptr;		/* -> deposit point in fixup chunk buffer */

extern MCHUNK *firstmch;	/* -> first mark chunk */
extern MCHUNK *curmch;		/* -> current mark chunk */
extern PTR markptr;		/* -> deposit point in current mark chunk */
extern LONG mcalloc;		/* = #bytes alloc'd to current mark chunk */
extern LONG mcused;		/* = #bytes used in current mark chunk */
extern WORD curfrom;		/* = current "from" section */
