
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\script.h"
#include "..\\include\\color.h"


struct poly_list *empty_poly_list();

cken_tweens(ss)
register struct s_sequence *ss;
{
register struct tween *tween, **tweens;
extern struct tween grc_tween;
WORD j;
WORD tween_offset;

#ifdef DEBUG
lprintf("cken_tweens(seq%lx)\n",ss);
#endif DEBUG

tween_offset = ss->next_tween - ss->tween_list;	
while ( (j=ss->tween_alloc) < ss->tween_count)
	{
	tweens = (struct tween **)(alloc( (j+1)*sizeof(struct tween *) )  );
	copy_structure(ss->tween_list, tweens, j * sizeof(struct tween *) );
	mfree(ss->tween_list, j * sizeof(struct tween*));
	ss->tween_list = tweens;
	ss->next_tween = ss->tween_list + tween_offset;
	*(tweens + j) = tween = (struct tween *)
	clone_structure( &grc_tween, sizeof(struct tween) );
	tween->poly_list = empty_poly_list();
	ss->tween_alloc++;
	}
}

cken_polys(ss)
register struct s_sequence *ss;
{
#ifdef DEBUG
lprintf("cken_polys(seq%lx)\n",ss);
#endif DEBUG

check_poly_list( (ss->next_poly_list) );
}

check_poly_list(poly_list)
register struct poly_list *poly_list;
{
#ifdef DEBUG
lprintf("check_poly_list(%lx)\n",poly_list);
lprintf("%lx->(%d %d %lx)\n", poly_list, poly_list->count, poly_list->alloc,
	poly_list->list);
#endif DEBUG

while (  poly_list->count > poly_list->alloc)
	{
	register struct poly **temp_p;
	register struct poly *new_poly;
	extern WORD ground_z;


	temp_p = (struct poly **)(alloc(sizeof(struct poly *) *
		(poly_list->alloc + 1) ));
	copy_structure(poly_list->list, temp_p,
		sizeof(struct poly *) *(poly_list->alloc) );
	mfree(poly_list->list, 
		sizeof(struct poly *) *(poly_list->alloc) );
	poly_list->list = temp_p;
	/*allocate new polygon_list*/

	grc_poly.center.z = ground_z;
	temp_p[poly_list->alloc] = new_poly = (struct poly *)
	clone_structure(&grc_poly, sizeof(struct poly) );
	/*and allocate a polygon, and point last polygon pointer to
	  us*/

	temp_p = (struct poly **)(alloc(sizeof(struct poly *) *
		(poly_list->alloc + 1) ));
	mfree(poly_list->zlist, 
		sizeof(struct poly *) *(poly_list->alloc) );
	poly_list->zlist = temp_p;
	/*allocate new polygon_zlist*/

	poly_list->alloc++;
	}

}

cken_points(poly)
register struct poly *poly;
{

#ifdef DEBUG
lprintf("cken_points( poly%lx )\n",poly);
lprintf("pt_count %d pt_alloc %d\n",poly->pt_count, poly->pt_alloc);
#endif DEBUG

if (poly->type & IS_RASTER)
	return;
if (poly->pt_count  > poly->pt_alloc)
	{
	register struct point *pt_list;

	pt_list = (struct point *) alloc( sizeof(struct point) * poly->pt_count);
	copy_structure(poly->pt_list, pt_list, 
	sizeof(struct point) * poly->pt_alloc );
	mfree(poly->pt_list, sizeof(struct point) * poly->pt_alloc);
	poly->pt_list = pt_list;
	poly->pt_alloc = poly->pt_count;
	}
}



add_act(tween, act)
register struct tween *tween;
WORD *act;
{
register WORD **new_act_list;

new_act_list = (WORD **)alloc( (tween->act_count + 1) * sizeof(WORD *)  );
copy_structure( tween->act_list, new_act_list,
	tween->act_count * sizeof(WORD *));

mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
tween->act_list = new_act_list;

new_act_list += tween->act_count;
*new_act_list = act;
(tween->act_count)++;
}


WORD **
expand_act_list(tween)
struct tween *tween;
{
WORD **acts;

acts = (WORD **)alloc( sizeof(WORD *) * (tween->act_count+1) );
if (acts)
	{
	copy_structure(tween->act_list, acts, 
		tween->act_count * sizeof(WORD *) );
	mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
	tween->act_list = acts;
	acts += tween->act_count;
	tween->act_count++;;
	}
return(acts);
/* expand act list*/
}

/******
*******		copy_poly(sp, dp)
*******
******* what can I say... this routine actually worked quite well before
******* I introduced rasters.  Now it is apt to cause the system to 
******* shift and jerk when scene shifts from rasters to polys, or
******* even when object inserted near head of list in a mixed list.
******* Sorry.  This should fall out in the wash eventually.
*******/
copy_poly(sp, dp)
register struct poly *sp, *dp;
{
#ifdef DEBUG
lprintf("copy_poly( %lx %lx )\n",sp, dp);
#endif DEBUG

if (sp->type & IS_RASTER)
	{
	if (!(dp->type & IS_RASTER))
	mfree(dp->pt_list, sizeof(Point) * dp->pt_alloc);
	copy_structure(sp, dp, sizeof(struct poly) );
	}
else
	{
	if ( dp->type & IS_RASTER)
	{
	copy_structure(sp, dp, sizeof(struct poly) );
	dp->pt_list = (Point *)clone_structure(dp->pt_list,
		dp->pt_count * sizeof(Point));
	dp->pt_alloc = dp->pt_count;
	}
	else
	{
	dp->type = sp->type;
	dp->color = sp->color;
	dp->fill_color = sp->fill_color;
	dp->center.x = sp->center.x;
	dp->center.y = sp->center.y;
	dp->center.z = sp->center.z;
	dp->center.level = sp->center.level;
	dp->pt_count = sp->pt_count;

	if (dp->pt_count  > dp->pt_alloc)
		{
		mfree(dp->pt_list, sizeof(struct point) * dp->pt_alloc);
		dp->pt_list =
			(struct point *) 
			alloc( sizeof(struct point) * dp->pt_count);
		dp->pt_alloc = dp->pt_count;
		}
	copy_structure( sp->pt_list, dp->pt_list, 
		sp->pt_count * sizeof(struct point) );
	}
	}
}


copy_poly_list(sp_list, dp_list)
struct poly_list *sp_list, *dp_list;
{
register struct poly **sl, **dl;
register WORD count;
register struct poly *spl, *dpl;

#ifdef DEBUG
lprintf("copy_poly_list(%lx, %lx)\n",sp_list, dp_list);
#endif DEBUG

count = dp_list->count = sp_list->count;
check_poly_list(dp_list);

sl = sp_list->list;
dl = dp_list->list;
	
while (--count>= 0)
	copy_poly( *(sl++), *(dl++) );

copy_structure(sp_list->cmap, dp_list->cmap,
	MAXCOL * sizeof(struct color_def) );
if ( jstrcmp(sp_list->bg_name, dp_list->bg_name) != 0)
	{
	free_string(dp_list->bg_name);
	dp_list->bg_name = clone_string(sp_list->bg_name);
	}
}


