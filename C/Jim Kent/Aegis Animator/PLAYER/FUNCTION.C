
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"

#define ZSORT

extern WORD update_cm;

/**
**act sample
**
**op format:	op[0] = how many samples
**		op+1  ->  sample table xyz format
**/
#ifdef JUST_FOR_DOCUMENTATION
act_sample(point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
lprintf("sample( (%ld %ld %ld)\n",point->x, point->y, point->z);
lprintf("op (%ld %ld %ld)   %ld/%ld\n",op[0], op[1], op[2], op[3], op[4]);

op += scale_mult(op[0], scale) * 3;
op++; /*jump over how many samples we are in op parameter array*/


point->x += *(op++);
point->y += *(op++);
point->z += *(op++);
return;
}

act_interpolated_sample(point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
WORD samp0, samples, t0samp, little_scale;
WORD *samp_val0, *samp_val1;
WORD dx, dy, dz;

samples = *op++;
--samples;
samp0 = scale * samples/ SCALE_ONE;
t0samp = samp0 * SCALE_ONE / samples;
little_scale = (scale - t0samp)*samples;

samp_val0 = op + samp0*3;
samp_val1 = samp_val0 + 3;

--scale;
dx = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
dy = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
dz = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);

point->x += dx;
point->y += dy;
point->z += dz;
return;
}
#endif JUST_FOR_DOCUMENTATION

fetch_ix_scale(number_samples, time_scale, output)
register WORD number_samples, time_scale;
register WORD *output;
{
register WORD t0samp;

if (time_scale == SCALE_ONE)
	{
	*output++ = number_samples - 1;
	*output = SCALE_ONE;
	}
else
	{
#ifdef GREENHILLS
	*output = time_scale * (number_samples)/SCALE_ONE; /*calc ix*/
	t0samp = *output++ * SCALE_ONE / number_samples;
#endif GREENHILLS
	*output = uscale_by(number_samples, time_scale, SCALE_ONE);
	t0samp =  uscale_by(SCALE_ONE, *output++, number_samples);
	*output = (time_scale - t0samp) * number_samples;  /*calc little_scale*/
	}
}

interpolate_sample(op, scale, delta_array)
register WORD *op;
register WORD scale;
register WORD *delta_array;
{
register WORD samp0, little_scale;
register WORD *samp_val0, *samp_val1;
WORD samples, t0samp;

samples = *op++ - 1;
if (scale == SCALE_ONE)
	{
	samp0 = samples - 1;
	little_scale = SCALE_ONE;
	}
else
	{
#ifdef GREENHILLS
	samp0 = scale * (samples)/SCALE_ONE;
	t0samp = samp0 * SCALE_ONE / samples;
#endif GREENHILLS
	samp0 = uscale_by(samples, scale, SCALE_ONE);
	t0samp = uscale_by(samp0, SCALE_ONE, samples);
	little_scale = (scale - t0samp) * samples;
	}

samp_val0 = op + samp0*3;
samp_val1 = samp_val0 + 3;

*delta_array++ = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
*delta_array++ = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
*delta_array++ = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
}



act_size( point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
register WORD p,q;

#ifdef NEVER
lprintf("size( (%ld %ld %ld)\n",point->x, point->y, point->z);
lprintf("op (%ld %ld %ld)   %ld/%ld\n",op[0], op[1], op[2], op[3], op[4]);
return;
#endif NEVER

p = *(op + 3);
q = *(op + 4);
if (q == 0)
	{
	q = 1;
	p++;
	}
if (q < 32)
	{
	q <<= 4;
	p <<= 4;
	}
	/*this should make things smoother when q is small*/

p = scale_mult(q, SCALE_ONE - scale)  +  scale_mult(p, scale);

point->x = ((long)p * (point->x - *(op) ) ) /q + *(op); 
point->y = ((long)p * (point->y - *(op+1) ) ) /q + *(op+1); 
point->z = ((long)p * (point->z - *(op+2) ) ) /q + *(op+2); 
}

act_rot_offset( point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
register WORD theta;
register WORD s,c;
WORD x,y,z;

theta =  op[3];
if (theta)
	{
	s = isin(theta);
	c = icos(theta);


	x = point->x;
	y = point->y;

	point->x = itmult(x,c) + itmult(y,s);
	point->y = itmult(y,c) + itmult(x,-s);
	}
theta =  op[4];
if (theta)
	{
	s = isin(theta);
	c = icos(theta);

	y = point->y;
	z = point->z;

	point->y = itmult(y,c) + itmult(z,s);
	point->z = itmult(z,c) + itmult(y,-s);
	}
theta =  op[5];
if (theta)
	{
	theta = scale_mult(theta, scale);
	s = isin(theta);
	c = icos(theta);

	x = point->x;
	y = point->y;

	point->x = itmult(x,c) + itmult(y,s);
	point->y = itmult(y,c) + itmult(x,-s);
	}
theta =  -op[4];
if (theta)
	{
	s = isin(theta);
	c = icos(theta);

	y = point->y;
	z = point->z;

	point->y = itmult(y,c) + itmult(z,s);
	point->z = itmult(z,c) + itmult(y,-s);
	}
theta =  -op[3];
if (theta)
	{
	s = isin(theta);
	c = icos(theta);


	x = point->x;
	y = point->y;

	point->x = itmult(x,c) + itmult(y,s);
	point->y = itmult(y,c) + itmult(x,-s);
	}
}


act_rotate( point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
register WORD theta;
register WORD s,c;
WORD x,y,z;

point->x -= op[0];
point->y -= op[1];
point->z -= op[2];

act_rot_offset( point, op, scale);

point->x += op[0];
point->y += op[1];
point->z += op[2];
}


act_move(point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
point->x += scale_mult( *(op++), scale );
point->y += scale_mult( *(op++), scale );
point->z += scale_mult( *(op++), scale );
}


asz_point(poly_list,pt,scale)
register struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point *point;

#ifdef DEBUG
print_tube("size_point",pt);
#endif DEBUG


point = ((*(poly_list->list + *(pt+2)))->pt_list + *(pt+3));

act_size( point, pt+4, scale);
}

asz_segment(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp , *end_p;
struct poly *poly;
WORD i;
WORD x,y;


#ifdef DEBUG
print_tube("size_segment",pt);
#endif DEBUG

poly = *(poly_list->list + *(pt+2) );

dp = poly->pt_list + *(pt+3);
end_p = poly->pt_list + *(pt+5);

i = *(pt+4);

while ( --i >= 0 )
	{
	act_size( dp, pt+6, scale);
	dp++;
	if (dp >= end_p)
	dp = poly->pt_list;
	}
}


asz_poly(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
register WORD s,c;
WORD i;
WORD x,y;


#ifdef DEBUG
print_tube("size_poly",pt);
#endif DEBUG

poly = *(poly_list->list + *(pt+2) );
dp = poly->pt_list;
i = poly->pt_count;

pt += 3;
while ( --i >= 0 )
	{
	act_size( dp, pt, scale);
	dp++;
	}
act_size( &poly->center, pt, scale);
}


asz_polys(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
struct poly **polys;
WORD i;
WORD h;


#ifdef DEBUG
print_tube("size_polys",pt);
#endif DEBUG

polys = poly_list->list + *(pt+2);

h = *(pt+3);
pt += 4;
while ( --h >= 0)
	{
	poly = *(polys++);
	dp = poly->pt_list;
	i = poly->pt_count;

	while ( --i >= 0 )
	{
	act_size( dp, pt, scale);
	dp++;
	}
	act_size( &poly->center, pt, scale);
	}
}


apa_point(poly_list,pt,scale)
register struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point *point;
WORD delta_array[3];

point = ((*(poly_list->list + *(pt+2)))->pt_list + *(pt+3));

interpolate_sample(pt+4, scale, delta_array);
point->x += delta_array[0];
point->y += delta_array[1];
point->z += delta_array[2];
}

apa_segment(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
WORD delta_array[3];
register struct point  *dp , *end_p;
struct poly *poly;
WORD i;
register WORD dx,dy, dz;


interpolate_sample(pt+6, scale, delta_array);
dx = delta_array[0];
dy = delta_array[1];
dz = delta_array[2];

poly = *(poly_list->list + *(pt+2) );

dp = poly->pt_list + *(pt+3);
end_p = poly->pt_list + *(pt+5);

i = *(pt+4);

while ( --i >= 0 )
	{
	dp->x += dx;
	dp->y += dy;
	dp->z += dz;
	dp++;
	if (dp >= end_p)
	dp = poly->pt_list;
	}
}



apa_poly(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
register WORD i;
WORD delta_array[3];
register WORD dx,dy, dz;

interpolate_sample(pt+3, scale, delta_array);
dx = delta_array[0];
dy = delta_array[1];
dz = delta_array[2];

poly = *(poly_list->list + *(pt+2) );
dp = poly->pt_list;
i = poly->pt_count;

while (--i >= 0)
	{
	dp->x += dx;
	dp->y += dy;
	dp->z += dz;
	dp++;
	}
poly->center.x += dx;
poly->center.y += dy;
poly->center.z += dz;
}


apa_polys(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
struct poly **polys;
register WORD i;
WORD h;
WORD delta_array[3];
register WORD dx,dy, dz;

interpolate_sample(pt+4, scale, delta_array);
dx = delta_array[0];
dy = delta_array[1];
dz = delta_array[2];

h = *(pt+3);
polys = poly_list->list + *(pt+2);

while ( --h >= 0)
	{
	poly = *(polys++);
	dp = poly->pt_list;
	i = poly->pt_count;
	while ( --i >= 0 )
	{
	dp->x += dx;
	dp->y += dy;
	dp->z += dz;
	dp++;
	}
	poly->center.x += dx;
	poly->center.y += dy;
	poly->center.z += dz;
	}
}




aro_point(poly_list,pt,scale)
register struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point *point;

point = ((*(poly_list->list + *(pt+2)))->pt_list + *(pt+3));

act_rotate( point, pt+4, scale);
}

aro_segment(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp , *end_p;
struct poly *poly;
WORD i;
WORD x,y;

poly = *(poly_list->list + *(pt+2) );

dp = poly->pt_list + *(pt+3);
end_p = poly->pt_list + *(pt+5);

i = *(pt+4);

while ( --i >= 0 )
	{
	act_rotate( dp, pt+6, scale);
	dp++;
	if (dp >= end_p)
	dp = poly->pt_list;
	}
}



aro_poly(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
register WORD s,c;
WORD i;
WORD x,y;

poly = *(poly_list->list + *(pt+2) );
dp = poly->pt_list;
i = poly->pt_count;

pt+=3;
while (--i >= 0)
	{
	act_rotate( dp, pt, scale);
	dp++;
	}
act_rotate( &poly->center, pt, scale);
}


aro_polys(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
struct poly **polys;
WORD i;
WORD h;


h = *(pt+3);
polys = poly_list->list + *(pt+2);

pt += 4;
while ( --h >= 0)
	{
	poly = *(polys++);

	dp = poly->pt_list;
	i = poly->pt_count;
	while ( --i >= 0 )
	{
	act_rotate( dp, pt, scale);
	dp++;
	}
	act_rotate( &poly->center, pt, scale);
	}
}



amv_point(poly_list,pt,scale)
register struct poly_list *poly_list;
register WORD *pt;
register WORD scale;
{
register struct point  *point;

point = ((*(poly_list->list + *(pt+2)))->pt_list + *(pt+3));

point->x += scale_mult( *(pt+4), scale);
point->y += scale_mult( *(pt+5), scale);
point->z += scale_mult( *(pt+6), scale);
}

amv_segment(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp, *end_p;
struct poly *poly;
WORD i;
register WORD xoff, yoff, zoff;

poly = *(poly_list->list + *(pt+2));
dp = poly->pt_list + *(pt+3);
end_p = poly->pt_list + *(pt+5);

i = *(pt+4);

xoff = *(pt+6);
yoff = *(pt+7);
zoff = *(pt+8);
while ( --i >= 0 )
	{
	dp->x += scale_mult( xoff, scale);
	dp->y += scale_mult( yoff, scale);
	dp->z += scale_mult( zoff, scale);
	dp++;
	if (dp >= end_p)
	dp = poly->pt_list;
	}
}



amv_poly(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
WORD i;
register WORD xoff, yoff, zoff;

poly = *(poly_list->list + *(pt+2));
dp = poly->pt_list;
i = poly->pt_count;

while (--i >= 0)
	{
	dp->x += scale_mult( *(pt+3) , scale);
	dp->y += scale_mult( *(pt+4) , scale);
	dp->z += scale_mult( *(pt+5) , scale);
	dp++;
	}
act_move( &poly->center, pt + 3, scale);
}


amv_polys(poly_list,pt,scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct point  *dp;
register struct poly *poly;
struct poly **pp;
WORD i, poly_count;

pp = poly_list->list + *(pt+2);
poly_count = *(pt + 3);
while (poly_count--)
	{
	poly = *(pp++);
	dp = poly->pt_list;
	i = poly->pt_count;

	while ( --i >= 0 )
	{
	dp->x += scale_mult( *(pt+4) , scale );
	dp->y += scale_mult( *(pt+5) , scale );
	dp->z += scale_mult( *(pt+6) , scale );
	dp++;
	}
	act_move( &poly->center, pt + 4, scale);
	}
}

ain_stencil(poly_list, pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct bitplane_raster *temp;
register WORD j, poly_ix;
register struct raster_list *raster;

poly_ix = *(pt+2);

raster = *( (struct raster_list **)(pt+3) );

poly_list->count++;
check_poly_list(poly_list);

temp = (struct bitplane_raster *)*(poly_list->list + poly_list->count - 1);
mfree( ((Poly *)temp)->pt_list, ((Poly *)temp)->pt_alloc * sizeof(Point) );
block_stuff( temp, 0, sizeof(struct bitplane_raster) );
temp->type = BITPLANE_RASTER;
copy_structure( &grc_point, &temp->origin, sizeof(Point) );
temp->origin.x = pt[5];
temp->origin.y = pt[6];
temp->origin.z = pt[7];
if (raster)
	{
	temp->raster = raster;
	}
temp->color0 = pt[8];

polys = poly_list->list + poly_list->count;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	--polys;
	*polys = *(polys-1);
	}
/*shift up the polygon list from where inserting on up*/
polys = poly_list->list + poly_ix;
*polys = (Poly *)temp;
/*and then point duplicate pointer in middle to the one that used to be
at the end .. the one with the goodies.*/
}


ain_raster(poly_list, pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct amiga_BitMap *temp;
register WORD j, poly_ix;
register struct raster_list *raster;

#ifdef DEBUG
ldprintf("\nain_raster()");
#endif DEBUG

poly_ix = *(pt+2);

raster = *( (struct raster_list **)(pt+3) );

poly_list->count++;
check_poly_list(poly_list);

temp = (struct amiga_BitMap *)*(poly_list->list + poly_list->count - 1);
mfree( ((Poly *)temp)->pt_list, ((Poly *)temp)->pt_alloc * sizeof(Point) );
block_stuff( temp, 0, sizeof(struct amiga_BitMap) );
temp->type = raster->type;
temp->color0 = 1;
copy_structure( &grc_point, &temp->origin, sizeof(Point) );
temp->origin.x = pt[5];
temp->origin.y = pt[6];
temp->origin.z = pt[7];
if (raster)
	{
	temp->raster = raster;
	}
else
	ldprintf("\nwarning - NULL raster in ain_raster");

polys = poly_list->list + poly_list->count;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	--polys;
	*polys = *(polys-1);
	}
/*shift up the polygon list from where inserting on up*/
polys = poly_list->list + poly_ix;
*polys = (Poly *)temp;
/*and then point duplicate pointer in middle to the one that used to be
at the end .. the one with the goodies.*/
}

ain_cblock(poly_list, pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct poly *temp;
register WORD j, poly_ix;
register struct point *point;

poly_list->count++;
check_poly_list(poly_list);

poly_ix = *(pt+2);

temp = *(poly_list->list + poly_list->count - 1);
temp->type = pt[3];
temp->color = pt[4];
temp->center.x = pt[5];
temp->center.y = pt[6];
temp->center.z = pt[7];
mfree(temp->pt_list, temp->pt_alloc * sizeof(Point) );
( (struct color_block *)temp)->width = pt[8];
( (struct color_block *)temp)->height = pt[9];
temp->pt_count = temp->pt_alloc = 0;

polys = poly_list->list + poly_list->count;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	--polys;
	*polys = *(polys-1);
	}
/*shift up the polygon list from where inserting on up*/
polys = poly_list->list + poly_ix;
*polys = temp;
/*and then point duplicate pointer in middle to the one that used to be
at the end .. the one with the goodies.*/
}


ain_strip(poly_list, pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct poly *temp;
register WORD j, poly_ix;
register struct point *point;
struct ani_strip *strip;

#ifdef DEBUG
printf("ain_strip(%lx %lx %x)\n", poly_list, pt, scale);
lsleep(1);
#endif DEBUG
poly_list->count++;
check_poly_list(poly_list);

poly_ix = pt[2];

temp = *(poly_list->list + poly_list->count - 1);
if (!(temp->type & IS_RASTER))
	mfree(temp->pt_list, temp->pt_alloc * sizeof(Point) );
temp->type = ANI_STRIP;
temp->center.x = pt[4];
temp->center.y = pt[5];
temp->center.z = pt[6];
temp->pt_count = temp->pt_alloc = 0;
strip = (struct ani_strip *)temp;
strip->script_ix =  pt[3];
strip->xhot = pt[7];
strip->yhot = pt[8];
strip->zhot = pt[9];
 
polys = poly_list->list + poly_list->count;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	--polys;
	*polys = *(polys-1);
	}
/*shift up the polygon list from where inserting on up*/
polys = poly_list->list + poly_ix;
*polys = temp;
/*and then point duplicate pointer in middle to the one that used to be
at the end .. the one with the goodies.*/
}

ain_poly(poly_list, pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct poly *temp;
register WORD j, poly_ix;
register struct point *point;

poly_list->count++;
check_poly_list(poly_list);

poly_ix = *(pt+2);

temp = *(poly_list->list + poly_list->count - 1);
temp->type = *(pt+3);
temp->color = *(pt+4);
temp->pt_count = *(pt+5);
temp->fill_color = *(pt+6);
cken_points(temp);


copy_structure( pt+9, temp->pt_list, temp->pt_count*sizeof(struct point) );
/*make sure there's an extra polygon at the end and stuff our goodies into
it*/

find_poly_center(temp);

polys = poly_list->list + poly_list->count;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	--polys;
	*polys = *(polys-1);
	}
/*shift up the polygon list from where inserting on up*/
polys = poly_list->list + poly_ix;
*polys = temp;
/*and then point duplicate pointer in middle to the one that used to be
at the end .. the one with the goodies.*/
}



#ifdef NEVER
ain_poly(poly_list,pt, scale)
struct poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct poly **polys;
register struct poly *temp;
register WORD j, poly_ix;

poly_list->count++;
check_poly_list(poly_list);

poly_ix = *(pt+2);
polys = poly_list->list + poly_list->count - 1;
j = poly_list->count - poly_ix;
while (--j >= 0)
	{
	copy_structure( *(polys-1), *(polys), sizeof(struct poly) );
	--polys;
	}


temp = *(poly_list->list + poly_ix);
temp->type = *(pt+3);
temp->color = *(pt+4);
temp->pt_count = *(pt+5);

cken_points(temp);

pt += 9;
copy_structure( pt, temp->pt_list,
	sizeof(struct point) * temp->pt_count);
}
#endif NEVER


ain_point(poly_list, pt, scale)
struct poly_list *poly_list;
WORD *pt;
WORD scale;
{
register struct poly *poly;
register struct point *point, *npoint;
register WORD i;

poly = *(poly_list->list + *(pt+2));
poly->pt_count++;
cken_points(poly);
npoint = poly->pt_list + poly->pt_count;
point = npoint-1;
 
i = poly->pt_count - *(pt+3) - 1;
while (--i >= 0)
	{
	--point;
	--npoint;
	copy_structure( point, npoint, sizeof(struct point) );
	}
if (point<=poly->pt_list)
	point = poly->pt_list + poly->pt_count;
--point;
--npoint;

npoint->x = (point->x + npoint->x)>>1;
npoint->y = (point->y + npoint->y)>>1;
npoint->z = (point->z + npoint->z)>>1;
npoint->level = point->level;
}



acg_color(poly_list,data, scale)
register struct poly_list *poly_list;
register WORD *data;
WORD scale;
{
struct poly *dp;

dp = *(poly_list->list + data[2]);
dp->fill_color = dp->color = data[3];
}


acg_ocolor(poly_list,data, scale)
register struct poly_list *poly_list;
register WORD *data;
WORD scale;
{
struct poly *dp;

dp = *(poly_list->list + data[2]);
dp->color = data[3];
}

acg_fcolor(poly_list,data, scale)
register struct poly_list *poly_list;
register WORD *data;
WORD scale;
{
struct poly *dp;

dp = *(poly_list->list + data[2]);
dp->fill_color = data[3];
}

acg_type(poly_list,data, scale)
register struct poly_list *poly_list;
register WORD *data;
WORD scale;
{
struct poly *dp;

dp = *(poly_list->list + *(data+2));
dp->type = *(data+3);
}

	
aki_poly(poly_list,data, scale)
register struct poly_list *poly_list;
register WORD *data;
WORD scale;
{
register struct poly *psave;
register struct poly **pp;
WORD i;

pp = poly_list->list + *(data+2);
psave = *pp;

--(poly_list->count);
i = poly_list->count - *(data+2);
while ( --i >= 0)
	{
	*pp = *(pp+1);
	pp++;
	}
*pp = psave;

}

aii_colors(poly_list, pt, scale)
Poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register WORD length, start;

length = pt[4];
start = pt[3];
if (start >= MAXCOL)
	return;
if (start + length >= MAXCOL)
	length = MAXCOL-start;
copy_structure(pt+5, poly_list->cmap+start, length*3*sizeof(WORD));
update_cm = 1;
}

atw_color(poly_list, pt, scale)
Poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct color_def *cm;

update_cm = 1;
cm = poly_list->cmap + pt[3];

cm->red += scale_mult(pt[4],scale);
cm->green += scale_mult(pt[5],scale);
cm->blue += scale_mult(pt[6],scale);
}

atw_to_colors(poly_list, pt, scale)
Poly_list *poly_list;
register WORD *pt;
WORD scale;
{
register struct color_def *cm;
register WORD count;
register WORD fr, fg, fb;

update_cm = 1;
cm = poly_list->cmap + pt[3];
count = pt[4];
fr = pt[5];
fg = pt[6];
fb = pt[7];

while (--count >= 0)
	{
	cm->red += scale_mult( fr - cm->red, scale);
	cm->green += scale_mult(fg - cm->green, scale);
	cm->blue += scale_mult(fb - cm->blue, scale);
	cm++;
	}
}


#ifdef SLUFFED
WORD_wrap(input, lower, length)
register WORD input,lower;
WORD length;
{
register WORD upper = lower + length;
while (lower < input)
	input += length;
while (input >= upper)
	input -= length;
return(input);
}
#endif SLUFFED

acy_colors(poly_list, pt, scale)
Poly_list *poly_list;
WORD *pt;
register WORD scale;
{
WORD ix_scale[2];
WORD i;
struct color_def local_cm[MAXCOL];
register struct color_def *cm, *next_cm, *color_base, *dest;
register WORD color_counts, start_color, direction;
register WORD little_scale;
WORD ix;

update_cm = 1;
start_color = pt[3];
color_counts = pt[4];
direction = pt[5];
dest = local_cm;

if (direction > 0)
	{
	fetch_ix_scale( direction, scale, ix_scale);
	ix = color_counts - ix_scale[0] - 1;
	poly_wrap( &ix, color_counts);
	}
else
	{
	fetch_ix_scale( -direction, scale, ix_scale);
	ix = ix_scale[0];
	poly_wrap( &ix, color_counts);
	}
little_scale = ix_scale[1];
color_base = poly_list->cmap + start_color;
cm = color_base + ix;
i = color_counts;
while (--i >= 0)
	{
	ix++;
	poly_wrap( &ix, color_counts);
	next_cm = color_base + ix;
	if (direction < 0)
	{
	dest->red = cm->red + 
		scale_mult(next_cm->red - cm->red, little_scale);
	dest->green = cm->green + 
		scale_mult(next_cm->green - cm->green, little_scale);
	dest->blue = cm->blue + 
		scale_mult(next_cm->blue - cm->blue, little_scale);
	}
	else
	{
	dest->red = next_cm->red + 
		scale_mult(cm->red - next_cm->red, little_scale);
	dest->green = next_cm->green + 
		scale_mult(cm->green - next_cm->green, little_scale);
	dest->blue = next_cm->blue + 
		scale_mult(cm->blue - next_cm->blue, little_scale);
	}
	cm = next_cm;
	dest++;
	}
copy_structure( local_cm, poly_list->cmap + start_color,
	color_counts*sizeof(struct color_def) );
#ifdef NEVER
put_cmap(usr_cmap, start_color, color_counts);
#endif NEVER
}

#ifdef NEVER
acy_colors(poly_list, pt, scale)
Poly_list *poly_list;
WORD *pt;
register WORD scale;
{
WORD ix_scale[2];
WORD i;
struct color_def local_cm[MAXCOL];
register struct color_def *cm, *next_cm, *color_base, *dest;
register WORD color_counts, start_color, direction;
register WORD ix, little_scale;

update_cm = 1;
start_color = pt[3];
color_counts = pt[4];
direction = pt[5];

fetch_ix_scale(direction, scale, ix_scale);

ix = ix_scale[0];
little_scale = ix_scale[1];
color_base = poly_list->cmap + start_color;
cm = color_base + ix;
dest = local_cm;
i = color_counts;
while (--i >= 0)
	{
	ix++;
	if (ix >= color_counts)
	ix = 0;
	next_cm = color_base + ix;
	dest->red = cm->red + 
	scale_mult(next_cm->red - cm->red, little_scale);
	dest->green = cm->green + 
	scale_mult(next_cm->green - cm->green, little_scale);
	dest->blue = cm->blue + 
	scale_mult(next_cm->blue - cm->blue, little_scale);
	cm = next_cm;
	dest++;
	}
copy_structure( local_cm, color_base,
	color_counts*sizeof(struct color_def) );
#ifdef NEVER
put_cmap(usr_cmap, start_color, color_counts);
#endif NEVER
}
#endif NEVER

#ifdef ATARI
ald_background(poly_list, pt, scale)
Poly_list *poly_list;
register WORD *pt;
WORD scale;
{
char *name = (char *)(pt+3);
extern char *bbm_name;
extern WORD *bbm;
extern WORD in_story_mode;

if (jstrcmp(name, poly_list->bg_name) != 0)
	{
	free_string(poly_list->bg_name);
	poly_list->bg_name = clone_string(name);
	}
}

#ifdef LATER_AMIGA
ald_background(poly_list, pt, scale)
Poly_list *poly_list;
register WORD *pt;
WORD scale;
{
char *name = (char *)(pt+3);
extern char *bbm_name;
extern struct BitMap *bbm;
extern WORD in_story_mode;

#ifdef DEBUG
ldprintf("ald_background(%s)\n", name);
#endif DEBUG

if (  !in_story_mode && jstrcmp(name, bbm_name) != 0 )
	{
	stop_time();
	bbm = load_background(name);
	if (!bbm)
		{
		bbm = init_BitMap(WIDTH, HEIGHT, BITPLANES);
		if (bbm)
			{
			set_draw_to_BitMap(bbm);
			whipe_screen();
			gtext(name,XMAX/3,YMAX/2,0);
			set_d2_front();
			}
		}
	start_time();
	bbm_name = clone_string(name);
	remove_intuition_bar();
	}
}
#endif LATER_AMIGA

#ifdef LATER_SUN
ald_background(poly_list, pt, scale)
Poly_list *poly_list;
WORD *pt;
WORD scale;
{
#ifdef DEBUG
#endif DEBUG
ldprintf("\nald_background()");
}
#endif LATER_SUN



arm_background(poly_list, pt, scale)
Poly_list *poly_list;
WORD *pt;
WORD scale;
{

free_string(poly_list->bg_name);
poly_list->bg_name = NULL;
}


