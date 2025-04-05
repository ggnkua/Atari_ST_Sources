#define STRING01 "ASCII-Table auswÑhlen"
#define STRING02 "Erste Tabelle"
#define STRING03 "Zweite Tabelle"
#define STRING04 "Auto-Logon-Datei"

#define FORM01 "[3][Datei ist zu groû !||Kommentare kÅrzen !][OK]"
static char FORM02[]= "[3][Syntax-Fehler !][Abbruch]";


overlay "bremser"

#include <osbind.h>
#include <gembind.h>
#include "ptvars.h"
#include <megatadd.h>

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

extern char *ptadr();
extern char *index();
extern long fil_len();


brems_wie_die_sau()
{
   int sli_wert,a;
   int exit,offset;
   int mx,my,button,kstate=0;
   GRECT field,slide,box;
   char byte;
   long help;

   objc_xywh(mainmenu,buf,&box);

   sli_wert=bremser;

   box_draw(time__di,box);
   brems_update(sli_wert);

   do
   {
      if(exit != -1)
      {      
         undo_objc(time__di,exit,SELECTED);
         objc_update(time__di,exit,2);
         exit = -1;
      }


      while(exit==-1)
      {
         if(mouse_but)
            exit=objc_find(time__di,0,8,mouse_x,mouse_y);
         if(Bconstat(2))
            if(Bconin(2)==13)
               exit = TI__OKAY;         

         if(exit!=TI__OKAY&&exit!=TI__LEFT&&exit!=TI_RIGHT&&
            exit!=TI_SLIDE&&exit!=TICANCEL)
            exit=-1;
      }     
      kstate = Kbshift(-1);
      do_objc(time__di,exit,SELECTED);
      objc_update(time__di,exit,2);

      switch(exit)
      {
         case TI__LEFT  :
                           sli_wert=(kstate&0x0003) ? sli_wert-10 : sli_wert-1;
                           sli_wert=(sli_wert>0)  ? sli_wert : 0;
                           break;

         case TI_RIGHT :
			   sli_wert=(kstate&0x0003) ? sli_wert+10 : sli_wert+1;
                           sli_wert=(sli_wert<=600)  ? sli_wert : 600;
                           break;

         case TI_SLIDE :   offset=graf_slidebox(time__di,TI_FIELD,TI_SLIDE,0);
                           sli_wert=((long)offset*600l)/1000;
                           break;
      }
      brems_update(sli_wert);
   }while(exit!=TICANCEL&&exit!=TI__OKAY);

   if(exit==TI__OKAY)
         bremser=sli_wert;

   undo_objc(time__di,exit,SELECTED);
   objc_update(time__di,exit,2);
   box_undraw(time__di,box);
}

brems_update(sli_wert)
int sli_wert;
{
   char *ti_string;   

   ti_string=ptadr(time__di,TI___SEC,0);
   sprintf(ti_string,"%3d",sli_wert);
   ti_string[0]=(ti_string[0]==' ') ? '0' : ti_string[0];
   ti_string[1]=(ti_string[1]==' ') ? '0' : ti_string[1];
   objc_update(time__di,TI___SEC,2);

   OB_X(time__di,TI_SLIDE) = ((long)sli_wert<<1)/5l;
   objc_update(time__di,TI_FIELD,2);
}

get_own(ascown)
int ascown;
{
   int a,b,c,handle;
   long len;
   char pfad[80],name[40];
   char *p,*string;

   if(ascown)
      strcpy(pfad,"ASCII_D.ASC");
   else
   {
      if(!file_select(STRING01,pfad,name,"*.ASC"))
      {
         do_redraw();
         own_loaded=0;
         return;
      }
      do_redraw();
      strcat(pfad,name);
   }

   len=fil_len(pfad);
   if(len<0)
   {
      brain_alert(1,ALNOTOPEN);
      own_loaded=0;
      return;
   }

   if(len>20000)
   {
      a=brain_alert(1,FORM01);
      return;
   }

   handle=Fopen(pfad,0);
   if(handle<6)
   {
      brain_alert(1,ALNOTOPEN);
      own_loaded=0;
      return;
   }

   if(!(own_table&&own_loaded))
   {
      own_table=(char *)Malloc(512l);
      if(!own_table)
      {
         brain_alert(1,ALNOMEM);
         Fclose(handle);
         own_loaded=0;
         return;
      }
      iwn_table=own_table+256;
   }

   TASSE;

   for(a=0;a<512;a++)
      *(own_table+a)=(char)(a&0xff);

   Fread(handle,len,box_space);
   Fclose(handle);
   string=box_space;
   p=index(string,10);
   if(!p)
   {
      PFEIL;
      brain_alert(1,FORM02);
      return;
   }
   *p=0;
   len-=strlen(string)+1;

   while(len>0)
   {
      if(p=index(string,'E'))
         if(!strncmp(p,STRING02,13))
            break;
      string+=strlen(string)+1;
      p=index(string,10);
      if(!p)
      {
         PFEIL;
         brain_alert(1,FORM02);
         return;
      }
      *p=0;
      len-=strlen(string)+1;
   }

   while(len>0)
   {
      string+=strlen(string)+1;
      p=index(string,10);
      if(!p)
      {
         PFEIL;
         brain_alert(1,FORM02);
         return;
      }
      *p=0;
      len-=strlen(string)+1;
      if(p=index(string,'Z'))
         if(!strncmp(p,STRING03,14))
            break;

      a=atoi(string);
      p=index(string,',');
      if(a&&p)
      {
         b=atoi(p+1);
         *(own_table+(a&0xff))=b;
      }
   }

   while(len>0)
   {
      string+=strlen(string)+1;
      p=index(string,10);
      if(!p)
         break;
      *p=0;
      len-=strlen(string)+1;

      a=atoi(string);
      p=index(string,',');
      if(a&&p)
      {
         b=atoi(p+1);
         *(iwn_table+(a&0xff))=b;
      }
   }


   if(ascown)
   {
      asc_loaded=1;
      own_loaded=0;
   }
   else
   {
      own_loaded=1;
      asc_loaded=0;
   }
   PFEIL;
}

brain_alert(defexit,string)
int defexit;
char *string;
{
   int a;

   a=alert_akt;
   alert_akt=1;
   set_mouse();
   form_alert(defexit,string);
   alert_akt=a;
   irq_menu=0;
}

long autolen;
int autoda=0;

load_auto(how)
int how;
{
   char pfad[80],name[20];
   int han;
   long len,a,fil_len();

   if(how)
   {
      if((len=fil_len("1ST_TERM.LOG"))>0)
         strcpy(pfad,"1ST_TERM.LOG");
      else
         return(0);

      han=Fopen(pfad,0);
      if(han<6)
         return(0);
   }
   else
   {
      pfad[0]=name[0]=0;
      if(!file_select(STRING04,pfad,name,"*.LOG"))
         return(0);
   
      strcat(pfad,name);
      len=fil_len(pfad);

      if(len<0||((han=Fopen(pfad,0))<6))
      {
         brain_alert(1,ALNOTOPEN);
         autocode=0;
         return(0);
      }
   }

   TASSE;
   if(autoda)
   {
      buf_end+=autolen;
      buf_size+=autolen;
   }
   autocode=(unsigned char *)buf_end-len;
   buf_size-=len;
   buf_end-=len;
   Fread(han,len,autocode);
   Fclose(han);
   autolen=len;
   autoda=1;
   return(1);
}
