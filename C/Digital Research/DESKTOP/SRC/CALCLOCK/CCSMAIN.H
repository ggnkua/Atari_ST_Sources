/*	CCSMAIN.H		11/09/84-06/20/85	Andrew Muir	*/
					/* set to zero to generate B&W	*/
					/* set to one to generate COLOR	*/


#define SEL SELECTABLE

#define SPOOLER 0  	/* TREE */
#define SPOLBOX 1
#define ADDNAME 14  	/* OBJECT in TREE #0 */
#define REMNAME 15  	/* OBJECT in TREE #0 */
#define F1NAME 2  	/* OBJECT in TREE #0 */
#define F12NAME 13  	/* OBJECT in TREE #0 */

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

#define CLOCK_TI 0x7
#define CLOK_OBS 0x13
#define CLOK_STR 0x7

#define SPOL_STR 14
#define SPOL_OBS 16

EXTERN BYTE	*the_str[];
EXTERN TEDINFO	the_ted[];
EXTERN OBJECT	the_calc[];

EXTERN BYTE	*clok_str[];
EXTERN TEDINFO	clok_ted[];
EXTERN OBJECT	the_clok[];

EXTERN BYTE	*spol_str[];
EXTERN OBJECT	the_spol[];

