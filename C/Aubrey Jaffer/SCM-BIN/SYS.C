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
#include <ctype.h>
#define IN_SYS
#include "scm.h"

#ifdef vms
# ifndef CHEAP_CONTINUATIONS
#  include "setjump.h"
# else
#  include <setjmp.h>
# endif /* ndef CHEAP_CONTINUATIONS */
#else
# include <setjmp.h>
#endif /* def vms */

#define NEWCELL(_into) {if IMP(freelist) _into = gc_for_newcell();\
	else {_into = freelist;freelist = CDR(freelist);++cells_allocated;}}

char	s_make_vector[]="make-vector";
char	s_nogrow[]="could not grow", s_heap[]="heap", s_hplims[]="hplims";
void grow_throw(), gc_mark(), mark_locations(), gc_sweep();
static char	s_input_portp[]="input-port?", s_output_portp[]="output-port?";
static char	s_close_port[]="close-port";
static char	s_open_file[]="open-file";
SCM open_file(filename, modes)
SCM filename, modes;
{
	FILE *f;
	register SCM z;
	ASSERT(NIMP(filename) && STRINGP(filename),
	       filename,ARG1,s_open_file);
	ASSERT(NIMP(modes) && STRINGP(modes),
	       modes,ARG1,s_open_file);
	NEWCELL(z);
	DEFER_INTS;
	SYSCALL(f = fopen(CHARS(filename),CHARS(modes)););
	if (!f) z = BOOL_F;
	else {
	  SETLENGTH(z,0L,(((strchr(CHARS(modes),'r') ||
			    strchr(CHARS(modes),'+') )?tc_inport:0) |
			  ((strchr(CHARS(modes),'w') ||
			    strchr(CHARS(modes),'a') ||
			    strchr(CHARS(modes),'+') )?tc_outport:0)));
	  SETSTREAM(z,f);
	}
	ALLOW_INTS;
	return z;
}
#ifdef IO_EXTENSIONS
#ifdef HAVE_PIPE
FILE *popen();
static char	s_op_pipe[]="open-pipe";
static char	s_cls_pipe[]="close-pipe";
SCM open_pipe(pipestr,modes)
SCM pipestr,modes;
{
	FILE *f;
	register SCM z;
	ASSERT(NIMP(pipestr) && STRINGP(pipestr),pipestr,ARG1,s_op_pipe);
	ASSERT(NIMP(modes) && STRINGP(modes),modes,ARG1,s_op_pipe);
	NEWCELL(z);
	/* DEFER_INTS, SYSCALL, and ALLOW_INTS are probably paranoid here*/
	DEFER_INTS;
	ignore_signals();
	SYSCALL(f = popen(CHARS(pipestr),CHARS(modes)););
	unignore_signals();
	if (!f) z = BOOL_F;
	else {
	  SETLENGTH(z,0L,strchr(CHARS(modes),'r')?tc_inpipe:tc_outpipe);
	  SETSTREAM(z,f);
	}
	init_signals();
	ALLOW_INTS;
	return z;
}
SCM close_pipe(f)
SCM f;
{
	int ans;
	ASSERT(NIMP(f) && PIPEP(f),f,ARG1,s_cls_pipe);
	if CLOSEDP(f) return UNSPECIFIED;
	DEFER_INTS;
	SYSCALL(ans = pclose(STREAM(f)););
	SETSTREAM(f,0);
	CAR(f) &= ~OPN;
	ALLOW_INTS;
	return MAKINUM(ans);
}
#endif /* HAVE_PIPE */
#endif /* def IO_EXTENSIONS */

SCM close_port(f)
SCM f;
{
	ASSERT(NIMP(f) && PORTP(f),f,ARG1,s_close_port);
	if CLOSEDP(f) return UNSPECIFIED;
	DEFER_INTS;
	SYSCALL(fclose(STREAM(f)););
	SETSTREAM(f,0);
	CAR(f) &= ~OPN;
	ALLOW_INTS;
	return UNSPECIFIED;
}
SCM input_portp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return INPORTP(x) ? BOOL_T : BOOL_F;
}
SCM output_portp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return OUTPORTP(x) ? BOOL_T : BOOL_F;
}

#if (__TURBOC__==1)
# undef L_tmpnam		/* Not supported in TURBOC V1.0 */
#endif
#ifdef GNUDOS
# undef L_tmpnam
#endif

#ifdef L_tmpnam
SCM ltmpnam()
{
  char *name;
  SYSCALL(name = tmpnam(NULL););
  if (name)
    return makfromstr(name, strlen(name));
  return BOOL_F;
}
#else
char template[]=TEMPTEMPLATE;
# define TEMPLEN (sizeof template - 1)
SCM ltmpnam()
{
  SCM name;
  int temppos=TEMPLEN-9;
  name = makfromstr(template,(sizet)TEMPLEN);
  DEFER_INTS;
inclp:
  template[temppos]++;
  if (!isalpha(template[temppos])) {
    template[temppos++]='a';
    goto inclp;
  }
# ifndef AMIGA
#  ifndef __MSDOS__
  SYSCALL(temppos = !mktemp(CHARS(name)););
  if (temppos) name = BOOL_F;
#  endif
# endif
  ALLOW_INTS;
  return name;
}
#endif /* L_tmpnam */

#ifdef IO_EXTENSIONS
#ifndef THINK_C
static char s_chdir[]="chdir";
SCM lchdir(str)
     SCM str;
{
  ASSERT(NIMP(str) && STRINGP(str), str, ARG1, s_chdir);
  SYSCALL(str = chdir(CHARS(str)););
  return (str) ? BOOL_F : BOOL_T;
}
#endif
static char s_del_fil[]="delete-file";
SCM del_fil(str)
     SCM str;
{
  SCM ans;
  ASSERT(NIMP(str) && STRINGP(str), str, ARG1, s_del_fil);
#ifdef STDC_HEADERS
  SYSCALL(ans = (remove(CHARS(str))) ? BOOL_F : BOOL_T;);
#else
  SYSCALL(ans = (unlink(CHARS(str))) ? BOOL_F : BOOL_T;);
#endif
  return ans;
}
static char s_ren_fil[]="rename-file";
SCM ren_fil(oldname, newname)
     SCM oldname, newname;
{
  SCM ans;
  ASSERT(NIMP(oldname) && STRINGP(oldname), oldname, ARG1, s_ren_fil);
  ASSERT(NIMP(newname) && STRINGP(newname), newname, ARG2, s_ren_fil);
#ifdef STDC_HEADERS
  SYSCALL(ans = (rename(CHARS(oldname), CHARS(newname))) ? BOOL_F: BOOL_T;);
  return ans;
#else
  DEFER_INTS;
  SYSCALL(ans = link(CHARS(oldname),CHARS(newname)) ? BOOL_F : BOOL_T;);
  if (!FALSEP(ans)) {
    SYSCALL(ans = unlink(CHARS(oldname)) ? BOOL_F : BOOL_T;);
    if FALSEP(ans)
      SYSCALL(unlink(CHARS(newname));); /* unlink failed.  remove new name */
  }
  ALLOW_INTS;
  return ans;
#endif
}
#endif
extern SCM obhash(), obunhash();
static char s_obunhash[]="object-unhash";
static iproc subr0s[]={
	{"gc",gc},
	{"tmpnam",ltmpnam},
	{0,0}};

static iproc subr1s[]={
	{"call-with-current-continuation",call_cc},
	{s_input_portp,input_portp},
	{s_output_portp,output_portp},
	{s_close_port,close_port},
	{"eof-object?",eof_objectp},
#ifdef IO_EXTENSIONS
# ifdef HAVE_PIPE
	{s_cls_pipe,close_pipe},
# endif
# ifndef THINK_C
	{s_chdir,lchdir},
# endif
	{s_del_fil, del_fil},
#endif /* def IO_EXTENSIONS */
	{"object-hash",obhash},
	{s_obunhash,obunhash},
	{0,0}};

static iproc subr2s[]={
	{s_open_file,open_file},
#ifdef IO_EXTENSIONS
# ifdef HAVE_PIPE
	{s_op_pipe,open_pipe},
# endif
	{s_ren_fil, ren_fil},
#endif /* def IO_EXTENSIONS */
	{0,0}};

void init_io(){
  init_iprocs(subr0s, tc7_subr_0);
  init_iprocs(subr1s, tc7_subr_1);
  init_iprocs(subr2s, tc7_subr_2);
}

int expmem = 0;
sizet hplim_ind = 0;
long heap_size = 0;
CELLPTR *hplims, heap_org;
SCM freelist = EOL;

char *must_malloc(len,what)
long len;
char *what;
{
	char *ptr;
	sizet size = len;
	if (len != size)
malerr:
		wta(MAKINUM(len),(char *)NALLOC,what);
	SYSCALL(ptr = malloc(size););
	if (ptr != NULL) return ptr;
	gc();
	SYSCALL(ptr = malloc(size););
	if (ptr != NULL) return ptr;
	goto malerr;
}

int symhash_dim = NUM_HASH_BUCKETS;

void init_isyms()
{
	int hash,i = NUM_ISYMS,n = symhash_dim;
	char *cname,c;
	while (0 <= --i) {
		hash = 0;
		cname = isymnames[i];
		while(c = *cname++) hash = ((hash * 17) ^ c) % n;
		VELTS(symhash)[hash] =
			cons((i<14)?MAKSPCSYM(i):MAKISYM(i),
			     VELTS(symhash)[hash]);
	}
}
/* if length is negative, use the given string directly if possible */
SCM intern(name,len)
unsigned char *name;
sizet len;
{
  SCM lsym;
  register sizet i = len;
  register unsigned char *tmp = name;
  register unsigned int hash = 0, n = symhash_dim;
  while(i--) hash = ((hash * 17) ^ *tmp++) % n;
  for(lsym=VELTS(symhash)[hash];NIMP(lsym);lsym=CDR(lsym)) {
    if ISYMP(CAR(lsym)) {
      tmp = (unsigned char *)ISYMCHARS(CAR(lsym));
      for(i = 0;i < len;i++) {
	if (tmp[i] == 0) goto trynext;
	if (name[i] != tmp[i]) goto trynext;
      }
      if (tmp[i] == 0) return CAR(lsym);
    }
    else {
      tmp = (unsigned char *)CHARS(NAMESTR(CAR(lsym)));
      if (len != LENGTH(NAMESTR(CAR(lsym)))) goto trynext;
      for(i = len;i--;)
	if (name[i] != tmp[i]) goto trynext;
      return CAR(lsym);
    }
  trynext: ;
  }
  lsym = makfromstr(name, len);
  {
    SCM z = lsym;
    NEWCELL(lsym);
    DEFER_INTS;
    VCELL(lsym) = UNDEFINED;
    SETNAMESTR(lsym,z);
    VELTS(symhash)[hash] = cons(lsym,VELTS(symhash)[hash]);
    ALLOW_INTS;
  }
  return lsym;
}
SCM sysintern(name)
unsigned char *name;
{
	SCM lsym;
	sizet len = strlen((char *) name);
	register sizet i = len;
	register unsigned char *tmp = name;
	register unsigned int hash = 0, n = symhash_dim;
	while(i--) hash = ((hash * 17) ^ *tmp++) % n;
	NEWCELL(lsym);
	SETLENGTH(lsym,(long)len,tc7_string);
	SETCHARS(lsym,name);
	{
		SCM z = lsym;
		NEWCELL(lsym);
		VCELL(lsym) = UNDEFINED;
		SETNAMESTR(lsym,z);
	}
	VELTS(symhash)[hash] = cons(lsym,VELTS(symhash)[hash]);
	return lsym;
}
SCM cons(x,y)
SCM x,y;
{
	register SCM z;
	NEWCELL(z);
	CAR(z) = x;
	CDR(z) = y;
	return z;
}
SCM cons2(w,x,y)
SCM w,x,y;
{
	register SCM z;
	NEWCELL(z);
	CAR(z) = x;
	CDR(z) = y;
	x = z;
	NEWCELL(z);
	CAR(z) = w;
	CDR(z) = x;
	return z;
}
SCM cons2r(w,x,y)
SCM w,x,y;
{
	register SCM z;
	NEWCELL(z);
	CAR(z) = w;
	CDR(z) = x;
	x = z;
	NEWCELL(z);
	CAR(z) = x;
	CDR(z) = y;
	return z;
}

SCM makstr(len)
long len;
{
	SCM s;
	NEWCELL(s);
	DEFER_INTS;
	SETLENGTH(s,len,tc7_string);
	SETCHARS(s,must_malloc(len+1,s_string));
	ALLOW_INTS;
	CHARS(s)[len] = 0;
	return s;
}
SCM makfromstr(src, len)
char *src;
sizet len;
{
	SCM s;
	register char *dst;
	s = makstr((long)len);
	dst = CHARS(s);
	while (len--) *dst++ = *src++;
	return s;
}
char s_resizstr[]="string-set-length!";
SCM resizstr(str, len)
     SCM str, len;
{
  char *tmp;
  sizet l = INUM(len);
  ASSERT(NIMP(str) && STRINGP(str) && (str != nullstr),str,ARG1,s_resizstr);
  ASSERT(INUMP(len) && (len == MAKINUM(l)),len,ARG2,s_resizstr);
  DEFER_INTS;
  SYSCALL(tmp = realloc(CHARS(str),l+1););
  if (tmp) {
    SETCHARS(str,tmp);
    SETLENGTH(str,l,tc7_string);
  }
  ALLOW_INTS;
  if (!tmp)
    wta(len,(char *)NALLOC,s_resizstr);
  return UNSPECIFIED;
}
char s_resizvect[]="vector-set-length!";
SCM resizvect(vect, len)
     SCM vect, len;
{
  char *tmp;
  sizet oldl;
  sizet l = INUM(len)*sizeof(SCM);
  ASSERT(NIMP(vect) && VECTORP(vect) && (vect != nullvect),
	 vect,ARG1,s_resizvect);
  ASSERT(INUMP(len) && (len == MAKINUM(l/sizeof(SCM))),len,ARG2,s_resizvect);
  oldl = LENGTH(vect);
  DEFER_INTS;
  SYSCALL(tmp = realloc(CHARS(vect),l););
  if (tmp) {
    SETCHARS(vect,tmp);
    SETLENGTH(vect,INUM(len),tc7_vector);
  }
  for(l=INUM(len);l > oldl;) VELTS(vect)[--l]=UNSPECIFIED;
  ALLOW_INTS;
  if (!tmp)
    wta(len,(char *)NALLOC,s_resizvect);
  return UNSPECIFIED;
}
SCM make_vector(k,fill)
SCM k,fill;
{
	SCM v;
	register long i;
	register SCM *velts;
	ASSERT(INUMP(k),k,ARG1,s_make_vector);
	i = INUM(k);
	if (i == 0) return nullvect;
	NEWCELL(v);
	DEFER_INTS;
	SETLENGTH(v,i,tc7_vector);
	SETCHARS(v,must_malloc(i*sizeof(SCM),s_vector));
	velts = VELTS(v);
	while(--i>=0) (velts)[i] = fill;
	ALLOW_INTS;
	return v;
}
#ifdef FLOATS
 SCM makdbl (x,y)
double x,y;
{
  SCM z;
  if ((y == 0.0) && (x == 0.0)) return flo0;
  NEWCELL(z);
  DEFER_INTS;
  if (y == 0.0) {
# ifdef SINGLES
    float fx = x;
#ifndef SINGLESONLY
    if ((-FLTMAX<x) && (x<FLTMAX) && (fx==x))
#endif
      {
	CAR(z) = tc_flo;
	FLO(z) = x;
	ALLOW_INTS;
	return z;
      }
# endif /* def SINGLES */
    SETCDR(z,must_malloc(1L*sizeof(double),"real"));
    CAR(z) = tc_dblr;
  }
  else {
    SETCDR(z,must_malloc(2L*sizeof(double),"complex"));
    CAR(z) = tc_dblc;
    IMAG(z) = y;
  }
  REAL(z) = x;
  ALLOW_INTS;
  return z;
}
#endif /* FLOATS */

void make_subr(name,type,fcn)
char *name;
int type;
SCM (*fcn)();
{
	SCM sym = sysintern(name);
	register SCM z;
	NEWCELL(z);
	SETSNAME(z,NAMESTR(sym),type);
	SUBRF(z) = fcn;
	VCELL(sym) = z;
}
SCM closure(code,env)
SCM code,env;
{
	register SCM z;
	NEWCELL(z);
	SETCODE(z,code);
	ENV(z) = env;
	return z;
}
SCM makprom(code)
SCM code;
{
	register SCM z;
	NEWCELL(z);
	CDR(z) = code;
	CAR(z) = tc16_promise;
	return z;
}
char s_force[]="force";
SCM force(x)
     SCM x;
{
  ASSERT((TYP16(x)==tc16_promise),x,ARG1,s_force);
  if (!((1L<<16) & CAR(x))) {
    CDR(x) = apply(CDR(x),EOL,EOL);
    CAR(x) |= (1L<<16);
  }
  return CDR(x);
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

long stack_size(start)
SCMPTR start;
{
	long stack;
#ifdef STACK_GROWS_UP
	stack = (SCMPTR)&stack - start;
#else
	stack = start - (SCMPTR)&stack;
#endif /* def STACK_GROWS_UP */
	return stack;
}

typedef struct {jmp_buf jmpbuf;} regs;
#define JMPBUF(x) (((regs *)CHARS(x))->jmpbuf)
#define SETJMPBUF(x,v) SETCDR(x,v)

SCM throwval = UNDEFINED;
SCM call_cc(proc)
SCM proc;
{
	long j;
	SCM cont;
#ifdef CHEAP_CONTINUATIONS
	NEWCELL(cont);
	DEFER_INTS;
	SETLENGTH(cont,0L,tc7_contin);
	SETJMPBUF(cont,must_malloc((long)sizeof(regs),"continuation"));
	ALLOW_INTS;
#else
	register SCM *src,*dst;
	NEWCELL(cont);
	DEFER_INTS;
	FLUSH_REGISTER_WINDOWS;
	SETLENGTH(cont,stack_size(stack_start_ptr),tc7_contin);
	SETJMPBUF(cont,must_malloc(sizeof(regs)+LENGTH(cont)*sizeof(SCM *)
				   ,"continuation"));
	ALLOW_INTS;
	src = stack_start_ptr;
# ifndef STACK_GROWS_UP
	src -= LENGTH(cont);
# endif /* ndef STACK_GROWS_UP */
	dst = (SCM *)(CHARS(cont)+sizeof(regs));
	for (j = LENGTH(cont);0 <= --j;) *dst++ = *src++;
#endif /* def CHEAP_CONTINUATIONS */
	if (setjmp(JMPBUF(cont))) return throwval;
	return apply(proc,cont,listofnull);
}

#define PTR_GT(x,y) PTR_LT(y,x)
#define PTR_LE(x,y) (!PTR_GT(x,y))
#define PTR_GE(x,y) (!PTR_LT(x,y))

void lthrow(cont,val)
SCM cont,val;
{
#ifndef CHEAP_CONTINUATIONS
	register long j;
	register SCM *src;
	register SCMPTR dst = stack_start_ptr;
# ifdef STACK_GROWS_UP
	if PTR_GE(dst + LENGTH(cont),(SCMPTR)&cont) grow_throw(cont,val);
# else
	dst -= LENGTH(cont);
	if PTR_LE(dst,(SCMPTR)&cont) grow_throw(cont,val);
# endif /* def STACK_GROWS_UP */
	FLUSH_REGISTER_WINDOWS;
	src = (SCM *)(CHARS(cont)+sizeof(regs));
	for (j = LENGTH(cont);0 <= --j;) *dst++ = *src++;
#endif /* ndef CHEAP_CONTINUATIONS */
	throwval = val;
	longjmp(JMPBUF(cont),1);
}
#ifndef CHEAP_CONTINUATIONS
void grow_throw(cont,val)	/* Grow the stack so that there is room */
SCM cont,val;			/* to copy in the continuation.  Then */
{				/* retry the throw. */
	long growth[100];
	lthrow(cont,val);
}
#endif /* ndef CHEAP_CONTINUATIONS */

SCM obhash(obj)
     SCM obj;
{
  return (obj<<1)+2L;
}

SCM obunhash(obj)
     SCM obj;
{
  ASSERT(INUMP(obj),obj,ARG1,s_obunhash);
  obj = SRS(obj,1) & ~1L;
  if IMP(obj) return obj;
  /* if NCELLP(obj) return BOOL_F; */
  {				/* code is adapted from mark_locations */
    register CELLPTR ptr = (CELLPTR)obj;
    register int i=0, j=hplim_ind;
    do {
      if PTR_GT(hplims[i++], ptr) break;
      if PTR_LE(hplims[--j], ptr) break;
      if ((i != j) &&
	  PTR_LE(hplims[i++], ptr) &&
	  PTR_GT(hplims[--j], ptr)) continue;
      if NFREEP(obj) return obj;
      break;
    } while(i<j);
  }
  return BOOL_F;
}

void fixconfig(s1,s2)
     char *s1, *s2;
{
  fputs(s1,stdout);
  puts(s2);
  puts("in config.h and recompile scm");
  quit(MAKINUM(1L));
}

sizet init_heap_seg(seg_org,size)
     CELLPTR seg_org;
     sizet size;
{
  register CELLPTR ptr = seg_org;
  CELLPTR seg_end = CELL_DN((char *)ptr + size);
  sizet i = hplim_ind, ni = 0;
  if (ptr == NULL) return 0;
  while((ni < hplim_ind) && PTR_LE(hplims[ni],seg_org)) ni++;
  while(i-- > ni) hplims[i+2] = hplims[i];
  hplim_ind += 2;
  hplims[ni++] = ptr;		/* same as seg_org here */
  hplims[ni++] = seg_end;
  ptr = CELL_UP(ptr);
  ni = seg_end - ptr;
  for (i=ni;i--;ptr++) {
    CAR(ptr) = (SCM)tc_free_cell;
    CDR(ptr) = (SCM)(ptr+1);
  }
  CDR(--ptr) = freelist;
  freelist = (SCM) CELL_UP(seg_org);
  heap_size += ni;
  growth_mon(s_heap,heap_size,"cells");
  return size;
}
void alloc_some_heap()
{
  CELLPTR ptr, *tmplims;
  sizet len = (2+hplim_ind)*sizeof(CELLPTR);
  ASRTGO(len == (2+hplim_ind)*sizeof(CELLPTR),badhplims);
  SYSCALL(tmplims = (CELLPTR *)realloc((char *)hplims, len););
  if (!tmplims)
badhplims:
    wta(UNDEFINED,s_nogrow,s_hplims);
  else {
    hplims = tmplims;
    growth_mon("number of heaps", 1L+hplim_ind/2,"segments");
  }
  /* hplim_ind gets incremented in init_heap_seg() */
  if (expmem) {
    len = heap_size/2*sizeof(cell);
    if (len != heap_size/2*sizeof(cell)) len = 0;
  }
  else {
    len = HEAP_SEG_SIZE;
    if (len != HEAP_SEG_SIZE)
      fixconfig("reduce","size of HEAP_SEG_SIZE");
  }
  while (len >= MIN_HEAP_SEG_SIZE) {
    SYSCALL(ptr = (CELLPTR) malloc(len););
    if (ptr) {
      init_heap_seg(ptr, len);	
      return;
    }
    len /= 2;
  }
  wta(UNDEFINED, s_nogrow, s_heap);
}

#ifdef FLOATS
# include <math.h>
# ifdef ENGNOT
#  define MANTRAD 1000.0
#  define EXPINC 3
# else
#  define MANTRAD 10.0
#  define EXPINC 1
# endif /* def ENGNOT */

double dbl1 = 1.0;
int dblprec=55;
# ifdef SINGLES
float flo1 = 1.0;
int floprec=25;
# endif /* def SINGLES */
sizet idbl2str(f,prec,ec,str)
     double f;
     int prec;
     char ec,*str;
{
  register sizet i=1;
  register int xpo=0,c;
  if (f == 0.0) {str[0]='0'; str[i++]='.'; str[i++]='0'; return i;}
  if (f < 0.0) {f = -f;str[0]='-';}
  else if (f > 0.0) str[0]='+';
  else {
    i=0;
  funny: str[i++]='#'; str[i++]='.'; str[i++]='#'; return i;
  }
  if (f == f/2) goto funny;
  while(f >= MANTRAD) {xpo++;f /= MANTRAD;}
  while(f < 1.0) {xpo--;f *= MANTRAD;}
  c = floor(f);
# ifdef ENGNOT
  i += iint2str((long)c,10,&str[i]);
# else
  str[i++] = c+'0';
# endif /* def ENGNOT */
  str[i++] = '.';
  {
    double M =
      pow((double)FLTRADIX,
	  -floor(prec - 1 - log(f)/log((double)FLTRADIX)))/2;
    f -= c;
    do {
      f *= 10;
      c = floor(f);
      f -= c;
      M *= 10;
      str[i++] = c + '0';
/*      printf("prec= %d f= %g c= %d M= %g i= %d\n",prec,f,c,M,i); */
    } while ((f >= M) && (f <= 1 - M));
    if (f >= .5) str[i-1]++;
  }
  if (xpo) {
    str[i++] = ec;
    i += iint2str((long)xpo*EXPINC,10,&str[i]);
  }
  return i;
}
sizet iflo2str(flt,str)
     SCM flt;
     char *str;
{
  sizet i;
# ifdef SINGLES
  if SINGP(flt)
    return idbl2str(FLO(flt),floprec,'e',str);
# endif /* def SINGLES */
  i = idbl2str(REAL(flt),dblprec,'e',str);
  if CPLXP(flt) {
    i += idbl2str(IMAG(flt),dblprec,'e',&str[i]);
    str[i++] = 'i';
  }
  return i;
}
# ifndef SINGLES
double dbl0s[2] = {0.0, 0.0};
# endif
#endif /* FLOATS */

SCM sys_protects[NUM_PROTECTS];
void init_storage()
{
	sizet j = NUM_PROTECTS;
	/* Because not all protects may get initialized */
	while(j) sys_protects[--j] = BOOL_F;

#ifdef SINGLES
	if (sizeof (float) != sizeof (long))
	  fixconfig("remove\n#","define SINGLES");
#endif /* def SINGLES */
	if (stack_start_ptr==0)
	  wta(INUM0,"stack_start_ptr not ",ISYMCHARS(I_SET));
#ifdef STACK_GROWS_UP
	if (((SCMPTR)&j - stack_start_ptr) < 0)
	  fixconfig("remove\n#","define STACK_GROWS_UP");
#else
	if ((stack_start_ptr - (SCMPTR)&j) < 0)
	  fixconfig("add\n#","define STACK_GROWS_UP");
#endif

	hplims = (CELLPTR *)
		must_malloc(2L*sizeof(CELLPTR),s_hplims);
	j = INIT_HEAP_SIZE;
	if ((j != INIT_HEAP_SIZE) || !init_heap_seg((CELLPTR) malloc(j),j))
		alloc_some_heap();
	else expmem=1;
	heap_org = CELL_UP(hplims[0]);
		/* hplims[0] can change. do not remove heap_org */

	NEWCELL(def_inp);
	SETLENGTH(def_inp,0L,tc_inport);
	SETSTREAM(def_inp,stdin);
	NEWCELL(def_outp);
	SETLENGTH(def_outp,0L,tc_outport);
	SETSTREAM(def_outp,stdout);
	cur_inp = def_inp;
	cur_outp = def_outp;
	listofnull = cons(EOL,EOL);
	undefineds = cons(UNDEFINED,EOL);
	CDR(undefineds) = undefineds;
	nullstr = makstr(0L);
	NEWCELL(nullvect);
	SETLENGTH(nullvect,0L,tc7_vector);
	SETCHARS(nullvect,NULL);
	symhash = make_vector(MAKINUM(symhash_dim),EOL);
	init_isyms();
	VCELL(sysintern("most-positive-fixnum"))
	  = MAKINUM(MOST_POSITIVE_FIXNUM);
	VCELL(sysintern("most-negative-fixnum"))
	  = MAKINUM(MOST_NEGATIVE_FIXNUM);
#ifdef FLOATS
	NEWCELL(flo0);
# ifdef SINGLES
	CAR(flo0) = tc_flo;
	FLO(flo0) = 0.0;
# else
	CAR(flo0) = tc_dblr;
	CDR(flo0) = dbl0s;
# endif
# ifdef DBL_MANT_DIG
	dblprec=DBL_MANT_DIG;
# else
	{
	  double d=1.0/FLTRADIX;
	  double dsum = dbl1+d;
	  dblprec = 1;
	  while (dsum != 1.0) {
	    d /= FLTRADIX;
	    dblprec++;
	    dsum = dbl1+d;
	  }
	}
# endif
# ifdef SINGLES
#  ifdef FLT_MANT_DIG
	floprec=FLT_MANT_DIG;
#  else
	{
	  float f=1.0/FLTRADIX;
	  float fx=(flo1+f);
	  floprec = 1;
	  while (fx != 1.0) {
	    f /= FLTRADIX;
	    floprec++;
	    fx=(flo1+f);
	  }
	}
#  endif
# endif
/*	printf("dblprec = %d, floprec = %d\n",dblprec,floprec); */
#endif /* def FLOATS */
}
/* The way of garbage collecting which allows use of the cstack is due to */
/* Scheme In One Defun, but in C this time.

 *			  COPYRIGHT (c) 1989 BY				    *
 *	  PARADIGM ASSOCIATES INCORPORATED, CAMBRIDGE, MASSACHUSETTS.	    *
 *			   ALL RIGHTS RESERVED				    *

Permission to use, copy, modify, distribute and sell this software
and its documentation for any purpose and without fee is hereby
granted, provided that the above copyright notice appear in all copies
and that both that copyright notice and this permission notice appear
in supporting documentation, and that the name of Paradigm Associates
Inc not be used in advertising or publicity pertaining to distribution
of the software without specific, written prior permission.

PARADIGM DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
PARADIGM BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

gjc@paradigm.com

Paradigm Associates Inc		 Phone: 617-492-6079
29 Putnam Ave, Suite 6
Cambridge, MA 02138
*/

SCM gc_for_newcell()
{
	SCM fl;
	gc();
	if ((gc_cells_collected < MIN_GC_YIELD) || IMP(freelist))
		alloc_some_heap();
	++cells_allocated;
	fl = freelist;
	freelist = CDR(fl);
	return fl;
}

static char	s_bad_type[]="unknown type in ";
jmp_buf save_regs_gc_mark;

SCM gc()
{
  int j = NUM_PROTECTS;
  gc_start();
  DEFER_INTS;
  errjmp_ok = 0;
  while(j--) gc_mark(sys_protects[j]);
  FLUSH_REGISTER_WINDOWS;
  /* This assumes that all registers are saved into the jmp_buf */
  setjmp(save_regs_gc_mark);
  mark_locations((SCM *) save_regs_gc_mark,
		 (sizet) sizeof(save_regs_gc_mark)/sizeof(SCM *));
  {
    /* stack_len is long rather than sizet in order to guarantee that
       &stack_len is long aligned */
#ifdef STACK_GROWS_UP
# ifdef nosve
    long stack_len = (SCMPTR)(&stack_len) - stack_start_ptr;
# else
    long stack_len = stack_size(stack_start_ptr);
# endif
    mark_locations(stack_start_ptr,(sizet)stack_len);
#else
# ifdef nosve
    long stack_len = stack_start_ptr - (SCMPTR)(&stack_len);
# else
    long stack_len = stack_size(stack_start_ptr);
# endif
    mark_locations((stack_start_ptr - stack_len),(sizet)stack_len);
#endif
#ifdef SHORT_ALIGN
    mark_locations((SCM *) (((char *)save_regs_gc_mark)+sizeof(short)),
		   (sizet)(sizeof(save_regs_gc_mark)-sizeof(short))/
		   sizeof(SCM *));
# ifdef STACK_GROWS_UP
    mark_locations((SCMPTR)(((char *)stack_start_ptr)+sizeof(short)),
		   (sizet)stack_len);
# else
    mark_locations((SCMPTR)(((char *)(stack_start_ptr - stack_len))+
			    sizeof(short)),
		   (sizet)stack_len);
# endif
#endif
  }
  gc_sweep();
  gc_end();
  errjmp_ok = 1;
  ALLOW_INTS;
  return UNSPECIFIED;
}

#ifndef NULL
SCM freeall()
{
  gc_start();
  DEFER_INTS;
  errjmp_ok = 0;
  gc_mark(def_inp);		/* don't want to close stdin */
  gc_mark(def_outp);		/* don't want to close stdout */
  gc_mark(nullstr);		/* has NULL pointer */
  gc_mark(nullvect);		/* has NULL pointer */
  /* system symbols have strings which are not malloced.  Need to mark
     all those strings. */
  gc_sweep();
  gc_end();
  /* need to free the heap_org segment here; but which one is it? */
  free((char *)hplims);
  errjmp_ok = 1;
  ALLOW_INTS;
  throwval = INUM0;
  longjmp(errjmp,-1);		/* same as quit(0) */
}
#endif

void gc_mark(p)
SCM p;
{
  register long i;
  register SCM ptr = p;
 gc_mark_loop:
  if IMP(ptr) return;
 gc_mark_nimp:
  if (NCELLP(ptr)
      /* #ifndef RECKLESS
	 || PTR_GT(hplims[0], (CELLPTR)ptr)
	 || PTR_GE((CELLPTR)ptr, hplims[hplim_ind-1])
	 #endif */
      ) wta(ptr,"rogue pointer in ",s_heap);
  switch TYP7(ptr) {
  case tcs_cons_nimcar:
    if GCMARKP(ptr) break;
    SETGCMARK(ptr);
    if IMP(CDR(ptr)) {		/* IMP works even with a GC mark */
      ptr = CAR(ptr);
      goto gc_mark_nimp;
    }
    gc_mark(CAR(ptr));
    ptr = GCCDR(ptr);
    goto gc_mark_nimp;
  case tcs_cons_imcar:
  case tcs_cons_gloc:
    if GCMARKP(ptr) break;
    SETGCMARK(ptr);
    ptr = GCCDR(ptr);
    goto gc_mark_loop;
  case tcs_symbols:
    if GCMARKP(ptr) break;
    SETGCMARK(ptr);
    gc_mark(NAMESTR(ptr));	/* this could be bummed. */
    ptr = GCCDR(ptr);
    goto gc_mark_loop;
  case tcs_closures:
    if GCMARKP(ptr) break;
    SETGCMARK(ptr);
    if IMP(CDR(ptr)) {
      ptr = CODE(ptr);
      goto gc_mark_nimp;
    }
    gc_mark(CODE(ptr));
    ptr = GCCDR(ptr);
    goto gc_mark_nimp;
  case tc7_vector:
    if GC8MARKP(ptr) break;
    SETGC8MARK(ptr);
    i=LENGTH(ptr);
    if (i == 0) break;
    while(--i>0) if NIMP(VELTS(ptr)[i]) gc_mark(VELTS(ptr)[i]);
    ptr = VELTS(ptr)[0];
    goto gc_mark_loop;
  case tc7_contin:
    if GC8MARKP(ptr) break;
    SETGC8MARK(ptr);
    mark_locations(VELTS(ptr),
		   (sizet)
		   (LENGTH(ptr) + sizeof(regs)/sizeof(SCM *)));
#ifdef SHORT_ALIGN
    mark_locations(CHARS(ptr)+sizeof(short),
		   (sizet)
		   (LENGTH(ptr)+(sizeof(regs)-sizeof(short))/sizeof(SCM *)));
#endif /* def SHORT_ALIGN */
    break;
  case tc7_string:
    /*		if GC8MARKP(ptr) break;*/
    SETGC8MARK(ptr);
  case tcs_subrs:
    break;
  case tc7_smob:
    if GC8MARKP(ptr) break;
    switch TYP16(ptr) {
#ifdef FLOATS
    case tc16_flo:
#endif /* def FLOATS */
    case tc16_port:
      SETGC8MARK(ptr);
      break;
    case tc16_promise:
    case tc16_arbiter:
      if GC8MARKP(ptr) break;
      SETGC8MARK(ptr);
      ptr = CDR(ptr);
      goto gc_mark_loop;
    default:
      goto def;
    }
    break;
  default:
  def:
    wta(ptr,s_bad_type,"gc_mark");
  }
}

void mark_locations(x,n)
SCM x[];
sizet n;
{
	register long m = n;
	register int i,j;
	register CELLPTR ptr;
	while(0 <= --m) if CELLP(x[m]) {
		ptr = (CELLPTR)x[m];
		i=0;
		j=hplim_ind;
		do {
			if PTR_GT(hplims[i++], ptr) break;
			if PTR_LE(hplims[--j], ptr) break;
			if ((i != j) &&
			    PTR_LE(hplims[i++], ptr) &&
			    PTR_GT(hplims[--j], ptr)) continue;
			if NFREEP(x[m]) gc_mark(x[m]);
			break;
		} while(i<j);
	}
}

void gc_sweep()
{
  register CELLPTR ptr;
  register SCM nfreelist = EOL;
  register long n=0,m=0;
  register sizet j;
  sizet i=0;
  sizet seg_size;
  while (i<hplim_ind) {
    ptr=CELL_UP(hplims[i++]);
    seg_size=CELL_DN(hplims[i++]) - ptr;
    for(j=seg_size;j--;++ptr) {
      switch TYP7(ptr) {
      case tcs_cons_imcar:
      case tcs_cons_nimcar:
      case tcs_cons_gloc:
      case tcs_closures:
	if GCMARKP(ptr) goto cmrkcontinue;
	break;
      case tc7_vector:
	if GC8MARKP(ptr) goto c8mrkcontinue;
	m += (LENGTH(ptr)*sizeof(SCM));
	free(CHARS(ptr));
	break;
#ifdef BIGDIG
      case tc7_bignum:
	if GC8MARKP(ptr) goto c8mrkcontinue;
	m += (LENGTH(ptr)*sizeof(short));
	free(CHARS(ptr));
	break;
#endif /* def BIGDIG */
      case tc7_string:
	if GC8MARKP(ptr) goto c8mrkcontinue;
	m += LENGTH(ptr)+1;
	free(CHARS(ptr));
	break;
      case tc7_contin:
	if GC8MARKP(ptr) goto c8mrkcontinue;
	m += LENGTH(ptr) + sizeof(regs);
	free(CHARS(ptr));
	break;
      case tcs_symbols:
	goto cmrkcontinue;
      case tcs_subrs:
	continue;
      case tc7_smob:
	switch GCTYP16(ptr) {
	case tc16_port:
	  if GC8MARKP(ptr) goto c8mrkcontinue;
	  if OPENP(ptr) {
#ifdef IO_EXTENSIONS
#ifdef HAVE_PIPE
	    if (PIP & CAR(ptr)) pclose(STREAM(ptr));
	    else
#endif
#endif
	      fclose(STREAM(ptr));
	    gc_ports_collected++;
	    SETSTREAM(ptr,0);
	    CAR(ptr) &= ~OPN;
	  }
	case tc16_promise:
	case tc16_arbiter:
	  if GC8MARKP(ptr) goto c8mrkcontinue;
	case tc_free_cell:
	  break;
#ifdef FLOATS
	case tc16_flo:
	  if GC8MARKP(ptr) goto c8mrkcontinue;
	  switch ((int)(CAR(ptr)>>16)) {
	  case (IMAG_PART | REAL_PART)>>16:
	    m += 2*sizeof(double);
	  case REAL_PART>>16:
	  case IMAG_PART>>16:
	    m += sizeof(double);
	    free(CHARS(ptr));
#ifdef SINGLES
	  case 0:
#endif /* def SINGLES */
	    break;
	  default:
	    goto sweeperr;
	  }
	  break;
#endif				/* FLOATS */
	default:
	  goto sweeperr;
	}
	break;
      default:
      sweeperr:
	wta((SCM)ptr,s_bad_type,"gc_sweep");
      }
      ++n;
      CAR(ptr) = (SCM)tc_free_cell;
      CDR(ptr) = nfreelist;
      nfreelist = (SCM)ptr;
      continue;
    c8mrkcontinue:
      CLRGC8MARK(ptr);
      continue;
    cmrkcontinue:
      CLRGCMARK(ptr);
    }
    if (n==seg_size) {
      heap_size -= seg_size;
      free((char *)hplims[i-2]);
      for(j=i;j < hplim_ind;j++) hplims[j-2] = hplims[j];
      hplim_ind -= 2;
      i -= 2;			/* need to scan segment just moved. */
      growth_mon(s_heap,heap_size,"cells");
      nfreelist = freelist;
    }
    else freelist = nfreelist;
    gc_cells_collected += n;
    n=0;
  }
  gc_malloc_collected = m;
}
