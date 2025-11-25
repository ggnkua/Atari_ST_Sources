/* #include <portab.h> */
#include <math.h>
#include <string.h>
#include "vect.h"

#define EPSILON 1e-6

void vect_init (Vector v, float  x, float  y, float  z)
{
    v[X] = x;
    v[Y] = y;
    v[Z] = z;
}


void vect_copy (Vector v1, Vector v2)
{
    v1[X] = v2[X];
    v1[Y] = v2[Y];
    v1[Z] = v2[Z];
}


int vect_equal (Vector v1, Vector v2)
{
    if (v1[X] == v2[X] && v1[Y] == v2[Y] && v1[Z] == v2[Z])
	return 1;
    else
	return 0;
}


void vect_add (Vector v1, Vector v2, Vector v3)
{
    v1[X] = v2[X] + v3[X];
    v1[Y] = v2[Y] + v3[Y];
    v1[Z] = v2[Z] + v3[Z];
}


void vect_sub (Vector v1, Vector v2, Vector v3)
{
    v1[X] = v2[X] - v3[X];
    v1[Y] = v2[Y] - v3[Y];
    v1[Z] = v2[Z] - v3[Z];
}


void vect_scale (Vector v1, Vector v2, float  k)
{
    v1[X] = k * v2[X];
    v1[Y] = k * v2[Y];
    v1[Z] = k * v2[Z];
}


float vect_mag (Vector v)
{
    float mag = sqrt(v[X]*v[X] + v[Y]*v[Y] + v[Z]*v[Z]);

    return mag;
}


void vect_normalize (Vector v)
{
    float mag = vect_mag (v);

    if (mag > 0.0)
	vect_scale (v, v, 1.0/mag);
}


float vect_dot (Vector v1, Vector v2)
{
    return (v1[X]*v2[X] + v1[Y]*v2[Y] + v1[Z]*v2[Z]);
}


void vect_cross (Vector v1, Vector v2, Vector v3)
{
    v1[X] = (v2[Y] * v3[Z]) - (v2[Z] * v3[Y]);
    v1[Y] = (v2[Z] * v3[X]) - (v2[X] * v3[Z]);
    v1[Z] = (v2[X] * v3[Y]) - (v2[Y] * v3[X]);
}

void vect_min (Vector v1, Vector v2, Vector v3)
{
    v1[X] = (v2[X] < v3[X]) ? v2[X] : v3[X];
    v1[Y] = (v2[Y] < v3[Y]) ? v2[Y] : v3[Y];
    v1[Z] = (v2[Z] < v3[Z]) ? v2[Z] : v3[Z];
}


void vect_max (Vector v1, Vector v2, Vector v3)
{
    v1[X] = (v2[X] > v3[X]) ? v2[X] : v3[X];
    v1[Y] = (v2[Y] > v3[Y]) ? v2[Y] : v3[Y];
    v1[Z] = (v2[Z] > v3[Z]) ? v2[Z] : v3[Z];
}


/* Return the angle between two vectors */
float vect_angle (Vector v1, Vector v2)
{
    float  mag1, mag2, angle, cos_theta;

    mag1 = vect_mag(v1);
    mag2 = vect_mag(v2);

    if (mag1 * mag2 == 0.0)
	angle = 0.0;
    else {
	cos_theta = vect_dot(v1,v2) / (mag1 * mag2);

	if (cos_theta <= -1.0)
	    angle = 180.0;
	else if (cos_theta >= +1.0)
	    angle = 0.0;
	else
	    angle = (180.0/M_PI) * acos(cos_theta);
    }

    return angle;
}


void vect_print (FILE *f, Vector v, int dec, char sep)
{
    char fstr[] = "%.4f, %.4f, %.4f";

    if (dec < 0) dec = 0;
    if (dec > 9) dec = 9;

    fstr[2]  = '0' + dec;
    fstr[8]  = '0' + dec;
    fstr[14] = '0' + dec;

    fstr[4]  = sep;
    fstr[10] = sep;

    fprintf (f, fstr, v[X], v[Y], v[Z]);
}


/* Rotate a vector about the X, Y or Z axis */
void vect_rotate (Vector v1, Vector v2, int axis, float angle)
{
    float  cosa, sina;

    cosa = cos ((M_PI/180.0) * angle);
    sina = sin ((M_PI/180.0) * angle);

    switch (axis) {
	case X:
	    v1[X] =  v2[X];
	    v1[Y] =  v2[Y] * cosa + v2[Z] * sina;
	    v1[Z] =  v2[Z] * cosa - v2[Y] * sina;
	    break;

	case Y:
	    v1[X] = v2[X] * cosa - v2[Z] * sina;
	    v1[Y] = v2[Y];
	    v1[Z] = v2[Z] * cosa + v2[X] * sina;
	    break;

	case Z:
	    v1[X] = v2[X] * cosa + v2[Y] * sina;
	    v1[Y] = v2[Y] * cosa - v2[X] * sina;
	    v1[Z] = v2[Z];
	    break;
    }
}


/* Rotate a vector about a specific axis */
void vect_axis_rotate (Vector v1, Vector v2, Vector axis, float angle)
{
    float  cosa, sina;
    Matrix mx;

    cosa = cos ((M_PI/180.0) * angle);
    sina = sin ((M_PI/180.0) * angle);

    mx[0][0] = (axis[X] * axis[X]) + ((1.0 - (axis[X] * axis[X]))*cosa);
    mx[0][1] = (axis[X] * axis[Y] * (1.0 - cosa)) - (axis[Z] * sina);
    mx[0][2] = (axis[X] * axis[Z] * (1.0 - cosa)) + (axis[Y] * sina);
    mx[0][3] = 0.0;

    mx[1][0] = (axis[X] * axis[Y] * (1.0 - cosa)) + (axis[Z] * sina);
    mx[1][1] = (axis[Y] * axis[Y]) + ((1.0 - (axis[Y] * axis[Y])) * cosa);
    mx[1][2] = (axis[Y] * axis[Z] * (1.0 - cosa)) - (axis[X] * sina);
    mx[1][3] = 0.0;

    mx[2][0] = (axis[X] * axis[Z] * (1.0 - cosa)) - (axis[Y] * sina);
    mx[2][1] = (axis[Y] * axis[Z] * (1.0 - cosa)) + (axis[X] * sina);
    mx[2][2] = (axis[Z] * axis[Z]) + ((1.0 - (axis[Z] * axis[Z])) * cosa);
    mx[2][3] = 0.0;

    mx[3][0] = mx[3][1] = mx[3][2] = mx[3][3] = 0.0;

    vect_transform (v1, v2, mx);
}


/* Create an identity matrix */
void mx_identity (Matrix mx)
{
    int i, j;

    for (i = 0; i < 4; i++)
	for (j = 0; j < 4; j++)
	    mx[i][j] = 0.0;

    for (i = 0; i < 4; i++)
	mx[i][i] = 1.0;
}


/* Rotate a matrix about the X, Y or Z axis */
void mx_rotate (Matrix mx1, Matrix mx2, int axis, float angle)
{
    Matrix mx;
    float  cosa, sina;

    cosa = cos ((M_PI/180.0) * angle);
    sina = sin ((M_PI/180.0) * angle);

    mx_identity (mx);

    switch (axis) {
	case X:
	    mx[1][1] = cosa;
	    mx[1][2] = sina;
	    mx[2][1] = -sina;
	    mx[2][2] = cosa;
	    break;

	case Y:
	    mx[0][0] = cosa;
	    mx[0][2] = -sina;
	    mx[2][0] = sina;
	    mx[2][2] = cosa;
	    break;

	case Z:
	    mx[0][0] = cosa;
	    mx[0][1] = sina;
	    mx[1][0] = -sina;
	    mx[1][1] = cosa;
	    break;
    }

    mx_mult (mx1, mx2, mx);
}


void mx_axis_rotate (Matrix mx1, Matrix mx2, Vector axis, float angle)
{
    float  cosa, sina;
    Matrix mx;

    cosa = cos ((M_PI/180.0) * angle);
    sina = sin ((M_PI/180.0) * angle);

    mx[0][0] = (axis[X] * axis[X]) + ((1.0 - (axis[X] * axis[X]))*cosa);
    mx[0][1] = (axis[X] * axis[Y] * (1.0 - cosa)) - (axis[Z] * sina);
    mx[0][2] = (axis[X] * axis[Z] * (1.0 - cosa)) + (axis[Y] * sina);
    mx[0][3] = 0.0;

    mx[1][0] = (axis[X] * axis[Y] * (1.0 - cosa)) + (axis[Z] * sina);
    mx[1][1] = (axis[Y] * axis[Y]) + ((1.0 - (axis[Y] * axis[Y])) * cosa);
    mx[1][2] = (axis[Y] * axis[Z] * (1.0 - cosa)) - (axis[X] * sina);
    mx[1][3] = 0.0;

    mx[2][0] = (axis[X] * axis[Z] * (1.0 - cosa)) - (axis[Y] * sina);
    mx[2][1] = (axis[Y] * axis[Z] * (1.0 - cosa)) + (axis[X] * sina);
    mx[2][2] = (axis[Z] * axis[Z]) + ((1.0 - (axis[Z] * axis[Z])) * cosa);
    mx[2][3] = 0.0;

    mx[3][0] = mx[3][1] = mx[3][2] = mx[3][3] = 0.0;

    mx_mult (mx1, mx2, mx);
}


void mx_mult (Matrix mx1, Matrix mx2, Matrix mx3)
{
    float sum;
    int   i, j, k;

    for (i = 0; i < 4; i++) {
	for (j = 0; j < 4; j++) {
	    sum = 0.0;

	    for (k = 0; k < 4; k++)
		sum = sum + mx2[i][k] * mx3[k][j];

	    mx1[i][j] = sum;
	}
    }
}


/* Transform the given vector */
void vect_transform (Vector v1, Vector v2, Matrix mx)
{
    Vector tmp;

    tmp[X] = (v2[X] * mx[0][0]) + (v2[Y] * mx[1][0]) + (v2[Z] * mx[2][0]) + mx[3][0];
    tmp[Y] = (v2[X] * mx[0][1]) + (v2[Y] * mx[1][1]) + (v2[Z] * mx[2][1]) + mx[3][1];
    tmp[Z] = (v2[X] * mx[0][2]) + (v2[Y] * mx[1][2]) + (v2[Z] * mx[2][2]) + mx[3][2];

    vect_copy (v1, tmp);
}



/*
   Decodes a 3x4 transformation matrix into separate scale, rotation,
   translation, and shear vectors. Based on a program by Spencer W.
   Thomas (Graphics Gems II)
*/
void mx_decode (Matrix mx, Vector scale,  Vector shear, Vector rotate,
		Vector transl)
{
    int i;
    Vector row[3], temp;

    for (i = 0; i < 3; i++)
	transl[i] = mx[3][i];

    for (i = 0; i < 3; i++) {
	row[i][X] = mx[i][0];
	row[i][Y] = mx[i][1];
	row[i][Z] = mx[i][2];
    }

    scale[X] = vect_mag (row[0]);
    vect_normalize (row[0]);

    shear[X] = vect_dot (row[0], row[1]);
    row[1][X] = row[1][X] - shear[X]*row[0][X];
    row[1][Y] = row[1][Y] - shear[X]*row[0][Y];
    row[1][Z] = row[1][Z] - shear[X]*row[0][Z];

    scale[Y] = vect_mag (row[1]);
    vect_normalize (row[1]);

    if (scale[Y] != 0.0)
	shear[X] /= scale[Y];

    shear[Y] = vect_dot (row[0], row[2]);
    row[2][X] = row[2][X] - shear[Y]*row[0][X];
    row[2][Y] = row[2][Y] - shear[Y]*row[0][Y];
    row[2][Z] = row[2][Z] - shear[Y]*row[0][Z];

    shear[Z] = vect_dot (row[1], row[2]);
    row[2][X] = row[2][X] - shear[Z]*row[1][X];
    row[2][Y] = row[2][Y] - shear[Z]*row[1][Y];
    row[2][Z] = row[2][Z] - shear[Z]*row[1][Z];

    scale[Z] = vect_mag (row[2]);
    vect_normalize (row[2]);

    if (scale[Z] != 0.0) {
	shear[Y] /= scale[Z];
	shear[Z] /= scale[Z];
    }

    vect_cross (temp, row[1], row[2]);
    if (vect_dot (row[0], temp) < 0.0) {
	for (i = 0; i < 3; i++) {
	    scale[i]  *= -1.0;
	    row[i][X] *= -1.0;
	    row[i][Y] *= -1.0;
	    row[i][Z] *= -1.0;
	}
    }

    if (row[0][Z] < -1.0) row[0][Z] = -1.0;
    if (row[0][Z] > +1.0) row[0][Z] = +1.0;

    rotate[Y] = asin(-row[0][Z]);

    if (fabs(cos(rotate[Y])) > EPSILON) {
	rotate[X] = atan2 (row[1][Z], row[2][Z]);
	rotate[Z] = atan2 (row[0][Y], row[0][X]);
    }
    else {
	rotate[X] = atan2 (row[1][X], row[1][Y]);
	rotate[Z] = 0.0;
    }

    /* Convert the rotations to degrees */
    rotate[X] = (180.0/M_PI)*rotate[X];
    rotate[Y] = (180.0/M_PI)*rotate[Y];
    rotate[Z] = (180.0/M_PI)*rotate[Z];
}

