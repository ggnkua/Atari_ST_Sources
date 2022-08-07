overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\addr.h"

WORD *
make_opcode( address, function)
register WORD *address;
WORD *function;
{
register WORD *op_code;

#ifdef DEBUG
lprintf("make_opcode(%lx %lx)\n", address, function);
#endif DEBUG

op_code = (WORD *) alloc( ( *address + *function - 2 ) * sizeof(WORD) );
if (op_code)
	{
	*op_code = *address + *function - 2;
	*(op_code+1) = op_matrix[ *(function+1) ]  [ *(address+1) ];
	if ( *(op_code+1) == -1)
	{
	ldprintf("\ninsane function, address combination in make_opcode");
	return(NULL);
	}
	copy_structure( address+2, op_code+2, (*address - 2)*sizeof(WORD) );
	copy_structure( function+2, op_code+ *address,
	(*function - 2)*sizeof(WORD) );
	}
return(op_code);
}

WORD *
make_act(opcode, poly_ix, start, length, data)
register WORD opcode;
WORD poly_ix, start;
register WORD length;
register WORD *data;
{
register WORD *act;
register WORD op_length;

switch(opcode)
	{
	case INIT_COLORS:
	act = (WORD *)alloc( (5 + 3*length)*sizeof(WORD) );
	if (act)
		{
		act[0] = 5 + 3*length;
		act[1] = opcode;
		act[2] = poly_ix;
		act[3] = start;
		act[4] = length;
		copy_structure( data, act+5, 3*length*sizeof(WORD) );
		}
	break;
	case LOAD_BACKGROUND:
	{
	WORD act_length;

	act_length = 3 + (strlen(data)+2)/2;
	act = (WORD *)clone_zero( act_length * sizeof(WORD) );
	if (act)
		{
		act[0] = act_length;
		act[1] = LOAD_BACKGROUND;
		act[2] = -2;
		strcpy(act+3, data);
		}
	}
	break;
	case REMOVE_BACKGROUND:
	{
	act = (WORD *)alloc( 3 * sizeof(WORD) );
	if (act)
		{
		act[0] = 3;
		act[1] = REMOVE_BACKGROUND;
		act[2] = -2;
		}
	}
	break;
	case TWEEN_COLOR:
	{
	op_length = lof_type(opcode);
	act = (WORD *)alloc(op_length * sizeof(WORD) );
	act[0] = op_length;
	act[1] = opcode;
	act[2] = poly_ix;  /*it's a colormap thing */
	act[3] = start;		/*color_ix*/
	act[4] = data[0];	/*red*/
	act[5] = data[1];	/*green*/
	act[6] = data[2];	/*blue*/
	}
	break;
	case TWEEN_TO_COLORS:
	{
	op_length = lof_type(opcode);
	act = (WORD *)alloc(op_length * sizeof(WORD) );
	act[0] = op_length;
	act[1] = opcode;
	act[2] = poly_ix;  /*it's a colormap thing */
	act[3] = start;		/*start color segment*/
	act[4] = length;	/*# of colors in segment*/
	act[5] = data[0];	/*red*/
	act[6] = data[1];	/*green*/
	act[7] = data[2];	/*blue*/
	}
	break;
	case CYCLE_COLORS:
	{
	op_length = lof_type(opcode);
	act = (WORD *)alloc(op_length * sizeof(WORD) );
	act[0] = op_length;
	act[1] = opcode;
	act[2] = poly_ix;  /*it's a colormap thing */
	act[3] = start;		
	act[4] = length;
	act[5] = data[0];	/*direction*/
	}
	break;
	default:
	ldprintf("\nunknown case %d in code()",opcode);
	act = NULL;
	break;
	}
return(act);
}

last_such_op(tween, opcode)
register Tween *tween;
register WORD opcode;
{
register WORD i;
register WORD **acts, *act;

i = tween ->act_count;
acts = tween->act_list + i;
while (--i >= 0)
	{
	act = *(--acts);
	if (act[1] == opcode)
	return(i);
	}
return(-1);
}

remove_last_like(tween, opcode)
register Tween *tween;
WORD opcode;
{
register WORD concerning_ix;

concerning_ix = last_such_op(tween, opcode);
if (concerning_ix >= 0)
	remove_act(tween, concerning_ix);
}


WORD *
peephole(tween, act)
register Tween *tween;
register WORD *act;
{
register WORD concerning_ix, i;
register WORD *old_act;

switch(act[1])
	{
	case REMOVE_BACKGROUND:
	{
	remove_last_like(tween, REMOVE_BACKGROUND);
	remove_last_like(tween, LOAD_BACKGROUND);
	}
	break;
	case LOAD_BACKGROUND:
	{
	remove_last_like(tween, LOAD_BACKGROUND);
	remove_last_like(tween, REMOVE_BACKGROUND);
	}
	break;
	case INIT_COLORS:
	{
	concerning_ix = last_such_op(tween, INIT_COLORS);
	if (concerning_ix >= 0)
		if (block_same(act, tween->act_list[concerning_ix],
			5*sizeof(WORD)))
		remove_act(tween, concerning_ix);
	}
	break;
	case TWEEN_COLOR:
	{
	i = tween->act_count;
	while (--i >= 0)
		{
		old_act = tween->act_list[i];
		if ( old_act[1] == INIT_COLORS || old_act[1] == CYCLE_COLORS ||
		 old_act[1] == TWEEN_TO_COLORS)
		break;
		if ( old_act[1] == TWEEN_COLOR && act[3] == old_act[3] )
		{
		act[4] += old_act[4];
		act[5] += old_act[5];
		act[6] += old_act[6];
		remove_act(tween, i);
		break;	/*need only remove last one since get called each time*/
		}
		}
	}
	break;
	case CYCLE_COLORS:
	{
	concerning_ix = last_such_op(tween, CYCLE_COLORS);
	if (concerning_ix >= 0)
		{
		old_act = tween->act_list[concerning_ix];

		if (act[3] == old_act[3]  && act[4] == old_act[4])
		{
		act[5] += old_act[5];
		remove_act(tween, concerning_ix);
		}
		}
	}
	break;
	case MOVE_POINT:
	{
	i = tween->act_count;
	while (--i >= 0)
		{
		old_act = tween->act_list[i];
		if ( old_act[1] != MOVE_POINT)
		break;
		if ( act[2] == old_act[2] && act[3] == old_act[3] )
		{
		act[4] += old_act[4];
		act[5] += old_act[5];
		act[6] += old_act[6];
		remove_act(tween, i);
		break;	/*need only remove last one since get called each time*/
		}
		}
	}
	break;
	default:
	break;
	}
return(act);
}

opto_add_act(tween, act)
register Tween *tween;
register WORD *act;
{
if (act = peephole(tween, act) )
	add_act(tween, act);
}

code(ss,opcode, poly_ix, start, length, data)
Script *ss;
WORD opcode, poly_ix, start, length;
WORD *data;
{
register Tween *tween = *(ss->next_tween);
register WORD *act;

act = make_act(opcode, poly_ix, start, length, data);
if (act)
	{
	opto_add_act(tween, act);
	}
}


WORD *
act_from_poly(cur_poly, insert_where, sscript)
register struct poly *cur_poly;
register WORD insert_where;
Script sscript;
{
register WORD *sh_pt;
register struct raster_list *rl;
extern struct raster_list *raster_master;

if (cur_poly->type & IS_RASTER)
	{
	rl = ((struct bitplane_raster *)cur_poly)->raster;
#ifdef PARANOID
	if (!rl && cur_poly->type != COLOR_BLOCK)
	{
	ldprintf("act_from_poly - raster not in raster_master");
	printf("act_from_poly - raster not in raster_master");
	}
#endif PARANOID

	switch (cur_poly->type)
	{
	case AMIGA_BITMAP:
	case BYPLANE_RASTER:
	case ATARI_CEL:
		sh_pt = (WORD *)alloc( 8*sizeof(WORD) );
		sh_pt[0] = 8;
		sh_pt[1] = INSERT_RASTER;
		sh_pt[2] = insert_where;
		/*following bizarre cast is to let sh_pt[3-4] hold
		  a pointer to a raster... -jk*/
		*( (struct raster_list **)(sh_pt+3)) = rl;
		sh_pt[5] = cur_poly->center.x;
		sh_pt[6] = cur_poly->center.y;
		sh_pt[7] = cur_poly->center.z;
		break;
	case BITPLANE_RASTER:
		sh_pt = (WORD *)alloc( 9*sizeof(WORD) );
		sh_pt[0] = 9;
		sh_pt[1] = INSERT_STENCIL;
		sh_pt[2] = insert_where;
		/*following bizarre cast is to let sh_pt[3-4] hold
		  a pointer to a raster... -jk*/
		*( (struct raster_list **)(sh_pt+3)) = rl;
		sh_pt[5] = cur_poly->center.x;
		sh_pt[6] = cur_poly->center.y;
		sh_pt[7] = cur_poly->center.z;
		sh_pt[8] = cur_poly->color;
		break;
	case COLOR_BLOCK:
		sh_pt = (WORD *)alloc( 10*sizeof(WORD) );
		sh_pt[0] = 10;
		sh_pt[1] = INSERT_CBLOCK;
		sh_pt[2] = insert_where;
		sh_pt[3] = cur_poly->type;
		sh_pt[4] = cur_poly->color;
		sh_pt[5] = cur_poly->center.x;
		sh_pt[6] = cur_poly->center.y;
		sh_pt[7] = cur_poly->center.z;
		sh_pt[8] = ((struct color_block *)cur_poly)->width;
		sh_pt[9] = ((struct color_block *)cur_poly)->height;
		break;
	case ANI_STRIP:
	   sh_pt = (WORD *)alloc(lof_type(INSERT_STRIP) * sizeof(WORD) );
	   sh_pt[0] = lof_type(INSERT_STRIP);
	   sh_pt[1] = INSERT_STRIP;
	   sh_pt[2] = insert_where;
	   sh_pt[3] = ((struct ani_strip *)cur_poly)->script_ix;
	   sh_pt[4] = ((struct ani_strip *)cur_poly)->origin.x;
	   sh_pt[5] = ((struct ani_strip *)cur_poly)->origin.y;
	   sh_pt[6] = ((struct ani_strip *)cur_poly)->origin.z;
	   sh_pt[7] = ((struct ani_strip *)cur_poly)->xhot;
	   sh_pt[8] = ((struct ani_strip *)cur_poly)->yhot;
	   sh_pt[9] = ((struct ani_strip *)cur_poly)->zhot;
	   sh_pt[10] = 0;
	   sh_pt[11] = 0;
	   sh_pt[12] = 0;
	   sh_pt[13] = 0;
	   break;
	}
	}
else
	{
	sh_pt = (WORD *)
		alloc( (4*cur_poly->pt_count + 9)*sizeof(WORD) );
	sh_pt[0] = 4*cur_poly->pt_count + 9;
	sh_pt[1] = INSERT_POLY;
	sh_pt[2] = insert_where;
	sh_pt[3] = cur_poly->type;
	sh_pt[4] = cur_poly->color;
	sh_pt[5] = cur_poly->pt_count;
	sh_pt[6] = cur_poly->fill_color; 
	sh_pt[7] = 0;
	sh_pt[8] = 0;
	copy_structure( cur_poly->pt_list, sh_pt + 9, cur_poly->pt_count *
		sizeof(struct point) );
	}
return(sh_pt);
}


Poly *
poly_from_act(act)
register WORD *act;
{
register Poly_list *poly_list;
Poly *poly;

if (act[1] != INSERT_POLY)
	{
	ldprintf("\n*act not INSERT_POLY");
	return(NULL);
	}
poly_list = empty_poly_list();
if (poly_list)
	{
	ain_poly(poly_list,act);
	poly = clone_poly(poly_list->list[0]);
	free_poly_list(poly_list);
	return(poly);
	}
else
	return(NULL);
}

