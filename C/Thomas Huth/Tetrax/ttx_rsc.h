/* *** TTX_RSC.H - Object defines *** */

#ifndef TTX_RSC_H
#define TTX_RSC_H

#include <aes.h>

extern OBJECT _maindlg[], *maindlg;
extern OBJECT _itree[], *itree;
extern OBJECT setupdlg[], aboutdlg[];
extern OBJECT freqpop[], eofrpop[] /*, mostepop[]*/;
extern char modulename[];
extern char skinname[];

#define MAINMENU 0  /* menu */
#define MAINDLG 1  /* form/dial */
#define ICONDLG 2  /* form/dial */

#define MAINBOX 	0 /* BOX: Root box */
#define BWARDBUT	1 /* ICON: >Fast Backward< */
#define PLAYBUT 	2 /* ICON: >Play< */
#define FWARDBUT	3 /* ICON: >Fast Forward< */
#define STOPBUT 	4 /* ICON: >Stop< */
#define LOADBUT 	5 /* ICON: >Load< */
#define SETUPBUT    6 /* ICON: >Setup< */
#define ABOUTBUT    7 /* ICON: >About< */
#define EXITBUT     8 /* ICON: >Exit< */
#define MODNAME 	9 /* TEXT: name of the module */

#define ABOUTBOX	0
#define ABTITLE 	1
#define ABCR1		2
#define ABCR2		3
#define ABCR3		4
#define ABTHX1		5
#define ABTHX2		6
#define ABOKAY		7

#define SETUPBOX    0
#define SUTITEL		1
#define EOFRSTR		2
#define EOFRBUT		3
#define FREQSTR		4
#define FREQBUT		5
#define MSBUT		6
#define LSKININF    7
#define LSKINNAM    8
#define LSKINBUT    9
#define SUOKAY      10

#define MOSTEBOX	0 /* Mono/Stereo pop up */
#define MONO		1
#define STEREO		2

#define FREQBOX		0 /* Frequency pop up */
#define FRLOW		1
#define FRMID		2
#define FRHI		3

#define EOFRBOX		0 /* End-of-frame popup */
#define EOFRM0      1
#define EOFRM1      2
#define EOFRM2      3
#define EOFRM3      4
#define EOFRM4      5

#define ICNFBOX 	0 /* BOX */
#define ICNFICON  1

#endif
