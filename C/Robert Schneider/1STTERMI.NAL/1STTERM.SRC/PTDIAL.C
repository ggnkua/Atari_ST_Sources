#define STRING01 "Nummern laden" 
#define STRING02 "Nummern speichern"
#define STRING03 "Fehler"

#define FORM01 "[3][Diese Funktion|ist nur im|Online-Status verfÅgbar][Abbruch]"
#define FORM02 "[0][Mit den Pfeilen kînnen Sie die|internen Register des Modems|setzen (vom Rechner weg)|oder|einlesen (zum Rechner hin)][OK]"
#define FORM03 "[3][Modem akzeptiert|Register %2d|nicht !][Ignorieren|Abbruch]"
#define FORM04 "[2][Laden oder Speichern ?][Laden|Speichern]"
#define FORM05 "[2][Nach dem WÑhlen|zurÅck in den|Online-Modus][Ja|Nein|Abbruch]"
#define FORM06 "[3][Modem legt nicht auf !][Ignorieren|Abbruch]"


#include <osbind.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

extern char *ptadr();
extern OBJECT **load_rsrc();

do_modem()
{
   int a,b,exit;
   char s_s[80],r_s[80];
   GRECT box;

   if(!online)
   {
      brain_alert(1,FORM01);
      return;
   }

   TASSE;

   for(a=0;a<3;a++)
   {
      send_modem("E0",r_s);
      if(!strcmp(r_s,"OK"))
         break;
   }

   for(a=0;a<17;a++)
   {
      strncpy(regs[a],"???",3);
   }

   objc_xywh(mainmenu,buf,&box);
   box_draw(dial__di,box.g_x,box.g_y,box.g_w,box.g_h);

   PFEIL;

   do
   {
      exit=form_do(dial__di,DL___COM);

      switch(exit)
      {
         case DL__OKAY  : break;

         case DLHELREG  :  form_alert(1,FORM02);
            break;

         case DLGETREG  :
            TASSE;
            for(a=0;a<17;a++)
            {
               strcpy(regs[a],"???");
               objc_update(dial__di,DL____R0+a,0);
            }
            for(a=0;a<17;a++)
            {
               sprintf(s_s,"S%d?",a);
               send_modem(s_s,r_s);
               strncpy(regs[a],r_s,3);
               objc_update(dial__di,DL____R0+a,0);
            }
            PFEIL;
            break;

         case DLSENREG  :
            TASSE;
            for(a=0;a<17;a++)
            {
               sprintf(s_s,"S%d=%s",a,regs[a]);
               send_modem(s_s,r_s);
               if(strcmp(r_s,"OK"))
               {
                  PFEIL;
                  sprintf(s_s,FORM03,a);
                  if(form_alert(1,s_s)==2)
                     break;
                  else
                     TASSE;
               }
            }
            PFEIL;
            break;

         case DL__DISK  :
            b=form_alert(1,FORM04);
            TASSE;
            if(b==1)
               nums_disk(0);
            else
               nums_disk(1);
            objc_update(dial__di,DLNUMBOX,8);
            PFEIL;
            break;

         case DL_VOL_1  :  send_modem("L1",r_s); break;
         case DL_VOL_2  :  send_modem("L2",r_s); break;
         case DL_VOL_3  :  send_modem("L3",r_s); break;

         case DL_SPOFF  :  send_modem("M0",r_s); break;
         case DL_SP_CD  :  send_modem("M1",r_s); break;
         case DL_SP_AL  :  send_modem("M2",r_s); break;

         case DLSENDIT  :  send_modem(ptadr(dial__di,DL___COM,1),r_s); break;

         case RDDIAL01  :  b=0; goto dial_it;
         case RDDIAL02  :  b=1; goto dial_it;
         case RDDIAL03  :  b=2; goto dial_it;
         case RDDIAL04  :  b=3; goto dial_it;
         case RDDIAL05  :  b=4; goto dial_it;
         case RDDIAL06  :  b=5; goto dial_it;
         case RDDIAL07  :  b=6; goto dial_it;
         case RDDIAL08  :  b=7; goto dial_it;
         case RDDIAL09  :  b=8; goto dial_it;
         case RDDIAL10  :  b=9; goto dial_it;
dial_it:
            sprintf(s_s,"DP%s",nums[b]);
            b=form_alert(1,FORM05);
            if(b==3)
               break;
            send_modem("H0",r_s);
            if(strcmp(r_s,"OK"))
            {
               sprintf(s_s,FORM06);
               if(form_alert(1,s_s)==2)
                  break;
            }
            Cauxout('A');
            Cauxout('T');
            a=0;
            while(s_s[a])
               Cauxout(s_s[a++]);

            if(b==1)
            {
               Cauxout(13);
               undo_objc(dial__di,exit,SELECTED);
               exit=DL__OKAY;
            }
            else
            {
               Cauxout(';');
               Cauxout(13);
            }
            break;

      }/* Switch end */

      undo_objc(dial__di,exit,SELECTED);
      objc_update(dial__di,exit,8);

      if(strcmp(r_s,ptadr(dial__di,DLRESULT,1)))
      {
         strcpy(ptadr(dial__di,DLRESULT,1),r_s);
         objc_update(dial__di,DLRESULT,0);
      }

   }while(exit!=DL__OKAY);

   box_undraw(dial__di,box.g_x,box.g_y,box.g_w,box.g_h);
}

nums_disk(what)
int what;
{
   int a,handle;
   char pfad[80],name[20],s[20];

   if(what==2)
   {
      pfad[0]=0;
      strcpy(name,"1ST_TERM.TEL");
      if(fil_len(name)<=0)
         return;
      what=0;
   }
   else
   {
      if(!what)
         strcpy(s,STRING01);
      else
         strcpy(s,STRING02);

      pfad[0]=name[0]=0;
      PFEIL;
      if(!file_select(s,pfad,name,"*.TEL"))
         return;
   }
   TASSE;
   strcat(pfad,name);

   if(!what)
      handle=Fopen(pfad,0);
   else
      handle=Fcreate(pfad,0);

   if(handle<6)
   {
      PFEIL;
      form_alert(1,ALNOTOPEN);
      return;
   }

   for(a=0;a<10;a++)
   {
      if(!what)
      {
         Fread(handle,21l,numdoc[a]);
         numdoc[a][20]=0;
         Fread(handle,21l,nums[a]);
         nums[a][20]=0;
      }
      else
      {
         Fwrite(handle,21l,numdoc[a]);
         Fwrite(handle,21l,nums[a]);
      }
   }

   Fclose(handle);
}

send_modem(s,r)
char *s,*r;
{
   char c;
   int a;

   while(Cauxis())
      Cauxin();

   Cauxout('A');
   Cauxout('T');

   while(*s)
   {
      if(Cauxos())
         Cauxout(*s++);

      if(Bconstat(2))
      {
         Bconin(2);
         strcpy(r,STRING03);
         return;
      }
   }
   Cauxout(13);

   do
   {
      if(Cauxis())
         c=Cauxin();
      if(Bconstat(2))
      {
         Bconin(2);
         strcpy(r,STRING03);
         return;
      }
   }while(c!=10);

   do
   {
      if(Cauxis())
         *r++ = Cauxin();
      if(Bconstat(2))
      {
         Bconin(2);
         strcpy(r,STRING03);
         return;
      }
   }while(*(r-1)!=10);

   *(r-2)=0;

   for(a=0;a<40;a++)
      Vsync();

   while(Cauxis())
      Cauxin();
}
