
overlay "reader"

#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\script.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"
#include "..\\include\\raster.h"
#include "..\\include\\animath.h"
#include "..\\include\\poly.h"


Script *
convert_one_op(ss, changing_op, transfunct)
Script *ss;
WORD changing_op;
WORD *(*transfunct)(); /*pointer to a function returning a tube*/
{
register int j;
int i;
Tween **tweens, *tween;
WORD *act, **acts;

tweens = ss->tween_list;
i = ss->tween_count;
while (--i >= 0)
	{
	tween = *(tweens++);
	acts = tween->act_list;
	j = tween->act_count;
	while (--j >= 0)
	{
	act = *(acts);
	if ( act[1] == changing_op)
		if (transfunct)
		*(acts) = (*transfunct)(act);
		else
		print_tube("convert",act);
	acts++;
	}
	}
return(ss);
}

fix_tween_times(ss)
Script *ss;
{
Tween **tweens, *tween;
int i;
long present = 0;

i = ss->tween_count;
tweens = ss->tween_list;
while (--i>=0)
	{
	tween = *(tweens++);
	tween->start_time = present;
	present += tween->tweening;
	tween->stop_time = present;
	}
ss->duration = present;
}

long
script_duration(ss)
Script *ss;
{
Tween **tweens, *tween;
int i;
long present = 0;

i = ss->tween_count;
tweens = ss->tween_list;
while (--i>=0)
	{
	tween = *(tweens++);
	present += tween->tweening;
	}
return(present);
}

WORD r0_cl_lookup[] = {
	0,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
	17,18,19,20,21,22,23,24,25,26,27,28,29,30,1,31,
};

WORD *
r0_clor_poly(act)
WORD *act;
{
act[4] = r0_cl_lookup[ act[4] ];
return(act);
}

WORD *
adline_width(act)
WORD *act;
{
act[6] = act[4];
return(act);
}

WORD *
r0_clor_cop(act)
WORD *act;
{
act[3] = r0_cl_lookup[ act[3] ];
return(act);
}

#ifdef SLUFFED
WORD *
add_org_raster(act)
WORD *act;
{
WORD *new_act;

new_act = (WORD *)alloc( 7 * sizeof(WORD) );
copy_structure(act, new_act, 5 * sizeof(WORD) );
new_act[0] = 7;
new_act[5] = XMAX/2;
new_act[6] = YMAX/2;
free_tube(act);
return(new_act);
}

WORD *
add_org_stencil(act)
WORD *act;
{
WORD *new_act;

new_act = (WORD *)alloc( 8 * sizeof(WORD) );
copy_structure(act, new_act, 5 * sizeof(WORD) );
new_act[0] = 8;
new_act[5] = XMAX/2;
new_act[6] = YMAX/2;
new_act[7] = act[5];
free_tube(act);
return(new_act);
}

WORD *
add_zor_stencil(act)
WORD *act;
{
WORD *new_act;

new_act = (WORD *)alloc( 9 * sizeof(WORD) );
copy_structure(act, new_act, 8 * sizeof(WORD) );
new_act[8] = new_act[7];
new_act[7] = ground_z;
free_tube(act);
return(new_act);
}

WORD *
add_zor_raster(act)
WORD *act;
{
WORD *new_act;

new_act = (WORD *)alloc( 8 * sizeof(WORD) );
copy_structure(act, new_act, 7 * sizeof(WORD) );
new_act[7] = ground_z;
free_tube(act);
return(new_act);
}
#endif SLUFFED


extern Tween * ma_insert_colors();

Tween *
m_init_cmap(tween)
Tween *tween;
{
return(ma_insert_colors(tween, init_cmap, 0, 32));
}

#ifdef SLUFFED
Tween *
m_init_background(tween)
Tween *tween;
{
WORD *act;
extern WORD *make_act();

act = make_act(REMOVE_BACKGROUND, -2, 0, 0, 0);
if (act)
	add_act(tween, act);
return(tween);
}
#endif SLUFFED


Script *
at_creation(ss, return_cr_act)
Script *ss;
Tween * (*return_cr_act)();
{
if (ss->tween_count > 0)
	ss->tween_list[0] = (*return_cr_act)(ss->tween_list[0]);
return(ss);
}


clean_dead_acts(ss)
Script *ss;
{
Tween *tween, **tweens;
WORD i;

i = ss->tween_count;
tweens = ss->tween_list;
while (--i >= 0)
	{
	tween = *tweens++;
	while ( can_clean_tween(tween) )
	;
	}
}

can_clean_tween(tween)
register Tween *tween;
{
register WORD **acts, *act, i;
WORD birth_ix;

acts = tween->act_list;
for (i=0; i<tween->act_count; i++)
	{
	act = *acts++;
	if (act[1] == KILL_POLY)
	{
	if ( (birth_ix = born_in_tween(tween, i, act[2]) ) >= 0)
		{
		rm_from_birth(tween, birth_ix);
		return(1);
		}
	else
		if (rm_dead_acts(tween, i, act[2]) > 0)
		return(1);
	}
	}
return(0);
}

WORD *
fx_ppoints(act)
register WORD *act;
{
register WORD *new_act;

if (act[4] < 3)
	{
	new_act = (WORD *)alloc(7 * sizeof(WORD) );
	new_act[0] = 7;
	new_act[1] = MOVE_POINT;
	new_act[2] = act[2];
	new_act[3] = act[3];
	new_act[4] = act[8] - act[5];
	new_act[5] = act[9] - act[6];
	new_act[6] = act[10] - act[7];
	free_tube(act);
	return(new_act);
	}
else
	return(act);
}

WORD *
fx_psegment(act)
register WORD *act;
{
register WORD *new_act;

if (act[6] < 3)
	{
	new_act = (WORD *)alloc(9 * sizeof(WORD) );
	new_act[0] = 9;
	new_act[1] = MOVE_SEGMENT;
	new_act[2] = act[2];
	new_act[3] = act[3];
	new_act[4] = act[4];
	new_act[5] = act[5];
	new_act[6] = act[10] - act[7];
	new_act[7] = act[11] - act[8];
	new_act[8] = act[12] - act[9];
	free_tube(act);
	return(new_act);
	}
else
	return(act);
}

WORD *
fx_ppoly(act)
register WORD *act;
{
register WORD *new_act;

if (act[3] < 3)
	{
	new_act = (WORD *)alloc(6 * sizeof(WORD) );
	new_act[0] = 6;
	new_act[1] = MOVE_POLY;
	new_act[2] = act[2];
	new_act[3] = act[7] - act[4];
	new_act[4] = act[8] - act[5];
	new_act[5] = act[9] - act[6];
	free_tube(act);
	return(new_act);
	}
else
	return(act);
}

WORD *
fx_ppolys(act)
register WORD *act;
{
register WORD *new_act;

if (act[4] < 3)
	{
	new_act = (WORD *)alloc(7 * sizeof(WORD) );
	new_act[0] = 7;
	new_act[1] = MOVE_POLYS;
	new_act[2] = act[2];
	new_act[3] = act[3];
	new_act[4] = act[8] - act[5];
	new_act[5] = act[9] - act[6];
	new_act[6] = act[10] - act[7];
	free_tube(act);
	return(new_act);
	}
else
	return(act);
}

Script *
convert(ss)
Script *ss;
{
while (ss->type < generic_sequence.type)
	{
	ldprintf("converting to rev %d", ss->type + 1);
	switch( ss->type)
	{
	case 0:
		ss = convert_one_op(ss, INSERT_POLY, r0_clor_poly);
		ss = convert_one_op(ss, CHANGE_COLOR, r0_clor_cop);
		break;
	case 1:
		ss = at_creation(ss,m_init_cmap);
		break;
	case 2:
		fix_tween_times(ss);
		break;
	case 3: /*this one is/was done only on text representation of script*/
		break;
	case 4:
		break;
	case 5:
		break;
	case 6: /*this one is/was done only on text representation of script*/
		break;
	case 7:
		break;
	case 8:
		ss->level_z = GROUND_Z;
		break;
	case 9:
		clean_dead_acts(ss);
		break;
	case 10:
		ss = convert_one_op(ss, PATH_POINT, fx_ppoints);
		ss = convert_one_op(ss, PATH_SEGMENT, fx_psegment);
		ss = convert_one_op(ss, PATH_POLY,	fx_ppoly);
		ss = convert_one_op(ss, PATH_POLYS, fx_ppolys);
		break;
	case 11:
		break;
	case 12:
		break;
	case 13:	/*case 12 and 13 canceled each other out */
		break;
	case 14:
		ss->speed = (ss->speed*32+10)/20;
		break;	/* move default speed from 20 to 32 so can shift 5...*/
	case 15:
		ss = convert_one_op(ss, INSERT_POLY, adline_width);
		break;
#ifdef PARANOID
	default:
		printf("unknown case %d in convert()");
		break;
#endif PARANOID
	}
	ss->type++;
	}
fix_tween_times(ss);
return(ss);
}

