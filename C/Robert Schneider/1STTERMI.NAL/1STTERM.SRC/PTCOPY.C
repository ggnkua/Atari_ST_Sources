#include <osbind.h>
#include <gemobdef.h>

#include "ptcopy.h"

#define write(a,b,c) Flopwr(a,0l,0,c,b,0,1)

extern char *ptadr();
extern OBJECT **load_rsrc();

extern int vdi_handle;

char fbuf[9216];
char *buffer;
long momser;
char *track;
char *snm,*sns;

OBJECT *rsc;

main()
{
   int a,exit;
   long b;
   char s[100];
   OBJECT **adr;

   aes_init();

   open_vwork();

   graf_mouse(0,0l);

   adr=load_rsrc("PTCOPY.RSC");
   if(!adr)
      Pterm0();
   rsc=adr[PBCOPY];

   buffer=(char *)Malloc(370000l);

   if(!buffer)
   {
      form_alert(1,"[3][Nicht genug Chips in der Kiste !][Abgang]");
      Pterm0();
   }
   asm
   {
      ANDI.L   #0XFFFFFFFE,buffer(A4)
   }

   form_alert(1,"[1][1st Terminal|Master-Toast||in||Toaster A !][Jau]");

   track=ptadr(rsc,TRACKNR,0);
   sns=ptadr(rsc,FIRSTSNR,0);
   snm=ptadr(rsc,MOMSNR,0);

   graf_mouse(2);
   for(a=0,b=0;a<80;a++,b+=4608l)
   {
      exit=Floprd((buffer+b),0l,0,1,a,0,9);
      if(exit)
      {
         graf_mouse(0);
         sprintf(s,"[3][Read-Error Nr. %d auf Track %d][Abgang]",exit,a);
         form_alert(1,s);
         Pterm0();
      }
   }
   graf_mouse(0);

   box_draw(rsc,0,0,10,10);

   do
   {
      exit=form_do(rsc,FIRSTSNR);
      if(exit==CANCEL)
         break;

      momser=atoi(sns);
      sprintf(snm,"%ld",momser);
      objc_update(rsc,FIRSTSNR,0);
      objc_update(rsc,MOMSNR,0);

      if(format())
      {
         if(ramtodisk())
         {
            momser++;
         }
      }

      sprintf(sns,"%ld",momser);
      sprintf(snm,"%ld",momser);
      objc_update(rsc,FIRSTSNR,0);
      objc_update(rsc,MOMSNR,0);
      Cconout(7);
      undo_objc(rsc,exit,SELECTED);
      objc_update(rsc,exit,0);
   }while(1);

   box_undraw(rsc,0,0,10,10);

   v_clsvwk(vdi_handle);
   appl_exit();
}


format()
{
   int a,c,b,d;

   for(a=0;a<9216;fbuf[a++]=0);

   for(a=0;a<80;a++)
   {
      sprintf(track,"Formatiere Track : %2d",a);
      objc_draw(rsc,TRACKNR,0,0l,0x2800190l);

      if(xbios(10,fbuf,0l,0,9,a,0,1,0x87654321l,0xe5e5))
      {
         b=form_alert(1,"[2][Formatierfehler !| Wiederholen ?][Ja|Nein]");
         if(b==1)
         {
            a--;
            continue;
         }
         else
         {
            return(0);
         }
      }
   }
   for(a=0;a<512;fbuf[a++]=0);
   Protobt(fbuf,0x00081665l,2,0);
   fbuf[19]=(720&0xff);
   fbuf[20]=(720>>8)&0xff;
   fbuf[24]=9;
   write(fbuf,0,1);
   for(a=0;a<512;fbuf[a++]=0);
   fbuf[0]=0xf7;
   fbuf[1]=fbuf[2]=0xff;
   write(fbuf,0,7);
   write(fbuf,0,2);
   sprintf(fbuf,"1ST_TERMBW\010");
   write(fbuf,1,3);
   return(1);
}

ramtodisk()
{
   int a,exit;
   long b;
   char s[100];

   for(a=0,b=0;a<80;a++,b+=4608)
   {
      sprintf(track,"Schreibe Track : %2d",a);
      objc_update(rsc,TRACKNR,0);

      exit=Flopwr((buffer+b),0l,0,1,a,0,9);
      if(exit)
      {
         sprintf(s,"[3][Write-Error Nr. %d auf Track %d][Abgang]",exit,a);
         form_alert(1,s);
         return(0);
      }
   }
   return(1);
}


