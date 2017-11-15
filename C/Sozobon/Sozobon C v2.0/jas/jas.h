/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#include <stdio.h>
#include <ctype.h>

#include <setjmp.h>

/* i don't know why we need this ...
#define short int
... */

typedef struct _sym {
	struct _sym *next;
	union {
		char here[8];
		long stix[2];
	} name;
	long value;
	unsigned short index;
	unsigned short flags;
	unsigned short access;
} SYM;

typedef struct {
	struct _sym *psym;
	long value;
} EXPR;

/*
 * Flags for symbols
 */
#define UNK	0x0000
#define BSS	0x0100
#define TXT	0x0200
#define DAT	0x0400
#define SEGMT	0x0700
#define EXTERN	0x0800
#define GLOBAL	0x2000
#define EQUATED	0x4000
#define DEFINED	0x8000

#define NAMEX	(EQUATED|TXT)	/* special mark for name extension */
#define NAMEV	0x87654321	/* special value for name extension */

typedef struct {
	unsigned short mode;
	unsigned char reg, inx;
	EXPR expr;
} OPERAND;

typedef struct {
	char mnemon[8];
	unsigned short op0, op1;
	char size;
	char format[14];
	unsigned char flags;
} INST;

typedef struct {
	INST *inst;
	OPERAND *op0, *op1;
	short misc;
} STMT;

/*
 * Flags for operand types
 */
#define O_NONE	0x0000
#define O_AN	0x0001
#define O_DN	0x0002
#define	O_INDR	0x0004
#define O_DISP	0x0008
#define O_POST	0x0010
#define O_PRE	0x0020
#define O_INDX	0x0040
#define O_ABS	0x0080
#define O_SABS	0x8000
#define	O_PCRL	0x0100
#define O_PCIX	0x0200
#define O_IMM	0x0400
#define O_USP	0x0800
#define O_CCR	0x1000
#define O_SR	0x2000
#define O_REGS	0x4003
#define O_ALL	0x87ff
#define O_DMEM	0x80fc
#define O_DST	0x80fe
#define O_MEM	0x83fc
#define O_LAB	0x8380
#define O_STAT	0x83cc
#define O_WRT	0x80ec
#define O_RD	0x83dc
#define O_NAN	0x87fe

/*
 * Flags for the size field
 */
#define S_B	0x01
#define S_W	0x02
#define S_L	0x04
#define S_BW	S_B|S_W
#define S_BL	S_B|S_L
#define S_WL	S_W|S_L
#define S_BWL	S_B|S_W|S_L

/*
 * Flags for special actions and defaults
 */
#define F_B	0x01
#define F_W	0x02
#define F_L	0x04
#define F_TXT	0x08
#define F_Q	0x10
#define F_TV	0x20
#define F_MQ	0x40
#define F_PC	0x80

typedef struct _list {
	struct _list *next;
	union {
		SYM *sym;
		EXPR val;
	} u;
} LIST;

/*
 * Types of things that get generated
 */
#define GENSTMT  1
#define GENVALUE 2
#define GENRELOC 3
#define GENPCREL 4
#define GENBRNCH 5

#define CBLEN 512

typedef struct {
	unsigned char nbits;
	unsigned char action;
	int line;
	EXPR value;
} CBUF;

typedef struct _clist {
	struct _clist *next;
	short cnt, inx;
	CBUF cblock[CBLEN];
} CLIST;

typedef struct _branch BRANCH;
struct _branch {
	long where;
	CBUF *cptr;
	BRANCH *link;
};

#define ALLOC(n,t) ((t *) allocate( (unsigned) ( (n) * sizeof (t) ) ))
#define ALLO(t)	ALLOC(1,t)
#define REALLO(p,n,t) ((t *) myreallocate( p, (unsigned) ( (n) * sizeof (t) ) ))
#define STRCPY(s) strcpy( ALLOC(1+strlen(s),char), s )
extern char *allocate(), *strcpy(), *myreallocate();

#define free my_free
