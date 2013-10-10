/*	ICONHI.H	10/05/84 - 06/11/85 	Lee Lorenzen		*/
/* added Desktop Publisher icons	03/27/87	Gregg Morris	*/

#define NUM_IBLKS 72
/*ICONBLK
   (L)ib_pmask, (L)ib_pdata, (L)ib_ptext,
   (W)ib_char, (W)ib_xchar, (W)ib_ychar,
   (W)ib_xicon, (W)ib_yicon, (W)ib_wicon, (W)ib_hicon,
   (W)ib_xtext, (W)ib_ytext, (W)ib_wtext, (W)ib_htext;
*/

EXTERN BYTE	*pi[];	    
BYTE	**gl_strs = {&pi[0]};
BYTE	***gl_start = {&gl_strs};

ICONBLK	gl_ilist[NUM_IBLKS] =
{
/* System Icons:	*/
	(WORD *)0x0L,  (WORD *)0x1L,  (BYTE *)-1L, 0x1000,5,11, 23,0,32,32, 0,32,72,10,	/*IGHARD 0*/
	(WORD *)0x2L,  (WORD *)0x3L,  (BYTE *)-1L, 0x1000,4,11, 23,0,32,32, 0,32,72,10,	/*IGFLOPPY 1*/
	(WORD *)0x4L,  (WORD *)0x5L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IGFOLDER 2*/
	(WORD *)0x6L,  (WORD *)0x7L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IGTRASH 3*/
	(WORD *)0x8L,  (WORD *)0x9L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IG4RESV 4*/
	(WORD *)0x8L,  (WORD *)0x9L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IG5RESV 5*/
	(WORD *)0x8L,  (WORD *)0x9L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IG6RESV 6*/
	(WORD *)0x8L,  (WORD *)0x9L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IG7RESV 7*/
/* Application Icons:	*/
	(WORD *)0x8L,  (WORD *)0x9L,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAGENER 8*/
	(WORD *)0x8L,  (WORD *)0xAL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IASS 9*/
	(WORD *)0x8L,  (WORD *)0xBL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAWP 10*/
	(WORD *)0x8L,  (WORD *)0xCL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IADB 11*/
	(WORD *)0x8L,  (WORD *)0xDL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IADRAW 12*/
	(WORD *)0x8L,  (WORD *)0xEL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAPAINT 13*/
	(WORD *)0x8L,  (WORD *)0xFL,  (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAPROJ 14*/
	(WORD *)0x8L,  (WORD *)0x10L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAGRAPH 15*/
	(WORD *)0x8L,  (WORD *)0x11L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAOUTL 16*/
	(WORD *)0x8L,  (WORD *)0x12L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAACCNT 17*/
	(WORD *)0x8L,  (WORD *)0x13L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAMULTI 18*/
	(WORD *)0x8L,  (WORD *)0x14L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAEDUC 19*/
	(WORD *)0x8L,  (WORD *)0x15L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IACOMM 20*/
	(WORD *)0x8L,  (WORD *)0x16L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IATOOL 21*/
	(WORD *)0x8L,  (WORD *)0x17L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAGAME 22*/
	(WORD *)0x8L,  (WORD *)0x18L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAOUTPT 23*/
	(WORD *)0x8L,  (WORD *)0x19L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IADPUB 24*/
	(WORD *)0x8L,  (WORD *)0x1AL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IASCAN 25*/
	(WORD *)0x8L,  (WORD *)0x1BL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IAMAIL 26*/
/* currently unused Application icons:	*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 4*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 5*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 6*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 7*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 8*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 9*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 10*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 11*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 12*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 13*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 14*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 15*/
	(WORD *)0x8L,  (WORD *)0x9L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IARSV 16*/
/* Document Icons:	*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDGENER 40*/
	(WORD *)0x1CL, (WORD *)0x1EL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDSS 41*/
	(WORD *)0x1CL, (WORD *)0x1FL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDWP 42*/
	(WORD *)0x1CL, (WORD *)0x20L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDDB 43*/
	(WORD *)0x1CL, (WORD *)0x21L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDDRAW 44*/
	(WORD *)0x1CL, (WORD *)0x22L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDPAINT 45*/
	(WORD *)0x1CL, (WORD *)0x23L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDPROJ 46*/
	(WORD *)0x1CL, (WORD *)0x24L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDGRAPH 47*/
	(WORD *)0x1CL, (WORD *)0x25L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDOUTLN 48*/
	(WORD *)0x1CL, (WORD *)0x26L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDACCNT 49*/
	(WORD *)0x1CL, (WORD *)0x27L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDMULTI 50*/
	(WORD *)0x1CL, (WORD *)0x28L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDEDUC 51*/
	(WORD *)0x1CL, (WORD *)0x29L, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDCOMM 52*/
	(WORD *)0x1CL, (WORD *)0x2AL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDTOOL 53*/
	(WORD *)0x1CL, (WORD *)0x2BL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDGAME 54*/
	(WORD *)0x1CL, (WORD *)0x2CL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDOUTPT 55*/
	(WORD *)0x1CL, (WORD *)0x2DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDDPUB 56*/
/* currently unused Document icons:	*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 2*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 3*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 4*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 5*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 6*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 7*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 8*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 9*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 10*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 11*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 12*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 13*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 14*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10,	/*IDRSV 15*/
	(WORD *)0x1CL, (WORD *)0x1DL, (BYTE *)-1L, 0x1000,0,0,  23,0,32,32, 0,32,72,10	/*IDRSV 16*/
};

#include <IGHDSKMH.ICN>	/*x0*/			/* System icons		*/
#include <IGHDSKDH.ICN>
#include <IGFDSKMH.ICN>
#include <IGFDSKDH.ICN>
#include <IGFOLDMH.ICN>
#include <IGFOLDDH.ICN>
#include <IGFOLD3H.ICN>
#include <IGFLOP3H.ICN>	/*x7*/
/* Placeholders for future icons
#include <IGRES4MH.ICN>
#include <IGRES4DH.ICN>
#include <IGRES5MH.ICN>
#include <IGRES5DH.ICN>
#include <IGRES6MH.ICN>
#include <IGRES6DH.ICN>
#include <IGRES7MH.ICN>
#include <IGRES7DH.ICN>
#include <IGRES8MH.ICN>
#include <IGRES8DH.ICN>
*/
#include <IAGENRMH.ICN>	/*x8*/			/* Application Icons	*/
#include <IAGENRDH.ICN>
#include <IASPRDDH.ICN>
#include <IAWORDDH.ICN>
#include <IADBASDH.ICN>
#include <IADRAWDH.ICN>
#include <IAPANTDH.ICN>
#include <IAPROJDH.ICN>
#include <IAGRPHDH.ICN>	/*x10*/
#include <IAOUTLDH.ICN>
#include <IAACCTDH.ICN>
#include <IAMULTDH.ICN>
#include <IAEDUCDH.ICN>
#include <IACOMMDH.ICN>
#include <IATOOLDH.ICN>
#include <IAGAMEDH.ICN>
#include <IAOUTPDH.ICN>
#include <IADPUBDH.ICN> /*x19*/
#include <IASCANDH.ICN>
#include <IAMAILDH.ICN>
/* Placeholders for future Application icons
#include <IARS04DH.ICN>
#include <IARS05DH.ICN>
#include <IARS06DH.ICN>
#include <IARS07DH.ICN>
#include <IARS08DH.ICN>
#include <IARS09DH.ICN>
#include <IARS10DH.ICN>
#include <IARS11DH.ICN>
#include <IARS12DH.ICN>
#include <IARS13DH.ICN>
#include <IARS14DH.ICN>
#include <IARS15DH.ICN>
#include <IARS16DH.ICN>
*/
#include <IDGENRMH.ICN>				/* Document Icons	*/
#include <IDGENRDH.ICN>
#include <IDSPRDDH.ICN>
#include <IDWORDDH.ICN>
#include <IDDBASDH.ICN>
#include <IDDRAWDH.ICN>
#include <IDPANTDH.ICN>	/*x20*/
#include <IDPROJDH.ICN>
#include <IDGRPHDH.ICN>
#include <IDOUTLDH.ICN>
#include <IDACCTDH.ICN>
#include <IDMULTDH.ICN>
#include <IDEDUCDH.ICN>
#include <IDCOMMDH.ICN>
#include <IDTOOLDH.ICN>	/*x28*/
#include <IDGAMEDH.ICN>
#include <IDOUTPDH.ICN>
#include <IDDPUBDH.ICN>
/* Placeholders for future Document Icons
#include <IDRS02DH.ICN>
#include <IDRS03DH.ICN>
#include <IDRS04DH.ICN>
#include <IDRS05DH.ICN>
#include <IDRS06DH.ICN>
#include <IDRS07DH.ICN>
#include <IDRS08DH.ICN>
#include <IDRS09DH.ICN>
#include <IDRS10DH.ICN>
#include <IDRS11DH.ICN>
#include <IDRS12DH.ICN>
#include <IDRS13DH.ICN>
#include <IDRS14DH.ICN>
#include <IDRS15DH.ICN>
#include <IDRS16DH.ICN>
*/

/* Icon names for use in Desktop's Configure Application dialog	*/
BYTE	*pi[32]=
{
	" Generic ",
	" Spreadsheet ",
	" Word Processor ",
	" Database ",
	" Draw ",
	" Paint ",
	" Project ",
	" Graph ",
	" Outline ",
	" Accounting ",
	" Multi-Function ",
	" Education ",
	" Communications ",
	" Programmer's Tool ",
	" Game ",
	" Output ",
	" Desktop Publisher ",
	" Scan ",
	" Mail ",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
};
