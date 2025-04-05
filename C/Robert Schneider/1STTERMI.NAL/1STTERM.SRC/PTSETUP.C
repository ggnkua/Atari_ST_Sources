#define STRING01 "Parameter laden"
#define STRING02 "Parameter abspeichern"

#define FORM01 "[2][Altes Table Åbernehmen|oder|neues Table einladen ?][Neu|Alt]"  
#define FORM02 "[2][|Neue Parameter einladen ?|][Ja|Nein]"
#define FORM03 "[2][Disketten-Mitschrift:||Datei ist schon vorhanden !||Neue Daten :][AnhÑngen|öberschreiben]"
static char FORM04[]= "[1][Dateinamenendung wurde auf||.PAR||geÑndert !][OK]";
#define FORM06 "[2][Parameterdatei existiert schon !][öberschreiben|Abbruch]"
#define FORM07 "[2][|Parameter abspeichern ?|][Ja|Nein]"

overlay "setup"

#include <osbind.h>
#include <megatadd.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

extern char *index(), *rindex();

/*  Ausgabe der Setup-Dialogbox  */

do_setup()
{
   GRECT box;
   int exit;

   objc_xywh(mainmenu,buf,&box);
   set_setup_obj();
   exit=hndl_dial(setup_di,0,box);
   if(exit==SECANCEL)
      set_setup_obj();
   else
      set_obj_setup();
   undo_objc(setup_di,exit,SELECTED);
}

/* Konverter der Dialogbox in Variablen */


set_obj_setup()
{
   if(is_objc(setup_di,HAYESAUS,SELECTED))
   {
      OB_STATE(mainmenu,MN_MODEM)|=DISABLED;
      modemon=0;
   }
   else
   {
      OB_STATE(mainmenu,MN_MODEM)&=(~DISABLED);
      modemon=1;
   }
   
   duplex=echo=0;

   if(is_objc(setup_di,SEPAGEON,SELECTED)) duplex=1;
   if(is_objc(setup_di,SE_LOCON,SELECTED)) echo=1;

   lf_disk = lf_screen = lf_print = lf_rs232 = 0;

   if(is_objc(setup_di,SELFDISK,SELECTED)) lf_disk=1;
   if(is_objc(setup_di,SELFSCRE,SELECTED)) lf_screen=1;
   if(is_objc(setup_di,SELFPRIN,SELECTED)) lf_print=1;
   if(is_objc(setup_di,SELFRS23,SELECTED)) lf_rs232=1;

}

/* Konverter der Variablen in die Dialogbox */

set_setup_obj()
{

   undo_objc(setup_di,SELFPRIN,SELECTED);
   undo_objc(setup_di,SELFSCRE,SELECTED);
   undo_objc(setup_di,SELFDISK,SELECTED);
   undo_objc(setup_di,SELFRS23,SELECTED);

   undo_objc(setup_di,SEPAGEOF,SELECTED);
   undo_objc(setup_di,SEPAGEON,SELECTED);

   undo_objc(setup_di,SE_LOCON,SELECTED);
   undo_objc(setup_di,SE_LOCOF,SELECTED);

   undo_objc(setup_di,HAYESEIN,SELECTED);
   undo_objc(setup_di,HAYESAUS,SELECTED);

   switch(modemon)
   {
      case 1 : do_objc(setup_di,HAYESEIN,SELECTED);
               break;
      default: do_objc(setup_di,HAYESAUS,SELECTED);
               modemon=0;
               break;
   }

   switch(duplex)
   {
      case 1 : do_objc(setup_di,SEPAGEON,SELECTED); break;
      default: do_objc(setup_di,SEPAGEOF,SELECTED); duplex=0; break;
   }

   switch(echo)
   {
      case 1 : do_objc(setup_di,SE_LOCON,SELECTED); break;
      default: do_objc(setup_di,SE_LOCOF,SELECTED); echo=0; break;
   }
   if(lf_print)
      do_objc(setup_di,SELFPRIN,SELECTED);
   if(lf_screen)
      do_objc(setup_di,SELFSCRE,SELECTED);
   if(lf_disk)
      do_objc(setup_di,SELFDISK,SELECTED);
   if(lf_rs232)
      do_objc(setup_di,SELFRS23,SELECTED);

}

do_transfer()
{
   GRECT box;
   int exit;

   objc_xywh(mainmenu,buf,&box);
   set_transfer_obj();
   exit=hndl_dial(transfer_di,0,box);
   if(exit==TRCANCEL)
      set_transfer_obj();
   else
      set_obj_transfer();
   undo_objc(transfer_di,exit,SELECTED);
}

/* Konverter der Dialogbox in Variablen */


set_obj_transfer()
{
   int exit;

   if(is_objc(transfer_di,TRBINARY,SELECTED)) transfer=0;
   if(is_objc(transfer_di,TR_ASCII,SELECTED)) transfer=1;
   if(is_objc(transfer_di,TR_ASCID,SELECTED))
   {
      if(transfer!=2)
      {
         transfer=2;
         if(!asc_loaded)
            get_own(1);
      }
   }
   if(is_objc(transfer_di,TR_OWNPR,SELECTED))
   {
      if(transfer!=3)
      {
         if(own_loaded)
         {
            if(brain_alert(1,FORM01)==1)
               get_own(0);
         }
         else
            get_own(0);
         transfer=3;
      }
   }

   if(is_objc(transfer_di,TR___OFF,SELECTED)) mode=0;
   if(is_objc(transfer_di,TR__XMOD,SELECTED)) mode=1;
   if(is_objc(transfer_di,TR___1ST,SELECTED)) mode=3;
   if(is_objc(transfer_di,TR_KERMI,SELECTED))
   {
      mode=2;
      do_redraw();
      undo_objc(kermitdi,KE_DEB_0,SELECTED);
      undo_objc(kermitdi,KE_DEB_1,SELECTED);
      undo_objc(kermitdi,KE_DEB_2,SELECTED);
      undo_objc(kermitdi,KE_FILON,SELECTED);
      undo_objc(kermitdi,KE_FILOF,SELECTED);
      undo_objc(kermitdi,KE_IMAON,SELECTED);
      undo_objc(kermitdi,KE_IMAOF,SELECTED);

      switch(debug)
      {
         case 1 : do_objc(kermitdi,KE_DEB_1,SELECTED); break;
         case 2 : do_objc(kermitdi,KE_DEB_2,SELECTED); break;
         default: do_objc(kermitdi,KE_DEB_0,SELECTED); debug=0; break;
      }
      switch(filnamcnv)
      {
         case 1 : do_objc(kermitdi,KE_FILON,SELECTED); break;
         default: do_objc(kermitdi,KE_FILOF,SELECTED); filnamcnv=0; break;
      }
      switch(image)
      {
         case 1 : do_objc(kermitdi,KE_IMAON,SELECTED); break;
         default: do_objc(kermitdi,KE_IMAOF,SELECTED); image=0; break;
      }
      exit=hndl_dial(kermitdi,0,0,0,0);
      undo_objc(kermitdi,exit,SELECTED);
      if(exit==KE__OKAY)
      {
         if(is_objc(kermitdi,KE_DEB_0,SELECTED))   debug=0;
         if(is_objc(kermitdi,KE_DEB_1,SELECTED))   debug=1;
         if(is_objc(kermitdi,KE_DEB_2,SELECTED))   debug=2;
         if(is_objc(kermitdi,KE_FILON,SELECTED))   filnamcnv=1;
         if(is_objc(kermitdi,KE_FILOF,SELECTED))   filnamcnv=0;
         if(is_objc(kermitdi,KE_IMAON,SELECTED))   image=1;
         if(is_objc(kermitdi,KE_IMAOF,SELECTED))   image=0;
      }
   }
}

/* Konverter der Variablen in die Dialogbox */

set_transfer_obj()
{
   undo_objc(transfer_di,TRBINARY,SELECTED);
   undo_objc(transfer_di,TR_ASCII,SELECTED);
   undo_objc(transfer_di,TR_ASCID,SELECTED);
   undo_objc(transfer_di,TR_OWNPR,SELECTED);

   undo_objc(transfer_di,TR___OFF,SELECTED);
   undo_objc(transfer_di,TR___1ST,SELECTED);
   undo_objc(transfer_di,TR__XMOD,SELECTED);
   undo_objc(transfer_di,TR_KERMI,SELECTED);


   switch(transfer)
   {
      case 1 : do_objc(transfer_di,TR_ASCII,SELECTED); break;
      case 2 : do_objc(transfer_di,TR_ASCID,SELECTED); break;
      case 3 : do_objc(transfer_di,TR_OWNPR,SELECTED); break;
      default: do_objc(transfer_di,TRBINARY,SELECTED); transfer=0; break;
   }
   switch(mode)
   {
      case 1 : do_objc(transfer_di,TR__XMOD,SELECTED); break;
      case 2 : do_objc(transfer_di,TR_KERMI,SELECTED); break;
      case 3 : do_objc(transfer_di,TR___1ST,SELECTED); break;
      default: do_objc(transfer_di,TR___OFF,SELECTED); mode=0; break;
   }

}

load_para(how)
int how;
{
   int handle;
   long len;
   char pfad[80],name[80];
   register int *i , *i2, a;
   if(how)
   {
      handle=Fopen("1ST_TERM.PAR",0);
      if(handle<6)
         return(0);
   }
   else
   {
      pfad[0]=name[0]=0;
      if(!file_select(STRING01,pfad,name,"*.PAR"))
         return(0);
      do_redraw();
      strcat(pfad,name);
      handle=Fopen(pfad,0);
      if(handle<6)
         return(0);
      if(brain_alert(1,FORM02)==2)
         return(0);
   }

   TASSE;
   Fread(handle,82l,box_space);
   i=(int *) box_space;
  
   baud =    *i++;
   xmode =   *i++;
   data =    *i++;
   stop =    *i++;
   parity =  *i++;
   transfer = *i++;
   mode =    *i++;
   modemon = *i++;
   duplex =  *i++;
   echo =    *i++;
   lf_screen = *i++;
   lf_rs232 = *i++;
   lf_disk = *i++;
   lf_print = *i++;
   bremser = *i++;
   debug = *i++;
   filnamcnv = *i++;
   image = *i++;
   jo_disk = *i++;
   jo_screen = *i++;
   jo_print = *i++;
   for(a=0,i2=(int *)jo_name;a<15;a++)
      *i2++ = *i++;
   jo_buff   = *i++;
   online    = *i++;
   onli_vt52 = *i++;
   onli_curs = *i++;
   profibox  = *i++;
   Fclose(handle);

   jo_name[29]=0;
   if(bremser>600) bremser=600;
   if(bremser<0) bremser=0;

   switch(modemon)
   {
      case  1  :  OB_STATE(mainmenu,MN_MODEM)&=(~DISABLED); break;
      default  :  modemon=0; OB_STATE(mainmenu,MN_MODEM)|=DISABLED; break;
   }

   PFEIL;

   if(jo_disk)
   {
      if(file_da(jo_name)&&brain_alert(1,FORM03)==1)
      {
         jo_handle=Fopen(jo_name,1);
         if(jo_handle<6)
            jo_diskwrong();
         else
            Fseek(0l,jo_handle,2);
      }
      else
      {
         jo_handle=Fcreate(jo_name,0);
         if(jo_handle<6)
            jo_diskwrong();
      }
   }

   if(jo_print)
   {
      if(!Cprnos())
         jo_printwrong();
   }

   set_rs232_obj();
}

save_para()
{
   int handle;
   long len;
   char pfad[80],name[80];
   char *p;
   register int  *i,*i2,a;


   pfad[0]=name[0]=0;
   if(!file_select(STRING02,pfad,name,"*.PAR"))
      return(0);
   do_redraw();
   p=rindex(name,'.');
   if(!p||strcmp(p,".PAR"))
   {
      strcat(name,".PAR");
      brain_alert(1,FORM04);
   }

   strcat(pfad,name);

   if((handle=Fcreate(pfad,0))<6)
      return(0);

   TASSE;
   i=(int *) box_space;
   *i++ =baud;
   *i++ =xmode;
   *i++ =data;
   *i++ =stop;
   *i++ =parity;
   *i++ =transfer;
   *i++ =mode;
   *i++ =modemon;
   *i++ =duplex;
   *i++ =echo;
   *i++ =lf_screen;
   *i++ =lf_rs232;
   *i++ =lf_disk;
   *i++ =lf_print;
   *i++ =bremser;
   *i++ =debug;
   *i++ =filnamcnv;
   *i++ =image;
   *i++ =jo_disk;
   *i++ =jo_screen;
   *i++ =jo_print;
   for(a=0,i2=(int*) jo_name;a<15;a++)
      *i++ = *i2++;
   *i++ =jo_buff;
   *i++ =online;
   *i++ =onli_vt52;
   *i++ =onli_curs;
   *i++ =profibox;
   Fwrite(handle,82l,box_space);
   Fclose(handle);
   PFEIL;
}

file_da(name)
char *name;
{
   char dta[44];

   Fsetdta(dta);
   if(Fsfirst(name,0xff))
      return(0);
   else
      return(1);
}

para_disk()
{
   int what;

   what=do_disk(STRING01,STRING02);
   do_redraw();

   if(what==1)
   {
      load_para(0);
      return(0);
   }

   if(what==2)
      save_para();
   return(1);
}
