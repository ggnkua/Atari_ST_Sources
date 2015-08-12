#define		DH		0x07
#define		END_CMD		0xde
#define		ST_CMD		0xdd
#define		MDASH		0xf0
#define		NDASH		0xf7
#define		HRD_HYP 	0x2d
#define		XDSIZ		18000
#define 	NULP		0L

extern	unsigned char	ptsfpos[256];
extern	unsigned char	mcsdbl[303];
extern	unsigned char	*hyptr[65];	/* hyphenation ptrs array...	*/
extern	unsigned char	fpascii[118];

/*
	Locals
*/
unsigned	hyph_index;
unsigned	hyofs[65];

char		MNdash;
char		HY_TYPE;
char		DHfnd;
char		hypcnt;
char		dashct;
char		wrdbuf[80];

unsigned char	X_BUF[XDSIZ];
unsigned char	hyphens[65];
unsigned char	cmd_lngth;
unsigned char	alphact;

unsigned char	*bgnptr;
unsigned char	*endptr;
unsigned char	*wrkend;
unsigned char	*xptr;
