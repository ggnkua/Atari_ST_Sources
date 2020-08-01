/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992, 1993, 1994 Aubrey Jaffer.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The author can be reached at jaffer@ai.mit.edu or
Aubrey Jaffer, 84 Pleasant St., Wakefield MA 01880
*/

#include "scm.h"
#include "setjump.h"

#ifdef ARM_ULIB
# include <termio.h>
int set_erase()
{
   struct termio tin;
   
   ioctl(0,TCGETA,&tin);
   tin.c_cc[VERASE] = '\010';
   
   ioctl(0,TCSETA,&tin);
   return(0);
}
#endif

/* ttyname() should be defined in <unistd.h>.  But unistd.h is missing
   on many systems. */
char *ttyname();

unsigned char upcase[CHAR_CODE_LIMIT];
unsigned char downcase[CHAR_CODE_LIMIT];
unsigned char lowers[] = "abcdefghijklmnopqrstuvwxyz";
unsigned char uppers[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
extern int verbose;
void init_tables()
{
  int i;
  for(i = 0;i<CHAR_CODE_LIMIT;i++) upcase[i] = downcase[i] = i;
  for(i = 0;i<sizeof lowers/sizeof(char);i++) {
    upcase[lowers[i]] = uppers[i];
    downcase[uppers[i]] = lowers[i];
  }
  verbose = 1;			/* Here so that monitor info won't be */
				/* printed while in init_storage. (BOOM) */
}

#ifdef EBCDIC
char *charnames[] = {
  "nul","soh","stx","etx", "pf", "ht", "lc","del",
   0   , 0   ,"smm", "vt", "ff", "cr", "so", "si",
  "dle","dc1","dc2","dc3","res", "nl", "bs", "il",
  "can", "em", "cc", 0   ,"ifs","igs","irs","ius",
   "ds","sos", "fs", 0   ,"byp", "lf","eob","pre",
   0   , 0   , "sm", 0   , 0   ,"enq","ack","bel",
   0   , 0   ,"syn", 0   , "pn", "rs", "uc","eot",
   0   , 0   , 0   , 0   ,"dc4","nak", 0   ,"sub",
  "space",s_newline,"tab","backspace","return","page","null"};
char charnums[] =
"\000\001\002\003\004\005\006\007\
\010\011\012\013\014\015\016\017\
\020\021\022\023\024\025\026\027\
\030\031\032\033\034\035\036\037\
\040\041\042\043\044\045\046\047\
\050\051\052\053\054\055\056\057\
\060\061\062\063\064\065\066\067\
\070\071\072\073\074\075\076\077\
 \n\t\b\r\f\0";
#endif /* def EBCDIC */
#ifdef ASCII
char *charnames[] = {
  "nul","soh","stx","etx","eot","enq","ack","bel",
   "bs", "ht", "nl", "vt", "np", "cr", "so", "si",
  "dle","dc1","dc2","dc3","dc4","nak","syn","etb",
  "can", "em","sub","esc", "fs", "gs", "rs", "us",
  "space",s_newline,"tab","backspace","return","page","null","del"};
char charnums[] =
"\000\001\002\003\004\005\006\007\
\010\011\012\013\014\015\016\017\
\020\021\022\023\024\025\026\027\
\030\031\032\033\034\035\036\037\
 \n\t\b\r\f\0\177";
#endif /* def ASCII */
char *isymnames[] = {
				/* Special Forms */
				/*  NUM_ISPCSYMS ISPCSYMS here */
  "#@and", "#@begin", "#@case", "#@cond", "#@do", "#@if", "#@lambda",
  "#@let", "#@let*", "#@letrec", "#@or", "#@quote", "#@set!",
  "#@define", "#@apply", "#@call-with-current-continuation",
				/* user visible ISYMS */
				/* other keywords */
				/* Flags */
  "#f", "#t", "#<undefined>", "#<eof>", "()", "#<unspecified>"
  };

static char	s_read_char[] = "read-char", s_peek_char[] = "peek-char";
char	s_read[] = "read", s_write[] = "write", s_newline[] = "newline";
static char	s_display[] = "display", s_write_char[] = "write-char";

static char	s_eofin[] = "end of file in ";
static char	s_unknown_sharp[] = "unknown # object";

static SCM lreadr(),lreadparen();
static sizet read_token();

void intprint(n,radix,port)
long n;
int radix;
SCM port;
{
  char num_buf[INTBUFLEN];
  lfwrite(num_buf,(sizet)sizeof(char),iint2str(n,radix,num_buf),port);
}

void ipruk(hdr,ptr,port)
     char *hdr;
     SCM ptr;
     SCM port;
{
  lputs("#<unknown-",port);
  lputs(hdr,port);
  if CELLP(ptr) {
    lputs(" (0x",port);
    intprint(CAR(ptr),16,port);
    lputs(" . 0x",port);
    intprint(CDR(ptr),16,port);
    lputs(") @",port);
  }
  lputs(" 0x",port);
  intprint(ptr,16,port);
  lputc('>',port);
}

void iprlist(hdr,exp,tlr,port,writing)
     char *hdr, tlr;
     SCM exp;
     SCM port;
     int writing;
{
  lputs(hdr,port);
  /* CHECK_INTS; */
  iprin1(CAR(exp),port,writing);
  exp = CDR(exp);
  for(;NIMP(exp);exp = CDR(exp)) {
    if NECONSP(exp) break;
    lputc(' ',port);
    /* CHECK_INTS; */
    iprin1(CAR(exp),port,writing);
  }
  if NNULLP(exp) {
    lputs(" . ",port);
    iprin1(exp,port,writing);
  }
  lputc(tlr,port);
}
void iprin1(exp,port,writing)
SCM exp;
SCM port;
int writing;
{
  register long i;
taloop:
  switch (7 & (int)exp) {
  case 2:
  case 6:
    intprint(INUM(exp),10,port);
    break;
  case 4:
    if ICHRP(exp) {
      i = ICHR(exp);
      if (writing) lputs("#\\",port);
      if (!writing) lputc((int)i,port);
      else if ((i <= ' ') && charnames[i]) lputs(charnames[i],port);
#ifndef EBCDIC
      else if (i=='\177')
	lputs(charnames[(sizeof charnames/sizeof(char *))-1],port);
#endif /* ndef EBCDIC */
      else if (i > '\177')
	intprint(i,8,port);
      else lputc((int)i,port);
    }
    else if (IFLAGP(exp) && (ISYMNUM(exp)<(sizeof isymnames/sizeof(char *))))
      lputs(ISYMCHARS(exp),port);
    else if ILOCP(exp) {
      lputs("#@",port);
      intprint((long)IFRAME(exp),10,port);
      lputc(ICDRP(exp)?'-':'+',port);
      intprint((long)IDIST(exp),10,port);
    }
    else goto idef;
    break;
  case 1:			/* gloc */
    lputs("#@",port);
    exp = CAR(exp-1);
    goto taloop;
  default:
  idef:
    ipruk("immediate",exp,port);
    break;
  case 0:
    switch TYP7(exp) {
    case tcs_cons_gloc:
    case tcs_cons_imcar:
    case tcs_cons_nimcar:
      iprlist("(",exp,')',port,writing);
      break;
    case tcs_closures:
      exp = CODE(exp);
      iprlist("#<CLOSURE ",exp,'>',port,writing);
      break;
    case tc7_string:
      if (writing) {
	lputc('\"',port);
	for(i = 0;i<LENGTH(exp);++i) switch (CHARS(exp)[i]) {
	case '"':
	case '\\':
	  lputc('\\',port);
	default:
	  lputc(CHARS(exp)[i], port);
	}
	lputc('\"',port);
	break;
      }
    case tcs_symbols:
      lfwrite(CHARS(exp),(sizet)sizeof(char),(sizet)LENGTH(exp),port);
      break;
    case tc7_vector:
      lputs("#(",port);
      for(i = 0;i+1<LENGTH(exp);++i) {
	/* CHECK_INTS; */
	iprin1(VELTS(exp)[i],port,writing);
	lputc(' ',port);
      }
      if (i<LENGTH(exp)) {
	/* CHECK_INTS; */
	iprin1(VELTS(exp)[i],port,writing);
      }
      lputc(')',port);
      break;
    case tc7_bvect:
    case tc7_ivect:
    case tc7_uvect:
    case tc7_fvect:
    case tc7_dvect:
    case tc7_cvect:
      uvprin1(exp,port,writing);
      break;
    case tcs_subrs:
      lputs("#<primitive-procedure ",port);
      lputs(CHARS(SNAME(exp)),port);
      lputc('>',port);
      break;
    case tc7_contin:
      lputs("#<continuation ",port);
      intprint(LENGTH(exp),10,port);
      lputs(" @ ",port);
      intprint((long)CHARS(exp),16,port);
      lputc('>',port);
      break;
    case tc7_port:
      i = PTOBNUM(exp);
      if (i<numptob && ptobs[i].print && (ptobs[i].print)(exp,port,writing))
	break;
      goto punk;
    case tc7_smob:
      i = SMOBNUM(exp);
      if (i<numsmob && smobs[i].print && (smobs[i].print)(exp,port,writing))
	break;
      goto punk;
    default: punk: ipruk("type",exp,port);
    }
  }
}

#ifdef MSDOS
# ifndef GO32
#  include <io.h>
#  include <conio.h>
static int input_waiting(f)
     FILE *f;
{
  if (feof(f)) return 1;
  if (fileno(f)==fileno(stdin) && (isatty(fileno(stdin)))) return kbhit();
  return -1;
}
# endif
#else
# ifdef _DCC
#  include <ioctl.h>
# else
#  ifndef AMIGA
#   ifndef vms
#    ifdef MWC
#     include <sys/io.h>
#    else
#     ifndef THINK_C
#      ifndef ARM_ULIB
#       include <sys/ioctl.h>
#      endif
#     endif
#    endif
#   endif
#  endif
# endif
static int input_waiting(f)
     FILE *f;
{
# ifdef FIONREAD
  long remir;
  if (feof(f)) return 1;
  ioctl(fileno(f), FIONREAD, &remir);
  return remir;
# else
  return -1;
# endif
}
#endif
#ifndef GO32
static char s_char_readyp[]="char-ready?";
SCM char_readyp(port)
     SCM port;
{
  if UNBNDP(port) port = cur_inp;
  else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_char_readyp);
  if (CRDYP(port) || !FPORTP(port)) return BOOL_T;
  return input_waiting(STREAM(port)) ? BOOL_T : BOOL_F;
}
#endif

SCM eof_objectp(x)
SCM x;
{
	return (EOF_VAL==x) ? BOOL_T : BOOL_F;
}

void lfflush(port)		/* internal SCM call */
     SCM port;
{
  sizet i = PTOBNUM(port);
  (ptobs[i].fflush)(STREAM(port));
}
#ifdef IO_EXTENSIONS
static char	s_flush[] = "force-output";
SCM lflush(port)		/* user accessible as flush-output */
SCM port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG1,s_flush);
	{
	  sizet i = PTOBNUM(port);
	  SYSCALL((ptobs[i].fflush)(STREAM(port)););
	  return UNSPECIFIED;
	}
}
#endif
SCM lwrite(obj,port)
SCM obj,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_write);
	iprin1(obj,port,1);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE==errno) close_port(port);
# endif
#endif
	return UNSPECIFIED;
}
SCM display(obj,port)
SCM obj,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_display);
	iprin1(obj,port,0);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE==errno) close_port(port);
# endif
#endif
	return UNSPECIFIED;
}
SCM newline(port)
SCM port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG1,s_newline);
	lputc('\n',port);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE==errno) close_port(port);
	else
# endif
#endif
	  if (port==cur_outp) lfflush(port);
	return UNSPECIFIED;
}
SCM write_char(chr,port)
SCM chr,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_write_char);
	ASSERT(ICHRP(chr),chr,ARG1,s_write_char);
	lputc((int)ICHR(chr),port);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE==errno) close_port(port);
# endif
#endif
	return UNSPECIFIED;
}

FILE *trans = 0;
SCM trans_on(fil)
     SCM fil;
{
  transcript = open_file(fil, makfromstr("w", (sizet)sizeof(char)));
  if FALSEP(transcript) trans = 0;
  else trans = STREAM(transcript);
  return UNSPECIFIED;
}
SCM trans_off()
{
  if (!FALSEP(transcript)) close_port(transcript);
  transcript = BOOL_F;
  trans = 0;
  return UNSPECIFIED;
}

void lputc(c,port)
     int c;
     SCM port;
{
  sizet i = PTOBNUM(port);
  SYSCALL((ptobs[i].fputc)(c,STREAM(port)););
  if (trans && (port==def_outp || port==cur_errp))
    SYSCALL(fputc(c,trans););
}
void lputs(s,port)
     char *s;
     SCM port;
{
  sizet i = PTOBNUM(port);
  SYSCALL((ptobs[i].fputs)(s,STREAM(port)););
  if (trans && (port==def_outp || port==cur_errp))
    SYSCALL(fputs(s,trans););
}
int lfwrite(ptr, size, nitems, port)
     char *ptr;
     sizet size;
     sizet nitems;
     SCM port;
{
  int ret;
  sizet i = PTOBNUM(port);
  SYSCALL(ret = (ptobs[i].fwrite)
	  (ptr, size, nitems, STREAM(port)););
  if (trans && (port==def_outp || port==cur_errp))
    SYSCALL(fwrite(ptr, size, nitems, trans););
  return ret;
}

int lgetc(port)
  SCM port;
{
  FILE *f;
  int c;
  sizet i;
  /* One char may be stored in the high bits of (car port) orre@nada.kth.se. */
  if CRDYP(port)
    {
      c = CGETUN(port);
      CLRDY(port);		/* Clear ungetted char */
      return c;
    }
  f=STREAM(port);
  i = PTOBNUM(port);
#ifdef linux
  c = (ptobs[i].fgetc)(f);
#else
  SYSCALL(c = (ptobs[i].fgetc)(f););
#endif
  if (trans && (f==stdin)) SYSCALL(fputc(c,trans););
  return c;
}
void lungetc(c,port)
  int c;
  SCM port;
{
/*	ASSERT(!CRDYP(port),port,ARG2,"too many lungetc");*/
	CUNGET(c,port);
}

SCM read_char(port)
  SCM port;
{
	int c;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_read_char);
	c = lgetc(port);
	if (EOF==c) return EOF_VAL;
	return MAKICHR(c);
}
SCM peek_char(port)
  SCM port;
{
	int c;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port), port,ARG1,s_peek_char);
	c = lgetc(port);
	if (EOF==c) return EOF_VAL;
	lungetc(c,port);
	return MAKICHR(c);
}

static char *grow_tok_buf(tok_buf)
     SCM tok_buf;
{
  sizet len = LENGTH(tok_buf);
  len += len / 2;
  resizuve(tok_buf,(SCM)MAKINUM(len));
  return CHARS(tok_buf);
}

static int flush_ws(port,eoferr)
SCM port;
char *eoferr;
{
	register int c;
	while(1) switch (c = lgetc(port)) {
	case EOF:
goteof:
		if (eoferr) wta(UNDEFINED,s_eofin,eoferr);
		return c;
	case ';':
lp:
		switch (c = lgetc(port)) {
		case EOF:
			goto goteof;
		default:
			goto lp;
		case LINE_INCREMENTORS:
			break;
		}
	case LINE_INCREMENTORS:
		linum++;
	case WHITE_SPACES:
		break;
	default:
		return c;
	}
}
SCM lread(port)
SCM port;
{
	int c;
	SCM tok_buf;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_read);
	do {
	  c = flush_ws(port,(char *)NULL);
	  if (EOF==c) return EOF_VAL;
	  lungetc(c,port);
	  tok_buf = makstr(30L);
	} while (EOF_VAL==(tok_buf = lreadr(tok_buf,port)));
	return tok_buf;
}
static SCM lreadr(tok_buf,port)
SCM tok_buf;
SCM port;
{
	int c;
	sizet j;
	SCM p;
tryagain:
	c = flush_ws(port,s_read);
	switch (c) {
/*	case EOF: return EOF_VAL;*/
#ifdef BRACKETS_AS_PARENS
	case '[':
#endif
	case '(': return lreadparen(tok_buf,port,s_list);
#ifdef BRACKETS_AS_PARENS
	case ']':
#endif
	case ')': warn("unexpected \")\"","");
	  goto tryagain;
	case '\'': return cons2(i_quote,lreadr(tok_buf,port),EOL);
	case '`': return cons2(i_quasiquote,lreadr(tok_buf,port),EOL);
	case ',':
		c = lgetc(port);
		if ('@'==c) p = i_uq_splicing;
		else {
			lungetc(c,port);
			p = i_unquote;
		}
		return cons2(p,lreadr(tok_buf,port),EOL);
	case '#':
		c = lgetc(port);
		switch (c) {
#ifdef BRACKETS_AS_PARENS
		case '[':
#endif
		case '(':
			p = lreadparen(tok_buf,port,s_vector);
			return NULLP(p) ? nullvect : vector(p);
		case 't': case 'T': return BOOL_T;
		case 'f': case 'F': return BOOL_F;
		case 'b': case 'B': case 'o': case 'O':
		case 'd': case 'D': case 'x': case 'X':
		case 'i': case 'I': case 'e': case 'E':
			lungetc(c,port);
			c = '#';
			goto num;
		case '*':
			j = read_token(c,tok_buf,port);
			p = istr2bve(CHARS(tok_buf)+1,(long)(j-1)); 
			if (NFALSEP(p)) return p;
			else goto unkshrp;
		case '\\':
			c = lgetc(port);
			j = read_token(c,tok_buf,port);
			if (j==1) return MAKICHR(c);
			if (c >= '0' && c < '8') {
			  p = istr2int(CHARS(tok_buf),(long)j,8);
			  if (NFALSEP(p)) return MAKICHR(INUM(p));
			}
			for (c = 0;c<sizeof charnames/sizeof(char *);c++)
			  if (charnames[c]
			      && (0==strcmp(charnames[c],CHARS(tok_buf))))
			    return MAKICHR(charnums[c]);
			wta(UNDEFINED,"unknown # object: #\\",CHARS(tok_buf));
		case '|':
			j = 1;	/* here j is the comment nesting depth */
lp:			c = lgetc(port);
lpc:			switch (c) {
			case EOF:
			  wta(UNDEFINED,s_eofin,"balanced comment");
			case LINE_INCREMENTORS:
			  linum++;
			default:
			  goto lp;
			case '|':
			  if ('#' != (c = lgetc(port))) goto lpc;
			  if (--j) goto lp;
			  break;
			case '#':
			  if ('|' != (c = lgetc(port))) goto lpc;
			  ++j; goto lp;
			}
			goto tryagain;
		case '.':
			p = lreadr(tok_buf,port);
			return EVAL(p,(SCM)EOL);
		default: callshrp:
			p = CDR(intern("read:sharp", (sizeof "read:sharp")-1));
			if NIMP(p) {
			  p = apply(p,MAKICHR(c),acons(port,EOL,EOL));
			  if (UNSPECIFIED == p) goto tryagain;
			  return p;
			}
		      unkshrp: wta((SCM)MAKICHR(c),s_unknown_sharp,"");
		}
	case '\"':
		j = 0;
		while ('\"' != (c = lgetc(port))) {
			ASSERT(EOF != c,UNDEFINED,s_eofin,s_string);
			if (j+1 >= LENGTH(tok_buf)) grow_tok_buf(tok_buf);
			if (c=='\\') switch (c = lgetc(port)) {
			case '\n': continue;
			case '0': c = '\0'; break;
			case 'f': c = '\f'; break;
			case 'n': c = '\n'; break;
			case 'r': c = '\r'; break;
			case 't': c = '\t'; break;
			case 'a': c = '\007'; break;
			case 'v': c = '\v'; break;
			}
			CHARS(tok_buf)[j] = c;
			++j;
		}
		if (j==0) return nullstr;
		CHARS(tok_buf)[j] = 0;
		return makfromstr(CHARS(tok_buf),j);
	case DIGITS:
	case '.': case '-': case '+':
num:
		j = read_token(c,tok_buf,port);
		p = istring2number(CHARS(tok_buf), (long)j, 10L);
		if NFALSEP(p) return p;
	        if (c == '#') {
		  if ((j == 2) && (lgetc(port) == '(')) {
		    lungetc('(',port);
		    c = CHARS(tok_buf)[1];
		    goto callshrp;
		  }
		  wta(UNDEFINED,s_unknown_sharp,CHARS(tok_buf));
		}
	        goto tok;
	default:
		j = read_token(c,tok_buf,port);
tok:
		p = intern(CHARS(tok_buf),j);
		return CAR(p);
	}
}
static sizet read_token(ic,tok_buf,port)
int ic;
SCM tok_buf;
SCM port;
{
	register sizet j = 1;
	register int c = ic;
	register char *p = CHARS(tok_buf);
	p[0] = downcase[c];
	while(1) {
		if (j+1 >= LENGTH(tok_buf)) p = grow_tok_buf(tok_buf);
		switch (c = lgetc(port)) {
#ifdef BRACKETS_AS_PARENS
		case '[': case ']':
#endif
		case '(': case ')': case '\"': case ';':
		case WHITE_SPACES:
		case LINE_INCREMENTORS:
			lungetc(c,port);
		case EOF:
			p[j] = 0;
			return j;
		default:
			p[j++] = downcase[c];
		}
	}
}
static SCM lreadparen(tok_buf,port,name)
SCM tok_buf;
SCM port;
char *name;
{
  SCM tmp, tl, ans;
  int c = flush_ws(port,name);
  if (')'==c
#ifdef BRACKETS_AS_PARENS
      || ']'==c
#endif
      ) return EOL;
  lungetc(c,port);
  if (i_dot==(tmp = lreadr(tok_buf,port))) {
    ans = lreadr(tok_buf,port);
  closeit:
    if (')' != (c = flush_ws(port,name))
#ifdef BRACKETS_AS_PARENS
	&& ']' != c
#endif
	)
      wta(UNDEFINED,"missing close paren","");
    return ans;
  }
  ans = tl = cons(tmp, EOL);
  while (')' != (c = flush_ws(port,name))
#ifdef BRACKETS_AS_PARENS
	 && ']' != c
#endif
	 ) {
    lungetc(c,port);
    if (i_dot == (tmp = lreadr(tok_buf,port))) {
      CDR(tl) = lreadr(tok_buf,port);
      goto closeit;
    }
    tl = (CDR(tl) = cons(tmp,EOL));
  }
  return ans;
}

#ifdef IO_EXTENSIONS
static char	s_file_position[] = "file-position",
		s_file_set_pos[] = "file-set-position";
SCM file_position(port)
SCM port;
{
	long ans;
	ASSERT(NIMP(port) && OPFPORTP(port), port,ARG1,s_file_position);
	SYSCALL(ans = ftell(STREAM(port)););
	if CRDYP(port) ans--;
	return MAKINUM(ans);
      }
SCM file_set_position(port, pos)
     SCM port, pos;
{
	SCM ans;
	ASSERT(NIMP(port) && OPFPORTP(port), port,ARG1,s_file_set_pos);
	CLRDY(port);		/* Clear ungetted char */
	SYSCALL(ans = (fseek(STREAM(port),INUM(pos),0)) ? BOOL_F : BOOL_T;);
#ifdef HAVE_PIPE
# ifdef ESPIPE
	ASSERT(ESPIPE != errno, port, ARG1, s_file_set_pos);
# endif
#endif
	return ans;
}
static char s_readline[] = "read-line";
SCM readline(port)
     SCM port;
{
  register int c;
  register int j = 0;
  sizet len = 30;
  SCM tok_buf = makstr((long) len);
  register char *p = CHARS(tok_buf);
  if UNBNDP(port) port = cur_inp;
  else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_readline);
  if (EOF==(c = lgetc(port))) return EOF_VAL;
  while(1) {
    switch (c) {
    case LINE_INCREMENTORS:
    case EOF:
      if (len==j) return tok_buf;
      return resizuve(tok_buf,(SCM)MAKINUM(j));
    default:
      if (j >= len) {
	p = grow_tok_buf(tok_buf);
	len = LENGTH(tok_buf);
      }
      p[j++] = c;
      c = lgetc(port);
    }
  }
}
static char s_read_line1[] = "read-line!";
SCM read_line1(str,port)
     SCM str, port;
{
  register int c;
  register int j = 0;
  register char *p;
  sizet len;
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_read_line1);
  p = CHARS(str);
  len = LENGTH(str);
  if UNBNDP(port) port = cur_inp;
  else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG2,s_read_line1);
  c = lgetc(port);
  if (EOF==c) return EOF_VAL;
  while(1) {
    switch (c) {
    case LINE_INCREMENTORS:
    case EOF:
      return MAKINUM(j);
    default:
      if (j >= len) {
	lungetc(c,port);
	return BOOL_F;
      }
      p[j++] = c;
      c = lgetc(port);
    }
  }
}
#endif /* def IO_EXTENSIONS */

/* These procedures implement synchronization primitives.  Processors
   with an atomic test-and-set instruction can use it here (and not
   DEFER_INTS). */
char s_tryarb[] = "try-arbiter";
char s_relarb[] = "release-arbiter";
long tc16_arbiter;
SCM tryarb(arb)
     SCM arb;
{
  ASSERT((TYP16(arb)==tc16_arbiter),arb,ARG1,s_tryarb);
  DEFER_INTS;
  if (CAR(arb) & (1L<<16))
    arb = BOOL_F;
  else {
    CAR(arb) = tc16_arbiter | (1L<<16);
    arb = BOOL_T;
  }
  ALLOW_INTS;
  return arb;
}
SCM relarb(arb)
     SCM arb;
{
  ASSERT((TYP16(arb)==tc16_arbiter),arb,ARG1,s_relarb);
  if (!(CAR(arb) & (1L<<16))) return BOOL_F;
  CAR(arb) = tc16_arbiter;
  return BOOL_T;
}
SCM makarb(name)
SCM name;
{
  register SCM z;
  NEWCELL(z);
  CDR(z) = name;
  CAR(z) = tc16_arbiter;
  return z;
}
static int prinarb(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  lputs("#<arbiter ",port);
  if (CAR(exp) & (1L<<16)) lputs("locked ",port);
  iprin1(CDR(exp),port,writing);
  lputc('>',port);
  return !0;
}

static char s_tryload[] = "try-load";
#define s_load (&s_tryload[4])

struct errdesc {char *msg;char *s_response;short parent_err;};
struct errdesc errmsgs[] = {
  {"Wrong number of args",0,0},
  {"numerical overflow",0,FPE_SIGNAL},
  {"Argument out of range",0,FPE_SIGNAL},
  {"Could not allocate","out-of-storage",0},
  {"EXIT","end-of-program",-1},
  {"hang up","hang-up",EXIT},
  {"user interrupt","user-interrupt",0},
  {"arithmetic error","arithmetic-error",0},
  {"bus error",0,0},
  {"segment violation",0,0},
  {"alarm","alarm-interrupt",0}
};

int errjmp_bad = 1, ints_disabled = 1, sig_deferred = 0, alrm_deferred;
SCM err_exp,err_env;
char *err_pos, *err_s_subr;
cell tmp_errobj = {(SCM)UNDEFINED, (SCM)EOL};
cell tmp_loadpath = {(SCM)BOOL_F, (SCM)EOL};
SCM *loc_errobj = (SCM *)&tmp_errobj;
SCM *loc_loadpath = (SCM *)&tmp_loadpath;
long linum = 1;
int verbose = 1;
long cells_allocated = 0, lcells_allocated = 0,
  mallocated = 0, lmallocated = 0,
  rt = 0, gc_rt, gc_time_taken;
long gc_cells_collected, gc_malloc_collected, gc_ports_collected;
static void def_err_response();

int handle_it(i)
     int i;
{
  char *name = errmsgs[i-WNA].s_response;
  SCM proc;
  if (name) {
    proc = CDR(intern(name,(sizet)strlen(name)));
    if NIMP(proc) {
      apply(proc,EOL,EOL);
      return i;
    }
  }
  return errmsgs[i-WNA].parent_err;
}

void init_init(initpath)
     char *initpath;
{
  SCM name = makfromstr(initpath, (sizet)(strlen(initpath))*sizeof(char));
  if (BOOL_T != tryload(name))
    wta(name,"Could not open file",s_load);
}

SCM exitval;			/* INUM with return value */
SCM repl_driver(initpath)
     char *initpath;
{
#ifdef _UNICOS
  int i;
#else
  long i;
#endif
  BASE(rootcont) = (STACKITEM *)&i;
  i = setjmp(JMPBUF(rootcont));
 drloop:
  switch ((int)i) {
  default:
    {
      char *name = errmsgs[i-WNA].s_response;
      if (name) {
	SCM proc = CDR(intern(name,(sizet)strlen(name)));
	if NIMP(proc) apply(proc,EOL,EOL);
      }
      if ((i = errmsgs[i-WNA].parent_err)) goto drloop;
      def_err_response();
      goto reset_toplvl;
    }
  case 0:
    exitval = MAKINUM(EXIT_SUCCESS);
    errjmp_bad = 0;
    errno = 0;
    alrm_deferred = 0;
    sig_deferred = 0;
    ints_disabled = 0;
    init_init(initpath);	/* load Scheme init files */
  case -2:
  reset_toplvl:
    errjmp_bad = 0;
    alrm_deferred = 0;
    sig_deferred = 0;
    ints_disabled = 0;
				/* need to close loading files here. */
    *loc_loadpath = BOOL_F;
    repl();
    err_pos = (char *)EXIT;
    i = EXIT;
    goto drloop;		/* encountered EOF on stdin */
  case -1:
    return exitval;
  case -3:
    return 0;
  }
}

SCM line_num()
{
  return MAKINUM(linum);
}
SCM prog_args()
{
  return progargs;
}

extern char s_heap[];
extern sizet hplim_ind;
extern CELLPTR *hplims;
void growth_mon(obj, size, units)
     char *obj;
     long size;
     char *units;
{
  if (verbose>2)
    {
      lputs("; grew ",cur_errp);
      lputs(obj,cur_errp);
      lputs(" to ",cur_errp);
      intprint(size,10,cur_errp);
      lputc(' ',cur_errp);
      lputs(units,cur_errp);
      if ((verbose>4) && (obj==s_heap)) heap_report();
      lputs("\n",cur_errp);
    }
}

void gc_start(what)
     char *what;
{
  if (verbose>3 && FPORTP(cur_errp)) {
    ALLOW_INTS;
    lputs(";GC(",cur_errp);
    lputs(what,cur_errp);
    lputs(")",cur_errp);
    lfflush(cur_errp);
    DEFER_INTS;
  }
  gc_rt = INUM(my_time());
  gc_cells_collected = 0;
  gc_malloc_collected = 0;
  gc_ports_collected = 0;
}
void gc_end()
{
  gc_rt = INUM(my_time()) - gc_rt;
  gc_time_taken = gc_time_taken + gc_rt;
  if (verbose>3) {
    ALLOW_INTS;
    if (!FPORTP(cur_errp)) lputs(";GC ",cur_errp);
    intprint(time_in_msec(gc_rt),10,cur_errp);
    lputs(" cpu mSec, ",cur_errp);
    intprint(gc_cells_collected,10,cur_errp);
    lputs(" cells, ",cur_errp);
    intprint(gc_malloc_collected,10,cur_errp);
    lputs(" malloc, ",cur_errp);
    intprint(gc_ports_collected,10,cur_errp);
    lputs(" ports collected\n",cur_errp);
    lfflush(cur_errp);
    DEFER_INTS;
  }
}
void repl_report()
{
  if (verbose>1) {
    lfflush(cur_outp);
    lputs(";Evaluation took ",cur_errp);
    intprint(time_in_msec(INUM(my_time())-rt),10,cur_errp);
    lputs(" mSec (",cur_errp);
    intprint(time_in_msec(gc_time_taken),10,cur_errp);
    lputs(" in gc) ",cur_errp);
    intprint(cells_allocated - lcells_allocated,10,cur_errp);
    lputs(" cells work, ",cur_errp);
    intprint(mallocated - lmallocated,10,cur_errp);
    lputs(" bytes other\n",cur_errp);
    lfflush(cur_errp);
  }
}
SCM lroom(args)
     SCM args;
{
  intprint(cells_allocated,10,cur_errp);
  lputs(" out of ",cur_errp);
  intprint(heap_size,10,cur_errp);
  lputs(" cells in use, ",cur_errp);
  intprint(mallocated,10,cur_errp);
  lputs(" bytes allocated (of ",cur_errp);
  intprint(mtrigger,10,cur_errp);
  lputs(")\n",cur_errp);
  if NIMP(args) {
    heap_report();
    lputs("\n",cur_errp);
    stack_report();
  }
  return UNSPECIFIED;
}
void heap_report()
{
  sizet i = 0;
  lputs("; heap segments:",cur_errp);
  while(i<hplim_ind) {
    lputs("\n; 0x",cur_errp);
    intprint((long)hplims[i++],16,cur_errp);
    lputs(" - 0x",cur_errp);
    intprint((long)hplims[i++],16,cur_errp);
  }
}
void exit_report()
{
  if (verbose>2) {
    lputs(";Totals: ",cur_errp);
    intprint(time_in_msec(INUM(my_time())),10,cur_errp);
    lputs(" mSec my time, ",cur_errp);
    intprint(time_in_msec(INUM(your_time())),10,cur_errp);
    lputs(" mSec your time\n",cur_errp);
  }
}

SCM prolixity(arg)
SCM arg;
{
  int old = verbose;
  if (!UNBNDP(arg)) {
    if FALSEP(arg) verbose = 1;
    else verbose = INUM(arg);
  }
  return MAKINUM(old);
}

void repl()
{
  SCM x;
  repl_report();
  while(1) {
    if OPOUTPORTP(cur_inp) {	/* This case for curses window */
      lfflush(cur_outp);
      if (verbose) lputs(PROMPT,cur_inp);
      lfflush(cur_inp);
    }
    else {
      if (verbose) lputs(PROMPT,cur_outp);
      lfflush(cur_outp);
    }
    lcells_allocated = cells_allocated;
    lmallocated = mallocated;
    x = lread(cur_inp);
    rt = INUM(my_time());
    gc_time_taken = 0;
    if (EOF_VAL==x) break;
    if (!CRDYP(cur_inp))	/* assure newline read (and transcripted) */
      lungetc(lgetc(cur_inp),cur_inp);
#ifdef __TURBOC__
    if ('\n' != CGETUN(cur_inp))
      if OPOUTPORTP(cur_inp)	/* This case for curses window */
	{lfflush(cur_outp); newline(cur_inp);}
      else newline(cur_outp);
#endif
    x = EVAL(x,(SCM)EOL);
    repl_report();
    iprin1(x,cur_outp,1);
    lputc('\n',cur_outp);
  }
}
SCM quit(n)
SCM n;
{
  if (UNBNDP(n) || n==BOOL_T) n = MAKINUM(EXIT_SUCCESS);
  else if INUMP(n) exitval = n;
  else n = MAKINUM(EXIT_FAILURE);
  if IMP(rootcont) exit(INUM(exitval));
  dowinds(EOL,ilength(dynwinds));
  longjmp(JMPBUF(rootcont),-1);
}
SCM abrt()
{
  if IMP(rootcont) exit(INUM(exitval));
  dowinds(EOL,ilength(dynwinds));
  longjmp(JMPBUF(rootcont),-2);
}
SCM restart()
{
  if IMP(rootcont) exit(INUM(exitval));
  dowinds(EOL,ilength(dynwinds));
  longjmp(JMPBUF(rootcont),-3);
}
#ifndef THINK_C
# ifndef __WATCOMC__
#  ifndef GO32
char **execargv = 0;
char s_exec[] = "exec";
SCM lexec(args)
     SCM args;
{
  int i = ilength(args);
  ASSERT(i>0,args,WNA,s_exec);
  dowinds(EOL,ilength(dynwinds));
  DEFER_INTS;
  execargv = (char **)must_malloc((1L+i)*sizeof(char *), s_vector);
  for(i = 0; NNULLP(args); args=CDR(args), ++i) {
    sizet len = 1 + LENGTH(CAR(args));
    char *dst = (char *)must_malloc((long)len, s_string);
    char *src = CHARS(CAR(args));
    while (len--) dst[len] = src[len];
    execargv[i] = dst;
  }
  execargv[i] = 0;
  ALLOW_INTS;
  longjmp(JMPBUF(rootcont),-3);
}
#  endif
# endif
#endif
void han_sig()
{
  sig_deferred = 0;
  if (INT_SIGNAL != handle_it(INT_SIGNAL))
    wta(UNDEFINED,(char *)INT_SIGNAL,"");
}
void han_alrm()
{
  alrm_deferred = 0;
  if (ALRM_SIGNAL != handle_it(ALRM_SIGNAL))
    wta(UNDEFINED,(char *)ALRM_SIGNAL,"");
}

SCM tryload(filename)
SCM filename;
{
  ASSERT(NIMP(filename) && STRINGP(filename),filename,ARG1,s_load);
  {
    SCM oloadpath = *loc_loadpath;
    long olninum = linum;
    SCM form,port;
    port = open_file(filename, makfromstr("r", (sizet)sizeof(char)));
    if FALSEP(port) return port;
    *loc_loadpath = filename;
    linum = 1;
    while(1) {
      form = lread(port);
      if (EOF_VAL==form) break;
      SIDEVAL(form,EOL);
    }
    close_port(port);
    linum = olninum;
    *loc_loadpath = oloadpath;
  }
  return BOOL_T;
}

static void err_head(str)
char *str;
{
  int oerrno = errno;
  exitval = MAKINUM(EXIT_FAILURE);
  if NIMP(cur_outp) lfflush(cur_outp);
  lputc('\n',cur_errp);
  if(BOOL_F != *loc_loadpath) {
    iprin1(*loc_loadpath,cur_errp,1);
    lputs(", line ",cur_errp);
    intprint((long)linum,10,cur_errp);
    lputs(": ",cur_errp);
  }
  lfflush(cur_errp);
  errno = oerrno;
  if (cur_errp==def_errp) {
    if (errno>0) perror(str);
    fflush(stderr);
    return;
  }
}
void warn(str1,str2)
char *str1,*str2;
{
  err_head("WARNING");
  lputs("WARNING: ",cur_errp);
  lputs(str1,cur_errp);
  lputs(str2,cur_errp);
  lputc('\n',cur_errp);
  lfflush(cur_errp);
}

SCM lerrno(arg)
SCM arg;
{
  int old = errno;
  if (!UNBNDP(arg)) {
    if FALSEP(arg) errno = 0;
    else errno = INUM(arg);
  }
  return MAKINUM(old);
}
static char s_perror[] = "perror";
SCM lperror(arg)
SCM arg;
{
  ASSERT(NIMP(arg) && STRINGP(arg),arg,ARG1,s_perror);
  err_head(CHARS(arg));
  return UNSPECIFIED;
}
static void def_err_response()
{
  SCM obj = *loc_errobj;
  DEFER_INTS;
  err_head("ERROR");
  lputs("ERROR: ",cur_errp);
  if (err_s_subr && *err_s_subr) {
    lputs(err_s_subr,cur_errp);
    lputs(": ",cur_errp);
  }
  if (err_pos==(char *)ARG1 && UNBNDP(*loc_errobj)) err_pos = (char *)WNA;
#ifdef nosve
  if ((~0x1fL) & (short)err_pos) lputs(err_pos,cur_errp);
  else if (WNA>(short)err_pos) {
    lputs("Wrong type in arg",cur_errp);
    lputc('0'+(short)err_pos,cur_errp);
  }
#else
  if ((~0x1fL) & (long)err_pos) lputs(err_pos,cur_errp);
  else if (WNA>(long)err_pos) {
    lputs("Wrong type in arg",cur_errp);
    lputc('0'+(int)err_pos,cur_errp);
  }
#endif
  else {
    lputs(errmsgs[((int)err_pos)-WNA].msg,cur_errp);
    goto outobj;
  }
  if (IMP(obj) || SYMBOLP(obj) || (TYP16(obj)==tc7_port)
      || (NFALSEP(procedurep(obj))) || (NFALSEP(numberp(obj)))) {
outobj:
    if (!UNBNDP(obj)) {
      lputs(((long)err_pos==WNA)?" to ":" ",cur_errp);
      iprin1(obj,cur_errp,1);
    }
  }
  else lputs(" (see errobj)",cur_errp);
  if UNBNDP(err_exp) goto getout;
  if NIMP(err_exp) {
    lputs("\n; in expression: ",cur_errp);
    if NCONSP(err_exp) iprin1(err_exp,cur_errp,1);
    else if (UNDEFINED==CDR(err_exp))
      iprin1(CAR(err_exp),cur_errp,1);
    else iprlist("(... ",err_exp,')',cur_errp,1);
  }
  if NULLP(err_env) lputs("\n; in top level environment.",cur_errp);
  else {
    SCM env = err_env;
    lputs("\n; in scope:",cur_errp);
    while NNULLP(env) {
      lputc('\n',cur_errp);
      lputs(";   ",cur_errp);
      iprin1(CAR(CAR(env)),cur_errp,1);
      env = CDR(env);
    }
  }
 getout:
  lputc('\n',cur_errp);
  lfflush(cur_errp);
  err_exp = err_env = UNDEFINED;
  if (errjmp_bad) {
    iprin1(obj,cur_errp,1);
    lputs("\nFATAL ERROR DURING CRITICAL CODE SECTION\n",cur_errp);
    quit(MAKINUM(errno?(long)errno:1L));
  }
  errno = 0;
  ALLOW_INTS;
}
void everr(exp,env,arg,pos,s_subr)
SCM exp,env,arg;
char *pos, *s_subr;
{
  err_exp = exp;
  err_env = env;
  *loc_errobj = arg;
  err_pos = pos;
  err_s_subr = s_subr;
  if (((~0x1fL) & (long)pos) || (WNA>(long)pos)) {
    def_err_response();
    abrt();
  }
  if IMP(rootcont) exit(INUM(exitval));
  dowinds(EOL,ilength(dynwinds));
  longjmp(JMPBUF(rootcont),(int)pos);
}
void wta(arg,pos,s_subr)
SCM arg;
char *pos, *s_subr;
{
 everr(UNDEFINED,EOL,arg,pos,s_subr);
}
SCM cur_input_port()
{
  return cur_inp;
}
SCM cur_output_port()
{
  return cur_outp;
}
SCM cur_error_port()
{
  return cur_errp;
}
char s_cur_inp[] = "set-current-input-port";
char s_cur_outp[] = "set-current-output-port";
char s_cur_errp[] = "set-current-error-port";
SCM set_inp(port)
     SCM port;
{
  SCM oinp = cur_inp;
  ASSERT(NIMP(port) && OPINPORTP(port), port,ARG1,s_cur_inp);
  cur_inp = port;
  return oinp;
}
SCM set_outp(port)
     SCM port;
{
  SCM ooutp = cur_outp;
  ASSERT(NIMP(port) && OPOUTPORTP(port), port,ARG1,s_cur_outp);
  cur_outp = port;
  return ooutp;
}
SCM set_errp(port)
     SCM port;
{
  SCM oerrp = cur_errp;
  ASSERT(NIMP(port) && OPOUTPORTP(port), port,ARG1,s_cur_errp);
  cur_errp = port;
  return oerrp;
}

char *features[] = {
#ifdef IO_EXTENSIONS
# ifdef HAVE_PIPE
  s_pipe,
# endif
  "i/o-extensions",
  "line-i/o",
#endif
#ifdef RECKLESS
  "reckless",
#endif
#ifndef GO32
  s_char_readyp,
#endif
#ifdef SICP
  "sicp",
#endif
  0};

SCM *loc_features;
void init_features()
{
  char **feats = features;
  SCM fts = EOL;
  for(;*feats;feats++)
    /* This sysintern is dangerous if any features have the same names */
    /* as SCM functions.  ED is a case of this! */
    fts = cons(CAR(sysintern(*feats,UNDEFINED)), fts);
  loc_features = &CDR(sysintern("*features*", fts));
}
void add_feature(str)
     char* str;
{
  *loc_features = cons(CAR(intern(str,strlen(str))), *loc_features);
}

static iproc subr0s[] = {
	{&s_cur_inp[4],cur_input_port},
	{&s_cur_outp[4],cur_output_port},
	{&s_cur_errp[4],cur_error_port},
	{"transcript-off",trans_off},
	{"program-arguments",prog_args},
	{"line-number",line_num},
	{"abort",abrt},
	{"restart",restart},
	{0,0}};

static iproc subr1s[] = {
	{s_cur_inp,set_inp},
	{s_cur_outp,set_outp},
	{s_cur_errp,set_errp},
#ifdef IO_EXTENSIONS
	{s_file_position,file_position},
#endif
	{"transcript-on",trans_on},
	{s_tryload,tryload},
	{s_perror,lperror},
	{"make-arbiter", makarb},
	{s_tryarb, tryarb},
	{s_relarb, relarb},
	{0,0}};

static iproc subr1os[] = {
	{s_read,lread},
	{s_read_char,read_char},
	{s_peek_char,peek_char},
	{s_newline,newline},
#ifndef GO32
	{s_char_readyp,char_readyp},
#endif
#ifdef IO_EXTENSIONS
	{s_flush,lflush},
	{s_readline,readline},
#endif /* def IO_EXTENSIONS */
	{"quit",quit},
	{"verbose",prolixity},
	{"errno",lerrno},
	{0,0}};

static iproc subr2os[] = {
	{s_write,lwrite},
	{s_display,display},
	{s_write_char,write_char},
#ifdef IO_EXTENSIONS
	{s_file_set_pos,file_set_position},
	{s_read_line1,read_line1},
#endif /* def IO_EXTENSIONS */
	{0,0}};

static smobfuns arbsmob = {markcdr,free0,prinarb};
char s_ccl[] = "char-code-limit";

void init_repl( iverbose )
int iverbose;
{
	sysintern(s_ccl, MAKINUM(CHAR_CODE_LIMIT));
	loc_errobj = &CDR(sysintern("errobj", UNDEFINED));
	loc_loadpath = &CDR(sysintern("*load-pathname*", BOOL_F));
	transcript = BOOL_F;
	trans = 0;
	linum = 1;
	verbose = iverbose;
	init_iprocs(subr0s, tc7_subr_0);
	init_iprocs(subr1os, tc7_subr_1o);
	init_iprocs(subr1s, tc7_subr_1);
	init_iprocs(subr2os, tc7_subr_2o);
	make_subr("room",tc7_lsubr,lroom);
#ifdef ARM_ULIB
	set_erase();
#endif
#ifndef THINK_C
# ifndef __WATCOMC__
#  ifndef GO32
	make_subr(s_exec,tc7_lsubr,lexec);
#  endif
# endif
#endif
	tc16_arbiter = newsmob(&arbsmob);
}
void final_repl()
{
  loc_errobj = (SCM *)&tmp_errobj;
  loc_loadpath = (SCM *)&tmp_loadpath;
  transcript = BOOL_F;
  trans = 0;
  linum = 1;
}
