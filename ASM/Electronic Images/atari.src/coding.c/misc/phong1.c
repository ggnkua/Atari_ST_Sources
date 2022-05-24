/*
 *		Phong/Gouraud Object Shading Routines.
 *
 *		Martin Griffiths June 1994
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include "types.h"

extern unsigned char *screen_ptr;
short z_buffer[MAX_X*MAX_Y];
static int translated_crds[MAX_CRDS][3];
static int normals[MAX_CRDS][3];
static int perspected_crds[MAX_CRDS][3];
int scan[MAX_X+10][16];
static int L[3],V[3];
static int ox=0,oy=0,oz=640;
static int rx=0,ry=0,rz=0,drx=0,dry=0,drz=0;
static int lxa=0,lya=0,lza=0,dlxa=0,dlya=0,dlza=0;
static int shape = 0;
int timingflag = 0;

/*
 *	Compute Intensity given a unit normal.
 */

#define COL_RANGE 128

/* Ks * ((2N (N.L) - L) . V))^n 
   n  = specular reflection exponent 
   Ks = specular reflection co-efficient */
/*
#define light_model(i,j,k,in)  	 				\
	{	float i1 = (float) i/LSCALE;			\
		float j1 = (float) j/LSCALE;			\
		float k1 = (float) k/LSCALE;			\
		float N_L = (i*L[0]+j*L[1]+k*L[2])/LSCALE;	\
		float t = (    ( ((i1*2*N_L))-L[0])*V[0]+	\
		      	       ( ((j1*2*N_L))-L[1])*V[1]+	\
	       		       ( ((k1*2*N_L))-L[2])*V[2]	\
			)/(LSCALE*LSCALE);			\
		int spec = (t/(t-(50*t)+50)*LSCALE);		\
		int intens = (N_L+(spec))/(LSCALE/COL_RANGE); 	\
		if (intens < 0)	intens = 0;			\
		if (intens > COL_RANGE-1) intens = COL_RANGE-1;	\
		in = intens;					\
	}
*/

#define light_model(i,j,k,in)  	 				\
	{ 	int N_L = (i*L[0]+j*L[1]+k*L[2])>>LBITS;	\
		int spec = 0;					\
		int intens = (N_L+spec)/(LSCALE/COL_RANGE); 	\
		if (intens<0) intens = 0;			\
		if (intens>=COL_RANGE-1) intens = COL_RANGE-1;	\
		in = intens;					\
	}

//		int t = (  (((i*2*N_L)>>LBITS)-L[0])*V[0]+	\
//		      	   (((j*2*N_L)>>LBITS)-L[1])*V[1]+	\
//	       		   (((k*2*N_L)>>LBITS)-L[2])*V[2]	\
//			);					\
// int t1 = t>>LBITS;				\
// int spec = (t/(t1-(32*t1)+(32<<LBITS)))/(LSCALE/COL_RANGE);	\

void Draw_Point_XYZ(short x1,short y1,short z1,char c)
{	short *zp = &z_buffer[(MAX_X*y1)+x1];
    	if (z1 < *zp)
    	{	*zp = z1;
    		PlotPixelX(x1,y1,c);
	}
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

void Draw_Dot_Object(int *obj,int xang,int yang,int zang,int xoff,int yoff,int zoff)
{	int i,n = *obj++;
      	view_matrix(xang,yang,zang);
        trans (n, obj, &translated_crds[0][0],xoff,yoff,zoff);
        pers  (n,&translated_crds[0][0], &perspected_crds[0][0]);
	for (i=0; i<n; i++)
        { 	short x1 = perspected_crds[i][0];
		short y1 = perspected_crds[i][1];
		PlotPixelX(x1,y1,63);
        }
}

/*
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
*/

#pragma aux interpolate parm [ebx] [eax] [ecx] [edi] modify [eax ebx ecx edx edi];

enum scant { xc1=0,zc1,ic1,jc1,kc1,xc2,zc2,ic2,jc2,kc2,mx1,mx2,m3,m4,m5,MXMP };

static int expanded[2*16*8];

void init_scan_consts(void)
{	int i;
    	for (i=0 ; i<MAX_X; i++)
	{ 	unsigned short mask = (256 << (i & 3)) + 2;
	    	scan[i][MXMP] = (mask << 16) | (i>>2);
	}
}

void draw_poly2(int n,int polylist[],int coords[],int normls[])
{ 	int n6=n*6,i,e_dy,dy,dy2;
    	int *dup1 = &expanded[0], *dup2 = &expanded[n6];
    	int *index1 = coords+polylist[0];
	int *index2 = normls+polylist[0];
	int y1=index1[0];
	int max_y = y1, min_y = y1;
   	int *left, *right = dup1;
    	dup1[0] = y1;        dup2[0] = y1;
	dup1[1] = index1[1]; dup2[1] = index1[1];
	dup1[2] = index1[2]; dup2[2] = index1[2];
	dup1[3] = index2[0]; dup2[3] = index2[0];
	dup1[4] = index2[1]; dup2[4] = index2[1];
	dup1[5] = index2[2]; dup2[5] = index2[2];
	for (i = 1 ; i < n ; i++)
	{	dup1+=6;dup2+=6;
	 	index1 = coords+polylist[i];
		index2 = normls+polylist[i];
		y1=index1[0];
		if (y1 >= max_y) { max_y = y1; }
		if (y1 <= min_y) { min_y = y1; right = dup1; }
	    	dup1[0] = y1;        dup2[0] = y1;
		dup1[1] = index1[1]; dup2[1] = index1[1];
		dup1[2] = index1[2]; dup2[2] = index1[2];
		dup1[3] = index2[0]; dup2[3] = index2[0];
		dup1[4] = index2[1]; dup2[4] = index2[1];
		dup1[5] = index2[2]; dup2[5] = index2[2];
	}
	dy = max_y - min_y;	
	left = right+n6;

	e_dy = dy;
	while (e_dy > 0)
	{	left -= 6;
		y1 = left[6]; dy2 = left[0]-y1;
		e_dy -= dy2;
		interpolate(left[7],left[1],dy2,&scan[y1][xc2]);
		interpolate(left[8],left[2],dy2,&scan[y1][zc2]);
		interpolate(left[9],left[3],dy2,&scan[y1][ic2]);
		interpolate(left[10],left[4],dy2,&scan[y1][jc2]);
		interpolate(left[11],left[5],dy2,&scan[y1][kc2]);
	}	

	e_dy = dy;
	while (e_dy > 0)
	{	y1 = right[0]; dy2 = right[6]-y1;
		e_dy -= dy2;
		interpolate(right[1],right[7],dy2,&scan[y1][xc1]);
		interpolate(right[2],right[8],dy2,&scan[y1][zc1]);
		interpolate(right[3],right[9],dy2,&scan[y1][ic1]);
		interpolate(right[4],right[10],dy2,&scan[y1][jc1]);
		interpolate(right[5],right[11],dy2,&scan[y1][kc1]);
	    	right +=6;
	}

	{
	short *zi_ptr = z_buffer + min_y;
	register int *in;
	for (in = &scan[min_y][0] ; in <= &scan[max_y][0] ; in+=16)
	{ 	int x1 = in[xc1]>>16;
		int x2 = in[xc2]>>16;
		int dx = (x2-x1)+1;
		if (dx>0)
		{ 	int x;
			int z1 = in[zc1];
			int l1 = in[ic1];
	  		int m1 = in[jc1];
			int n1 = in[kc1];
			int dZ = (in[zc2] - z1) / dx;
			int dL = ((in[ic2] - l1)) / dx;
			int dM = ((in[jc2] - m1)) / dx;
			int dN = ((in[kc2] - n1)) / dx;
			for (x = x1*(MAX_X>>2) ; x <= x2*(MAX_X>>2) ; x+=(MAX_X>>2))
			{	short z = z1>>16;
				//if ( z < zi_ptr[x] )
				{	int nd;
				    	int l2 = l1>>5;
					int m2 = m1>>5;
					int n2 = n1>>5;
					//zi_ptr[x] = z;
					outpw(SC_INDEX,in[MXMP]>>16);
					l2 = abs(l2); m2 = abs(m2); n2 = abs(n2);
					if (l2>m2) { int t=m2; m2=l2; l2=t;}
					if (m2>n2) { int t=n2; n2=m2; m2=t;}
					if (l2>m2) { int t=m2; m2=l2; l2=t;}
					nd = ((n2<<5)+(m2*11)+(l2<<3))>>(16-(16-LBITS));
					l2 = l1/nd; m2 = m1/nd; n2 = n1/nd;
					light_model(l2,m2,n2, *(screen_ptr+x+(in[MXMP]&0x0000ffff)) );
				}
				l1 += dL; m1 += dM; n1 += dN; z1 += dZ;
			}
		}
		zi_ptr++;
	}
	}
}

/*
 *	Gouraud Poly Routine.
 */
 
void draw_poly(int n,int polylist[],int coords[],int normls[])
{ 	int n6=n*6,i,dy,dy2;
    	int *dup1 = &expanded[0], *dup2 = &expanded[n6];
    	int *index1 = coords+polylist[0];
	int *index2 = normls+polylist[0];
	int y1=index1[0];
	int max_y = y1, min_y = y1;
    	int *left, *right = dup1;
	dup1[0] = y1; dup1[1] = index1[1]; dup1[2] = index1[2];
	dup2[0] = y1; dup2[1] = index1[1]; dup2[2] = index1[2];
	dup1[3] = index2[0]; 
	dup2[3] = index2[0];
	for (i = 1 ; i < n ; i++)
	{	dup1+=6;dup2+=6;
	 	index1 = coords+polylist[i];
		index2 = normls+polylist[i];
		y1=index1[0];
	    	dup1[0] = y1; dup1[1] = index1[1]; dup1[2] = index1[2];
		dup2[0] = y1; dup2[1] = index1[1]; dup2[2] = index1[2];
		if (y1 >= max_y) { max_y = y1; }
		if (y1 <= min_y) { min_y = y1; right = dup1; }
		dup1[3] = index2[0]; dup2[3] = index2[0];
	}
	left = right+n6;

	/* Scan convert left edge */

	dy = max_y - min_y;	
	do
	{	left -= 6; y1 = left[6]; dy2 = left[0]-y1;
		interpolate(left[7],left[1],dy2,&scan[y1][xc2]);
		interpolate(left[8],left[2],dy2,&scan[y1][zc2]);
		interpolate(left[9],left[3],dy2,&scan[y1][ic2]);
		dy -= dy2;
	} while (dy > 0);

	/* Scan convert right edge */

	dy = max_y - min_y;	
	do
	{	y1 = right[0]; dy2 = right[6]-y1;
		interpolate(right[1],right[7],dy2,&scan[y1][xc1]);
		interpolate(right[2],right[8],dy2,&scan[y1][zc1]);
		interpolate(right[3],right[9],dy2,&scan[y1][ic1]);
	    	right +=6; dy -= dy2;
	} while (dy > 0);

#pragma aux rend_gourpoly parm [eax] [ebx] modify [eax ebx ecx edx edi esi];
	rend_gourpoly(min_y,max_y);
//#pragma aux rend_poly parm [eax] [ebx] modify [eax ebx ecx edx edi esi];
//	rend_poly(min_y,max_y);
}

extern int Pyramid[],Cube[],Cube2[],Station[],Asteriod[];
int *Sphere;

void SetLightSource(int lxang,int lyang,int lzang)
{ 	int L1[3]  = { 0,0,-LSCALE };
	int L2[3];
      	view_matrix(lxang,lyang,lzang);
	trans(1,&L1[0],&L2[0],0,0,0);
	V[0] = L[0] = L2[0];
	V[1] = L[1] = L2[1];
	V[2] = L[2] = L2[2];
	L2[0] = (L2[0]*MAX_X) >> (LBITS+2);
	L2[1] = (L2[1]*MAX_X) >> (LBITS+2);
	L2[2] = (L2[2]*MAX_X) >> (LBITS+2);
        pers  (1,&L2[0], &L2[0]);
	Draw_Point_XYZ(L2[0],L2[1],L[2],127);
}

void test(void)
{ 	ClearDisplay();
	SetLightSource(lxa,lya,lza);
	switch (shape)
	{	case 0: Draw_Poly_Object(Sphere,rx,ry,rz,ox,oy,oz);
			break;
		case 1: Draw_Poly_Object(Pyramid,rx,ry,rz,ox,oy,oz);
			break;
	    	case 2: Draw_Poly_Object(Cube,rx,ry,rz,ox,oy,oz);
			break;
		case 3: Draw_Poly_Object(Station,rx,ry,rz,ox,oy,oz);
			break;
	    	case 4:	Draw_Poly_Object(Asteriod,rx,ry,rz,ox,oy,oz);
			break;
	}
	UpdateDisplay();
}


int main(int argc,char **argv)
{	if (argc == 2)
    		shape = atoi(argv[1]);
    	InitDisplay("");
	init_3d();
	init_scan_consts();
	Sphere = (int *) gen_sphere(100,24);
	do
	{ 	do
		{	test();
		    	rx += drx;
		    	ry += dry;
		    	rz += drz;
      			lxa += dlxa;
      			lya += dlya;
      			lza += dlza;
		}
		while (!kbhit());
		switch (getch())
		{	case ' ': 	CloseDisplay();
	    		 		return 0;
			case '+':	oz -= 10;
					break;
			case '-':	oz += 10;
					break;
			case 'z':	drx++;
					break;
			case 'x':	drx--;
					break;
			case 'c':	dry++;
					break;
			case 'v':	dry--;
					break;
			case 'b':	drz++;
					break;
			case 'n':	drz--;
					break;
			case 'a':	dlxa++;
					break;
			case 's':	dlxa--;
					break;
			case 'd':	dlya++;
					break;
			case 'f':	dlya--;
					break;
			case 'g':	dlza++;
					break;
			case 'h':	dlza--;
					break;
			case 't':	timingflag ^=1;
					break;
			case '/':	shape++;
					break;
			case '*':	shape--;
					break;
			
		}
	} while (1);
}
