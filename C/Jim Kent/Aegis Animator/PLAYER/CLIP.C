
overlay "player"

#define C_CODE

#include "..\\include\\lists.h"
#include "..\\include\\clip.h"
#include "..\\include\\poly.h"
#include "..\\include\\script.h"
#include "..\\include\\menu.h"
#include "..\\include\\animath.h"
#include "..\\include\\format.h"
#include "..\\include\\perspect.h"

extern Poly *de_z();

#ifdef DEBUG
dump_poly(poly)
register struct poly *poly;
{
register LLpoint *pt;
register WORD i;

lprintf("poly color pt_count pt_list clipped_list\n%lx %lx %lx %lx %lx\n",
	poly, poly->color, poly->pt_count, poly->pt_list, poly->clipped_list);
pt = poly->clipped_list;
i = poly->pt_count;
while (i && pt)
	{
	lprintf("(%lx %lx %lx %lx)\n",
	pt->x, pt->y, pt->level, pt->next);
	i -= 1;
	pt = pt->next;
	}
}
#endif DEBUG


WORD sys_scale = 0;
WORD ssc_yoff, ssc_xoff, ssc_zoff, ssc_scale;
WORD ground_z = NEW_GROUND_Z;

set_sys_scale(ss)
Script *ss;
{
ssc_yoff = ss->yoff;
ssc_xoff = ss->xoff;
ssc_scale = ss->xscale;
}

LLpoint *free_points;  /*set by de_z = allocated points can use for inserting
			vertices during clipping*/

Poly clip_poly;
LLpoint *clip_points = NULL;
WORD clip_alloc = 0;


#ifdef CCODE
Poly *
de_z(poly,z)
register Poly *poly;
register WORD z;
{
extern WORD perspective;
register Poly *lpoly;
register LLpoint *lp;
register Point *point;
register WORD zscale;
register WORD rground_z = ground_z;
register WORD i;
register WORD xoff, yoff;

lpoly = &clip_poly;
i = poly->pt_count * 2 + 4;  /*sufficient to hold any extra points introduced
				by clipping */
/*actual inequality is something like clip_pts <= 3*points/2 + 4
  (the four is for the corners, 2 in fact may be enough...)  */

if (i > clip_alloc)  /*check size of dynamic buffer*/
	{
	mfree(clip_points, clip_alloc * sizeof(LLpoint) );
	clip_points = (LLpoint *)alloc( i * sizeof(LLpoint) );
	clip_alloc = i;
	}
copy_structure( poly, lpoly, sizeof(Poly) );
lp = lpoly->clipped_list = clip_points;

i = poly->pt_count;
if (i <= 0)
	return(lpoly);
point = poly->pt_list;

if (perspective)
	{
	while (--i > 0)
		{
		zscale = point->z + ssc_zoff;
		if ( zscale  < z)
			--(lpoly->pt_count);
		else
			{
			if (zscale != rground_z)
				{
				lp->x = sscale_by( point->x + ssc_xoff
					- VXMAX/2, rground_z, zscale)
					+ VXMAX/2;
				lp->y = sscale_by( point->y +ssc_yoff 
					- VYMAX/2, rground_z, zscale)
					+ VYMAX/2;
				lp->level = point->level;
				}
			else
				{
				lp->x = point->x + ssc_xoff;
				lp->y = point->y + ssc_yoff;
				lp->level = point->level;
				}
			lp->next = lp+1;
			lp++;
			}
		point++;
		}
	zscale = point->z + ssc_zoff;
	if (zscale < z)
		{
		if ( --lpoly->pt_count <= 0)
			{
			return(NULL);
			}
		else
			{
			--lp;
			lp->next = lpoly->clipped_list;
			}
		}
	else
		{
		if (zscale != rground_z)
			{
			lp->x = sscale_by( point->x + ssc_xoff - VXMAX/2,
				 rground_z, zscale)
				+ VXMAX/2;
			lp->y = sscale_by( point->y + ssc_yoff - VYMAX/2, 
				rground_z, zscale)
				+ VYMAX/2;
			}
		else
			{
			lp->x = point->x + ssc_xoff;
			lp->y = point->y + ssc_yoff;
			}
		lp->level = point->level;
		if (lpoly->type == JUST_LINE)
			lp->level |= 1;
		lp->next = lpoly->clipped_list;
		}
	}
else
	{
	while (--i > 0 )
		{
		lp->x = point->x + ssc_xoff;
		lp->y = point->y + ssc_yoff;
		lp->level = point->level;
		lp->next = lp+1;
		lp++;
		point++;
		}
	lp->x = point->x + ssc_xoff;
	lp->y = point->y + ssc_yoff;
	lp->level = point->level;
	lp->next = lpoly->clipped_list;
	if (lpoly->type == JUST_LINE)
	lp->level |= 1;
	}

if (sys_scale)
	{
	lp = lpoly->clipped_list;
	i = lpoly->pt_count;
	while (--i >= 0)
		{
		lp->x =  (lp->x>>2);
		lp->y =  (lp->y>>2);
		lp++;
		}
	}
free_points =  lpoly->clipped_list + lpoly->pt_count;

return(lpoly);
}
#endif CCODE


Cube clipping_cube =
	{
	0, XMAX,
	0, YMAX,
	GROUND_Z/50,
	};

Cube safety_cube =
	{
	0, XMAX,
	0, YMAX,
	GROUND_Z/50,
	};

#ifdef SLUFFED
set_safety_cube()
{
copy_structure( &safety_cube, &clipping_cube, sizeof(Cube) );
clipping_cube.z = ground_z/50;
}
#endif SLUFFED

#ifdef LATER
dump_cpoly(poly)
register Poly *poly;
{
int i;
LLpoint *p;

if (poly== NULL)
	{
	printf("dump_cpoly NULL\n");
	return;
	}
p = poly->clipped_list;
i = poly->pt_count;
while (--i >= 0)
	{
	printf("(%d %d %d)\n", p->x, p->y, p->level);
	p = p->next;
	}
printf("\n");
await_anydn();
}
#endif NEVER

Poly *
cube_clip(poly)
register Poly *poly;
{
register Cube *cube = &clipping_cube;
extern Poly *de_z(), *xclip(), *yclip(), *Xclip(), *Yclip();

poly = de_z(poly, cube->z);
if (poly)
	{
	if (poly = xclip(poly, cube->x))
		{
		if (poly = yclip(poly, cube->y))
			{
			if (poly = Xclip(poly, cube->X) )
				{
				poly = Yclip(poly, cube->Y);
				}
			}
		}
	}
return(poly);
}

/*reverse order of x y assignments allows returnp = in or out in these
  macros */
#define xhalf_clip(in, out, returnp, x) \
	{\
	returnp->y = in->y + (out->y - in->y) * (in->x - x) / (in->x - out->x);\
	returnp->x = x;\
	}

#define Xhalf_clip( in, out, returnp, X)\
	{\
	returnp->y = in->y + (out->y - in->y) * (in->x - X + 1) / (in->x - out->x);\
	returnp->x = X-1;\
	}

#define yhalf_clip( in, out, returnp, y)\
	{\
	returnp->x = in->x + (out->x - in->x) * (in->y - y) / (in->y - out->y);\
	returnp->y = y;\
	}

#define Yhalf_clip( in, out, returnp, Y)\
	{\
	returnp->x = in->x + (out->x - in->x) * (in->y - Y + 1) / (in->y - out->y);\
	returnp->y = Y-1;\
	}



#ifdef NEVER
xhalf_clip( in, out, returnp, x)
register LLpoint *in, *out, *returnp;
WORD x;
{

returnp->y = in->y + (out->y - in->y) * (in->x - x) / (in->x - out->x);
returnp->x = x; /*reverse order of x y assignments allows returnp = in or out*/
}

Xhalf_clip( in, out, returnp, X)
register LLpoint *in, *out, *returnp;
WORD X;
{

returnp->y = in->y + (out->y - in->y) * (in->x - X + 1) / (in->x - out->x);
returnp->x = X-1;
	/*reverse order of x y assignments allows returnp = in or out*/
}

yhalf_clip( in, out, returnp, y)
register LLpoint *in, *out, *returnp;
WORD y;
{

returnp->x = in->x + (out->x - in->x) * (in->y - y) / (in->y - out->y);
returnp->y = y;
}

Yhalf_clip( in, out, returnp, Y)
register LLpoint *in, *out, *returnp;
WORD Y;
{

returnp->x = in->x + (out->x - in->x) * (in->y - Y + 1) / (in->y - out->y);
returnp->y = Y-1;
}
#endif NEVER


#ifdef CCODE
Poly *
xclip(poly, x)
register Poly *poly;
register WORD x;
{
register LLpoint *list, *last;
register LLpoint *last_out;
register WORD init_count, pcount;
register WORD in, next_in;

pcount = init_count = poly->pt_count;
if (init_count <= 0)
	return(NULL);

list = poly->clipped_list;

while ( !(in = (list->x >= x)  ))  /*maybe you can redo the loops to make
					 this unnecessary, but I couldn't.
					 This runs along until it finds the
					 first vertex inside the clipping box
					-jk	*/
	{
	if (--init_count <= 0)
		{
		poly->pt_count = 0;
		return(NULL);
		}
	list = list->next;
	}
poly->clipped_list = last = list;
list = list->next;
init_count = pcount;
while (--init_count >= 0)
	{
	next_in = (list->x >= x);
	if (in)
		{
		if (next_in) /*continue in state*/
			{
			last = list;
			list = list->next;
			}
		else		 /*go from in to out state*/
			{
			xhalf_clip( last, list, free_points,x);
			last->next = free_points;
			last_out = list;
			last = free_points;
			free_points->level |= 1;
			free_points->next = list = list->next;
			free_points++;
			pcount++;
			in = 0;
			}
		}
	else
		{
		if (next_in)  /*go from out to in state */
			{
			xhalf_clip( list, last_out, last_out ,x);
			last->next = last_out;
			last_out->next = last = list;
			list = list->next;
			in = 1;
			}
		else		/*continue out state*/
			{
			last_out = list;
			last->next = list = list->next; /*pop out link*/
			--pcount;
			}
		}
	}
poly->pt_count = pcount;
return(poly);
}
#endif CCODE


#ifdef CCODE
Poly *
yclip(poly, y)
register Poly *poly;
register WORD y;
{
register LLpoint *list, *last;
register LLpoint *last_out;
register WORD init_count, pcount;
register WORD in, next_in;

pcount = init_count = poly->pt_count;
if (init_count <= 0)
	return(NULL);

list = poly->clipped_list;
/*de_z makes sure that free_points points to enough allocated empty space*/

while ( !(in = (list->y >= y)  ))
	{
	if (--init_count <= 0)
		{
		poly->pt_count = 0;
		return(NULL);
		}
	list = list->next;
	}
poly->clipped_list = last = list;
list = list->next;
init_count = pcount;
while (--init_count >= 0)
	{
	next_in = (list->y >= y);
	if (in)
		{
		if (next_in) /*continue in state*/
			{
			last = list;
			list = list->next;
			}
		else		 /*go from in to out state*/
			{
			yhalf_clip( last, list, free_points,y);
			last->next = free_points;
			last_out = list;
			last = free_points;
			free_points->level |= 1;
			free_points->next = list = list->next;
			free_points++;
			pcount++;
			in = 0;
			}
		}
	else
		{
		if (next_in)  /*go from out to in state */
			{
			yhalf_clip( list, last_out, last_out ,y);
			last->next = last_out;
			last_out->next = last = list;
			list = list->next;
			in = 1;
			}
		else		/*continue out state*/
			{
			last_out = list;
			last->next = list = list->next; /*pop out link*/
			--pcount;
			}
		}
	}
poly->pt_count = pcount;
return(poly);
}
#endif CCODE


#ifdef CCODE
Poly *
Yclip(poly, Y)
register Poly *poly;
register WORD Y;
{
register LLpoint *list, *last;
register LLpoint *last_out;
register WORD init_count, pcount;
register WORD in, next_in;

pcount = init_count = poly->pt_count;
if (init_count <= 0)
	return(NULL);

list = poly->clipped_list;

while ( !(in = (list->y < Y)  ))
	{
	if (--init_count <= 0)
		{
		poly->pt_count = 0;
		return(NULL);
		}
	list = list->next;
	}
poly->clipped_list = last = list;
list = list->next;
init_count = pcount;
while (--init_count >= 0)
	{
	next_in = (list->y < Y);
	if (in)
		{
		if (next_in) /*continue in state*/
			{
			last = list;
			list = list->next;
			}
		else		 /*go from in to out state*/
			{
			Yhalf_clip( last, list, free_points,Y);
			last->next = free_points;
			last_out = list;
			last = free_points;
			free_points->level |= 1;
			free_points->next = list = list->next;
			free_points++;
			pcount++;
			in = 0;
			}
		}
	else
		{
		if (next_in)  /*go from out to in state */
			{
			Yhalf_clip( list, last_out, last_out ,Y);
			last->next = last_out;
			last_out->next = last = list;
			list = list->next;
			in = 1;
			}
		else		/*continue out state*/
			{
			last_out = list;
			last->next = list = list->next; /*pop out link*/
			--pcount;
			}
		}
	}
poly->pt_count = pcount;
return(poly);
}
#endif CCODE



#ifdef CCODE
Poly *
Xclip(poly, X)
register Poly *poly;
register WORD X;
{
register LLpoint *list, *last;
LLpoint *last_out;
register WORD init_count, pcount;
register WORD in, next_in;

pcount = init_count = poly->pt_count;
if (init_count <= 0)
	return(NULL);

list = poly->clipped_list;

while ( !(in = (list->x < X)  ))
	{
	if (--init_count <= 0)
		{
		poly->pt_count = 0;
		return(NULL);
		}
	list = list->next;
	}
poly->clipped_list = last = list;
list = list->next;
init_count = pcount;
while (--init_count >= 0)
	{
	next_in = (list->x < X);
	if (in)
		{
		if (next_in) /*continue in state*/
			{
			last = list;
			list = list->next;
			}
		else		 /*go from in to out state*/
			{
			Xhalf_clip( last, list, free_points,X);
			last->next = free_points;
			last_out = list;
			last = free_points;
			free_points->level |= 1;
			free_points->next = list = list->next;
			free_points++;
			pcount++;
			in = 0;
			}
		}
	else
		{
		if (next_in)  /*go from out to in state */
			{
			Xhalf_clip( list, last_out, last_out ,X);
			last->next = last_out;
			last_out->next = last = list;
			list = list->next;
			in = 1;
			}
		else		/*continue out state*/
			{
			last_out = list;
			last->next = list = list->next; /*pop out link*/
			--pcount;
			}
		}
	}
poly->pt_count = pcount;
return(poly);
}
#endif CCODE


#ifdef SUN
set_menu_cube(menu)
struct menu *menu;
{

clipping_cube.x = menu->xoff;
clipping_cube.y = menu->yoff;
clipping_cube.z = safety_cube.z;
clipping_cube.X = menu->xoff + menu->width + 1;
clipping_cube.Y = menu->yoff + menu->height + 1;
size_down_to_safety();
}
#endif SUN

Cube *
size_down_to_safety(c)
Cube *c;
{
if (c->x >= safety_cube.X 
		|| c->y >= safety_cube.Y
		|| c->X <= safety_cube.x
		|| c->Y <= safety_cube.y  )
	{
	return(NULL);
	}
if (c->x < safety_cube.x)
	c->x = safety_cube.x;
if (c->y < safety_cube.y)
	c->y = safety_cube.y;
if (c->X > safety_cube.X)
	c->X = safety_cube.X;
if (c->Y > safety_cube.Y)
	c->Y = safety_cube.Y;
return(c);
}

long_clip(min, val, max)
long min,max;
register long *val;
{
if ( *val < min)
	*val = min;
if (*val >= max)
	*val = max-1;
}

WORD_clip(min, val, max)
WORD min,max;
register WORD *val;
{
if ( *val < min)
	*val = min;
if (*val >= max)
	*val = max-1;
}

poly_wrap( point_ix, pt_count)
WORD *point_ix, pt_count;
{
#ifdef DEBUG
lprintf("poly_wrap(%d %d)\n", *point_ix, pt_count);
#endif DEBUG
int returned;

returned = 0;
while (*point_ix >= pt_count)
	{
	*point_ix -= pt_count;
	returned = 1;
	}
while (*point_ix < 0)
	{
	*point_ix += pt_count;
	returned = 1;
	}
return(returned);
}

