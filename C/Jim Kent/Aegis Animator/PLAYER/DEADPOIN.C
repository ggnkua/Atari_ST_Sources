
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\animath.h"



/******DEAD_POINTS.C  - yuck I HATE dead points.
	Basically this file results from the fact that you can't kill
	a point as soon as the user does.  You have to keep it alive until
	the end of a tween so that the polygon does'nt appear to snap
	or jerk.  You have to keep it alive so that it will appear to
	gradually merge into one of it's neighbors.
	Anyway I hate dead points and I'm sure you will too if you
	have to work with this program.
*******/

find_dead_segment(tween, poly_ix, poly, this_ix, start_ix, segment_length)
struct tween *tween;
WORD poly_ix;
struct poly *poly;
WORD this_ix;
WORD *start_ix;
WORD *segment_length;
{
extern WORD *build_dead_list();
WORD *dead_list, *dead_pt, dead_count;
WORD next_ix, last_ix;
WORD i;

#ifdef DEBUG
lprintf("find_dead_segment(%lx %d %lx %d %lx %lx)\n",tween, poly_ix, poly,
	this_ix, start_ix, segment_length);
#endif DEBUG
dead_list = build_dead_list( tween, poly_ix);

*segment_length = 1;
next_ix = this_ix;
dead_pt = dead_list+1;
dead_count = *dead_list-1;
for (i=0; i< dead_count; i++)
	{
	if (next_ix == dead_pt[i])
	{
	(*segment_length)++;
	next_ix++;
	if (poly_wrap(&next_ix, poly->pt_count));
		i = -1;
	}
	} /*find next living vertex*/

last_ix = this_ix-1;
poly_wrap(&last_ix, poly->pt_count);
i = dead_count;
while (--i >= 0)
	{
	if (last_ix == dead_pt[i])
	{
	(*segment_length)++;
	--last_ix;
	if (poly_wrap(&last_ix, poly->pt_count) );
		i = dead_count;
	}
	}/*find last living vertex*/
*start_ix = last_ix + 1;
poly_wrap(start_ix, poly->pt_count);

free_tube(dead_list);
#ifdef DEBUG
lprintf("next = %d this %d last = %d pt_count = %d\n",
	next_ix, this_ix, last_ix, poly->pt_count);
#endif DEBUG
}


WORD *
build_dead_list(tween, poly_ix)
struct tween *tween;
WORD poly_ix;
{
WORD **acts, *act, act_count;
WORD *dead_list, *new_dead_list;

#ifdef DEBUG
lprintf("build_dead_list(%lx %d)\n", tween, poly_ix);
#endif DEBUG

dead_list = (WORD *) alloc( sizeof(WORD) );
*dead_list = 1;
act_count = tween->act_count;
acts = tween->act_list + act_count;
while (--act_count >= 0)
	{
	act = *(--acts);
	if ( *(act+2) == poly_ix )
	{
	switch( *(act+1) )
		{
		case KILL_POINT:
		new_dead_list = (WORD *)
			alloc( (*dead_list + 1) * sizeof(WORD));
		copy_structure(dead_list, new_dead_list,
			*dead_list * sizeof(WORD) );
		new_dead_list[ *dead_list ] = *(act+3);
		mfree( dead_list, *dead_list * sizeof(WORD) );
		dead_list = new_dead_list;
		(*dead_list)++;
		break;
		case INSERT_POLY:
		case INSERT_RASTER:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		if ( act[2] < poly_ix)
			--poly_ix;
		else if ( act[2] == poly_ix)
			act_count = 0;
		break;
		case KILL_POLY:
		if ( *(act+2) <= poly_ix )
			poly_ix++;
		break;
		default:
		break;
		}
	}
	}
tube_sort(dead_list);
return(dead_list);
}


/*doto_dead_too:
** this routine is passed list and count.  However *count better be one or
** else.  By the time we get through it might be more.  This is to generate
** addresses to move along dead points too.
**/
WORD **
doto_dead_too(seq, poly_list, list, count)
struct s_sequence *seq;
struct poly_list *poly_list;
WORD **list;
WORD *count;
{
extern WORD **tlist(), **add_to_tube_list();
WORD *dead_list, *dead_pt, dead_count;
WORD *living_addr;
struct tween *tween;
WORD poly_ix;
WORD point_ix;
WORD last_point_ix;
struct poly *poly;
WORD i;
WORD *another_addr;
WORD next, last;
WORD start_ix;

#ifdef DEBUG
lprintf("doto_dead_too(seq%lx %lx %lx %d)\n", seq, poly_list, list, *count);
#endif DEBUG

living_addr = *list;

poly_ix = living_addr[2];
point_ix = living_addr[3];
poly = *(poly_list->list + poly_ix);
tween = *(seq->next_tween);


switch( living_addr[1] )  /*type*/
	{
	case POINTS:
	find_dead_segment(tween, poly_ix, poly, 
		point_ix, &start_ix, &dead_count);
	if (dead_count > 1)
		{
		another_addr = (WORD *)alloc(address_length[SEGMENT]
			* sizeof(WORD) );
		another_addr[0] = address_length[SEGMENT];
		another_addr[1] = SEGMENT;
		another_addr[2] = poly_ix;
		another_addr[3] = start_ix;
		another_addr[4] = dead_count;
		another_addr[5] = poly->pt_count;
		*list = another_addr;
		mfree(living_addr, *living_addr * sizeof(WORD) );
		}
	break;
	case SEGMENT:
	dead_list = build_dead_list(tween, poly_ix);
	last_point_ix = *(living_addr+3) + *(living_addr+4) - 1;
	dead_pt = dead_list+1;
	for (i=0; i<*dead_list; i++)
		{
		if ( *(dead_pt++) == last_point_ix)
		{
		last_point_ix++;
		if (last_point_ix >= poly->pt_count)
			{
			point_ix = 0;
			dead_pt = dead_list+1;
			i = 0;
			}
		living_addr[4]++;
		}
		}
	mfree(dead_list, *dead_list * sizeof(WORD) );
	break;
	case POLYS:
	case FRAME:
	break;
	}
return(list);
}

	
