/* interactive 3-d rotating cube
   
   allows user to choose various options while displaying 
   a cube in 3 space


   code thrown together on 1-13-94 just to see if it'd work





		jmb8302@cs.tamu.edu     Jeffrey Bilger
*/


#include <osbind.h>
#include <gemdefs.h>
#include <math.h>
#include <linea.h>

int pts[4][2] = { 
	320, 050,
	120, 150,
	520, 150,
	320, 050
};
lineaport *theport;


#define M1 65536L
#define MF 65536.0
#define BITSH 16
#define PI 205887L
#define SPININC (PI >> 4)
#define addpt(p1,p2,p3) \
        { p3.x = p1.x + p2.x; \
          p3.y = p1.y + p2.y; \
          p4.z = p1.z + p2.z; }

#define cosf(x) (cos((double) x / M1))
#define sinf(x) (sin((double) x / M1))

typedef struct {double x,y,z;} point3d;

#define perx(p) \
        (perspective ? ((p.x/(p.z+pdist))*pdist):p.x)
#define pery(p) \
        (perspective ? ((p.y/(p.z+pdist))*pdist):p.y)



#define NPTS 64
#define NLINES 64
#define NFACES 64
#define I 100.0


point3d point_[NPTS] =
		{ -10.0,-10.0,10.0,   10.0,-10.0,10.0,  10.0,10.0,10.0,  -10.0,10.0,10.0,
           -10.0,-10.0,-10.0, 10.0,-10.0,-10.0, 10.0,10.0,-10.0, -10.0,10.0,-10.0 },
        drawpt1[NPTS],drawpt2[NPTS];
long spininc = SPININC >> 2;

int drawclr,
    white,
    glasses = 0,
    perspective = 0,
    npts  = 8,
    linefrom[NLINES] = {0,1,2,3,0,4,7,1,5,6,6,5},
    lineto[NLINES]   = {1,2,3,0,4,7,3,5,6,2,7,4},
    from[NLINES]     = {0,1,1,5,4,7,0,3,2,6,1,0},
    to[NLINES]       = {1,2,5,6,7,6,3,7,6,7,0,4},
    nlines = 12;

double pdist=200.0;

unsigned int pause = 8092;

int x_offset=320,y_offset=100;
double z_offset=1.0;


int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];

#define REZ 1                    /* 1 med, 0 low */
#define rnd(t) Random()%(t)   /*returns a number from 0 to (t-1) */

char	 temp_[32000],		             /* Temp buffer where file is read in	*/
         *hld,
		 *iff_in, *iff_out;	              /* Pointers for DEGAS unpack() routine	*/

#include <stdio.h>
int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];

char title[] ="rotate.pc2";
int savepal[16],newpal[16],junkbuff[46],pal2[16];
int filehandle,xoff,yoff,zoff;
unsigned form[37];

main()

{
    int save_rot;
    char *scr1,*scr2,*screen,*temp;
    int kill1;
    char a,string[20];    
  	MFDB	source;
	int		handle,status,x,y;
    register int i,j;
    point3d pointi;
    int color =3;
    double cos_2,sin_2;
    char com;
    int rect[4];
    int pl0,pl1,pl2,pl3;
    
	/*
		Start up ROM.
	*/
	appl_init();
	handle = open_workstation(&source);

    theport = a_init();     

   
	pl0=theport -> plane0;
	pl1=theport -> plane1;
	pl2=theport -> plane2;
	pl3=theport -> plane3;


	theport -> plane0 = 0;
	theport -> plane1 = 0;
	theport -> plane2 = 0;
	theport -> plane3 = 0;


    cos_2 = cos( (double) (5.0*3.141596/180.0));  /* precompute values */
    sin_2 = sin( (double) (5.0*3.141596/180.0));

   scr1 = malloc(32768+256);  /*allocate memory for 2nd screen */
    if ((long) scr1 & 0xff)
      scr1 = scr1 + (0x100 - (long)scr1 & 0xff);
  scr2 = malloc(32768+256);  /*allocate memory for 3rd screen */
    if ((long) scr2 & 0xff)
      scr2 = scr2 + (0x100 - (long)scr2 & 0xff);
screen = (char *)Physbase();
read_stuff(title,scr1,1);  /* read main title screen onto the temp scr*/
read_stuff(title,scr2,1);  /* read main title screen onto the temp scr*/


Setpalette(newpal);        /* tel sys to use these colors! */
Setscreen(scr1,scr1,-1);

graf_mouse(3,form);



for(i=0;i<npts;i++)
   {
   pointi = point_[i];
   point_[i].y =( pointi.y * cos_2  +
                pointi.z * sin_2);
   point_[i].z =( pointi.y * -sin_2 +
                pointi.z * cos_2);
   }


for(i=0;i<nlines;i++)  /* set up points-to-connect lookup table*/
{ drawpt1[i] = point_[linefrom[i]];
  drawpt2[i] = point_[lineto[i]];  
}


com = 0x31;  /* start out spinning y */


do{
    vq_mouse(handle,&status,&x,&y);
 if(status & 0x1)   com=pick(x,y);  /* left button pressed */    

 for(i=0;i<npts;i++)
   {
   pointi = point_[i];
   
    if(com == 0x31) {              /* spin y */
               point_[i].x =( pointi.x * cos_2  -
                              pointi.z * sin_2);
               point_[i].z =( pointi.x * sin_2 +
                              pointi.z * cos_2);
                    save_rot = com;
                    }
    if(com == 0x32) {              /* spin x */
                point_[i].y =( pointi.y * cos_2  +
                               pointi.z * sin_2);
                point_[i].z =( pointi.y * -sin_2 +
                               pointi.z * cos_2);
                     save_rot = com;
                    }
    if(com == 0x33) {              /* spin z */
                point_[i].x =( pointi.x * cos_2  +
                               pointi.y * sin_2);
                point_[i].y =( pointi.y * cos_2  -
                               pointi.x * sin_2);
                     save_rot = com;
                    }
    if(com == 0x37) point_[i].x+=xoff;      /* These will move the */
    if(com == 0x38) point_[i].y+=yoff;      /* object around in its */
    if(com == 0x39) point_[i].z+=zoff;      /* OWN co-ord sys!! Thus */
                                        /* changing these will effect*/
                                        /* how it rotates about the origin */
                                        /* The default is that the origin*/
                                        /* is at the CENTER of the object */

   }
      /* if perspective on/off picked */
if( com < 2) 
  {for(i=0;i<nlines;i++) draw3dline(drawpt1[i],drawpt2[i],0);/* erase */
   if (com == 1) perspective = 1;
   if (com == -1)perspective = 0;
  }

if( (com > 0x77 && com < 0x7b) || ( com > 0x57 && com < 0x5b) ) 
 {
    for(i=0;i<nlines;i++) draw3dline(drawpt1[i],drawpt2[i],0);
    if(com == 0x78) x_offset++;
    if(com == 0x79) y_offset++;
    if(com == 0x7a) z_offset+=0.2;
    if(com == 0x58) x_offset--;
    if(com == 0x59) y_offset--;
    if(com == 0x5a) z_offset-=0.2;
   com = 0x01; /* so that code below will execute */
 } 



if(com == 0x31 || com == 0x32 || com == 0x33 || com == 0x01 || com == 0x37 || com == 0x38 || com ==0x39)          /* if 1,2,3 chosen, then display it */
  for(i=0;i<nlines;i++)
    draw3dline(drawpt1[i],drawpt2[i],0);  /*erase */
  for(i=0;i<nlines;i++)
     draw3dline(drawpt1[i]=point_[linefrom[i]],drawpt2[i]=point_[lineto[i]],color);
     /* draw it */
  

/*
compute_normals();
*/


com = save_rot;



}while( !(status & 0x2) );


Setpalette(savepal);      /* restore palette */
	theport -> plane0 = pl0;
	theport -> plane1 = pl1;
	theport -> plane2 = pl2;
	theport -> plane3 = pl3;





	v_clsvwk(handle);
	appl_exit();

}

/***********************************/
int pick( x,y )
int x,y;

{
  if(y > 16 && y< 30) 
    if( x > 515 && x < 538 ) return 0x32;
    else if( x > 558 && x < 582 ) return 0x31;
    else if( x > 603 && x < 626 ) return 0x33;
  
   if(y > 58 && y< 73) 
    if( x > 530 && x < 553 ) {  return 1;}
    else if( x > 581 && x < 604 ) {  return -1;}
  
  if(y > 58 && y< 73) 
    if( x > 530 && x < 553 ) return 0x34;
    else if( x > 581 && x < 604 ) return 0x34;

  if(y > 97 && y< 111) 
    if( x > 528 && x < 564 ){ xoff = 1; return 0x37; }
    else if( x > 565 && x < 603 ) { xoff = -1; return 0x37; }

  if(y > 113 && y< 127) 
    if( x > 528 && x < 564 ){ yoff = 1; return 0x38; }
    else if( x > 565 && x < 603 ) { yoff = -1; return 0x38; }
   
    if(y > 129 && y< 143) 
    if( x > 528 && x < 564 ){ zoff = 1; return 0x39; }
    else if( x > 565 && x < 603 ) { zoff = -1; return 0x39; }

   if(y > 163 && y< 177) 
    if( x > 512 && x < 537 ) return 0x78;
    else if( x > 554 && x < 578 ) return 0x79;
    else if( x > 596 && x < 622 ) return 0x7a;

   if(y > 178 && y< 191) 
    if( x > 512 && x < 538 ) return 0x58;
    else if( x > 554 && x < 578 ) return 0x59;
    else if( x > 596 && x < 622 ) return 0x5a;

  
}


draw3dline(p1,p2,color)
point3d p1,p2;
int color;
{
 int x1,y1,x2,y2;

 x1 = (int)( perx(p1) *z_offset) +x_offset;
 y1 = (int)( pery(p1) *z_offset) +y_offset;
 x2 = (int)( perx(p2) *z_offset) +x_offset;
 y2 = (int)( pery(p2) *z_offset) +y_offset;
/*
printf(" %d,%d  %d,%d\n",x1,y1,x2,y2);
*/
 if( x1 > 501) x1 = 501; if( x1 < 0 ) x1 = 0;
 if( y1 > 199) y1 = 199; if( y1 < 0 ) y1 = 0;
 if( x2 > 501) x2 = 501; if( x2 < 0 ) x2 = 0;
 if( y2 > 199) y2 = 199; if( y2 < 0 ) y2 = 0;


    
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


/************************************/
/* load degas compressed pics */

/************************/
read_stuff(hold,adrr,which)
char hold[];
register char *adrr;
int which;  
/* if which = 1 then store palette into newpal*/
/* which is the main pal of the game. If = 0 then store */
/* into pal2. the alternate pal of the game */

{
 char buf[130];
 int lines,i;
 
 
 /*v_gtext(handle,1,5,"in read stuff");*/



filehandle = Fopen(hold,0); 

for(i=0; i<16;i++)
 savepal[i]=Setcolor(i,-1);
/* read header data */
i=Fread(filehandle,2L,buf);


/* read 16 words of palette data into newpal array */
if(which==0) i = Fread(filehandle,32L,pal2); /* save pal2 */
else
i =Fread(filehandle,32L,newpal);
 

 

i=Fread(filehandle,32000L,temp_);  /* read image onto back screen*/
/* Close file */
Fclose(filehandle);
	 lines = 200;		             /* Low, med-res	*/
				 iff_in  = temp_;                /* iff_in pts to temp_buf*/
			     iff_out = adrr;      /* iff_out pts to pic_buffer*/
			      do		
         unpack(REZ);			                          /* Unpack a line at a time */
			      while (--lines); 


 /*v_gtext(handle,1,5,"             ");*/

}
/************************/

/***********************/

/*---------------------------------------------------------------------------*/
/*					         |--------- DEGAS ---------|			*/
/*					          UNCOMPRESSED   COMPRESSED			*/
/*			     NEO  low med mono   low med mono	 TINY	*/
/*	typ...		0     1   2   3     4   5   6     7		*/

/* Unpacks a single scan line & updates iff_in & iff_out global pointers

                     /	byt ==  0 to  127  copy next [byt+1] bytes
Unpack routine --if-<	byt == -1 to -127  copy next byte [-byt+1] times
                     \	byt == 128         NO-OP							*/

unpack(rez)
int	 rez;

{
	register char	 *src_ptr, *dst_ptr,           /* ptrs to source/dest */
              byt, cnt;                     /* byt holds the ACTUAL compressed data code(control byte ) */
	register int	  minus128 = -128, 
              len;                          
	char			     linbuf[320];		                    /* Oversize just in case! */
	int				      llen;


	if (rez < 2)	 len = 160;
	else			 len = 80;
	llen = len;
	src_ptr = iff_in;           /* iff_in is ptr to compressed data */
	dst_ptr = &linbuf[0];       /* linbuf WILL hold an ENTIRE Uncompressed scan line. 4 bitplanes * 80 = 320 max! */ 

	while (len > 0)
   {
		    byt = *src_ptr++;       /* get byte value at address scr_ptr, THEN inc scr_ptr+1 */
		    if (byt >= 0)           /* If ctrl code >= 0 then use the next x+1 bytes*/
    {
			     ++byt;                 /* inc byt +1 */
			      do 
       {
				        *dst_ptr++ = *src_ptr++;  /* get byte value from address source, and inc the 2 ptrs */
				        --len;                    /* one byte down.. */
			       }
         while (--byt);           /* do this byt TIMES (remember byt here = byt+1 */
		     }
		     else 
       if (byt != minus128)       /* else if ctrl code NOT = -128*/
         {                        /*Then use the next byte -x+1 times, (-x) cause x will be negative and - - = + */
			          cnt = -byt + 1;         /* cnt = -x + 1 */
			          byt = *src_ptr++;       /* byt = THE very next byte past the ctrl code(or ctrl byte! */
			           do {
				               *dst_ptr++ = byt;  /* store that byte */
				               --len;         
			              }
               while (--cnt);    /* keep doing it cnt times */
		          }
	    }

	ilbm_st(linbuf, iff_out, rez);   /* convert the format line */
	iff_in = src_ptr;					                /* Update global pointers */
	iff_out += llen;

}                                /* end of module uncompress() */

/*---------------------------------------------------------------------------*/

ilbm_st(src_ptr, dst_ptr, rez)		   /* Convert ILBM format line to ST format */
int		 *src_ptr, *dst_ptr, rez;
{
	int		 x, *p0_ptr, *p1_ptr, *p2_ptr, *p3_ptr;

	if (rez==0) 
 {				                                     /* Low-res */
  
		p0_ptr = src_ptr;
		p1_ptr = src_ptr + 20;
		p2_ptr = src_ptr + 40;
		p3_ptr = src_ptr + 60;
		for (x=0; x<20; ++x)
  {
			   *dst_ptr++ = *p0_ptr++;
			   *dst_ptr++ = *p1_ptr++;
			   *dst_ptr++ = *p2_ptr++;
			   *dst_ptr++ = *p3_ptr++;
		  }
	} 
 else if (rez==1) 
  {		                                    /* Med-res */
		   p0_ptr = src_ptr;
		   p1_ptr = src_ptr + 40;
		   for (x=0; x<40; ++x)
    {
			     *dst_ptr++ = *p0_ptr++;
			     *dst_ptr++ = *p1_ptr++;
		    }
	}
    else 
     {					                               /* Monochrome */
		      for (x=0; x<40; ++x)
			      *dst_ptr++ = *src_ptr++;
	     }
 
 }
/*---------------------------------------------------------------------------*/

