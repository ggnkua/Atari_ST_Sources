#ifndef PC
#ifndef ST
#define ST 1
#endif
#endif

#include "xlang.h"

#include <string.h>

#include "xdef.h"

#define SHELL2 TRUE

#include "xglobals.h"
#include "xfuncs.h"

static char delim='\0';

#include "portab.i"

void waitkey()
{
   crson();
   printf("%c", 7);
   (void) getachar();
   crsoff();
}

void sscript()
{
   prn_out("\n");
   prn_out("**************************************************************\n");
   prn_out("**   Here starts script mode from the C Adventure Toolkit   **\n");
   prn_out("**************************************************************\n");
   prn_out("\n\n");
}

void escript()
{
   prn_out("\n");
   prn_out("**************************************************************\n");
   prn_out("**    Here ends script mode from the C Adventure Toolkit    **\n");
   prn_out("**************************************************************\n");
   prn_out("\n\f");
}

void newline(mode)
BOOLEAN mode;
{
   static int scroll=0;
   int i;

   if (mode==TRUE)
      scroll=0;
   else
   {
      ++scroll;
      if (scroll>=23)
         wrap();
      else
         printf("\n ");
      if (script)
         prn_out("\n ");
      ++usc;
      if (usc%22==0)
      {
         printf(msg[M_MORE]);
         waitkey();
         for (i=0; i<strlen(msg[M_MORE]); i++)
            printf("%c",8);
         for (i=0; i<strlen(msg[M_MORE]); i++)
            printf(" ");
         for (i=0; i<strlen(msg[M_MORE]); i++)
            printf("%c", 8);
      }
      x=2;
   }
}

void endchar(c)
char c;
{
   delim= c;
}

void cmdcat(out,cmd)
char *out, *cmd;
{
   char wrk[80];
   char *p;
   
   strcpy(wrk, cmd);
   p= strchr(wrk, '_');
   if (p)
      *p= ' ';
      
   strcat(out,wrk);
}

void expand(in,out)
char *in, *out;
{
   int i=0;
   char work[500];
   int n;

   work[0]='\0';
   out[0]='\0';
   
   while (in[i])
   {
   	
      if (in[i]=='~')			/* Compressed words */
      {
         sscanf(&in[i+1],"%x",&n);
         expand(dict[n-1],work);
         strcat(out,work);
         i+=2;
         if (n>15) i++;
         if (n>255) i++;
         if (n>4095) i++;
      }
      else if (in[i]=='#')             /* Counters in text */
      {
         if (sscanf(&in[i+1],"%d",&n)>0) 
         {
            sprintf(pc,"%d",cnt[n-1]);
            strcat(out,pc);
            i++;
            if (n>9) i++;
            if (n>99) i++;
         }
      }
      else if (in[i]=='$')		/* Include something here */
      {
         if ((in[i+1]=='v') || (in[i+1]=='V'))  /* its a verb */
         {
            ++i;
            if ((in[i+1]=='c') || (in[i+1]=='C'))  /* compound verb */
            {
               ++i;
               cmdcat(out,prepv);
            }
            else
               cmdcat(out,vp);
         }
         else if ((in[i+1]=='N') || (in[i+1]=='N')) /* Noun */
         {
            ++i;
            if ((in[i+1]=='c') || (in[i+1]=='C'))  /* compound Noun */
            {
               ++i;
               cmdcat(out,prepo);
            }
            else
               cmdcat(out,np);
         }
         else if ((in[i+1]=='A') || (in[i+1]=='A'))	/* Actor */
         {
            ++i;
            cmdcat(out,actor);
         }
         else
         {
            if (sscanf(&in[i+1],"%d",&n)>0)  /* This is a string */
            {
               expand(strp[n-1],work);
               strcat(out,work);
               i++;
               if (n>9) i++;
               if (n>99) i++;
            }
         }
      }
      else
      {
         out[strlen(out)+1]='\0';
         out[strlen(out)]=in[i];
      }
      ++i;
   }
   for (i=strlen(out); i<strlen(out)+80; i++)
      out[i]='\0';
}

void prt_text(in)
char *in;
{
   static char ol[2000]="";
   char wrk[80];
   char *o;
   int w;

   w= width();

   expand(in,&ol[0]);
   o= &ol[0];

   if (delim != '\0')
   {
      o[strlen(o)]=delim;
      delim= '\0';
   }
   
   do
   {
      o= strtok(o, " ");
      if (o)
      {
         if (strcmp(o, "LF")==0)
            newline(FALSE);
         else
         {
            strcpy(wrk,o);
            if ((x+strlen(wrk)+1)>w)
               newline(FALSE);
            printf("%s ", wrk);
            if (script)
            {
               prn_out(wrk);
               prn_out(" ");
            }
            x+= strlen(wrk)+1;
         }
         o+= strlen(o)+1;
      } 
   } while (o != NULL);
}

ftext(s)
char *s;
{
   printf(s);
   if (script)
      prn_out(s);
   NEWLINE;
}

int strfstr(s1,s2)
char *s1, *s2;
{
   char *p;
   
   p= strstr(s1,s2);
   if (p)
      return(p-s1);
   else
      return(-1);
}

int strfchr(s,c)
char *s, c;
{
   char *p;
   
   p= strchr(s,c);
   if (p)
      return(p-s);
   else
      return(-1);
}

