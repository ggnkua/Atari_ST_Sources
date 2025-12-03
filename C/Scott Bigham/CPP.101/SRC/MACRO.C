
#include <stddef.h>
#include <string.h>
#include <time.h>
#include "global.h"

char *magic_words[] =
{
  "__STDC__",			/* these two are particuarly magic -- */
  "defined",			/* leave them where they are */
  "__DATE__",
  "__TIME__",
  "__FILE__",
  "__LINE__",
  "__INCLUDE_LEVEL__",
};
int N_MWORDS = nelems(magic_words);

/*
   magic_token() -- create a Token to be returned by expand_magic() below
*/
static TokenP magic_token(type, text, l, T0)
  int type;
  char *text;
  long l;
  TokenP T0;
{
  TokenP T = alloc_token();
  int len;
  register char *s, *t;

  T->pre_ws = strdup(T0->pre_ws);
  if (type != STR_CON)
    T->txt = strdup(T0->txt);
  else {
    len = strlen(T0->txt);
    T->txt = mallok(len + 3);
    strcpy(T->txt + 1, T0->txt);
    T->txt[0] = T->txt[len + 1] = '"';
    T->txt[len + 2] = '\0';
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
  TokenP T;
{
  static char buf[20];
  int i;
  TokenP T1, tL;
  Token tLH;

  for (i = 0; i < N_MWORDS; i++)
    if (streq(T->txt, magic_words[i]))
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
    tL = tL->next = T1;
    if (T1->type == ID) {
      if (lookup(T1->txt, T1->hashval))
	buf[0] = '1';
    } else if (T1->type == LPAREN) {
      T1 = token();
      tL = tL->next = T1;
      if (T1->type == STOP) {
	error("unterminated defined() macro");
	goto nope;
      } else if (T1->type == ID) {
	if (lookup(T1->txt, T1->hashval))
	  buf[0] = '1';
	T1 = token();
	tL = tL->next = T1;
	if (T1->type != RPAREN) {
	  error("missing `)' in defined()");
	  goto nope;
	}
      } else {
	error("parameter \"%s\" to defined() is not an identifier", T1->txt);
	goto nope;
      }
    } else {
      error("parameter \"%s\" to defined() is not an identifier", T1->txt);
      goto nope;
    }
    free_tlist(tLH.next);
    return magic_token(NUMBER, buf, (long)(*buf == '1'), T);
  nope:
    push_tlist(tLH.next);
    return magic_token(NUMBER, "0", 0L, T);
  case 2:			/* __DATE__ */
    return magic_token(STR_CON, date_string, 0L, T);
  case 3:			/* __TIME__ */
    return magic_token(STR_CON, time_string, 0L, T);
  case 4:			/* __FILE__ */
    return magic_token(STR_CON, cur_file, 0L, T);
  case 5:			/* __LINE__ */
    sprintf(buf, "%lu", this_line);
    return magic_token(NUMBER, buf, this_line, T);
  case 6:			/* __INCLUDE_LEVEL__ */
    sprintf(buf, "%lu", include_level);
    return magic_token(NUMBER, buf, include_level, T);
  default:
    bugchk("unknown magic word %s", T->txt);
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
  TokenP *args;
  int cur_arg, par_level = 0;
  TokenP T, L;
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
  TokenP tt, t0;

  s = buf = mallok(buflen = 80);
  *s++ = '"';
  for (tt = T; tt; tt = tt->next) {
    i = 2 * strlen(tt->txt) + 2;
    if (tt != T) ;
    i += strlen(tt->pre_ws);
    s = grow(&buf, &buflen, s, i);
    if (tt != T)
      for (t = tt->pre_ws; *t; t++)
	*s++ = *t;
    for (t = tt->txt; *t; t++) {
      if (*t == '\\' || *t == '"')
	*s++ = '\\';
      *s++ = *t;
    }
  }
  *s++ = '"';
  *s = '\0';
  t0 = alloc_token();
  t0->type = STR_CON;
  t0->txt = buf;
  t0->pre_ws = strdup(T->pre_ws);
  return t0;
}

/*
   expand() -- expand the macro definition |M| of the Token |T|. Returns a
   list of Token's representing the expanded text.

WARNING:  _Always_ check the BLUEPAINT flag before calling expand(), or
   you'll end up with either the wrong answer or an infinite loop, or both.
   At the moment this is not a concern, since only exp_token() calls
   expand().
*/
void expand(T, M)
  TokenP T;
  Macro *M;
{
  Token head1, head2, mhead;
  TokenP t1, pt1, t2 = &head2, pt2 = &head1, *args, *exp_args, *str_args;
  int n;

  head1.flags = head2.flags = mhead.flags = 0;
  head1.next = &head2;
  head2.next = NULL;
  mhead.next = M->m_text;
  if (M->flags & MARKED) {
    T->flags |= BLUEPAINT;
    push_tlist(T);
    return;
  }
  if (M->flags & MAGIC) {
    push_tlist(expand_magic(T));
    return;
  }
  if (M->flags & HASARGS) {
    t1 = token();
    if (t1->type != LPAREN) {
      push_tlist(t1);
      T->flags |= BLUEPAINT;
      push_tlist(T);
      return;
    }
    args = get_args(T->txt, M->nargs);
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
    if (head2.next->pre_ws)
      free(head2.next->pre_ws);
    head2.next->pre_ws = T->pre_ws;
  }
  /* add a trailing space */
  t2->flags |= TRAIL_SPC;
  push_tlist(mk_unmarker(T));
  push_tlist(head2.next);
}

/*
   expand_tlist() -- call expand() on each of a list of Token's, returning
   the resulting list of Token's
*/
TokenP expand_tlist(TL)
  TokenP TL;
{
  Token head;
  TokenP t1, t2 = &head;
  Macro *M;

  head.next = NULL;
  push_tlist(mk_stopper());
  push_tlist(TL);
  for (t1 = token(); t1->type != STOP; t1 = token()) {
    if (t1->type == ID && !(t1->flags & BLUEPAINT) &&
	(M = lookup(t1->txt, t1->hashval))) {
      expand(t1, M, NULL);
      free_token(t1);
    } else {
      t2->next = t1;
      t2 = t2->next;
    }
  }
  /* t1 should now hold a STOP token */
  free_token(t1);
  return head.next;
}
