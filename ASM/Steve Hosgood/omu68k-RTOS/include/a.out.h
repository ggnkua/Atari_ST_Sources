/*
 *	Layout of a.out file :
 *
 *	header of 8 longs	magic number 405, 407, 410, 411
 *				text size		)
 *				data size		) in bytes
 *				bss size		)
 *				symbol table size	)
 *				text relocation size	)
 *				data relocation size	)
 *				entry point
 *
 *	header:			0
 *	text:			32
 *	data:			32+textsize
 *	symbol table:		32+textsize+datasize
 *	text relocation:	32+textsize+datasize+symsize
 *	data relocation:	32+textsize+datasize+symsize+rtextsize
 *
 */
/* various parameters */
#define SYMLENGTH	50		/* maximum length of a symbol */

/* types of files */
#define	ARCMAGIC 0177545
#define OMAGIC	0405
#define	FMAGIC	0407
#define	NMAGIC	0410
#define	IMAGIC	0411

/* symbol types */
#define	EXTERN	040
#define	UNDEF	00
#define	ABS	01
#define	TEXT	02
#define	DATA	03
#define	BSS	04
#define	COMM	05	/* internal use only */
#define REG	06

/* relocation regions */
#define	RTEXT	00
#define	RDATA	01
#define	RBSS	02
#define	REXT	03

/* relocation sizes */
#define RBYTE	00
#define RWORD	01
#define RLONG	02

/* macros which define various positions in file based on a bhdr, filhdr */
#define TEXTPOS		((long) sizeof(filhdr))
#define DATAPOS 	(TEXTPOS + filhdr.tsize)
#define SYMPOS		(DATAPOS + filhdr.dsize)
#define RTEXTPOS	(SYMPOS + filhdr.ssize)
#define RDATAPOS	(RTEXTPOS + filhdr.rtsize)
#define ENDPOS		(RDATAPOS + filhdr.rdsize)

/* header of a.out files */
struct bhdr {
	long	fmagic;
	long	tsize;
	long	dsize;
	long	bsize;
	long	ssize;
	long	rtsize;
	long	rdsize;
	long	entry;
};

/* symbol management */
struct sym {
	char	stype;		/* symbol type */
	char	sympad;		/* pad to long align */
	long	svalue;		/* value */
};

/* relocation commands */
struct reloc {
	unsigned rsegment:2;	/* RTEXT, RDATA, RBSS, or REXTERN */
	unsigned rsize:2;		/* RBYTE, RWORD, or RLONG */
	unsigned rdisp:1;		/* 1 => a displacement */
	unsigned relpad1:3;		/* pad 1 */
	char	 relpad2;		/* pad 2 */
	short rsymbol;		/* id of the symbol of external relocations */
	long rpos;		/* position of relocation in segment */
};

/* Stuff for unix compatibility */

#define	A_MAGIC1	FMAGIC       	/* normal */
#define	A_MAGIC2	NMAGIC       	/* read-only text */

struct	nlist {	/* symbol table entry */
	char    	n_name[8];	/* symbol name */
	int     	n_type;    	/* type flag */
	unsigned	n_value;	/* value */
};

		/* values for type flag */
#define	N_UNDF	0	/* undefined */
#define	N_ABS	01	/* absolute */
#define	N_TEXT	02	/* text symbol */
#define	N_DATA	03	/* data symbol */
#define	N_BSS	04	/* bss symbol */
#define	N_TYPE	037
#define	N_REG	024	/* register name */
#define	N_FN	037	/* file name symbol */
#define	N_EXT	040	/* external bit, or'ed in */
#define	FORMAT	"%06o"	/* to print a value */
