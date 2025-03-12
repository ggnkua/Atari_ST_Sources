/*===============================================================*
 *                                                               *
 * putenv.c                                                      *
 *                                                               *
 *   int putenv (const char *entry)                              *
 *                                                               *
 *   FÅgt <entry> zum Environment hinzu.                         *
 *   entry:                                                      *
 *   <VARIABLE>          lîsche <VARIABLE>                       *
 *   <VARIABLE>=<value>  setze  <VARIABLE>=<value>               *
 *                                                               *
 *   putenv = 1 ok                                               *
 *   putenv = 0 kein Speicher verfÅgbar                          *
 *                                                               *
 * 01.06.90 Jan Bolt       Version 220990                        *
 *                                                               *
 * Turbo C                                                       *
 *===============================================================*/
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

extern BASPAG *_BasPag;            /* Zeiger auf base page */

static char *envbeg = NULL;        /* Beginn Environment */

/* liefert Zeiger auf <var> im Environment */
static char *Getvar(const char *var)
{
const char *v;
char *r, *s = envbeg;

while (*s)
      {
      for (r = s, v = var; *s && *s++ == *v++; )
          if (*s == '=' && (*v == '=' || *v == '\0'))
             return r;
      while (*s++)
            ;
      }
return NULL;
}

/* kopiert Environment von <s> nach <d>, */
static void Copy(char *s, char *d)
{
do
      while ((*d++ = *s++) != '\0')
            ;
while (*s);
*d = '\0';
}

int putenv(const char *entry)
{
const char *e;
char *d, *s;
size_t envlen = 0;
unsigned l, new;

s = _BasPag->p_env;
/* LÑnge Environment bestimmen */
if (s != NULL && *s)
   {
   while (*s)
         while (*s++)
               ;
   envlen = s - _BasPag->p_env;
   }

if (envbeg == NULL)
   {
   s = _BasPag->p_env;
   /* lokales Environment anlegen */
   if ((envbeg = malloc(envlen + 2)) == NULL)
      return 0;
   /* altes Environment kopieren */
   if (s != NULL && *s)
      Copy(s, envbeg);
   else
      envbeg[0] = envbeg[1] = '\0';
   _BasPag->p_env = envbeg;
   }

if ((d = s = Getvar(entry)) != NULL) /* Variable lîschen */
   {
   while (*s++)                      /* Variablenende */
         ;
   envlen -= s - d;                  /* LÑnge anpassen */
   if (*s)
      Copy(s, d);                    /* Rest aufrÅcken */
   else
      d[0] = d[1] = '\0';            /* ist letzte Var */
   }

for (e = entry, new = l = 0; *e++; l++)
    if (*e == '=')
       new = 1;
if (new)
   envlen += l + 1;
if ((d = malloc(envlen + 2)) == NULL)
   return 0;                       /* Environmentgrîûe */
Copy(envbeg, d);                   /* anpassen und */
free(envbeg);                      /* Daten kopieren */
envbeg = d;
   
if (new)                           /* Neue Variable */
   {                               /* anfÅgen */
   while (*d)
         while (*d++)
               ;
   e = entry;
   while ((*d++ = *e++) != 0)
         ;
   *d = 0;
   }

_BasPag->p_env = envbeg;           /* eigenen Zeiger setzen */

return 1;
}

