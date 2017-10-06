
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
| comment.c -- comment and whitespace processing			|
\*---------------------------------------------------------------------*/

#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "global.h"

#define SPC_GRAN 16
#define LINEBUF 128

char *the_comment;
size_t len_comment;

static char SC_nested[] = "nested comment (began at line %lu)",
	    SC_unterm[] = "unterminated comment (began at line %ld)";
/*
   find_start_comment() -- return a pointer to the first comment-start
   sequence after |s|, or |NULL| if none is found
*/
static char *find_start_comment(s)
  register char *s;
{
  register int in_dq = 0, in_sq = 0;

  for (;;) {
    switch (*s++) {
    case '\0':
      return NULL;
    case '\\':
      s++;
      continue;
    case '"':
      if (!in_sq)
	in_dq ^= 1;
      break;
    case '\'':
      if (!in_dq)
	in_sq ^= 1;
      break;
    case '/':
      if (!in_dq && !in_sq && *s == '*')
	return s - 1;
    }
  }
}

/*
   find_end_comment() -- return a pointer to the first character after the
   current comment, or end of line if the comment does not end on this line.
*/
static char *find_end_comment(s)
  register char *s;
{
  for (; *s; s++) {
    if (*s == '*' && s[1] == '/')
      return s + 2;
  }
  return NULL;
}

/*
   nest_check() -- examine the body of a comment for comment-start sequences.
   Return 1 if one is found, 0 if not.
*/
static int nest_check(s, t)
  register char *s, *t;
{
  register char *u;

  if (!t)
    t = s + strlen(s);
  if (f_cpp_cmts) {
    for (u = s; u < t - 1; u++)
      if (*u == '/' && (u[1] == '*' || u[1] == '/'))
	return 1;
  } else {
    for (u = s; u < t - 1; u++)
      if (*u == '/' && u[1] == '*')
	return 1;
  }
  return 0;
}

/*
   copy_comment() -- place a malloc()'ed copy of the comment beginning at |s|
   into the global pointer |the_comment|.  Return a pointer to the first
   character after the comment.
*/
static char *copy_comment(s)
  register char *s;
{
  register char *in_com, *t;
  register int n;
  register unsigned long in_comment;

  in_comment = this_line;
  in_com = the_comment = mallok(len_comment = LINEBUF);
  if (s[1] == '/') {
    free(the_comment);
    the_comment = strdup(s);
    if (w_nest_cmts && nest_check(s + 2, (char *)0))
      warning(SC_nested, in_comment);
    return s + strlen(s);
  }
  for (;;) {
    t = find_end_comment(s);
    n = (!t ? strlen(s) + 2 : (int)(t - s) + 1);
    in_com = grow(&the_comment, &len_comment, in_com, n);
    (void)strncpy(in_com, s, n);
    in_com += n;
    if (!t)
      *in_com++ = '\n';
    *in_com = '\0';
    if (w_nest_cmts && nest_check(s, t))
      warning(SC_nested, in_comment);
    if (t)
      break;
    s = getline();
    if (!s) {
      error(SC_unterm, in_comment);
      in_com = grow(&the_comment, &len_comment, in_com, 3);
      *in_com++ = '*';
      *in_com++ = '/';
      *in_com = '\0';
      t = NULL;
      break;
    }
  }
  return t;
}

/*
   suck_comment() -- Skip over the comment beginning at |s|.  Return a
   pointer to the first character after the comment.
*/
static char *suck_comment(s)
  register char *s;
{
  register char *t;
  register unsigned long in_comment;

  if (keep_comments)
    return copy_comment(s);
  in_comment = this_line;
  /* C++ comments end at the end of the line */
  if (s[1] == '/') {
    if (w_nest_cmts && nest_check(s + 2, (char *)0))
      warning(SC_nested, in_comment);
    return s + strlen(s);
  }
  for (;;) {
    t = find_end_comment(s);
    if (w_nest_cmts && nest_check(s + 2 * (this_line == in_comment), t))
      warning(SC_nested, in_comment);
    if (t) {
      return t;
    }
    s = getline();
    if (!s) {
      error(SC_unterm, in_comment);
      return NULL;
    }
  }
}

/*
   suck_ws() -- skip over whitespace characters after |S|, placing them
   into the whitespace field of |T|.  Return a pointer to the first
   non-whitespace character after |s|.
*/
char *suck_ws(s, T)
  register char *s;
  TokenP T;
{
  register char *t, *u;
  char *spc_buf;
  size_t sz_spc_buf;
  register int n;

  u = spc_buf = mallok(sz_spc_buf = SPC_GRAN);
  for (;;) {
    t = s;
    while (isspace(*s))
      *s++;
    n = (int)(s - t);
    u = grow(&spc_buf, &sz_spc_buf, u, n + 2);
    (void)strncpy(u, t, n);
    u += n;
    *u = '\0';
    if (!(*s == '/' && (s[1] == '*' || (f_cpp_cmts && s[1] == '/'))))
      break;
    s = suck_comment(s);
    if (!keep_comments)
      *u++ = ' ';
    else {
      n = strlen(the_comment);
      u = grow(&spc_buf, &sz_spc_buf, u, n + 1);
      (void)strcpy(u, the_comment);
      free(the_comment);
      u += n;
    }
    if (!s)
      break;
  }
  *u = '\0';
  set_ws(T, spc_buf);
  free(spc_buf);
  return s;
}
