/* symbol table handling for Mon */

#include <error.h>
#include <ctype.h>
#include "mon.h"
#include "syms.h"

extern int _OSERR;

txt(TX_NONSTDDEBUG);
txt(TX_NODEBUGINFO);
txt(TX_DEBUGOK);
txt(TX_LOADING);
txt(TX_SOURCEDB);
txt(TX_SYMBOLMENU);
txt(TX_SCOPEDDB);
txt(TX_READINGSYMS);

#define CMD_BLANK	" "



/* each proc/alias ptr field points to this: */
struct pralias {
	struct pralias *next;			/* NULL for aliases */
	char it[2];
	};

/* global variables */
sym *reserved_syms,*asm_syms,*alias_list,*user_list;
hash *asm_hash,*static_hash;
long asmmax,asmmin;
bool symcase=TRUE;			/* TRUE is sig, FALSE is not sig */
unsigned long debugtime;

enum symstyle symbol_style;

/* not-so global vars */
static uchar proc_depth;					/* depth of procs */
static bool oldsymcase=TRUE;
static bool gotlower;		/* used for auto-upper */

/***************** Hash Code **********************/

/* return a ptr to the hash entry, either it or 0 */
/* dies if full */
long *find_hash(hash *h, ulong lookup)
{
long *try;

	try=h->hstart;
	try+=(lookup % h->hsize)<<1;
	for (;;)
		{
		if ( (*try==lookup) || (*try==0L) )
			return try;
		if ( try==h->hend)
			try=h->hstart;
		else
			try+=2;
		}
}

/* these are statics to avoid recursion */
static hash *htable;
static void*(*hashfn)(sym*);

long calc_hash(sym *s)
{
long *new;
void *hashvalue;

	new=find_hash(htable,(ulong)(hashvalue=(hashfn)(s)));
	if (*new==0L)					/* kill duplicates */
		{
		*new++=(long)hashvalue;
		*new=(long)s;
		}
	return 0;
}

void add_hash(hash *h, sym *s, void*(*geth)(sym *), bool all)
{
	htable=h;
	hashfn=geth;
	if (all)
		foreachsym(s, calc_hash);
	else
		calc_hash(s);
}

#if 0
/* OLD recursive function to add symbol to hash table */
void add_hash(hash *h, sym *s, void*(*geth)(sym *))
{
long *new;
void *hashvalue;

	if (s->left)
		add_hash(h,s->left,geth);
	new=find_hash(h,(ulong)(hashvalue=geth(s)));
	if (*new==NULL)					/* kill duplicates */
		{
		*new++=(long)hashvalue;
		*new=(long)s;
		}
	if (s->right)
		add_hash(h,s->right,geth);
	
}
#endif

/* create a hash table */
/* based on magic value of 8/12ths */
void build_hash(hash **glo,uword hsize)
{
	*glo=NULL;
	if ( (hsize==0) || (hsize>45000) )
		return;
	hsize=(uword)( (ulong)hsize*12 / 8 ) | 3;
	if ( (*glo=getzmem((long)( (hsize<<3) +sizeof(hash))))==NULL)
		return;
	(*glo)->hsize=hsize;
	(*glo)->hstart=(long*)( ((char*)(*glo))+sizeof(hash) );
	(*glo)->hend=(*glo)->hstart+((hsize-1)*2);		/* the last one */
}

void clear_hash(hash **glo)
{
	if (*glo)
		{
		freemem(*glo);
		*glo=NULL;
		}
}

/* return the length, subject to a max */
ubyte strnlen(char *t, ubyte max)
{
char *s;

	s=t;
	while (*s++)
		if (max--==0)
			break;
	return (ubyte)(--s-t);
}


#ifdef SLOWSYMS

sym *get_last_sym(sym *global)
{
sym *p;
	if ( (p=global)==NULL)
		return NULL;
	while (p->next)
		p=p->next;
	return p;
}

/* find a given symbol in a given table */
/* returns pointer to struct, or NULL if not there */
/* remember can be used to add it subsequently, or can be NULL */
sym *find_sym(sym **global,char *symname, ubyte symlen, struct remstruct *remember,bool casesig)
{
sym *s;
int cmp;

	if ( (s=*global)==NULL )
		{ /* very first symbol */
		if (remember)
			{
			remember->toadd=global;
			remember->last=NULL;
			}
		return NULL;
		}
	for( ; ; )
		{ /* scan the tree */
		/* sorting is in true AMP tradition of length/ASCII */
		if (symlen < s->len)
			goto goleft;
		else if (symlen > s->len)
			goto goright;
		if (casesig)
			cmp=strncmp(symname,s->name,(unsigned)symlen);
		else
			cmp=strnicmp(symname,s->name,(unsigned)symlen);
		if (cmp>0)
			goto goright;
		else if (cmp==0)
		/* ahah - we have found the beast */
			return s;
		/* look in left branch */
goleft:
		if (s->left==NULL)
			{
			if (remember)
				{
				remember->toadd=&(s->left);
				remember->last=get_last_sym(*global);
				}
			return NULL;
			}
		else
			{
			s=s->left;
			continue;
			}
goright:
		if (s->right==NULL)
			{
			if (remember)
				{
				remember->toadd=&(s->right);
				remember->last=get_last_sym(*global);
				}
			return NULL;
			}
		else
			{
			s=s->right;
			continue;
			}
		}
}
#else
sym *find_sym(sym **,char *, ubyte, struct remstruct *,bool);
#endif

/* after a call to the above, this adds a symbol to a tree */
/* can only return with out of memory error or 0 */
word add_sym(char *symname, ubyte symlen, struct remstruct *remember)
{
word l;
sym *newsym;

	l=sizeof(struct s_sym)+symlen+1;
	if ( (newsym=(sym*)getzmem(l))==NULL)
		return ERRM_NOMEMORY;
	newsym->len=symlen;
	strncpy(newsym->name,symname,symlen);
	newsym->name[symlen]=0;					/* null term */
	newsym->next=NULL;
	*(remember->toadd)=newsym;
	if (remember->last)
		(remember->last)->next=newsym;
	return 0;
}


/* these are built-ins in reserved_table only */
#define	STYPE_RESERVED		2
/* these are general symbols in asm table */
#define	STYPE_ASM			3
/* these are functional ones, in reserved table */
#define	STYPE_FUNCTION		4
/* these are user syms, in user table only */
#define STYPE_USER			5
/* these are in the asm table - globals which need indirection */
#define	STYPE_INDIRECT		6

/* if func=NULL then we are read-only */
word add_reserved_sym(char *name,void *where,byte size, word (*func)(void *) )
{
sym *s;
struct remstruct remember;
word err;

	err=0;
	s=find_sym(&reserved_syms,name,(ubyte)strlen(name),&remember,TRUE);
	if (s==NULL)
		{
		if ( (err=add_sym(name,(ubyte)strlen(name),&remember))==0 )
			{
			(*(remember.toadd))->type=STYPE_RESERVED;
			(*(remember.toadd))->size=size;
			(*(remember.toadd))->v.ptr=where;
			(*(remember.toadd))->func=func;
			}
		}
	return err;
}

/* a function symbol has a pointer to a function to get its addr */
/* lives in reserved symbol table */
word add_function_sym(char *name,void * (*where)(bool*,void*),byte size, word (*func)(void *))
{
sym *s;
struct remstruct remember;
word err;

	err=0;
	s=find_sym(&reserved_syms,name,(ubyte)strlen(name),&remember,TRUE);
	if (s==NULL)
		{
		if ( (err=add_sym(name,(ubyte)strlen(name),&remember))==0 )
			{
			(*(remember.toadd))->type=STYPE_FUNCTION;
			(*(remember.toadd))->size=size;
			(*(remember.toadd))->v.ptr=where;
			(*(remember.toadd))->func=func;
			}
		}
	return err;
}

/* initialise the reserved symbol table */
/* can return out of memory or 0 */
word init_symbols()
{
extern word monversion;
word err;
extern void init_find_sym(void);

	init_find_sym();
	if (err=add_reserved_sym("symbolcase",&symcase,EXPR_BYTE,alter_nothing))
		return err;
	if (err=add_reserved_sym("symbolstyle",&symbol_style,EXPR_LONG,alter_nothing))		/* assumes enum is int is long */
		return err;
	return add_reserved_sym("version",&monversion,EXPR_WORD,NULL);
	
}

#if M68000
#include "regs.h"
/* for special sr.condition pseudo-registers */
bool sr_conditional;				/* strictly temporary */
static char cond_list[]="hilscccsneeqvcvsplmigeltgtlesuus";
extern word test_cond(word cond, bool bra);			/* in diss.c */

/* if symbol is found then set variable and return TRUE */
bool find_sr_sym(char *it)
{
	if ( (tolower(*it++)=='s') && (tolower(*it++)=='r') )
		{
		word cond;
		char first,second;
		/* match the condition */
		it++;
		first=tolower(*it++); second=tolower(*it++);
		for(cond=0; cond<sizeof(cond_list); cond+=2)
			{
			if ( (cond_list[cond]==first) && (cond_list[cond+1]==second) )
				{
				if (cond==(14*2))
					sr_conditional= (regs.sr&0x2000) ? -1 : 0;
				else if (cond==(15*2))
					sr_conditional= (regs.sr&0x2000) ? 0 : -1;
				else
					sr_conditional=test_cond((word)((cond>>1)+2),FALSE) ? -1 : 0;
				return TRUE;
				}
			}
		}
	return FALSE;
}
#endif

/* for reserved symbls only */
/* returns error if not found, else 0 */
word find_reserved_sym(char *resname, ubyte reslen, void **where, byte *size,bool *writeable)
{
sym *s;
	if (reslen==0)
		return ERRM_INVALIDSYM;
	s=find_sym(&reserved_syms,resname,reslen,NULL,FALSE);
	if (s==NULL)
		{
		/* handle the sr.COND symbols */
		if ( (reslen==5) && (resname[2]=='.') && find_sr_sym(resname) )
			{
			*size=EXPR_BYTE;
			*writeable=FALSE;
			*where=(void*)&sr_conditional;
			return 0;
			}
		else
			return ERRM_SYMNOTFOUND;
		}
	
	*size=s->size;

	if (s->type==STYPE_FUNCTION)
		*where=( (void*(*)(bool*,sym*)) (s->v.ptr) ) (writeable,s);
	else
		{
		*where=s->v.ptr;
		if (s->func)
			*writeable=TRUE;
		else
			*writeable=FALSE;
		}
	return 0;
}

word set_reserved_sym(sym *s, long value)
{
bool writeable;
void *where;

	if (s->func==NULL)
		return ERRM_READONLYVAR;

	if (s->type==STYPE_FUNCTION)
		{
		where=( (void*(*)(bool*,sym*)) (s->v.ptr) ) (&writeable,s);
		if (writeable==FALSE)
			return ERRM_READONLYVAR;
		}
	else
		where=s->v.ptr;

	switch (s->size)
		{
		case EXPR_BYTE:
			*( (byte*)where )=(byte)value; break;
		case EXPR_WORD:
			*( (word*)where )=(word)value; break;
		case EXPR_UWORD: 
			*( (uword*)where )=(uword)value; break;
		case EXPR_LONG: 
			*( (long*)where )=value; break;
		default:
			return ERRI_BADTYPE;
		}
	return (s->func)(where);
}

/* find a 'general' symbol; this means:
look in scoped table
	look in asm table
		if fails, try usersym
			if fails, try underlines (MAYBE)
				if fails, try @s (MAYBE)
					if fails, look in reserved table
						if fails, try magic symbols
	returns error if not found, else 0
	returns a *pointer* to its value plus its size */
word find_general_sym(char *resname, ubyte reslen, void **where, byte *size, bool getaddr)
{
sym *s;
char usym[256];

	if ( (reslen==0) || (reslen==255) )
		return ERRM_INVALIDSYM;


	if (find_scoped_sym(resname,reslen,where,size,getaddr))
		return 0;

	if (s=user_list)
		s=find_sym(&user_list,resname,reslen,NULL,symcase);
	if (s==NULL)
		{
		s=find_sym(&asm_syms,resname,reslen,NULL,symcase);
		if (s==NULL)
			{
			usym[0]='_';
			stccpy(&usym[1],resname,reslen);
			s=find_sym(&asm_syms,usym,(ubyte)(reslen+1),NULL,symcase);
			if (s==NULL)
				{
				usym[0]='@';
				s=find_sym(&asm_syms,usym,(ubyte)(reslen+1),NULL,symcase);
				if (s==NULL)
					{
					s=find_sym(&reserved_syms,resname,reslen,NULL,FALSE);
					if (s==NULL)
						{
#if M68000
						/* handle the sr.COND symbols */
						if ( (reslen==5) && (resname[2]=='.') && find_sr_sym(resname) )
							{
							*size=EXPR_BYTE;
							*where=(void*)&sr_conditional;
							return 0;
							}
#endif
						return ERRM_SYMNOTFOUND;
						}
					else
						{
						bool wp;
gotim:						*where=s->v.ptr;
						*size=s->size;
						if (s->type==STYPE_FUNCTION)
							*where=( (void*(*)(bool*,sym*)) (s->v.ptr) ) (&wp,s);
						return 0;
						}
					}
				}
			}
		}
	*size=s->size;
	*where=&s->v.l;
	if (s->type==STYPE_INDIRECT)
		{
		switch (s->size)
			{
			case EXPR_WORD: case EXPR_LONG:
				*where=(void*)s->v.l;
				break;
			}
		}
	return 0;
}

word list_table(sym *s)
{
word err;

	if (s==NULL)
		return 0;
	if (s->left)
		{
		err=list_table(s->left);
		if (err)
			return err;
		}

	sprintf(linebuf,"%08lx %s\n",s->v.l,s->name);
	if (err=list_print(linebuf))
		return err;

	if (s->right)
		{
		err=list_table(s->right);
		if (err)
			return err;
		}
}

long dump_res(sym *s)
{
long l;
	if (
		(s->type!=STYPE_FUNCTION) &&
		( coerce_value(s->v.ptr,s->size,&l,EXPR_LONG) == 0 )
	   )
		{
		sprintf(linebuf,"%08lX %s\n",l,s->name);
		return (long)list_print(linebuf);
		}
	return 0L;
}

/* reserved symbols are stored as pointers, so different technology required */
word list_reserved(char *p)
{
	if (reserved_syms)
		foreachsym(reserved_syms,dump_res);
	return 0;
}

word list_asm(char *p)
{
	return list_table(asm_syms);
}

word list_user(char *p)
{
	return list_table(user_list);
}

/* unload any debug info */
long clear_debug(sym *s)
{
	freemem(s);
	return 0;
}

void clear_asm()
{
	if (asm_syms)
		{
		foreachsym(asm_syms, clear_debug);
		asm_syms=NULL;
		if (gotlower==FALSE)
			symcase=oldsymcase;
		}
	clear_hash(&asm_hash);
	asmmax=0L; asmmin=0x7FFFFFF;
	clear_dbfile();
}

#define	safe_read(a,b)	if (b!=fread(a,1,b,fp)) goto rderr
#define	safe_skip(a)	if (fseek(fp,a,1)==-1L) goto rderr

static long st_max[3];			/* for each section */

/* we are about to load an executable program - load its debug info */
/* return error only if physical problem */
/* a filename of NULL means clear the old */
/* offset means stuff on front of file to skip */
word load_debug(char *filename, ulong offset)
{
word err;
FILE *fp;
char *warn;
struct remstruct remember;
byte secnum;
long numsyms;
long realsyms;
bool gotdb;


struct  {
	word magic;
	long tlen,dlen,blen;
	long symlen,r0,r1;
	word reloc;
	} sthead;

struct {
	char first8[8];
	ubyte flaghigh,flaglow;
	long value;
	} stsym;

/* lose the original ones */
	clear_asm();

	if (filename==NULL)
		return 0;

	realsyms=0;
	gotdb=FALSE;

	#if DEMO
	offset = debug_offset();
	fp=fopen(demo_program_name, "rb");
	#else
	fp=fopen(filename,"rb");
	#endif
	if (fp==NULL)
		{
		if (errno==EOSERR)
			return remember_doserr((word)_OSERR);
		else
			return remember_unixerr();
		}

	debugtime=filetime(fp);

	if (offset)
		safe_skip(offset);

/* Atari Only at present */
	memset(&st_max,0,sizeof(st_max));

	safe_read(&sthead,sizeof(sthead));
	if ( (sthead.magic!=0x601a) )
		{
		err=ERRM_BADFILEFORMAT;
		goto rderr;
		}
	if (sthead.symlen % 14)
		{
		warn=TX_NONSTDDEBUG;
		goto warning;
		}
	if ( (numsyms=(long)sthead.symlen/14) ==0 )
		{
		warn=TX_NODEBUGINFO;
		goto warning;
		}
	safe_skip(sthead.tlen+sthead.dlen);
	safe_print(TX_READINGSYMS);
	while (numsyms-->0)
		{
		/* do all the ST symbols */
		ubyte len;
		char *thesym;
		sym *s;
		char maxssym[14*2];

		safe_read(&stsym,sizeof(stsym));
		if (stsym.flaglow=='H')
			{
			safe_read(&maxssym[8],14);		/* second 14-byte block */
			stsym.flaglow=0;
			thesym=maxssym;
			strncpy(maxssym,stsym.first8,8);
			len=strnlen(thesym,22);
			numsyms--;
			}
		else
			{
			len=strnlen(thesym=stsym.first8,8);
			}
		/* add it to the table */
		switch (stsym.flaghigh)
			{
			case 0xa1: secnum=2; break;
			case 0xa2: secnum=0; break;
			case 0xa4: secnum=1; break;
			default: secnum=-1;
			}
		if (secnum>=0)
			if ( (s=find_sym(&asm_syms,thesym,len,&remember,TRUE))==NULL )
				if ( (err=add_sym(thesym,len,&remember))==0 )
					{
					(*(remember.toadd))->type=secnum;
					(*(remember.toadd))->size=EXPR_LONG;
					(*(remember.toadd))->v.l=stsym.value;

					/* value will need fixups after loading prog */

					if (stsym.value>st_max[secnum])
						st_max[secnum]=stsym.value;

					realsyms++;
					if (len>8) realsyms++;
					}
				else
					goto x;
		}
	/* read all OK */
	build_hash(&asm_hash,(uword)realsyms);
	if (gotdb=read_dbfile(fp,sthead.reloc))
		if (scoped_symbol_count)
			sprintf(linebuf,TX_SCOPEDDB,realsyms,scoped_symbol_count);
		else
			sprintf(linebuf,TX_SOURCEDB,realsyms);
	else
		sprintf(linebuf,TX_DEBUGOK,realsyms);
	warn=linebuf;
warning:
	safe_print(warn);
	if (gotdb)
		prepare_source();
	safe_print(TX_LOADING);
	err=0;
	goto x;
rderr:
	err=ERRM_READERROR;
x:
	if (err)
		clear_asm();

	fclose(fp);
	return err;
}

long foreachsym( sym *s,long (*each)(sym *))
{
long ret;
sym *next;

	if (s==NULL)
		return 0L;

	do
		{
		next=s->next;			/* in case we're freeing! */
		if (ret=(*each)(s))
			return ret;
		}
	while (s=next);
	return 0;
	
#if 0
the old recursive version. Bad news for large GenST symbol tables.
	if (s->left)
		if (ret=foreachsym(s->left,(each)))
			return ret;
	if (ret=(*each)(s))
		return ret;
	if (s->right)
		if (ret=foreachsym(s->right,(each)))
			return ret;
	return 0L;
#endif
}



long stfixup(sym *s)
{
	if (symbol_style==NEW)
		s->v.l+=progbp->tbase;			/* new HiSoft, Atari standard */
	else switch (s->type)
		{								/* old HiSoft, aka AMP */
		case 0: s->v.l+=progbp->tbase; break;
		case 1: s->v.l+=progbp->dbase; break;
		case 2: s->v.l+=progbp->bbase; break;
		}
	asmmax=max(asmmax,s->v.l);
	asmmin=min(asmmin,s->v.l);
	s->type=STYPE_ASM;
	if ( (symcase==TRUE) && (gotlower==FALSE) )
		{
		char *p,c; ubyte len;
		p=s->name; len=s->len;
		while (len--)
			{
			c=*p++;
			if ( (c>='a') && (c<='z') )
				{
				gotlower=TRUE;
				break;
				}
			}
		}
	return 0L;
}

void *do_asm_hash(sym *s)
{
	return (void *)s->v.l;
}

/* after the prog is loaded, call this to fix it up */
/* and to generate asm hash tables etc */
void fixup_debug()
{
	if (asm_syms)
		{
		oldsymcase=symcase;
		gotlower=FALSE;
		if (symbol_style==AUTO)
			{
			if (
				(st_max[0]>progbp->tlen) ||			/* if any text sym>len of text  OR */
				(st_max[1]>progbp->dlen)			/* if any data sym>len of data */
			   )
				symbol_style=NEW;
			else
				symbol_style=OLD;
			}
			
		/* Atari only */
		foreachsym(asm_syms,stfixup);
		if (asm_hash)
			add_hash(asm_hash,asm_syms,do_asm_hash,TRUE);
		fixup_dbfile(progbp->tbase);
		if (gotlower==FALSE)
			symcase=FALSE;			/* if all syms ucase */
		}
	
}

/* used when loading non-ST progs. Name of NULL means last one */
word define_normal_sym(char *name, ubyte len, long value)
{
struct remstruct remember;
sym *s;
word err;

	if (name)
		{
		if ( (s=find_sym(&asm_syms,name,len,&remember,TRUE))==NULL )
			if ( (err=add_sym(name,len,&remember))==0 )
				{
				(*(remember.toadd))->type=0;
				(*(remember.toadd))->size=EXPR_LONG;
				(*(remember.toadd))->v.l=value;
				}
		asmmax=max(asmmax,value);
		asmmin=min(asmmin,value);
		}
	else if (value<60000)
		{
		build_hash(&asm_hash,(uword)value);
		if (asm_hash)
			add_hash(asm_hash,asm_syms,do_asm_hash,TRUE);
		}
	return 0;
}

static long asmextra;
static sym *asmextra2;
static long asmextra3;

long asm_sym_find(sym *s)
{
	if (s->v.l==asmextra)
		return (long)s;
	else
		return NULL;
}

/* like find_asm_symbol below but for user symbols */
char *find_usym(long value, ubyte *len)
{
sym *s;
	if (user_list==NULL)
		return NULL;
	asmextra=value;
	s=(sym*)foreachsym(user_list,asm_sym_find);
	if (s)
		{
		*len=s->len;
		return s->name;
		}
	else
		return NULL;
}

/* given a value, find its asm label */
/* returns NULL if not found */
char *find_asm_symbol(long value, ubyte *len)
{
sym *s;
long *h;
static char buf[256];

	if ( (asm_syms==NULL) || (value<asmmin) || (value>asmmax) )
		return find_usym(value,len);
	if (asm_hash)
		{
		h=find_hash(asm_hash,value);
		if (*h++)
			{
			s=(sym *)*h;
			*len=s->len;
			return s->name;
			}
		}
	else
		{
		/* if no hash try the slow way */
		asmextra=value;
		s=(sym *)foreachsym(asm_syms,asm_sym_find);
		if (s)
			{
			*len=s->len;
			return s->name;
			}
		}
	
	/* try statics */
	if (static_hash)
		{
		h=find_hash(static_hash,value);
		if (*h++)
			{
			s=(sym *)*h;
			buf[0]='!';
			memcpy(buf+1,s->name,s->len);		/* indicate static */
			*len=s->len+1;
			return buf;
			}
		}
	
	/* then try users */
	return find_usym(value,len);
}


long asm_sym_close(sym *s)
{
long diff;

	if ( (diff=asmextra-s->v.l) >=0 )
		{
		if (diff<asmextra3)
			{
			asmextra2=s;
			if ( (asmextra3=diff)==0 )
				return (long)s;				/* stop if found exactly */
			}
		}
	return NULL;
}

/* find the symbol closest but not biggest to a value */
/* eg john+42 */

char *find_close_symbol(long value, ubyte *len, long *diff)
{
	if ( (asm_syms==NULL) || (value<asmmin) )
		return NULL;
	asmextra=value;
	asmextra2=NULL;			/* closest so far */
	asmextra3=0x7FFFFFFF;	/* how close */

	foreachsym(asm_syms,asm_sym_close);
	foreachsym(user_list,asm_sym_close);
	if (asmextra2)
		{
		*len=asmextra2->len;
		*diff=asmextra3;
		return asmextra2->name;
		}
	return NULL;
}

long dump_asm(sym *s)
{
word key,x,y,event;

	sprintf(linebuf,"\n%08lX %s",s->v.l,s->name);
	safe_print(linebuf);
	do
		{
		event=get_event(&key,&x,&y);
		if (event&EV_KEY)
			if (key==KEY_ESC)
				{
				safe_print("\n");
				return 1L;				/* abort */
				}
			else
				break;
		}
	while (1);
	return 0L;
}

word cmd_dumpsym(char *p)
{
	if (asm_syms)
		foreachsym(asm_syms,dump_asm);
	return 0;
}

/***************** set register ***************/

word cmd_reg(char *p)
{
register char *regstart;		/* L5BUG: must be resgister */
ubyte reglen;
word err;
long l;
sym *s;

	while (*p==' ')
		{ p++; }

	if (*p=='?')
		p++;

	/* this relies on built-ins being alphabetic only */
	regstart=p;

	if (!isalpha(*p++))
		return ERRM_INVALIDSYM;
	while (isalnum(*p))
		p++;

	reglen=(ubyte)(p-regstart);			/* length of reserved */
	s=find_sym(&reserved_syms,regstart,reglen,NULL,FALSE);
	if (s==NULL)
		return ERRM_SYMNOTFOUND;

	while (*p==' ')
		p++;
	if (*p=='=')
		p++;
	while (*p==' ')
		p++;

	if (*p==0)
		{ /* just print its value */
		if ( coerce_value(s->v.ptr,s->size,&l,EXPR_LONG) == 0 )
			{
			sprintf(linebuf,"%08lX\n",l);
			safe_print(linebuf);
			}
		err=0;
		}
	else
		{ /* try to set its value */
		if ( (err=get_expression(&p,EXPR_LONG,&l))==0 )
			err=set_reserved_sym(s,l);
		}
	return err;
}

/* returns a pointer to something and whether it is simple or not */
/* currently simple only */
word parse_lock(char *p, bool *simple, char**ptr)
{
char *regstart; ubyte reglen; sym *s;
bool writeable;

	while (*p==' ')
		p++;
	if (*p==0)
		{
		*simple=TRUE;
		*ptr=NULL;
		return 0;
		}
	if (*p=='?')
		p++;

	regstart=p;

	if (!isalpha(*p++))
		return ERRM_INVALIDSYM;
	while (isalnum(*p))
		p++;

	reglen=(ubyte)(p-regstart);			/* length of reserved */
	s=find_sym(&reserved_syms,regstart,reglen,NULL,FALSE);
	if (s==NULL)
		return ERRM_SYMNOTFOUND;
	if (s->size!=EXPR_LONG)
		return ERRM_LONGONLY;
	if (*p)
		return ERRE_CRAPAFTER;

	if (s->type==STYPE_FUNCTION)
		*ptr=( (void*(*)(bool*,sym*)) (s->v.ptr) ) (&writeable,s);
	else
		*ptr=(char*)(s->v.ptr);

	*simple=TRUE;
	return 0;
}

/**************** alias code *****************/

static sym *current_proc;

/* also works for procs */
void clear_alias(sym *s)
{
struct pralias *old,*n;
	n=(struct pralias*)s->v.ptr;
	if (n==NULL)
		return;

	while (old=n)
		{
		n=old->next;
		freemem(old);
		}
	s->v.ptr=NULL;
}

word define_alias(char *thesym, ubyte len, char *p)
{
sym *s;
struct remstruct remember;
struct pralias *new;
word memlen;
word err;

	err=0;

	if (s=find_sym(&alias_list,thesym,len,&remember,FALSE))
		clear_alias(s);

	memlen=strlen(p);
	if (memlen==0)
		return 0;					/* if undefining */
	if (memlen>MAXALIASLEN)
		return ERRM_TOOLONG;

	if ( (new=getzmem(sizeof(struct pralias)+memlen+1))==NULL )
		return ERRM_NOMEMORY;

	strcpy(new->it,p);				/* remember it */

	if (s==NULL)
		{
		if ( (err=add_sym(thesym,len,&remember))==0 )
			s=*(remember.toadd);
		else
			return err;
		}
	s->v.ptr=(void*)new;
	current_proc=s;

	return err;

}

long dump_alias(sym *s)
{
	if (s->v.ptr)
		{
		sprintf(linebuf,"%s %s\n",s->name,
			((struct pralias*)(s->v.ptr))->next ?
				"(proc)" : ((struct pralias*)(s->v.ptr))->it );
		return (long)list_print(linebuf);
		}
	else
		return 0L;
}

word list_alias(char *p)
{
	if (alias_list)
		foreachsym(alias_list,dump_alias);
	return 0;
}

#define	ALIASPARAM	'#'

word get_alias_param(char *line, char pnum, char **result, word *len, char *temp)
{
char c;

	if (pnum==ALIASPARAM)
		{
		*temp='#';
		*result=temp;
		*len=1;
		return 0;
		}
	else if (pnum=='?')
		{
		word params;
		params=0;
		for (;;)
			{
			if (*line==' ')
				line++;
			if (*line==0)
				break;
			params++;
			while ( (*line) && (*line!=' ') )
				line++;
			}
		sprintf(temp,"%d",params);
		*result=temp;
		*len=(word)strlen(temp);
		return 0;
		}
	else if ( (pnum=='d') || (pnum=='D') )
		{ /* #d is the last dialog result */
		if (line_buffer==NULL)
			{
			*len=0;
			*result=NULL;
			}
		else
			{
			*len=(word)strlen(line_buffer);
			*result=line_buffer;
			}
		return 0;
		}

	pnum-='0';
	if ( (pnum<0) || (pnum>9) )
		return ERRM_BADAPARAM;
	while (*line==' ')
		line++;

	if (pnum==0)
		{
		*result=line;
		*len=strlen(line);
		return 0;
		}
	for (;;)
		{
nxt:	if (*line==' ')
			line++;

		if (--pnum==0)					/* found it */
			break;

		while (c=*line++)
			if (c==' ') goto nxt;		/* next param */

		line--;							/* run out - point to null */
		break;
		}
	*result=line;						/* start of param */
	while (c=*line++)
		{
		if (c==' ')
			break;
		}
	*len=(word)(--line - *result);
	return 0;
}

word expand_alias(char *defn, char *expanded, char *pstart)
{
word sofar;
char c;

	sofar=0;
	while (c=*defn++)
		{
		if (c!=ALIASPARAM)
			{
			if (sofar++>MAXALIASLEN)
				return ERRM_TOOLONG;
			*expanded++=c;
			}
		else
			{
			byte pnum;
			pnum=*defn++;
			if (pnum==0)
				return ERRM_BADAPARAM;
			else
				{
				char *theparam;
				word paramlen,err;
				char temp[10];
				err=get_alias_param(pstart,pnum,&theparam,&paramlen,temp);
				if (err)
					return err;
				if ( (sofar+=paramlen)>MAXALIASLEN )
					return ERRM_TOOLONG;
				while (paramlen--)
					*expanded++=*theparam++;
				}
			}
			
		}	/* end while */
	*expanded=0;
	return 0;
}

/* also finds (and executes) procs */
word find_alias(char *alias, word len, char *expanded)
{
sym *s;
struct pralias *proc;
word err;

	if (len>MAXALIASLEN)
		return ERRM_TOOLONG;
	*expanded=0;
	if (alias_list==NULL)
		return 0;
	err=0;
	if (s=find_sym(&alias_list,alias,(ubyte)len,NULL,FALSE))
		{
		proc=(struct pralias*)(s->v.ptr);
		if (proc==NULL)
			return 0;				/* if no definition */
		if (proc->next==NULL)
			{ /* simple alias */
			return expand_alias( proc->it,
				expanded, (char*)(alias+len) );
			}
		else
			{ /* we are a procedure call (recursive) */
			  /* relies on expanded being local to do_command */
			proc_depth++;
			err=0;
			do
				{
				err=expand_alias( proc->it, expanded, (char*)(alias+len) );
				if (err)
					break;
				err=do_command(expanded);
				if (err)
					break;
				}
			while (proc=proc->next);
			proc_depth--;
			strcpy(expanded,CMD_BLANK);		/* simple return */
			}
		}
	return err;
}


/*************** PROC code ******************/

bool defining_proc;					/* TRUE during definition */

/* procs are mult-line aliases */
word define_proc(char *thesym, ubyte len, char *p)
{
word err;

	if ( (defining_proc) || proc_depth )
		return ERRM_DEFINE;			/* cannot define recursively */
	err=define_alias(thesym,len,CMD_BLANK);
	if (err==0)
		defining_proc=TRUE;
	return err;

}

word undefine_proc(char *name, ubyte len)
{
sym *s;

	if (s=find_sym(&alias_list,name,len,NULL,FALSE))
		clear_alias(s);
	return 0;
}

/* called to add a line to the current proc */
word add_proc(char *p)
{
struct pralias *new,*last;
word memlen,err;

	while ( (*p==' ') || (*p=='\t') )
		p++;						/* dont store leading spaces */

	memlen=strlen(p);
	if (memlen==0)
		return 0;					/* skip blank lines */
	if (memlen>MAXALIASLEN)
		{
		err=ERRM_TOOLONG;
		goto bad;
		}

	if (strnicmp("endproc",p,7)==0)
		{
		if ( (p[7]==' ') || (p[7]==0) )
			{
			defining_proc=FALSE;
			return 0;
			}
		}

	if ( (new=getzmem(sizeof(struct pralias)+memlen+1))==NULL )
		{
		err=ERRM_NOMEMORY;
		goto bad;
		}
	strcpy(new->it,p);				/* remember it */

	last=(struct pralias*)(current_proc->v.ptr);
	while (last->next)
		last=last->next;

	last->next=new;					/* add to the list */

	while (*p==' ')
		p++;
	

	return 0;

/* error during definition must kill defn else no end */
bad:
	defining_proc=FALSE;
	undefine_proc(current_proc->name, current_proc->len);
	return err;
}

/* used to find a symbol, Macsbug style */
#define	HELPMAX	14
#define	HELPWIDTH	25

static char *help_sym_list[HELPMAX];
static word sofar;
static char *matchlist;

// dummy sym ptrs (e.g. from match_fn_names) have a len of 0 and a real
// ptr in s->v.ptr

long match_sym(sym *s)
{
char *p,*q;

	p=s->name;
	q=matchlist;
	while (*q)
		{
		if (toupper(*p)!=*q)
			return 0;			/* when difference found */
		p++; q++;
		}

	help_sym_list[sofar++]=s->len ? s->name : s->v.ptr;
	if (sofar==HELPMAX)
		return 1;				/* limit it */
	return 0;					/* else continue */
}

bool refill_help_sym(char *match, word *number)
{
	matchlist=match;			/* NOT recursive */

	sofar=0;
	for(;;)
		{
		if (match_scoped_syms(match_sym))
			break;
		if ( asm_syms && foreachsym(asm_syms,match_sym) )
			break;
		if (user_list)
			foreachsym(user_list,match_sym);
		break;
		}
	*number=sofar;
	return TRUE;
}

/* diff contains number of chars to back up */
char *help_symbol(char *start, word len, word *diff)
{
word err; word result;
char *p; word l; char *realstart;
char preload[30+1];

	/* see what the user has typed so far */
	l=len; p=start; realstart=NULL;
	*diff=0;
	while (l--)
		{
		char c;
		c=*--p;
		if (issym(c))
			{
			realstart=p;
			(*diff)++;
			}
		else
			break;
		}
	if (realstart)
		{
		/* pre-load with what has been typed */
		stccpy( preload+1, realstart, 29);
		err=do_menu(TX_SYMBOLMENU,HELPWIDTH,HELPMAX,help_sym_list,
			&result,refill_help_sym,preload+1);
		if ( (err==0) && (result==-1) )
			{
			preload[0]='_';
			err=do_menu(TX_SYMBOLMENU,HELPWIDTH,HELPMAX,help_sym_list,
				&result,refill_help_sym,preload);
			// maybe add register vars
			if ( (err==0) && (result==-1) )
				{
				preload[0] = '@';
				err = do_menu(TX_SYMBOLMENU,HELPWIDTH,HELPMAX,help_sym_list,
								&result, refill_help_sym,preload);
				}
			}
		}
	else
		err=do_menu(TX_SYMBOLMENU,HELPWIDTH,HELPMAX,help_sym_list,
			&result,refill_help_sym,NULL);
	if ( (err) || (result<0) )
		return NULL;
	else
		return help_sym_list[result];
}

/************* Data Symbols *****************/

/* these are used to define areas of memory to be disassembled as data not instructions */

typedef struct {
	ulong start;
	uword len;
	ubyte size;
	ubyte spare;
	} datasym;

datasym *datalist;				/* a dynamic array, always sorted */
word datasize;					/* the size of the above */
word dataused;					/* used entries in the above */

word data_add(ulong start, ulong end, char *sizetx)
{
ubyte size;
uword len;
word i;
datasym *p;

	if (end<start)
		return ERRM_BADP;
	len=(uword)end-start;
	switch (toupper(*sizetx))
		{
		case 'B':
			size=1; break;
		case '\0': case 'W':
			size=2; break;
		case 'L':
			size=4; break;
		default:
			return ERRM_BADP;
		}
	if ((size&1)==0)
		{
		/* even data must start even and its end must be fixed up */
		if (start&1L)
			return ERRM_BADP;
		len=( (len/size)*size )+size-1;
		}

	if (datasize==dataused)
		{
		/* its full (or not allocated) so grow it */
		word newsize;
		
		newsize=(datasize==0) ? 16 : datasize<<1;			/* doubles in size */
		p=(datasym*)getzmem(sizeof(datasym)*newsize);
		if (p==NULL)
			return ERRM_NOMEMORY;
		if (datalist)
			{
			/* copy data to new table */
			memcpy(p,datalist,sizeof(datasym)*datasize);
			freemem(datalist);
			}
		datasize=newsize;
		datalist=p;
		}
	else
		p=datalist;

	/* lets add it to the array now, in the correct place */
	for (i=0; i<dataused; i++)
		{
		if (start<=p->start)
			break;					/* it goes here, possibly replacing it */
		p++;
		}
	
	/* it needs to go at p - we might need to move the others down */
	if (i!=dataused)
		if (start!=p->start)
			{
			/* shovel them */
			i=dataused-i;				/* number to move - never zero */
			p=datalist+dataused;		/* new last entry */
			while (i--)
				{
				p[0]=p[-1];				/* structure assignment */
				p--;
				}
			}
		else
			{
			/* replacement - should split really but overwrites now */
			dataused--;
			}

	p->start=start;
	p->len=len;
	p->size=size;
	dataused++;
	return 0;
}

static char ds_list[]="?BW?L";

word list_data(char *p)
{
word i;
datasym *d;
word err;

	if ( ((d=datalist)==NULL) || (dataused==0) )
		return 0;
	for (i=0; i<dataused; i++)
		{
		sprintf(linebuf,"%08lx-%08lx %c\n",d->start,d->start+(long)(d->len),ds_list[d->size]);
		if (err=list_print(linebuf))
			return err;
		d++;
		}
	return 0;
}

/* called by the disassembler to see if something is data. Only called for even addrs */
bool check_data(ulong addr, ubyte *size)
{
datasym *d;
word i;

	if ( (dataused==0) || ((d=datalist)==NULL) )
		return FALSE;

	for (i=0; i<dataused; i++)
		{
		if (addr<d->start)
			return FALSE;
		if (addr<=(d->start+d->len))
			{
			*size=d->size;
			return TRUE;
			}
		d++;
		}
	return FALSE;
}

/******** user symbol code **************/
/* the user symbol is a simple table of user-defined symbols which can be saved & loaded */
/* user_list is NULL if none, else points to the usual sort of thing */
/* case IS significant */

/* SYMBOL ADD name expr */
word usym_add(char *p)
{
char *symname; ubyte symlen;
struct remstruct remember;
long l;
sym *s; word err;

	while (*p==' ')
		p++;
	symname=p++;					/* remember start of symbol */
	if (!issymstart(*symname))
		return ERRM_INVALIDSYM;
	symlen=1;
	while (issym(*p))
		{
		p++; symlen++;
		}
	while (*p==' ')
		p++;
	if (*p=='=')
		{
		p++;
		while (*p==' ')
			p++;
		}
	/* check the expression */
	if (err=get_expression(&p,EXPR_LONG,&l))
		return err;

	/* if its already there, just change its value */
	s=find_sym(&user_list,symname,symlen,&remember,TRUE);
	if (s==NULL)
		{ /* better add it */
		if (err=add_sym(symname,symlen,&remember))
			return err;
		s=*(remember.toadd);				/* the new symbol */
		}

	/* record its info */
	s->type=STYPE_USER;
	s->size=EXPR_LONG;
	s->v.l=l;
	s->func=NULL;	
	return 0;
}

#define DEFUSERNAME	"user.usm"

/* the file format is as follows:
	long	'SYM1'
		ubyte	type
				FF=the end
				0=abs symbol
				1-7F=section symbol
				bit 7 set=data defn, section is in low 7 bits ($80 means abs)
				if symbol,
					ubyte	symlen
					bytes	the ASCII (not null termed)
					long	offset (not aligned)
				else
					ubyte	skipl length
					xxx bytes	skip me, which for data sections is:
						skipl = 8
						ulong	start (offset, may need fixing)
						uword	len
						ubyte	size
						ubyte	future use (display method?)
*/

/* if filename starts with + then its a merge */
word usym_load(char *p)
{
FILE *fp;
word err;
int c;
ubyte stype,slen;
char symbol[256];
long offset;
bool clear;

	clear=TRUE;
	while (*p==' ')
		p++;
	if (*p=='+')
		{
		clear=FALSE;
		p++;
		}
	if (*p==0)
		p=DEFUSERNAME;
	if ( (fp=fopen(p,"rb"))==NULL )
		return remember_unixerr();
	if (clear)
		usym_clear(NULL);

	err=0;
	fread(&offset,1,4,fp);
	if (offset!='SYM1')
		err=ERRM_BADFILEFORMAT;
	else for (;;)
		{
		c=fgetc(fp);
		if (c==EOF)
			{
			err=ERRM_READERROR;
			break;
			}
		else if (c==0xFF)
			break;
		stype=c;
		slen=(ubyte)fgetc(fp);
		if (stype&0x80)
			{
			/* we might be a data definition */
			if (slen!=8)
				fseek(fp,(long)slen,SEEK_CUR);		/* future use */
			else
				{
				/* we *are* a data definition */
				struct {
					uword len;
					ubyte size;
					ubyte other;
					} buf;
				fread(&offset,1,4,fp);
				fread(&buf,1,4,fp);
				if (stype&=0x7f)
					fix_sym_type(stype,&offset);
				if (err=data_add(offset,offset+buf.len,&buf.size))
					break;
				}
			}
		else
			{ /* we're a symbol */
			struct remstruct remember;
			sym *s;
			
			fread(symbol,1,slen,fp);
			fread(&offset,1,4,fp);
			if (stype)
				fix_sym_type(stype,&offset);		/* for relative symbols */
			s=find_sym(&user_list,symbol,slen,&remember,TRUE);
			if (s==NULL)
				{ /* better add it */
				if (err=add_sym(symbol,slen,&remember))
					break;
				s=*(remember.toadd);				/* the new symbol */
				}
			/* record its info */
			s->type=STYPE_USER;
			s->size=EXPR_LONG;
			s->v.l=offset;
			s->func=NULL;	
			}
		}
	fclose(fp);
	return err;
}


word usym_save(char *p)
{
FILE *fp;
uchar bytes[2];
sym *s;
long offset;
datasym *data;

	if ( ((s=user_list)==NULL) && (dataused==0) )
		return ERRM_NOSYMBOLS;
		
	while (*p==' ')
		p++;
	if (*p==0)
		p=DEFUSERNAME;
	if ( (fp=fopen(p,"wb"))==NULL )
		return remember_unixerr();

	offset='SYM1';
	fwrite(&offset,1,4,fp);

	while (s)
		{
		bytes[0]=calc_sym_type(s->v.l,&offset);
		bytes[1]=s->len;
		fwrite(bytes,1,2,fp);
		fwrite(s->name,1,bytes[1],fp);
		fwrite(&offset,1,4,fp);
		s=s->next;
		}

	if (data=datalist)	
		{
		word i;
		for (i=0; i<dataused; i++)
			{
			bytes[0]=calc_sym_type(data->start,&offset)|0x80;
			bytes[1]=8;
			fwrite(bytes,1,2,fp);
			fwrite(&offset,1,4,fp);
			fwrite(&(data->len),1,2,fp);
			bytes[0]=ds_list[data->size];
			bytes[1]=0;
			fwrite(bytes,1,2,fp);
			data++;
			}
		}

	bytes[0]=0xFF;				/* the end marker */
	fwrite(bytes,1,1,fp);

	return (word) (fclose(fp) ? remember_unixerr() : 0);

}

word usym_clear(char *p)
{
sym *s,*next;
	s=user_list;
	while (s)
		{
		next=s->next;
		freemem(s);
		s=next;
		}
	user_list=NULL;
	if (datasize)
		{
		freemem(datalist);
		datasize=dataused=0;
		}
	return 0;
}

/********* typed variables ************/

/* simple BASIC-only ones for now */

long fix_var(sym *s)
{
char last; byte size;
	if (s->len>=2)
		{
		last=s->name[s->len-1];
		switch (last)
			{
			case '%':
				size=EXPR_WORD; break;
			case '&':
				size=EXPR_LONG; break;
			/* RSN handle floats etc */
			default:
				size=-1; break;
			}
		if (size>=0)
			{
			s->size=size;
			s->type=STYPE_INDIRECT;
			}
		}
	return 0L;
}

void add_variable_types(void)
{
	if (compiler_type!=CTYPE_BASIC)
		return;
	if (asm_syms)
		foreachsym(asm_syms,fix_var);
}

/************* Debug Code *************/

static word amp_err;

long each_amp(sym *s)
{
void *where;
byte size;

	if (find_general_sym(s->name,s->len,&where,&size,FALSE))
		{
		sprintf(linebuf,"%s\n",s->name);
		if (amp_err=list_print(linebuf))
			return 1;
		}
	return 0;
}

word list_amp(char *p)
{

	amp_err=0;
	foreachsym(asm_syms,each_amp);
	return amp_err;
}
