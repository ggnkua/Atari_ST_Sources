
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

#define LINEBUF 128

char *cur_file;
unsigned long last_line,	/* the last line we registered */
  this_line,			/* the line we just read */
  next_line;			/* the line we're about to read */

static char *the_line;
static size_t the_size;
char *next_c;

/*
   trigraph() -- translate trigraph sequences in string |s|.  |s| is modified
   in place.
*/
static void trigraph(s)
  register char *s;
{
  register char *t = s;

  while (*s) {
    if (*s == '?' && s[1] == '?')
      switch (s[2]) {
      case '=':
	*t++ = '#';
	goto skip;
      case '/':
	*t++ = '\\';
	goto skip;
      case '\'':
	*t++ = '^';
	goto skip;
      case '(':
	*t++ = '[';
	goto skip;
      case ')':
	*t++ = ']';
	goto skip;
      case '!':
	*t++ = '|';
	goto skip;
      case '<':
	*t++ = '{';
	goto skip;
      case '>':
	*t++ = '}';
	goto skip;
      case '-':
	*t++ = '~';
      skip:s += 3;
	break;
      default:
	*t++ = *s++;
    } else
      *t++ = *s++;
  }
  *t = '\0';
}

/*
   getline() -- read a line from input file |f|, translate trigraphs if
   necessary, collapse lines spliced with \<newline>, and strip comments if
   necessary
*/
char *getline()
{
  register char *s, *t;
  ptrdiff_t dp;

  this_line = next_line;	/* tomorrow never arrives; it just becomes
				   today */
  if (!the_line)
    the_line = mallok(the_size = LINEBUF);
  s = the_line;
  if (!fgets(s, the_size, inf)) {
    return NULL;
  }
  if (do_trigraphs)
    trigraph(s);
  t = s + strlen(s);
  next_line++;
  for (;;) {
    if (t[-1] != '\n' || (--t > s && t[-1] == '\\')) {
      if (t[-1] == '\\') {
	t--;
	next_line++;
      }
      if (the_size - (t - s) < LINEBUF) {
	dp = t - s;
	the_size += LINEBUF;
	s = reallok(s, the_size);
	t = s + dp;
      }
      if (!fgets(t, (int)(the_size - (t - s)), inf)) {
	*t = '\0';
	break;
      }
      if (do_trigraphs)
	trigraph(t);
      t += strlen(t);
    } else
      break;
  }
  *t++ = '\0';
  the_line = next_c = s;
  return s;
}

/*
   flush_line() -- discard the rest of the input line and any pushed-back
   tokens
*/
void flush_line()
{
  next_c = NULL;
  flush_tokenizer();
}

/*
   rest_of_line() -- return a pointer to the remainder of the input line
*/
char *rest_of_line()
{
  return next_c;
}

/*
   tokenize_string() -- convert the string pointed to by |s| into a list of
   tokens.  If |s| is NULL, convert the remainder of the input line.
*/
TokenP tokenize_string(s)
  char *s;
{
  char *old_next_c;
  TokenP T = NULL, t = NULL, tt;

  if (s) {
    old_next_c = next_c;
    next_c = s;
  }
  for (;;) {
    tt = _one_token();
    if (tt->type == EOL) {
      free_token(tt);
      break;
    }
    if (!T)
      t = T = tt;
    else
      t = t->next = tt;
  }
  if (s)
    next_c = old_next_c;
  if (t) {
    t->next = NULL;
    *T->pre_ws = '\0';
  }
  return T;
}

/*
   expand_rest_of_line() -- tokenize and macro-expand the remainder of the
   input line.  Pushes the resulting Token list back onto the input stream.
   Note:  we restore here the EOL token that tokenize_string() threw away.
*/
void expand_rest_of_line()
{
  TokenP T1, T2, T3;

  T1 = tokenize_string(NULL);
  T2 = expand_tlist(T1);
  push_tlist(mk_eol());
  push_tlist(T2);
}
