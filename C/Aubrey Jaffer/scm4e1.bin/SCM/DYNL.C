/* Scheme implementation intended for JACAL.
   Copyright (C) 1993, 1994 Aubrey Jaffer.

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

#ifdef DLD
#include "dld.h"

void listundefs()
{
  int i;
  char **undefs = dld_list_undefined_sym();
  puts("   undefs:");
  for(i = dld_undefined_sym_count;i--;) puts(undefs[i]);
  free(undefs);
}

static char s_link[] = "dld:link", s_fcall[] = "dld:call";
SCM llink(fname)
     SCM fname;
{
  int status;
  ASSERT(NIMP(fname) && STRINGP(fname), fname, ARG1, s_link);
  DEFER_INTS;
  status = dld_link(CHARS(fname));
  ALLOW_INTS;
  if (!status) return fname;
  if (DLD_ENOFILE==status) return BOOL_F;
  if (DLD_EBADOBJECT==status) return BOOL_F;
  dld_perror("DLD");
  return BOOL_F;
}
SCM fcall(symb)
     SCM symb;
{
  void (*func)() = 0;
  int i;
  ASSERT(NIMP(symb) && STRINGP(symb), symb, ARG1, s_fcall);
  DEFER_INTS;
  if (i = dld_function_executable_p(CHARS(symb)))
    func = (void (*) ()) dld_get_func(CHARS(symb));
  else dld_perror("DLDP");
  ALLOW_INTS;
  if (!i) listundefs();
  if (!func) {
    dld_perror("DLD");
    return BOOL_F;
  }
  (*func) ();
  return BOOL_T;
}
static char s_unlink[] = "dld:unlink";
SCM lunlink(fname)
     SCM fname;
{
  int status;
  ASSERT(NIMP(fname) && STRINGP(fname), fname, ARG1, s_unlink);
  DEFER_INTS;
  status = dld_unlink_by_file(CHARS(fname),1);
  ALLOW_INTS;
  if (!status) return BOOL_T;
  dld_perror("DLD");
  return BOOL_F;
}
static iproc subr1s[] = {
	{s_link, llink},
	{s_unlink, lunlink},
	{s_fcall, fcall},
	{0,0}};
void init_dynl()
{
#ifndef RTL
  if (dld_init (dld_find_executable (CHARS(CAR(progargs))))) {
    dld_perror("DLD:");
/*    wta(CAR(progargs),"couldn't init","dld"); */
    return;
  }
#endif
  init_iprocs(subr1s, tc7_subr_1);
  add_feature("dld");
}
#else

#ifdef hpux
#include "dl.h"

#define SHL(obj) ((shl_t*)CDR(obj))
sizet frshl(ptr)
     CELLPTR ptr;
{
  free(CHARS(ptr));
  return sizeof(shl_t);
}
int prinshl(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  lputs("#<shl ",port);
  intprint(CDR(exp),16,port);
  lputc('>',port);
  return 1;
}
int tc16_shl;
static smobfuns shlsmob = {mark0,frshl,prinshl};

static char s_load[] = "shl:load", s_fcall[] = "shl:call";
SCM lload(fname)
     SCM fname;
{
  SCM z;
  shl_t *shl;
  ASSERT(NIMP(fname) && STRINGP(fname), fname, ARG1, s_load);
  DEFER_INTS;
  shl = shl_load(CHARS(fname), BIND_DEFERRED | BIND_VERBOSE ,0L);
  if (NULL==shl) {
    ALLOW_INTS;
    return BOOL_F;
  }
  NEWCELL(z);
  SETCHARS(z, (shl_t*)must_malloc((long)sizeof(shl_t),"shl"));
  CAR(z) = tc16_shl;
  ALLOW_INTS;
  return z;
}
SCM fcall(symb,shl)
     SCM symb,shl;
{
  void (*func)() = 0;
  ASSERT(NIMP(symb) && STRINGP(symb), symb, ARG1, s_fcall);
  ASSERT(NIMP(shl) && CAR(shl)==tc16_shl, shl, ARG2, s_fcall);
  DEFER_INTS;
  shl_findsym(SHL(shl),CHARS(symb),TYPE_PROCEDURE,&func);
  ALLOW_INTS;
  if (!func) return BOOL_F;
  (*func) ();
  return BOOL_T;
}
static char s_unload[] = "shl:unload";
SCM lunload(shl)
     SCM shl;
{
  int status;
  ASSERT(NIMP(shl) && CAR(shl)==tc16_shl, shl, ARG1, s_unload);
  DEFER_INTS;
  status = shl_unload(SHL(shl));
  ALLOW_INTS;
  if (!status) return BOOL_T;
  return BOOL_F;
}
static iproc subr1s[] = {
	{s_load, lload},
	{s_unload, lunload},
	{0,0}};
void init_dynl()
{
  tc16_shl = newsmob(&shlsmob);
  init_iprocs(subr1s, tc7_subr_1);
  make_subr(s_fcall,tc7_subr_2,fcall);
  add_feature("shl");
}
#endif
#endif

#ifdef vms
/* This permits dynamic linking. For example, the procedure of 0 arguments
   from a file could be the initialization procedure.
   (vms:dynamic-link-call "MYDISK:[MYDIR].EXE" "foo" "INIT_FOO")
   The first argument specifies the directory where the file specified
   by the second argument resides.  The current directory would be
   "SYS$DISK:[].EXE".
   The second argument cannot contain any punctuation.
   The third argument probably needs to be uppercased to mimic the VMS linker.
   */

#include <descrip.h>
#include <ssdef.h>
#include <rmsdef.h>

struct dsc$descriptor *descriptorize(x,buff)
     struct dsc$descriptor *x;
     SCM buff;
{(*x).dsc$w_length = LENGTH(buff);
 (*x).dsc$a_pointer = CHARS(buff);
 (*x).dsc$b_class = DSC$K_CLASS_S;
 (*x).dsc$b_dtype = DSC$K_DTYPE_T;
 return(x);}

static char s_dynl[] = "vms:dynamic-link-call";
SCM dynl(dir,symbol,fname)
     SCM dir,symbol,fname;
{
  struct dsc$descriptor fnamed,symbold,dird;
  void (*fcn)();
  long retval;
  ASSERT(IMP(dir) || STRINGP(dir),dir,ARG1,s_dynl);
  ASSERT(NIMP(fname) && STRINGP(fname),fname,ARG2,s_dynl);
  ASSERT(NIMP(symbol) && STRINGP(symbol),symbol,ARG3,s_dynl);
  descriptorize(&fnamed,fname);
  descriptorize(&symbold,symbol);
  DEFER_INTS;
  retval = lib$find_image_symbol(&fnamed, &symbold, &fcn,
				 IMP(dir) ? 0 : descriptorize(&dird, dir));
  if (SS$_NORMAL != retval) {
    /* wta(MAKINUM(retval),"vms error",s_dynl); */
    ALLOW_INTS;
    return BOOL_F;
  }
  (*fcn)();
  ALLOW_INTS;
  return BOOL_T;
}

void init_dynl()
{
  make_subr(s_dynl,tc7_subr_3,dynl);
}
#endif


#ifdef SUN_DL
#ifdef DLD
#error "Can't use DLD and the System Dynamic Linker"
#endif
#include <dlfcn.h>

#define SHL(obj) ((void*)CDR(obj))

#ifdef SVR4		/* Solaris 2. */
#define DLOPEN_MODE	RTLD_LAZY
#else
#define DLOPEN_MODE	1	/* Thats what it says in the man page. */
#endif

sizet frshl(ptr)
	CELLPTR ptr;
{
#if 0
  /* Should freeing a shl close and possibly unmap the object file it */
  /* refers to? */
  if(SHL(ptr))
    dlclose(SHL(ptr));
#endif
  return 0;	
}

int prinshl(exp,port,writing)
	SCM exp; SCM port; int writing;
{
  lputs("#<shl ",port);
  intprint(CDR(exp),16,port);
  lputc('>',port);
  return 1;
}
int tc16_shl;
static smobfuns shlsmob = {mark0,frshl,prinshl};

static char s_load[] = "shl:load", s_fcall[] = "shl:call";
SCM lload(fname)
	SCM fname;
{
  SCM z;
  void *handle;
  ASSERT(NIMP(fname) && STRINGP(fname), fname, ARG1, s_load);
  DEFER_INTS;
  handle = dlopen(CHARS(fname), DLOPEN_MODE);	
  if (NULL==handle) {
    ALLOW_INTS;
    return BOOL_F;
  }
  NEWCELL(z);
  SETCHARS(z, handle);
  CAR(z) = tc16_shl;
  ALLOW_INTS;
  return z;
}
 
SCM fcall(symb,shl)
	SCM symb,shl;
{
  void (*func)() = 0;
  ASSERT(NIMP(symb) && STRINGP(symb), symb, ARG1, s_fcall);
  ASSERT(NIMP(shl) && CAR(shl)==tc16_shl, shl, ARG2, s_fcall);
  DEFER_INTS;
  func = dlsym(SHL(shl), CHARS(symb));
  ALLOW_INTS;
  if (!func) return BOOL_F;
  (*func) ();
  return BOOL_T;
}
static char s_unload[] = "shl:unload";
SCM lunload(shl)
	SCM shl;
{
  int status;
  ASSERT(NIMP(shl) && CAR(shl)==tc16_shl, shl, ARG1, s_unload);
  DEFER_INTS;
  status = dlclose(SHL(shl));
  SETCHARS(shl, NULL);
  ALLOW_INTS;
  if (!status) return BOOL_T;
  return BOOL_F;
}
static iproc subr1s[] = {
{s_load, lload},
{s_unload, lunload},
{0,0}};

void init_dynl()
{
  tc16_shl = newsmob(&shlsmob);
  init_iprocs(subr1s, tc7_subr_1);
  make_subr(s_fcall,tc7_subr_2,fcall);
  add_feature("sun-dl");
}
#endif	/* SUN_DL */


