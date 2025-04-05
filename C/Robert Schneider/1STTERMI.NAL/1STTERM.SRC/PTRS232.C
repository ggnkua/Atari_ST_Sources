overlay "rs232"

#include <osbind.h>
#include "ptvars.h"
#include <megatadd.h>

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

#define Auxis() while(!Cauxis()) if(mouse_but==3) return;

extern char *ptadr();

/*  Ausgabe der RS-232 Dialogbox  */

do_rs232()
{
   GRECT box;
   int exit,a,b;
   long sl;
   int ob,nb;

   objc_xywh(mainmenu,buf,&box);
   ob=set_rs232_obj();
   box_draw(rs232_di,box);
   bup(ob,ob);
   do
   {
      while(mouse_but!=1&&!Bconstat(2));
      if(mouse_but!=1)
      {
         if((char)Bconin(2)==13)
         {
            exit=RS__OKAY;
            do_objc(rs232_di,exit,SELECTED);
            objc_draw(rs232_di,exit,0,SXY,SWH);
            break;
         }
      }
      exit=objc_find(rs232_di,0,8,mouse_x,mouse_y);
      switch(exit)
      {
         case RSBAUDUP  :  
            if(baud>1) baud--; goto dbaud;
         case RSBAUDDN  :
            if(baud<256) baud++; 
dbaud:
            for(b=RS75,a=256;a>0;a>>=1,b--)
            {
               if(baud&a)
               {
                  nb=b;
                  break;
               }
            }
            if(baud&(a>>1))
               nb++;
            ob=bup(nb,ob);
            if(!(Kbshift(-1)&3))
               while(mouse_but);
            break;

#ifdef COLOR
         case RS_SHAKE : do_rs_slide(RS_SHAKE,RS_SHAKB,RS_SHAKR,24l);
                         break;

         case RSPARITY : do_rs_slide(RSPARITY,RSPARITB,RSPARITR,16l);
                         break;

         case RS__DATA : do_rs_slide(RS__DATA,RS__DATB,RS__DATR,24l);
                         break;

         case RS__STOP : do_rs_slide(RS__STOP,RS__STOB,RS__STOR,16l);
                         break;
#else
         case RS_SHAKE : do_rs_slide(RS_SHAKE,RS_SHAKB,RS_SHAKR,48l);
                         break;

         case RSPARITY : do_rs_slide(RSPARITY,RSPARITB,RSPARITR,32l);
                         break;

         case RS__DATA : do_rs_slide(RS__DATA,RS__DATB,RS__DATR,48l);
                         break;

         case RS__STOP : do_rs_slide(RS__STOP,RS__STOB,RS__STOR,32l);
                         break;
#endif

         case RSCANCEL :
         case RS__OKAY :
            a=exit;
	    do_objc(rs232_di,exit,SELECTED);
            objc_draw(rs232_di,exit,0,SXY,SWH);
            while(mouse_but==1&&
                  (exit=objc_find(rs232_di,8l,mouse_x,mouse_y))==RS__OKAY);
            if(exit!=a)
            {
               undo_objc(rs232_di,a,SELECTED);
               objc_draw(rs232_di,a,0,SXY,SWH);
               exit=0;
            }
            break;

         default       :   
            if(exit<=RS75&&exit>=RS19200)
            {
               baud=1<<(exit-RS19200);
               ob=bup(exit,ob);
            }
            break;
      }
   }while(exit!=RSCANCEL&&exit!=RS__OKAY);

   if(exit==RSCANCEL)
      set_rs232_obj();
   else
      set_obj_rs232();

   box_undraw(rs232_di,box);
   undo_objc(rs232_di,exit,SELECTED);
   return;
}

bup(nb,ob)
int nb,ob;
{
   long a;
   char *p1=ptadr(rs232_di,RSBAUDTX,1);
   char p[10];

   a=1920000l/baud;

   sprintf(p,"%8ld ",a);
   p[8]=p[7];
   p[7]=p[6];
   p[6]='.';

   if(strcmp(p,p1))
   {
      strcpy(p1,p);
      objc_draw(rs232_di,RSBAUDTX,0,SXY,SWH);
   }

   if(nb!=ob)
   {
      undo_objc(rs232_di,ob,SELECTED);
      do_objc(rs232_di,nb,SELECTED);
      objc_draw(rs232_di,RS19200-1,2,SXY,SWH);
   }
   return(nb);
}
            

do_rs_slide(sl,ib,rb,size)
int sl,ib,rb;
long size;
{
   long lg;
   GRECT box;

   objc_xywh(rs232_di,sl,&box);
   OB_FLAGS(rs232_di,sl)|=HIDETREE;
   objc_draw(rs232_di,rb,3,
             box.g_x-2,box.g_y-2,box.g_w+4,box.g_h+4);
   lg=(long)graf_slidebox(rs232_di,ib,sl,1);

#ifdef COLOR
   lg=size*lg/1000l+4;
   OB_Y(rs232_di,sl)=lg&0xfff8;
#else
   lg=size*lg/1000l+8;
   OB_Y(rs232_di,sl)=lg&0xfff0;
#endif

   OB_FLAGS(rs232_di,sl)&=(~HIDETREE);
   objc_draw(rs232_di,sl,1,SXY,SWH);
}
/* Konverter der Dialogbox in Variablen */


set_obj_rs232()
{
#ifdef COLOR
   xmode  = OB_Y(rs232_di,RS_SHAKE)>>3;
   parity = OB_Y(rs232_di,RSPARITY)>>3;
   stop   = (OB_Y(rs232_di,RS__STOP)>>3)+1;
   data   = (OB_Y(rs232_di,RS__DATA)>>3)+5;
#else
   xmode  = OB_Y(rs232_di,RS_SHAKE)>>4;
   parity = OB_Y(rs232_di,RSPARITY)>>4;
   stop   = (OB_Y(rs232_di,RS__STOP)>>4)+1;
   data   = (OB_Y(rs232_di,RS__DATA)>>4)+5;
#endif
   set_config();
}

/* Konverter der Variablen in die Dialogbox */

set_rs232_obj()
{
   int a,b;
   int ob;

   if(baud<1||baud>256)
   {
      ob=RS300;
      baud=64;
   }
   else
   {
      for(a=256,b=RS75;a>0;a>>=1,b--)
      {
         if(baud&a)
         {
            ob=b; 
            break;
         }
      }
      if(baud&(a>>1))
         ob++;
   }
   for(a=RS19200;a<=RS75;a++)
   {
      if(a==ob)
         do_objc(rs232_di,a,SELECTED);
      else
         undo_objc(rs232_di,a,SELECTED);
   }
     
   if(xmode<0||xmode>3)
      xmode=0;
#ifdef COLOR
   OB_Y(rs232_di,RS_SHAKE) = xmode<<3;
   if(parity<0||parity>2)
      parity=0;
   OB_Y(rs232_di,RSPARITY) = parity<<3;
   if(stop<1||stop>3)
      stop=1;
   OB_Y(rs232_di,RS__STOP) = (stop-1)<<3;
   if(data<5||data>8)
      data=8;
   OB_Y(rs232_di,RS__DATA) = (data-5)<<3;
#else
   OB_Y(rs232_di,RS_SHAKE) = xmode<<4;
   if(parity<0||parity>2)
      parity=0;
   OB_Y(rs232_di,RSPARITY) = parity<<4;
   if(stop<1||stop>3)
      stop=1;
   OB_Y(rs232_di,RS__STOP) = (stop-1)<<4;
   if(data<5||data>8)
      data=8;
   OB_Y(rs232_di,RS__DATA) = (data-5)<<4;
#endif
   set_config();

   return(ob);
}

set_config()
{
   long save;

   ucr=0x0080;
   switch(parity)    /* 0=no,1=even,2= odd */
   {
      case 2 : ucr|=0x0002;
      case 1 : ucr|=0x0004; break;
   }

   switch(stop)
   {
      case  1  :  ucr|=0x0008; break;
      case  3  :  ucr|=0x0008; 
      case  2  :  ucr|=0x0010; break;
   }

   switch(data)
   {
      case 7 : ucr|=0x0020; break;
      case 6 : ucr|=0x0040;
      case 5 : ucr|=0x0020; break;
   }

   Rsconf(1,(xmode==3)? 4 : xmode,ucr,-1,-1,-1);
   save=Super(0l);
   *((char *)0xFFFA25l)=(baud&0xff);
   Super(save);
}



vt_what(c)
char c;
{
   int a,b,x,y;
   char p1,p2;

   x=xcur; y=ycur;

   switch(c)
   {
      case 'A' :  if(y>0) y--; break;

      case 'B' :  if(y<max_ycur) y++; break;

      case 'C' :  if(x<max_xcur) x++; break;

      case 'D' :  if(x>0) x--; break;

      case 'E' :  clr_window();
      case 'H' :  set_xy_cur(wi_han1); x=y=0; break;

      case 'I' :  (y>0)? y-- : win_down();
                  break;

      case 'J' :  for(ycur++;ycur<=max_ycur;ycur++)
                     clr_line(ycur);
                  ycur=y;
      case 'K' :  a=vtwrap;
                  vtwrap=0;
                  out_s(space80+xcur);
                  vtwrap=a;
                  break;

      case 'L' : 
      case 'M' :  a=s_up_y;
                  x=0;
                  if(y==max_ycur)
                  {
                     clr_line(y);
                     break;
                  }
#ifdef COLOR
                  s_up_y += ycur*(screenline/160);
#else
                  s_up_y += ycur*(screenline/80);
#endif
                  max_ycur -= ycur;
                  if(c=='M')
                     win_up();
                  else
                     win_down();
                  max_ycur += ycur;
                  s_up_y=a;
                  break;

      case 'Y' :  Auxis();
                  p2=Cauxin()-32; if(p2<0) p2=0;
                  Auxis();
                  p1=Cauxin()-32; if(p1<0) p1=0;
                  x=(p1<max_xcur)? p1 : max_xcur;
                  y=(p2<max_ycur)? p2 : max_ycur;
                  break;
      case 'd' :  for(ycur=0;ycur<y;ycur++)
                     clr_line(ycur);
                  xcur=0;
                  out_s(space0-x);
                  break;

      case 'e' :  onli_curs=1; break;

      case 'f' :  onli_curs=0; break;

      case 'j' :  vtoldx=x; vtoldy=y; break;

      case 'k' :  x=vtoldx; y=vtoldy; break;

      case 'l' :  x=0 ; clr_line(y) ; break;

      case 'o' :  xcur=0 ; out_s(space0-x-1); break;

      case 'p' :  vtrevers=1; break;
      case 'q' :  vtrevers=0; break;
      case 'v' :  vtwrap=1; break;
      case 'w' :  vtwrap=0; 
   }
   xcur=x;
   ycur=y;
}
