
overlay "reader"

#include "..\\include\\lists.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"

extern WORD perspective;
inv_zscale_distance( distance, z )
WORD distance;
WORD z;
{
if (perspective)
	{
	if (z <= 0)
	z = 1;
	return( sscale_by( distance, z, ground_z) );
	}
else
	return(distance);
}



/*find_conjugates()
  the guy passed to this is the op or function portion of the act with
  the axis  - function6-8 - already filled in. It fills in function3&4,
  with the time parameter theta = function5 set by whoever...
  */
find_conjugates(function)
WORD *function;
{
struct point axis;
WORD rotate_op[9];
WORD theta;

block_stuff(rotate_op, 0,  9*sizeof(WORD) );
copy_structure( function+6, &axis, 3*sizeof(WORD) );

theta = arctan( 0, SCALE_ONE) - arctan( axis.x, axis.y);
while (theta > TWO_PI/2 ) theta -= TWO_PI;
while (theta < -TWO_PI/2) theta += TWO_PI;

rotate_op[5] = function[3] = theta;
act_rot_offset(&axis, rotate_op, SCALE_ONE);

theta = arctan( 0, SCALE_ONE) - arctan( axis.y, axis.z);
while (theta > TWO_PI/2 ) theta -= TWO_PI;
while (theta < -TWO_PI/2) theta += TWO_PI;

function[4] = theta;
}


