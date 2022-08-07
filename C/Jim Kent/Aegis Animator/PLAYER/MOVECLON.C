

overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\script.h"
#include "..\\include\\color.h"

move_poly(s,d,xoff,yoff)
register struct poly *s, *d;
register WORD xoff, yoff;
{
register struct point *dp, *sp;
register WORD i;

d->center.x = s->center.x + xoff;
d->center.y = s->center.y + yoff;
if ( !(s->type & IS_RASTER) )
	{
	sp = s->pt_list;
	dp = d->pt_list;
	i = s->pt_count;
	while (--i >= 0)
	{
	dp->x = sp->x + xoff;
	dp->y = sp->y + yoff;
	dp++;
	sp++;
	}
	}
}



free_poly_list(poly_list)
register struct poly_list *poly_list;
{
register struct poly **polys;
register WORD count;

#ifdef DEBUG
printf("free_poly_list(%lx)\n", poly_list);
lsleep(1);
#endif DEBUG

if (poly_list)
	{
	count = poly_list->alloc;
	polys = poly_list->list;
	while (--count >= 0)
	free_poly( *(polys++) );
	mfree(poly_list->list, poly_list->alloc * sizeof(struct poly *) );
	mfree(poly_list->zlist, poly_list->alloc * sizeof(struct poly *) );
	mfree(poly_list->cmap, MAXCOL * sizeof(struct color_def) );
	free_string(poly_list->bg_name);
	mfree(poly_list, sizeof(struct poly_list) );
	}
}


free_poly(poly)
register struct poly *poly;
{

if (poly)
	{
	if ( !(poly->type & IS_RASTER) )
#ifdef SLOWER
	mfree( poly->pt_list, poly->pt_alloc * sizeof(struct point) );
#else  SLOWER
	mfree( poly->pt_list, poly->pt_alloc<<3);
#endif SLOWER
	mfree(poly, sizeof(struct poly) );
	}
}

Item_list *
clone_item_list(source)
register Item_list *source;
{
register Item_list *dest = NULL;
register Item_list *next;

while (source)
	{
	if ( !(next = (Item_list *)alloc(sizeof(Item_list) ) ))
	{
	free_item_list(dest);
	return(NULL);
	}
	next->next = dest;
	next->item = source->item;
	dest = next;
	source = source->next;
	}
return(dest);
}


Item_list *
clone_n_link_rasters(source)
register Item_list *source;
{
#ifdef DEBUG
printf("clone_n_link_rasters(%lx)\n", source);
lsleep(1);
#endif DEBUG

source = clone_item_list(source);
if (source)
	link_rasters(source);
return(source);
}

free_n_unlink_rasters(list)
register Item_list *list;
{
#ifdef DEBUG
printf("free_n_unlink_rasters(%lx)\n", list);
lsleep(1);
#endif DEBUG

unlink_rasters(list);
free_item_list(list);
}


fr_act_list(list, count)
register WORD **list, count;
{
register WORD *act;

while (--count >= 0)
	{
	act = *list++;
#ifdef SLOWER
	mfree(act, act[0]*sizeof(WORD) );
#else SLOWER
	mfree(act, act[0]<<1);
#endif SLOWER
	}
}

fr_tweens(ss)
struct s_sequence *ss;
{
register struct tween *tween, **tweens;
register WORD i;

#ifdef DEBUG
printf("fr_tweens(%lx)\n", ss);
lsleep(1);
#endif DEBUG

if (!ss)
	return;
tweens = ss->tween_list;
i = ss->tween_alloc;
while (--i >= 0)
	{
	tween = *(tweens++);
	fr_act_list(tween->act_list, tween->act_count);
#ifdef SLOWER
	mfree(tween->act_list, tween->act_count<<2);
#else SLOWER
	mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
#endif SLOWER
	free_poly_list(tween->poly_list);
	mfree( tween, sizeof(struct tween) );
	}
#ifdef SLOWER
mfree(ss->tween_list,  ss->tween_alloc << 2);
#else SLOWER
mfree(ss->tween_list, ss->tween_alloc * sizeof(Tween *) );
#endif SLOWER
}



rfree_s_sequence(ss, level)
register struct s_sequence *ss;
int level;
{
register Script **sc;
WORD i;

#ifdef DEBUG
printf("rfree_s_sequence(%lx, %d)\n", ss, level);
lsleep(1);
#endif DEBUG

if (!ss)
	return;

/*recursively free children first */
sc = ss->child_scripts;
i = ss->child_count;
while (--i >= 0)
	{
	rfree_s_sequence(*sc++, level+1);
	}
mfree(ss->child_scripts, ss->child_count * sizeof(Script *) );
free_poly_list(ss->next_poly_list);

if (level == 0)
	{
	fr_tweens(ss);
	free_string(ss->name);
	free_n_unlink_rasters(ss->script_rasters);
	}

mfree(ss, sizeof(struct s_sequence) );
}

free_s_sequence(ss)
struct s_sequence *ss;
{
#ifdef DEBUG
printf("free_s_sequence(%lx)\n", ss);
lsleep(1);
#endif DEBUG

rfree_s_sequence(ss, 0);
clean_raster_master();
}

Poly *
clone_poly(poly)
register Poly *poly;
{
poly = (Poly *)clone_structure( poly, sizeof(Poly) );
if (poly)
	{
	if ( !(poly->type & IS_RASTER) )
	{
	if (poly->pt_alloc = poly->pt_count)
		{
		if ( !(poly->pt_list = (Point *)clone_structure(poly->pt_list,
			poly->pt_count * sizeof(Point) ) ) )
		{
		mfree(poly, sizeof(Poly) );
		return(NULL);
		}
		}
	}
	}
return(poly);
}

Poly_list *
clone_plist(poly_list)
register struct poly_list *poly_list;
{
register Poly **polys;
register WORD i;

#ifdef DEBUG
printf("clone_plist(%lx)\n", poly_list);
lsleep(1);
#endif DEBUG

if (poly_list == NULL)
	return(NULL);
poly_list = (Poly_list *)clone_structure(poly_list, sizeof(Poly_list) );
if (poly_list)
	{
	i = poly_list->alloc = poly_list->count;
	if (i)
	{
	if ( !(poly_list->zlist = (Poly **)
			alloc( i * sizeof(Poly *) ) ) )
		{
		mfree(poly_list, sizeof(Poly_list) );
		return(NULL);
		}
	if ( !(polys = poly_list->list = (Poly **)
			clone_structure( poly_list->list, i * sizeof(Poly *) ) ) )
		{
		mfree(poly_list->zlist, i * sizeof(Poly *) );
		mfree(poly_list, sizeof(Poly_list) );
		return(NULL);
		}
	while (--i >= 0)
		{
		if ( !( *polys = (Poly *)clone_poly( *polys ) ) )
		{
		i = poly_list->count - i - 1;
		while (--i >= 0)
			free_poly( *(--polys) );
		mfree(poly_list->zlist, poly_list->count * sizeof(WORD *) );
		mfree(poly_list->list, poly_list->count * sizeof(WORD *) );
		mfree(poly_list, sizeof(Poly_list) );
		return(NULL);
		}
		polys++;
		}
	}
	poly_list->cmap = (struct color_def *)clone_structure( poly_list->cmap,
	MAXCOL * sizeof(struct color_def) );
	poly_list->bg_name = clone_string(poly_list->bg_name);
	}
return(poly_list);
}

Tween *
clone_tween(tween, with_polys)
register Tween *tween;
WORD with_polys;
{
register WORD **acts, *act;
register WORD i;

tween = (Tween *)clone_structure(tween, sizeof(Tween) );
if (tween)
	{
	if (with_polys)
	{
	if ((tween->poly_list = clone_plist(tween->poly_list)) == NULL)
		{
		mfree(tween, sizeof(Tween) );
		return(NULL);
		}
	}
	else
	tween->poly_list = NULL;
	if ( i = tween->act_count)
	{
	acts = tween->act_list = (WORD **)clone_structure(tween->act_list,
		i * sizeof(WORD *) );
	if (acts)
		{
		while (--i>=0)
		{
		act = *acts;
		act = (WORD *)clone_structure( act, act[0] * sizeof(WORD) );
		if ( !(*acts = act) )
			{
			i = tween->act_count - i - 1;
			while (--i >= 0)
			free_tube( *(--acts) );
			mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
			free_poly_list(tween->poly_list);
			mfree(tween, sizeof(Tween) );
			return(NULL);
			}
		acts++;
		}
		}
	else
		{
		free_poly_list(tween->poly_list);
		mfree(tween, sizeof(Tween) );
		return(NULL);
		}
	}
	}
return(tween);
}


Script *
rclone_script(s, level, for_undo)
register Script *s;
WORD level, for_undo;
{
WORD i;
int next_tween_ix;


next_tween_ix = s->next_tween - s->tween_list;
s = Clone_a(s, Script);

clone_kids(s, level, for_undo);

s->next_poly_list = NULL;

if (level == 0)
	{
	register Tween **t;

	s->script_rasters = clone_n_link_rasters(s->script_rasters);
	s->tween_alloc = i = s->tween_count;
	t = s->tween_list = 
	(Tween **)clone_structure(s->tween_list, i*sizeof(Tween *));
	while (--i >= 0)
	{
	*t = clone_tween(*t, !for_undo);
	t++;
	}
	s->name = clone_string(s->name);
	}
s->next_tween = s->tween_list + next_tween_ix;
return(s);
}

clone_kids(s, level, for_undo)
register Script *s;
WORD level, for_undo;
{
register Script **children;
WORD i;

/*recursively clone children */
i = s->child_count;
children = s->child_scripts = (Script **)
	clone_structure(s->child_scripts, i*sizeof(Script *) );
while (--i >= 0)
	{
	*children = rclone_script(*children, level+1, for_undo);
	children++;
	}
}

Script *
clone_s_sequence(s)
Script *s;
{
#ifdef DEBUG
printf("clone_s_sequence(%lx)\n", s);
lsleep(1);
#endif DEBUG

s = rclone_script(s, 0, 0 /* not for undo */);
return(s);
}

Script *
uclone_s_sequence(s)
Script *s;
{
s = rclone_script(s, 0, 1 /* for undo */);
return(s);
}

fr_tween(tween)
register struct tween *tween;
{
register WORD **acts, *act;
register WORD i;

#ifdef DEBUG
printf("fr_tween(%lx)\n", tween);
lsleep(1);
#endif DEBUG

i = tween->act_count;
acts = tween->act_list;
while (--i >= 0)
	{
	act = *(acts++);
	mfree( act, act[0] * sizeof(WORD ));
	}
mfree( tween->act_list, tween->act_count * sizeof(WORD *) );
free_poly_list(tween->poly_list);
mfree(tween, sizeof(struct tween) );
}


free_name_list(list)
register Name_list *list;
{
register Name_list *next;

while ( list )
	{
	next = list->next;
	free_string(list->name);
	mfree(list, sizeof(Name_list) );
	list = next;
	}
}

free_item_list(list)
register Item_list *list;
{
register Item_list *next;

while (list)
	{
	next = list->next;
	mfree(list, sizeof(Item_list));
	list = next;
	}
}
