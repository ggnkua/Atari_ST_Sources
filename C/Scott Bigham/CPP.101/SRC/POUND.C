
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include "global.h"

#define IF_STACK_SIZE 10
#define N_DIRS nelems(d_table)
#define IF_STATE (if_sp[-1])

#define COND_FALSE	0
#define COND_ELSE_SEEN	4
#define COND_DONE_TRUE	8

/* a bundle of information about a preprocessor directive */
typedef struct {
  char *word;
  int is_cond;
  void (*handler) __PROTO((void));
} Directive;

static int *if_stack, if_stack_size;
int *if_sp;

extern void do_include __PROTO((void));
extern void do_define __PROTO((void));
extern void do_undefine __PROTO((void));

/* set up the conditional-compile stack */
void cond_setup()
{
  if_sp = if_stack = (int *)mallok((if_stack_size = IF_STACK_SIZE) * sizeof (int));

  *if_sp++ = COND_TRUE;
}

/*
   endif_check() -- see if there are states left on the stack; each
   corresponds to a missing #endif
*/
void endif_check()
{
  int i;

  i = if_sp - if_stack - 1;
  if (i) {
    while (i--)
      error("missing #endif");
  }
}

/* cond_shutdown() -- free the conditional-compile stack() */
void cond_shutdown()
{
  free(if_stack);
}

/* cond_push() -- push a conditional-compile state onto the stack */
static void cond_push(s)
  int s;
{
  if (if_sp - if_stack >= if_stack_size) {
    ptrdiff_t dp;

    dp = if_sp - if_stack;
    if_stack = reallok(if_stack, (if_stack_size *= 2) * sizeof (int));

    if_sp = if_stack + dp;
  }
  *if_sp++ = s;
}

/* cond_pop() -- remove a conditional-compile state from the stack */
static void cond_pop()
{
  if (if_sp - if_stack <= 1)
    error("unmatched #endif");
  else
    if_sp--;
}

/* do_if() -- handle an #if directive */
static void do_if()
{
  cond_push(!cond_true()? COND_NESTED :
	    if_expr()? COND_TRUE | COND_DONE_TRUE :
	    COND_FALSE
  );
}

/* do_ifdef() -- handle an #ifdef directive */
static void do_ifdef()
{
  TokenP T;

  T = _one_token();
  if (T->type != ID)
    error("argument \"%s\" to #ifdef is not an identifier", T->txt);
  else {
    cond_push(!cond_true()? COND_NESTED :
	      lookup(T->txt, T->hashval) ? COND_TRUE | COND_DONE_TRUE :
	      COND_FALSE
	);
  }
  free_token(T);
  T = _one_token();
  if (T->type != EOL)
    warning("garbage after #ifdef");
  free_token(T);
}

/* do_ifndef() -- handle an #ifndef directive */
static void do_ifndef()
{
  TokenP T;

  T = _one_token();
  if (T->type != ID)
    error("argument \"%s\" to #ifndef is not an identifier", T->txt);
  else {
    cond_push(!cond_true()? COND_NESTED :
	      lookup(T->txt, T->hashval) ? COND_FALSE :
	      COND_TRUE | COND_DONE_TRUE
	);
  }
  free_token(T);
  T = _one_token();
  if (T->type != EOL)
    warning("garbage after #ifndef");
  free_token(T);
}

/* do_else() -- handle an #else directive */
static void do_else()
{
  TokenP T;

  if (IF_STATE & COND_ELSE_SEEN)
    error("#else after #else");
  if (IF_STATE & COND_DONE_TRUE)
    IF_STATE &= (~COND_TRUE);
  else
    IF_STATE |= (COND_TRUE | COND_DONE_TRUE);
  T = _one_token();
  if (T->type != EOL)
    warning("garbage after #else");
  free_token(T);
}

/* do_elif() -- handle an #elif directive */
static void do_elif()
{
  TokenP T;

  if (IF_STATE & COND_ELSE_SEEN)
    error("#elif after #else");
  if (IF_STATE & COND_DONE_TRUE)
    IF_STATE &= (~COND_TRUE);
  else if (if_expr())
    IF_STATE |= (COND_TRUE | COND_DONE_TRUE);
  else
    IF_STATE &= (~COND_TRUE);
}

/* do_endif() -- handle an #endif directive */
static void do_endif()
{
  TokenP T;

  cond_pop();
  T = _one_token();
  if (T->type != EOL)
    warning("garbage after #endif");
  free_token(T);
}

/* do_line() -- handle a #line directive */
static void do_line()
{
  unsigned long ln;
  TokenP Tn, Tf;
  int l;

  _tokenize_line();
  Tn = exp_token();
  if (Tn->type != NUMBER) {
    error("malformed number \"%s\" in #line directive", Tn->txt);
    return;
  }
  Tf = exp_token();
  if (Tf->type != STR_CON && Tf->type != EOL) {
    error("malformed filename \"%s\" in #line directive", Tf->txt);
    return;
  }
  if (Tf->type == STR_CON) {
    l = strlen(Tf->txt) - 2;
    free(cur_file);
    cur_file = mallok(l);
    strncpy(cur_file, Tf->txt + 1, l - 2);
    cur_file[l] = '\0';
    free_token(Tf);
    Tf = exp_token();
    if (Tf->type != EOL)
      error("garbage after #line");
    free_token(Tf);
  }
  this_line = next_line = Tn->val;
  sync_line(0);
  free_token(Tn);
}

/* do_error() -- handle an #error directive */
static void do_error()
{
  error("%s", rest_of_line());
}

/* do_pragma() -- handle a #pragma directive */
static void do_pragma()
{
  /* at the moment, we don't recognize any #pragma directives */
}

/* do_nothing() -- handle a # directive */
static void do_nothing()
{
}

/* blurbs on all the recognized preprocessor directives */
Directive d_table[] =
{
  {"define", 0, do_define},
  {"undef", 0, do_undefine},
  {"include", 0, do_include},
  {"if", 1, do_if},
  {"ifdef", 1, do_ifdef},
  {"ifndef", 1, do_ifndef},
  {"else", 1, do_else},
  {"elif", 1, do_elif},
  {"endif", 1, do_endif},
  {"line", 0, do_line},
  {"error", 0, do_error},
  {"pragma", 0, do_pragma},
  {"", 0, do_nothing}
};

/*
   directive() -- perform the directive on the current input line
*/
void directive()
{
  char *outline;
  TokenP T;
  int i;
  Directive *d;

  T = _one_token();
  if (T->type == EOL) {
    free_token(T);
    return;
  }
  for (i = 0, d = d_table; i < N_DIRS; i++, d++)
    if (streq(T->txt, d->word))
      break;
  if (i == N_DIRS)
    fatal("unrecognized preprocessor directive #%s", T->txt);
  if (cond_true() || d->is_cond)
    (*d->handler) ();
  free_token(T);
  flush_line();
}
