/*   *** SPIN7.C ***
     ***************


    Will spin ==========>  A triangle in 3 space <===============
             
    
      *** This will project 3 different views of the triangle
          projects onto the xy,zy and xz PLANES!!!

     


  

   March 28 ,1994  jeff bilger 
   jbilger@cs.tamu.edu

*/


#include <math.h>
#include <linea.h>
#include <osbind.h>
int pts[4][2] = { 
	320, 050,
	120, 150,
	520, 150,
	320, 050
};
lineaport *theport;

long mu_global_s();                     /* prototype, tells our 
    			        				  Assembly language function
						         		  to return a long int  */
long mu_global_c();  /* multiply 32 bit global w/ a precomputed sin or cos value */


#define SCALE 2048L       /* so far 2048 is the upper bounds scale
                              i can get W/O overflow */
#define BITSH 11        /* what to shift (ie DIVIDE) by. this number
                           2^11 = 2048 */


typedef struct {long x,y,z;} point3d;   /* our faithful structure that defines a point in 3 space*/

          
/* these are used to allocate size of arrays */
#define NPTS   25                 /* max allowable points */
#define NLINES 50                
#define NFACES 50                


#define I ( SCALE  )           /* set up a SCALE factor */

point3d point_[NPTS] =         /* define our triangle in 3d */
		{ 
          I,I,I,     3*I,I,I, 2*I,I,-I,  2*I,-I,I/2,
 },
        drawpt1[NPTS],drawpt2[NPTS];     /* for fast draw/erasing look up */



int 
    npts  = 4,         /* linefrom, lineto for drawing lines */                                                                                            
    linefrom[NLINES] = {0,1,2,0,1,2},     /* set up lines to draw */
    lineto[NLINES]   = {1,2,0,3,3,3}, 
    nlines = 6,         /* number of lines */
    x_offset=320,       /* for viewport mapping */
    y_offset=100,
    z_offset=1;

long cos_2=2048;    /* cos of 3 degrees * scale of 2048 */
long sin_2=107;     /* sin of 3 degrees * scale of 2048 */


main()
{
register int i,j;   /* use em for FOR loops */
point3d pointi;     /* declare one instance of our point3d struct */
int color =1;       /* color to draw triangle */
char com;           /* for user input */




puts("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
puts("1-Spin Y  2-Spin X  3-Spin Z  9-Quit\n");


theport = a_init();                   /* line a invokage */    
	theport -> plane0 = 1;
	theport -> plane1 = 0;
	theport -> plane2 = 0;
	theport -> plane3 = 0;


   
for(i=0;i<nlines;i++)  /* set up points-to-connect lookup table*/
{ drawpt1[i] = point_[linefrom[i]];
  drawpt2[i] = point_[lineto[i]];  
}

com = 0x32;                       /* set to spin about x */

while( com != 0x39)
{
if( Bconstat(2) )       /* if keypress */
 com = Bconin(2);       /* get input */


                                  /* The main loop */
 for(i=0;i<npts;i++)
   {
   pointi = point_[i];        /* get current point data. We do this for efficiency, since we will use this value many times within one loop
                                 it's more efficient to compute it's value only once */
   
    if(com == 0x31) {              /* spin y */
               point_[i].x =( mu_global_c(pointi.x)  -
                              mu_global_s(pointi.z))>>BITSH; /* since our points are scaled AND or trig angles, sin&cos values are scaled we must divide by scale once here*/
               point_[i].z =( mu_global_s(pointi.x) +
                              mu_global_c(pointi.z))>>BITSH;

                    }
    if(com == 0x32) {              /* spin x */
                point_[i].y =( mu_global_c(pointi.y)  +
                               mu_global_s(pointi.z))>>BITSH;
                point_[i].z =( -(mu_global_s(pointi.y)) +
                                 mu_global_c(pointi.z))>>BITSH;
                    }
    if(com == 0x33) {              /* spin z */
                point_[i].x =( mu_global_c(pointi.x)  +
                               mu_global_s(pointi.y))>>BITSH;
                point_[i].y =( mu_global_c(pointi.y)  -
                               mu_global_s(pointi.x))>>BITSH;
                    }
  

   }

                              /* draw and erase triangle */
  for(i=0;i<nlines;i++)
   { draw3dline(drawpt1[i],drawpt2[i],0);  /*erase */
     draw3dline(drawpt1[i]=point_[linefrom[i]],drawpt2[i]=point_[lineto[i]],color);
     /* draw it */
  }
   

}/* end of while */



} /* end of main */



/*******************************/

draw3dline(p1,p2,color)
point3d p1,p2;
int color;
{
 int x1,y1,x2,y2,z1,z2;

theport -> plane0 = color;

 /* project onto the xy plane */
 x1 = (p1.x>>BITSH-4) + x_offset;      
 y1 = (p1.y>>BITSH-4) + y_offset;
 x2 = (p2.x>>BITSH-4) + x_offset;
 y2 = (p2.y>>BITSH-4) + y_offset;


/* project onto xy plane */
a_line(x1,y1,x2,y2); 


/* project onto yz  plane */
z1 = (p1.z>>BITSH-4) + x_offset;
z2 = (p2.z>>BITSH-4) + x_offset;
a_line(z1-100,y1,z2-100,y2);

/* project onto the xz plane */
z1 = (p1.z>>BITSH-4) + y_offset;
z2 = (p2.z>>BITSH-4) + y_offset;
a_line(x1+100,z1,x2+100,z2);

 


}



/***************************************************************/
/* We will now modify the assembly mult. routine to be as efficient
   as possible. We will make 2 mult. routines, one to multiply 
   by a precomputed SINE value, and one to multiply by a precomputed
   COSINE value
   ************************************************************/

/*******************************************************/
/* Multiply 1 16 bit(GLOBAL) SIGNED number b by a precomputed 
   SINE value of 3 degrees (then the sine value was * SCALE where
   scale was 2048 )

  and return the 32 bit result in D0

   *** BIG NOTE:: b MUST be a GLOBAL var!!!!!!!!!!!!!!!!!

   * WARNING * No test is made on the overflow bit (V) to see if 
               the result in c is indeed correct. 

   Send arguments to this prodecure by: c=multiply(b) 
*/

long mu_global_s(b)
register long b;  /* extern variables so b is placed in D7,*/          
{
 asm
    { 
  
      muls   #107,b    /* generates  muls #107,d7 */
      move.l b,D0  /* generates   move.l A7,(A5) */
                    /* Note: You MUST specify the size (.l) cause
                             if you just write 'move b,d0' Laser
                             C will assume move.w as the default */
     
    }

}

/*************************************************
 multiplies a number 'b' by a precomputed COSINE value
 The Cos value is ===> cosine of 2 degrees * SCALE factor
 where scale factor is defined. In our case the precomputed cos value 
 is 2045 */

long mu_global_c(b)
register long b;  /* extern variable so b is placed in D7*/
{
 asm
    { 
  
      muls   #2045,b    /* generates  muls #2045,d7 */
      move.l b,D0  /* generates   move.l A7,(A5) */
                    /* Note: You MUST specify the size (.l) cause
                             if you just write 'move b,d0' Laser
                             C will assume move.w as the default */
     
    }

}



di(a,b)
register long int a,b;
{
 asm
    {
     move.l a,D0
     move.l b,D1
    }
}
