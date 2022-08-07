

overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"
#include "..\\include\\animath.h"
#include "..\\include\\script.h"
#include "..\\include\\clip.h"

extern WORD ghost_mode;
extern WORD ssc_yoff, ssc_xoff, ssc_zoff, ssc_scale, in_story_mode;
extern Poly *cube_clip();

any_polys(poly_list)
register Poly_list *poly_list;
{
register WORD i;
register Poly **polys, *poly;

i = poly_list->count;
polys = poly_list->list;
while (--i>=0)
	{
	poly = *polys++;
	if ( !(poly->type & IS_RASTER) )
	return(1);
	}
return(0);
}

long
calc_d(x1,y1,x2,y2)
register WORD x1,y1;
WORD x2,y2;
{
x1 -= x2;
y1 -= y2;
return((long)x1*x1 + (long)y1*y1);
}

find_closest(vis,list,points,closest,distance)
VIRTUAL_INPUT *vis;
struct point *list;
WORD points;
WORD *closest;
long *distance;
{
WORD i;
long cclosest,cdistance;
register struct point *point;
WORD x,y;
WORD zscale;
extern WORD perspective;

#ifdef DEBUG
lprintf("find_closest(%lx->(%lx %lx) %lx %lx %lx)\n",
	vis,vis->curx, vis->cury, points, closest, distance);
#endif DEBUG

*distance = 3000000; /*3000000 is just a big number*/
for (i=0; i<points; i++)
	{
	point = list++;
	if (perspective)
		{
		x = sscale_by( point->x - XMAX/2, ground_z, point->z) + XMAX/2;
		y = sscale_by( point->y - YMAX/2, ground_z, point->z) + YMAX/2;
		}
	else
		{
		x = point->x;
		y = point->y;
		}
	cdistance = calc_d(vis->curx,vis->cury,x, y);
	if (cdistance < *distance)
		{
		*distance = cdistance;
		*closest = i;
		}
	}
}


do_edge_list(edge_list,vertex_list,num_pts)
struct point *edge_list, *vertex_list;
register WORD num_pts;
{
register struct point *last_vs, *next_vs;
struct point *edge_point;

last_vs = vertex_list + num_pts - 1;
next_vs = vertex_list;
while (--num_pts >= 0)
	{
	edge_point = edge_list++;
	edge_point->x = (last_vs->x + next_vs->x)>>1;
	edge_point->y = (last_vs->y + next_vs->y)>>1;
	last_vs = next_vs;
	next_vs++;
	}
}




#define in_box(ptx, pty, x0, y0, x1, y1) (ptx >= x0 && ptx < x1 && pty >= y0 && pty < y1)
#define in_raster_box(ptx, pty, xcen, ycen, width, height) ( \
	ptx >= (xcen)-(width)/2 && ptx < (xcen)+(width)/2  && \
	pty >= (ycen)-(height)/2 && pty < (ycen)+(height)/2 )

#ifdef NEVER
#define crosses(y0, y1, y) ( ( (y0-y)^(y1-y) ) < 0)
#endif NEVER
/* crosses returns true if y is on one endpoint or if endpoints on opposite
   sides of y */
crosses( y0, y1, y)
register WORD y0, y1, y;
{
if ( (y0 -= y) == 0)   /*y0 == y1 */
	return(1);
if ( (y1 -= y) == 0)
	return(0);
return( (y0^y1) < 0 );
}



find_xcross( x0, y0, x1, y1, y)
WORD x0, y0, x1, y1, y;
{
WORD swapper;
WORD dy;
WORD xcross;

if (y0 > y1)
	{
	swapper = x0;
	x0 = x1;
	x1 = swapper;
	swapper = y0;
	y0 = y1;
	y1 = swapper;
	}
dy = y1 - y0;
xcross = ( ( (long)x0*( dy -  (y - y0)) + (long)x1*( dy - (y1 - y)) ) + dy/2)
		/ dy;

return(xcross);
}

#define L_UP 0
#define L_DOWN 1
in_closed_poly(poly, x, y)
Poly *poly;
register WORD x, y;
{
register LLpoint *p, *next_p;
WORD lefts, i;
WORD direction, next_direction, is_hor;

#ifdef DEBUG
printf("in_closed_poly\n");
#endif DEBUG


poly = cube_clip(poly);
if (!poly)
	return(0);

i = poly->pt_count;
p = poly->clipped_list;
next_p = p->next;
while (--i >= 0)   /*establish initial direction, check all horiz. case */
	{
	if (p->y != next_p->y)
		{
		if (p->y > next_p->y) 
			direction = L_DOWN;
		else
			direction = L_UP;
		i++;
		break;
		}
	if ( y == p->y)
	if (crosses(p->x, next_p->x, x) )
		{
		return(1);  /*is in middle of hor. line */
		}
	p = next_p;
	next_p = next_p->next;
	}
if ( i < 0)
	return(0);

lefts = 0;
i = poly->pt_count;
while (--i >= 0)
	{
	p = next_p;
	next_p = next_p->next;
	is_hor = (p->y == next_p->y);
	if (!is_hor)
	if (p->y > next_p->y) 
		next_direction = L_DOWN;
	else
		next_direction = L_UP;
	if (p->x == x && p->y == y)
		{
		return(1);	/*test if right on vertex first */
		}
	if (crosses(p->y, next_p->y, y) )
		{
		if (is_hor)
			{
			if (crosses(p->x, next_p->x, x) )
				return(1);  /*is in middle of hor. line */
			}
		else
			{
			p->x = find_xcross(p->x, p->y, next_p->x, next_p->y, y);
			if (p->x == x)
				{
				return(1);   /*test if right on edge*/
				}
			if (p->x < x)
				{
				/*spurious peak?*/
				if (direction == next_direction || y != p->y)
					lefts++;
				}
			}
		}
	if (!is_hor)
	direction = next_direction;
	}
return( lefts&1 );
}

#define CLOSE_ENOUGH 3
near_open_poly(poly, x, y)
register Poly *poly;
register WORD x, y;
{
register LLpoint *p, *next_p;
register WORD i, cross;
register WORD is_near;


#ifdef DEBUG
ldprintf("\nnear_open_poly()");
#endif DEBUG


poly = cube_clip(poly);
if (!poly)
	return(0);
i = poly->pt_count;
p = poly->clipped_list;
next_p = p->next;
if (poly->type == JUST_LINE)
	--i;

while (--i >= 0)
	{
	if (crosses(p->y, next_p->y, y) )
		{
		if (p->y == next_p->y)  /*horizontal line */
			{
			if (crosses(p->x, next_p->x, x) )
				return(1);  /*is in middle of hor. line */
			}
		else
			{
			cross = abs( find_xcross(p->x, p->y, next_p->x, next_p->y, y) - x);
			if (cross <= CLOSE_ENOUGH)
				{
				return(1);
				}
			}
		}
	p = next_p;
	next_p = p->next;
	}
return( 0 );
}

near_frame(xlo, ylo, xhi, yhi, x, y)
WORD xlo, ylo, xhi, yhi;
register WORD x,y;
{
if ( x>=xlo-CLOSE_ENOUGH && x<xhi+CLOSE_ENOUGH)
	{
	if ( abs(y - ylo) <=CLOSE_ENOUGH )
		return(1);
	if ( abs(yhi - 1 - y) <= CLOSE_ENOUGH)
		return(1);
	}
else if ( y>=ylo-CLOSE_ENOUGH && y<yhi+CLOSE_ENOUGH)
	{
	if ( abs(x - xlo) <=CLOSE_ENOUGH )
		return(1);
	if ( abs(xhi - 1 - x) <= CLOSE_ENOUGH)
		return(1);
	}
return(0);
}

static
in_poly(poly, x, y, script)
register struct poly *poly;
WORD x, y;
Script *script;
{
register WORD type;

#ifdef DEBUG
printf("in_poly\n");
#endif DEBUG

#ifdef PARANOID
if (!poly)
	{
	ldprintf("\nwarning - NULL poly in in_poly()");
	return(0);  /*nothing is in a null object*/
	}
#endif PARANOID
if ( (type = poly->type) & IS_RASTER) 
	{
	register WORD cenx, ceny, width, height;
	register OBJ *drawable;

	drawable = (OBJ *)poly->clipped_list;   /*bad type punning, field which
						corresponds to raster_list *
						*/
	cenx = poly->center.x + ssc_xoff;
	ceny = poly->center.y + ssc_yoff;
	if (in_story_mode)
		{
		cenx = scale_mult(cenx, ssc_scale);
		ceny = scale_mult(ceny, ssc_scale);
		if (type != COLOR_BLOCK)
			if (! (drawable = 
				(OBJ *)( ((struct raster_list *)drawable)->scaled)))
			return(0);
		}
	else
	if (type != COLOR_BLOCK && type != ANI_STRIP)
		if (! (drawable = 
			(OBJ *)( ((struct raster_list *)drawable)->raster)))
		return(0);

	switch (type)
		{
		case ANI_STRIP:
			{
			Script *ss;
			Poly_list *plist;
			Poly **polys;
			WORD i, ret;
			WORD xoff, yoff, zoff;

			xoff = poly->center.x - ((struct ani_strip *)poly)->xhot;
			yoff = poly->center.y - ((struct ani_strip *)poly)->yhot;
			zoff = poly->center.z - ground_z;
			ssc_xoff += xoff;
			ssc_yoff += yoff;
			ssc_zoff += zoff;
			ss = script->child_scripts[
			((struct ani_strip *)poly)->script_ix];
			plist = ss->next_poly_list;
			polys = plist->list;
			i = plist->count;
			ret = 0;
			while (--i >= 0)
			{
			if (in_poly(*polys++, x, y, ss) )
				{
				ret = 1;
				break;
				}
			}
			ssc_xoff -= xoff;
			ssc_yoff -= yoff;
			ssc_zoff -= zoff;
			return(ret); 
			}
#ifdef AMIGA
		case AMIGA_BITMAP:
			width = ((struct BitMap *)drawable)->width;
			height = ((struct BitMap *)drawable)->Rows;
			break;
#endif AMIGA
#ifdef ATARI
		case ATARI_CEL:
			width = ((struct atari_cel *)drawable)->width;
			height = ((struct atari_cel *)drawable)->height;
			break;
#endif ATARI
#ifdef SUN
		case BYPLANE_RASTER:
			width = ((struct byte_plane *)drawable)->width;
			height = ((struct byte_plane *)drawable)->height;
			break;
		case BYPLANE_STENCIL:
			width = ((struct byte_bit_plane *)drawable)->width;
			height = ((struct byte_bit_plane *)drawable)->height;
			break;
#endif SUN
		case BITPLANE_RASTER:
			width = ((struct bit_plane *)drawable)->width;
			height = ((struct bit_plane *)drawable)->height;
			break;
		case COLOR_BLOCK:
			width = ((struct color_block *)poly)->width;
			height = ((struct color_block *)poly)->height;
			break;
		case TEXT_WINDOW:
			width = ((struct text_stamp *)drawable)->width;
			height = ((struct text_stamp *)drawable)->height;
			break;
#ifdef PARANOID
		default:
			lprintf("unknown raster type %d in in_poly\n",poly->type);
			break;
#endif PARANOID
		}
	if (ghost_mode)
		{
		register WORD xoff, yoff;

		xoff = cenx - (width>>1);
		yoff = ceny - (height>>1);
		return(near_frame(xoff, yoff, xoff+width, yoff+height, x, y) );
		}
	
	if (!in_raster_box( x, y, cenx, ceny, width, height)) 
		return(0);
	switch( type)
		{
#ifdef AMIGA
		case AMIGA_BITMAP:
			{
			if (((struct BitMap *)drawable)->Planes[7])
				{
				return(getbit( x - cenx + (width>>1),
					y - ceny + (height>>1), 
					((struct BitMap *)drawable)->Planes[7],
					((struct BitMap *)drawable)->BytesPerRow>>1)  );
				}
			else
				return(1);
			}
#endif AMIGA
#ifdef ATARI
		case ATARI_CEL:
			{
			if (((struct atari_cel *)drawable)->mask)
				{
				return(!getbit( x - cenx + (width>>1),
					y - ceny + (height>>1), 
					((struct atari_cel *)drawable)->mask,
					((struct atari_cel *)drawable)->nxln>>3) );
				}
			else
				return(1);
			}
#endif ATARI	
		case BITPLANE_RASTER:
			return(getbit( x - cenx + (width>>1),
				y - ceny + (height>>1), 
				((struct bit_plane *)drawable)->plane,
				((struct bit_plane *)drawable)->words_per_line));
#ifdef SUN
		case BYPLANE_RASTER:
			return(1);
		case BYPLANE_STENCIL:
			{
			return(getbit( x - cenx + (width>>1),
				y - ceny + (height>>1), 
				((struct byte_bit_plane *)drawable)->stencil,
				((struct byte_bit_plane *)drawable)->swords_per_line));
			}
#endif SUN
		case COLOR_BLOCK:
		case TEXT_WINDOW:
			return(1);
#ifdef PARANOID
		default:
			ldprintf("\nunknown case %d in in_poly()", poly->type);
			return(0);
#endif PARANOID
		}
	}
else
	{
	if ( !(poly = cube_clip(poly) ) )
	return(0);
	switch( type)
		{
		case FILLED:
			if (ghost_mode)
				return(near_open_poly(poly, x, y) );
			else
				return(in_closed_poly(poly, x, y));
		case OUT_LINE:
		case JUST_LINE:
			return(near_open_poly(poly, x, y) );
		case COLOR_RECT:
			{
			register LLpoint *p1, *p2;

			p1 = poly->clipped_list;
			p2 = p1->next;
			return( in_box(x, y, p1->x, p1->y, p2->x, p2->y) );
			}
#ifdef PARANOID
		default:
			ldprintf("\nunknown case %d in in_poly()", poly->type);
			return(0);
#endif PARANOID
		}
	}
}


lookup_polyix(poly, poly_list)
Poly *poly;
Poly_list *poly_list;
{
register struct poly **polys;
WORD i;

i = poly_list->count;
polys = poly_list->list + i;
while (--i >= 0)
	if ( poly == *(--polys) )
		return(i);
#ifdef PARANOID
ldprintf("\nlookup_polyix(%lx %lx) - WARNING, not in list", poly, poly_list);
#endif PARANOID
}


Poly *
which_poly(vis, ss, poly_ix)
VIRTUAL_INPUT *vis;
Script *ss;
WORD *poly_ix;
{
WORD point_ix;
WORD i;
Poly **pps, *poly;
struct poly_list *poly_list;

poly_list = ss->next_poly_list;
zlist_sort(poly_list);  /*kludge to make it work # 145 -jk */
i = poly_list->count;
pps = poly_list->zlist + i;
while (--i >= 0)
	{
	poly = *(--pps);
	if (in_poly(poly, vis->curx, vis->cury, ss) )
		{
		*poly_ix = lookup_polyix(poly, poly_list);
		return(poly);
		}
	}

if (which_which(vis, poly_list, poly_ix, &point_ix, ss) )
	return( *(poly_list->list + *poly_ix));
else
	return(NULL);
}

#ifdef SLUFFED
struct point *
which_point(vis, poly_list, poly_ix, point_ix, sscript)
VIRTUAL_INPUT *vis;
struct poly_list *poly_list;
WORD *poly_ix, *point_ix;
Script *sscript;
{
which_which(vis, poly_list, poly_ix, point_ix, sscript);

return( ((*(poly_list->list + *poly_ix))->pt_list + *point_ix) );
}
#endif SLUFFED


/*scan poly list for closest point, and returns where it is*/
which_which(vis,poly_list, poly_ix,point_ix, sscript)
VIRTUAL_INPUT *vis;
struct poly_list *poly_list;
WORD *poly_ix, *point_ix;
Script *sscript;
{
extern WORD ssc_yoff, ssc_xoff, ssc_scale;
register WORD cenx, ceny, width, height;
WORD x,y;
WORD i;
struct poly *poly, **polys;
long distance;
WORD index;
long closest_d = 3000000; /*big number*/
Square box;


x = vis->curx;
y = vis->cury;

#ifdef DEBUG
lprintf("which_whic(%lx->(%d %d) %lx )\n",vis,x,y,point_ix);
#endif DEBUG

if (poly_list->count <= 0) 
	{
	return(0);
	}

*poly_ix = *point_ix = 0;
zlist_sort(poly_list);  /*kludge to make it work # 145 -jk */
i = poly_list->count;
polys = poly_list->zlist+i;
while (--i >= 0)
	{
	poly = *(--polys);

	if (poly->type & IS_RASTER)
	{
	if (poly->type == ANI_STRIP)
		{
		find_bounding_box(poly, &box, sscript);
		cenx = (box.x + box.X)/2;
		ceny = (box.y + box.Y)/2;
		}
	else
		{
		cenx = poly->center.x;
		ceny = poly->center.y;
		}
	cenx += ssc_xoff;
	ceny += ssc_yoff;
	if (in_story_mode)
		{
		cenx = scale_mult(cenx, ssc_scale);
		ceny = scale_mult(ceny, ssc_scale);
		}
	distance = calc_d(vis->curx, vis->cury, cenx, ceny);
	index = 0;
	}
	else
	find_closest(vis,poly->pt_list,poly->pt_count,
		&index,&distance);
	if (distance < closest_d)
	{
	closest_d = distance;
	*poly_ix = lookup_polyix(poly, poly_list);
	*point_ix = index;
	}
	}
return(1);
}


