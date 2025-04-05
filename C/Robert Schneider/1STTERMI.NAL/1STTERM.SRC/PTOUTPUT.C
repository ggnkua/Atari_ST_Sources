#define STRING01 "Protokoll-Datei"
#define STRING03 "--- mehr ---"
#define STRING04 "--- Ende ---"
#define STRING06 "\15\12\15\12 Taste = Drucker ein \\ aus \15\12 Esc = Ausduck abbrechen\15\12"
#define STRING07 "\15\12 Drucker aus "
#define STRING08 "\15\12 Drucker ein "

#include <osbind.h>
#include <megatadd.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

overlay "out_put"

extern char *ptadr();

/* Dialogbox fr Mitschriftselektion */
do_jornal()
{
   GRECT box;
   char name[20];
   char pfad[80];
   int exit;

   if(!jo_disk)
      undo_objc(jornaldi,JO__DISK,SELECTED);
   else
      do_objc(jornaldi,JO__DISK,SELECTED);
   if(!jo_screen)
      undo_objc(jornaldi,JOSCREEN,SELECTED);
   else
      do_objc(jornaldi,JOSCREEN,SELECTED);
   if(!jo_print)
      undo_objc(jornaldi,JO_PRINT,SELECTED);
   else
      do_objc(jornaldi,JO_PRINT,SELECTED);
   if(!jo_buff)
      undo_objc(jornaldi,JOBUFFER,SELECTED);
   else
      do_objc(jornaldi,JOBUFFER,SELECTED);

   objc_xywh(mainmenu,buf,&box);
   exit=hndl_dial(jornaldi,0,box);

   if(exit==JO____OK)
   {
      jo_disk     = is_objc(jornaldi,JO__DISK,SELECTED);
      jo_print    = is_objc(jornaldi,JO_PRINT,SELECTED);
      jo_screen   = is_objc(jornaldi,JOSCREEN,SELECTED);
      jo_buff     = is_objc(jornaldi,JOBUFFER,SELECTED);
   }

   if(jo_disk&&!jo_handle)
   {
      pfad[0]=name[0]=0;
      if(!file_select(STRING01,pfad,name,"*.*"))
         jo_disk=0;
      else
      {
         strcat(pfad,name);
         strcpy(jo_name,pfad);
      }
   }

   undo_objc(jornaldi,exit,SELECTED);

   if(!jo_disk)
   {
      if(jo_handle>5)
      {
         Fclose(jo_handle);
         jo_handle=0;
      }
      return;
   }
   
   if(jo_handle>5)                 /* File besteht schon */
      return;

   jo_handle = Fopen(jo_name,2);

   if(jo_handle<6)
      jo_handle = Fcreate(jo_name,0);

   if(jo_handle<6)
   {
      form_alert(1,ALNOTOPEN);
      return;
   }

   Fseek(0l,jo_handle,2);
}


out_screen(offset,size,firstflag,endflag)
char *offset;
long size;
int endflag,firstflag;
{
   char *pointer, *end;
   int a,*count;

   pointer = offset;
   end = offset+size;
   
   if(firstflag)
   {
      hide_mouse();
      /* ersten Bildschirm aufbauen  */
      clr_window();
      count=&ycur;
   }
   else
      count=&w_up;

   w_up = 0;

   while(1)
   {
      do
      {
         out_c(*pointer++);
         if(pointer>end)
         {
            if(endflag)
            {
               out_send();
               show_mouse();
               return(0);
            }
            return(1);
         }
      }
      while(*count<max_ycur);
      count=&w_up;
      a=out_smehr();
      if(!a)
      {
         show_mouse();
         return(0);
      }
      if(a==2)       /* bei Return */
         w_up = max_ycur -1;
      else           /* bei Space */
         w_up = 0;
   }
}

out_smehr()
{
   int a,b;

   if(mouse_but==1)
      return(2);
   xcur=0;
   out_s(STRING03);
   xcur=0;
   while(mouse_but==2);	
   while(1)
   {
      while(!Bconstat(2))
         if(mouse_but)
            goto Ende;
      switch(a=Bconin(2))
      {
        
         case 03  :  
         case 113 :  
         case 81  :  return(0);
         case 13  :  
         case 32  :  goto Ende;
      }
   }
Ende:
   out_s(space0-15);
   xcur=0;
   while(Bconstat(2))
      Bconin(2);
   if(mouse_but==3)
      return(0);
   if(a==32)
      return(1);
   return(2);
}

out_send()
{
   if(ycur!=max_ycur)
      out_s(cr_lf);
   out_s(STRING04);
   while(mouse_but);
   while(!Bconstat(2))
      if(mouse_but)
         return(0);
   Bconin(2);
}

static int devhan;


/* Dialogbox fr Ausgabeselektion */
do_output()
{
   int exit;
   GRECT box;
   char  name[40];

   objc_xywh(mainmenu,buf,&box);

   exit=hndl_dial(outputdi,0,box);
   undo_objc(outputdi,exit,SELECTED);

   switch(exit)
   {
      case OU__DISK :
                     such1[0]=name[0]=0;
		     PFEIL;
                     if(!file_select("Ausgabe-Datei",such1,name,""))
                        return(0);
                     else
                        strcat(such1,name);
		     return(6);
      case OU_PRINT :return(3);

      case OUSCREEN :return(1);
      default       :return(0);
   }
}

/* DISK__DI Dialogbox Steuerung */

do_disk(string1,string2)
char *string1;
char *string2;
{
   int exit;
   GRECT box;

   objc_xywh(mainmenu,buf,&box);
   strcpy(OB_SPEC(disk__di,DI__LOAD),string1);
   strcpy(OB_SPEC(disk__di,DI__SAVE),string2);
   exit=hndl_dial(disk__di,0,SMXY,SMWH);
   undo_objc(disk__di,exit,SELECTED);

   switch(exit)
   {
      case DI__LOAD :return(1);
      case DI__SAVE :return(2);
   }
return(0);
}



do_print(device,string,length,first,end)
char *string;
int device,first,end;
long length;
{
   long len;
   int a;
   char cr_lf[4];


   while(Bconstat(2))
      Bconin(2);

   switch(device)
   {
      case 1   :  return(out_screen(string,length,first,end));

      case 3   :  if(first)
                  {
                     hide_mouse();
                     clr_window();
                     out_s(STRING06);
                     show_mouse();
                  }
                  TASSE;
                  for(len=0;len<length;len++)
                  {
                     while(!Cprnos())
                     {
                        if(Bconstat(2))
                        {
                           a=Bconin(2);
                           PFEIL;
                           if(a==27)
                              return(0);
                           hide_mouse();
                           out_s(STRING07);
                           show_mouse();
                           while(!Bconstat(2))
                              if(mouse_but==3)
                                 return(0);
                           a=Bconin(2);
                           if(a==27)
                              return(0);
                           hide_mouse();
                           out_s(STRING08);
                           show_mouse();
                           TASSE;
                        }
                        if(mouse_but==3)
                        {
                           PFEIL;
                           return(0);
                        }
                     }
                     Cprnout(string[len]);
                  }
                  PFEIL;
                  if(end)
                  {
                     hide_mouse();
                     clr_window(wi_han1);
                     show_mouse();
                     return(0);
                  }
                  return(1);

      case 6:     if(first)
                  {
                     devhan=Fopen(such1,2);
                     if(devhan>5)
                        Fseek(0l,devhan,2);
                     else
                        devhan=Fcreate(such1,0);    

                     if(devhan<6)
                     {
                        brain_alert(1,ALNOTOPEN);
                        return(0);
                     }
		     TASSE;
                  }
                  if(Fwrite(devhan,length,string)!=length)
                  {
                     PFEIL;
                     brain_alert(1,ALWRIERR);
                     Fclose(devhan);
                     return(0);
                  }
                  PFEIL;
                  if(end)
                     Fclose(devhan);
                  return(!end);
   }
}
