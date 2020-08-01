#include "scm.h"
#include "regex.h"
#include <stdio.h>

/* Posix regexp bindings.  */

static char rcsid[] =
   "$Id: rgx.c,v 1.4.1.2 1993/01/08 05:48:12 schwartz Exp schwartz $";

static char s_regex[] = "regex";
static char s_regcomp[] = "regcomp", s_regerror[] = "regerror";
static char s_regexec[] = "regexec", s_regmatp[] = "regmatch?";
#define s_error &s_regerror[3]

#define RGX(obj) ((regex_t*)CDR(obj))
sizet fregex(ptr)
     CELLPTR ptr;
{
  regfree(RGX(ptr));
  free(CHARS(ptr));
  return sizeof(regex_t);
}
int prinregex(exp,port,writing)
     SCM exp; SCM port; int writing;
{
  lputs("#<regex ",port);
  intprint(CDR(exp),16,port);
  lputc('>',port);
  return 1;
}
int tc16_rgx;
static smobfuns rgxsmob = {mark0,fregex,prinregex};

SCM lregerror(scode)
     SCM scode;
{
  int code, len;
  SCM str;
  ASSERT(INUMP(scode),scode,ARG1,s_regerror);
  code = INUM(scode);
  if (code < 0)
    return makfromstr("Invalid code", sizeof("Invalid code")-1);
  /* XXX - is regerror posix or not? */
#ifdef __REGEXP_LIBRARY_H__
  /* XXX - gnu regexp doesn't use the re parameter, so we will
     ignore it in a very untidy way. */
  len = regerror(code, 0, 0, 0);
  str = makstr(len-1);
  regerror(code, 0, CHARS(str), len);
#else
  str = makfromstr(s_error, (sizet)5);
#endif
  return str;
}

SCM lregcomp(pattern)
     SCM pattern;
{
  SCM z;
  int i;
  regex_t *prog;
  ASSERT(NIMP(pattern) && STRINGP(pattern), pattern, ARG1, s_regcomp);
  NEWCELL(z);
  DEFER_INTS;
  SETCHARS(z, prog = (regex_t*)must_malloc((long)sizeof(regex_t),s_regex));
  CAR(z) = tc16_rgx;
#ifdef __REGEXP_LIBRARY_H__
  for(i=sizeof(regex_t);i--;((char *)prog)[i] = 0);
#endif
  ALLOW_INTS;
  i = regcomp(prog, CHARS(pattern), REG_EXTENDED);
  return (i) ? MAKINUM(i) : z;
}

SCM lregexec(prog, str)
     SCM prog,str;
{
  size_t nsub;
  SCM ans, pmatch;
  regmatch_t *pm;
  int flags = 0;		/* XXX - optional arg? */
  ASSERT(NIMP(prog) && tc16_rgx==CAR(prog), prog, ARG1, s_regexec);
  ASSERT(NIMP(str) && STRINGP(str), str, ARG2, s_regexec);
  nsub = RGX(prog)->re_nsub + 1; /* XXX - is this posix? */
  pmatch = makstr((long)(nsub * sizeof(regmatch_t)));
  pm = (regmatch_t *)CDR(pmatch);
  if (regexec(RGX(prog), CHARS(str), nsub, pm, flags) != 0)
    ans = BOOL_F;
  else {
    ans = make_vector(MAKINUM(2L * nsub), MAKINUM(-1L));
    while (nsub--) {
/* #ifdef __REGEXP_LIBRARY_H__ */
      VELTS(ans)[2*nsub+0] = MAKINUM(pm[nsub].rm_so);
      VELTS(ans)[2*nsub+1] = MAKINUM(pm[nsub].rm_eo);
/* #else
      VELTS(ans)[2*nsub+0] = MAKINUM(pm[nsub].rm_sp - CHARS(str));
      VELTS(ans)[2*nsub+1] = MAKINUM(pm[nsub].rm_ep - CHARS(str));
   #endif */
    }
  }
  return ans;
}

SCM lregmatp(prog, str)
     SCM prog,str;
{
  int flags = 0;		/* XXX - optional arg? */
  ASSERT(NIMP(prog) && tc16_rgx==CAR(prog), prog, ARG1, s_regmatp);
  ASSERT(NIMP(str) && STRINGP(str), str, ARG2, s_regmatp);
  flags = regexec(RGX(prog), CHARS(str), 0, NULL, flags);
  if (!flags) return BOOL_T;
  if (REG_NOMATCH!=flags) wta(MAKINUM(flags),s_error,s_regmatp);
  return BOOL_F;
}

void init_rgx()
{
  tc16_rgx = newsmob(&rgxsmob);
  make_subr(s_regcomp,tc7_subr_1,lregcomp);
  make_subr(s_regexec,tc7_subr_2,lregexec);
  make_subr(s_regmatp,tc7_subr_2,lregmatp);
  make_subr(s_regerror,tc7_subr_1,lregerror);
  add_feature(s_regex);
}
