/* Shell Funktionen */
/*****************************************************************************
*
*											  7UP
*										Modul: SHELL.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>
#if GEMDOS
#include <tos.h>
#else
#include <process.h>
#endif
#include "alert.h"
#include "7up.h"
#include "forms.h"
#include "windows.h"

#include "language.h"

int pexec=FALSE; /* fr Fontbox, wg. "static" */
int getfilename(char *pathname, char * pattern, char *fname, const char *meldung);
extern int nodesktop,windials;

#if GEMDOS
extern int aeshandle,xdesk,ydesk,wdesk,hdesk;
extern OBJECT *winmenu,*prtmenu,*popmenu,
				  *desktop,*findmenu,*gotomenu,
				  *fontmenu,*tabmenu,*infomenu,
				  *copyinfo,*shellmenu,*chartable,
				  *shareware,*shell2;


void get_path(char *path)
{
	 register int i;
	 i=strlen(path)-1;
	 for(; i>=0; i--)
		 if(path[i]=='\\')
		 {
			 path[i+1]=0;
			 break;
		 }
}

int istos(char *pathname)
{
	char *cp;
	cp=&pathname[strlen(pathname)-3];		 /* auf Zeichen nach dem '.'	  */
	if(!strnicmp(cp,"TOS",3) ||			  /* ...und vergleichen, ob legal */
		!strnicmp(cp,"TTP",3))
		return(1);														 /* ok, er ist */
	return(0);
}

void hndl_shell(OBJECT *tree, int start)
{
	int exit_obj, olddrv, ret, mouse_click,area[4];
	char oldpath[PATH_MAX],path[PATH_MAX],pathname[PATH_MAX],cmdstr[40];
	COMMAND cmd;
	/*static*/ char fpattern[FILENAME_MAX]="*.*";
	extern BASPAG *_BasPag;

	form_exopen(tree,start);
	do
	{
		exit_obj=form_exdo(tree,start);
		if(exit_obj==SHELHELP)
		{
			form_alert(1,Ashell[0]);
			objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
/*
			tree[exit_obj].ob_state&=~SELECTED;
			if(!windials)
				objc_update(tree,ROOT,MAX_DEPTH);
			else
				objc_update(tree,exit_obj,0);
*/
		}
	}
	while(exit_obj==SHELHELP);
	form_exclose(tree,exit_obj,0);

	if(exit_obj == SHELLOK)
	{
		if(tree[SHELLGEM].ob_state&SELECTED)
		{
			pathname[0]=0;
			if(getfilename(pathname,fpattern,"@",fselmsg[24]))
			{
				form_read(tree,SHELCOMM,cmd.command_tail);
				cmd.length=(unsigned char)strlen(cmd.command_tail);
				if(!cmd.length)
				{
					cmd.command_tail[0]=0;
					if(getfilename(cmd.command_tail,fpattern,"@",fselmsg[25]))
						cmd.length=(unsigned char)strlen(cmd.command_tail);
					else
						cmd.length=0;
				}
				if(istos(pathname))
				{
					graf_mouse(M_OFF,0L);
#if MiNT
					wind_update(BEG_UPDATE);
#endif
					menu_bar(winmenu,FALSE);
#if MiNT
					wind_update(END_UPDATE);
#endif
					v_enter_cur(aeshandle);
				}
				else
				{
					if(Sversion()>=0x1500)
						shel_write(1,1,1,pathname,&cmd);
					pexit();
					pexec=TRUE;
				}
				olddrv=Dgetdrv();
				Dgetpath(oldpath,0);
				strcpy(path,pathname);
				get_path(path);
				Dsetdrv((int)(path[0]-'A'));
				Dsetpath(&path[2]);

				ret=Pexec(0,pathname,&cmd,_BasPag->p_env); /* Start frei */

				Dsetdrv(olddrv);
				Dsetpath(oldpath);
				if(istos(pathname))
				{
					v_exit_cur(aeshandle);
#if MiNT
					wind_update(BEG_UPDATE);
#endif
					menu_bar(winmenu,TRUE);
/*
					_wind_get(0, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
					while( area[2] && area[3] )
					{
						form_dial(FMD_FINISH,0,0,0,0,area[0],area[1],area[2],area[3]);
						_wind_get(0, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
					}
*/
#if MiNT
					wind_update(END_UPDATE);
#endif
					graf_mouse(M_ON,0L);
					form_dial(FMD_FINISH,0,0,0,0,xdesk,ydesk,wdesk,hdesk);
				}
				else
				{
					pinit(NULL);
#if OLDTOS
					wind_update(BEG_UPDATE);
#endif
					if(Sversion()>=0x1500)
						shel_write(0,1,1,"","");
				}
			}
		}
		else
		{
			if(system(NULL))
			{
#if MiNT
				wind_update(BEG_UPDATE);
#endif
				menu_bar(winmenu,FALSE);
				wind_update(END_UPDATE);
				graf_mouse(M_OFF,0L);
				v_enter_cur(aeshandle);
				graf_mouse(M_ON,0L);

				v_curtext(aeshandle,KOMMANDO);
				v_curtext(aeshandle,form_read(tree,SHELCOMM,cmdstr));
				v_curtext(aeshandle,"\r\n");
				ret=system(cmdstr);
				if(ret<0)
					form_error((~ret)-30);
				v_curtext(aeshandle,PRESSANYKEY);
				while(!kbhit())
					;
				while(kbhit())
					Cconin();

				graf_mouse(M_OFF,0L);
				v_exit_cur(aeshandle);

				wind_update(BEG_UPDATE);
				menu_bar(winmenu,TRUE);
/*
				wind_set(0,WF_NEWDESK,nodesktop?NULL:desktop,0,0);
				_wind_get(0, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
				while( area[2] && area[3] )
				{
					form_dial(FMD_FINISH,0,0,0,0,area[0],area[1],area[2],area[3]);
					_wind_get(0, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
				}
*/
#if MiNT
				wind_update(END_UPDATE);
#endif
				graf_mouse(M_ON,0L);
				graf_mouse(ARROW,NULL);
				form_dial(FMD_FINISH,0,0,0,0,xdesk,ydesk,wdesk,hdesk);
			}
			else
				form_alert(1,Ashell[1]);
		}
	}
}
#else

typedef struct
{
	unsigned char length;
	char command_tail[128];
} COMMAND;

void hndl_shell(OBJECT *tree, int start)
{
	WINDOW *wp;
	char string[PATH_MAX];
	int done=FALSE,exit_obj;
	COMMAND cmd={0,""};
	static char fpattern[20]="*.APP,*.EXE,*.COM";
	char pathname[PATH_MAX];
	static int doex=TRUE,isgr=TRUE,isover=TRUE;

	if(wp=Wgettop())
		tree[SH2AKTP].ob_state&=~DISABLED;
	else
		tree[SH2AKTP].ob_state|= DISABLED;
	form_write(tree,SH2PRG,fpattern,FALSE);
	form_write(tree,SH2PARAM,"",FALSE);
	form_exopen(tree,0);
	do
	{
		exit_obj=form_exdo(tree,0);
		switch(exit_obj)
		{
			case SH2PRG:
				pathname[0]=0;
				if(getfilename(pathname,fpattern,"@",fselmsg[26]))
				{
					form_write(tree,SH2PRG,pathname,FALSE);
				}
				tree[exit_obj].ob_state&=~SELECTED;
				form_open(tree,0);  /* redraw */
				break;
			case SH2PARAM:
				cmd.command_tail[0]=0;
				strcpy(fpattern,"*.*");
				if(getfilename(cmd.command_tail,fpattern,"@",fselmsg[27]))
				{
					cmd.length=(unsigned char)strlen(cmd.command_tail);
					form_write(tree,SH2PARAM,cmd.command_tail,FALSE);
					tree[SH2NOP].ob_state&=~SELECTED;
					tree[SH2AKTP].ob_state&=~SELECTED;
				}
				tree[exit_obj].ob_state&=~SELECTED;
				form_open(tree,0);  /* redraw */
				break;
			case SH2NOP:
				*cmd.command_tail=0;
				cmd.length=0;
				form_write(tree,SH2PARAM,"",TRUE);
				break;
			case SH2AKTP:
				strcpy(cmd.command_tail,(char *)Wname(wp));
				cmd.length=(unsigned char)strlen(cmd.command_tail);
				form_write(tree,SH2PARAM,cmd.command_tail,TRUE);
				break;
			case SH2GEM:
				isgr=1;
				tree[SH2ALLR].ob_state&=~SELECTED;
				tree[SH2ALLR].ob_state|=DISABLED;
				objc_update(tree,SH2ALLR,0);
				tree[SH2BACK].ob_state&=~DISABLED;
				tree[SH2BACK].ob_state|=SELECTED;
				objc_update(tree,SH2BACK,0);
				break;
			case SH2DOS:
				isgr=0;
				tree[SH2ALLR].ob_state&=~DISABLED;
				objc_update(tree,SH2ALLR,0);
				break;
			case SH2ALLR:
				if(gb.gb_pglobal[0]<0x0400) /* bei GEM/4 vielleicht */
				{
					if(tree[SH2ALLR].ob_state&SELECTED)
					{
						tree[SH2BACK].ob_state&=~SELECTED;
						tree[SH2BACK].ob_state|=DISABLED;
					}
					else
					{
						tree[SH2BACK].ob_state&=~DISABLED;
						tree[SH2BACK].ob_state|=SELECTED;
					}
					objc_update(tree,SH2BACK,0);
				}
				break;
			case SH2ABBR:
			case SH2OK:
				done=TRUE;
				break;
		}
	}
	while(!done);
	form_exclose(tree,exit_obj,0);
	if(exit_obj==SH2OK)
	{
		if(tree[SH2SAVE].ob_state&SELECTED)
		{
			 writenames();
			 sicons();
			 Wnew();
			 saveconfig(TRUE);
		}
		if(tree[SH2BACK].ob_state&SELECTED)
		{
			strcpy(string,"7UP.APP");
			shel_find(string);
			string[strlen(string)-strlen("7UP.APP")]=0;
			shel_wdef("7UP.APP",string);						/* Zurck zu 7UP.APP */
		}
		if(tree[SH2ALLR].ob_state&SELECTED)
		{
			isover=2;									  /* vorher Speicher freigeben */
		}
		shel_write(doex,isgr,isover,pathname,&cmd);	  /* Shell starten ...  */
		exit(0);											 /* ... mit exit() ber AES  */
	}
}
#endif
