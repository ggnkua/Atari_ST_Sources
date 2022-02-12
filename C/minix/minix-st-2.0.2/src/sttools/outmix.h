/*
 * output format for MINIX-PC and MINIX-ST.
 * for the i8088 longs are stored with low-order byte first.
 * for the 68000 longs are stored with high-order byte first.
 * this is a mess!
 * This MINIX format is a stripped down and mutilated version of
 * the Vrije Universiteit flavor of the ACK loadfile format.
 */

struct exec {
	long 	a_magic;	/* contains a.out magic number */
	long	a_versn;	/* header length and version */
	long	a_tsize;	/* # bytes in program text segment */
	long	a_dsize;	/* # bytes in program data segment */
	long	a_bsize;	/* # bytes in program bss  segment */
	long	a_entry;	/* entry point */
	long	a_msize;	/* # bytes allocated for program */
	long	a_ssize;	/* # bytes in symbol table */
};

#ifdef ATARI_ST
#define	A_MAGICD	0x0b100301L	/* combined I & D space */
#define	A_MAGICI	0x0103200bL	/* separate I & D space */

#define	A_VERSION	0x20000000L
#else
#define	A_MAGICD	0x04100301L	/* combined I & D space */
#define	A_MAGICI	0x04200301L	/* separate I & D space */

#define	A_VERSION	0x00000020L
#endif

struct  nlist
{       char   n_name[8];      /* symbol name */
	long   n_value;        /* symbol value */
	char   n_sclass;       /* storage class */
	char   n_numaux;       /* number of auxiliary entries */
	short  n_type;         /* language base and derived type */
};

/*
 * structure format strings
 */
#ifdef i8088
#define	SF_HEAD		"L44444444"
#define	SF_SYMB		"L11111114112"
#endif
#ifdef ATARI_ST
#define	SF_HEAD		"M44444444"
#define	SF_SYMB		"M11111114112"
#endif

/*
 * structure sizes in file (add digits in SF_*)
 */
#define	SZ_HEAD		32
#define	SZ_SYMB		16
