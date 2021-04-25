#ifndef PC
#ifndef ST
#define ST 1
#endif
#endif

extern char *malloc();

#define CTRL(x) (x-64)

#include "xlang.h"

#include <string.h>
#include <ctype.h>

#include "xdef.h"

#define SHELL1 TRUE

#include "xglobals.h"
#include "xfuncs.h"

static char fil[13];
static char qt[31];
static char bv[80]="";
static char bn[80]="";
static char bpv[80]="";
static char bpn[80]="";
static char *rsb;
static BOOLEAN rss=FALSE;
static BOOLEAN except= FALSE;

#include "portab.i"

void upper(s)
char *s;
{
   while (*s)
   {
      if (islower(*s))
         *s=toupper(*s);
      s++;
   }
}

void lower(s)
char *s;
{
   while (*s)
   {
      if (isupper(*s))
         *s=tolower(*s);
      s++;
   }
}

void get_input(buf,l,s)
char *buf;
int l;
BOOLEAN s;
{
   int match;
   int c;
   int i, len=0;
   static char alllow[37]="abcdefghijklmnopqrstuvwxyz1234567890";
   static char allhi[27]= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   static char wbuf[81]="";
   static char obuf[81]="";
   char *bp;
   
   bp= wbuf;
   *bp= '\0';
   
   crson();
   usc= 0;

   for (i=0; i<l; i++)
      buf[i]='\0';
   do
   {
      do
      {
         do
         {
            match= FALSE;
            if (*bp)
            {
               c= *bp;
               ++bp;
            }
            else
               c= getachar();
            len= strlen(buf);
            switch (c)
            {
               case '[':
                  strcpy(wbuf,obuf);
                  bp= wbuf;
                  break;
               case ']':
                  for (i=0; i<len; i++)
                     wbuf[i]=8;
                  wbuf[i]='\0';
                  bp= wbuf;
                  break;
               case '*':
                  i= len-1;
                  wbuf[0]='\0';
                  while ((i>=0) && (strchr(sep,buf[i])!=NULL))
                  {
                     --i;
                     strcat(wbuf,"\b");
                  }
                  while ((i>=0) && (strchr(sep,buf[i])==NULL))
                  {
                     --i;
                     strcat(wbuf,"\b");
                  }
                  bp= wbuf;
                  break;
               case CTRL('A'):
                  strcpy(wbuf,bv);
                  bp= wbuf;
                  break;
               case CTRL('B'):
                  strcpy(wbuf,bn);
                  bp= wbuf;
                  break;
               case CTRL('C'):
                  strcpy(wbuf,bpv);
                 bp= wbuf;
                  break;
               case CTRL('D'):
                  strcpy(wbuf,bpn);
                  bp= wbuf;
                  break;
               case CTRL('E'):
                  strcpy(wbuf,"Examine ");
                  bp= wbuf;
                  break;
               case CTRL('F'):
                  strcpy(wbuf,"Drop ");
                  bp= wbuf;
                  break;
               case CTRL('G'):
                  strcpy(wbuf,"Get ");
                  bp= wbuf;
                  break;
               case CTRL('I'):
                  sprintf(wbuf,"Inventory%c",13);
                  bp= wbuf;
                  break;
               case CTRL('J'):
                  strcpy(wbuf,"Jump ");
                  bp= wbuf;
                  break;
               case CTRL('K'):
                  strcpy(wbuf,"Kill ");
                  bp= wbuf;
                  break;
               case CTRL('L'):
                  sprintf(wbuf,"Look%c",13);
                  bp= wbuf;
                  break;
               case CTRL('N'):
                  strcpy(wbuf,"No ");
                  bp= wbuf;
                  break;
               case CTRL('O'):
                  strcpy(wbuf,"Open ");
                  bp= wbuf;
                  break;
               case CTRL('P'):
                  strcpy(wbuf,"Close ");
                  bp= wbuf;
                  break;
               case CTRL('Q'):
                  sprintf(wbuf,"Quit%c",13);
                  bp= wbuf;
                  break;
               case CTRL('R'):
                  sprintf(wbuf,"Restore%c",13);
                  bp= wbuf;
                  break;
               case CTRL('S'):
                  sprintf(wbuf,"Save%c",13);
                  bp= wbuf;
                  break;
               case CTRL('T'):
                  strcpy(wbuf,"Lock ");
                  bp= wbuf;
                  break;
               case CTRL('U'):
                  strcpy(wbuf,"Unlock ");
                  bp= wbuf;
                  break;
               case CTRL('V'):
                  sprintf(wbuf,"Vocabulary%c",13);
                  bp= wbuf;
                  break;
               case CTRL('W'):
                  sprintf(wbuf,"Whoami%c",13);
                  bp= wbuf;
                  break;
               case CTRL('X'):
                  sprintf(wbuf,"Exits%c",13);
                  bp= wbuf;
                  break;
               case CTRL('Y'):
                  strcpy(wbuf,"Yes ");
                  bp= wbuf;
                  break;
               case CTRL('Z'):
                  strcpy(wbuf,"Created with CAT, Copyright Tony Stiles.");
                  bp= wbuf;
                  break;
               case '8':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"North%c",13);
                     bp= wbuf;
                     break;
                  }
               case '9':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"NorthEast%c",13);
                     bp= wbuf;
                     break;
                  }
               case '6':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"East%c",13);
                     bp= wbuf;
                     break;
                  }
               case '3':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"SouthEast%c",13);
                     bp= wbuf;
                     break;
                  }
               case '2':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"South%c",13);
                     bp= wbuf;
                     break;
                  }
               case '1':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"SouthWest%c",13);
                     bp= wbuf;
                     break;
                  }
               case '4':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"West%c",13);
                     bp= wbuf;
                     break;
                  }
               case '7':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"NorthWest%c",13);
                     bp= wbuf;
                     break;
                  }
               case '5':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"Up%c",13);
                     bp= wbuf;
                     break;
                  }
               case '0':
                  if ((len==0) || (strchr(sep,buf[len-1])!=NULL))
                  {
                     sprintf(wbuf,"Down%c",13);
                     bp= wbuf;
                     break;
                  }
               default:
                  match= ((c==8) || (c==13) ||
                          (strchr(alllow, c) != NULL) ||
                          (strchr(allhi, c) != NULL) ||
                         ((strchr(sep,c) != NULL)&&(s)) );
                  if (!match)
                     putchar(7);
            }
         } while (!match);
         len=strlen(buf);
         if (c==8)
         {
            if (len==0)
               putchar(7);
            else
            {
               buf[len-1]='\0';
               putchar(8);
               putchar(32);
               putchar(8);
               --x;
            }
         }
         else
         {
            if (c==13)
            {
               if (len==0)
                  putchar(7);
            }
            else
            {
               if ((x==width()) || (len==l))
                  putchar(7);
               else
               {
                  buf[len+1]='\0';
                  buf[len]=c;
                  putchar(c);
                  ++x;
               }
            }
         }
      } while (c!=13);
      len= strlen(buf);
   } while (len==0);
     
   crsoff();
   strcpy(obuf,buf); 
}

int calc_weight(o) /* very recursive */
int o;
{
   register weight=0;
   register i=0;
   
   while (odet[i][2] != -1)
   {
      if ((odet[i][2]==odet[o][3]) && (ISMOVABLE(i)))
      {
         weight+= odet[i][0];
         if (odet[i][3]!=R_NOWHERE)
            weight+= calc_weight(i);
      }
      ++i;
   }
   return weight;
}

void calcw()
{
   register i=0;
   
   if (wgt_c)
   {
      wgt_c= FALSE;
      while (odet[i][2] != -1)
      {
         if (odet[i][3]!=R_NOWHERE)
            odet[i][13]= calc_weight(i);
         else
            odet[i][13]= 0;
         ++i;
      }
   }
}
      
BOOLEAN isprepv(s)
char *s;
{
   int i=0;
   while (strlen(vprep[i]))
   {
      if (strcmp(vprep[i],s)==0)
         return TRUE;
      ++i; 
   }
   return FALSE;
}

BOOLEAN isqual(s)
char *s;
{
   int i=0;
   while (strlen(oqual[i]))
   {
      if (strcmp(oqual[i],s)==0)
         return TRUE;
      ++i; 
   }
   return FALSE;
}

BOOLEAN isqualo(s)
char *s;
{
   int i=0;
   while (strlen(oqualo[i]))
   {
      if (strcmp(oqualo[i],s)==0)
         return TRUE;
      ++i; 
   }
   return FALSE;
}

BOOLEAN qualified(s,echo,dobox,po,pv)
char *s;
BOOLEAN echo,dobox;
char *po, *pv;
{
   char wrk[80];
   char wrk3[80];
   char wrk4[80];
   char *wp;
   int i=0, c=0, ct=0;
   BOOLEAN got_any= FALSE;
   BOOLEAN got_nowhere= FALSE;
   int oldroom;
   int first= -1;
   
   if ((dobox) && (verb_no(pv)==V_FROM) && (noun_no(po) != -1) 
                                        && (ISBOX(noun_no(po))))
   {
      oldroom= THISROOM;
      odet[player][2]=OBJINRM(noun_no(po));
   }
   else
      dobox= FALSE;
      
   while (strlen(osynt[i]))
   {
      wp= strchr(osynt[i],'_');
      if ( (wp!=NULL) && (strcmp((wp+1),s)==0) )
      {
      	 if (ISAVAIL(osynn[i]))
      	 {
            ++c;
            if (c==1)
               strcpy(wrk, osynt[i]);
            if (!ISHIDDEN(osynn[i]))
            {
               ++ct;
               if (ct==2)
               {
                  if (echo)
                  {
                     PMSG(M_YOU_CAN_SEE);
                     ENDCHAR(',');
                     POBJS(first);
                  }
               }
               if (ct>1)
               {
                  if (echo)
                  {
                     ENDCHAR(',');
                     POBJS(osynn[i]);
                  }
               }
               else
                  first= osynn[i];
            }
         }
         else
         {
            if ( (!got_any) && (OBJRM(osynn[i])!=R_NOWHERE) )
            {
               strcpy(wrk3, osynt[i]);
               got_any= TRUE;
            }
            if ( (!got_nowhere) && (OBJRM(osynn[i])==R_NOWHERE) )
            {
               strcpy(wrk4, osynt[i]);
               got_nowhere= TRUE;
            }
         }
      }
      ++i;
   }
   
   if (dobox)
      odet[player][2]=oldroom;
      
   if (c==1)
   {
      strcpy(s, wrk);
      return TRUE;
   }
   else
      if ((c==0) && (got_any))
      { 
         strcpy(s, wrk3);
         return TRUE;
      }
      else
         if ((c==0) && (got_nowhere))
         { 
            strcpy(s, wrk4);
            return TRUE;
         }
         else if (echo)
         {
            /* Okay we'll give them one last chance to qualify! */
            
            PMSG(M_WHICH_ONE);
            NEWLINE;
            get_input(qt,80,FALSE);
            if (script)
               prn_out(qt);
            upper(qt);
            NEWLINE;
            i=0;
            while (strlen(oqual[i])!=0)
            {
               if ( (strcmp(qt,oqual[i])==0) && (strcmp(s,oqualo[i])==0) )
               {
                  strcpy(s,oqual[i]);
                  strcat(s,"_");
                  strcat(s,oqualo[i]);
                  return TRUE;
               }
               ++i;
            }
            return FALSE;
         }
         else
            return FALSE;
}

int verb_no(v)
char *v;
{
   int i=0;
   
   while ((vsynn[i] != -1) && (strcmp(vsynt[i],v)!=0))
      ++i;
      
   return vsynn[i];
}

int noun_no(n)
char *n;
{
   int i=0;
   
   while ((osynn[i] != -1) && (strcmp(osynt[i],n)!=0))
      ++i;
      
   return osynn[i];
}

void clr_nouns()
{
   noun_t[0]= '\0';
   except= FALSE;
}

void add_noun(v,n)
char *v, *n;
{
   int i, j, x, vn;
   int oplr;
   BOOLEAN ok;
   char wrk[80];
   char *p;
   
   vn= verb_no(v);

   oplr= player;
   if (strlen(actor))
      player= noun_no(actor);
     
   if (noun_no(n) == O_EXCEPT)
   {
      except= TRUE;
      return;
   }
   
   if (noun_no(n) == O_ALL)
   {
      if (ISDARK)
      {
      	 prt_text("...");
         PMSG(M_TOO_DARK);
      }
      else
      { 
         if (except)
         {
            strcpy(noun_t,"");
            return;
         }
         i=0;
         while (odet[i][0] != -1)
         {
      	 if (!ISHIDDEN(i))
         {
      	    ok= FALSE;
            if ((vchk[vn][0]==VC_HERE) && (ISHERE(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_CARRIED_NOT_WORN) && (ISCARRIED(i))
                                                  && (!ISWORN(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_WORN) && (ISWORN(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_AVAIL) && (ISAVAIL(i))) 
               ok= TRUE;
            if ((vchk[vn][0]==VC_CARRIED) && (ISCARRIED(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_AVAIL_NOT_WORN) && (ISAVAIL(i))
                                                && (!ISWORN(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_NOT_CARRIED) && (ISAVAIL(i))
                                                && (!ISCARRIED(i)))
               ok= TRUE;
            if ((vchk[vn][0]==VC_EXIST) && (ISAVAIL(i)))
               ok= TRUE;
            if (ok)
            {
               j=0;
               while (osynn[j]!=i)
                  ++j;
               strcat(noun_t, osynt[j]);
               strcat(noun_t, " ");
            }
         }
         ++i;
      }
      }
   }
   else if (noun_no(n) == O_THEM)
      strcat(noun_t, noun_o);
   else
   {
      wrk[0]='\0';
      if ( (strlen(qual)) && (isqualo(n)) )
      {
         strcpy(wrk,qual);
         qual[0]='\0';
      }
      strcat(wrk, n);
      if (except)
      {
         p=strstr(noun_t,wrk);
         if (p)
         {
            if (*(p-1)=='_')
               while ((*p!=' ') && (p!=&noun_t[0]))
               {
                 --p;
                 strcat(wrk," ");
               }
            for (x=0; x<strlen(wrk); x++)
               *p++= ' ';
         }
      }
      else
      {
         strcat(wrk, " ");
         strcat(noun_t,wrk);
      }
   }
   player= oplr;
}

void get_cmd(more, got_cmd)
BOOLEAN *more, *got_cmd;
{
   int noun, verb, i, k;
   char wrk[80];
   char *wnoun;
   char *a;
   
   verb= -1;
   prepv[0]= '\0';
   prepo[0]= '\0';
   quala[0]= '\0';
   qual[0]=  '\0';

   /* Replace any two part verbs (i.e. 'PUT ON' with 'PUT_ON') */
   
   i=0;
   while (vsynn[i] != -1)
   {
      a= strchr(vsynt[i],'_');
      if (a)
      {
         strcpy(wrk, vsynt[i]);
         strcat(wrk, " ");
         a= strchr(wrk,'_');
         *a= ' ';
         a= strstr(sptr, wrk);
         while (a)
         {
            strncpy(a,vsynt[i],strlen(vsynt[i]));
            a= strstr(sptr, wrk);
         }
      }
      ++i;
   }
   
   if (!(*more))
      actor[0]='\0';
      
   /* First, strip a verb from the command line */
   /* We'll look for an actor as well! - i.e. a noun before a verb! */
   
   while ((sptr!=NULL) && (verb == -1))
   {
      sptr= strtok(sptr, sep);
      if (sptr != NULL)
      {
      	 if (isqual(sptr))
      	    sprintf(quala, "%s_", sptr);
      	 else
      	 {
      	    /* Only allow change of actor at start of line */
      	    if ( (noun_no(sptr) != -1) && (!(*more)))
      	    {
      	       if (isqualo(sptr))
      	       {
                  actor[0]= '\0';
      	          sprintf(actor, "%s%s", quala, sptr);
      	          if (noun_no(sptr) == -1)
      	             strcpy(actor, sptr);
      	       }
      	       else
      	          strcpy(actor, sptr);
      	    }
      	    else
      	    {
               verb= verb_no(sptr);
               if (verb != -1)
                  strcpy(verb_t, sptr);
            }
         }
         sptr+= strlen(sptr)+1;
      }
   }
   
   *got_cmd= (verb != -1);
   
   /* Now, get all the nouns relating to this command (if any) */
   
   if (got_cmd)
   {
      clr_nouns();
      
      /* Keep reading till we hit EOL, or another verb */
      while ((sptr!=NULL) && ((verb_no(sptr) == -1)||(isprepv(sptr))))
      {
         sptr= strtok(sptr, sep);
         if ((sptr!=NULL) && ( (verb_no(sptr) == -1 ) || (isprepv(sptr)) ))
         {
            if (isqual(sptr))
               sprintf(qual, "%s_", sptr);
            else
            {
               if (isprepv(sptr))
                  strcpy(prepv, sptr);
               else
               {
               	  wnoun= sptr;
                  noun= noun_no(wnoun);
                  if (noun==O_ME)
                  {
                     noun=cplr;
                     k=0;
                     while (osynn[k]!=cplr)
                        ++k;
                     wnoun= osynt[k];
                  }
                  if (noun != -1)
                  {
                     if (strlen(prepv))
                     {
                        if ( (noun != O_THEM) && (noun != O_ALL) )
                        {
                           if ( (strlen(qual)) && (isqualo(wnoun)) )
                           {
                              strcpy(prepo, qual);
                              strcat(prepo, wnoun);
                           }
                           else
                              strcpy(prepo, wnoun);
                        }
                     }
                     else
                        add_noun(verb_t, wnoun);
                  }
               }
            }
            sptr+= strlen(sptr)+1;
         }
      }
      
      /* Save this noun list for reference by O_THEM (i.e GET THEM)..
         but only if this verb requires nouns */
         
      if (vchk[verb][0] != VC_NO_CHECK)
         strcpy(noun_o, noun_t);
   }
   
   /* Any more verbs waiting? */
   *more= (sptr != NULL);
   if (*more)
      sptr[strlen(sptr)]=' ';
}

/* Can we walk along any paths? */

BOOLEAN ispath(vn)
int vn;
{
   if ((vn!=V_NORTH) && (vn!=V_SOUTH) && (vn!=V_EAST) && (vn!=V_WEST) &&
       (vn!=V_NORTHEAST) && (vn!=V_SOUTHEAST) && (vn!=V_SOUTHWEST) &&
       (vn!=V_NORTHWEST) && (vn!=V_UP) && (vn!=V_DOWN) && (vn!=V_LEAVE))
      return FALSE;
   else
      return TRUE;
}

BOOLEAN paths(vn)
int vn;
{
   int i, j;
   
   if (!ispath(vn))
      return(TRUE);
      
   i=0;
   while (rmp[i][0] != -1)
   {
      if ((rmp[i][0]==THISROOM) && (rmp[i][1]==vn))
      {
         if (rmp[i][2]==CARRIED)
         {
            j=0;
            while (THISROOM != OBJINRM(j))
               ++j;
            GOTO(OBJRM(j));
            return TRUE;
         }
         else
         {
            GOTO(rmp[i][2]);
            return TRUE;
         }
      }
      ++i;
   }
   PMSG(M_NO_PATH);
   return(FALSE);
}

/* Check out the syntax of the verb / noun expression */

BOOLEAN check(chk,lgt,nn,nt)
int chk;
int lgt;
int nn;
char *nt;
{
   char w[80], *p;
   
   p= strchr(nt, '_');
   if (p) *p=' ';
   if ((isupper(nt[0])) && (isupper(nt[1])) && (nt[2]==' '))
      strcpy(w,(nt)+3);
   else
      strcpy(w,nt);
   if (p) *p= '_';
       
   if (lgt==NEED_LIGHT && ISDARK)
   {
      PMSG(M_TOO_DARK);
      return(FALSE);
   }

   if (chk==VC_NO_CHECK)
      return(TRUE);

   if ((chk==VC_EXIST) || ((chk!=VC_NO_CHECK)&&(nn == -1)))
   {
      if (nn == -1)
      {
         endchar(':');
         prt_text(w);
         PMSG(M_NOUN_NOT_FOUND);
         return FALSE;
      }
      else
         return TRUE;
   }
   
   if ((chk==VC_HERE) && (!ISHERE(nn)))
   {
      endchar(':');
      prt_text(w);
      if ISWORN(nn)
         PMSG(M_OBJECT_WORN);
      else if ISCARRIED(nn)
         PMSG(M_OBJECT_CARRIED);
      else
         PMSG(M_OBJECT_NOT_HERE);
      return FALSE;
   }
   
   if ((chk==VC_CARRIED_NOT_WORN) && ((!ISCARRIED(nn)) || ISWORN(nn)))
   {
      endchar(':');
      prt_text(w);
      if ISWORN(nn)
         PMSG(M_OBJECT_WORN);
      else
         PMSG(M_OBJECT_NOT_GOT);
      return FALSE;
   }
   
   if ((chk==VC_WORN) && (!ISWORN(nn)))
   {
      endchar(':');
      prt_text(w);
      PMSG(M_OBJECT_NOT_WORN);
      return FALSE;
   }
   
   if ((chk==VC_AVAIL) && (!ISAVAIL(nn)))
   {
      endchar(':');
      prt_text(w);
      PMSG(M_OBJECT_NOT_HERE);
      return FALSE;
   }
   
   if ((chk==VC_AVAIL_NOT_WORN) && ((!ISAVAIL(nn)) || ISWORN(nn)))
   {
      endchar(':');
      prt_text(w);
      if ISWORN(nn)
         PMSG(M_OBJECT_WORN);
      else
         PMSG(M_OBJECT_NOT_HERE);
      return FALSE;
   }
   
   if ((chk==VC_CARRIED) && (!ISCARRIED(nn)))
   {
      endchar(':');
      prt_text(w);
      PMSG(M_OBJECT_NOT_GOT);
      return FALSE;
   }
   
   if ((chk==VC_NOT_CARRIED) && (ISCARRIED(nn)))
   {
      endchar(':');
      prt_text(w);
      PMSG(M_OBJECT_CARRIED);
      return FALSE;
   }
   
   return TRUE;
}

BOOLEAN prc_cmd()
{
   char wrk[1000];
   char tmp[80];
   char *w, *p;
   BOOLEAN go_on= TRUE;
   BOOLEAN done;
   int k;
   
   cplr= player;
   w= wrk;
   strcpy(w, noun_t);
   w= strtok(w, " ");
   do
   {
      tmp[0]= '\0';
      if (w)
      {
         strcpy(tmp, w);
         w+= strlen(w)+1;
         w= strtok(w, " ");
      }
      
      if ((verb_no(verb_t)==V_ENTER) && (noun_no(tmp) == -1))
      {
         k=0;
         done= FALSE;
         while ((osynn[k] != -1) && (!done))
         {
            if ((ISHERE(osynn[k])) && (ISEXIT(osynn[k])))
            {
               done= TRUE;
               strcpy(tmp, osynt[k]);
            }
            ++k;
         }
      }
            
      newline(FALSE);
      prt_text("[");
      if (strlen(actor))
      {
         player= noun_no(actor);   
         p= strchr(actor, '_');
         if (p) *p=' ';
         endchar(',');
         prt_text(actor);
         if (p) *p='_';
      }

      if (isqualo(prepo)) (void)(qualified(prepo,FALSE,FALSE,"",""));
      if (isqualo(tmp)) (void)(qualified(tmp,FALSE,TRUE,prepo,prepv));
      
      if (strlen(actor))
         player= cplr;
         
      strcpy(vp, verb_t);
      strcpy(np, tmp);

      p= strchr(np, '_');
      if (p)
         *p= ' ';

      bv[0]='\0';
      bn[0]='\0';
      bpv[0]='\0';
      bpn[0]='\0';
            
      p= strchr(vp, '_');
      if (p) *p=' ';
      prt_text(vp);
      strcpy(bv,vp);
      if (p) *p='_';
      
      if (strlen(np))
         if ((isupper(np[0])) && (isupper(np[1])) && (np[2]==' '))
         {
            prt_text((np)+3);
            strcpy(bn,np+3);
         }
         else  
         {
            prt_text(np);
            strcpy(bn,np);
         }
            
      if (strlen(prepo))
      {
         p= strchr(prepv, '_');
         if (p) *p=' ';
         prt_text(prepv);
         strcpy(bpv,prepv);
         if (p) *p='_';

         p= strchr(prepo, '_');
         if (p) *p=' ';
         if ((isupper(prepo[0])) && (isupper(prepo[1])) && (prepo[2]==' '))
         {
            prt_text((prepo)+3);
            strcpy(bpn,prepo+3);
         }
         else  
         {
            prt_text(prepo);
            strcpy(bpn,prepo);
         }
         if (p) *p='_';
      }
      else
         prepv[0]='\0';
      prt_text("]");

      lower(bv); bv[0]=toupper(bv[0]); if (strlen(bv)) strcat(bv," ");
      lower(bn); bn[0]=toupper(bn[0]); if (strlen(bn)) strcat(bn," ");
      lower(bpv); bpv[0]=toupper(bpv[0]); if (strlen(bpv)) strcat(bpv," ");
      lower(bpn); bpn[0]=toupper(bpn[0]); if (strlen(bpn)) strcat(bpn," ");
      
      if ((strlen(actor)) && (((!ISAVAIL(noun_no(actor)))||(!ISCOMMANDABLE(noun_no(actor))))
                               && (noun_no(actor)!=player)))
         PMSG(M_DEAF_EARS);
      else 
      {
         if (strlen(actor))
            player=noun_no(actor);
         
         if ( ((isqualo(prepo))   && (!qualified(prepo,TRUE,FALSE,"",""))) ||
              ((isqualo(tmp)) && (!qualified(tmp,TRUE,TRUE,prepo,prepv))) )
            PMSG(M_BE_MORE_SPECIFIC);
         else
         {
            go_on=check(vchk[verb_no(verb_t)][0],
                        vchk[verb_no(verb_t)][1], noun_no(tmp), tmp);
            if (!go_on)
               go_on= TRUE;
            else
            {
               if (strlen(prepv))
                  go_on= check(vchk[verb_no(prepv)][0], 
                  	       vchk[verb_no(prepv)][1], noun_no(prepo), prepo);
               if (!go_on)
                  go_on= TRUE;
               else
               {
                  go_on= low(verb_t, verb_no(verb_t), tmp, noun_no(tmp));
                  if (go_on)
                     go_on= paths(verb_no(verb_t));
               }
            }   
         }
         if (!dead)
            high();
         if (player == noun_no(actor))
            player= cplr;
         
      }
         
      phead();
      
      calcw();
      
      upd_doors();
      
      ++turns;
   } while ((go_on) && (w!=NULL));
   return go_on;
}

void load(mode,ram)
BOOLEAN mode, ram;
{
   FILE *f= NULL;
   int i=0, j=0, k;
   int test;
   char *p;

   while (odet[i][0] != -1)
      ++i;

   while (rmd[j][0] != -1)
      ++j;

   if (mode==TRUE)
   {
      PMSG(M_GET_FILE_NAME);
      get_input(fil,8,FALSE);
      if (script)
         prn_out(fil);
      upper(fil);
      newline(FALSE);
   }
   else
      strcpy(fil, "START123");
   strcat(fil, ".SAV");

   if (!ram)
   {
      f= fopen(fil, "rb");
      if (f==NULL)
      {
         PMSG(M_FILE_NOT_FOUND);
         return;
      }
   }

   if (ram)
   {  
      if (rss==FALSE)
      {
         PMSG(M_NO_RAM_LOAD);
         return;
      }
      p= rsb;
      memcpy(&odet[0][0],p,sizeof(int)*i*23);
      p+= sizeof(int)*i*23;
      memcpy(&rmd[0][0],p,sizeof(int)*j*4);
      p+= sizeof(int)*j*4;
      memcpy(&cnt[0],p,sizeof(int)*500);
      p+= sizeof(int)*500;
      memcpy(&score,p,sizeof(int));
      p+= sizeof(int);
      memcpy(&cplr,p,sizeof(int));
      p+= sizeof(int);
      memcpy(&player,p,sizeof(int));
      p+= sizeof(int);
   }
   else
   {
      fread(&test,sizeof(int),1,f);
      if (test!=(int) i*j+1782)
      {
      	PMSG(M_BAD_LOAD);
      	fclose(f);
      	return;
      }	
      else
      {
         fread(&odet[0][0],sizeof(int),i*23,f);
         fread(&rmd[0][0],sizeof(int),j*4,f);
         fread(&cnt[0],sizeof(int),500,f);
         fread(&score,sizeof(int),1,f);
         fread(&cplr,sizeof(int),1,f);
         fread(&player,sizeof(int),1,f);
      }
   }
   
   for (k=0; k<2; k++)
   {
      if (ram)
      {
         memcpy(strp[k],p,200);
         p+= 200;
      }
      else
         fread(strp[k],200,1,f);
      decrypt(strp[k]);
   }
   for (k=2; k<6; k++)
   {
      if (ram)
      {
         memcpy(strp[k],p,100);
         p+= 100;
      }
      else
         fread(strp[k],100,1,f);
      decrypt(strp[k]);
   }
   for (k=6; k<10; k++)
   {
      if (ram)
      {
         memcpy(strp[k],p,50);
         p+= 50;
      }
      else
         fread(strp[k],50,1,f);
      decrypt(strp[k]);
   }

   if (ram)
   {
      memcpy(&turns,p,sizeof(int));
      p+= sizeof(int);
   }
   else
   {   
      fread(&turns,sizeof(int),1,f);
      if (ferror(f))
         PMSG(M_DISK_ERROR);
      else
         if (mode==TRUE)
            PMSG(M_OPERATION_COMPLETE);
      fclose(f);
   }
}

void save(mode,ram)
BOOLEAN mode, ram;
{
   FILE *f= NULL;
   int i=0, j=0, k=0;
   int test=1;
   char *p;

   while (odet[i][0] != -1)
      ++i;

   while (rmd[j][0] != -1)
      ++j;

   test= i*j+1782;

   if (mode==TRUE)
   {
      PMSG(M_GET_FILE_NAME);
      get_input(fil,8,FALSE);
      if (script)
         prn_out(fil);
      upper(fil);
      newline(FALSE);
   }
   else
      strcpy(fil, "START123");
   strcat(fil, ".SAV");

   if (ram)
   {
      if (rsb==NULL)
      {
         rsb= (char *)malloc(RSIZE);
         if (rsb)
            rss=TRUE;
         else
         {
            PMSG(M_NO_RAM_SAVE);
            return;
         }
      }
   }
   else
   {
      f= fopen(fil, "wb");
      if (f==NULL)
      {
         PMSG(M_DISK_ERROR);
         PMSG(M_DISK_FULL);
         if (mode!=TRUE)
         {
            waitkey();
            crson();
            exit(1);
         }
      }
   }
   
   if (ram)
   {
      p= rsb;
      memcpy(p, &odet[0][0],sizeof(int)*i*23);
      p+= sizeof(int)*i*23;
      memcpy(p, &rmd[0][0],sizeof(int)*j*4);
      p+= sizeof(int)*j*4;
      memcpy(p, &cnt[0],sizeof(int)*500);
      p+= sizeof(int)*500;
      memcpy(p, &score,sizeof(int));
      p+= sizeof(int);
      memcpy(p, &cplr,sizeof(int));
      p+= sizeof(int);
      memcpy(p, &player,sizeof(int));
      p+= sizeof(int);
   }
   else
   {  
      fwrite(&test,sizeof(int),1,f);
      fwrite(&odet[0][0],sizeof(int),i*23,f);
      fwrite(&rmd[0][0],sizeof(int),j*4,f);
      fwrite(&cnt[0],sizeof(int),500,f);
      fwrite(&score,sizeof(int),1,f);
      fwrite(&cplr,sizeof(int),1,f);
      fwrite(&player,sizeof(int),1,f);
   }
   
   for (k=0; k<2; k++)
   {
      encrypt(strp[k]);
      if (ram)
      {
         memcpy(p,strp[k],200);
         p+= 200;
      }
      else
         fwrite(strp[k],200,1,f);
      decrypt(strp[k]);
   }
      
   for (k=2; k<6; k++)
   {
      encrypt(strp[k]);
      if (ram)
      {
         memcpy(p,strp[k],100);
         p+= 100;
      }
      else
         fwrite(strp[k],100,1,f);
      decrypt(strp[k]);
   }
      
   for (k=6; k<10; k++)
   {
      encrypt(strp[k]);
      if (ram)
      {
         memcpy(p,strp[k],50);
         p+= 50;
      }
      else
         fwrite(strp[k],50,1,f);
      decrypt(strp[k]);
   }
      
   if (ram)
   {
      memcpy(p, &turns, sizeof(int));
      p+= sizeof(int);
      PMSG(M_OPERATION_COMPLETE);
   }
   else
   {
      if (fwrite(&turns,sizeof(int),1,f)==0)
      {
         fclose(f);
      	 unlink(fil);
         PMSG(M_DISK_ERROR);
         PMSG(M_DISK_FULL);
         if (mode!=TRUE)
         {
            waitkey();
            crson();
            exit(1);
         }
      }
      else
      {
         fclose(f);
         if (mode==TRUE)
            PMSG(M_OPERATION_COMPLETE);
      }
   }
}

