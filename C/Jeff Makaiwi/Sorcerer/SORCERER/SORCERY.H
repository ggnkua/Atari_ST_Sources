/*****************************************************************************
 *  This is the custom header file for the Spectral Sorcery C-routines.      *
 *****************************************************************************/

/* Game Constants  */
#define	NO_LOCK		0
#define	RED_LOCK	1
#define	VIO_LOCK	2

#define	XOFFSET    6
#define	YOFFSET   24
#define	SPECLINE 140

#define	BLACK	0
#define	RED	1
#define	YELLOW	2
#define	GREEN	3
#define	BLUE	4
#define	VIOLET	5
#define	GRAY	6
#define	IR	7
#define	UV	8
#define	DK_VIO	9
#define	LT_VIO	10
#define DK_RED	11
#define LT_RED	12
#define FLESH	13
#define	DK_GRAY	14
#define	WHITE	15

#define	MINCOL	0
#define	MAXCOL	4
#define	MINROW	0
#define	MAXROW	4

#define	REDPLAYER	0
#define	VIOPLAYER	1

#define	TWOPLAYER  0
#define	COMPRED    1
#define	COMPVIO    2
#define	DEMOMODE   3

/* Number of VPLANES in LOWRES */
#define	VPLANE_CNT 4

/* Word size of different image arrays */
#define	SCRSIZE		8128
#define	WIZSIZE		280
#define WIZBUFFSIZE	420
#define	EDGESIZE	160
#define	PADSIZE		272
#define PADBUFFSIZE	340

#define PAD_WIDTH	4
#define PAD_HEIGHT	17
#define EDGE_HEIGHT	10
#define WW_WIDTH	2
#define WIZ_HEIGHT	35


/* ACTION Definitions */
#define	PASS		0
#define	MOVE		1
#define	CAST		2
#define	STOMP		3
#define HELPACT		4
#define RESIGN		5
#define MAXACTION	6

/* SPELL Definitions */
#define	NO_SPELL	0
#define	CONVERT		1
#define	TELEPORT	2
#define	BLITZ		3
#define	TRANSMUTE	4
#define	LOCK		5
#define	UNLOCK		6
#define	RELEASE		7
#define MAXSPELL 	8

/* Here are some keyboard constants that are specific to Spectral Sorcery */
#define	FUNC1	0x003b
#define	UNDO	0x0061
#define HELPKEY 0x0062

/* Some constants for the game options */
#define STNDRD_CONFIG	0
#define RANDOM_CONFIG	1

/* Player Information structure.  This structure is used to record the
   status of the players. */
typedef struct {
    int row;		/* Row the player occupies */
    int col;		/* Column the player occupies */
    int power;		/* Player's energy level */
    int comp;		/* 0=human control, 1=computer control */
    int advantage;	/* pads in favor of the player */
} PLINFO;


/* Board Information union.  This is for the board data access. */
typedef union {
    int linear[25];
    int grid[5][5];
} BDTYPE;
