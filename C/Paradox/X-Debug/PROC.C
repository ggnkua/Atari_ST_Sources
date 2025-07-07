
/************* Mon processor specifics *************/
/* 68000 only, of course */

/* brk on/off needs finishing */
/* conditionals need work */

#include "mon.h"
#include "window.h"
#include "regs.h"
#include "diss2.h"

txt(TX_TERMINATED);
txt(TX_EXCEPTION);
txt(TX_LATTICE5ST); txt(TX_TURBOC); txt(TX_BASIC);
txt(TX_BRKLIST);
txt(TX_BRKLIST2);
txt(TX_WHILETERMINATING);
txt(TX_TSR);
extern char *TX_EXNAME(word);
extern char *TX_BRKTYPE(word);

struct regs68k regs;

bool followtraps;			/* true to follow; false to not (default) */
bool fastsource=TRUE;		/* true for faster source step */
word proctype;				/* 0,10,20,30,40 etc (DISPLAY ONLY) */
ulong progstart;
char linkreg=6;				/* 0-6 of LINK register */
bool automain=TRUE;
bool autoccr; bool autodiv0;
extern ulong backstep;
extern ubyte user_compiler_type;

#define MAXILEN	10

/*********** checksum code ************/

#if 0
/* more powerful version reqd RSN */
ulong checksum(ulong where, ulong end)
{
ubyte *x;
ulong c;
	x=(ubyte*)where;
	c=0x12345678;
	while ( ((ubyte*)end)!=x )
		{
		c+=(ulong)peekb(x++);
		}
	return c;
}
#endif

/*********** breakpoint code ***************/
#define MAXBRK	16

typedef struct {
	ulong where;
	word btype;
	bool on,autoclear;
	uword old;
	char *count;			/* also ulong */
	} brk;

brk brklist[MAXBRK];

/* returns empty brk entry, or re-used one with same loc */
brk *spare_brk(ulong where)
{
word i;
void clear_brk(brk *);

	for (i=0; i<MAXBRK; i++)
		{
		if (brklist[i].btype==0)
			return &brklist[i];
		if (brklist[i].where==where)
			{
			clear_brk(&brklist[i]);		/* to free cond strings */
			return &brklist[i];
			}
		}
	return NULL;
}

/* find the breakpoint for a given PC */
/* may be turned off */
brk *find_brk(ulong where)
{
word i;
brk *b;
	b=brklist;
	for (i=0; i<MAXBRK; i++,b++)
		if ( (b->btype) && (b->where==where) )
			return b;
	return NULL;
}

/* see if a break within a range of memory */
bool find_range_brk(long start, long end)
{
word i;
brk *b;

	b=brklist;
	for (i=0; i<MAXBRK; i++,b++)
		{
		if (
				(b->btype) && 
				(b->where>=start) &&
				(b->where<end)
			)
			return TRUE;
		}
	return FALSE;
}


void clear_brk(brk *b)
{
	if (b==NULL)
		{ /* NULL means all of em, so recurse a little */
		short i;
		for (i=0; i<MAXBRK; i++)
			if (brklist[i].btype)
				clear_brk(&brklist[i]);
		return;
		}
/* all types work the same */
	if (b->on)
		pokew(b->where,b->old);		/* dont care if fails */

	if (b->btype==BTYPE_COND)		/* well almost */
		{
		freemem(b->count);			/* free the string */
		b->count=NULL;
		}
	b->btype=0;
}

word clear_break(ulong where)
{
brk *b;
	b=find_brk(where);
	if (b==NULL)
		return ERRM_BRKNOTFOUND;
	clear_brk(b);
}

void on_brk(brk *b)
{
	if (b==NULL)
		{ /* NULL means all of em, so recurse a little */
		short i;
		for (i=0; i<MAXBRK; i++)
			if (brklist[i].btype)
				on_brk(&brklist[i]);
		return;
		}
	if (b->on==FALSE)
		{	/* RSN do something!! */
		;
		}
}


void off_brk(brk *b)
{
	if (b==NULL)
		{ /* NULL means all of em, so recurse a little */
		short i;
		for (i=0; i<MAXBRK; i++)
			if (brklist[i].btype)
				off_brk(&brklist[i]);
		return;
		}
	if (b->on)
		{	/* RSN do something!! */
		;
		}
}

word set_break(ulong where, word btype, char *count, bool autoclear)
{
brk *b;
word err;

	if (where & 1)
		return ERRM_ODD;
	if ( (btype<=0) || (btype>=BTYPE_MAX) )
		return ERRM_BADP;

	if (b=find_brk(where))
		clear_brk(b);				/* re-use existing brk */
	else if ( (b=spare_brk(where))==NULL )
		return ERRM_BRKFULL;

	if (btype==BTYPE_COND)
		{
		/* we'de better make a more permanent string */
		char *tmp;
		if ( (tmp=getmem(strlen(count)))==NULL )
			return ERRM_NOMEMORY;
		strcpy(tmp,count);
		count=tmp;
		}
	
	b->old=peekw(where);
	err=pokew(where,BRKOP);
	if (err)
		return err;
	b->where=where;
	b->btype=btype;
	b->count=count;
	b->on=TRUE;
	b->autoclear= btype==BTYPE_ALWAYS ? FALSE : autoclear;
	return 0;
}

/* like above put passed a str pointer to the rest of things */
word set_break_txt(ulong where, word btype, bool autoclear, char *p)
{
long count;
word err;
char *start;

	while (*p==' ')
		p++;
	if ( (*p==0) || (btype==BTYPE_ALWAYS) )				/* no more text */
		{
		if ( (btype!=BTYPE_COND) && (btype!=BTYPE_TRAP) )
			return set_break(where,btype,
				btype==BTYPE_RECORD ? (char*)0 : (char*)1,autoclear);
		else
			return ERRM_BADEXPRESSION;
		}
	switch (btype)
		{
		case BTYPE_COUNT: case BTYPE_RECORD:
			if (err=get_expression(&p,EXPR_LONG,&count)) return err;
			break;
		case BTYPE_COND:
			start=p;
			if (err=check_expression(&p,EXPR_LONG,&count)) return err;
			count=(long)start;
			break;
		case BTYPE_TRAP:
			{
			byte tnum;
			/* fn TRAP tnum - special case */
			while (*p==' ')
				p++;
			if (err=get_expression(&p,EXPR_BYTE,&tnum)) return err;
			return trap_break(tnum,(word)where);
			break;
			}
		default:
			return ERRM_INVALIDBRK;
		}
	return set_break(where,btype,(char*)count,autoclear);
}

/* return TRUE if program should resume execution */
/* b was found with a call to find_brk */
/* if tracing is True then we're about to single-step */
bool hit_brk(brk *b, bool tracing)
{
bool cont;

	cont=FALSE;
	switch (b->btype)
		{
		case BTYPE_COUNT:
			// permanent count brks always break once count reaches 0
			if ( (b->autoclear==FALSE) && (b->count==0L) )
				break;
			if (--b->count)
				cont=TRUE;
			break;
		case BTYPE_RECORD:
			b->count++;
			cont=TRUE;
			break;
		case BTYPE_ALWAYS:
			cont=tracing;		/* so we can step them */
			break;
		case BTYPE_COND:
			{
			word err; long result; char *p;
			p=b->count;
			err=get_expression(&p,EXPR_LONG,&result);
			while (*p==' ')
				p++;
			if ( (err==0) && (*p) )
				err=ERRE_CRAPAFTER;
			if ( (err) || (result==0) || tracing )
				cont=TRUE;
			else
				cont=FALSE;
			break;
			}
		default:
			cont=FALSE;			/* just in case */
			break;
		}
	if ( (cont==FALSE) && (b->autoclear) )
		clear_brk(b);

	return cont;
}

bool check_brk(word *op,ulong x)
{
brk *b;
	if (b=find_brk(x))
		{
		*op=b->old;
		return TRUE;
		}
	return FALSE;
}

/* used by the disassembler to get the string to put on the end of a line */
char *diss_brk(char *p,ulong where)
{
brk *b;
	b=find_brk(where);
	if (b)
		{
		*p++=' ';
		*p++='[';
		switch (b->btype)
			{
			case BTYPE_COUNT:
				p=sprintlong(p,(ulong)b->count,FALSE);
				break;
			case BTYPE_RECORD:
				*p++='=';
				p=sprintlong(p,(ulong)b->count,FALSE);
				break;
			case BTYPE_ALWAYS:
				*p++='*';
				break;
			case BTYPE_COND:
				{
				word elen; char *e;
				elen=strlen(e=b->count);
				if (elen>8) elen=8;
				*p++='?';
				while (elen--)
					*p++=*e++;
				if (*e)
					*p++='.';
				break;
				}
			default:
				*p++='!';
				break;
			}
		*p++=']';
		}
	return p;
}

void brk_ascii(char *buf, brk *b, char eol)
{
short i;
char neat[100];

	value_to_ascii(b->where,neat,15);
	i=b-&brklist[0];				/* index */
	
	if (b->autoclear==FALSE)
		{
		char *p;
		p = neat+strlen(neat);
		*p++ = ' ';
		*p++ = 'P';
		*p = 0;
		}
	
	switch (b->btype)
	{
	case BTYPE_COND:
		sprintf(buf,TX_BRKLIST,i,b->where,
			TX_BRKTYPE(BTYPE_COND),b->count,neat,eol);
		break;
	case BTYPE_ALWAYS:
		sprintf(buf,TX_BRKLIST,i,b->where,
			TX_BRKTYPE(BTYPE_ALWAYS),"",neat,eol);
		break;
	default:
		sprintf(buf,TX_BRKLIST2,i,b->where,
			TX_BRKTYPE(b->btype),(ulong)b->count,neat,eol);
	}
}

word brk_list(char *p)
{
brk *b; word i; word err;
	b=&brklist[0];
	for (i=0; i<MAXBRK; i++)
		{
		if (b->btype)
			{
			brk_ascii(linebuf,b,'\n');
			if (err=list_print(linebuf))
				return err;
			}
		b++;
		}
	return 0;
}

/* BRK window handler; pretty straightforward cos we dont allow scrolling */
bool refill_break(struct ws *wptr)
{
brk *b; word i;

	b=&brklist[0];
	for (i=0; i<MAXBRK; i++)
		{
		if (b->btype)
			{
			brk_ascii(linebuf,b,0);
			wprint_line(wptr,linebuf,FALSE);
			diss(b->where,FALSE);
			linebuf[0]=0;
			strcattab(linebuf,dissbuf,TRUE,8);
			wprint_line(wptr,linebuf,FALSE);
			}
		b++;
		}
	return TRUE;
}

/***************** Watch window code **************/

/* the watch list is a global forward linked list. Each window always has the
	same stuff in it */

/* the wlong field in each window refers to the starting index. For efficiency,
	we only calculate the minimum to display */

struct watchstuff {
	struct watchstuff *next;
	char *expr;
	char *fmt;
	} *watchlist;

/* 1=open if not, 2=refill if open */
void check_watch_open(word action)
{
word i;
bool found;
word spare;
	found=FALSE; spare=-1;
	for (i=0; i<MAXWINDOW; i++)
		{
		if (wlist[i]->open)
			{
			if (wlist[i]->type==WTYPE_WATCH)
				{
				found=TRUE;
				if (action&2)
					refill_window(i,TRUE);
				}
			}
		else
			if (spare==-1)
				spare=i;
		}
		
	if ( (action&1) && (found==FALSE) && (spare!=-1) )
		if (open_window(spare,0,0,30,5,NULL,WTYPE_WATCH)==0)
			refill_window(spare,TRUE);
		
}

/* try to find owner of Nth watch item. Returns NULL if not there (ie goto front) */
/* (returns wrong value in case of 1) */
struct watchstuff *getwatch(word which)
{
struct watchstuff *w;
	if ( (which<=0) || (watchlist==NULL) )
		return NULL;
	w=watchlist;
	if ( (which-=2) <=0 )
		return w;					/* wrong for 1 but must return non-NULL */
	do
		{
		if (w->next==NULL)
			return NULL;
		w=w->next;
		}
	while (--which);
	return (w->next==NULL) ? NULL : w;
}

/* fmt can be null for default format. Where of 0 means add, others mean number to replace */
word add_watch(char *expr, char *fmt, word where)
{
struct watchstuff *new;
struct watchstuff *watch,*old;

	new=getmem(sizeof(struct watchstuff)+strlen(expr)+
		(fmt ? strlen(fmt)+2 : 0) );
	if (new==NULL)
		return ERRM_NOMEMORY;

	/* add to correct posn in list */
	watch=getwatch(where);

	if (watch==NULL)
		{
		/* add to front */
		new->next=watchlist;
		watchlist=new;
		old=NULL;
		}
	else if (where==1)
		{
		/* replace 1st item (if not there then getwatch returns NULL) */
		old=watchlist;
		new->next=old->next;
		watchlist=new;
		}
	else
		{
		/* arbritary replacement */
		old=watch->next;
		new->next=old->next;
		watch->next=new;
		}

	freemem(old);		/* might be NULL but thats OK */

	new->expr=(char*)new+sizeof(*new);
	strcpy(new->expr,expr);
	if (fmt)
		{
		new->fmt=new->expr+strlen(expr)+1;
		strcpy(new->fmt,fmt);
		}
	else
		new->fmt=NULL;

	check_watch_open(1+2);
	return 0;	
}

word kill_watch(word n)
{
struct watchstuff *w;

	if (n==-1)
		{
		struct watchstuff *temp;
		w=watchlist;
		while (w)
			{
			temp=w->next;
			freemem(w);
			w=temp;
			}
		watchlist=NULL;
		}
	else
		{
		struct watchstuff **last;
		word i;
		i=1;
		last=&watchlist;
		while (*last)
			{
			if (i++==n)
				{
				w=*last;
				*last=(*last)->next;
				freemem(w);
				break;
				}
			last=&((*last)->next);
			}
		}
	check_watch_open(2);
	return 0;
}

/* this should be in-line? */
char *eol(char*p)
{
	while (*p)
		p++;
	return p;
}

bool refill_watch(struct ws *wptr)
{
struct watchstuff *w;
char *p;
int i;
uword start;
word lines;

	start=(uword)(wptr->wlong);
	w=watchlist; i=1;
	while (start-- && w)
		{
		i++;
		w=w->next;
		}
	if (w==NULL)
		return TRUE;

	lines=frontwindow->h-2;

	while (w && lines--)
		{
		sprintf(linebuf,"%d %s",i++,w->expr);
		p=eol(linebuf);
		*p++=' ';
		if (w->fmt)
			{
			strcpy(p,w->fmt);
			p=eol(p);
			*p++=' ';
			}
		format_expr(p,w->expr,w->fmt);
		wprint_line(wptr,linebuf,TRUE);
		w=w->next;
		}
	return TRUE;
}

void key_watch(word key)
{
word adjust;
word lines;
uword start,count;
struct watchstuff *w;

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	lines=frontwindow->h-2;
	adjust=0;
	start=(uword)(frontwindow->wlong);

	count=0;
	w=watchlist;
	if (w==NULL)
		return;

	while (w)
		{
		count++;
		w=w->next;
		}

	if (key==KEY_DOWN)
		{
		if ( (count-start)>lines)
			adjust=1;
		}
	else if (key==KEY_UP)
		{
		if (start)
			adjust=-1;
		}
	else
		return;

	if (adjust)
		{
		frontwindow->wlong+=adjust;
		window_cls(frontwindow);
		refill_watch(frontwindow);
		update_contents(frontwindow);
		}
}

/***************** Recalc World ***************/

/* memory and/or regs have changed; recalc & redisplay */
/* bool allows forcible changes */
void world_changed(bool force)
{
word rx,ry,rw,rh;
struct ws *w;
bool add,ch; long new;

	rx=ry=rw=rh=0;					/* clean rect to start with */
	if ( (w=frontwindow)==NULL )
		return;
	add=FALSE;
	do
		{
		if (force)
			ch=lockchanged(w,&new);
		else
			{
			ch=FALSE;
			new=w->wlong;
			}
		switch (w->type)
			{
			case WTYPE_REGS:
				window_cls(w);
				refill_regs(w);
				add=TRUE;
				break;
			case WTYPE_MMU:
				window_cls(w);
				refill_mmu(w);
				add=TRUE;
				break;
			case WTYPE_MEM:
				if ( (mayrefill_mem(w,new)) || ch || force )
					{
					window_cls(w);
					refill_mem(w);
					add=TRUE;
					}
				break;
			case WTYPE_DISS:
				if ( (mayrefill_diss(w,new,FALSE)) || ch || force )
					{
					add=TRUE;
					window_cls(w);
					refill_diss(w);
					}
				break;
			case WTYPE_SMART:
				if ( (mayrefill_smart(w,new,FALSE)) || ch || force )
					{
					add=TRUE;
					window_cls(w);
					refill_smart(w);
					}
				break;
			case WTYPE_BREAK:
				window_cls(w);
				refill_break(w);
				add=TRUE;
				break;
			case WTYPE_WATCH:
				window_cls(w);
				refill_watch(w);
				add=TRUE;
				break;
			case WTYPE_LOCAL:
				window_cls(w);
				refill_local(w);
				add=TRUE;
				break;
			case WTYPE_FPU:
				window_cls(w);
				refill_fpu(w);
				add=TRUE;
				break;
			}
		if (add)
			{
			or_rectangle(&rx,&ry,&rw,&rh,(word)(w->x+1),(word)(w->y+1),
				(word)(w->w-2),(word)(w->h-2) );
			add=FALSE;
			}
		w=w->next;
		}
	while (w!=frontwindow);
	if (rw || rh)
		update_rectangle(rx,ry,rw,rh);
}

/* returns TRUE if the address is a subroutine which has in-line params */
bool checkinline(long x)
{
int i;
	if (compiler_type!=CTYPE_BASIC)
		return FALSE;
	for (i=0; i<DISS_SPECIAL; i++)
		if ( x==diss_special_long[i] )
			return TRUE;
	return FALSE;
}

/* returns non-zero if code is a (recognised) builtin function */
long isbuiltin(long pc)
{
word opcode,masked;
ulong l;
	opcode=peekw((ulong)pc);
	if ( (opcode&0xFFF8)==0x4A18 )
		{
		/* tst.b (an)+ */
		if (peekw((ulong)(pc+2))==0x66FC)		/* bne.s *-2 (strlen) */
			return pc+4;
		else
			return 0L;
		}

	masked=opcode&0xE1F8;
	if (masked==0x00D8)
		{
		/* move.x (An)+,(An+) */
		if (peekw((ulong)(pc+2))==0x66FC)		/* bne.s *-2 (strcpy) */
			return pc+4;
chkend:		l=(peekl((ulong)(pc+2)));
		if (	/* memcpy */
			( (l&0xFFF8FFFF)==0x51C8FFFC )	||	/* dbf dn,*-2 */
			( (l&0xFFF8FFFF)==0x538064FA )		/* subq.l #1,dn, bcc.s */
		   )
			return pc+6;
		}
	else if (masked==0xC0)
		{
		/* move.x dn,(An)+ */
		goto chkend;						/* poor practice but saves bytes */
		}
	return 0L;	
}

#define getsp	regs.sr & 0x2000 ? regs.ssp : regs.aregs[7]

word last_exception;
#define FLIPSCREEN	((flags&EMFLAG_NOSCREEN)==0)
extern char waitname[];

/* either start a program from scratch (brk inserted) */
/* or resume a paused program */
/* or do something else */
/* can return error code if something is bad */
/* if flags then no screen switching done  or no display */
word execute_prog(byte mode, word *sometime, word flags)
{
word start_exec(),resume_exec(),resume_trap(),start_tsr(word*);
void remember_history(word);
brk *isbrk;
word realsr;
bool refresh;
#define SPRINTMAX	19
char lbuf[SPRINTMAX+1];
long oldsp;
bool sourcespeed;
bool havehidden = FALSE;

	refresh=FALSE;
	isbrk=NULL;
	sourcespeed=fastsource;

	if (mode==EM_TSR)
		must_hide_screen();
		
	else if (FLIPSCREEN)
		may_hide_screen();

	if (mode==EM_KILL)
		{
		if (am_auto)
			{
			progstate=PSTATE_RUNNING;
			last_exception=kill_prog();
			goto doneterm;
			}
		else if (progstate==PSTATE_STOPPED)
			{
			progstate=PSTATE_RUNNING;
			last_exception=kill_prog();
			if (last_exception)
				safe_print(TX_WHILETERMINATING);
			goto doneterm;
			}
		else
			{
			if (FLIPSCREEN) must_show_screen();
			return ERRM_CANNOTKILL;
			}
		}

run_again:

	if (mode==EM_SOURCESTEP)
		oldsp=getsp;

	if ( (mode!=EM_START) && (mode!=EM_TSR) )
		if ( (regs.pc&1) || (regs.ssp==0) || (regs.ssp&1) ||
				(progstate!=PSTATE_STOPPED) )
			{
			if (FLIPSCREEN)	must_show_screen();
			return ERRM_NORUN;
			}

	/* important that these only called from identical sp/env */
	if (mode==EM_START)
		{
		progstate=PSTATE_RUNNING;
		last_exception=start_exec();
		refresh=TRUE;
		}
	else if (mode==EM_TSR)
		{
		sprintf(linebuf,TX_TSR,loaded_high ? 0L : sometime);
		end_message(FALSE,linebuf);
		progstate=PSTATE_RUNNING;
		last_exception=start_tsr(sometime);
		refresh=TRUE;
		}
	else
		{
		/* if about to run directly at a breakpoint then remove it */
		if (isbrk=find_brk(regs.pc))
			if (isbrk->on)
				{
				realsr=regs.sr&0xC000;
				refresh=TRUE;
				if (realsr)					/* about to trace */
					if (hit_brk(isbrk,TRUE)==FALSE)
						{
						last_exception=1;				/* pretend we hit it */
						refresh=TRUE;
						remember_history(1);
						goto gotex;
						}
				pokew(regs.pc,isbrk->old);
				regs.sr&=0xbfff;
				regs.sr|=0x8000;			/* Trace it */
				}
			else
				isbrk=NULL;
			
run2:
		if ( ((mode==EM_SOURCESKIP)||(mode==EM_SOURCESTEP)) && (regs.sr&0x8000) )
			{
			/* may be about to step an in-line function. Works for any language */
			long after;
			if ( after=isbuiltin(regs.pc) )
				{
				if (set_break(after,BTYPE_TRACE,(char*)1L,TRUE)==0)
					regs.sr&=0x3FFF;
				}
			}
			
		if ( (mode==EM_SOURCESKIP) && (regs.sr&0x8000) )
			{ /* may be about to trace a jsr, which we dont want */
			long where, after;
			if ( isjsr(regs.pc,&where,&after) && !checkinline(where) )
				{ /* about to do a JSR/BSR */
				if (set_break(after,BTYPE_TRACE,(char*)1L,TRUE)==0)
					regs.sr&=0x3FFF;				/* full speed */
				}
			}

		progstate=PSTATE_RUNNING;
/********** DO NOT TRACE FROM HERE ************/
		if (followtraps)
			last_exception=resume_exec();
		else
			{ /* tracing traps is special */
			if ( (regs.sr&0xC000) && ((peekw(regs.pc)&0xfff0)==0x4e40) )
				{
				if ( FLIPSCREEN && (havehidden==FALSE))
					{
					must_hide_screen();						// always flip on traps
					havehidden=TRUE;
					}
				last_exception=resume_trap();			/* what if brk? */
				}
			else
				last_exception=resume_exec();
			}
		}
doneterm:
	progstate=PSTATE_STOPPED;
/******************** TO HERE ************/

// as a panic-breakout, check both shift keys here if tracing
	if ( (last_exception==9) && check_tsr_wait() )
		goto gotex;

	if ( autoccr && (last_exception==8) && realproc )
		{
		/* try and fix the instruction */
		uword op;
		op=peekw(regs.pc);
		if ( (op&0xFFC0) == 0x40C0 )			/* MOVE SR, ?? */
			if (pokew(regs.pc,op|0x200)==0)
				goto run_again;					/* if hacked to MOVE CCR, */
		}

	if ( autodiv0 && (last_exception==5) && ((regs.sr&0x8000)==0) )
		{
		/* ignore div0, unless tracing */
		if (realproc>10)
			regs.pc = diss(regs.pc, TRUE);		// skip to next instruction
		goto run_again;
		}

	if ( isbrk && (last_exception==9) )
		{ /* restore brk then run properly */
		regs.sr&=0x3fff;
		regs.sr|=realsr;
		pokew(isbrk->where,BRKOP);
		isbrk=NULL;
		if (realsr==0)
			goto run2;		/* execute if no trace, else say 'Trace' */
		}


	if (last_exception)
		{

		if ( (last_exception==4) && peekw(regs.pc)==BRKOP )		/* illegal excep */
			{
			brk *b;

				b=find_brk(regs.pc);
				if (b)
					{
					if (b->btype==BTYPE_TRACE)
						{
						last_exception=9;			/* pretend a Trace exception */
						clear_brk(b);
						if ( (mode==EM_SOURCESKIP) || (mode==EM_SOURCESTEP) )
							goto source;
						}
					refresh=TRUE;
					remember_history(1);
					new_scope(regs.pc);				/* so exprs in breakpoints work */
					if ( hit_brk(b,FALSE) )
						{
						if (mode==EM_START)
							mode=EM_NORMAL;
						goto run_again;
						}
					last_exception=1;
					}
				else
					remember_history(last_exception);
			}
		else if ( ( (mode==EM_SOURCESKIP) || (mode==EM_SOURCESTEP) )
					&& (last_exception==9) )
			{
			/* we are tracing until we hit some C */
			char exact;
source:		exact=check_source(regs.pc);
			/* 0=not in source, 1=exact, 2=mid source */
			if (sourcespeed)
				{ /* once out of source, go until stack */
				/* unless we're on a JMP xxx.l op, which means we're
					going via an ALV */
				if ( alvflag && (exact==0) && (peekw(regs.pc)==0x4ef9) )
					{
					/* as ALVs are such grief, we do the jmp for the processor (!) */
					regs.pc=peekl(regs.pc+2);			/* des of the ALV */
					exact=check_source(regs.pc);
					}
				if (exact==0)
					{
					long sp;
					sp=getsp;
					/* unless we just entered a fn with inline params */
					if (checkinline(regs.pc))
						sourcespeed=FALSE;			/* go slowly for duration of this fn */
					else if ( ((sp&1)==0) && (within_prog(peekl(sp))) && (sp<oldsp) )
						{
						if (set_break( peekl(sp),BTYPE_TRACE,(char*)1L,TRUE)==0)
							regs.sr&=0x3FFF;			/* lose trace */
						}
					else
						{
						regs.sr&=0xbfff;
						regs.sr|=0x8000;
						}
					goto run_again;
					}
				else if (exact==2)
					{
					/* just single-step till we hit */
					regs.sr&=0xbfff;
					regs.sr|=0x8000;
					goto run_again;		/* if mid, go slowly */
					}
				}
			else
				{ /* only stop tracing on source lines */
				if (exact!=1)
					{
					regs.sr&=0xbfff;
					regs.sr|=0x8000;
					goto run_again;
					}
				}
			remember_history(last_exception);
			}
		else if ( (last_exception==EXNUM_TRAP) && (waitname[0]) )
			{
			/* we've just hit the load trap */
			regs.sr&=0xbfff; regs.sr|=0x8000;
			progstate=PSTATE_RUNNING;
			last_exception=resume_trap();
			progstate=PSTATE_STOPPED;
			if (loaded_high && (regs.pc>=romstart) && (regs.pc<=romend) )
				{
				/* might be TOS 1.4> whose desktop does a Shrink */
				mode = EM_NORMAL;
				regs.sr&=0xbfff;		// dont trace any more
				goto run_again;
				}
			if (last_exception==9)
				{ /* its been loaded - get debug, bung break */
				if (start_loaded())
					{
					mode=EM_NORMAL;
					goto run_again;
					}
				else
					mode=EM_START;			// switch to smart etc
				}
			refresh=TRUE;
			remember_history(last_exception);
			goto gotex;
			}
		else /* we're gonna stop */
			{
			remember_history(last_exception);
			if ( ( (last_exception==2) || (last_exception==3)) && (realproc==0) && ((regs.pc&1)==0) )
				{ /* for 68000s we need to try and find the real PC */
				ulong where; uword ir; word i;
				ir=(uword)(regs.msp);
				where=regs.pc;
				i=10;				/* longest instruction (words) */
				while (i--)
					{
					if (peekw(where)==ir)
						{
						regs.pc=where;
						break;
						}
					where-=2;
					}
				}
			}
gotex:
	if (FLIPSCREEN) must_show_screen();
	if (mode==EM_START)
		just_started();
	*( sprintlong(lbuf,regs.pc,SPRINTMAX) )=0;
	sprintf(linebuf,TX_EXCEPTION,TX_EXNAME(last_exception),lbuf);
	new_scope(regs.pc);
		}
	else
		{
		progstate=(am_auto==0) ? PSTATE_NONE : PSTATE_STOPPED;
		if (FLIPSCREEN) must_show_screen();
		remember_history(0);
		sprintf(linebuf,TX_TERMINATED,(word)regs.dregs[0]);
		refresh=TRUE;
		new_scope(0L);								/* nothing is in scope now */
		}
	if ((flags & EMFLAG_NOREFRESH)==0)
		{
		safe_print(linebuf);
		if (FLIPSCREEN) world_changed(TRUE);		/* temp kludge - should be refresh */
		}
	return 0;	
}

/* pretend to do a JSR */
word pretend_jsr(ulong where, ulong after)
{
extern void *illegal_op;
ulong *stack,sp;
word err;
char lbuf[SPRINTMAX+1];

	regs.sr&=0x3fff;		/* no trace */
	if (regs.sr & 0x2000)
		stack=&regs.ssp;
	else
		stack=&regs.aregs[7];
	if (*stack&1)
		return ERRM_ODD;
	*stack-=4;
	sp=*stack;
	pokel(sp,(long)(&illegal_op));			/* the return address */
	regs.pc=where;
	err=execute_prog(EM_NORMAL,NULL,EMFLAG_NOREFRESH);
	if ( (err==0) && (last_exception==4) && (regs.pc==(ulong)(&illegal_op)) )
		{
		last_exception=9;
		regs.pc=after;					/* what we are expecting */
		}
	else
		pokel(sp,(long)after);			/* restore as some other exception */
	*( sprintlong(lbuf,regs.pc,SPRINTMAX) )=0;
	sprintf(linebuf,TX_EXCEPTION,TX_EXNAME(last_exception),lbuf);
	safe_print(linebuf);
	world_changed(TRUE);				/* cos execute_prog wont */
	return 0;
}

/* if non-Trace happens, returns 'interrupted'; leaves screen */
word step_asm_slow(word flag)
{
word err;

	regs.sr &= 0x3FFF;				/* lose both trace bits */
	/* if ints have been turned off, dont trace */
	if ( (regs.sr&0x700)!=0x700 )
		regs.sr |= 0x8000;				/* Trace bit */
	err=execute_prog(EM_NORMAL,NULL,flag);
	if (err)
		return err;
	return (last_exception==9) ? 0 : ERRM_INTERRUPTED;
}

/* like the above but uses 68020 super-Trace mode */
/* caller must check realproc */
word step_asm_fast(word flag)
{
word err;
	regs.sr &= 0x3FFF;				/* lose both trace bits */
	/* if ints have been turned off, dont trace */
	if ( (regs.sr&0x700)!=0x700 )
		regs.sr |= 0x4000;				/* T2 bit */

	err=execute_prog(EM_NORMAL,NULL,flag);
	if (err)
		return err;
	if (last_exception==9)
		{
		/* we have to check in case we just traced into a trap */
		if (start_of_trap())
			err=execute_prog(EM_NORMAL,NULL,flag);		/* resume it */
		return 0;
		}
	return ERRM_INTERRUPTED;
}

word step_asm()
{
	regs.sr |= 0x8000;				/* Trace bit */
	regs.sr &= 0xBFFF;				/* no T2 bit */
	return execute_prog(EM_NORMAL,NULL,0);
}

word step_asm_skip(void)
{
word err; ulong x;
	x=diss_next(regs.pc);
	if (err=set_break(x,BTYPE_COUNT,(char*)1L,TRUE))
		return err;
	return run_prog();
}

word step_asm_miss(void)
{
	if (progstate!=PSTATE_STOPPED)
		return ERRM_NORUN;
	regs.pc=diss_next(regs.pc);
	world_changed(TRUE);
	return 0;
}

/* if not a JSR/BSR then Trace, else interpret it */
word step_asm_rom(void)
{
ulong dest,after;
	if (progstate!=PSTATE_STOPPED)
		return ERRM_NORUN;
	if (isjsr(regs.pc,&dest,&after))
		return pretend_jsr(dest,after);
	else
		return step_asm();
}

word step_source()
{
	regs.sr |= 0x8000;				/* Trace bit */
	regs.sr &= 0xBFFF;				/* no T2 bit */
	return execute_prog(EM_SOURCESTEP,NULL,0);
}

word step_sourceskip()
{
	regs.sr |= 0x8000;				/* Trace bit */
	regs.sr &= 0xBFFF;				/* no T2 bit */
	return execute_prog(EM_SOURCESKIP,NULL,0);
}

word step_sourcenext(void)
{
ulong pc;
word err;

	pc=regs.pc;
	if (err=next_source(&pc))
		return err;
	if (err=set_break(pc,BTYPE_COUNT,(char*)1L,TRUE))
		return err;
	return run_prog();
}

word run_prog()
{
	regs.sr &= 0x3FFF;				/* no trace of either sort */
	return execute_prog(EM_NORMAL,NULL,0);
}

word alter_reg(void *reg)
{
	world_changed(TRUE);
	return 0;
}

word alter_nothing(void *reg)
{
	return 0;
}

word alter_backstep(void *reg)
{
	backstep&=~1;			/* ensure even */
	if (backstep==0)
		backstep=2;
	else if (backstep>1024)
		backstep=1024;
	return 0;
}

/* "sp"s address varies */
void *fn_sp(bool *writeable, void *s)
{
	*writeable=TRUE;
	if (regs.sr & 0x2000)
		return (void*)&regs.ssp;
	else
		return (void*)&regs.aregs[7];
}

void init_history(void);

void init_proc()
{
word i;
char regname[3];
word alter_linkreg(void *);

	regname[1]='0';
	regname[2]=0;
	for (i=0; i<8; i++)
		{
		regname[0]='d';
		add_reserved_sym(regname,&regs.dregs[i],EXPR_LONG,alter_reg);
		regname[0]='a';
		add_reserved_sym(regname,&regs.aregs[i],EXPR_LONG,alter_reg);
		regname[1]++;
		}
	add_reserved_sym("pc",&regs.pc,EXPR_LONG,alter_reg);
	add_reserved_sym("sr",&regs.sr,EXPR_UWORD,alter_reg);
	add_function_sym("sp",fn_sp,EXPR_LONG,alter_reg);
	add_reserved_sym("ssp",&regs.ssp,EXPR_LONG,alter_reg);
	add_reserved_sym("usp",&regs.aregs[7],EXPR_LONG,alter_reg);
	if (proctype>=20)
		{
		add_reserved_sym("msp",&regs.msp,EXPR_LONG,alter_reg);
		add_reserved_sym("isp",&regs.isp,EXPR_LONG,alter_reg);
		}
	add_reserved_sym("processor",&proctype,EXPR_WORD,alter_reg);

	add_reserved_sym("fastsource",&fastsource,EXPR_BYTE,alter_nothing);
	add_reserved_sym("linkareg",&linkreg,EXPR_BYTE,alter_linkreg);
	add_reserved_sym("automain",&automain,EXPR_BYTE,alter_nothing);
	add_reserved_sym("followtrap",&followtraps,EXPR_BYTE,alter_nothing);
	add_reserved_sym("autoccr",&autoccr,EXPR_BYTE,alter_nothing);
	add_reserved_sym("autodiv0",&autodiv0,EXPR_BYTE,alter_nothing);
	add_reserved_sym("backstep",&backstep,EXPR_LONG,alter_backstep);
	add_reserved_sym("compilertype",&user_compiler_type,EXPR_BYTE,alter_nothing);
	
	add_reserved_sym("stickybrk",&auto_brktype,EXPR_BYTE,alter_nothing);
	
	if (proctype)
		autoccr=TRUE;

	init_history();
}


/* return a safe representation of a character */
/* so we dont screw the window display up */
char safe_char(char x)
{
	switch (x)
		{
		case 0: case '\n':
			return ' ';
		default:
			return x;
		}
}

char *pad_tab(char *now, char *start, word tab)
{
word offset;
	offset=(word)(now-start);
	offset=tab - (offset % tab);
	while (offset--)
		*now++=' ';
	return now;
}

word alter_linkreg(void *reg)
{
	*((char*)reg)&=7;			/* limit its range */
	return 0;
}

char *ascii_stack(long code, long params)
{
ubyte len; long diff;
char *sym; char *p;
word i;

	sym=find_close_symbol(code,&len,&diff);
	p=linebuf;
	if (sym)
		{
		if (len>25)
			len=25;
		while (len--)
			*p++=*sym++;
		if (diff)
			{
			*p++='+';
			p=sprintlong(p,(ulong)diff,0);
			}
		}
	else
		p=sprintlong(p,(ulong)code,0);

	if ( params && ((params&1)==0) )
		{
		p=pad_tab(p,linebuf,8);
		for (i=0; i<6; i++)
			/* dump parameters as hex words */
			{
			sprintf(p,"%04x ",peekw((ulong)params));
			p+=5;
			params+=2;
			}
		}
	*p++='\n';
	*p=0;
	return linebuf;
}

word list_stack(char *p)
{
long a6;
long code;
word err;

	a6=regs.aregs[linkreg];

	if (err=list_print(ascii_stack(regs.pc,(long)(a6+8))))
		return err;			/* first is easiest */
	for(;;)
		{
		if (a6&1)
			break;
		code=peekl((ulong)(a6+4));	/* the return address */
		if (!within_prog(code))
			break;
		if (peekl((ulong)a6)>a6)
			{
			a6=peekl((ulong)a6);
			if (err=list_print(ascii_stack(code,(long)(a6+8))))
				return err;
			}
		else
			{ /* a6 link has gone backwards */
			if (err=list_print(ascii_stack(code,0L)))
				return err;
			break;
			}
		}
	return 0;
}

/*************** history command handler **********/

/* this is used to remember the processor state */
long hsize=10;				/* how many to remember */
long hspare;				/* index of next one to use */
long hfirst;				/* index of first one used */

struct history {
	struct smallregs68k regs;
	word exnum;
	};
struct history *hlist;

void init_history(void)
{
	if (hsize<=0)
		hsize=1;

	if ( (hlist=(struct history*)
			getanymem(sizeof(struct history)*hsize))==NULL)
				finish(RET_NOMEM);
	hspare=hfirst=0L;
}

/* called to remember the world */
void remember_history(word exnum)
{
	memcpy(&(hlist[hspare].regs),&regs,sizeof(struct smallregs68k));
	hlist[hspare].exnum=exnum;
	if (++hspare==hsize)
		hspare=0L;						/* wrapped over end */
	if (hspare==hfirst)
		{								/* wrapped over start */
		if (++hfirst==hsize)
			hfirst=0L;
		}
}

/* called to dump the history */
/* starts with oldest first */
word list_history(char *p)
{
long h;
word err;
char *end;
char *flags_68k(uword);

	h=hfirst;
	while (h!=hspare)
		{
		sprintf(linebuf,"D:%08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",
			hlist[h].regs.dregs[0],hlist[h].regs.dregs[1],hlist[h].regs.dregs[2],hlist[h].regs.dregs[3],
			hlist[h].regs.dregs[4],hlist[h].regs.dregs[5],hlist[h].regs.dregs[6],hlist[h].regs.dregs[7]);
		if (err=list_print(linebuf))
			return err;
		sprintf(linebuf,"A:%08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",
			hlist[h].regs.aregs[0],hlist[h].regs.aregs[1],hlist[h].regs.aregs[2],hlist[h].regs.aregs[3],
			hlist[h].regs.aregs[4],hlist[h].regs.aregs[5],hlist[h].regs.aregs[6],hlist[h].regs.aregs[7]);
		if (err=list_print(linebuf))
			return err;
		sprintf(linebuf,"PC:%08lx SR:%04x %s SSP:%08lx %s\n",
			hlist[h].regs.pc,hlist[h].regs.sr,
				flags_68k(hlist[h].regs.sr),
				hlist[h].regs.ssp,
				TX_EXNAME(hlist[h].exnum));
		if (err=list_print(linebuf))
			return err;

			
		diss(hlist[h].regs.pc,FALSE);
		linebuf[0]=0;
		strcattab(linebuf,dissbuf,TRUE,8);
		end=linebuf+strlen(linebuf);
		*end++=' '; *end++=' ';
		end=value_to_ascii(hlist[h].regs.pc,end,15);
		*end++='\n'; *end=0;
		if (err=list_print(linebuf))
			return err;

		if (++h==hsize)
			h=0L;
		}
	return 0;
}

/************** diss/regs window handler ***********/

/* return a string representation of the flag bits */
/* always 11 chars+null of the form:
	TtSm3 XNZVC
	01234 6789A
*/
char *flags_68k(uword sr)
{
static char fbuf[12];
	strcpy(fbuf,"      xnzvc");
	if (sr & 0x8000)
		fbuf[0]='T';
	if ( (proctype>=20) && (sr & 0x4000) )
		fbuf[1]='t';

	if (sr & 0x2000)
		fbuf[2]='S';
	else
		fbuf[2]='U';
	
	if (proctype>=20)
		fbuf[3]= 'M' ? 'I' : sr & 0x1000;	/* set is M */

			
	fbuf[4]='0'+((sr & 0x0300)>>8);

	if (sr & 0x10)
		fbuf[6]='X';
	if (sr & 8)
		fbuf[7]='N';
	if (sr & 4)
		fbuf[8]='Z';
	if (sr & 2)
		fbuf[9]='V';
	if (sr & 1)
		fbuf[10]='C';
	return fbuf;
}


char *addhex(char *p,long where,word len)
{

	while (*p++)
		;						/* so we add to its end */
	p--;

	if (len<=0)
		return p;

	while (len--)
		{
		sprintf(p,"%02X",peekb(where));
		p+=2;
		if ( where & 1 )
			*p++=' ';
		where++;
		}
	*p=0;
	return p;
}


char *prt_efad(char *b, struct remefad *r)
{
	if (r->immed)
		{
		ubyte *d; word i;
		*b++='#';
		i=size_size[r->esize];
		d=(ubyte*)((ulong)(&(r->addr))+4-i);
		while (i--)
			{
			sprintf(b,"%02x",(int)(*d++));
			b+=2;
			}
		*b=0;
		}
	else
		{
		b=sprintlong(b,r->addr,0);
		*b++=' ';
		*b=0;
		b=addhex(b,r->addr,(word)size_size[r->esize]);
		}
	return b;
}

static struct remefad remember[2];

/* create efad display - must be called after ascii_diss */
char *ascii_efad(char *b)
{
	if (remember[0].esize!=42)
		{
		b=prt_efad(b,&remember[0]);
		if (*--b!=' ')
			b++;
		}
	if (remember[1].esize!=42)
		{
		*b++='>';
		b=prt_efad(b,&remember[1]);
		}
	return b;
}

/* create ASCII line of disassembly */
void ascii_diss(char *b,ulong pc,bool efad)
{
char c,*d;

	remefad=remember;
	remember[0].esize=remember[1].esize=42;
	diss(pc,FALSE);
	d=dissbuf;
	*b++=' ';
	*b++=' ';
	*b++=' ';
	while (c=*d++)
		{
		if (c=='\t')
			c=' ';
		*b++=c;
		}
	if (efad)
		{
		*b++=' ';
		b=ascii_efad(b);
		}
	*b=0;
}

bool refill_regs(struct ws *wptr)
{
word i;
word bwidth;					// bytes displayed on RHS of addr reg

bwidth = wptr->w - 2;

/* there are various allowed formats */

if (wptr->h>21)		/* deep */
	{
	bwidth -= 8+3+1;
	bwidth = (bwidth/5)<<1;
	sprintf(linebuf,"PC:%08lX",regs.pc);
	wprint_line(wptr,linebuf,FALSE);		/* #1 */
	ascii_diss(linebuf,regs.pc,TRUE);		/* includes efad */
	wprint_line(wptr,linebuf,FALSE);		/* #2 */
	for (i=0; i<8; i++)
		{
		sprintf(linebuf,"D%d:%08lX %c",i,regs.dregs[i],safe_char((char)regs.dregs[i]));
		wprint_line(wptr,linebuf,FALSE);
		}
	for (i=0; i<8; i++)
		{
		sprintf(linebuf,"A%d:%08lX ",i,regs.aregs[i]);
		addhex(linebuf,regs.aregs[i],bwidth);
		wprint_line(wptr,linebuf,FALSE);
		}
	sprintf(linebuf,"A7'%08lX",regs.ssp);
	wprint_line(wptr,linebuf,FALSE);			/* #19 */
	sprintf(linebuf,"SR:%04X %s",regs.sr,flags_68k(regs.sr) );
	wprint_line(wptr,linebuf,FALSE);			/* #20 */
	}
else	/* not deep, but wide */
	{
	bwidth -= (3+8+3+3+8+1);
	bwidth = (bwidth/5)<<1;
	
	for (i=0; i<8; i++)
		{
		sprintf(linebuf,"D%d:%08lX %c A%d:%08lX ",
				i,regs.dregs[i],safe_char((char)regs.dregs[i]),
					i,regs.aregs[i] );
		addhex(linebuf,regs.aregs[i],bwidth);
		wprint_line(wptr,linebuf,FALSE);
		}
	sprintf(linebuf,"SR:%04X %s",regs.sr,flags_68k(regs.sr) );
	wprint_line(wptr,linebuf,FALSE);
	sprintf(linebuf,"PC:%08lX   A7'%08lX",regs.pc,regs.ssp);
	wprint_line(wptr,linebuf,FALSE);
	ascii_diss(linebuf,regs.pc,FALSE);
	wprint_line(wptr,linebuf,FALSE);
	*ascii_efad(linebuf)=0;
	if (linebuf)
		wprint_line(wptr,linebuf,FALSE);
	}

	if ( (wptr->h>21) && (proctype==30) )
		{
		sprintf(linebuf,"MSP:%08lX ISP:%08lX VBR:%08lX SFC :%08lX DFC :%08lX",
			regs.msp,regs.isp,regs.vbr,regs.sfc,regs.dfc);
		wprint_line(wptr,linebuf,FALSE);
		sprintf(linebuf,"TC :%08lX TT0:%08lX TT1:%08lX CACR:%08lX CAAR:%08lX",
				regs.tc,regs.tt0,regs.tt1,regs.cacr,regs.caar);
		wprint_line(wptr,linebuf,FALSE);
		sprintf(linebuf,"CRP:%08lX %08lX     SRP:%08lX %08lX",
				regs.crp[0],regs.crp[1],
				regs.srp[0],regs.srp[1]);
		wprint_line(wptr,linebuf,FALSE);
		}

	return TRUE;
}

static char mmubits[]="BLS\0WIM\0\0T";

char *ascii_rp(ulong rp[], char type)
{
char *p;
	sprintf(linebuf,"%cRP  : %08lX%08lX ",type,rp[0],rp[1]);
	p=linebuf+strlen(linebuf);
	*p++ = (rp[0]&0x80000000) ? 'L' : 'U';
	sprintf(p," LIMIT=$%04X DT=%d @$%08lX",
		(int)((rp[0]>>16)&0x7FFF),
		(int)(rp[0]&3),
		rp[1]&0xFFFFFFF0 );
	return linebuf;
}

char *ascii_tt(ulong tt, char digit)
{
char *p;
	sprintf(linebuf,"TT%c  : %08lX ",digit,tt);
	p=linebuf+strlen(linebuf);
	*p++ = (tt & 0x8000) ? 'E' : ' ';
	*p++=' ';
	strcpy(p,(tt & 0x0400) ? "CI " : "   ");
	p+=3;
	*p++ = (tt & 0x0200) ? 'R' : 'W';
	*p++=' ';
	strcpy(p,(tt & 0x0100) ? "RWM " : "    ");
	p+=4;
	sprintf(p,"FC BASE=%d MASK=%d",(int)((tt>>4)&7),(int)(tt&7));
	p=linebuf+strlen(linebuf);
	sprintf(p," ADDR BASE=$%02X MASK=$%02X",(int)(tt>>24),(int)((tt>>16)&0xFF) );
	return linebuf;
}

bool refill_mmu(struct ws *wptr)
{
char *p,*q;
uword mask;

	if (realproc!=30)
		{
		wprint_line(wptr,TX_ERROR(ERRM_NOMMU),FALSE);
		return TRUE;
		}

	sprintf(linebuf,"SFC  : %03ld      DFC: %03ld",regs.sfc,regs.dfc);
	wprint_line(wptr,linebuf,FALSE);

	wprint_line(wptr,ascii_tt(regs.tt0,'0'),FALSE);
	wprint_line(wptr,ascii_tt(regs.tt1,'1'),FALSE);

	sprintf(linebuf,"TC   : %08lX ",regs.tc);
	p=linebuf+strlen(linebuf);
	*p++=(regs.tc & 0x80000000) ? 'E' : ' ';
	*p++=' ';
	strcpy(p,(regs.tc & 0x02000000) ? "SRE " : "    ");
	p+=4;
	strcpy(p,(regs.tc & 0x01000000) ? "FCL " : "    ");
	p+=4;
	sprintf(p,"PS=$%X ",0x100<<((regs.tc>>20)&0x7));
	p=linebuf+strlen(linebuf);
	sprintf(p,"IS=%d ",(int)((regs.tc>>16)&0xF));
	p=linebuf+strlen(linebuf);
	sprintf(p,"TIA=%d,B=%d,C=%d,D=%d",
		(int)((regs.tc>>12)&0xF),
		(int)((regs.tc>>8)&0xF),
		(int)((regs.tc>>4)&0xF),
		(int)(regs.tc&0xF) );
	wprint_line(wptr,linebuf,TRUE);

	wprint_line(wptr,ascii_rp(regs.crp,'C'),TRUE);
	wprint_line(wptr,ascii_rp(regs.srp,'S'),TRUE);

	sprintf(linebuf,"MMUSR: %04X ",regs.mmusr);
	p=linebuf+strlen(linebuf);
	q=mmubits;
	for (mask=0x8000; mask>0x20; mask>>=1)
		{
		if (*q)
			*p++= (regs.mmusr & mask) ? *q : ' ';
		q++;
		}
	sprintf(p," N=%d",(int)(regs.mmusr&7));
	wprint_line(wptr,linebuf,FALSE);
	return TRUE;
}

/************* memory window handler **********/
/* each line consists of:
	12345678 hhhh hhhh aaaa			or
	12345678 hh hhhh hh aaaa
	*/


word bperline(struct ws *wptr)
{ 
word bytes;

	bytes=(((wptr->w-12)/7)<<1);
	if (bytes>0)
		return bytes;
	else
		return 1;
}

bool mayrefill_mem(struct ws *wptr, long new)
{
word bytes;
ulong newchk;

	bytes=bperline(wptr);
	wptr->wlong=new;
	newchk=checksum(wptr->wlong,wptr->wlong+bytes*(wptr->h-2));
	return (bool)(newchk!=(ulong)wptr->magic);
}

void mem_line(struct ws *wptr, long mem, word bytes)
{
char *asc;

	sprintf(linebuf,"%08lX ",mem);
	asc=addhex(linebuf,mem,bytes);
	*asc++=' ';
	while (bytes--)
		*asc++=safe_char(peekb((ulong)(mem++)));
	*asc=0;
}

bool refill_mem(struct ws *wptr)
{
word lines,bytes;
ulong mem;

	lines=wptr->h-2;
	bytes=bperline(wptr);
	mem=wptr->wlong;
	wptr->magic=(void*)checksum(mem,mem+bytes*lines);
	while (lines--)
		{
		mem_line(wptr,mem,bytes);
		mem+=(ulong)bytes;
		wprint_line(wptr,linebuf,FALSE);
		}
	return TRUE;
}

void key_mem(word key)
{
long adjust,mem;
word bytes,lines;

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	bytes=bperline(frontwindow);
	lines=frontwindow->h-2;
	adjust=0L;
	mem=frontwindow->wlong;

	if (key==KEY_DOWN)
		{
		scroll_window(frontwindow,TRUE);
		frontwindow->wlong+=bytes;
		mem+=(long)bytes*lines;
		/* do the new bottom line */
		mem_line(frontwindow,mem,bytes);
		wprint_str(linebuf);
		}
	else if (key==KEY_UP)
		{
		scroll_window(frontwindow,FALSE);
		frontwindow->wlong-=bytes;
		mem-=(long)bytes;
		/* do the new top line */
		mem_line(frontwindow,mem,bytes);
		wprint_str(linebuf);
		}
	else if (key==KEY_PAGEUP)
		adjust=-(long)bytes*lines;
	else if ( (key==KEY_PAGEDOWN) || ((key&0xFF)==' ') )
		adjust=(long)bytes*lines;
	else if (key==KEY_LEFT)
		adjust=-1L;
	else if (key==KEY_RIGHT)
		adjust=1L;
	else
		return;

	if (adjust)
		{
		frontwindow->wlong+=adjust;
		window_cls(frontwindow);
		refill_mem(frontwindow);
		update_contents(frontwindow);
		}
	else
		frontwindow->magic=(void*)checksum(frontwindow->wlong,
			frontwindow->wlong+bytes*lines);

}

/************ diss window handler ************/

/* each diss handler magic ptr has a ptr to this structure
	which contains the addresses of each line */
struct ds {
	word syms;				/* significance */
	ulong lastpc,checksum;
	word lastline;			/* 0 means none */
	ulong addr[MAXY];			/* of each line */
	};

void winit_diss(struct ws *w)
{
struct ds *d;

	d=(struct ds*)getzmem(sizeof(struct ds));
	if (d==NULL)
		w->type=WTYPE_NONE;
	else
		{
		d->syms=10;
		w->magic=(void *)d;
		}
}

/* add a symbol or spaces to linebuf */
char *diss_sym(char *s, ubyte slen, ubyte max)
{
char*p;

	p=linebuf;
	while (*p++)
		;
	--p;
	if (s==NULL)
		slen=0;
	while (max--)
		{
		if (slen)
			{
			*p++=*s++;
			slen--;
			}
		else
			*p++=' ';
		}
	/* indicate more chars or not */
	*p++=(slen ? '.' : ' ');
	return p;
}

/* print a line of diss into linebuf */
ulong diss_line(struct ws *wptr,ulong curpc)
{
char *p,*d,c,here,*s;
ubyte slen;
#define TABPOSN	8

		if (curpc==regs.pc)
			{
			here='>';
			((struct ds*)wptr->magic)->lastline=wptr->ypos;
			((struct ds*)wptr->magic)->lastpc=curpc;
			}
		else
			here=' ';

		sprintf(linebuf,(ucasediss ? "%04lX%c" : "%04lx%c"),curpc,here);

		s=find_asm_symbol(curpc,&slen);
		p=diss_sym(s,slen,10);

		curpc=diss(curpc,FALSE);
		d=dissbuf;
		do
			{
			if ( (c=*d++)=='\t' )
				{
				word pad;
				pad=TABPOSN+1-(word)(d-dissbuf);
				if (pad>1)
					{
					while ( (pad--)>0)
						*p++=' ';
					}
				else
					*p++=' ';
				}
			else
				*p++=c;
			}
		while (c);
		return curpc;
}

/* returns TRUE if a proper refill required, else FALSE
	if FALSE may redraw a little bit itself */
bool mayrefill_diss(struct ws *w, ulong new, bool actual)
{
/* we try to keep the PC on screen, max three from bottom */
word maxline,i,lines,lastline;
ulong lastpc;
bool exact;
ulong newchk;

	lastpc=((struct ds*)w->magic)->lastpc;
	lastline=((struct ds*)w->magic)->lastline;
	lines=w->h-2;
	/* see if contents changed */
	newchk=checksum( w->wlong,
		((struct ds*)w->magic)->addr[lines-1] );

	/* if same addr and same contents then leave */
	if ( (lastpc==new) && (actual==FALSE) )
		if ( newchk==((struct ds*)w->magic)->checksum )
			return FALSE;

	((struct ds*)w->magic)->checksum=newchk;
	maxline=lines-3;
	if (maxline<2)
		maxline=2;
	if (actual==FALSE)
		{
		for (i=0; i<maxline; i++)
			{
			if ( ((struct ds*)w->magic)->addr[i]==new )
				{
				w->ypos=i+1;
				diss_line(w,new);			/* will set last stuff */
				wprint_line(w,linebuf,TRUE);		/* new posn */
				update_rectangle((word)(w->x+1),(word)(w->y+i+1),
					(word)(w->w-2),1);
				if (lastline)
					{
					w->ypos=lastline;
					diss_line(w,lastpc);
					wprint_line(w,linebuf,TRUE);		/* new posn */
					update_rectangle((word)(w->x+1),(word)(w->y+lastline),
							(word)(w->w-2),1);
					}
				return FALSE;
				}
			}
		}
	if ( (new==progstart) || actual )
		w->wlong=new;					/* always show exact start */
	else
		{
			lastpc=backdiss(new,&exact);
			w->wlong=(exact ? lastpc : new );
		}
	return TRUE;					/* oh well */
}

bool refill_diss(struct ws *wptr)
{
ulong curpc; word lines,i;
struct ds *d;

	d=(struct ds*)wptr->magic;
	curpc=wptr->wlong;
	lines=wptr->h-2;
	d->lastline=0;
	for (i=0; i<lines; i++)
		{
		d->addr[i]=curpc;
		curpc=diss_line(wptr,curpc);
		wprint_line(wptr,linebuf,FALSE);
		}
	d->checksum=checksum(wptr->wlong,d->addr[--i]);
	return TRUE;
}


void key_diss(word key)
{
ulong curpc; word lines;
bool exact;
struct ds *d;
word i;

	d=(struct ds*)frontwindow->magic;

	auto_numeric(&key);

	if (do_controlkey(key)==TRUE)
		return;

	curpc=frontwindow->wlong;
	lines=frontwindow->h-2;

	if (key==KEY_DOWN)
		{
		/* down is easy */
		scroll_window(frontwindow,TRUE);
		frontwindow->wlong=d->addr[1];
		/* we need to recalc but not redraw */
		for (i=1; i<lines; i++)
			{
			d->addr[i-1]=d->addr[i];
			}
		/* do the new bottom line */
		if (compiler_type && (i>2) )
			diss(d->addr[i-3],TRUE);				/* eg str_constant */
		d->addr[i-1]=diss(d->addr[i-1],TRUE);		/* requires min 2 lines */
		diss_line(frontwindow,d->addr[i-1]);
		wprint_str(linebuf);
		if (d->lastline)
			d->lastline--;
		d->checksum=checksum( d->addr[0],d->addr[lines-1] );
		return;
		}
	else if (key==KEY_UP)
		{
		frontwindow->wlong=backdiss(curpc,&exact);
		if (exact)
			{
			for (i=lines-1; i; i--)
				d->addr[i]=d->addr[i-1];
			scroll_window(frontwindow,FALSE);
			d->addr[0]=frontwindow->wlong;
			diss_line(frontwindow,frontwindow->wlong);
			wprint_str(linebuf);
			if (d->lastline)
				{
				if ( d->lastline++ > frontwindow->h+2 )
					d->lastline=0;
				}
			d->checksum=checksum( d->addr[0],d->addr[lines-1] );
			return;
			}
		}
	else if (key==KEY_PAGEUP)
		{
		for (i=1; i<lines; i++)
			curpc=backdiss(curpc,&exact);
		frontwindow->wlong=curpc;
		}
	else if ( (key==KEY_PAGEDOWN) || ((key&0xFF)==' ') )
		{
		frontwindow->wlong=d->addr[lines-1];
		}
	else if (key==KEY_LEFT)
		{
		frontwindow->wlong-=2;
		}
	else if (key==KEY_RIGHT)
		{
		frontwindow->wlong+=2;
		}
	else
		return;

	window_cls(frontwindow);
	refill_diss(frontwindow);
	update_contents(frontwindow);

}

/* if printing to screen use spaces, if printer use tabs */

word list_diss(ulong start, ulong end)
{
word err=0;
char *p;
ubyte slen;

	while (start<=end)
		{

		p=find_asm_symbol(start,&slen);
		if (p)
			{
			memcpy(linebuf,p,(size_t)slen);
			linebuf[slen]='\n';
			linebuf[slen+1]=0;
			err=list_print(linebuf);
			if (err)
				break;
			}

		p=linebuf+sprintf(linebuf,(ucasediss ? "%04lX" : "%04lx"),start);

		start = diss( start, FALSE );

		if (list_redirection)
			*p++='\t';
		else
			{
			strcat(p,"    ");
			p+=4;
			}

		if (list_redirection)
			{
			strcpy(p,dissbuf);
			p+=strlen(p);
			}
		else
			{
			char *d,c;
			d=dissbuf;
			do
				{
				if ( (c=*d++)=='\t' )
					{
					word pad;
					pad=TABPOSN+1-(word)(d-dissbuf);
					if (pad>1)
						{
						while ( (pad--)>0)
							*p++=' ';
						}
					else
						*p++=' ';
					}
				else
					*p++=c;
				}
			while (c);
			p--;
			}
		*p++='\n';
		*p=0;
		err=list_print(linebuf);
		if (err)
			break;
		}
	return err;
}

/* 5.04 a4-relative */
uword lat0[] = {
	13,
	0x246f, 0x0004, 0x49f9, 0, 0,
	0x294a, 0, 0x42a7, 0x3f3c, 0x0020,
	0x4e41, 0x2978, 0x4ba };

/* 5.04 absolute */
uword lat1[] = {
	14,
	0x246f, 0x0004, 0x49f9, 0, 0,
	0x23ca, 0, 0,
	0x42a7, 0x3f3c, 0x0020,
	0x4e41, 
	0x23f8, 0x4ba };

/* 5.06.02 -b0 option */
uword lat2[] = {
	15,
	0x246f, 0x0004,
	0x23ca, 0, 0,
	0x42a7,
	0x3f3c, 0x0020,
	0x4e41,
	0x23f8, 0x04ba, 0, 0,
	0x2078, 0x04f2 };

/* new LC a4-relative */
uword lat3[] = {
	12,
	0x246f, 0x0004, 0x49f9, 0, 0,
	0x294a, 0, 0x487a, 0, 0x3f3c, 0x0026,
	0x4e4e };

/* new LC4 -b0 */
uword lat4[] = {
	10,
	0x246f, 0x0004,
	0x23ca, 0, 0,
	0x487a, 0,
	0x3f3c, 0x0026,
	0x4e4e,
	};

uword tb[] = {
	14,
	0x6060,
	0,0,0,0,0,0,0,
	'>>','> ','TU','RB','O-','C ' };

/* small BASIC */
uword hbasic1[] = {
	6,
	0x267c,0,0,
	0x6000,0,
	0x4e71 };

/* BASIC with >32k of DATA */
uword hbasic2[] = {
	4,
	0x267c,0,0,
	0x4ef9 };

uword *patch_array[]={
	lat0, lat1, lat2, lat3, lat4,
	tb,
	hbasic1,hbasic2
};

ubyte compiler_type,user_compiler_type;				/* user 0=default, BASIC=1, LC5=2 */
ulong diss_special_long[DISS_SPECIAL];
ulong trace_special_long[3];

long find_diss_l(char *name)
{
long *newstart; byte size;

	if (
			(find_general_sym(name,(ubyte)strlen(name),(void**)&newstart, &size, FALSE)==0)
			&& (size==EXPR_LONG)
		)
			return *newstart;
	return 0L;
}

/* list of fns to not step over */
char *basic_magic_list[] = { "str_constant", "profile_init", "on_goto", "on_gosub", "on_gosubv",
	"ffor_i16", "fnext_i16", "fnext_i16v",
	"ffor_i32", "fnext_i32", "fnext_i32v",
	"ffor_ffp", "fnext_ffp", "fnext_ffpv",
	"for_double", "next_double" };

/* list of fns to not trace through */
char *basic_magic_trace[] = { "stop_statement", "garbage_collect", "system" };

/* see if recognised compiler startup */
void show_exec_type(long *start)
{
word i,len;
uword *p,*q;
char *mainsym[3];

	mainsym[0]=mainsym[1]=mainsym[2]=NULL;
	compiler_type=0;
	memset(diss_special_long,0,sizeof(diss_special_long));
	memset(trace_special_long,0,sizeof(trace_special_long));
	for (i=0; i<(sizeof(patch_array)/sizeof(uword*)); i++)
		{
		if (user_compiler_type==1)
			{
			i=6;
			len=-1;		/* pretend we found BASIC */
			}
		else if (user_compiler_type==2)
			{
			i=0;
			len=-1;		/* pretend we found LC5 */
			}
		else
			{
			/* try to match startup code */
			p=(uword*)(*start); q=patch_array[i];
			len=*q++;
			while (len--)
				{
				if (*q)
					if (*q!=peekw((ulong)p))
						break;
				q++; p++;
				}
			}
		if (len==-1)
			{ /* found it */
			switch (i)
				{
				case 0: case 1: case 2: case 3: case 4:			/* LC 5 various */
					baseregs=(uchar)(1<<4);
					alvflag=TRUE;
					linkreg=6;
					safe_print(TX_LATTICE5ST);
					mainsym[0]="main";
					break;
				case 5:							/* TurboC 1.1 (others?) */
					safe_print(TX_TURBOC);
					mainsym[0]="main";
					break;
				case 6: case 7:					/* HiSoft BASIC, small & large */
					safe_print(TX_BASIC);
					baseregs=(uchar)( (1<<3) | (1<<5) );	/* a3 for JSRs, a5 for globals via basdiss */
					linkreg=4;
					mainsym[0]="_start_prog"; 		/* if basdiss has been here! */
					mainsym[1]="REF0001";			/* if HBasic 2 */
					mainsym[2]="REF_0000";			/* else as close as we can get */
					compiler_type=CTYPE_BASIC;
					for (i=0; i<sizeof(basic_magic_list)/sizeof(char*); i++)
						diss_special_long[i]=find_diss_l(basic_magic_list[i]);
					for (i=0; i<sizeof(basic_magic_trace)/sizeof(char*); i++)
						trace_special_long[i]=find_diss_l(basic_magic_trace[i]);
					add_variable_types();
					break;

				/* others here when available */
				default:
					return;
				}
			if (mainsym[0] && automain )
				{
				long l;
				int i;
				for (i=0; i<2; i++)
					if ( mainsym[i] && (l=find_diss_l(mainsym[i])) )
					{
					*start=l;
					break;
					}
				}
			break;
			}
		}
}


/******** FPU Code ***********/

bool refill_fpu(struct ws *wptr)
{
short i;
char ascii[30];
ulong cregs[3];

	if (fputype==0)
		return TRUE;

	for (i=0; i<8; i++)
		{
		get_fpu_reg(i,ascii,cregs,NULL);
		sprintf(linebuf,"FP%c: %08lx %08lx %08lx = %s",(char)(i+'0'),cregs[0],cregs[1],cregs[2],ascii);
		wprint_line(wptr,linebuf,TRUE);
		}

	/* FPCR, FPSR, FPIAR */
	get_fpu_cregs(cregs);
	sprintf(linebuf,"FPCR:%04X FPSR:%08lX FPIAR:%08lX",(int)cregs[0],cregs[1],cregs[2]);
	wprint_line(wptr,linebuf,FALSE);

	/* RSN proper flags */
	
	return TRUE;
}

