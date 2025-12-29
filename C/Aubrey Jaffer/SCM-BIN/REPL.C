/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.

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

#include <stdio.h>
#include "scm.h"

#ifdef vms
# ifndef CHEAP_CONTINUATIONS
#  include "setjump.h"
# else
#  include <setjmp.h>
# endif
#else
# include <setjmp.h>
#endif /* vms */

unsigned char upcase[CHAR_CODE_LIMIT];
unsigned char downcase[CHAR_CODE_LIMIT];
unsigned char lowers[]="abcdefghijklmnopqrstuvwxyz";
unsigned char uppers[]="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
void init_tables()
{
	int i;
	for(i=0;i<CHAR_CODE_LIMIT;i++) upcase[i]=downcase[i]=i;
	for(i=0;i<sizeof(lowers);i++) {
		upcase[lowers[i]]=uppers[i];
		downcase[uppers[i]]=lowers[i];
	}
}

#ifdef EBCDIC
char *charnames[]={
  "nul","soh","stx","etx", "pf", "ht", "lc","del",
   0   , 0   ,"smm", "vt", "ff", "cr", "so", "si",
  "dle","dc1","dc2","dc3","res", "nl", "bs", "il",
  "can", "em", "cc", 0   ,"ifs","igs","irs","ius",
   "ds","sos", "fs", 0   ,"byp", "lf","eob","pre",
   0   , 0   , "sm", 0   , 0   ,"enq","ack","bel",
   0   , 0   ,"syn", 0   , "pn", "rs", "uc","eot",
   0   , 0   , 0   , 0   ,"dc4","nak", 0   ,"sub",
  "space",s_newline,"tab","backspace","return","page","null"};
char charnums[]=
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
char charnums[]=
"\000\001\002\003\004\005\006\007\
\010\011\012\013\014\015\016\017\
\020\021\022\023\024\025\026\027\
\030\031\032\033\034\035\036\037\
 \n\t\b\r\f\0\177";
#endif /* def ASCII */
char *isymnames[]={
				/* Special Forms */
  "and", "begin", "case", "cond", "define", "do", "if", "lambda",
  "let", "let*", "letrec", "or", "quote", "set!",
				/* IXSYMS go here */
  "quasiquote", "defined?", "delay",
				/* other keywords */
  "=>", "else", "unquote", "unquote-splicing", ".",
				/* Flags */
  "#f", "#t", "#<undefined>", "#<eof>", "()", "#<unspecified>"
  };

SCMPTR stack_start_ptr = 0;

static char	s_read_char[]="read-char", s_peek_char[]="peek-char";
char	s_read[]="read", s_write[]="write", s_newline[]="newline";
static char	s_display[]="display", s_write_char[]="write-char";

static char	s_eofin[]="end of file in ";
static char	s_unknown_sharp[]="unknown # object";

SCM lreadr(),lreadparen(),istring2number();
sizet read_token();

void intprint(n,radix,f)
long n;
int radix;
FILE *f;
{
  char num_buf[INTBUFLEN];
  lfwrite(num_buf,(sizet)1,iint2str(n,radix,num_buf),f);
}
#ifdef FLOATS
void floprint(exp,f)
     SCM exp;
     FILE *f;
{
  char num_buf[FLOBUFLEN];
  lfwrite(num_buf,(sizet)1,iflo2str(exp,num_buf),f);
}
#endif

void ipruk(hdr,ptr,f)
     char *hdr;
     SCM ptr;
     FILE *f;
{
  lputs("#<unknown-",f);
  lputs(hdr,f);
  if CELLP(ptr) {
    lputs(" (0x",f);
    intprint(CAR(ptr),16,f);
    lputs(" . 0x",f);
    intprint(CDR(ptr),16,f);
    lputs(") @",f);
  }
  lputs(" 0x",f);
  intprint(ptr,16,f);
  lputc('>',f);
}

void iprlist(hdr,exp,tlr,f,writing)
     char *hdr, tlr;
     SCM exp;
     FILE *f;
     int writing;
{
  lputs(hdr,f);
  /* CHECK_INTS; */
  iprin1(CAR(exp),f,writing);
  exp = CDR(exp);
  for(;NIMP(exp);exp=CDR(exp)) {
    if NECONSP(exp) break;
    lputc(' ',f);
    /* CHECK_INTS; */
    iprin1(CAR(exp),f,writing);
  }
  if NNULLP(exp) {
    lputs(" . ",f);
    iprin1(exp,f,writing);
  }
  lputc(tlr,f);
}
void iprin1(exp,f,writing)
SCM exp;
FILE *f;
int writing;
{
  register long i;
taloop:
  switch (7 & (int)exp) {
  case 2:
  case 6:
    intprint(INUM(exp),10,f);
    break;
  case 4:
    if ICHRP(exp) {
      i = ICHR(exp);
      if (writing) lputs("#\\",f);
      if (!writing) lputc((int)i,f);
      else if ((i<=' ') && charnames[i]) lputs(charnames[i],f);
#ifndef EBCDIC
      else if (i=='\177')
	lputs(charnames[(sizeof charnames/sizeof(char *))-1],f);
#endif /* ndef EBCDIC */
      else lputc((int)i,f);
    }
    else if (IFLAGP(exp) && (ISYMNUM(exp)<(sizeof isymnames/sizeof(char *))))
      lputs(ISYMCHARS(exp),f);
    else if ILOCP(exp) {
      lputs("#@",f);
      intprint((long)IFRAME(exp),10,f);
      lputc(ICDRP(exp)?'-':'+',f);
      intprint((long)IDIST(exp),10,f);
    }
    else goto idef;
    break;
  case 1:			/* gloc */
    lputs("#@",f);
    exp--;
    goto taloop;
  default:
  idef:
    ipruk("immediate",exp,f);
    break;
  case 0:
    switch TYP7(exp) {
    case tcs_cons_gloc:
    case tcs_cons_imcar:
    case tcs_cons_nimcar:
      iprlist("(",exp,')',f,writing);
      break;
    case tcs_closures:
      exp = CODE(exp);
      iprlist("#<CLOSURE ",exp,'>',f,writing);
      break;
    case tc7_string:
      if (writing) {
	lputc('\"',f);
	for(i=0;i<LENGTH(exp);++i) switch (CHARS(exp)[i]) {
	case '"':
	case '\\':
	  lputc('\\',f);
	default:
	  lputc(CHARS(exp)[i], f);
	}
	lputc('\"',f);
      }
      else
      dispstr:
	lfwrite(CHARS(exp),(sizet)1,(sizet)LENGTH(exp),f);
      break;
    case tc7_vector:
      lputs("#(",f);
      for(i=0;i<(LENGTH(exp)-1);++i) {
	/* CHECK_INTS; */
	iprin1(VELTS(exp)[i],f,writing);
	lputc(' ',f);
      }
      if (i<LENGTH(exp)) {
	/* CHECK_INTS; */
	iprin1(VELTS(exp)[i],f,writing);
      }
      lputc(')',f);
      break;
    case tcs_symbols:
      exp = NAMESTR(exp);
      goto dispstr;
    case tcs_subrs:
      lputs("#<primitive-procedure ",f);
      lputs(CHARS(SNAME(exp)),f);
      lputc('>',f);
      break;
    case tc7_contin:
      lputs("#<continuation ",f);
      intprint(LENGTH(exp),10,f);
      lputs(" @ ",f);
      intprint((long)CHARS(exp),16,f);
      lputc('>',f);
      break;
    case tc7_smob:
      switch TYP16(exp) {
      case tc16_port:
	lputs("#<",f);
	if (RDNG & CAR(exp))
	  lputs("input-",f);
	if (WRTNG & CAR(exp))
	  lputs("output-",f);
	lputs((PIP & CAR(exp))?"pipe ":"port ",f);
	if CLOSEDP(exp) lputs("closed",f);
	else intprint((long)fileno(STREAM(exp)),10,f);
	lputc('>',f);
	break;
      case tc16_promise:
	lputs("#<promise ",f);
	iprin1(CDR(exp),f,writing);
	lputc('>',f);
	break;
      case tc16_arbiter:
	lputs("#<arbiter ",f);
	if (CAR(exp) & (1L<<16)) lputs("locked ",f);
	iprin1(CDR(exp),f,writing);
	lputc('>',f);
	break;
#ifdef FLOATS
      case tc16_flo:
	floprint(exp,f);
	break;
#endif /* def FLOATS */
      default:
	goto cdef;
      }
      break;
    default:
    cdef:
      ipruk("type",exp,f);
    }
  }
}

SCM eof_objectp(x)
SCM x;
{
	return (EOF_VAL == x) ? BOOL_T : BOOL_F;
}

SCM lwrite(obj,port)
SCM obj,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_write);
	iprin1(obj,STREAM(port),1);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE == errno) close_pipe(port);
# endif
#endif
	return UNSPECIFIED;
}
SCM display(obj,port)
SCM obj,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_display);
	iprin1(obj,STREAM(port),0);
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE == errno) close_pipe(port);
# endif
#endif
	return UNSPECIFIED;
}
SCM newline(port)
SCM port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG1,s_newline);
	lputc('\n',STREAM(port));
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE == errno) close_pipe(port);
	else
# endif
#endif
	  if (port == cur_outp) fflush(STREAM(port));
	return UNSPECIFIED;
}
SCM write_char(chr,port)
SCM chr,port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG2,s_write_char);
	ASSERT(ICHRP(chr),chr,ARG1,s_write_char);
	lputc((int)ICHR(chr),STREAM(port));
#ifdef HAVE_PIPE
# ifdef EPIPE
	if (EPIPE == errno) close_pipe(port);
# endif
#endif
	return UNSPECIFIED;
}

FILE *trans = 0;
SCM trans_on(fil)
     SCM fil;
{
  transcript = open_file(fil, makfromstr("w", (sizet) 1));
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

void lputc(c,f)
     int c;
     FILE *f;
{
  SYSCALL(putc(c,f););
  if (trans && (f == STREAM(def_outp)))
    SYSCALL(putc(c,trans););
}
void lputs(s,f)
     char *s;
     FILE *f;
{
  SYSCALL(fputs(s,f););
  if (trans && (f == STREAM(def_outp)))
    SYSCALL(fputs(s,trans););
}
int lfwrite(ptr, size, nitems, stream)
     char *ptr;
     sizet size;
     sizet nitems;
     FILE *stream;
{
#ifdef vms
  sizet l = size * nitems;
  int i=0;
  for(;i < l;++i) lputc(ptr[i],stream);
  return l;
#else
  int ret;
  SYSCALL(ret = fwrite(ptr, size, nitems, stream););
  if (trans && (stream == STREAM(def_outp)))
    SYSCALL(fwrite(ptr, size, nitems, trans););
  return ret;
#endif
}

int ungetted = 0;
#ifdef vms			/* THIS CODE IS NO LONGER CORRECT */
int lgetc(f)
FILE *f;
{
	int c;
	long old_sig_deferred;
	DEFER_INTS;
	old_sig_deferred = sig_deferred;
	c = getc(f);
	if ((old_sig_deferred == 0) && sig_deferred && (f == stdin))
		while(c && (c != EOF)) c = getc(f);
	if (trans && (f == stdin))
	  SYSCALL(putc(c,trans););
	ALLOW_INTS;
	return c;
}
#else
int lgetc(f)
     FILE *f;
{
  int c;
  SYSCALL(c = getc(f););
  if (trans && (f == stdin)) {
    if (ungetted) ungetted = 0;
    else SYSCALL(putc(c,trans););
  }
  return c;
}
#endif /* def vms */
void lungetc(c,f)
     int c;
     FILE *f;
{
  if ((f == stdin) && trans) ungetted = 1;
  ungetc(c,f);
}

SCM read_char(port)
SCM port;
{
	int c;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_read_char);
	c = lgetc(STREAM(port));
	if (c == EOF) return EOF_VAL;
	return MAKICHR(c);
}
SCM peek_char(port)
SCM port;
{
	FILE *f;
	int c;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port), port,ARG1,s_peek_char);
	f = STREAM(port);
	SYSCALL(c = getc(f););
	if (c == EOF) return EOF_VAL;
	ungetc(c,f);
	return MAKICHR(c);
}

char *grow_tok_buf(tok_buf)
     SCM tok_buf;
{
  sizet len = LENGTH(tok_buf);
  len += len / 2;
  resizstr(tok_buf,MAKINUM(len));
  return CHARS(tok_buf);
}

int flush_ws(f,eoferr)
FILE *f;
char *eoferr;
{
	register int c;
	while(1) switch (c = lgetc(f)) {
	case EOF:
goteof:
		if (eoferr) wta(UNDEFINED,s_eofin,eoferr);
		return c;
	case ';':
lp:
		switch (c = lgetc(f)) {
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
	FILE *f;
	int c;
	if UNBNDP(port) port = cur_inp;
	else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG1,s_read);
	f = STREAM(port);
	c = flush_ws(f,(char *)NULL);
	if (c == EOF) return EOF_VAL;
	lungetc(c,f);
	{
	  SCM tok_buf = makstr(30L);
	  return lreadr(tok_buf,f);
	}
}
SCM lreadr(tok_buf,f)
SCM tok_buf;
FILE *f;
{
	int c;
	sizet j;
	SCM p;
tryagain:
	c = flush_ws(f,s_read);
	switch (c) {
	case '(':
		return lreadparen(tok_buf,f,s_list);
	case ')':
		warn("unexpected \")\"","");
		goto tryagain;
	case '\'':
		return cons2(I_QUOTE,lreadr(tok_buf,f),EOL);
	case '`':
		return cons2(I_QUASIQUOTE,lreadr(tok_buf,f),EOL);
	case ',':
		c = lgetc(f);
		if (c == '@') p = I_UQ_SPLICING;
		else {
			lungetc(c,f);
			p = I_UNQUOTE;
		}
		return cons2(p,lreadr(tok_buf,f),EOL);
	case '#':
		c = lgetc(f);
		switch (c) {
		case '(':
			return vector(lreadparen(tok_buf,f,s_vector));
		case 't':
		case 'T':
			return BOOL_T;
		case 'f':
		case 'F':
			return BOOL_F;
		case 'b':
		case 'B':
		case 'o':
		case 'O':
		case 'd':
		case 'D':
		case 'x':
		case 'X':
		case 'i':
		case 'I':
		case 'e':
		case 'E':
			lungetc(c,f);
			c = '#';
			goto num;
		case '\\':
			c = lgetc(f);
			j = read_token(c,tok_buf,f);
			if (j==1) return MAKICHR(c);
			for (c=0;c<sizeof charnames/sizeof(char *);c++)
				if (charnames[c] &&
				    (0==strcmp(charnames[c],CHARS(tok_buf))))
				  return MAKICHR(charnums[c]);
			wta(UNDEFINED,"unknown # object: #\\",CHARS(tok_buf));
		case '|':
			j = 1;	/* here j is the comment nesting depth */
lp:
			c = lgetc(f);
lpc:
			switch (c) {
			case EOF:
			  wta(UNDEFINED,s_eofin,"balanced comment");
			case LINE_INCREMENTORS:
			  linum++;
			default:
			  goto lp;
			case '|':
			  if ('#' != (c = lgetc(f))) goto lpc;
			  if (--j) goto lp;
			  break;
			case '#':
			  if ('|' != (c = lgetc(f))) goto lpc;
			  ++j; goto lp;
			}
			goto tryagain;
		case '.':
			p = lreadr(tok_buf,f);
			return EVAL(p,EOL);
		default:
			wta(MAKICHR(c),s_unknown_sharp,"");
		}
	case '\"':
		j = 0;
		while ((c = lgetc(f)) != '\"') {
			ASSERT(c != EOF,UNDEFINED,s_eofin,s_string);
			if (j+1 >= LENGTH(tok_buf)) grow_tok_buf(tok_buf);
			if (c == '\\') c = lgetc(f);
			CHARS(tok_buf)[j] = c;
			++j;
		}
		if (j == 0) return nullstr;
		CHARS(tok_buf)[j] = 0;
		return makfromstr(CHARS(tok_buf),j);
	case DIGITS:
	case '.': case '-': case '+':
num:
		j = read_token(c,tok_buf,f);
		p = istring2number(CHARS(tok_buf), (long)j, 10L);
		if (p != BOOL_F) return p;
		ASSERT(c != '#',UNDEFINED,s_unknown_sharp,CHARS(tok_buf));
		goto tok;
	default:
		j = read_token(c,tok_buf,f);
tok:
		return intern(CHARS(tok_buf),j);
	}
}
sizet read_token(ic,tok_buf,f)
int ic;
SCM tok_buf;
FILE *f;
{
	register sizet j = 1;
	register int c = ic;
	register char *p = CHARS(tok_buf);
	p[0] = downcase[c];
	while(1) {
		if (j+1 >= LENGTH(tok_buf)) p = grow_tok_buf(tok_buf);
		switch (c = lgetc(f)) {
		case '(': case ')': case '\"': case ';':
		case WHITE_SPACES:
getout:
			lungetc(c,f);
		case EOF:
			p[j] = 0;
			return j;
		case LINE_INCREMENTORS:
			linum++;
			goto getout;
		default:
			p[j++] = downcase[c];
		}
	}
}
SCM lreadparen(tok_buf,f,name)
SCM tok_buf;
FILE *f;
char *name;
{
	SCM tmp;
	int c;
	c = flush_ws(f,name);
	if (c == ')') return EOL;
	lungetc(c,f);
	tmp = lreadr(tok_buf,f);
	if (tmp != I_DOT) return cons(tmp,lreadparen(tok_buf,f,name));
	tmp = lreadr(tok_buf,f);
	c = flush_ws(f,name);
	if (c != ')') wta(UNDEFINED,"missing close paren","");
	return tmp;
}
#ifdef IO_EXTENSIONS
static char	s_file_position[]="file-position",
		s_file_set_pos[]="file-set-position";
static char	s_flush[]="force-output",
		s_read_to_str[]="read-string!";
SCM file_position(port)
SCM port;
{
	ASSERT(NIMP(port) && OPPORTP(port), port,ARG1,s_file_position);
	SYSCALL(port = MAKINUM(ftell(STREAM(port))););
	return port;
}
SCM file_set_position(port, pos)
SCM port, pos;
{
	ASSERT(NIMP(port) && OPPORTP(port), port,ARG1,s_file_set_pos);
	SYSCALL(port = (fseek(STREAM(port),INUM(pos),0)) ? BOOL_F : BOOL_T;);
#ifdef HAVE_PIPE
# ifdef ESPIPE
	ASSERT(ESPIPE != errno, port, ARG1, s_file_set_pos);
# endif
#endif
	return port;
}
SCM lflush(port)
SCM port;
{
	if UNBNDP(port) port = cur_outp;
	else ASSERT(NIMP(port) && OPOUTPORTP(port),port,ARG1,s_flush);
	SYSCALL(fflush(STREAM(port)););
	return UNSPECIFIED;
}
SCM read_to_string(str,port)
SCM str,port;
{
  if UNBNDP(port) port = cur_inp;
  else ASSERT(NIMP(port) && OPINPORTP(port),port,ARG2,s_read_to_str);
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_read_to_str);
  SYSCALL(str = MAKINUM(fread(CHARS(str),(sizet)1,
			      (sizet)LENGTH(str),STREAM(port))););
  return str;
}
#endif /* def IO_EXTENSIONS */

/* These procedures implement synchronization primitives.  Processors
   with an atomic test-and-set instruction can use it here (and not
   DEFER_INTS). */
char s_tryarb[]="try-arbiter";
char s_relarb[]="release-arbiter";
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

SCM sym_features=EOL;
static char s_tryload[]="try-load";
#define s_load (&s_tryload[4])

char *features[] = {
#ifdef IO_EXTENSIONS
# ifdef HAVE_PIPE
  "pipe",
# endif
  "i/o-extensions",
#endif
#ifdef REV2_PROCEDURES
  "rev2-procedures",
#endif
#ifndef CHEAP_CONTINUATIONS
  "full-continuation",
#endif
#ifdef RECKLESS
  "reckless",
#endif
#ifdef vms
  "ed",
#endif
  0};

void init_features()
{
  char **feats = features;
  sym_features = sysintern("*features*");
  VCELL(sym_features) = EOL;
  for(;*feats;feats++) {
      VCELL(sym_features) =
      cons(sysintern(*feats),
	   VCELL(sym_features));
  }    
}

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

jmp_buf errjmp;
int errjmp_ok = 0, ints_disabled = 1, sig_deferred = 0, alrm_deferred;
SCM err_exp,err_env;
char *err_pos, *err_s_subr;
SCM sym_errobj = BOOL_F;
SCM sym_loadpath = BOOL_F;
long linum = 1;
int verbose = 0;
long cells_allocated = 0, rt = 0, gc_rt, gc_time_taken;
long gc_cells_collected, gc_malloc_collected, gc_ports_collected;
void def_err_response();

int handle_it(i)
     int i;
{
  char *name = errmsgs[i-WNA].s_response;
  SCM proc;
  if (name) {
    proc = VCELL(intern(name,strlen(name)));
    if NIMP(proc) {
      apply(proc,EOL,EOL);
      return i;
    }
  }
  return errmsgs[i-WNA].parent_err;
}

SCM repl_driver(argc,argv)
int argc;
char **argv;
{
  long i;
  stack_start_ptr = &i;
  i=setjmp(errjmp);
 drloop:
  switch ((int)i) {
  default:
    {
      char *name = errmsgs[i-WNA].s_response;
      if (name) {
	SCM proc = VCELL(intern(name,strlen(name)));
	if NIMP(proc) apply(proc,EOL,EOL);
      }
      if (i=errmsgs[i-WNA].parent_err) goto drloop;
      def_err_response();
      goto reset_toplvl;
    }
  case 0:
    errjmp_ok = 1;
    errno = 0;
    alrm_deferred = 0;
    sig_deferred = 0;
    ints_disabled = 0;
    progargs = EOL;
    while (argc--)
      progargs = cons(makfromstr(argv[argc], strlen(argv[argc])), progargs);
    {
#ifdef nosve
      char *init_path= INIT_PATH ;
      SCM name = makfromstr(init_path, (sizet) (strlen(init_path)));
#else
      SCM name = lgetenv(makfromstr("SCM_INIT_PATH",
				    (sizet) (sizeof "SCM_INIT_PATH"-1)));
      if FALSEP(name)
# ifdef IMPLINIT
	name = makfromstr(IMPLINIT, (sizet) (sizeof IMPLINIT-1));
# else
      goto noname;
# endif /* IMPLINIT */
#endif /* nosve */
      if (BOOL_T != tryload(name))
      noname:
	wta(name,"Could not open file",s_load);
    }
  case -2:
  reset_toplvl:
    errjmp_ok = 1;
    alrm_deferred = 0;
    sig_deferred = 0;
    ints_disabled = 0;
    VCELL(sym_loadpath) = BOOL_F;
    repl();
    err_pos = (char *)EXIT;
    i= EXIT;
    goto drloop;		/* encountered EOF on stdin */
  case -1:
    return throwval;
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
  if (verbose>1)
    {
      lputs("; grew ",STREAM(def_outp));
      lputs(obj,STREAM(def_outp));
      lputs(" to ",STREAM(def_outp));
      intprint(size,10,STREAM(def_outp));
      lputc(' ',STREAM(def_outp));
      lputs(units,STREAM(def_outp));
      if ((verbose>3) && (obj==s_heap)) {
	sizet i=0;
	lputs("; heap segments:",STREAM(def_outp));
	while(i<hplim_ind) {
	  lputs("\n; 0x",STREAM(def_outp));
	  intprint(hplims[i++],16,STREAM(def_outp));
	  lputs(" - 0x",STREAM(def_outp));
	  intprint(hplims[i++],16,STREAM(def_outp));
	}
	lputs("\n",STREAM(def_outp));
      }
    }
}

void gc_start()
{
  if (verbose>2) lputs(";GC ",STREAM(def_outp));
  fflush(STREAM(def_outp));
  gc_rt = INUM(my_time());
  gc_cells_collected = 0;
  gc_malloc_collected = 0;
  gc_ports_collected = 0;
}
void gc_end()
{
  gc_rt = INUM(my_time()) - gc_rt;
  gc_time_taken = gc_time_taken + gc_rt;
  if (verbose>2) {
    intprint(time_in_msec(gc_rt),10,STREAM(def_outp));
    lputs(" cpu mSec, ",STREAM(def_outp));
    intprint(gc_cells_collected,10,STREAM(def_outp));
    lputs(" cells, ",STREAM(def_outp));
    intprint(gc_malloc_collected,10,STREAM(def_outp));
    lputs(" malloc, ",STREAM(def_outp));
    intprint(gc_ports_collected,10,STREAM(def_outp));
    lputs(" ports collected\n",STREAM(def_outp));
    fflush(STREAM(def_outp));
  }
}
void repl_report()
{
  if (verbose) {
    lputs(";Evaluation took ",STREAM(def_outp));
    intprint(time_in_msec(INUM(my_time())-rt),10,STREAM(def_outp));
    lputs(" mSec (",STREAM(def_outp));
    intprint(time_in_msec(gc_time_taken),10,STREAM(def_outp));
    lputs(" in gc) ",STREAM(def_outp));
    intprint(cells_allocated,10,STREAM(def_outp));
    lputs(" cons work\n",STREAM(def_outp));
  }
}

SCM prolixity(arg)
SCM arg;
{
  int old = verbose;
  if (!UNBNDP(arg)) {
    if FALSEP(arg) verbose = 0;
    else verbose = INUM(arg);
  }
  return MAKINUM(old);
}

void repl()
{
  SCM x;
  while(1) {
    lputs("> ",STREAM(def_outp));
    fflush(STREAM(def_outp));
    cur_inp = def_inp;
    cur_outp = def_outp;
    x = lread(def_inp);
    if (x == EOF_VAL) break;
    if (trans && !ungetted)
      lungetc(lgetc(stdin),stdin); /* assure newline out */
    rt = INUM(my_time());
    cells_allocated = 0;
    gc_time_taken = 0;
    x = EVAL(x,EOL);
    repl_report();
    iprin1(x,STREAM(def_outp),1);
    lputc('\n',STREAM(def_outp));
  }
}
SCM quit(n)
SCM n;
{
  if UNBNDP(n) n=INUM0;
  throwval = n;
  longjmp(errjmp,-1);
}
void han_sig()
{
  sig_deferred=0;
  if (handle_it(INT_SIGNAL) != INT_SIGNAL)
    wta(UNDEFINED,(char *)INT_SIGNAL,"");
}
void han_alrm()
{
  alrm_deferred = 0;
  if (handle_it(ALRM_SIGNAL) != ALRM_SIGNAL)
    wta(UNDEFINED,(char *)ALRM_SIGNAL,"");
}
SCM abrt()
{
  longjmp(errjmp,-2);
}

SCM tryload(filename)
SCM filename;
{
  ASSERT(NIMP(filename) && STRINGP(filename),filename,ARG1,s_load);
  {
    SCM oloadpath = VCELL(sym_loadpath);
    long olninum = linum;
    SCM form,port;
    port = open_file(filename, makfromstr("r", (sizet) 1));
    if FALSEP(port) return port;
    VCELL(sym_loadpath) = filename;
    linum = 1;
    while(1) {
      form = lread(port);
      if (EOF_VAL == form) break;
      SIDEVAL(form,EOL);
    }
    close_port(port);
    linum = olninum;
    VCELL(sym_loadpath) = oloadpath;
  }
  return BOOL_T;
}

void err_head(str)
char *str;
{
  lputc('\n',STREAM(def_outp));
  if(BOOL_F != VCELL(sym_loadpath)) {
    iprin1(VCELL(sym_loadpath),STREAM(def_outp),1);
    lputs(", line ",STREAM(def_outp));
    intprint((long)linum,10,STREAM(def_outp));
    lputs(": ",STREAM(def_outp));
  }
  fflush(STREAM(def_outp));
  if (errno>0) perror(str);
  fflush(stderr);
}
void warn(str1,str2)
char *str1,*str2;
{
  err_head("WARNING");
  lputs("WARNING: ",STREAM(def_outp));
  lputs(str1,STREAM(def_outp));
  lputs(str2,STREAM(def_outp));
  lputc('\n',STREAM(def_outp));
  fflush(STREAM(def_outp));
}

SCM seterrno(arg)
SCM arg;
{
  errno = INUM(arg);
  return UNSPECIFIED;
}
static char s_perror[]="perror";
SCM lperror(arg)
SCM arg;
{
  ASSERT(NIMP(arg) && STRINGP(arg),arg,ARG1,s_perror);
  err_head(CHARS(arg));
  return UNSPECIFIED;
}
extern cell dummy_cell;
void def_err_response()
{
  SCM obj = VCELL(sym_errobj);
  DEFER_INTS;
  err_head("ERROR");
  lputs("ERROR: ",STREAM(def_outp));
  if (err_s_subr && *err_s_subr) {
    lputs(err_s_subr,STREAM(def_outp));
    lputs(": ",STREAM(def_outp));
  }
#ifdef nosve
  if ((~0x1fL) & (short)err_pos) lputs(err_pos,STREAM(def_outp));
  else if (WNA>(short)err_pos) {
    lputs("Wrong type in arg",STREAM(def_outp));
    lputc('0'+(short)err_pos,STREAM(def_outp));
  }
#else
  if ((~0x1fL) & (long)err_pos) lputs(err_pos,STREAM(def_outp));
  else if (WNA>(long)err_pos) {
    lputs("Wrong type in arg",STREAM(def_outp));
    lputc('0'+(int)err_pos,STREAM(def_outp));
  }
#endif
  else {
    lputs(errmsgs[((int)err_pos)-WNA].msg,STREAM(def_outp));
    goto outobj;
  }
  if (IMP(obj) || SYMBOLP(obj)) {
outobj:
    if (!UNBNDP(obj)) {
      lputs(((long)err_pos == WNA)?" to ":" ",STREAM(def_outp));
      iprin1(obj,STREAM(def_outp),1);
    }
  }
  else lputs(" (see errobj)",STREAM(def_outp));
  if UNBNDP(err_exp) goto getout;
  if NIMP(err_exp) {
    lputs("\n; in expression: ",STREAM(def_outp));
    if (err_exp == (SCM)&dummy_cell) iprin1(CAR(err_exp),STREAM(def_outp),1);
    else if ECONSP(err_exp)
      iprlist("(... ",err_exp,')',STREAM(def_outp),1);
    else iprin1(err_exp,STREAM(def_outp),1);
  }
  if NULLP(err_env) lputs("\n; in top level environment.",STREAM(def_outp));
  else {
    SCM env=err_env;
    lputs("\n; in scope:",STREAM(def_outp));
    while NNULLP(env) {
      lputc('\n',STREAM(def_outp));
      lputs(";   ",STREAM(def_outp));
      iprin1(CAR(CAR(env)),STREAM(def_outp),1);
      env = CDR(env);
    }
  }
 getout:
  lputc('\n',STREAM(def_outp));
  fflush(STREAM(def_outp));
  err_exp = err_env = UNDEFINED;
  if (!errjmp_ok) {
    iprin1(obj,STREAM(def_outp),1);
    lputs("\nFATAL ERROR DURING CRITICAL CODE SECTION\n",STREAM(def_outp));
    quit(MAKINUM(errno?(long)errno:1L));
  }
  errno=0;
  ALLOW_INTS;
}
void everr(exp,env,arg,pos,s_subr)
SCM exp,env,arg;
char *pos, *s_subr;
{
  err_exp=exp;
  err_env=env;
  VCELL(sym_errobj)=arg;
  err_pos=pos;
  err_s_subr=s_subr;
  if (((~0x1fL) & (long)pos) || (WNA>(long)pos)) {
    def_err_response();
    abrt();
  }
  longjmp(errjmp,(int)pos);
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
char s_set_cur_inp[]="set-current-input-port";
char s_set_cur_outp[]="set-current-output-port";
SCM set_cur_inp(port)
     SCM port;
{
  SCM oinp = cur_inp;
  ASSERT(NIMP(port) && OPINPORTP(port), port,ARG1,s_set_cur_inp);
  cur_inp = port;
  return oinp;
}
SCM set_cur_outp(port)
     SCM port;
{
  SCM ooutp = cur_outp;
  ASSERT(NIMP(port) && OPOUTPORTP(port), port,ARG1,s_set_cur_outp);
  cur_outp = port;
  return ooutp;
}

static iproc subr0s[]={
	{&s_set_cur_inp[4],cur_input_port},
	{&s_set_cur_outp[4],cur_output_port},
	{"transcript-off",trans_off},
	{"program-arguments",prog_args},
	{"line-number",line_num},
	{"abort",abrt},
	{0,0}};

static iproc subr1s[]={
	{s_set_cur_inp,set_cur_inp},
	{s_set_cur_outp,set_cur_outp},
#ifdef IO_EXTENSIONS
	{s_file_position,file_position},
#endif
	{"transcript-on",trans_on},
	{s_load,tryload},
	{s_tryload,tryload},
	{"set-errno!",seterrno},
	{s_perror,lperror},
	{"make-arbiter", makarb},
	{s_tryarb, tryarb},
	{s_relarb, relarb},
	{0,0}};

static iproc subr1os[]={
	{s_read,lread},
	{s_read_char,read_char},
	{s_peek_char,peek_char},
	{s_newline,newline},
#ifdef IO_EXTENSIONS
	{s_flush,lflush},
#endif /* def IO_EXTENSIONS */
	{"quit",quit},
	{"verbose",prolixity},
	{0,0}};

static iproc subr2os[]={
	{s_write,lwrite},
	{s_display,display},
	{s_write_char,write_char},
#ifdef IO_EXTENSIONS
	{s_file_set_pos,file_set_position},
	{s_read_to_str,read_to_string},
#endif /* def IO_EXTENSIONS */
	{0,0}};

SCM sym_char_code_limit;
void init_repl()
{
	sym_char_code_limit = sysintern("char-code-limit");
	VCELL(sym_char_code_limit) = MAKINUM(CHAR_CODE_LIMIT);
	sym_errobj=sysintern("errobj");
	VCELL(sym_errobj)=UNDEFINED;
	sym_loadpath=sysintern("*load-pathname*");
	VCELL(sym_loadpath)=BOOL_F;
	transcript = BOOL_F;
	init_iprocs(subr0s, tc7_subr_0);
	init_iprocs(subr1os, tc7_subr_1o);
	init_iprocs(subr1s, tc7_subr_1);
	init_iprocs(subr2os, tc7_subr_2o);
}
