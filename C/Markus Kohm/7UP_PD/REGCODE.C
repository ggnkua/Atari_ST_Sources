/* SchlÅsselregistrierung (Code gelîscht) */
/*****************************************************************************
*
*											 7UP
*									  Modul: REGCODE.C
*								  (c) by TheoSoft '92/94
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <tos.h>
#include <ext.h>

#include "7up.h"
#include "forms.h"
#include "windows.h"
#include "alert.h"

#include "language.h"

#define FILEIOBUFF (32*1024L)

char *search_env(char *path, char *filename, int write);

static unsigned long sum(unsigned char *str)
{
   /* algorithm canceled */
   return(0);
}

static unsigned long summe1(char *str)
{
   /* algorithm canceled */
   return(0);
}

static unsigned long summe2(char *str)
{
   /* algorithm canceled */
   return(0);
}

static unsigned long cryptsumme(char *str)
{
   /* algorithm canceled */
   return(0);
}

void reg_code()
{
}

int loadlizenz(char *filename)
{
	FILE *fp;
   char name[40], code[11];
   char pathname[PATH_MAX];

   extern char alertstr[];
   extern OBJECT *registmenu, *copyinfo;

   if((fp=fopen(search_env(pathname,filename,FALSE),"r"))!=NULL)
   {
   	fgets(name,sizeof(name),fp);
		if(name[strlen(name)-1]=='\n')
			name[strlen(name)-1]=0;
   	
   	fgets(code,sizeof(code),fp);
		if(code[strlen(code)-1]=='\n')
			code[strlen(code)-1]=0;

   	fclose(fp);

		if((cryptsumme(name) == atol(code)) && (strlen(name) != 0))
		{
		   form_write(registmenu,REGISTNAME,name,FALSE);
   		form_write(registmenu,REGISTKEY ,code,FALSE);

			strcpy(alertstr,BENUTZER);
			strcat(alertstr,name);
   		form_write(copyinfo,CNAME,alertstr,FALSE);

			return(TRUE);
   	}
   }
	return(FALSE);
}

int registerprogram(char *filename)
{
	FILE *fp;
   char name[40], code[11];
   char pathname[PATH_MAX];

   extern char alertstr[];
   extern OBJECT *registmenu, *copyinfo;

   form_read(registmenu,REGISTNAME,name);
   form_read(registmenu,REGISTKEY ,code);

	if((cryptsumme(name) != atol(code)) || (strlen(name) == 0))
  	{
  		form_alert(1,Aregcode[0]);
  		return(FALSE);
  	}

   if((fp=fopen(search_env(pathname,filename,TRUE),"wb"))!=NULL)
   {
   	fprintf(fp,"%s\r\n%ls",name,code);
   	fclose(fp);

		strcpy(alertstr,BENUTZER);
		strcat(alertstr,name);
		form_write(copyinfo,CNAME,alertstr,FALSE);

		sprintf(alertstr,Aregcode[1],name,code);
  		form_alert(1,alertstr);

   	return(TRUE);
   }

	return(FALSE);
}
