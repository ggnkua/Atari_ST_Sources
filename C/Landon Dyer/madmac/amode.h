/*
 *  68000 and 68020 addressing modes
 */
#define	DREG		000		/* Dn */
#define	AREG		010		/* An */
#define	AIND		020		/* (An) */
#define	APOSTINC	030		/* (An)+ */
#define	APREDEC		040		/* -(An) */
#define	ADISP		050		/* (d16,An) d16(An) */
#define	AINDEXED	060		/* (d8,An,Xn) d8(An,Xn) */
#define	ABSW		070		/* xxx.W */
#define	ABSL		071		/* xxx or xxx.L */
#define	PCDISP		072		/* (d16,PC) d16(PC) */
#define	PCINDEXED	073		/* (d16,PC,Xn) d16(PC,Xn) */
#define	IMMED		074		/* #data */
#define	ABASE		0100		/* (bd,An,Xn) */
#define	MEMPOST		0101		/* ([bd,An],Xn,od) */
#define	MEMPRE		0102		/* ([bc,An,Xn],od) */
#define	PCBASE		0103		/* (bd,PC,Xn) */
#define	PCMPOST		0104		/* ([bd,PC],Xn,od) */
#define	PCMPRE		0105		/* ([bc,PC,Xn],od) */
#define	AM_USP		0106
#define	AM_SR		0107
#define	AM_CCR		0110
#define	AM_NONE		0111		/* nothing */

/* addressing-mode masks */
#define	M_DREG		0x00000001L		/* Dn */
#define	M_AREG		0x00000002L		/* An */
#define	M_AIND		0x00000004L		/* (An) */
#define	M_APOSTINC	0x00000008L		/* (An)+ */
#define	M_APREDEC	0x00000010L		/* -(An) */
#define	M_ADISP		0x00000020L		/* (d16,An) d16(An) */
#define	M_AINDEXED	0x00000040L		/* (d8,An,Xn) d8(An,Xn) */
#define	M_ABSW		0x00000080L		/* xxx.W */
#define	M_ABSL		0x00000100L		/* xxx or xxx.L */
#define	M_PCDISP	0x00000200L		/* (d16,PC) d16(PC) */
#define	M_PCINDEXED	0x00000400L		/* (d16,PC,Xn) d16(PC,Xn) */
#define	M_IMMED		0x00000800L		/* #data */
#define	M_ABASE		0x00001000L		/* (bd,An,Xn) */
#define	M_MEMPOST	0x00002000L		/* ([bd,An],Xn,od) */
#define	M_MEMPRE	0x00004000L		/* ([bc,An,Xn],od) */
#define	M_PCBASE	0x00008000L		/* (bd,PC,Xn) */
#define	M_PCMPOST	0x00010000L		/* ([bd,PC],Xn,od) */
#define	M_PCMPRE	0x00020000L		/* ([bc,PC,Xn],od) */
#define	M_AM_USP	0x00040000L		/* USP */
#define	M_AM_SR		0x00080000L		/* SR */
#define	M_AM_CCR	0x00100000L		/* CCR */
#define	M_AM_NONE	0x00200000L		/* (nothing) */

/* addr mode categories*/
#define	C_ALL		0x00000fffL
#define	C_DATA		0x00000ffdL
#define	C_MEM		0x00000ffcL
#define	C_CTRL		0x000007e4L
#define	C_ALT		0x000001ffL

#define	C_ALTDATA	(C_DATA&C_ALT)
#define	C_ALTMEM	(C_MEM&C_ALT)
#define	C_ALTCTRL	(C_CTRL&C_ALT)
#define	C_LABEL		(M_ABSW|M_ABSL)
#define	C_NONE		M_AM_NONE


/*  Scales */
#define	TIMES1		00000	/* (empty or *1) */
#define	TIMES2		01000	/* *2 */
#define	TIMES4		02000	/* *4 */
#define	TIMES8		03000	/* *8 */


/*
 *  Addressing mode variables, output of amode().
 */
extern int nmodes;
extern int am0, am1;
extern int a0reg, a1reg;
extern TOKEN a0expr[], a1expr[];
extern VALUE a0exval, a1exval;
extern WORD a0exattr, a1exattr;
extern int a0ixreg, a1ixreg;
extern int a0ixsiz, a1ixsiz;
extern TOKEN a0oexpr[], a1oexpr[];
extern VALUE a0oexval, a1oexval;
extern WORD a0oexattr, a1oexattr;
extern SYM *a0esym, *a1esym;

/* mnemonic table structure */
#define MNTAB struct _mntab
MNTAB {
	WORD mnattr;			/* attributes (CGSPECIAL, SIZN, ...) */
	LONG mn0, mn1;		/* addressing modes */
	WORD mninst;			/* instruction mask */
	WORD mncont;			/* continuation (or -1) */
	int (*mnfunc)();		/* -> mnemonic builder */
};

/* mnattr: */
#define	CGSPECIAL	0x8000	/* special (don't parse addr modes) */
