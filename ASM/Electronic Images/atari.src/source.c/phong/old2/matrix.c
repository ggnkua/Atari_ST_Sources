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
 *	Create a 3d rotation matrix.
 */

void view_matrix(int xang,int yang,int zang)
{	short sin_x,cos_x,sin_y,cos_y,sin_z,cos_z,sinz_sinx,sinz_cosx;	
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
        { 	int x = xyz[0];
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
        { 	short x = xyz[0];
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
{	int i;	
	double j = 0;
	for (i=0 ; i < 2048 ; i++)
	{	sin_t[i] = (int) ( sin(j) * (1 << BITS) );
		cos_t[i] = (int) ( cos(j) * (1 << BITS) );
		j += (double) (M_PI*2)/2048;
	}	
}

/*
 *
 */

int *gen_sphere(int r,int n)
{	int i,j;
    	int no_verts = n*n*2;
	int no_faces = ((n-1)*n)*2;
    	int *sphere = malloc (sizeof(int)*((no_verts*6)+3+(no_faces*5)));
	int *sphere2 = sphere;
	int *norms = sphere+(no_verts*3)+1;
	double delta = (2.*M_PI)/(n*2.);
	double delta2 = (M_PI)/(n+1);
	double beta = delta2;
	*sphere++ = no_verts; *norms++ = no_verts;
	for (i = 0; i < n ; i++)
	{	double sinb = sin(beta);
	    	double cosb = cos(beta);
		double alpha=0.;
	    	for (j=0 ; j < (n*2) ; j++)
	    	{	double sina = sin(alpha);
		    	double cosa = cos(alpha);
		    	double x = (sinb*cosa*r);
		    	double y = (sinb*sina*r);
			double z = -(cosb*r);
			sphere[0] = (int) x;
			sphere[1] = (int) y;
			sphere[2] = (int) z;
			norms[0] = (int) (x*1.05*LSCALE/r);
			norms[1] = (int) (y*1.05*LSCALE/r);
			norms[2] = (int) (z*1.05*LSCALE/r);
			sphere+=3; norms+=3;
			alpha+=delta;
		}
		beta+=delta2;
	}
	*norms++= no_faces;
	for (i = 0; i < n-1 ; i++)
	{ 	for (j = 0; j < (n*2)-1 ; j++)
	    	{	norms[0] = 4;
		    	norms[4] = ( (i*n*2)+j      )*3;
		    	norms[3] = ( (i*n*2)+j+1    )*3;
			norms[2] = ( ((i+1)*n*2)+j+1)*3;
			norms[1] = ( ((i+1)*n*2)+j  )*3;
			norms+=5;
		}
	    	norms[0] = 4;
	    	norms[4] = ( (i*n*2)+j      )*3;
	    	norms[3] = ( (i*n*2)        )*3;
		norms[2] = ( ((i+1)*n*2)    )*3;
		norms[1] = ( ((i+1)*n*2)+j  )*3;
		norms+=5;
	}
	return (sphere2);
}
