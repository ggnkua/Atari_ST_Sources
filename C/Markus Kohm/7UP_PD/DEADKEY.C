/* Deadkeys */
/*****************************************************************************
*
*											  7UP
*										Modul: DEADKEY.C
*									 (c) by TheoSoft '92
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>

#include "7up.h"
#include "alert.h"
#include "di_fly.h"

extern OBJECT *winmenu, *menueditor;
char *split_fname(char *pathname);
char *find_7upinf(char *path, char *ext, int read_write);
char shortcutfile[32]="";
int scaktiv;

#if GEMDOS
#include <ext.h>

typedef struct /* Deadkeystruktur */
{
	unsigned char dead,sym,sign;
} DK;

static DK dk[]= /* Deadkeyliste  */
{
	'\'','a','†',
	'\'','e','Ç',
	'\'','E','ê',
	'\'','i','°',
	'\'','o','¢',
	'\'','u','£',

	'`','a','Ö',
	'`','A','∂',
	'`','e','ä',
	'`','i','ç',
	'`','o','ï',
	'`','u','ó',

	'^','a','É',
	'^','e','à',
	'^','i','å',
	'^','o','ì',
	'^','u','ñ',

	'~','a','∞',
	'~','A','∑',
	'~','n','§',
	'~','N','•',
	'~','o','±',
	'~','O','∏',

	'o','a','Ü',
	'o','A','è',

	'/','o','≥',
	'/','O','≤',

	',','c','á',
	',','C','Ä',

	'_','a','¶',
	'_','o','ß',

	'\"','e','â',
	'\"','i','ã',
	'\"','y','ò',

	'a','e','ë',
	'A','E','í',
	'<','<','Æ',
	'>','>','Ø',
	'!','!','≠',
	'?','?','®',
	'f','f','',
	'F','F','',

	'1','2','´',
	'1','4','¨',

	'+','-','Ò',
	'>','=','Ú',
	'<','=','Û',

	'^','2','˝',
	'^','3','˛'
};

static char *shortcut=NULL;

int deadkey(int dead, int key, char **cp)				/* Zeichen wandeln			  */
{
	register int i;
	register char sct[4];
	
	sct[0]=dead;
	sct[1]=key;
	sct[2]='=';
	sct[3]=0;
	*cp=NULL;	
	if(shortcut && (*cp=strstr(shortcut,sct))!=NULL)/* Shortcut aus Datei */
	{																/* nachtrÑglich erweitert */
		(*cp)+=3;
		return(0);
	}
	
	for(i=0; i<sizeof(dk)/3; i++)
	{
		if(dk[i].dead == dead)				  /* Deadkey gefunden			 */
			for(i; dk[i].dead == dead; i++)  /* weiter mit den Symbolen	*/
				if(dk[i].sym == key)			 /* Zeichen gefunden			 */
					return(dk[i].sign);		  /* Sonderzeichen zurÅckgeben */
	}
	return(key);
}

int isdeadkey(int dead)			  /* gehîrt das Zeichen zu den Deadkeys */
{
	register int i;
	register char *cp;
	
	if(shortcut)						 /* nachladbare Shortcuts */
	{
		cp=shortcut;
		while((cp=strchr(cp,'='))!=NULL)
		{
			if((*(cp-2) == dead) || (*(cp-3) == dead))
				return(dead);
			cp++;
		}
	}

	for(i=0; i<sizeof(dk)/3; i++) /* erstes Zeichen der Liste abklappern */
	{
		if(dk[i].dead == dead)	  /* Zeichen gefunden						  */
			return(dead);
	}
	return(FALSE);
}
#endif

static void _loadshortcuts(char *filename)
{
	FILE *fp;
	register char *cp;
	
	if((fp=fopen(filename,"rb"))!=NULL)	
	{
		form_write(menueditor,MENUTFILE,split_fname(filename),FALSE);
		graf_mouse(BUSY_BEE,NULL);
		if(shortcut)
			free(shortcut);
		if((shortcut=malloc(filelength(fileno(fp))+1))!=NULL)
		{
			fread(shortcut,1,filelength(fileno(fp)),fp);
			shortcut[filelength(fileno(fp))]=0; /* letztes Zeichen eine 0 */
/*
			strcpy(filename,(char *)split_fname(filename));
			if((cp=strchr(filename,'.'))!=NULL)
				*cp=0;
*/
         strcpy(shortcutfile,(char *)split_fname(filename)); /* wird in Infozeile eingeblendet */

			if((cp=strrchr(shortcut,'#'))!=NULL) /* Kommentarkopf abschneiden */
				if((cp=strchr(cp,'\n'))!=NULL)
					memmove(shortcut,cp+1,strlen(cp+1)+1);
			cp=shortcut;
			while((cp=strchr(cp,'='))!=NULL)		 /* Leerzeichen vor den '=' lîschen */
			{
				if(*(cp-1)==' ')
					memmove(cp-1,cp,strlen(cp)+1);
				else
					cp++;
			}
		}
		else
			form_alert(1,Adeadkey[0]);
		fclose(fp);
		graf_mouse(ARROW,NULL);
	}
}

void loadshortcuts(char *filename)
{
	FILE *fp;
	char *cp,pathname[PATH_MAX];
	
	search_env(pathname,filename,FALSE); /* READ */
	_loadshortcuts(pathname);
}

static int _hndl_shortcuts(OBJECT *tree)
{
	FILE *fp;
	char *cp,str[4],filename[PATH_MAX]="";
	int a, exit_obj, last_entry=FALSE, desk=1, m_title, c_title, m_entry, c_entry;
	/*static*/ char fpattern[FILENAME_MAX]="*.*";

	extern int boxw, windials;
		
	m_title=(winmenu+winmenu->ob_head)->ob_head;
	c_title=(winmenu+m_title)->ob_head;
	m_entry=(winmenu+winmenu->ob_tail)->ob_head;
	c_entry=(winmenu+m_entry)->ob_head;

	tree[MENUTSAVE].ob_flags|=HIDETREE;

	tree[MENUMIDX].ob_flags&=~EDITABLE;
	form_write(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index,FALSE);
	sprintf(str,"%003d",c_entry);
	
	a = tree[MENUTAKTIV].ob_state; /* merken */
	
	form_write(tree,MENUMIDX,str,FALSE);
	form_exopen(tree,0);
   do
   {
      exit_obj=(form_exdo(tree,0)&0x7FFF);
      switch(exit_obj)
      {
			case MENUMVOR:
				form_read(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index);
				c_entry=(winmenu+c_entry)->ob_next;
				if(desk) /* Deskmenu nicht auswerten */
				{
					c_entry=m_entry;
					desk=0;
				}
				if(c_entry == m_entry || c_entry == -1)
				{
					c_title=(winmenu+c_title)->ob_next;
					m_entry=(winmenu+m_entry)->ob_next;
					c_entry=(winmenu+m_entry)->ob_head;
					if(c_title==m_title)
					{
						m_title=(winmenu+winmenu->ob_head)->ob_head;
						c_title=(winmenu+m_title)->ob_head;
						m_entry=(winmenu+winmenu->ob_tail)->ob_head;
						c_entry=(winmenu+m_entry)->ob_head;
						desk=1;
					}
				}
				if(!*(char *)winmenu[c_entry].ob_spec.index ||
					 *(char *)winmenu[c_entry].ob_spec.index == '-')
					c_entry=(winmenu+c_entry)->ob_next;
				while(c_entry>=WINDAT1 && c_entry<=WINDAT7) /* diese benîtigen wir nicht */
					c_entry=(winmenu+c_entry)->ob_next;
				if(c_entry == m_entry || c_entry == -1)
				{  /* weiter zum nÑchsten MenÅ, wg. WINDAT7 = letzter Eintrag */
					c_title=(winmenu+c_title)->ob_next;
					m_entry=(winmenu+m_entry)->ob_next;
					c_entry=(winmenu+m_entry)->ob_head;
				}
				form_write(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index,TRUE);
				sprintf(str,"%003d",c_entry);
				form_write(tree,MENUMIDX,str,TRUE);
				evnt_timer(62,0);
        		break;
			case MENUMHELP:
			   form_alert(1,Adeadkey[4]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
        		break;
			case MENUMSAVE:
				form_read(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index);
				strcpy(fpattern,"*.MNU");
				find_7upinf(filename,"MNU",TRUE);
				if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
					strcpy(&cp[1],fpattern);
				else
					*filename=0;
				if(getfilename(filename,fpattern,"@",fselmsg[5]))
					_savemenu(filename);
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
			   break;
			case MENUMLOAD:
			   /* muû TRUE, weil nicht 7UP.MNU sondern auch XYZ.MNU gÅltig ist */
				strcpy(fpattern,"*.MNU");
				find_7upinf(filename,"MNU",TRUE /*FALSE*/); 
				if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
					strcpy(&cp[1],fpattern);
				else
					*filename=0;
				if(getfilename(filename,fpattern,"@",fselmsg[6]))
				{
					_loadmenu(filename);
					form_write(tree,MENUMFILE,split_fname(filename),TRUE);
				}
				
				/* neu aufsetzen */
				m_title=(winmenu+winmenu->ob_head)->ob_head;
				c_title=(winmenu+m_title)->ob_head;
				m_entry=(winmenu+winmenu->ob_tail)->ob_head;
				c_entry=(winmenu+m_entry)->ob_head;

				form_write(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index,TRUE);
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
			   break;
			case MENUTHELP:
			   form_alert(1,Adeadkey[5]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
        		break;
			case MENUTSAVE:
				break;
			case MENUTLOAD:
				strcpy(fpattern,"*.KBD");
				find_7upinf(filename,"KBD",TRUE /*FALSE*/);
				if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
					strcpy(&cp[1],fpattern);
				else
					*filename=0;
				if(getfilename(filename,fpattern,"@",fselmsg[7]))
				{
					_loadshortcuts(filename);
					form_write(tree,MENUTFILE,split_fname(filename),TRUE);
				}
				tree[exit_obj].ob_state&=~SELECTED;
				if(!windials)
					objc_update(tree,ROOT,MAX_DEPTH);
				else
					objc_update(tree,exit_obj,0);
			   break;
			case MENUOK:
				form_read(tree,MENUMNAME,(char *)winmenu[c_entry].ob_spec.index);
        		break;
      }
   }
   while(exit_obj!=MENUOK);
	form_exclose(tree,exit_obj,0);
	if (exit_obj!=MENUOK)
	{
		tree[MENUTAKTIV].ob_state = a;
	}
	else
	{
		if(tree[MENUTAKTIV].ob_state & SELECTED)
			scaktiv=TRUE;
		else
			scaktiv=FALSE;
	}
}

int hndl_shortcuts(void)
{
	int ret, kstate;

	graf_mkstate(&ret,&ret,&ret,&kstate);
	if(kstate & (K_LSHIFT|K_RSHIFT))
	{
		if(shortcut)
		{
			free(shortcut);
			shortcut=NULL;
         *shortcutfile=0;
			form_write(menueditor,MENUTFILE,"",FALSE);
			return;
		}
	}
   _hndl_shortcuts(menueditor);
}
