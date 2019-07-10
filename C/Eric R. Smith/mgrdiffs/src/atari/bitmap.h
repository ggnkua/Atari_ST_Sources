/*                        Copyright (c) 1987,1989 Bellcore
 *                            All Rights Reserved
 *       Permission is granted to copy or use this program, EXCEPT that it
 *       may not be sold for profit, the copyright notice must be reproduced
 *       on copies, and credit should be given to Bellcore where it is due.
 *       BELLCORE MAKES NO WARRANTY AND ACCEPTS NO LIABILITY FOR THIS PROGRAM.
 */
/*	$Header: bitmap.h,v 4.2 88/07/19 14:19:23 sau Exp $
	$Source: /tmp/mgrsrc/src/oblit/RCS/bitmap.h,v $
*/
static char	h_bitmap_[] = "$Source: /tmp/mgrsrc/src/oblit/RCS/bitmap.h,v $$Revision: 4.2 $";

/* header file for SUN version of portable bitblit code (S. A. Uhler) */

#ifndef Min
#define Min(x,y)	((x)>(y)?y:x)
#endif

/* Machine configurations go here */

/*
 * DATA is the memory size of the frame buffer.  Usually "unsigned int",
 * but sometimes "unsigned {long,short,char}" is more appropriate
 */

typedef unsigned int DATA;				/* basic frame buffer word size */
#define LOGBITS		5				/* Log2 of bits in type DATA */

/*
 * The macro "GET Most Significant Bits" defines how the bits in each
 * word map from memory to pixels on the display.  The top left most
 * pixel on the display comes from either the *high* order or *low* order
 * bit of the first frame buffer word.  Use "<<" in the first case, ">>"
 * in the second.
 * 
 * The macro "GET Least Significant Bits" does the inverse of GETMSB
 */

#define GETMSB(word,shift)	\
	(word << shift)					/* get most significant bits in word */
#define GETLSB(word,shift) \
	(word >> shift)					/* get least significant bits in word */

/* these probably won't need changing */

#define BITS	(~(~0 << LOGBITS))			/* mask for bit# within word */
#define MSB		(~GETLSB((unsigned)~0,1))	/* most sig bit set */
#define LSB		(~GETMSB((unsigned)~0,1))	/* least sig bit set */

/*
 * bitmap data has 2 formats, an internal format and an external format.
 * (Sometimes the formats are the same).  The external format is native
 * 68020 SUN/3, DATA aligned 1=black, 0=white.  The internal format is
 * whatever the frame buffer is.  If DOFLIP is set, data is converted
 * from external to internal format the first time it is used.  Bitmap
 * data is recognized as being in external format if the _FLIP flag is
 * set in the type field.  The installation routine flip() does the
 * conversion.
 */

#define DOFLIP (MSB==1)							/* need to flip bytes */

/****************************/

#define ROP_INVERT(x) (x)							/* punt for now */

/* bit_blit is defined as a macro so machines with special graphics 
 * hardware can use mem_rop a a special case
 */

#define bit_blit(dest,dx,dy,width,height,func,source,sx,sy)  \
	mem_rop(dest,dx,dy,width,height,func,source,sx,sy) 

/* Macro to declare a static bitmap */

#define bit_static(name,wide,high,data,n)	\
	BITMAP name = {(DATA *) data, &name, 0, 0, wide, high, _STATIC};

#define NULL_DATA	((DATA *) 0)				/* NULL bitmap data */
#define BIT_NULL	((BITMAP *) 0)				/* NULL bitmap pointer */

#define IS_SCREEN(x)	(3&(x)->type==_SCREEN)	/* bitmap is on the display */
#define IS_MEMORY(x)	(3&(x)->type==_MEMORY)	/* bitmap space malloc'd */
#define IS_PRIMARY(x)	((x)->primary == (x))
#define SET_FLIP(x)     ((x)->primary->type |= DOFLIP ? _FLIP : 0)

/*
 * OPCODE(expr), where expr is boolean expression involving SRC and DST,
 * is one of sixteen numbers encoding a rasterop opcode. The values for SRC
 * and DST are abitrary, as long as all 16 patterns may be produced by
 * boolean combinations of them.
 */

#define			DST 	0xA	/* 1010 */
#define			SRC	0xC	/* 1100 */

#define OPCODE(expr)	(0xF&(expr))

/* names for common bitblit functions */

#ifndef BIT_NOT
#   define BIT_NOT(x)	(~(x))
#endif
#define BIT_SRC		SRC
#define BIT_DST		DST
#define BIT_SET		(BIT_SRC|BIT_NOT(BIT_SRC))
#define BIT_CLR		(BIT_SRC&BIT_NOT(BIT_SRC))
#define BIT_XOR		(BIT_SRC^BIT_DST)
#define BIT_INVERT	(BIT_NOT(DST))
#define GET_OP(x)	((x)&0xf)		/* OPCODE, and GET_OP are redundant */

/* bitmap types */

#define _SCREEN		1		/* frame buffer */
#define _MEMORY		2		/* malloc'd space */
#define _STATIC		3		/* don't free space at destroy time */
#define _FLIP			4		/* data is in external format */

/* member access macros */

#define BIT_X(x)	x->x0
#define BIT_Y(x)	x->y0
#define BIT_DATA(x)	x->data
#define BIT_WIDE(x)	x->wide
#define BIT_HIGH(x)	x->high
#define BIT_DEPTH(x)	1		/* no color support for now */

#define BIT_SIZE(m) BIT_Size(BIT_WIDE(m), BIT_HIGH(m), BIT_DEPTH(m)) /* bytes */
#define BIT_Size(wide,high,d)     (((d)*((wide+BITS)&~BITS)*high)>>3) /* bytes*/
#define BIT_LINE(x)	((x->primary->wide+BITS)>>LOGBITS)/* words on scan line */

/* structure and type definitions */

typedef struct bitmap {
   DATA	*data;		/* bitmap data */
   struct bitmap	*primary;	/* pointer to primary bitmap */
   short		x0, y0;				/* starting coordinates, in bits */
   short		wide, high;			/* bitmap size, in bits */
   unsigned short	type;			/* bitmap type */
   } BITMAP;

/* function declarations */

int mem_rop();
int bit_destroy();
int bit_line();
BITMAP * bit_create();
BITMAP * bit_alloc();
BITMAP * bit_open();

/* for non existant color support */

#define DEPTH				1			/* bits per pixel */
#define NOCOLOR         0xF
#define GETCOLOR(x)     0
#define PUTCOLOR(x)     0

/* other */

#define Bprintf(x)	/* gone */
