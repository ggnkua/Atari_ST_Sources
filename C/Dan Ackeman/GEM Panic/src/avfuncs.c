/*
 * AVFUNCS.c
 *
 * Routines for AV PROTOCOL programs
 * mostly scavenged elsewhere, but some small modifications
 * 
 */

#ifdef USE_GEMLIB
	#define __GEMLIB_OLDNAMES
	#include <gem.h>
#else
	#include <aes.h>
	#include <vdi.h>
#endif
#include <string.h>
#include <time.h>
#include <tos.h>
#include <process.h>
#include <stdlib.h>
#include <stdio.h>     /* for the string functions */
#include <ext.h>
#include <ctype.h>		/* for toupper() */

#include "global.h"


char		*va_helpbuf = NULL;			/* ST-Guide */
short av_id = -100;

/* do_help()
 *
 * launches ST-Guide help for application
 */
 
void 
do_help(char *pattern)
{
  int i;

  if ((i=appl_find("ST-GUIDE"))>=0)
  {
    strcpy(va_helpbuf, "*:\\gempanic.hyp ");
    strcat(va_helpbuf, pattern);

	send_extmessage(i, VA_START, 0, (int)(((long)va_helpbuf >> 16) & 0x0000ffffL), (int)((long)va_helpbuf & 0x0000ffffL), 0, 0, 0);
  }
  else
    form_alert(1, "[1][Can't Find ST Guide.][ OK ]" );
}

/* start_avsystem()
 *
 * just starts up the AV message buffer and process
 */
void
start_avsystem(void)
{
  	if( AES_type == AES_single ) 
   	{
   		if (_app != 0)
			va_helpbuf = (char *) Malloc(250);
		else
			va_helpbuf = (char *) malloc(250);
	}
	else
		va_helpbuf = (char *) Mxalloc(250,ALLOCMODE);

	va_helpbuf[0] = 0;

	send_avprot();
}

/* exit_avsystem()
 *
 * free's the buffer and tells AV server we are shutting down
 */
void
exit_avsystem(void)
{
	send_avexit();
	
	Mfree(va_helpbuf);
}

/* send_vastart()
 *
 * sends a VA start message to an external application
 */
 
int 
send_vastart(char *path, char *cmdline)
{
	int i;
	char progname[32];
	char *dummy;

	strncpy(progname,path,min((strlen(path)),32));

	dummy = strrchr(progname,'.');
	
	dummy[0] = '\0';

	if (strlen(progname)>8)
		progname[8]=0;
	else
		while (strlen(progname)<8) 
			strcat(progname," ");

	/* make certain the name is uppercase */

	for (i=0;i<8;i++)
		progname[i]=toupper(progname[i]);

	if ((i=appl_find(progname))>=0)
	{	
    	strcpy(va_helpbuf, (char *)&cmdline[1]);

		send_extmessage(i, VA_START, 0, (int)(((long)va_helpbuf >> 16) & 0x0000ffffL), (int)((long)va_helpbuf & 0x0000ffffL), 0, 0, 0);

		return(1);
	}
	
	return(0);
		
}

/* get_avserver()
 *
 * identifies AV server from a list
 * and returns it's id
 */
 
short 
get_avserver(void)
{
	short ret;
	char *av_env;

	if((av_env = getenv("AVSERVER")))
	{
		ret = appl_find(av_env);

		if (ret >= 0)
			return ret;
	}

	ret = appl_find("AVSERVER");

	if (ret >= 0)
		return ret;

	ret = appl_find("JINNEE  ");

	if (ret >= 0)
		return ret;

	ret = appl_find("THING   ");

	if (ret >= 0)
		return ret;

	ret = appl_find("MAGXDESK");

	if (ret >= 0)
		return ret;

	ret = appl_find("GEMINI  ");

	if (ret >= 0)
		return ret;

	ret = appl_find("STRNGSRV");

	if (ret >= 0)
		return ret;

	return -100;
}

/* send_avprot()
 *
 * alerts AV server that we are AV aware
 */
 
void 
send_avprot(void)
{
	av_id = get_avserver();
	
	if (av_id != -100)
	{
	    strcpy(va_helpbuf, "GEMPANIC");
		send_extmessage(get_avserver(), AV_PROTOKOLL, 0,(2|16), 0, 0,(int)(((long)va_helpbuf >> 16) & 0x0000ffffL), (int)((long)va_helpbuf & 0x0000ffffL));
	}
}

/* send_avexit()
 *
 * tells AV server we are shutting down
 */

void 
send_avexit(void)
{
	if (av_id != -100)
	{
		 #ifdef __GNUC__
 			send_extmessage(get_avserver(), AV_EXIT, 0, _global[2] , 0, 0,0,0);
 		#else
			#ifdef _GEMLIB_H_
 			 	send_extmessage(get_avserver(), AV_EXIT, 0, aes_global[2] , 0, 0,0,0);
			#else
 			 	send_extmessage(get_avserver(), AV_EXIT, 0, _GemParBlk.global[2] , 0, 0,0,0);
			#endif
		 #endif
	}
}

/* send_extmessage()
 * 
 * sends an AV message to another application
 */

int
send_extmessage(int extapp, int msg0, int msg2, int msg3, int msg4, int msg5, int msg6, int msg7)
{
	int msg[8];

	msg[0] = msg0;
#ifdef __GNUC__
 	msg[1] = _global[2];  /* my apps id */
#else
  	msg[1] = _GemParBlk.global[2];  /* my apps id */
#endif
	msg[2] = msg2;
	msg[3] = msg3;   
	msg[4] = msg4;
	msg[5] = msg5;
	msg[6] = msg6;
	msg[7] = msg7;

	appl_write(extapp, (int)sizeof(msg), msg);

	return(1);
}