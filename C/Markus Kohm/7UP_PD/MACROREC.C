/* Aufzeichnung und Wiedergabe von TastaturdrÅcken, siehe auch mevent.c */
/*****************************************************************************
*
*                                   7UP
*                             Modul: MACROREC.C
*                            (c) by TheoSoft '94
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>

#include "windows.h"
#include "7up.h"
#include "version.h"
#include "macro.h"

#include "alert.h"

#define MAXLONGINT 0x7FFFFFFF

TMACRO macro = {VERSIONNAME,0x0100,sizeof(TMACRO)-sizeof(void *),0L,0L,0L,0L,0L,0L,0L,NULL};

int record_macro(int command, int kstate, int key) 
{
	TMACROBUFF *ip;
	
	switch(command)
	{
		case MACREC:
			if(macro.mp)
				free(macro.mp);
		   macro.mp=(TMACROBUFF *)malloc(MAX_MACROS*sizeof(TMACROBUFF));
			if(macro.mp)
			{
				macro.size  = MAX_MACROS;
				macro.rec   = TRUE;
				macro.play  = FALSE;
				macro.macroindex = 0;
				macro.lastmacro = -1;
				macro.lastrep = 1;
				memset(macro.mp, 0, MAX_MACROS*sizeof(TMACROBUFF));
			}
			return(0);
			break;
		case MACSTOP:
			if(macro.rec)
				macro.rec = FALSE;
			return(0);
			break;
		case MACPLAY:
			if(macro.mp)
			{
				macro.macroindex = 0;
				macro.repindex   = 0;
				macro.rec  = FALSE;
				macro.play = TRUE;
			}
			return(0);
			break;
		default:
			if(macro.rec)
			{
				if(macro.lastmacro==-1) /* als erstes die Wiederholrate */
				{
					if(isdigit(key)) /* Ziffer? */
					{
						macro.lastrep=(int)((char)key-'0'); /* 1-9 erlaubt */
						macro.lastmacro++;
					}
					else /* Ziffer!!! */
					{
						macro.rec = FALSE; /* Fehler, halt! */
						form_alert(1,Amacrorec[0]);
					}
					return(0);
				}
				else
				{
					if(macro.lastmacro < macro.size) /* paût das Zeichen noch in den Puffer */
					{
						macro.mp[macro.lastmacro].kstate = kstate;
						macro.mp[macro.lastmacro].key    = key;
						macro.lastmacro++;
					}
					else /* Makroplatz ist zu klein, erweitern wir ihn */
					{
						if(macro.size + MAX_MACROS <= MAXLONGINT) 
						{  /* immer um 256 erweitern, aber nicht mehr als 2^31-1 */
							ip = (TMACROBUFF *)realloc(macro.mp,(macro.size+MAX_MACROS)*sizeof(TMACROBUFF));
							if(ip) /* der Platz reicht */
							{
								macro.mp    = ip;      /* Pointer auf neuen Wert */
								macro.size += MAX_MACROS; /* Puffer grîûer machen */
								/* das letzte Zeichen nehmen wir aber noch mit! */
								macro.mp[macro.lastmacro].kstate = kstate;
								macro.mp[macro.lastmacro].key    = key;
								macro.lastmacro++;
							}
							else /* leider kein Speicher mehr frei */
							{
								form_alert(1,Amacrorec[1]);
								macro.rec = FALSE;
							}
						}
						else /* max. Makrogrîûe erreicht */
						{	
							form_alert(1,Amacrorec[1]);
							macro.rec = FALSE;
						}
					}
				}
			}
			return(MU_KEYBD);
			break;
	}
}

int play_macro(int *kstate, int *key)
{
	if(macro.repindex < macro.lastrep)
	{
		if(macro.macroindex < macro.lastmacro)
		{
		 	*kstate = macro.mp[macro.macroindex].kstate;
			*key	  = macro.mp[macro.macroindex].key;
			macro.macroindex++;
			return(MU_KEYBD|MU_TIMER);
		}
		macro.macroindex=0;
		macro.repindex++;
		return(0);
	}
	macro.repindex=1;
	macro.play=FALSE;
	return(0);
}

void _loadmacro(char *filename)
{
	FILE *fp;

	if((fp=fopen(filename,"rb"))!=NULL)
	{
		if(macro.mp) /* alten MÅll freigeben */
			free(macro.mp);
		fread(&macro,sizeof(TMACRO),1,fp); /* Kopf laden */
	   macro.mp=(TMACROBUFF *)malloc(macro.size*sizeof(TMACROBUFF));
		if(macro.mp) /* Speicher angefordert */
			fread(macro.mp,macro.size*sizeof(TMACROBUFF),1,fp); /* hinein damit */
		fclose(fp);
	}
}

void loadmacro(void)
{
	char *cp, filename[PATH_MAX]="";
	/*static*/ char fpattern[FILENAME_MAX]="*.*";

	strcpy(fpattern,"*.MAC");
	find_7upinf(filename,"MAC",TRUE /*FALSE*/);
	if((cp=strrchr(filename,'\\'))!=NULL)
		strcpy(&cp[1],fpattern);
	else
		*filename=0;
	if(getfilename(filename,fpattern,"@",fselmsg[28]))
		_loadmacro(filename);
}

void _savemacro(char *filename)
{
	FILE *fp;

	if(!macro.mp)
		return;

	if((fp=fopen(filename,"wb"))!=NULL)
	{
		fwrite(&macro,sizeof(TMACRO),1,fp); /* Kopfdaten schreiben */
		fwrite(macro.mp,macro.size*sizeof(TMACROBUFF),1,fp); /* Makros schreiben */
		fclose(fp);
	}
}

void savemacro(void)
{
	char *cp, filename[PATH_MAX]="";
	/*static*/ char fpattern[FILENAME_MAX]="*.*";

	strcpy(fpattern,"*.MAC");
	find_7upinf(filename,"MAC",TRUE /*FALSE*/);
	if((cp=strrchr(filename,'\\'))!=NULL)
		strcpy(&cp[1],fpattern);
	else
		*filename=0;
	if(getfilename(filename,fpattern,"@",fselmsg[29]))
		_savemacro(filename);
}
