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

#include <ctype.h>

#include "scm.h"
#include "setjump.h"

char	s_nogrow[] = "could not grow", s_heap[] = "heap",
	s_hplims[] = "hplims";
static void grow_throw(), gc_sweep();
static char	s_input_portp[] = "input-port?",
		s_output_portp[] = "output-port?";
static char	s_close_port[] = "close-port";
#define s_port (s_close_port+6)
static char	s_open_file[] = "open-file";
#ifndef MSDOS
# ifndef ultrix
#  ifndef vms
#   ifdef _DCC
#    include <ioctl.h>
#    define setbuf(stream,buf) setvbuf(stream,buf,_IONBF,0)
#   else
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
#endif
long mode_bits(modes)
     char *modes;
{
  return OPN | (strchr(modes,'r') || strchr(modes,'+')?RDNG:0)
    | (strchr(modes,'w') || strchr(modes,'a') || strchr(modes,'+') ?WRTNG:0);
}

SCM open_file(filename, modes)
SCM filename, modes;
{
	FILE *f;
	register SCM z;
	ASSERT(NIMP(filename) && STRINGP(filename),
	       filename,ARG1,s_open_file);
	ASSERT(NIMP(modes) && STRINGP(modes),
	       modes,ARG2,s_open_file);
	NEWCELL(z);
	DEFER_INTS;
	SYSCALL(f = fopen(CHARS(filename),CHARS(modes)););
	if (!f) z = BOOL_F;
	else {
	  SETLENGTH(z,0L,tc16_fport | mode_bits(CHARS(modes)));
	  SETSTREAM(z,f);
#ifndef NOSETBUF
# ifndef MSDOS
#  ifdef FIONREAD
#   ifndef ultrix
	  if ((RDNG & CAR(z)) && isatty(fileno(f)))
	    SYSCALL(setbuf(f,0););
	  /* turn off input buffering for ttys */
#   endif
#  endif
# endif
#endif
	}
	ALLOW_INTS;
	return z;
      }
#ifdef IO_EXTENSIONS
#ifdef HAVE_PIPE
FILE *popen();
int pclose();
char	s_op_pipe[] = "open-pipe";
SCM open_pipe(pipestr,modes)
SCM pipestr,modes;
{
	FILE *f;
	register SCM z;
	ASSERT(NIMP(pipestr) && STRINGP(pipestr),pipestr,ARG1,s_op_pipe);
	ASSERT(NIMP(modes) && STRINGP(modes),modes,ARG2,s_op_pipe);
	NEWCELL(z);
	/* DEFER_INTS, SYSCALL, and ALLOW_INTS are probably paranoid here*/
	DEFER_INTS;
	ignore_signals();
	SYSCALL(f = popen(CHARS(pipestr),CHARS(modes)););
	unignore_signals();
	if (!f) z = BOOL_F;
	else {
	  SETLENGTH(z,0L,tc16_pipe | OPN |
		    (strchr(CHARS(modes),'r') ? RDNG : WRTNG));
	  SETSTREAM(z,f);
	}
	init_signals();
	ALLOW_INTS;
	return z;
}
#endif /* HAVE_PIPE */
#endif /* def IO_EXTENSIONS */

SCM close_port(port)
SCM port;
{
	sizet i;
	ASSERT(NIMP(port) && TYP7(port)==tc7_port,port,ARG1,s_close_port);
	if CLOSEDP(port) return UNSPECIFIED;
	i = PTOBNUM(port);
	DEFER_INTS;
	if (ptobs[i].fclose) {
	  SYSCALL((ptobs[i].fclose)(STREAM(port)););
	  SETSTREAM(port,0);
	}
	CAR(port) &= ~OPN;
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
#ifdef GO32
# undef L_tmpnam
#endif
#ifdef MWC
# undef L_tmpnam
#endif

#ifdef L_tmpnam
SCM ltmpnam()
{
  char name[L_tmpnam];
  SYSCALL(tmpnam(name););
  return makfromstr(name, strlen(name));
}
#else
/* TEMPTEMPLATE is used only if mktemp() is being used instead of
   tmpnam(). */

#ifdef AMIGA
# define TEMPTEMPLATE "T:SchemeaaaXXXXXX";
#else
char *mktemp();
# ifdef vms
#  define TEMPTEMPLATE "sys$scratch:aaaXXXXXX";
# else /* vms */
#  ifdef __MSDOS__
#   ifdef GO32
#    define TEMPTEMPLATE "\\tmp\\TMPaaaXXXXXX";
#   else
#    define TEMPTEMPLATE "TMPaaaXXXXXX";
#   endif
#  else /* __MSDOS__ */
#   define TEMPTEMPLATE "/tmp/aaaXXXXXX";
#  endif /* __MSDOS__ */
# endif /* vms */
#endif /* AMIGA */

char template[] = TEMPTEMPLATE;
# define TEMPLEN (sizeof template/sizeof(char) - 1)
SCM ltmpnam()
{
  SCM name;
  int temppos = TEMPLEN-9;
  name = makfromstr(template,(sizet)TEMPLEN);
  DEFER_INTS;
inclp:
  template[temppos]++;
  if (!isalpha(template[temppos])) {
    template[temppos++] = 'a';
    goto inclp;
  }
# ifndef AMIGA
#  ifndef __MSDOS__
  SYSCALL(temppos = !*mktemp(CHARS(name)););
  if (temppos) name = BOOL_F;
#  endif
# endif
  ALLOW_INTS;
  return name;
}
#endif /* L_tmpnam */

#ifdef IO_EXTENSIONS
#ifndef THINK_C
static char s_chdir[] = "chdir";
SCM lchdir(str)
     SCM str;
{
  int ans;
  ASSERT(NIMP(str) && STRINGP(str), str, ARG1, s_chdir);
  SYSCALL(ans = chdir(CHARS(str)););
  return ans ? BOOL_F : BOOL_T;
}
#endif
#ifdef M_SYSV
#define remove unlink
#endif
static char s_del_fil[] = "delete-file";
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
static char s_ren_fil[] = "rename-file";
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
char s_isatty[] = "isatty?";
SCM lisatty(port)
     SCM port;
{
  ASSERT(NIMP(port) && OPPORTP(port), port,ARG1,s_isatty);
  if (tc16_fport != TYP16(port)) return BOOL_F;
  return isatty(fileno(STREAM(port)))?BOOL_T:BOOL_F;
}
#endif				/* IO_EXTENSIONS */

void prinport(exp,port,type)
     SCM exp; SCM port; char *type;
{
  lputs("#<",port);
  if (RDNG & CAR(exp)) lputs("input-",port);
  if (WRTNG & CAR(exp)) lputs("output-",port);
  lputs(type,port);
  lputc(' ',port);
  if CLOSEDP(exp) lputs("closed",port);
#ifndef MSDOS
# ifndef __EMX__
#  ifndef _DCC
#   ifndef AMIGA
#    ifndef THINK_C
  else if (tc16_fport==TYP16(exp) && isatty(fileno(STREAM(exp))))
    lputs(ttyname(fileno(STREAM(exp))),port);
#    endif
#   endif
#  endif
# endif
#endif
  else if FPORTP(exp) intprint((long)fileno(STREAM(exp)),10,port);
  else intprint(CDR(exp),16,port);
  lputc('>',port);
}
static int prinfport(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  prinport(exp,port,s_port);
  return !0;
}
#ifdef HAVE_PIPE
static int prinpipe(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  prinport(exp,port,s_pipe);
  return !0;
}
#endif
static int prinstpt(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  prinport(exp,port,s_string);
  return !0;
}
static int prinsfpt(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  prinport(exp,port,"soft");
  return !0;
}

static int stputc(c,p)
     int c; SCM p;
{
  sizet ind = INUM(CAR(p));
  if (ind >= LENGTH(CDR(p))) resizuve(CDR(p),MAKINUM(ind + (ind>>1)));
  CHARS(CDR(p))[ind] = c;
  CAR(p) = MAKINUM(ind + 1);
  return c;
}
sizet stwrite(str,siz,num,p)
     sizet siz, num;
     char *str; SCM p;
{
  sizet ind = INUM(CAR(p));
  sizet len = siz * num;
  char *dst;
  if (ind + len >= LENGTH(CDR(p)))
    resizuve(CDR(p),MAKINUM(ind + len + ((ind + len)>>1)));
  dst = &(CHARS(CDR(p))[ind]);
  while (len--) dst[len] = str[len];
  CAR(p) = MAKINUM(ind + siz*num);
  return num;
}
static int stputs(s,p)
     char *s; SCM p;
{
  stwrite(s,1,strlen(s),p);
  return 0;
}
static int stgetc(p)
     SCM p;
{
  sizet ind = INUM(CAR(p));
  if (ind >= LENGTH(CDR(p))) return EOF;
  CAR(p) = MAKINUM(ind + 1);
  return CHARS(CDR(p))[ind];
}
int noop0(stream)
     FILE *stream;
{
  return 0;
}
SCM mkstrport(cs,modes)
     SCM cs;
     long modes;
{
  SCM z;
  NEWCELL(z);
  DEFER_INTS;
  SETCHARS(z, cs);
  CAR(z) = tc16_strport | modes;
  ALLOW_INTS;
  return z;
}
static char s_cwos[] = "call-with-output-string";
static char s_cwis[] = "call-with-input-string";
SCM cwos(proc)
     SCM proc;
{
  SCM p = mkstrport(cons(INUM0,make_string(MAKINUM(30),UNDEFINED)),
		    OPN | WRTNG);
  apply(proc, p, listofnull);
  return resizuve(CDR(CDR(p)),CAR(CDR(p)));
}
SCM cwis(str, proc)
     SCM str, proc;
{
  SCM p = mkstrport(cons(INUM0,str),OPN | RDNG);
  return apply(proc, p, listofnull);
}
#ifdef vms
sizet pwrite(ptr, size, nitems, port)
     char *ptr;
     sizet size, nitems;
     FILE* port;
{
  sizet len = size * nitems;
  sizet i = 0;
  for(;i < len;i++) putc(ptr[i],port);
  return len;
}
#define ffwrite pwrite
#else
#define ffwrite fwrite
#endif

static ptobfuns fptob = {mark0,fclose,prinfport,0,
			   fputc,fputs,ffwrite,fflush,fgetc,fclose};
#ifndef HAVE_PIPE
#define pclose 0
#define prinpipe 0
#endif
static ptobfuns pipob = {mark0,pclose,prinpipe,0,
			   fputc,fputs,ffwrite,fflush,fgetc,pclose};
static ptobfuns stptob = {markcdr,noop0,prinstpt,0,
			    stputc,stputs,stwrite,noop0,
			    stgetc,0};

				/* Soft ports */

/* fputc, fwrite, fputs, and fclose are called within a
   SYSCALL.  So we need to set errno to 0 before returning.  fflush
   may be called within a SYSCALL.  So we need to set errno to 0
   before returning. */

static int sfputc(c,p)
     int c; SCM p;
{
  apply(VELTS(p)[0],MAKICHR(c),listofnull);
  errno = 0;
  return c;
}
sizet sfwrite(str,siz,num,p)
     sizet siz, num;
     char *str; SCM p;
{
  SCM sstr;
  sstr = makfromstr(str,siz * num);
  apply(VELTS(p)[1],sstr,listofnull);
  errno = 0;
  return num;
}
static int sfputs(s,p)
     char *s; SCM p;
{
  sfwrite(s,1,strlen(s),p);
  return 0;
}
int sfflush(stream)
     SCM stream;
{
  SCM f = VELTS(stream)[2];
  if (BOOL_F==f) return 0;
  f = apply(f,EOL,EOL);
  errno = 0;
  return BOOL_F==f ? EOF : 0;
}
static int sfgetc(p)
     SCM p;
{
  SCM ans;
  ans = apply(VELTS(p)[3],EOL,EOL);
  errno = 0;
  if (FALSEP(ans) || EOF_VAL==ans) return EOF;
  ASSERT(ICHRP(ans), ans, ARG1, "getc");
  return ICHR(ans);
}
static int sfclose(p)
     SCM p;
{
  SCM f = VELTS(p)[4];
  if (BOOL_F==f) return 0;
  f = apply(f,EOL,EOL);
  errno = 0;
  return BOOL_F==f ? EOF : 0;
}
static char s_mksfpt[] = "make-soft-port";
SCM mksfpt(pv,modes)
     SCM pv, modes;
{
  SCM z;
  ASSERT(NIMP(pv) && VECTORP(pv) && 5==LENGTH(pv), pv, ARG1, s_mksfpt);
  ASSERT(NIMP(modes) && STRINGP(modes), modes,ARG2,s_mksfpt);
  NEWCELL(z);
  DEFER_INTS;
  SETLENGTH(z,0L,tc16_sfport | mode_bits(CHARS(modes)));
  SETSTREAM(z,pv);
  ALLOW_INTS;
  return z;
}

static ptobfuns sfptob = {markcdr,noop0,prinsfpt,0,
			    sfputc,sfputs,sfwrite,sfflush,
			    sfgetc,sfclose};

static smobfuns freecell = {mark0,free0,0,0};
static smobfuns flob = {mark0,/*flofree*/0,floprint,floequal};
static smobfuns bigob = {mark0,/*bigfree*/0,bigprint,bigequal};
void (**finals)() = 0;
sizet num_finals = 0;
static char s_final[] = "final";

void init_types()
{
  numptob = 0;
  ptobs = (ptobfuns *)malloc(4*sizeof(ptobfuns));
  /* These newptob calls must be done in this order */
  /* tc16_fport = */ newptob(&fptob);
  /* tc16_pipe = */ newptob(&pipob);
  /* tc16_strport = */ newptob(&stptob);
  /* tc16_sfport = */ newptob(&sfptob);
  numsmob = 0;
  smobs = (smobfuns *)malloc(7*sizeof(smobfuns));
  /* These newsmob calls must be done in this order */
  newsmob(&freecell);
  newsmob(&flob);
  newsmob(&bigob);
  newsmob(&bigob);
  finals = (void(**)())malloc(2 * sizeof(finals[0]));
  num_finals = 0;
}

void add_final(final)
     void (* final)();
{
  DEFER_INTS;
  finals = (void (**)()) must_realloc((char *)finals,
				      1L*(num_finals)*sizeof(finals[0]),
				      (1L+num_finals)*sizeof(finals[0]),
				      s_final);
  finals[num_finals++] = final;
  ALLOW_INTS;
  return;
}

char s_obunhash[] = "object-unhash";
#define s_cont (ISYMCHARS(IM_CONT)+20)
static iproc subr0s[] = {
	{"gc",gc},
	{"tmpnam",ltmpnam},
	{0,0}};

static iproc subr1s[] = {
	{s_input_portp,input_portp},
	{s_output_portp,output_portp},
	{s_close_port,close_port},
	{"eof-object?",eof_objectp},
	{s_cwos,cwos},
#ifdef IO_EXTENSIONS
	{s_isatty,lisatty},
# ifndef THINK_C
	{s_chdir,lchdir},
# endif
	{s_del_fil, del_fil},
#endif /* def IO_EXTENSIONS */
	{"object-hash",obhash},
	{s_obunhash,obunhash},
	{0,0}};

static iproc subr2s[] = {
	{s_open_file,open_file},
	{s_cwis,cwis},
	{s_mksfpt,mksfpt},
#ifdef IO_EXTENSIONS
# ifdef HAVE_PIPE
	{s_op_pipe,open_pipe},
# endif
	{s_ren_fil, ren_fil},
#endif /* def IO_EXTENSIONS */
	{0,0}};

SCM dynwind();
void init_io(){
  make_subr("dynamic-wind",tc7_subr_3,dynwind);
  init_iprocs(subr0s, tc7_subr_0);
  init_iprocs(subr1s, tc7_subr_1);
  init_iprocs(subr2s, tc7_subr_2);
#ifndef CHEAP_CONTINUATIONS
  add_feature("full-continuation");
#endif
}

void grew_lim(nm)
     long nm;
{
  ALLOW_INTS;
  growth_mon(s_limit,nm,"bytes");
  DEFER_INTS;
}
int expmem = 0;
sizet hplim_ind = 0;
long heap_size = 0;
CELLPTR *hplims, heap_org;
SCM freelist = EOL;
long mtrigger;
char *must_malloc(len,what)
long len;
char *what;
{
	char *ptr;
	sizet size = len;
	long nm = mallocated+size;
	if (len != size)
malerr:
		wta(MAKINUM(len),(char *)NALLOC,what);
	if ((nm <= mtrigger)) {
	  SYSCALL(ptr = (char *)malloc(size););
	  if (NULL != ptr) {mallocated = nm; return ptr;}
	}
	igc(what);
	nm = mallocated+size;
	if (nm > mtrigger) grew_lim(nm+nm/2); /* must do before malloc */
	SYSCALL(ptr = (char *)malloc(size););
	if (NULL != ptr) {
	  mallocated = nm;
	  if (nm > mtrigger) mtrigger = nm + nm/2;
	  return ptr;}
	goto malerr;
}
char *must_realloc(where,olen,len,what)
char *where;
long olen, len;
char *what;
{
	char *ptr;
	sizet size = len;
	long nm = mallocated+size-olen;
	if (len != size)
ralerr:
		wta(MAKINUM(len),(char *)NALLOC,what);
	if ((nm <= mtrigger)) {
	  SYSCALL(ptr = (char *)realloc(where,size););
	  if (NULL != ptr) {mallocated = nm; return ptr;}
	}
	igc(what);
	nm = mallocated+size-olen;
	if (nm > mtrigger) grew_lim(nm+nm/2); /* must do before realloc */
	SYSCALL(ptr = (char *)realloc(where,size););
	if (NULL != ptr) {
	  mallocated = nm;
	  if (nm > mtrigger) mtrigger = nm + nm/2;
	  return ptr;}
	goto ralerr;
}
void must_free(obj)
     char *obj;
{
  if (obj) free(obj);
  else wta(INUM0,"already free","");
}

int symhash_dim = NUM_HASH_BUCKETS;
/* sym2vcell looks up the symbol in the symhash table. */
SCM sym2vcell(sym)
SCM sym;
{
  SCM lsym, z;
  sizet hash = strhash(UCHARS(sym), (sizet)LENGTH(sym),
		       (unsigned long)symhash_dim);
  for(lsym = VELTS(symhash)[hash];NIMP(lsym);lsym = CDR(lsym)) {
    z = CAR(lsym);
    if (CAR(z)==sym) return z;
  }
  wta(sym,"uninterned symbol? ","");
}
SCM intern(name,len)
     char *name;
sizet len;
{
  SCM lsym, z;
  register sizet i = len;
  register unsigned char *tmp = (unsigned char *)name;
  sizet hash = strhash(tmp, i, (unsigned long)symhash_dim);
  for(lsym = VELTS(symhash)[hash];NIMP(lsym);lsym = CDR(lsym)) {
    z = CAR(lsym);
    z = CAR(z);
    tmp = UCHARS(z);
    if (LENGTH(z) != len) goto trynext;
    for(i = len;i--;) if (((unsigned char *)name)[i] != tmp[i]) goto trynext;
    return CAR(lsym);
  trynext: ;
  }
  lsym = makfromstr(name, len);
  DEFER_INTS;
  SETLENGTH(lsym,(long)len,tc7_msymbol);
  ALLOW_INTS;
  return CAR(VELTS(symhash)[hash] =
	     acons(lsym, UNDEFINED, VELTS(symhash)[hash]));
}
SCM sysintern(name,val)
     char *name;
SCM val;
{
	SCM lsym;
	sizet len = strlen(name);
	register unsigned char *tmp = (unsigned char *)name;
	sizet hash = strhash(tmp, len, (unsigned long)symhash_dim);
	NEWCELL(lsym);
	SETLENGTH(lsym,(long)len,tc7_ssymbol);
	SETCHARS(lsym,name);
	lsym = cons(lsym,val);
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
SCM acons(w,x,y)
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
	SETCHARS(s,must_malloc(len+1,s_string));
	SETLENGTH(s,len,tc7_string);
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

SCM make_subr(name,type,fcn)
char *name;
int type;
SCM (*fcn)();
{
	SCM symcell = sysintern(name,UNDEFINED);
	long tmp = ((((CELLPTR)(CAR(symcell)))-heap_org)<<8);
	register SCM z;
	if ((tmp>>8) != ((CELLPTR)(CAR(symcell))-heap_org))
	  tmp = 0;
	NEWCELL(z);
	SUBRF(z) = fcn;
	CAR(z) = tmp + type;
	CDR(symcell) = z;
	return z;
}

#ifdef STACK_LIMIT
void stack_check()
{
  STACKITEM *start = BASE(rootcont);
  STACKITEM stack;
#ifdef STACK_GROWS_UP
  if (&stack - start > STACK_LIMIT*sizeof(STACKITEM))
#else
  if (start - &stack > STACK_LIMIT*sizeof(STACKITEM))
#endif /* def STACK_GROWS_UP */
    wta(UNDEFINED,(char *)SEGV_SIGNAL,"stack");
}
#endif
static long stack_size(start)
STACKITEM *start;
{
	STACKITEM stack;
#ifdef STACK_GROWS_UP
	return &stack - start;
#else
	return start - &stack;
#endif /* def STACK_GROWS_UP */
}
void stack_report()
{
  STACKITEM stack;
  intprint(stack_size(BASE(rootcont))*sizeof(STACKITEM),16,cur_errp);
  lputs(" of stack: 0x",cur_errp);
  intprint((long)BASE(rootcont),16,cur_errp);
  lputs(" - 0x",cur_errp);
  intprint((long)&stack,16,cur_errp);
  lputs("\n",cur_errp);
}

SCM dynwind(thunk1,thunk2,thunk3)
     SCM thunk1,thunk2,thunk3;
{
  SCM ans;
  apply(thunk1,EOL,EOL);
  dynwinds = acons(thunk1,thunk3,dynwinds);
  ans = apply(thunk2,EOL,EOL);
  dynwinds = CDR(dynwinds);
  apply(thunk3,EOL,EOL);
  return ans;
}
void dowinds(to,delta)
     SCM to;
     long delta;
{
 tail:
  if (dynwinds==to);
  else if (0 > delta) {
    dowinds(CDR(to),1+delta);
    apply(CAR(CAR(to)),EOL,EOL);
    dynwinds = to;
  }
  else {
    SCM from = CDR(CAR(dynwinds));
    dynwinds = CDR(dynwinds);
    apply(from,EOL,EOL);
    delta--; goto tail;		/* dowinds(to,delta-1); */
  }
}

SCM throwval = UNDEFINED;

SCM make_cont()
{
	long j;
	SCM cont;
#ifdef CHEAP_CONTINUATIONS
	NEWCELL(cont);
	DEFER_INTS;
	SETJMPBUF(cont,must_malloc((long)sizeof(regs),s_cont));
	SETLENGTH(cont,0L,tc7_contin);
	DYNENV(cont) = dynwinds;
	BASE(cont) = BASE(rootcont);
	ALLOW_INTS;
#else
	register STACKITEM *src,*dst;
	NEWCELL(cont);
	DEFER_INTS;
	FLUSH_REGISTER_WINDOWS;
	j = stack_size(BASE(rootcont));
	SETJMPBUF(cont,must_malloc((long)(sizeof(regs)+j*sizeof(STACKITEM))
				   ,s_cont));
	SETLENGTH(cont,j,tc7_contin);
	DYNENV(cont) = dynwinds;
	src = BASE(cont) = BASE(rootcont);
	ALLOW_INTS;
# ifndef STACK_GROWS_UP
	src -= LENGTH(cont);
# endif /* ndef STACK_GROWS_UP */
	dst = (STACKITEM *)(CHARS(cont)+sizeof(regs));
	for (j = LENGTH(cont);0 <= --j;) *dst++ = *src++;
#endif /* def CHEAP_CONTINUATIONS */
	return cont;
}

#define PTR_GT(x,y) PTR_LT(y,x)
#define PTR_LE(x,y) (!PTR_GT(x,y))
#define PTR_GE(x,y) (!PTR_LT(x,y))

void dynthrow(cont,val)
SCM cont,val;
{
#ifndef CHEAP_CONTINUATIONS
	register long j;
	register STACKITEM *src, *dst = BASE(rootcont);
# ifdef STACK_GROWS_UP
	if PTR_GE(dst + LENGTH(cont),(STACKITEM *)&cont) grow_throw(cont,val);
# else
	dst -= LENGTH(cont);
	if PTR_LE(dst,(STACKITEM *)&cont) grow_throw(cont,val);
# endif /* def STACK_GROWS_UP */
	FLUSH_REGISTER_WINDOWS;
	src = (STACKITEM *)(CHARS(cont)+sizeof(regs));
	for (j = LENGTH(cont);0 <= --j;) *dst++ = *src++;
#endif /* ndef CHEAP_CONTINUATIONS */
	throwval = val;
	longjmp(JMPBUF(cont),1);
}
void lthrow(cont,val)
SCM cont,val;
{
	if (BASE(cont) != BASE(rootcont)) wta(cont,"stale",s_cont);
	dowinds(DYNENV(cont),ilength(dynwinds)-ilength(DYNENV(cont)));
	dynthrow(cont,val);
}
#ifndef CHEAP_CONTINUATIONS
static void grow_throw(cont,val) /* Grow the stack so that there is room */
SCM cont,val;			/* to copy in the continuation.  Then */
{				/* retry the throw. */
	SCM growth[100];
#ifdef sparc
	sizet i = sizeof(growth)/sizeof(SCM);
	while(i--) growth[i] = BOOL_F;
#endif
	growth[0] = (SCM)growth;
	dynthrow(cont,val);
}
#endif /* ndef CHEAP_CONTINUATIONS */

SCM obhash(obj)
     SCM obj;
{

#ifdef BIGDIG
  long n = SRS(obj,1);
  if (!FIXABLE(n)) return long2big(n);
#endif
  return (obj<<1)+2L;
}

SCM obunhash(obj)
     SCM obj;
{
#ifdef BIGDIG
  if (NIMP(obj) && BIGP(obj)) {
    sizet i = NUMDIGS(obj);
    BIGDIG *ds = BDIGITS(obj);
    if (TYP16(obj)==tc16_bigpos) {
      obj = 0;
      while (i--) obj = BIGUP(obj) + ds[i];
    }
    else {
      obj = 0;
      while (i--) obj = BIGUP(obj) - ds[i];
    }
    obj <<= 1;
    goto comm;
  }
#endif
  ASSERT(INUMP(obj),obj,ARG1,s_obunhash);
  obj = SRS(obj,1) & ~1L;
 comm:
  if IMP(obj) return obj;
  if NCELLP(obj) return BOOL_F;
  {				/* code is adapted from mark_locations */
    register CELLPTR ptr = (CELLPTR)SCM2PTR(obj);
    register sizet i = 0, j = hplim_ind;
    do {
      if PTR_GT(hplims[i++], ptr) break;
      if PTR_LE(hplims[--j], ptr) break;
      if ((i != j)
	  && PTR_LE(hplims[i++], ptr)
	  && PTR_GT(hplims[--j], ptr)) continue;
      if NFREEP(obj) return obj;
      break;
    } while(i<j);
  }
  return BOOL_F;
}

unsigned long strhash(str, len, n)
     unsigned char *str;
     sizet len;
     unsigned long n;
{
  if (len>5)
    {
      sizet i = 5;
      unsigned long h = 264 % n;
      while (i--) h = ((h<<8) + ((unsigned)(downcase[str[h % len]]))) % n;
      return h;
    }
  else {
    sizet i = len;
    unsigned long h = 0;
    while (i) h = ((h<<8) + ((unsigned)(downcase[str[--i]]))) % n;
    return h;
  }
}

static void fixconfig(s1,s2,s)
     char *s1, *s2;
     int s;
{
  fputs(s1,stderr);
  fputs(s2,stderr);
  fputs("\nin ",stderr);
  fputs(s ? "setjump" : "config",stderr);
  fputs(".h and recompile scm\n",stderr);
  quit(MAKINUM(1L));
}

sizet init_heap_seg(seg_org,size)
     CELLPTR seg_org;
     sizet size;
{
  register CELLPTR ptr = seg_org;
#ifdef POINTERS_MUNGED  
  register SCM scmptr;
#else
# define scmptr ptr
#endif
  CELLPTR seg_end = CELL_DN((char *)ptr + size);
  sizet i = hplim_ind, ni = 0;
  if (ptr==NULL) return 0;
  while((ni < hplim_ind) && PTR_LE(hplims[ni],seg_org)) ni++;
  while(i-- > ni) hplims[i+2] = hplims[i];
  hplim_ind += 2;
  hplims[ni++] = ptr;		/* same as seg_org here */
  hplims[ni++] = seg_end;
  ptr = CELL_UP(ptr);
  ni = seg_end - ptr;
  for (i = ni;i--;ptr++) {
#ifdef POINTERS_MUNGED
    scmptr = PTR2SCM(ptr);
#endif
    CAR(scmptr) = (SCM)tc_free_cell;
    CDR(scmptr) = PTR2SCM(ptr+1);
  }
/*  CDR(scmptr) = freelist; */
  CDR(PTR2SCM(--ptr)) = freelist;
  freelist = PTR2SCM(CELL_UP(seg_org));
  heap_size += ni;
  return size;
#ifdef scmptr
# undef scmptr
#endif
}
static void alloc_some_heap()
{
  CELLPTR ptr, *tmplims;
  sizet len = (2+hplim_ind)*sizeof(CELLPTR);
  ASRTGO(len==(2+hplim_ind)*sizeof(CELLPTR),badhplims);
  SYSCALL(tmplims = (CELLPTR *)realloc((char *)hplims, len););
  if (!tmplims)
badhplims:
    wta(UNDEFINED,s_nogrow,s_hplims);
  else {
    hplims = tmplims;
  }
  /* hplim_ind gets incremented in init_heap_seg() */
  if (expmem) {
    len = (sizet)(EXPHEAP(heap_size)*sizeof(cell));
    if ((sizet)(EXPHEAP(heap_size)*sizeof(cell)) != len) len = 0;
  }
  else {
    len = HEAP_SEG_SIZE;
    if (HEAP_SEG_SIZE != len)
      fixconfig("reduce","size of HEAP_SEG_SIZE",0);
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

smobfuns *smobs;
sizet numsmob;
long newsmob(smob)
     smobfuns *smob;
{
  char *tmp;
  if (255 <= numsmob) goto smoberr;
  DEFER_INTS;
  SYSCALL(tmp = (char *)realloc((char *)smobs, (1+numsmob)*sizeof(smobfuns)););
  if (tmp) {
    smobs = (smobfuns *)tmp;
    smobs[numsmob].mark = smob->mark;
    smobs[numsmob].free = smob->free;
    smobs[numsmob].print = smob->print;
    smobs[numsmob].equalp = smob->equalp;
    numsmob++;
  }
  ALLOW_INTS;
  if (!tmp) smoberr: wta(MAKINUM((long)numsmob),(char *)NALLOC,"newsmob");
  return tc7_smob + (numsmob-1)*256;
}
ptobfuns *ptobs;
sizet numptob;
long newptob(ptob)
     ptobfuns *ptob;
{
  char *tmp;
  if (255 <= numptob) goto ptoberr;
  DEFER_INTS;
  SYSCALL(tmp = (char *)realloc((char *)ptobs, (1+numptob)*sizeof(ptobfuns)););
  if (tmp) {
    ptobs = (ptobfuns *)tmp;
    ptobs[numptob].mark = ptob->mark;
    ptobs[numptob].free = ptob->free;
    ptobs[numptob].print = ptob->print;
    ptobs[numptob].equalp = ptob->equalp;
    ptobs[numptob].fputc = ptob->fputc;
    ptobs[numptob].fputs = ptob->fputs;
    ptobs[numptob].fwrite = ptob->fwrite;
    ptobs[numptob].fflush = ptob->fflush;
    ptobs[numptob].fgetc = ptob->fgetc;
    ptobs[numptob].fclose = ptob->fclose;
    numptob++;
  }
  ALLOW_INTS;
  if (!tmp) ptoberr: wta(MAKINUM((long)numptob),(char *)NALLOC,"newptob");
  return tc7_port + (numptob-1)*256;
}
SCM markcdr(ptr)
     SCM ptr;
{
  if GC8MARKP(ptr) return BOOL_F;
  SETGC8MARK(ptr);
  return CDR(ptr);
}
SCM mark0(ptr)
     SCM ptr;
{
  SETGC8MARK(ptr);
  return BOOL_F;
}
sizet free0(ptr)
     CELLPTR ptr;
{
  return 0;
}
SCM equal0(ptr1, ptr2)
     SCM ptr1, ptr2;
{
  return (CDR(ptr1)==CDR(ptr2)) ? BOOL_T : BOOL_F;
}

/* statically allocated port for diagnostic messages */
cell tmp_errp = {(SCM)((0L<<8)|tc16_fport|OPN|WRTNG), 0};

static char remsg[] = "remove\n#define ", addmsg[] = "add\n#define ";
extern sizet num_protects;	/* sys_protects now in scl.c */
void init_storage(stack_start_ptr)
     STACKITEM *stack_start_ptr;
{
	sizet j = num_protects;
	/* Because not all protects may get initialized */
	while(j) sys_protects[--j] = BOOL_F;
	tmp_errp.cdr = (SCM)stderr;
	cur_errp = PTR2SCM(&tmp_errp);
	freelist = EOL;
	expmem = 0;

#ifdef SINGLES
	if (sizeof(float) != sizeof(long))
	  fixconfig(remsg,"SINGLES",0);
#endif /* def SINGLES */
#ifdef BIGDIG
	if (2*BITSPERDIG/CHAR_BIT > sizeof(long))
	  fixconfig(remsg,"BIGDIG",0);
# ifndef DIGSTOOBIG
	if (DIGSPERLONG*sizeof(BIGDIG) > sizeof(long))
	  fixconfig(addmsg,"DIGSTOOBIG",0);
# endif
#endif
#ifdef STACK_GROWS_UP
	if (((STACKITEM *)&j - stack_start_ptr) < 0)
	  fixconfig(remsg,"STACK_GROWS_UP",1);
#else
	if ((stack_start_ptr - (STACKITEM *)&j) < 0)
	  fixconfig(addmsg,"STACK_GROWS_UP",1);
#endif

	mtrigger = INIT_MALLOC_LIMIT;
	hplims = (CELLPTR *) must_malloc(2L*sizeof(CELLPTR),s_hplims);
	j = INIT_HEAP_SIZE;
	if ((INIT_HEAP_SIZE != j) || !init_heap_seg((CELLPTR) malloc(j),j))
		alloc_some_heap();
	else expmem = 1;
	heap_org = CELL_UP(hplims[0]);
		/* hplims[0] can change. do not remove heap_org */

	NEWCELL(def_inp);
	SETLENGTH(def_inp,0L,(tc16_fport|OPN|RDNG));
	SETSTREAM(def_inp,stdin);
	NEWCELL(def_outp);
	SETLENGTH(def_outp,0L,(tc16_fport|OPN|WRTNG));
	SETSTREAM(def_outp,stdout);
	NEWCELL(def_errp);
	SETLENGTH(def_errp,0L,(tc16_fport|OPN|WRTNG));
	SETSTREAM(def_errp,stderr);
	cur_inp = def_inp;
	cur_outp = def_outp;
	cur_errp = def_errp;
	dynwinds = EOL;
	NEWCELL(rootcont);
	SETJMPBUF(rootcont,must_malloc((long)sizeof(regs),s_cont));
	SETLENGTH(rootcont,0L,tc7_contin);
	DYNENV(rootcont) = EOL;
	BASE(rootcont) = stack_start_ptr;
	listofnull = cons(EOL,EOL);
	undefineds = cons(UNDEFINED,EOL);
	CDR(undefineds) = undefineds;
	nullstr = makstr(0L);
	nullvect = make_vector(INUM0,UNDEFINED);
	/* NEWCELL(nullvect);
	   SETLENGTH(nullvect,0L,tc7_vector);
	   SETCHARS(nullvect,NULL); */
	symhash = make_vector((SCM)MAKINUM(symhash_dim),EOL);
	sysintern("most-positive-fixnum", (SCM)MAKINUM(MOST_POSITIVE_FIXNUM));
	sysintern("most-negative-fixnum", (SCM)MAKINUM(MOST_NEGATIVE_FIXNUM));
#ifdef BIGDIG
	sysintern("bignum-radix", MAKINUM(BIGRAD));
#endif
	/* flo0 is now setup in scl.c */
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
char s_cells[] = "cells";
SCM gc_for_newcell()
{
	SCM fl;
	DEFER_INTS;
	igc(s_cells);
	ALLOW_INTS;
	if ((gc_cells_collected < MIN_GC_YIELD) || IMP(freelist)) {
	  DEFER_INTS;
	  alloc_some_heap();
	  ALLOW_INTS;
	  growth_mon("number of heaps", (long)(hplim_ind/2),"segments");
	  growth_mon(s_heap,heap_size,s_cells);
	}
	++cells_allocated;
	fl = freelist;
	freelist = CDR(fl);
	return fl;
}

static char	s_bad_type[] = "unknown type in ";
jmp_buf save_regs_gc_mark;

SCM gc()
{
  DEFER_INTS;
  igc("call");
  ALLOW_INTS;
  return UNSPECIFIED;
}
void igc(what)
     char *what;
{
  int j = num_protects;
  long oheap_size = heap_size;
  gc_start(what);
  ++errjmp_bad;
  while(j--) gc_mark(sys_protects[j]);
  FLUSH_REGISTER_WINDOWS;
  /* This assumes that all registers are saved into the jmp_buf */
  setjmp(save_regs_gc_mark);
  mark_locations((STACKITEM *) save_regs_gc_mark,
		 (sizet) sizeof save_regs_gc_mark/sizeof(STACKITEM));
  {
    /* stack_len is long rather than sizet in order to guarantee that
       &stack_len is long aligned */
#ifdef STACK_GROWS_UP
# ifdef nosve
    long stack_len = (STACKITEM *)(&stack_len) - BASE(rootcont);
# else
    long stack_len = stack_size(BASE(rootcont));
# endif
    mark_locations(BASE(rootcont),(sizet)stack_len);
#else
# ifdef nosve
    long stack_len = BASE(rootcont) - (STACKITEM *)(&stack_len);
# else
    long stack_len = stack_size(BASE(rootcont));
# endif
    mark_locations((BASE(rootcont) - stack_len),(sizet)stack_len);
#endif
  }
  gc_sweep();
  --errjmp_bad;
  gc_end();
  if (oheap_size != heap_size) {
    ALLOW_INTS;
    growth_mon(s_heap,heap_size,s_cells);
    DEFER_INTS;
  }
}

void free_storage()
{
  sizet i = 0;
  DEFER_INTS;
  gc_start("free");
  ++errjmp_bad;
  cur_inp = BOOL_F; cur_outp = BOOL_F; cur_errp = PTR2SCM(&tmp_errp);
  gc_mark(def_inp);		/* don't want to close stdin */
  gc_mark(def_outp);		/* don't want to close stdout */
  gc_mark(def_errp);		/* don't want to close stderr */
  gc_sweep();
  rootcont = BOOL_F;
  while (i<hplim_ind) {		/* free heap segments */
    CELLPTR ptr = CELL_UP(hplims[i]);
    sizet seg_size = CELL_DN(hplims[i+1]) - ptr;
    heap_size -= seg_size;
    hplim_ind -= 2;
    must_free((char *)hplims[i]);
    hplims[i] = 0;
/*    growth_mon(s_heap,heap_size,s_cells); */
    i += 2;
  }
  if (hplim_ind) wta((SCM)MAKINUM(hplim_ind),s_hplims,"");
  if (heap_size) wta(MAKINUM(heap_size),s_heap,"");
  /* I don't know why these 2 don't work */
/*  if (cells_allocated) wta(MAKINUM(cells_allocated),s_heap,""); */
/*  if (mallocated) wta(MAKINUM(mallocated),"malloc",""); */
  must_free((char *)hplims);
  hplims = 0;
  must_free((char *)smobs);
  smobs = 0;
  gc_end();
  ALLOW_INTS; /* A really bad idea, but printing does it anyway. */
  exit_report();
  must_free((char *)ptobs);
  ptobs = 0;
  lmallocated = mallocated = 0;
  /* Can't do gc_end() here because it uses ptobs which have been freed */
}

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
    i = LENGTH(ptr);
    if (i==0) break;
    while(--i>0) if NIMP(VELTS(ptr)[i]) gc_mark(VELTS(ptr)[i]);
    ptr = VELTS(ptr)[0];
    goto gc_mark_loop;
  case tc7_contin:
    if GC8MARKP(ptr) break;
    SETGC8MARK(ptr);
    mark_locations(VELTS(ptr),
		   (sizet)(LENGTH(ptr) + sizeof(regs)/sizeof(STACKITEM)));
    break;
  case tc7_bvect:
  case tc7_ivect:
  case tc7_uvect:
  case tc7_fvect:
  case tc7_dvect:
  case tc7_cvect:
  case tc7_string:
  case tc7_msymbol:
    /*		if GC8MARKP(ptr) break;*/
    SETGC8MARK(ptr);
  case tc7_ssymbol:
  case tcs_subrs:
    break;
  case tc7_port:
    i = PTOBNUM(ptr);
    if (!(i < numptob)) goto def;
    ptr = (ptobs[i].mark)(ptr);
    goto gc_mark_loop;
    break;
  case tc7_smob:
    if GC8MARKP(ptr) break;
    switch TYP16(ptr) {		/* should be faster than going through smobs */
    case tc_free_cell:
      /* printf("found free_cell %X ",ptr); fflush(stdout); */
      SETGC8MARK(ptr);
      CDR(ptr) = EOL;
      break;
    case tcs_bignums:
    case tc16_flo:
      SETGC8MARK(ptr);
      break;
    default:
      i = SMOBNUM(ptr);
      if (!(i < numsmob)) goto def;
      ptr = (smobs[i].mark)(ptr);
      goto gc_mark_loop;
    }
    break;
  default: def: wta(ptr,s_bad_type,"gc_mark");
  }
}

void mark_locations(x,n)
STACKITEM x[];
sizet n;
{
	register long m = n;
	register int i,j;
	register CELLPTR ptr;
	while(0 <= --m) if CELLP(*(SCM **)&x[m]) {
		ptr = (CELLPTR)SCM2PTR((*(SCM **)&x[m]));
		i = 0;
		j = hplim_ind;
		do {
			if PTR_GT(hplims[i++], ptr) break;
			if PTR_LE(hplims[--j], ptr) break;
			if ((i != j)
			    && PTR_LE(hplims[i++], ptr)
			    && PTR_GT(hplims[--j], ptr)) continue;
			/* if NFREEP(*(SCM **)&x[m]) */ gc_mark(*(SCM *)&x[m]);
			break;
		} while(i<j);
	}
}

static void gc_sweep()
{
  register CELLPTR ptr;
#ifdef POINTERS_MUNGED
  register SCM scmptr;
#else
# define scmptr (SCM)ptr
#endif
  register SCM nfreelist = EOL;
  register long n = 0,m = 0;
  register sizet j;
  sizet i = 0;
  sizet seg_size;
  while (i<hplim_ind) {
    ptr = CELL_UP(hplims[i++]);
    seg_size = CELL_DN(hplims[i++]) - ptr;
    for(j = seg_size;j--;++ptr) {
#ifdef POINTERS_MUNGED
      scmptr = PTR2SCM(ptr);
#endif
      switch TYP7(scmptr) {
      case tcs_cons_imcar:
      case tcs_cons_nimcar:
      case tcs_cons_gloc:
      case tcs_closures:
	if GCMARKP(scmptr) goto cmrkcontinue;
	break;
      case tc7_vector:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += (LENGTH(scmptr)*sizeof(SCM));
      freechars:
	must_free(CHARS(scmptr));
/*	SETCHARS(scmptr,0);*/
	break;
      case tc7_bvect:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += sizeof(long)*((LENGTH(scmptr)+LONG_BIT-1)/LONG_BIT);
	goto freechars;
      case tc7_ivect:
      case tc7_uvect:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)*sizeof(long);
	goto freechars;
      case tc7_fvect:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)*sizeof(float);
	goto freechars;
      case tc7_dvect:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)*sizeof(double);
	goto freechars;
      case tc7_cvect:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)*2*sizeof(double);
	goto freechars;
      case tc7_string:
      case tc7_msymbol:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)+1;
	goto freechars;
      case tc7_contin:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	m += LENGTH(scmptr)*sizeof(STACKITEM) + sizeof(regs);
	goto freechars;
      case tc7_ssymbol:
      case tcs_subrs:
	continue;
      case tc7_port:
	if GC8MARKP(scmptr) goto c8mrkcontinue;
	if OPENP(scmptr) {
	  int k = PTOBNUM(scmptr);
	  if (!(k < numptob)) goto sweeperr;
	  (ptobs[k].free)(STREAM(scmptr));
	  gc_ports_collected++;
	  SETSTREAM(scmptr,0);
	  CAR(scmptr) &= ~OPN;
	}
	break;
      case tc7_smob:
	switch GCTYP16(scmptr) {
	case tc_free_cell:
	  if GC8MARKP(scmptr) goto c8mrkcontinue;
	  break;
#ifdef BIGDIG
	case tcs_bignums:
	  if GC8MARKP(scmptr) goto c8mrkcontinue;
	  m += (NUMDIGS(scmptr)*BITSPERDIG/CHAR_BIT);
	  goto freechars;
#endif /* def BIGDIG */
	case tc16_flo:
	  if GC8MARKP(scmptr) goto c8mrkcontinue;
	  switch ((int)(CAR(scmptr)>>16)) {
	  case (IMAG_PART | REAL_PART)>>16:
	    m += sizeof(double);
	  case REAL_PART>>16:
	  case IMAG_PART>>16:
	    m += sizeof(double);
	    goto freechars;
	  case 0:
	    break;
	  default:
	    goto sweeperr;
	  }
	  break;
	default:
	  if GC8MARKP(scmptr) goto c8mrkcontinue;
	  {
	    int k = SMOBNUM(scmptr);
	    if (!(k < numsmob)) goto sweeperr;
	    m += (smobs[k].free)(scmptr);
	  }
	}
	break;
      default: sweeperr: wta(scmptr,s_bad_type,"gc_sweep");
      }
      ++n;
      CAR(scmptr) = (SCM)tc_free_cell;
      CDR(scmptr) = nfreelist;
      nfreelist = scmptr;
      continue;
    c8mrkcontinue:
      CLRGC8MARK(scmptr);
      continue;
    cmrkcontinue:
      CLRGCMARK(scmptr);
    }
#ifdef GC_FREE_SEGMENTS
    if (n==seg_size) {
      heap_size -= seg_size;
      must_free((char *)hplims[i-2]);
      hplims[i-2] = 0;
      for(j = i;j < hplim_ind;j++) hplims[j-2] = hplims[j];
      hplim_ind -= 2;
      i -= 2;			/* need to scan segment just moved. */
      nfreelist = freelist;
    }
    else
#endif /* ifdef GC_FREE_SEGMENTS */
	freelist = nfreelist;
    gc_cells_collected += n;
    n = 0;
  }
  lcells_allocated += (heap_size - gc_cells_collected - cells_allocated);
  cells_allocated = (heap_size - gc_cells_collected);
  lmallocated -= m;
  mallocated -= m;
  gc_malloc_collected = m;
}
