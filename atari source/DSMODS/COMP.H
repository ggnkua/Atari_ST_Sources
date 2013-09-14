#define		FTSIZ		24768	/* Font Library buffer size	*/
#define 	UTSIZE		4097	/* Slave buffer malloc size	*/
#define 	SLVEOB		32	/* Slave End of Block command	*/
#define 	SLVEOD		33	/* Slave End of Data  command	*/
#define		AJ		0
#define		AL		1
#define		AR		2
#define		AC		3
#define		UNIT4		4	/* number of unit supported	*/

/****************************************************************/
/*		DSII Structure definitions			*/
/****************************************************************/

struct	slvll {			/* SLaVe Linked List structure	*/
	struct	slvll	*fptr;	/* Forward PoinTeR		*/
	unsigned char	*bufptr;/* PoinTeR to BUFfer malloced	*/
};				/* structure size = 8 bytes	*/

struct	txtattr {		/* TeXT ATTRibutes structure	*/
	unsigned	llen;	/* Line LENgth	in HMS		*/
	unsigned long	depth;	/* DEPTH	in VMS		*/
	unsigned long	lnsp;	/* LiNe SPacing in VMS		*/
	unsigned	ptsz;	/* PoinT SiZe	in 1/8ths Point	*/
	unsigned	ssiz;	/* Set	 SIZe	in 1/8ths Point	*/
	unsigned	font;	/* FONT number (1 to 9999)	*/
	unsigned char	mcomp;	/* Manual char. COMPensation	*/
	char		acomp;	/* Auto.  char. COMPensation	*/
	char		kernmd;	/* KERNing	 MoDe flag	*/
	char		hypmd;	/* HYPhenation	 MoDe flag	*/
	char		nsuchyp;/* No. of SUCcessive	HYPhens	*/
	char		nbefhyp;/* No. of chars BEFore	HYPhen	*/
	char		nafthyp;/* No. of chars AFTer	HYPhen	*/
	char		ltsmd;	/* LetTerSpacing MoDe flag	*/
	char		plts;	/* Positive LetTer Space in RU	*/
	char		nlts;	/* Negative LetTer Space in RU	*/
	char		minsp;	/* MINimum	SPace	 in RU	*/
	char		prfsp;	/* PReFerred	SPace	 in RU	*/
	char		maxsp;	/* MAXimum	SPace	 in RU	*/
	char		rvomd;	/* Reverse VideO MoDe flag	*/
	char		psimd;	/* PSeudo Italic MoDe flag	*/
	char		jstmd;	/* JuSTification MoDe flag	*/
	int		scoff;  /* Scan offset			*/
} cp;				/* structure size = 34 bytes	*/

struct textobj {		/* TEXT OBJect structure	*/
	unsigned char	*begtext;
			/* pointer to BEGinning of TEXT		*/
	struct	txtattr	*attr;
			/* pointer to text ATTRibutes block	*/
	struct	slvll	*slvlist;
			/* pointer to SLaVe LIST		*/
	unsigned	State;
			/* bit 0 - set	: linebreak	done	*/
			/* bit 1 - set	: slave		created	*/
			/* bit 2 - set	: output	done	*/
			/* bit 3 - 15	: future use		*/
};				/* structure size = 14 bytes	*/

/****************************************************************/
/*	System PowerUp Definitions				*/
/****************************************************************/
struct	pwup {
	char	rsv1;		/* Reserved future Use		*/
	char	rsv2;		/* Reserved future Use		*/
	char	ftdrs[14];	/* default FonT DResS	name	*/
	char	edict[14];	/* default Exc. DICTionary	*/
	char	kblyt[14];	/* default KeyBoard LaYouT	*/
	char	omod;		/* Ouptut device MODe		*/
	char	hylg;		/* HYphenation LanGuage number	*/
	char	rsv3;		/* Reserved future Use		*/
	char 	cign;		/* Case IGNore search flag	*/
} setp;				/* structure size = 48 bytes	*/

/****************************************************************/
/*	Composition Module globals				*/
/****************************************************************/
unsigned char	ftlib[FTSIZ];		/* 16 FonTs LIBrary	*/
unsigned char	*pftpt;			/* Present FonT PoinTer	*/
char		ftin;			/* FonTs IN library	*/
char		cpabt;			/* ComP. mode ABorT	*/
char		inovs;			/* IN OVerSet range	*/
char		sflg;			/* -letterSpace FLaG	*/
char		txkn;			/* TeXt KerNing flag	*/
char		IFerr;			/* IFont ERRor setup	*/
	/* bit set 0:memory buffer, 1:memory driver, 2:IF init	*/
unsigned char	HYfp;			/* Flash Pos. of HYphen */
unsigned	ltsct;			/* +/- LTS CounTer	*/
unsigned	spbval;			/* SPaceBand VALue	*/
unsigned long	cdep;			/* DEPth Counter	*/
unsigned	clen;			/* line LENght Counter	*/
unsigned	cct;			/* line Character CounT	*/
unsigned	lspc;			/* Line SPace Count	*/
unsigned	smsz;			/* line SMallest SiZe	*/
unsigned	cmpval;			/* manual CoMP. VALue	*/
unsigned	avcval;			/* A.Var. Comp. VALue	*/
unsigned	acmp;			/* Auto.  ComP. current	*/

struct {				/* A.V.Char Cmp. struct	*/
	char	zpt, var;		/* Zero PoinT, VARiable	*/
} avcc[4];			/* structure size = 8 bytes	*/

unsigned char	*kpptr;			/* Kerning Pair PoinTeR	*/
unsigned	kpval;			/* Kerning Pair VALue	*/
struct {				/* KERNing structure	*/
	unsigned char	ch;		/* l or r CHar in pair	*/
	unsigned char	lval[4];	/* Left  4 VALues	*/
	unsigned char	rval[4];	/* Right 4 VALues	*/
} kern[2];			/* structure size = 20 bytes	*/
