static char *STRING01 ="Funktionstasten einladen";
static char *STRING02 ="Funktionstasten speichern";

#define STRING05 "Funktions- | Zusatz-   | Text/  |     Belegung der Taste\12\15 taste     | taste     | File   |\12\15"
#define STRING07 "   F-%2d    | %9s | %6s | %s\12\15"

#define FORM01 "[1][Fileendung auf .FKY |ge„ndert!][OK]"
#define FORM02 "[3][Fehler in Filename ||%s][Abbruch]"
#define FORM03 "[1][Sendung wird abgebrochen !][OK]"
#define FORM04 "[1][Sendung beendet !][OK]"
#define FORM05 "[2][Dateiname fr Senden :|'%s'||Wandlung 1st_WORD -> BINARY||Sendeabbruch :|Beide Maustasten oder Taste !][Ohne Echo|Mit Echo|Abbruch]"

#include <osbind.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

overlay "ptfkey"

extern char* index();
extern char* ptadr();

/*  Ausgabe der Funktionstasten-Dialogbox  */

do_fkey()
{
   GRECT box;
   int exit;
   char select[2];

   objc_xywh(mainmenu,buf,&box);
   box_draw(fkey_di,box);
   set_string(select);
   while(1)
   {
      exit=form_do(fkey_di,STRING);
      get_string(select);
      if(exit==FK__OKAY)
         break;
      set_string(select);
   }
   undo_objc(fkey_di,exit,SELECTED);
   box_undraw(fkey_di,box);
}

/* Konverter fkey[] der Dialogbox  */


set_string(select)
char *select;
{
   int a,b;
   char *string;
   int pointer;

   for(a=0;a<10;a++)
      if(is_objc(fkey_di,F1___KEY+a,SELECTED))
         select[0]=a+1;

   if(is_objc(fkey_di,FNOR_KEY,SELECTED)) select[1]=0;
   if(is_objc(fkey_di,CON__KEY,SELECTED)) select[1]=2;
   if(is_objc(fkey_di,ALT__KEY,SELECTED)) select[1]=3;
   if(is_objc(fkey_di,SHIF_KEY,SELECTED)) select[1]=1;

   pointer = select[0] + select[1]*10;
   string=ptadr(fkey_di,STRING,0);
   strncpy(string,fkey[pointer],40);
   objc_update(fkey_di,STRING,0);
   if(fflag[pointer]=='2')
   {
      a=TEXT_BUT; b=FILE_BUT;
   }
   else
   {
      a=FILE_BUT; b=TEXT_BUT;
   }

   undo_objc(fkey_di,a,SELECTED);
   do_objc(fkey_di,b,SELECTED);

   objc_update(fkey_di,FILE_BUT,0);
   objc_update(fkey_di,TEXT_BUT,0);

}

/* Konverter der Dialogbox in fkey[] */

get_string(select)
char select[];
{
   char *string;
   int pointer;

   string=ptadr(fkey_di,STRING,1);
   pointer=select[0] + select[1]*10;
   strcpy(fkey[pointer],string);
   fflag[pointer]='1';
   if(is_objc(fkey_di,FILE_BUT,SELECTED))
      fflag[pointer]='2';
   if(!strlen(string))
      fflag[pointer]='0';
}

/* Funktionstasten einladen  */

load_fkey(what)
int what;
{
   char *p;
   char pfad[80];
   char name[20];

   int test,a;
   int handle;

   pfad[0]=0;
   name[0]=0;

   if(what==2)
   {
      strcpy(name,"1ST_TERM.FKY");
      if(fil_len(name)<=0)
         return;
   }
   else
   {
      test=file_select(STRING01,pfad,name,"*.FKY");
      if(!test)
         return;
   }

   strcat(pfad,name);
   handle=Fopen(pfad,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }
   TASSE;
   if(Fread(handle,1764l,fbuffer)!=1764l)
   {
      PFEIL;
      brain_alert(1,ALREAERR);
      return;
   }
   for(a=40;a<1764;a+=43)
   {
      fbuffer[a]=0;
      fbuffer[a+1]=13;
      fbuffer[a+2]=10;
   }
   if(Fread(handle,42l,fflag)!=42l)
   {
      PFEIL;
      brain_alert(1,ALREAERR);
      return;
   }
   Fread(handle,6l,cur_up);
   Fread(handle,6l,cur_dn);
   Fread(handle,6l,cur_lt);
   Fread(handle,6l,cur_rt);
   cur_up[5]=0;
   cur_dn[5]=0;
   cur_lt[5]=0;
   cur_rt[5]=0;
   Fclose(handle);
   PFEIL;
}

/* Funktionstasten abspeichern  */

save_fkey()
{
   char *p;
   char pfad[80];
   char name[20];

   int test,a;
   int handle;

   pfad[0]=0;
   name[0]=0;

   if(!file_select(STRING02,pfad,name,"*.FKY"))
      return;
   p=index(name,'.');
   if(!p)
      p=name+strlen(name);

   if(strcmp(p,".fky") && strcmp(p,".FKY"))
   {
      brain_alert(1,FORM01);
      strcpy(p,".FKY");
   }
   strcat(pfad,name);
   strcpy(fbuffer,name);
   TASSE;
   handle=Fcreate(pfad,0);
   if(handle<6)
   {
      PFEIL;
      sprintf(pfad,ALNOTOPEN);
      brain_alert(1,pfad);
      return;
   }
   if(Fwrite(handle,1764l,fbuffer)!=1764l)
   {
      PFEIL;
      brain_alert(1,ALWRIERR);
      return;
   }
   if(Fwrite(handle,42l,fflag)!=42l)
   {
      PFEIL;
      brain_alert(1,ALWRIERR);
      return;
   }
   Fwrite(handle,6l,cur_up);
   Fwrite(handle,6l,cur_dn);
   Fwrite(handle,6l,cur_lt);
   Fwrite(handle,6l,cur_rt);
   Fclose(handle);
   PFEIL;
}

/*Steuerung von F-Tasten <-> Diskette */

do_fdisk()
{
   int test;

   test = do_disk(STRING01,STRING02);
   do_redraw();
   if(test==1)
      load_fkey(1);
   else
      save_fkey();
}

do_fshow()
{
   char *string;
   char druck[80];
   char addkey[4][10];
   char kind[3][8];

   int device;
   int a,b,c;
   long length;
   string = box_space;

   device=do_output();
   do_redraw();
   if(!device)
      return;

   strcpy(string,STRING05);

   strcat(string,strich80);
   strcat(string,cr_lf);


   strcpy(addkey[1],"Shift");
   strcpy(addkey[0],space0);
   strcpy(addkey[2],"Control");
   strcpy(addkey[3],"Alternate");

   strcpy(kind[0],space0);
   strcpy(kind[1],"Text");
   strcpy(kind[2],"File");

   for(b=0;b<4;b++)
   {
      for(a=1;a<11;a++)
      {
	 c=a+10*b;

         if(fflag[c] < '0' || fflag[c] > '2')
            fflag[c] = '0';
         sprintf(druck,STRING07
         ,a,addkey[b],kind[fflag[c]-'0'],fkey[c]
         );
         strcat(string,druck);
      }
      strcat(string,cr_lf);
   }

   strcat(string,strich80);
   length=(long)strlen(string);
   a=lf_screen;
   lf_screen=0;
   do_print(device,string,length,1,1);
   lf_screen=a;
}

send_1st(name)
char *name;
{
   int b,e;
   int a,handle;
   long len,r_len;
   char c;
   unsigned char *p;
   char string[300];

   len=fil_len(name);
   if(len<0)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }

   handle=Fopen(name,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }

   sprintf(string,FORM05,name);


   e=brain_alert(1,string)-1;
   if(e==2)
      return;

   TASSE;

   if(e)
   {
      hide_mouse();
      clr_window(wi_han1);
   }

   while(Bconstat(2))
      Bconin(2);

   while(len>0)
   {
      r_len=(len>19999)?19999:len;
    
      if(Fread(handle,r_len,box_space)!=r_len)
      {
         PFEIL;
         if(e)
            show_mouse();
         brain_alert(1,ALREAERR);
         Fclose(handle);
         return;
      }
      len-=r_len;

      box_space[r_len]=0;
      p=(unsigned char *)box_space;
      while(p<(unsigned char *)box_space+r_len)
      {
         if(mouse_but==3||Bconstat(2))
         {
            while(Bconstat(2))
               Bconin(2);
            PFEIL;
            if(e)
               show_mouse();
            brain_alert(1,FORM03);
            Fclose(handle);
            save_screen();
            return;
         }
         if(!b)
         {
            if(1)
               switch(*p)
               {
                  case  0x1f  :  b=1; continue;
                  case  0x1c  :
                  case  0x1d  :  p++; continue;
                  case  0x0b  :
                  case  0x1b  :  p+=2; continue;
                  case  0x1e  :  p++; c=' '; break;
                  default     :  c=*p++;
               }
            switch(transfer)
            {
               case 0 : c = *p++; break;
               case 1 : c = *(p++)&127; break;
               default: if(!(c=own_table[*p++]))
                           continue;
                        else
                           break;
            }
            portc(c);
            if(e)
               out_c(c);
         }
         else
            if(*p++==10)
               b=0;
      }
   }

   Fclose(handle);

   save_screen();

   PFEIL;

   if(e)
      show_mouse();

   brain_alert(1,FORM04);
}
