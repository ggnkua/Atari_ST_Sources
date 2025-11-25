#ifndef __VECT_H
#define __VECT_H

#include <stdio.h>

typedef float Vector[3];

#define X 0
#define Y 1
#define Z 2

/* Transformation matrix */
typedef float Matrix[4][4];

void vect_init (Vector v, float x, float y, float z);
void vect_copy (Vector v1, Vector v2);
int vect_equal (Vector v1, Vector v2);
void vect_add (Vector v1, Vector v2, Vector v3);
void vect_sub (Vector v1, Vector v2, Vector v3);
void vect_scale (Vector v1, Vector v2, float k);
float vect_mag (Vector v);
void vect_normalize (Vector v);
float vect_dot (Vector v1, Vector v2);
void vect_cross (Vector v1, Vector v2, Vector v3);
void vect_min (Vector v1, Vector v2, Vector v3);
void vect_max (Vector v1, Vector v2, Vector v3);
float vect_angle (Vector v1, Vector v2);
void vect_print (FILE *f, Vector v, int dec, char sep);
void vect_rotate (Vector v1, Vector v2, int axis, float angle);
void vect_axis_rotate (Vector v1, Vector v2, Vector axis, float angle);
void mx_identity (Matrix mx);
void mx_rotate (Matrix mx1, Matrix mx2, int axis, float angle);
void mx_axis_rotate (Matrix mx1, Matrix mx2, Vector axis, float angle);
void mx_mult (Matrix mx1, Matrix mx2, Matrix mx3);
void vect_transform (Vector v1, Vector v2, Matrix mx);
void mx_decode (Matrix mx, Vector scale, Vector shear, Vector rotate, Vector
	 transl);

#endif
