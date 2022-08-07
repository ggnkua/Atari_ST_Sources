
overlay "find"

#ifdef SUN

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\animath.h"
#include "..\\include\\addr.h"

extern char *op_name[];  /*for debugging*/
extern WORD *clone_tube();

WORD *
split_op(op, start, stop)
register WORD *op;
WORD start, stop;
{
WORD type;
WORD length;
WORD samples,first_sample,last_sample;
WORD *scratch;
WORD *return_op;
WORD i;
WORD firstx, firsty, firstz;

#ifdef DEBUG
lprintf("split_op(%s %d %d)\n",op_name[op[1]], start, stop);
#endif DEBUG

type = function_type[ op[1] ];
switch( type )
	{
	case ROT_OP:
	return_op = op = (WORD *)clone_structure(op, op[0]*sizeof(WORD) );
	op += op_offset(op);
	op[5] = scale_mult(op[5], stop) - scale_mult(op[5], start);
	return(return_op);
	case MOVE_OP:
	return_op = op = (WORD *)clone_structure(op, op[0]*sizeof(WORD) );
	op += op_offset(op);
	op[0] = scale_mult(op[0], stop) - scale_mult(op[0], start);
	op[1] = scale_mult(op[1], stop) - scale_mult(op[1], start);
	op[2] = scale_mult(op[2], stop) - scale_mult(op[2], start);
	return(return_op);
	case SIZE_OP:
	op = return_op = (WORD *)clone_structure(op, op[0]*sizeof(WORD) );
	op += op_offset(op);
	op[3] = op[4] 
		-  scale_mult(op[4], stop) + scale_mult(op[4], start)
		+  scale_mult(op[3], stop) - scale_mult(op[3], start);
	return(return_op);
	case SAMPLE_OP:
	{
	WORD ooffset;

	lprintf("splitting SAMPLE_OP\n");

	ooffset = op_offset(op);
	samples = *(op + ooffset);
	first_sample = scale_mult(samples,start);
	last_sample = scale_mult(samples,stop);
	printf("first sample %d, last_sample %d\n", first_sample, last_sample);
	samples = last_sample - first_sample;
	length =	ooffset + 3*samples + 1;
	return_op = (WORD *)alloc(length * sizeof(WORD) );
	copy_structure( op, return_op, 
		ooffset * sizeof(WORD) ); /*copy address*/
	return_op[0] = length;
	scratch = return_op + ooffset;
	*scratch++ = i = samples;
	op += ooffset - 2 + first_sample*3;
		/*point to last sample before split*/
	if (first_sample == 0)
		{
		firstx = firsty = firstz = 0;
		op += 3;
		}
	else
		{
		firstx = *op++;
		firsty = *op++;
		firstz = *op++;
		}
	printf( "(%d %d %d)\n", firstx, firsty, firstz);
	while (--i >= 0)
		{
		printf("(%d ", *op - firstx);
		*(scratch++) = *(op++) - firstx;
		printf("%d ", *op - firsty);
		*(scratch++) = *(op++) - firsty;
		printf("%d)\t", *op - firstz);
		*(scratch++) = *(op++) - firstz;
		}
	printf("\n");
	}
	return(return_op);
	default:
	return( (WORD *)clone_structure(op, op[0]*sizeof(WORD)));
	break;
	}
}

WORD *
second_split_op(new_act, scale, acts, act_count)
WORD *new_act;
WORD scale;
WORD **acts;
WORD act_count;
{
WORD *act;
Script *ss;
Tween *tw1, *tw2, **tw_list;

new_act = split_op(new_act, scale, SCALE_ONE);  /*split w/out upstream... */

ss = (Script *)clone_structure(&generic_sequence, sizeof(Script) );
tw1 = (Tween *)clone_structure(&grc_tween, sizeof(Tween) );
tw2 = (Tween *)clone_structure(&grc_tween, sizeof(Tween) );
tw_list = (Tween **)alloc(2*sizeof(Tween *) );
tw_list[0] = tw1;
tw_list[1] = tw2;
ss->tween_count = 2;
ss->next_tween = ss->tween_list = tw_list;

tw2->act_count = 1;
tw2->act_list = &new_act;
/*prepare a very small script of one act so can use general implications*/

printf("second split\n");
print_tube("new_act", new_act);
while (--act_count >= 0)
	{
	act = *acts++;
	if ( act[1] != KILL_POINT)
	{
	act = split_op(act, 0, scale);
	do_one_upstream(act, ss);
	free_tube(act);
	}
	}
mfree(ss, sizeof(Script) );
mfree(tw1, sizeof(Tween));
mfree(tw2, sizeof(Tween));
mfree(tw_list, 2*sizeof(Tween *) );
print_tube("snew_act", new_act);
return(new_act);
}



/****
**
split_tween()
**
**	
	geometric ops are split and appear in both tweens.
	KILL_POINT appears just in the second tween.
	INSERT_POINT, INSERT_POLY, KILL_POLY, INIT_COLORS all
	appear only in first tween
*****/

split_tween(tween, tween1_pt, tween2_pt, scale)
struct tween *tween;
struct tween **tween1_pt, **tween2_pt;
WORD scale;
{
register WORD **acts1;
register WORD *act1;
register WORD **acts;
register WORD *act;
struct tween *tween1, *tween2;
WORD i,j;
extern WORD address_type[];
WORD ftype;

printf("split_tween(%s %d)\n");

tween1 = (struct tween *)clone_structure( tween, sizeof(struct tween) );
tween1->tweening = scale_mult(scale, tween1->tweening);
tween1->stop_time = tween1->start_time + tween1->tweening;
tween1->act_count = 0;
i = tween->act_count;
acts = tween->act_list;
while( --i >= 0)	/*first just count how many acts in first half */
	{
	act = *(acts++);
	switch( act[1]   )
	{
	case KILL_POINT:
		break;
	default:
		tween1->act_count += 1;
		break;
	}
	}

tween1->act_list = acts1 = (WORD **)
	alloc( tween1->act_count * sizeof(WORD *) );
i = tween->act_count;
acts = tween->act_list;
while( --i >= 0)
	{
	act = *(acts++);
	switch( act[1]  )
	{
	case KILL_POINT:
		break;
	default:
		*(acts1++) = split_op( act, 0, scale );
		break;
	}
	}

tween2 = (struct tween *)clone_structure( tween, sizeof(struct tween) );
tween2->start_time = tween1->stop_time;
tween2->tweening = tween2->stop_time - tween2->start_time;
tween2->act_count = 0;
i = tween->act_count;
acts = tween->act_list;
while( --i >= 0)		/*count how many acts in second half*/
	{
	act = *(acts++);
	switch(act[1])
	{
	case INSERT_POINT:
	case INSERT_POLY:
	case INSERT_RASTER:
	case INSERT_STENCIL:
	case INIT_COLORS:
	case KILL_POLY:
	case REMOVE_BACKGROUND:
	case LOAD_BACKGROUND:
	case CHANGE_TYPE:
	case CHANGE_COLOR:
		break;
	default:
		tween2->act_count++;
		break;
	}
	}

tween2->act_list = acts1 = (WORD **)
	alloc( tween2->act_count * sizeof(WORD *) );
i = tween->act_count;
acts = tween->act_list;
while( --i >= 0)
	{
	act = *(acts++);
	switch(act[1])
	{
	case INSERT_POINT:
	case INSERT_POLY:
	case INSERT_RASTER:
	case INSERT_STENCIL:
	case INIT_COLORS:
	case KILL_POLY:
	case REMOVE_BACKGROUND:
	case LOAD_BACKGROUND:
	case CHANGE_TYPE:
	case CHANGE_COLOR:
		break;
	case KILL_POINT:
		*acts1++ = clone_tube(act);
		find_next_addr(acts, i, act[2], -1,
		act+2, NULL, 0);
		break;
	default:
		*(acts1++) = act = second_split_op( act , scale, acts, i);
#ifdef NEVER	
		*acts1++ = split_op(act, scale, SCALE_ONE);
		if ( address_type[ act[1] ] == POINTS ||
		address_type[ act[1] ] == SEGMENT)
		find_next_addr( acts, i, act[2], act[3],
			act+2, act+3, 0);
		else
		find_next_addr( acts, i, act[2], -1,
			act+2, NULL, 0);
#endif NEVER
		break;
	}
	}
*tween1_pt = tween1;
*tween2_pt = tween2;
}

#endif SUN
