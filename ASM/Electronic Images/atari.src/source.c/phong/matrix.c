/*
 *      3d routines for solid,light sourced, gouraud and phong shading
 *      (c) 1994 Martin Griffiths 
 *      University of Kent at Canterbury.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "types.h"

#ifndef M_PI
#define M_PI 3.1415926
#endif

short sin_t[2048];
short cos_t[2048];
short obj_matrix[9];

/*
 *      Create a 3d rotation matrix.
 */

void view_matrix(int xang,int yang,int zang)
{       short sin_x,cos_x,sin_y,cos_y,sin_z,cos_z,sinz_sinx,sinz_cosx;  
	xang &= 0x7ff;
	yang &= 0x7ff;
	zang &= 0x7ff;
	sin_x = sin_t[xang];    
	cos_x = cos_t[xang];
	sin_y = sin_t[yang];
	cos_y = cos_t[yang];
	sin_z = sin_t[zang];
	cos_z = cos_t[zang];
	sinz_sinx = ((sin_x*sin_z) >> BITS);
	sinz_cosx = ((cos_x*sin_z) >> BITS);
	obj_matrix[0] = (((cos_y*cos_x) - (sin_y*sinz_sinx)) >> BITS);
	obj_matrix[1] = (((sin_y*cos_x) + (cos_y*sinz_sinx)) >> BITS);
	obj_matrix[2] = ((-cos_z*sin_x) >> BITS);
	obj_matrix[3] = ((-sin_y*cos_z) >> BITS);
	obj_matrix[4] = ((cos_y*cos_z) >> BITS);
	obj_matrix[5] = (sin_z);
	obj_matrix[6] = (((cos_y*sin_x)+(sin_y*sinz_cosx)) >> BITS);
	obj_matrix[7] = (((sin_y*sin_x)-(cos_y*sinz_cosx)) >> BITS);
	obj_matrix[8] = ((cos_z*cos_x) >> BITS);
}

/* 
 *      Transform N points 
 */

void trans(int n,int *xyz,int *new_xyz,int xoff,int yoff,int zoff)
{       int i;
	for (i = 0 ; i < n ; i++)
	{       int x = xyz[0];
		int y = xyz[1];
		int z = xyz[2];
		new_xyz[0] = ( ((  x * obj_matrix[0] ) +
				 (   y * obj_matrix[1] ) +
				 (   z * obj_matrix[2] )) >> BITS ) +xoff; 
		new_xyz[1] = ( ((  x * obj_matrix[3] ) +
				 (   y * obj_matrix[4] ) +
				 (   z * obj_matrix[5] )) >> BITS ) +yoff; 
		new_xyz[2] = ( ((  x * obj_matrix[6] ) +
				 (   y * obj_matrix[7] ) +
				 (   z * obj_matrix[8] )) >> BITS ) +zoff;
		xyz+=3; new_xyz+=3;
	}
}

/*
 *
 */

void pers(int n,int *xyz, int *perspd_xyz)
{       int i;
	for (i = 0 ; i < n ; i++)
	{       short x = xyz[0];
		short y = xyz[1];
		short z = xyz[2];
		perspd_xyz[0] = ((x * DIST) / ( z + DIST)) + (MAX_X/2);
		perspd_xyz[1] = ((y * DIST) / ( z + DIST)) + (MAX_Y/2);
		perspd_xyz[2] = z;
		xyz+=3;perspd_xyz+=3;
	}

}

/*
 *
 */

void init_3d(void)
{       int i;  
	double j = 0;
	for (i=0 ; i < 2048 ; i++)
	{       sin_t[i] = (int) ( sin(j) * (1 << BITS) );
		cos_t[i] = (int) ( cos(j) * (1 << BITS) );
		j += (double) (M_PI*2)/2048;
	}       
}

/*
 *
 */

int *gen_sphere(int r,int n)
{       int i,j;
    	int n2 = n*2;
	int no_verts = 2+(n*n2);
	int no_faces = (n+1)*n2;
	int *sphere = malloc (sizeof(int)*((no_verts*6)+3+(no_faces*5)));
	int *sphere2 = sphere;
	int *nm = sphere+(no_verts*3)+1;
	double delta = (2.*M_PI)/n2;
	double delta2 = (M_PI)/(n+1);
	double beta = delta2;
	*sphere++ = no_verts; *nm++ = no_verts;
	for (i = 0; i < n ; i++)
	{       double sinb = sin(beta);
		double cosb = cos(beta);
		double alpha=0.;
		for (j=0 ; j < n2 ; j++)
		{       double sina = sin(alpha);
			double cosa = cos(alpha);
			double x = (sinb*cosa*r);
			double y = (sinb*sina*r);
			double z = -(cosb*r);
			sphere[0] = (int) x+0.5;
			sphere[1] = (int) y+0.5;
			sphere[2] = (int) z+0.5;
			nm[0] = (int) (x*(LSCALE-1)/r)+0.5;
			nm[1] = (int) (y*(LSCALE-1)/r)+0.5;
			nm[2] = (int) (z*(LSCALE-1)/r)+0.5;
			sphere+=3; nm+=3;
			alpha+=delta;
		}
		beta+=delta2;
	}
	sphere[0] = 0; sphere[1] = 0; sphere[2] = r; sphere+=3;
	nm[0] = 0; nm[1] = 0; nm[2] = LSCALE; nm+=3;
	sphere[0] = 0; sphere[1] = 0; sphere[2] = -r; sphere+=3;
	nm[0] = 0; nm[1] = 0; nm[2] = -LSCALE+1; nm+=3;
	*nm++= no_faces;
	for (i = 0; i < n-1 ; i++)
	{       for (j = 0; j < n2-1 ; j++)
		{       nm[0] = 4;
			nm[4] = ( (i*n2)+j      )*3;
			nm[3] = ( (i*n2)+j+1    )*3;
			nm[2] = ( ((i+1)*n2)+j+1)*3;
			nm[1] = ( ((i+1)*n2)+j  )*3;
			nm+=5;
		}
		nm[0] = 4;
		nm[4] = (i*n2+j)*3; nm[3] = i*n2*3;
		nm[2] = (i+1)*n2*3; nm[1] = (((i+1)*n2)+j)*3;
		nm+=5;
	}
	for (j=0 ; j < (n*2)-1 ; j++)
	{       nm[0]=3; nm[1]=j*3; nm[2]=(j+1)*3; nm[3]=((n*n2)+1)*3; nm+=4;
		nm[0]=3; nm[3]=(n*n2)*3; nm[1]=( ((n-1)*n2)+(j+1))*3;
		nm[2]=( ((n-1)*n2)+j)*3; nm+=4;
	}
	nm[0]=3; nm[1]=j*3; nm[2]=0; nm[3]=((n*n2)+1)*3; nm+=4;
	nm[0]=3; nm[1]=(n*n2)*3; nm[2]=(n-1)*n2*3; nm[3]=(((n-1)*n2)+j)*3;
	return (sphere2);
}
