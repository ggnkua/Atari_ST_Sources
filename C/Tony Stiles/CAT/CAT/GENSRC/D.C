#ifndef PC
#ifndef ST
#define ST 1
#endif
#endif

#include "xlang.h"

#include <string.h>

#include "xdef.h"

#define SHELL3 TRUE

#include "xglobals.h"
#include "xfuncs.h"

#include "portab.i"

void pause(s)
int s;
{
   unsigned long start, end;

   start= get_secs();
   do
   {
      end= get_secs();
      if (end<start)
         end+= 86400L;
   } while (((int)(end-start))<s);
}

BOOLEAN yesno()
{
   char c;

   crson();
   do
   {
      c= getachar();
   } while ((strchr(msg[M_YES_CHARS],c)==NULL) &&
                                       (strchr(msg[M_NO_CHARS],c)==NULL));

   crsoff();
   if (strchr(msg[M_YES_CHARS],c))
   {
      PMSG(M_YES);
      newline(FALSE);
      return(TRUE);
   }
   else
   {
      PMSG(M_NO);
      return(FALSE);
   }
}

int firstob(r)
int r;
{
   int i=0;

   while ((OBJRM(i) != -1) && (OBJRM(i)!=r))
      ++i;

   if (OBJRM(i) == -1)
      return -1;
   else
      return i;
}

int lastob(r)
int r;
{
   int i=0, last=-1;

   while (OBJRM(i) != -1)
   {
      if (OBJRM(i)==r)
         last= i;
      ++i;
   }
   return(last);
}

BOOLEAN isdark(r, init) /* very recursive */
int r;
BOOLEAN init;
{
   register i=0;
   BOOLEAN dark= TRUE;
   
   if ((rmd[r][0]==LIGHT) && (init))
      return FALSE;
      
   while ((odet[i][2] != -1) && (dark))
   {
      if (odet[i][2]==r)
      {
         if ISLIT(i)
            dark= FALSE;
         if ((dark) && (odet[i][3]!=R_NOWHERE) && 
         			((!ISCLOSED(i))&&(!ISLOCKED(i))))
            dark= isdark(odet[i][3],FALSE);
      }
      ++i;
   }
   return dark;
}

int verbpath(v)
int v;
{
   int i=0;
   
   while (rmp[i][0] != -1)
   {
      if ((rmp[i][0]==THISROOM) && (rmp[i][1]==v))
         return rmp[i][2];
      ++i;
   }
   return -1;
}

void upd_doors()
{
   register i=0;
   static int lroom= -1;

   if (THISROOM != lroom)
   {   
      while (odet[i][2] != -1)
      {
         if ((odet[i][14]==odet[player][2]) || (odet[i][15]==odet[player][2]))
            TOROOM(odet[player][2],i);
         ++i;
      }
      lroom= THISROOM;
   }
}

void pcontents(o)
int o;
{
   int i, sr;
   int last, slast;
   BOOLEAN first= TRUE;
   
   PMSG(M_IT_CONTAINS);
   sr= OBJRM(PLAYER_);
   odet[player][2]=OBJINRM(o);

   i=0;
   last= -1;
   slast= -1;
   while (odet[i][2] != -1)
   {
      if ( (ISHERE(i)) && (!ISHIDDEN(i)) )
      {
         slast= last;
         last= i;
      }
      ++i;
   }
   
   i=0; 
   while (odet[i][2] != -1)
   {
      if ( (ISHERE(i)) && (!ISHIDDEN(i)) )
      {
         first= FALSE;
         if (i==last)
            endchar('.');
         else if (i!=slast)
            endchar(',');
         POBJS(i);
         if (i==slast)
            PMSG(M_AND);
      }
      ++i;
   }
   if (first)
      PMSG(M_NOTHING);
   odet[player][2]=sr;      
}

void look(mode)
int mode;
{
   int i, r;
   int last;
   int slast;
   BOOLEAN first= TRUE;
   
      upd_doors();
   
      r= odet[player][2];

      if ISDARK
      {
         PMSG(M_IT_IS_DARK);
         return;
      }
   
      if ((rmd[r][1]==NOT_VISITED) || (verbose) || (mode==LONG))
         PROOML(r);
      else
         PROOMS(r);
      
      rmd[r][1]= VISITED;
   
      if (rmd[r][2] != NO_SCORE)
      {
         ADDCOUNT(497,rmd[r][2]);
         rmd[r][2]=0;
      }

      i=0;
      last= -1;
      slast= -1;
      while (odet[i][2] != -1)
      {
         if ( (ISHERE(i)) && (!ISHIDDEN(i)) )
         {
            slast= last;
            last= i;
         }
         ++i;
      }
   
      i=0; 
      while (odet[i][2] != -1)
      {
         if ( (ISHERE(i)) && (!ISHIDDEN(i)) )
         {
            if (first)
            {
               first= FALSE;
               PMSG(M_YOU_CAN_SEE);
            }
            if (i==last)
               endchar('.');
            else if (i!=slast)
               endchar(',');
            POBJS(i);
            if (i==slast)
               PMSG(M_AND);
         }
         ++i;
      }
}

void enter(o)
int o;
{
   int i;
   
   for (i=14; i<17; i++)
   {
      if ((odet[o][i]!=R_NOWHERE) && (odet[o][i]!=odet[player][2]))
      {
         TOROOM(odet[o][i],player);
         break;
      }
   }
}

void inventory()
{
   int i, last, slast;
   BOOLEAN first;
   
   /* Objects carried */
   
   first= TRUE;
   i=0;
   last= -1;
   slast= -1;
   while (odet[i][2] != -1)
   {
      if ((ISCARRIED(i)) && (!ISWORN(i)) && (!ISHIDDEN(i)))
      {
         slast= last;
         last= i;
      }
      ++i;
   }
   
   i=0;
   while ((odet[i][2] != -1))
   {
      if ((ISCARRIED(i)) && (!ISWORN(i)) && (!ISHIDDEN(i)))
      {
         if (first)
         {
            first = FALSE;
            PMSG(M_YOU_ARE_CARRYING);
         }
         if (i==last)
            endchar('.');
         else if (i!=slast)
            endchar(',');
         POBJS(i);
         if (i==slast)
            PMSG(M_AND);
      }
      ++i;
   }
   if (first)
      PMSG(M_EMPTY_HANDS);
      
   /* Objects worn */
   
   first= TRUE;
   i=0;
   last= -1;
   slast= -1;
   while (odet[i][2] != -1)
   {
      if ((ISCARRIED(i)) & (ISWORN(i)) && (!ISHIDDEN(i)))
      {
         slast= last;
         last= i;
      }
      ++i;
   }
   
   i=0;
   while (odet[i][2] != -1)
   {
      if ((ISCARRIED(i)) && (ISWORN(i)) && (!ISHIDDEN(i)))
      {
         if (first)
         {
            first= FALSE;
            PMSG(M_YOU_ARE_WEARING);
         }
         if (i==last)
            endchar('.');
         else if (i!=slast)
            endchar(',');
         POBJS(i);
         if (i==slast)
            PMSG(M_AND);
      }
      ++i;
   }
}

void pexits()
{
   int r, w, i;
   int last;
   BOOLEAN first= TRUE;
   
   r= odet[player][2];
   
   i=0;
   last= -1;
   while (rmp[i][0] != -1)
   {
      if (rmp[i][0]==r)
         last=i;
      ++i;
   }
   
   i=0;
   while (rmp[i][0] != -1)
   {
      if (rmp[i][0]==r)
      {
         if (first)
         {
            first= FALSE;
            PMSG(M_OBVIOUS_EXITS);
         }
         if (i==last)
            ENDCHAR('.');
         else
            ENDCHAR(',');
         w=0;
         while (rmp[i][1]!=vsynn[w])
            ++w;
         prt_text(vsynt[w]);
      }
      ++i;
   }
   if (first)
      PMSG(M_NO_OBVIOUS_EXITS);
}

void vocab()
{
   int i=0;
   char wrk[80];
   char *p;
   
   while (vsynn[i] != -1)
   {
      if (vsynn[i+1] == -1)
         endchar('.');
      else
         endchar(',');
      strcpy(wrk,vsynt[i]);
      p= strchr(wrk, '_');
      if (p) *p=' ';
      prt_text(wrk);
      ++i;
   }
}

void swap(x,y)
int x,y;
{
   int r;
   
   r= OBJRM(x);
   TOROOM(OBJRM(y),x);
   TOROOM(r,y);
}

int catrand(x)
int x;
{
   static unsigned long _rseed = -1;
   if (_rseed == -1)
      _rseed= get_secs();
   _rseed = (_rseed * 1103515245L) + 12345;
   return(((unsigned int) ((_rseed / 65536L) % 32768L))%x+1);
}
