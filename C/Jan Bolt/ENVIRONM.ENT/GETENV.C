/*===============================================================*
 *                                                               *
 * getenv.c                                                      *
 *                                                               *
 * replacement fÅr getenv.o aus tcstdlib                         *
 *                                                               *
 * char *getenv(const char *var)                                 *
 *                                                               *
 * Original fand auch Teilstrings anderer Variablen              *
 * getenv("PATH") fand "CDPATH"                                  *
 *                                                               *
 * 21.09.90 Jan Bolt                                             *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/

#include <tos.h>

#define NULL ((void *)0l)

extern BASPAG *_BasPag;

char *getenv(const char *var)
{
const char *v;
char *s = _BasPag->p_env;

if (s == NULL)
   return NULL;
while (*s)
      {
      for (v = var; *s && *s++ == *v++; )
          if (*s == '=' && *v == '\0')
             return ++s;
      while (*s++)
            ;
      }
return NULL;
}
