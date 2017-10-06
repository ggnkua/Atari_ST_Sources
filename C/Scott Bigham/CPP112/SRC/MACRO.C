
/*---------------------------------------------------------------------*\
|									|
| CPP -- a stand-alone C preprocessor					|
| Copyright (c) 1993 Hacker Ltd.		Author: Scott Bigham	|
|									|
| Permission is granted to anyone to use this software for any purpose	|
| on any computer system, and to redistribute it freely, with the	|
| following restrictions:						|
| - No charge may be made other than reasonable charges for repro-	|
|     duction.								|
| - Modified versions must be clearly marked as such.			|
| - The author is not responsible for any harmful consequences of	|
|     using this software, even if they result from defects therein.	|
|									|
| macro.c -- do macro expansion						|
\*---------------------------------------------------------------------*/

#include <stddef.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include "global.h"
#include "alloc.h"

static char SC_not_id[] = "parameter \"%s\" to defined() is not an identifier";

char *magic_words[] =
{
  "__STDC__",			/* the first three are particuarly magic -- */
  "defined",			/* leave them where they are */
  "__FLUFF__",
  "__DATE__",
  "__TIME__",
  "__FILE__",
  "__LINE__",
  "__INCLUDE_LEVEL__",
};
int N_MWORDS = nelems(magic_words);
int N_M2WORDS = 3;		/* number of "special" magic words */

/* mk_Macro() -- allocate and initialize a macro structure */
Macro *mk_Macro()
{
  register Macro *M = alloc_Macro();

  M->flags = M->nargs = 0;
  M->m_text = M->argnames = NULL;
  M->next = NULL;
  return M;
}

/* free_Macro() -- clean up and deallocate a macro structure */
void free_Macro(M)
  register Macro *M;
{
  if (!M)
    return;
  if (M->m_text)
    free_tlist(M->m_text);
  if (M->argnames)
    free_tlist(M->argnames);
  dealloc_Macro(M);
}

/*
   magic_token() -- create a Token to be returned by expand_magic() below
*/
static TokenP magic_token(type, text, l, T0)
  int type;
  const char *text;
  long l;
  TokenP T0;
{
  register TokenP T = mk_Token();

  set_ws(T, token_ws(T0));
  if (type != STR_CON)
    set_txt(T, text);
  else {
    char *u = mallok(strlen(text) + 3);

    (void)sprintf(u, "\"%s\"", text);
    set_txt(T, u);
    free(u);
  }
  T->type = type;
  if (type == NUMBER)
    T->val = l;
  if (type == ID)
    T->flags |= BLUEPAINT;
  return T;
}

/* expand_magic() -- expand a magic preprocessor constant */
static TokenP expand_magic(T)
  register TokenP T;
{
  static char buf[20];
  int i;
  register TokenP T1, tL;
  Token tLH;

  for (i = 0; i < N_MWORDS; i++)
    if (streq(token_txt(T), magic_words[i]))
      break;
  switch (i) {
  case 0:			/* __STDC__ */
    return magic_token(NUMBER, "1", 1L, T);
  case 1:			/* defined */
    tL = &tLH;
    tL->next = NULL;
    buf[0] = '0';
    buf[1] = '\0';
    T1 = token();
    if (T1->type == STOP) {
      push_tlist(T1);
      error("defined() has no parameter");
      goto nope;
    }
#if 0
    tL = tL->next = T1;
#endif
    if (T1->type == ID) {
      if (lookup(token_txt(T1), T1->hashval))
	buf[0] = '1';
      free_token(T1);
    } else if (T1->type == LPAREN) {
      free_token(T1);
      T1 = token();
#if 0
      tL = tL->next = T1;
#endif
      if (T1->type == STOP) {
	push_tlist(T1);
	error("unterminated defined() macro");
	goto nope;
      } else if (T1->type == ID) {
	if (lookup(token_txt(T1), T1->hashval))
	  buf[0] = '1';
	free_token(T1);
	T1 = token();
#if 0
	tL = tL->next = T1;
#endif
	if (T1->type != RPAREN) {
	  push_tlist(T1);
	  error("missing `)' in defined()");
	  goto nope;
	}
	free_token(T1);
      } else {
	error(SC_not_id, token_txt(T1));
	free_token(T1);
	goto nope;
      }
    } else {
      error(SC_not_id, token_txt(T1));
      free_token(T1);
      goto nope;
    }
#if 0
    free_tlist(tLH.next);
#endif
    return magic_token(NUMBER, buf, (long)(*buf == '1'), T);
  nope:
#if 0
    push_tlist(tLH.next);
#endif
    return magic_token(NUMBER, "0", 0L, T);
  case 2:			/* __FLUFF__ */
    return magic_token(NUMBER, "1", 1L, T);
  case 3:			/* __DATE__ */
    return magic_token(STR_CON, date_string, 0L, T);
  case 4:			/* __TIME__ */
    return magic_token(STR_CON, time_string, 0L, T);
  case 5:			/* __FILE__ */
    return magic_token(STR_CON, cur_file, 0L, T);
  case 6:			/* __LINE__ */
    sprintf(buf, "%lu", this_line);
    return magic_token(NUMBER, buf, this_line, T);
  case 7:			/* __INCLUDE_LEVEL__ */
    sprintf(buf, "%lu", include_level);
    return magic_token(NUMBER, buf, include_level, T);
  default:
    bugchk("unknown magic word %s", token_txt(T));
  }
}

/*
   get_args() -- read in the actual arguments of a macro expansion. |mname|
   is the name of the macro being expanded; |nargs| is the number of
   arguments to read.
*/
static TokenP *get_args(mname, nargs)
  char *mname;
  int nargs;
{
  int cur_arg, par_level = 0;
  register TokenP T, L;
  register TokenP *args;
  Token head;

  args = (TokenP *) mallok((nargs ? nargs : 1) * sizeof (TokenP));
  for (cur_arg = 0; cur_arg < nargs || cur_arg == 0; cur_arg++)
    args[cur_arg] = NULL;
  cur_arg = 0;
  L = &head;
  L->next = NULL;
  change_mode(SLURP, 0);
  for (;;) {
    T = token();
    switch (T->type) {
    case STOP:
      push_tlist(T);
      error("unterminated macro \"%s\"", mname);
      goto out_loop;
    case EOL:
      free_token(T);
      continue;
    case LPAREN:
      par_level++;
      break;
    case RPAREN:
      if (--par_level < 0) {
	free_token(T);
	goto out_loop;
      }
      break;
    case COMMA:
      if (par_level == 0) {
	free_token(T);
	args[cur_arg++] = head.next;
	L = &head;
	L->next = NULL;
	continue;
      }
      break;
    }
    if (cur_arg < nargs)
      L = L->next = T;
  }
out_loop:
  change_mode(0, SLURP);
  if (head.next || cur_arg > 0)
    args[cur_arg++] = head.next;
  if (cur_arg != nargs)
    error("macro \"%s\" declared with %d arg%s, used with %d",
	  mname, nargs, (nargs == 1 ? "" : "s"), cur_arg);
  return args;
}

/*
   stringize() -- create a string literal representing the token list |T|
*/
static TokenP stringize(T)
  TokenP T;
{
  char *buf;
  register char *s, *t;
  size_t buflen, i;
  ptrdiff_t dp;
  register TokenP tt;
  TokenP t0;

  s = buf = mallok(buflen = 80);
  *s++ = '"';
  for (tt = T; tt; tt = tt->next) {
    i = 2 * strlen(token_txt(tt)) + 2;
    if (tt != T)
      i += strlen(token_ws(tt));
    s = grow(&buf, &buflen, s, i);
    if (tt != T)
      for (t = token_ws(tt); *t; t++)
	*s++ = *t;
    for (t = token_txt(tt); *t; t++) {
      if (*t == '\\' || *t == '"')
	*s++ = '\\';
      *s++ = *t;
    }
  }
  *s++ = '"';
  *s = '\0';
  t0 = mk_Token();
  t0->type = STR_CON;
  set_txt(t0, buf);
  free(buf);
  set_ws(t0, token_ws(T));
  return t0;
}

/*
   expand() -- expand the macro definition |M| of the Token |T|.  Push the
   resulting token list onto the token stream.

WARNING:  _Always_ check the BLUEPAINT flag before calling expand(), or
   you'll end up with either the wrong answer or an infinite loop, or both.
   At the moment this is not a concern, since only exp_token() and
   expand_tlist() call expand().

NOTE:  |T| should be free_token()'d after the call to expand().
*/
void expand(T, M)
  TokenP T;
  register Macro *M;
{
  Token head1, head2, mhead;
  register TokenP t1, pt1, t2 = &head2;
  TokenP pt2 = &head1, *args, *exp_args, *str_args;
  int n;

  head1.flags = head2.flags = mhead.flags = 0;
  head1.next = &head2;
  head2.next = NULL;
  mhead.next = M->m_text;
  if (M->flags & MARKED) {
    t1 = copy_token(T);
    t1->flags |= BLUEPAINT;
    push_tlist(t1);
    return;
  }
  if (M->flags & MAGIC) {
    push_tlist(expand_magic(T));
    return;
  }
  if (M->flags & HASARGS) {
    t1 = token();
    if (t1->type == STOP) {

      /*
         Special case:  we can't expand this token now, but if it is placed
         before a left paren, we can expand it later.  Mark it to be
         unpainted after expansion.
      */
      push_tlist(t1);
      t1 = copy_token(T);
      t1->flags |= BLUEPAINT | UNPAINT_ME;
      push_tlist(t1);
      return;
    }
    if (t1->type != LPAREN) {
      push_tlist(t1);
      t1 = copy_token(T);
      t1->flags |= BLUEPAINT;
      push_tlist(t1);
      return;
    }
    free_token(t1);
    args = get_args(token_txt(T), M->nargs);
    exp_args = mallok(M->nargs * sizeof (TokenP));
    str_args = mallok(M->nargs * sizeof (TokenP));
    for (n = 0; n < M->nargs; n++)
      if (args[n]) {
	exp_args[n] = expand_tlist(copy_tlist(args[n]));
	str_args[n] = stringize(args[n]);
      } else
	exp_args[n] = str_args[n] = NULL;
  } else
    args = exp_args = str_args = NULL;
  M->flags |= MARKED;
  t2->next = NULL;
  for (t1 = M->m_text, pt1 = &mhead; t1; t1 = t1->next, pt1 = pt1->next) {
    TokenP t3;

    if (t1->type == MACRO_ARG) {
      t3 = copy_tlist(
		       (t1->flags & STRINGIZE_ME ? str_args
		: t1->flags & CONCAT_NEXT || pt1->flags & CONCAT_NEXT ? args
			: exp_args
		       )[t1->val]
	  );
      /* copy over the leading whitespace from t1 */
#if 0
      if (t1->pre_ws) {
	if (t3->pre_ws)
	  free(t3->pre_ws);
	t3->pre_ws = strdup(t1->pre_ws);
      }
#else
      set_ws(t3, token_ws(t1));
#endif
    } else {
      t3 = copy_token(t1);
      t3->flags &= ~(STRINGIZE_ME | CONCAT_NEXT | TRAIL_SPC);
    }
    if (pt1->flags & CONCAT_NEXT) {
      TokenP t4;

      t4 = merge_tokens(t2, t3);
      pt2->next = t4;
      t4->next = t3->next;
      t2->next = t3->next = NULL;
      free_token(t2);
      free_token(t3);
      t2 = t4;
    } else
      t2->next = t3;
    while (t2->next) {
      t2 = t2->next;
      pt2 = pt2->next;
    }
  }

  /*
     prepend the leading whitespace from T to the first token of the expanded
     text, if any
  */
  if (head2.next) {
#if 0
    if (head2.next->pre_ws)
      free(head2.next->pre_ws);
    head2.next->pre_ws = strdup(T->pre_ws);
#else
    set_ws(head2.next, token_ws(T));
#endif
  }
  /* add a trailing space */
  t2->flags |= TRAIL_SPC;
  push_tlist(mk_unmarker(T));
  push_tlist(head2.next);

  /* clear out the tables of arguments we created on entry */
  if (args) {
    for (n = 0; n < M->nargs; n++) {
      if (args[n])
	free_tlist(args[n]);
    }
    free(args);
  }
  if (exp_args) {
    for (n = 0; n < M->nargs; n++) {
      if (exp_args[n])
	free_tlist(exp_args[n]);
    }
    free(exp_args);
  }
  if (str_args) {
    for (n = 0; n < M->nargs; n++) {
      if (str_args[n])
	free_tlist(str_args[n]);
    }
    free(str_args);
  }
}

/*
   expand_tlist() -- call expand() on each of a list of Token's, returning
   the resulting list of Token's
*/
TokenP expand_tlist(TL)
  TokenP TL;
{
  Token head;
  register TokenP t1, t2 = &head;
  Macro *M;

  head.next = NULL;
  push_tlist(mk_stopper());
  push_tlist(TL);
  for (t1 = token(); t1->type != STOP; t1 = token()) {
    if (t1->type == ID && !(t1->flags & BLUEPAINT) &&
	(M = lookup(token_txt(t1), t1->hashval))) {
      expand(t1, M);
      free_token(t1);
    } else {
      t2->next = t1;
      t2 = t2->next;
    }
  }
  /* t1 should now hold a STOP token */
  if (t1->type != STOP)
    bugchk("%d isn't STOP...", (int)t1->type);

  /*
     Special case:  the last token in the list may need to be unpainted. See
     expand() for details.
  */
  if (t2->flags & UNPAINT_ME)
    t2->flags &= ~(BLUEPAINT | UNPAINT_ME);
  free_token(t1);
  return head.next;
}
