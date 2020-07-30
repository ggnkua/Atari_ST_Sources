/* Tastaturbedienung des MenÅs */
/*****************************************************************************
*
*											  7UP
*									  Modul: MENUIKEY.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#if GEMDOS
#include <tos.h>
#include <ext.h>
#else
extern unsigned char b_keycod[];
#endif
#include <aes.h>

#include "7up.h"
#include "windows.h"

#if GEMDOS
#define  F1		0x3b
#define  F10	0x44
#define  F11	0x54
#define  F20	0x5d

#define  K_CAPS	0x10
#define  K_SHIFT	0x03
#define  K_SCAN	0x8000
#define  K_NUM		0x4000
#else
#define  F1		0x68
#define  F10	0x71
#define  F11	0x72
#define  F20	0x7B
#endif

#define FLAGS15 0x8000

int SysKey=FALSE;

#if GEMDOS
static KEYTAB *pkeytbl=NULL;
#endif

extern int ydesk;

char *split_fname(char *filename);

static int test_entry(char *str, int kstate, int key, int ob_flags)
{
	char *pchar, vchr;
	int ret=0,zahl;

	pchar = str;
	while(*pchar)
		pchar++;
	while(*--pchar == ' ')
		;
	vchr=__tolower(*pchar);

	if(vchr == __tolower((char)key) && !(key & 0x8000))/* 0x8000 = Scancode */
	{
		pchar-=2;
		if((*pchar==1	&& *(pchar+1)=='^' && kstate==(K_CTRL|K_LSHIFT)) ||
			(*pchar==1	&& *(pchar+1)== 7  && kstate==(K_ALT |K_LSHIFT)))
			return(TRUE);

		if((*pchar==' ' && *(pchar+1)=='^' && kstate==K_CTRL) ||
			(*pchar==' ' && *(pchar+1)== 7  && kstate==K_ALT))
			return(TRUE);

		if(((*pchar==' ' && *(pchar+1)=='^' && kstate==(K_CTRL|K_LSHIFT)) ||
			 (*pchar==' ' && *(pchar+1)== 7  && kstate==(K_ALT |K_LSHIFT))) &&
			(ob_flags & FLAGS15))
			return(TRUE);
	}
	if(key & 0x8000) /* Funktionstaste */
	{
		if(*pchar >= '0' && *pchar <= '9')
		{
			zahl=*pchar-'0';
			pchar--;
			if(*pchar >= '0' && *pchar <= '9')
			{
				zahl+=(*pchar-'0')*10;
				pchar--;
			}
			if(*pchar == 'F')
			{
			   key&=0x00FF;
				if(*(pchar-1)=='') /* z.B.: F4 */
					zahl+=10;
				if((zahl>=1) && (zahl<=10))
					if(zahl==(key-F1+1))
						ret=1;
				if((zahl>=11) && (zahl<=20))
					if(zahl==(key-F11+11))
						ret=1;
			}
      }
		if((kstate &  K_ALT) && (*(pchar-1) != 7))  /*7Fx*/
			ret=0;
		if((kstate & K_CTRL) && (*(pchar-1) != '^'))/*^Fx*/
			ret=0;
   }
/*
	if(key & 0x8000) /* Funktionstaste */
	{
		if(*pchar =='\'' && (kstate & (K_CTRL|K_ALT))==0)
		{
			pchar--;
			vchr=__tolower(*pchar);
			if(vchr==key && *(pchar-1)=='\'')
				ret=1;
		}
		else
		{
			if(*pchar >= '0' && *pchar <= '9')
			{
				zahl=*pchar-'0';
				pchar--;
				if(*pchar >= '0' && *pchar <= '9')
				{
					zahl+=(*pchar-'0')*10;
					pchar--;
				}
				if(*pchar == 'F')
				{
				   key&=0x00FF;
					if(*(pchar-1)=='') /* z.B.: F4 */
						zahl+=10;
					if((zahl>=1) && (zahl<=10))
						if(zahl==(key-F1+1))
							ret=1;
					if((zahl>=11) && (zahl<=20))
						if(zahl==(key-F11+11))
							ret=1;
				}
			}
      }
   }
*/
	return(ret);
}

static int _menu_ikey(OBJECT *m_tree, int kstate, int key, int *menu, int *item)
{
	int do_quit=0, desk=1;
	register int m_title, c_title, m_entry, c_entry;
	int msgbuf[8];
   WINDOW *wp;
   
	if(!(kstate & (K_CTRL|K_ALT)) || __tolower((char)key)=='y')
		return(FALSE);         /* keine Sondertaste > kein Shortcut */

	msgbuf[4]=0;

	m_title=(m_tree+m_tree->ob_head)->ob_head;
	c_title=(m_tree+m_title)->ob_head;
	m_entry=(m_tree+m_tree->ob_tail)->ob_head;
	c_entry=(m_tree+m_entry)->ob_head;
	while(!do_quit)
	{
		if(((m_tree +c_title)->ob_state & DISABLED) == 0)
		{
			while(!do_quit && c_entry != m_entry && c_entry != -1)
			{
				if( ((m_tree+c_entry)->ob_type != G_USERDEF) &&
					
					/* MT 16.4.95 disablete MenÅpunkte mÅssen auch durchsucht werden */
					/*(((m_tree+c_entry)->ob_state & DISABLED) == 0) &&*/
					 
					 ((m_tree+c_entry)->ob_type == G_STRING ||
					  (m_tree+c_entry)->ob_type == G_BUTTON))
					do_quit=test_entry((char *)(m_tree+c_entry)->ob_spec.index,
									kstate,key,(m_tree+c_entry)->ob_flags);
				if(do_quit)
				{
					if (((m_tree+c_entry)->ob_state & DISABLED) == 0)
					{ 
						msgbuf[0]=MN_SELECTED;
#if GEMDOS
						msgbuf[1]=_GemParBlk.global[2];
#else
						msgbuf[1]=gb.gb_pglobal[2];
#endif
						msgbuf[2]=0;
						*menu=msgbuf[3]=c_title;
					   *item=msgbuf[4]=c_entry;
#if MiNT
						wind_update(BEG_UPDATE);
						wind_update(END_UPDATE);
#endif
						graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */
						menu_tnormal(m_tree,c_title,0);
						wp=Wgettop();
						toolbar_tnormal(wp,wp?wp->toolbar:NULL,c_entry,0);
/* alte Version
						appl_write(msgbuf[1],16,msgbuf);
*/
					}
					else /* wenn disabled, anderen Returncode verwenden */
					{
						msgbuf[4]=-1; /* gefunden, aber disabled */
					}

				}
				c_entry=(m_tree+c_entry)->ob_next;
				if(desk)
				{
					c_entry=m_entry;
					desk=0;
				}
			}
		}
		c_title=(m_tree+c_title)->ob_next;
		m_entry=(m_tree+m_entry)->ob_next;
		c_entry=(m_tree+m_entry)->ob_head;
		if(c_title==m_title)
		{
			do_quit=1;
		}
	}
	return(msgbuf[4]);
}

static int test_SysKeyentry(char *str, char chr1, char chr2)
{
	char *cp;
	
	if((cp=strchr(str,'^'))!=NULL && (chr1==*(cp+1)) && (chr2==*(cp+2)))
		return(TRUE);
	return(FALSE);
}

static int _menu_SysKey(OBJECT *m_tree, int kstate, int key, int *menu, int *item)
{
	char chr1, chr2;
	int i, do_quit=0, desk=1;
	register int m_title, c_title, m_entry, c_entry;
	int msgbuf[8];
	WINDOW *wp;

	if(!(kstate & K_CTRL)|| /* kein ^	  */
	    (kstate & K_ALT) || /* Alt		  */
	    (key==0x0408)	 	|| /* ^Backspace */
	    (key==0x047F)	 	|| /* ^Delete    */
	    ((char)key=='y')	|| /* ^Y			*/
	    ((char)key=='e')	|| /* ^E			*/
	    ((char)key=='a') || /* ^A			*/
	    ((char)key=='Y')	|| /* ^Y			*/
	    ((char)key=='E')	|| /* ^E			*/
	    ((char)key=='A'))	/* ^A			*/
		return(FALSE); /* raus bei nicht Control oder Alt */

	msgbuf[3]=msgbuf[4]=0;
   
   chr1=__toupper((char)key);
   
	for(i=ROOT+3; m_tree[i].ob_type==G_TITLE; i++)
	{
		if(!(m_tree[i].ob_state & DISABLED) && chr1==__toupper(*((char *)m_tree[i].ob_spec.index+1L)))
		{
  			menu_tnormal(m_tree,msgbuf[3]=i,FALSE);

			wind_update(BEG_UPDATE);			 /* Keine MenÅaktionen */
/*
		   m_tree[WINNEW-1].ob_flags|=FLAGS15; /* kein Windial!!! */
		   m_tree[WINNEW-1].ob_next=-1;
		   m_tree[WINNEW-1].ob_head=1;
		   m_tree[WINNEW-1].ob_tail=WINQUIT-WINNEW+1;
		   m_tree[WINNEW-1].ob_y=ydesk;
         for(i=WINNEW; i<WINQUIT; i++)
			   m_tree[i].ob_next=i-WINNEW+2;
		   m_tree[WINQUIT].ob_next=0;
		   m_tree[WINQUIT].ob_head=-1;
		   m_tree[WINQUIT].ob_tail=-1;
		   m_tree[WINQUIT ].ob_flags|=LASTOB; /* */            
         form_exopen(&m_tree[WINNEW-1],0);
*/
			key=evnt_keybd();			/* zweiten Tastendruck abwarten */
/*
         form_exclose(&m_tree[WINNEW-1],-1,0);
		   m_tree[WINNEW-1].ob_flags&=~FLAGS15; 
		   m_tree[WINNEW-1].ob_next=39;
		   m_tree[WINNEW-1].ob_head=WINNEW;
		   m_tree[WINNEW-1].ob_tail=WINQUIT;
		   m_tree[WINNEW-1].ob_y=0;
         for(i=WINNEW; i<WINQUIT; i++)
			   m_tree[i].ob_next=i+1;
		   m_tree[WINQUIT].ob_next=21;
		   m_tree[WINQUIT].ob_head=-1;
		   m_tree[WINQUIT].ob_tail=-1;
		   m_tree[WINQUIT ].ob_flags&=~LASTOB; /* */
*/
			wind_update(END_UPDATE);

         MapKey(&kstate,&key);
         kstate=0;
			chr2=__toupper((char)key);

			m_title=(m_tree+m_tree->ob_head)->ob_head;
			c_title=(m_tree+m_title)->ob_head;
			m_entry=(m_tree+m_tree->ob_tail)->ob_head;
			c_entry=(m_tree+m_entry)->ob_head;
			while(!do_quit)
			{
				if(((m_tree +c_title)->ob_state & DISABLED) == 0)
				{
					while(!do_quit && c_entry != m_entry && c_entry != -1)
					{
						if( ((m_tree+c_entry)->ob_type != G_USERDEF) &&
							(((m_tree+c_entry)->ob_state & DISABLED) == 0) &&
							 ((m_tree+c_entry)->ob_type == G_STRING ||
							  (m_tree+c_entry)->ob_type == G_BUTTON))
							do_quit=test_SysKeyentry((char *)(m_tree+c_entry)->ob_spec.index,chr1,chr2);
						if(do_quit)
						{
							msgbuf[0]=MN_SELECTED;
#if GEMDOS
							msgbuf[1]=_GemParBlk.global[2];
#else
							msgbuf[1]=gb.gb_pglobal[2];
#endif
							msgbuf[2]=0;
							*menu=msgbuf[3]=c_title;
						   *item=msgbuf[4]=c_entry;
							graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */
							wp=Wgettop();
							toolbar_tnormal(wp,wp?wp->toolbar:NULL,c_entry,0);
/*
							appl_write(msgbuf[1],16,msgbuf);
*/
						}
						c_entry=(m_tree+c_entry)->ob_next;
						if(desk)
						{
							c_entry=m_entry;
							desk=0;
						}
					}
				}
				c_title=(m_tree+c_title)->ob_next;
				m_entry=(m_tree+m_entry)->ob_next;
				c_entry=(m_tree+m_entry)->ob_head;
				if(c_title==m_title)
				{
					do_quit=1;
				}
			}
		}
	}
   if(msgbuf[3] && !msgbuf[4]) /* zurÅcksetzen, weil falsch */
		menu_tnormal(m_tree,msgbuf[3],TRUE);
	return(msgbuf[4]);
}

int menu_ikey(OBJECT *m_tree, int kstate, int key, int *menu, int *item)
{
	if(SysKey)
		return(_menu_SysKey(m_tree, kstate, key, menu, item));
	else
		return(_menu_ikey(m_tree, kstate, key, menu, item));
}

void _loadmenu(char *filename)
{
	FILE *fp;
	char *cp;
	
	extern char iostring[];
	extern OBJECT *winmenu,*menueditor;
		
	if((fp=fopen(filename,"r"))!=NULL)
	{
		form_write(menueditor,MENUMFILE,split_fname(filename),FALSE);
		wind_update(BEG_UPDATE);
      graf_mouse(BUSY_BEE,NULL);
		SysKey=FALSE; /* erstmal zurÅcksetzen auf Standard */
		while(fgets(iostring,80,fp)!=NULL)
		{
			if(*iostring!='#' && *iostring!='-')
			{
				if(*iostring=='%')
				{
					if(!strncmp(iostring,"%SysKey",7))
						SysKey=TRUE;
				}
				else
				{
					if(iostring[strlen(iostring)-1]=='\n')
						iostring[strlen(iostring)-1]=0;
					if((cp=strchr(iostring,',')) && (strlen(cp+1)>0)) /* Komma drin? */
					{
						*cp=0;
						menu_text(winmenu,atoi(iostring),cp+1);
					}
				}
			}
		}
      graf_mouse(ARROW,NULL);
		wind_update(END_UPDATE);
		fclose(fp);
	}
}

static void __savemenu(OBJECT *m_tree, FILE *fp)
{
	int do_quit=0, desk=1;
	int m_title, c_title, m_entry, c_entry;
   char menustr[40];

   fprintf(fp,"###############################\n");
   fprintf(fp,"# 7UP 2.3 MenÅshortcuts\n");
   fprintf(fp,"###############################\n");
	if(SysKey)
	   fprintf(fp,"%SysKey\n");
	m_title=(m_tree+m_tree->ob_head)->ob_head;
	c_title=(m_tree+m_title)->ob_head;
	m_entry=(m_tree+m_tree->ob_tail)->ob_head;
	c_entry=(m_tree+m_entry)->ob_head;
	while(!do_quit)
	{
      fprintf(fp,"#==============================\n");
		sprintf(menustr,"#    %s\n",(char *)m_tree[c_title].ob_spec.index);
		fprintf(fp,strupr(menustr));
		while(c_entry != m_entry && c_entry != -1)
		{
			/* Trennlinie ist ÅberflÅssig */
			if(! (char *)m_tree[c_entry].ob_spec.index ||
			   !*(char *)m_tree[c_entry].ob_spec.index ||
			    *(char *)m_tree[c_entry].ob_spec.index == '-') /* Let 'em Fly am Werk */
				fprintf(fp,"#---\n");
			else
	         if(!(c_entry>=WINDAT1 && c_entry<=WINDAT7)) /* diese benîtigen wir nicht */
					fprintf(fp,"%003d,%s\n",c_entry, (char *)m_tree[c_entry].ob_spec.index);
			
			c_entry=(m_tree+c_entry)->ob_next;
			if(desk)
			{
				c_entry=m_entry;
				desk=0;
			}
		}
		c_title=(m_tree+c_title)->ob_next;
		m_entry=(m_tree+m_entry)->ob_next;
		c_entry=(m_tree+m_entry)->ob_head;
		if(c_title==m_title)
		{
			do_quit=1;
		}
	}
}

void _savemenu(char *filename)
{
	FILE *fp;
	if((fp=fopen(filename,"w"))!=NULL)
	{
		wind_update(BEG_UPDATE);
      graf_mouse(BUSY_BEE,NULL);
      __savemenu(winmenu,fp);
      graf_mouse(ARROW,NULL);
		wind_update(END_UPDATE);
		fclose(fp);
	}	
}

void loadmenu(char *filename)
{
	char *cp,pathname[PATH_MAX];
	
   search_env(pathname,filename,FALSE); /* READ */
	_loadmenu(pathname);
}

static void sonderzeichen(int *kstate, int *key)
{  /* Capslock ausmaskiert */
	extern int eszet,komma;
	
   switch(*key)
   {
      case 0x402E: /* Zehnerblockpunkt */
         if(komma)
            *key=',';
         break;
      case 'û':
			if(eszet)
				*key='·';
			break;
      case 0x0A9A:
         *kstate=0;
			*key='\\';
         break;
      case 0x0881:
      case 0x089A:/* caps */
         *kstate=0;
			*key='@';
         break;
      case 0x0A99:
         *kstate=0;
			*key='{';
         break;
      case 0x0A8E:
         *kstate=0;
			*key='}';
         break;
      case 0x0894:
      case 0x0899:/* caps */
         *kstate=0;
			*key='[';
         break;
      case 0x0884:
      case 0x088E:/* caps */
         *kstate=0;
			*key=']';
         break;
   }
}

int MapKey(int *kstate, int *key)
{
	register int ks,sc,ret;

	if(!pkeytbl)
		pkeytbl=Keytbl(-1L,-1L,-1L);

	sc=((*key)>>8)&0xFF;

	ks=(int)Kbshift(-1);
/*
	ks=*kstate; /* wg. Macrorecorder 16.4.94. Denkste, kein CAPS!!! */
*/	
   /* ALT 1 - ALT û -> runterrechnen auf 2 - 13 */
   if((ks&K_ALT) && (sc>=0x78) && (sc<=0x83))
	   sc-=0x76;

	if((ks&K_CAPS) && !(ks&K_SHIFT))
		ret=pkeytbl->capslock[sc];
	else
	{
		if(ks&K_SHIFT)
      {
         if (( sc >= 0x54 ) && ( sc <= 0x5d ))
            ret= pkeytbl->shift[sc - 0x19];
         else if (( sc == 0x47 ) || ( sc == 0x48 ) || ( sc == 0x4b ) ||
               ( sc == 0x4d ) || ( sc == 0x50 ) || ( sc == 0x52 ))
                  /* Ins, Clr, Cursor - fehlt im Profibuch */
            ret = 0;
         else
            ret = pkeytbl->shift[sc];
      }
      else
         ret = pkeytbl->unshift[sc];
	}
	if(!ret)
		ret=sc|K_SCAN;
	else  /* Ziffernblock markieren */
		if((sc==0x4A) || (sc==0x4E) || ((sc>=0x63) && (sc<=0x72)))
			ret|=K_NUM;

	if(ks & K_RSHIFT)
	{
		ks &= ~K_RSHIFT;
		ks |=  K_LSHIFT;
	}

   ks&=~K_CAPS; /* CAPSLOCK ausblenden */

	*kstate=ks;
	*key=((ks<<8)|ret);

   sonderzeichen(kstate,key);

	return(*key);
}

