/* Star simulation taken from Computer Shopper March 1993
   Ported from ibm to Atari ST :    March 16,1993
                                    Jeff Bilger   Texas A&M University
                                    jmb8302@neuron.tamu.edu
*/

#include <linea.h>
#include <osbind.h>

/*random number generator */

#define random(x) abs(Random()%(x))

/*returns a number from 0 to (x-1) */

#define MAX_STARS 100
#define SCALE 10  
#define CONSOLE 2
#define xmed 639 
#define ymed 199
#define xlow 319
#define ylow 199
#define WHITE 0 
#define BLACK 3 
#define GREEN 1
#define RED   2
#define BLUE  4


typedef struct
 {
  int  x,y;
 }POINT;

typedef struct
 {
  int speed;
  POINT loc;       /* stars location */
  POINT dir;       /* its direction */
  int   size;      /* 1x1 or 2x2 pixel */
  int   color;      /* its color  */
 }STAR;

struct
 {
   STAR stars[MAX_STARS];           /* array of stars */
  int  numstars;                   /* # of active stars */
  POINT screen;                    /* screen size */
  int   speed;                     /* speed as a percentage */
 }g;





main()
{
 lineaport *myport;
 char c;
 int rez,xrez,yrez;
 int pl0,pl1,pl2,pl3,
     col0,col1,col2,col3,
     exit=0;
printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
 
  myport = a_init();
  a_hidemouse();
printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

col0=Setcolor(0,-1);             /* makes border black */
col1=Setcolor(3,-1);             /* color of pixels. text */
col2=Setcolor(2,-1);             /* 2= background */
col3=Setcolor(1,-1);    


   pl0=myport->plane0 ;       /* MED RES, 2 PLANES. LO RES MAKE 4 PLANES */
   pl1=myport->plane1 ;       
   pl2=myport->plane2 ;
   pl3=myport->plane3 ;


   myport->plane0 = 0;       /* MED RES, 2 PLANES. LO RES MAKE 4 PLANES */
   myport->plane1 = 0;       
   myport->plane2 = 0;
   myport->plane3 = 0;

printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    rez = Getrez();            /* 0 low,1 med 2 hi */
     if ( rez == 2) {puts("Hi rez not supported.\n"); exit=1;}
      if (rez == 1) {xrez = xmed; yrez=ymed;}
       if (rez == 0) { xrez =xlow; yrez=ylow;}
                                   /* 0= border and all printed text
                                     including aputpixels */
Setcolor(0,0x000);             /* makes border black */
Setcolor(3,0x777);             /* color of pixels. text */
Setcolor(2,0x222);             /* 2= background */
Setcolor(1,0x444);    
    

     puts("Starfield simulation Keys: + Faster    - Slower    X exit");
      g.screen.x = xrez * SCALE;        /* set up x,y max resolution */
      g.screen.y = yrez  * SCALE;
      g.speed = 10;

       g.numstars = 0;
    while(!exit)
      {
       while ( !(Bconstat(CONSOLE)))       /* main loop */
        {
          if( g.numstars < MAX_STARS)
           {
            NewStar(&g.stars[g.numstars]);
            g.numstars++;
           }
          MoveStars();
         }
       switch( (c=Bconin(CONSOLE)))
          {
           case '+': if(g.speed < 300) g.speed++; break;
           case '-': if(g.speed > 1  ) g.speed--; break;
           case 'x':
           case 'X':Setcolor(0,col0);             /* makes border black */
Setcolor(3,col1);             /* color of pixels. text */
Setcolor(2,col2);             /* 2= background */
Setcolor(1,col3);    

                    exit=1;
          }
 } /*end of while(1) */

   myport->plane0 =pl0;       /* MED RES, 2 PLANES. LO RES MAKE 4 PLANES */
   myport->plane1 =pl1;       
   myport->plane2 =pl2;
   myport->plane3 =pl3;
 

}
/***********************************************/
EraseStar( star ,color)
STAR *star;
int  color;
{
 int x,y;

 
 x = star->loc.x/SCALE;             
 y = star->loc.y/SCALE;
 
 if( y < 186 || y > 193)
  a_putpixel(x,y,color);

  
}

/************************************************/
/***********************************************/
DrawStar( star )
STAR *star;

{
 int x,y;

 
 x = star->loc.x/SCALE;             
 y = star->loc.y/SCALE;
 if( x < 220 ) star->speed++;
 if( x > 420 ) star->speed++; 
 if( y < 60  ) star->speed++; 
 if( y > 130 ) star->speed++; 
 
  if( x < 220 && x > 150) star->color=1;
  if( x > 420 && x < 530) star->color=1;
  if( y < 60 && y > 30) star->color=1;
  if( y > 130 && y < 160) star->color=1;
  if( x < 151 || x > 529){ star->speed+=2; star->color = BLACK;}
  if( y < 31  || y > 159){ star->speed+=2; star->color = BLACK;}

  if( y < 186 || y > 193)
    a_putpixel(x,y,star->color);

  
}

/************************************************/
NewStar( star )
STAR *star;
{
 int ran,ran1;
 
 star->speed = 0;

 star->loc.x = (g.screen.x / 2)+ random(SCALE*2);
 star->loc.y = (g.screen.y / 2)+ random(SCALE*2);
        /* place star at center of screen */
 
   do
   {
    star->dir.x = SCALE - random(SCALE*2);  /* calc dir */
    star->dir.y = SCALE - random(SCALE*2);
     }while(star->dir.x == 0 || star->dir.y == 0);  /* if 0,0 keep trying*/

    switch(random(40))
      {
       case 39: star->color = 2; break;
       case 38: star->color = 2; break;
       case 37: star->color  =2; break;
       default: star->color = 2;
      }
}
/***********************************************************/
MoveStars()
{
 int i;
 STAR *star;
 
 for(star = &g.stars[g.numstars-1]; star >= g.stars; star--)
  {
   EraseStar(star,0);  /* erase it */
   star->loc.x += star->dir.x * (g.speed+star->speed)/3;
   star->loc.y += star->dir.y * (g.speed+star->speed)/3;
       if( star->loc.x < 0 || star->loc.x >= g.screen.x || star->loc.y <0
        || star->loc.y >= g.screen.y)
         {
          NewStar( star );
         }
        else
         {
          DrawStar(star);        
         }
       }
     }





 
