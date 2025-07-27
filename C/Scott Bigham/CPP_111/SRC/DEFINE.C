
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
| define.c -- handle #define and #undef directives			|
\*---------------------------------------------------------------------*/

#include <string.h>
#include "global.h"

/*
   get_parms() -- return a list of the formal parameters in a macro
   definition.  Return the number of parameters in |*n|.
*/
static TokenP get_parms(n)
  register int *n;
{
  register TokenP T, parms;
  Token phead;

  for (*n = 0, parms = &phead, phead.next = NULL;;) {
    T = token();
    if (T->type == EOL)
      goto oops;
    if (T->type == RPAREN) {
      if (*n == 0)
	return NULL;
      goto oops;
    }
    if (T->type != ID)
      goto oops;
    parms = parms->next = T;
    (*n)++;
    T = token();
    switch (T->type) {
    case COMMA:
      free_token(T);
      continue;
    case RPAREN:
      free_token(T);
      return phead.next;
    default:
      free_token(T);
      goto oops;
    }
  }
oops:
  error("syntax error in macro definition");
  if (parms)
    free_tlist(parms);
  *n = -1;
  return NULL;
}

/*
   macro_eq() -- determine if macro bodies |M1| and |M2| are equal, modulo
   whitespace.  Currently experimental.
*/
int macro_eq(M1, M2)
  Macro *M1, *M2;
{
  register TokenP h1, h2;
  if (M1->flags != M2->flags || M1->nargs != M2->nargs)
    return 0;
  for (h1 = M1->argnames, h2 = M2->argnames;
       h1 && h2;
       h1 = h1->next, h2 = h2->next)
    if (!streq(h1->txt, h2->txt))
      return 0;
  for (h1 = M1->m_text, h2 = M2->m_text;
       h1 && h2;
       h1 = h1->next, h2 = h2->next)
    if (h1->type != h2->type &&
        h1->subtype != h2->subtype &&
        h1->hashval != h2->hashval &&
        !streq(h1->txt, h2->txt) &&
        (h1->flags & ~BLUEPAINT) != (h2->flags & ~BLUEPAINT))
      return 0;
  return 1;
}

/*
   is_parm() -- determine if Token |T| is one of the formal parameters of the
   macro.  Return the "index" into the list of parameters, or -1 if there is
   no match
*/
static int is_parm(T, parms)
  register TokenP T, parms;
{
  int i;
  register TokenP t;

  if (parms == NULL)
    return -1;
  for (i = 0, t = parms; t; i++, t = t->next) {
    if (streq(T->txt, t->txt)) {
      return i;
    }
  }
  return -1;
}

/* do_define() -- handle a #define directive */
void do_define()
{
  TokenP K, L;
  register TokenP T, pT;
  register Macro *M, *M1;
  int i;
  static Token head;

  _tokenize_line();
  K = token();
  if (K->type != ID) {
    error("argument \"%s\" to #define is not an identifier", K->txt);
    return;
  }
  M = (Macro *)mallok(sizeof (Macro));

  M->flags = 0;
  T = token();
  if (strlen(T->pre_ws) == 0 && T->type == LPAREN) {
    /* a macro with arguments -- get the formal parameters */
    free_token(T);
    T = NULL;
    M->flags |= HASARGS;
    M->argnames = get_parms(&M->nargs);
    if (M->nargs < 0) {
      free_tlist(M->argnames);
      free(M);
      return;
    }
  } else {
    M->nargs = 0;
    M->argnames = NULL;
    push_tlist(T);
  }
  L = &head;
  head.next = NULL;
  for (;;) {
    T = token();
    if (T->type == EOL)
      break;
    switch (T->type) {
    case POUND:
      free_token(T);
      T = token();
      if ((i = is_parm(T, M->argnames)) < 0) {
	error("# not followed by macro parameter");
	push_tlist(T);
	break;
      }
      T->type = MACRO_ARG;
      T->flags |= STRINGIZE_ME;
      T->val = i;
      L = L->next = T;
      break;
    case TOK_CAT:
      free_token(T);
      T = token();
      if (L == &head || T->type == EOL) {
	if (L == &head)
	  error("## at beginning of macro body");
	if (T->type == EOL)
	  error("## at end of macro body");
	break;
      }
      L->flags |= CONCAT_NEXT;
      push_tlist(T);
      break;
    case ID:
      if ((i = is_parm(T, M->argnames)) >= 0) {
	T->type = MACRO_ARG;
	T->val = i;
      }
      L = L->next = T;
      break;
    default:
      L = L->next = T;
      break;
    }
  }
  /* remove leading space from the resulting sequence */
  T = head.next;
  if (T)
    *T->pre_ws = '\0';
  M->m_text = head.next;

  /*
     As per the Standard, a macro can only be re-#define'd with an identical
     body, modulo whitespace.
  */
  if ((M1 = lookup(K->txt, K->hashval)) && !macro_eq(M, M1)) {
    warning("non-identical redefine of \"%s\"", K->txt);
    free_tlist(M->m_text);
    free_tlist(M->argnames);
    free(M);
  } else {
    hash_add(K->txt, K->hashval, M);
  }
  free_token(K);
}

/* do_undefine() -- handle an #undef directive */
void do_undefine()
{
  register Macro *M;
  register TokenP T;

  T = _one_token();
  if (T->type != ID) {
    if (T->type == EOL)
      error("missing argument to #undef");
    else
      error("argument \"%s\" to #undef is not an identifier", T->txt);
    free_token(T);
    return;
  }
  M = lookup(T->txt, T->hashval);
  if (M && !(M->flags & MAGIC))
    hash_remove(T->txt, T->hashval);
  free_token(T);
  T = _one_token();
  if (T->type != EOL)
    warning("garbage after #undef");
  free_token(T);
}
