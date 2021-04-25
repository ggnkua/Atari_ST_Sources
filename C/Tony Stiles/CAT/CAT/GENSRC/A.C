#ifndef PC
#ifndef ST
#define ST 1
#endif
#endif

#include "xlang.h"

#include <string.h>

#define COMMAND 1
#define FNAME 2

#include "xdef.h"

#define MAIN TRUE

#include "xglobals.h"
#include "xfuncs.h"

#include "a.dic"

#include "portab.i"

void encrypt(s)
char *s;
{
#ifdef DECRYPT
   char *p;

   static char *code1="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
   static char *code2="qazwsxedcrfvtgbyhnujmikolpMNBVCXZQWERTYUIOPGHJKLFDSA";
   
   while (*s)
   {
      p= strchr(code1,*s);
      if (p)
         *s= code2[p-code1];
      s++;
   }
#endif
}

void decrypt(s)
char *s;
{
#ifdef DECRYPT
   char *p;

   static char *code1= "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
   static char *code2= "qazwsxedcrfvtgbyhnujmikolpMNBVCXZQWERTYUIOPGHJKLFDSA";

   while (*s)
   {
      p= strchr(code2,*s);
      if (p)
         *s= code1[p-code2];
      s++;
   }
#endif
}

centre(l)
char *l;
{
   int i, w;
   w= width();
   for (i=0; i<((w-strlen(l))/2);i++)
      printf(" ");
   printf("%s", l);
}

main()
{
   FILE *title;
   char l[82];
   int i;
   BOOLEAN more= FALSE, got_cmd, go_on=FALSE, start_again= TRUE, saved= FALSE;

   setbuf(stdout, NULL);

   crsoff();
   cls();
   first();
   usc=0;
   x=3;
   newline(TRUE);
   cls();
   title= fopen("title.txt", "r");
   if (title != NULL)
   {
      while (fgets(l,80,title)!=NULL)
         centre(l);
      fclose(title);
   }
   printf("\n");
   centre("Created with the\n");
   centre("C Adventure Toolkit by Tony Stiles\n");
   printf("\n");
   centre("103a Ludlow Road\n");
   centre("Itchen, Southampton\n");
   centre("Hants, SO2 7ER\n");
   centre("United Kingdom\n");

   i=0;
   while (strlen(dict[i]))
   {
      decrypt(dict[i]);
      ++i;
   }

   i=0;
   while (strlen(vsynt[i]))
   {
      decrypt(vsynt[i]);
      ++i;
   }

   i=0;
   while (strlen(osynt[i]))
   {
      decrypt(osynt[i]);
      ++i;
   }

   i=0;
   while (strlen(osht[i]))
   {
      decrypt(osht[i]);
      ++i;
   } 

   i=0;
   while (strlen(olng[i]))
   {
      decrypt(olng[i]);
      ++i;
   }

   i=0;
   while (strlen(rms[i]))
   {
      decrypt(rms[i]);
      ++i;
   }

   i=0;
   while (strlen(rms[i]))
   {
      decrypt(rml[i]);
      ++i;
   }

   i=0;
   while (strlen(msg[i]))
   {
      decrypt(msg[i]);
      ++i;
   }

   i=0;
   while (strlen(oqual[i]))
   {
      decrypt(oqual[i]);
      ++i;
   }

   i=0;
   while (strlen(oqualo[i]))
   {
      decrypt(oqualo[i]);
      ++i;
   }

   i=0;
   while (strlen(vprep[i]))
   {
      decrypt(vprep[i]);
      ++i;
   }

   waitkey();

   while (start_again)
   {
      cls();
      printf("\n\n");
   
      printf(" ");

      for (i=0; i<500; i++)
         cnt[0]=0;
      cnt[496]= -1;

      sinit();
      init();
      if (!saved)
      {
         save(FALSE,FALSE);
         saved=TRUE;
      }
      if (!dead)
      {
         WHOAMI;
         LOOK;
      }

      while (!dead)
      {
         if ((!go_on) || (!more))
         {
            newline(FALSE);
            newline(FALSE);
            if (turns < 10)
               PMSG(M_WHAT_NOW);
            else
               prt_text(">");
            get_input(str, 80, TRUE);
            strcat(str, "  "); 
            sptr= str;
            if (script)
               prn_out(str);
            upper(str);
         }
         get_cmd(&more, &got_cmd);
         if (got_cmd)
            go_on= prc_cmd();
         else
         {
            newline(FALSE);
            PMSG(M_NO_COMMAND);
         }
      }
      newline(FALSE);
      UNSCRIPT;
      PMSG(M_PLAY_AGAIN);
      start_again= yesno();
      if (start_again)
      {
         load(FALSE,FALSE);
         usc=0;
         x=3;
         dead= FALSE;
         verbose= FALSE;
         newline(TRUE);
      }
   }
   last();
   unlink("START123.SAV");
   crson();
}


