/* Scheme implementation intended for JACAL.
   Copyright (C) 1990-1994 Aubrey Jaffer & Hugh E. Secker-Walker.

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

typedef struct {long sname;double (*dproc)();} dsubr;
#define DSUBRF(x) (((dsubr *)(SCM2PTR(x)))->dproc)

#define I_SYM(x) (CAR((x)-1L))
#define I_VAL(x) (CDR((x)-1L))
#define EVALCELLCAR(x,env) SYMBOLP(CAR(x))?*lookupcar(x,env):ceval(CAR(x),env)
#ifdef MEMOIZE_LOCALS
#define EVALIMP(x,env) (ILOCP(x)?*ilookup((x),env):x)
#else
#define EVALIMP(x,env) x
#endif
#define EVALCAR(x,env) (NCELLP(CAR(x))?(IMP(CAR(x))?EVALIMP(CAR(x),env):\
					I_VAL(CAR(x))):EVALCELLCAR(x,env))
#define EXTEND_ENV acons

#ifdef MEMOIZE_LOCALS
SCM *ilookup(iloc,env)
SCM iloc,env;
{
  register int ir = IFRAME(iloc);
  register SCM er = env;
  for(;0 != ir;--ir) er = CDR(er);
  er = CAR(er);
  for(ir = IDIST(iloc);0 != ir;--ir) er = CDR(er);
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
	if (fl==var) {
#ifdef MEMOIZE_LOCALS
	  CAR(vloc) = iloc + ICDR;
#endif
	  return &CDR(*al);
	}
	else break;
      al = &CDR(*al);
      if (CAR(fl)==var) {
#ifdef MEMOIZE_LOCALS
# ifndef RECKLESS		/* letrec inits to UNDEFINED */
	if UNBNDP(CAR(*al)) {env = EOL; goto errout;}
# endif
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
  var = sym2vcell(var);
#ifndef RECKLESS
  if (NNULLP(env) || UNBNDP(CDR(var))) {
    var = CAR(var);
  errout:
    everr(vloc,genv,var,
	  NULLP(env)?"unbound variable: ":"damaged environment","");
  }
#endif
  CAR(vloc) = var + 1;
  return &CDR(var);
}
static SCM unmemocar(form,env)
     SCM form,env;
{
  register int ir;
  if IMP(form) return form;
  if (1==TYP3(form))
    CAR(form) = I_SYM(CAR(form));
#ifdef MEMOIZE_LOCALS
  else if ILOCP(form) {
    for(ir = IFRAME(CAR(form)); ir != 0; --ir) env = CDR(env);
    env = CAR(CAR(env));
    for(ir = IDIST(CAR(form));ir != 0;--ir) env = CDR(env);
    CAR(form) = ICDRP(CAR(form)) ? env : CAR(env);
  }
#endif
  return form;
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

    /* the following rewrite expressions and
     * some memoized forms have different syntax */

static char s_expression[] = "missing or extra expression";
static char s_test[] = "bad test";
static char s_body[] = "bad body";
static char s_bindings[] = "bad bindings";
static char s_variable[] = "bad variable";
static char s_clauses[] = "bad or missing clauses";
static char s_formals[] = "bad formals";
#define ASSYNT(_cond,_arg,_pos,_subr) if(!(_cond))wta(_arg,(char *)_pos,_subr);

SCM i_dot, i_quote, i_quasiquote, i_lambda,
  i_let, i_arrow, i_else, i_unquote, i_uq_splicing, i_apply;
static char s_quasiquote[] = "quasiquote";
static char s_delay[] = "delay";

#define ASRTSYNTAX(cond_,msg_) if(!(cond_))wta(xorig,(msg_),what);

static void bodycheck(xorig,bodyloc,what)
     SCM xorig, *bodyloc;
     char *what;
{
  ASRTSYNTAX(ilength(*bodyloc) >= 1,s_expression);
}

SCM m_quote(xorig,env)
     SCM xorig, env;
{
  ASSYNT(ilength(CDR(xorig))==1,xorig,s_expression,s_quote);
  return cons(IM_QUOTE,CDR(xorig));
}

SCM m_begin(xorig,env)
     SCM xorig, env;
{
  ASSYNT(ilength(CDR(xorig)) >= 1,xorig,s_expression,s_begin);
  return cons(IM_BEGIN,CDR(xorig));
}

SCM m_if(xorig,env)
     SCM xorig, env;
{
  int len = ilength(CDR(xorig));
  ASSYNT(len >= 2 && len <= 3,xorig,s_expression,s_if);
  return cons(IM_IF,CDR(xorig));
}

SCM m_set(xorig,env)
     SCM xorig, env;
{
  SCM x = CDR(xorig);
  ASSYNT(2==ilength(x),xorig,s_expression,s_set);
  ASSYNT(NIMP(CAR(x)) && SYMBOLP(CAR(x)),
	 xorig,s_variable,s_set);
  return cons(IM_SET, x);
}

SCM m_and(xorig,env)
     SCM xorig, env;
{
  int len = ilength(CDR(xorig));
  ASSYNT(len >= 0,xorig,s_test,s_and);
  if (len >= 1) return cons(IM_AND,CDR(xorig));
  else return BOOL_T;
}

SCM m_or(xorig,env)
     SCM xorig, env;
{
  int len = ilength(CDR(xorig));
  ASSYNT(len >= 0,xorig,s_test,s_or);
  if (len >= 1) return cons(IM_OR,CDR(xorig));
  else return BOOL_F;
}

SCM m_case(xorig,env)
     SCM xorig, env;
{
  SCM proc,x = CDR(xorig);
  ASSYNT(ilength(x) >= 2,xorig,s_clauses,s_case);
  while(NIMP(x = CDR(x))) {
    proc = CAR(x);
    ASSYNT(ilength(proc) >= 2,xorig,s_clauses,s_case);
    ASSYNT(ilength(CAR(proc)) >= 0 || i_else==CAR(proc),
	   xorig,s_clauses,s_case);
  }
  return cons(IM_CASE,CDR(xorig));
}

SCM m_cond(xorig,env)
     SCM xorig, env;
{
  SCM arg1,x = CDR(xorig);
  int len = ilength(x);
  ASSYNT(len >= 1,xorig,s_clauses,s_cond);
  while(NIMP(x)) {
    arg1 = CAR(x);
    len = ilength(arg1);
    ASSYNT(len >= 1,xorig,s_clauses,s_cond);
    if (i_else==CAR(arg1)) {
      ASSYNT(NULLP(CDR(x)) && len >= 2,xorig,"bad ELSE clause",s_cond);
      CAR(arg1) = BOOL_T;
    }
    if (len >= 2 && i_arrow==CAR(CDR(arg1)))
      ASSYNT(3==len && NIMP(CAR(CDR(CDR(arg1)))),
	     xorig,"bad recipient",s_cond);
    x = CDR(x);
  }
  return cons(IM_COND, CDR(xorig));
}

SCM m_lambda(xorig,env)
     SCM xorig, env;
{
  SCM proc,x = CDR(xorig);
  if (ilength(x) < 2) goto badforms;
  proc = CAR(x);
  if NULLP(proc) goto memlambda;
  if IMP(proc) goto badforms;
  if SYMBOLP(proc) goto memlambda;
  if NCONSP(proc) goto badforms;
  while NIMP(proc) {
    if NCONSP(proc)
      if (!SYMBOLP(proc)) goto badforms;
      else goto memlambda;
    if (!(NIMP(CAR(proc)) && SYMBOLP(CAR(proc)))) goto badforms;
    proc = CDR(proc);
  }
  if NNULLP(proc)
  badforms: wta(xorig,s_formals,s_lambda);
 memlambda:
  bodycheck(xorig,&CDR(x),s_lambda);
  return cons(IM_LAMBDA, CDR(xorig));
}
SCM m_letstar(xorig,env)
     SCM xorig, env;
{
  SCM x = CDR(xorig), arg1, proc, vars = EOL, *varloc = &vars;
  int len = ilength(x);
  ASSYNT(len >= 2,xorig,s_body,s_letstar);
  proc = CAR(x);
  ASSYNT(ilength(proc) >= 0,xorig,s_bindings,s_letstar);
  while NIMP(proc) {
    arg1 = CAR(proc);
    ASSYNT(2==ilength(arg1),xorig,s_bindings,s_letstar);
    ASSYNT(NIMP(CAR(arg1)) && SYMBOLP(CAR(arg1)),xorig,s_variable,s_letstar);
    *varloc = cons2(CAR(arg1),CAR(CDR(arg1)),EOL);
    varloc = &CDR(CDR(*varloc));
    proc = CDR(proc);
  }
  x = cons(vars, CDR(x));
  bodycheck(xorig,&CDR(x),s_letstar);
  return cons(IM_LETSTAR, x);
}

/* DO gets the most radically altered syntax
   (do ((<var1> <init1> <step1>)
   (<var2> <init2>)
   ... )
   (<test> <return>)
   <body>)
   ;; becomes
   (do_mem (varn ... var2 var1)
   (<init1> <init2> ... <initn>)
   (<test> <return>)
   (<body>)
   <step1> <step2> ... <stepn>) ;; missing steps replaced by var
   */
SCM m_do(xorig,env)
     SCM xorig, env;
{
  SCM x = CDR(xorig), arg1, proc;
  SCM vars = EOL, inits = EOL, steps = EOL;
  SCM *initloc = &inits, *steploc = &steps;
  int len = ilength(x);
  ASSYNT(len >= 2,xorig,s_test,s_do);
  proc = CAR(x);
  ASSYNT(ilength(proc) >= 0,xorig,s_bindings,s_do);
  while NIMP(proc) {
    arg1 = CAR(proc);
    len = ilength(arg1);
    ASSYNT(2==len || 3==len,xorig,s_bindings,s_do);
    ASSYNT(NIMP(CAR(arg1)) && SYMBOLP(CAR(arg1)),xorig,s_variable,s_do);
    /* vars reversed here, inits and steps reversed at evaluation */
    vars = cons(CAR(arg1),vars); /* variable */
    arg1 = CDR(arg1);
    *initloc = cons(CAR(arg1),EOL); /* init */
    initloc = &CDR(*initloc);
    arg1 = CDR(arg1);
    *steploc = cons(IMP(arg1)?CAR(vars):CAR(arg1),EOL); /* step */
    steploc = &CDR(*steploc);
    proc = CDR(proc);
  }
  x = CDR(x);
  ASSYNT(ilength(CAR(x)) >= 1,xorig,s_test,s_do);
  x = cons2(CAR(x), CDR(x), steps);
  x = cons2(vars, inits, x);
  bodycheck(xorig,&CAR(CDR(CDR(x))),s_do);
  return cons(IM_DO, x);
}

/* evalcar is small version of inline EVALCAR when we don't care about speed */
static SCM evalcar(x,env)
     SCM x, env;
{
  return EVALCAR(x,env);
}

static SCM iqq(form, env, depth)
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
    for(;--i >= 0;) tmp = cons(data[i],tmp);
    return vector(iqq(tmp,env,depth));
  }
  if NCONSP(form) return form;
  tmp = CAR(form);
  if (i_quasiquote==tmp) {
    depth++;
    goto label;
  }
  if (i_unquote==tmp) {
    --depth;
  label:
    form = CDR(form);
    ASSERT(NIMP(form) && ECONSP(form) && NULLP(CDR(form)),
	   form,ARG1,s_quasiquote);
    if (0==depth) return evalcar(form,env);
    return cons2(tmp,iqq(CAR(form),env,depth),EOL);
  }
  if (NIMP(tmp) && (i_uq_splicing==CAR(tmp))) {
    tmp = CDR(tmp);
    if (0==--edepth)
      return append(cons2(evalcar(tmp,env),iqq(CDR(form),env,depth),EOL));
  }
  return cons(iqq(CAR(form),env,edepth),iqq(CDR(form),env,depth));
}

/* Here are acros which return values rather than code. */

SCM m_quasiquote(xorig,env)
     SCM xorig, env;
{
  SCM x = CDR(xorig);
  ASSYNT(ilength(x)==1,xorig,s_expression,s_quasiquote);
  return iqq(CAR(x), env, 1);
}

SCM m_delay(xorig,env)
     SCM xorig, env;
{
  ASSYNT(ilength(xorig)==2,xorig,s_expression,s_delay);
  return makprom(closure(cons(EOL,CDR(xorig)),env));
}

extern int verbose;
SCM m_define(x,env)
  SCM x, env;
{
  SCM proc, arg1 = x; x = CDR(x);
  /*  ASSYNT(NULLP(env),x,"bad placement",s_define);*/
  ASSYNT(ilength(x) >= 2,arg1,s_expression,s_define);
  proc = CAR(x); x = CDR(x);
  while (NIMP(proc) && CONSP(proc)) { /* nested define syntax */
    x = cons(cons2(i_lambda,CDR(proc),x),EOL);
    proc = CAR(proc);
  }
  ASSYNT(NIMP(proc) && SYMBOLP(proc),arg1,s_variable,s_define);
  ASSYNT(1==ilength(x),arg1,s_expression,s_define);
  if NULLP(env) {
    x = evalcar(x,env);
    arg1 = sym2vcell(proc);
#ifndef RECKLESS
    if (NIMP(CDR(arg1)) && ((SCM) SNAME(CDR(arg1))==proc))
      warn("redefining built-in ", CHARS(proc));
    else
#endif
    if (5 <= verbose && UNDEFINED != CDR(arg1))
      warn("redefining ", CHARS(proc));
    CDR(arg1) = x;
#ifdef SICP
    return cons2(i_quote,CAR(arg1),EOL);
#else
    return UNSPECIFIED;
#endif
  }
  return cons2(IM_DEFINE,proc,x);
}
/* end of acros */

SCM m_letrec(xorig,env)
  SCM xorig,env;
{
  SCM cdrx = CDR(xorig);	/* locally mutable version of form */
  char *what = CHARS(CAR(xorig));
  SCM x = cdrx, proc, arg1;	/* structure traversers */
  SCM vars = EOL, inits = EOL, *initloc = &inits;

  ASRTSYNTAX(ilength(x) >= 2,s_body);
  proc = CAR(x);		
  if NULLP(proc) return m_letstar(xorig,env); /* null binding, let* faster */
  ASRTSYNTAX(ilength(proc) >= 1,s_bindings);
  do {
    /* vars list reversed here, inits reversed at evaluation */
    arg1 = CAR(proc);
    ASRTSYNTAX(2==ilength(arg1),s_bindings);
    ASRTSYNTAX(NIMP(CAR(arg1)) && SYMBOLP(CAR(arg1)), s_variable);
    vars = cons(CAR(arg1),vars);
    *initloc = cons(CAR(CDR(arg1)),EOL);
    initloc = &CDR(*initloc);
  } while NIMP(proc = CDR(proc));
  cdrx = cons2(vars,inits,CDR(x));
  bodycheck(xorig,&CDR(CDR(cdrx)),what);
  return cons(IM_LETREC, cdrx);
}

SCM m_let(xorig,env)
  SCM xorig,env;
{
  SCM cdrx = CDR(xorig);	/* locally mutable version of form */
  SCM x = cdrx, proc, arg1, name; /* structure traversers */
  SCM vars = EOL, inits = EOL, *varloc = &vars, *initloc = &inits;

  ASSYNT(ilength(x) >= 2,xorig,s_body,s_let);
  proc = CAR(x);
  if (NULLP(proc)
      || (NIMP(proc) && CONSP(proc)
	  && NIMP(CAR(proc)) && CONSP(CAR(proc)) && NULLP(CDR(proc))))
    return m_letstar(xorig,env); /* null or single binding, let* is faster */
  ASSYNT(NIMP(proc),xorig,s_bindings,s_let);
  if CONSP(proc)		/* plain let, proc is <bindings> */
    return cons(IM_LET, CDR(m_letrec(xorig,env)));
  if (!SYMBOLP(proc)) wta(xorig,s_bindings,s_let); /* bad let */
  name = proc;			/* named let, build equiv letrec */
  x = CDR(x);
  ASSYNT(ilength(x) >= 2,xorig,s_body,s_let);
  proc = CAR(x);		/* bindings list */
  ASSYNT(ilength(proc) >= 0,xorig,s_bindings,s_let);
  while NIMP(proc) {		/* vars and inits both in order */
    arg1 = CAR(proc);
    ASSYNT(2==ilength(arg1),xorig,s_bindings,s_let);
    ASSYNT(NIMP(CAR(arg1)) && SYMBOLP(CAR(arg1)),xorig,s_variable,s_let);
    *varloc = cons(CAR(arg1),EOL);
    varloc = &CDR(*varloc);
    *initloc = cons(CAR(CDR(arg1)),EOL);
    initloc = &CDR(*initloc);
    proc = CDR(proc);
  }
  return
    m_letrec(cons2(i_let,
		   cons(cons2(name, cons2(i_lambda,vars,CDR(x)), EOL), EOL),
		   acons(name,inits, EOL)), /* body */
	     env);
}

#define s_atapply (ISYMCHARS(IM_APPLY)+1)

SCM m_apply(xorig,env)
     SCM xorig, env;
{
  ASSYNT(ilength(CDR(xorig))==2,xorig,s_expression,s_atapply);
  return cons(IM_APPLY,CDR(xorig));
}

#define s_atcall_cc (ISYMCHARS(IM_CONT)+1)

SCM m_cont(xorig,env)
     SCM xorig, env;
{
  ASSYNT(ilength(CDR(xorig))==1,xorig,s_expression,s_atcall_cc);
  return cons(IM_CONT,CDR(xorig));
}

char s_map[] = "map", s_for_each[] = "for-each" /*, s_apply[] = "apply" */ ;
SCM eqv();
long tc16_macro;

SCM ceval(x,env)
SCM x,env;
{
  union {SCM *lloc; SCM arg1;} t;
  SCM proc;
  CHECK_STACK;
 loop: POLL;
  switch TYP7(x) {
  case tcs_symbols:
    /* only happens when called at top level */
    x = cons(x,UNDEFINED);
    goto retval;
  case (127 & IM_AND):
    x = CDR(x);
    t.arg1 = x;
    while(NNULLP(t.arg1 = CDR(t.arg1)))
      if FALSEP(EVALCAR(x,env)) return BOOL_F;
      else x = t.arg1;
    goto carloop;
  case (127 & IM_BEGIN):
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
    if SYMBOLP(CAR(x)) {
 retval:
      return *lookupcar(x,env);
    }
    x = CAR(x);
    goto loop;			/* tail recurse */

  case (127 & IM_CASE):
    x = CDR(x);
    t.arg1 = EVALCAR(x,env);
    while(NIMP(x = CDR(x))) {
      proc = CAR(x);
      if (i_else==CAR(proc)) {
	x = CDR(proc);
	goto begin;
      }
      proc = CAR(proc);
      while NIMP(proc) {
	if (CAR(proc)==t.arg1
#ifdef FLOATS
	    || NFALSEP(eqv(CAR(proc),t.arg1))
#endif
	    ) {
	  x = CDR(CAR(x));
	  goto begin;
	}
	proc = CDR(proc);
      }
    }
    return UNSPECIFIED;
  case (127 & IM_COND):
    while(NIMP(x = CDR(x))) {
      proc = CAR(x);
      t.arg1 = EVALCAR(proc,env);
      if NFALSEP(t.arg1) {
	x = CDR(proc);
	if NULLP(x) return t.arg1;
	if (i_arrow != CAR(x)) goto begin;
	proc = CDR(x);
	proc = EVALCAR(proc,env);
	ASRTGO(NIMP(proc),badfun);
	goto evap1;
      }
    }
    return UNSPECIFIED;
  case (127 & IM_DO):
    x = CDR(x);
    proc = CAR(CDR(x)); /* inits */
    t.arg1 = EOL; /* values */
    while NIMP(proc) {
      t.arg1 = cons(EVALCAR(proc,env),t.arg1);
      proc = CDR(proc);
    }
    env = EXTEND_ENV(CAR(x),t.arg1,env);
    x = CDR(CDR(x));
    while (proc = CAR(x),FALSEP(EVALCAR(proc,env))) {
      for(proc = CAR(CDR(x));NIMP(proc);proc = CDR(proc)) {
	t.arg1 = CAR(proc);	/* body */
	SIDEVAL(t.arg1,env);
      }
      for(t.arg1 = EOL, proc = CDR(CDR(x)); NIMP(proc); proc = CDR(proc))
	t.arg1 = cons(EVALCAR(proc,env),t.arg1); /* steps */
      env = EXTEND_ENV(CAR(CAR(env)),t.arg1,CDR(env));
    }
    x = CDR(proc);
    if NULLP(x) return UNSPECIFIED;
    goto begin;
  case (127 & IM_IF):
    x = CDR(x);
    if NFALSEP(EVALCAR(x,env)) x = CDR(x);
    else if IMP(x = CDR(CDR(x))) return UNSPECIFIED;
    goto carloop;
  case (127 & IM_LET):
    x = CDR(x);
    proc = CAR(CDR(x));
    t.arg1 = EOL;
    do {
      t.arg1 = cons(EVALCAR(proc,env), t.arg1);
    } while NIMP(proc = CDR(proc));
    env = EXTEND_ENV(CAR(x),t.arg1,env);
    x = CDR(x);
    goto cdrxbegin;
  case (127 & IM_LETREC):
    x = CDR(x);
    env = EXTEND_ENV(CAR(x),undefineds,env);
    x = CDR(x);
    proc = CAR(x);
    t.arg1 = EOL;
    do {
	t.arg1 = cons(EVALCAR(proc,env), t.arg1);
    } while NIMP(proc = CDR(proc));
    CDR(CAR(env)) = t.arg1;
    goto cdrxbegin;
  case (127 & IM_LETSTAR):
    x = CDR(x);
    proc = CAR(x);
    if IMP(proc) {
      env = EXTEND_ENV(EOL,EOL, env);
      goto cdrxbegin;
    }
    do {
      t.arg1 = CAR(proc);
      proc = CDR(proc);
      env = EXTEND_ENV(t.arg1, EVALCAR(proc,env), env);
    } while NIMP(proc = CDR(proc));
    goto cdrxbegin;
  case (127 & IM_OR):
    x = CDR(x);
    t.arg1 = x;
    while(NNULLP(t.arg1 = CDR(t.arg1))) {
      x = EVALCAR(x,env);
      if NFALSEP(x) return x;
      x = t.arg1;
    }
    goto carloop;
  case (127 & IM_LAMBDA):
    return closure(CDR(x),env);
  case (127 & IM_QUOTE):
    return CAR(CDR(x));
  case (127 & IM_SET):
    x = CDR(x);
    proc = CAR(x);
    switch (7 & (int)proc) {
    case 0:
      t.lloc = lookupcar(x,env);
      break;
    case 1:
      t.lloc = &I_VAL(proc);
      break;
#ifdef MEMOIZE_LOCALS
    case 4:
      t.lloc = ilookup(proc,env);
      break;
#endif
    }
    x = CDR(x);
    *t.lloc = EVALCAR(x,env);
#ifdef SICP
    return *t.lloc;
#else
    return UNSPECIFIED;
#endif
  case (127 & IM_DEFINE):	/* only for internal defines */
    x = CDR(x);
    proc = CAR(x);
    x = CDR(x);
    x = evalcar(x,env);
    env = CAR(env);
    DEFER_INTS;
    CAR(env) = cons(proc,CAR(env));
    CDR(env) = cons(x,CDR(env));
    ALLOW_INTS;
    return UNSPECIFIED;
	/* new syntactic forms go here. */
  case (127 & MAKISYM(0)):
    proc = CAR(x);
    ASRTGO(ISYMP(proc),badfun);
    switch ISYMNUM(proc) {
    case (ISYMNUM(IM_APPLY)):
      proc = CDR(x);
      proc = EVALCAR(proc,env);
      ASRTGO(NIMP(proc),badfun);
      if (CLOSUREP(proc)) {
	x = CDR(CDR(x));
	env = EXTEND_ENV(CAR(CODE(proc)), EVALCAR(x,env), ENV(proc));
	x = CODE(proc);
	goto cdrxbegin;
      }
      proc = i_apply;
      goto evapply;
    case (ISYMNUM(IM_CONT)):
      t.arg1 = make_cont();
      if (setjmp(JMPBUF(t.arg1))) return throwval;
      proc = CDR(x);
      proc = evalcar(proc,env);
      ASRTGO(NIMP(proc),badfun);
      goto evap1;
    default:
      goto badfun;
    }
  default:
    proc = x;
  badfun:
    everr(x,env,proc,"Wrong type to apply: ","");
  case tc7_vector:
  case tc7_bvect: case tc7_ivect: case tc7_uvect:
  case tc7_fvect: case tc7_dvect: case tc7_cvect:
  case tc7_string:
  case tc7_smob:
    return x;
#ifdef MEMOIZE_LOCALS
  case (127 & ILOC00):
    proc = *ilookup(CAR(x),env);
    ASRTGO(NIMP(proc),badfun);
#ifndef RECKLESS
# ifdef CAUTIOUS
    goto checkargs;
# endif
#endif
    break;
#endif /* ifdef MEMOIZE_LOCALS */
  case tcs_cons_gloc:
    proc = I_VAL(CAR(x));
    ASRTGO(NIMP(proc),badfun);
#ifndef RECKLESS
# ifdef CAUTIOUS
    goto checkargs;
# endif
#endif
    break;
  case tcs_cons_nimcar:
    if SYMBOLP(CAR(x)) {
      proc = *lookupcar(x,env);
      if IMP(proc) {unmemocar(x,env); goto badfun;}
      if (tc16_macro==TYP16(proc)) {
	unmemocar(x,env);
	t.arg1 = apply(CDR(proc), x, cons(env,listofnull));
	switch ((int)(CAR(proc)>>16)) {
	case 2:
	  if (ilength(t.arg1) <= 0)
	    t.arg1 = cons2(IM_BEGIN, t.arg1, EOL);
	  DEFER_INTS;
	  CAR(x) = CAR(t.arg1);
	  CDR(x) = CDR(t.arg1);
	  ALLOW_INTS;
	  goto loop;
	case 1:
	  if NIMP(x = t.arg1) goto loop;
	case 0:
	  return t.arg1;
	}
      }
    }
    else proc = ceval(CAR(x),env);
    ASRTGO(NIMP(proc),badfun);
#ifndef RECKLESS
# ifdef CAUTIOUS
  checkargs:
# endif
    if CLOSUREP(proc) {
      SCM varl = CAR(CODE(proc));
      t.arg1 = CDR(x);
      while NIMP(varl) {
	if NCONSP(varl)
	  goto evapply;
	if IMP(t.arg1) goto umwrongnumargs;
	varl = CDR(varl);
	t.arg1 = CDR(t.arg1);
      }
      if NNULLP(t.arg1) goto umwrongnumargs;
    }
#endif
  }
 evapply:
  if NULLP(CDR(x)) switch TYP7(proc) { /* no arguments given */
  case tc7_subr_0:
    return SUBRF(proc)();
  case tc7_subr_1o:
    return SUBRF(proc) (UNDEFINED);
  case tc7_lsubr:
    return SUBRF(proc)(EOL);
  case tc7_rpsubr:
    return BOOL_T;
  case tc7_asubr:
    return SUBRF(proc)(UNDEFINED,UNDEFINED);
  case tcs_closures:
    x = CODE(proc);
    env = EXTEND_ENV(CAR(x),EOL,ENV(proc));
    goto cdrxbegin;
  case tc7_contin:
  case tc7_subr_1:
  case tc7_subr_2:
  case tc7_subr_2o:
  case tc7_cxr:
  case tc7_subr_3:
  case tc7_lsubr_2:
  umwrongnumargs:
    unmemocar(x,env);
  wrongnumargs:
    everr(x,env,proc,(char *)WNA,"");
  default:
    goto badfun;
  }
  x = CDR(x);
#ifdef CAUTIOUS
  if (IMP(x)) goto wrongnumargs;
#endif  
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
#ifdef BIGDIG
      if BIGP(t.arg1)
	return makdbl(DSUBRF(proc)(big2dbl(t.arg1)), 0.0);
#endif
    floerr:
      wta(t.arg1,(char *)ARG1,CHARS(SNAME(proc)));
    }
#endif
    proc = (SCM)SNAME(proc);
    {
      char *chrs = CHARS(proc)+LENGTH(proc)-1;
      while('c' != *--chrs) {
	ASSERT(NIMP(t.arg1) && CONSP(t.arg1),
	       t.arg1,ARG1,CHARS(proc));
	t.arg1 = ('a'==*chrs)?CAR(t.arg1):CDR(t.arg1);
      }
      return t.arg1;
    }
  case tc7_rpsubr:
    return BOOL_T;
  case tc7_asubr:
    return SUBRF(proc)(t.arg1,UNDEFINED);
  case tc7_lsubr:
    return SUBRF(proc)(cons(t.arg1,EOL));
  case tcs_closures:
    x = CODE(proc);
    env = EXTEND_ENV(CAR(x),cons(t.arg1,EOL),ENV(proc));
    goto cdrxbegin;
  case tc7_contin:
    lthrow(proc,t.arg1);
  case tc7_subr_2:
  case tc7_subr_0:
  case tc7_subr_3:
  case tc7_lsubr_2:
    goto wrongnumargs;
  default:
    goto badfun;
  }
#ifdef CAUTIOUS
  if (IMP(x)) goto wrongnumargs;
#endif  
  {				/* have two or more arguments */
    SCM arg2 = EVALCAR(x,env);
    x = CDR(x);
    if NULLP(x) switch TYP7(proc) { /* have two arguments */
    case tc7_subr_2:
    case tc7_subr_2o:
      return SUBRF(proc)(t.arg1,arg2);
    case tc7_lsubr:
      return SUBRF(proc)(cons2(t.arg1,arg2,EOL));
    case tc7_lsubr_2:
      return SUBRF(proc)(t.arg1, arg2, EOL);
    case tc7_rpsubr:
    case tc7_asubr:
      return SUBRF(proc)(t.arg1,arg2);
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
      env = EXTEND_ENV(CAR(CODE(proc)),cons2(t.arg1,arg2,EOL),ENV(proc));
      x = CODE(proc);
      goto cdrxbegin;
    }
    switch TYP7(proc) {		/* have 3 or more arguments */
    case tc7_subr_3:
      ASRTGO(NULLP(CDR(x)), wrongnumargs);
      return SUBRF(proc)(t.arg1,arg2,EVALCAR(x,env));
    case tc7_asubr:
/*      t.arg1 = SUBRF(proc)(t.arg1,arg2);
      while NIMP(x) {
	t.arg1 = SUBRF(proc)(t.arg1,EVALCAR(x,env));
	x = CDR(x);
      }
      return t.arg1; */
    case tc7_rpsubr:
      return apply(proc,t.arg1,acons(arg2, eval_args(x,env), EOL));
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

/* This code is for apply. it is destructive on multiple args.
   This will only screw you if you do (apply apply '( ... )) */
SCM nconc2last(lst)
     SCM lst;
{
  SCM *lloc = &lst;
  while NNULLP(CDR(*lloc)) lloc = &CDR(*lloc);
  *lloc = CAR(*lloc);
  return lst;
}

SCM apply(proc,arg1,args)
SCM proc,arg1,args;
{
  ASRTGO(NIMP(proc),badproc);
  if NULLP(args)
    if NULLP(arg1) arg1 = UNDEFINED;
    else {
      args = CDR(arg1);
      arg1 = CAR(arg1);
    }
  else {
    /*		ASRTGO(NIMP(args) && CONSP(args),wrongnumargs); */
    args = nconc2last(args);
  }
  switch TYP7(proc) {
  case tc7_subr_2o:
    args = NULLP(args)?UNDEFINED:CAR(args);
    return SUBRF(proc)(arg1,args);
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
#ifdef BIGDIG
      if BIGP(arg1)
	return makdbl(DSUBRF(proc)(big2dbl(arg1)), 0.0);
#endif
    floerr:
      wta(arg1,(char *)ARG1,CHARS(SNAME(proc)));
    }
#endif
    proc = (SCM)SNAME(proc);
    {
      char *chrs = CHARS(proc)+LENGTH(proc)-1;
      while('c' != *--chrs) {
	ASSERT(NIMP(arg1) && CONSP(arg1),
	       arg1,ARG1,CHARS(proc));
	arg1 = ('a'==*chrs)?CAR(arg1):CDR(arg1);
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
  case tc7_rpsubr:
    if NULLP(args) return BOOL_T;
    while NIMP(args) {
      ASSERT(CONSP(args),args,ARG2,s_apply);
      if FALSEP(SUBRF(proc)(arg1,CAR(args))) return BOOL_F;
      arg1 = CAR(args);
      args = CDR(args);
    }
    return BOOL_T;
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
	SCM res = EOL,*pres = &res;
	SCM *ve = &args;	/* Keep args from being optimized away. */
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
#ifndef RECKLESS
	for(i = LENGTH(args)-1; i >= 0; i--)
	  ASSERT(NIMP(ve[i]) && CONSP(ve[i]),args,ARG1,s_map);
#endif
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
	SCM *ve = &args;	/* Keep args from being optimized away. */
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
#ifndef RECKLESS
	for(i = LENGTH(args)-1; i >= 0; i--)
	  ASSERT(NIMP(ve[i]) && CONSP(ve[i]),args,ARG1,s_for_each);
#endif
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

SCM closure(code,env)
SCM code,env;
{
	register SCM z;
	NEWCELL(z);
	SETCODE(z,code);
	ENV(z) = env;
	return z;
}

long tc16_promise;
SCM makprom(code)
SCM code;
{
	register SCM z;
	NEWCELL(z);
	CDR(z) = code;
	CAR(z) = tc16_promise;
	return z;
}
static int prinprom(exp,port,writing)
     SCM exp;
     SCM port;
     int writing;
{
  lputs("#<promise ",port);
  iprin1(CDR(exp),port,writing);
  lputc('>',port);
  return !0;
}

SCM makacro(code)
SCM code;
{
	register SCM z;
	NEWCELL(z);
	CDR(z) = code;
	CAR(z) = tc16_macro;
	return z;
}
SCM makmacro(code)
SCM code;
{
	register SCM z;
	NEWCELL(z);
	CDR(z) = code;
	CAR(z) = tc16_macro | (1L<<16);
	return z;
}
SCM makmmacro(code)
SCM code;
{
	register SCM z;
	NEWCELL(z);
	CDR(z) = code;
	CAR(z) = tc16_macro | (2L<<16);
	return z;
}
static int prinmacro(exp,port,writing)
     SCM exp;
     SCM port;
     int writing;
{
  if (CAR(exp) & (3L<<16)) lputs("#<macro",port);
  else lputs("#<syntax",port);
  if (CAR(exp) & (2L<<16)) lputc('!',port);
  lputc(' ',port);
  iprin1(CDR(exp),port,writing);
  lputc('>',port);
  return !0;
}

char s_force[] = "force";
SCM force(x)
     SCM x;
{
  ASSERT((TYP16(x)==tc16_promise),x,ARG1,s_force);
  if (!((1L<<16) & CAR(x))) {
    SCM ans = apply(CDR(x),EOL,EOL);
    DEFER_INTS;
    CDR(x) = ans;
    CAR(x) |= (1L<<16);
    ALLOW_INTS;
  }
  return CDR(x);
}

SCM copytree(obj)
SCM obj;
{
  SCM ans, tl;
  if IMP(obj) return obj;
  if VECTORP(obj) {
    sizet i = LENGTH(obj);
    ans = make_vector(MAKINUM(i), UNSPECIFIED);
    while(i--) VELTS(ans)[i] = copytree(VELTS(obj)[i]);
    return ans;
  }
  if NCONSP(obj) return obj;
/*  return cons(copytree(CAR(obj)),copytree(CDR(obj))); */
  ans = tl = cons(copytree(CAR(obj)),UNSPECIFIED);
  while(NIMP(obj = CDR(obj)) && CONSP(obj))
    tl = (CDR(tl) = cons(copytree(CAR(obj)),UNSPECIFIED));
  CDR(tl) = obj;
  return ans;
}
SCM eval(obj)
SCM obj;
{
  obj = copytree(obj);
  return EVAL(obj,(SCM)EOL);
}

SCM definedp(x, env)
     SCM x, env;
{
  SCM proc = CAR(x = CDR(x));
  return (ISYMP(proc)
	  || (NIMP(proc) && SYMBOLP(proc)
	      && !UNBNDP(CDR(sym2vcell(proc)))))?
		(SCM)BOOL_T : (SCM)BOOL_F;
}

static iproc subr1s[] = {
	{"copy-tree",copytree},
	{"eval",eval},
	{s_force,force},
	{"procedure->syntax",makacro},
	{"procedure->macro",makmacro},
	{"procedure->memoizing-macro",makmmacro},
	{"apply:nconc-to-last",nconc2last},
	{0,0}};

static iproc lsubr2s[] = {
/*	{s_apply,apply}, now explicity initted */
	{s_map,map},
	{s_for_each,for_each},
	{0,0}};

static smobfuns promsmob = {markcdr,free0,prinprom};
static smobfuns macrosmob = {markcdr,free0,prinmacro};

SCM make_synt(name,macroizer,fcn)
char *name;
SCM (*macroizer)();
SCM (*fcn)();
{
  SCM symcell = sysintern(name,UNDEFINED);
  long tmp = ((((CELLPTR)(CAR(symcell)))-heap_org)<<8);
  register SCM z;
  if ((tmp>>8) != ((CELLPTR)(CAR(symcell))-heap_org))
    tmp = 0;
  NEWCELL(z);
  SUBRF(z) = fcn;
  CAR(z) = tmp + tc7_subr_2;
  CDR(symcell) = macroizer(z);
  return CAR(symcell);
}

void init_eval()
{
  tc16_promise = newsmob(&promsmob);
  tc16_macro = newsmob(&macrosmob);
  init_iprocs(subr1s, tc7_subr_1);
  init_iprocs(lsubr2s, tc7_lsubr_2);
  i_apply = make_subr(s_apply, tc7_lsubr_2, apply);
  i_dot = CAR(sysintern(".",UNDEFINED));
  i_arrow = CAR(sysintern("=>",UNDEFINED));
  i_else = CAR(sysintern("else",UNDEFINED));
  i_unquote = CAR(sysintern("unquote",UNDEFINED));
  i_uq_splicing = CAR(sysintern("unquote-splicing",UNDEFINED));

  /* acros */
  i_quasiquote = make_synt(s_quasiquote, makacro, m_quasiquote);
  make_synt(s_define, makmmacro, m_define);
  make_synt(s_delay, makacro, m_delay);
  /* end of acros */

  make_synt(s_and, makmmacro, m_and);
  make_synt(s_begin, makmmacro, m_begin);
  make_synt(s_case, makmmacro, m_case);
  make_synt(s_cond, makmmacro, m_cond);
  make_synt(s_do, makmmacro, m_do);
  make_synt(s_if, makmmacro, m_if);
  i_lambda = make_synt(s_lambda, makmmacro, m_lambda);
  i_let = make_synt(s_let, makmmacro, m_let);
  make_synt(s_letrec, makmmacro, m_letrec);
  make_synt(s_letstar, makmmacro, m_letstar);
  make_synt(s_or, makmmacro, m_or);
  i_quote = make_synt(s_quote, makmmacro, m_quote);
  make_synt(s_set, makmmacro, m_set);
  make_synt(s_atapply, makmmacro, m_apply);
  make_synt(s_atcall_cc, makmmacro, m_cont);

  make_synt("defined?", makmmacro, definedp);
}
