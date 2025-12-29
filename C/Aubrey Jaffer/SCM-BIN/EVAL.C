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
#include "scm.h"

typedef struct {long sname;double (*dproc)();} dsubr;
#define DSUBRF(x) (((dsubr *)(x))->dproc)

#define I_VAL(x) (CDR((x)-1L))
#define EVALCELLCAR(x,env) SYMBOLP(CAR(x))?*lookupcar(x,env):ceval(CAR(x),env)
#ifdef MEMOIZE_LOCALS
#define EVALIMP(x,env) (ILOCP(x)?*ilookup((x),env):x)
#else
#define EVALIMP(x,env) x
#endif
#define EVALCAR(x,env) (NCELLP(CAR(x))?(IMP(CAR(x))?EVALIMP(CAR(x),env):\
					I_VAL(CAR(x))):EVALCELLCAR(x,env))
/* #define EVALCAR(x,env) (IMP(CAR(x))?CAR(x):ceval(CAR(x),(env))) */

char s_apply[]="apply", s_map[]="map", s_for_each[]="for-each";

#define EXTEND_ENV(formals,actuals,env) cons2r(formals,actuals,env)

#ifdef MEMOIZE_LOCALS
SCM *ilookup(iloc,env)
SCM iloc,env;
{
  register int ir = IFRAME(iloc);
  register SCM er = env;
  for(;ir != 0;--ir) er = CDR(er);
  er = CAR(er);
  for(ir = IDIST(iloc);ir != 0;--ir) er = CDR(er);
  if ICDRP(iloc) return &CDR(er);
  return &CAR(CDR(er));
}
#endif
SCM *lookupcar(vloc,genv)
SCM vloc,genv;
{
  SCM env = genv;
  register SCM *al, fl, var = CAR(vloc);
#ifdef MEMOIZE_LOCALS
  register SCM iloc = ILOC00;
#endif
  for(;NIMP(env);env = CDR(env)) {
    al = &CAR(env);
    for(fl = CAR(*al);NIMP(fl);fl = CDR(fl)) {
      if NCONSP(fl)
	if (fl == var) {
#ifdef MEMOIZE_LOCALS
	  CAR(vloc) = iloc + ICDR;
#endif
	  return &CDR(*al);
	}
	else break;
      al = &CDR(*al);
      if (CAR(fl) == var) {
#ifdef MEMOIZE_LOCALS
	CAR(vloc) = iloc;
#endif
	return &CAR(*al);
      }
#ifdef MEMOIZE_LOCALS
      iloc += IDINC;
#endif
    }
#ifdef MEMOIZE_LOCALS
    iloc = (~IDSTMSK) & (iloc + IFRINC);
#endif
  }
#ifndef RECKLESS
  if (NNULLP(env) || UNBNDP(VCELL(var)))
    everr(vloc,genv,var,
	  NULLP(env)?"unbound variable: ":"damaged environment","");
#endif
  CAR(vloc) += 1;
  return &VCELL(var);
}
SCM eval_args(l,env)
SCM l,env;
{
	SCM res = EOL,*lloc = &res;
	while NIMP(l) {
		*lloc = cons(EVALCAR(l,env),EOL);
		lloc = &CDR(*lloc);
		l = CDR(l);
	}
	return res;
}

SCM iqq(form, env, depth)
SCM form, env;
int depth;
{
  SCM tmp;
  int edepth = depth;
  if IMP(form) return form;
  if VECTORP(form) {
    long i = LENGTH(form);
    SCM *data = VELTS(form);
    tmp = EOL;
    for(;--i>=0;) tmp = cons(data[i],tmp);
    return vector(iqq(tmp,env,depth));
  }
  if NCONSP(form) return form;
  tmp = CAR(form);
  if (tmp == I_QUASIQUOTE) {
    depth++;
    goto label;
  }
  if (tmp == I_UNQUOTE) {
    --depth;
  label:
    form = CDR(form);
    ASSERT(NIMP(form) && ECONSP(form) && NULLP(CDR(form)),
	   form,ARG1,ISYMCHARS(I_QUASIQUOTE));
    if (depth == 0) return EVALCAR(form,env);
    return cons2(tmp,iqq(CAR(form),env,depth),EOL);
  }
  if (NIMP(tmp) && (CAR(tmp) == I_UQ_SPLICING)) {
    tmp = CDR(tmp);
    if (--edepth == 0)
      return append(cons2(EVALCAR(tmp,env),iqq(CDR(form),env,depth),EOL));
  }
  return cons(iqq(CAR(form),env,edepth),iqq(CDR(form),env,depth));
}
cell dummy_cell = {EOL, EOL};
SCM ceval(x,env)
SCM x,env;
{
  union {SCM *lloc; SCM arg1;} t;
  SCM proc;
 loop:
  switch TYP7(x) {
  case tcs_symbols:
    /* only happens when called at top level */
    CAR(&dummy_cell) = x;
/*    CDR(&dummy_cell) = EOL; */
    x = (SCM)&dummy_cell;
    goto retval;
  case (127 & I_AND):
    x = CDR(x);
    if NULLP(x) return BOOL_T;
    t.arg1 = x;
    while(NNULLP(t.arg1 = CDR(t.arg1)))
      if FALSEP(EVALCAR(x,env)) return BOOL_F;
      else x = t.arg1;
    goto carloop;
  case (127 & I_BEGIN):
  cdrxbegin:
    x = CDR(x);
  begin:
    t.arg1 = x;
    while(NNULLP(t.arg1 = CDR(t.arg1))) {
      SIDEVAL(CAR(x),env);
      x = t.arg1;
    }
  carloop:			/* eval car of last form in list */
    if NCELLP(CAR(x)) {
      x = CAR(x);
      return IMP(x)?EVALIMP(x,env):I_VAL(x);
    }
    if SYMBOLP(CAR(x))
retval:
      return *lookupcar(x,env);
    x = CAR(x);
    goto loop;			/* tail recurse */
  case (127 & I_CASE):
    x = CDR(x);
    proc = EVALCAR(x,env);
    while(NIMP(x = CDR(x))) {
      ASSERT(CONSP(x),x,ARG1,ISYMCHARS(I_CASE));
      t.arg1 = CAR(x);
      ASSERT(NIMP(t.arg1) && CONSP(t.arg1),t.arg1,ARG1,ISYMCHARS(I_CASE));
#ifndef FLOATS
#define memv memq
#endif
      if ((I_ELSE == CAR(t.arg1)) || NFALSEP(memv(proc,CAR(t.arg1)))) {
	x = CDR(t.arg1);
	goto begin;
      }
    }
    return UNSPECIFIED;
  case (127 & I_COND):
    x = CDR(x);
    while(NIMP(x)) {
      ASSERT(CONSP(x),x,ARG1,ISYMCHARS(I_COND));
      t.arg1 = CAR(x);
      ASSERT(NIMP(t.arg1) && ECONSP(t.arg1),t.arg1,ARG1,ISYMCHARS(I_COND));
      t.arg1 = EVALCAR(t.arg1,env);
      if NFALSEP(t.arg1) {
	x = CDR(CAR(x));
	if NULLP(x) return t.arg1;
	ASSERT(ECONSP(x),x,ARG2,ISYMCHARS(I_COND));
	if (I_ARROW != CAR(x)) goto begin;
	proc = CDR(x);
	ASSERT(ECONSP(proc),proc,ARG3,ISYMCHARS(I_COND));
	proc = EVALCAR(proc,env);
/* was	return apply(proc,t.arg1,listofnull); */
	ASRTGO(NIMP(proc),badfun);
	goto evap1;
      }
      x = CDR(x);
    }
    return UNSPECIFIED;
  case (127 & I_DO):
    x = CDR(x);
    {
      SCM vars = EOL,inits = EOL;
      t.arg1 = CAR(x);
      while NIMP(t.arg1) {
	ASSERT(CONSP(t.arg1),x,ARG1,ISYMCHARS(I_DO));
	proc = CAR(t.arg1);
	ASSERT(NIMP(proc) && CONSP(proc) && SYMBOLP(CAR(proc)),
	       x,ARG1,ISYMCHARS(I_DO));
	vars = cons(CAR(proc),vars);
	proc = CDR(proc);
	ASSERT(NIMP(proc) && ECONSP(proc), x,ARG1,ISYMCHARS(I_DO));
	if IMP(CDR(proc))
	  CDR(proc) = cons(CAR(vars),EOL);
	inits = cons(EVALCAR(proc,env),inits);
	t.arg1 = CDR(t.arg1);
      }
      env = EXTEND_ENV(vars,inits,env);
      while (1) {
	env = EXTEND_ENV(vars,inits,CDR(env));
	t.arg1 = CDR(x);
	proc = CAR(t.arg1);
	if NFALSEP(EVALCAR(proc,env)) {
	  x = CDR(proc);
	  if NULLP(x) return UNSPECIFIED;
	  goto begin;
	}
	while NIMP(t.arg1 = CDR(t.arg1))
	  SIDEVAL(CAR(t.arg1),env);
	inits = EOL;
	t.arg1=CAR(x);
	for(;NIMP(t.arg1);t.arg1=CDR(t.arg1)) {
	  proc=CDR(CDR(CAR(t.arg1)));
	  inits = cons(EVALCAR(proc,env), inits);
	}
      }
    }
  case (127 & I_IF):
    x = CDR(x);
    if NFALSEP(EVALCAR(x,env)) x = CDR(x);
    else if IMP(x = CDR(CDR(x))) return UNSPECIFIED;
    goto carloop;
  case (127 & I_LET):
    t.arg1 = CDR(x);
    if IMP(CAR(t.arg1)) {
      x = t.arg1;
    nullet:
      ASSERT(NULLP(CAR(x)),x,ARG1,ISYMCHARS(I_LET));
      env = EXTEND_ENV(EOL,EOL,env);
      x = CDR(x);
      ASSERT(NIMP(x),x,ARG2,ISYMCHARS(I_LET));
      goto begin;
    }
    if SYMBOLP(CAR(t.arg1)) t.arg1 = CAR(CDR(t.arg1)); /* named let */
    else t.arg1 = CAR(t.arg1);
    {				/* binding list is now in t.arg1 */
      SCM vars = NULLP(t.arg1) ? t.arg1 : CAR(t.arg1);
      while NIMP(t.arg1) {	/* destructively rearrange let-list */
	ASSERT(CONSP(t.arg1),t.arg1,ARG1,ISYMCHARS(I_LET));
	proc = CAR(t.arg1);	/* arg list */
	ASSERT(ilength(proc)==2,t.arg1,ARG1,ISYMCHARS(I_LET));
	CAR(t.arg1) = CAR(CDR(proc));
	if IMP(CDR(t.arg1)) CDR(proc) = EOL;
	else CDR(proc) = CAR(CDR(t.arg1));
	t.arg1 = CDR(t.arg1);
      }
      if SYMBOLP(CAR(CDR(x))) {	/* named let */
	t.arg1 = CDR(x);
	CAR(x) = cons2(I_LAMBDA, vars, CDR(CDR(t.arg1)));
	CAR(x) = cons2(I_LETREC,
		       cons2r(CAR(t.arg1), cons(CAR(x),EOL), EOL),
		       cons(CAR(t.arg1),EOL));
	CDR(x) = CAR(CDR(t.arg1));
	goto loop;
      }
      CAR(x) = cons2(I_LAMBDA,vars,CDR(CDR(x)));
      CDR(x) = CAR(CDR(x));
      goto loop;
    }
  case (127 & I_LETSTAR):
    x = CDR(x);
    proc = CAR(x);
    if IMP(proc) goto nullet;
    while NIMP(proc) {
      ASSERT(CONSP(proc),x,ARG1,ISYMCHARS(I_LETSTAR));
      t.arg1 = CAR(proc);
      /* ASSERT(CONSP(t.arg1) && ECONSP(CDR(t.arg1))  &&
	 SYMBOLP(CAR(t.arg1)),x,ARG1,ISYMCHARS(I_LETSTAR)); */
      env = EXTEND_ENV(CAR(t.arg1), EVALCAR(CDR(t.arg1),env), env);
      proc = CDR(proc);
    }
    goto cdrxbegin;
  case (127 & I_LETREC):
    x = CDR(x);
    proc = CAR(x);
    if IMP(proc) goto nullet;
    t.arg1 = EOL;
    while NIMP(proc) {
      ASSERT((NIMP(proc) && CONSP(proc)) ||
	     (NIMP(CAR(proc)) && CONSP(CAR(proc)) && SYMBOLP(CAR(CAR(proc)))),
	     x,ARG1,ISYMCHARS(I_LETREC));
      t.arg1 = cons(CAR(CAR(proc)),t.arg1);
      proc = CDR(proc);
    }
    env = EXTEND_ENV(t.arg1,undefineds,env);
    t.arg1 = EOL;
    proc = CAR(x);
    while NIMP(proc) {
      SCM tmp = CDR(CAR(proc));
      t.arg1 = cons(EVALCAR(tmp,env), t.arg1);
      proc = CDR(proc);
    }
    CDR(CAR(env)) = t.arg1;
    goto cdrxbegin;
  case (127 & I_OR):
    x = CDR(x);
    if NULLP(x) return BOOL_F;
    t.arg1 = x;
    while(NNULLP(t.arg1 = CDR(t.arg1))) {
      x = EVALCAR(x,env);
      if NFALSEP(x) return x;
      x = t.arg1;
    }
    goto carloop;
  case (127 & I_DEFINE):
    x = CDR(x);
    proc = CAR(x);
    x = CDR(x);
    while (NIMP(proc) && CONSP(proc)) {
      x = cons(cons2(I_LAMBDA,CDR(proc),x),EOL);
      proc = CAR(proc);
    }
    ASSERT(NIMP(proc) && SYMBOLP(proc),proc,ARG1,ISYMCHARS(I_DEFINE));
    ASSERT(NIMP(x) && ECONSP(x),x,WNA,ISYMCHARS(I_DEFINE));
    x = EVALCAR(x,env);
    if NNULLP(env) {
      env = CAR(env);
      CAR(env) = cons(proc,CAR(env));
      CDR(env) = cons(x,CDR(env));
    }
    else {
      t.arg1 = VCELL(proc);
#ifndef RECKLESS
      if (NIMP(t.arg1)  &&
	  SUBRP(t.arg1)  &&
	  ((SCM) SNAME(t.arg1) == NAMESTR(proc)))
	warn("redefining built-in ", CHARS(NAMESTR(proc)));
#endif
      VCELL(proc) = x;
    }
    return UNSPECIFIED;
  case (127 & I_LAMBDA):
    x = CDR(x);
    ASSERT(NIMP(x) && CONSP(x)  &&
	   NIMP(CDR(x)) && ECONSP(CDR(x)),x,ARG1,ISYMCHARS(I_LAMBDA));
    return closure(x,env);
  case (127 & I_QUOTE):
    x = CDR(x);
    return CAR(x);
#ifndef PURE_FUNCTIONAL
  case (127 & I_SET):
    x = CDR(x);
    proc = CAR(x);
    switch (7 & (int)proc) {
    case 0:
      ASRTGO(SYMBOLP(proc),badset);
      t.lloc = lookupcar(x,env);
      break;
    case 1:
      t.lloc = &VCELL(proc-1);
      break;
#ifdef MEMOIZE_LOCALS
    case 4:
      ASRTGO(ILOCP(proc),badset);
      t.lloc = ilookup(proc, env);
      break;
#endif
    default:
    badset:
      everr(x,env,proc,(char *)ARG1,ISYMCHARS(I_SET));
    }
    x = CDR(x);
    *t.lloc = EVALCAR(x,env);
    return UNSPECIFIED;
#endif /* ~PURE_FUNCTIONAL */
  case (127 & MAKISYM(0)):
    proc = CAR(x);
    ASRTGO(ISYMP(proc),badfun);
    switch ISYMNUM(proc) {
    case ISYMNUM(I_QUASIQUOTE):
      x = CDR(x);
      ASSERT(NIMP(x) && CONSP(x) && NULLP(CDR(x)),
	     x,ARG1,ISYMCHARS(I_QUASIQUOTE));
      return iqq(CAR(x), env, 1);
    case ISYMNUM(I_DELAY):
      return makprom(closure(cons(EOL,CDR(x)),env));
#ifdef SYNTAX_EXTENSIONS	/* extension special forms go here */
    case ISYMNUM(I_DEFINEDP):
      CAR(x) = I_QUOTE;
      x = CDR(x);
      proc = CAR(x);
      CAR(x) = (ISYMP(proc) ||
		(NIMP(proc) && SYMBOLP(proc) && !UNBNDP(VCELL(proc))))?
		  BOOL_T : BOOL_F;
      return CAR(x);
#endif /* SYNTAX_EXTENSIONS */
    default:
      goto badfun;
    }
  default:
  badfun2:
    proc = x;
  badfun:
    everr(x,env,proc,"Wrong type to apply: ","");
  case tc7_vector:
  case tc7_string:
  case tc7_smob:
    return x;
#ifdef MEMOIZE_LOCALS
  case (127 & ILOC00):
/*    ASRTGO(ILOCP(CAR(x)),badfun2); */
    proc = *ilookup(CAR(x),env);
    goto checkprocbreak;
#endif
  case tcs_cons_gloc:
    proc = I_VAL(CAR(x));
  checkprocbreak:
    ASRTGO(NIMP(proc),badfun);
    break;
  case tcs_cons_nimcar:
    proc = EVALCELLCAR(x,env);
    ASRTGO(NIMP(proc),badfun);
#ifndef RECKLESS
    if CLOSUREP(proc) {
      SCM varl = CAR(CODE(proc));
      t.arg1 = CDR(x);
      while NIMP(varl) {
	if NCONSP(varl)
	  goto evapply;
	if IMP(t.arg1) goto wrongnumargs;
	varl = CDR(varl);
	t.arg1 = CDR(t.arg1);
      }
      if NNULLP(t.arg1) goto wrongnumargs;
    }
#endif
  }
 evapply:
  x = CDR(x);
  if NULLP(x) switch TYP7(proc) { /* no arguments given */
  case tc7_subr_0:
    return SUBRF(proc)();
  case tc7_subr_1o:
    return SUBRF(proc) (UNDEFINED);
  case tc7_lsubr:
    return SUBRF(proc)(EOL);
  case tc7_asubr:
    return SUBRF(proc)(UNDEFINED,UNDEFINED);
  case tcs_closures:
    x = CODE(proc);
    env = EXTEND_ENV(CAR(x),EOL,ENV(proc));
    goto cdrxbegin;
  case tc7_contin:
  case tc7_subr_1:
  case tc7_subr_2:
  case tc7_subr_2x:
  case tc7_subr_2o:
  case tc7_cxr:
  case tc7_subr_3:
  case tc7_lsubr_2:
  wrongnumargs:
    everr(x,env,proc,(char *)WNA,"");
  default:
    goto badfun;
  }
  t.arg1 = EVALCAR(x,env);
  x = CDR(x);
  if NULLP(x)
evap1: switch TYP7(proc) { /* have one argument in t.arg1 */
  case tc7_subr_2o:
    return SUBRF(proc)(t.arg1,UNDEFINED);
  case tc7_subr_1:
  case tc7_subr_1o:
    return SUBRF(proc)(t.arg1);
  case tc7_cxr:
#ifdef FLOATS
    if SUBRF(proc) {
      if INUMP(t.arg1)
	return makdbl(DSUBRF(proc)((double) INUM(t.arg1)), 0.0);
      ASRTGO(NIMP(t.arg1),floerr);
      if REALP(t.arg1)
	return makdbl(DSUBRF(proc)(REALPART(t.arg1)), 0.0);
    floerr:
      wta(t.arg1,(char *)ARG1,CHARS(SNAME(proc)));
    }
#endif
    {
      char *chrs = CHARS(SNAME(proc));
      while(*++chrs != 'r');
      while(*--chrs != 'c') {
	ASSERT(NIMP(t.arg1) && CONSP(t.arg1),
	       t.arg1,ARG1,CHARS(SNAME(proc)));
	t.arg1 = (*chrs == 'a')?CAR(t.arg1):CDR(t.arg1);
      }
      return t.arg1;
    }
  case tc7_asubr:
    return t.arg1 = SUBRF(proc)(t.arg1,UNDEFINED);
  case tc7_lsubr:
    return SUBRF(proc)(cons(t.arg1,EOL));
  case tcs_closures:
    x = CODE(proc);
    env = EXTEND_ENV(CAR(x),cons(t.arg1,EOL),ENV(proc));
    goto cdrxbegin;
  case tc7_contin:
    lthrow(proc,t.arg1);
  case tc7_subr_2x:
  case tc7_subr_2:
  case tc7_subr_0:
  case tc7_subr_3:
  case tc7_lsubr_2:
    goto wrongnumargs;
  default:
    goto badfun;
  }
  {				/* have two or more arguments */
    SCM arg2 = EVALCAR(x,env);
    x = CDR(x);
    if NULLP(x) switch TYP7(proc) { /* have two arguments */
    case tc7_subr_2:
    case tc7_subr_2o:
      return SUBRF(proc)(t.arg1,arg2);
    case tc7_subr_2x:
      return SUBRF(proc)(arg2,t.arg1);
    case tc7_lsubr:
      return SUBRF(proc)(cons2(t.arg1,arg2,EOL));
    case tc7_lsubr_2:
      return SUBRF(proc)(t.arg1, arg2, EOL);
    case tc7_asubr:
      return t.arg1 = SUBRF(proc)(t.arg1,arg2);
    case tc7_subr_0:
    case tc7_cxr:
    case tc7_subr_1o:
    case tc7_subr_1:
    case tc7_subr_3:
    case tc7_contin:
      goto wrongnumargs;
    default:
      goto badfun;
    case tcs_closures:
      env =EXTEND_ENV(CAR(CODE(proc)),cons2(t.arg1,arg2,EOL),ENV(proc));
      x = CODE(proc);
      goto cdrxbegin;
    }
    switch TYP7(proc) {		/* have 3 or more arguments */
    case tc7_subr_3:
      ASRTGO(NULLP(CDR(x)), wrongnumargs);
      return SUBRF(proc)(t.arg1,arg2,EVALCAR(x,env));
    case tc7_asubr:
      t.arg1 = SUBRF(proc)(t.arg1,arg2);
      while NIMP(x) {
	t.arg1 = SUBRF(proc)(t.arg1,EVALCAR(x,env));
	x = CDR(x);
      }
      return t.arg1;
    case tc7_lsubr_2:
      return SUBRF(proc)(t.arg1, arg2, eval_args(x,env));
    case tc7_lsubr:
      return SUBRF(proc)(cons2(t.arg1,arg2,eval_args(x,env)));
    case tcs_closures:
      env = EXTEND_ENV(CAR(CODE(proc)),
		       cons2(t.arg1,arg2,eval_args(x,env)),
		       ENV(proc));
      x = CODE(proc);
      goto cdrxbegin;
    case tc7_subr_2:
    case tc7_subr_2x:
    case tc7_subr_1o:
    case tc7_subr_2o:
    case tc7_subr_0:
    case tc7_cxr:
    case tc7_subr_1:
    case tc7_contin:
      goto wrongnumargs;
    default:
      goto badfun;
    }
  }
}

SCM procedurep(obj)
SCM obj;
{
	if NIMP(obj) switch TYP7(obj) {
	case tcs_closures:
	case tc7_contin:
	case tcs_subrs:
	  return BOOL_T;
	}
	return BOOL_F;
}

SCM apply(proc,arg1,args)
SCM proc,arg1,args;
{
  ASRTGO(NIMP(proc),badproc);
  /* This code is for lsubr apply. it is destructive on multiple args.
     this will only screw you if you do (apply apply '( ... )) */
  if NULLP(args)
    if NULLP(arg1) arg1 = UNDEFINED;
    else {
      args = CDR(arg1);
      arg1 = CAR(arg1);
    }
  else {
    /*		ASRTGO(NIMP(args) && CONSP(args),wrongnumargs); */
    SCM *lloc = &args;
    while NNULLP(CDR(*lloc)) lloc = &CDR(*lloc);
    *lloc = CAR(*lloc);
  }
  switch TYP7(proc) {
  case tc7_subr_2o:
    args = NULLP(args)?UNDEFINED:CAR(args);
    return SUBRF(proc)(arg1,args);
  case tc7_subr_2x:
    ASRTGO(NULLP(CDR(args)),wrongnumargs);
    args = CAR(args);
    return SUBRF(proc)(args,arg1);
  case tc7_subr_2:
    ASRTGO(NULLP(CDR(args)),wrongnumargs);
    args = CAR(args);
    return SUBRF(proc)(arg1,args);
  case tc7_subr_0:
    ASRTGO(UNBNDP(arg1),wrongnumargs);
    return SUBRF(proc)();
  case tc7_subr_1:
  case tc7_subr_1o:
    ASRTGO(NULLP(args),wrongnumargs);
    return SUBRF(proc)(arg1);
  case tc7_cxr:
    ASRTGO(NULLP(args),wrongnumargs);
#ifdef FLOATS
    if SUBRF(proc) {
      if INUMP(arg1)
	return makdbl(DSUBRF(proc)((double) INUM(arg1)), 0.0);
      ASRTGO(NIMP(arg1),floerr);
      if REALP(arg1)
	return makdbl(DSUBRF(proc)(REALPART(arg1)), 0.0);
    floerr:
      wta(arg1,(char *)ARG1,CHARS(SNAME(proc)));
    }
#endif
    {
      char *chrs = CHARS(SNAME(proc));
      while(*++chrs != 'r');
      while(*--chrs != 'c') {
	ASSERT(NIMP(arg1) && CONSP(arg1),
	       arg1,ARG1,CHARS(SNAME(proc)));
	arg1 = (*chrs == 'a')?CAR(arg1):CDR(arg1);
      }
      return arg1;
    }
  case tc7_subr_3:
    return SUBRF(proc)(arg1,CAR(args),CAR(CDR(args)));
  case tc7_lsubr:
    return SUBRF(proc)(UNBNDP(arg1) ? EOL : cons(arg1,args));
  case tc7_lsubr_2:
    ASRTGO(NIMP(args) && CONSP(args),wrongnumargs);
    return SUBRF(proc)(arg1,CAR(args),CDR(args));
  case tc7_asubr:
    if NULLP(args) return SUBRF(proc)(arg1,UNDEFINED);
    while NIMP(args) {
      ASSERT(CONSP(args),args,ARG2,s_apply);
      arg1 = SUBRF(proc)(arg1,CAR(args));
      args = CDR(args);
    }
    return arg1;
  case tcs_closures:
#ifndef RECKLESS
    {
      SCM formals = CAR(CODE(proc));
      arg1 = (UNBNDP(arg1) ? EOL : cons(arg1,args));
      args = EXTEND_ENV(formals,arg1,ENV(proc));
      while (1) {
	if IMP(arg1)
	  if (IMP(formals) || SYMBOLP(formals)) break;
	  else goto wrongnumargs;
	else if IMP(formals) goto wrongnumargs;
	else if SYMBOLP(formals) break;
	arg1 = CDR(arg1);
	formals = CDR(formals);
      }
    }
#else
    args = EXTEND_ENV(CAR(CODE(proc)),
		      (UNBNDP(arg1) ? EOL : cons(arg1,args)),
		      ENV(proc));
#endif
    proc = CODE(proc);
    while NNULLP(proc = CDR(proc)) arg1 = EVALCAR(proc,args);
    return arg1;
  case tc7_contin:
    ASRTGO(NULLP(args),wrongnumargs);
    lthrow(proc,arg1);
  wrongnumargs:
    wta(proc,(char *)WNA,s_apply);
  default:
  badproc:
    wta(proc,(char *)ARG1,s_apply);
    return arg1;
  }
}

SCM map(proc,arg1,args)
SCM proc,arg1,args;
{
	long i;
	SCM res = EOL,*pres = &res,*ve;
	if NULLP(arg1) return res;
	ASSERT(NIMP(arg1),arg1,ARG1,s_map);
	if NULLP(args) {
		while NIMP(arg1) {
			ASSERT(CONSP(arg1),arg1,ARG2,s_map);
			*pres = cons(apply(proc,CAR(arg1),listofnull),EOL);
			pres = &CDR(*pres);
			arg1 = CDR(arg1);
		}
		return res;
	}
	args = vector(cons(arg1,args));
	ve = VELTS(args);
	while (1) {
		arg1 = EOL;
		for (i = LENGTH(args)-1;i >= 0;i--) {
			if IMP(ve[i]) return res;
			arg1 = cons(CAR(ve[i]),arg1);
			ve[i] = CDR(ve[i]);
		}
		*pres = cons(apply(proc,arg1,EOL),EOL);
		pres = &CDR(*pres);
	}
}
SCM for_each(proc,arg1,args)
SCM proc,arg1,args;
{
	SCM *ve;
	long i;
	if NULLP(arg1) return UNSPECIFIED;
	ASSERT(NIMP(arg1),arg1,ARG1,s_for_each);
	if NULLP(args) {
		while NIMP(arg1) {
			ASSERT(CONSP(arg1),arg1,ARG2,s_for_each);
			apply(proc,CAR(arg1),listofnull);
			arg1 = CDR(arg1);
		}
		return UNSPECIFIED;
	}
	args = vector(cons(arg1,args));
	ve = VELTS(args);
	while (1) {
		arg1 = EOL;
		for (i = LENGTH(args)-1;i >= 0;i--) {
			if IMP(ve[i]) return UNSPECIFIED;
			arg1 = cons(CAR(ve[i]),arg1);
			ve[i] = CDR(ve[i]);
		}
		apply(proc,arg1,EOL);
	}
}

				/* inits are in subr.c */
