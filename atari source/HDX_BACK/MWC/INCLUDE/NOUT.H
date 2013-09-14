/*
 * nout.h -- give structure of Mark Williams "n.out" object format.
 *
 * Copyright (c) 1986-1988, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef	 L_OUT_H
#define	 L_OUT_H

#define	NCPLN	16		/* Chars in loader name */
#define NLSEG	9		/* No. of segments */
#define	NXSEG	6		/* No. of segments used by exec */
#define	L_MAGIC	0407		/* Magic number */

/*
 * The following gives the header for n.out.
 * It sits at the front of the file,
 * and contains control information and
 * the sizes of the other segments
 * of the file.
 * These values are in canonical byte order
 * in disk files, they should be converted
 * to native byte order with canint() and
 * canlong() when read from the file, and
 * converted back to canonical order when
 * written back to a file.
 *
 * Gemdos format executable files written
 * by the MWC linker or converted by drtomw
 * have a ldheader inserted into the gemdos
 * symbol table with the MWC debug and symbol
 * segments.
 * The LF_FAKE flag is set in the ldheader l_flag.
 */
struct	ldheader {
	short	l_magic;	/* Magic number */
	short	l_flag;		/* Flags */
	short	l_machine;	/* Type of target machine */
	short	l_tbase;	/* Text starts here */
	long	l_ssize[NLSEG];	/* Segment sizes */
	long	l_entry;	/* Entry point */
};

/* Flags */
#define LF_SHR		01	/* Bound shared */
#define LF_SEP		02	/* Bound separated */
#define LF_NRB		04	/* No relocation bits */
#define	LF_KER		010	/* Loadable driver */
#define	LF_32		020	/* 32-bit format l.out */
#define	LF_SLREF	040	/* References shared library */
#define	LF_SLIB		0100	/* Is the shared library */
#define LF_DEBUG	0200	/* Debug information is present */
#define LF_FAKE		0400	/* Header is displaced to end of exe or prg */

/* Formats */
#define	AFMT	"%08lx"		/* Address */

/* Machines */
#ifndef	MTYPE_H
#include <mtype.h>
#endif

/* Segments */
#define	L_SHRI	0		/* Shared Instruction space */
#define	L_PRVI	1		/* Private Instruction space */
#define	L_BSSI	2		/* Uninitialised Instruction */
#define	L_SHRD	3		/* Shared Data space */
#define	L_PRVD	4		/* Private Data space */
#define	L_BSSD	5		/* Uninitalised Data */
#define L_DEBUG 6		/* Debug tables */
#define L_SYM	7		/* Symbols */
#define L_REL	8		/* Relocation */

#define L_ABS	9		/* Absolute (symbol table only) */
#define L_REF	10		/* Reference (symbol table) */

#define	L_GLOBAL	020	/* Global bit, or'ed in */

/*
 * Symbols.
 * These live in the "L_SYM" section
 * of the file; the size of this section
 * determines the number of symbols.
 * The ls_type and ls_addr fields are kept
 * in canonical byte order.
 */
struct	ldsym {
	char	ls_id[NCPLN];	/* Symbol name */
	short	ls_type;	/* Global + Seg. */
	long	ls_addr;	/* Value of symbol */
};

/*
 * The nlist structure for the nlist routine.
 */
struct nlist	{
	char	n_name[NCPLN];	/* Symbol name */
	short	n_type;		/* Type flag */
	long	n_value;	/* Value */
};


/*
 * Relocation is a byte stream.
 * The first byte is an opcode
 * which specifies the size of the relocated item,
 * whether the item is program counter relative,
 * and the segment to which the item refers.
 * The next four bytes are a long address
 * stored in canonical byte order
 * which identifies the location of the item
 * to be relocated.
 * If the opcode specifies L_SYM as the segment,
 * then the next two bytes are a symbol index
 * stored in canonical byte order
 * which identifies the symbol to which the item
 * wishes to refer.
 */
#define LR_SEG	017		/* Seg., L_SYM => Sym. based */
#define LR_PCR	020		/* PC-rel. flag */
#define LR_OP	0340		/* Opcode */

#define LR_BYTE	(0<<5)		/* Rel. a byte */
#define LR_WORD	(1<<5)		/* Rel. a word */
#define	LR_LONG	(2<<5)		/* Rel. a long */

#endif

/* End of nout.h */
