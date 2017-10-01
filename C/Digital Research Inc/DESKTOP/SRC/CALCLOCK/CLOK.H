/*	CLOK.H			11/09/84-06/20/84	Andrew Muir	*/
					/* set to zero to generate B&W	*/
					/* set to one to generate COLOR	*/


#define SEL SELECTABLE

#define THECLOCK 0
#define TOPBOX   1
#define LOWBOX	 2
#define SW_TIME  3
#define HOUR     5
#define MINUTE	 7
#define AM_PM    9
#define THEALARM 11
#define	MONTH	 13
#define THEDATE	 15
#define YEAR	 18

#define CLOCK_TI 0x7
#define CLOK_OBS 0x13
#define CLOK_STR 0x7


OBJECT the_clok[CLOK_OBS] = 
{
	-1, 1, 18, G_IBOX, NONE, NORMAL, 0x0L, 0, 0, 16, 0x0702,
	2, -1, -1, G_BOX, NONE, NORMAL, 0x00fc1201L, 0, 0, 16, 0x0401,
	3, -1, -1, G_BOX, NONE, NORMAL, 0x00fc1201L, 0, 0x0401, 16, 0x0401,
	4, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x09001100L, 0, 0, 2, 0x0301,
	5, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x20001203L, 2, 0, 1, 0x0301,
	6, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x0L,        3, 0, 3, 0x0301,
	7, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x3a001103L, 6, 0, 1, 0x0301,
	8, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x1L,        7, 0, 3, 0x0301,
	9, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x20001103L, 10, 0, 1, 0x0301,
        10, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x2L,        11, 0, 3, 0x0301,
	11, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x20001203L, 14, 0, 1, 0x0301,
	12, -1, -1, G_BOXCHAR, SEL, DISABLED,   0x0b001100L, 14, 0, 2, 0x0301,
	13, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x3L,       0, 0x0401, 3, 0x0301,
	14, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x4L,        3, 0x0401, 3, 0x0301,
	15, -1, -1, G_BOXCHAR, NONE,NORMAL, 0x2f001405L, 6, 0x0401, 1, 0x0301,
	16, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x5L,    7, 0x0401, 3, 0x0301,
	17, -1, -1, G_BOXCHAR, NONE,NORMAL,0x2f001405L, 10, 0x0401, 1, 0x0301,
	18, -1, -1, G_BOXCHAR, NONE,NORMAL,0x20001405L, 14, 0x0401, 2, 0x0301,
	 0, -1, -1, G_BOXTEXT, SEL | LASTOB,  NORMAL, 0x6L, 11, 0x0401, 3, 0x0301
};

TEDINFO clok_ted[CLOCK_TI] =
{
	(BYTE *)0x0L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1103, WHITE, 0, 13, 13,
	(BYTE *)0x1L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1103, WHITE, 0, 13, 13,
	(BYTE *)0x2L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1103, WHITE, 0, 13, 13,
	(BYTE *)0x3L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1405, WHITE, 0, 13, 13,
	(BYTE *)0x4L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1405, WHITE, 0, 13, 13,
	(BYTE *)0x5L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1405, WHITE, 0, 13, 13,
	(BYTE *)0x6L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1405, WHITE, 0, 13, 13
};

BYTE *clok_str[CLOK_STR] =
{
	" 1",
	" 2",
	" m",
	"   ",
	" 4",
	" 5",
	" 6"
};

