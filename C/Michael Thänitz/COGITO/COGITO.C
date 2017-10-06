/***************************************************************************
*
*                                COGITO 1.0
*                                Packershell
*                          (c) 1994 Michael Th„nitz
*
***************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include <aes.h>

#include "cogito.h"
#include "vaproto.h"

#define MAX_PACKER 5
#define OPT_MAX 17

#define ACCNAME "Cogito"

OBJECT *packmenu,*packdial,*setdial,*set2dial;
char *envptr;
int gl_apid;
int aeshandle,boxh;
int xdesk, ydesk, wdesk, hdesk;

extern int wi_handle;

typedef struct
{
   char typ[5];
	char pathname[PATH_MAX];
	char packein[OPT_MAX], packaus[OPT_MAX], inhalt[OPT_MAX];
}PACKER;
PACKER packer[MAX_PACKER];

typedef struct
{
	WORD packer, ordner, alles, taste, merken, pein, paus, pinhalt, x, y;
	char source[PATH_MAX], dest[PATH_MAX], pattern[13];
}SHELL;
SHELL shell;

COMMAND cmd;

void write_inf(char *pathname);
void read_inf(char *pathname);
void AVExit(int myapid);
void set_dials(void);
int aktiver_packer(void);
void strcut(register char *s, register char c);
int getfilename(char *pathname, char *patt, char *fname, const char *meldung);
int packer_auswaehlen(void);
void packer_starten(COMMAND *cmd);
void einpacken(void);
void auspacken(void);
void inhalt(void);
void optionen(void);
void optionen2(void);
WORD hndl_menu(OBJECT *tree, WORD msgbuf[]);
void dredraw(OBJECT *tree, int exit_obj);
WORD packer_extension(char *filename);
void parameter_bearbeiten(char *filename, WORD pein, WORD paus, WORD inhalt);

int form_exhndl(OBJECT *tree,int start, int modus);
int form_hndl(OBJECT *tree, int start);
void form_write(OBJECT *tree, int item, char *string, int modus);
char *form_read(OBJECT *tree,int item, char *string);

int aktiver_packer(void)
{
   int i;

   for(i=0; i<MAX_PACKER; i++)
      if(packdial[PACKZOO+i].ob_state & SELECTED)
         return(i);
   return(0);
}

void strcut(register char *s, register char c)/* trennt string 's' vor zeichen 'c' */
{
	s+=strlen(s);
	while(*s != c)
		s--;
	*++s = '\0';
}

int getfilename(char *pathname, char *patt, char *fname, const char *meldung)
{
	int button,ret;
	static int first=TRUE;
	static char fsname[13],fspath[PATH_MAX];

	if(first)
	{
		fsname[0]=0;
		fspath[0]='@';
		fspath[1]=':';
		fspath[2]=0;
		fspath[0]=(char)(Dgetdrv()+'A');
		Dgetpath(&fspath[2],0);
		if(fspath[strlen(fspath)-1]!='\\')
			strcat(fspath,"\\");
		if(*patt)
			strcat(fspath,patt);
		else
			strcat(fspath,"*.*");
		first=FALSE;
	}
	if(!first)
	{
		if(*patt)
		{
			strcut(fspath,'\\');		 /* '*.*' in fspath abhacken		*/
			strcat(fspath,patt);
		}
		if(*fsname)
		{
			if(*fname=='@')
				*fsname=0;
			else
				strcpy(fsname,fname);
		}
	}
	if(*pathname)
		strcpy(fspath,pathname);

	if(_GemParBlk.global[0] >= 0x0140)
		ret=fsel_exinput(fspath,fsname,&button,meldung);
	else
		ret=fsel_input(fspath,fsname,&button);
	if(ret)
	{
		if(button)
		{
			strcpy(pathname,fspath);
			strcut(pathname,'\\');		 /* '*.*' in path abhacken		*/
			strcat(pathname,fsname);	/* zugriffspfad zusammensetzen */
			return(TRUE);
		}
	}
	return(FALSE);
}

int packer_auswaehlen(void)
{
   char fsstring[41];
   
   strcpy(fsstring,"Wo ist der Packer xxx?");
   memmove(&fsstring[18],packer[shell.packer].typ,3);
   return(getfilename(packer[shell.packer].pathname,"*.*","@",fsstring));
}

void packer_starten(COMMAND *cmd)
{
	int ret;

   cmd->length=(unsigned char)strlen(cmd->command_tail);
   if(AVActive())
   {
	   AVOpenConsole();
      printf("\33ECOGITO 1.01 Packershell\n");
      printf("%s\n",cmd->command_tail);
   	AVStartProgram(packer[shell.packer].pathname,cmd->command_tail);
   }
   else
   {
		graf_mouse(M_OFF,NULL);
      printf("\33ECOGITO 1.01 Packershell\n");
      printf("%s\n",cmd->command_tail);
   	ret=Pexec(0,packer[shell.packer].pathname,cmd,envptr);
      if(ret<0)
      {
			graf_mouse(M_ON,NULL);
         if(!packer_auswaehlen())
            return;
			graf_mouse(M_OFF,NULL);
         ret=Pexec(0,packer[shell.packer].pathname,cmd,envptr);
         if(ret<0)
            form_alert(1,"[3][|Der Packer lieá sich |nicht starten!][   OK   ]");
      }
      if(shell.taste)
      {
         printf("\n(Taste)");
         evnt_keybd();
      }
      form_dial(FMD_FINISH, 0, 0, 0, 0, xdesk, ydesk, wdesk, hdesk);
		graf_mouse(M_ON,NULL);
		if(_app)
		{
			wind_update(BEG_UPDATE);
			menu_bar(packmenu,TRUE);
			wind_update(END_UPDATE);
		}
   }
}

void einpacken(void)
{
   int ret;

   shell.packer = aktiver_packer();
   shell.source[0]=shell.dest[0]=0;
   strcpy(shell.pattern,"*.*");
   if(getfilename(shell.source,shell.pattern,"@","Welchen Ordner einpacken?"))
   {
   	strcut(shell.source,'\\');
   	strcpy(shell.pattern,"*.???");
   	memmove(&shell.pattern[2],packer[shell.packer].typ,3);
      if(getfilename(shell.dest,shell.pattern,"@","In welche Archivdatei einpacken?"))
      {
         if(!packer[shell.packer].pathname[0])
         {
            if(!packer_auswaehlen())
               return;
         }
         strcpy(cmd.command_tail,packer[shell.packer].packein);
         strcat(cmd.command_tail," ");
         strcat(cmd.command_tail,shell.dest);
         strcat(cmd.command_tail," ");
         strcat(cmd.command_tail,shell.source);
         packer_starten(&cmd);
      }
   }
}

void auspacken(void)
{
   char *cp;
   char filename[13]="";
   int ret;

   shell.packer = aktiver_packer();
  	strcpy(shell.pattern,"*.???");
  	memmove(&shell.pattern[2],packer[shell.packer].typ,3);
   shell.source[0]=shell.dest[0]=0;
   if(getfilename(shell.source,shell.pattern,"@","Welche Archivdatei auspacken?"))
   {
      *shell.pattern=0;
      if(getfilename(shell.dest,shell.pattern,"@","In welchen Ordner auspacken?"))
      {
	   	strcut(shell.dest,'\\');
         if(!packer[shell.packer].pathname[0])
         {
            if(!packer_auswaehlen())
               return;
         }
         if(shell.ordner)
         {
            cp=strrchr(shell.source,'\\');
            if(cp)
            {
              strcat(shell.dest,cp+1);
              shell.dest[strlen(shell.dest)-strlen(packer[shell.packer].typ)-1] = 0;
              Dcreate(shell.dest);
              strcat(shell.dest,"\\");
            }
         }
         strcpy(cmd.command_tail,packer[shell.packer].packaus);
         strcat(cmd.command_tail," ");
         strcat(cmd.command_tail,shell.source);
         strcat(cmd.command_tail," ");
         strcat(cmd.command_tail,shell.dest);
         if(!shell.alles)
         {
         	filename[0]=0;
            if(getfilename(filename,"*.*","@","Welche Datei(en) auspacken?"))
            {
               if((cp=strrchr(filename,'\\'))!=NULL)
               {
                  strcat(cmd.command_tail," ");
                  strcat(cmd.command_tail,cp+1);
               }
            }
         }
         else
	         strcat(cmd.command_tail," *.*");
         packer_starten(&cmd);
      }
   }
}

void inhalt(void)
{
   int ret;

   shell.packer = aktiver_packer();
 	strcpy(shell.pattern,"*.???");
  	memmove(&shell.pattern[2],packer[shell.packer].typ,3);
   shell.source[0]=shell.dest[0]=0;
   if(getfilename(shell.source,shell.pattern,"@","Welche Archivdatei ansehen?"))
   {
      if(!packer[shell.packer].pathname[0])
      {
         if(!packer_auswaehlen())
            return;
      }
      strcpy(cmd.command_tail,packer[shell.packer].inhalt);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,shell.source);
      packer_starten(&cmd);
   }
}

void optionen(void)
{
	int exit_obj;

   shell.packer = aktiver_packer();

   form_write(setdial,SETTYP,   packer[shell.packer].typ,    FALSE);
   form_write(setdial,SETEIN,   packer[shell.packer].packein,FALSE);
   form_write(setdial,SETAUS,   packer[shell.packer].packaus,FALSE);
   form_write(setdial,SETINHALT,packer[shell.packer].inhalt, FALSE);

	form_open(setdial,0);

	do
	{
		exit_obj=(form_do(setdial,0) & 0x7FFF);
      switch(exit_obj)
		{
		   case SETINFO:
			   form_alert(1,"[1][    COGITO 1.01|       Email:|Michael_Thaenitz@Bi.Maus.De][   OK   ]");
		      objc_change(setdial,exit_obj,0,
		   	   setdial->ob_x,setdial->ob_y,setdial->ob_width,setdial->ob_height,
		   	   setdial[exit_obj].ob_state^SELECTED,TRUE);
            break;
		   case SETSAVE:
		      shell.ordner  = (setdial[SETORDNER].ob_state & SELECTED);
		      shell.alles   = (setdial[SETALLES ].ob_state & SELECTED);
		      shell.taste   = (setdial[SETTASTE ].ob_state & SELECTED);
		      shell.merken  = (setdial[SETMERKEN].ob_state & SELECTED);
				shell.pein    = (set2dial[SET2PACKEIN].ob_state & SELECTED);
				shell.paus    = (set2dial[SET2PACKAUS].ob_state & SELECTED);
				shell.pinhalt = (set2dial[SET2SHOW   ].ob_state & SELECTED);
		      form_read(setdial,SETEIN,   packer[shell.packer].packein);
		      form_read(setdial,SETAUS,   packer[shell.packer].packaus);
		      form_read(setdial,SETINHALT,packer[shell.packer].inhalt);
			   write_inf("COGITO.INF");
		      objc_change(setdial,exit_obj,0,
		   	   setdial->ob_x,setdial->ob_y,setdial->ob_width,setdial->ob_height,
		   	   setdial[exit_obj].ob_state^SELECTED,TRUE);
            break;
		}
	}
	while(exit_obj!=SETOK);

	form_close(setdial,exit_obj,0);

   shell.ordner = (setdial[SETORDNER].ob_state & SELECTED);
   shell.alles  = (setdial[SETALLES ].ob_state & SELECTED);
   shell.taste  = (setdial[SETTASTE ].ob_state & SELECTED);
   shell.merken = (setdial[SETMERKEN].ob_state & SELECTED);

	shell.pein    = (set2dial[SET2PACKEIN].ob_state & SELECTED);
	shell.paus    = (set2dial[SET2PACKAUS].ob_state & SELECTED);
	shell.pinhalt = (set2dial[SET2SHOW   ].ob_state & SELECTED);

   form_read(setdial,SETEIN,   packer[shell.packer].packein);
   form_read(setdial,SETAUS,   packer[shell.packer].packaus);
   form_read(setdial,SETINHALT,packer[shell.packer].inhalt);
}

void optionen2(void)
{
   shell.packer = aktiver_packer();

   form_write(set2dial,SET2TYP,   packer[shell.packer].typ,    FALSE);
   form_write(set2dial,SET2EIN,   packer[shell.packer].packein,FALSE);
   form_write(set2dial,SET2AUS,   packer[shell.packer].packaus,FALSE);
   form_write(set2dial,SET2INHALT,packer[shell.packer].inhalt, FALSE);

	form_hndl(set2dial,0);

	shell.pein    = (set2dial[SET2PACKEIN].ob_state & SELECTED);
	shell.paus    = (set2dial[SET2PACKAUS].ob_state & SELECTED);
	shell.pinhalt = (set2dial[SET2SHOW   ].ob_state & SELECTED);

   form_read(set2dial,SET2EIN,   packer[shell.packer].packein);
   form_read(set2dial,SET2AUS,   packer[shell.packer].packaus);
   form_read(set2dial,SET2INHALT,packer[shell.packer].inhalt);
}

int hndl_menu(OBJECT *tree, int msgbuf[])
{
   int fm_cont=TRUE;

	switch(msgbuf[4])
	{
		case MENUABOUT:
			form_alert(1,"[1][    COGITO 1.01|       Email:|Michael_Thaenitz@Bi.Maus.De][   OK   ]");
			break;
		case MENUSAVE:
			write_inf("COGITO.INF");
			break;
		case MENUQUIT:
         fm_cont=FALSE;
			break;
		case MENUORDNER:
			menu_icheck(tree,msgbuf[4],shell.ordner^=TRUE);
			break;
		case MENUALLES:
			menu_icheck(tree,msgbuf[4],shell.alles^=TRUE);
			break;
		case MENUTASTE:
			menu_icheck(tree,msgbuf[4],shell.taste^=TRUE);
			break;
		case MENUMERKEN:
			menu_icheck(tree,msgbuf[4],shell.merken^=TRUE);
			break;
		case MENUOPT:
			optionen2();
			break;
	}
	menu_tnormal(tree,msgbuf[3],TRUE);
   return(fm_cont);
}

void dredraw(OBJECT *tree, int exit_obj)
{
	int ret, x, y, pxyarray[4];

   tree[exit_obj].ob_state &= ~SELECTED;
   objc_offset(tree,exit_obj,&x,&y);
   pxyarray[0]=x-3;
   pxyarray[1]=y-3;
   pxyarray[2]=tree[exit_obj].ob_width+6;
   pxyarray[3]=tree[exit_obj].ob_height+6;
   fwind_redraw(tree,wi_handle,pxyarray);
	evnt_button(1,1,0,&ret,&ret,&ret,&ret);
}

int form_exhndl(OBJECT *tree,int start, int modus)
{
	int exit_obj, closed=FALSE;

	if(form_exopen(tree,modus)>0)
	{
		if(wi_handle>0)
		   AVAccOpenedWindow(wi_handle);
		do
		{
	     	exit_obj=(form_exdo(tree,start) & 0x7FFF);
	      switch(exit_obj)
	      {
				case ROOT:
				   closed=TRUE;
				   break;
				case PACKEIN:
               einpacken();
               dredraw(tree,exit_obj);
				   break;
				case PACKAUS:
               auspacken();
               dredraw(tree,exit_obj);
				   break;
				case PACKINHALT:
               inhalt();
               dredraw(tree,exit_obj);
				   break;
				case PACKOPT: /* nur als ACC */
               optionen();
               dredraw(tree,exit_obj);
				   break;
	      }
		}
		while(!closed);
		if(wi_handle>0)
		   AVAccClosedWindow(wi_handle);
		form_exclose(tree,-1,modus);
	}
	else
	   form_alert(1,"[3][|Kein GEM-Fenster mehr frei! ][   OK   ]");
	return(exit_obj);
}

int packer_extension(char *filename)
{
	int i;
	char *cp;

	if((cp=strrchr(filename,'.'))!=NULL)
	   for(i=0; i<MAX_PACKER; i++)
   		if(!stricmp(cp+1, packer[i].typ))
   			return(i);
   return(0);
}

void parameter_bearbeiten(char *filename, WORD pein, WORD paus, WORD inhalt)
{
   int len, msgbuf[8];
   char *cp;
	extern char AVName[];
   
   if(appl_find("GEMINI  ")>=0) /* AV-Programm suchen */
   {
	   evnt_mesag(msgbuf);
   	AVProcessMsg(msgbuf);
	}
	if(pein)
	{
		len=strlen(filename);
		if(filename[len-1] == '\\')
		{									/* Backslash am Ende? Eigentlich nicht */
			filename[len-1] = 0;
			len--;
		}

		strcpy(shell.dest,filename);
		if(shell.dest[len-1] == '.') /* evtl. Extension abtrennen */
			shell.dest[len-1] = 0;
		if(shell.dest[len-2] == '.')
			shell.dest[len-2] = 0;
		if(shell.dest[len-3] == '.')
			shell.dest[len-3] = 0;
		strcat(shell.dest,".");                      /* Dateinamen erzeugen */
		strcat(shell.dest,packer[shell.packer].typ); /* Extension anh„ngen */

		strcat(filename,"\\");								/* Backslash anh„ngen */

      strcpy(cmd.command_tail,packer[shell.packer].packein);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,shell.dest);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,filename);
      packer_starten(&cmd);
	}
	shell.packer = packer_extension(filename);
	if(paus)
	{
		strcpy(shell.dest, filename);
		strcut(shell.dest,'\\');

      if(shell.ordner)
      {
         cp=strrchr(filename,'\\');
         if(cp)
         {
           strcat(shell.dest,cp+1);
           shell.dest[strlen(shell.dest)-strlen(packer[shell.packer].typ)-1] = 0;
           Dcreate(shell.dest);
           strcat(shell.dest,"\\");
         }
      }

      strcpy(cmd.command_tail,packer[shell.packer].packaus);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,filename);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,shell.dest);
      strcat(cmd.command_tail," *.*");
	   packer_starten(&cmd);
	}
	if(inhalt)
	{
      strcpy(cmd.command_tail,packer[shell.packer].inhalt);
      strcat(cmd.command_tail," ");
      strcat(cmd.command_tail,filename);
      packer_starten(&cmd);
	}
}

void read_inf(char *pathname)
{
   FILE *fp;
	int i;

	graf_mouse(BUSY_BEE,NULL);
	memset(&shell,0,sizeof(SHELL));
   form_write(setdial,SETEIN,   "",FALSE);
   form_write(setdial,SETAUS,   "",FALSE);
   form_write(setdial,SETINHALT,"",FALSE);
   form_write(set2dial,SET2EIN,   "",FALSE);
   form_write(set2dial,SET2AUS,   "",FALSE);
   form_write(set2dial,SET2INHALT,"",FALSE);

   if((fp=fopen(pathname,"r"))!=NULL)
   {
  	   fgets(packer[0].pathname,PATH_MAX,fp);/*dummy*/
      for(i=0; i<MAX_PACKER; i++)
      {
   	   fgets(packer[i].pathname,PATH_MAX,fp);
   	   strncpy(packer[i].typ,packer[i].pathname,3);
   	   packer[i].typ[3]=0;

	      strcpy(packer[i].pathname,&packer[i].pathname[4]);
         packer[i].pathname[strlen(packer[i].pathname)-1]=0; /*CR weg*/

   	   fgets(packer[i].packein,OPT_MAX-1,fp);
         packer[i].packein[strlen(packer[i].packein)-1]=0; /*CR weg*/

   	   fgets(packer[i].packaus,OPT_MAX-1,fp);
         packer[i].packaus[strlen(packer[i].packaus)-1]=0; /*CR weg*/

   	   fgets(packer[i].inhalt,OPT_MAX-1,fp);
         packer[i].inhalt[strlen(packer[i].inhalt)-1]=0; /*CR weg*/

      }
      fscanf(fp,"%d",&shell.packer);
      fscanf(fp,"%d",&shell.ordner);
      fscanf(fp,"%d",&shell.alles);
      fscanf(fp,"%d",&shell.taste);
      fscanf(fp,"%d",&shell.merken);
      fscanf(fp,"%d",&shell.pein);
      fscanf(fp,"%d",&shell.paus);
      fscanf(fp,"%d",&shell.pinhalt);
      fscanf(fp,"%d",&shell.x);
      fscanf(fp,"%d",&shell.y);
/*
		fgets(shell.source,PATH_MAX,fp);
      shell.source[strlen(shell.source)-1]=0; /*CR weg*/
      strcpy(shell.source,&shell.source[7]);
		fgets(shell.dest,PATH_MAX,fp);
      shell.dest[strlen(shell.dest)-1]=0; /*CR weg*/
      strcpy(shell.dest,&shell.dest[5]);
*/
      fclose(fp);
   }
	graf_mouse(ARROW,NULL);
}

void write_inf(char *pathname)
{
   FILE *fp;
	int i;

	graf_mouse(BUSY_BEE,NULL);
   if((fp=fopen(pathname,"w"))!=NULL)
   {
  	   fprintf(fp,"#COGITO 1.01 (c)1994 TheoSoft, Michael Th„nitz\n");
      for(i=0; i<MAX_PACKER; i++)
      {
   	   fprintf(fp,"%s=%s\n",packer[i].typ,packer[i].pathname);
   	   fprintf(fp,"%s\n",packer[i].packein);
   	   fprintf(fp,"%s\n",packer[i].packaus);
   	   fprintf(fp,"%s\n",packer[i].inhalt);
      }
      shell.packer = aktiver_packer();
     	fprintf(fp,"%d\n",shell.packer);
      fprintf(fp,"%d\n",shell.ordner);
      fprintf(fp,"%d\n",shell.alles);
      fprintf(fp,"%d\n",shell.taste);
      fprintf(fp,"%d\n",shell.merken);
      fprintf(fp,"%d\n",shell.pein);
      fprintf(fp,"%d\n",shell.paus);
      fprintf(fp,"%d\n",shell.pinhalt);
      fprintf(fp,"%d\n",shell.x);
      fprintf(fp,"%d\n",shell.y);
/*
      fprintf(fp,"SOURCE=%s\n",shell.source);
      fprintf(fp,"DEST=%s\n",shell.dest);
*/
      fclose(fp);
   }
	graf_mouse(ARROW,NULL);
}

int objc_sysvar(int ob_smode, int ob_swhich, 
					 int ob_sival1, int ob_sival2,
                int *ob_soval1, int *ob_soval2 )
{
	AESPB aespb=
	{
		_GemParBlk.contrl,
		_GemParBlk.global,
		_GemParBlk.intin,
		_GemParBlk.intout,
		_GemParBlk.addrin,
		_GemParBlk.addrout
	};

	_GemParBlk.intin [0] = ob_smode;
	_GemParBlk.intin [1] = ob_swhich;
	_GemParBlk.intin [2] = ob_sival1;
	_GemParBlk.intin [3] = ob_sival2;

	_GemParBlk.contrl[0]=48;
	_GemParBlk.contrl[1]=4;	
	_GemParBlk.contrl[2]=3;	
	_GemParBlk.contrl[3]=0;	
	_GemParBlk.contrl[4]=0;	

	_crystal(&aespb);

	*ob_soval1 = _GemParBlk.intout[1];
	*ob_soval2 = _GemParBlk.intout[2];

	return(_GemParBlk.intout[0]);
}

void set_dials(void)
{
	int ret;
	
	packdial[PACKZOO+shell.packer].ob_state |= SELECTED;
	setdial[SETORDNER].ob_state |= shell.ordner;
	setdial[SETALLES ].ob_state |= shell.alles;
	setdial[SETTASTE ].ob_state |= shell.taste;
	setdial[SETMERKEN].ob_state |= shell.merken;

	set2dial[SET2PACKEIN].ob_state |= shell.pein;
	set2dial[SET2PACKAUS].ob_state |= shell.paus;
	set2dial[SET2SHOW   ].ob_state |= shell.pinhalt;

	menu_icheck(packmenu,MENUORDNER,shell.ordner);
	menu_icheck(packmenu,MENUALLES,shell.alles);
	menu_icheck(packmenu,MENUTASTE,shell.taste);
	menu_icheck(packmenu,MENUMERKEN,shell.merken);
	if(_app)
	{
		packdial[ROOT].ob_height-=2*boxh;
		packdial[PACKGREY].ob_height-=2*boxh;
		packdial[PACKOPT].ob_flags|=HIDETREE;
	}
	if((_GemParBlk.global[0]>=0x0340) && 
	   (objc_sysvar(0,4,0,0,&ret,&ret)>0) &&
	   (TRUE/*mindestens_16_Farben()*/))          /* 3D-Effekt m”glich? */
	{
/*
		packdial[PACKGREY].ob_state |= OUTLINED;
*/
		packdial[PACKGREY].ob_spec.fillpattern = 0;
		packdial[PACKGREY].ob_spec.interiorcol = 0;

	}
}

void AVExit(int myapid)
{
	int apid;
	static int av_buf[8];
	extern char AVName[];

	if((apid=appl_find(AVName))>=0)
	{
		av_buf[0]=AV_EXIT;
		av_buf[1]=myapid;
		av_buf[2]=0;
		av_buf[3]=myapid;
		av_buf[4]=0;
		av_buf[5]=0;
		av_buf[6]=0;
		av_buf[7]=0;
		appl_write(apid,16,av_buf);
	}
}

/***************************************************************************/
/*													  												*/
/***************************************************************************/
int main(int argc, char *argv[], char *env)
{
   int event,ret,msgbuf[8];

   if((gl_apid=appl_init())>-1)
   {
      envptr = env;
      aeshandle=graf_handle(&ret,&boxh,&ret,&ret);
		wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
      graf_mouse(ARROW,NULL);
      rsrc_init();
   	read_inf("COGITO.INF");
   	set_dials();
	   AVInit(gl_apid,"COGITO  ",1|4|32|64|1024);
      if(_app)
      {
			if(argc==2)
			{
				parameter_bearbeiten(argv[1], shell.pein, shell.paus, shell.pinhalt);
			}
			else
			{
				if(_GemParBlk.global[0]>=0x0400)
					menu_register(gl_apid,"  " ACCNAME);
				wind_update(BEG_UPDATE);
				menu_bar(packmenu,TRUE);
				wind_update(END_UPDATE);
	
	         form_exhndl(packdial,0,0);
	
				wind_update(BEG_UPDATE);
				menu_bar(packmenu,FALSE);
				wind_update(END_UPDATE);
	         if(shell.merken)
   	         write_inf("COGITO.INF");
			}
         AVExit(gl_apid);
         appl_exit();
      }
      else
      {
			menu_register(gl_apid,"  " ACCNAME);
		   do
		   {
		      event = evnt_multi(MU_MESAG,
		         0x02, 0x01, 0x01,
		         0, 0, 0, 0, 0,
		         0, 0, 0, 0, 0,
		         msgbuf,
		         0, 0,
		         &ret, &ret, &ret, &ret, &ret, &ret);
		      if(event & MU_MESAG)
		         if(msgbuf[0]==AC_OPEN)
                  form_exhndl(packdial,0,0);
		   }
		   while(1);
	   }
   }
   return(0);
}