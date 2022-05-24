/*
 *
 *
 *
 */ 

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "types.h"
#include "proto.h"

int wibble = 0;

extern unsigned char *screen_ptr;
extern unsigned char pixel[256];
short z_buffer[MAX_X*MAX_Y];

int translated_crds[MAX_CRDS][3];
int normals[MAX_CRDS][3];
int perspected_crds[MAX_CRDS][3];

/*
 *	Compute Intensity given a unit normal.
 */

double L[] = { 0,0,-1 };
double V[] = { 0,0,-1 }; 

#define INTENSITY_RANGE 128

int light_model(double u_i,double u_j,double u_k)
{	double t,N_L,specular,intens;	

/* N.L */

	N_L = 	(u_i*L[0]) +
		(u_j*L[1]) +
		(u_k*L[2]);

/* Ks * ((2N (N.L) - L) . V))^n 
   n  = specular reflection exponent 
   Ks = specular reflection co-efficient */

	/*specular = pow( (((u_i*2*N_L)-L[0])*V[0])+
	               	(((u_j*2*N_L)-L[1])*V[1])+
	               	(((u_k*2*N_L)-L[2])*V[2]),250);
			*/
	t =  	(((u_i*2*N_L)-L[0])*V[0])+
	      	(((u_j*2*N_L)-L[1])*V[1])+
	       	(((u_k*2*N_L)-L[2])*V[2]);
	specular = t / ( t - 50*t + 50);
	intens = ((N_L)+(0.9*specular)) * INTENSITY_RANGE;
	if (intens < 0)
		intens = 0;
	if (intens > INTENSITY_RANGE-1)
		intens = INTENSITY_RANGE-1;
	return (int) intens;
}

void Draw_Poly_Object(Bool phong,int *obj,int xang,int yang,int zang,int xoff,int yoff,int zoff)
{	int i,n = *obj++;
      	view_matrix(xang,yang,zang);
        trans (n, obj, &translated_crds[0][0],xoff,yoff,zoff);
        pers  (n,&translated_crds[0][0], &perspected_crds[0][0]);
	obj += (n+n+n);
	n = *obj++;
        trans (n, obj, &normals[0][0],0,0,0);
	obj += (n+n+n);
	if (phong == FALSE)
	{ 	for (i=0; i<n; i++)
		{	normals[i][0] = light_model((double) normals[i][0]/(1<<BITS),(double) normals[i][1]/(1<<BITS),(double) normals[i][2]/(1<<BITS)); 
			normals[i][1] = 0;
			normals[i][2] = 0;
			if (normals[i][0] < 0)
				normals[i][0] = 0;
		}
		
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
                	draw_poly(phong,np,obj,&perspected_crds[0][0],&normals[0][0]);
		}
		obj += np;
        }
}

/*
 *
 */


void interpolate(int v1,int v2,int dy,int store[])
{	register int grad,i;	
	v1 <<= BITS;	v2 <<= BITS;
	if (dy > 0)
	{	grad = (v2 - v1) / dy;
		for (i = 0 ; i < dy ; i++)
		{	*store++ = v1;
			v1 += grad;
		}
	}
	*store = v1;
}

void gouraud_line(int y,int x1,int x2,int z1,int z2,int i1,int i2)
{	register unsigned char * line_ptr;	
	register short * z_ptr;
	int dx;
	x1 >>= BITS;
	x2 >>= BITS;
	dx = (x2 - x1);
	line_ptr = screen_ptr + (y * MAX_X) + x1;	
	z_ptr    = z_buffer   + (y * MAX_X) + x1;	
	if (dx > 0) 
	{	register int x;
		register unsigned int error = 1 << (BITS-1);
		int dI = (i2 - i1) / dx;
		int dZ = (z2 - z1) / dx;
		for (x = 0 ; x < dx ; x++)
		{	short z = z1 >> BITS;	
			if ((short) z < (short) *z_ptr)
			{	
				*z_ptr = z;
				if (error < (1 << BITS))
					*line_ptr = pixel[(i1 >> BITS)];
				else
					*line_ptr = pixel[(i1 >> BITS)+1];				} 
			z1 += dZ; i1 += dI;
			error &= ((1<<BITS)-1);
			error += (i1 & ((1<<BITS)-1));
			line_ptr++;
			z_ptr++;
		}
	} 
	/**line_ptr++ = pixel[i1 >> BITS];*/
}

void phong_line(int y,int x1,int x2,int z1,int z2,int l1,int l2,int m1,int m2,int n1,int n2)
{	register unsigned char * line_ptr;	
	register short * z_ptr;
	int dx;
	x1 >>= BITS;
	x2 >>= BITS;
	line_ptr = screen_ptr + (y * MAX_X) + x1;	
	z_ptr    = z_buffer   + (y * MAX_X) + x1;	
	dx = x2 - x1 ;
	if (dx > 0)
	{	register int x;
		int dZ = (z2 - z1) / dx;
		int dL = (l2 - l1) / dx;
		int dM = (m2 - m1) / dx;
		int dN = (n2 - n1) / dx;
		for (x = 0 ; x <= dx ; x++)
		{	short z = z1 >> BITS;	
			if ((short) z < (short) *z_ptr)
			{	double l2 = (l1 >> BITS);	
				double m2 = (m1 >> BITS);	
				double n2 = (n1 >> BITS);	
				double l3 = l2*l2;
				double m3 = m2*m2;
				double n3 = n2*n2;
				double nd = sqrt(l3+m3+n3);
				*z_ptr = z;
				*line_ptr = pixel[light_model(l2/nd,m2/nd,n2/nd)]; 
			}
			z_ptr++;
			line_ptr++;
			l1 += dL; m1 += dM; n1 += dN; z1 += dZ;

		}
	}
}

void draw_poly(Bool phong,int n,int polylist[],int coords[],int normls[])
{	int xc1[MAX_Y+1], xc2[MAX_Y+1];
	int zc1[MAX_Y+1], zc2[MAX_Y+1];
	int ic1[MAX_Y+1], ic2[MAX_Y+1];
	int jc1[MAX_Y+1], jc2[MAX_Y+1];
	int kc1[MAX_Y+1], kc2[MAX_Y+1];
	int expanded[256];
	int *dup1 = &expanded[0];
	int *dup2 = &expanded[n*6];
	int *left, *right;
	int e_dy,dy,i;
	int min_y=0x7fffffff,max_y=0;
	right = dup1;
	for (i = 0 ; i < n ; i++)
	{	int y;	
		int *index1 = coords + (*polylist);
		int *index2 = normls + (*polylist++);
		*dup1++ = *index1; *dup2++ = *index1++;
		y = *index1++;
		if (y >= max_y)
			max_y = y;
		if (y <= min_y)
		{	min_y = y;	
			right = dup1-1;
		}
		*dup1++ = y; *dup2++ = y;
		*dup1++ = *index1; *dup2++ = *index1++;
		*dup1++ = *index2; *dup2++ = *index2++;
		*dup1++ = *index2; *dup2++ = *index2++;
		*dup1++ = *index2; *dup2++ = *index2++;
	}
	dy = max_y - min_y;	
	left = right + (n*6);	
	
	/* Scan convert left edge */

	e_dy = dy;
	while (e_dy > 0)
	{	int x1,x2,y1,y2,z1,z2,i1,i2,j1,j2,k1,k2,dy;	
		left -= 6; 
		x2 = *(left+0); y2 = *(left+1); z2 = *(left+2);
		i2 = *(left+3); j2 = *(left+4); k2 = *(left+5);
		x1 = *(left+6); y1 = *(left+7); z1 = *(left+8);
		i1 = *(left+9); j1 = *(left+10); k1 = *(left+11);
		dy = y2-y1;	
		interpolate(x1,x2,dy,&xc1[y1]);
		interpolate(z1,z2,dy,&zc1[y1]);
		interpolate(i1,i2,dy,&ic1[y1]);
		interpolate(j1,j2,dy,&jc1[y1]);
		interpolate(k1,k2,dy,&kc1[y1]);
		e_dy -= dy;
	}	

	/* Scan convert right edge */

	e_dy = dy;
	while (e_dy > 0)
	{	int x1,x2,y1,y2,z1,z2,i1,i2,j1,j2,k1,k2,dy;	
		x1 = *right++; y1 = *right++; z1 = *right++;
		i1 = *right++; j1 = *right++; k1 = *right++;
		x2 = *(right+0); y2 = *(right+1); z2 = *(right+2);
		i2 = *(right+3); j2 = *(right+4); k2 = *(right+5);
		dy = y2-y1;	
		interpolate(x1,x2,dy,&xc2[y1]);
		interpolate(z1,z2,dy,&zc2[y1]);
		interpolate(i1,i2,dy,&ic2[y1]);
		interpolate(j1,j2,dy,&jc2[y1]);
		interpolate(k1,k2,dy,&kc2[y1]);
		e_dy -= dy;
	}
	if (phong == FALSE)
	{ 	for (i = min_y ; i <= max_y ; i++)
		{	gouraud_line(i,xc1[i],xc2[i],zc1[i],zc2[i],ic1[i],ic2[i]);
		}
	} else	
	{	for (i = min_y ; i <= max_y ; i++)
		{	  phong_line(i,xc1[i],xc2[i],zc1[i],zc2[i],ic1[i],ic2[i],
			               jc1[i],jc2[i],kc1[i],kc2[i]); 
		}
	}	
}

void clear_zbuffer()
{	register int i;		
	register long *zb = (long *) &z_buffer[0];	
	register long val = 0x7fff7fff;
	for (i = 0 ; i < MAX_X*MAX_Y ; i+=2)
	{	*zb++ = val;
	}
}

extern int Cube[];
extern int Cube2[];
extern int Pyramid[];
extern int Station[];

void test(void)
{	
	int L1[3]  = { 0,0,-16384 };	
	int L2[3];	
	clear_zbuffer();	
	ClearDisplay();
      	view_matrix(100,200,0);
	trans(1,&L1[0],&L2[0],0,0,0);
	L[0] = (double) L2[0] / 16384;
	L[1] = (double) L2[1] / 16384;
	L[2] = (double) L2[2] / 16384;
	L2[0] = (L2[0] * (MAX_X/3)) >> BITS;
	L2[1] = (L2[1] * (MAX_X/3)) >> BITS;
	L2[2] = (L2[2] * (MAX_X/3)) >> BITS;
        pers  (1,&L2[0], &L2[0]);
	Draw_Poly_Object(FALSE,Station, wibble,wibble,wibble, 0,0,-150); 
	/*Draw_Poly_Object(Station,300,700,900, 0,0,40); 
	Draw_Poly_Object(Pyramid,0,512,123, 0,0,0); 
	Draw_Poly_Object(Station,wibble,wibble,123, 0,0,0); */
	
	DrawLine((MAX_X/2),(MAX_Y/2),L2[0],L2[1],127);
}


int main(int argc,char **argv)
{	InitDisplay("");
	puts("\nColourMap Ok.");
	init_3d();
	while (1)
	{	
		test();
		/*ExecuteDisplay(MAX_X>>2,MAX_Y>>2,MAX_X-(MAX_X>>2),MAX_Y-(MAX_Y>>2)); */
		ExecuteDisplay(0,0,MAX_X-1,MAX_Y-1);
		wibble +=32;
	}
	getchar();
	return 0;
}
