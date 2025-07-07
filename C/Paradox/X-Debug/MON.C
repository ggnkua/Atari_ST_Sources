
/* this is it - the all-new Mon3 debugger from AMP */
#include "mon.h"

void init_exceptions(),deinit_exceptions();

/* a few globals */
char linebuf[256];
byte progstate;
char progname[256];
char progcmd[256];

txt(TX_DURING);
txt(TX_ADVERT); txt(TX_AADVERT); txt(TX_MORE); txt(TX_ADVERTDEBUG);
char *TX_FATALERROR(word);

#if 0
/*********** memory management *************/

/* grab some bytes */
void *getanymem(long bytes)
{
	return malloc(bytes);
}

/* grab some zeroed bytes */
void *getzmem(long bytes)
{
	return calloc(bytes,1);
}

/* give back either */
void freemem(void *where)
{
	free(where);
}
#endif

/********* virtual windowing system *********/

#include "window.h"

/* must be dynamic when I can figure it out */
byte scr_which[MAXX][MAXY];				/* -1=background; x=owner window */

struct ws *wlist[MAXWINDOW],*frontwindow;
word frontnum;

#define MINWIDTH	6
#define	MINHEIGHT	4

/* the next pointer points to the one behind it, the prev
	to the one in front (OK, who needs consistency?) 
	and both lists are circular */

void dump_wlist()
{
struct ws *w;
	if (frontwindow==NULL)
		{
		printf("Empty window list");
		return;
		}
	printf("Window Next");
	w=frontwindow;
	do
		{
		printf("-%d",(short)w->number);
		w=w->next;
		}
	while (w!=frontwindow);
	printf("\nWindow Prev");
	w=frontwindow;
	do
		{
		printf("-%d",(short)w->number);
		w=w->prev;
		}
	while (w!=frontwindow);
	putchar('\n');
	wait_key();
	return;
}

word current_wnum()
{
	if (frontwindow)
		return (word)frontwindow->number;
	else
		return -1;
}

bool check_wvalid(word num)
{
	if ( (num>=0) && (num<MAXWINDOW) )
		return TRUE;
	else
		return FALSE;
}

bool check_wopen(word num)
{
	if (check_wvalid(num)==FALSE)
		return FALSE;
	else
		return wlist[num]->open;
}

/* requires valid param */
struct ws *getwptr(num)
{
	return wlist[num];
}

bool in_wlist(struct ws *wptr)
{
struct ws *w;
	if ( (w=frontwindow)==NULL )
		return FALSE;
	do
		{
		if (w==wptr)
			return TRUE;
		w=w->next;
		}
	while (w!=frontwindow);
	return FALSE;
}

/* extract a window from the list */
void remove_wlist(struct ws *w)
{
struct ws *oldnext,*oldprev;
	if (frontwindow==frontwindow->next)			/* only window */
		{
		frontwindow=NULL;
		frontnum=-1;
		}
	else
		{
		oldnext=w->next;
		oldprev=w->prev;
		oldprev->next=w->next;
		oldnext->prev=w->prev;
		if (frontwindow==w)						/* if was front window */
			{
			frontwindow=oldnext;
			frontnum=(word)frontwindow->number;
			}
		}
}

/* move/add a ws to the very front of the window list */
void add_wlist(struct ws *w)
{
struct ws *oldprev;

	if (in_wlist(w))
		remove_wlist(w);

	if (frontwindow==NULL)
		{
		w->next=w->prev=w;
		}
	else if (frontwindow==frontwindow->next)
		{ /* only one; another being added */
		w->next=w->prev=frontwindow;
		frontwindow->next=frontwindow->prev=w;
		}
	else
		{ /* insert op */
		oldprev=frontwindow->prev;
		w->next=frontwindow;
		w->prev=oldprev;
		frontwindow->prev=w;
		oldprev->next=w;
		}
	frontwindow=w;
	frontnum=(word)frontwindow->number;
/*	dump_wlist();	*/
	return;
}


/* clears the contents of the window in memory only */
/* and homes cursor to inside top-left */
void window_cls(struct ws *wptr)
{
short i,j;
	for (i=1; i<wptr->w-1; i++)
		for (j=1; j<wptr->h-1; j++)
			wptr->contents[i][j]=' ';
	wptr->xpos=wptr->ypos=1;
}

/* scroll a window up or down, as required */
/* puts cursor on bottom left of clean new line */
void scroll_window(struct ws *wptr,bool upflag)
{
word x,y;
void scroll_rect(word,word,word,word,word);

if (upflag)
	{
	/* physically do it */
	if (wptr==frontwindow)
		scroll_rect( (word)(wptr->x+1),(word)(wptr->y+2),
			(word)(wptr->w-2),(word)(wptr->h-3),-1 );

	/* scroll the charmap */
	for (y=2; y<=(wptr->h-2); y++ )
		{
		for (x=1; x<(wptr->w-2); x++)
			wptr->contents[x][y-1]=wptr->contents[x][y];
		}
	/* clear the new line */
	y--;
	for (x=1; x<(wptr->w-2); x++)
		wptr->contents[x][y]=' ';

	wptr->xpos=1;
	wptr->ypos=wptr->h-2;
	}
else
	{
	if (wptr==frontwindow)
		scroll_rect( (word)(wptr->x+1),(word)(wptr->y+1),
			(word)(wptr->w-2),(word)(wptr->h-3), 1 );

	for (y=wptr->h-3; y; y-- )
		{
		for (x=1; x<(wptr->w-2); x++)
			wptr->contents[x][y+1]=wptr->contents[x][y];
		}
	y=1;
	for (x=1; x<(wptr->w-2); x++)
		wptr->contents[x][y]=' ';
	wptr->xpos=wptr->ypos=1;
	}

	/* refresh the new window */
	if (wptr!=frontwindow)
		update_contents(wptr);
}

/* if the front window is a command window and someone's
	written to it then tidy up */
void check_command(void)
{
	if (frontwindow && (frontwindow->type==WTYPE_COMMAND)
			&& (frontwindow->written) )
		{
			frontwindow->xpos=1;
			start_command(frontwindow,"");
			frontwindow->written=FALSE;
		}
}

/* tell the window recalculator to refresh its buffer for this one */
void refill_window(word num, bool maydraw)
{
struct ws *wptr;
bool redraw;
	wptr=wlist[num];
	if ( (!wptr->open) || (wptr->type==WTYPE_NONE) )
		return;
	if (wptr->type!=WTYPE_DEAD)
		{
		redraw=FALSE;
		window_cls(wptr);
		switch (wptr->type)
			{
			case WTYPE_REGS: redraw=refill_regs(wptr); break;
			case WTYPE_DISS: redraw=refill_diss(wptr); break;
			case WTYPE_MEM:  redraw=refill_mem(wptr); break;
			case WTYPE_ASCII:redraw=refill_ascii(wptr); break;
			case WTYPE_SMART:redraw=refill_smart(wptr); break;
			case WTYPE_WATCH:redraw=refill_watch(wptr); break;
			case WTYPE_BREAK:redraw=refill_break(wptr); break;
			case WTYPE_MMU:  redraw=refill_mmu(wptr); break;
			case WTYPE_LOCAL:redraw=refill_local(wptr); break;
			case WTYPE_FPU:  redraw=refill_fpu(wptr); break;
			}
		if (redraw && maydraw)
			update_rectangle((word)(wptr->x+1),(word)(wptr->y+1),
				(word)(wptr->w-2),(word)(wptr->h-2));
		}
}

/* user wants to change the start addr of this window */
void window_setlong(word w, ulong l, bool draw)
{
struct ws *wl;

	wl=wlist[w];
	switch (wl->type)
		{
		case WTYPE_DISS:
			if ( (mayrefill_diss(wl,l,TRUE)) || draw )
				refill_window(w, TRUE);
			break;
		case WTYPE_SMART:
			if ( (mayrefill_smart(wl,l,TRUE)) || draw )
				refill_window(w, TRUE);
			break;
		case WTYPE_COMMAND:
			wl->wlong=l;
			break;
		default:
			wl->wlong=l;
			if (draw)
				refill_window(w, TRUE);
			break;
		}
}

/* user wants to change the word setting  (-1 means next) */
void window_setword(word w, word x, bool draw)
{
	wlist[w]->wword=x;
	/* cause a general re-calc */
	window_setlong(w, wlist[w]->wlong, draw);
	wlist[w]->lastlock=wlist[w]->wlong;			/* so changing it doesnt screw up next lockchanged */
}

/* return TRUE if lock value has changed (with new value) */
bool lockchanged(struct ws *w, long*new)
{
long *lreg;

	*new=w->wlong;					/* default value */
	if ( (lreg=w->lockreg)==NULL)
		return FALSE;
	if (*lreg==w->lastlock)
		return FALSE;
	w->lastlock=*new=*lreg;
	return TRUE;
}

void window_lock(word w, char *ptr, bool simple, char *ascii, bool refill)
{
long *oldlock;
char oldtitle[MAXTITLE+1];
word junk;
char *t;
void window_title2(struct ws *, char *, bool);
word wtype; long new;

	wtype=wlist[w]->type;
	/* only some windows can be locked */
	if (! ( (wtype==WTYPE_MEM) || (wtype==WTYPE_DISS) /* || (wtype==WTYPE_SMART) */ ) )
		return;
	if (simple==FALSE)
		return;					/* cannot cope with these yet */
	oldlock=wlist[w]->lockreg;
	wlist[w]->lockreg=(long*)ptr;
	get_window(w,t=oldtitle,&junk,&junk,&junk,&junk);
	while (*t)
		t++;							/* t=ptr to null */
	if ( (oldlock==NULL) && (ptr) )		/* none->something */
		{
		*t++=' ';
		while (*t++=*ascii++)
			;
		}
	else if (oldlock)					/* something->?? */
		{
		while (*t!=' ')
			t--;
		*t=0;							/* kill old one */
		if (ptr)
			{
			*t++=' ';
			while (*t++=*ascii++)
				;
			}
		}
	window_title2(wlist[w],oldtitle,TRUE);
	if ( refill && lockchanged(wlist[w],&new) )
		/* better redraw it */
		window_setlong(w, new, TRUE);			/* was world_changed(FALSE); but didn't redisplay correctly */
}

/* return the oring of two rectangles */
void or_rectangle(word *x1,word *y1,word *w1,word *h1,
	word x2, word y2, word w2, word h2)
{
word x3,y3;
	if ( (w2&&h2)==0 )
		return;
	if ( (*w1&&*h1)==0 )
		{ *x1=x2; *y1=y2; *w1=w2; *h1=h2;
		  return;
		}
	x3=max(*x1+*w1,x2+w2);
	y3=max(*y1+*h1,y2+h2);
	*x1=min(*x1,x2);
	*y1=min(*y1,y2);
	*w1=x3-*x1;
	*h1=y3-*y1;
}

/* return the intersection of two rects */
/* returns TRUE if there is any intersection */
bool inter_rectangle(word x1,word y1,word w1,word h1,
	word x2, word y2, word w2, word h2,
	word *x3, word *y3, word *w3, word *h3)
{
word e1,e2;

	if ( (w2==0) || (h2==0) || (w1==0) || (h1==0) )
		return FALSE;

	e1=x1+w1; e2=x2+w2;
	if ( (x2>e1) || (x1>e2) )
		return FALSE;
	*w3=min(e1,e2)-(*x3=max(x1,x2));

	e1=y1+h1; e2=y2+h2;
	if ( (y2>e1) || (y1>e2) )
		return FALSE;
	*h3=min(e1,e2)-(*y3=max(y1,y2));

	if ( (*w3>=0) && (*h3>=0) )
		return TRUE;
	else
		return FALSE;
}

/* given a (charactor) xy pos on the screen, which window is it?
	returns -1 if doesnt know, else xy updated to local coords */
word which_window(word *x, word *y, ubyte *what)
{
word w;

	if ( (*x>=maxw) || (*y>=maxh) )
		return -1;
	if ( (w=scr_which[*x][*y]) <0 )
		return w;
	(*x)-=wlist[w]->x;
	(*y)-=wlist[w]->y;
	*what= (*y==0) ? BD_TITLE1 : wlist[w]->contents[*x][*y];
	if (!isborder(*what))
		*what=0;
	return w;
}

/* re-draw a section of screen */
void update_rectangle(word x, word y, word w, word h)
{
word i,j;
byte b; schar c;
struct ws *wptr;

	DONT(clear_rect(x,y,w,h));			/* clear out the crap */
	for (j=0; j<h; j++)
		for (i=0; i<w; i++)
			{
			b=scr_which[i+x][j+y];
			if (b!=NOWINDOW)
				{
				wptr=wlist[b];
				c=wptr->contents[x+i-wptr->x][y+j-wptr->y];
				if (isborder(c))
					border_out((word)(x+i),(word)(y+j),c,(bool)(wptr==frontwindow));
				else
					char_out((word)(x+i),(word)(y+j),c);
				}
			else
				border_out((word)(x+i),(word)(y+j),BD_BACKGROUND,TRUE);
			}
}

/* change font etc - need to tell low-level, then recalc high level */
void change_mode(void)
{
word i; word junk;
word yshift;

	yshift = maxh;
	if (kick_mode()==0)			/* if hw doesnt allow */
		return;
	// if going to a smaller font size, keep window posns same if poss
	yshift = (maxh==yshift*2) ? 1 : 0;

	for (i=0; i<MAXWINDOW; i++)
		if (wlist[i]->open)
			{
			change_window(i,wlist[i]->x,wlist[i]->y<<yshift,
					wlist[i]->w,wlist[i]->h<<yshift,&junk,&junk,&junk,&junk);
			}
	update_rectangle(0,0,maxw,maxh);
}

/* spit a whole line out into the window buffer and bump y (x ignored) */
void wprint_line(struct ws *wptr, char *t, bool pad)
{
word x,l;
char *p;

	if (wptr->ypos >(wptr->h-2) )
		return;							/* off bottom */
	l=strlen(p=t);
	x=1;
	while (l--)
		{
		wptr->contents[x++][wptr->ypos]=*p++;
		if (x>wptr->w-2)
			break;
		}
	if (pad)
		{
		l=wptr->w-2-strlen(t);
		while (l-->0)
			{
			wptr->contents[x++][wptr->ypos]=' ';
			}
		}
	wptr->ypos++;
	wptr->xpos=1;
	wptr->written=TRUE;
}



/* spit some chars out , CRs have expected effect */
/* doesnt have to be front window */
void wprint_str2(struct ws *w,char *t)
{
word x,l,l2;
	if (w->ypos >(w->h-2) )
		scroll_window(w,TRUE);							/* off bottom */
	x=w->xpos;
	l2=l=strlen(t);
	if ( l2 > (w->w-2-x) )
		l2=w->w-2-x;
	while (l--)
		{
		if (*t=='\n')
			{
			w->xpos=1;
			if (w->ypos++ >= (w->h-2) )
				scroll_window(w,TRUE);	

			update_rectangle( (word)(w->x+x),
				(word)(w->y+w->ypos-1),l2,1);
			x=w->xpos;
			t++;
			}
		else
			{
			if ( w->xpos < w->w-2 )
				w->contents[w->xpos++][w->ypos]=*t++;
			else
				break;
			}
		}
	update_rectangle( (word)(w->x+x),
		(word)(w->y+w->ypos),l2,1);
	w->written=TRUE;
}

/* as above but to front window */
void wprint_str(char *t)
{
	wprint_str2(frontwindow,t);
}

/* try to print to the frontmost command window, if possible */
void safe_print(char *t)
{
struct ws *w;

	if ( (w=frontwindow)==NULL)
		return;
	do
		{
		if (w->type==WTYPE_COMMAND)
			{
			wprint_str2(w,t);
			return;
			}
		w=w->next;
		}
	while (w!=frontwindow);
	return;
}

FILE *list_redirection;
static char redir_name[MAXPATHLEN+1];
static bool firstprint;

word list_init(char **p)
{
char *name;
char *mode;

	list_redirection=NULL;
	redir_name[0]=0;
	while (*(*p)==' ') (*p)++;
	if (**p=='>')
		{
		char c;
		mode="wt";
		(*p)++;
		if (**p=='>')		/* >> means append */
			{
			mode="rt+";
			*(*p)++;
			}
		while (*(*p)==' ') (*p)++;
		name=redir_name;
		for(;;)
			{
			if ((c=*(*p)++)==0)
				{
				(*p)--;
				break;
				}
			if (c==' ')
				break;
			*name++=c;
			}
		*name=0;
		while (*(*p)==' ') (*p)++;
		if (redir_name[0])
			{
			#if !DEMO
			if ( (list_redirection=fopen(redir_name,mode))==NULL)
				return remember_unixerr();
			if (mode[2])
				{
				fseek(list_redirection,0L,SEEK_END);
				fputc('\n',list_redirection);		/* if append then add blank */
				}
			#else
			return ERRM_NOTINDEMO;
			#endif
			}
		}
	firstprint=TRUE;
	return 0;
}

void list_deinit(void)
{
	if (list_redirection)
		{
		fclose(list_redirection);
		list_redirection=NULL;
		}
}

bool moreflag;

word list_print(char *p)
{
word event,key,mx,my;

if (list_redirection)
	{
	if (fwrite(p,1,strlen(p),list_redirection)!=strlen(p))
		{
		fclose(list_redirection);
		list_redirection=0;
		return ERRM_WRITEERROR;
		}
	event=may_get_event(&key,&mx,&my);
	if ( (event & EV_KEY) && (key==KEY_ESC) )
		return ERRM_INTERRUPTED;
	else
		return 0;
	}

if (moreflag)
	{
	/* ctrl-S ctrl-Q version */
	event=may_get_event(&key,&mx,&my);
	if (event & EV_KEY)
		{
		key&=0xFF;
		if (key==('S'-'@'))
			for(;;)
			{
			do
				event=get_event(&key,&mx,&my);
			while ( (event & EV_KEY)==0 );
			if (key==KEY_ESC)
				return ERRM_INTERRUPTED;
			key&=0xFF;
			if (key==('C'-'@'))
				return ERRM_INTERRUPTED;
			if ( (key==('Q'-'@')) || (key==' ') )
				break;
			}
		else if (key==('C'-'@'))
			return ERRM_INTERRUPTED;
		}
	safe_print(p);
	}
else
	{
	/* More version */
	if (frontwindow && (frontwindow->ypos>=(frontwindow->h-2)))
		{
		if (firstprint==FALSE)
			{
			safe_print(TX_MORE);
			do
				event=get_event(&key,&mx,&my);
			while ( (event & (EV_KEY|EV_CLICK))==0 );
			if ( (event&EV_KEY) && ((key==KEY_ESC) || ((key&0xFF)==('C'-'@'))) )
				return ERRM_INTERRUPTED;
			}
		window_cls(frontwindow);
		update_contents(frontwindow);
		}
	safe_print(p);
	firstprint=FALSE;
	}
	return 0;
}

/* spit a char into memory and on screen */
void wprint_now(word x, word y,schar c)
{

	if ( y > frontwindow->h-2 )
		return;						/* off bottom */
	frontwindow->contents[x][y]=c;
	update_rectangle( (word)(frontwindow->x+x),
		(word)(frontwindow->y+y),1,1);
	frontwindow->written=TRUE;
}

void wprint_cr()
{
	frontwindow->xpos=1;
	frontwindow->written=TRUE;
	if (frontwindow->ypos++ >= (frontwindow->h-2) )
		scroll_window(frontwindow,TRUE);	
}

void draw_title(struct ws *wptr)
{
	update_rectangle(wptr->x,wptr->y,wptr->w,1);
	update_rectangle(wptr->x,(word)(wptr->y+wptr->h-1),wptr->w,1);
	update_rectangle(wptr->x,wptr->y,1,wptr->h);
	update_rectangle((word)(wptr->x+wptr->w-1),wptr->y,1,wptr->h);
}

void clip_screen(word *x,word *y, word *w, word *h)
{
	if (*w<MINWIDTH)
		*w=MINWIDTH;
	if (*h<MINHEIGHT)
		*h=MINHEIGHT;
	if (*x<0)
		*x=0;
	if (*y<0)
		*y=0;

	if ( (*x+*w)>maxw )
		{
		*x=maxw-*w;
		if (*x<0)
			{
			*x=0;
			*w=maxw;
			}
		}

	if ( (*y+*h)>maxh )
		{
		*y=maxh-*h;
		if (*y<0)
			{
			*y=0;
			*h=maxh;
			}
		}

}

/* assumes mouse is presently visible */
void waitmouse(byte buttonstate, word *x, word *y)
{
	for (;;)
		{
		if ((mousestate &2)==buttonstate)
			return;
		if ( (mousex!=*x) || (mousey!=*y) )
			{
			hide_mouse(*x,*y);
			*x=mousex; *y=mousey;
			draw_mouse(*x,*y);
			return;
			}
		}
}

/* a click was detected in a window border */
void drag_window(struct ws *wptr, ubyte edge)
{
word xoffset,yoffset;
word x,y,w,h;
bool draw;
word cx,cy,mx,my;

	mx=mousex; my=mousey;
	x=wptr->x; y=wptr->y; w=wptr->w; h=wptr->h;
	xoffset=mx-(x<<xshift); yoffset=my-(y<<yshift);
	draw=TRUE;

	if (edge!=BD_BOTRIGHT)
		for(;;)
		{ /* move the window */
		if (draw)
			{
			plot_border(x,y,w,h,TRUE);
			draw_mouse(mx,my);
			draw=FALSE;
			}
		waitmouse(0,&mx,&my);				
		if (mousestate==0)
			break;
		cx=(mx-xoffset)>>xshift;
		cy=(my-yoffset)>>yshift;
		clip_screen(&cx,&cy,&w,&h);
		if ( (cx!=x) || (cy!=y) )
			{
			hide_mouse(mx,my);
			plot_border(x,y,w,h,FALSE);
			draw=TRUE;
			x=cx; y=cy;
			}
		}
	else
		{ /* resize the window, if possible */
		if (wptr->type==WTYPE_DEAD)
			return;						/* dead windows dont zoom */
		for (;;)
		{
		if (draw)
			{
			plot_border(x,y,w,h,TRUE);
			draw_mouse(mx,my);
			draw=FALSE;
			}
		waitmouse(0,&mx,&my);
		if (mousestate==0)
			break;
		cx=((mx+halfx)>>xshift)-x;			/* really cwidth */
		cy=((my+halfy)>>yshift)-y;			/* really cheight */
		clip_screen(&x,&y,&cx,&cy);
		if ( (cx!=w) || (cy!=h) )
			{
			hide_mouse(mx,my);
			plot_border(x,y,w,h,FALSE);
			draw=TRUE;
			w=cx; h=cy;
			}
		}
		}
	hide_mouse(mx,my);
	plot_border(x,y,w,h,FALSE);

	if (change_window((word)(wptr->number),x,y,w,h,&cx,&cy,&xoffset,&yoffset)==0)
		update_rectangle(cx,cy,xoffset,yoffset);
}

void plot_border(word x, word y, word w, word h, bool draw)
{
word i,c;
word bx,by;

	if (draw)
		{
		bx=x+w-1; by=y+h-1;
		c=w;
		i=x;
		while (c--)
			{
			border_out(i,y,BD_TITLE1,TRUE);
			border_out(i++,by,BD_HORIZ,TRUE);
			}
		i=y;
		c=h;
		while (c--)
			{
			border_out(x,i,BD_VERT,TRUE);
			border_out(bx,i++,BD_VERT,TRUE);
			}
		border_out(x,y,BD_TOPLEFT,TRUE);
		border_out(x,by,BD_BOTLEFT,TRUE);
		border_out(bx,y,BD_TOPRIGHT,TRUE);
		border_out(bx,by,BD_BOTRIGHT,TRUE);
		}
	else
		{
		update_rectangle(x,y,w,1);
		update_rectangle(x,(word)(y+h-1),w,1);
		update_rectangle(x,y,1,h);
		update_rectangle((word)(x+w-1),y,1,h);
		}
}

/* a title of NULL means dont have one */

void window_title2(struct ws *wptr, char *t, bool draw)
{
word x,i,w,h;
size_t len;
char *t2;

	w=wptr->w-1;
	h=wptr->h-1;
	/* mark logical window values */
	for (i=0; i<wptr->w; i++)				/* go across window */
		{
		wptr->contents[i][0]=BD_TITLE1;
		wptr->contents[i][h]=BD_HORIZ;
		}
	for (i=0; i<wptr->h; i++)				/* go down */
		{
		wptr->contents[0][i]=BD_VERT;
		wptr->contents[w][i]=BD_VERT;
		}
	wptr->contents[0][0]=BD_TOPLEFT;
	wptr->contents[w][0]=BD_TOPRIGHT;
	wptr->contents[0][h]=BD_BOTLEFT;
	wptr->contents[w][h]=BD_BOTRIGHT;
	/* handle title */
	if (t)
		{
		len=strlen(t);
		if (len>MAXTITLE)
			len=MAXTITLE;
		t2=wptr->title;
		if (wptr->type!=WTYPE_DIALOG)
			{
			*t2++=wptr->number+'0';
			*t2++=' ';
			strncpy(t2,t,len);						/* remember it */
			*(t2+len)=0;							/* null term */
			t2-=2;
			len+=2;
			x=(wptr->w-len-2)/2;					/* left border size */
			}
		else
			{ /* dialog windows have no number */
			stccpy(t2,t,len);
			x=(wptr->w-len)/2;
			}
		if (x<1)
			{
			x=1;								/* truncate title */
			len=wptr->w-4;
			}
		}
	else
		{
		len=0;
		x=1;
		}
	wptr->contents[x++][0]=BD_TITLE1;
	i=len;
	while (i--)
		wptr->contents[x++][0]=*t2++;		/* the new title */
	wptr->contents[x++][0]=BD_TITLE1;

	if (draw)
		draw_title(wptr);
}

void window_title(word num, char *t, bool draw)
{
	window_title2(wlist[num],t,draw);
}

/* mark a window on the screen array */
void recalcw(struct ws *w)
{
word i,j;
	for (j=0; j<w->h; j++)
		for (i=0; i<w->w; i++)
			scr_which[w->x+i][w->y+j]=w->number;
}

/* work out who owns every piece of screen */
void recalc_frontback()
{
word i,j;
struct ws *w;
	for (j=0; j<maxh; j++)
		for (i=0; i<maxw; i++)
			scr_which[i][j]=NOWINDOW;			/* clear it out */

	if (frontwindow)
		{
		w=frontwindow->prev;			/* backwindow */
		do
			{
			recalcw(w);						/* front it */
			w=w->prev;
			}
		while (w!=frontwindow->prev);
		}
}

void front_window(struct ws *neww)
{
struct ws *old;
word tx,ty,tw,th;

	if (neww==frontwindow)
		return;
	old=frontwindow;
	add_wlist(neww);
	recalc_frontback();

	if (old)
		{
		struct ws *w;
		draw_title(old);			/* old=disabled */
		/* be smart - only update area required */
		w=neww->next;
		while (w!=frontwindow)
			{
			if (inter_rectangle(w->x,w->y,w->w,w->h,
				(word)(neww->x+1),(word)(neww->y+1),
				(word)(neww->w-2),(word)(neww->h-2),
				&tx,&ty,&tw,&th))
					update_rectangle(tx,ty,tw,th);
			w=w->next;
			}
		draw_title(neww);
		}
	else
		update_rectangle(neww->x,neww->y,neww->w,neww->h);	/* inc border */

	check_command();
}

/* select the window numerically behind the front one */
void next_window()
{
byte i;

	if ( (frontwindow==NULL) || (frontwindow->prev==frontwindow) )
		return;				/* we need 0 or 1 */
	i=frontwindow->number;
	for (;;)
		{
		if (++i>=MAXWINDOW)
			i=0;
		if (i==frontwindow->number)
			return;
		if (wlist[i]->open)
			{
			front_window(wlist[i]);
			return;
			}
		}

}

/* called when someone changes a window addr */
word wchanged(void *mvar)
{
ubyte w;
	/* this code relies on the fact that the number field lies immediately after wlong */
	w=*( ((ubyte*)mvar) + sizeof(long) );
	if (wlist[w]->open)
		window_setlong((word)w, *( (ulong*)mvar ), TRUE);
	return 0;
}

void init_windows()
{
word i;
extern bool askfinish;

	frontwindow=NULL;
	frontnum=-1;
	add_reserved_sym("window",&frontnum,EXPR_WORD,NULL);
	add_reserved_sym("moreflag",&moreflag,EXPR_BYTE,alter_nothing);
	add_reserved_sym("confirmexit",&askfinish,EXPR_BYTE,alter_nothing);
	
	/* allocate all window structs now and m0-m9 */
	for (i=0; i<MAXWINDOW; i++)
		{
		char mname[4];
		if ( (wlist[i]=getzmem(sizeof(struct ws)))==NULL )
			finish(RET_NOMEM);
		if ( (wlist[i]->title=getanymem(MAXTITLE+3))==NULL )
			finish(RET_NOMEM);
		wlist[i]->next=NULL;
		wlist[i]->open=FALSE;
		wlist[i]->type=WTYPE_NONE;
		wlist[i]->lockreg=0L;
		sprintf(mname,"m%d",i);
		add_reserved_sym(mname,&(wlist[i]->wlong),EXPR_LONG,wchanged);
		}

	if (scr_which==NULL)
		finish(RET_NOMEM);
	
	recalc_frontback();

	update_rectangle(0,0,maxw,maxh);
}

/* drawnew controls redraw of new border */
void close_window(word num, bool drawnew)
{
struct ws *wptr;
	wptr=wlist[num];
	if (wptr->open==FALSE)
		return;
	switch (wptr->type)
		{
		case WTYPE_COMMAND: wdeinit_command(wptr); break;
		}
	wptr->open=FALSE;
	remove_wlist(wptr);
	recalc_frontback();
	update_rectangle(wptr->x,wptr->y,wptr->w,wptr->h);	/* the old posn */
	if (drawnew)
		if (frontwindow)
			draw_title(frontwindow);
}

/* coords include border areas, always opens to front */
/* whole window must fit on screen, min size 4x4 */
/* width or height of zero means Max */
/* title of zero means default */
word open_window(word num,word x,word y,word w,word h, char *t,byte wtype)
{
struct ws *wptr,*oldw;

	if (w==0)
		w=maxw-x;
	if (h==0)
		h=maxh-y;

	if ( (num<0) || (num>=MAXWINDOW) )
		return ERRM_BADP;

	/* clip the window so its on the screen, no matter what */
	clip_screen(&x,&y,&w,&h);

	wptr=wlist[num];
	if (wptr->open)
		close_window(num,FALSE);
	wptr->open=TRUE;

	wptr->x=x;
	wptr->y=y;
	wptr->w=w;
	wptr->h=h;
	wptr->number=num;
	wptr->type=wtype;
	wptr->magic=NULL;
	wptr->zoomed=FALSE;
	wptr->wword=0;
	wptr->wlong=0L;
	wptr->written=FALSE;

	if (t==NULL)
		t=wdef_title(wtype);

	window_cls(wptr);		/* homes cursor too */
	window_title2(wptr, t, FALSE);
	
	oldw=frontwindow;
	add_wlist(wptr);
	if (oldw)
		draw_title(oldw);					/* de-select old */
	recalcw(wptr);							/* mark on screen */
	update_rectangle(x,y,w,h);				/* redraw all new inc border */
	/* allocate any structures for this type of window */
	switch (wtype)
		{
		case WTYPE_COMMAND:	winit_command(wptr); break;
		case WTYPE_DISS:	winit_diss(wptr); break;
		case WTYPE_SMART:	winit_smart(wptr); break;
		}
	return 0;
}

/* open a spare window; returns 0 if OK, else -1 */
/* will re-use other temp windows if runs out */
word open_temp(word *num,word x,word y,word w,word h, char *t)
{
word i;
	for (i=0; i<MAXWINDOW; i++)
		if (wlist[i]->open==FALSE)
			{
			*num=i;
			return open_window(i,x,y,w,h,t,WTYPE_TEMP);
			}
	for (i=MAXWINDOW-1; i>=0; i--)
		if (wlist[i]->type==WTYPE_TEMP)
			{
			*num=i;
			return open_window(i,x,y,w,h,t,WTYPE_TEMP);
			}
	return ERRM_NOSPARE;
}

word attach_window(word num, void *magic)
{
	switch (wlist[num]->type)
		{
		case WTYPE_ASCII:
			wlist[num]->magic=magic;
			wlist[num]->wlong=1;
			break;
		default:
			break;
		}
	refill_window(num,TRUE);
	return 0;
}

/* return a number of an unused window, or -1 if none */
/* if must is set then use a reserved window */
word spare_window(bool must)
{
word i,j;

	j = must ? MAXWINDOW : MAXWINDOW-1;			// leave last one for special purposes
	for (i=0; i<j; i++)
		{
		if (wlist[i]->open==FALSE)
			return i;
		}
	return -1;
}

/* move and/or resize a window; returns update_rect as required */
word change_window(word num, word x, word y, word w, word h,
						word *rx, word *ry, word *rw, word *rh)
{
struct ws *wptr;

	if (w==0)
		w=maxw-x;
	if (h==0)
		h=maxh-y;

	if ( (num<0) || (num>=MAXWINDOW) )
			return ERRM_BADP;
	clip_screen(&x,&y,&w,&h);

	wptr=wlist[num];
	if (!wptr->open)
		return ERRM_BADWINDOW;			/* must be open */
	*rx=wptr->x; *ry=wptr->y;
	*rw=wptr->w; *rh=wptr->h;			/* old size */
	wptr->x=x; wptr->y=y;
	wptr->w=w; wptr->h=h;

	window_title2(wptr, wptr->title+2, FALSE);	/* new border, old title */

	recalc_frontback();

	if ( (*rw!=w) || (*rh!=h) )
		refill_window(num,FALSE);		/* if size changed */

	or_rectangle(rx,ry,rw,rh,x,y,w,h);	/* old or new */
	
	if ( x || y || (w!=maxw) || (h!=maxh) )
		wptr->zoomed=FALSE;				/* cannot be zoomed */

	wptr->xpos=wptr->ypos=1;			/* home cursor */
	
	if (wptr->type==WTYPE_COMMAND)
		{
		window_cls(wptr);
		start_command(wptr,"");
		wptr->written=FALSE;
		}

	return 0;
}

/* zoom (or unzoom) a window */
word zoom_window(word num)
{
word rx,ry,rw,rh;
struct ws *wptr;
word err;
word w;

	wptr=wlist[num];
	if (wptr->type==WTYPE_DEAD)
		return 0;			/* cannot zoom dead'uns */
	if (wptr->zoomed==FALSE)
		{
		wptr->ox=wptr->x; wptr->oy=wptr->y;
		wptr->ow=wptr->w; wptr->oh=wptr->h;

		w=maxw;
		if (wptr->type==WTYPE_MEM)
			{
			if (w>14)
				w -= w % 14;				/* ensure mult of 14 for memory windows */
			}
		err=change_window(num,0,0,w,0,&rx,&ry,&rw,&rh);
		if (err)
			return err;
		wptr->zoomed=TRUE;
		}
	else
		{
		err=change_window(num,wptr->ox,wptr->oy,wptr->ow,wptr->oh,
			&rx,&ry,&rw,&rh);
		if (err)
			return err;
		wptr->zoomed=FALSE;
		}
	update_rectangle(rx,ry,rw,rh);
	return 0;
}

bool any_zoomed(void)
{
word i;
	for (i=0; i<MAXWINDOW; i++)
		if (wlist[i]->open && wlist[i]->zoomed)
			return TRUE;
	return FALSE;
}

/* find out about windows */
/* assumes valid parameters */
void get_window(word num, char *title, word *x, word *y, word *w, word *h)
{
struct ws *wptr;
	wptr=wlist[num];
	strcpy(title,wptr->title+2);
	*x=wptr->x;
	*y=wptr->y;
	*w=wptr->w;
	*h=wptr->h;
}

void deinit_windows()
{
/*	if (scr_which)
		{
		freemem(scr_which);
		scr_which=NULL;
		}
*/
}

/* dump a window to the printer */
word dump_window(word wnum)
{
word err; struct ws *w;
word x,y;

	if (err=pr_init())
		return err;
	w=wlist[wnum];
	for (y=1; y<(w->h-1); y++)
		{
		for (x=1; x<(w->w-1); x++)
			pr_out(w->contents[x][y]);
		pr_cr();
		}
	return 0;
}

/*************** command handler ****************/

#define	MAXEDIT	255

#define COMMANDMAX	10
char **command_history;							/* ptr to array */
short command_index;							/* how many in there */

struct edit { word xstart, ystart;				/* posn of top left */
	word xoff;
	word length;
	short cmdindex;
	uchar line[MAXEDIT+1];
	};

word list_chistory(char *p)
{
word i,err;
	i=0;
	err=0;
	while ( (err==0) && (i<command_index) )
		{
		sprintf(linebuf,"%2d %s\n",i+1,command_history[i++]);
		err=list_print(linebuf);
		}
	return err;
}

void start_command(struct ws *w, char *start)
{
struct edit *e;
	if ( (w==NULL) || (w->open==FALSE) )
		return;							/* just in case */
	if (defining_proc)
		wprint_str2(w,"+");
	e=(struct edit *)w->magic;
	e->xstart=w->xpos;
	e->ystart=w->ypos;
	e->xoff=0;
	e->length=min(strlen(start),MAXEDIT);
	e->cmdindex=-1;						/* means nowhere */
	stccpy(e->line,start,e->length);
}

void winit_command(struct ws *w)
{
struct edit *e;

	if (command_history==NULL)
		{ /* allocate a once-only buffer of long ptrs */
		short i; char *cbuf;
		if ( (command_history=getmem(COMMANDMAX*4))==NULL)
			finish(RET_NOMEM);
		  /* and a buffer for all the lines */
		if ( (cbuf=getzmem( (MAXEDIT+1)*COMMANDMAX ))==NULL)
			finish(RET_NOMEM);
		for (i=0; i<COMMANDMAX; i++)
			{
			command_history[i]=cbuf;
			cbuf+=(MAXEDIT+1);
			}
		command_index=0;
		}
	e=(struct edit *)getzmem(MAXEDIT+1);
	if (e!=NULL)
		{
		w->magic=(void *)e;
		start_command(w,"");
		}
	else
		w->type=WTYPE_NONE;			/* if no mem */
}

void wdeinit_command(struct ws *w)
{
	if (w->magic)
		freemem(w->magic);
	w->magic=NULL;
}

void key_command(word key)
{
struct edit *e;
bool redraw;

	redraw=FALSE;

	e=frontwindow->magic;

	if (key==KEY_CLEAR)
		{
		while (e->length>=0)
			{
			wprint_now( (word)(e->xstart+e->length--),e->ystart,' ');
			}
		e->length=e->xoff=0;
		e->line[0]=0;
		e->cmdindex=-1;
		}
	else if (key==KEY_LEFT)
		{
		if (e->xoff)
			e->xoff--;
		}
	else if (key==KEY_RIGHT)
		{
		if ( e->xoff < e->length )
			e->xoff++;
		}
	else if (key==KEY_PAGELEFT)
		e->xoff=0;
	else if (key==KEY_PAGERIGHT)
		e->xoff=e->length;
	else if (key==KEY_BACKSPACE)
		{
		if ( e->xoff )
			{
			word l,x; uchar *p,*q;
			l=e->length-e->xoff;			/* chars to shovel */
			p=e->line+e->xoff-1;
			q=p+1;
			x=e->xstart+e->xoff-1;
			while (l--)
				{
				*p++=*q++;
				wprint_now( x++,e->ystart,*(p-1));
				}
			*p=0;
			e->xoff--;
			e->length--;
			wprint_now( x, e->ystart, ' ');
			}
		}
	else if (key==KEY_DEL)
		{
		if (e->length!=e->xoff )
			{
			word l,x; uchar *p,*q;
			l=e->length-e->xoff-1;			/* chars to shovel */
			p=e->line+e->xoff;
			q=p+1;
			x=e->xstart+e->xoff;
			while (l--)
				{
				*p++=*q++;
				wprint_now( x++,e->ystart,*(p-1));
				}
			*p=0;
			e->length--;
			wprint_now( x, e->ystart, ' ');
			}
		}
	else if (key==KEY_HELP)
		{ /* Help means try to find the symbol */
		unsigned char *sym; word diff;
			if ( (e->xoff!=e->length) || (e->length==0) )
				{
				/* when not at end or empty, its easy */
				sym=(unsigned char*)help_symbol(NULL,0,&diff);
				}
			else
				{
				/* use what the user typed */
				sym=(unsigned char*)help_symbol(
						e->line+e->length,e->length,&diff);
				if (sym)
					{
					char *p;
					p=e->line+e->length-diff;
					if (diff<=strlen(sym))
						{
						/* new symbol longer than old one (or same) */
						memcpy(p,sym,diff);		/* copy the start of the symbol */
						sym+=diff;				/* extra chars copied below */
						}
					else
						{
						word x;
						/* new symbol shorter than old one */
						strcpy(p,sym);
						diff-=strlen(sym);			/* chars to delete */
						e->length-=diff;
						e->xoff-=diff;
						x=e->xstart+e->length;
						while (diff--)
							wprint_now( x++, e->ystart, ' ');
						sym=NULL;
						}
					redraw=TRUE;						/* to show the new start */
					}
				}
			if (sym)
				{
				while (*sym)
					key_command((word)(*sym++));	/* pretend key presses */
				}
		}
	else if ( (key==KEY_RETURN) || (key==KEY_ENTER) )
		{
		word err; struct ws *old;

		if (e->line[0])	/* dont record empty lines */
			{		
			/* remember the command in the buffer */
			if (command_index==COMMANDMAX)
				{ /* we are full so shuffle all back one */
				  /* and diddle the pointers */
				  char *temp;
					temp=command_history[0];
					movmem(command_history+1,command_history,
						(COMMANDMAX-1)*4);
					strcpy(command_history[COMMANDMAX-1]=temp,e->line);
				}
			else
				{
				strcpy(command_history[command_index++],e->line);
				}
			}
		e->cmdindex=-1;

		frontwindow->xpos=e->xstart+e->length;
		frontwindow->ypos=e->ystart;
		wprint_cr();
		old=frontwindow;
		if (frontwindow->type==WTYPE_COMMAND)
			{
			err=do_command(e->line);
			if (old->open==FALSE)
				{ /* I have been closed; if no other command windows then bye bye */
				word i;
				for (i=0; i<MAXWINDOW; i++)
					if ( (wlist[i]->open) && 
						(wlist[i]->type==WTYPE_COMMAND) )
							{
							front_window(wlist[i]);
							return;
							}
				finish(0);
				}
			else
				front_window(old);
			}
		else
			{ /* being used as a line editor */
			strcpy(line_buffer,e->line);
			return;
			}
		if (err)
			{
			wprint_str(error_message(err));
			wprint_cr();
			}
		start_command(frontwindow,"");
		}
	else if ( (key==KEY_UP) || (key==KEY_DOWN) || (key==KEY_PAGEUP) || (key==KEY_PAGEDOWN) )
		{
		short i;
		if ( (i=e->cmdindex)==-1)
			i=command_index;

		if ( (key==KEY_UP) || (key==KEY_PAGEUP) )
			if (i>0)
				i--;
			else
				i=-1;
		else /* KEY_DOWN */
			if ( (i<(COMMANDMAX-1)) && (*(command_history[i+1])) )
				i++;
			else
				i=-1;
		
		if (i>=0)
			{
			/* clear the old one */
			while (e->length>=0)
				{
				wprint_now( (word)(e->xstart+e->length--),e->ystart,' ');
				}
			strcpy(e->line,command_history[i]);
			e->length=e->xoff=strlen(e->line);
			redraw=TRUE;
			e->cmdindex=i;
			}
		}
	else if (key&0xFF)			/* normal ASCII key */
		{
		if (e->length < MAXEDIT)
			{
			word l,x; uchar *p,*q;
			l=e->length-e->xoff;			/* chars to shovel */
			p=e->line+e->length;		/* points to null */
			q=p+1;
			x=e->xstart+e->length;
			*q=0;
			while (l--)
				{
				*--q=*--p;
				wprint_now( x--, e->ystart, (schar)*p);
				}
			*p=(uchar)key;
			wprint_now(x,e->ystart,(schar)key);
			e->length++;
			e->xoff++;
			}
		}

	if (redraw)		/* slow redraw */
		{
		word x; uchar *p;
		x=e->xstart;
		p=e->line;
		while (*p)
			{
			wprint_now( x++,e->ystart,*p++);
			}
		}
	frontwindow->written=FALSE;
}

void xor_command()
{
struct edit *e;
	if ( (frontwindow) && ( 
		(frontwindow->type==WTYPE_COMMAND) ||
			(frontwindow->type==WTYPE_DIALOG)
				))
		{
		e=(struct edit *)frontwindow->magic;
		cursor_out( (word)(frontwindow->x+e->xstart+e->xoff), 
			(word)(frontwindow->y+e->ystart) );
		}
}

/******************** event handling ********************/


/* handle a key-press; we have a current window, BTW */
void do_key(word key)
{
	/* junk first, then let new key happen during draw */
	if ( (key==KEY_LEFT) || (key==KEY_RIGHT) || (key==KEY_UP) ||
		(key==KEY_DOWN) || (key==KEY_PAGEUP) || (key==KEY_PAGEDOWN) )
			junk_keys(key);

	if (key==KEY_TAB)
		next_window();
	else
		switch(frontwindow->type)
		{
		case WTYPE_COMMAND:
			if ( ( ((struct edit *)(frontwindow->magic))->length) ||
					(!do_controlkey(key)) )
				key_command(key);
			break;
		case WTYPE_DISS:
			key_diss(key); break;
		case WTYPE_MEM:
			key_mem(key); break;
		case WTYPE_ASCII:
			key_ascii(key); break;
		case WTYPE_SMART:
			key_smart(key); break;
		case WTYPE_WATCH:
			key_watch(key); break;
		case WTYPE_LOCAL:
			key_local(key); break;
		default:
			do_controlkey(key);
		}
}

/* guaranteed never to return */
void handle_events()
{
word key,mx,my,event;

do
	{
	check_command();
	xor_command();
	event=get_event(&key,&mx,&my);
	xor_command();
	if (event&EV_CLICK)
		{
		word w; ubyte edge;
		w=which_window(&mx,&my,&edge);
		if (w>=0)
			{
			if (frontwindow!=wlist[w])
				front_window(wlist[w]);
			else if (edge)
				drag_window(wlist[w],edge);
			}
		}
	if (event&EV_KEY)
		{
		if (frontwindow)
			do_key(key);
		}
	if (event&EV_ALT)
		{
		do_altkey(key);
		}
	if (event&EV_CLICK)
		{
		}
	}
while (1);
}

/* the actual program itself */
int main(int argc, char *argv[])
{
word res,comerr;
long default_diss, default_dlock;
char fname[MAXPATHLEN+1];

	init_machine();
	comerr=init_commands(&argc,&argv);
	init_graphics();
	init_windows();
	init_proc();
	init_symbols();
	init_exceptions();
	init_diss();
	init_mach2(&default_diss,&default_dlock);		/* handles machine-specific symbols */
	init_source();

	res=open_window(1,0,0,30,14,NULL,WTYPE_REGS);
	refill_window(1,TRUE);

	res=open_window(2,30,0,50,21,NULL,WTYPE_DISS);
	wlist[2]->wlong=default_diss;
	window_lock(2,(char*)default_dlock,TRUE,"PC",FALSE);	/* but dont recalc */
	refill_window(2,TRUE);

	res=open_window(3,0,13,30,8,NULL,WTYPE_MEM);
	wlist[3]->wlong=0L;
	refill_window(3,TRUE);

	res=open_window(0,0,20,80,5,am_auto ? TX_AADVERT : (malloc_debug_flag ? TX_ADVERTDEBUG : TX_ADVERT),WTYPE_COMMAND);

	/* get global settings */
	if (find_file(SCRIPT_STARTUP,fname,NULL))
		{
		if (res=cl_script(fname))
			{
			sprintf(linebuf,TX_DURING,error_message(res),fname);
			safe_print(linebuf);
			}
		}

	res=cl_script(SCRIPT_LSTARTUP);
	if ( res && (res!=ERRM_UNIXERR) )
		{
		sprintf(linebuf,TX_DURING,error_message(res),SCRIPT_LSTARTUP);
		safe_print(linebuf);
		}

	if (comerr)
		{
		sprintf(linebuf,TX_DURING,error_message(comerr),VAR_STARTUP);
		safe_print(linebuf);
		}

	/* read the help file */
	if (find_file(HELP_STARTUP,fname,NULL))
		{
		FILE *fp; char *p;
		long hsize;
		#if DEMO
		hsize=get_demo_long( 3 );
		#else
		hsize=check_flen(fname);
		#endif
		p=NULL;
		if (hsize>0)
			{
			if (p=getmem(hsize+2))
				{
				fp=special_fopen(fname,"rt");
				if (fp)
					{
					help_list=p;
					while (special_fgets(p,255,fp))
						{
						if (*p==0)
							continue;
						if (*(p+strlen(p)-1)!='\n')
							{
							*(p+strlen(p)-1)='\n';		/* ensure CR on end */
							*(p+strlen(p))=0;
							}
						if (*p=='\n')
							continue;
						help_count++;
						p+=strlen(p)+1;		/* convert to null termed string list */
						}
					fclose(fp);
					}
				else
					{
					freemem(p);
					}
				}
			}
		}

	if ( frontwindow && (frontwindow->type==WTYPE_COMMAND) )
		start_command(frontwindow,"");

	if ( (am_auto==0) || (tsr_wait) || check_tsr_wait() )
		{
		parse_cmdline(argc, argv);
		handle_events();
		}
	else
		{
		finish(0);
		/* we only get here if we're a TSR */
		handle_events();
		}
	/* we never, ever get here, but this stops the compiler bitching */
	return 0;
}

/* always use this instead of exit */
/* MAY RETURN if TSR-ing! */
word finish(word returncode)
{
	if ( (am_auto) && (returncode==0) )
		{
		if ( (returncode=finish_tsr())==0 )
			return 0;
		}

	switch (progstate)
		{
		case PSTATE_STOPPED:
			kill_prog(); break;
		}
	deinit_diss();
	deinit_mach2();
	deinit_exceptions();
	deinit_windows();
	deinit_graphics();
	deinit_machine();
	if (returncode)
		end_message(TRUE,TX_FATALERROR(returncode));
	exit(returncode);
}

void internal_error(word err)
{
	printf("**Internal error %d***\n",err);
	wait_key();
	finish(0);
}

