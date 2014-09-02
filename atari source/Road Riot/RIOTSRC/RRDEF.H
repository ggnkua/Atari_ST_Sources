/*	C and general game definitions		*/

#define BLANK		0
#define	NULL		0
#define	TRUE		1
#define	FALSE		0

#define	uint	unsigned int
#define	ulong	unsigned long
#define	ushort	unsigned short
#define	uchar	unsigned char

typedef char		S8;
typedef unsigned char	U8;
typedef short		S16;
typedef unsigned short	U16;
typedef unsigned long	U32;
typedef long		S32;

#define	LOCAL	static
#define	CONSTANT(arg)	 ((int)(&arg))

#define	BYTE		unsigned char
#define	SBYTE		char
#define	WORD		unsigned short
#define	SWORD		short
#define	LWORD		unsigned long
#define	SLWORD		long

/*	SPEED C structures		*/

typedef	int (*PFI)();

typedef	struct	hilo
	{
	short	hi;
	short	lo;
	} HILO;

typedef	union	dbl
	{
	HILO	half;
	long	full;
	} DBL;

/*	Object setup data structure			*/
typedef	struct	oblist
	{
	BYTE	attr;			/* Attribute and end flag	*/
	BYTE	type;			/* Object type code		*/
	short	xpos;			/* X position			*/
	short	ypos;			/* Y position offset from strip	*/
	short	zpos;			/* Z position			*/
	} OBLIST;

/*	Playfield scroll pairs				*/
typedef	struct	pfscrl
	{
	short	hscroll;
	short	vscroll;
	} PFSCRL;


/* structure for lap timers	*/
typedef struct ltimer
{
  BYTE min;			/* minute count */
  BYTE sec;			/* second count */
  BYTE hun;			/* hundredths of seconds */ 
} LTIMER; 

/*	The 3 sound calls associated music and/or SFX	*/
typedef	struct	triad
	{
	BYTE	start;
	BYTE	fade;
	BYTE	kill;
	} TRIAD;


/*	Object type indexes		*/
#define	DUMMY_TYPE	0
#define	PLR_TYPE	1
#define	LASER_TYPE	2
#define	FGIRL_TYPE	3
#define	GATE1_TYPE	4
#define	COW_TYPE	5
#define	ARAB2_TYPE	6
#define	ARAB3_TYPE	7
#define	ROCK0_TYPE	8
#define	ROCK1_TYPE	9
#define	BUMP0_TYPE	10
#define	BUMP1_TYPE	11
#define	LDRN_TYPE	12
#define	BUMP4_TYPE	13
#define	BUMP5_TYPE	14
#define	PALM_TYPE	15
#define	TIRE1_TYPE	16
#define	TIRE2_TYPE	17
#define	RAIL0_TYPE	18
#define	DUNE0_TYPE	19
#define	TREES0_TYPE	20
#define	TRAT_TYPE	21
#define	BODY_TYPE	22
#define	SHADOW_TYPE	23
#define	GATE0_TYPE	24
#define	SIGN0_TYPE	25
#define	BALE0_TYPE	26
#define	BALE1_TYPE	27
#define	TREES1_TYPE	28
#define	TREE0_TYPE	29
#define	STAND_TYPE	30
#define	TIRE0_TYPE	31
#define	DRONE0_TYPE	32
#define	DRONE1_TYPE	33
#define	DRONE2_TYPE	34
#define	DRONE3_TYPE	35
#define	DRONE4_TYPE	36
#define	DIRT0_TYPE	37
#define	DIRT1_TYPE	38
#define	DIRT2_TYPE	39
#define	DIRT3_TYPE	40
#define	BALE2_TYPE	41
#define	SPARE42_TYPE	42
#define	MUD0_TYPE	43
#define	MUD1_TYPE	44
#define	TRASH0_TYPE	45
#define	TRASH1_TYPE	46
#define	TRASH2_TYPE	47
#define	TREE1_TYPE	48
#define	TREE2_TYPE	49
#define	TREE3_TYPE	50
#define	WRECK0_TYPE	51
#define	WRECK1_TYPE	52
#define	WRECK2_TYPE	53
#define	CAR0_TYPE	54
#define	CAR10_TYPE	55
#define	CAR2_TYPE	56
#define	CAR3_TYPE	57
#define	CAR4_TYPE	58
#define	CAR5_TYPE	59
#define	CAR6_TYPE	60
#define	CAR7_TYPE	61
#define	CAR8_TYPE	62
#define	CAR9_TYPE	63
#define	BAG0_TYPE	64
#define	BAG1_TYPE	65
#define	BAG2_TYPE	66
#define	GATE2_TYPE	67
#define	DRAIL0_TYPE	68
#define	DPOST_TYPE	69
#define	POST_TYPE	70
#define	DUNE1_TYPE	71
#define	DIRT4_TYPE	72
#define	CORN_TYPE	73
#define	CACT0_TYPE	74
#define	CACT1_TYPE	75
#define	BLDG0_TYPE	76
#define	TREE4_TYPE	77
#define	BLDG1_TYPE	78
#define	BLDG2_TYPE	79
#define	BUMP2_TYPE	80
#define	BUMP3_TYPE	81
#define	CURB0_TYPE	82
#define	SIGN1_TYPE	83
#define	HYDR_TYPE	84
#define	DTIRE0_TYPE	85
#define	DTIRE2_TYPE	86
#define	DBALE0_TYPE	87
#define	DBALE2_TYPE	88
#define	DTREE0_TYPE	89
#define	DSIGN0_TYPE	90
#define	DDIRT0_TYPE	91
#define	DDIRT2_TYPE	92
#define	DCACT0_TYPE	93
#define	COWS_TYPE	94
#define	CRWD0_TYPE	95
#define	DBAG0_TYPE	96
#define	DBAG2_TYPE	97
#define	BLDG3_TYPE	98
#define	DBLDG0_TYPE	99
#define	DBLDG2_TYPE	100
#define	DTREE1_TYPE	101
#define	DTREE2_TYPE	102
#define	DTREE3_TYPE	103
#define	DTREE4_TYPE	104
#define	DPALM_TYPE	105
#define	DSIGN1_TYPE	106
#define	BLDG4_TYPE	107
#define	POST1_TYPE	108
#define	DPOST1_TYPE	109
#define	BLDG5_TYPE	110
#define	BLDG6_TYPE	111
#define	CAR11_TYPE	112
#define	DUNE2_TYPE	113
#define	DUNE3_TYPE	114
#define	ARAB0_TYPE	115
#define	ROCK3_TYPE	116
#define	CAR12_TYPE	117
#define	CAR13_TYPE	118
#define	CRWD4_TYPE	119
#define	CRWD2_TYPE	120
#define	CRWD3_TYPE	121
#define	ROCK2_TYPE	122
#define	RHINO_TYPE	123
#define	GRASS_TYPE	124
#define	ELE_TYPE	125
#define	LION_TYPE	126
#define	TREE5_TYPE	127
#define	DTREE5_TYPE	128
#define	TREE6_TYPE	129
#define	DTREE6_TYPE	130

/*	Forground #0 dispatch bits		*/
#define	F_TOY		0x0001
#define	F_VOL		0x0002
#define	F_ANCDELAY	0x0004
#define	F_DECANC	0x0008
#define	F_MONEY		0x0010
#define	F_PRIZE		0x0020
#define	F_FIRE		0x0040
#define	F_TALLYWAIT	0x0080
#define	F_BOMB		0x0100
#define	F_BOMB1		0x0200
#define	F_HIT		0x0400
#define	F_HIT1		0x0800


/*	Forground #1 dispatch bits		*/

/*	Mailbox bits			*/
#define	STRIP_REQ	0x8000

/*	Backround dispatch bits		*/
#define	B_TTLMUD	0x0001
#define	B_PLF		0x0002
#define	B_NEEDLE	0x0004
#define	B_SCORE		0x0008
#define	B_LAP 		0x0010
#define	B_EGO		0x0020
#define	B_LAST		0x0040
#define	B_ALTERA	0x0080
#define	B_MOBNORM	0x0100

/*	Collision dispatches		*/
#define	C_CAR		0x0001
#define	C_LASER		0x0002
#define	C_OBSTCLE	0x0004
#define	C_BALE		0x0008
#define	C_RAIL		0x0010
#define	C_OB1		0x0020

/*	Interrupt dispatches		*/
#define	I_CROWN		0x0001
#define	I_WHEEL		0x0002
#define	I_WFLASH	0x0004
#define	I_DDEV		0x0008
#define	I_WTRFALL	0x0010
#define	I_MAW1		0x0020
#define	I_MAW2		0x0040
#define	I_VOLX		0x0080
#define	I_HISCORE	0x0100


/*	Motion Object Parameters	*/
#define	STRIP_SIZE	0x1000			/* Strip y width	*/
#define	STRIP_MAX	16			/* Max objs per strip	*/
#define	STRIP_NUM	16			/* World strip count	*/
#define	FRONT_CLIP	0x0200			/* Front clip value	*/
#define	ROT_DIST	0x20			/* Rotation distance	*/
#define	SCANLINES	(short)240		/* Number of scanlines	*/
#define	VIEWZ_OFF	0x0C0			/* Normal z postion	*/
#define	Z_LOWEST	0x0C0			/* Lowest z offset from playfield	*/

#define	FULL_SCALE	0x100			/* Default scale value	*/
#define	QRTR3_SCALE	0x0C0
#define	HALF_SCALE	0x080
#define CAR_SCALE   	0x060
#define	QRTR_SCALE	0x040
#define	DRN_SCALE	0x100

/*	Max's and Min's				*/
#define	LO_MAX		0x140				/* Max speed in low gear		*/
#define	MAX_DRONE	6
#define	MAX_BALE	4
#define	MAX_RAIL	4

#define MAX_PLASER   4				/* 4 lasers per player */
#define MAX_UNITS    2				/* max number of systems on line */
#define	MAX_LASER	(MAX_PLASER * MAX_UNITS)   /* max total laser shots */

/*	Constants				*/
#define	MAX_STRIP	144				/* Max number of strips EVER per world	*/
#define	WLD_EDGE	0x1300				/* X world edge		*/
#define	Z_TOP		0x300				/* Highest Z position 	*/
#define	NORM_BANK	0x700				/* Normal bank edge		*/
#define	CAVE_STRIP	(LEG_MAX-6)			/* Where cave starts		*/
#define	YDEPTH		12				/* Number of visible strips	*/
#define	SCALE_NORM	0xC000				/* Normal y/z scale		*/
#define	MAX_RACE	11
#define ENDWMIN		( 3 * 30 )			/* End wave min timer		*/
#define ENDWTIME 	( 8 * 30 )			/* End wave max timer		*/


/*	Playfield specifications				*/
#define	BOTTOM_OFFSET	24
#define HORIZON_NORM	((120 - BOTTOM_OFFSET) << 6)
#define	BOTTOM_LINE	(0x3BC0 - (BOTTOM_OFFSET << 6))
#define	BOTTOMY		((SCALE_NORM * Z_LOWEST)/(BOTTOM_LINE - HORIZON_NORM))
#define	MIRRORH		0x2A00
#define	MIRRORV		0x600

/*	Misc. Flags				*/

#define	XTL_BIT		0x10
#define	BST_BIT		0x08

#define	NO_MULT		0x80000000
#define	NO_WAVE		0x40000000


/*	op->user1 Flags for Rat Race		*/
#define	MU_CNTR		0x8000
#define	MU_NOKILL	0x4000
#define	MU_MOVE		0x2000
#define	MU_STOP		0x1000
#define	MU_ONBANK	0x0800
#define	MU_TBOUNCE	0x0400

/* game options */
#define	DO_SHAKER	0x4000
#define DO_THUMP	0x0010

/*	Compile Flags			*/
#define	TRAP_CODE	TRUE

/*	C MACROS			*/
#define	ABS(val)	(((val) < 0) ? -(val) : (val))

/*	Announcement flags		*/
#define	PER_RACE	0x80
#define	PER_LAP		0x40
