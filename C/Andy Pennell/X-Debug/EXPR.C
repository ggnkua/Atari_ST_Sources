/* expression handler for Mon */

/* assembly-language only at present; all maths uses long-signed arithmetic */
/* doubles now also supported if DOUBLES defined */

#include "mon.h"

/* this gets us macros for the is brothers (beware side-effects) */
#include <ctype.h>

/* used for factors and terms */
typedef struct {
	union {
		long l;
		word w;
		byte b;
		#if DOUBLES
		double d;
		#endif
		struct { word priority; byte theop; } op;
			} v;
	ubyte type;
	} item;

static bool checking;				/* zero for eval, non zero for syntax chacking */

/* follow asm rules for symbols */
bool issymstart(char c)
{
	if ( isalpha(c) || (c=='_') || (c=='@') || (c=='.') )
		return TRUE;
	return FALSE;
}

bool issym(char c)
{
	if ( isalnum(c) || (c=='_') || (c=='@') || (c=='.') )
		return TRUE;
	return FALSE;
}

bool issymend(char c)
{
	if (compiler_type!=CTYPE_BASIC)
		return FALSE;
	if ( (c=='%') || (c=='&') || (c=='$') || (c=='#') || (c=='!') )
		return TRUE;
	else
		return FALSE;
}

bool isfilenamechar(char c)
{
	if ( isalnum(c) || (c=='.') || (c==':') || (c==SLASH) )
		return TRUE;
	return FALSE;
}

/* general expression handler, same for all languages! */

#define MAXITEM	10
#define	MAXOP	10

#define E_BAD			0
#define	E_NUMBER		1
#define	E_PREMONADIC	2
#define	E_OPENBRACKET	3
#define E_DYADIC		4
#define	E_CLOSEBRACKET	5
#define	E_POSTMONADIC	6
#define	E_OPENIND		7
#define	E_CLOSEIND		8
#if DOUBLES
#define	E_DBLNUMBER		9
#endif

#define	must(a)			{ if(err=(a))return err; }
#define	push_item(E,X)	if (topitem==maxitem) return ERRE_ITEMOVERFLOW; else {topitem->type=E;topitem->v.l=X;topitem++;}
#if DOUBLES
#define	push_dbl_item(E,X)	if (topitem==maxitem) return ERRE_ITEMOVERFLOW; else {topitem->type=E;topitem->v.d=X;topitem++;}
#endif

/* for multi-character operators */
#define	OP_SLEFT	1
#define	OP_SRIGHT	2
#define	OP_NOTEQUAL	3
#define	OP_BYTE		4
#define	OP_SBYTE	5
#define	OP_WORD		6
#define	OP_SWORD	7
#define	OP_LONG		8

item itemlist[MAXITEM],*topitem,*maxitem,*botitem;
item oplist[MAXOP],*topop,*maxop,*botop;
char *ev;

word coerce_value(void *in, byte intype, void *out, byte wanted)
{
long v;

	#if DOUBLES
	if ( (intype>=EXPR_NOTINT) && (wanted>=EXPR_NOTINT) )
		{
		*(double*)out=*(double*)in;
		return 0;
		}
	#endif
	
	if (intype==EXPR_WORD)
		v=*((word*)in);
	else if (intype==EXPR_LONG)
		v=*((long*)in);
	else if (intype==EXPR_UWORD)
		v=*((uword*)in);
	else if (intype==EXPR_BYTE)
		v=*((byte*)in);
	#if DOUBLES
	else if (intype==EXPR_DOUBLE)
		v=*((double*)in);
	#endif
	else
		return ERRE_BADCOERCION;

	switch (wanted)
		{
		case EXPR_WORD:
			*((word*)out)=(word)v;
			break;
		case EXPR_LONG:
			*((long*)out)=v;
			break;
		case EXPR_UWORD:
			*((uword*)out)=(uword)v;
			break;
		case EXPR_BYTE:
			*((byte*)out)=(byte)v;
			break;
		#if DOUBLES
		case EXPR_DOUBLE:
			*(double*)out=(double)v;
			break;
		#endif
		default:
			return ERRE_BADCOERCION;
		}
	return 0;
}

/* completely the wrong name; actually extracts required
	size from v.l structure (or v.d struct if is a double) */
word coerce_type(item *it,byte wanted, void *result)
{
	if (checking)
		return 0;

#if DOUBLES
	if (it->type==E_DBLNUMBER)
		switch (wanted)
			{
			case EXPR_WORD:
				*((word*)result)=(word)it->v.d;
				break;
			case EXPR_LONG:
				*((long*)result)=it->v.d;
				break;
			case EXPR_UWORD:
				*((uword*)result)=(uword)it->v.d;
				break;
			case EXPR_BYTE:
				*((byte*)result)=(byte)it->v.d;
				break;
			case EXPR_DOUBLE:
				*(double*)result=(double)it->v.d;
				break;
			default:
				return ERRE_BADCOERCION;
			}
	else
#endif
		switch (wanted)
			{
			case EXPR_WORD:
				*((word*)result)=(word)it->v.l;
				break;
			case EXPR_LONG:
				*((long*)result)=it->v.l;
				break;
			case EXPR_UWORD:
				*((uword*)result)=(uword)it->v.l;
				break;
			case EXPR_BYTE:
				*((byte*)result)=(byte)it->v.l;
				break;
			#if DOUBLES
			case EXPR_DOUBLE:
				*(double*)result=(double)it->v.l;
				break;
			#endif
			default:
				return ERRE_BADCOERCION;
			}
	return 0;
}

/* returns error or 0 */
word parse_decimal(long *result)
{
unsigned long x;
char c;

	x=0;
	if (!isdigit(c=*ev++))
		return ERRE_BADNUMBER;
	do
		{
		if ( x>(0xFFFFFFFF/10) )
			return ERRE_NUMBERTOOBIG;
		x=x*10+(ulong)(c-'0');
		c=*ev++;
		}
	while (isdigit(c));
	--ev;
	*result=x;
	return 0;
}

word parse_hex(long *result)
{
unsigned long x;
char c;

	if (!isxdigit(*ev))
		return ERRE_BADNUMBER;
	x=0;
	while (isxdigit(c=*ev++))
		{
		if ( x>0x0FFFFFFF )
			return ERRE_NUMBERTOOBIG;
		x<<=4;
		if (c<='9')
			x+=(ulong)(c-'0');
		else if (c>'Z')
			x+=(ulong)(c-'a'+10);
		else
			x+=(ulong)(c-'A'+10);
		}
	*result=x;
	--ev;
	return 0;
}

word parse_bin(long *result)
{
unsigned long x;
char c;

	x=0;
	c=*ev++;
	if ( (c=='0') || (c=='1') )
		{
		do
			{
			if (x&0x80000000)
				return ERRE_NUMBERTOOBIG;
			x=(x<<1)|(ulong)(c-'0');
			c=*ev++;
			}
		while ( (c=='0') || (c=='1') );
		--ev;
		*result=x;
		return 0;
		}
	else
		return ERRE_BADNUMBER;
}

word parse_oct(long *result)
{
unsigned long x;
char c;

	x=0;
	c=*ev++;
	if ( (c>='0') && (c<='7') )
		{
		do
			{
			if ( x>(0xFFFFFFFF/8) )
				return ERRE_NUMBERTOOBIG;
			x=(x<<3)|(ulong)(c-'0');
			c=*ev++;
			}
		while ( (c>='0') && (c<='7') );
		--ev;
		*result=x;
		return 0;
		}
	else
		return ERRE_BADNUMBER;
}

/* starts with alphabetic; thats all we know */
/* returns longs or doubles */
/* takes care with symbols ending in .bwl or .bb/ww/ll */
word parse_symbol(void *result,bool getaddr, byte *etype)
{
char *p;
void *value;
byte ssize;
word err;
ubyte len; char size;

/*	if (!isalpha(*ev))		already done for us
		return ERRM_INVALIDSYM;	*/
	p=ev++;
	while (issym(*ev))
		ev++;
	if (issymend(*ev))
		ev++;
	len=(ubyte)(ev-p);	
	if ( (len>2) && (*(ev-2)=='.') )
		{
		size=upper(*(ev-1));
		if ( (size=='B') || (size=='W') || (size=='L') )
			{
			ev-=2;
			len-=2;
			}
		}
	else if ( (len>3) && (*(ev-3)=='.') )
		{
		size=upper(*(ev-1));
		if (
			( (size=='B') || (size=='W') || (size=='L') ) &&
				(upper(*(ev-2))==size)
		   )
			{
			ev-=3;
			len-=3;
			}
		}
	/* try general table */
	if (!checking)
		{
		must( find_general_sym(p,len,&value,&ssize,getaddr) );
		#if DOUBLES
		if (ssize<EXPR_NOTINT)
			{
			must( coerce_value(value,ssize,result,EXPR_LONG) );
			*etype=E_NUMBER;
			}
		else
			{
			*(double*)result=
				ssize==EXPR_DOUBLE ?
					*(double*)value : *(float*)value;		/* cope with singles & doubles */
			*etype=E_DBLNUMBER;
			}
		#else
		must( coerce_value(value,ssize,result,EXPR_LONG) );
		*etype=E_NUMBER;
		#endif
		}
	else
		{
		*etype=E_NUMBER;
		}
	return 0;
}

/* a bit naughty; take the TOS and do an indirection on it,
	directly accessing ev++ for the .w/b/l */
word do_indirection(void)
{
ulong ind;
long result;
char *p,s;
word err;
bool got;

	if (topitem==botitem)
		return ERRE_ITEMUNDERFLOW;
	must(coerce_type(--topitem,EXPR_LONG,&ind));	/* pops it */
	p=ev;
	got=FALSE;
	if (*p++=='.')
		{
		s=upper(*p++);
		if (s=='B')
			{
			result=peekb(ind);
			if (upper(*p)==s)
				{
				p++;
				result=(signed char)result;
				}
			ev=p; got=TRUE;
			}
		else if (s=='W')
			{
			if (checking)
				result=0;
			else
				{
				must(safe_peekw(ind,(uword*)&result));
				result>>=16;
				}
			if (upper(*p)==s)
				{
				p++;
				result=(word)result;
				}
			ev=p; got=TRUE;
			}
		else if (s=='L')
			{
			if (checking)
				result=0;
			else
				{
				must(safe_peekl(ind,&result));
				}
			if (upper(*p)==s)
				p++;
			ev=p; got=TRUE;
			}
		}
	if ( (got==FALSE) && (checking==0) )
		must(safe_peekl(ind,&result));

	/* put back new result */
	push_item(E_NUMBER,result);
	return 0;
}

/* distinctly asm only; all long-ints */
word do_op()
{
byte op;
long left,right,l;
word err;

	topop--;
	op=topop->v.op.theop;
	
	must(coerce_type(--topitem,EXPR_LONG,&right));

	if (topop->type==E_DYADIC)
		{
		if (topitem==botitem)
			return ERRE_ITEMUNDERFLOW;

		must(coerce_type(--topitem,EXPR_LONG,&left));

		switch (op)
			{
			case '+':
				l=left+right; break;
			case '-':
				l=left-right; break;
			case '*':
				l=left*right; break;
			case '/':
				if (right==0)
					{
					if (!checking)
						return ERRE_DIV0;
					}
				else
					l=left/right;
				break;
			case '&':
				l=left&right; break;
			case '!': case '|':
				l=left|right; break;
			case '^':
				l=left^right; break;
			case '=':
				if (l=(left==right))
					l=-1L;
				break;
			case '>':
				if (l=(left>right))
					l=-1L;
				break;
			case '<':
				if (l=(left<right))
					l=-1L;
				break;
			case OP_SLEFT:
				l=((ulong)left)<<right; break;
			case OP_SRIGHT:
				l=((ulong)left)>>right; break;
			case OP_NOTEQUAL:
				if (l=(left!=right))
					l=-1L;
				break;
			default:
				return ERRE_BADOP;
				break;
			}
		}
	else /* monadic */
		{
		switch (op)
			{
			case '+':
				l=right; break;
			case '-':
				l=-right; break;
			case '~':
				l=~right; break;
			case OP_BYTE:
				l=right & 0xFF; break;
			case OP_SBYTE:
				l=(char)right; break;
			case OP_WORD:
				l=right & 0xFFFF; break;
			case OP_SWORD:
				l=(word)right; break;
			case OP_LONG:
				l=right; break;
			default: 
				return ERRE_BADOP;
				break;
			}
		}
	push_item(E_NUMBER,l);
	return 0;
}

#if DOUBLES
/* almost identical to do_op() but using doubles */
word do_op_double()
{
byte op;
double left,right,l;
word err;

	topop--;
	op=topop->v.op.theop;
	
	must(coerce_type(--topitem,EXPR_DOUBLE,&right));

	if (topop->type==E_DYADIC)
		{
		if (topitem==botitem)
			return ERRE_ITEMUNDERFLOW;

		must(coerce_type(--topitem,EXPR_DOUBLE,&left));

		switch (op)
			{
			case '+':
				l=left+right; break;
			case '-':
				l=left-right; break;
			case '*':
				l=left*right; break;
			case '/':
				if (right==0)
					{
					if (!checking)
						return ERRE_DIV0;
					}
				else
					l=left/right;
				break;
			#if 0
			what about bitwise ops on doubles??
			case '&':
				l=left&right; break;
			case '!': case '|':
				l=left|right; break;
			case '^':
				l=left^right; break;
			#endif
			case '=':
				if (l=(left==right))
					l=-1L;
				break;
			case '>':
				if (l=(left>right))
					l=-1L;
				break;
			case '<':
				if (l=(left<right))
					l=-1L;
				break;
			#if 0
			case OP_SLEFT:
				l=((ulong)left)<<right; break;
			case OP_SRIGHT:
				l=((ulong)left)>>right; break;
			#endif
			case OP_NOTEQUAL:
				if (l=(left!=right))
					l=-1L;
				break;
			default:
				return ERRE_BADOP;
				break;
			}
		}
	else /* monadic */
		{
		switch (op)
			{
			case '+':
				l=right; break;
			case '-':
				l=-right; break;
			#if 0
			case '~':
				l=~right; break;
			case OP_BYTE:
				l=right & 0xFF; break;
			case OP_SBYTE:
				l=(char)right; break;
			case OP_WORD:
				l=right & 0xFFFF; break;
			case OP_SWORD:
				l=(word)right; break;
			#endif
			case OP_LONG:
				l=right; break;
			default: 
				return ERRE_BADOP;
				break;
			}
		}
	push_dbl_item(E_DBLNUMBER,l);
	return 0;
}
#endif

/* do all pending ops, above a certain priority */
word do_ops(word cmp)
{
word err;
	while (topop!=botop)
	{
		--topop;
		if (topop->v.op.priority >= cmp)
			{
			topop++;

			if (topop==botop)
				return ERRE_OPUNDERFLOW;
			if (topitem==botitem)
				return ERRE_ITEMUNDERFLOW;

		#if DOUBLES	
			/* if any term is double, use double arithmetic */
			if (
				( (topitem-1)->type==E_DBLNUMBER ) ||
				( ( (topop-1)->type==E_DYADIC) && ( (topitem-2)->type==E_DBLNUMBER) )
			   )
			   err=do_op_double();
			else
				err=do_op();
			if (err)
				return err;
		#else
			must(do_op())
		#endif
			}
		else
			{
			topop++;
			return 0;
			}
	}
	return 0;
}

/* return pointer to next item, based on *ev */
word getsym_asm(item *sym, bool expecting_op)
{
char c;
word err;

#if 0
	while (*ev==' ')
		ev++;				/* skip ws */
#endif

	c=*ev++;
	
	/* initialise to be common */
	sym->v.op.theop=c;
	sym->type=E_DYADIC;
	
	switch (c)
		{
		case '+': case '-':
			if (expecting_op)
				{
				sym->v.op.priority=4;
				}
			else
				{
				sym->type=E_PREMONADIC;
				sym->v.op.priority=14;
				}
			break;
		case '*': case '/':
			sym->v.op.priority=6;
			break;
		case '(':
			sym->type=E_OPENBRACKET;
			break;
		case '{':
			sym->type=E_OPENIND;
			break;
		case ')':
			sym->v.op.priority=1;		/* MUST be lowest prior */
			sym->type=E_CLOSEBRACKET;
			break;
		case '}':
			sym->v.op.priority=1;
			sym->type=E_CLOSEIND;
			break;
		case '~':
			sym->type=E_PREMONADIC;
			sym->v.op.priority=12;
			break;
		case '&':
			if (!expecting_op)
				{
				/* & must be followed by a symbol, to get its address */
				long *addr;
				err=parse_symbol(&sym->v.l,TRUE,&(sym->type));
				break;
				}
			/* nobreak; */
		case '!': case '|': case '^':
			sym->v.op.priority=8;
			break;
		case '=':
			sym->v.op.priority=2;
			break;
		case '<':
			if (*ev=='>')
				{
				sym->v.op.priority=2;
				sym->v.op.theop=OP_NOTEQUAL;
				ev++;
				}
			else if (*ev=='<')
				{
				sym->v.op.priority=10;
				sym->v.op.theop=OP_SLEFT;
				ev++;
				}
			else
				{
				sym->v.op.priority=2;
				}
			break;
		case '>':
			if (*ev=='>')
				{
				sym->v.op.priority=10;
				sym->v.op.theop=OP_SRIGHT;
				ev++;
				}
			else
				{
				sym->v.op.priority=2;
				}
			break;
		case '"': case '\'':
			{
			unsigned long str;
			unsigned char c2;
				str=0;
				do
					{
					c2=*ev++;
					if (c==0)
						return ERRE_BADQUOTES;
					else if (c2!=c)
						{
						if (str&0xFF000000)
							return ERRE_LONGSTRING;
						str<<=8;
						str|=c2;
						}
					else
					/* hack - cannot cope with nested quotes */
						break;
					}
				while (1);
			sym->v.l=str;
			}
			sym->type=E_NUMBER;
			break;
		case '$':
			must(parse_hex(&sym->v.l));
			sym->type=E_NUMBER;
			break;
		case '%':
			must(parse_bin(&sym->v.l));
			sym->type=E_NUMBER;
			break;
		case '\\':
			must(parse_decimal(&sym->v.l));
			sym->type=E_NUMBER;
			break;
		case '#':
			{ /* #1234:fred is a source file reference */
			ulong line; char *fname;
			must(parse_decimal(&line));
			if (*ev==':')
				{
				fname=++ev;
				while (isfilenamechar(*ev++))
					;
				--ev;
				}
			else
				fname=NULL;
			must(get_source_addr(line,fname,(ubyte)(ev-fname),&sym->v.l));
			sym->type=E_NUMBER;
			break;
			}
		case '.':
			{ /* must come before all other symbol code to
				allow symbols to start with . */
			char s;
			s=upper(*ev);
			if (s=='B')
				{
				sym->type=E_POSTMONADIC;
				sym->v.op.priority=20;		/* MUST be highest prior */
				sym->v.op.theop=OP_BYTE;
				if (upper(*++ev)==s)
					{
					ev++;
					sym->v.op.theop++;
					}
				break;
				}
			else if (s=='W')
				{
				sym->type=E_POSTMONADIC;
				sym->v.op.priority=20;		/* MUST be highest prior */
				sym->v.op.theop=OP_WORD;
				if (upper(*++ev)==s)
					{
					ev++;
					sym->v.op.theop++;
					}
				break;
				}
			else if (s=='L')
				{
				sym->type=E_POSTMONADIC;
				sym->v.op.priority=20;		/* MUST be highest prior */
				sym->v.op.theop=OP_LONG;
				if (upper(*++ev)==s)
					ev++;				/* no such thing as signed-long */
				break;
				}
			/* else we dont break, as could be .symbol */
			}
		case '@':
			if (c=='@')
				{
				if (isdigit(*ev))
					{
					must(parse_oct(&sym->v.l));
					sym->type=E_NUMBER;
					break;
					}
				/* fall through; might be @label */
				}
		case '?':
			if (c=='?')
			{
			char *p;
			void *value;
			byte ressize; bool junk;
			word err;
			
			if (!issymstart(*ev))
				return ERRM_INVALIDSYM;
			p=ev++;
			while (issym(*ev))
				ev++;
			err=find_reserved_sym(p,(ubyte)(ev-p),&value,&ressize,&junk);
			if (err)
				return err;
			sym->type=E_NUMBER;
			must(coerce_value(value,ressize,&sym->v.l,EXPR_LONG));		/* builtins are never floats */
			break;
			}
		case '0':
			/* 0n123 is Codeview for decimal */
			if ( (*ev=='n') || (*ev=='N') )
				{
				ev++;
				must(parse_decimal(&sym->v.l));
				sym->type=E_NUMBER;
				break;
				}
			/* falls through */
		default:
			if ( (c>='0') && (c<='9') )
				{
				char *dot;
				ev--;
				#if DOUBLES
				/* might be a double precision constant if its digit. something */
				dot=ev;
				while (isdigit(*dot))
					dot++;
				if (*dot=='.')
					{
					sym->v.d=strtod(ev,&ev);		/* let library do the hard work */
					sym->type=E_DBLNUMBER;
					}
				else
				#endif
				{
				must(parse_hex(&sym->v.l));
				sym->type=E_NUMBER;
				}
				}
			else if (issymstart(c))
				{ /* presumably a symbol */
				char *oldev;
				oldev=--ev;
				err=parse_symbol(&sym->v.l,FALSE,&(sym->type));
				if (err==ERRM_SYMNOTFOUND)
					{ /* eg fc100 looks like a symbol */
					if (isxdigit(*oldev))
						{
						ev=oldev;
						must(parse_hex(&sym->v.l));
						sym->type=E_NUMBER;
						}
					else
						return err;
					}
				}
			else
				{
				/* I dont understand, so hopefully end of expr */
				ev--;
				sym->type=E_BAD;
				}
			break;
		}
	return 0;
}

/* returns with topop pointing to the result */
word eval(char **p)
{
bool iwant_op;
word err;
item *next;
/* bracket goes up every ( or {, and down on ) or }
   the low byte of bracket is used as a bitlist of indirection
   Byte-sex dependent */
union {
		word value;
		struct  { ubyte count; ubyte bitlist; } bit;
	   } bracket;

	/* initialise the queues */
	topitem=botitem=itemlist;
	maxitem=&itemlist[MAXITEM-1];
	topop=botop=oplist;
	maxop=&oplist[MAXOP-1];
	iwant_op=FALSE;
	bracket.value=0;
	
	ev=*p;

	
	for ( ; ; )
		{
		/* getsym puts result directly into topitem */
		must(getsym_asm(next=topitem,iwant_op));

		if (next->type==E_BAD)
			break;

		if (!iwant_op)
			{ /* we want a factor */
			switch (next->type)
				{
				case E_NUMBER:
				#if DOUBLES
				case E_DBLNUMBER:
				#endif
					if (maxitem==topitem)
						return ERRE_ITEMOVERFLOW;
					/* copied directly by getsym
					topitem->type = next->type;
					topitem->v = next->v; */
					topitem++;
					iwant_op=TRUE;
					break;
				case E_PREMONADIC: case E_POSTMONADIC:
					if (topop==maxop)
						return ERRE_OPOVERFLOW;
					topop->type = next->type;
					topop->v.op.theop = next->v.op.theop;
					topop->v.op.priority = next->v.op.priority+bracket.value;
					topop++;
					if (next->type==E_POSTMONADIC)
						iwant_op=TRUE;
					break;
				case E_OPENBRACKET:
					bracket.bit.count++;
					bracket.bit.bitlist<<=1;
					break;
				case E_OPENIND:
					bracket.bit.count++;
					bracket.bit.bitlist<<=1;
					bracket.bit.bitlist|=1;
					break;
				default:
					goto nowhile;
					break;
				}
			}
		else
			{ /*we want an operator */
			if (next->type==E_CLOSEBRACKET)
				{
				if ( (bracket.bit.count==0) || (bracket.bit.bitlist&1) )
					return ERRE_NOOPENBRACKET;
				must(do_ops(bracket.value));
				bracket.bit.count--;
				bracket.bit.bitlist>>=1;
				}
			else if (next->type==E_CLOSEIND)
				{
				if ( (bracket.bit.count==0) || ((bracket.bit.bitlist&1)==0) )
					return ERRE_NOOPENBRACKET;
				must(do_ops(bracket.value));
				bracket.bit.count--;
				bracket.bit.bitlist>>=1;
				must(do_indirection());
				}
			else if (next->type==E_DYADIC)
				{
				must(do_ops((word)(next->v.op.priority+bracket.value)));
				if (topop==maxop)
					return ERRE_OPOVERFLOW;
				topop->v.op.priority = next->v.op.priority+bracket.value;
				topop->v.op.theop = next->v.op.theop;
				topop->type = next->type;
				topop++;
				iwant_op=FALSE;
				}
			else if (next->type==E_POSTMONADIC)
				{
				must(do_ops(next->v.op.priority+bracket.value));	/* tidy up ()s */
				if (topop==maxop)
					return ERRE_OPOVERFLOW;		/* then push op */
				topop->v.op.priority = next->v.op.priority+bracket.value;
				topop->v.op.theop = next->v.op.theop;
				topop->type = next->type;
				topop++;
				}
			else
				return ERRM_BADEXPRESSION;
			}
		}
nowhile:
	if (bracket.bit.count)
		return ERRE_NOCLOSEBRACKET;

	must(do_ops(0));					/* do all ops */

	if (--topitem!=botitem)
		return ERRE_LEFTOVER;
	*p=ev;
	return 0;
}



/* the only export; given a pointer to an expr, eval and co-erce */
/* returns error code or 0 */
word get_expression(char **p, byte wanted, void *result)
{
word err;

	checking=FALSE;
	must(eval(p));
	return coerce_type(topitem,wanted,result);

}

/* like the above but just checks syntax */
word check_expression(char **p, byte wanted, void *result)
{
word err;

	checking=TRUE;
	must(eval(p));
	return coerce_type(topitem,wanted,result);
}

/* returns type of expression */
word get_max_expression(char **p, byte *type, union alltypes *result)
{
word err;

	checking=FALSE;
	must(eval(p));
	*type=topitem->type;
	return coerce_type(topitem,*type,(void*)result);		/* won't coerce, just copy according to size */
}

/* called for simple expressions only. These are constants, which
	may be decimal, hex, octal or binary. Thats all. */
word simple_expr(char **start, long *result)
{
word err;
	ev=*start;
	switch (*ev)
		{
		case '$':
			ev++;
			err=parse_hex(result);
			break;
		case '%':
			ev++;
			err=parse_bin(result);
			break;
		case '@':
			ev++;
			err=parse_oct(result);
			break;
		case '\\':
			ev++;
			/* does not break */
		default:
			err=parse_decimal(result);
			break;
		}
	if (err==0)
		*start=ev;
	return err;
}

/* simple string parser */
word getstring(char **start, char *dest, size_t max)
{
char quote,c,*p;
size_t sofar;
	
	p=*start;
	sofar=1;
	if (*p=='\'')
		quote=*p++;
	else if (*p=='"')
		quote=*p++;
	else
		quote=0;

	while (c=*p++)
		{
		if (c==quote)
			break;				/* RSN cope with nested quotes */
		if (++sofar>max)
			return ERRE_LONGSTRING;
		*dest++=c;
		}
	*dest=0;
	*start=p;
	return 0;
}

char *add_char(char *buf, ubyte c)
{					
	if (c>=' ')
		*buf++=c;
	else
		{
		sprintf(buf,"\\x%02x",(int)c);
		buf+=4;
		}
	return buf;
}

/* given an expression and (optional) format string, calc the result */
/* for now coerces to long, but shouldn't really */
word format_expr(char *buf, char *expr, char *fmt)
{
char f;
word err;
long l;
byte type;
word i; ubyte c;

	err=0; type=0;

	if (fmt==NULL)
		fmt="$%lx";
	else
		switch (*fmt)
			{
			case 'd':
				fmt="%ld"; break;
			case 'h':
			case 'x':
				fmt="$%lx"; break;
			case 'a':
				type=1; break;
			case 'c':
				type=2; break;
			default:
				err=ERRM_BADFORMAT;
				break;
			}
	
	if (err==0)
		err=get_expression(&expr,EXPR_LONG,&l);
	if (err==0)
		{
		switch (type)
			{
			case 0:
				sprintf(buf,fmt,l);
				break;
			case 1:
				/* display as ASCII string */
				*buf++='\"';
				i=0;
				while (c=peekb(l++))
					{
					buf=add_char(buf,c);
					if (i++>80)
						break;
					}
				*buf++='\"';
				if (i>80)
					*buf++='.';
				*buf=0;
				break;
			case 2:
				*buf++='\'';
				buf=add_char(buf,(ubyte)l);
				*buf++='\'';
				*buf=0;
				break;
			}
		}
	else
		strcpy(buf,TX_ERROR(err));
	return err;
}

#if DOUBLES

#include <math.h>
#include <limits.h>

/* returns TRUE if the value is really an integer */

bool islongint(double d)
{
double c;

	c=ceil(d);
	if ( (c==d) && (c<=LONG_MAX) && (c>=LONG_MIN) )
		return TRUE;
	else
		return FALSE;
}
#endif

