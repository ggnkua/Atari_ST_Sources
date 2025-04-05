overlay "brain_graf"

#include <osbind.h>
#include <megatadd.h>
#include <obdefs.h>

#define _COLOR 24
#define _LSTLIN 32
#define _LN_MASK 34
#define _WRT_MODE 36
#define _X1 38
#define _Y1 40
#define _X2 42
#define _Y2 44
#define _PATPTR 46
#define _PATMSK 50
#define _CLIP 54

extern int vdi_handle;
extern int mouse_x,mouse_y,mouse_but;

hide_mouse()
{
   v_hide_c(vdi_handle);
}

show_mouse()
{
   Vsync();
   v_show_c(vdi_handle,1);
}

set_mouse()
{
   Vsync();
   v_show_c(vdi_handle,0);
}

graf_growbox(sxy,swh,exy,ewh)
long exy,ewh,sxy,swh;
{
   graf_shrinkbox(exy,ewh,sxy,swh);
}

graf_shrinkbox(ex,ey,ew,eh,sx,sy,sw,sh)
int ex,ey,ew,eh,sx,sy,sw,sh;
{
   int a,b;
   int ex2,ey2,sx2,sy2;
   int x,x2,y,y2;
   int dx,dx2,dy,dy2;
   long pause;

   hide_mouse();

   ex2 = ex+ew;
   ey2 = ey+eh;
   sx2 = sx+sw;
   sy2 = sy+sh;

   dx  = ex-sx;
   dx2 = ex2-sx2;
   dy  = ey-sy;
   dy2 = ey2-sy2;

   for(b=0;b<2;b++)
   {
      a=2;

      x = sx;
      y = sy;
      x2 = sx2 = sx+sw;
      y2 = sy2 = sy+sh;

      graf_xor(x,y,x2,y2);

      while(a<17)
      {
         x = (dx*a)/16+sx;
         x2= (dx2*a)/16+sx2;
         y = (dy*a)/16+sy;
         y2= (dy2*a)/16+sy2;

         for(pause=0;pause<1000;pause++);

         graf_xor(x,y,x2,y2);
         a++;
      }
   }

   show_mouse();
   return(1);
}


graf_xor(x1,y1,x2,y2)
int x1,y1,x2,y2;
{
   register int mask1,mask2;
   register char reg_a2,reg_a3;

   (x1&1) ? mask1=0X5555 : mask1=0XAAAA;
   (x2&1) ? mask2=0X5555 : mask2=0XAAAA;

   if(!(y1&1))
   {
      mask1^=0xffff;
      mask2^=0xffff;
   }

   x1 = (x1<0) ? 0 : x1;
   y1 = (y1<0) ? 0 : y1;
   x2 = (x2<0) ? 0 : x2;
   y2 = (y2<0) ? 0 : y2;

   x1 = (x1>639) ? 639 : x1;
   y1 = (y1>399) ? 399 : y1;
   x2 = (x2>639) ? 639 : x2;
   y2 = (y2>399) ? 399 : y2;

   asm
   {
         DC.W     0XA000
         MOVE.L   A0, A3
         MOVE.W   #1, _COLOR(A3)
         MOVE.W   #2, _WRT_MODE(A3)
         MOVE.W   mask2, _LN_MASK(A3)
         MOVE.W   #0XFFFF, _LSTLIN(A3)
         MOVE.W   #1, _PATMSK(A3)
         LEA      LINE(PC), A2
         MOVE.L   A2, _PATPTR(A3)
         MOVE.W   x1(A6), _X1(A3)
         MOVE.W   y1(A6), _Y1(A3)
         MOVE.W   x2(A6), _X2(A3)
         DC.W     0XA004
         MOVE.W   x2(A6), _X1(A3)
         MOVE.W   y1(A6), _Y1(A3)
         MOVE.W   x2(A6), _X2(A3)
         MOVE.W   y2(A6), _Y2(A3)
         DC.W     0XA003
         MOVE.W   x1(A6), _X1(A3)
         MOVE.W   y2(A6), _Y1(A3)
         MOVE.W   x2(A6), _X2(A3)
         DC.W     0XA004
         MOVE.W   mask1, _LN_MASK(A3)
         MOVE.W   x1(A6), _X1(A3)
         MOVE.W   y1(A6), _Y1(A3)
         MOVE.W   x1(A6), _X2(A3)
         MOVE.W   y2(A6), _Y2(A3)
         DC.W     0XA003
         BRA      ENDE
LINE:
         DC.W     0X5555,0XAAAA
ENDE:
   }
}

#ifdef MITSHRINK
graf_slidebox(rsc,par,chi,dir)
OBJECT *rsc;
int par,chi,dir;
{
   int x,y,w,h,xmax,ymax,wmax,hmax;
   int x1,x2,y1,y2;
   int oldx,oldy,xs,ys;
   int dx1,dx2,dy1,dy2;
   long s1,s2,s3,erg;

   xs=oldx=mouse_x;                    /* oldx,oldy = maus startpos */
   ys=oldy=mouse_y;

   objc_offset(rsc,par,&xmax,&ymax);/* xmax,ymax,wmax,hmax = parent */
   wmax=OB_WIDTH(rsc,par);
   hmax=OB_HEIGHT(rsc,par);

   objc_offset(rsc,chi,&x,&y);      /* x,y,w,h = child = slider */
   w=OB_WIDTH(rsc,chi);
   h=OB_HEIGHT(rsc,chi);

   x1=oldx+xmax-x;                  /* x1,y1   = max mousewert    */
   x2=oldx+xmax+wmax-x-w;           /* x2,y2   = min mousewert    */
   y1=oldy+ymax-y;
   y2=oldy+ymax+hmax-y-h;

   dx1=x-oldx;         /* dx1,dx2,dy1,dy2 = abstand der eckpunkte zur mouse */
   dx2=x+w-1-oldx;
   dy1=y-oldy;
   dy2=y+h-1-oldy;

   hide_mouse();
   while(mouse_but)
   {
      graf_xor(oldx+dx1,oldy+dy1,oldx+dx2,oldy+dy2);
      show_mouse();
      do
      {
         if(!dir)
         {
            xs=(mouse_x>x1)? mouse_x : x1 ;
            xs=(xs<x2)?      xs      : x2 ;
         }
         else
         {
            ys=(mouse_y>y1)? mouse_y : y1 ;
            ys=(ys<y2)?      ys      : y2 ;
         }
      }
      while(oldx==xs&&oldy==ys);
      hide_mouse();
      graf_xor(oldx+dx1,oldy+dy1,oldx+dx2,oldy+dy2);
      oldx=xs;
      oldy=ys;
   }
   show_mouse();

   if(dir)
      return((1000l*(long)(oldy+dy1-ymax))/(hmax-h));

   return((1000l*(long)(oldx+dx1-xmax))/(wmax-x));
}
#endif
