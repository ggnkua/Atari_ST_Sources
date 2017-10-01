/*	CALC.H		11/09/84-06/20/85	Andrew Muir	*/
					/* set to zero to generate B&W	*/
					/* set to one to generate COLOR	*/
#define SEL SELECTABLE

#define THECALC 0
#define THEDISP 1
#define THECLR 3
#define EQUAL 27
#define TIMES 5
#define SEVEN 7
#define EIGHT 8
#define NINE 9
#define DIVIDE 10
#define FOUR 12
#define FIVE 13
#define SIX 14
#define MINUS 20
#define ONE 17
#define TWO 18
#define THREE 19
#define PLUS 15
#define ZERO 22
#define POINT 23
#define PERCENT 24
#define PLUMIN 4
#define CLRNTRY 2
#define CLRMEM 6
#define RETMEM 11
#define MEMPLU 16
#define MEMMIN 21 
#define	MEMFLG 25
#define THE_R 28
#define THE_M 31
#define THE_E 30

#define DISP_LEN 14
#define NOP 0
#define NUM 1

#define NUM_OBS 0x1c
#define NUM_TI 0x7
#define NUM_STRINGS 0x7

OBJECT the_calc[NUM_OBS] = 
{
	-1, 1, 27, G_BOX, NONE, SHADOWED, 0x00fd1264L, 0, 0, 19, 13,
	2, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x0L, 3, 1, 15, 1,
	3, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x1L, 2, 3, 3, 0x0301,
	4, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x43ff1105L, 6, 3, 2, 0x0301,
	5, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x2L, 9, 3, 5, 0x0301,
	6, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x2aff1105L, 15, 3, 2, 0x0301,
	7, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x3L, 2, 5, 3, 0x0301,
	8, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x37ff1100L, 6, 5, 2, 0x0301,
	9, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x38ff1100L, 9, 5, 2, 0x0301,
	10, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x39ff1100L, 12, 5, 2,0x0301,
	11, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x2fff1105L, 15, 5, 2,0x0301,
	12, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x4L, 2, 7, 3, 0x0301,
	13, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x34ff1100L, 6, 7, 2, 0x0301,
	14, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x35ff1100L, 9, 7, 2,0x0301,
	15, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x36ff1100L, 12, 7, 2,0x0301,
	16, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x2Bff1105L, 15, 7, 2,0x0301,
	17, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x5L, 2, 9, 3, 0x0301,
	18, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x31ff1100L, 6, 9, 2, 0x0301,
	19, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x32ff1100L, 9, 9, 2, 0x0301,
	20, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x33ff1100L, 12, 9, 2,0x0301,
	21, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x2dff1105L, 15, 9, 2,0x0301,
	22, -1, -1, G_BOXTEXT, SEL, NORMAL, 0x6L, 2, 11, 3, 0x0301,
	23, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x30ff1100L, 6, 11, 2,0x0301,
	24, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x2eff1105L, 9, 11, 2,0x0301,
	25, -1, -1, G_BOXCHAR, SEL, NORMAL, 0x25ff1105L, 12, 11,2,0x0301,
	26, -1, -1, G_BOXCHAR, NONE, NORMAL, 0x20001106L, 1, 1, 2, 1,
	27, -1, -1, G_BOX, NONE, NORMAL, 0x00001106L, 18, 1, 0x0300, 1,
	0, -1, -1, G_BOXCHAR, SEL | LASTOB, NORMAL, 0x3dff1105L,
				15, 11, 2,0x0301
};

TEDINFO the_ted[NUM_TI] =
{
 	(BYTE *)0x0L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_RIGHT, 0x1106, WHITE, 0, 13, 13,
	(BYTE *)0x1L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0,
	(BYTE *)0x2L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0,
	(BYTE *)0x3L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0,
	(BYTE *)0x4L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0,
	(BYTE *)0x5L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0,
	(BYTE *)0x6L, (BYTE *)-1L, (BYTE *)-1L, IBM, S_XOR_D, TE_CNTR, 0x1105, WHITE, -1, 0, 0
};

BYTE *the_str[NUM_STRINGS] =
{
	"              0",
	"EC",
	"+\\-",
	"MC",
	"MR",
	"M+",
	"M-"
};

