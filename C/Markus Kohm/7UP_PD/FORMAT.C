/* Textformatierung */
/*****************************************************************************
*
*											  7UP
*										Modul: FORMAT.C
*									 (c) by TheoSoft '91
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
#include "vaproto.h"
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
#include "undo.h"

extern OBJECT *desktop;
extern char iostring[],*iostr2[];
extern LINESTRUCT *lastwstr;
extern long		  lasthfirst,begline, endline;
extern int gl_apid, cut;

/* Neuformatieren im RAM. Umkopieren */
static void write_ram(WINDOW *wp, char *buff, long bsize, LINESTRUCT *beg, LINESTRUCT *end)
{
	LINESTRUCT *line;
	char *save,*cp;

	graf_mouse(BUSY_BEE,NULL);
	line=beg;
	save=buff;
	while(line!=end->next && ((buff+line->used+1L) < (save+bsize)))
	{
		if(line->used > 0)
		{
			while(line->string[--line->used] == ' ')
				line->string[line->used] = 0;
			line->used++;
		}
		/* mehrfache Blanks killen */
		while(line->string[0] == ' ')/*MT 24.7.94 fhrende Blanks raus */
		{
			strcpy(&line->string[0],&line->string[1]);
		}
		cp=strchr(line->string,' ');
		while(cp)
		{
			if(*(cp+1L) == ' ')
				strcpy(cp,cp+1L);
			cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
		}
		strcpy(buff,line->used?line->string:"\r");
		if(line->used && line->next)
		{
			if(!line->next->used)
				strcat(buff,"\r"); /* Abs„tze markieren */
			else
				strcat(buff," ");  /* Blank anh„ngen */
		}
		buff+=strlen(buff);
		line=line->next;
	}
	strcat(buff,"\r");
	graf_mouse(ARROW,NULL);
}

static long mread(char *dst, char *src, size_t count)
{
	register long i;
	
	for(i=0; i<count; i++)
		if(src[i]==' ') /* blank drin? */
		{
			memmove(dst,src,count);
			return(count);
		}
	for(i=count; i ; i++)
		if((src[i]==' ') || (src[i]=='\r'))
		{
			memmove(dst,src,i);
			return(i);
		}
}

/* Neuformatieren im RAM. Wiedereinketten */
static int read_ram(WINDOW *wp, char *buff, long bsize, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	register long k=0, count, count2;
	int blank, enough_ram=TRUE;
	register LINESTRUCT *line, *help1;
	char *cp,*save;

	if(wp)
	{
		save=buff;
		graf_mouse(BUSY_BEE,NULL);
		if((line=malloc(sizeof(LINESTRUCT)))!=NULL)
		{
			line->effect=0;
			(*begcut)=line;
			begline=begline=wp->row+wp->hfirst/wp->hscroll;  /* zeilen = 1 */
			line->prev=0L;
			while((enough_ram != -1) && (buff<(save+bsize)))
			{
/* 10.7.94
				memmove(iostring,buff,wp->umbruch+1);
				buff+=wp->umbruch+1;
				iostring[wp->umbruch+1]=0;
*/
			/* wenn count2 > wp->umbruch+1 kann der String nicht umbrochen werden */
				count2=mread(iostring,buff,wp->umbruch+1);
				buff+=count2;
				iostring[count2]=0;

				if(iostring[0]==' ')
					strcpy(iostring,&iostring[1]);
				if((cp=strchr(iostring,'\r'))!=NULL)
					*cp=0;
				count=strlen(iostring);

				if((count2<=wp->umbruch+1) && (count>wp->umbruch))
				{
					blank=findlastspace(iostring,wp->umbruch,wp->umbruch+1);
					if(blank>0)
					{
						buff-=(long)(wp->umbruch-blank); /* zurck positionieren */
						iostring[blank]=0;
						if(wp->w_state & BLOCKSATZ) /* evtl. Blocksatz formatieren */
						{
							blockformat(iostring, wp->umbruch-blank);
						}
					}
				}
				else
				{
					if(count2<=wp->umbruch+1)
						buff-=(long)(wp->umbruch-count);
					else
						buff++; /* Der String kann nicht umbrochen werden. */
						/* buff steht auf dem Trennblank. Ein Zeichen weiter. */
				}
				line->len=strlen(iostring);
				if((line->string=malloc(line->len + 1)) != NULL)
				{
					k++;
					line->used = line->len;
					strcpy(line->string,iostring);
					line->attr=0;	 /* zeilenmarkierung */
					help1=line;
					if((line->next=malloc(sizeof(LINESTRUCT))) != NULL)
					{
						line->effect = 0;
						line=line->next;
						line->prev=help1;
					}
					else
					{
						enough_ram=-1;
					}
				}
				else
				{
					enough_ram=-1;
				}
			}
			if((line->string=malloc(NBLOCKS+1))!=NULL)
			{
				line->string[0]=0;
				line->len=NBLOCKS;
				line->used=0;
				line->attr=0;
				line->effect=0;
				line->next=NULL;
				k++;
			}
			else
			{
				line=line->prev;
				free(line->next);
				line->next=0L;
			}
			(*endcut)=line;							 /* ende markieren */
			endline=begline + k;
		}
		else
			enough_ram=-1;
		graf_mouse(ARROW,NULL);
		return(enough_ram);
	}
	return(FALSE);
}

/* Neuformatieren auf Disk. Umkopieren */
static int _write_disk(WINDOW *wp, char *filename, LINESTRUCT *beg, LINESTRUCT *end)
{
	FILE *fp;
	register LINESTRUCT *line;
	int error;
	register char *cp;

	if((fp=fopen(filename,"w"))!=NULL)
	{
		graf_mouse(BUSY_BEE,0L);
		line=beg;
		do
		{
			if(line->used > 0)
			{
				while(line->string[--line->used] == ' ')
					line->string[line->used] = 0;
				line->used++;
			}
			/* mehrfache Blanks killen */
			while(line->string[0] == ' ')/*MT 24.7.94 fhrende Blanks raus */
			{
				strcpy(&line->string[0],&line->string[1]);
			}
			cp=strchr(line->string,' ');
			while(cp)
			{
				if(*(cp+1L) == ' ')
					strcpy(cp,cp+1L);
				cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
			}
			if(fputs(line->string,fp)==EOF)
			{
				form_alert(1,Aformat[0]);
				goto WEITER;
			}
			if(fputs(" ",fp)==EOF)
			{
				form_alert(1,Aformat[0]);
				goto WEITER;
			}
			line=line->next;
		}
		while(line != end->next);
WEITER:
		error=ferror(fp);
		fclose(fp);
		if(error)
			unlink(filename);
		graf_mouse(ARROW,0L);
		return(TRUE);
	}
	return(FALSE);
}

static int write_disk(WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut)
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
				form_alert(1,Aformat[1]);
				return(FALSE);
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
/*
		if(filename[strlen(filename)-1]!='\\')
			strcat(filename,"\\");
*/
		strcat(filename,"SCRAP.TXT");

		if(!_write_disk(wp, filename, begcut, endcut))
		{
			form_alert(1,Aformat[2]);
			return(FALSE);
		}
		inst_clipboard_icon(desktop,DESKICNB,DESKICNC,FALSE);
		return(TRUE);
	}
	return(FALSE);
}

/* Neuformatieren auf Disk. Wiedereinketten */
static int _read_disk(WINDOW *wp, char *filename, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	FILE *fp;
	register long k=0,filesize;
	int count, blank, enough_ram=TRUE;
	register LINESTRUCT *line, *help1;

	if((fp=fopen(filename,"r")) != NULL)
	{
		graf_mouse(BUSY_BEE,0L);
		filesize=filelength(fileno(fp));
		if(filesize==0)
		{
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			ins_line(wp);
			Wcursor(wp);
			graf_mouse(M_ON,0L);
		}
		else
		{
			if((line=malloc(sizeof(LINESTRUCT)))!=NULL)
			{
				line->effect=0;
				(*begcut)=line;
				begline=begline=wp->row+wp->hfirst/wp->hscroll;  /* zeilen = 1 */
				line->prev=0L;
				while((enough_ram != -1) && !feof(fp))
				{
					memset(iostring,0,wp->umbruch);
					count=fread(iostring,wp->umbruch+1,1,fp);
					if(iostring[0]==' ')
						strcpy(iostring,&iostring[1]);
					if(count>0)
					{
						blank=findlastspace(iostring,wp->umbruch,wp->umbruch+1);
						if(blank>0)
						{
							fseek(fp,-(long)(wp->umbruch-blank),SEEK_CUR); /* zurck positionieren */
							iostring[blank]=0;
							if(wp->w_state & BLOCKSATZ) /* evtl. Blocksatz formatieren */
							{
								blockformat(iostring, wp->umbruch-blank);
							}
						}
					}
					line->len=strlen(iostring);
					if((line->string=malloc(line->len + 1)) != NULL)
					{
						k++;
						line->used = line->len;
						strcpy(line->string,iostring);
						line->attr=0;	 /* zeilenmarkierung */
						help1=line;
						if((line->next=malloc(sizeof(LINESTRUCT))) != NULL)
						{
							line->effect=0;
							line=line->next;
							line->prev=help1;
						}
						else
						{
							enough_ram=-1;
						}
					}
					else
					{
						enough_ram=-1;
					}
				}
				if((line->string=malloc(NBLOCKS+1))!=NULL)
				{
					line->string[0]=0;
					line->len=NBLOCKS;
					line->used=0;
					line->attr=0;
					line->effect=0;
					line->next=NULL;
					k++;
				}
				else
				{
					line=line->prev;
					free(line->next);
					line->next=0L;
				}
				(*endcut)=line;							 /* ende markieren */
				endline=begline + k;
			}
			else
				enough_ram=-1;
		}
		fclose(fp);
		graf_mouse(ARROW,0L);
		return(enough_ram);
	}
	return(FALSE);
}

static void read_disk(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	char filename[PATH_MAX];

	if(wp)
	{
		scrp_read(filename);
		complete_path(filename);
/*
		if(filename[strlen(filename)-1] != '\\')
			strcat(filename,"\\");
*/
		strcat(filename,"SCRAP.TXT");

		switch(_read_disk(wp,filename,begcut,endcut))
		{
			case -1:
				form_alert(1,Aformat[3]);
			case TRUE:
				wp->w_state|=CHANGED;
				break;
			case FALSE:
				form_alert(1,Aformat[4]);
				break;
		}
		unlink(filename);
		inst_clipboard_icon(desktop,DESKICNB,DESKICNC,FALSE);
	}
}

static int badblock(WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut)
{					 /* wenn eine Leerzeile enthalten ist, warnen */
	LINESTRUCT *line;
	if(wp && begcut && endcut)
	{
		for(line=begcut; line && line!=endcut->next; line=line->next)
			if(line->used==0)
				return(TRUE);
	}
	return(FALSE);
}

void textformat(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int abcursor)
{
	long lines,chars;
	char *formbuff;
	LINESTRUCT *help;
	int ret,key_state,lastline=FALSE;

	if(wp && !cut && !*begcut && !*endcut)
	{
		if(wp->cstr->used)
		{
			if(!abcursor) /* 30.9.94 letzte Leerzeile vor dem Cursor suchen */
			{
				for(help=wp->cstr; help->prev; help=help->prev)
					if(!help->prev->used)
						break;
			}
			else /* bei Shift ab Cursor */
				help=wp->cstr;

			*begcut=help;
			for(help=wp->cstr; help->next; help=help->next)
				if(!help->next->used)
					break;
			*endcut=help;
			for(help=*begcut; help && help!=(*endcut)->next; help=help->next)
			{
				help->begcol=0;
				help->endcol=STRING_LENGTH;
				help->attr|=SELECTED;
			}
			mark_blk(wp,begcut,endcut);
			hndl_blkfind(wp,*begcut,*endcut,SEARBEG);
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
			begline=endline=wp->row+wp->hfirst/wp->hscroll;
			for(help=*begcut; help && help!=(*endcut)->next; help=help->next, endline++)
				;
			evnt_timer(25,0);
		}
	}
	if(wp && !cut && *begcut && *endcut)
	{
		if(((*begcut)==wp->fstr && (*endcut)->next==NULL) || badblock(wp,*begcut,*endcut))
			if(form_alert(2,Aformat[5])==1)
				return;

		graf_mouse(M_OFF,0L);
		Wcursor(wp);

		if(!(*endcut)->next)
			lastline=TRUE;

      free_undoblk(wp, undo.blkbeg);
		cut=cut_blk(wp,*begcut,*endcut);
      undo.flag=copy_blk(wp,*begcut,*endcut,&undo.blkbeg,&undo.blkend);

		if(lastline)
		{
			wp->cspos=wp->col=wp->cstr->used-wp->wfirst/wp->wscroll;
			ins_line(wp);
		}

		Wcuron(wp);
		Wcursor(wp);
		graf_mouse(M_ON,0L);

		(*begcut)->begcol=0;
		(*endcut)->endcol=STRING_LENGTH;
		Wblksize(wp,*begcut,*endcut,&lines,&chars);
		wp->umbruch--;/* Korrektur, arbeitet anders als beim Tippen */
		undo.item=FALSE;
#if GEMDOS
		if((formbuff=malloc(chars+lines+2))!=NULL)/* evtl. zus„tzliches Blank */
#else
		if((formbuff=farmalloc(chars+lines+2))!=NULL)/* evtl. zus„tzliches Blank */
#endif
		{
			*formbuff=0;
			write_ram(wp,formbuff,chars+lines+2,*begcut,*endcut);
			free_blk(wp,*begcut);
			if(read_ram(wp,formbuff,strlen(formbuff),begcut,endcut)<TRUE)
				form_alert(1,Aformat[6]);
         store_undo(wp, &undo, *begcut, *endcut, WINEDIT, CUTPAST);
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			paste_blk(wp,*begcut,*endcut);
			Wcursor(wp);
			graf_mouse(M_ON,0L);
#if GEMDOS
			free(formbuff);
#else
			farfree(formbuff);
#endif
		}
		else
		{
			if(write_disk(wp,*begcut,*endcut))
			{
				free_blk(wp,*begcut);
				read_disk(wp,begcut,endcut);
            store_undo(wp, &undo, *begcut, *endcut, WINEDIT, CUTPAST);
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				paste_blk(wp,*begcut,*endcut);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
			}
			else
				return;
		}
		wp->umbruch++;
		(*endcut)->endcol=0;
		hndl_blkfind(wp,*begcut,*endcut,SEAREND);
		(*endcut)->endcol=STRING_LENGTH;
		*begcut=*endcut=NULL;
		begline=endline=0;
		cut=FALSE;
	}
}

/* Textformatierung								*/
/*						  ^F9  = zentriert		*/
/*						  ^F10 = rechtsbndig	*/
void textformat2(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int key, int abcursor)
{
	LINESTRUCT *line;
	LINESTRUCT *help;
	char *temp, *cp;
	long i,y;
	int maxlen;
	static int gewarnt=FALSE;
	
	if(wp && !cut && !*begcut && !*endcut)
	{
		if(wp->cstr->used)
		{
			if(!abcursor) /* 30.9.94 letzte Leerzeile vor dem Cursor suchen */
			{
				for(help=wp->cstr; help->prev; help=help->prev)
					if(!help->prev->used)
						break;
			}
			else /* bei Shift ab Cursor */
				help=wp->cstr;

			*begcut=help;
			for(help=wp->cstr; help->next; help=help->next)
				if(!help->next->used)
					break;
			*endcut=help;
			for(help=*begcut; help && help!=(*endcut)->next; help=help->next)
			{
				help->begcol=0;
				help->endcol=STRING_LENGTH;
				help->attr|=SELECTED;
			}
			mark_blk(wp,begcut,endcut);
			hndl_blkfind(wp,*begcut,*endcut,SEARBEG);
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
			begline=endline=wp->row+wp->hfirst/wp->hscroll;
			for(help=*begcut; help && help!=(*endcut)->next; help=help->next, endline++)
				;
			evnt_timer(25,0);
		}
	}
	if(wp && !cut && *begcut && *endcut)
   {
		maxlen=0;
		for(line=(*begcut); line!=(*endcut)->next; line=line->next)
			maxlen=max(line->used,maxlen);
		if(maxlen >= wp->umbruch)
		{
			form_alert(1,Aformat[9]);
			return;
		}
		if((wp->umbruch > 90) && !gewarnt)/* das drfte wohl reichen (?) */
		{
			if(form_alert(1,Aformat[7])==1)
				return;
			gewarnt=TRUE;
		}
		if(TRUE)
		{
			for(line=(*begcut); line!=(*endcut)->next; line=line->next)
			{
				temp=line->string;
				line->string=realloc(line->string, wp->umbruch+1);
				if(!line->string)
				{
					line->string=temp;
					form_alert(1,Aformat[6]);
					return;
				}
				graf_mouse(BUSY_BEE,NULL);
				line->len=wp->umbruch;
				/* mehrfache Blanks killen */
				while(line->string[0] == ' ')/* fhrende Blanks raus */
				{
					strcpy(&line->string[0],&line->string[1]);
				}
				cp=strchr(line->string,' ');
				while(cp)
				{
					if(*(cp+1L) == ' ')
						strcpy(cp,cp+1L);
					cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
				}
				line->used=strlen(line->string);
			
				switch(key)
				{
					case FORMLEFT:
						break;
					case FORMCENTER:
						memmove(&line->string[(wp->umbruch-line->used)/2],
									line->string,
									line->used+1);
						memset(line->string,' ',(wp->umbruch-line->used)/2);
						break;
					case FORMRIGHT:
						memmove(&line->string[wp->umbruch-line->used],
									line->string,
									line->used+1);
						memset(line->string,' ',wp->umbruch-line->used);
						break;
				}
				line->used=strlen(line->string);
				
			}
			graf_mouse(M_OFF,NULL);
			for(i=0,line=wp->wstr,y=wp->ywork; line!=(*endcut)->next && y < (wp->ywork+wp->hwork); i++, line=line->next, y+=wp->hscroll)
				if(line->attr & SELECTED)
				{
					refresh(wp,line,0,i);
				}
			wp->w_state |= CHANGED;
			graf_mouse(ARROW,NULL);
		}
	}
}

void hndl_textformat(WINDOW *wp, OBJECT *tree, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	int exit_obj;
	unsigned int hilf;
	extern char alertstr[];
	
	if(wp)
	{
		if(*begcut && *endcut)
		{
			tree[FORMCURSOR].ob_state &= ~SELECTED;
			tree[FORMPARA  ].ob_state &= ~SELECTED;
			tree[FORMMARK  ].ob_state |=  SELECTED; /* gleich Block markieren */
		}
		else
		{
			if(tree[FORMMARK  ].ob_state &  SELECTED) /* ohne Block geht das nicht */
			{
				tree[FORMCURSOR].ob_state |=  SELECTED;
				tree[FORMPARA  ].ob_state &= ~SELECTED;
				tree[FORMMARK  ].ob_state &= ~SELECTED;
			}
		}
		
		sprintf(tree[FORMLENGHT].ob_spec.tedinfo->te_ptext,"%d",wp->umbruch-1);

		if(tree[FORMBLOCK ].ob_state & SELECTED)
			tree[FORMLENGHT].ob_flags |= EDITABLE;
		else
			tree[FORMLENGHT].ob_flags &= ~EDITABLE;
		
		
		form_exopen(tree,FALSE);
		do
		{
			exit_obj=form_exdo(tree,0);
			switch(exit_obj)
			{
				case FORMLEFT:
				case FORMCENTER:
				case FORMRIGHT:
					tree[FORMLENGHT].ob_flags &= ~EDITABLE;
					objc_update(tree,FORMLENGHT,0);
					break;

				case FORMBLOCK:
					tree[FORMLENGHT].ob_flags |= EDITABLE;
					objc_update(tree,FORMLENGHT,0);
					break;
				
				case FORMHELP:
					form_alert(1,Aformat[8]);
					objc_change(tree,exit_obj,0,
						tree->ob_x,tree->ob_y,
						tree->ob_width,tree->ob_height,
						tree[exit_obj].ob_state&~SELECTED,TRUE);
					break;
			}
		}
		while(exit_obj!=FORMOK && exit_obj!=FORMABBR);
		form_exclose(tree,exit_obj,FALSE);
	
		wp->umbruch=atoi(form_read(tree,FORMLENGHT,alertstr))+1;
		if(wp->umbruch<2)
			wp->umbruch=2;
		if(wp->umbruch>STRING_LENGTH)
			wp->umbruch=STRING_LENGTH;
	
		if(exit_obj == FORMOK)
		{
			if(tree[FORMLEFT  ].ob_state & SELECTED)
		   	textformat2(wp,begcut,endcut, FORMLEFT, tree[FORMCURSOR ].ob_state & SELECTED);

			/*dies ist die alte Methode*/
			if(tree[FORMBLOCK ].ob_state & SELECTED)
			{
				hilf = wp->w_state;
				wp->w_state |= BLOCKSATZ;
				textformat (wp, begcut, endcut, tree[FORMCURSOR ].ob_state & SELECTED);
				wp->w_state = hilf;
			}

			if(tree[FORMCENTER].ob_state & SELECTED)
				textformat2(wp, begcut, endcut, FORMCENTER, tree[FORMCURSOR ].ob_state & SELECTED);
			if(tree[FORMRIGHT ].ob_state & SELECTED)
				textformat2(wp, begcut, endcut, FORMRIGHT, tree[FORMCURSOR ].ob_state & SELECTED);
	   }
   }
}
