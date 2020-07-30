/* Liste der zuletzt editierten Dateien (soll angeblich nicht funktionieren) */
/*****************************************************************************
*
*											  7UP
*									  Modul: PICKLIST.C
*									 (c) by TheoSoft '93
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>
#include <ext.h>

#include "alert.h"

#include "forms.h"
#include "windows.h"
#include "7up.h"
#include "version.h"

#include "language.h"

#define MAXENTRIES     8L
#define MAXLETTERS    42L
#define MAXSPACES     42L
#define MAXPICKFILES 128L
#define notnull(a) (((a)>0)?(a):(1))
#define FLAGS15 0x8000

extern int boxh;

typedef struct
{
	char name[PATH_MAX];
	char line[8];
	char info[41];
}PICKLISTE;

long *get_cookie(long cookie);
void objc_update(OBJECT *tree, int obj, int depth);
void set_vslider(OBJECT *tree, int ext, int slide,  int newpos);
static int _hndl_picklist(OBJECT *tree, char *filename, long *line);
char *find_7upinf(char *path, char *ext, int mode);
long strcchg(register char *str, register char old, register char new);
void hsort(char *base, int num, int size, int (*cmp)());
char *stristr(char *s1, char *s2);
int list_do(OBJECT *tree, int exit_obj, long *first, int *which, int count, int *done);
WINDOW *Wreadtempfile(char *filename, int mode);
int access(char *filename, int fattr);

static PICKLISTE *pl=NULL;

void free_picklist()
{
	if(pl)
		free(pl);
	pl=NULL;
	return;
}

int load_picklist()
{
	FILE *fp;
	char filename[PATH_MAX];
	long i,size,lines;
	int count=0;

	if((fp=fopen(find_7upinf(filename,"PCK",FALSE),"r"))!=NULL)
	{															/* Pickfile ”ffnen */
		graf_mouse(BUSY_BEE,NULL);	
		if((pl=malloc(MAXPICKFILES*sizeof(PICKLISTE)))!=NULL)
		{
			memset(pl,0,MAXPICKFILES*sizeof(PICKLISTE));
			fgets(filename,VERSIONSTRLEN+1,fp);
			filename[strlen(filename)-1]=0; /*CR weg*/
			if(!strcmp(filename,VERSIONNAME))
			{
				while(!feof(fp))
				{
					fgets(pl[count].name,PATH_MAX,fp);
					pl[count].name[strlen(pl[count].name)-1]=0; /*CR weg*/
					if(*pl[count].name)
					{
						fgets(pl[count].line,PATH_MAX,fp);
						pl[count].line[strlen(pl[count].line)-1]=0; /*CR weg*/
						fgets(pl[count].info,41,      fp);
						pl[count].info[strlen(pl[count].info)-1]=0; /*CR weg*/
						count++;
					}
				}
			}
			else
			{
				if(filelength(fileno(fp)) > 0)
					form_alert(1,Apicklist[2]);
			}
		}
		fclose(fp);
		graf_mouse(ARROW,NULL);	
	}
	return(count);
}

int change_picklist(int count)
{
	FILE *fp;
	char filename[PATH_MAX];
	int i;

	if((fp=fopen(find_7upinf(filename,"PCK",TRUE),"w"))!=NULL)
	{													/* Pickfile ”ffnen */
		graf_mouse(BUSY_BEE,NULL);	
		fprintf(fp,"%s\n",VERSIONNAME);
		for(i=0; i<count; i++)
			if(*pl[i].name)
			{
				fprintf(fp,"%s\n",pl[i].name);
				fprintf(fp,"%s\n",pl[i].line);
				fprintf(fp,"%s\n",pl[i].info);
			}
		fclose(fp);												/* Datei schliežen */
		graf_mouse(ARROW,NULL);	
	}
}

static int name_existiert(char *name) /* abklappern, ob Fenstername schon vorhanden */
{
	int i;
	extern WINDOW _wind[];
	for(i=1; i<MAXWINDOWS; i++) /* Fensternamen sichern */
	{
		if((_wind[i].w_state & CREATED) && /* Fenster muž existieren */
			!strcmp(name,(char *)Wname(&_wind[i])))
			return(TRUE);
	}
	return(FALSE);
}

static char *getinfo(char *pathname, int count)
{
	int i;
	
	for(i=0; i<count; i++)
		if(!stricmp(pl[i].name, pathname))
			return(pl[i].info);
	return("");
}

void append_picklist(OBJECT * tree, char *pathname, long line)
{
	FILE *fp;
	char filename[PATH_MAX];
	int i, count=0;
	char info[41]="";
	
	extern WINDOW _wind[];
	
	if(Wcount(CREATED)==0)
		return;

	if(!(tree[PICKAKTIV].ob_state & SELECTED)) /* ist ausgeschaltet 8.1.95 */
		return;

	count=load_picklist();
	if((fp=fopen(find_7upinf(filename,"PCK",TRUE),"w"))!=NULL)
	{
		graf_mouse(BUSY_BEE,NULL);	
		if(pathname)
		{
			fprintf(fp,"%s\n",VERSIONNAME);
			for(i=0; i<count; i++)
			   if(stricmp(pathname, pl[i].name))
			   {							/* alles sichern, was anders ist */
					fprintf(fp,"%s\n",pl[i].name);
					fprintf(fp,"%s\n",pl[i].line);
					fprintf(fp,"%s\n",pl[i].info);
				}
				else
					strcpy(info,pl[i].info);
			fprintf(fp,"%s\n",pathname);
			fprintf(fp,"%ld\n",line);
			fprintf(fp,"%s\n",info);
		}
		else
		{
			fprintf(fp,"%s\n",VERSIONNAME);
			for(i=0; i<count; i++)
				if(!name_existiert(pl[i].name))
				{							/* alles sichern, was anders ist */
					fprintf(fp,"%s\n",pl[i].name);
					fprintf(fp,"%s\n",pl[i].line);
					fprintf(fp,"%s\n",pl[i].info);
				}
			for(i=1; i<MAXWINDOWS; i++)
				if((_wind[i].w_state & CREATED) &&
					(strcmp(NAMENLOS,(char *)Wname(&_wind[i]))) &&
					(1/*!stristr(pickbuff,(char *)Wname(&_wind[i]))*/))
				{
					fprintf(fp,"%s\n",(char *)Wname(&_wind[i]));
					fprintf(fp,"%ld\n",_wind[i].row + _wind[i].hfirst/_wind[i].hscroll + 1);
					fprintf(fp,"%s\n",getinfo((char *)Wname(&_wind[i]),count));
				}
		}
		fclose(fp);
		graf_mouse(ARROW,NULL);	
	}
	free_picklist();
}

static char *stradj(char *dest, char *src, int maxlen)
{
	register int len;
	dest[0]=' ';
	if((len=strlen(src))>maxlen)
	{
		strncpy(&dest[1],src,maxlen/2);
		strncpy(&dest[maxlen/2+1],&src[len-maxlen/2],maxlen/2);
		dest[maxlen/2-1+1]='.';
		dest[maxlen/2+0+1]='.';
		dest[maxlen/2+1+1]='.';
	}
	else
	{
		strcpy(&dest[1],src);
		memset(&dest[len+1],' ',maxlen-len+1);
	}
	dest[maxlen+1]=' ';
	dest[maxlen+2]=0;
	return(dest);
}

static int list_do(OBJECT *tree, int exit_obj, long *first, int *which, int count, int *done)
{
	int my,ret,newpos,oby,kstate;
/*	
	*which=-1;
*/
	graf_mkstate(&ret,&my,&ret,&kstate);
	switch(exit_obj)
	{
		case PICKUP:
			if(kstate & (K_LSHIFT|K_RSHIFT))
			{
				if((*first-MAXENTRIES)>0)
					*first-=MAXENTRIES;
				else
					*first=0;
			}
			else
			{
				if(*first>0)
					(*first)--;
				else
					exit_obj=-1;
			}
			break;
		case PICKDN:
			if(kstate & (K_LSHIFT|K_RSHIFT))
			{
				if((*first+MAXENTRIES)<(count-MAXENTRIES))
					*first+=MAXENTRIES;
				else
					*first=count-MAXENTRIES;
			}
			else
			{
				if(*first<count-MAXENTRIES)
					(*first)++;
				else
					exit_obj=-1;
			}
			break;
		case PICKSLID:
			graf_mouse(FLAT_HAND,NULL);
			newpos=graf_slidebox(tree,PICKBOX,PICKSLID,1);
			graf_mouse(ARROW,NULL);
			*first=((newpos*(count-MAXENTRIES))/1000L);
			break;
		case PICKBOX:
			objc_offset(tree,exit_obj+1,&ret,&oby);
			if(my>oby)
			{
				if((*first+MAXENTRIES)<(count-MAXENTRIES))
					*first+=MAXENTRIES;
				else
					*first=count-MAXENTRIES;
			}
			else
			{
				if((*first-MAXENTRIES)>0)
					*first-=MAXENTRIES;
				else
					*first=0;
			}
			break;
		case PICKFIRST:
		case PICKFIRST+1:
		case PICKFIRST+2:
		case PICKFIRST+3:
		case PICKFIRST+4:
		case PICKFIRST+5:
		case PICKFIRST+6:
		case PICKLAST:
			*which=exit_obj-PICKFIRST+*first;
			break;
	}
	if((exit_obj) & 0x8000) /* Verlassen mit Doppelklick */
	{
		switch((exit_obj) &= 0x7FFF)
		{
			case PICKUP:
				if(*first>0)
					*first=0;
				else
					exit_obj=-1;
				break;
			case PICKDN:
				if(*first<count-MAXENTRIES)
					*first=count-MAXENTRIES;
				else
					exit_obj=-1;
				break;
			case PICKFIRST:
			case PICKFIRST+1:
			case PICKFIRST+2:
			case PICKFIRST+3:
			case PICKFIRST+4:
			case PICKFIRST+5:
			case PICKFIRST+6:
			case PICKLAST:
				*which=exit_obj-PICKFIRST+*first;
				*done=TRUE;
				break;
		}
	}
	return(exit_obj);
}

static int _hndl_picklist(OBJECT *tree, char *filename, long *line)
{
	static long first2=0;

	long first,newpos;
	int which=-1,count,count2,exit_obj,done=FALSE,changed=FALSE;
	int i,k,ret,kstate;
	struct ffblk fileRec;
	
	char string[41];

	count=load_picklist();
	if(count==0)
		return(-1);
	count2=count;
/*	
	hsort(pl,count,sizeof(char *),strcmp);
*/
/**************************************************************************/
/* letzte OK-Werte einstellen, falls verstellt und Abbruch gedrckt wurde */
/**************************************************************************/
	first=first2;

	for(i=PICKFIRST; i<=PICKLAST; i++)
	{
		tree[i].ob_state&=~SELECTED;
		tree[i].ob_flags&=~SELECTABLE;
	}
	tree[PICKSLID].ob_height=
			 max(boxh,MAXENTRIES*tree[PICKBOX].ob_height/max(MAXENTRIES,count));
	newpos=/*(int)*/((first*1000L)/notnull(count-MAXENTRIES));
   newpos=max(0,newpos);
	newpos=min(newpos,1000);
	set_vslider(tree,PICKBOX,PICKSLID,newpos);

	for(i=first,k=0; i<count && k<MAXENTRIES; i++,k++)
	{
		stradj(string,pl[i].name,MAXLETTERS-2);
		form_write(tree,PICKFIRST+k,string,FALSE);
		tree[PICKFIRST+k].ob_flags|=SELECTABLE;
	}
/*MT 16.7.94*/
	form_write(tree,PICKCOMMENT,"",FALSE);

	memset(string,' ',MAXLETTERS);
	string[MAXLETTERS]=0;
	for(; k<MAXENTRIES; k++)
		form_write(tree,PICKFIRST+k,string,FALSE);
/*
	if(get_cookie('MiNT') && (_GemParBlk.global[1] != 1)) /* MultiTOS */
		tree[PICKBOX].ob_spec.obspec.fillpattern=4;
*/
	tree[PICKDEL].ob_state|=DISABLED;
	tree[PICKCLEAN].ob_state|=DISABLED;

	sprintf(string,PICKFILES,count2);
	form_write(tree,PICKINFO,string,FALSE);
/*   
	if(_GemParBlk.global[0] >=0x0340) /* Ab Falcon Muster „ndern */
	{
		tree[PICKBOX ].ob_spec.obspec.fillpattern=4;
	}
*/
	form_exopen(tree,0);
	do
	{
		exit_obj=form_exdo(tree,0);

		if(which>-1)
			form_read(tree,PICKCOMMENT,pl[which].info);

		exit_obj=list_do(tree, exit_obj, &first, &which, count, &done);
		switch(exit_obj)
		{
			case PICKHELP:
				form_alert(1,Apicklist[0]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			case PICKDEL:
				if(which>-1)
				{
					graf_mouse(BUSY_BEE,NULL);	
				   if(tree[PICKCLEAN].ob_state & SELECTED)
				   {
				      for(i=0; i<count; i++)
				      {
/* L”schen, wenn A | B | N | (U & (A | B)) | 'nicht existent' */
				         if((toupper(pl[i].name[0]) == 'A') ||
				            (toupper(pl[i].name[0]) == 'B') ||
				            (toupper(pl[i].name[0]) == 'N') ||
				            ((toupper(pl[i].name[0]) == 'U') && 
				             ((toupper(pl[i].name[3]) == 'A') ||
				              (toupper(pl[i].name[3]) == 'B'))) ||
				            (!access(pl[i].name,0)) )
							{
									*pl[i].name=0; /* L”schen */
									if((i+PICKFIRST-first)>=PICKFIRST && 
									   (i+PICKFIRST-first)<=PICKLAST)
									{
										tree[i+PICKFIRST-first].ob_state&=~SELECTED;
										memset(string,' ',MAXLETTERS);
										string[MAXLETTERS]=0;
										form_write(tree,i+PICKFIRST-first,string,TRUE);
									}
							}
				      }
				   }
				   else
					{
						*pl[which].name=0; /* L”schen */
						tree[which+PICKFIRST-first].ob_state&=~SELECTED;
						memset(string,' ',MAXLETTERS);
						string[MAXLETTERS]=0;
						form_write(tree,which+PICKFIRST-first,string,TRUE);
					}
					change_picklist(count);
					which=-1;
					changed=TRUE;
				   sprintf(string,PICKFILES,--count2);	
				   form_write(tree,PICKINFO,string,TRUE);
					graf_mouse(ARROW,NULL);	
				}
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
								tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				tree[PICKCLEAN].ob_state&=~SELECTED;
				tree[PICKCLEAN].ob_state|=DISABLED;
				objc_update(tree,PICKCLEAN,0);
				tree[PICKDEL].ob_state|=DISABLED;
				objc_update(tree,PICKDEL,0);
				break;
			case PICKFIRST:
			case PICKFIRST+1:
			case PICKFIRST+2:
			case PICKFIRST+3:
			case PICKFIRST+4:
			case PICKFIRST+5:
			case PICKFIRST+6:
			case PICKLAST:
			   sprintf(string,PICKFILESSELECTED,count2);	
			   form_write(tree,PICKINFO,string,TRUE);
/*MT 16.7.94*/
				if(which>-1)
					form_write(tree,PICKCOMMENT,pl[which].info,TRUE);
				objc_change(tree,PICKCLEAN,0,tree->ob_x,tree->ob_y,
								tree->ob_width,tree->ob_height,tree[PICKCLEAN].ob_state&~DISABLED,TRUE);
				objc_change(tree,PICKDEL,0,tree->ob_x,tree->ob_y,
								tree->ob_width,tree->ob_height,tree[PICKDEL].ob_state&~DISABLED,TRUE);
				changed=TRUE;
				break;
			case PICKUP:
			case PICKDN:
			case PICKBOX:
			case PICKSLID:
				if(count>MAXENTRIES)
				{
					for(i=PICKFIRST; i<=PICKLAST; i++)
						if(tree[i].ob_state & SELECTED)
							which=i-PICKFIRST+first;
					newpos=/*(int)*/((first*1000L)/notnull(count-MAXENTRIES));
					newpos=min(max(0,newpos),1000);
					set_vslider(tree,PICKBOX,PICKSLID,newpos);
					objc_update(tree,PICKBOX,MAX_DEPTH);
					for(i=first,k=0; k<MAXENTRIES; i++,k++)
					{
						stradj(string,pl[i].name,MAXLETTERS-2);
						form_write(tree,PICKFIRST+k,string,TRUE);
					}
					if(which>-1)
						form_write(tree,PICKCOMMENT,pl[which].info,TRUE);
				}
				break;
			case PICKOK:
			case PICKABBR:
				done=TRUE;
				break;
		}
	}
	while(!done);
	form_exclose(tree, exit_obj, 0);
	tree[PICKOK].ob_state&=~SELECTED;
	if(which>-1)
	{
		strcpy(filename,pl[which].name);
		*line = atol(pl[which].line);
	}
	if(changed)/*nach L”schen auf null, damit Neuaufbau klappt*/
		first=0;
/*
	if(changed && (exit_obj==PICKOK))
	{
		if(which>-1)
			form_read(tree,PICKCOMMENT,pl[which].info);
		change_picklist(count);
		first=0;
	}
*/
	free_picklist();
	first2=first;
	switch(exit_obj)
	{
		case PICKFIRST:
		case PICKFIRST+1:
		case PICKFIRST+2:
		case PICKFIRST+3:
		case PICKFIRST+4:
		case PICKFIRST+5:
		case PICKFIRST+6:
		case PICKLAST:
		case PICKOK:
			if(which>-1)
			{
				return(TRUE);
			}
			break;
	}
	return(FALSE);
}

int hndl_picklist(OBJECT *tree)
{
	char filename[PATH_MAX];
	long line=0;
	WINDOW *wp;
	int a;
	a = tree[PICKAKTIV].ob_state;
	
	switch(_hndl_picklist(tree,filename,&line))
	{
		case TRUE:
			if((wp=Wreadtempfile(filename,FALSE))!=NULL)
				if(line > 1) /* nur wenn positioniert werden soll */
					hndl_goto(wp, NULL, line);
			break;
		case -1:
			form_alert(1,Apicklist[1]);
			/* durchfallen!!! */
		case FALSE:
			tree[PICKAKTIV].ob_state = a;
			break;
	}
}
