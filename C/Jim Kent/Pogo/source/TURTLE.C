
/* turtle.c - Stuff to handle turtle graphics calls.  */

#include <stdio.h>
#include "pogo.h"

#define XMAX 320
#define YMAX 200
#define XCEN (XMAX/2)
#define YCEN (YMAX/2)
#define PI 3.1415
#define TWOPI (PI*2)

double turtlepos[2];	/* position in *8 coordinates */
int ipos[2] = {XCEN, YCEN};		/* position in screen coordinates */
int drawit = 1;
int tcolor = 15;
double tangle = -PI/2;	/* point up to start */

penup()
{
drawit = 0;
}

pendown()
{
drawit = 1;
}

left(p)
union pt_int *p;
{
double val;

val = p[-1].i;
tangle += val*TWOPI/360;
}

right(p)
union pt_int *p;
{
double val;

val = p[-1].i;
tangle -= val*TWOPI/360;
}

pencolor(p)
union pt_int *p;
{
tcolor = p[-1].i;
}

extern double sin(), cos();

forward(p)
union pt_int *p;
{
int ixy[2];
int xy[2];
union pt_int line_p[5];

double amount;

amount = p[-1].i;	/* get argument and float it */
turtlepos[0] += cos(tangle)*amount;
turtlepos[1] += sin(tangle)*amount;
ixy[0] = turtlepos[0];
line_p[1].i = ixy[0] += XCEN;
ixy[1] = turtlepos[1];
line_p[2].i = ixy[1] += YCEN;
if (drawit)
	{
	line_p[3].i = ipos[0];
	line_p[4].i = ipos[1];
	line_p[0].i = tcolor;
	pline(line_p+5);
	}
ipos[0] = ixy[0];
ipos[1] = ixy[1];
}

reverse(p)
union pt_int *p;
{
p[-1].i = -p[-1].i;
forward(p);
}
