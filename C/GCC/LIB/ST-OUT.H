/*	atst.out.h	.1	24Dec85	*/
/*
 * Header prepended to each Atari ST .prg file
 */
struct aexec {
	 short	a_magic;	/* magic number */
unsigned long	a_text;		/* size of text segment */
unsigned long	a_data;		/* size of initialized data */
unsigned long	a_bss;		/* size of uninitialized data */
unsigned long	a_syms;		/* size of symbol table */
unsigned long	a_AZero1;	/* always zero */
unsigned long	a_AZero2;	/* always zero */
unsigned short	a_isreloc;	/* is reloc info present */
};
#define	CMAGIC	0x601A		/* contiguous text */
#define	ISRELOCINFO	0	/* relocation information is present */
				/*  any other value - no reloc info  */
/*
 * Macros which take exec structures as arguments and tell whether
 * the file has a reasonable magic number or offsets to text|symbols|strings.
 */
#define	A_BADMAG(x) 	(((x).a_magic)!=CMAGIC)
/* this is busted...
#define	A_TXTOFF(x)	((x).a_magic==ZMAGIC ? 1024 : sizeof (struct exec))
*/
#define	A_TXTOFF(x)	(sizeof (struct aexec))
#define A_DATOFF(x)	(A_TXTOFF(x) + (x).a_text)
#define A_SYMOFF(x)	(A_TXTOFF(x) + (x).a_text+(x).a_data)
#define	A_STROFF(x)	(A_SYMOFF(x) + (x).a_syms)

/*
 * Format of a symbol table entry
 */
struct	asym 
	{
	char		a_name[8];	/* symbol name */
	unsigned short	a_type;		/* type flag, i.e. N_TEXT etc; see below */
	unsigned long	a_value;	/* value of this symbol (or sdb offset) */
	};

/*
 * Simple values for a_type.
 */
#define A_UNDF	0		/* ?? for gas */
#define	A_BSS	0x0100		/* bss */
#define	A_TEXT	0x0200		/* text */
#define	A_DATA	0x0400		/* data */
#define	A_EXT	0x0800		/* external */
#define A_EQREG	0x1000		/* equated register */
#define A_GLOBL	0x2000		/* global */
#define A_EQU	0x4000		/* equated */
#define A_DEF	0x8000		/* defined */

