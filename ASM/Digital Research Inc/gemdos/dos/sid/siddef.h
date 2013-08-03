/********************************************************/
/*							*/
/*	Usual filename:  SIDDEF.H			*/
/*	Put ' #include "siddef.h" ' at head of each	*/
/*	   separately compiled module containing	*/
/*	   code added to DDT68K to give SID68K.		*/
/*	Remarks:  Definitions and declarations		*/
/*	   specific to SID68K.				*/
/*	Author:  Timothy M. Benson			*/
/*	Control:  12 MAY 83  15:36  (TMB)		*/
/*							*/
/********************************************************/

typedef	long		U32;
typedef	unsigned int	U16;

extern  long HMSYMS;

#define HMPPTS	32	/* # pass points allowed */
#define SAYMAX	stout("32\n");	/* (Must agree with preceding line */
#define CONTIG	0x601A	/* First word of contiguous load modules */
#define	DISCON	0x601B	/* First word of noncontiguous load modules */
#define TLONG	0x0080	/* Flag for entry in long-names string table */
#define	GONE	0x0040	/* Flag indicating hidden symbol */
#define	SEGREF	0x0700	/* Text, data, or bss relative */
#define IS	&	/* (Sometimes reads well) */
#define	TREL	0x0200	/* (sic) Text relative */
#define	DREL	0x0400	/* (sic) Data relative */
#define	BREL	0x0100	/* Bss relative */
#define	XTRASYM	32	/* Number of symbols to pre-allocate space for */

/************************************************/
/*						*/
/*	Structure of symbol table entry		*/
/*						*/
/************************************************/

struct	asymbl	BEGIN
	char	namae[8];
	U16	symtyp;
	U32	symval;
END;

#define sizasym 14

/************************************************/
/*						*/
/*	Structure of load module header		*/
/*	followed by symbol table		*/
/*						*/
/************************************************/

/* Using type definitions to ensure lengths of 16 and 32 bits,
   unsigned if allowed, alignment on even address, no gaps. */

struct	lmhedr	BEGIN
	U16	lmkind;	/* 0x601A => contiguous; 0x601B => noncontiguous */
	U32	lmtlen;	/* Number of bytes in text segment */
	U32	lmdlen;	/* Number of bytes in data segment */
	U32	padlen;	/* Number of bytes in bss segment */
	U32	symlen;	/* Number of bytes in symbol table */
	U32	nought;	/* Filler:  Should be zero */
	U32	tceps;	/* Start of text */
	U16	rflagb;	/* 0 => relocation; nonzero => no relocation */
	U32	dceps;	/* Start of data */
	U32	bceps;	/* Start of bss */
	struct	asymbl sump[1];	/* Symbol table per se */
	char	filler[128];
END;

#define sizlmhdr 178

