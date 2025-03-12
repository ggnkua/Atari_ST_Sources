/* $Id: getarg.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *getarg_id = "$Id: getarg.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#if defined(__STDC__)
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "proto.h"
#include "getargs.h"

/*
  Usage is like :

     argc = getargs(argc,argv,
                    "r", "%d", &rate,               Integer
                    "u", "",   &ufile_name,         String
                    "g", "%d", &gain,               Double
                    "a", NULL, &use_audio,          Boolean -a toggles, +a sets
                    "s", ""  , &speaker,            Booelan -s clears, +s sets
                    NULL);

*/


#if defined(__STDC__)
int
getargs(int argc, char *argv[],...)
#else
int
getargs(argc, argv, va_alist)
int argc;
char *argv[];
va_dcl
#endif
{
 va_list ap;
 int i = 0;
 while (i < argc)
  {
   char *s = argv[i];
   int flag = *s++;
   if (flag == '-' || flag == '+')
    {
     int off = 1;
     while (*s)
      {
       char *a;
       int count = 0;
#if defined(__STDC__)
       va_start(ap, argv);
#else
       va_start(ap);
#endif
       while ((a = va_arg(ap, char *)))
        {
         int l = strlen(a);
         char *fmt = va_arg(ap, char *);
         void *var = va_arg(ap, void *);
         if (l > 1)
          {
           if (!count && !strcmp(s, a))
            {
             if (fmt)
              {
               if (i + off < argc)
                {
                 char *x = argv[i + off++];
                 if (strchr(fmt, '%'))
                  {
                   if (sscanf(x, fmt, var) != 1)
                    fprintf(stderr, "%s : %s invalid after -%s\n", argv[0], x, a);
                  }
                 else
                  *((char **) var) = x;
                }
               else
                fprintf(stderr, "%s : no argument after -%s\n", argv[0], a);
              }
             else
              {
               if (flag == '+')
                *((int *) var) = !0;
               else
                *((int *) var) = !*((int *) var);
              }
             /* skip to end of string */
             count++;
             s += l;
             break;       /* out of va_arg loop */
            }
          }
         else
          {
           if (*s == *a)
            {
             if (fmt)
              {
               if (i + off < argc)
                {
                 char *x = argv[i + off++];
                 if (strchr(fmt, '%'))
                  {
                   if (sscanf(x, fmt, var) != 1)
                    fprintf(stderr, "%s : %s invalid after -%s\n", argv[0], x, a);
                  }
                 else
                  *((char **) var) = x;
                }
               else
                fprintf(stderr, "%s : no argument after -%s\n", argv[0], a);
              }
             else
              {
               if (fmt || flag == '+')
                *((int *) var) = (flag == '+');
               else
                *((int *) var) = !*((int *) var);
              }
             count++;
             s++;
             break;       /* out of va_arg loop */
            }
          }
        }
       va_end(ap);
       if (!count)
        {
         off = 0;
         break;           /* Out of s loop */
        }
      }
     if (off != 0)
      {
       int j;
       argc -= off;
       for (j = i; j <= argc; j++)
        argv[j] = argv[j + off];
      }
     else
      i++;
    }
   else
    i++;
  }
 return argc;
}
