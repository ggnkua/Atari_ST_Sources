#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
/******************************************************************/
/* Some of the available video modes supported by the falcon 030  */
/* Vxxx_xxx_xxx = VGA Monitor.                                    */
/* For use with the xbios(0x58, int mode) aka Vsetmode(int mode). */
/******************************************************************/

#define  V320_240_4   273
#define  V320_240_16  274
#define  V320_240_256 275
#define  V320_240_32k 276
#define  V320_200_16  402
#define  V640_200_4   409
#define  V640_400_2   152
#define  V640_480_2   24
#define  V640_480_4   25
#define  V640_480_16  26
#define  V640_480_256 27
#define  V320_480_32k 20

typedef struct
{
   unsigned int red:5;
   unsigned int green:5;
   unsigned int overlay:1;
   unsigned int blue:5;
}HIGHCOLOR;

unsigned int old_vm;
unsigned int line_color;

unsigned int *y_table[500];
unsigned long screen_loc;
unsigned int *old_screen;
void line(int x1, int y1, int x2, int y2, unsigned int color);
void plot(int x, int y, unsigned int color);
void xorline(int x1, int y1, int x2, int y2, unsigned int color);
void set_colors(void);


#define LINECOLOR 576

unsigned int color_table[LINECOLOR+10];
int dx1, dx2, dy1, dy2;
int x1, x2, y1, y2;
int mask = 0x1;
void main()
{
   unsigned int *screen_loc;
   unsigned int *old_screen;
   unsigned int *t;
   register long int index;
   
   screen_loc = (unsigned int *) Malloc(-1L);
   if(screen_loc < (unsigned int *)307400L)
   {
      printf("Unable to allocate screen memeory, sorry!");
      exit(0);
   }

   set_colors();
   
   old_screen = (unsigned int *) Physbase();
   t = screen_loc = (unsigned int *) Malloc(307400L);
   
   for(index = 0; index < 500; index++)
      y_table[index] = (unsigned int *)(screen_loc+((long)index * 320L));

   old_vm = (unsigned int)Vsetmode(V320_480_32k);
   xbios(5,screen_loc, screen_loc, 3, V320_480_32k);
   for(index = 0; index < (307200L/2L); index++)
       *(t++) = 0;

   while(Bconstat(2)) Bconin(2);
   line_color = 0;
   
   x1 = (int)(Random() & 0xff);
   y1 = (int)(Random() & 0xff);
   x2 = (int)(Random() & 0xff);
   y2 = (int)(Random() & 0xff);

   dx1 = -1;
   dx2 = 1;
   dy1 = -1;
   dy2 = 1;
   
   while(Bconstat(2)) Bconin(2);
   
   while(1)
   {
      if(x1 > 318) 
      {
         x1 = 318;
         dx1 = -((int)(Random() & mask)+1);
      }
      
      if(x1 < 1) 
      {
         x1 = 1;
         dx1 = ((int)(Random() & mask)+1);
      }

      if(x2 > 318) 
      {
         x2 = 318;
         dx2 = -((int)(Random() & mask)+1);
      }
      
      if(x2 < 1) 
      {
         x2 = 1;
         dx2 = ((int)(Random() & mask)+1);
      }
      
      if(y1 > 478) 
      {
         y1 = 478;
         dy1 = -((int)(Random() & mask)+1);
      }
      
      if(y1 < 1) 
      {
         y1 = 1;
         dy1 = ((int)(Random() & mask)+1);
      }
      
      if(y2 > 478) 
      {
         y2 = 478;
         dy2 = -((int)(Random() & mask)+1);
      }
      
      if(y2 < 1) 
      {
         y2 = 1;
         dy2 = ((int)(Random() & mask)+1);
      }
      
      x1 += dx1;
      y1 += dy1;
      x2 += dx2;
      y2 += dy2;
           
      line_color++;
      line(x1, y1, x2, y2, color_table[line_color % LINECOLOR]);

      if(Bconstat(2)) break;

   }  
   
   Bconin(2);
   xbios(5,old_screen, old_screen, 3, old_vm); 
   Mfree(screen_loc);

}

/****************************************************************/
/* Draw a line x1,y1,x2,y2,color                                */
/****************************************************************/
void line(int x1, int y1, int x2, int y2, unsigned int color)
{

   #define sign(x) ((x) > 0 ? 1: ((x) == 0 ? 0: (-1)))

   
   register int x, y, py, px;
   register int dx,dy,dxabs,dyabs,i,sdx,sdy;

   if(x1 < 1) x1 = 0;
   if(x1 > 318) x1 = 319;
   if(x2 < 1) x2 = 0;
   if(x2 > 318) x2 = 319;
   if(y1 > 478) y1 = 479;
   if(y1 < 1) y1 = 0;
   if(y2 > 478) y2 = 479;
   if(y2 < 1) y2 = 0;
      
   dx = x2 - x1;
   dy = y2 - y1;

   sdx = sign(dx);
   sdy = sign(dy);
   dxabs = abs(dx);
   dyabs = abs(dy);
   x = 0;
   y = 0;
   px = x1;
   py = y1;
   
   if(dxabs >= dyabs)
   {
      for(i = 0; i <= dxabs; i++)
      {
         y += dyabs;
         
         if(y >= dxabs)
         {
            y -= dxabs;
            py += sdy;
         }
         
         *((unsigned int *)((y_table[py]) + (px))) = color;

         px += sdx;
      }
   }
   else
   {
      for(i = 0; i < dyabs; i++)
      {
         x += dxabs;
         if(x >= dyabs)
         {
            x -= dyabs;
            px += sdx;
         }

         *((unsigned int *)((y_table[py]) + (px))) = color;
         py += sdy;
      }
   }
}
/****************************************************************/
/* Draw a line x1,y1,x2,y2,color                                */
/****************************************************************/
void xorline(int x1, int y1, int x2, int y2, unsigned int color)
{

   #define sign(x) ((x) > 0 ? 1: ((x) == 0 ? 0: (-1)))

   
   register int x, y, py, px;
   register int dx,dy,dxabs,dyabs,i,sdx,sdy;

   if(x1 < 1) x1 = 0;
   if(x1 > 318) x1 = 319;
   if(x2 < 1) x2 = 0;
   if(x2 > 318) x2 = 319;
   if(y1 > 478) y1 = 479;
   if(y1 < 1) y1 = 0;
   if(y2 > 478) y2 = 479;
   if(y2 < 1) y2 = 0;
   
   dx = x2 - x1;
   dy = y2 - y1;

   sdx = sign(dx);
   sdy = sign(dy);
   dxabs = abs(dx);
   dyabs = abs(dy);
   x = 0;
   y = 0;
   px = x1;
   py = y1;
   
   if(dxabs >= dyabs)
   {
      for(i = 0; i <= dxabs; i++)
      {
         y += dyabs;
         
         if(y >= dxabs)
         {
            y -= dxabs;
            py += sdy;
         }
         
         *((unsigned int *)((y_table[py]) + (px))) ^= color;
         px += sdx;
      }
   }
   else
   {
      for(i = 0; i < dyabs; i++)
      {
         x += dxabs;
         if(x >= dyabs)
         {
            x -= dyabs;
            px += sdx;
         }

         *((unsigned int *)((y_table[py]) + (px))) ^= color;
         py += sdy;
      }
   }
}

/************************************************************/
/* Plot color at x,y.                                       */
/************************************************************/
void plot(int x, int y, unsigned int color)
{
   register unsigned int *temp;
   temp = (unsigned int *) ((y_table[y]) + (x));
   *temp = color;
}
/*************************************************************/
/* Set the color table.                                      */
/*************************************************************/
void set_colors(void)
{
   int a, b;
   HIGHCOLOR tc;
   unsigned int *ti;
   b = 0;
   
   ti = (unsigned int *)&tc;
   
   for(a = 0; a < 32; a++)
   {
      tc.red = a;
      tc.green = 0;
      tc.blue = 0;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = a;
      tc.green = 0;
      tc.blue = 0;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 0; a < 32; a++)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = 0;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = 0;
      color_table[b] = *ti;
      b++;
   }

   for(a = 0; a < 32; a++)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   for(a = 0; a < 32; a++)
   {
      tc.red = 0;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = 0;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   for(a = 0; a < 32; a++)
   {
      tc.red = 0;
      tc.green = 0;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = 0;
      tc.green = 0;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   /*************************************/
   
   for(a = 0; a < 32; a++)
   {
      tc.red = a;
      tc.green = 0;
      tc.blue = 15;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = a;
      tc.green = 0;
      tc.blue = 15;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 0; a < 32; a++)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = 15;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = a;
      tc.green = a;
      tc.blue = 15;
      color_table[b] = *ti;
      b++;
   }

   for(a = 0; a < 32; a++)
   {
      tc.red = 15;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = 15;
      tc.green = a;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   for(a = 0; a < 32; a++)
   {
      tc.red = 15;
      tc.green = 0;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
   for(a = 31; a > 0; a--)
   {
      tc.red = 15;
      tc.green = 0;
      tc.blue = a;
      color_table[b] = *ti;
      b++;
   }
   
}