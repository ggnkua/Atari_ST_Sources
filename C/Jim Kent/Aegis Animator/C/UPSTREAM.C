
overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\animath.h"
#include "..\\include\\poly.h"


#ifdef NO_OVERLAY
/*this is a hairy routine that is used by the upstream editing code.
  basically it determines if the op question is effected by the
  insertion of the op concerned upstream*/
op_concerns_op( concerned, question)
register WORD *concerned, *question;
{
WORD c_type, q_type;

c_type = address_type[ concerned[OP] ];
q_type = address_type[ question[OP] ];
if (q_type > c_type)
	return(0);
switch( c_type )
	{
	case POINTS:
	if (concerned[PL] != question[PL] )
		return(0);
	if (concerned[PT] == question[PT] )
		return(1);
	else
		return(0);
	break;
	case SEGMENT:
	if (concerned[PL] != question[PL] )
		return(0);
	switch (q_type)
		{
		case POINTS:
		if ( question[PT] >= *(concerned+3) &&
			question[PT] < *(concerned+3) + *(concerned+4) )
			return(1);
		else if ( question[PT] + *(concerned+5) >= *(concerned+3) &&
			question[PT]  + *(concerned+5) < 
			*(concerned+3) + *(concerned+4) )
			return(1);
		else
			return(0);
		break;
		case SEGMENT:  /*segment only effected if question seg inside
				 concerned segment.  Not just overlapping */
		if ( *(question+3) >= *(concerned+3) &&
			*(question+3) + *(question+4) <= 
			*(concerned+3) + *(concerned+4) )
			return(1);
		else
			return(0);
		}
	case POLYS:
	if (concerned[PL] != question[PL] )
		return(0);
	else
		return(1);
	case FRAME:
	switch (q_type)
		{
		case POINTS:
		case SEGMENT:
		case POLYS:
		if (*(concerned+2) <= *(question+2)  &&
			*(concerned+2) + *(concerned+3) > *(question+2) )
			return(1);
		else
			return(0);
		case FRAME:
		if (*(concerned+2) <= *(question+2)  &&
			*(concerned+2) + *(concerned+3) <= 
			*(question+2) + *(question+3) )
			return(1);
		else
			return(0);

		}
	
	}
}
#endif NO_OVERLAY

/*this is a hairy routine that is used by the upstream editing code.
  basically it determines if the op question is effected by the
  insertion of the op concerned upstream*/
op_concerns_op( concerned, question)
register WORD *concerned, *question;
{
WORD c_type, q_type;

c_type = address_type[ concerned[OP] ];
q_type = address_type[ question[OP] ];
if (q_type > c_type)
	return(0);
switch( c_type )
	{
	case POINTS:
	if (concerned[PL] != question[PL] )
		return(0);
	if (concerned[PT] == question[PT] )
		return(1);
	else
		return(0);
	break;
	case SEGMENT:
	if (concerned[PL] != question[PL] )
		return(0);
	switch (q_type)
		{
		case POINTS:
		if ( question[PT] >= *(concerned+3) &&
			question[PT] < *(concerned+3) + *(concerned+4) )
			return(1);
		else if ( question[PT] + *(concerned+5) >= *(concerned+3) &&
			question[PT]  + *(concerned+5) < 
			*(concerned+3) + *(concerned+4) )
			return(1);
		else
			return(0);
		break;
		case SEGMENT:  /*segment only effected if question seg inside
				 concerned segment.  Not just overlapping */
		if ( *(question+3) >= *(concerned+3) &&
			*(question+3) + *(question+4) <= 
			*(concerned+3) + *(concerned+4) )
			return(1);
		else
			return(0);
		}
	case POLYS:
	if (concerned[PL] != question[PL] )
		return(0);
	else
		return(1);
	case FRAME:
	return(1);
	}
}

/* this guy is who does the upstream processing for geometric ops.
   of course there are the usual topological/combinatorical nastinesses
   at the bottom  */
general_implications(ss, new_op)
struct s_sequence *ss;
register WORD *new_op;
{
struct tween **tweens, **end_tween, *tween;
WORD **acts, *act; 
register WORD *start_act_function;
WORD  *start_new_op_function;
WORD  new_op_end_addr;
WORD i,j;
WORD x,y,z;
WORD p,q;
WORD xcen, ycen, zcen;
WORD xoff, yoff, zoff;
WORD new_op_type;
WORD sub_end_tween;
WORD st_point_ix, st_poly_ix;  /*start of tween addresses */
WORD  next_point_addr, next_poly_addr;  /*addresses at start of next tween*/

extern WORD address_type[], address_length[];
extern WORD function_type[], function_length[];

new_op = (WORD *)clone_structure( new_op, *new_op * sizeof(WORD) );
/*make a local copy so can bop around poly and point indices*/

start_new_op_function = new_op + op_offset( new_op );
switch(function_type[ new_op[OP] ] )
	{
	case MOVE_OP:
	xoff = *(start_new_op_function);
	yoff = *(start_new_op_function+1);
	zoff = *(start_new_op_function+2);
	break;
	case SAMPLE_OP:
	start_new_op_function += 3*start_new_op_function[0] + 1 - 3;
	xoff = *(start_new_op_function);
	yoff = *(start_new_op_function+1);
	zoff = *(start_new_op_function+2);
	break;
	case ROT_OP:
	xcen = *(start_new_op_function);
	ycen = *(start_new_op_function+1);
	zcen = *(start_new_op_function+2);
	break;
	case SIZE_OP:
	xcen = *(start_new_op_function);
	ycen = *(start_new_op_function+1);
	zcen = *(start_new_op_function+2);
	p = *(start_new_op_function+3);
	q = *(start_new_op_function+4);
	break;
#ifdef PARANOID
	default:
	lprintf("unknown case in general_implications 0\n");
	goto end_gen;
#endif PARANOID
	}

tweens = ss->next_tween + 1;
end_tween = ss->tween_list + ss->tween_count;

while (tweens < end_tween)
	{
	st_poly_ix = new_op[2];
	switch(address_type[new_op[1]])
	{
	case POINTS:
	case SEGMENT:
		st_point_ix = new_op[3];
		break;
	default:
		st_point_ix = -1;
		break;
	}
	tween = *(tweens++);
	sub_end_tween = 0;
	acts = tween->act_list;
	for (i=0; i<tween->act_count; i++)
	{
	act = *(acts++);
	if ( op_concerns_op(new_op, act) )
		{
		start_act_function = act + op_offset( act );
		switch (function_type[ act[OP]] )
		{
		case MOVE_OP:
			switch(function_type[ new_op[OP] ] )
			{
			case MOVE_OP:
			case SAMPLE_OP:
				break;
			case ROT_OP:
				act_rot_offset( start_act_function,
				start_new_op_function, SCALE_ONE);
				break; /*rotate offset*/
			case SIZE_OP:
				x = *(start_act_function);
				y = *(start_act_function+1);
				z = *(start_act_function+2);
				*(start_act_function) 
					= x*p/q;
				*(start_act_function+1) 
					= y*p/q;
				*(start_act_function+2) 
					= z*p/q;
				break;
#ifdef PARANOID
			default:
				lprintf("unknown case in general_implications 1\n");
				goto end_gen;
#endif PARANOID
			}/*this switch takes care of downstream offsets*/
			break;
		case SAMPLE_OP:
			switch(function_type[ new_op[OP] ] )
			{
			case MOVE_OP:
			case SAMPLE_OP:
				break;
			case ROT_OP:
				{
				register WORD *dpt = start_act_function;
				register WORD count = *(dpt++);
				while (--count >= 0)
					{
					act_rot_offset( dpt,
					start_new_op_function, SCALE_ONE);
					dpt += 3;
					}
				}
				break; /*rotate offset*/
			case SIZE_OP:
				{
				register WORD *dpt = start_act_function;
				register WORD count = *(dpt++);
				while (--count >= 0)
					{
					x = *(dpt);
					y = *(dpt+1);
					z = *(dpt+2);
					*(dpt++) 
						= x*p/q;
					*(dpt++) 
						= y*p/q;
					*(dpt++) 
						= z*p/q;
					}
				}
				break;
#ifdef PARANOID
			default:
				lprintf("unknown case in general_implications 1\n");
				goto end_gen;
#endif PARANOID
			}/*this switch takes care of downstream offsets*/
			break;
		case ROT_OP:
			switch(function_type[ new_op[OP] ] )
			{
			case MOVE_OP:
			case SAMPLE_OP:
				*(start_act_function) += xoff;
				*(start_act_function+1) += yoff;
				*(start_act_function+2) += zoff;
				break;
			case ROT_OP:
				act_rotate( start_act_function,
				start_new_op_function, SCALE_ONE);
				/*rotate center*/
				act_rot_offset( start_act_function+6, 
				start_new_op_function, SCALE_ONE);
				/*rotate axis*/
				find_conjugates( start_act_function );
				/*find new parameters for conjugation... */
				break;  
			case SIZE_OP:
				x = *(start_act_function) - xcen;
				y = *(start_act_function+1) - ycen;
				z = *(start_act_function+2) - zcen;
				*(start_act_function) 
					= x*p/q + xcen;
				*(start_act_function+1) 
					= y*p/q + ycen;
				*(start_act_function+2) 
					= z*p/q + zcen;
				break; /*rationally size center*/
#ifdef PARANOID
			default:
				lprintf("unknown case in general_implications 2\n");
				goto end_gen;
#endif PARANOID
			}
			break;
		case SIZE_OP:
			switch(function_type[ new_op[OP] ] )
			{
			case MOVE_OP:
			case SAMPLE_OP:
				*(start_act_function) += xoff;
				*(start_act_function+1) += yoff;
				*(start_act_function+2) += zoff;
				break;
			case ROT_OP:
				act_rotate( start_act_function,
				start_new_op_function, SCALE_ONE);
				break; /*rotate center*/
			case SIZE_OP:
				x = *(start_act_function) - xcen;
				y = *(start_act_function+1) - ycen;
				z = *(start_act_function+2) - zcen;
				*(start_act_function) 
					= x*p/q + xcen;
				*(start_act_function+1) 
					= y*p/q + ycen;
				*(start_act_function+2) 
					= z*p/q + zcen;
				break;
#ifdef PARANOID
			default:
				lprintf("unknown case in general_implications 3\n");
				goto end_gen;
#endif PARANOID
			}
			break;
		default:
			break;
		}
		}
	new_op_type = address_type[ new_op[OP] ];
	switch ( act[OP] )
		{
		case INSERT_STENCIL:
		case INSERT_RASTER:
		case INSERT_POLY:
		case INSERT_CBLOCK:
		case INSERT_STRIP:
		if (new_op[PL] >= act[PL] )
			(new_op[PL] )++;
		if (new_op_type == FRAME)
			{
			struct poly_list *a_plist;
			WORD *lnew_op, *lact;
			extern WORD *act_from_poly();
			extern WORD *clone_tube();

			a_plist = empty_poly_list();
			lnew_op = clone_tube(new_op);
			lnew_op[PL] = 0;
			lnew_op[3] = 1;  /*poly_count*/
			lact = clone_tube(act);
			lact[PL] = 0;
			act_on_poly_list( &lact, 1, a_plist, SCALE_ONE, ss);
			act_on_poly_list( &lnew_op, 1, a_plist, SCALE_ONE, ss);
			free_tube(lact);
			free_tube(lnew_op);
			lact = act_from_poly((a_plist->list)[0], act[PL], ss);
			copy_structure( lact, act, lact[0] * sizeof(WORD) );
			free_tube(lact);
			free_poly_list(a_plist);
			}
		break;
		case KILL_POINT:
		if (st_point_ix >= 0)  /*ie is a point or segment op */
			{
			new_op_end_addr = 
				mid_to_end_addr( st_poly_ix, st_point_ix,
				tween->act_list, tween->act_count);
			find_next_addr( tween->act_list, tween->act_count,
			st_poly_ix, st_point_ix,
			&next_poly_addr, &next_point_addr, 1);
			}
		switch (new_op_type)
			{
			case POINTS:
			if ( new_op[PL] == act[PL] )
				{
				/*check to see if moving apart two dead
				  points, if so resurrect the dead one...*/
				if ( new_op_end_addr == act[PT] )
				{
				remove_act(tween, i);
				upindex_points_in_s_sequence(ss, tweens,
					next_poly_addr, next_point_addr );
				goto end_gen;  /*hey we're dead*/
				}
				else if ( new_op_end_addr == *(act+3) + 1 )
				{
				remove_act(tween, i);
				upindex_points_in_s_sequence(ss, tweens,
					next_poly_addr, next_point_addr );
				acts = tween->act_list + i + 1;
				}
				else if ( new_op_end_addr > *(act+3) )
				sub_end_tween++;
				}
			break;
			case SEGMENT:
			if ( new_op[PL] == act[PL] )
				{
				if ( new_op_end_addr <= *(act+3)  &&
				new_op_end_addr + *(new_op+4) > *(act+3) )
				{
				--(*(new_op+4) );  /*kill point inside segment*/
				--(*(new_op+5) );
				}
				else if ( new_op_end_addr <= 
				*(act+3) + *(new_op+5)  &&
				new_op_end_addr + *(new_op+4) > 
				*(act+3) + *(new_op+5) )
				{
				--(*(new_op+4) );  /*kill point inside segment*/
				--(*(new_op+5) );
				}
				else if ( new_op_end_addr > *(act+3) )
				sub_end_tween++; /*move segmet down a notch*/
				}
			break;
			default:
			break;
			}
		break;
		case INSERT_POINT:
		switch (new_op_type)
			{
			case POINTS:
			if ( new_op[PL] == act[PL] )
				{
				if ( new_op[PT] >= act[PT] )
				(new_op[PT] )++;
				}
			break;
			case SEGMENT:
			if ( new_op[PL] == act[PL] )
				{
				if ( *(new_op+3) < *(act+3)  &&
				*(new_op+3) + *(new_op+4) > *(act+3) )
					{
					(*(new_op+4) )++; 
					/*add point inside segment*/
					(*(new_op+5) )++;
					/*add point to poly too*/
					}
				else if ( *(new_op+3) < *(act+3) + *(new_op+5)  &&
				*(new_op+3) + *(new_op+4) >
				*(act+3) + *(new_op+5) )
					{
					(*(new_op+4) )++; 
					/*add point inside segment*/
					(*(new_op+5) )++;  /*add point to poly too*/
					}
				else if ( *(new_op+3) >= *(act+3) )
				(*(new_op+3) )++;  /*move segment up a notch*/
				}
			break;
			default:
			break;
			}
		break;
		case KILL_POLY:
		switch (new_op_type)
			{
			case POINTS:
			case SEGMENT:
			case POLYS:
			if ( new_op[PL] == act[PL] )
				goto end_gen;  /*say now we're finished*/
			break;
			case FRAME:
			if ( *(new_op+2) <= *(act+2)  &&
				*(new_op+2) + *(new_op+3) > *(act+2) )
				--(*(new_op+3) );  /*kill poly inside frame*/
			if ( *(new_op+2) > *(act+2) )
				--(*(new_op+2) );  /*move frame down a notch*/
			break;
			default:
			break;
			}
		break;
		default:
		break;
		}
	}
	switch( address_type[ new_op[OP] ] )
	{
	case POINTS:
	case SEGMENT:
		new_op[PT] -= sub_end_tween;
		break;
	default:
		break;
	}
	}
end_gen:
free_tube(new_op);
}

