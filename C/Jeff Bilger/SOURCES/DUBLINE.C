#include <linea.h>
#include <osbind.h>












/* symmetric double step line algorithm */

#define swap(a,b)   { a^=b; b^=a; a^=b; }
#define absolute(i,j,k)  ( (i-j)*(k= ((i-j)<0 ? -1 : 1)))

int symwuline(a1,b1,a2,b2,color)
int a1,b1,a2,b2,color;
{
 int	dx,dy,incr1,incr2,D,x,y,xend,c,pixels_left;
 int	x1,y1;
 int	sign_x,sign_y,step,reverse,i;

dx = absolute(a2,a1,sign_x);
dy = absolute(b2,b1,sign_y);

/* decide increment sign by the slope sign*/

if (sign_x == sign_y)
   step = 1;
else
   step = -1;

if (dy > dx)   /* chooses axis of greatest movement (make dx) */
  {
   swap(a1,b1);
   swap(a2,b2);
   swap(dx,dy);
   reverse = 1;
  }
else
   reverse = 0;

/*note error check for dx == 0 should be included here */
if (a1 > a2)       /* start from the smaller coord */
   {
    x = a2;
    y = b2;
    x1 = a1;
    y1 = b1;
   }
else      /* a2 >? a1 */
   {
    x = a1;
    y = b1;
    x1 = a2;
    y1 = b2;
   }

/* Note dx=n implies 0-n or (dx+1) pixels to be set */

xend = (dx-1)/4;
pixels_left = (dx-1)%4;  /* # of pixels left over at the end */


plot(x,y,reverse,color);        /* plot first 2 points */
plot(x1,y1,reverse,color);

incr2 = 4*dy-2*dx;

if(incr2 < 0)  /* slope less than 1/2 */
  {
   c = 2*dy;
   incr1 = 2*c;
   D = incr1 - dx;

   for(i=0;i<xend;i++)       /* THE plotting loop */
    {
     ++x;
     --x1;
     if(D<0)  /* pattern 1 forwards */
       {
        plot(x,y,reverse,color);
        plot(++x,y,reverse,color);
              
        plot(x1,y1,reverse,color);  /* plot pattern 1 backwards */
        plot(--x1,y1,reverse,color);
        D+=incr1;
       }

      else
      {
        if(D<c)  /* pattern 2 forwards */
       {
        plot(x,y,reverse,color);
        plot(++x,y+=step,reverse,color);
              
        plot(x1,y1,reverse,color);  /* plot pattern 2 backwards */
        plot(--x1,y1-=step,reverse,color);
       }
        else
        {
                     /*pattern 3 forwards */
       
        plot(x,y+=step,reverse,color);
        plot(++x,y,reverse,color);
        plot(x1,y1-=step,reverse,color);  /* plot pattern 2 backwards */
        plot(--x1,y1,reverse,color);
       }
      D+=incr2;
    }        
   }        /* end for */


/* plot last pattern */
if(pixels_left)
   {
      if(D<0)
        {
         plot(++x,y,reverse,color);   /*pattern 1*/
         if (pixels_left > 1)
          plot(++x,y,reverse,color);
         if(pixels_left > 2)
          plot(--x1,y1,reverse,color);
        }
      else
       {
        if(D<c)
         {
           plot(++x,y,reverse,color);   /*pattern 2*/
           if(pixels_left > 1)
            plot(++x,y+=step,reverse,color);
           if(pixels_left > 2)
            plot(--x1,y1,reverse,color);
         }
         else
         {
           plot(++x,y+=step,reverse,color);   /*pattern 3*/
           if(pixels_left > 1)
            plot(++x,y,reverse,color);
           if(pixels_left > 2)
            plot(--x1,y1-=step,reverse,color);
         }
       }
     } /*end if pixels left */
  } 
   /* end slope < 1/2 */

else         /* else slope is > 1/2 */
 {
   c = 2*(dy-dx);
   incr1 = 2*c;
   D = incr1 + dx;

   for(i=0;i<xend;i++)       /* THE plotting loop */
    {
     ++x;
     --x1;
     if(D>0)  /* pattern 4 forwards */
       {
        plot(x,y+=step,reverse,color);
        plot(++x,y+=step,reverse,color);
              
        plot(x1,y1-=step,reverse,color);  /* plot pattern 4 backwards */
        plot(--x1,y1-=step,reverse,color);
        D+=incr1;
       }

      else
      {
        if(D<c)  /* pattern 2 forwards */
       {
        plot(x,y,reverse,color);
        plot(++x,y+=step,reverse,color);
              
        plot(x1,y1,reverse,color);  /* plot pattern 2 backwards */
        plot(--x1,y1-=step,reverse,color);
       }
        else
        {
                     /*pattern 3 forwards */
       
        plot(x,y+=step,reverse,color);
        plot(++x,y,reverse,color);
        plot(x1,y1-=step,reverse,color);  /* plot pattern 2 backwards */
        plot(--x1,y1,reverse,color);
       }
      D+=incr2;
    }        
   }        /* end for */


/* plot last pattern */
if(pixels_left)
   {
      if(D>0)
        {
         plot(++x,y+=step,reverse,color);   /*pattern 4*/
         if (pixels_left > 1)
          plot(++x,y+=step,reverse,color);
         if(pixels_left > 2)
          plot(--x1,y1-=step,reverse,color);
        }
      else
       {
        if(D<c)
         {
           plot(++x,y,reverse,color);   /*pattern 2*/
           if(pixels_left > 1)
            plot(++x,y+=step,reverse,color);
           if(pixels_left > 2)
            plot(--x1,y1,reverse,color);
         }
         else
         {
           plot(++x,y+=step,reverse,color);   /*pattern 3*/
           if(pixels_left > 1)
            plot(++x,y,reverse,color);
           if(pixels_left > 2)
             {
               if(D>c)  /*step 3*/
                 plot(--x1,y1 -=step,reverse,color);
                else /*step 2*/
                 plot(--x1,y1,reverse,color);
              }
       }
     }
  } 
 }
}




/*******************************/
/* non zero flag indicates the pixels needing swap back*/
plot(x,y,flag,color)
int x,y,flag,color;
{


 if(flag)
  a_putpixel(y,x,color);
  else  
  a_putpixel(x,y,color);
}
