/*
 *
 *
 *
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "types.h"

static short z_buffer[MAX_X*MAX_Y];
static int translated_crds[MAX_CRDS][3];
static int normals[MAX_CRDS][3];
static int perspected_crds[MAX_CRDS][3];
static int L[3],V[3];
static int wibble = 0;
static int shape = 1;
extern unsigned char *screen_ptr;

/*
 *	Compute Intensity given a unit normal.
 */

#define COL_RANGE 128

/* Ks * ((2N (N.L) - L) . V))^n 
   n  = specular reflection exponent 
   Ks = specular reflection co-efficient */
/*		double t = ( (double)( (((i*2*N_L)>>LBITS)-L[0])*V[0])+	\
		      	     ( (((j*2*N_L)>>LBITS)-L[1])*V[1])+	\
	       		     ( (((k*2*N_L)>>LBITS)-L[2])*V[2])	\
			)/(LSCALE*LSCALE);			\
		int spec = t / ( t - 3000*t + 3000)*LSCALE;	\
*/

#define light_model(i,j,k,in)  	 				\
	{							\
		int N_L = (i*L[0]+j*L[1]+k*L[2])>>LBITS;	\
		int spec = 0;					\
		int intens = (N_L+(spec*16))/(LSCALE/COL_RANGE); \
		if (intens < 0)	intens = 0;			\
		if (intens > COL_RANGE-1) intens = COL_RANGE-1;	\
		in = intens;					\
	}						

void Draw_Poly_Object(int *obj,int xang,int yang,int zang,int xoff,int yoff,int zoff)
{	int i,n = *obj++;
      	view_matrix(xang,yang,zang);
        trans (n, obj, &translated_crds[0][0],xoff,yoff,zoff);
        pers  (n,&translated_crds[0][0], &perspected_crds[0][0]);
	obj += (n+n+n);
	n = *obj++;
        trans (n, obj, &normals[0][0],0,0,0);
	obj += (n+n+n);

	for (i=0; i<n; i++)
	{	light_model(normals[i][0],normals[i][1],normals[i][2],normals[i][0]);
		normals[i][1] = 0;
		normals[i][2] = 0;
		
	}	

	n = *obj++;
	for (i=0; i<n; i++)
        {       int np = *obj++;
		int i1 = *(obj+0), i2 = *(obj+1), i3 = *(obj+2);
		int x1 = *(&(perspected_crds[0][0])+i1);
		int y1 = *(&(perspected_crds[0][1])+i1);
		int x2 = *(&(perspected_crds[0][0])+i2);
		int y2 = *(&(perspected_crds[0][1])+i2);
		int x3 = *(&(perspected_crds[0][0])+i3);
		int y3 = *(&(perspected_crds[0][1])+i3);
		if ( ((x1-x2)*(y2-y3))-((y1-y2)*(x2-x3)) > 0) 
		{
                	draw_poly(np,obj,&perspected_crds[0][0],&normals[0][0]);
		}
		obj += np;
        }
}

/*
 *
 */

void interpolate(int v1,int v2,int d,int store[])
{	register int grad,i;	
	v1 <<= BITS;	v2 <<= BITS;
	if (d > 0)
	{	grad = (v2 - v1) / d;
		for (i = d;--i>=0;)
		{	*store++ = v1;
			v1 += grad;
		}
	}
	*store = v1;
}

static int xc1[MAX_Y+10], xc2[MAX_Y+10];
static int zc1[MAX_Y+10], zc2[MAX_Y+10];
static int ic1[MAX_Y+10], ic2[MAX_Y+10];
static int jc1[MAX_Y+10], jc2[MAX_Y+10];
static int kc1[MAX_Y+10], kc2[MAX_Y+10];
static int expanded[256];

void draw_poly2(int n,int polylist[],int coords[],int normls[])
{ 	int n6=n*6,i,e_dy,dy,dy2;
    	int *dup1 = &expanded[0], *dup2 = &expanded[n6];
    	int *index1 = coords+polylist[0];
	int *index2 = normls+polylist[0];
	int y1=index1[1];
	int max_y = y1, min_y = y1;
    	int *left, *right = dup1;
	dup1[0] = index1[0]; dup1[1] = y1; dup1[2] = index1[2];
	dup2[0] = index1[0]; dup2[1] = y1; dup2[2] = index1[2];
	dup1[3] = index2[0]; dup1[4] = index2[1]; dup1[5] = index2[2];
	dup2[3] = index2[0]; dup2[4] = index2[1]; dup2[5] = index2[2];
	for (i = 1 ; i < n ; i++)
	{	dup1+=6;dup2+=6;
	 	index1 = coords+polylist[i];
		index2 = normls+polylist[i];
		y1=index1[1];
	    	dup1[0] = index1[0]; dup1[1] = y1; dup1[2] = index1[2];
		dup2[0] = index1[0]; dup2[1] = y1; dup2[2] = index1[2];
		if (y1 >= max_y) { max_y = y1; }
		if (y1 <= min_y) { min_y = y1; right = dup1; }
		dup1[3] = index2[0]; dup1[4] = index2[1]; dup1[5] = index2[2];
		dup2[3] = index2[0]; dup2[4] = index2[1]; dup2[5] = index2[2];
	}
	dy = max_y - min_y;	
	left = right+n6;

	/* Scan convert left edge */

	e_dy = dy;
	while (e_dy > 0)
	{	left -= 6;
		y1 = left[7]; dy2 = left[1]-y1;
		interpolate(left[6],left[0],dy2,&xc1[y1]);
		interpolate(left[8],left[2],dy2,&zc1[y1]);
		interpolate(left[9],left[3],dy2,&ic1[y1]);
		interpolate(left[10],left[4],dy2,&jc1[y1]);
		interpolate(left[11],left[5],dy2,&kc1[y1]);
		e_dy -= dy2;
	}	

	/* Scan convert right edge */

	e_dy = dy;
	while (e_dy > 0)
	{	y1 = right[1]; dy2 = right[7]-y1;
		interpolate(right[0],right[6],dy2,&xc2[y1]);
		interpolate(right[2],right[8],dy2,&zc2[y1]);
		interpolate(right[3],right[9],dy2,&ic2[y1]);
		interpolate(right[4],right[10],dy2,&jc2[y1]);
		interpolate(right[5],right[11],dy2,&kc2[y1]);
	    	right +=6;
		e_dy -= dy2;
	}

	{
	char *li_ptr = screen_ptr + (min_y*MAX_X);
	short *zi_ptr = z_buffer   + (min_y*MAX_X);
	for (i = min_y ; i <= max_y ; i++)
	{ 	int x1 = xc1[i]>>BITS;
		int x2 = xc2[i]>>BITS;
		int z1 = zc1[i];
		int l1 = ic1[i];
	  	int m1 = jc1[i];
		int n1 = kc1[i];
		int dx = (x2-x1)+1;
		if (x2>=x1)
		{ 	register int x;
			int dZ = (zc2[i] - z1) / dx;
			int dL = ((ic2[i] - l1)) / dx;
			int dM = ((jc2[i] - m1)) / dx;
			int dN = ((kc2[i] - n1)) / dx;
			for (x = x1 ; x <= x2 ; x++)
			{	short z = z1 >> BITS;
				if ( z < zi_ptr[x] )
				{	int nd;
				    	int l2 = l1>>(BITS+3);
					int m2 = m1>>(BITS+3);
					int n2 = n1>>(BITS+3);
				    	if (l2<0) l2=-l2;
					if (m2<0) m2=-m2;
					if (n2<0) n2=-n2;
					if (l2>m2) { int t=m2; m2=l2; l2=t;}
					if (m2>n2) { int t=n2; n2=m2; m2=t;}
					if (l2>m2) { int t=m2; m2=l2; l2=t;}
					nd = ((n2<<5)+(m2*11)+(l2<<3));
					l2 = (l1)/nd;
					m2 = (m1)/nd;
					n2 = (n1)/nd;
					light_model(l2,m2,n2,li_ptr[x]);
					zi_ptr[x] = z;
				}
				l1 += dL; m1 += dM; n1 += dN; z1 += dZ;
			}
		}
		li_ptr += MAX_X;
		zi_ptr += MAX_X;
	}
	}
}

/*
 *
 *	Gouraud Poly Routine.
 *
 */
 
void draw_poly(int n,int polylist[],int coords[],int normls[])
{ 	int n6=n*6,i,e_dy,dy,dy2;
    	int *dup1 = &expanded[0], *dup2 = &expanded[n6];
    	int *index1 = coords+polylist[0];
	int *index2 = normls+polylist[0];
	int y1=index1[1];
	int max_y = y1, min_y = y1;
    	int *left, *right = dup1;
	dup1[0] = index1[0]; dup1[1] = y1; dup1[2] = index1[2];
	dup2[0] = index1[0]; dup2[1] = y1; dup2[2] = index1[2];
	dup1[3] = index2[0]; 
	dup2[3] = index2[0];
	for (i = 1 ; i < n ; i++)
	{	dup1+=6;dup2+=6;
	 	index1 = coords+polylist[i];
		index2 = normls+polylist[i];
		y1=index1[1];
	    	dup1[0] = index1[0]; dup1[1] = y1; dup1[2] = index1[2];
		dup2[0] = index1[0]; dup2[1] = y1; dup2[2] = index1[2];
		if (y1 >= max_y) { max_y = y1; }
		if (y1 <= min_y) { min_y = y1; right = dup1; }
		dup1[3] = index2[0]; 
		dup2[3] = index2[0];
	}
	dy = max_y - min_y;	
	left = right+n6;

	/* Scan convert left edge */

	e_dy = dy;
	while (e_dy > 0)
	{	left -= 6;
		y1 = left[7]; dy2 = left[1]-y1;
		interpolate(left[6],left[0],dy2,&xc1[y1]);
		interpolate(left[8],left[2],dy2,&zc1[y1]);
		interpolate(left[9],left[3],dy2,&ic1[y1]);
		e_dy -= dy2;
	}	

	/* Scan convert right edge */

	e_dy = dy;
	while (e_dy > 0)
	{	y1 = right[1]; dy2 = right[7]-y1;
		interpolate(right[0],right[6],dy2,&xc2[y1]);
		interpolate(right[2],right[8],dy2,&zc2[y1]);
		interpolate(right[3],right[9],dy2,&ic2[y1]);
	    	right +=6;
		e_dy -= dy2;
	}

	{
	char *li_ptr = screen_ptr + (min_y*MAX_X);
	short *zi_ptr = z_buffer   + (min_y*MAX_X);
	for (i = min_y ; i <= max_y ; i++)
	{ 	int x1 = xc1[i]>>BITS;
		int x2 = xc2[i]>>BITS;
		int z1 = zc1[i];
		int i1 = ic1[i];
		int dx = (x2-x1)+1;
		if (x2>=x1)
		{	register char *xp;
		    	register short *zp;
			int dI = (ic2[i] - i1) / dx;
			int dZ = (zc2[i] - z1) / dx;
			for (zp = &zi_ptr[x1],xp=&li_ptr[x1];xp<=&(li_ptr[x2]) ; xp++,zp++)
			{ 	if ( (z1>>BITS) < *zp)
				{	*zp=z1>>BITS;
					*xp=i1>>BITS;
				}
				z1 += dZ; i1 += dI;
			}
		}
		li_ptr += MAX_X;
		zi_ptr += MAX_X;
	}
	}
}

void clear_zbuffer()
{	 memset(&z_buffer[0],0x7f,MAX_X*MAX_Y*2);
}

extern int Cube[];
extern int Cube2[];
extern int Pyramid[];
extern int Station[];

void test(void)
{	int L2[3],L1[3]  = { 0,0,-LSCALE };
	clear_zbuffer();
	ClearDisplay();
      	/*view_matrix(wibble,wibble*2,wibble*3);*/
      	view_matrix(0,0,0);
	trans(1,&L1[0],&L2[0],0,0,0);
	V[0] = L[0] = L2[0];
	V[1] = L[1] = L2[1];
	V[2] = L[2] = L2[2];
	switch (shape)
	{	case 1: Draw_Poly_Object(Station,wibble,wibble,900, 0,0,640);
	    		Draw_Poly_Object(Cube,wibble>>1,0,wibble, 0,0,640);
			break;
	    	case 2: Draw_Poly_Object(Cube,wibble,wibble,900, 0,0,940);
			break;
		case 3: Draw_Poly_Object(Station,wibble,wibble,900, 0,0,940);
			break;
	}
	WaitVBL();
	//L2[0] = (L2[0] * (MAX_X/3)) >> LBITS;
	//L2[1] = (L2[1] * (MAX_X/3)) >> LBITS;
	//L2[2] = (L2[2] * (MAX_X/3)) >> LBITS;
        //pers  (1,&L2[0], &L2[0]);
	//DrawLine((MAX_X/2),(MAX_Y/2),L2[0],L2[1],127);
	UpdateDisplay();
}


int main(int argc,char **argv)
{	if (argc == 2)
    		shape = atoi(argv[1]);
    	InitDisplay("");
	init_3d();
	while (!kbhit())
	{	
		test();
		wibble +=32;
	}
	CloseDisplay();
	return 0;
}
