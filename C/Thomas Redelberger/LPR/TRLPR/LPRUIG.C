/* user interface for lpr printer client.
(C) Dr. Thomas redelberger, Dec 1999
GEM AES version 
*/

/* $Id: lpruig.c 1.1 1999/12/30 12:55:34 Thomas Exp Thomas $
*/

#include <string.h>		/* strcat, strlen */
#include <stdarg.h>		/* vsprintf */
#include <stdio.h>		/* vsprintf */
#include <portab.h>
#include <aes.h>

#include "lprui.h"

void* uiH;


#define TITLEN	8
static char gtitle[TITLEN+1];		/* that is the ui object in this case */



/************************************************************************************************/
/************************************************************************************************/

void* uiOpen(char *title)
{
	if ( appl_init() < 0 ) return NULL;

	strncpy(gtitle, title, TITLEN);
	gtitle[TITLEN] = '\0';

	return gtitle;
}


#pragma warn -par		 /* do not moarn unused parameters */

/************************************************************************************************/
/************************************************************************************************/

void uiClose(void *uiH)
{
	appl_exit();
}



/************************************************************************************************/
/************************************************************************************************/

void uiYield(void *uiH, long waitMilliSecs)
{
	evnt_timer( (int)(waitMilliSecs & 0xffff), (int)(waitMilliSecs>>16) );
}

#pragma warn +par


/************************************************************************************************/
/************************************************************************************************/

void uiPrintf(void *uiH, int type, char *format, ...)
{
	char buff[100];
	va_list arglist;

	strcpy(buff, "[1][");
	buff[1] = '0' + type;		/* insert the icon */
	strcat(buff, uiH);
	strcat(buff, "|");

	va_start(arglist, format);
	vsprintf(buff+strlen(buff), format, arglist);
	va_end(arglist);

	strcat(buff, "][OK]");

	form_alert(1, buff);

}	/* uiPrintf */
