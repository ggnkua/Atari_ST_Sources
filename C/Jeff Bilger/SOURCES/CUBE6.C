/* Will spin a box in 3d space. 

   o ) User can controll x,y,z rotation by keys 1,2 or 3
   o ) Perspective viewing 
   o ) Movement of object in its Object-Coords relative to its origin
       (Default is origin at center of object, so any rotation will
        just make it 'spin' in the x,y,z direction...rather booring
        So change its co-ords w/ respect to its origin to get cool
        tumbling rotations)
   o ) Movement of camera. You can move the camera in the x,y or z
       direction. (ie. You can move to the left or right of the object
                       or you can view it close up or far away )
  
   Jan. 8 ,1994  jeff bilger 

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


#define SCALE 8192L       /* so far 2048 is the upper bounds scale
                              i can get W/O overflow */
#define MF 65536.0
#define BITSH 13
#define PI 205887L
#define SPININC (PI >> 4)
#define addpt(p1,p2,p3) \
        { p3.x = p1.x + p2.x; \
          p3.y = p1.y + p2.y; \
          p4.z = p1.z + p2.z; }

#define cosf(x) (cos((double) x / M1))
#define sinf(x) (sin((double) x / M1))

typedef struct {long x,y,z;} point3d;

#define perx(p) \
        (perspective ? ((p.x/(p.z+pdist))*pdist):p.x)
#define pery(p) \
        (perspective ? ((p.y/(p.z+pdist))*pdist):p.y)



#define NPTS 64
#define NLINES 64
#define NFACES 64


#define I ( SCALE * 10 )

point3d point_[NPTS] =
		{ -I,-I,I,   I,-I,I,  I,I,I,  -I,I,I,
           -I,-I,-I, I,-I,-I, I,I,-I, -I,I,-I },
        drawpt1[NPTS],drawpt2[NPTS];

long spininc = SPININC >> 2;

int drawclr,
    white,
    glasses = 0,
    perspective = 1,
    npts  = 8,
    linefrom[NLINES] = {0,1,2,3,0,4,7,1,5,6,6,5},
    lineto[NLINES]   = {1,2,3,0,4,7,3,5,6,2,7,4},
    from[NLINES]     = {0,1,1,5,4,7,0,3,2,6,1,0},
    to[NLINES]       = {1,2,5,6,7,6,3,7,6,7,0,4},
    nlines = 12;

double pdist=200.0;

unsigned int pause = 8092;

int x_offset=320,y_offset=100,z_offset=1;


main()
{
register int i,j;
point3d pointi;
int color =1;
long cos_2,sin_2;
char com;

cos_2 = (cos( (double) (5.0*3.141596/180.0))) * SCALE;  /* precompute values */
sin_2 = (sin( (double) (5.0*3.141596/180.0))) * SCALE;

/*
printf("%ld\n",sin_2);
printf("%ld\n",cos_2);
*/

printf(" 1-Spin Y  2-Spin X  3-Spin Z\n");
printf(" 4-Perspective ON/OFF\n");
printf(" Move object (x,y,z) -> 7,8,9\n");
printf(" Move view   x/X,y/Y,z/Z\n");
theport = a_init();     
   

	theport -> plane0 = 1;
	theport -> plane1 = 0;
	theport -> plane2 = 0;
	theport -> plane3 = 0;

/*
printf("1...%ld\n",point_[2].y * cos_2 +point_[2].z * sin_2 );
printf("2...%ld\n",point_[2].y * -sin_2 +point_[2].z * cos_2 );
*/


 for(i=0;i<npts;i++)
   {
   pointi = point_[i];
   point_[i].y =( pointi.y * cos_2  +
                pointi.z * sin_2)>>BITSH;   /* scale is 2048 or 2^BITSH */
   point_[i].z =( pointi.y * -sin_2 +    /* so divide by scale */
                pointi.z * cos_2)>>BITSH;
   }
/*printf("1...%ld\n",point_[2].y>>BITSH);
printf("2...%ld\n",point_[2].z>>BITSH);
*/





for(i=0;i<nlines;i++)  /* set up points-to-connect lookup table*/
{ drawpt1[i] = point_[linefrom[i]];
  drawpt2[i] = point_[lineto[i]];  
}

/*
printf("%ld,%ld,%ld\n",point_[2].x,point_[2].y,point_[2].z);
*/

while(1)
{
 com = 0x31;

 for(i=0;i<npts;i++)
   {
   pointi = point_[i];
   
    if(com == 0x31) {              /* spin y */
               point_[i].x =( pointi.x * cos_2  -
                              pointi.z * sin_2)>> BITSH;
               point_[i].z =( pointi.x * sin_2 +
                              pointi.z * cos_2)>> BITSH;
                    }
    if(com == 0x32) {              /* spin x */
                point_[i].y =( pointi.y * cos_2  +
                               pointi.z * sin_2)>> BITSH;
                point_[i].z =( pointi.y * -sin_2 +
                               pointi.z * cos_2)>> BITSH;
                    }
    if(com == 0x33) {              /* spin z */
                point_[i].x =( pointi.x * cos_2  +
                               pointi.y * sin_2)>> BITSH;
                point_[i].y =( pointi.y * cos_2  -
                               pointi.x * sin_2)>> BITSH;
                    }
    if(com == 0x37) point_[i].x++;      /* These will move the */
    if(com == 0x38) point_[i].y++;      /* object around in its */
    if(com == 0x39) point_[i].z++;      /* OWN co-ord sys!! Thus */
                                        /* changing these will effect*/
                                        /* how it rotates about the origin */
                                        /* The default is that the origin*/
                                        /* is at the CENTER of the object */

   }

if( (com > 0x77 && com < 0x7b) || ( com > 0x57 && com < 0x5b) ) 
 {
    for(i=0;i<nlines;i++) draw3dline(drawpt1[i],drawpt2[i],0);
    if(com == 0x78) x_offset++;
    if(com == 0x79) y_offset++;
    if(com == 0x7a) z_offset++;
    if(com == 0x58) x_offset--;
    if(com == 0x59) y_offset--;
    if(com == 0x5a) z_offset--;
   com = 0x36; /* so that code below will execute */
 } 

if(com < 0x37)          /* if 1,2,3 chosen, then display it */
  for(i=0;i<nlines;i++)
   { draw3dline(drawpt1[i],drawpt2[i],0);  /*erase */
     draw3dline(drawpt1[i]=point_[linefrom[i]],drawpt2[i]=point_[lineto[i]],color);
     /* draw it */
  }
   
/*
compute_normals();
*/

if(com == 0x34) perspective = perspective ^ 1;
}

}
draw3dline(p1,p2,color)
point3d p1,p2;
int color;
{
 int x1,y1,x2,y2;

/*
printf("==> %ld,%ld,%ld\n",p1.x/SCALE,p1.y/SCALE,p1.z/SCALE);

 x1 = (( (int)( perx(p1) )*z_offset) +x_offset) / SCALE;
 y1 = (( (int)( pery(p1) )*z_offset) +y_offset) / SCALE;
 x2 = (( (int)( perx(p2) )*z_offset) +x_offset) / SCALE;
 y2 = (( (int)( pery(p2) )*z_offset) +y_offset) / SCALE;
*/
 x1 = (p1.z>>12) + x_offset;       /* divide by scale ie: shift left BITSH bits == divide by 2048 */
 y1 = (p1.y>>12) + y_offset;
 x2 = (p2.z>>12) + x_offset;
 y2 = (p2.y>>12) + y_offset;


/*
printf(" %d,%d  %d,%d\n",x1,y1,x2,y2);
*/
 theport -> plane0 = color;

a_line(x1,y1,x2,y2); 

}

mu(a,b)
register long int a,b;
{
 asm
    {
     move.l a,D0
     move.l b,D1
     muls   D0,D1
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



compute_normals()
{
 point3d A,B;
 int h;
  double An,Bn,ycomp;

 for(h=0;h<6;h++)
   {
    A.x = point_[to[h]].x - point_[from[h]].x;
    A.z = point_[to[h]].z - point_[from[h]].z;
    A.y = point_[to[h]].y - point_[from[h]].y;
    B.x = point_[to[h+1]].x - point_[from[h+1]].x;
    B.z = point_[to[h+1]].z - point_[from[h+1]].z;
    B.y = point_[to[h+1]].y - point_[from[h+1]].y;

    An = sqrt(A.x*A.x+A.z*A.z+A.y*A.y);
    Bn = sqrt(B.x*B.x+B.z*B.z+B.y*B.y);
     A.x = A.x / An;
    A.z = A.z / An;
    B.x = B.x / Bn;
    B.z = B.z / Bn;
   
    ycomp = A.z*B.x - A.x*B.z;
    
   }

}
