/*  ARC - Archive utility - ARCMATCH

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains service routines needed to maintain an archive.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

int match(n,t)                         /* test name against template */
char *n;                               /* name to test */
char *t;                               /* template to test against */
{
    upper(n); upper(t);                /* avoid case problems */

    /* first match name part */

    while((*n && *n!='.') || (*t && *t!='.'))
    {    if(*n!=*t && *t!='?')         /* match fail? */
         {    if(*t!='*')              /* wildcard fail? */
                   return 0;           /* then no match */
              else                     /* else jump over wildcard */
              {    while(*n && *n!='.')
                        n++;
                   while(*t && *t!='.')
                        t++;
                   break;              /* name part matches wildcard */
              }
         }
         else                          /* match good for this char */
         {    n++;                     /* advance to next char */
              t++;
         }
    }

    if(*n && *n=='.') n++;             /* skip extension delimiters */
    if(*t && *t=='.') t++;

    /* now match name part */

    while(*n || *t)
    {    if(*n!=*t && *t!='?')         /* match fail? */
         {    if(*t!='*')              /* wildcard fail? */
                   return 0;           /* then no match */
              else return 1;           /* else good enough */
         }
         else                          /* match good for this char */
         {    n++;                     /* advance to next char */
              t++;
         }
    }

    return 1;                          /* match worked */
}

rempath(nargs,arg)                     /* remove paths from filenames */
int nargs;                             /* number of names */
char *arg[];                           /* pointers to names */
{
    char *i, *rindex();                /* string index, reverse indexer */
    int n;                             /* index */

    for(n=0; n<nargs; n++)             /* for each supplied name */
    {    if(!(i=rindex(arg[n],'\\')))  /* search for end of path */
              if(!(i=rindex(arg[n],'/')))
                   i=rindex(arg[n],':');
         if(i)                         /* if path was found */
              arg[n] = i+1;            /* then skip it */
    }
}
