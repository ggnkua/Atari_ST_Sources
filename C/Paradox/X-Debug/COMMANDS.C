/* the command handler for Mon - aka AMPlanguage */

#include "mon.h"
#include <ctype.h>
#include <error.h>
#include "window.h"

txt(TX_MOVEME);
txt(TX_DOSERROR);
txt(TX_NOTFOUND);
txt(TX_FOUND);
txt(TX_HELPNOTFOUND);
txt(TX_HELPMORE);
txt(TX_HELPNOFILE);
txt(TX_HELPBRIEF);
txt(TX_DURING);

void *getwptr(word);
void *find_brk(ulong);

#define getbyte(x,p)	if (err=get_expression(p,EXPR_BYTE,&x)) return err
#define getword(x,p)	if (err=get_expression(p,EXPR_WORD,&x)) return err
#define getlong(x,p)	if (err=get_expression(p,EXPR_LONG,&x)) return err

#define	COMMENTCHAR	'#'

struct clist { char *name; word (*fn)(); };
word doserror;

static char *other_startup_file;

char *error_message(word err)
{
static char mesbuf[20];
	if (err==ERRM_DOSERR)
		sprintf(mesbuf,TX_DOSERROR,doserror);
	else if (err==ERRM_UNIXERR)
		return strerror(doserror);
	else
		return TX_ERROR(err);
	return mesbuf;
}

word remember_doserr(word err)
{
	doserror=err;
	return ERRM_DOSERR;
}

word remember_unixerr()
{
	doserror=errno;
	return ERRM_UNIXERR;
}

/*********** command utilities *************/

#define	SKIPWS(p)	while (*(p)==' ') (p)++

/* remove any '\n's from the end of a string */
char *striplf(char *str)
{
char *e;

	e=str;
	if (*e==0)
		return str;
	while (*e++)
		;
	e-=2;
	if (*e=='\n')
		*e=0;
	return str;
}

/* return length of command */
/* and next character of it */
word comlen(char *start, char **end)
{
unsigned char c,*p;

	p=start;
	while (c=*p++)
		{
		if ( !( (isalnum((int)c)) || (c=='_') ) )
			break;
		}
	p--;
	*end=p;
	return (word)(p-start);
}

/* given a ptr to something starting with a ", find its end */
/* result points to after " or null */

#define	QUOTE	'\"'

char *parse_quote(char *start)
{
char c;

	while (c=*start++)
		{
		if (c==QUOTE)
			return start;
		}
	return --start;
}

/* parse a filename - on the Amiga this could do quoted string etc */
word parse_filename(char **in, char *out)
{
word len; char c;

	len=0;
	SKIPWS(*in);
	if (**in==0)
		return ERRM_BADP;
	while (c=*(*in)++)
		{
		if (c==' ')
			break;
		*out++=c;
		if (len++==MAXPATHLEN)
			return ERRM_TOOLONG;
		}
	*out++=0;
	if (c)
		SKIPWS(*in);
	else
		(*in)--;
	return 0;
}

#define dotable(p,x)	return do_table(p,x,(word)sizeof(x));

word do_table(char *p,struct clist *t, word elems)
{
word i,l;
char *second;

	if ( (l=comlen(p,&second))==0)
		return ERRM_BADCOMMAND;
	SKIPWS(second);

	i=elems/sizeof(struct clist);
	while (i--)
		{
		if (strnicmp(p,t->name,l)==0)
				{
				/* check this doesnt match anything else */
				struct clist *t2;
				t2=t+1;
				while (i--)
					{
					if (strnicmp(p,t2->name,l)==0)
						return ERRM_AMBIGUOUS;
					t2++;
					}
				return (*t->fn)(second);
				}
		t++;
		}
	return ERRM_BADCOMMAND;
}

/* find a keyword, given an array of them */
/* returns index or -1 if failed */
word cmp_token(char **p,char *tlist[], word howmany)
{
word i,l;
char *second;
word token;

	if ( (l=comlen(*p,&second))==0)
		return -1;
	SKIPWS(second);

	token=0;
	i=howmany;
	while (i--)
		{
		if (strnicmp(*p,tlist[token],l)==0)
				{
				word j;
				j=token+1;
				/* check this doesnt match anything else */
				while (i--)
					{
					if (strnicmp(*p,tlist[j++],l)==0)
						return -1;
					}
				*p=second;
				return token;
				}
		token++;
		}
	return -1;
}


/************** actual commands *****************/


/********* loading commands ***********/

/* load an ascii file into next avail window */
word cl_ascii(char *p)
{
word err,num,file;

	SKIPWS(p);

	if ( (num=spare_window(FALSE))==-1)
		return ERRM_NOSPARE;

	if ( (file=open_file(p,NULL))==0 )
		return ERRM_FILENOTFOUND;

	err=open_window(num,30,10,49,10,p,WTYPE_ASCII);
	if (err)
		return err;

	return attach_window(num,(void*)file);
}

/* clear out any old debug - thats all */
word cl_nothing(char *p)
{
	/* not safe unless no prog loaded */
	if (progstate!=PSTATE_NONE)
		return ERRM_BADP;
	load_debug(NULL,0L);
	return 0;
}

/* requires fixed-up filename */
word load_prog(char *name, char *cmd, bool debug)
{
word err;
extern word load_exec();

	stccpy(progcmd,cmd,255);

	/* load debug first while we have some memory (or clear it) */
	if (err=load_debug(debug ? name : NULL,0L))
		return err;
	if (err=load_exec(name,cmd,&progstart))
		return err;
	if (debug)
		fixup_debug();

	show_exec_type(&progstart);			/* may alter it, e.g. main */

	/* loaded OK; wack a breakpoint in there */
	progstate=PSTATE_STOPPED;
	err=set_break(progstart,BTYPE_COUNT,(char*)1L,TRUE);
	if (err)
		return err;
	
	/* start it going */
	return execute_prog(EM_START,NULL,0);

}

#if !DEMO
/* load a binary file as a task */
word cl_bin(char *p)
{
word err;
extern word load_bin_exec();

	if (progstate!=PSTATE_NONE)
		return ERRM_BADP;			/* if something else already there */
	load_debug(NULL,0L);				/* kill old debug */
	if (err=load_bin_exec(p,&progstart))
		return err;
	progstate=PSTATE_STOPPED;
	err=set_break(progstart,BTYPE_COUNT,(char*)1L,TRUE);
	if (err)
		return err;
	/* start it going */
	return execute_prog(EM_START,NULL,0);
}

/* load an Amiga executable file (!) */
word cl_amiga(char *p)
{
word err;

	if (progstate!=PSTATE_NONE)
		return ERRM_BADP;			/* if something else already there */
	load_debug(NULL,0L);				/* kill old debug */
	if (err=load_amiga_exec(p,&progstart))
		return err;
	progstate=PSTATE_STOPPED;
	err=set_break(progstart,BTYPE_COUNT,(char*)1L,TRUE);
	if (err)
		return err;
	/* start it going */
	return execute_prog(EM_START,NULL,0);
}
#endif

#if DEMO

word cl_bin(char *p)	{ return ERRM_NOTINDEMO; }
word cl_amiga(char *p)	{ return ERRM_NOTINDEMO; }
word cl_exec(char *p)	{ return ERRM_NOTINDEMO; }
word cl_execnodebug(char *p)	{ return ERRM_NOTINDEMO; }
word cs_bin(char *p)	{ return ERRM_NOTINDEMO; }

#else

/* load an executable program (or last one if p=NULL) */
word cl_exec(char *p)
{
char *cmd;

	/* extract the command-line from after the prog name */
	cmd=p;
	while ( (*cmd) && (*cmd!=' ') )
		cmd++;
	if (*cmd)
		{
		*cmd++=0;						/* term the filename */
		while (*cmd==' ')
			cmd++;
		}

	stccpy(progname,p,255);
	fixup_extension(progname);

	return load_prog(progname,cmd,TRUE);
}

/* as above but doesn't load any debug info */
word cl_execnodebug(char *p)
{
char *cmd;

	/* extract the command-line from after the prog name */
	cmd=p;
	while ( (*cmd) && (*cmd!=' ') )
		cmd++;
	if (*cmd)
		{
		*cmd++=0;						/* term the filename */
		while (*cmd==' ')
			cmd++;
		}

	stccpy(progname,p,255);
	fixup_extension(progname);

	return load_prog(progname,cmd,FALSE);
}
#endif

/* load the last program again */
word cl_reload(char *p)
{
	if (*progname==0)
		return ERRM_NOPROG;
	if (progstate!=PSTATE_NONE)
		{
		word err;
		if (err=execute_prog(EM_KILL,NULL,0))
			return err;
		}
	return load_prog(progname,progcmd,TRUE);		/* always with db */
}

word cl_killprog(char *name)
{
	return execute_prog(EM_KILL,NULL,0);
}

/* load a file of commands; must be re-entrant */
word cl_script(char *name)
{
FILE *fp;
char linebuf[256];
word err;
char *res;

	if ( (fp=special_fopen(name,"r"))==NULL)
		return remember_unixerr();
	err=0;
	while (err==0)
		{
		linebuf[254]=0;
		if ( (res=special_fgets(linebuf,255,fp))==NULL)
			{
			err=0;
			break;
			}
		if (linebuf[254])			/* line overflow */
			err=ERRM_TOOLONG;
		else
			err=do_command(striplf(linebuf));
		}
x:	fclose(fp);
	return err;
}

/* wait for a particular prog to load - about-to-be-resident only */
word cl_wait(char *p)
{
word err;
	if ( (*p==0) || (am_auto!=1) )
		return ERRM_BADP;
	if (err=break_wait(p))
		return err;
	finish(0);
	return 0;
}

word cl_cpx(char *p)
{
word err;
	if ( (*p==0) || (am_auto!=1) )
		return ERRM_BADP;
	if (err=break_cpx(p))
		return err;
	finish(0);
	return 0;
}

#if !DEMO


/* save a binary file as a raw image */
word cs_bin(char *p)
{
FILE *fp;
word err;
char name[MAXPATHLEN+1];
ulong start,len;

	err=parse_filename(&p,name);
	if (err)
		return err;
	getlong(start,&p);
	SKIPWS(p);
	getlong(len,&p);
	if (start>len)
		return ERRM_BADP;
	len=len-start+1;
	fp=fopen(name,"wb");
	if (fp==NULL)
		return remember_unixerr();
	if (bigfwrite(start, len, fp)==len)
		{
		if (fclose(fp)==0)
			return 0;
		}
	else
		fclose(fp);
	return remember_unixerr();
}
#endif

struct clist svlist[] = {
	"bin", cs_bin,
	"user", usym_save
};

word cmd_save(char *p)
{
	dotable(p,svlist);
}

struct clist ldlist[] = {
	"exec", cl_exec,
	"script", cl_script,
	"ascii", cl_ascii,
	"nodebug", cl_execnodebug,
	"kill", cl_killprog,
	"again", cl_reload,
	"wait", cl_wait,
	"bin", cl_bin,
	"nothing", cl_nothing,
	"amiga", cl_amiga,
	"user", usym_load,
	"cpx", cl_cpx
};

word cmd_load(char *p)
{
	dotable(p,ldlist);
}

/********** step commands ***************/

word cs_stepasm(char *p)
{
word count,err;

	SKIPWS(p);
	if (*p)
		{
		getword(count,&p);
		}
	else
		return step_asm();
	while (count--)
		{
		if (check_tsr_wait())
			return ERRM_INTERRUPTED;
		if (err=step_asm())
			return err;
		}
	return 0;
}

word cs_stepfasm(char *p)
{
word count,err;
	if (realproc<20)
		return cs_stepasm(p);
	SKIPWS(p);
	if (*p)
		{
		getword(count,&p);
		}
	else
		return step_asm_fast(0);
	while (count--)
		{
		if (check_tsr_wait())
			return ERRM_INTERRUPTED;
		if (err=step_asm_fast(0))
			return err;
		}
	return 0;
}

word cs_stepasmmiss(char *p)
{
	return step_asm_miss();
}

word cs_stepasmskip(char *p)
{
	return step_asm_skip();
}

word cs_interpret(char *p)
{
	return step_asm_rom();
}

word cs_stepsource(char *p)
{
	return step_source();
}

word cs_stepsourceskip(char *p)
{
	return step_sourceskip();
}

word cs_stepsnext(char *p)
{
	return step_sourcenext();
}

struct clist steplist[]= {
	"asm", cs_stepasm,
	"askip", cs_stepasmskip,
	"source", cs_stepsource,
	"sskip", cs_stepsourceskip,
	"amiss", cs_stepasmmiss,
	"fastasm", cs_stepfasm,
	"interpret", cs_interpret,
	"snext", cs_stepsnext
};

word cmd_step(char *p)
{
	dotable(p,steplist);
}

/*********** run commands *************/

word cr_until(char *p)
{
long result;
word err;

	SKIPWS(p);
	err=get_expression(&p,EXPR_LONG,&result);
	if (err)
		return err;
	if (err=set_break(result,BTYPE_COUNT,(char*)1L,TRUE))
		return err;
	return run_prog();

}

word cr_slow(char *p)
{
long result; word err;
char *expr;
	SKIPWS(p);
	expr=p;
	err=*p ? check_expression(&expr,EXPR_LONG,&result) : 0;
	if (err)
		return err;
	may_hide_screen();
	while (err==0)
		{
		if (check_tsr_wait())
			break;
		err=step_asm_slow(EMFLAG_NOSCREEN|EMFLAG_NOREFRESH);
		if ( (err==0) && (*p) )
			{
			expr=p;
			if ( (get_expression(&expr,EXPR_LONG,&result)==0)
				 && result )
				 break;
			}
		}
	world_changed(TRUE);
	must_show_screen();
	return (word) (err==ERRM_INTERRUPTED ? 0 : err);
}

word cr_fast(char *p)
{
long result; word err;
char *expr;
	if (realproc<20)
		return cr_slow(p);
	SKIPWS(p);
	expr=p;
	err=*p ? check_expression(&expr,EXPR_LONG,&result) : 0;
	if (err)
		return err;
	may_hide_screen();
	while (err==0)
		{
		if (check_tsr_wait())
			break;
		err=step_asm_fast(EMFLAG_NOSCREEN|EMFLAG_NOREFRESH);
		if (err==0)
			{
			expr=p;
			if ( (get_expression(&expr,EXPR_LONG,&result)==0)
				 && result )
				 break;
			}
		}
	world_changed(TRUE);
	must_show_screen();
	return (word) (err==ERRM_INTERRUPTED ? 0 : err);
}

struct clist rc_list[] = {
	"until", cr_until,
	"slow", cr_slow,
	"fast", cr_fast
};

word cmd_run(char *p)
{
char *expr;
long result;
word err;

	SKIPWS(p);
	if (*p==0)
		return run_prog();
	expr=p;
	if ( (get_expression(&expr,EXPR_LONG,&result)==0) && (*expr==0) )
		{ /* GO expression */
		if (err=set_break(result,BTYPE_COUNT,(char*)1L,TRUE))
			return err;
		else
			return run_prog();
		}
	dotable(p,rc_list);
}

bool askfinish;
txt(TX_ASKQUIT);
txt(TX_ASKQUIT2);

/* can be "noresident" */
word cmd_exit(char *p)
{
	SKIPWS(p);
	if ( (*p=='n') || (*p=='N') )
		if (am_auto==1)
			am_auto=0;

	if (askfinish)
		{
		if (
			(askfinish>0) ||
			(progstate!=PSTATE_NONE)
		   )
			if (yn_alert((progstate!=PSTATE_NONE) ? TX_ASKQUIT2 : TX_ASKQUIT,NULL)==FALSE)
				return 0;
		}

	finish(0);
	return 0;		/* will get here if TSR exit */
}

#if TEST_COMMAND
word cmd_test(char *p)
{
	return 0;
}
#endif

/* are there any more parameters? */
word more_params(char **p)
{
	if (**p==0)
		return 0;			/* if end of line */
	if (**p==' ')
		{
		while (**p==' ')
			*(*p)++;
		return 0;
		}
	else
		return ERRE_CRAPAFTER;
}

word cmd_pokeb(char *p)
{
word err; byte result; ulong addr;

	if (err=get_expression(&p,EXPR_LONG,&addr))
		return err;
	SKIPWS(p);
	for(;;)
		{
		if (err=get_expression(&p,EXPR_BYTE,&result))
			break;
		if (err=more_params(&p))
			break;
		if (err=pokeb(addr,result))
			break;
		if (*p==0)
			break;
		addr++;
		}
	world_changed(FALSE);
	return err;
}

word cmd_pokew(char *p)
{
word err; word result; ulong addr;

	if (err=get_expression(&p,EXPR_LONG,&addr))
		return err;
	SKIPWS(p);
	for (;;)
		{
		if (err=get_expression(&p,EXPR_WORD,&result))
			break;
		if (err=more_params(&p))
			break;
		if (err=pokew(addr,result))
			break;
		if (*p==0)
			break;
		addr+=2;
		}
	world_changed(FALSE);
	return err;
}

word cmd_pokel(char *p)
{
word err; long result; ulong addr;

	if (err=get_expression(&p,EXPR_LONG,&addr))
		return err;
	SKIPWS(p);
	for(;;)
		{
		if (err=get_expression(&p,EXPR_LONG,&result))
			break;
		if (err=more_params(&p))
			break;
		if (err=pokel(addr,result))
			break;
		if (*p==0)
			break;
		addr+=4;
		}
	world_changed(FALSE);
	return err;
}

word cmd_pokes(char *p)
{
word err; ulong addr;
char dest[100]; size_t i;

	if (err=get_expression(&p,EXPR_LONG,&addr))
		return err;
	SKIPWS(p);
	while (err==0)
		{
		if ( (*p!='\'') && (*p!='"') )
			{
			byte result;
			if (err=get_expression(&p,EXPR_BYTE,&result))
				break;
			if (err=more_params(&p))
				break;
			err=pokeb(addr++,result);
			}
		else
			{
			char *x;
			if (err=getstring(&p,dest,99))
				break;
			if (err=more_params(&p))
				break;
			i=strlen(x=dest);
			while (i--)
				{
				if (err=pokeb(addr++,*x++))
				break;
				}
			}
		if (*p==0)
			break;
		}
	world_changed(FALSE);
	return err;
}

/* given an address, print:
	[symbol+offset] [line#file]
 creates null-termed string, returns ptr to its end
*/
char *value_to_ascii(ulong x, char *where, ubyte maxsym)
{
char *sym; ubyte len; long diff;

	sym=find_close_symbol(x,&len,&diff);
	if (sym)
		{
		*where++=' ';
		if (len>maxsym) len=maxsym;
		while (len--)
			*where++=*sym++;
		if (diff)
			{
			*where++='+';
			where=sprintlong(where,(ulong)diff,0);
			}
		}
	where=find_line_txt(x,where);
	*where=0;
	return where;
}

word cmd_eval(char *p)
{
word err;
long result;
char *end;

	#if DOUBLES
double dbl;
char *oldp;

	oldp=p;
	if (err=get_expression(&p,EXPR_DOUBLE,&dbl))
		return err;
	if (!islongint(dbl))
		{
		linebuf[0]='=';
		sprintf(linebuf+1,double_format_string,dbl);
		strcat(linebuf,"\n");
		wprint_str(linebuf);
		return 0;
		}
	else
		p=oldp;						/* parse again for double */
	#endif
	if (err=get_expression(&p,EXPR_LONG,&result))
		return err;
	if (*p)
		return ERRM_BADEXPRESSION;
	sprintf(linebuf,"=%ld $%lx",result,result);
	end=linebuf;
	while (*end++)
		;
	end=value_to_ascii(result,--end,25);
	*end++='\n';
	*end=0;
	wprint_str(linebuf);
	return 0;
}

/*********** window commands *********/


/* get window number, or return error code */
/* can also check whether open */
word getwnum(char **p, word *w, bool open)
{
word result,err;
	getword(result,p);
	if (open)
		{
		if (check_wopen(result)==FALSE)
			return ERRM_BADWINDOW;
		}
	else
		{
		if (check_wvalid(result)==FALSE)
			return ERRM_BADWINDOW;
		}
	*w=result;
	return 0;
}

char *wtype_list[]={
	"regs", "diss", "command", "mem", "break", "watch", "mmu", "local", "fpu" ,NULL };
byte wtype_real[]={
	WTYPE_REGS, WTYPE_DISS, WTYPE_COMMAND, WTYPE_MEM,
	WTYPE_BREAK, WTYPE_WATCH, WTYPE_MMU, WTYPE_LOCAL, WTYPE_FPU };


word list_windows(char *p)
{
word err;
word i; bool open;
	for (i=0; i<MAXWINDOW; i++)
		{
		if (wlist[i]->open)
			{
			open=TRUE;
			switch (wlist[i]->type)
				{
				case WTYPE_REGS:
					if (i==1) open=FALSE;
					break;
				case WTYPE_DISS:
					if (i==2) open=FALSE;
					break;
				case WTYPE_COMMAND:
					if (i==0) open=FALSE;
					break;
				case WTYPE_MEM:
					if (i==3) open=FALSE;
					break;
				case WTYPE_SMART:
					if (i==2) open=FALSE;
					break;
				}
			if (open)
				{
				int j;
				for (j=0; j<sizeof(wtype_real); j++)
					if (wtype_real[j]==wlist[i]->type)
						break;
				sprintf(linebuf,"window open %s %d 0 %x %x %x %x\n",
					wtype_list[j],i,
					wlist[i]->x,wlist[i]->y,wlist[i]->w,wlist[i]->h);
				}
			else
				sprintf(linebuf,"window move %d %x %x %x %x\n",
					i,wlist[i]->x,wlist[i]->y,wlist[i]->w,wlist[i]->h);
			if (err=list_print(linebuf))
				return err;
			}
		}
	return 0;
}

/* window clone oldnum [deadtitle] */
word cw_clone(char *p)
{
word err,w;
word x,y,width,height;
struct ws *old,*new;
word dead;

	SKIPWS(p);

	if (err=getwnum(&p,&w,TRUE))		/* old must exist */
		return err;

	get_window(w,linebuf,&x,&y,&width,&height);
	/* linebuf used as a junk buffer for the old name */
	
	SKIPWS(p);
	/* we need a new window number */
	if ( (dead=spare_window(FALSE)) == -1)
		return ERRM_NOSPARE;

	if (err=open_window(dead,x,y,width,height,*p ? p : NULL,WTYPE_DEAD ))
		return err;

	/* copy the contents from the old to the new */
	/* the new one has been CLSed by the open */
	old=(struct ws*)getwptr(w);
	new=(struct ws*)getwptr(dead);
	x=old->w;
	while (--x)
		{
		y=old->h;
		while (--y)
			{
			new->contents[x][y]=old->contents[x][y];
			}
		}
	update_contents(new);
	return 0;
}

/* format: type number [addr] [x y w h] */
word cw_open(char *p)
{
word err,num;
word len,i;
char **type;
byte wtype;
word x,y,w,h;
long l;
char *next;
struct ws *oldw;

	SKIPWS(p);
	len=comlen(p,&next);

	i=0;
	type=(char**)&wtype_list;
	wtype=0;

	do
		{
		if (strnicmp(*type,p,len)==0)
			{
			wtype=wtype_real[i];
			break;
			}
		i++;
		}
	while (*++type);

	if (wtype==0)
		return ERRM_BADP;

	p=next;
	SKIPWS(p);
	if (*p==0)
		num=-1;
	else
		{
		getword(num,&p);
		if (num!=-1)
			if (check_wvalid(num)==FALSE)
				return ERRM_BADWINDOW;
		}

	if (num==-1)
		if ( (num=spare_window(FALSE))==-1)
			return ERRM_NOSPARE;

	oldw=wlist[num];				/* get old window, if present */
	if (oldw->open==FALSE)
		oldw=NULL;

	SKIPWS(p);
	if (*p)
		{
		getlong(l,&p);
		}
	else
		{
		if (oldw)
			l=oldw->wlong;
		else
			l=0;
		}

	SKIPWS(p);
	if (*p==0)
		{
		if (oldw)
			{
			x=oldw->x; y=oldw->y; w=oldw->w; h=oldw->h;
			}
		else
			{
			x=0; y=0; w=30; h=10;
			}
		}
	else
		{
		getword(x,&p);
		SKIPWS(p);
		getword(y,&p);
		SKIPWS(p);
		getword(w,&p);
		SKIPWS(p);
		getword(h,&p);
		}

	if (err=open_window(num,x,y,w,h,NULL,wtype))
		return err;
	
	window_setlong(num,l,TRUE);			/* draws too */
	return 0;
}

word cw_close(char *p)
{
word err,w;

	if (err=getwnum(&p,&w,FALSE))	/* no harm if not there */
		return err;
	if (w)							/* dont close #0 */
		close_window(w,TRUE);
	return 0;
}

word cw_recalc(char *p)
{
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	refill_window(w,TRUE);
	return 0;
}

word cw_front(char *p)
{
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	front_window(getwptr(w));
	return 0;
}

word cw_move(char *p)
{
word err,w,x,y,width,height;
word rx,ry,rw,rh;
char oldtitle[MAXTITLE+1];
bool finished;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	SKIPWS(p);
	if (*p==0)			/* no params mean move me with keyboard */
		{
		word key;
		front_window(getwptr(w));
		get_window(w,oldtitle,&x,&y,&width,&height);
		window_title(w,TX_MOVEME,TRUE);
		finished=FALSE;
		do
			{
			word mx,my,event;
			bool newpos;
			word ox,oy,ow,oh;
			
			newpos=FALSE;
			ox=x; oy=y; ow=width; oh=height;
			event=get_event(&key,&mx,&my);
			auto_numeric(&key);
			if (event&EV_KEY)
				{
				switch (key)
					{
					case KEY_ESC: case KEY_RETURN: case KEY_ENTER:
						finished=TRUE; break;
					case KEY_LEFT:
						if (x) { x--; newpos=TRUE; }
						break;
					case KEY_RIGHT:
						if ((x+width)<maxw)
							{ x++; newpos=TRUE; }
						break;
					case KEY_UP:
						if (y) { y--; newpos=TRUE; }
						break;
					case KEY_DOWN:
						if ((y+height)<maxh)
							{ y++; newpos=TRUE; }
						break;
					case KEY_PAGEUP:
						if (height>5)
							{ height--; newpos=TRUE; }
						break;
					case KEY_PAGEDOWN:
						if ( (y+height)<maxh)
							{ height++; newpos=TRUE; }
						break;
					case KEY_PAGELEFT:
						if (width>6)
							{ width--; newpos=TRUE; }
						break;
					case KEY_PAGERIGHT:
						if ( (x+width)<maxw )
							{ width++; newpos=TRUE; }
						break;
					}
				if (newpos)
					{
					junk_keys(key);
					plot_border(ox,oy,ow,oh,FALSE);
					plot_border(x,y,width,height,TRUE);
					}
				}
			else
				finished=TRUE;
			}
		while (!finished);
		plot_border(x,y,width,height,FALSE);
		window_title(w,oldtitle,TRUE);		/* restore */
		if (key!=KEY_ESC)
			{
			err=change_window(w,x,y,width,height,&rx,&ry,&rw,&rh);
			if (err)
				return err;						/* shouldnt happen */
			else
				update_rectangle(rx,ry,rw,rh);
			return 0;
			}
		}
	else
		{
		getword(x,&p);
		SKIPWS(p);
		getword(y,&p);
		SKIPWS(p);
		getword(width,&p);
		SKIPWS(p);
		getword(height,&p);
		if (err=change_window(w,x,y,width,height,&rx,&ry,&rw,&rh))
			return err;
		update_rectangle(rx,ry,rw,rh);
		}
	return 0;
}

word cw_zoom(char *p)
{
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;

	return zoom_window(w);
}

word cw_addr(char *p)
{
ulong addr;
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	SKIPWS(p);
	getlong(addr,&p);
	SKIPWS(p);
	if (*p)
		return ERRE_CRAPAFTER;
	window_setlong(w,addr,TRUE);
	return 0;
}

static char *wmlist[]={ "asm", "mixed", "source" };

word cw_mode(char *p)
{
word mode;
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	SKIPWS(p);
	if (*p)
		{
		mode=cmp_token(&p,wmlist,3);
		if (++mode==0)
			return ERRM_BADP;
		}
	else
		mode=-1;					/* just go to next */
	window_setword(w,mode,TRUE);
	return 0;
}

word cw_lock(char *p)
{
word err,w;
bool simple; long *lockptr;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	SKIPWS(p);
	err=parse_lock(p,&simple,(char**)&lockptr);
	if (err)
		return err;
	window_lock(w,(char*)lockptr,simple,p,TRUE);
	return 0;
}

word cw_print(char *p)
{
word err,w;

	if (err=getwnum(&p,&w,TRUE))
		return err;
	return dump_window(w);
}

struct clist wclist[] = {
	"close", cw_close,
	"recalc", cw_recalc,
	"front", cw_front,
	"move", cw_move,
	"address", cw_addr,
	"zoom", cw_zoom,
	"open", cw_open,
	"clone", cw_clone,
	"lock", cw_lock,
	"mode", cw_mode,
	"print", cw_print
};

word cmd_window(char *p)
{
	dotable(p,wclist);
}

/************** Breakpoint Commands *******************/

/* most of these allow a first parameter to be a brknum or an address */
/* we are not allowed to know what a brk structure is */

#define brk void


/* allow monst syntax for breakpoints */
word br_monst(char *p)
{
ulong b; word btype; word err;
char *count; long junk;
bool clear;

	/* expr [, [ count | * | = | ?cond ] ] */
	btype=BTYPE_COUNT; clear=!auto_brktype;
	SKIPWS(p);
	getlong(b,&p);
	SKIPWS(p);
	count=(char*)(1L);
	if (*p==',')
		{
		switch (*++p)
			{
			case '*': btype=BTYPE_ALWAYS; ++p; break;
			case '=': btype=BTYPE_RECORD; ++p; count=NULL; break;
			case '?': btype=BTYPE_COND;
					count=++p;
					err=check_expression(&p,EXPR_LONG,&junk);
					if (err)
						return err;
					break;
			case '-': if (*(p+1)==0)
				{
				clear_break(b);
				world_changed(TRUE);
				return 0;
				}
				/* no break - might be -expression */
			default:
				getlong(count,&p);
				break;
			}
		}
	if (*p=='+')
		{
		clear=FALSE;
		p++;
		}
	if (*p)
		return ERRM_BADP;
	if (err=set_break(b, btype, count, clear))
		return err;
	world_changed(FALSE);			/* TRUE causes smart window mode to recalc */
	return 0;
}

bool auto_brktype;			// TRUE means permanent, FALSE means temp

char *brtlist[]={ "after", "count", "permanent", "conditional", "noclear", "trap", "temporary" };

/* break set addr TYPE NOCLEAR expr */
word br_set(char *p)
{
ulong b; word btype; bool clear;
word err; word tok; bool wt;

	clear=!auto_brktype; btype=BTYPE_COUNT;		/* defaults */
	wt=TRUE;
	SKIPWS(p);
	getlong(b,&p);
	while (wt)
		{
		SKIPWS(p);
		if (*p==0)
			break;
		tok=cmp_token(&p,brtlist,7);
		switch  (tok)
			{
			case 0: btype=BTYPE_COUNT; break;
			case 1: btype=BTYPE_RECORD; break;
			case 2: btype=BTYPE_ALWAYS; break;
			case 3: btype=BTYPE_COND; break;
			case 4: clear=FALSE; break;
			case 5: btype=BTYPE_TRAP; break;
			case 6: clear=TRUE; break;
			default: wt=FALSE;
			}
		}
	if (err=set_break_txt(b,btype,clear,p))
		return err;
	world_changed(TRUE);				/* redraw it */
	return 0;
}

word br_clear(char *p)
{
ulong addr;
void *b;
word err;

	SKIPWS(p);
	if (*p==0)
		{
		clear_brk(NULL);			/* all if no params */
		}
	else
		{
		getlong(addr,&p);
		if ( (b=find_brk(addr)) == NULL)
			return ERRM_BRKNOTFOUND;
		clear_brk(b);
		}
	world_changed(TRUE);
	return 0;
}


word br_on(char *p)
{
ulong addr;
void *b;
word err;

	SKIPWS(p);
	if (*p==0)
		{
		on_brk(NULL);			/* all if no params */
		}
	else
		{
		getlong(addr,&p);
		if ( (b=find_brk(addr)) == NULL)
			return ERRM_BRKNOTFOUND;
		on_brk(b);
		}
	world_changed(TRUE);
	return 0;
}

word br_off(char *p)
{
ulong addr;
void *b;
word err;

	SKIPWS(p);
	if (*p==0)
		{
		off_brk(NULL);			/* all if no params */
		}
	else
		{
		getlong(addr,&p);
		if ( (b=find_brk(addr)) == NULL)
			return ERRM_BRKNOTFOUND;
		off_brk(b);
		}
	world_changed(TRUE);
	return 0;
}

extern word brk_list(char *p);

struct clist brlist[] = {
	"set", br_set,
	"clear", br_clear,
	"on", br_on,
	"off", br_off,
	"monst", br_monst
};

word cmd_break(char *p)
{
	dotable(p,brlist);
}

word check_builtin(char *, ubyte);

word cmd_alias(char *p)
{
word len;
char *def;
word err;

	len=comlen(p,&def);
	if (len>255)
		return ERRM_TOOLONG;
	SKIPWS(def);
	
	if (err=check_builtin(p,(ubyte)len))
		return err;

	return define_alias(p, (ubyte)len, def);
}

word cmd_proc(char *p)
{
word len,err;
char *def;

	len=comlen(p,&def);
	if (len>255)
		return ERRM_TOOLONG;
	SKIPWS(def);

	if (err=check_builtin(p,(ubyte)len))
		return err;

	return define_proc(p, (ubyte)len, def);
}

/* if ever gets called then we aren't in a procedure */
word cmd_endproc(char*p)
{
	return ERRM_DEFINE;
}

/* strings must be quoted; spaces are ignored; everything else
	is assumed to be a number, preceeded by $ if hex */
word cmd_echo(char *p)
{
char c[20];
long l;
word err;

	err=0;
	c[1]=0;				/* ultra-crude, but who cares? */
	while (c[0]=*p++)
		{
		if (c[0]==QUOTE)
			{
			while (c[0]=*p)
				{
				if (c[0]==QUOTE)
					break;
				wprint_str(c);
				p++;
				}
			if (c[0]==0)
				break;
			p++;
			}
		else if (c[0]!=' ')
			{
			char *fmt;
			
			p--;
			if (*p=='$')
				{
				p++;
				fmt="%lX";
				}
			else
				fmt="%ld";
			if (err=get_expression(&p,EXPR_LONG,&l))
				break;
			sprintf(c,fmt,l);
			wprint_str(c);
			c[1]=0;
			}
		}
	wprint_str("\n");
	return err;
}

/************* dialog command ****************/

/* dialog title line1 line2 etc */
/* the line is copied into #d */
word cmd_dialog(char *p)
{
word err;
char *pstart,*t,c;
char title[MAXTITLE+1];
word numparams;

	SKIPWS(p);
	pstart=p;
	if (*p==0)
		return ERRM_BADP;
	t=title;
	while (c=*p++)
		{
		if (c==' ')
			break;
		if (c==QUOTE)
			{
			word cp;
			cp=parse_quote(p)-p-1;
			while (cp-->0)
				*t++=*p++;
			if (*p==QUOTE)
				p++;
			}
		else
			*t++=c;
		}
	*t=0;
	if (c==0)
		return ERRM_BADP;			/* if no params */

	numparams=1;					/* super-hack */

	if ( err=open_dialog(title,30,(word)(numparams+4),p) )
		return err;
	
	err=wait_dialog();
	
	close_dialog();
	
	return err;
}

/************** Help Command *******************/

/* help_list points to a list of CR/null terminated strings */
char *help_list;
word help_count;

word cmd_help(char *p)
{
char *h;
word i;
size_t len;

	SKIPWS(p);

	if ( (*p) && (h=help_list) )
		{
		i=help_count;
		len=strlen(p);
		while (i--)
			{
			if (strnicmp(p,h,len)==0)
				{
				safe_print(h);		/* includes CR */
				while ( (i) && (*(h+strlen(h)+1)=='!') )
					{
					/* handle multiple liners */
					h+=strlen(h)+1;
					safe_print(h+1);		/* dont print '!' */
					i--;
					}
				return 0;
				}
			h+=strlen(h)+1;
			}
		sprintf(linebuf,TX_HELPNOTFOUND,p);
		safe_print(linebuf);
		}
	else
		{
		if (help_list)
			safe_print(TX_HELPMORE);
		else
			safe_print(TX_HELPNOFILE);
		safe_print(TX_HELPBRIEF);
		}
	return 0;
}

word list_help(char *p)
{
word err; word i;

	if (p=help_list)
		{
		err=0;
		i=help_count;
		while (i--)
			{
			if (*p=='!') p++;
			if (err=list_print(p))
				break;
			p+=strlen(p)+1;
			}
		}
	else
		err=list_print(HELP_STARTUP " file not found\n");
	return err;
}

static char *sclist[]={ "font", "clear", "user", "other" };

word cmd_screen(char *p)
{
word event,key,mx,my;
word tok;
long scr; word err;

	SKIPWS(p);
	if (*p==0)
		{
		if (switch_mode)			/* dont if none */
			{
			must_hide_screen();
			do
				{
				event=get_event(&key,&mx,&my);
				}
			while ( (event&(EV_KEY|EV_ALT|EV_CLICK))==0 );
			must_show_screen();
			}
		}
	else
		{
		tok=cmp_token(&p,sclist,4);
		switch (tok)
			{
			case 0:
				change_mode(); break;
			case 1:
				screen_clear();
				update_rectangle(0,0,maxw,maxh);
				break;
			case 2:
				switch_screen_user();
				break;
			case 3:
				getlong(scr,&p);
				switch_screen_other(scr);
				break;
			default:
				return ERRM_BADP;
			}
		}
	return 0;
}

word list_diss2(char *p)
{
ulong start,end;
word err;

	SKIPWS(p);
	getlong(start,&p);
	SKIPWS(p);
	if (*p==0)
		end=0xFFFFFFFF;			/* end addr is optional */
	else
		getlong(end,&p);
	if ( *p || (end<=start) )
		return ERRM_BADP;
	return list_diss(start,end);
}

word list_info(char*),list_internal(char*),list_functions(char*),list_amp(char*);

struct clist listlist[] = {
	"break", brk_list,
	"reserved", list_reserved,
	"asm", list_asm,
	"alias", list_alias,
	"history", list_history,
	"commands", list_chistory,
	"stack", list_stack,
	"info", list_info,
	"user", list_user,
	"memory", list_memory,
	"mmu", list_mmu,
	"amp", list_internal,
	"data", list_data,
	"windows", list_windows,
	"help", list_help,
	"keys", list_key,
	"function", list_functions,
	"diss", list_diss2,
	"bugs", list_amp
};

word cmd_list(char *p)
{
word err;

	if (err=list_init(&p))
		return err;
	err=do_table(p,listlist,(word)sizeof(listlist));
	list_deinit();
	return err;
}

word cs_data(char *p)
{
ulong s,e;
word err;
	getlong(s,&p);
	SKIPWS(p);
	getlong(e,&p);
	if (e==0)
		e=s;				/* shortcut for single entry */
	SKIPWS(p);
	return data_add(s,e,p);
}

struct clist symlist[] = {
	"add",usym_add,
	"save",usym_save,
	"load",usym_load,
	"clear",usym_clear,
	"data",cs_data
};

word cmd_symbol(char *p)
{
	dotable(p,symlist);
}

word cmd_madd(char *p)
{
ulong start,end; word flag;
word err;

	SKIPWS(p);
	getlong(start,&p);
	SKIPWS(p);
	getlong(end,&p);
	SKIPWS(p);
	if (*p==0)
		flag=0;
	else
		getword(flag,&p);
	return memory_add(start,end,flag);
}

word cmd_mfill(char *p)
{
ulong start,end; byte what;
word err;

	SKIPWS(p);
	getlong(start,&p);
	SKIPWS(p);
	getlong(end,&p);
	SKIPWS(p);
	getbyte(what,&p);
	return memory_fill(start,end,what);
}

static struct clist memlist[] = {
	"add",cmd_madd,
	"fill", cmd_mfill
};

word cmd_memory(char *p)
{
	dotable(p,memlist);
}


struct clist mmulist[] = {
	"init",mmu_init,
	"wprotect",mmu_wprotect,
	"wclear",mmu_wclear,
	"reset",mmu_reset
};

word cmd_mmu(char *p)
{
	dotable(p,mmulist);
}

/********** search commands ***********/
word sf_wnum;				/* window number, or 0 if none */
byte sf_type;				/* 0 means none */
byte sf_howmany;
ulong sf_addr;				/* so far */
#define MAXSEARCH 10
char sf_area[MAXSEARCH*sizeof(long)];

static char *sf_list[]={ "attach", "next", "byte", "word", "long", "instruction", "text" };

word search_next(void)
{
ulong even,old;
	if (sf_howmany==0)
		return ERRM_BADP;
	even = (sf_type=='b') ? 1 : 2;
	if (sf_wnum && check_wopen(sf_wnum) )
		sf_addr=wlist[sf_wnum]->wlong;
	/* align then increment */
	sf_addr=(sf_addr&(~(even-1))) + even;	

	if (sf_wnum && (wlist[sf_wnum]->type==WTYPE_SMART) )
		{
		/* smart windows are VERY different */
		if (smart_search(sf_wnum,sf_area,sf_howmany))
			return 0;
		}
		
	old=sf_addr;
	sf_addr=mach_search(sf_type,sf_addr,sf_howmany,sf_area);
	if (sf_wnum && check_wopen(sf_wnum) )
		window_setlong(sf_wnum,sf_addr,TRUE);
	else
		{
		if (old==sf_addr)
			sprintf(linebuf,TX_NOTFOUND);
		else
			sprintf(linebuf,TX_FOUND,sf_addr);
		safe_print(linebuf);
		}
	return 0;
}

word cmd_search(char *p)
{
word mode,err;
word count; char *store;
	SKIPWS(p);
	mode=cmp_token(&p,sf_list,7);
	SKIPWS(p);
	switch (mode)
		{
		case -1: return ERRM_BADP; break;
		case 0:
			if (*p==0)
				sf_wnum=0;
			else
				getword(sf_wnum,&p);
			return 0; break;
		case 1:
			if (*p)
				getlong(sf_addr,&p);
			return search_next(); break;
		default:
			sf_type=sf_list[mode][0]; break;
		}
	sf_howmany=0;
	if (!(sf_wnum && check_wopen(sf_wnum)))
		getlong(sf_addr,&p);
	SKIPWS(p);

	/* parse the various parameters */
	store=sf_area; count=0;
	if ( (sf_type=='t') || (sf_type=='i') )
		{ /* text is special */
		if (err=getstring(&p,sf_area,MAXSEARCH*sizeof(long)))
			return err;
		count=(byte)strlen(sf_area);
		if (sf_type=='t')
			sf_type='b';
		else
			{ /* convert first space into tab */
			if (store=strchr(sf_area,' '))
				*store='\t';
			}
		}
	else while (*p)
		{
		SKIPWS(p);
		if (*p==0)
			break;
		if (store>(&sf_area[MAXSEARCH*sizeof(long)]))
			return ERRM_BADP;
		switch (sf_type)
			{
			case 'b':
				getbyte(*store,&p);
				store++;
				break;
			case 'w':
				getword(*store,&p);
				store+=sizeof(word);
				break;
			case 'l':
				getlong(*store,&p);
				store+=sizeof(long);
				break;
			default:
				return ERRM_BADP; break;
			}
		count++;
		}
	sf_howmany=count;
	return search_next();
}

char *double_format_string="%g";			/* RSN allow editing */

static char *set_list[]={ "source_path" };

word cmd_set(char *p)
{
word mode,err;
char *dest;
size_t max;

	SKIPWS(p);
	if (*p==0)
		{
		/* list them CRUDELY */
		sprintf(linebuf,"source_path=%s\n",sourcepath);
		safe_print(linebuf);
		return 0;
		}

	mode=cmp_token(&p,set_list,1);
	switch (mode)
		{
		case 0: dest=sourcepath; max=MAXPATHLEN; break;
		default:
			return ERRM_BADP;
		}
	SKIPWS(p);
	if (*p==0)
		{
		/* dump it */
		sprintf(linebuf,"%s='%s'\n",set_list[mode],dest);
		safe_print(linebuf);
		return 0;
		}
	if (err=getstring(&p,dest,max))
		return err;
	return 0;
}

char *watchtlist[]= { "add", "delete", "clear", "edit" };

word cmd_watch(char *p)
{
word err;
word tok;
char *expr,*fmt;
long l;

	tok=cmp_token(&p,watchtlist,4);
	if (tok==-1)
		return ERRM_BADP;
	SKIPWS(p);
	switch (tok)
		{
		case 3:
			/* watch edit number expr [frmat] */
			getword(tok,&p);
			SKIPWS(p);
			/* carries on */
		case 0:
			/* watch add expr [format] */
			fmt=NULL;
			expr=p;
			if (err=check_expression(&p,EXPR_LONG,&l))
				break;
			SKIPWS(p);
			if (*p)
				{
				fmt=p;
				*--p=0;
				}
			err=add_watch(expr,fmt,tok);
			break;
		case 1:
			if (*p==0)
				tok=-1;
			else
				{
				getword(tok,&p);
				}
			err=kill_watch(tok);
			break;
		case 2:
			err=kill_watch(-1);
			break;
		default:
			err=ERRM_BADP;
			break;
		}
	return err;
}

/************* main command handler **************/

extern word cmd_dumpsym(char *);
extern word cmd_reg(char *);
word cmd_key(char *);
extern word cmd_info(char *);
extern word cmd_cd(char*);
extern word cmd_dir(char*);

struct clist comlist[] = {
	"exit", cmd_exit,
	"quit", cmd_exit,
	"system", cmd_exit,
#if TEST_COMMAND
	"test", cmd_test,
#endif
	"window", cmd_window,
	"help", cmd_help,
	"eval", cmd_eval,
	"load", cmd_load,
	"step", cmd_step,
	"go", cmd_run,
	"run", cmd_run,
	"dumpsyms", cmd_dumpsym,
	"break", cmd_break,
	"screen", cmd_screen,
	"list", cmd_list,
	"alias", cmd_alias,
	"echo", cmd_echo,
	"reg", cmd_reg,
	"dialog", cmd_dialog,
	"proc", cmd_proc,
	"endproc", cmd_endproc,
	"key", cmd_key,
	"pokeb", cmd_pokeb,
	"pokew", cmd_pokew,
	"pokel", cmd_pokel,
	"pokes", cmd_pokes,
	"symbol", cmd_symbol,
	"memory", cmd_memory,
	"mmu", cmd_mmu,
	"search", cmd_search,
	"set", cmd_set,
	"cdirectory", cmd_cd,
	"watch", cmd_watch,
	"directory", cmd_dir,
	"save", cmd_save
};


/* do a command, or remember it if defining */

word do_command(char *p)
{
word err,l; char *param;
char aliasbuffer[MAXALIASLEN+1];

	if (stack_space()<1000)
		return ERRM_NOSTACK;

	if (defining_proc)
		return add_proc(p);

	SKIPWS(p);
	if ( (*p==0) || (*p==COMMENTCHAR) )
		return 0;

	if (*p=='?')
		{
		p++;
		SKIPWS(p);
		return cmd_eval(p);
		}

	if ( (l=comlen(p,&param))==0)
		return ERRM_BADCOMMAND;
	SKIPWS(param);
	err=find_alias(p,l,aliasbuffer);
	if (err)
		return err;
	else if (aliasbuffer[0])
		return do_command(aliasbuffer);		/* recurse */
	else
		dotable(p,comlist);

}

/* called by startup code with program command line */
void parse_cmdline(int argc, char *argv[])
{
char *name,*cmd;
word err;
bool freecmd;

	#if DEMO
	demo_intro();
	#endif
	
	if (other_startup_file)
		{
		err=cl_script(other_startup_file);
		if (err)
			{
			sprintf(linebuf,TX_DURING,error_message(err),other_startup_file);
			safe_print(linebuf);
			}
		}

	name=NULL; freecmd=FALSE;
	if (argc>1)
		{
		name=argv[1];
		if (argc==3)
			cmd=argv[2];			/* easy if only 1 */
		else if (argc>3)
			{ /* make one long command-line from all the argvs */
			int c;
			size_t total;
			total=0;
			c=2;
			while (c<argc)
				total+=strlen(argv[c++])+1;
			if ( (cmd=getanymem(total))==NULL )
				cmd=argv[2];				/* wimp out if no mem */
			else
				{
				char *p;
				c=2; p=cmd; freecmd=TRUE;
				while (c<argc)
					{
					strcpy(p,argv[c++]);
					while (*p)
						p++;
					*p++=' ';
					}
				*--p=0;						/* null term it */
				}
			}
		else
			cmd="";
		}

	#if DEMO
	name = "tutorial\vowels.ttp";
	#endif
	
	if ( (name) && (*name) )
		{
		stccpy(progname,name,255);
		fixup_extension(progname);
		err=load_prog(progname,cmd,TRUE);
		if (err)
			{
			safe_print(error_message(err));
			sprintf(linebuf," (%s)\n",progname);
			safe_print(linebuf);
			}
		}
	if (freecmd)
		freemem(cmd);
}

/******** alt/command key handler ************/

/* each alt key is assigned a command string */
/* each string is allocated as required */

char *alt_lookup[26],*ctrl_lookup[26],*fn_lookup[20],*normal_lookup[26];

word define_anykey(char *lookup[],char index, char *defn)
{
size_t len;

	if ( (len=strlen(defn))>MAXALIASLEN )
		return ERRM_BADP;

	if (lookup[index])
		{
		freemem(lookup[index]);
		lookup[index]=NULL;
		}
	if (len==0)
		return 0;						/* if undefining */
	if ( (lookup[index]=getanymem(len+1))==NULL)
		return ERRM_NOMEMORY;
	strcpy(lookup[index],defn);
	return 0;
}

word define_alt(char key, char *defn)
{
	key=upper(key)-'A';
	if ( (key<0) || (key>25) )
		return ERRM_BADP;
	return define_anykey(alt_lookup,key,defn);
}

word define_ctrl(char key, char *defn)
{
	key=upper(key)-'A';
	if ( (key<0) || (key>25) )
		return ERRM_BADP;
	return define_anykey(ctrl_lookup,key,defn);
}

word define_fn(word fn, char *defn)
{
	if ( (fn<1) || (fn>20) )
		return ERRM_BADP;
	return define_anykey(fn_lookup,(char)(--fn),defn);
}

word define_normal(char fn, char *defn)
{
	fn=(char)tolower((int)(uchar)fn)-'a';
	if ( (fn<0) || (fn>25) )
		return ERRM_BADP;
	return define_anykey(normal_lookup,fn,defn);
}

struct varlist { char *name; long *where; } vars[] =
{
	"mode", &defaultvideomode,
	"maxfiles", &maxfiles,
	"history", &hsize,
	"fontsize", &fontsize,
	"overscan", &overscan_flag,
	NULL,NULL
};

word set_var(char *var, word len, long value)
{
word i;
	i=0;
	while (vars[i].name)
		{
		if (strlen(vars[i].name)==len)
			{
			if (strnicmp(vars[i].name,var,(size_t)len)==0)
				{
				*(vars[i].where)=value;
				return 0;
				}
			}
		i++;
		}
	return ERRM_SYMNOTFOUND;
}


/* called during startup, must also handle default vars */

word init_commands( int *argc, char **argv[])
{
word err;
FILE *fp; char line[256];
char *p,c;
char *eend;
long value;

	/* read the startup file */
	err=0;
	if (find_file(VAR_STARTUP,line,NULL))
		{
		fp=fopen(line,"rt");
		if (fp!=NULL)
			{
			/* format for lines is:
				/;#*' comments
				blank lines
				var<whitespace|=>expr	*/
			do
				{
				p=fgets(line,255,fp);
				if (p)
					{
					if ( (*p==0) || (*p=='\n') || (*p==';')
							|| (*p=='*') || (*p=='\'') || (*p=='/') )
								continue;			/* junk some lines */
					for ( ;; )
						{
						if ( (c=*p++)==0 )
							break;
						if (!isalpha(c))
							break;
						}
					eend=p;
					while ( (c=='=') || (isspace(c)) )
						c=*p++;
					p--;
					if (c)
						{
						err=simple_expr(&p,&value);
						if (err==0)
							{
							if ((*p) && !isspace(*p))
								err=ERRE_CRAPAFTER;
							else
								{
								err=set_var(line,(word)(eend-line-1),value);
								}
							}
						}
					else
						err=ERRE_CRAPAFTER;
					}
				}
			while ( (p) && (err==0) );
			fclose(fp);
			}
		}

	/* read environment var */
	/* (errors not reported) */
	p=getenv(VAR_ENV);
	if (p)
		{
		char *start;
		for (;;)
			{
			start=p;
			while (c=*p++)
				if (c=='=')
					break;
			if (c==0)
				break;
			eend=p;
			if (simple_expr(&p,&value)==0)
				set_var(start,(word)(eend-start-1),value);
			if ( (*p==',') || (*p==';') )
				p++;
			else
				break;
			}
		}
		
	/* read -vSYM=value from command line */
	if ( (*argc>=2) && ((*argv)[1][0]=='-') )
		{
		char **arg;
		int i;
		i=1;
		arg=*argv;
		while ( (*argc>=2) && (strnicmp(arg[i],"-v",2)==0) )
			{
			p=arg[i]+2;
			while (c=*p++)
				if (c=='=')
					break;
			if (c)
				{
				eend=p;
				if (simple_expr(&p,&value)==0)
					set_var(arg[i]+2,(word)(eend-arg[i]-1-2),value);
				}
			(*argv)++;						/* kill the param from the list */
			(*argc)--;
			i++;
			}
		}
	// -sscriptfile
	if ( (*argc>=2) && (strnicmp((*argv)[1],"-s",2)==0) )
		{
		other_startup_file = &(*argv)[1][2];
		(*argv)++;
		(*argc)--;
		}
	return err;
}

void do_altkey(word key)
{
word err;
char *com;

	if (defining_proc)
		return;				/* not during definition */

	if (isdigit(key))
		{
		key-='0';
		if (check_wopen(key))
			front_window(getwptr(key));
		return;
		}
	if ( (key>='A') && (key<='Z') )
		{ /* alt-alphas */
		key-='A';
		if ((com=alt_lookup[key])==NULL)
			return;
		}
	else if ( (key>0) && (key<21) )
		{ /* function keys */
		key--;
		if ((com=fn_lookup[key])==NULL)
			return;
		}
	else
		return;
	if (err=do_command(com))
		error_alert(err,com);
}

/* return TRUE if command found, else FALSE */
bool do_controlkey(word key)
{
word err;
char *c;

	if (defining_proc)
		return FALSE;				/* ignore the key */

	key&=0xff;
	
	/* ? always activates, space does unless zoomed */
	if (
		( (key=='?') || (key==' ') ) &&
		( (wlist[0]->open) && (wlist[0]->type==WTYPE_COMMAND) )
	   )
	   {
	   if ( (key=='?') || (any_zoomed()==FALSE) )
	   	{
	   	front_window(wlist[0]);
	   	key_command(key);
	   	return TRUE;
	   	}
	   }
	   
	if (isalpha(key))
		{
		c=normal_lookup[toupper(key)-'A'];
		if (c==NULL)
			{
			/* we're an alpha-numeric. Lets activate the command window for the user */
			if ( (wlist[0]->open) && (wlist[0]->type==WTYPE_COMMAND) )
				{
				front_window(wlist[0]);
				key_command(key);			/* had better not recurse! */
				}
			return TRUE;
			}
		}
	else if ( (key==0) || (key>26))
		return FALSE;
	else
		{
		junk_keys(key);
		key--;
		c=ctrl_lookup[key];
		}
	if (c==NULL)
		return FALSE;
	if (*c==0)
		return FALSE;
	if (err=do_command(c))
		error_alert(err,c);
	return TRUE;
}

static char *klist[]={"alt","ctrl","normal","fn","record","play"};

word cmd_key(char *p)
{
word len;
char *end,key;

	SKIPWS(p);
	len=comlen(p,&end);
	SKIPWS(end);
	key=*end++;
	SKIPWS(end);
	switch (cmp_token(&p,klist,6))
		{
		case 0:
			return define_alt(key,end);
		case 1:
			return define_ctrl(key,end);
		case 2:
			return define_normal(key,end);
		case 3:
			if (isdigit(key))
				{
				word fn;
				fn=(word)key-'0';
				if (isdigit(*end))
					fn=(fn*10)+ *end++ -'0';
				return define_fn(fn,end);
				}
		case 4:
			return cmd_key_record(p);
		case 5:
			return cmd_key_play(p);
		}
	return ERRM_BADP;
}

word list_key(char *p)
{
word err;
word t,i;
char **lookup;
word max;

	for (t=0; t<4; t++)
		{
		max=26;
		switch (t)
			{
			case 0: lookup=alt_lookup; break;
			case 1: lookup=ctrl_lookup; break;
			case 2: lookup=normal_lookup; break;
			case 3: lookup=fn_lookup; max=20; break;
			}
		for (i=0; i<max; i++)
			{
			char *p;
			p=lookup[i];
			if ( (p==NULL) || (*p==0) )
				continue;
			if (max==20)
				sprintf(linebuf,"key fn %d %s\n",i+1,p);
			else
				sprintf(linebuf,"key %s %c %s\n",klist[t],i+'a',p);
			if (err=list_print(linebuf))
				return err;
			}
		}
	return 0;
}

/* does this match with a reserved word, or its start */

word check_builtin(char *start, ubyte len)
{
word i,l;
	for (i=0; i<(sizeof(comlist)/sizeof(struct clist)); i++)
		{
		l=strlen(comlist[i].name);
		if (len>l)
			continue;
		if (strnicmp(start,comlist[i].name,l)==0)
			return ERRM_AMBIGUOUS;
		}
	return 0;
}
