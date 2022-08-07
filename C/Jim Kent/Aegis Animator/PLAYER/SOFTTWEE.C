

overlay "timer"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\story.h"
#include "..\\include\\animath.h"
#include "..\\include\\replay.h"
#include "..\\include\\color.h"


extern struct BitMap *bbm;
extern WORD see_beginning;

startup_sequence(ss)
register Script *ss;
{
#ifdef DEBUG
printf("startup_sequence(%lx)\n");
#endif DEBUG
loop_around_script(ss);
adjust_pos_in_tween(ss);
}

loop_around_script(ss)
register struct s_sequence *ss;
{
register Script *child;
Script **sc;
WORD i;

#ifdef DEBUG
lprintf("loop_around_script( %lx )\n",ss);
#endif DEBUG
sc = ss->child_scripts;
i = ss->child_count;
while (--i >= 0)
	{
	child = *sc++;
	loop_around_script(child);
	if (child->forward_offset != 0)
	{
	advance_timer(child, child->forward_offset, REPLAY_LOOP);
	}
	}
if (ss->tween_count)
	{
	register Tween *tw;
	ss->next_tween = ss->tween_list;
	tw = *(ss->next_tween);
	ss->local_time = 0;
	if (ss->next_poly_list != NULL)
	ss->next_poly_list->count = 0;
	ss->since_last_tween = 0;
	ss->to_next_tween = tw->tweening;
	}
}

#ifdef DEBUG
timeless_sleep(secs)
WORD secs;
{
stop_time();
lsleep(secs);
start_time();
}
#endif DEBUG

adjust_pos_in_tween(ss)
Script *ss;
{
Tween *tween;

#ifdef DEBUG
lprintf("adjust_pos_in_tween( %lx )\n",ss, begin);
#endif DEBUG

if ( ss && ss->tween_count)
	{
	tween = *(ss->next_tween);
	if (see_beginning)
	{
	tseek(ss, tween->start_time);
	}
	else
	{
	tseek(ss, tween->stop_time);
	}
	}
}

tseek(ss, time)
Script *ss;
long time;
{
loop_around_script(ss);
advance_timer(ss, time, REPLAY_LOOP);
}

static
advance_kids(ss, t)
register Script *ss;
register long t;
{
Script **kids;
register Script *kid;
register long toff;
register WORD i;

i = ss->child_count;
kids = ss->child_scripts;
while (--i >= 0)
	{
	toff = t;
	kid = *kids++;
	if (kid->stop_time <= ss->local_time)	/* we're past our time */
	continue;
	if (kid->start_time > ss->local_time + toff)
	continue;	/* not time for us yet */ 
	if (kid->start_time <= ss->local_time)
	{
	/*we're starting in the kid's lifetime, got to see if ending too...*/
	if (kid->stop_time < ss->local_time + toff)
		toff = kid->stop_time - ss->local_time;
	}
	else
	{
	/*starting before kid is alive ... will we end after he's dead? */
	if (kid->stop_time >= ss->local_time + toff)
		/* here the end is in kid's lifetime */
		toff = ss->local_time + toff - kid->start_time;
	else
		/*here the kid is born and dies within toff ... */
		toff = kid->stop_time - kid->start_time;
	}
	advance_timer(kid, 
	(((kid->local_time +toff)*kid->speed+16)>>5) -
	((kid->local_time*kid->speed+16)>>5),
	REPLAY_LOOP);
	}
}


advance_timer(ss,toff, stop_when)
register struct s_sequence *ss;
register long toff;
WORD stop_when;
{
register struct tween **tweens, *tweet;
register long duration;

#ifdef DEBUG
printf("advance_timer(%lx %ld %d)\n",ss,toff, stop_when);
lsleep(1);
#endif DEBUG

if (toff == 0)
	return(0);
if ( !(ss->tween_count) )
	return(1);

duration = ss->duration;
if (toff < 0)
	{
	long time;

	time = ss->local_time;
	if (stop_when == REPLAY_START_END)
	if (toff + ss->local_time <= 0)
		return(1);
	loop_around_script(ss);
	toff += time;
	if (toff < 0)
	{
	while (toff < 0)
		toff += duration;
	}
	}

if (ss->to_next_tween <= toff)
	{
	if (stop_when == REPLAY_TWEEN)
	return(1);
	else if (stop_when == REPLAY_START_END && ss->next_tween >= ss->tween_list +
	 	ss->tween_count-1)
	return(1);
	}
/*go recurse to kids first */
advance_kids(ss, toff);

while (ss->to_next_tween <= toff)
	{
	if (!see_beginning && ss->to_next_tween == toff)
	break;

	tweens = ss->next_tween+1;
	toff -= ss->to_next_tween;
	ss->local_time += ss->to_next_tween;

	/*if come to end of script, loop around (which restarts kids at 0 time)
	  and kick the kids forward by whats left of toff after the loop */
	if (tweens >= ss->tween_list + ss->tween_count)
		{
		if (stop_when == REPLAY_START_END)
		return(1);
		tweens = ss->tween_list;
		loop_around_script(ss);
		advance_kids(ss, toff);
		}
	else
		{
		ss->since_last_tween = 0;
		ss->to_next_tween = (*tweens)->tweening;
		}
	ss->next_tween = tweens;
	}
ss->to_next_tween -= toff;
ss->since_last_tween += toff;
ss->local_time += toff;
return(0);
}



remove_dead(poly, dead_list)
register struct poly *poly;
WORD *dead_list;
{
register WORD *dd_list;
register WORD count, dead_count;
register WORD i;
register struct point *spt, *dpt;

#ifdef DEBUG
printf("remove_dead(%lx %lx)\n", poly, dead_list);
#endif DEBUG

dd_list = dead_list;
dead_count = *(dd_list++) - 1;
if (dead_count <= 0)
	return;

count = poly->pt_count;
spt = dpt = poly->pt_list;
for (i=0; i<count && dead_count > 0; i++) 
	{
	if ( *dd_list == i)
	{
	spt++;
	--(poly->pt_count);
	--dead_count;
	dd_list++;
	}
	else
	{
	copy_structure( spt, dpt, sizeof(struct point) );
	spt++;
	dpt++;
	}
	}
for ( ; i<count; i++)
	{
	copy_structure( spt, dpt, sizeof(struct point) );
	spt++;
	dpt++;
	}
}

overlay "player"

act_on_poly_list( act_list, act_count, poly_list, scale, ss)
WORD **act_list;
WORD act_count;
register struct poly_list *poly_list;
WORD scale;
Script *ss;
{
register WORD *pt;
register WORD **acts;
register WORD i;


#ifdef DEBUG
printf("act_on_poly_list(%lx %d %lx %d %lx)\n",
	act_list, act_count, poly_list, scale, ss);
#endif DEBUG
acts = act_list;
i = act_count;
while (--i >= 0)
	{
	pt = *(acts++);
	switch ( pt[1] )
	{
	case MOVE_POINT:
		amv_point(poly_list, pt, scale);
		break;
	case MOVE_POLY:
		amv_poly(poly_list, pt, scale);
		break;
	case MOVE_SEGMENT:
		amv_segment(poly_list, pt, scale);
		break;
	case ROT_POINT:
		aro_point(poly_list, pt, scale);
		break;
	case ROT_SEGMENT:
		aro_segment(poly_list, pt, scale);
		break;
	case ROT_POLY:
		aro_poly(poly_list, pt, scale);
		break;
	case INSERT_POINT:
		ain_point(poly_list, pt, scale);
		break;
	case INSERT_POLY:
		ain_poly(poly_list, pt, scale);
		break;
	case CHANGE_COLOR:
		acg_color(poly_list, pt);
		break;
	case CHANGE_TYPE:
		acg_type(poly_list, pt);
		break;
	case KILL_POINT:
		break;
	case KILL_POLY:
		aki_poly(poly_list, pt, scale);
		break;
	case MOVE_POLYS:
		amv_polys(poly_list, pt, scale);
		break;
	case ROT_POLYS:
		aro_polys(poly_list, pt, scale);
		break;
	case SIZE_POLYS:
		asz_polys(poly_list, pt, scale);
		break;
	case SIZE_POINT:
		asz_point(poly_list, pt, scale);
		break;
	case SIZE_SEGMENT:
		asz_segment(poly_list, pt, scale);
		break;
	case SIZE_POLY:
		asz_poly(poly_list, pt, scale);
		break;
	case PATH_POINT:
		apa_point(poly_list, pt, scale);
		break;
	case PATH_POLY:
		apa_poly(poly_list, pt, scale);
		break;
	case PATH_POLY_PTS:
		lprintf("path_poly_pts\n");
		break;
	case PATH_SEGMENT:
		apa_segment(poly_list, pt, scale);
		break;
	case PATH_POLYS:
		apa_polys(poly_list, pt, scale);
		break;
	case INIT_COLORS:
		aii_colors(poly_list, pt, scale);
		break;
	case INSERT_RASTER:
		ain_raster(poly_list, pt, scale);
		break;
	case INSERT_STENCIL:
		ain_stencil(poly_list, pt, scale);
		break;
	case LOAD_BACKGROUND:
		ald_background(poly_list, pt, scale);
		break;
	case REMOVE_BACKGROUND:
		arm_background(poly_list, pt, scale);
		break;
	case TWEEN_COLOR:
		atw_color(poly_list, pt, scale);
		break;
	case CYCLE_COLORS:
		acy_colors(poly_list, pt, scale);
		break;
	case INSERT_CBLOCK:
		ain_cblock(poly_list, pt, scale);
		break;
	case TWEEN_TO_COLORS:
		atw_to_colors(poly_list, pt, scale);
		break;
	case INSERT_STRIP:
		ain_strip(poly_list, pt, scale);
		break;
	case CHANGE_OCOLOR:
		acg_ocolor(poly_list, pt);
		break;
	case CHANGE_FCOLOR:
		acg_fcolor(poly_list, pt);
		break;
	default:
		lprintf("unknown case in act_on_poly_list\n");
		break;
	}
	}
}

static mc_frame();

WORD update_cm;
m_frame(ss)
register struct s_sequence *ss;
{
register struct tween *tween;
register struct poly_list *poly_list;
register int time_scale;
extern WORD ground_z;

#ifdef DEBUG
printf("m_frame( %lx )\n",ss);
lsleep(1);
#endif DEBUG

if (ss->tween_count == 0)
	return;

mc_frame(ss);

ground_z = ss->level_z;
if ((poly_list = (ss->next_poly_list)) == NULL)
	ss->next_poly_list = poly_list = empty_poly_list();
tween = *(ss->next_tween);
copy_poly_list( tween->poly_list, poly_list );
if (tween->tweening == 0)
	{
#ifdef PARANOID
	lprintf("zero tween time\n");
#endif PARANOID
	time_scale = 0;
	}
else
	time_scale = uscale_by(SCALE_ONE, ss->since_last_tween, tween->tweening);
act_on_poly_list( tween->act_list, tween->act_count, poly_list, time_scale, ss);
}

static
mc_frame(ss)
register Script *ss;
{
Script **schilds;
register Script *schild;
register WORD i;

#ifdef DEBUG
printf("mc_frame(%lx %lx)\n", ss, plist);
lsleep(1);
#endif DEBUG

if ( (i = ss->child_count) > 0)
	{
	schilds = ss->child_scripts;
	while (--i >= 0)
	{
	schild = *schilds++;
	if (ss->local_time >= schild->start_time  &&
		ss->local_time <= schild->stop_time)
		m_frame( schild);
	}
	}
}


make_frame(ss)
Script *ss;
{
#ifdef DEBUG
printf("make_frame(%lx)\n", ss);
lsleep(1);
#endif DEBUG
m_frame(ss);
see_seq(ss);
if (update_cm)
	{
	copy_structure(ss->next_poly_list->cmap, usr_cmap,
	MAXCOL * sizeof(struct color_def) );
	put_cmap(usr_cmap, 0, MAXCOL);
	update_cm = 0;
	}
}

overlay "timer"

end_frame(poly_list,tween, ss)
struct poly_list  *poly_list;
struct tween *tween;
Script *ss;
{
WORD poly_ix;
register struct poly **polys;
WORD *dead_list;
extern WORD *build_dead_list();

#ifdef DEBUG
printf("end_frame(%lx %lx %lx)\n", poly_list, tween, ss);
lsleep(1);
#endif DEBUG
act_on_poly_list( tween->act_list, tween->act_count, poly_list, SCALE_ONE, ss);

poly_ix = poly_list->count;
polys = poly_list->list + poly_ix;
while (--poly_ix >= 0)
	{
	dead_list = build_dead_list(tween, poly_ix);
	remove_dead( *(--polys), dead_list);
	mfree(dead_list, *dead_list * sizeof(WORD) );
	}
}


retween_poly_list(ss)
Script *ss;
{
tween_poly_list(ss);
}

tween_poly_list(ss)
Script *ss;
{
Tween **tweens, *last_tween, *next_tween;
int i;

#ifdef DEBUG
printf("tween_poly_list(%lx)\n", ss);
lsleep(1);
#endif DEBUG

i = ss->tween_count;
if (i < 1)
	return;
tweens = ss->tween_list;
last_tween = *tweens++;
if (last_tween->poly_list == NULL)
	last_tween->poly_list = empty_poly_list();
else
	last_tween->poly_list->count = 0;
i -= 1;
while (--i >= 0)
	{
	next_tween = *tweens++;
	if (next_tween->poly_list == NULL)
	next_tween->poly_list = empty_poly_list();
	copy_poly_list( last_tween->poly_list, next_tween->poly_list );
	end_frame(next_tween->poly_list, last_tween, ss);
	last_tween = next_tween;
	}
initimes(ss);
}

initimes(ss)
Script *ss;
{
Tween **tweens;
Tween *tween;
register WORD **acts;
register WORD *act;
register WORD i, j;
Poly_list *poly_list;
struct ani_strip *strip;
Script **children, *child;
long duration;

if ((i = ss->child_count) <= 0)
	return;	/* no kids, no hassle... */

ss->duration = duration = script_duration(ss);
/* Make it so "unused" children are never activated */
children = ss->child_scripts;
while (--i >= 0)
	{
	child = *children++;
	child->start_time = child->stop_time = duration; 
	}
	
poly_list = empty_poly_list();
children = ss->child_scripts;
tweens = ss->tween_list;
i = ss->tween_count;
while (--i >= 0)
	{
	tween = *tweens++;
	acts = tween->act_list;
	j = tween->act_count;
	while (--j >= 0)
	{
	act = *acts++;
	switch (act[1])
		{
		case INSERT_POLY:
			ain_poly(poly_list, act, SCALE_ONE);
		break;
		case KILL_POLY:
		strip = (struct ani_strip *)poly_list->list[act[2]];
		if (strip->type == ANI_STRIP)
			{
			register Script *script;

			script = children[ strip->script_ix];
			if (script->stop_time > tween->start_time)
			script->stop_time = tween->start_time;
			}
		aki_poly(poly_list, act, SCALE_ONE);
		break;
		case INSERT_RASTER:
		ain_raster(poly_list, act, SCALE_ONE);
		break;
		case INSERT_STENCIL:
		ain_stencil(poly_list, act, SCALE_ONE);
		break;
		case INSERT_CBLOCK:
		ain_cblock(poly_list, act, SCALE_ONE);
		break;
		case INSERT_STRIP:
		{
		register Script *kid;

		ain_strip(poly_list, act, SCALE_ONE);
		strip = (struct ani_strip *)poly_list->list[act[2]];
		kid = children[strip->script_ix];
		kid->start_time = tween->start_time;
		kid->forward_offset = act[10]*10000L + act[11];
		if (act[13] != 0)
			{
			kid->speed = act[13];
			}
		if (act[12] != 0)	/*looping */
			{
			kid->stop_time = kid->start_time + 
			act[12] * ((script_duration(kid) * 32 + kid->speed/2)/
			kid->speed);
#ifdef DEBUG
printf("looping %d %ld to %ld\n", act[12], kid->start_time, kid->stop_time); 
lsleep(1);
#endif DEBUG
			}
		}
		break;
		}
	}
	}
free_poly_list(poly_list);
}
