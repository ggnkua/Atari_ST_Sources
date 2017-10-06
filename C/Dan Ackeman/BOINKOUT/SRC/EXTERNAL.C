/*
 * External.c
 * 
 * Routines for external programs
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

#include "boink.h"

typedef struct _shelw{
char *newcmd;
long psetlimit;
long prenice;
char *defdir;
char *env;
} SHELW;

extern int AES_type;

int
run_web_browser(char *temp_file)
{
	char env_path[128];
	SHELW myshellw;
	char *tomyshellw = (char *)&myshellw;
	char *browser_name;
	char *temp_name;
    char *app_name;
	int i;

	shel_envrn(&temp_name,"WWW_CLIENT");

	if (temp_name == (char *)NULL)
		shel_envrn(&temp_name,"BROWSER");

	if ((char *)temp_name == (char *)NULL)
		return(-1);

	for (i = 1; i < strlen(temp_name);i++) 
	{
		/* Make certain it's not a space or = sign */
		if((temp_name[i] != 32)&&(temp_name[i] != 61))
			break;
	}
		
	browser_name = (char *)&temp_name[i];
/*	browser_name = (char *)&temp_name[3];*/

	app_name = strrchr(browser_name,92);

	app_name = (char *)&app_name[1];

	if (av_id != -100)
	{
		if (send_vastart(app_name, temp_file) == 1)
			return(1);
	}
	
	strcpy(env_path,"PATH=$HOME,$PATH,");
	strcat(env_path,browser_name);

 	myshellw.newcmd = browser_name;
	myshellw.defdir = browser_name;
	myshellw.env = env_path;

	switch( AES_type )
	{
	case	AES_MagiC:
		shel_write(1,1,100,browser_name,temp_file);
		break;	/* Ends:	case AES_MagiC */

	case	AES_nAES:
		shel_write(0,1,1,browser_name,temp_file);
		break;	/* Ends:	case AES_nAES */

	case	AES_Geneva:
		strcpy(env_path,"PATH=");
		strcat(env_path,browser_name);
		myshellw.env = env_path;

		shel_write(0|0x800|0x400,0,0,tomyshellw,temp_file);

		break;	/* Ends:	case AES_Geneva */

	case	AES_MTOS:
		shel_write(0|0x800|0x400,0,0,tomyshellw,temp_file);

		break;	/* Ends:	case AES_MTOS */

	case	AES_single:
/* I know of no legal way for a GEM program to start another without exiting */
/* I have just put a normal Pexec here for now, so replace it with your code */

		Pexec(0,browser_name,temp_file,env_path);
		break;	/* Ends:	case AES_single */
	
	default:		/* some default method (MTOS?) for future multitaskers */
		break;	/* Ends:	default */

	}	/* Ends:	switch( AES_type ) */

	graf_mouse(0,NULL);

	return(1);
}
