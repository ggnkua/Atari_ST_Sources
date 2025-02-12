

/* $Id: phtoelm.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *phtoelm_id = "$Id: phtoelm.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#include <stdio.h>
#include <ctype.h>
#if defined (__STDC__)
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include "proto.h"
#include "elements.h"
#include "darray.h"
#include "trie.h"
#include "phtoelm.h"
#include "holmes.h"

trie_ptr phtoelm = NULL;

static Elm_ptr find_elm PROTO((char *s));

static Elm_ptr
find_elm(s)
char *s;
{
 Elm_ptr e = Elements;
 while (e < Elements + num_Elements)
  {
   if (!strcmp(s, e->name))
    {
     return e;
    }
   e++;
  }
 return NULL;
}

#if defined (__STDC__)
static void
enter(char *p,...)
#else
static void
enter(p, va_alist)
char *p;
va_dcl
#endif
{
 va_list ap;
 char *s;
 char buf[20];
 char *x = buf + 1;
#if defined(__STDC__)
 va_start(ap, p);
#else
 va_start(ap);
#endif
 while ((s = va_arg(ap, char *)))
  {
   Elm_ptr e = find_elm(s);
   if (e)
    *x++ = (e - Elements);
   else
    {
     fprintf(stderr, "Cannot find %s\n", s);
    }
  }
 va_end(ap);
 buf[0] = (x - buf) - 1;
 x = malloc(buf[0] + 1);
 memcpy(x, buf, buf[0] + 1);
 trie_insert(&phtoelm, p, x);
}

static void enter_phonemes
PROTO((void))
{
#include "phtoelm.def"
}

void
phone_append(p, ch)
darray_ptr p;
int ch;
{
 char *s = (char *) darray_find(p, p->items);
 *s = ch;
}

unsigned
phone_to_elm(phone, n, elm)
char *phone;
int n;
darray_ptr elm;
{
 char *s = phone;
 unsigned t = 0;
 char *limit = s + n;
 if (!phtoelm)
  enter_phonemes();
 while (s < limit && *s)
  {
   char *e = trie_lookup(&phtoelm, &s);
   if (e)
    {
     int n = *e++;
     while (n-- > 0)
      {
       int x = *e++;
       t += Elements[x].du * speed;
       phone_append(elm, x);
      }
    }
   else
    {
     char ch = *s++;
     switch (ch)
      {
       case '\'':              /* Primary stress */
       case ',':               /* Secondary stress */
       case '+':               /* Stress of some kind */
       case '-':               /* hyphen in input */
        break;
       default:
        fprintf(stderr, "Ignoring %c in '%.*s'\n", ch, n, phone);
        break;
      }
    }
  }
 return t;
}
