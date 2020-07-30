/*****************************************************************************
*
*											  7UP
*										Modul: MARKBLK.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
/**************************************************************************
						  Auen Scrollbereich, innen Fenster.
							  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							  ³  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³
							  ³  ³							³  ³
							  ³  ³		 ÚÄÄÂÄÄÄÄÄÄÄÄÄÄ´  ³
                       ³  ÃÄÄÄÄÄÄÄ´  ³          ³  ³
							  ³  ³		 ³  ÃÄÄÄÄÄÄÄÄÄÄ´  ³
                       ³  ÃÄÄÄÄÄÄÄÁÄÄÙ          ³  ³
							  ³  ³							³  ³
							  ³  ³							³  ³
							  ³  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ³
							  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    So markiert 7UP den Block. Drei Teile.
             Das hat mehrere Wochen Nerven gekostet, bis es lief :-(
**************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
/*
#include <vdi.h>
*/
#include "7up.h"
#include "windows.h"
#include "undo.h"

#define HORIZ_OFFSET 5
#define HALFPAGE	  (wp->hwork/wp->hscroll/2)

void hide_blk(WINDOW *wp,LINESTRUCT *begcut, LINESTRUCT *endcut);
void free_blk(WINDOW *wp,LINESTRUCT *begcut);
void mark_line(WINDOW *wp, LINESTRUCT *str, int i);
int isgerman(char key);

extern LINESTRUCT *lastwstr;
extern long		  lasthfirst,begline, endline;
extern int cut;
extern int vdihandle,xdesk,ydesk,wdesk,hdesk;
extern char searchstring[];

static int findword(char *string, int x, int *beg, int *end)
{
	register int i,k;
	k=strlen(string);
	*beg=0;
	*end=k;/*STRING_LENGTH;*/

	if( ! (!isspace(string[x]) && (isalnum(string[x]) || isgerman(string[x]))))
		return(FALSE);
	for(i=x; i<k; i++)
		if( ! (!isspace(string[i]) && (isalnum(string[i]) || isgerman(string[i]))))
		{
			*end=i;
			break;
		}
	for(i=x; i>=0; i--)
		if( ! (!isspace(string[i]) && (isalnum(string[i]) || isgerman(string[i]))))
		{
			*beg=i+1;
			break;
		}
	if((*end - *beg) > 0)
		return(TRUE);
	else
		return(FALSE);
}

int Wdclickword(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int mx, int my)
{
	register int i,x,y;
	register long line;
	register LINESTRUCT *help;
	int beg,end,ret,nx,ny;
	if(wp)
	{
		if(cut)					/* gibt es erst noch mll zu l”schen */
			free_blk(wp,*begcut);
		else
			hide_blk(wp,*begcut,*endcut);

		if(mx>wp->xwork && mx<wp->xwork+wp->wwork-1 &&
			my>wp->ywork && my<wp->ywork+wp->hwork-1)
		{
			graf_mkstate(&nx,&ny,&ret,&ret);
			x=(mx-wp->xwork)/wp->wscroll;
			y=(my-wp->ywork)/wp->hscroll;
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
			begline=y+wp->hfirst/wp->hscroll;
			endline=begline;
			if(begline<wp->hsize/wp->hscroll)
			{
				for(help=wp->wstr, i=0; help && i<=y; help=help->next, i++)
					*begcut=*endcut=help;
				if(findword((*begcut)->string,(int)(x+wp->wfirst/wp->wscroll),&beg,&end))
				{
					(*begcut)->begcol=(*endcut)->begcol=beg;
					(*begcut)->endcol=(*endcut)->endcol=end;
					(*begcut)->attr=((*endcut)->attr|=SELECTED);
					graf_mouse(M_OFF,0L);
					Wcursor(wp);
					mark_line(wp,*begcut,y);
					wp->cstr=*begcut;
					wp->cspos=wp->col=end-wp->wfirst/wp->wscroll;
					wp->row=y;
					Wcuroff(wp);
					Wcursor(wp);
					graf_mouse(M_ON,0L);
					strncpy(searchstring,&(*begcut)->string[beg],end-beg);
					searchstring[end-beg]=0;
					undo.item=FALSE;
/*
printf("\33H%ld %ld",begline,endline);
*/
               /* 28.02.94 */
					if((*begcut)->begcol==0 && (*begcut)->endcol==wp->cstr->used)
						endline++; /* ganze Zeile */

					return(TRUE);
				}
			}
		}
	}
	endline=begline=0L;
	*begcut=*endcut=NULL;
	*searchstring=0;
	return(FALSE);
}

void mark_blk(WINDOW *wp,LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	LINESTRUCT *help;
	register int i,y;

	graf_mouse(M_OFF,0L);
	Wcursor(wp);
	for(help=wp->wstr,i=0,y=wp->ywork;
		 help && y<(wp->ywork+wp->hwork-1);
		 help=help->next, i++, y+=wp->hscroll)
	{
		if(help->attr & SELECTED)
			mark_line(wp,help,i);
	}
	Wcuroff(wp);
	Wcursor(wp);
	graf_mouse(M_ON,0L);
}

static int find_backward(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, char a, char b)
{
	LINESTRUCT *help;
	register int save,klammer=0;
	register long i;

	save=(*endcut)->endcol;
	i=(*endcut)->endcol-1;
	for(help=*endcut; help->prev; help=help->prev, i=help->used-1, begline--)
	{
		for(i; i>=0; i--)
		{
			if(help->string[i]==a)
			{
				klammer++;
			}
			if(help->string[i]==b)
			{
				klammer--;
				if(klammer==0)
				{
					*begcut=lastwstr=help;
					for(help=*begcut; help && help!=(*endcut)->next; help=help->next)
					{
						help->begcol=0;
						help->endcol=STRING_LENGTH;
						help->attr|=SELECTED;
					}
					(*begcut)->endcol=STRING_LENGTH;
					(*endcut)->begcol=0;
					(*endcut)->endcol=save;
					(*begcut)->begcol=i;
					mark_blk(wp,begcut,endcut);
					hndl_blkfind(wp,*begcut,*endcut,SEARBEG);
					lastwstr=wp->wstr;
					lasthfirst=wp->hfirst;
            	undo.item=FALSE;
					return(TRUE);
				}
			}
		}
	}
	return(FALSE);
}

static int find_forward(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, char a, char b)
{
	LINESTRUCT *help;
	register int i,save,klammer=0;

	save=i=(*begcut)->begcol;
	for(help=*begcut; help; help=help->next, i=0, endline++)
	{
		for(i; i<help->used; i++)
		{
			if(help->string[i]==a)
			{
				klammer++;
			}
			if(help->string[i]==b)
			{
				klammer--;
				if(klammer==0)
				{
					*endcut=help;
					for(help=*begcut; help!=(*endcut)->next; help=help->next)
					{
						help->begcol=0;
						help->endcol=STRING_LENGTH;
						help->attr|=SELECTED;
					}
					(*begcut)->endcol=STRING_LENGTH;
					(*endcut)->begcol=0;
					(*begcut)->begcol=save;
					(*endcut)->endcol=i+1;
					mark_blk(wp,begcut,endcut);
					hndl_blkfind(wp,*begcut,*endcut,SEAREND);
             	undo.item=FALSE;
					return(TRUE);
				}
			}
		}
	}
	return(FALSE);
}

int Wdclickbrace(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int mx, int my)
{
	register long i;
	int y,found=0,ret,key_state,klammer=0;
	register LINESTRUCT *line,*help;
	unsigned char c;

	if(wp)
	{
		if(cut)					/* gibt es erst noch mll zu l”schen */
			free_blk(wp,*begcut);
		else
			hide_blk(wp,*begcut,*endcut);

		if(mx>wp->xwork && mx<wp->xwork+wp->wwork-1 &&
			my>wp->ywork && my<wp->ywork+wp->hwork-1)
		{
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;

			y=(my-wp->ywork)/wp->hscroll;
			if(y>=wp->hsize/wp->hscroll)/* wenn unterhalb der letzten Zeile angesetzt */
				return(FALSE);

			begline=endline=y+wp->hfirst/wp->hscroll;

			for(i=0, help=wp->wstr; i<y && help; i++, help=help->next)
			  ;
			*begcut=*endcut=help;

			/* Zeichen unter Maus suchen */
			c=help->string[(mx-wp->xwork)/wp->wscroll+wp->wfirst/wp->wscroll];
			if((mx-wp->xwork)/wp->wscroll+wp->wfirst/wp->wscroll >= help->used)
				c=0; /* hinter dem Stringende */

			(*begcut)->begcol=(mx-wp->xwork)/wp->wscroll+wp->wfirst/wp->wscroll;
			(*endcut)->endcol=(*begcut)->begcol+1;

			switch(c)
			{
				case '(':
					if(find_forward(wp,begcut,endcut,c,')'))
					{
						return(TRUE);
					}
					break;
				case '{':
					if(find_forward(wp,begcut,endcut,c,'}'))
					{
						return(TRUE);
					}
					break;
				case '[':
					if(find_forward(wp,begcut,endcut,c,']'))
					{
						return(TRUE);
					}
					break;
				case '<':
					if(find_forward(wp,begcut,endcut,c,'>'))
					{
						return(TRUE);
					}
					break;
				case ')':
					if(find_backward(wp,begcut,endcut,c,'('))
					{
						return(TRUE);
					}
					break;
				case '}':
					if(find_backward(wp,begcut,endcut,c,'{'))
					{
						return(TRUE);
					}
					break;
				case ']':
					if(find_backward(wp,begcut,endcut,c,'['))
					{
						return(TRUE);
					}
					break;
				case '>':
					if(find_backward(wp,begcut,endcut,c,'<'))
					{
						return(TRUE);
					}
					break;
				default:
					for(line=help; line; line=line->prev, begline--)
					{
						if(strchr(line->string,'}'))
						{
							klammer++;
							continue;  /* weiter mit for */
						}
						if(strchr(line->string,'{'))
						{
							klammer--;
							if(klammer==-1)
							{
								*begcut=lastwstr=line;
								found++;
								break;
							}
						}
					}
					klammer=0;
					for(line=help->next; line; line=line->next, endline++)
					{
						if(strchr(line->string,'{'))
						{
							klammer++;
							continue;  /* weiter mit for */
						}
						if(strchr(line->string,'}'))
						{
							klammer--;
							if(klammer==-1)
							{
								*endcut=line;
								found++;
								break;
							}
						}
					}
					graf_mkstate(&ret, &ret, &ret, &key_state);
					if(found==2 && (key_state & K_CTRL))
					{
						(*begcut)=(*begcut)->next;
						begline++;
						(*endcut)=(*endcut)->prev;
						endline--;
						if(endline<begline)
							found=0;
					}
					if(found==2)
					{
						for(help=*begcut; help!=(*endcut)->next; help=help->next)
						{
							help->begcol=0;
							help->endcol=STRING_LENGTH;
							help->attr|=SELECTED;
						}
						mark_blk(wp,begcut,endcut);

						/* BEGLINE und LASTHFIRST setzen */
						for(help=wp->fstr, i=0;
							 help && help!=wp->wstr;
							 help=help->next, i++)
							if(help==*begcut)
							{
								lastwstr=help;
								lasthfirst=i*wp->hscroll;
								begline=i;
							}
               	undo.item=FALSE;
						return(TRUE);
					}
					break;
			}
		}
	}
	endline=begline=0L;
	*begcut=*endcut=NULL;
	*searchstring=0;
	return(FALSE);
}

int Wdclickline(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int mx, int my)
{
	register int i,x,y;
	register long line;
	register LINESTRUCT *help;
	if(wp)
	{
		if(cut)					/* gibt es erst noch mll zu l”schen */
			free_blk(wp,*begcut);
		else
			hide_blk(wp,*begcut,*endcut);

		if(mx>wp->xwork && mx<wp->xwork+wp->wwork-1 &&
			my>wp->ywork && my<wp->ywork+wp->hwork-1)
		{
			x=(mx-wp->xwork)/wp->wscroll;
			y=(my-wp->ywork)/wp->hscroll;
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
			begline=y+wp->hfirst/wp->hscroll;
			endline=begline+1;
			if(begline<wp->hsize/wp->hscroll)
			{
				for(help=wp->wstr, i=0; help && i<=y; help=help->next, i++)
					*begcut=*endcut=help;
				(*begcut)->begcol=(*endcut)->begcol=0;
				if(wp->w_state & COLUMN)
					(*begcut)->endcol=(*endcut)->endcol=(*begcut)->used;
				else
					(*begcut)->endcol=(*endcut)->endcol=STRING_LENGTH;
				(*begcut)->attr=((*endcut)->attr|=SELECTED);
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				mark_line(wp,*begcut,y);
				wp->cstr=*begcut;
				wp->cspos=wp->col=x;
				wp->row=y;
				Wcuroff(wp);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				undo.item=FALSE;
				return(TRUE);
			}
		}
	}
	endline=begline=0L;
	*begcut=*endcut=NULL;
	*searchstring=0;
	return(FALSE);
}

int find_end_of_word(char *str, int x, int len)
{
	register int i;

	for(i=x; i<len; i++)
	{
		if(!inw(str[i]) && (inw(str[i+1]) || str[i+1]==0))
			return(i+1);
	}
	return(len);
}

int find_beg_of_word(char *str, int x, int len)
{
	register int i;

	for(i=x; i>0; i--)
	{
		if(!inw(str[i]) && inw(str[i-1]))
			return(i);
	}
	return(0);
}

static void blackbox(WINDOW *wp, int rect[], int cw)
{
	int area[4],full[4],pxyarray[4];

	if(rect[2]>=cw)
	{
		graf_mouse(M_OFF,0L);
		wind_update(BEG_UPDATE);
		_wind_get(0, WF_WORKXYWH, &full[0], &full[1], &full[2], &full[3]);
		_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
		while( area[2] && area[3] )
		{
			if(rc_intersect(full,area))
			{
				if(rc_intersect(rect,area))
				{
					if(rc_intersect(&wp->xwork,area)) /* 26.5.94 wg. Toolbar */
					{
						pxyarray[0]=area[0];
						pxyarray[1]=area[1];
						pxyarray[2]=area[0]+area[2]-1;
						pxyarray[3]=area[1]+area[3]-1;
						vs_clip(vdihandle,TRUE,pxyarray);
						vr_recfl(vdihandle,pxyarray);		/* markieren */
					}
				}
			}
			_wind_get(wp->wihandle, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
		}
		wind_update(END_UPDATE);
/*
		vs_clip(vdihandle,FALSE,pxyarray);
*/
		graf_mouse(M_ON,0L);
	}
}

void swap(int *a, int *b)
{
	int hilf;
	hilf=*a;
	*a  =*b;
	*b  =hilf;
}
/*
Wenn Shifttaste gedrckt, markierten Block nicht l”schen. Falls Block
schon gecutet ist, Puffer l”schen. Erweitern ist dann auch nicht m”glich.
Erweiterung des Blocks bei gedrckter Shifttaste.
*/
int _Wmarkblock(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int e_mx, int e_my, int clicks, int key_state)
{
	int ret,fx,fy,x,y,x2,oldx,oldy,pxyarray[4];
	int mx,my,mouse_click,wordmark=FALSE,linemark=FALSE;
	int bbcsave,becsave,ebcsave,eecsave;
	register LINESTRUCT *line,*help;
	int xout,yout,wout,hout;
	long i,y2,temp;

	if(wp)
	{
		switch(clicks) /* Klicken z„hlen */
		{
			case 1:
				break;
			case 2:
				wordmark=TRUE;
				break;
			case 3:
				linemark=TRUE;
				break;
		}
		if(key_state & K_CTRL && !(key_state & K_ALT))
			wordmark=TRUE;
		if(key_state & K_ALT && !(key_state & K_CTRL))
			linemark=TRUE;

		if((clicks>1)||
			!(!cut && *begcut && *endcut && (key_state & (K_RSHIFT|K_LSHIFT))))
		{  /* es liegt keine Blockerweiterung vor per Shifttaste vor */
			graf_mkstate(&mx, &my, &mouse_click, &ret);
			if(!mouse_click)
				return(FALSE);
			for(i=0; i<4; i++)
			{
				evnt_timer(25,0);  /* 4 x 25ms warten */
				graf_mkstate(&mx, &my, &mouse_click, &ret);
				if(!mouse_click)
					return(FALSE);
			}
		}
						  /* bei gedrckter Shifttaste Block erweitern */
		if(!cut && !(key_state & (K_RSHIFT|K_LSHIFT)))
			hide_blk(wp,*begcut,*endcut);
		if(cut)					/* gibt es erst noch mll zu l”schen */
			free_blk(wp,*begcut);

		wind_calc(WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&xout,&yout,&wout,&hout);

		mx=e_mx;
		my=e_my;

		if(!(mx >= wp->xwork && mx <= (wp->xwork + wp->wwork - 1) &&
			my >= wp->ywork && my <= (wp->ywork + wp->hwork - 1)))
		{
			return(FALSE);
		}

		x=(mx-wp->xwork)/wp->wscroll;
		if(((mx-wp->xwork)%wp->wscroll) >= wp->wscroll/2)
			x++;
		fx=oldx=x;
		fy=oldy=y=(my-wp->ywork)/wp->hscroll;

		if(y>=wp->hsize/wp->hscroll)/* wenn unterhalb der letzten Zeile angesetzt */
		{
			return(FALSE);
		}

		for(i=0, line=wp->wstr; i<y && line; i++, line=line->next)
		  ;

		lastwstr=wp->wstr;
		lasthfirst=wp->hfirst;
		wind_update(BEG_MCTRL);
		if(!(wp->w_state&COLUMN))
		{
			oldx=x=min(x,line->used-wp->wfirst/wp->wscroll);
/*
			if(x>line->used-wp->wfirst/wp->wscroll)
				oldx=x=line->used-wp->wfirst/wp->wscroll;
*/
			y2=(my-wp->ywork)/wp->hscroll+wp->hfirst/wp->hscroll;
			if(!cut && *begcut && *endcut && (key_state & (K_RSHIFT|K_LSHIFT)))
			{
				if((y2 > (begline+(endline-begline)/2)) ||
					((y2 == (begline+(endline-begline)/2)) && x>((*begcut)->begcol-wp->wfirst/wp->wscroll)))
				{  /* bereits vorhandenen Block nach unten erweitern */
					lastwstr=(*begcut);
					lasthfirst=begline*wp->hscroll;
					(*begcut)->endcol=STRING_LENGTH;
					for(help=(*begcut)->next; help && help!=line->next; help=help->next)
					{
						help->attr|=SELECTED;
						help->begcol=0;
						help->endcol=STRING_LENGTH;
					}
					for(help=line->next; help; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					bbcsave=(*begcut)->begcol;	/* erste spalte */
					becsave=line->endcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					pxyarray[0]=wp->xwork;
					pxyarray[1]=wp->ywork+(min(y2,endline)*wp->hscroll)-wp->hfirst;
					pxyarray[2]=wp->wwork;
					pxyarray[3]=(abs(y2-endline)+1)*wp->hscroll;
				}
				else
				{  /* bereits vorhandenen Block nach oben erweitern */
					lastwstr=wp->wstr;
					lasthfirst=wp->hfirst;
					bbcsave=becsave=(*endcut)->endcol;
					becsave++;
					*begcut=*endcut;
					(*begcut)->begcol=0;
					(*begcut)->endcol=bbcsave;
					*endcut=line;
					(*endcut)->begcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					(*endcut)->endcol=STRING_LENGTH;
					temp=begline;
					begline=endline;
					for(help=wp->fstr; help && help!=line; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					for(help=(*endcut); help && help!=(*begcut); help=help->next)
					{
						help->attr|=SELECTED;
						help->begcol=0;
						help->endcol=STRING_LENGTH;
					}
					for(help=(*begcut)->next; help; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					(*endcut)->begcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					(*begcut)->endcol=bbcsave;
					pxyarray[0]=wp->xwork;
					pxyarray[1]=wp->ywork+(min(y2,temp)*wp->hscroll)-wp->hfirst;
					pxyarray[2]=wp->wwork;
					pxyarray[3]=(abs(y2-temp)+1)*wp->hscroll;
				}
				if(wordmark)  /* wortweise markieren */
				{
					if(y+wp->hfirst/wp->hscroll>begline)
					{
						becsave=line->endcol=find_end_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						oldx=x=line->endcol-wp->wfirst/wp->wscroll;
						goto WEITER3;
					}
					if(y+wp->hfirst/wp->hscroll==begline && x>bbcsave)
					{
						becsave=line->endcol=find_end_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						oldx=x=line->endcol-wp->wfirst/wp->wscroll;
						goto WEITER3;
					}
					if(y+wp->hfirst/wp->hscroll==begline && x<bbcsave)
					{
						line->begcol=find_beg_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						oldx=x=line->begcol-wp->wfirst/wp->wscroll;
						goto WEITER3;
					}
					if(y+wp->hfirst/wp->hscroll<begline)
					{
						line->begcol=find_beg_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						oldx=x=line->begcol-wp->wfirst/wp->wscroll;
					}
WEITER3:		 ;
				}
				if(linemark)  /* zeilenweise markieren */
				{
					if(y+wp->hfirst/wp->hscroll<begline)
					{
						oldx=x=0;
						line->begcol=0;
						line->endcol=STRING_LENGTH;
						goto WEITER4;
					}
					if(y+wp->hfirst/wp->hscroll==begline)
					{
						line->begcol=bbcsave=0;
						line->endcol=oldx=x=STRING_LENGTH;
						goto WEITER4;
					}
					if(y+wp->hfirst/wp->hscroll>begline)
					{
						line->begcol=0;
						line->endcol=oldx=x=STRING_LENGTH;
					}
WEITER4:		 ;
				}
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				Wredraw(wp,pxyarray);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
			}
			else
			{
				if(!cut)
					hide_blk(wp,*begcut,*endcut);
				line->attr|=SELECTED; /* nochmal */
				bbcsave=line->begcol=(int)(x+wp->wfirst/wp->wscroll);	/* erste spalte */
				becsave=line->endcol=(int)(x+wp->wfirst/wp->wscroll+1);
				*begcut=line;									 /* blk beginn */
				begline=y+wp->hfirst/wp->hscroll;		  /* erste zeile */
			}
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			graf_mouse(M_ON,0L);
			graf_mouse(TEXT_CRSR,NULL);

			if(wordmark)
			{
				if(!(key_state & (K_RSHIFT|K_LSHIFT)))
				{
					bbcsave=find_beg_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
					(*begcut)->begcol=line->begcol=bbcsave;
					oldx=x=bbcsave-wp->wfirst/wp->wscroll;
				}
			}
			if(linemark)
			{
				if(!(key_state & (K_RSHIFT|K_LSHIFT)))
				{
					bbcsave=0;
					(*begcut)->begcol=line->begcol=bbcsave;
					oldx=x=bbcsave-wp->wfirst/wp->wscroll;
				}
			}

			do
			{
				x=(mx - wp->xwork) / wp->wscroll;
				if(((mx-wp->xwork)%wp->wscroll) >= wp->wscroll/2)
					x++;
				y=(my - wp->ywork) / wp->hscroll;

				x=min(x,line->used-wp->wfirst/wp->wscroll);
				x=max(0,x);
				y=max(0,y);
				x=min(x,wp->wwork/wp->wscroll-1);
				y=min(y,wp->hwork/wp->hscroll-1);
				y=min(y,wp->hsize/wp->hscroll-1);

				if(y < oldy)
				{
					for(i=y; i<oldy; i++)
					{
						if(line->prev)
						{
							if(line==*begcut)				  /* Blockbeginn */
							{
								line->begcol=0;
								line->endcol=bbcsave;
								line=line->prev;
								line->attr|=SELECTED;
								line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
								line->endcol=STRING_LENGTH;
							}
							else
							{
								if(line->prev->attr & SELECTED)	/* hinter Bb zurck */
								{
									line->attr&=~SELECTED;
									line=line->prev;
									if(line==*begcut)		 /* jetzt am Bb */
									{
										line->begcol=bbcsave;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										if(line->begcol>line->endcol)
											swap(&line->begcol,&line->endcol);
									}
									else
									{
										line->begcol=0;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
									}
								}
								else							  /* vor Bb zurck */
								{
									line->begcol=0;
									line->endcol=STRING_LENGTH;
									line=line->prev;
									line->attr|=SELECTED;
									line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
									line->endcol=STRING_LENGTH;
								}
							}
						}
					}
				}
				if(y > oldy)
				{
					for(i=oldy; i<y; i++)
					{
						if(line->next)
						{
							if(line==*begcut) /* Blockbeginn */
							{
								line->begcol=bbcsave;
								line->endcol=STRING_LENGTH;
								line=line->next;
								line->attr|=SELECTED;
								line->begcol=0;
								line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
							}
							else
							{
								if(line->next->attr & SELECTED)  /* vor Blockbeginn */
								{
									line->attr&=~SELECTED;
									line=line->next;
									if(line==*begcut)		/* jetzt am Bb */
									{
										line->begcol=bbcsave;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										if(line->begcol>line->endcol)
											swap(&line->begcol,&line->endcol);
									}
									else						 /* immer noch vor Bb */
									{
										line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										line->endcol=STRING_LENGTH;
									}
								}
								else							 /* nach Blockbeginn */
								{
									line->begcol=0;
									line->endcol=STRING_LENGTH;
									line=line->next;
									line->attr|=SELECTED;
									line->begcol=0;
									line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
								}
							}
						}
					}
				}
				if(wordmark && x!=oldx)  /* wortweise markieren */
				{
					if(y+wp->hfirst/wp->hscroll>begline)
					{
						line->endcol=find_end_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						x=line->endcol-wp->wfirst/wp->wscroll;
						goto WEITER;
					}
					if(y+wp->hfirst/wp->hscroll==begline && x>bbcsave)
					{
						line->endcol=find_end_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						x=line->endcol-wp->wfirst/wp->wscroll;
						goto WEITER;
					}
					if(y+wp->hfirst/wp->hscroll==begline && x<bbcsave)
					{
						line->begcol=find_beg_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						x=line->begcol-wp->wfirst/wp->wscroll;
						goto WEITER;
					}
					if(y+wp->hfirst/wp->hscroll<begline)
					{
						line->begcol=find_beg_of_word(line->string,(int)(x+(int)(wp->wfirst/wp->wscroll)), line->used);
						x=line->begcol-wp->wfirst/wp->wscroll;
					}
WEITER:		  ;
				}
				if(linemark)  /* zeilenweise markieren */
				{
					if(y+wp->hfirst/wp->hscroll<begline)
					{
						x=0;
						line->begcol=0;
						line->endcol=0;
						goto WEITER2;
					}
					if(y+wp->hfirst/wp->hscroll>=begline)
					{
						line->begcol=0;
						line->endcol=x=STRING_LENGTH;
					}
WEITER2:		 ;
				}
				if(y < oldy)
				{
					if(x>=oldx)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(oldy - y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=oldx * wp->wscroll;
						pxyarray[3]=abs(oldy- y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else /* kleiner */
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(oldy - y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=x * wp->wscroll;
						pxyarray[3]=abs(oldy- y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(y > oldy)
				{
					if(x >= oldx)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (oldy + 1) * wp->hscroll;
						pxyarray[2]=oldx * wp->wscroll;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else /* kleiner */
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (oldy + 1) * wp->hscroll;
						pxyarray[2]=x * wp->wscroll;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(x > oldx)
				{
					if(y>=oldy)
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)+1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)-1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(x < oldx)
				{
					if(y==oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=abs(oldx - x) * wp->wscroll;
						pxyarray[3]=wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					if(y>oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + (oldy+1) * wp->hscroll;
						pxyarray[2]=abs(oldx - x) * wp->wscroll;
						pxyarray[3]=(abs(oldy - y)-1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					if(y<oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)+1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				oldx=x;
				oldy=y;
				graf_mkstate(&mx, &my, &mouse_click, &key_state);
				if(my < wp->ywork)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_UPLINE))
					{
						oldy++;
					}
					if(my>yout)					/* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					else
						if(mouse_click & 2) /* bei rechter Taste 2x */
							for(i=0; i<HALFPAGE; i++)
								if(Warrow(wp,WA_UPLINE))
								{
									oldy++;
								}
					graf_mouse(M_ON,0L);
				}
				if(my > (wp->ywork + wp->hwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_DNLINE))
					{
						oldy--;
					}
					if(my<(yout+hout-2))		  /* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					else
						if(mouse_click & 2) /* bei rechter Taste 2x */
							for(i=0; i<HALFPAGE; i++)
								if(Warrow(wp,WA_DNLINE))
								{
									oldy--;
								}
					graf_mouse(M_ON,0L);
				}
				if(wp->wfirst!=0 && mx < wp->xwork+1)
				{
					if(mx>xout)					/* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_LFLINE))
					{
						oldx+=HORIZ_OFFSET;
					}
					graf_mouse(M_ON,0L);
				}
				if(mx > (wp->xwork + wp->wwork))
				{
					if(mx<(xout+wout))		  /* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_RTLINE))
					{
						oldx-=HORIZ_OFFSET;
					}
					graf_mouse(M_ON,0L);
				}
				endline=oldy+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */
				wp->row=oldy;
				wp->col=oldx;
				wp->cstr=line;
				Wsetrcinfo(wp);
			}
			while(mouse_click);
			evnt_button(1,1,0,&i,&i,&i,&i);

			for(i=0, line=wp->wstr; i<oldy && line; i++, line=line->next)
			  ;
			endline=i+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */

			ebcsave=line->begcol=0;
			(*begcut)->begcol=bbcsave;
			eecsave=line->endcol=(int)(oldx+wp->wfirst/wp->wscroll); /* letzte spalte */
			*endcut=line;								  /* ende markieren */

			if(begline > endline)						/* vertauschen */
			{
/* Das fehlte hier!!! Erik Dick */
				 lastwstr=wp->wstr;
				 lasthfirst=wp->hfirst;

				 line=*endcut;
				 *endcut=*begcut;
				 *begcut=line;
  				 wp->cstr=*begcut;

				 i=endline;
				 endline=begline;
				 begline=i;

				 (*begcut)->begcol=eecsave;
				 (*begcut)->endcol=becsave;
				 (*endcut)->begcol=ebcsave;
				 (*endcut)->endcol=bbcsave;
			}
			if(*begcut != *endcut && begline < endline)
			{
				(*begcut)->endcol=STRING_LENGTH;  /* Fehlerkorrektur */
			}
			if(begline==endline)
			{
				if( (*begcut)->begcol > (*begcut)->endcol )
				{  /* vertauschen, wenn von links nach rechts gezogen !!! */
					(*begcut)->begcol=(*endcut)->begcol=eecsave;
					(*begcut)->endcol=(*endcut)->endcol=becsave-1;
				}
			}
			if((*endcut)->endcol==0)  /* wenn spalte=0, endcut zurcksetzen... */
			{
				if(*endcut != *begcut)  /* ...wenn endcut > begcut					*/
				{
					*endcut=(*endcut)->prev;
					if(*begcut != *endcut)
						(*endcut)->begcol=0;
					(*endcut)->endcol=STRING_LENGTH;
					endline--;
				}
			}
			if((*begcut)->begcol==0 && (*endcut)->endcol>=(*endcut)->used)
			{
				endline++;
			}
			if( (*begcut)->begcol < (*begcut)->endcol &&
				 (*endcut)->begcol < (*endcut)->endcol	 )
			{
				for(line=wp->fstr; line != *begcut; line=line->next)
				{
					line->attr&=~SELECTED;		  /* attribut l”schen */
				}
				for(line=*begcut; line != (*endcut)->next; line=line->next)
				{
					line->attr|=SELECTED;		  /* attribut setzen */
				}
				for(line=(*endcut)->next; line; line=line->next)
				{
					line->attr&=~SELECTED;		  /* attribut l”schen */
				}
				if(*begcut != *endcut) /* mehr als eine zeile */
				{
					(*begcut)->endcol=STRING_LENGTH;
					(*endcut)->begcol=0;
					for(line=(*begcut)->next; line && line != *endcut; line=line->next)
					{
						line->begcol=0;
						line->endcol=STRING_LENGTH;
					}
				}
				Wcuroff(wp);
				graf_mouse(ARROW,0L);
				graf_mouse(M_OFF,0L);
/*
				wp->cstr=*endcut;
*/
				wp->cspos=wp->col=oldx;
				wp->row=oldy;
				Wcuroff(wp);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				wind_update(END_MCTRL);
				undo.item=FALSE;
/*
printf("\33H*%d %d %d %d %ld %ld*",x,oldx,y,oldy,begline,endline);
*/
/*
printf("\33H%ld %ld",begline,endline);
*/
				return(TRUE);	/* entspricht beg_blk() + end_blk() */
			}
		}
		else /* Spaltenblockmarkierung */
		{
			x2=(mx-wp->xwork)/wp->wscroll+wp->wfirst/wp->wscroll;
			y2=(my-wp->ywork)/wp->hscroll+wp->hfirst/wp->hscroll;

			if(!cut && *begcut && *endcut &&
				(int)(fx+wp->wfirst/wp->wscroll)>(*begcut)->begcol &&
				y2>begline &&
				(key_state & (K_RSHIFT|K_LSHIFT)))
			{								 /* bereits vorhandenen Block erweitern */
				lastwstr=(*begcut);
				lasthfirst=begline*wp->hscroll;
				fx=(*begcut)->begcol-wp->wfirst/wp->wscroll;
				fy=begline-wp->hfirst/wp->hscroll;
				bbcsave=line->begcol=(*begcut)->begcol;		 /* erste spalte */
				(*endcut)=line;
				for(help=(*begcut); help!=(*endcut)->next; help=help->next)
				{
					help->attr|=SELECTED;
					help->begcol=(*begcut)->begcol;
					help->endcol=(int)(x2+wp->wfirst/wp->wscroll);
				}
				for(help=line->next; help; help=help->next)
				{
					help->attr&=~SELECTED;
				}
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				for(help=wp->wstr,i=0,y2=wp->ywork;
					 help && y2<(wp->ywork+wp->hwork-1);
					 help=help->next, i++, y2+=wp->hscroll)
				{
					refresh(wp,help,0,i);
				}
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				graf_mkstate(&mx, &my, &mouse_click, &key_state);
				oldx=x=(mx - wp->xwork)/wp->wscroll;
				oldy=y=(my - wp->ywork)/wp->hscroll;
			}
			else
			{
				if(!cut)
					hide_blk(wp,*begcut,*endcut);
				line->attr|=SELECTED; /* nochmal */
				bbcsave=line->begcol=(int)(fx+wp->wfirst/wp->wscroll);	/* erste spalte */
				(*begcut)=(*endcut)=line;					 /* blk beginn */
				begline=y+wp->hfirst/wp->hscroll;		  /* erste zeile */
			}
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			graf_mouse(M_ON,0L);
			graf_mouse(TEXT_CRSR,NULL);
			do
			{
				x= (mx - wp->xwork) / wp->wscroll;
				y= (my - wp->ywork) / wp->hscroll;

				x=max(0,x);
				y=max(0,y);
				x=min(x,wp->wwork/wp->wscroll);
				y=min(y,wp->hwork/wp->hscroll-1);
				y=min(y,wp->hsize/wp->hscroll-1);
				x=max(x,fx);
				y=max(y,fy);

				if(y<oldy)
				{
					for(i=y; i<oldy; i++)
					{
						line->attr^=SELECTED;
						line=line->prev;
						*endcut=line;
					}
				}
				if(y>oldy)
				{
					for(i=oldy; i<y; i++)
						if(line->next)
						{
							line=line->next;
							line->attr^=SELECTED;
							*endcut=line;
						}
				}

				for(help=(*begcut); help!=(*endcut)->next; help=help->next)
				{
					help->attr|=SELECTED;
					help->begcol=(int)(fx+wp->wfirst/wp->wscroll);
					help->endcol=(int)( x+wp->wfirst/wp->wscroll);
				}

				if(x>=fx && y>=fy && (x!=oldx || y!=oldy))
				{
					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll)+(oldx-max(0,fx))*wp->wscroll;
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll)+(oldy-max(0,fy)+1)*wp->hscroll;
					pxyarray[2]=(x-oldx)*wp->wscroll;
					pxyarray[3]=(y-oldy)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll)+(oldx-max(0,fx))*wp->wscroll;
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll);
					pxyarray[2]=(x-oldx)*wp->wscroll;
					pxyarray[3]=(oldy-max(0,fy)+1)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll);
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll)+(oldy-max(0,fy)+1)*wp->hscroll;
					pxyarray[2]=(oldx-max(0,fx))*wp->wscroll;
					pxyarray[3]=(y-oldy)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

				}
				oldx=x;
				oldy=y;
				graf_mkstate(&mx, &my, &mouse_click, &key_state);

				if(my < wp->ywork)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_UPLINE))
					{
						fy++;
						oldy++;
					}
					if(my>yout)					/* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					else
						if(mouse_click & 2) /* bei rechter Taste 2x */
							for(i=0; i<HALFPAGE; i++)
								if(Warrow(wp,WA_UPLINE))
								{
									fy++;
									oldy++;
								}
					graf_mouse(M_ON,0L);
				}
				if(my > (wp->ywork + wp->hwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_DNLINE))
					{
						fy--;
						oldy--;
					}
					if(my<(yout+hout-2))		  /* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					else
						if(mouse_click & 2) /* bei rechter Taste 2x */
							for(i=0; i<HALFPAGE; i++)
								if(Warrow(wp,WA_DNLINE))
								{
									fy--;
									oldy--;
								}
					graf_mouse(M_ON,0L);
				}
				if(mx < wp->xwork+1)
				{
					if(mx>xout)					/* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_LFLINE))
					{
						fx+=HORIZ_OFFSET;
						oldx+=HORIZ_OFFSET;
					}
					graf_mouse(M_ON,0L);
				}
				if(mx > (wp->xwork + wp->wwork))
				{
					if(mx<(xout+wout))		  /* Verz”gern wenn, auf Fensterrand */
						evnt_timer(62,0);
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_RTLINE))
					{
						fx-=HORIZ_OFFSET;
						oldx-=HORIZ_OFFSET;
					}
					graf_mouse(M_ON,0L);
				}
				endline=oldy+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */
				wp->row=oldy;
				wp->col=oldx;
				wp->cstr=line;
				Wsetrcinfo(wp);
			}
			while(mouse_click);
			evnt_button(1,1,0,&i,&i,&i,&i);
			endline=oldy+wp->hfirst/wp->hscroll;		  /* letzte zeile */

			for(line=wp->fstr; line && line!=(*begcut); line=line->next)
			{
				line->attr &=~SELECTED;
				line->begcol=0;
				line->endcol=STRING_LENGTH;
			}
			for(i=begline, line=*begcut;
				i<=endline && line;
				i++, line=line->next)
			{
				line->attr |=SELECTED;
				line->begcol=(int)(fx+wp->wfirst/wp->wscroll);
				line->endcol=(int)(oldx+wp->wfirst/wp->wscroll);
				*endcut=line;
			}
			for(line=(*endcut)->next; line; line=line->next)
			{
				line->attr &=~SELECTED;
				line->begcol=0;
				line->endcol=STRING_LENGTH;
			}
			if(abs(fx-oldx))
			{
				Wcuroff(wp);
				graf_mouse(ARROW,0L);
				graf_mouse(M_OFF,0L);
				wp->cstr=*endcut;
				wp->cspos=wp->col=oldx;
				wp->row=oldy;
				Wcuroff(wp);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				wind_update(END_MCTRL);
				undo.item=FALSE;
				return(TRUE);	/* entspricht beg_blk() + end_blk() */
			}
		}
		wind_update(END_MCTRL);
	}
	*begcut=*endcut=NULL;
	*searchstring=0;

	graf_mouse(ARROW,0L);

	graf_mouse(M_OFF,0L);
	Wcursor(wp);
	graf_mouse(M_ON,0L);
	return(FALSE);
}

long _keyoff(void);
long _keyon(void);

static void get_key(WINDOW *wp, int *mx, int *my,  int *key_state)
{
   int event;

	static MEVENT mevent=
	{
		MU_KEYBD|MU_TIMER,
		0,0,0,
		0,0,0,0,0,
		0,0,0,0,0,
		NULL,
		0L,
		0,0,0,0,0,0,
	/* nur der Vollst„ndigkeit halber die Variablen von XGEM */
		0,0,0,0,0,
		0,
		0L,
		0L,0L
	};

	Supexec(_keyon);

   event = evnt_event(&mevent);

	Supexec(_keyoff);

   *key_state = 0;
  	MapKey(&mevent.e_ks,&mevent.e_kr); /* Profibuch Seite 761 */
   if(event & MU_KEYBD)
   {
      switch(mevent.e_kr)
      {
			case 0x8648:	 /* shiftctrl up */
			   *my -= wp->hscroll;
			   break;
			case 0x8650:    /* shiftctrl dn */
			   *my += wp->hscroll;
			   break;
			case 0x864B:	 /* shiftctrl left  */
			case 0x8673:
			   *mx -= wp->wscroll;
				wp->cspos--; /* festen Cursor beim Scrollen 9.4.94 */
			   break;
			case 0x864D:	 /* shiftctrl right */
			case 0x8674:
			   *mx += wp->wscroll;
				wp->cspos++;
			   break;
      }
/* mu raus, wg. Makrorecorder
		while(evnt_event(&mevent) == MU_KEYBD)
			;
*/
      mx=max(0,mx);
      mx=min(mx,xdesk+wdesk);
      my=max(0,my);
      my=min(my,ydesk+hdesk);
   }
   *key_state = mevent.e_ks;
}

int _WKeyBlock(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int key_state, int key)
{
	int ret,fx,fy,x,y,x2,oldx,oldy,pxyarray[4];
	int mx,my,mouse_click,wordmark=FALSE,linemark=FALSE;
	int bbcsave,becsave,ebcsave,eecsave;
	register LINESTRUCT *line,*help;
	int xout,yout,wout,hout;
	long i,y2,temp;

   /* folgende Tasten mssen alternativ gedrckt sein: */
   if(!((key == 0x8648) || 	 /* shiftctrl up */
		  (key == 0x8650) ||   /* shiftctrl dn */
		  (key == 0x864B) ||	 /* shiftctrl left  */
		  (key == 0x864D) ||
		  (key == 0x8673) ||
		  (key == 0x8674)))    /* shiftctrl right  */
		return(FALSE);

	if(wp)
	{
						  /* bei gedrckter Shifttaste Block erweitern */
		if(!cut && !(key_state & (K_RSHIFT|K_LSHIFT|K_CTRL)))
			hide_blk(wp,*begcut,*endcut);
		if(cut)					/* gibt es erst noch mll zu l”schen */
			free_blk(wp,*begcut);

		wind_calc(WC_BORDER,wp->kind,wp->xwork,wp->ywork,wp->wwork,wp->hwork,
			&xout,&yout,&wout,&hout);

      /* Cursorposition umrechnen in Pixeln */
		mx=wp->xwork + wp->col*wp->wscroll;
		my=wp->ywork + wp->row*wp->hscroll;

		x=(mx-wp->xwork)/wp->wscroll;
		fx=oldx=x;
		fy=oldy=y=(my-wp->ywork)/wp->hscroll;

		for(i=0, line=wp->wstr; i<y && line; i++, line=line->next)
		  ;

		lastwstr=wp->wstr;
		lasthfirst=wp->hfirst;

		if(!(wp->w_state&COLUMN))
		{
			oldx=x=min(x,line->used-wp->wfirst/wp->wscroll);
			y2=(my-wp->ywork)/wp->hscroll+wp->hfirst/wp->hscroll;
			
			if(!cut && *begcut && *endcut && (key_state & (K_RSHIFT|K_LSHIFT|K_CTRL)))
			{
				if((y2 > (begline+(endline-begline)/2)) ||
					((y2 == (begline+(endline-begline)/2)) && x>((*begcut)->begcol-wp->wfirst/wp->wscroll)))
				{  /* bereits vorhandenen Block nach unten erweitern */
					lastwstr=(*begcut);
					lasthfirst=begline*wp->hscroll;
					(*begcut)->endcol=STRING_LENGTH;
					for(help=(*begcut)->next; help && help!=line->next; help=help->next)
					{
						help->attr|=SELECTED;
						help->begcol=0;
						help->endcol=STRING_LENGTH;
					}
					for(help=line->next; help; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					bbcsave=(*begcut)->begcol;	/* erste spalte */
					becsave=line->endcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					pxyarray[0]=wp->xwork;
					pxyarray[1]=wp->ywork+(min(y2,endline)*wp->hscroll)-wp->hfirst;
					pxyarray[2]=wp->wwork;
					pxyarray[3]=(abs(y2-endline)+1)*wp->hscroll;
				}
				else
				{  /* bereits vorhandenen Block nach oben erweitern */
					lastwstr=wp->wstr;
					lasthfirst=wp->hfirst;
					bbcsave=becsave=(*endcut)->endcol;
					becsave++;
					*begcut=*endcut;
					(*begcut)->begcol=0;
					(*begcut)->endcol=bbcsave;
					*endcut=line;
					(*endcut)->begcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					(*endcut)->endcol=STRING_LENGTH;
					temp=begline;
					begline=endline;
					for(help=wp->fstr; help && help!=line; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					for(help=(*endcut); help && help!=(*begcut); help=help->next)
					{
						help->attr|=SELECTED;
						help->begcol=0;
						help->endcol=STRING_LENGTH;
					}
					for(help=(*begcut)->next; help; help=help->next)
					{
						help->attr&=~SELECTED;
					}
					(*endcut)->begcol=min(line->used,(int)(x+wp->wfirst/wp->wscroll));
					(*begcut)->endcol=bbcsave;
					pxyarray[0]=wp->xwork;
					pxyarray[1]=wp->ywork+(min(y2,temp)*wp->hscroll)-wp->hfirst;
					pxyarray[2]=wp->wwork;
					pxyarray[3]=(abs(y2-temp)+1)*wp->hscroll;
				}
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				Wredraw(wp,pxyarray);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
			}
			else
			{
				if(!cut)
					hide_blk(wp,*begcut,*endcut);
				line->attr|=SELECTED; /* nochmal */
				bbcsave=line->begcol=(int)(x+wp->wfirst/wp->wscroll);	/* erste spalte */
				becsave=line->endcol=(int)(x+wp->wfirst/wp->wscroll+1);
				*begcut=line;									 /* blk beginn */
				begline=y+wp->hfirst/wp->hscroll;		  /* erste zeile */
			}
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			graf_mouse(M_ON,0L);

	      switch(key) /* Cursor gleich um eins weitersetzen, */
	      {				/* damit sofort ein Block entsteht 		*/
				case 0x8648:	 /* shiftctrl up */
				   my -= wp->hscroll;
				   break;
				case 0x8650:    /* shiftctrl dn */
				   my += wp->hscroll;
				   break;
				case 0x864B:	 /* shiftctrl left  */
				case 0x8673:
				   mx -= wp->wscroll;
				   wp->cspos--; /* festen Cursor beim Scrollen 9.4.94 */
				   break;
				case 0x864D:	 /* shiftctrl right */
				case 0x8674:
				   mx += wp->wscroll;
				   wp->cspos++;
				   break;
	      }
	      mx=max(0,mx);
	      mx=min(mx,xdesk+wdesk);
	      my=max(0,my);
	      my=min(my,ydesk+hdesk);

			do
			{
				x=(mx - wp->xwork) / wp->wscroll;
				y=(my - wp->ywork) / wp->hscroll;

				x=max(x,wp->cspos-wp->wfirst/wp->wscroll);
				x=min(x,line->used-wp->wfirst/wp->wscroll);

				/* nicht weiter als bis ans Zeilenende */
				mx=min(mx, wp->xwork + x*wp->wscroll);

				x=max(0,x);
				y=max(0,y);
				x=min(x,wp->wwork/wp->wscroll-1);
				y=min(y,wp->hwork/wp->hscroll-1);
				y=min(y,wp->hsize/wp->hscroll-1);
				
				if(y < oldy)
				{
					for(i=y; i<oldy; i++)
					{
						if(line->prev)
						{
							if(line==*begcut)				  /* Blockbeginn */
							{
								line->begcol=0;
								line->endcol=bbcsave;
								line=line->prev;
								line->attr|=SELECTED;
								line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
								line->endcol=STRING_LENGTH;
							}
							else
							{
								if(line->prev->attr & SELECTED)	/* hinter Bb zurck */
								{
									line->attr&=~SELECTED;
									line=line->prev;
									if(line==*begcut)		 /* jetzt am Bb */
									{
										line->begcol=bbcsave;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										if(line->begcol>line->endcol)
											swap(&line->begcol,&line->endcol);
									}
									else
									{
										line->begcol=0;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
									}
								}
								else							  /* vor Bb zurck */
								{
									line->begcol=0;
									line->endcol=STRING_LENGTH;
									line=line->prev;
									line->attr|=SELECTED;
									line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
									line->endcol=STRING_LENGTH;
								}
							}
						}
					}
				}
				if(y > oldy)
				{
					for(i=oldy; i<y; i++)
					{
						if(line->next)
						{
							if(line==*begcut) /* Blockbeginn */
							{
								line->begcol=bbcsave;
								line->endcol=STRING_LENGTH;
								line=line->next;
								line->attr|=SELECTED;
								line->begcol=0;
								line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
							}
							else
							{
								if(line->next->attr & SELECTED)  /* vor Blockbeginn */
								{
									line->attr&=~SELECTED;
									line=line->next;
									if(line==*begcut)		/* jetzt am Bb */
									{
										line->begcol=bbcsave;
										line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										if(line->begcol>line->endcol)
											swap(&line->begcol,&line->endcol);
									}
									else						 /* immer noch vor Bb */
									{
										line->begcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
										line->endcol=STRING_LENGTH;
									}
								}
								else							 /* nach Blockbeginn */
								{
									line->begcol=0;
									line->endcol=STRING_LENGTH;
									line=line->next;
									line->attr|=SELECTED;
									line->begcol=0;
									line->endcol=(int)(x+(int)(wp->wfirst/wp->wscroll));
								}
							}
						}
					}
				}
				if(y < oldy)
				{
					if(x>=oldx)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(oldy - y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=oldx * wp->wscroll;
						pxyarray[3]=abs(oldy- y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else /* kleiner */
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(oldy - y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=x * wp->wscroll;
						pxyarray[3]=abs(oldy- y) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(y > oldy)
				{
					if(x >= oldx)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (oldy + 1) * wp->hscroll;
						pxyarray[2]=oldx * wp->wscroll;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else /* kleiner */
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=wp->wwork;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
						pxyarray[0]=wp->xwork;
						pxyarray[1]=wp->ywork + (oldy + 1) * wp->hscroll;
						pxyarray[2]=x * wp->wscroll;
						pxyarray[3]=abs(y - oldy) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(x > oldx)
				{
					if(y>=oldy)
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + oldy * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)+1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					else
					{
						pxyarray[0]=wp->xwork + oldx * wp->wscroll;
						pxyarray[1]=wp->ywork + (y+1) * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)-1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				if(x < oldx)
				{
					if(y==oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=abs(oldx - x) * wp->wscroll;
						pxyarray[3]=wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					if(y>oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + (oldy+1) * wp->hscroll;
						pxyarray[2]=abs(oldx - x) * wp->wscroll;
						pxyarray[3]=(abs(oldy - y)-1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
					if(y<oldy)
					{
						pxyarray[0]=wp->xwork + x * wp->wscroll;
						pxyarray[1]=wp->ywork + y * wp->hscroll;
						pxyarray[2]=abs(x - oldx) * wp->wscroll;
						pxyarray[3]=(abs(y - oldy)+1) * wp->hscroll;
						blackbox(wp, pxyarray, wp->wscroll);
					}
				}
				oldx=x;
				oldy=y;
				get_key(wp, &mx, &my, &key_state);
				if(my < wp->ywork)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_UPLINE))
					{
						oldy++;
						my += wp->hscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(my > (wp->ywork + wp->hwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_DNLINE))
					{
						oldy--;
						my -= wp->hscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(wp->wfirst!=0 && mx < wp->xwork+1)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_LFLINE))
					{
						oldx+=HORIZ_OFFSET;
						mx += wp->wscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(mx > (wp->xwork + wp->wwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_RTLINE))
					{
						oldx-=HORIZ_OFFSET;
						mx -= wp->wscroll;
					}
					graf_mouse(M_ON,0L);
				}
				endline=oldy+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */
				wp->row=oldy;
				wp->col=oldx;
				wp->cstr=line;
				Wsetrcinfo(wp);
			}
			while(key_state & (K_RSHIFT|K_LSHIFT|K_CTRL));

			for(i=0, line=wp->wstr; i<oldy && line; i++, line=line->next)
			  ;
			endline=i+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */

			ebcsave=line->begcol=0;
			(*begcut)->begcol=bbcsave;
			eecsave=line->endcol=(int)(oldx+wp->wfirst/wp->wscroll); /* letzte spalte */
			*endcut=line;								  /* ende markieren */

			if(begline > endline)						/* vertauschen */
			{
/* Das fehlte hier!!! Erik Dick */
				 lastwstr=wp->wstr;
				 lasthfirst=wp->hfirst;

				 line=*endcut;
				 *endcut=*begcut;
				 *begcut=line;
  				 wp->cstr=*begcut;

				 i=endline;
				 endline=begline;
				 begline=i;

				 (*begcut)->begcol=eecsave;
				 (*begcut)->endcol=becsave;
				 (*endcut)->begcol=ebcsave;
				 (*endcut)->endcol=bbcsave;
			}
			if(*begcut != *endcut && begline < endline)
			{
				(*begcut)->endcol=STRING_LENGTH;  /* Fehlerkorrektur */
			}
			if(begline==endline)
			{
				if( (*begcut)->begcol > (*begcut)->endcol )
				{  /* vertauschen, wenn von links nach rechts gezogen !!! */
					(*begcut)->begcol=(*endcut)->begcol=eecsave;
					(*begcut)->endcol=(*endcut)->endcol=becsave-1;
				}
			}
			if((*endcut)->endcol==0)  /* wenn spalte=0, endcut zurcksetzen... */
			{
				if(*endcut != *begcut)  /* ...wenn endcut > begcut					*/
				{
					*endcut=(*endcut)->prev;
					if(*begcut != *endcut)
						(*endcut)->begcol=0;
					(*endcut)->endcol=STRING_LENGTH;
					endline--;
				}
			}
			if((*begcut)->begcol==0 && (*endcut)->endcol>=(*endcut)->used)
			{
				endline++;
			}
			if( (*begcut)->begcol < (*begcut)->endcol &&
				 (*endcut)->begcol < (*endcut)->endcol	 )
			{
				for(line=wp->fstr; line != *begcut; line=line->next)
				{
					line->attr&=~SELECTED;		  /* attribut l”schen */
				}
				for(line=*begcut; line != (*endcut)->next; line=line->next)
				{
					line->attr|=SELECTED;		  /* attribut setzen */
				}
				for(line=(*endcut)->next; line; line=line->next)
				{
					line->attr&=~SELECTED;		  /* attribut l”schen */
				}
				if(*begcut != *endcut) /* mehr als eine zeile */
				{
					(*begcut)->endcol=STRING_LENGTH;
					(*endcut)->begcol=0;
					for(line=(*begcut)->next; line && line != *endcut; line=line->next)
					{
						line->begcol=0;
						line->endcol=STRING_LENGTH;
					}
				}
				Wcuroff(wp);
				graf_mouse(ARROW,0L);
				graf_mouse(M_OFF,0L);
/*
				wp->cstr=*endcut;
*/
				wp->cspos=wp->col=oldx;
				wp->row=oldy;
				Wcuroff(wp);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				undo.item=FALSE;
/*
printf("\33H*%d %d %d %d %ld %ld*",x,oldx,y,oldy,begline,endline);
*/
				return(TRUE);	/* entspricht beg_blk() + end_blk() */
			}
		}
		else /* Spaltenblockmarkierung */
		{
			x2=(mx-wp->xwork)/wp->wscroll+wp->wfirst/wp->wscroll;
			y2=(my-wp->ywork)/wp->hscroll+wp->hfirst/wp->hscroll;

			if(!cut && *begcut && *endcut &&
				(int)(fx+wp->wfirst/wp->wscroll)>(*begcut)->begcol &&
				y2>begline &&
				(key_state & (K_RSHIFT|K_LSHIFT|K_CTRL)))
			{								 /* bereits vorhandenen Block erweitern */
				lastwstr=(*begcut);
				lasthfirst=begline*wp->hscroll;
				fx=(*begcut)->begcol-wp->wfirst/wp->wscroll;
				fy=begline-wp->hfirst/wp->hscroll;
				bbcsave=line->begcol=(*begcut)->begcol;		 /* erste spalte */
				(*endcut)=line;
				for(help=(*begcut); help!=(*endcut)->next; help=help->next)
				{
					help->attr|=SELECTED;
					help->begcol=(*begcut)->begcol;
					help->endcol=(int)(x2+wp->wfirst/wp->wscroll);
				}
				for(help=line->next; help; help=help->next)
				{
					help->attr&=~SELECTED;
				}
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				for(help=wp->wstr,i=0,y2=wp->ywork;
					 help && y2<(wp->ywork+wp->hwork-1);
					 help=help->next, i++, y2+=wp->hscroll)
				{
					refresh(wp,help,0,i);
				}
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				graf_mkstate(&mx, &my, &mouse_click, &key_state);
				oldx=x=(mx - wp->xwork)/wp->wscroll;
				oldy=y=(my - wp->ywork)/wp->hscroll;
			}
			else
			{
				if(!cut)
					hide_blk(wp,*begcut,*endcut);
				line->attr|=SELECTED; /* nochmal */
				bbcsave=line->begcol=(int)(fx+wp->wfirst/wp->wscroll);	/* erste spalte */
				(*begcut)=(*endcut)=line;					 /* blk beginn */
				begline=y+wp->hfirst/wp->hscroll;		  /* erste zeile */
			}
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			graf_mouse(M_ON,0L);

	      switch(key) /* Cursor gleich um eins weitersetzen, */
	      {				/* damit sofort ein Block entsteht 		*/
/* nein
				case 0x8648:	 /* shiftctrl up */
				   my -= wp->hscroll;
				   break;
*/
				case 0x8650:    /* shiftctrl dn */
				   my += wp->hscroll;
				   break;
/* nein
				case 0x864B:	 /* shiftctrl left  */
				case 0x8673:
				   mx -= wp->wscroll;
				   break;
*/
				case 0x864D:	 /* shiftctrl right */
				case 0x8674:
				   mx += wp->wscroll;
				   break;
	      }
	      mx=max(0,mx);
	      mx=min(mx,xdesk+wdesk);
	      my=max(0,my);
	      my=min(my,ydesk+hdesk);

			do
			{
				x= (mx - wp->xwork) / wp->wscroll;
				y= (my - wp->ywork) / wp->hscroll;

				x=max(0,x);
				y=max(0,y);
				x=min(x,wp->wwork/wp->wscroll);
				y=min(y,wp->hwork/wp->hscroll-1);
				y=min(y,wp->hsize/wp->hscroll-1);
				x=max(x,fx);
				y=max(y,fy);

				if(y<oldy)
				{
					for(i=y; i<oldy; i++)
					{
						line->attr^=SELECTED;
						line=line->prev;
						*endcut=line;
					}
				}
				if(y>oldy)
				{
					for(i=oldy; i<y; i++)
						if(line->next)
						{
							line=line->next;
							line->attr^=SELECTED;
							*endcut=line;
						}
				}

				for(help=(*begcut); help!=(*endcut)->next; help=help->next)
				{
					help->attr|=SELECTED;
					help->begcol=(int)(fx+wp->wfirst/wp->wscroll);
					help->endcol=(int)( x+wp->wfirst/wp->wscroll);
				}

				if(x>=fx && y>=fy && (x!=oldx || y!=oldy))
				{
					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll)+(oldx-max(0,fx))*wp->wscroll;
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll)+(oldy-max(0,fy)+1)*wp->hscroll;
					pxyarray[2]=(x-oldx)*wp->wscroll;
					pxyarray[3]=(y-oldy)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll)+(oldx-max(0,fx))*wp->wscroll;
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll);
					pxyarray[2]=(x-oldx)*wp->wscroll;
					pxyarray[3]=(oldy-max(0,fy)+1)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

					pxyarray[0]=max(wp->xwork,wp->xwork+fx*wp->wscroll);
					pxyarray[1]=max(wp->ywork,wp->ywork+fy*wp->hscroll)+(oldy-max(0,fy)+1)*wp->hscroll;
					pxyarray[2]=(oldx-max(0,fx))*wp->wscroll;
					pxyarray[3]=(y-oldy)*wp->hscroll;
					if(pxyarray[2]<0)
					{
						pxyarray[2]*=-1;
						pxyarray[0]-=pxyarray[2];
					}
					if(pxyarray[3]<0)
					{
						pxyarray[3]*=-1;
						pxyarray[1]-=pxyarray[3];
					}
					blackbox(wp, pxyarray, wp->wscroll);

				}
				oldx=x;
				oldy=y;
				get_key(wp, &mx, &my, &key_state);

				if(my < wp->ywork)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_UPLINE))
					{
						fy++;
						oldy++;
						my += wp->hscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(my > (wp->ywork + wp->hwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_DNLINE))
					{
						fy--;
						oldy--;
						my -= wp->hscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(mx < wp->xwork+1)
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_LFLINE))
					{
						fx+=HORIZ_OFFSET;
						oldx+=HORIZ_OFFSET;
						mx += wp->wscroll;
					}
					graf_mouse(M_ON,0L);
				}
				if(mx > (wp->xwork + wp->wwork))
				{
					graf_mouse(M_OFF,0L);
					if(Warrow(wp,WA_RTLINE))
					{
						fx-=HORIZ_OFFSET;
						oldx-=HORIZ_OFFSET;
						mx -= wp->wscroll;
					}
					graf_mouse(M_ON,0L);
				}
				endline=oldy+wp->hfirst/wp->hscroll;		/* fr zeilendifferenz */
				wp->row=oldy;
				wp->col=oldx;
				wp->cstr=line;
				Wsetrcinfo(wp);
			}
			while(key_state & (K_RSHIFT|K_LSHIFT|K_CTRL));
			endline=oldy+wp->hfirst/wp->hscroll;		  /* letzte zeile */

			for(line=wp->fstr; line && line!=(*begcut); line=line->next)
			{
				line->attr &=~SELECTED;
				line->begcol=0;
				line->endcol=STRING_LENGTH;
			}
			for(i=begline, line=*begcut;
				i<=endline && line;
				i++, line=line->next)
			{
				line->attr |=SELECTED;
				line->begcol=(int)(fx+wp->wfirst/wp->wscroll);
				line->endcol=(int)(oldx+wp->wfirst/wp->wscroll);
				*endcut=line;
			}
			for(line=(*endcut)->next; line; line=line->next)
			{
				line->attr &=~SELECTED;
				line->begcol=0;
				line->endcol=STRING_LENGTH;
			}
			if(abs(fx-oldx))
			{
				Wcuroff(wp);
				graf_mouse(ARROW,0L);
				graf_mouse(M_OFF,0L);
				wp->cstr=*endcut;
				wp->cspos=wp->col=oldx;
				wp->row=oldy;
				Wcuroff(wp);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				undo.item=FALSE;
				return(TRUE);	/* entspricht beg_blk() + end_blk() */
			}
		}
	}
	*begcut=*endcut=NULL;
	*searchstring=0;

	graf_mouse(ARROW,0L);

	graf_mouse(M_OFF,0L);
	Wcursor(wp);
	graf_mouse(M_ON,0L);
	return(FALSE);
}

