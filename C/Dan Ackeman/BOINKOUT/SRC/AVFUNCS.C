/*
 * AVFUNCS.c
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *   Electronic contact can be made via the following web address
 *  	http://www.netset.com/~baldrick/stik2.html
 *
 * Routines for AV PROTOCOL programs
 * mostly scavenged elsewhere, but some small modifications
 * 
 */

#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <time.h>
#include <tos.h>
#include <process.h>
#include <stdlib.h>
#include <stdio.h>     /* for the string functions */
#include <ext.h>
#include <ctype.h>		/* for toupper() */

#include "boink.h"


char		*va_helpbuf = NULL;			/* ST-Guide */
short av_id = -100;

void do_help(char *pattern)
{
  int i;

  if ((i=appl_find("ST-GUIDE"))>=0)
  {
    strcpy(va_helpbuf, "*:\\boinkout.hyp ");
    strcat(va_helpbuf, pattern);

	send_extmessage(i, VA_START, 0, (int)(((long)va_helpbuf >> 16) & 0x0000ffffL), (int)((long)va_helpbuf & 0x0000ffffL), 0, 0, 0);
  }
  else
    form_alert(1, "[1][Can't Find ST Guide.][ OK ]" );
}

int send_vastart(char *path, char *cmdline)
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

short get_avserver(void)
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

void send_avprot(void)
{
	av_id = get_avserver();
	
	if (av_id != -100)
	{
	    strcpy(va_helpbuf, "BOINKOUT");
		send_extmessage(get_avserver(), AV_PROTOKOLL, 0,(2|16), 0, 0,(int)(((long)va_helpbuf >> 16) & 0x0000ffffL), (int)((long)va_helpbuf & 0x0000ffffL));
	}
}


void send_avexit(void)
{
	if (av_id != -100)
	{
 #ifdef __GNUC__
 		send_extmessage(get_avserver(), AV_EXIT, 0, _global[2] , 0, 0,0,0);
 #else
 	 	send_extmessage(get_avserver(), AV_EXIT, 0, _GemParBlk.global[2] , 0, 0,0,0);
 #endif
	}
}
