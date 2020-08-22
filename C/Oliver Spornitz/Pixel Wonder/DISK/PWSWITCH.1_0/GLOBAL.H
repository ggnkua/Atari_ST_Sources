/*
 *	GLOBAL.H 
 * 	Globale Definitionen, die in mehrere Module
 *	ben”tigt werden
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte
 */

#if !defined( __GLOBAL__ )
#define __GLOBAL__

#include "piwobind.h"

/*
 *	Globale Konstanten
 */
#define VERSION 	"1.0\0"
#define SWITCHDATA	"pwswitch.dat\0" 


/*
 * Globale Variablen
 */
typedef char ENTRY[8+1+3+1];

extern ENTRY PROGRAMMLISTE[100]; /* Definition in PWSWITCH.C */

extern GPB	RESOLD;				 /* Definition in CHNGERES.C */
extern GPB	RESBUF;				 /* Definition in PWSWITCH.C */
extern void *SCRN_BUF;			 /* Definition in CHNGERES.C */



#endif