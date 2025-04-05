#define STRING01 "Xmodem"
#define STRING02 "Senden"
#define STRING03 "Block ist OK !"
#define STRING04 "Block fehlerhaft !"
#define STRING05 "Empfangen"
#define STRING06 "Sender ist zu langsam !"
#define STRING07 "öbertragungsfehler bei Blocknummer !"
#define STRING08 "Sender will Block erneut senden !"
#define STRING09 "Zu wenig Zeichen empfangen !"
#define STRING10 "Falsche Blocknummer empfangen :%2d"
#define STRING11 "Zu wenig Zeichen empfangen !"
#define STRING12 "PrÅfsumme fehlt !"
#define STRING13 "PrÅfsumme ist falsch"
#define STRING15 "Start bei Block (Nr 1 - %d)"

#define FORM01 "[2][EmpfÑnger meldet sich nicht|empfangsbereit !][Abbruch|Wiederholung]"
#define FORM02 "[2][10. Versuch fehlgeschlagen!][Abbruch|Wiederholung]"
#define FORM03 "[1][ öbertragung wurde von|EmpfÑnger abgebrochen !][OK]"
#define FORM04 "[1][EmpfÑnger hat Empfang nicht|bestÑtigt !][OK]"
#define FORM05 "[1][öbertragung  erfolgreich|beendet !!][OK]"
#define FORM06 "[2][Sender gibt keine|Empfangsaufforderung !][Abbruch|Wiederholung]"
#define FORM07 "[2][öbertragung abbrechen ?][Ja|Nein]"
#define FORM08 "[1][öbertragung  durch|Sender abgebrochen !][OK]"
#define FORM09 "[1][öbertragung abgebrochen !|Block nicht in Reihe !][OK]"
#define FORM10 "[2][öbertragung|ab Dateianfang|oder|ab Blocknummer][Anfang|Block]"
#define FORM11 "[2][Datei besteht schon.|Datei lîschen|oder|Zeichen anhÑngen][Lîschen|AnhÑngen]"

overlay "xmodem"

#include <osbind.h>
#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

#define SOH 0x01
#define EOT 0x04
#define ACK 0x06
#define NAK 0x15
#define CAN 0x18

#ifdef COLOR
   #define VBLSYNC 60
#else
   #define VBLSYNC 71
#endif

extern char *ptadr();
extern long gemdos();

static info_x();
static send_xmodem();
static receive_xmodem();
static wait();
static baudout();
static abflug();


static int end_xmodem;
char *perr,*pblkanz,*pinout,*ptry,*pproname,*pfilnam;


abflug()
{
   int a;

   if(brain_alert(1,FORM07)==1)
   {
      Cauxout(CAN);
      end_xmodem=1;
      return(1);
   }
   return(0);
}

baudout(byte)
char byte;
{
   if(mouse_but==1)
      if(abflug())
         return(-1);
   portc(byte);
   return(byte);
}

wait(sec)
int sec;
{
   register int a;
   for(a=sec * VBLSYNC;a>0;a--)
   {
      if(mouse_but&1)
         if(abflug())
            return(-1);
      if(Cauxis())
         return(Cauxin());
      Vsync();
   }
   return(-1);
}

info_x(string,out)
{
   register char *p;

   if(string!=3)
      Dosound(sound);

   switch(string)
   {
      case 3 : p=STRING03;break;
      case 4 : p=STRING04;break;
      case 6 : p=STRING06;break;
      case 7 : p=STRING07;break;
      case 8 : p=STRING08;break;
      case 9 : p=STRING09;break;
      case 10: p=STRING10;break;
      case 11: p=STRING11;break;
      case 12: p=STRING12;break;
      case 13: p=STRING13;break;
      default: return;
   }
   if(strcmp(perr,p))
   {
      strcpy(perr,p);
      objc_update(proto_di,XM_ERRUP,1);
   }

   if(out)
      baudout(out);

}

send_xmodem(handle,showblock,length)
int handle,showblock;
long length;
{
   int a;
   int word;
   char blocknr;
   int retries=1;
   int load_ok,end;
   long len;
   char checksum;
   char buffer[128];

   end=end_xmodem=0;
   do
   {
      word=wait(60);
      if(end_xmodem)
         return(0);
      if(word!=NAK)
         if(brain_alert(2,FORM01)==1)
            return(0);

   }while(word!=NAK);

   blocknr=1;
   load_ok=1;
   do
   {
      sprintf(ptry,"%3d",retries);
      objc_update(proto_di,XM_TRIES,0);

      if(retries>10)
      {
         Bconout(2,7);
         if(brain_alert(1,FORM02)==1)
         {
            baudout(CAN);
            return(0);
         }
         retries=1;
      }

      if(load_ok)
      {
         load_ok=0;
         len=Fread(handle,128l,buffer);
         length-=len;
         if(len!=128l||length<=0)
            end=1;
      }

      set_number(showblock);
      baudout(SOH);
      baudout(blocknr);
      baudout(~blocknr);
      if(end_xmodem)
         return(0);
      checksum=0;
      for(a=0;a<128;a++)
      {
         if(len>a)
         {
            baudout(buffer[a]);
            checksum+=buffer[a];
         }
         else
            baudout(0);
         if(end_xmodem)
            return(0);
      }
      while(Cauxis())
         Cauxin();
      baudout(checksum);
      word=wait(10);
      switch(word)
      {
         case ACK :  info_x(3,0);
                     blocknr++;
                     showblock++;
                     if(showblock==1000)
                        showblock=0;
                     retries=1;
                     load_ok=1;
                     break;

         case CAN :  return(3);

         default  :  info_x(4,0);
                     retries++;
      }
   if(end_xmodem)
      return(0);
   }while(!end||!load_ok);
   baudout(EOT);
   word=wait(10);
   if(word!=ACK)
      return(4);
   return(5);
}

receive_xmodem(handle)
{
   int a,not_again;
   int word,word2;
   char blocknr=1;
   int  showblock=0;
   int retries=1;
   char checksum;
   char buffer[128];

   end_xmodem=0;

while(1)
{
   a=0;
   do
   {
      baudout(NAK);
      word=wait(10);
      a++;
      if(end_xmodem)
         return(0);      
   }while(a<10&&word<0);

   if(word<0)
      if(brain_alert(2,FORM06)==1)
         return(0);
      else
         continue;

   if(!(word==SOH || word==EOT || word==CAN))
      continue;

   not_again = 1;
   goto sepp;

   while(not_again)
   {
      if(retries>10)
      {
         Bconout(2,7);
         if(brain_alert(1,FORM02)==1)
         {
            baudout(CAN);
            return(0);
         }
         retries=1;
      }
      if(end_xmodem)
         return(0);      

      sprintf(ptry,"%3d",retries);
      objc_update(proto_di,XM_TRIES,0);
      word=wait(10);
sepp:
      if(end_xmodem)
         return(0);      
      switch(word)
      {
         case CAN :
            return(8);

         case EOT :
         {
            baudout(ACK);
            return(5);
         }

         case SOH :
         {
            word=wait(2);
            set_number(showblock+word);
            if(word<0)
            {
               info_x(6,NAK);
               retries++;
               continue;
            }
            word2=wait(2);
            if(word2<0)
            {
               info_x(6,NAK);
               retries++;
               continue;
            }
            if((char)word != (char)~word2)
            {
               info_x(7,NAK);
               retries++;
               continue;
            }

            if((char)word != blocknr)
            {
               if((char)word+1==blocknr)
               {
                  info_x(8,0);
                  for(a=0;a<129;a++)
                  {
                     word=wait(2);
                     if(word<0)
                     {
                        info_x(9,0);
                        retries++;
                        not_again=0;
                        break;
                     }
                     if(end_xmodem)
                        return(0);      
                  }
                  if(!not_again)
                     break;
                  baudout(ACK);
                  continue;
               }
               else
               {
                  while(wait(1)>=0);
                  info_x(10,CAN);
                  return(9);
               }
            }

            checksum=0;
            for(a=0;a<128;a++)
            {
               word=wait(2);
               if(word<0)
               {
                  info_x(11,0);
                  retries++;
                  not_again = 0;
                  break;
               }
               buffer[a]=(char)word;
               checksum+=(char)word;
               if(end_xmodem)
                  return(0);      
            }
            if(!not_again)
               break;
            word=wait(2);
            if(word<0)
            {
               info_x(12,NAK);
               retries++;
               continue;
            }
            if((char)word!=checksum)
            {
               info_x(13,NAK);
               retries++;
               continue;
            }

            info_x(3,ACK);
            blocknr++;
            if(blocknr==0)
               showblock+=256;
            if(showblock==1000)
               showblock=0;
            retries=1;
            Fwrite(handle,128l,buffer);
         }
         break;
      }
   }
}
}

xmodem(what,filename)
char *filename;
{
   int handle;
   int a;
   int showblock,maxblock;
   char *p;
   long length;
   GRECT menbox;

   objc_xywh(mainmenu,buf,&menbox.g_x,&menbox.g_y,&menbox.g_w,&menbox.g_h);

   pinout   = ptadr(proto_di,XM_INOUT,0);
   ptry     = ptadr(proto_di,XM_TRIES,0);
   perr     = ptadr(proto_di,XM___ERR,0);
   pproname = ptadr(proto_di,XMPRONAM,0);
   pfilnam  = ptadr(proto_di,XMFILNAM,0);
   pblkanz  = ptadr(proto_di,XMBLKANZ,0);

   
   showblock = 1;

   strcpy(pfilnam,filename);
   strcpy(pproname,STRING01);
   strcpy(ptry,"1");
   if(what)	
   {
      if((handle=Fopen(filename,0))<6)
         return(brain_alert(1,ALNOTOPEN));
      length=Fseek(0l,handle,2);

      strcpy(pinout,STRING02);
      maxblock=(length/128)+((length&0x7f) ? 1 : 0);
      sprintf(pblkanz,"%3d",maxblock);

      if(brain_alert(1,FORM10)==2)
         do
         { 
            sprintf(ptadr(boxnr_di,BN__TEXT,0),STRING15,maxblock);
            ptadr(boxnr_di,BN____NR,0);
            a = hndl_dial(boxnr_di,BN____NR,menbox);
            undo_objc(boxnr_di,a,SELECTED);
            showblock=atoi(ptadr(boxnr_di,BN____NR,1));  
	    do_redraw(wi_han1);
         }
         while(showblock>maxblock);
	
      if(showblock<1)
         showblock=1;                  
      length -= (showblock-1)*128l;
      Fseek((long)((showblock-1l)*128l),handle,0);
   }
   else
   {
      strcpy(pinout,STRING05);
      strcpy(pblkanz,"???");
      if((handle=Fopen(filename,0))>5)
      {
         if(brain_alert(1,FORM11)==2)
            Fseek(0l,handle,2);
      }
      else
         if((handle=Fcreate(filename,0))<6)
            return(brain_alert(1,ALNOTOPEN));
   }

   box_draw(proto_di,menbox);
   reset_digis();
   while(Cauxis())
      Cauxin();

   a=what? send_xmodem(handle,showblock,length): receive_xmodem(handle);

   Fclose(handle);
   Bconout(2,7);
   switch(a)
   {
      case 3 : brain_alert(1,FORM03); break;
   
      case 4 : brain_alert(1,FORM04); break;

      case 5 : brain_alert(1,FORM05); break;

      case 7 : brain_alert(1,FORM07); break;

      case 8 : brain_alert(1,FORM08); break;
   } 
   box_undraw(proto_di,menbox);
}	
