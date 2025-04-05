#include <osbind.h>
#include <megatadd.h>
#include <gembind.h>

#include "ptvars.h"

#ifdef COLOR
   #include "1STTERMC.H"
#else
   #include "1STTERMM.H"
#endif

asm
{
   OLDMMOVE:   DC.W  0X4E71,0X4E71
   OLDMBUTT:   DC.W  0X4E71,0X4E71
   IRQ_DCD:    DC.W  0X4E71,0X4E71
   IRQ_RI:     DC.W  0X4E71,0X4E71
   IRQ_MENU:   DC.W  0X4E71,0X4E71
   MSX:        DC.W  0X4E71,0X4E71
   MSY:        DC.W  0X4E71,0X4E71
   MB:         DC.W  0X4E71,0X4E71
   MX:         DC.W  0X4E71
   MY:         DC.W  0X4E71
   MX1:        DC.W  0X4E71
   MY1:        DC.W  0X4E71
   MX2:        DC.W  0X4E71
   MY2:        DC.W  0X4E71
   ALERT_AKT:  DC.W  0X4E71,0X4E71
}

mbutton()
{
   asm
   {
MBUTTON:
         MOVEM.L  D0-D7/A1-A6, -(A7)
         MOVE.W   SR, -(A7)
         ORI.W    #0X0700, SR
         MOVE.L   MB(PC), A3
         MOVE.W   D0, (A3)
         ANDI.L   #0X03, D0

         MOVEA.L  ALERT_AKT(PC), A3
         TST.W    (A3)
         BNE      WARWOHLNIX

         MOVEA.L  IRQ_MENU(PC), A3
         TST.W    (A3)
         BNE      DONTPFUSCH

         CMPI.W   #3, D0            ; MEHR ALS ZWEI MAUSKN™PFE GEDRšCKT ?
         BHI      WARWOHLNIX        ; SCHERZKEKS
         TST.W    D0                ; MAUSKNOPF LOSGELASSEN (KEINER GEDRšCKT)
         BEQ      WARWOHLNIX        ; DANN HALT NICHT

         MOVE.W   MY1(PC), D1
         MOVE.W   MY2(PC), D2
         CMP.W    MY(PC), D1
         BHI      WARWOHLNIX
         CMP.W    MY(PC), D2
         BCS      WARWOHLNIX
         ANDI.B   #0XFC, (A0)

         MOVE.W   MX1(PC), D1
         MOVE.W   MX2(PC), D2
         CMP.W    MX(PC), D1
         BHI      DONTPFUSCH
         CMP.W    MX(PC), D2
         BCS      DONTPFUSCH

         MOVEA.L  IRQ_MENU(PC), A3  ; Y IST AUCH IM MENšFELD
         MOVE.W   D0, (A3)          ; MOUSEBUTTONSTATE NACH irq_menu
         BRA      DONTPFUSCH

WARWOHLNIX:
         MOVE.W   (A7)+, SR
         MOVEM.L  (A7)+, D0-D7/A1-A6
         MOVEA.L  OLDMBUTT(PC), A3  ; GEM SOLL AUCH WAS TUN
         JMP      (A3)              ; BETRIEBSSYSTEMROUTINE ZUM WEGSCHMEISSEN
                                    ; VON TASTATUR-PACKETS
DONTPFUSCH:
         MOVE.W   (A7)+, SR
         MOVEM.L  (A7)+, D0-D7/A1-A6
         RTS
   }
}


mmove()
{
   asm
   {
MMOVE:
         MOVE.W   SR, -(A7)
         ORI.W    #0X0700, SR
         MOVEA.L  MSX(PC), A0
         MOVE.W   D0, (A0)
         LEA      MX(PC), A0
         MOVE.W   D0, (A0)
         MOVEA.L  MSY(PC), A0
         MOVE.W   D1, (A0)
         LEA      MY(PC), A0
         MOVE.W   D1, (A0)
         MOVE.W   (A7)+, SR
         MOVEA.L  OLDMMOVE(PC), A0
         JMP      (A0)
   }
}


do_menu(mmgbuf)
int mmgbuf[];
{
   int i;
   int mx,my,eintrag;
   int inbox,intit;
   int tx1,ty1,tx2,ty2;
   int bx1,by1,bx2,by2;
   int ox,oy,ow,oh;

   if((i=find_title())<0)
      return(0);

   tx1=titles[i].x1;
   ty1=titles[i].y1;
   tx2=titles[i].x2;
   ty2=titles[i].y2;
   bx1=boxes[i].x1;
   by1=boxes[i].y1;
   bx2=boxes[i].x2;
   by2=boxes[i].y2;

   Bconout(2,7);

   hide_mouse();
   xor_box(tx1,ty1,tx2,ty2-1);
   form_save(bx1-8,by1,bx2-bx1+32,by2-by1+2);    /* save Hintergrund der Box */
   clr_box(bx1,by1,bx2,by2);
   draw_entries(i);
   show_mouse();

   do
   {
      inbox=1;
      if((mouse_x>=bx1&&mouse_x<=bx2)&&(mouse_y>=by1&&mouse_y<=by2))
         inbox=0;
      intit=1;
      if((mouse_x>=tx1&&mouse_x<=tx2)&&(mouse_y>=ty1&&mouse_y<=ty2))
         intit=0;
      if(inbox&&intit)
      {
         hide_mouse();
         xor_box(tx1,ty1,tx2,ty2-1);
         form_redraw(bx1-8,by1,bx2-bx1+32,by2-by1+2);  /* Boxredraw */
         show_mouse();
         irq_menu=0;
         return(0);
      }

      eintrag=find_objc(i,&ox,&oy,&ow,&oh);

      if(eintrag>0)
      {
         hide_mouse();
         xor_box(ox,oy,ox+ow-1,oy+oh-1);
         show_mouse();

         while((mouse_x>=ox)&&(mouse_x<ox+ow)&&(mouse_y>=oy)&&(mouse_y<oy+oh))
         {
            if(mouse_but&1)
            {
               hide_mouse();
               xor_box(tx1,ty1,tx2,ty2-1);
               form_redraw(bx1-8,by1,bx2-bx1+32,by2-by1+2);  /* Boxredraw */
               show_mouse();
               mmgbuf[0]=MN_SELECTED;
               mmgbuf[3]=titles[i].index;
               mmgbuf[4]=eintrag;
               irq_menu=0;
               return(MU_MESAG);
            }
         }
         hide_mouse(); 
         xor_box(ox,oy,ox+ow-1,oy+oh-1);
         show_mouse();
      }
   }while(1);
}

find_objc(which,ox,oy,ow,oh)
int which;
int *ox,*oy,*ow,*oh;
{
   GRECT box;
   int a,b,last;
   int x=mouse_x;
   int y=mouse_y;

   a=boxes[which].index;
   b=OB_HEAD(mainmenu,a);
   last=OB_TAIL(mainmenu,a);

   while(b!=boxes[which].index)
   {
      if(OB_TYPE(mainmenu,b)==28&& !(OB_STATE(mainmenu,b)&DISABLED))
      {
         objc_xywh(mainmenu,b,&box);
         *ox=box.g_x;
         *oy=box.g_y;
         *ow=box.g_w;
         *oh=box.g_h;
         if((y >= *oy)&&(y < *oy + *oh)&&(x >= *ox)&&(x < *ox + *ow))
            return(b);
      }
      b=OB_NEXT(mainmenu,b);
   }
   return(-1);
}

find_title()
{
   int mx;
   int title,a;

   title= -1;
   mx=mouse_x;

   for(a=0;a<=title_anz;a++)
   {
      if(mx>=titles[a].x1&&mx<=titles[a].x2)
         title=titles[a].index;
      if(title!= -1)
         break;
   }

   if(title!= -1)
      return(a);
   else
      return(-1);
}


init_menu()
{
   GRECT box;
   int last,first;
   int a,b,c;
   int acc_anz;
   int deskbox;
   long save;
   char **names;
   char *string;

   hide_mouse();

   last=OB_TAIL(mainmenu,2);

   a=OB_HEAD(mainmenu,2);
   for(c=0;c<=20;c++)
   {
      objc_xywh(mainmenu,a,&box);
      titles[c].index=a;
      titles[c].x1=box.g_x;
      titles[c].y1=box.g_y;
      titles[c].x2=box.g_x+box.g_w-1;
      titles[c].y2=box.g_y+box.g_h-1;
      if(a==last)
         break;
      a=OB_NEXT(mainmenu,a);
   }

   title_anz=c;

   b=OB_NEXT(mainmenu,1);

   last=OB_TAIL(mainmenu,b);
   b=OB_HEAD(mainmenu,b);
   for(c=0;c<=title_anz;c++)
   {
      objc_xywh(mainmenu,b,&box);
      boxes[c].index=b;
      boxes[c].x1=box.g_x;
      boxes[c].y1=box.g_y;
      boxes[c].x2=box.g_x+box.g_w-1;
      boxes[c].y2=box.g_y+box.g_h-1;

      boxes[c].offset=((box.g_x/8)&0xfffe)-2;

      boxes[c].xcount=box.g_w/8;
      boxes[c].xcount+=4;

      boxes[c].ycount=box.g_h;
      b=OB_NEXT(mainmenu,b);
   }

   objc_xywh(mainmenu,1,&box);
   clr_box(box.g_x,box.g_y,box.g_x+box.g_w-1,box.g_y+box.g_h-1);
   for(a=0;a<=title_anz;a++)
   {
      objc_xywh(mainmenu,titles[a].index,&box);
      string=OB_SPEC(mainmenu,titles[a].index);
      b=box.g_x;
      while(*string)
      {
         o_putbig(b,box.g_y+1,*string++);
         b+=8;
      }
   }
   show_mouse();
}

xor_box(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
   asm
   {
         MOVE.L   line_a_var(A4), A0
         MOVE.W   x1(A6), _X1(A0)
         MOVE.W   y1(A6), _Y1(A0)
         MOVE.W   x2(A6), _X2(A0)
         MOVE.W   y2(A6), _Y2(A0)
         MOVE.W   #1, _COLOR(A0)    ;PLANE 0
#ifdef COLOR
         MOVE.W   #1, _COLOR+2(A0)  ;PLANE 1
#endif
         MOVE.W   #2, _WRT_MODE(A0)
         LEA      LINE(PC), A1
         MOVE.L   A1, _PATPTR(A0)
         CLR.W    _PATMSK(A0)
         CLR.W    _CLIP(A0)
         DC.W     0XA005
         UNLK     A6
         RTS

LINE:    DC.W  0XFFFF
   }
}


dis_box(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
   asm
   {
         MOVE.L   line_a_var(A4), A0
         MOVE.W   x1(A6), _X1(A0)
         MOVE.W   y1(A6), _Y1(A0)
         MOVE.W   x2(A6), _X2(A0)
         MOVE.W   y2(A6), _Y2(A0)
         CLR.W    _COLOR(A0)        ;PLANE 0
#ifdef COLOR
         CLR.W    _COLOR+2(A0)      ;PLANE 1
#endif
         MOVE.W   #1, _WRT_MODE(A0)
         LEA      LINE(PC), A1
         MOVE.L   A1, _PATPTR(A0)
         MOVE.W   #1, _PATMSK(A0)
         CLR.W    _CLIP(A0)
         DC.W     0XA005
         UNLK     A6
         RTS

LINE:    DC.W     0X5555
         DC.W     0XAAAA
   }
}


clr_box(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
   asm
   {
         MOVE.L   line_a_var(A4), A0
         MOVE.W   x1(A6), _X1(A0)
         MOVE.W   y1(A6), _Y1(A0)
         MOVE.W   x2(A6), _X2(A0)
         MOVE.W   y2(A6), _Y2(A0)
         MOVE.W   #1, _COLOR(A0)
#ifdef COLOR
         MOVE.W   #1, _COLOR+2(A0)
#endif
         MOVE.W   #0, _WRT_MODE(A0)
         LEA      LINE(PC), A1
         MOVE.L   A1, _PATPTR(A0)
         CLR.W    _PATMSK(A0)
         CLR.W    _CLIP(A0)
         DC.W     0XA005
         UNLK     A6
         RTS

LINE:    DC.W     0X0000
   }
}


draw_entries(which)
int which;
{
   GRECT box;
   ICONBLK *icon;
   FDB icfdb;
   int first,last,a,b,c;
   char *string;

   asm
   {
         CLR.L    D0
         MOVE.L   line_a_var(A4), A3
         MOVE.W   #1, _COLOR(A3)
#ifdef COLOR
         MOVE.W   #1, _COLOR+2(A3)
#endif
         MOVE.W   #0, _WRT_MODE(A3)
         MOVE.W   #0XFFFF, _LN_MASK(A3)
         MOVE.W   #0XFFFF, _LSTLIN(A3)
         LEA      boxes(A4), A2
         MOVE.W   which(A6), D0
         MULU     #16, D0
         ADDA.L   D0, A2
         SUBQ.W   #1, 2(A2)
         SUBQ.W   #1, 4(A2)
         ADDQ.W   #1, 6(A2)
         ADDQ.W   #1, 8(A2)
         MOVE.W   2(A2), _X1(A3)
         MOVE.W   4(A2), _Y1(A3)
         MOVE.W   6(A2), _X2(A3)
         MOVE.W   4(A2), _Y2(A3)
         MOVEM.L  A2-A4, -(A7)
         DC.W     0XA003
         MOVEM.L  (A7)+, A2-A4
         MOVE.W   6(A2), _X1(A3)
         MOVE.W   4(A2), _Y1(A3)
         MOVE.W   6(A2), _X2(A3)
         MOVE.W   8(A2), _Y2(A3)
         MOVEM.L  A2-A4, -(A7)
         DC.W     0XA003
         MOVEM.L  (A7)+, A2-A4
         MOVE.W   2(A2), _X1(A3)
         MOVE.W   8(A2), _Y1(A3)
         MOVE.W   6(A2), _X2(A3)
         MOVE.W   8(A2), _Y2(A3)
         MOVEM.L  A2-A4, -(A7)
         DC.W     0XA003
         MOVEM.L  (A7)+, A2-A4
         MOVE.W   2(A2), _X1(A3)
         MOVE.W   4(A2), _Y1(A3)
         MOVE.W   2(A2), _X2(A3)
         MOVE.W   8(A2), _Y2(A3)
         MOVEM.L  A2-A4, -(A7)
         DC.W     0XA003
         MOVEM.L  (A7)+, A2-A4
         SUBQ.W   #1, 8(A2)
         SUBQ.W   #1, 6(A2)
         ADDQ.W   #1, 4(A2)
         ADDQ.W   #1, 2(A2)
   }

   a=OB_HEAD(mainmenu,boxes[which].index);

   while(a!=boxes[which].index)
   {
      switch(OB_TYPE(mainmenu,a))
      {
         case  0 : break;

         case 28 :
            objc_xywh(mainmenu,a,&box);
            string=OB_SPEC(mainmenu,a);
            b=box.g_x;
#ifdef COLOR
            c=box.g_y+box.g_h/2-4;
#else
            c=box.g_y+box.g_h/2-8;
#endif
            while(*string)
            {
               o_putbig(b,c,*string++);
               b+=8;
            }
            if(OB_STATE(mainmenu,a)&DISABLED)
               dis_box(box.g_x,box.g_y,box.g_x+box.g_w-1,box.g_y+box.g_h-1);
            break;

         default :
            objc_draw(mainmenu,a,0,SXY,SWH);
            break;
      }
      a=OB_NEXT(mainmenu,a);
   }
}
