/* Laden und Speichern von Dateien */
/*****************************************************************************
*
*											 7UP
*									  Modul: FILEIO.C
*									(c) by TheoSoft '90
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
#include <ext.h>
/*
#include "7up.rh"
*/
#include "fsel_inp.h"
#else
#include <alloc.h>
#include <dir.h>
#include <dos.h>
#include <io.h>
#endif

#include "alert.h"
#include "windows.h"
#include "forms.h"
#include "7UP.h"

#include "language.h"

extern WINDOW _wind[MAXWINDOWS];

typedef struct
{
	int menu,item;
} UNDO;

int  WI_KIND=CLOSER|MOVER|NAME|INFO|FULLER|UPARROW|VSLIDE|DNARROW|SIZER|RTARROW|HSLIDE|LFARROW;

#define FILEIOBUFF (32*1024L)
#define TEXT	  0  /* windowtype */
#define GRAPHIC  1
#define PRT	 0
#define DESK	  0
#define TRUE	  1
#define FALSE	0
#define VERTICAL 1
#define CRLF 1
#define LF	2
#define CR	3

#define METAFILE 31

void showprogress(OBJECT *tree, long size, long len);
int open_work (int device);
void close_work (int handle, int device);
int Wtxtdraw(register WINDOW *wp, int dir, int clip[]);
int menu_ikey(OBJECT *m_tree, int kstate, int key);
int editor(WINDOW *wp, int state, int key);
void add_icon(OBJECT *tree, int icon);
void ren_icon(OBJECT *tree, int icon);
void del_icon(OBJECT *tree, int icon);
void drag_icon(OBJECT *tree, int icon);
void click_icon(OBJECT *tree, int icon);
WINDOW *Wreadfile(char *name, int mode);
WINDOW *Wnewfile(char *name);
void Wdefattr(WINDOW *wp);
char *split_fname(char *pathname);
hndl_prtmenu(OBJECT *tree, WINDOW *wp);
Dredraw(OBJECT *tree, int obj, int depth);
int desk_fkey(OBJECT *tree,int ks,int kr);
int Dhndlfkt(OBJECT *tree, int x, int y);
int ins_line(WINDOW *wp);
void paste_blk(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end);
int getfilename(char *pathname, char *pattern, char *fname, const char *meldung);
int findlastspace(char *iostr, int umbruch, int abscol);
void write_file(WINDOW *wp, int newname);
char *change_ext(char *name, char *ext);
char *change_name(char *name, char *newname);
char *change_linealname(char *name, char *newname);
WINDOW *Wreadtempfile(char *filename, int mode);

char *stpexpan(char *, char *, int, int, int *); /* expand TABS in a string */
char *stptabfy(char *, int);				 /* Compress blanks to TABs.*/

long *get_cookie(long cookie);

int countdeletedfiles=0,bcancel,lineendsign,wret,eszet,tabexp;

extern OBJECT *winmenu,*prtmenu,*popmenu,
				  *desktop,*findmenu,*gotomenu,
				  *fontmenu,*tabmenu,*infomenu,
				  *progress,*divmenu,*layout,
				  *pinstall,*fselbox;

extern long begline,endline;
extern int vdihandle,xdesk,ydesk,wdesk,hdesk,boxh;
extern char alertstr[256];
extern UNDO undo;
extern int terminate_at_once;


char iostring[STRING_LENGTH+3],iostr2[STRING_LENGTH+3];

#if GEMDOS
int access(char *filename, int fattr)
{
	struct ffblk fileRec;
	int ret;
	
   ret=findfirst(filename,&fileRec,fattr);
	return(!ret);
}
#endif

void Wfree(WINDOW *wp)
{
	register LINESTRUCT *line /*,*lastline*/;
	int newname=FALSE;

	if(wp)
	{
		countdeletedfiles++;
		if(wp->fstr && !terminate_at_once) /* schnelles Beenden */
		{
			if(wp->w_state & CHANGED)
			{
				sprintf(iostring,Afileio[0],split_fname((char *)Wname(wp)));
				if(form_alert(2,iostring)==2)
				{
					if(!strcmp((char *)Wname(wp),NAMENLOS))
						newname=TRUE;
					 write_file(wp, newname);
				}
			}
			graf_mouse(BUSY_BEE,NULL);
         while(wp->fstr!=NULL)
         {
            line=wp->fstr;
            wp->fstr=line->next;
				free(line->string);
            free(line);
         }
			graf_mouse(ARROW,NULL);
		}
		free(wp->name);
		wp->name=NULL;
		free(wp->info);
		wp->info=NULL;
#if GEMDOS
		if(vq_gdos())
#endif
			if(wp->w_state & GEMFONTS)
			{
				vst_unload_fonts(wp->vdihandle,0);
				wp->w_state &= ~GEMFONTS;
				wp->w_state &= ~PROPFONT;
			}
	}
}

void complete_path(char *path)
{
	char *cp;
	
	if((cp=strchr(path,'/'))!=NULL)
	{  /* Wenn ein Slash auftritt, so ist das der DIRSEP! */
		if(path[strlen(path)-1]!='/')
			strcat(path,"/"); /* Slash anh„ngen */
	}
	else
	{	/* normaler Pfadname mit Backslash */
		if(path[strlen(path)-1]!='\\')
			strcat(path,"\\");
	}
}

void cut_path(char *path)
{
	char *cp;
	if((cp=strrchr(path,'\\'))!=NULL || (cp=strrchr(path,'/'))!=NULL)
		*(cp+1)=0;
}

char *search_env(char *path, char *filename, int write)
{
	register char *cp;
	if((cp=getenv("7UP"))!=NULL || 
	   (cp=getenv("SEVENUP"))!=NULL ||	/* wg. GEMINI 1.99 */
	   (cp=getenv("HOME"))!=NULL)
	{
		strcpy(path,cp);
		complete_path(path);
		strcat(path,filename);
/* MT 8.9.94 shel_find() macht Probleme. Zugriff auf A: 
		if(write) /* wenn schreiben, dann hier */
			return(path);
		if(shel_find(path))
			return(path);
*/
		return(path);
	}
	strcpy(path,filename);
	return(path);
}

int gettrashname(char *pathname, const char *meldung)
{
	int i,button;
	char filename[FILENAME_MAX];

	filename[0]=0;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */

#if GEMDOS

	if(_GemParBlk.global[0] >= 0x0140 || get_cookie('FSEL'))
	{
		if(fsel_exinput(pathname,filename,&button,meldung))
		{
			if(button && strlen(filename))
			{
				cut_path(pathname);
				strcat(pathname,filename); /* zugriffspfad zusammensetzen */
				wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
				wind_update(END_UPDATE);
				return(TRUE);
			}
		}
	}
	else
	{
#endif
#if MSDOS
		if(gb.gb_pglobal[0]<0x0400)	 /* bei GEM/3 */
			fselbox->ob_width=476;
		else
			fselbox->ob_width=476+28;	  /* bei GEM/4 */
		fselbox[FSELTEXT].ob_x=
			(fselbox[ROOT].ob_width-fselbox[FSELTEXT].ob_spec.tedinfo->te_txtlen*8)/2;
#endif
		form_center(fselbox,&i,&i,&i,&i);
#if GEMDOS
		fselbox->ob_y=ydesk+7;
		fselbox->ob_state&=~SHADOWED; /* Atari-like */
		fselbox->ob_state|=OUTLINED;
#else
		fselbox->ob_y=2*ydesk;
		fselbox->ob_spec.obspec.framesize=1; /* eigentlich framesize,...	*/
													/* aber anscheinend vertauscht */
		fselbox->ob_state|=SHADOWED;
		fselbox->ob_state&=~OUTLINED;
#endif
		form_write(fselbox,FSELTEXT,meldung,FALSE);
		form_open(fselbox,0);
		if(fsel_input(pathname,filename,&button))
		{
			if(button && strlen(filename))
			{
				cut_path(pathname);
				strcat(pathname,filename); /* zugriffspfad zusammensetzen */
				form_close(fselbox,-1,0);
				wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
				wind_update(END_UPDATE);
				return(TRUE);
			}
		}
		form_close(fselbox,-1,0);
#if GEMDOS
	}
#endif
	wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
	wind_update(END_UPDATE);
	return(FALSE);
}

int getfilename(char *pathname, char *pattern, char *fname, const char *meldung)
{
	int i,button;
	static int first=TRUE;
	static char path[PATH_MAX],filename[FILENAME_MAX];
	char *cp;
	WINDOW *wp;

#if GEMDOS
	if(first)
	{
		filename[0]=0;
		path[0]=(char)(Dgetdrv()+'A');
		path[1]=':';
		Dgetpath(&path[2],0);
		strcat(path,"\\");
		if(*pattern)
			strcat(path,pattern);
		else
			strcat(path,"*.*");
		first=FALSE;
	}
#else
	if(first)
	{
		filename[0]=0;
		path[0]=(char)(getdisk()+'A');
		path[1]=':';
		path[2]='\\';
		getcurdir(0,&path[3]);
		complete_path(path);
		if(*pattern)
			strcat(path,pattern);
		else
			strcat(path,"*.*");
		first=FALSE;
	}
#endif

	if(!first)
	{
		if(*pattern)
		{
			cut_path(path);
			strcat(path,pattern);
		}
		switch(*fname)
		{
			case '@':
				*filename=0;
				break;
			case '\0':
				break;
			default:
				strcpy(filename,fname);
				break;
		}
	}

	if(*pathname)
		strcpy(path,pathname);
	else
	{
		if((divmenu[DIVPATH].ob_state&SELECTED) &&  /* wenn angeklickt... */
			((wp=Wgettop())!=NULL) &&					/* und Fenster offen... */
			(strchr(wp->name,':')))					 /* und vollst„ndig...	*/
		{														/* dann Pfad bernehmen */
			strcpy(path,(char *)Wname(wp));
			cut_path(path);
			strcat(path,"*");
			if(cp=strrchr(wp->name,'.')) /* letzter Punkt von hinten */
				strcat(path,cp);
			else
				strcat(path,".*");
			*filename=0;
		}
	}
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
#if GEMDOS

	if(_GemParBlk.global[0] >= 0x0140 || get_cookie('FSEL'))
	{
		if(fsel_exinput(path,filename,&button,meldung))
		{
			if(button && strlen(filename))
			{
				strcpy(pathname,path);
				if((cp=strrchr(pathname,'\\'))!=NULL || (cp=strrchr(pathname,'/'))!=NULL) /* Extender merken */
					strcpy(pattern,cp+1);
				cut_path(pathname);
				strcat(pathname,filename); /* zugriffspfad zusammensetzen */
				wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
				wind_update(END_UPDATE);
				return(TRUE);
			}
		}
	}
	else
	{
#endif
#if MSDOS
		if(gb.gb_pglobal[0]<0x0400)	 /* bei GEM/3 */
			fselbox->ob_width=476;
		else
			fselbox->ob_width=476+28;	  /* bei GEM/4 */
		fselbox[FSELTEXT].ob_x=
			(fselbox[ROOT].ob_width-fselbox[FSELTEXT].ob_spec.tedinfo->te_txtlen*8)/2;
#endif
		form_center(fselbox,&i,&i,&i,&i);
#if GEMDOS
		fselbox->ob_y=ydesk+7;
		fselbox->ob_state&=~SHADOWED; /* Atari-like */
		fselbox->ob_state|=OUTLINED;
#else
		fselbox->ob_y=2*ydesk;
		fselbox->ob_spec.obspec.framesize=1; /* eigentlich framesize,...	*/
													/* aber anscheinend vertauscht */
		fselbox->ob_state|=SHADOWED;
		fselbox->ob_state&=~OUTLINED;
#endif
		form_write(fselbox,FSELTEXT,meldung,FALSE);
		form_open(fselbox,0);
		if(fsel_input(path,filename,&button))
		{
			if(button && strlen(filename))
			{
				strcpy(pathname,path);
				if((cp=strrchr(pathname,'\\'))!=NULL || (cp=strrchr(pathname,'/'))!=NULL) /* Extender merken */
					strcpy(pattern,cp+1);
				cut_path(pathname);
				strcat(pathname,filename); /* zugriffspfad zusammensetzen */
				form_close(fselbox,-1,0);
				wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
				wind_update(END_UPDATE);
				return(TRUE);
			}
		}
		form_close(fselbox,-1,0);
#if GEMDOS
	}
#endif
	if((cp=strrchr(path,'\\'))!=NULL || (cp=strrchr(pathname,'/'))!=NULL)  /* Extender in jedem Falle merken */
		strcpy(pattern,cp+1);
	wind_update(END_MCTRL); /* wg, graf_slidebox() lt. Profibuch S.691 */
	wind_update(END_UPDATE);
	return(FALSE);
}

char *split_fname(char *pathname)
{
	register char *cp;
/*
	if(getenv("UNIXMODE")!=NULL)
	{
		if((cp=strrchr(pathname,'/'))!=NULL)
			return(cp+1);
		else
			return(pathname);
	}
	else
*/
	{
		if((cp=strrchr(pathname,'\\'))!=NULL)
			return(cp+1);
		if((cp=strrchr(pathname,'/'))!=NULL)
			return(cp+1);
		return(pathname);
	}
}

long strcchg(register char *str, register char old, register char new)
{
   register long count=0;
	do
	{
		if(*str==old)
		{
			*str=new;
			count++;
		}
	}
	while(*(++str));
   return(count);
}

int isascformat(char *name)
{
	register int k;
	k=strlen(name);
	if(toupper(name[k-3])=='A' &&  /*  *.ASC laden */
		toupper(name[k-2])=='S' &&
		toupper(name[k-1])=='C')
		return(TRUE);
	return(FALSE);
}

int read_file(WINDOW *wp,char *name)
{
	FILE *fp;
	long k=0;
	char filename[PATH_MAX],lastchar=0;
	int ascformat=FALSE,blank,enough_ram=TRUE;
	register LINESTRUCT *line,*help;
	static char fpattern[FILENAME_MAX]="*.*";

#if GEMDOS
	int buff[2048];
#endif
	if(name)
		strcpy(filename,name);
	else
	{
		filename[0]=0;
		if(!getfilename(filename,fpattern,"",fselmsg[10]))
		{
			wp->name[0]=0;
			return(FALSE);
		}
		wp->hfirst=wp->wfirst=0;
		wp->row=wp->col=0;
	}
	wp->draw=Wtxtdraw;
	Wnewname(wp,filename);

	ascformat=isascformat(wp->name); /* Extension .ASC? */
	k=0;
	if((fp=fopen(filename,"rb"))!=NULL)
	{
		wp->umbruch--;
		graf_mouse(BUSY_BEE,NULL);
		if(filelength(fileno(fp))==0)
		{
			graf_mouse(M_OFF,NULL);
			Wcursor(wp);
			ins_line(wp);
			Wcursor(wp);
			graf_mouse(M_ON,NULL);
			k=1;
		}
		else
		{
/*
			fseek(fp,-4L,SEEK_END);					/* vier Bytes vor das Ende */
			fread(buff,1L,4L,fp);					  /* vier Bytes lesen */
			if(!strncmp(buff,"\r\t\r\t",4))		 /* CR TAB CR TAB */
			{
				wp->tab=0;
				fseek(fp,-(wp->tab+1+4L),SEEK_END);  /* ab Stelle davor Anzahl Tabs */
				while(fgetc(fp)=='\t')					/* lesen und zurckrcken */
				{
					fseek(fp,-(++wp->tab+1+4L),SEEK_END); /* nochmal zurck und lesen */
				}
				if(wp->tab==0)
					wp->tab=1;
			}
*/
#if GEMDOS
			if(setvbuf(fp,NULL,_IOFBF,FILEIOBUFF))
				setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
			if((line=malloc(sizeof(LINESTRUCT)))!=NULL)
			{
				wp->cstr=wp->wstr=wp->fstr=line;
				wp->cstr->prev=wp->wstr->prev=wp->fstr->prev=line->prev=NULL;
				while((enough_ram != -1) && (fgets(iostr2,ascformat?wp->umbruch+2:STRING_LENGTH+2, fp) != NULL))
				{
					if(ascformat) /* evtl. Zeilenumbruch */
					{
						iostr2[wp->umbruch+2]=0;
						line->len=strlen(iostr2);
						while((iostr2[line->len-1] == '\n') || 
						      (iostr2[line->len-1] == '\r'))
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
/*
						if(iostr2[line->len-1] == '\n')
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
						if(iostr2[line->len-1] == '\r')
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
*/
						if(iostr2[0]==' ')
						{
							strcpy(iostr2,&iostr2[1]);
							line->len--;
						}
						if(line->len > wp->umbruch)
						{
							blank=findlastspace(iostr2,wp->umbruch,wp->umbruch+1);
							if(blank>0)
							{
								fseek(fp,-(long)(wp->umbruch-blank),SEEK_CUR); /* zurck positionieren */
								iostr2[blank]=0;
								if(wp->w_state & BLOCKSATZ) /* evtl. Blocksatz formatieren */
								{
									blockformat(iostr2, wp->umbruch-blank);
								}
							}
						}
						strcpy(iostring, iostr2);
						line->len=strlen(iostring);
					}
					else
					{
						if(tabexp)
							stpexpan(iostring, iostr2, wp->tab, STRING_LENGTH, &line->len);
						else
						{
							strcpy(iostring, iostr2);
							line->len=strlen(iostring);
						}
						lastchar=0;
						while((iostring[line->len-1] == '\n') || 
						      (iostring[line->len-1] == '\r'))
						{
							iostring[line->len-1]=0;
							lastchar='\n';
							line->len--;
						}
/*
						if(iostring[line->len-1] == '\n') /* Linefeed */
						{
							iostring[line->len-1]=0;
							lastchar='\n';
							line->len--;
						}
						if(iostring[line->len-1] == '\r') /* Carriage Return */
						{
							iostring[line->len-1]=0;
							lastchar='\r';
							line->len--;
						}
*/
					}
					if((line->string=malloc(line->len + 1))!=NULL)
					{
						k++;
						line->used = line->len;
						strcpy(line->string,iostring);
						if(eszet)
							strcchg(line->string,'á','á'); /* Peseta gegen IBM-Eszet		 */
						line->attr=0;	/* zeilenmarkierung */
						line->effect=0; /* Texteffect */
/*
						if(strchr(line->string,9))
							line->attr|=TABCOMP;
*/
						help=line;
						if((line->next=malloc(sizeof(LINESTRUCT))) != NULL)
						{
							line=line->next;
							line->prev=help;
							line->next=NULL;
						}
						else
						{
							enough_ram=-1;
							lastchar=0; /* OUT OF MEMORY berlisten */
							goto WEITER;
						}
					}
					else
					{
						enough_ram=-1;
						lastchar=0;
					}
				}
				if((lastchar!=0) && ((line->string=malloc(NBLOCKS+1))!=NULL))
				{
					line->string[0]=0;
					line->len=NBLOCKS;
					line->used=0;
					line->attr=0;
					line->effect=0; /* Texteffect */
					line->next=NULL;
					k++;
				}
				else
				{
					line=line->prev;
					free(line->next);
					line->next=NULL;
				}
WEITER:	 ;
			}
			else
				enough_ram=-1;
		}
		fclose(fp);
		wp->hsize = k * wp->hscroll;
		graf_mouse(ARROW,NULL);
		wp->umbruch++;
	}
	else
	{
		return(FALSE);
	}
	return(enough_ram);
}

int _read_blk(WINDOW *wp, char *filename, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	FILE *fp;
	register long k=0;
	int ascformat=FALSE,blank, enough_ram=TRUE;
	register LINESTRUCT *line, *help1;
	char lastchar=0;

#if GEMDOS
	int buff[2048];
#endif

	ascformat=isascformat(wp->name); /* Extension .ASC? */
	k=0;
	if((fp=fopen(filename,"rb")) != NULL)
	{
		wp->umbruch--;
		graf_mouse(BUSY_BEE,NULL);
		if(filelength(fileno(fp))==0)
		{
			enough_ram=FALSE;
		}
		else
		{
#if GEMDOS
			if(setvbuf(fp,NULL,_IOFBF,FILEIOBUFF))
				setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
			if((line=malloc(sizeof(LINESTRUCT)))!=NULL)
			{
				(*begcut)=line;
				begline=begline=wp->row+wp->hfirst/wp->hscroll;  /* zeilen = 1 */
				line->prev=NULL;
				while((enough_ram != -1) && (fgets(iostr2,ascformat?wp->umbruch+2:STRING_LENGTH+2, fp) != NULL))
				{
					if(ascformat) /* evtl. Zeilenumbruch */
					{
						iostr2[wp->umbruch+2]=0;
						line->len=strlen(iostr2);
						while((iostr2[line->len-1] == '\n') || 
						      (iostr2[line->len-1] == '\r'))
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
/*
						if(iostr2[line->len-1] == '\n')
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
						if(iostr2[line->len-1] == '\r')
						{
							iostr2[line->len-1]=0;
							line->len--;
						}
*/
						if(iostr2[0]==' ')
						{
							strcpy(iostr2,&iostr2[1]);
							line->len--;
						}
						if(line->len > wp->umbruch)
						{
							blank=findlastspace(iostr2,wp->umbruch,wp->umbruch+1);
							if(blank>0)
							{
								fseek(fp,-(long)(wp->umbruch-blank),SEEK_CUR); /* zurck positionieren */
								iostr2[blank]=0;
								if(wp->w_state & BLOCKSATZ) /* evtl. Blocksatz formatieren */
								{
									blockformat(iostr2, wp->umbruch-blank);
								}
							}
						}
						strcpy(iostring, iostr2);
						line->len=strlen(iostring);
					}
					else
					{
						if(tabexp)
							stpexpan(iostring, iostr2, wp->tab, STRING_LENGTH,&line->len);
						else
						{
							strcpy(iostring, iostr2);
							line->len=strlen(iostring);
						}
						lastchar=0;
						while((iostring[line->len-1] == '\n') || 
						      (iostring[line->len-1] == '\r'))
						{
							iostring[line->len-1]=0;
							lastchar='\n';
							line->len--;
						}
/*
						if(iostring[line->len-1] == '\n')
						{
							iostring[line->len-1]=0;
							lastchar='\n';
							line->len--;
						}
						if(iostring[line->len-1] == '\r') /* Carriage Return */
						{
							iostring[line->len-1]=0;
							lastchar='\r';
							line->len--;
						}
*/
					}

					if((line->string=malloc(line->len + 1)) != NULL)
					{
						k++;
						line->used = line->len;
						strcpy(line->string,iostring);

						if(eszet)
							strcchg(line->string,'á','á'); /* Peseta gegen IBM-Eszet		 */
						line->attr=0;	/* zeilenmarkierung */
						line->effect=0; /* Texteffect */
/*
						if(strchr(line->string,9))
							line->attr|=TABCOMP;
*/
						help1=line;
						if((line->next=malloc(sizeof(LINESTRUCT))) != NULL)
						{
							line=line->next;
							line->prev=help1;
							line->next=NULL;
						}
						else
						{
							enough_ram=-1;
							lastchar=0;
							goto WEITER;
						}
					}
					else
					{
						enough_ram=-1;
						lastchar=0;
					}
				}
				if((lastchar!=0) && ((line->string=malloc(NBLOCKS+1))!=NULL))
				{
					line->string[0]=0;
					line->len=NBLOCKS;
					line->used=0;
					line->attr=0;
					line->effect=0; /* Texteffect */
					line->next=NULL;
					k++;
				}
				else
				{
					line=line->prev;
					free(line->next);
					line->next=NULL;
				}
WEITER:
				(*endcut)=line;							 /* ende markieren */
				endline=begline + k;
			}
			else
				enough_ram=-1;
		}
		fclose(fp);
		graf_mouse(ARROW,NULL);
		wp->umbruch++;
		return(enough_ram);
	}
	return(FALSE);
}

int read_clip(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	char filename[PATH_MAX];

	if(wp)
	{
		scrp_read(filename);
		if(!*filename)
		{
			form_alert(1,Afileio[3]);
			return(FALSE);
		}
		complete_path(filename);
		strcat(filename,"SCRAP.TXT");

		switch(_read_blk(wp, filename,begcut,endcut))
		{
			case -1:
				form_alert(1,Afileio[4]);
			case TRUE:
				wp->w_state|=CHANGED;
				return(TRUE);
			case FALSE:
				form_alert(1,Afileio[5]);
				break;
		}
	}
	return(FALSE);
}

WINDOW *Wnewfile(char *name)
{
	WINDOW *wp=NULL;
	char *cp, pathname[PATH_MAX],filename[FILENAME_MAX];
	int wort1, ret;
/*	
   WI_KIND &= ~SMALLER;
	if(_GemParBlk.global[0]>=0x0399)
	{
	   appl_getinfo(12, &wort1, &ret, &ret, &ret);
	   if((wort1 & 0x0080) && (wort1 & 0x0100))
	     WI_KIND |= SMALLER;
	}
*/
	if(wp=Wcreate(WI_KIND,xdesk,ydesk,wdesk,hdesk))
	{
		Wdefattr(wp);
		wp->hsize=0;
		wp->wsize =STRING_LENGTH*wp->wscroll;
		if((wp->name=malloc(max(PATH_MAX,strlen(name)+1+12)))==NULL)
		{
			Wdelete(wp);
			return(NULL);
		}
		wp->name[0]=0;
		if((wp->info=malloc(80))==NULL)
		{
			free(wp->name);
			Wdelete(wp);
			return(NULL);
		}
		wp->info[0]=0;

		Wnewname(wp,name);
		Wnewinfo(wp,"");
		wp->draw=Wtxtdraw;
		wp->type=TEXT;
		add_icon(desktop, wp->icon);
		ren_icon(desktop, wp->icon);
		wp->hfirst=wp->wfirst=0;
		wp->row=wp->col=wp->cspos=0;
		ins_line(wp);
		Wsetscreen(wp);
		Wsetrcinfo(wp);
		if(!Wopen(wp))
		{
			form_alert(1,Afileio[6]);
			_exit(-1);
		}
		Wcuron(wp);
		strcpy(filename,split_fname((char *)Wname(wp)));
		change_linealname(filename,"LINEAL");
		search_env(pathname,filename,FALSE); /* READ */
		_read_lin(wp,pathname);

		wp->cspos=0;
		undo.menu=WINFILE;
		undo.item=WINCLOSE;
	}
	else
		form_alert(1,Afileio[7]);
	return(wp);
}

WINDOW *Wreadfile(char *name, int automatic)
{
	WINDOW *wp=NULL;
	char *cp,pathname[PATH_MAX],filename[FILENAME_MAX];
	int wort1, ret;
/*	
   WI_KIND &= ~SMALLER;
	if(_GemParBlk.global[0]>=0x0399)
	{
	   appl_getinfo(12, &wort1, &ret, &ret, &ret);
	   if((wort1 & 0x0080) && (wort1 & 0x0100))
	     WI_KIND |= SMALLER;
	}
*/
	if(wp=Wcreate(WI_KIND,xdesk,ydesk,wdesk,hdesk))
	{
		Wdefattr(wp);
		wp->hsize=0;
		wp->wsize =STRING_LENGTH*wp->wscroll;
		if((wp->name=malloc(max(PATH_MAX,strlen(name)+1+12)))==NULL)
		{
			Wdelete(wp);
			return(NULL);
		}
		wp->name[0]=0;
		if((wp->info=malloc(80))==NULL)
		{
			free(wp->name);
			Wdelete(wp);
			return(NULL);
		}
		wp->info[0]=0;

		Wnewname(wp,NAMENLOS);
		Wnewinfo(wp,"");
		wp->type=TEXT;
		wp->cspos=0;
		switch(read_file(wp,name))
		{
			case -1: /* kein ram frei */
				sprintf(iostring,Afileio[1],split_fname((char *)Wname(wp)));
				form_alert(1,iostring); /* kein break, es geht weiter */
			case TRUE: /* ok */
				add_icon(desktop, wp->icon);
				ren_icon(desktop, wp->icon);
				if(!automatic)
				{
					wp->hfirst=wp->wfirst=0;
					wp->row=wp->col=0;
				}
				Wsetrcinfo(wp);
				Wsetscreen(wp);
				if(!Wopen(wp))
				{
					form_alert(1,Afileio[6]);
					_exit(-1);
				}
				Wslupdate(wp,1+2+4+8);
				Wcuron(wp);
				strcpy(filename,split_fname((char *)Wname(wp)));
				change_linealname(filename,"LINEAL");
				search_env(pathname,filename,FALSE); /* READ */
				_read_lin(wp,pathname);
				undo.menu=WINFILE;
				undo.item=WINCLOSE;
				break;
			case FALSE: /* keine Datei gew„hlt */
				strcpy(iostring,(char *)Wname(wp));
				Wdelete(wp);
				if(*iostring)
				{
					sprintf(alertstr,Afileio[8],(char *)split_fname(iostring));
					if(form_alert(2,alertstr)==2)
						wp=Wnewfile(iostring);
					else
						wp=NULL;
				}
				break;
		}
	}
	else
		form_alert(1,Afileio[7]);
	return(wp);
}

WINDOW *Wgetwp(char *filename);

WINDOW *Wreadtempfile(char *filename, int mode)
{
	FILE *fp;
	WINDOW *wp=NULL;
	char tempname[PATH_MAX];

	if(wp=Wgetwp(filename))  /* schon geladen ? */
	{
		if(!(wp->w_state & OPENED))
			Wopen(wp);			 /* als Icon, also ”ffnen */
		else
			Wtop(wp);			 /* nur toppen */
		return(wp);
	}
	else
	{
		strcpy(tempname,filename);
		change_ext(tempname,".$$$");
/*
		if((fp=fopen(tempname,"r"))!=NULL)
		{
			fclose(fp);
*/
		if(access(tempname,0))
		{
			sprintf(alertstr,Afileio[10],split_fname(filename));
			if(form_alert(2,alertstr)==2)
			{
				if(wp=Wreadfile(tempname,mode))
				{
					Wnewname(wp,filename);
					ren_icon(desktop, wp->icon);
					return(wp);
				}
			}
		}
		return(Wreadfile(filename,mode));
	}
}

static char *colcpy(char *str, LINESTRUCT *line) /* Spalte herauskopieren */
{
	if(line->begcol < line->used)
	{
		strcpy(str,&line->string[line->begcol]);
		str[line->endcol-line->begcol]=0;
		blank(str,line->endcol-line->begcol);/* evtl. blanks */
	}
	else /* auáerhalb des strings > line->used */
	{
		memset(str,' ',line->endcol-line->begcol);
		str[line->endcol-line->begcol]=0;
	}
	return(str);
}

static int _write_blk(WINDOW *wp, char *filename, LINESTRUCT *beg, LINESTRUCT *end)
{
	FILE *fp;
	register LINESTRUCT *line;
	char openmodus[2];
	int error,ret,kstate;

#if GEMDOS
	int buff[2048];
#endif

	graf_mkstate(&ret,&ret,&ret,&kstate);
	if(kstate & (K_LSHIFT|K_RSHIFT))	 /* bei gedrckter Shifttaste... */
		strcpy(openmodus,"a");			  /* ans Clipboard anh„ngen,...*/
	else
		strcpy(openmodus,"w");				/* ...sonst neue Datei	  */

	if((fp=fopen(filename,openmodus))!=NULL)
	{
		graf_mouse(BUSY_BEE,NULL);
#if GEMDOS
		if(setvbuf(fp,NULL,_IOFBF,FILEIOBUFF))
			setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
		line=beg;
		do
		{
			if((wp->w_state&COLUMN)) /* bei Spaltenblock */
			{
				if(fputs(colcpy(iostring,line),fp)==EOF)
				{
					form_alert(1,Afileio[11]);
					goto WEITER;
				}
			}
			else
			{
				strcpy(iostring,&line->string[line->begcol]);
				iostring[line->endcol-line->begcol]=0;
				if(fputs(iostring,fp)==EOF)
				{
					form_alert(1,Afileio[11]);
					goto WEITER;
				}
			}
			if(line->next != end->next)
			{
				if(fputs("\n",fp)==EOF)
				{
					form_alert(1,Afileio[11]);
					goto WEITER;
				}
			}
			else
			{
				if(line->endcol==STRING_LENGTH)
				{
					if(fputs("\n",fp)==EOF)
					{
						form_alert(1,Afileio[11]);
						goto WEITER;
					}
				}
			}
			line=line->next;
		}
		while(line != end->next);
WEITER:
		error=ferror(fp);
		fclose(fp);
		if(error)
			unlink(filename);
		graf_mouse(ARROW,NULL);
		return(TRUE);
	}
	return(FALSE);
}

char *change_ext(char *name, char *ext)
{
	char *cp;

	cp=strrchr(name,'.');
	if(cp)
		*cp=0;
	strcat(name,ext);
	return(name);
}

char *change_name(char *name, char *newname)
{
	register int i,k;
	char *cp,temp[PATH_MAX];

	cp=split_fname(name);
	strcpy(temp,cp);
	*cp=0;
	strcat(name,newname);
	k=strlen(temp);
	for(i=0; i<k; i++)
		if(temp[i]=='.')
			break;
	if(temp[i]=='.')
		strcat(name,&temp[i]);
	return(name);
}

char *change_linealname(char *name, char *newname)
{
	register int i,k;
	char *cp,temp[PATH_MAX];
/*
	cp=split_fname(name);
	strcpy(temp,cp);
	*cp=0;
	strcat(name,newname);
	k=strlen(temp);
	for(i=0; i<k; i++)
		if(temp[i]=='.')
			break;
	if(temp[i]=='.')
		strcat(name,&temp[i]);
	return(name);
*/
	strcpy(temp,name);
	if((cp=strrchr(temp,'\\'))!=NULL || (cp=strrchr(temp,'/'))!=NULL)
		cp[1]=0;
	else
		temp[0]=0;
		
	strcat(temp,"7UP");
	cp=strrchr(name,'.');
	if(cp)
		strcat(temp,&cp[1]);

	strcat(temp,".LIN");
	strcpy(name,temp);
	return(name);
}

/*
static long bwrite(WINDOW *wp, LINESTRUCT *line, int ascformat, FILE *fp)
{
	char *save=NULL, *buff=NULL, *cp;
	long count=0,m,n,bsize,lines,chars;

#if GEMDOS
	Wtxtsize(wp,&lines,&chars);
	bsize=(long)Malloc(-1L)-4096L;
#else
	bsize=farcoreleft()-4096L;
#endif
	if(bsize<0)
		return(0);
	if(wret)
	   chars+=lines; /* fr jede Zeile ein Blanks nicht vergessen */
#if GEMDOS
	save=buff=Malloc((long)min(chars+2,bsize+2));
#else
	save=buff=malloc(bsize=min(bsize,32000)+2);
#endif
	if(buff)
	{
		do
		{
			while(line && ((buff+line->used+3L) < (save+bsize)))
			{
				if(bcancel && !ascformat)
					if(line->used > 0)
					{
						while(line->string[--line->used] == ' ')
							line->string[line->used] = 0;
						line->used++;
					}
				strcpy(iostring,line->string);
				if(ascformat)
				{
					cp=strchr(iostring,' ');
					while(cp)
					{
						if(*(cp+1L) == ' ')
							strcpy(cp,cp+1L);
						cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
					}
				}
/*
				if(wp->w_state & TABCOMP)					/* tab compression */
					strcpy(buff,stptabfy(iostring, wp->tab));
				else
*/
					strcpy(buff,iostring);
				buff+=strlen(buff);
				if(line->next)
				{
					if(ascformat)
					{															/* ASC-Format */
						if(!line->next->used || !line->used)		  /* Absatzende */
						{
							switch(lineendsign) /* Zeilenendekennung */
							{
								case CRLF:
									strcat(buff,"\r\n");
									buff+=2L;
									break;
								case LF:
									strcat(buff,"\n");
									buff+=1L;
									break;
								case CR:
									strcat(buff,"\r");
									buff+=1L;
									break;
							}
						}
						else
						{
							strcat(buff," "); /* Flieátext */
							buff+=1L;
						}
					}
					else			/* TXT-Format */
					{
						if(wret)
						{
							if(line->next->used)
							{									/* kein Blank bei Absatzende */
								strcat(buff," ");						/* weiches Return */
								buff+=1L;
							}
						}
						switch(lineendsign) /* Zeilenendekennung */
						{
							case CRLF:
								strcat(buff,"\r\n");
								buff+=2L;
								break;
							case LF:
								strcat(buff,"\n");
								buff+=1L;
								break;
							case CR:
								strcat(buff,"\r");
								buff+=1L;
								break;
						}
					}
				}
				line=line->next;
			}
#if GEMDOS
			n=Fwrite(fileno(fp),m=strlen(save),save);
#else
			n=_write(fileno(fp),save,m=strlen(save));
#endif
			if(n==m)
				count+=n;
			else
			{
				form_alert(1,Afileio[11]);
				count=-1;
				goto WEITER;
			}
			buff=save;
		}
		while(line);
WEITER:
#if GEMDOS
		Mfree(save);
#else
		free(save);
#endif
	}
	return(count);
}
*/
void _write_file(WINDOW *wp, char *filename, char *openmodus, int newname, int ascformat, int signal)
{
	FILE *fp;
	register LINESTRUCT *line;
	char *cp;
	int i,error;
	struct ffblk fileRec;
	long lines,chars;

#if GEMDOS
	int buff[2048];
#endif

	if(wp)
	{
		if(signal==SIGNULL)
		{
			graf_mouse(M_OFF,NULL);
			Wcursor(wp);
			graf_mouse(M_ON,NULL);
		}
NOCHMAL:
		if((fp=fopen(filename,openmodus))!=NULL)
		{
			if(signal==SIGNULL)
				graf_mouse(BUSY_BEE,NULL);
			line=wp->fstr;
			if(TRUE/*bwrite(wp,line,ascformat,fp)==0*/) /* schnell */
			{
#if GEMDOS
				Wtxtsize(wp,&lines,&chars);
				if(wret)
	   			chars+=lines; /* fr jede Zeile ein Blanks nicht vergessen */

				if(setvbuf(fp,NULL,_IOFBF, ((chars/1024)+1)*1024 ))
					if(setvbuf(fp,NULL,_IOFBF,FILEIOBUFF))
						setvbuf(fp,buff,_IOFBF,sizeof(buff));
#endif
				do
				{										 /* Blanks am Ende unterdrcken */
					if(bcancel && !ascformat)
						if(line->used > 0)
						{
							while(line->string[--line->used] == ' ')
								line->string[line->used] = 0;
							line->used++;
						}
					strcpy(iostring,line->string);
					if(ascformat)
					{
						cp=strchr(iostring,' ');
						while(cp)
						{
							if(*(cp+1L) == ' ')
								strcpy(cp,cp+1L);
							cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
						}
					}
					if(fputs(iostring,fp)==EOF)
					{
						form_alert(1,Afileio[11]);
						goto WEITER;
					}
					if(line->next)
					{
						if(ascformat) /* ASC-Format */
						{
							if(!line->next->used || !line->used)
							{
								switch(lineendsign) /* Zeilenendekennung */
								{
									case CRLF:
										if(fputs("\r\n",fp)==EOF)
										{
											form_alert(1,Afileio[11]);
											goto WEITER;
										}
										break;
									case LF:
										if(fputs("\n",fp)==EOF)
										{
											form_alert(1,Afileio[11]);
											goto WEITER;
										}
										break;
									case CR:
										if(fputs("\r",fp)==EOF)
										{
											form_alert(1,Afileio[11]);
											goto WEITER;
										}
										break;
								}
							}
							else
							{
								if(fputs(" ",fp)==EOF)  /* weiches Return Absatzformat */
								{
									form_alert(1,Afileio[11]);
									goto WEITER;
								}
							}
						}
						else
						{
							if(wret)
							{
								if(fputs(" ",fp)==EOF)  /* weiches Return */
								{
									form_alert(1,Afileio[11]);
									goto WEITER;
								}
							}
							switch(lineendsign) /* Zeilenendekennung */
							{
								case CRLF:
									if(fputs("\r\n",fp)==EOF)
									{
										form_alert(1,Afileio[11]);
										goto WEITER;
									}
									break;
								case LF:
									if(fputs("\n",fp)==EOF)
									{
										form_alert(1,Afileio[11]);
										goto WEITER;
									}
									break;
								case CR:
									if(fputs("\r",fp)==EOF)
									{
										form_alert(1,Afileio[11]);
										goto WEITER;
									}
									break;
							}
						}
					}
					line=line->next;
				}
				while(line);
			}
WEITER:
			error=ferror(fp);
/*
			for(i=0; i<wp->tab; i++)
				fputc('\t',fp);
			fwrite("\r\t\r\t",1L,4L,fp);
*/
			fclose(fp);
			if(error)
				unlink(filename);
			else
			{
/*neu*/		if(newname && strcmp((char *)Wname(wp),filename))
				{
					if(form_alert(2,Afileio[13])==2)
					{
						wp->w_state &= ~CHANGED; /* rckg„ngig machen */
						Wnewname(wp,filename);
						ren_icon(desktop, wp->icon);
					}
				}
				else
					wp->w_state &= ~CHANGED; /* rckg„ngig machen */
			}
			if(signal==SIGNULL)
				graf_mouse(ARROW,NULL);
		}
		else
		{
			findfirst(filename,&fileRec,0);
			if(fileRec.ff_attrib & 1) /* readonly */
			{
/* unn”tig
				while(!findnext(&fileRec)); /* weiter bis zum Ende */
*/
				if(form_alert(2,Afileio[14])==2)
				{
#if GEMDOS
					Fattrib(filename,1,0);  /* Schreibschutz aufheben */
#else
					chmod(filename,0);
#endif
					goto NOCHMAL;
				}
				else
					wp->w_state&=~CHANGED;
			}
			else
			{
				while(!findnext(&fileRec)); /* weiter bis zum Ende */
				form_alert(1,Afileio[15]);
			}
		}
		if(signal==SIGNULL)
		{
			graf_mouse(M_OFF,NULL);
			Wcursor(wp);
			graf_mouse(M_ON,NULL);
		}
	}
}

void write_file(WINDOW *wp, int newname)
{
	char filename[PATH_MAX],openmodus[3];
	int ascformat=FALSE,k,ret,kstate;
	static char fpattern[FILENAME_MAX]="*.*";

	graf_mkstate(&ret,&ret,&ret,&kstate);
	if(kstate & (K_LSHIFT|K_RSHIFT))	 /* bei gedrckter Shifttaste... */
		strcpy(openmodus,"ab");			  /* an Datei anh„ngen,...*/
	else
		strcpy(openmodus,"wb");			  /* ...sonst neue Datei	  */

	if(wp)
	{
		if(newname)
		{
			if(!(kstate & (K_LSHIFT|K_RSHIFT)))
			{
				filename[0]=0;
				if(getfilename(filename,fpattern,"",fselmsg[11]))
				{
					if(access(filename,0))
					{
						sprintf(iostring,Afileio[12],split_fname(filename));
						if(form_alert(1,iostring)==1)
							return;
					}
					k=strlen(filename);
					if(filename[k-3]=='G' &&  /*  *.ASC speichern */
						filename[k-2]=='E' &&
						filename[k-1]=='M')
					{
						gdosprint(prtmenu,layout,pinstall,wp,METAFILE,filename);
						return;
					}
				}
				else
					return;
			}
			if(kstate & (K_LSHIFT|K_RSHIFT))
			{
				filename[0]=0;
				if(!getfilename(filename,fpattern,"",fselmsg[12]))
					return;
			}
		}
		else
		{
			if(!(kstate & (K_LSHIFT|K_RSHIFT))) /* backup nicht bei Anh„ngen */
			{
				if(!(wp->w_state & CHANGED))
					return;
				if(divmenu[DIVBACK].ob_state&SELECTED)
				{
					strcpy(filename,(char *)Wname(wp));
					change_ext(filename,".BAK");
					unlink(filename);
					rename((char *)Wname(wp),filename);
				}
			}
/*neu*/  strcpy(filename,(char *)Wname(wp));
		}
		ascformat=isascformat(wp->name); /* Extension .ASC? */
		_write_file(wp, filename, openmodus, newname, ascformat, SIGNULL);
	}
}

void write_block(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end)
{
	char filename[PATH_MAX];
	static char fpattern[FILENAME_MAX]="*.*";

	if(wp && beg && end)
	{
		filename[0]=0;
		if(!getfilename(filename,fpattern,"",fselmsg[13]))
			return;
		if(access(filename,0))
		{
			sprintf(iostring,Afileio[12],split_fname(filename));
			if(form_alert(1,iostring)==1)
				return;
		}
		if(!_write_blk(wp, filename, beg, end))
		{
			form_alert(1,Afileio[16]);
		}
	}
}

#if GEMDOS
int getbootdev(void)
{
	int drv;
	long stack;

	stack=Super(0L);
	drv= *(int *)0x446;
	Super((void *)stack);
	return(drv);
}

int create_clip(void)
{
	char *cp, *pathname="@:\\CLIPBRD";

	if((cp=getenv("CLIPBRD")) || (cp=getenv("SCRAPDIR")))
		return(scrp_write(cp));
	else
	{
		pathname[0]=(char)(getbootdev()+'A');
		Dcreate(pathname);
		return(scrp_write(pathname));
	}
}

int scrp_clear(void) /* Clipbrd l”schen, fr Atari */
{
	char filename[PATH_MAX],path[PATH_MAX];
	struct ffblk fileRec;

	scrp_read(path);
	if(*path)
	{
		complete_path(path);
		strcpy(filename,path);
		strcat(filename,"SCRAP.*");
		if(!findfirst(filename,&fileRec,0))
		{
			strcpy(filename,path);
			strcat(filename,fileRec.ff_name);
			unlink(filename);
			while(!findnext(&fileRec))
			{
				strcpy(filename,path);
				strcat(filename,fileRec.ff_name);
				unlink(filename);
			}
			return(TRUE);
		}
	}
	return(FALSE);
}
#endif

void write_clip(WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut)
{
	char filename[PATH_MAX];
	static int first=TRUE;

	if(wp && begcut && endcut)
	{
		scrp_read(filename);
		if(!*filename)
		{
#if GEMDOS
			if(create_clip())
				scrp_read(filename);
			else
			{
				form_alert(1,Afileio[17]);
				return;
			}
#endif
		}
		else
		{
			if(first) /* beim erstenmal Clipbrd l”schen */
			{
				scrp_clear();
				first=FALSE;
			}
		}
		complete_path(filename);
		strcat(filename,"SCRAP.TXT");
		if(!_write_blk(wp, filename, begcut, endcut))
		{
			form_alert(1,Afileio[25]);
		}
		inst_clipboard_icon(desktop,DESKICNB,DESKICNC,FALSE);
	}
}

void Gsave(WINDOW *wp) /* GEMINI: nach $TRASHDIR */
{
	char *cp,filename[PATH_MAX];
	LINESTRUCT *beg,*end,*help;
	if(wp && (divmenu[DIVPAPER].ob_state&SELECTED))
	{
		if(cp=getenv("TRASHDIR"))
		{
			strcpy(filename,cp);
  			complete_path(filename);
			strcat(filename,split_fname((char *)Wname(wp)));
			for(help=beg=wp->fstr; help; help=help->next)
			{
				help->begcol=0;
				help->endcol=STRING_LENGTH;
				end=help;
			}
			if(_write_blk(wp, filename, beg, end))
			{
				wp->w_state&=~CHANGED;
				inst_trashcan_icon(desktop,DESKICN8,DESKICND,FALSE);
			}
			else
			{
				form_alert(1,Afileio[18]);
			}
		}
	}
}

delete_file(void)
{
	char filename[PATH_MAX];
	struct ffblk fileRec;
	static char fpattern[FILENAME_MAX]="*.*";

#if GEMDOS
#define MAXPATHS 7
	int i;
	char *cp;
	extern char lpath[MAXPATHS][PATH_MAX];
	extern char *lname[MAXPATHS];
	extern SLCT_STR *slct;
#endif

#if GEMDOS
	if( slct_check(0x0100))
	{
		slct_morenames(0, MAXPATHS,lname); /* we want more */
	}
#endif
	filename[0]=0;
	if(!getfilename(filename,fpattern,"@",fselmsg[14]))
		return;
	if(!filename[0]) /* Kunde will nicht */
		return;
#if GEMDOS
	if(slct && (slct->out_count>1))
	{
		slct->out_count=min(slct->out_count,MAXPATHS);
		for(i=0; i<slct->out_count; i++)
		{  /* Pfadnamen zusammenbasteln */
			if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
			{
				cp[1]=0;
				strcat(filename,lpath[i]);
				{
					sprintf(alertstr,Afileio[19],lpath[i]);
					if(form_alert(2,alertstr)==2)
					{
						graf_mouse(BUSY_BEE,NULL);
						if(unlink(filename)!=0)
							form_alert(1,Afileio[23]);
						graf_mouse(ARROW,NULL);
					}
				}
			}
		}
	}
	else
#endif
	{
		sprintf(alertstr,Afileio[19],split_fname(filename));
		if(form_alert(2,alertstr)==2)
		{
			graf_mouse(BUSY_BEE,NULL);
			if(!findfirst(filename,&fileRec,0))
			{
				cut_path(filename);
				strcat(filename,fileRec.ff_name);
				if(unlink(filename)!=0)
					form_alert(1,Afileio[23]);
				while(!findnext(&fileRec))
				{
					cut_path(filename);
					strcat(filename,fileRec.ff_name);
					if(unlink(filename)!=0)
						form_alert(1,Afileio[23]);
				}
				inst_trashcan_icon(desktop,DESKICN8,DESKICND,FALSE);
				if(!stricmp((char *)split_fname(filename),"SCRAP.TXT"))
					inst_clipboard_icon(desktop,DESKICNB,DESKICNC,FALSE);
			}
			else
				form_alert(1,Afileio[20]);
			graf_mouse(ARROW,NULL);
		}
	}
}

char errorstr[PATH_MAX]="";

static void nofilearg(char *arg, char what)
{
	WINDOW *wp;
	char *cp;
	int window;

	switch(what)
	{
		case '-':
			switch(arg[1])
			{
				case 't':
					window=atoi(&arg[2]);
					if(window<0)
						window+=Wcount(OPENED);
					if(window>0 && window<MAXWINDOWS)
						Wtop(&_wind[window]);
					break;
				case 'z': /* -z50s25 = Zeile 50 Spalte 25 */
					if(wp=Wgettop())
					{
						cp=strchr(arg,'s');
						if(cp)
						{
							*cp=0;
							wp->cspos=wp->col=atoi(cp+1L)-1;
						}
						hndl_goto(wp,NULL/*gotomenu*/,atol(&arg[2]));
					}
					break;
				default:
					break;
			}
			break;
		case '\"':
			if(arg[strlen(arg)-1] == '\"') /* fr Compilerfehlermeldung */
			{
				strcpy(errorstr,arg);
				if(wp=Wgettop())
				{  /* erst normal Inforzeile, um Timer auszutricksen */
					if(wp->kind & INFO)
					{
						graf_mouse(M_OFF,NULL);
						Wcursor(wp);
						Wsetrcinfo(wp);
						Wcursor(wp);
						graf_mouse(M_ON,NULL);
						wind_set(wp->wihandle,WF_INFO,errorstr);
					}
					else
						form_alert(1,Afileio[21]);
				}
			}
			break;
		default:
			switch(what)
			{
				case 'z': /* 50 = Zeile 50 */
					if(wp=Wgettop())
					{
						wp->cspos=wp->col=0;
						hndl_goto(wp,NULL/*gotomenu*/,atol(arg));
					}
					break;
				case 's': /* (xx) 25 = Spalte 25 */
					if(wp=Wgettop())
					{
						wp->cspos=wp->col=atoi(arg)-1;
					}
					break;
				default:
					break;
			}
			break;
	}
}

int isnumeric(char *num)
{
	int i,k=strlen(num);
	for(i=0; i<k; i++)
		if(!isdigit(num[i]))
			return(FALSE);
	return(TRUE);
}

char *stristr(char *s1, char *s2);

char *isinffile(int argc, char *argv[]) /* *.INF File dabei? */
{
	register int i;
	if(argc>1)
		for(i=1; i<argc; i++)
			if(stristr(argv[i],"7UP") && stristr(argv[i],".INF"))
				return(argv[i]);
	return(NULL);
}

int file_input(int argc, char *argv[])
{
#if MSDOS
	FILE *fp;
	struct ffblk fileRec;
	char filename[PATH_MAX];
	static char fpattern[FILENAME_MAX]="*.*";
#endif
	int i,k,msgbuf[8];
	extern int gl_apid;
	
	if(argc>1)
	{
		for(i=1,k=1; i<argc && k<MAXWINDOWS; i++)
		{
			if(*argv[i] == '\"')
				nofilearg(argv[i],'\"');
			if(*argv[i] == '-')
				nofilearg(argv[i],'-');
			if(!isnumeric(argv[i-1]) && isnumeric(argv[i]))
				nofilearg(argv[i],'z');
			if(isnumeric(argv[i-1]) && isnumeric(argv[i]))
				nofilearg(argv[i],'s');
			if(!(stristr(argv[i],"7UP") && stristr(argv[i],".INF")) &&
				!isnumeric(argv[i]) && *argv[i]!='-' && *argv[i]!='\"')
			{
				Wreadtempfile(argv[i],FALSE);
				k++;
			}
		}
	}
	else
	{
#if GEMDOS
		if((get_cookie('MagX') &&
			 shel_read(alertstr,&alertstr[128]) &&
			 !memcmp(&alertstr[128],"\0\0AUTO",6)) ||
			(get_cookie('MiNT') &&
			 (_GemParBlk.global[1] != 1) &&
			 shel_read(alertstr,&alertstr[128]) &&
			 strstr(strupr(alertstr),"AUTOGEM")))
		{
			winmenu[WINNEW -1].ob_height-=(2*boxh);
			winmenu[WINQUIT-1].ob_flags|=HIDETREE;
			winmenu[WINQUIT  ].ob_state|=DISABLED;
			winmenu[WINQUIT  ].ob_flags|=HIDETREE;
			return;
		}
#endif
		if(TRUE/*!readnames()*/)  /* nur FSB, wenn keine alten Dateien oder Parameter */
		{
#if GEMDOS
			msgbuf[0]=MN_SELECTED;
			msgbuf[1]=gl_apid;
			msgbuf[2]=0;
			msgbuf[3]=WINFILE;
			msgbuf[4]=WINOPEN;
			msgbuf[5]=0;
			msgbuf[6]=0;
			msgbuf[7]=0;
			menu_tnormal(winmenu,WINFILE,0);
#if OLDTOS
			wind_update(END_UPDATE);
#endif
			appl_write(gl_apid,16,msgbuf);
#if OLDTOS
			wind_update(BEG_UPDATE);
#endif
#else
			filename[0]=0;
			if(!getfilename(filename,fpattern,"",fselmsg[15]))
				return;
			if(!findfirst(filename,&fileRec,0))
			{
				cut_path(filename);
				strcat(filename,fileRec.ff_name);
				if(!Wreadtempfile(filename,FALSE))
					return;
				while(!findnext(&fileRec))
				{
					cut_path(filename);
					strcat(filename,fileRec.ff_name);
					if(!Wreadtempfile(filename,FALSE))
						return;
				}
			}
			else
			{
				sprintf(alertstr,Afileio[8],(char *)split_fname(filename));
				if(form_alert(2,alertstr)==2)
					Wnewfile(filename);
			}
if(0)
form_alert(1,"[0][][ok]");
#endif
		}
	}
}

void loadfiles(char *TV_path, char *TV_pattern) /* evtl. Treeviewpfade */
{
	register int i;
	char *cp;
	char filename[PATH_MAX];
	static char fpattern[FILENAME_MAX]="*.*";
	struct ffblk fileRec;

#if GEMDOS
#define MAXPATHS 7
	extern char lpath[MAXPATHS][PATH_MAX];
	extern char *lname[MAXPATHS];
	extern SLCT_STR *slct;

	if( slct_check(0x0100))
	{
		slct_morenames(0, MAXPATHS,lname); /* we want more */
	}
#endif
	filename[0]=0;
	if(*TV_path) /* Treeview ist am Werk, Pfade bernehmen */
	{
		strcpy(filename,TV_path);
		strcpy(fpattern,TV_pattern);
	}
	if(!getfilename(filename,fpattern,"",fselmsg[16]))
		return;
	if(!filename[0]) /* Kunde will nicht */
		return;
#if GEMDOS
	if(slct && (slct->out_count>1))
	{
		slct->out_count=min(slct->out_count,MAXWINDOWS-Wcount(CREATED)-1);
		for(i=0; i<slct->out_count; i++)
		{  /* Pfadnamen zusammenbasteln */
			if((cp=strrchr(filename,'\\'))!=NULL || (cp=strrchr(filename,'/'))!=NULL)
			{
				cp[1]=0;
				strcat(filename,lpath[i]);
				if(!Wreadtempfile(filename,FALSE))
					break;
			}
		}
	}
	else
#endif
	{
		if(get_cookie('MiNT'))
		{
			if(!Wreadtempfile(filename,FALSE))
			{
				sprintf(alertstr,Afileio[8],(char *)split_fname(filename));
				if(form_alert(2,alertstr)==2)
					Wnewfile(filename);
			}
		}
		else
		{
			if(!findfirst(filename,&fileRec,0))
			{
				cut_path(filename);
				strcat(filename,fileRec.ff_name);
				if(!Wreadtempfile(filename,FALSE))
					return;
				while(!findnext(&fileRec))
				{
					cut_path(filename);
					strcat(filename,fileRec.ff_name);
					if(!Wreadtempfile(filename,FALSE))
						break;
				}
			}
			else
			{
				sprintf(alertstr,Afileio[8],(char *)split_fname(filename));
				if(form_alert(2,alertstr)==2)
					Wnewfile(filename);
			}
		}
	}
}
