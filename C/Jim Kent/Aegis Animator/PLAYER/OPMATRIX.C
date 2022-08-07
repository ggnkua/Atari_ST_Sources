
overlay "reader"

#include "..\\include\\lists.h"
#include "..\\include\\addr.h"
#include "..\\include\\acts.h"
#include "..\\include\\control.h"


WORD op_matrix[][5] =
{
	{ INSERT_POINT, 	-1,  INSERT_POLY,	 -1 , -1},
	{ KILL_POINT,	-1,  KILL_POLY,	 -1 , -1},
	{ MOVE_POINT, MOVE_SEGMENT, MOVE_POLY, MOVE_POLYS, MOVE_POLY_PTS},
	{ ROT_POINT, ROT_SEGMENT, ROT_POLY, ROT_POLYS , -1},
	{ SIZE_POINT, SIZE_SEGMENT,  SIZE_POLY, SIZE_POLYS , -1},
	{ -1, -1,  CHANGE_COLOR, -1 , -1},
	{ -1, -1,  CHANGE_TYPE, -1 , -1},
	{ PATH_POINT, PATH_SEGMENT, PATH_POLY, PATH_POLYS, PATH_POLY_PTS},
};

WORD function_length[] =
	{
	2, 	/*INSERT_OP*/
	2, 	/*KILL_OP*/
	5, 	/*MOVE_OP*/
	11,	/*ROT_OP*/
	7,  /*SIZE_OP*/
	3, 	/*XCOLOR_OP*/
	3, 	/*XTYPE_OP*/
	3,	/*SAMPLE_OP*/
	};

WORD address_length[] =
	{
	4, /*POINTS*/
	6, /*SEGMENT*/
	3, /*POLYS*/
	4, /*FRAME*/
	3, /*POLY_PTS*/
	};


WORD address_type[] =
	{
	POINTS,   /*MOVE_POINT*/
	POINTS,   /*ROT_POINT*/
	POINTS,   /*INSERT_POINT*/
	POINTS,   /*KILL_POINT*/

	POLY_PTS,		 /*MOVE_POLY_POINTS*/

	SEGMENT, /*ROT_SEGMENT*/


	POLYS,	/*MOVE_POLY*/
	POLYS,	/*ROT_POLY*/
	POLYS,	/*INSERT_POLY*/
	POLYS,	/*KILL_POLY*/
	POLYS,	/*CHANGE_COLOR*/

	FRAME,   /*MOVE_POLYS*/
	FRAME,   /*ROT_POLYS*/
	FRAME,   /*SIZE_POLYS*/
	-1,		 /*REDO_POLYS*/

	POINTS,   /*SIZE_POINT*/
	SEGMENT, /*SIZE_SEGMENT*/
	POLYS,	/*SIZE_POLY*/

	POLYS,	/*CHANGE_TYPE*/
	SEGMENT, /*MOVE_SEGMENT*/

	POINTS, /*PATH_POINT*/
	POLYS, /*PATH_POLY*/
	POLY_PTS, /*PATH_POLY_PTS*/
	SEGMENT,  /*PATH_SEGMENT*/
	FRAME,	/*PATH_POLYS*/
	 
	-1,		/*INIT_COLORS*/
	POLYS,	/*INSERT_RASTER*/
	POLYS,	/*INSERT_STENCIL*/

	-1,		/*LOAD_BACKGROUND*/
	-1,		/*REMOVE_BACKGROUND*/
	-1,		/*TWEEN_COLOR*/
	-1,		/*CYCLE_COLORS*/

	POLYS,	/*INSERT_CBLOCK*/

	-1,		/*TWEEN_TO_COLORS*/

	POLYS,	/*INSERT_STRIP*/
	POLYS,	/*CHANGE_OCOLOR*/
	POLYS,	/*CHANGE_FCOLOR*/
	};

WORD function_type[] =
	{
	MOVE_OP,   /*MOVE_POINT*/
	ROT_OP,   /*ROT_POINT*/
	INSERT_OP,   /*INSERT_POINT*/
	KILL_OP,   /*KILL_POINT*/

	-1,		 /*MOVE_POLY_POINTS*/

	ROT_OP, /*ROT_SEGMENT*/


	MOVE_OP,	/*MOVE_POLY*/
	ROT_OP,	/*ROT_POLY*/
	INSERT_OP,	/*INSERT_POLY*/
	KILL_OP,	/*KILL_POLY*/
	XCOLOR_OP,	/*CHANGE_COLOR*/

	MOVE_OP,   /*MOVE_POLYS*/
	ROT_OP,   /*ROT_POLYS*/
	SIZE_OP,   /*SIZE_POLYS*/
	-1,		 /*REDO_POLYS*/

	SIZE_OP,   /*SIZE_POINT*/
	SIZE_OP, /*SIZE_SEGMENT*/
	SIZE_OP,	/*SIZE_POLY*/

	XTYPE_OP,	/*CHANGE_TYPE*/
	MOVE_OP, /*MOVE_SEGMENT*/

	SAMPLE_OP, /*PATH_POINT*/
	SAMPLE_OP, /*PATH_POLY*/
	SAMPLE_OP, /*PATH_POLY_PTS*/
	SAMPLE_OP,  /*PATH_SEGMENT*/
	SAMPLE_OP,	/*PATH_POLYS*/
	 
	-1,		/*INIT_COLORS*/
	INSERT_OP,	/*INSERT_RASTER*/
	INSERT_OP,	/*INSERT_STENCIL*/

	-1,		/*LOAD_BACKGROUND*/
	-1,		/*REMOVE_BACKGROUND*/
	-1,		/*TWEEN_COLOR*/
	-1,		/*CYCLE_COLORS*/

	INSERT_OP,	/*INSERT_CBLOCK*/

	-1,		/*TWEEN_TO_COLORS*/

	INSERT_OP,	/*INSERT_STRIP*/
	XCOLOR_OP,	/*CHANGE_OCOLOR*/
	XCOLOR_OP,	/*CHANGE_FCOLOR*/
	};

op_offset(op)
WORD *op;
{
return( address_length[address_type[*(op+1)]]  );
}


lof_type(type)
WORD type;
{
WORD addr_type;
WORD func_type;

switch (type)
	{
	case INSERT_POINT:
	return(4);
	case INSERT_POLY:
	return(9);
	case KILL_POINT:
	return(4);
	case KILL_POLY:
	return(3);
	case INIT_COLORS:
	return(5);
	case INSERT_RASTER:
	return(8);
	case INSERT_STENCIL:
	return(9);
	case REMOVE_BACKGROUND:
	return(3);
	case TWEEN_COLOR:
	return(7);
	case CYCLE_COLORS:
	return(6);
	case INSERT_CBLOCK:
	return(10);
	case TWEEN_TO_COLORS:
	return(8);
	case INSERT_STRIP:
	return(14);
	default:
	addr_type = address_type[type];
	func_type = function_type[type];
	return(address_length[ addr_type ] + function_length[func_type] - 2);
	}
}

lof_act(act)
WORD *act;
{
if (!act)
	{
	ldprintf("\nlof_act(NULL)");
	return(0);
	}
switch( act[1] )
	{			/*cases for variable length types here*/
	case INIT_COLORS:
	return( 5 + 3*act[4] );
	break;
	case INSERT_POLY:
	return( 9 + 4*act[5] );
	break;
	case PATH_POINT:
	return( 5 + act[4]*3);
	break;
	case PATH_SEGMENT:
	return( 7 + act[6]*3);
	break;
	case PATH_POLY:
	return( 4 + act[3]*3);
	break;
	case PATH_POLYS:
	return( 5 + act[4]*3);
	break;
	case LOAD_BACKGROUND:
	return( 3 + (strlen(act+3)+2)/2);
	break;
	default:
	return(lof_type(act[1]));
	break;
	}
}

WORD *
check_act(act, line)
register WORD *act;
int line;
{
WORD type_len;
WORD *new_act;
extern char *op_name[];

if (act)
	{
	type_len = lof_act(act);
	if (type_len)
	{
	if (type_len != act[0] )
		{
		if (type_len > act[0] )
		{
		ldprintf("%s too short line %d (%d %d)\n",
			op_name[ act[1] ], line, act[0], type_len);
		new_act = (WORD *)clone_zero( type_len*sizeof(WORD) );
		if (new_act)
			copy_structure(act, new_act, act[0] * sizeof(WORD) );
		}
		else /* (type_len < act[0])  */
		{
		ldprintf("%s too long line %d (%d %d)\n",
			op_name[ act[1] ], line, act[0], type_len);
		new_act = (WORD *)
			clone_structure( act, type_len * sizeof(WORD) );
		}
		free_tube(act);
		act = new_act;
		act[0] = type_len;
		}
	}
	}
#ifdef PARANOID
else
	printf("check_act(NULL)\n");
#endif PARANOID
return(act);
}

