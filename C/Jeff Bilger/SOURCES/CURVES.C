/* Program 
  
   Plots 5 segments, Q3->Q7
   
   Q3 uses points P0,P1,P2 and P3 (Pm-3, Pm-2, Pm-1, Pm   m=3)
   Q4 uses points P1,P2,P3 and P4 (Pm-3, Pm-2, Pm-1, Pm   m=4)
   ditto for Q5.& Q6 & Q7..

   Giving a total of 8 points needed. P0->P7, These points are
   defined in Q[n]  where Q[0] = Point0, Q[1] = P1 etc..


   Jeff Bilger              463-08-8302
   Computer Graphics 441    Dr.Mc Cormick
   Summer 1993              July 17,1993

 */

#include <linea.h>
#include <osbind.h>

#define GREEN 2
#define RED 1
#define WHITE 0
#define BLACK 3

struct PointDef
 {
  int x,y;         /* x,y position of Geometry Vector */
  double B1,B2;    /* controls, a B1 & B2 for EACH control point! */
 }G[8];            /* define 8 of em. 0-7 Hence 5 segments! */

double delta1,delta2,
       delta3,delta4;   /* delta constants for segment */
double Pm_3Coeff,     
       Pm_2Coeff1,      /* The coeffs that stay constant and reoccur*/ 
       Pm_2Coeff2,      /* in many equs to calculate x,y at t for */
       Pm_2Coeff3,      /* a given Curve Qm.. Start at Q3 */
       Pm_2Coeff4,
       Pm_1Coeff1,
       Pm_1Coeff2;

main()
{
 int n = 150,             /* the # of times to divide up 0 to 1 */
     i,
     curve=3;             /* What segment we're on! */
 double delta = 1.0/ (double)n,  /* the delta value to inc t with */
     x=0,y=0,        /* the x,y coords of functions N and Y*/
     t=0;                        /* evaluated at t */
 lineaport *myport;

   init();

	myport = a_init();

	myport -> plane0 = WHITE;
	myport -> plane1 = WHITE;
 printf("STARTING \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

for(curve = 3; curve < 8; curve++)
{
 SetupSegment( curve );        /* sets up coeffs, and constants 
                                  for a specified segment */
 for( i=0;i<n;i++)
   {
      t += delta;              /* compute value of t */
      SetupCurve( curve, t ,&x,&y);  /* compute values of */ 
      Draw(x,y,RED);       /* Draw N function (x,y) in RED color */
      
    } /* end of t[0,1] interval */
   t=0;    /* reset t */
 }   /* end of curve # */
}



/************************************************/
/* calculates value if x,y using 
   precalculated coeffs and deltas, plus t 

   G[0] is point P0
   G[1] is point P1
   G[2] is point P2
  
   so when m =3  ( on 1st segment curve Q3 )
   so G[m-3] ===> G[0]  point0
      G[m-2] ===> G[1]  point1
      G[m-1] ===> G[2]  point2
      G[m]   ===> G[3]  point3
  
     Which are the 4 points that define Q3!!!

*/

SetupCurve( m , t , x,y )
int m;         /* holds curve we're on Q3,4 or 5 */
double t,      /* current place */
       *x,     /* returns this */
       *y;     /* and this */
{
 double t2,t3;
 
       t2 = t*t;        /* compute t^2 and t^3 */
       t3 = t2 * t;

/** may wish to compute mass of this once and apply to g[n].x and g[n].y
    values... **/


  *x = ((1.0/delta1) * ( -2.0*Pm_3Coeff*t3  + 6.0*Pm_3Coeff*t2  - 6.0*Pm_3Coeff*t  + 2.0*Pm_3Coeff) * (double)G[m-3].x)
      +((1.0/delta2) * (  2.0*Pm_2Coeff1*t3 - 3.0*Pm_2Coeff2*t2 + 6.0*Pm_2Coeff3*t + Pm_2Coeff4)    * (double)G[m-2].x)
      +((1.0/delta3) * ( -2.0*Pm_1Coeff1*t3 + 3.0*Pm_1Coeff2*t2 + 6.0*G[m-1].B1*t  + 2.0)           * (double)G[m-1].x)
      +((1.0/delta4) * (  2.0*t3 ) * (double)G[m].x);

  *y = ((1.0/delta1) * ( -2.0*Pm_3Coeff*t3  + 6.0*Pm_3Coeff*t2  - 6.0*Pm_3Coeff*t  + 2.0*Pm_3Coeff) * (double)G[m-3].y)
      +((1.0/delta2) * (  2.0*Pm_2Coeff1*t3 - 3.0*Pm_2Coeff2*t2 + 6.0*Pm_2Coeff3*t + Pm_2Coeff4)    * (double)G[m-2].y)
      +((1.0/delta3) * ( -2.0*Pm_1Coeff1*t3 + 3.0*Pm_1Coeff2*t2 + 6.0*G[m-1].B1*t  + 2.0)           * (double)G[m-1].y)
      +((1.0/delta4) * (  2.0*t3 ) * (double)G[m].y);
 
     

/*
printf("\n\n**** Stat for Calculate x,y ****\n");
printf("t  >%f    t2  >%f   t3  >%f \n",t,t2,t3);
printf("x  >%f    y   >%f\n",*x,*y);
printf("********* End stat  *********\n\n");

*/

}






/********************************/
/* m holds curve we're on : either 3,4,5,6 or 7 




  Sets up deltas and constant,reeoccuring coeffs:
  
       Pm_3Coeff,     
       Pm_2Coeff1,       The coeffs that stay constant and reoccur 
       Pm_2Coeff2,       in many equs to calculate x,y at t for 
       Pm_2Coeff3,       a given Curve Qm.. Start at Q3 
       Pm_2Coeff4,
       Pm_1Coeff1,
       Pm_2Coeff2;






*/
SetupSegment( m )
int m;
{
 double hold1,hold2,hold3,hold4;
 
  hold1 = G[m-3].B1*G[m-3].B1*G[m-3].B1;  
  hold2 = G[m-2].B1*G[m-2].B1*G[m-2].B1;
  hold3 = G[m-2].B1*G[m-2].B1;
  hold4 = G[m-1].B1*G[m-1].B1;

  delta1 = G[m-3].B2 + 2.0*hold1 + 4.0*(G[m-3].B1*G[m-3].B1) + 4.0*G[m-3].B1 + 2.0;
  
  delta2 = G[m-2].B2 + 2.0*hold2 + 4.0*hold3 + 4.0*G[m-2].B1 + 2.0;

  delta3 = G[m-1].B2 + 2.0*(hold4 * G[m-1].B1) + 4.0*hold4 + 4.0*G[m-1].B1 + 2.0;

  delta4 = G[m].B2 + 2.0*(G[m].B1*G[m].B1*G[m].B1) + 4.0*(G[m].B1*G[m].B1) + 4.0*G[m].B1 + 2.0;


  Pm_3Coeff = hold1;
  Pm_2Coeff1= G[m-2].B2 + hold2     + hold3      + G[m-2].B1;
  Pm_2Coeff2= G[m-2].B2 + 2.0*hold2 + 2.0*hold3;
  Pm_2Coeff3= hold2 - G[m-2].B1;
  Pm_2Coeff4= G[m-2].B2 + 4.0*(hold3 + G[m-2].B1);
  Pm_1Coeff1= G[m-1].B2 + hold4 + G[m-1].B1 + 1.0;
  Pm_1Coeff2= G[m-1].B2 + 2.0 * hold4; 

/*
  printf("Stats after SetUpSegment\n");
  printf("delta1:%f   delta2:%f   delta3:%f   delta4:%f  \n",delta1,delta2,delta3,delta4);
  printf("\nCoeffs\n");
  printf("Pm_3   >%f\n",hold1);
  printf("Pm_2:1 >%f  Pm_2:2 >%f  Pm_2:3 >%f  Pm_2:4  >%f\n",Pm_2Coeff1,Pm_2Coeff2,Pm_2Coeff3,Pm_2Coeff4);
  printf("Pm_1:1 >%f  Pm_1:2 >%f\n",Pm_1Coeff1,Pm_1Coeff2);
  printf("******* done with this stat *********");  
*/
}
/********************************/
/* Displays a pixel on the screen given x,y and a color.
*/
Draw(x,y,color)
double x,y;                /* the coords to plot at */
int color;                 /* the color of the pixel */

{
 int x1,y1;                /* local int. vars */
 char a;                   
 
 x1 = (int) x;             /* typecast to integer */
 y1 = (int) y;
 
/*
 printf("doubles: x:%f y:%f\nints x:%d y:%d\n",x,y,x1,y1);
*/             
a_putpixel(x1, y1, color);
a=Bconin(2);
}

/*******************************************/
/*
   init()

inits the G[n] values 
G[0] to G[7]   8 points


*/
init()
{
 int p;

 G[0].x  = 50;
 G[0].y  = 90;
 G[0].B1 = 10.5;
 G[0].B2 = 12.1;

 G[1].x  = 50;
 G[1].y  = 40;
 G[1].B1 = 20.1;
 G[1].B2 = 15.1;

 G[2].x  = 80;
 G[2].y  = 40;
 G[2].B1 = 9.1;
 G[2].B2 = 6.0;

 G[3].x  = 80;
 G[3].y  = 90;
 G[3].B1 = 10.1;
 G[3].B2 = 50.0;

 G[4].x  = 130; 
 G[4].y  = 90;
 G[4].B1 = 9.3;
 G[4].B2 = 999.8;

 G[5].x  = 130;
 G[5].y  = 40;
 G[5].B1 = 5.1;
 G[5].B2 = 888.5;

 G[6].x  = 300;
 G[6].y  = 40;
 G[6].B1 = 5.1;
 G[6].B2 = 888.5;


 G[7].x  = 300;
 G[7].y  = 90;
 G[7].B1 = 888.1;
 G[7].B2 = 88.5;



           
for(p=0;p<6;p++)
 printf("G[%d]   x >%d  y >%d  b1 >%f  b2  >%f\n",p,G[p].x,G[p].y,G[p].B1,G[p].B2);
}