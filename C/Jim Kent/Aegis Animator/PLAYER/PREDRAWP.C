
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\script.h"
#include "..\\include\\cursor.h"
#include "..\\include\\animath.h"
#include "..\\include\\clip.h"
#include "..\\include\\color.h"

extern struct poly *clone_poly();

extern int draw_pl_with();
extern WORD in_story_mode;
extern WORD ssc_yoff, ssc_xoff, ssc_zoff, ssc_scale;
extern WORD story_xoff, story_yoff;
extern WORD sys_scale;
extern char *bbm_name;

WORD ghost_mode = FALSE;

see_seq(ss)
register Script *ss;
{
register Poly_list *poly_list;

#ifdef DEBUG
printf("see_seq(%lx)\n", ss);
lsleep(1);
#endif DEBUG
if (!ss)
	return;

set_sys_scale(ss);
poly_list = ss->next_poly_list;
if (!in_story_mode)
	{
	if (jstrcmp(poly_list->bg_name, bbm_name) != 0)
		{
		if (poly_list->bg_name == NULL)
		free_background();
		else
		{
		stop_time();
		load_background(poly_list->bg_name);
		start_time();
		}
		}
	}
clear_screen();
draw_pllist(poly_list, ss);
}

draw_pllist(poly_list, sscript)
register Poly_list *poly_list;
Script *sscript;
{
register WORD i;
register struct poly **polys;

#ifdef DEBUG
printf("draw_pllist(%lx)\n",poly_list);
lsleep(1);
#endif DEBUG
if (poly_list)
	{
	zlist_sort(poly_list);
	polys = poly_list->zlist;
	i = poly_list->count;
	while (--i >= 0)
	{
	draw_pl_with( *(polys++), sscript);
	}
	}
}

#ifdef SLUFFED
unsee_seq(ss)
register struct s_sequence *ss;
{
register WORD i;
register struct poly **polys, *poly;

clear_screen();
}


generic_sort(list, list_count, field)
WORD **list;
WORD list_count;
register WORD field;
{
register WORD swapped;
register WORD *swapper;
register WORD **list_pt, **next_list_pt;
register WORD i;

swapped = 1;
--list_count;  /*since go one past*/
while (swapped)
	{
	list_pt = list;
	next_list_pt = list_pt+1;
	swapped = 0;
	i = list_count;
	while (--i >= 0)
	{
	if ( (*list_pt)[field] > (*next_list_pt)[field] )
		{
		swapped++;
		swapper = *list_pt;
		*list_pt = *next_list_pt;
		*next_list_pt = swapper;
		}
	list_pt++;
	next_list_pt++;
	}
	}
}
#endif SLUFFED


zlist_sort(poly_list)
Poly_list *poly_list;
{
Poly **zlist;
WORD count;
register WORD swapped;
register Poly *swapper;
register WORD i;
register Poly **list_pt, **next_list_pt;

#ifdef DEBUG
lprintf("zlist_sort(%lx)\n",poly_list);
#endif DEBUG

copy_structure( poly_list->list, poly_list->zlist,
	sizeof(Poly *) * poly_list->count);
swapped = 1;
count = poly_list->count - 1;  /*since go one past*/
zlist = poly_list->zlist;
while (swapped)
	{
	list_pt = zlist;
	next_list_pt = list_pt+1;
	swapped = 0;
	i = count;
	while (--i >= 0)
		{
		if ( (*list_pt)->center.z < (*next_list_pt)->center.z )
			{
			swapped++;
			swapper = *list_pt;
			*list_pt = *next_list_pt;
			*next_list_pt = swapper;
			}
		list_pt++;
		next_list_pt++;
		}
	}
}

find_poly_center(poly)
register struct poly *poly;
{
register struct point *center, *pts;
register WORD i;
register int x, y, z;

#ifdef DEBUG
printf("find_poly_center(%lx)\n",poly);
#endif DEBUG
x = y = z = 0;
pts = poly->pt_list;
i = poly->pt_count;
while (--i >= 0)
	{
	x += pts->x;
	y += pts->y;
	z += pts->z;
	pts++;
	}
i = poly->pt_count;
center = &(poly->center);
center->x = x/i;
center->y = y/i;
center->z = z/i;
}

zscale_point(source , dest)
register struct point *source, *dest;
{
extern WORD perspective;
register WORD zscale;

if (perspective)
	{
	zscale = source->z;
	dest->x = sscale_by(source->x - XMAX/2, ground_z, zscale) + XMAX/2;
	dest->y = sscale_by(source->y - YMAX/2, ground_z, zscale) + YMAX/2;
	dest->z = source->z;
	}
else
	{
	dest->x = source->x;
	dest->y = source->y;
	dest->z = source->z;
	}
}


scale_point_list(points, count, scale, xoff, yoff)
register struct point *points;
register WORD count;
register WORD scale;
register WORD xoff, yoff;
{
#ifdef DEBUG
printf("scale_point_list(%lx %d %d %d %d)\n",
	points, count, scale, xoff, yoff);
#endif DEBUG

while (--count >= 0)
	{
	points->x = scale_mult(points->x, scale) + xoff;
	points->y = scale_mult(points->y, scale) + yoff;
	points++;
	}
}

draw_pl_with(poly, sscript)
register struct poly *poly;
Script *sscript;
{
extern WORD ghost_mode;
extern Poly *clone_poly(), *cube_clip();
register WORD type;

#ifdef DEBUG
printf("draw_pl_with(%lx)\n",poly);
#endif DEBUG

if( (type = poly->type) & HIDE_BIT)
	return;
if (type & IS_RASTER)
	{
	register WORD xoff, yoff, width, height;
	register OBJ *drawable;

	drawable = (OBJ *)poly->clipped_list;	/* narsty type punning, scaled
											raster really */
	xoff = poly->center.x + ssc_xoff;
	yoff = poly->center.y + ssc_yoff;
	if (in_story_mode)
		{
		xoff >>= 2;
		xoff += story_xoff;
		yoff >>= 2;
		yoff += story_yoff;
		if (type != COLOR_BLOCK && type != ANI_STRIP)
			if (! (drawable = 
			(OBJ *)( ((struct raster_list *)drawable)->scaled)))
			return;
		}
	else
		if (type != COLOR_BLOCK && type != ANI_STRIP)
			if (! (drawable = 
				(OBJ *)( ((struct raster_list *)drawable)->raster)))
			return;
	switch (type)
		{
#ifdef AMIGA
		case AMIGA_BITMAP:
			{
			if (ghost_mode)
				{
				width = ((struct BitMap *)drawable)->width;
				height = ((struct BitMap *)drawable)->Rows;
				xoff -= (width>>1);
				yoff -= (height>>1);
				draw_frame(poly->color, xoff, yoff,
					xoff + width,  yoff + height);
				}
			else
				draw_BitMap(drawable,
					xoff - (((struct BitMap *)drawable)->width>>1),
					yoff - (((struct BitMap *)drawable)->Rows>>1));
			}
			break;
#endif AMIGA
#ifdef SUN
		case BYPLANE_RASTER:
			{
			if (ghost_mode)
			{
			width = ((struct byte_plane *)drawable)->width;
			height = ((struct byte_plane *)drawable)->height;
			xoff -= width/2;
			yoff -= height/2;
			draw_frame(poly->color, xoff, yoff,
				xoff + width,  yoff + height);
			}
			else
			draw_byteplane(drawable,
				xoff - ((struct byte_plane *)drawable)->width/2,
				yoff - ((struct byte_plane *)drawable)->height/2);
			}
			break;
		case BYPLANE_STENCIL:
			{
			if (ghost_mode)
				{
				width = ((struct byte_bit_plane *)drawable)->width;
				height = ((struct byte_bit_plane *)drawable)->height;
				xoff -= (width>>1);
				yoff -= (height>>1);
				draw_frame(poly->color, xoff, yoff,
					xoff + width,  yoff + height);
				}
			else
			draw_byte_bit(drawable,
				xoff - (((struct byte_bit_plane *)drawable)->width >>1),
				yoff - (((struct byte_bit_plane *)drawable)->height>>1));
			}
			break;
#endif SUN
		case COLOR_BLOCK:
			{
			width = ((struct color_block *)poly)->width;
			height = ((struct color_block *)poly)->height;
			if (in_story_mode)
				{
				width >>= 2;
				height >>= 2;
				}
			xoff -= (width>>1);
			yoff -= (height>>1);
			if (ghost_mode)
				{
				draw_frame(poly->color,
					xoff, yoff, xoff + width, yoff + height);
				}
			else
				{
				colrop( poly->color, xoff, yoff, width, height);
				}
			}
			break;
		case BITPLANE_RASTER:
			{
			if (ghost_mode)
				{
				width = ((struct bit_plane *)drawable)->width;
				height = ((struct bit_plane *)drawable)->height;
				xoff -= width/2;
				yoff -= height/2;
				draw_frame(poly->color, xoff, yoff,
					xoff + width,  yoff + height);
				}
			else
				draw_bitplane(drawable,
					xoff - ((struct bit_plane *)drawable)->width/2,
					yoff - ((struct bit_plane *)drawable)->height/2,
					poly->color);
			}
			break;
		case ATARI_CEL:
			{
			if (ghost_mode)
				{
				width = ((struct atari_cel *)drawable)->width;
				height = ((struct atari_cel *)drawable)->height;
				xoff -= width/2;
				yoff -= height/2;
				draw_frame(poly->color, xoff, yoff,
				xoff + width,  yoff + height);
				}
			else
			show_cel(drawable,
				xoff - ((struct atari_cel *)drawable)->width/2,
				yoff - ((struct atari_cel *)drawable)->height/2);
			}
			break;
		case TEXT_WINDOW:
			{
			if (ghost_mode)
				{
				width = ((struct text_stamp *)drawable)->width;
				height = ((struct text_stamp *)drawable)->height;
				xoff -= width/2;
				yoff -= height/2;
				draw_frame(1, xoff, yoff,
				xoff + width,  yoff + height);
				}
			else
			gtext(drawable,
				xoff - ((struct text_stamp *)drawable)->width/2,
				yoff - ((struct text_stamp *)drawable)->height/2,
				1);
			}
		case ANI_STRIP:
			{
			Script *ssq;

			ssq = (sscript->child_scripts)[((struct ani_strip *)
			poly)->script_ix];
			if (sscript->local_time >= ssq->start_time  &&
			sscript->local_time <= ssq->stop_time) /*time clip */
			{
			ssc_xoff += 
				poly->center.x - ((struct ani_strip *)poly)->xhot;
			ssc_yoff += 
				poly->center.y - ((struct ani_strip *)poly)->yhot;
			ssc_zoff += 
				poly->center.z - ((struct ani_strip *)poly)->zhot;
			draw_pllist(ssq->next_poly_list, ssq);
			ssc_xoff -= 
				poly->center.x - ((struct ani_strip *)poly)->xhot;
			ssc_yoff -= 
				poly->center.y - ((struct ani_strip *)poly)->yhot;
			ssc_zoff -= 
				poly->center.z - ((struct ani_strip *)poly)->zhot;
			}
#ifdef DEBUG
			else
			{
			printf("tclip %ld %ld %ld\n", ssq->start_time,
				sscript->local_time, ssq->stop_time);
			timeless_sleep(1);
			}
#endif DEBUG
			}
			break;
#ifdef PARANOID
		default:
			lprintf("unknown raster type %d in draw_pl_with\n",
			poly->type);
			break;
#endif PARANOID
		}
	}
else
	{
	if ( !(poly = cube_clip(poly) ) )
		return;
	switch (type)
		{
		case FILLED:
			if (poly)
				{
				if (ghost_mode)
					outline_poly( poly);
				else
					fill_poly( poly);
				}
			break;
		case OUT_LINE:
		case JUST_LINE:
			if (poly)
				{
				outline_poly( poly);
				}
			break;
#ifdef LATER
		case FONT_VECTOR:
			if (poly)
				{
				decode_font(poly);
				}
			break;
#endif LATER
		case COLOR_RECT:
			{
			register LLpoint *p1, *p2;

			p1 = poly->clipped_list;
			p2 = p1->next;
			if (ghost_mode)
				draw_frame(poly->color, p1->x, p1->y, p2->x, p2->y);
			else
				colblock(poly->color, p1->x, p1->y, p2->x, p2->y);
			}
			break;
#ifdef PARANOID
		default:
			lprintf("unknown poly type %d in draw_pl_with\n",poly->type);
			break;
#endif PARANOID
		}
	}
}

#ifdef EDITOR
unrub_ppoints(poly, sscript)
struct poly *poly;
Script *sscript;
{
Cube c;

if (find_bounding_box(poly, &c, sscript) )
	{
	/*add a little around edges to cover point cursors... */
	c.x -= 3;
	c.y -= 3;
	c.X += 3;
	c.Y += 3;
	if (size_down_to_safety(&c))
		restore_from_back(&c);
	}
}

rub_poly_pts(poly, sscript)
struct poly *poly;
Script *sscript;
{
hilite_poly(poly, 1);
}

unrub_poly(poly, sscript)
struct poly *poly;
Script *sscript;
{
Cube c;

if (find_bounding_box(poly, &c, sscript) )
	restore_from_back(&c);
}

rub_poly(poly, sscript)
struct poly *poly;
Script *sscript;
{
Cube c;

draw_pl_with(poly, sscript);
if (poly->type & IS_RASTER)
	{
	if (find_bounding_box(poly, &c, sscript) )
		draw_frame(cycle_color, c.x, c.y, c.X-1, c.Y-1);
	}
}

find_bounding_box(poly, box, sscript)
Poly *poly;
Cube *box;
Script *sscript;
{
extern WORD ground_z;
extern Poly *de_z();
int i;
LLpoint *p;
WORD type;

if ( (type = poly->type) & IS_RASTER)
	{
	register WORD xoff, yoff, width, height;
	register OBJ *drawable;

	drawable = (OBJ *)poly->clipped_list;
	xoff = poly->center.x + ssc_xoff;
	yoff = poly->center.y + ssc_yoff;
	if (in_story_mode)
		{
		xoff = scale_mult(xoff, ssc_scale);
		yoff = scale_mult(yoff, ssc_scale);
		if (type != COLOR_BLOCK && type != ANI_STRIP)
			if (!(drawable = (OBJ *)
				( ((struct raster_list *)drawable)->scaled)))
					return(0);
		}
	else
		{
		if (type != COLOR_BLOCK && type != ANI_STRIP)
			if (! (drawable = (OBJ *)
				( ((struct raster_list *)drawable)->raster)))
				return(0);
		}
	switch (type)
		{
		case ANI_STRIP:
			{
			WORD ret, xff, yff, zff;
			
			xff = poly->center.x - ((struct ani_strip *)poly)->xhot;
			yff = poly->center.y - ((struct ani_strip *)poly)->yhot;
			zff = poly->center.z - ground_z;
			ssc_xoff += xff;
			ssc_yoff += yff;
			ssc_zoff += zff;
			ret = bbox_script( 
			sscript->child_scripts[
			((struct ani_strip *)poly)->script_ix], box);
			ssc_xoff -= xff;
			ssc_yoff -= yff;
			ssc_zoff -= zff;
			return(ret);
			}
			break;
#ifdef AMIGA
		case AMIGA_BITMAP:
			width = ((struct BitMap *)drawable)->width;
			height = ((struct BitMap *)drawable)->Rows;
			break;
#endif AMIGA
#ifdef SUN
		case BYPLANE_RASTER:
#ifdef REAL_SLEAZY
			return(0);
#else REAL_SLEAZY
			width = ((struct byte_plane *)drawable)->width;
			height = ((struct byte_plane *)drawable)->height;
#endif REAL_SLEAZY
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
		case ATARI_CEL:
			width = ((struct atari_cel *)drawable)->width;
			height = ((struct atari_cel *)drawable)->height;
			break;
		case COLOR_BLOCK:
			width = ((struct color_block *)poly)->width;
			height = ((struct color_block *)poly)->height;
			if (in_story_mode)
				{
				width = scale_mult(width, ssc_scale);
				height = scale_mult(height, ssc_scale);
				}
			break;
#ifdef PARANOID
		default:
			lprintf("unknown raster type %d in find_bounding_box\n",
				poly->type);
			break;
#endif PARANOID
		}
	xoff -= width/2;
	yoff -= height/2;
	box->x = box->X = xoff;
	box->X += width;
	box->y = box->Y = yoff;
	box->Y += height;
	}
else
	{
	if ((poly = de_z(poly, ground_z/50)) == NULL)
	return(0);
	i = poly->pt_count;
	if (i<=0)
	return(0);
	p = poly->clipped_list;
	box->x = box->X = p->x;
	box->y = box->Y = p->y;
	--i;
	p = p->next;
	while (--i >= 0)
		{
		if (box->x > p->x)
			box->x = p->x;
		if (box->y > p->y)
			box->y = p->y;
		if (box->X <= p->x)
			box->X = p->x+1;
		if (box->Y <= p->y)
			box->Y = p->y+1;
		p = p->next;
		}
	}
box->X++;
box->Y++;
if (size_down_to_safety(box))
	return(1);
else
	return(0);
}

bbox_script(ss, bb)
Script *ss;
Square *bb;
{
Square box;
Poly *poly, **polys;
Poly_list *plist;
int i;
int found;

plist = ss->next_poly_list;
i = plist->count;
if (i < 1)
	return(0);
polys = plist->list;
found = 0;
while (--i >= 0)
	{
	if (find_bounding_box( *polys++, bb, ss) )
		{
		found = 1;
		break;
		}
	}
if (!found)
	return(0);
while (--i >= 0)
	{
	if (find_bounding_box( *polys++, &box, ss) )
		box_union(&box, bb);
	}
return(1);
}

box_union(source, dest)
register Square *source, *dest;
{
if (dest->x > source->x)
	dest->x = source->x;
if (dest->X < source->X)
	dest->X = source->X;
if (dest->y > source->y)
	dest->y = source->y;
if (dest->Y < source->Y)
	dest->Y = source->Y;
}


#define REAL_SLEAZY
undraw_poly(poly, sscript)
register struct poly *poly;
Script *sscript;
{
register WORD color;
register WORD type;
Cube bounding_box;
Cube old_clip;
extern Cube clipping_cube;

if (find_bounding_box(poly, &bounding_box, sscript))
	{
	copy_structure(&clipping_cube, &old_clip, sizeof(Cube) );
	copy_structure(&bounding_box, &clipping_cube, sizeof(Cube) );
	poly->type |= HIDE_BIT;
	see_seq(cur_sequence);
	poly->type &= ~HIDE_BIT;
	copy_structure(&old_clip, &clipping_cube, sizeof(Cube) );
	}
}

draw_pledge(poly,color, sscript)
register struct poly *poly;
register WORD color;
Script *sscript;
{
register WORD type;
Cube bounding_box;

if ( (type = poly->type) & IS_RASTER)
	{
	if (find_bounding_box(poly, &bounding_box, sscript) )
	draw_frame( color,
		bounding_box.x, bounding_box.y,
		bounding_box.X-1, bounding_box.Y-1);
	}
else
	{
	register WORD ocolor = poly->color;

	if (poly->type == FILLED)
	poly->type = OUT_LINE;
	poly->color = color;
	draw_pl_with(poly, sscript);
	poly->color = ocolor;
	poly->type = type;
	}
}

#endif EDITOR
