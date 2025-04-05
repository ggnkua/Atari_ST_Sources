#define FORM01 "[0][Puffer belegt ...: %6ld|Puffer frei .....: %6ld|Puffer gesamt ...: %6ld|"
#define FORM011 "Puffer anzeigen ..:|Auf = rechte Maustaste|Ab = linke Maustaste|Ende = Tastatur][OK]"
#define FORM02 "[2][Wollen Sie wirklich|den Puffer l”schen ?][Ja|Nein]"
#define FORM03 "[2][Im Puffer sind schon Zeichen belegt.|File anfgen,berschreiben oder abbrechen ?][Anfgen|šberschreiben|Abbruch]"
#define FORM04 "[2][Das File ist gr”žer|als der Puffer.|Anfang oder Ende einladen ?][Anfang|Ende|Abbruch]"
#define FORM05 "[1][Fehler beim lesen|vom File !][Abbruch|Egal]"
#define FORM06 "[3][File l„žt sich|nicht einrichten !][Abbruch]"

#define FORM08 "[2][Puffer ausgeben !||Abbruch -> Beide Maustasten oder Taste][Ohne Echo|Mit Echo|Abbruch]"
#define FORM09 "[2][Abbrechen ?][Ja|Nein]"
#define FORM10 "[1][Sendung beendet !][OK]"
#define FORM11 "[0][Anzeigen : |Linke Maustaste : weiter Anzeigen|Rechte Maustaste: Zeile anzeigen |Beide Maustasten: Abburch        |"
#define FORM111 "Kopieren : |1. Filesel.-Box : File aussuchen |2. Filesel.-Box : Ziel bestimmen |Umbenennen :|   auch auf anderes Laufwerk m”glich][OK]"
#define FORM12 "[2][Sicher ?][Ja|Nein]"
#define FORM13 "[1][File konnte|nicht kopiert werden][Abbruch]"

#define STRING01 "File in Puffer laden"
#define STRING02 "Puffer in File abspeichern"
#define STRING03 "File anzeigen"
#define STRING04 "File l”schen"
#define STRING05 "File umbenennen"
#define STRING06 "Alter Filename :"
#define STRING07 "Neuer Filename:"
#define STRING08 "File kopieren !"
#define STRING09 "kopieren nach ?"
#define STRING10 "File schon vorhanden !"

#include <megatadd.h>
#include "ptvars.h"
#include <gembind.h>
#include <osbind.h>

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

overlay "ptbuffer"

extern char *ptadr();

buf_info()
{
   char string[300];

   sprintf(string,FORM01
                 ,(long) buf_point -(long) buf_start
                 ,(long) buf_end - (long) buf_point
                 ,(long) buf_end - (long) buf_start);
   strcat(string,FORM011);
   brain_alert(1,string);
}


buf_del()
{
   if(brain_alert(2,FORM02)==2)
      return(0);

   buf_point=buf_start;
   *buf_point = 0;
   clr_window();
   save_screen();
   return(1);
}

buf_load()
{
   int a,handle;
   long length,size;

   char path[80],name[40];

   path[0]=name[0]=0;
   a=file_select(STRING01,path,name,"*.*");
   if(!a)
      return;
   strcat(path,name);

   handle = Fopen(path,0);
   if(handle < 6)
   {
      brain_alert(1,ALNOTOPEN);
      return;
   }
   if(buf_start != buf_point)
   {
      a=brain_alert(2,FORM03);
      switch(a)
      {
         case 2   :  buf_point=buf_start;
         case 1   :  break;
         default  :  return;
      }
   }
   size = (long)buf_end-(long)buf_point;
   length = Fseek(0l,handle,2);
   Fseek(0l,handle,0);
   if(length > size)
   {
      a=brain_alert(1,FORM04);

      switch (a)
      {
         case  1  :  length = size; break;
         case  2  :  length -= size;
                     Fseek(size,handle,0);
                     if(length > size)
                        length = size;
                     break;
         default  :  return;
      }
   }

   TASSE;
   if(Fread(handle,length,buf_point) != length)
   {
      PFEIL;
      a=brain_alert(1,FORM05);
      TASSE;
      if(a!=2)
      {
         *buf_point = 0;
         Fclose(handle);
         PFEIL;
         return;
      }
   }
   buf_point += length;
   Fclose(handle);
   PFEIL;
}

buf_save()
{
   int a,handle;
   long length;
   char path[80],name[40];
   path[0]=name[0]=0;
   a=file_select(STRING02,path,name,"*.*");
   if(!a)
      return;
   strcat(path,name);

   handle = Fcreate(path,0);

   if(handle < 6)
   {
      brain_alert(1,FORM06);
      return;
   }

   length = (long)buf_point-(long)buf_start;
   TASSE;
   if(length != Fwrite(handle,length,buf_start))
   {
      PFEIL;
      brain_alert(1,ALWRIERR);
   }
   PFEIL;
   Fclose(handle);
}


buf_out()
{
   int a,b,wait,x;
   char *p;
   char *end;
   unsigned char *stringlen;
   int line;
   xcur=ycur=0;
   end = buf_point;
   *(end+1)=10;
   buf_point = buf_start;
   stringlen= (unsigned char *) box_space;
   hide_mouse();
   clr_window(wi_han1);
   /* erste Bildschirmseite ausgeben */
   for (a=0;a<max_ycur;a++)
   {
      line=ycur;
      stringlen[line]=0;
      do
      {
         out_c(*buf_point++);
         stringlen[line]++;
         if(buf_point>end)
         {
            buf_point=end;
            out_send();
            show_mouse();
            return;
         }
      }while(line==ycur);
   }
   line++;
   while(Cconis)
      Bconin(2);

STOP:
   while(!Bconstat(2)&&mouse_but!=3)
   {
   wait = 1000;

      while(mouse_but==1)        /* runterscrollen */
      {
         b=w_up=0;

         if(buf_point>=end)
         {
            goto STOP;
         }

         do
         {
            out_c(*buf_point++);
            b++;

         }while(!w_up);

         stringlen[line++]=b;

         if(wait)
         {
            for(a=wait;a;a--)
               Bcostat(0);
            wait -= wait>>4;
            wait --;
         }

      }

      if(mouse_but==2)
      {
         for(a=-1;a<max_ycur;a++)
            buf_point -= stringlen[--line];
         p=buf_point;
         buf_point -= stringlen[--line];

         while(mouse_but==2)
         {
            if(buf_point<buf_start||line<0)
            {

               for(a=-2;a<max_ycur;a++)
                  buf_point += stringlen[line++];
               ycur=max_ycur;
               xcur=0;
               goto STOP;
            }
            win_down();
            xcur=ycur=0;
            a=*p;
            *p=0;
            out_s(buf_point);
            *p=a;
            p=buf_point;
            buf_point -= stringlen[--line];
            if(wait)
            {
               for(a=wait;a;a--)
                  Bcostat(0);
               wait -= wait>>4;
               wait --;
            }
         }

         for(a=-2;a<max_ycur;a++)
            buf_point += stringlen[line++];
         ycur=max_ycur;
         xcur=0;
      }
   }
   buf_point=end;
   show_mouse();
}

buf_rs()
{
   char *p;
   int e;
   char c;

   e=brain_alert(1,FORM08)-1;

   if(e==2)
      return;

   if(e)
      hide_mouse();

   p=buf_start;

   while(p<buf_point)
   {
      if(mouse_but==3||Bconstat(2))
      {
         if(e)
            show_mouse();
         if(brain_alert(1,FORM09)==1)
            return;
         else
            if(e)
               hide_mouse();
      }

      switch(transfer)
      {
         case 0 : c = *p++; break;
         case 1 : c = *p++;
                  if(c&128)
                     continue;
                  else
                     break;

         default: c = own_table[*p++];
                  if(!c)
                     continue;
                  else
                     break;
      }
      portc(c);
      if(e)
         out_c(c);
   }
   if(e)
      show_mouse();
   brain_alert(1,FORM10);
}

file_out()
{

   int a,new,handle;
   int save_whencr,device;
   long length,size;
   int endflag=0;
   char path[80],name[40];
   GRECT work;

   path[0]=name[0]=0;
   a=file_select(STRING03,path,name,"*.*");
   if(!a)
      return;
   do_redraw();
   strcat(path,name);

   device = do_output();
   do_redraw();
   if(device==6)
   {
      file_copy();
      return;
   }

   handle = Fopen(path,0);
   if(handle < 6)
      return;

   size = 19900l;
   length = Fseek(0l,handle,2);
   Fseek(0l,handle,0);

   save_whencr=when_cr;
   when_cr=max_xcur;
   new=1;

   do
   {
      if(length < size)
      {
         size = length;
         endflag = 1;
      }
      if(Fread(handle,size,box_space)!=size)
         break;
      a=do_print(device,box_space,size,new,endflag);
      new=0;
      length -= size;
   }while(a);

   Fclose(handle);
   when_cr = save_whencr;
}

file_info()
{
   char s[360];

   strcpy(s,FORM11);
   strcat(s,FORM111);
   brain_alert(1,s);
}

file_del()
{
   int a;
   char path[80],name[40];

   while(1)
   {
      path[0]=name[0]=0;
      a=file_select(STRING04,path,name,"*.*");
      if(!a)
         return;
      strcat(path,name);
      if(form_alert(1,FORM12)==1)
      {
         a=Fdelete(path);
         if(a)
            form_error(-a);
      }
   }
}

file_ren()
{

   int a;
   char newpath[80];
   char path[80],name[40];

   path[0]=name[0]=0;
   a=file_select(STRING05,path,name,"*.*");
   if(!a)
      return;
   strcat(path,name);
   strcpy(newpath,path);

   file_name(STRING05,STRING06,STRING07,path,newpath);

   if(strcmp(path,newpath))       /* Anderes Laufwerk und/oder Pfad */
   {
      if(f_copy(path,newpath))   
         Fdelete(path);
      else
         Fdelete(newpath);
      return;
   }
   a=Frename(0,path,newpath);
   if(a)
      form_error(0-a);
}

file_copy()
{

   int a;
   char newpath[80],dummy[40];
   char path[80],name[40];

   path[0]=name[0]=0;
   a=file_select(STRING08,path,name,"*.*");
   if(!a)
      return;
   strcat(path,name);

   newpath[0]=dummy[0]=0;
   file_select(STRING09,newpath,dummy,"*.*");
   if(!strlen(newpath))
      return;
   strcat(newpath,name);

   if(!f_copy(path,newpath))
      brain_alert(1,FORM13);
}

f_copy(path,newpath)
char path[];
char newpath[];
{
   int handle,handle1;
   long length,space;
   char s[100];

   space =19900;
   handle=Fopen(path,0);
   if(handle < 6)
      return 0 ;

   do
   {
      handle1=Fopen(newpath,1);
      Fclose(handle1);
      if(handle1 > 5)
      {
         strcpy(s,newpath);
         file_name(STRING10,STRING06,STRING07,
                     path,newpath);

         if(!strcmp(s,newpath))
            break;
      }
      if(!strlen(newpath))
         goto Abbruch;

   }while(handle1>5);

   if(!strcmp(path,newpath))
      goto Ende;

   TASSE;

   handle1=Fcreate(newpath,0);
   if(handle1<6)
      goto Abbruch;

   length=Fseek(0l,handle,2);
   Fseek(0l,handle,0);
   do
   {
      if(length<space)
         space = length;
      if(Fread(handle,space,box_space)!=space)
         goto Abbruch;
      if(Fwrite(handle1,space,box_space)!=space)
         goto Abbruch;
      length -= space;
   }while(length > 0);

Ende:
   PFEIL;
   Fclose(handle);
   Fclose(handle1);
   return 1;

Abbruch:
   PFEIL;
   Fclose(handle);
   Fclose(handle1);
   return 0;
}

file_name(title,oldfile,newfile,oldpath,newpath)
char *newpath,*title,*oldfile,*newfile,*oldpath;
{
   int exit;

   do_redraw();
   OB_SPEC(finam_di,FI_TITLE)=title;
   OB_SPEC(finam_di,FI_OLDNA)=oldfile;
   OB_SPEC(finam_di,FI_NEWNA)=newfile;
   OB_SPEC(finam_di,FI_OLDPA)=oldpath;
   strcpy(ptadr(finam_di,FI_NEWPA,0),newpath);

   undo_objc(finam_di,hndl_dial(finam_di,FI_NEWPA,SMXY,SMWH),SELECTED);

   strcpy(newpath,ptadr(finam_di,FI_NEWPA,1));
}
