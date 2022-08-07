
overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\addr.h"
#include "..\\include\\acts.h"
#include "..\\include\\story.h"


extern WORD **clean_tube_list();


/***********************************************************
*
*		born in tween
*
*	returns act # of birth act if born in tween, -1 if not
*
*	tween - tween in question
*	act_ix - one plus where will start looking, ie if you
*		use this to see if a kill poly act removes its
*		own birthing, then pass ix of kill poly act.
*	poly_ix - poly_ix at act referred to by act_ix
*************************************************************/
born_in_tween(tween, act_ix, poly_ix)
register Tween *tween;
WORD act_ix;
WORD poly_ix;
{
register WORD **acts, *act;
register WORD i;

acts = tween->act_list + act_ix;
while (--act_ix >= 0)
	{
	act = *(--acts);
	switch (act[OP])
		{
		case INSERT_POLY:
		case INSERT_RASTER:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			if (poly_ix == act[PL] )
			return(act_ix);
			if (poly_ix > act[PL] )
			--poly_ix;
			break;
		case KILL_POLY:
			if (poly_ix >= act[PL] )
			poly_ix++;
			break;
		default:
			break;
		}
	}
return(-1);
}

rm_from_birth(tween, birth_ix)
register Tween *tween;
WORD birth_ix;
{
WORD poly_ix;
register WORD *act, **acts;
register WORD i;

acts = tween->act_list + birth_ix;
act = *acts;
poly_ix = act[2];
*acts++ = NULL;
/*free act of birth */

i = tween->act_count - birth_ix - 1;
while (--i >= 0)
	{
	act = *acts;
	switch (act[1] )
		{
		case INSERT_RASTER:
		case INSERT_POLY:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			if (act[2] <= poly_ix)
				poly_ix++;
			else
				--act[2];
			break;
		case KILL_POLY:
			if (act[2] < poly_ix)
				--poly_ix;
			else if (act[2] == poly_ix)
				{
				free_tube(act);
				*acts = NULL;
				i = 0;
				}
			else
				--act[2];
				break;
		case MOVE_POINT:
		case ROT_POINT:
		case INSERT_POINT:
		case KILL_POINT:
		case ROT_SEGMENT:
		case MOVE_POLY:
		case ROT_POLY:
		case CHANGE_COLOR:
		case CHANGE_OCOLOR:
		case CHANGE_FCOLOR:
		case SIZE_POINT:
		case SIZE_SEGMENT:
		case SIZE_POLY:
		case CHANGE_TYPE:
		case MOVE_SEGMENT:
		case PATH_POINT:
		case PATH_POLY:
		case PATH_SEGMENT:
			/*all ops that effects are limited to a polygon*/
			if (act[2] > poly_ix)
				--act[2];
			else if (act[2] == poly_ix)
				{
				free_tube(act);
				*acts = NULL;
				}
			break;
		case MOVE_POLYS:
		case ROT_POLYS:
		case SIZE_POLYS:
		case PATH_POLYS:
			/*ops that effect multiple polygons*/
			if (act[2] > poly_ix)
				--act[2];  /*removing underneath segment*/
			else if (act[2] <= poly_ix && act[2] + act[3] > poly_ix)
			/*removing poly in middle of segment*/
				{
				--act[3];
				}
			if ( act[3] <= 0)	/*free up if no polys left */
				{
				free_tube(act);
				*acts = NULL;
				}
			break;
#ifdef PARANOID
		case INIT_COLORS:
		case LOAD_BACKGROUND:
		case REMOVE_BACKGROUND:
		case TWEEN_COLOR:
		case CYCLE_COLORS:
		case TWEEN_TO_COLORS:
			break;
		default:
			printf("unknown case %d in rm_from_birth\n", act[1]);
			break;
#endif PARANOID
		}
	acts++;
	}
tween->act_list = clean_tube_list( tween->act_list, &(tween->act_count) );
}

rm_dead_acts(tween, death_ix, poly_ix)
Tween *tween;
WORD death_ix;  /*where to start removing... */
WORD poly_ix;   /*poly ix at that point*/
{
register WORD *act, **acts;
register WORD i;
extern WORD **clean_tube_list();

#ifdef DEBUG
printf("rm_dead_acts()\n");
#endif DEBUG

acts = tween->act_list + death_ix;
act = *acts;

i = death_ix;
while (--i >= 0)
	{
	act = *(--acts);
	switch (act[1] )
		{
		case INSERT_RASTER:
		case INSERT_POLY:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			if (act[2] < poly_ix)
			--poly_ix;
			break;
		case KILL_POLY:
			if (act[2] <= poly_ix)
			poly_ix++;
			break;
		case MOVE_POINT:
		case ROT_POINT:
		case INSERT_POINT:
		case KILL_POINT:
		case ROT_SEGMENT:
		case MOVE_POLY:
		case ROT_POLY:
		case CHANGE_COLOR:
		case CHANGE_OCOLOR:
		case CHANGE_FCOLOR:
		case SIZE_POINT:
		case SIZE_SEGMENT:
		case SIZE_POLY:
		case CHANGE_TYPE:
		case MOVE_SEGMENT:
		case PATH_POINT:
		case PATH_POLY:
		case PATH_SEGMENT:
			/*all ops that effects are limited to a polygon*/
			if (act[2] == poly_ix)
				{
				free_tube(act);
				*acts = NULL;
				}
			break;
		case MOVE_POLYS:
		case ROT_POLYS:
		case SIZE_POLYS:
		case PATH_POLYS:
			/*ops that effect multiple polygons*/
			break;
#ifdef PARANOID
		case INIT_COLORS:
		case LOAD_BACKGROUND:
		case REMOVE_BACKGROUND:
		case TWEEN_COLOR:
		case CYCLE_COLORS:
		case TWEEN_TO_COLORS:
			break;
		default:
			printf("unknown case %d in rm_dead_acts\n", act[1]);
			break;
#endif PARANOID
		}
	}
tween->act_list = clean_tube_list( tween->act_list, &(tween->act_count) );
return;
}


find_next_addr( init_act_list, init_act_count, poly_ix, 
	point_ix, next_poly_ix, next_point_ix, kill_reix)
WORD **init_act_list, init_act_count;
WORD poly_ix, point_ix;
WORD *next_poly_ix, *next_point_ix;
WORD kill_reix;
{
register WORD **act_list;
WORD act_count;
register WORD *act;
WORD ref_poly_ix = poly_ix;

act_list = init_act_list;
act_count = init_act_count;
while (--act_count>= 0)
	{
	act = *act_list++;
	switch (act[OP])
		{
		case INSERT_POLY:
		case INSERT_RASTER:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			if (poly_ix >= act[PL] )
			poly_ix++;
			break;
		case KILL_POLY:
			if (poly_ix == act[PL] )
			act_count = 0;
			else if (poly_ix < act[PL] )
			--poly_ix;
			break;
		case INSERT_POINT:
			if (point_ix >= 0 && poly_ix == act[PL] )
			if (point_ix >= act[PT] )
				point_ix++;
			break;
		default:
			break;
		}
	}
act_list = init_act_list;
act_count = init_act_count;
poly_ix = ref_poly_ix;
while (--act_count>= 0)
	{
	act = *act_list++;
	switch (act[OP])
		{
		case INSERT_POLY:
		case INSERT_RASTER:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			if (poly_ix >= act[PL] )
			poly_ix++;
			break;
		case KILL_POLY:
			if (poly_ix == act[PL] )
			act_count = 0;
			else if (poly_ix < act[PL] )
			--poly_ix;
			break;
		case KILL_POINT:
			if (kill_reix && poly_ix == act[PL] )
			if (point_ix == act[PT] )
				act_count = 0;   /*hey we're already dead*/
			else if (point_ix > act[PT] )
				--point_ix;
			break;
		default:
			break;
		}
	}
*next_poly_ix = poly_ix;
if (next_point_ix)
	{
	*next_point_ix = point_ix;
	}
}



mid_to_end_addr(poly_ix, mid_point_ix, act_list, act_count)
WORD poly_ix;
WORD mid_point_ix;
WORD **act_list;
WORD act_count;
{
WORD *act;

while (--act_count >= 0)
	{
	act = *act_list++;
	if (act[2] == poly_ix && act[1] == INSERT_POINT && act[3] <= mid_point_ix)
		mid_point_ix++;
	if ( (act[1] == INSERT_POLY || act[1] == INSERT_RASTER || 
	act[1] == INSERT_STRIP
	|| act[1] == INSERT_CBLOCK || act[1] == INSERT_STENCIL))
		 if ( act[2] <= poly_ix)
			poly_ix++;
	if ( act[1] == KILL_POLY)
		if (act[2] < poly_ix)
			--poly_ix;
	else if (act[2] == poly_ix)
		act_count = 0;  /* we are gone */
	}
return(mid_point_ix);
}

remove_act(tween, act_ix)
register struct tween *tween;
register WORD act_ix;
{
WORD **acts, *act;
WORD **new_act_list;
WORD **re_acts;

new_act_list = (WORD **)
	alloc((tween->act_count-1) * sizeof(WORD *) );

act = *(tween->act_list + act_ix);

copy_structure(tween->act_list, new_act_list,
	(act_ix) * sizeof(WORD *) );
copy_structure(tween->act_list + act_ix + 1, new_act_list + act_ix,
	( tween->act_count -act_ix - 1) * sizeof(WORD *) );

mfree(act, *act * sizeof(WORD) );
mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
tween->act_list = new_act_list;
--tween->act_count;
}





insert_point_in_s_sequence(ss, poly_ix, point_ix)
struct s_sequence *ss;
WORD poly_ix;
WORD point_ix;
{
struct tween *tween;
WORD i;
WORD *act, **acts;
WORD sub_end_tween;

tween = *(ss->next_tween);
acts = tween->act_list;
i = tween->act_count;
sub_end_tween = 0;
while (--i >= 0)
	{
	act = *(acts++);
	if (act[1] == KILL_POINT && act[2] == poly_ix)
		{
		if (act[3] >= point_ix)
			(act[3]++);
		else
			sub_end_tween++;
		}
	/*move up kill points since none of them executed until end frame*/
	}
point_ix -= sub_end_tween;
upindex_points_in_s_sequence(ss, ss->next_tween+1, poly_ix, point_ix);
}

upindex_points_in_s_sequence(ss, start_tween, poly_ix, point_ix)
struct s_sequence *ss;
struct tween **start_tween;
WORD poly_ix;
WORD point_ix;
{
struct tween *tween, **tweens, **end_tweens;
WORD i;
WORD *act, **acts;
WORD *new_act;
WORD *spt, *dpt, *new_point;
WORD j;
WORD top_seg;
WORD sub_end_tween;

tweens = start_tween;
end_tweens = ss->tween_list + ss->tween_count;
while (tweens < end_tweens)
	{
	tween = *(tweens++);
	sub_end_tween = 0;
	acts = tween->act_list;
	i = tween->act_count;
	while (--i >= 0)
		{
		act = *acts++;
		switch ( *(act+1) )
			{
			case INSERT_POLY:
			case INSERT_RASTER:
			case INSERT_STENCIL:
			case INSERT_CBLOCK:
			case INSERT_STRIP:
				if ( *(act+2) <= poly_ix)
					poly_ix++;
				break;
			case KILL_POLY:
				if ( *(act+2) < poly_ix )
					--poly_ix;
				if ( *(act+2) == poly_ix)
					return;  /*from now on we're already dead*/
				break;
			default:
				if ( poly_ix == *(act+2)  )
					{
					switch(*(act+1) )
						{
						case INSERT_POINT:
							if ( *(act+3) <= point_ix)
								point_ix++;
							else
								( *(act+3))++;
							break;
						case KILL_POINT:
							if ( mid_to_end_addr( poly_ix, point_ix, acts, i)
								 > *(act+3) )
								sub_end_tween++;
							else
								( *(act+3))++;
							break;
						case MOVE_POINT:
						case ROT_POINT:
						case SIZE_POINT:
							if ( *(act+3) >= point_ix)
								(*(act+3))++;
							break;
						case MOVE_SEGMENT:
						case ROT_SEGMENT:
						case SIZE_SEGMENT:
							top_seg = act[3] + act[4];
							if ( (point_ix > act[3] && point_ix < top_seg)
							|| (point_ix + act[5] > act[3] &&
							point_ix + act[5] < top_seg))
								act[4]++;  /*inside segment so expand it*/
							else if (point_ix <= act[3] )
								act[3]++;  /*below segment so move it up*/
							break;
						default:
							break;
						}  
					}
			break;  /* outer switch*/
			}
		}
	point_ix -= sub_end_tween;
	}
}

kpt_in_s_sequence(ss, poly_ix, point_ix)
struct s_sequence *ss;
WORD poly_ix;
WORD point_ix;
{
struct tween *tween, **tweens, **end_tweens;
WORD i;
WORD *act, **acts;
WORD *new_act;
WORD *spt, *dpt;
WORD j;
WORD top_seg;
WORD sub_end_tween;  /*to gather together end point ops in a tweens effect*/
WORD end_addr;

tweens = ss->next_tween + 1;
end_tweens = ss->tween_list + ss->tween_count;
while (tweens < end_tweens)
	{
	tween = *(tweens++);
	sub_end_tween = 0;
	for (i=0; i<tween->act_count; i++)
		{
		act = *(tween->act_list + i);
		switch ( *(act+1) )
			{
			case INSERT_POLY:
			case INSERT_RASTER:
			case INSERT_STENCIL:
			case INSERT_CBLOCK:
			case INSERT_STRIP:
				if ( *(act+2) <= poly_ix)
					poly_ix++;
				break;
			case KILL_POLY:
				if ( *(act+2) < poly_ix )
					--poly_ix;
				if ( *(act+2) == poly_ix)
					return;  /*from now on we're already dead*/
				break;
			default:
				if ( poly_ix == *(act+2)  )
					{
					switch(*(act+1) )
						{
						case INSERT_POINT:
							if ( *(act+3) < point_ix)
								point_ix++;
							else
								--*(act+3);
							break;
						case KILL_POINT:
							end_addr = mid_to_end_addr( poly_ix, point_ix,
							tween->act_list + i + 1,
							tween->act_count - i - 1);
							if ( *(act+3) < end_addr )
								{
								sub_end_tween++;
								}
							else if ( *(act+3) == end_addr)
								{
								remove_act(tween, i);
								return;  /*from now on we're already dead*/
								}
							else
								--*(act+3);
							break;
						case MOVE_POINT:
						case ROT_POINT:
						case SIZE_POINT:
							if ( *(act+3) > point_ix)
								--*(act+3);
							if ( *(act+3) == point_ix)
								remove_act(tween, i);
							break;
						case MOVE_SEGMENT:
						case ROT_SEGMENT:
						case SIZE_SEGMENT:
							top_seg = act[3] + act[4];
							if ( (point_ix >= act[3] && point_ix < top_seg)
							|| (point_ix + act[5] >= act[3] &&
							point_ix + act[5] < top_seg) )
								--(act[4]);  /*inside segment so contract*/
							else if (point_ix < act[3] )
								--(act[3]);  /*below segment so move it down*/
							break;
						default:
							break;
						}  
					}
			break;  /* outer switch*/
			}
		}
	point_ix -= sub_end_tween;
	}
}

insert_poly_in_s_sequence(ss, poly_ix)
struct s_sequence *ss;
WORD poly_ix;
{
struct tween *tween, **tweens, **end_tweens;
WORD i;
WORD *act, **acts;
WORD *re_act, **re_acts;
WORD **new_act_list;
WORD j;

tweens = ss->next_tween + 1;
end_tweens = ss->tween_list + ss->tween_count;
while (tweens < end_tweens)
	{
	tween = *(tweens++);
	for (i=0; i< tween->act_count; i++)
		{
		act = *(tween->act_list + i);
		if ( *(act+2) >= poly_ix)
			{
			(*(act+2))++;
			}
		else
			{
			switch ( *(act+1) )
				{
				case MOVE_POLYS:
				case ROT_POLYS:
				case SIZE_POLYS:
					if ( *(act+2) + *(act+3) >  poly_ix)
						(*(act+3))++;
					break;
				case INSERT_POLY:
				case INSERT_RASTER:
				case INSERT_STENCIL:
				case INSERT_CBLOCK:
				case INSERT_STRIP:
					poly_ix++;
					break;
				case KILL_POLY:
					--poly_ix;
					break;
				default:
					break;
				}
			}
		}
	}
}


kpl_in_s_sequence(ss, poly_ix)
struct s_sequence *ss;
WORD poly_ix;
{
struct tween *tween, **tweens, **end_tweens;
WORD birth_ix;

tweens = ss->next_tween;
tween = *tweens++;
if ( (birth_ix = born_in_tween(tween, tween->act_count-1, poly_ix) ) >= 0)
	{
	rm_from_birth(tween, birth_ix);
	}
else
	{
	rm_dead_acts(tween, tween->act_count - 1, poly_ix);
	}
end_tweens = ss->tween_list + ss->tween_count;
while (tweens < end_tweens)
	if ((poly_ix = kpl_in_tween( *tweens++, poly_ix) ) < 0)
	break;
}


kpl_in_tween(tween, poly_ix)
Tween *tween;
WORD poly_ix;
{
WORD i;
WORD *act, **acts;

acts = tween->act_list;
for (i=0; i< tween->act_count; i++)
	{
	act = *acts;
	act = *(tween->act_list + i);
	if ( *(act+2) > poly_ix)
		--*(act+2);
	else if ( *(act+2) == poly_ix )
		{
		switch ( *(act+1) )
			{
			case MOVE_POLYS:
			case ROT_POLYS:
			case SIZE_POLYS:
			--*(act+3);  /*decrement poly_count*/
			if ( act[3] <= 0)
				{
				free_tube(act);
				*acts = NULL;
				}
			break;
			case KILL_POLY:
			free_tube(act);
			*acts = NULL;
			tween->act_list = 
				clean_tube_list( tween->act_list, 
				&(tween->act_count) );
			return(-1);
			break;
			case INSERT_POLY:
			case INSERT_RASTER:
			case INSERT_STENCIL:
			case INSERT_CBLOCK:
			case INSERT_STRIP:
			poly_ix++;
			break;
			default:
			free_tube(act);
			*acts = NULL;
			break;
			}
		}
	else
		{
		switch ( *(act+1) )
			{
			case MOVE_POLYS:
			case ROT_POLYS:
			case SIZE_POLYS:
			if ( *(act+2) + *(act+3) >  poly_ix)
				{
				--*(act+3);
				if ( act[3] <= 0)
				{
				free_tube(act);
				*acts = NULL;
				}
				}					
			break;
			case INSERT_POLY:
			case INSERT_RASTER:
			case INSERT_STENCIL:
			case INSERT_CBLOCK:
			case INSERT_STRIP:
				poly_ix++;
				break;
			case KILL_POLY:
				--poly_ix;
				break;
			default:
				break;
			}
		}
	acts++;
	}
tween->act_list = clean_tube_list( tween->act_list, &(tween->act_count) );
return(poly_ix);
}

poly_balance(tween)
struct tween *tween;
{
int balance;
WORD **acts, *act;
WORD i;

balance = 0;
acts = tween->act_list;
i = tween->act_count;
while (i--)
	{
	act = *(acts++);
	switch ( *(act+1) )
		{
		case KILL_POLY:
			balance--;
			break;
		case INSERT_POLY:
		case INSERT_RASTER:
		case INSERT_STENCIL:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
			balance++;
			break;
		}
	}
return(balance);
}

do_one_upstream(op, ss)
register WORD *op;
register Script *ss;
{
switch ( *(op+1) )
	{
	case INSERT_POINT:
		insert_point_in_s_sequence(ss, *(op+2), *(op+3) );
		break;
	case KILL_POINT:
		kpt_in_s_sequence(ss, *(op+2), *(op+3) );
		break;
	case INSERT_POLY:
	case INSERT_RASTER:
	case INSERT_STENCIL:
	case INSERT_CBLOCK:
	case INSERT_STRIP:
		insert_poly_in_s_sequence(ss, *(op+2) );
		break;
	case KILL_POLY:
		kpl_in_s_sequence(ss, *(op+2) );
		break;
	case CHANGE_COLOR:
	case CHANGE_OCOLOR:
	case CHANGE_FCOLOR:
	case CHANGE_TYPE:
	case INIT_COLORS:
	case LOAD_BACKGROUND:
	case REMOVE_BACKGROUND:
	case TWEEN_COLOR:
	case CYCLE_COLORS:
	case TWEEN_TO_COLORS:
		break;
	default:
		general_implications(ss, op);
		break;
	}
}

do_upstream( op_list, op_count, ss)
register WORD **op_list;
register WORD op_count;
register struct s_sequence *ss;
{
while (--op_count >= 0)
	do_one_upstream( *op_list++, ss);
}



