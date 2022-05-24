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
        {       int x,y,z;
                x = *xyz++; 
                y = *xyz++; 
                z = *xyz++; 
                *new_xyz++ = ( ((  x * obj_matrix[0] ) + 
                                 (   y * obj_matrix[1] ) +
                                 (   z * obj_matrix[2] )) >> BITS ) +xoff; 
                *new_xyz++ = ( ((  x * obj_matrix[3] ) + 
                                 (   y * obj_matrix[4] ) +
                                 (   z * obj_matrix[5] )) >> BITS ) +yoff; 
                *new_xyz++ = ( ((  x * obj_matrix[6] ) + 
                                 (   y * obj_matrix[7] ) +
                                 (   z * obj_matrix[8] )) >> BITS ) +zoff; 
        }
}

/*
 *
 */

void pers(int n,int *xyz, int *perspd_xyz)
{       int i;
        for (i = 0 ; i < n ; i++)
        {       short x,y,z;
                x = *xyz++;
                y = *xyz++;
                z = *xyz++;
                *perspd_xyz++ = ((x * DIST) / ( z + DIST)) + (MAX_X/2);
                *perspd_xyz++ = ((y * DIST) / ( z + DIST)) + (MAX_Y/2);
                *perspd_xyz++ = z;     
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

void gen_sphere()
{       
        
}

