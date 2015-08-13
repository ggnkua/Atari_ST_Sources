head	1.1;
access;
symbols
	TRLPR11B:1.1;
locks
	Thomas:1.1; strict;
comment	@ * @;


1.1
date	99.12.30.12.55.34;	author Thomas;	state Exp;
branches;
next	;


desc
@VT52 user interface for lp.dev and lpr.ttp
@


1.1
log
@Initial revision
@
text
@/* user interface for lpr printer client.
(C) Dr. Thomas redelberger, Dec 1999 
*/

/* $Id$
*/

#include <string.h>		/* strcat, strlen */
#include <stdarg.h>		/* vsprintf */
#include <stdio.h>		/* vsprintf */
#include <tos.h>		/* Cconws, _appl_yield */

#include "lprui.h"

void* uiH;


#define TITLEN	8
static char gtitle[TITLEN+1];		/* that is the ui opject in this case */



/************************************************************************************************/
/************************************************************************************************/

void* uiOpen(char *title)
{
	strncpy(gtitle, title, TITLEN);
	gtitle[TITLEN] = '\0';

	return gtitle;
}


#pragma warn -par		 /* do not moarn unused parameters */

/************************************************************************************************/
/************************************************************************************************/

void uiClose(void *uiH)
{
}



/************************************************************************************************/
/************************************************************************************************/

void uiYield(void *uiH, long waitMilliSecs)
{
	_appl_yield();
}

#pragma warn +par */


/************************************************************************************************/
/************************************************************************************************/

void myCconws(char *s)
{
	for ( ; *s; s++)
		Bconout(2, *s);
}


/************************************************************************************************/
/************************************************************************************************/

void uiPrintf(void *uiH, int type, char *format, ...)
{
	char buff[120];
	va_list arglist;

	strcpy(buff, uiH);
	switch (type) {
	case 0:
	case 1:
		break;

	case 2:
		strcat(buff, " warning");
		break;

	case 3:
		strcat(buff, " error");
		break;
	}
	
	strcat(buff, " ");


	va_start(arglist, format);
	vsprintf(buff+strlen(buff), format, arglist);
	va_end(arglist);

	strcat(buff, "\r\n");

	myCconws(buff);
}	/* uiPrintf */
@
