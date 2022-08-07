
overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\clip.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"

extern Point center_point;
extern WORD rot_mode;
extern Poly *which_poly();

/**
**
**	get_frame()
**
**	returns in pointer arguments the upper right and lower left
**	coordinates of a box input by user
***/
get_frame(x0, y0, x1, y1)
WORD *x0, *y0, *x1, *y1;
{
struct virtual_input *vis;
WORD firstx, firsty, lastx, lasty;
WORD swapper;
extern struct cursor cross_cursor;

do
	{
	vis = await_input(USE_CURSOR);
	}
while (pdn(vis));

new_cursor( &cross_cursor);

vis = await_anydn(USE_CURSOR);
if (!pjstdn(vis) )
	{
	if (vis->result & MENUPICKED)
	reuse_input();
	return(0);
	}

firstx = vis->curx;
firsty = vis->cury;
while (vis->result & JUST_DN )
	{
	lastx = vis->curx;
	lasty = vis->cury;
	rub_frame(firstx, firsty, lastx, lasty);
	vis = await_input(USE_CURSOR);
	rub_frame(firstx, firsty, lastx, lasty);
	}
lastx = vis->curx;
lasty = vis->cury;
if (firstx > lastx)
	{
	swapper = firstx;
	firstx = lastx;
	lastx = swapper;
	}
if (firsty > lasty)
	{
	swapper = firsty;
	firsty = lasty;
	lasty = swapper;
	}
*x0 = firstx;
*y0 = firsty;
*x1 = lastx;
*y1 = lasty;
return(1);
}

/**
**
**	move_rub_frame()
**
**	sets values referenced in pointer arguments to a new frame of
**	same dimensions as that passed in arguments initually, but moved
**	about by user.
***/
move_rub_frame( x0, y0, x1, y1, what)
WORD *x0, *y0, *x1, *y1;
Poly  *what;
{
register struct virtual_input *vis;
WORD lastx, lasty;
WORD deltax, deltay;
extern struct virtual_input *await_major_event();

if (what == NULL)
	rub_frame(*x0, *y0, *x1, *y1);
else
	rub_poly(what, cur_sequence);

for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (vis->result & MENUPICKED)
		{
		reuse_input();
		return(0);
		}
	if (vis->result & CANCEL)
		return(0);
	if (pjstdn(vis) )
		break;
	}
lastx = vis->curx;
lasty = vis->cury;
while (vis->result & JUST_DN)
	{
	if (what == NULL)
	rub_frame(*x0, *y0, *x1, *y1);
	else
	rub_poly(what, cur_sequence); 
	vis = await_input(USE_CURSOR);
	if (what == NULL)
	rub_frame(*x0, *y0, *x1, *y1); 
	else
	unrub_poly(what, cur_sequence);
	deltax = vis->curx - lastx;
	deltay = vis->cury - lasty;
	*x0 += deltax;
	*x1 += deltax;
	*y0 += deltay;
	*y1 += deltay;
	if (what != NULL)
	{
	what->center.x += deltax;
	what->center.y += deltay;
	}
	lastx = vis->curx;
	lasty = vis->cury;
	}
return(1);
}

initialize_function(m, sel, vis, function)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD *function;
{

#ifdef DEBUG
lprintf("initialize_function(%lx %lx %lx %lx)\n",m, sel, vis, function);
#endif DEBUG

switch (*(function+1) )
	{
	case ROT_OP:
		if (!move_center_point(m,sel,vis, "rotate") )
			{
			return(0);
			}
		*(function + 2) = center_point.x;
		*(function + 3) = center_point.y;
		*(function + 4) = center_point.z;
		*(function + 5) = 0;
		*(function + 6) = 0;
		*(function + 7) = 0;
		*(function + 8) = 0;
		*(function + 9) = 0;
		*(function + 10) = 0;
		switch( rot_mode )
			{
			case 'x':
				*(function+8) = SCALE_ONE;
				break;
			case 'y':
				*(function+9) = SCALE_ONE;
				break;
			case 'z':
				*(function+10) = SCALE_ONE;
				break;
			}
		find_conjugates( function+2 );
		break;
	case SIZE_OP:
		if (!move_center_point(m,sel,vis,"size") )
			return(0);
		*(function + 2) = center_point.x;
		*(function + 3) = center_point.y;
		*(function + 4) = center_point.z;
		break;
	case MOVE_OP:
		function[2] = function[3] = function[4] = 0;
		break;
	default:
		break;
	}
return(1);
}

extern struct cursor segment_cursor;

/****************
**
**	unsegged - takes care of escape from middle of which_segment()
**
****************/
unsegged(m, vis, point, poly, segged)
struct menu *m;
struct virtual_input *vis;
Point *point;
Poly *poly;
WORD segged;
{
if (vis->result & (CANCEL|MENUPICKED))
	{
	unrub_poly(poly, cur_sequence);
	if (segged)
		show_cursor(&segment_cursor, point->x, point->y, 0);
	draw_cur_frame(m);
	if (vis->result & MENUPICKED)
		reuse_input();
	return(1);
	}
else
	return(0);
}

which_segment(m, sel, vis, addr, poly_list) 
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
WORD *addr;
struct poly_list *poly_list;
{
WORD i;
WORD poly_ix, first_point, second_point, third_point;
WORD direction;
WORD closest;
long distance;
struct poly *poly;
struct point *point;
WORD segment_length, segment_start;

#ifdef DEBUG
lprintf("which_segment(%lx %lx %lx %lx %lx)\n", m, sel, vis, addr, poly_list);
#endif DEBUG

new_cursor(&segment_cursor);
maybe_clear_menu(m);

poly_ix = addr[2];
poly = *(poly_list->list + poly_ix);
if (poly->type & IS_RASTER)
	return(0);
draw_pledge(poly,0, cur_sequence);
rub_poly(poly, cur_sequence);
show_help("select segment - pick start point");
for (;;)
	{
	vis = await_input(USE_CURSOR);
	if ( unsegged(m, vis, point, poly, 0) )
		return(0);
	if (pjstdn(vis))
		break;
	}
find_closest(vis,poly->pt_list,poly->pt_count,
	&first_point,&distance);

point = (poly->pt_list + first_point);
show_cursor(&segment_cursor, point->x, point->y, cycle_color);

show_help("now pick point in direction");
for (;;)
	{
	vis = await_input(USE_CURSOR);
	if ( unsegged(m, vis, point, poly, 1) )
		return(0);
	if (pjstdn(vis))
		break;
	}
find_closest(vis,poly->pt_list,poly->pt_count,
	&second_point,&distance);

direction = second_point - first_point;
if (direction == 0)
	direction = 1;
else if (direction > 0)
	if (direction <= poly->pt_count/2 )
		direction = 1;
	else
		direction = -1;
else if (direction < 0)
	if (direction >= -(poly->pt_count/2) )
		direction = -1;   /*note careful balance between >= and -( */
	else
		direction = 1;

show_help("pick last point, hold down to move");
for (;;)
	{
	vis = await_input(USE_CURSOR);
	if ( unsegged(m, vis, point, poly, 1) )
		return(0);
	if (pjstdn(vis))
		break;
	}
find_closest(vis,poly->pt_list,poly->pt_count,
	&third_point,&distance);


if (direction > 0)
	{
	segment_start = first_point;
	segment_length = third_point - first_point;
	}
else
	{
	segment_start = third_point;
	segment_length = first_point - third_point;
	}


while (segment_length < 0 )
	segment_length += poly->pt_count;

segment_length++;

addr[3] = segment_start;
addr[4] = segment_length;
addr[5] = poly->pt_count;

show_cursor(&segment_cursor, point->x, point->y, 0);
unrub_poly(poly, cur_sequence);
return(1);
}

op_addr_convert(mode)
WORD mode;
{
switch(mode)
	{
	case S_POINT:
	case S_POINTS:
		return(POINTS);
	case S_SEGMENT:
		return(SEGMENT);
	case S_POLY:
	case S_POLYS:
		return(POLYS);
	case S_FRAME:
		return(FRAME);
	}
}



WORD **
one_address(m,sel, vis, seq, addr_mode, poly_list, init_poly, add_count,
	rin_menu)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
struct s_sequence *seq;
WORD addr_mode;
struct poly_list *poly_list;
WORD init_poly;
WORD *add_count;
WORD rin_menu;
{
WORD *addr, **addrs;
WORD really;
long distance;
struct poly *poly;
WORD op_addr_mode;

extern WORD ** doto_dead_too();

#ifdef DEBUG
lprintf("one_address(%lx %lx %lx %lx %d %lx %d %d\n", m, sel, vis, seq,
	addr_mode, poly_list, init_poly, add_count);
#endif DEBUG

poly_list = seq->next_poly_list;
if (poly_list->count <= 0)
	{
	*add_count = 0;
	return(NULL);
	}


for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (rin_menu)
		{
		if (in_menu(m, vis) )
			{
			reuse_input();
			return(NULL);
			}
		}
	else if (vis->result & MENUPICKED)
		{
		reuse_input();
		return(NULL);
		}

	if (vis->result & CANCEL) 
		{
		reuse_input();
		return(NULL);
		}
	if ( pjstdn(vis) )
		break;
	}

op_addr_mode = op_addr_convert(addr_mode);

addr = (WORD *) alloc(address_length[op_addr_mode] * sizeof(WORD) );
*addr = address_length[op_addr_mode];
*(addr+1) = op_addr_mode;


if (init_poly>=0)
	addr[2] = init_poly;
else
	{
	if ( which_poly(vis, seq, addr+2) == NULL)
	{
	return(NULL);
	}
	}

poly = *(poly_list->list + addr[2]);
if ((poly->type & IS_RASTER) && 
	(op_addr_mode == POINTS || op_addr_mode == SEGMENT)  )
	return(NULL);

switch(op_addr_mode)
	{
	case POINTS:
		find_closest(vis,poly->pt_list,poly->pt_count,addr+3,&distance);
		break;
	case SEGMENT:
		find_closest(vis,poly->pt_list,poly->pt_count,addr+3,&distance);
		really = which_segment(m, sel, vis, addr, poly_list);
		if (!really)
			{
			mfree(addr, *(addr) * sizeof(WORD) );
			addr = NULL;
			*add_count = 0;
			}
		break;
	case POLYS:
		break;
	case FRAME:
		*(addr+2) = 0;
		*(addr+3) = poly_list->count;
		break;
	}

if ( addr )
	{
	addrs = (WORD **)alloc( sizeof(WORD *) );
	*addrs = addr;
	*add_count = 1;
	addrs = doto_dead_too( seq, poly_list, addrs, add_count); 
	return(addrs);
	}
else
	return(NULL);
}




get_pd_off_menu(m)
struct menu *m;
{
struct virtual_input *vis;

for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (in_menu(m, vis) )
		{
		reuse_input();
		return(0);
		}
	if (pjstdn(vis) )
		return(1);
	if (vis->result & CANCEL)
		return(0);
	}
}

get_pd_no_menu()
{
struct virtual_input *vis;

for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (pjstdn(vis) )
		return(1);
#ifdef AMIGA
	if (vis->result & MENUPICKED)
		{
		reuse_input();
		return(0);
		}
#endif AMIGA
	if (vis->result & CANCEL)
		return(0);
	}
}

WORD **
get_frame_as_polys( m, poly_list, address_count)
struct menu *m;
struct poly_list *poly_list;
WORD *address_count;
{
register WORD **WORDpts, *WORDpt, i;
WORD **addr_list, addr_count;

if (!get_pd_off_menu(m) )
	{
	*address_count = 0;
	return(NULL);
	}
addr_count = *address_count = poly_list->count;
addr_list = WORDpts = (WORD **)alloc(addr_count *
	 sizeof(WORD *) );
for (i=0; i<addr_count; i++)
	{
	*(WORDpts++) = WORDpt = (WORD *)alloc( 3 * sizeof(WORD) );
	WORDpt[0] = 3;   /*length of tube*/
	WORDpt[1] = POLYS;  /*type word*/
	WORDpt[2] = i;   /*poly_ix */
	}
return(addr_list);
}

extern WORD a_count, **a_list;

WORD **
g_address_list(m, sel, vis, seq, addr_mode, poly_list, address_count, plonly)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
struct s_sequence *seq;
WORD addr_mode;
struct poly_list *poly_list;
WORD *address_count;
WORD plonly;
{
WORD **ret;
extern WORD **s_points(), **s_polys();

#ifdef DEBUG
lprintf("get_address_list(%lx %lx %lx %lx %d %lx %d)\n", m, sel, vis, seq,
	addr_mode, poly_list, address_count);
#endif DEBUG

free_tube_list(a_list, a_count);
a_count = 0;

if (plonly)
	{
	if (addr_mode == S_POINT || addr_mode == S_POINTS || addr_mode == S_SEGMENT)
	addr_mode = S_POLY;
	}

switch(addr_mode)
	{
	case S_POINT:
	case S_SEGMENT:
	case S_POLY:
	case S_FRAME:
		if (addr_mode == S_FRAME && plonly)
			{
			a_list = get_frame_as_polys( m, 
				cur_sequence->next_poly_list, &a_count);
			}
		else
			a_list = one_address(m, sel, vis, seq,
			addr_mode, cur_sequence->next_poly_list,-1, &a_count, 1);
		if (a_count > 0 && a_list != NULL)
			{
			*address_count = a_count;
			maybe_clear_menu(m);
			return(a_list);
			}
		else
			{
			*address_count = 0;
			return(NULL);
			}
		break;
	case S_POINTS:
		ret = s_points(m, sel, vis);
		break;
	case S_POLYS:
		ret = s_polys(m, sel, vis);
		break;
	}
if (a_count <= 0)
	{
	if (ret == (WORD **)-1)
		{
		maybe_draw_menu(m);
		ret = NULL;
		}
	}
*address_count = a_count;
return(ret);
}

WORD **
get_address_list(m, sel, vis, seq, addr_mode, poly_list, address_count)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
struct s_sequence *seq;
WORD addr_mode;
struct poly_list *poly_list;
WORD *address_count;
{
return(
	g_address_list(m, sel, vis,
	seq, addr_mode, poly_list, address_count, 0) );
}

WORD **
get_polys_only(m, sel, vis, seq, addr_mode, poly_list, address_count)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
struct s_sequence *seq;
WORD addr_mode;
struct poly_list *poly_list;
WORD *address_count;
{
return(
	g_address_list(m, sel, vis,
	seq, addr_mode, poly_list, address_count, 1) );
}



undraw_a_list(address_list, count, poly_list)
WORD **address_list;
WORD count;
struct poly_list *poly_list;
{
struct poly *poly, **polys;
WORD *addr, **add_list;
WORD i, j;
Cube oclip;
Cube bounds;


#ifdef DEBUG
lprintf("undraw_a_list(%lx %d %lx)\n",address_list, count, poly_list);
#endif DEBUG

clear_screen();
j = count;
add_list = address_list;
while (--j >= 0)
	{
	addr = *(add_list++);
	if ( *(addr+1) == FRAME )
		{
		polys = poly_list->list;
		i = poly_list->count;
		while (--i >= 0)
			{
			poly = *(polys++);
			poly->type |= HIDE_BIT;
			}
		}
	else
		{
		poly = *(poly_list->list + addr[2]);
		poly->type |= HIDE_BIT;
		}
	}
draw_pllist(poly_list, cur_sequence);
j = count;
add_list = address_list;
while (--j >= 0)
	{
	addr = *(add_list++);
	if ( *(addr+1) == FRAME )
		{
		polys = poly_list->list;
		i = poly_list->count;
		while (--i >= 0)
			{
			poly = *(polys++);
			poly->type &= ~HIDE_BIT;
			}
		}
	else
		{
		poly = *(poly_list->list + addr[2]);
			poly->type &= ~HIDE_BIT;
		}
	}
}

in_WORD_list(list, count, is_in)
WORD *list;
WORD count;
WORD is_in;
{
while (--count >= 0)
	{
	if (*(list++) == is_in)
		return(1);
	}
return(0);
}


rrub_a_list(address_list, count, poly_list, un)
WORD **address_list;
WORD count;
struct poly_list *poly_list;
WORD un;
{
struct poly *poly, **polys;
WORD *addr;
WORD i,j;
WORD *rub_list;
WORD rub_count;

#ifdef DEBUG
lprintf("rrub_a_list(%lx %d %lx)\n",address_list, count, poly_list);
#endif DEBUG

rub_list = (WORD *)alloc( count * sizeof(WORD) );
rub_count = 0;
i = count;
while (--i >= 0)
	{
	addr = *(address_list++);
	if ( *(addr+1) == FRAME )
		{
		polys = poly_list->list;
		j = poly_list->count;
		while (--j >= 0)
			{
			if (un)
			unrub_poly( *polys++, cur_sequence );
			else
			rub_poly(*polys++, cur_sequence);
			}
		}
	else
		{
		if (!in_WORD_list( rub_list, rub_count, addr[2] ))
			{
			poly = *(poly_list->list + addr[2]);
			if (un)
				unrub_poly( poly , cur_sequence);
			else
				rub_poly(poly, cur_sequence);
			rub_list[rub_count] = addr[2];
			rub_count++;
			}
		}
	}
mfree(rub_list, count * sizeof(WORD));
}

rub_a_list(address_list, count, poly_list)
WORD **address_list;
WORD count;
struct poly_list *poly_list;
{
rrub_a_list(address_list, count, poly_list, 0);
}


unrub_a_list(address_list, count, poly_list)
WORD **address_list;
WORD count;
struct poly_list *poly_list;
{
rrub_a_list(address_list, count, poly_list, 1);
}



last_coors( op_list, op_count, firstx, firsty, lastx, lasty, thisx, thisy)
WORD **op_list;
WORD op_count;
WORD firstx, firsty;
WORD lastx, lasty;
WORD thisx, thisy;
{
WORD *op;
WORD op_type, ad_type;
WORD xcen, ycen;
WORD theta;
WORD p, q;
extern WORD move_mode;

#ifdef DEBUG
lprintf("last_coors( %lx %d (%d %d) (%d %d) )\n", op_list, op_count,
	firstx, firsty, lastx, lasty);
#endif DEBUG

while (--op_count >= 0)
	{
	op = *(op_list++);
	op_type = function_type[ *(op+1) ];
	ad_type = address_type[ *(op+1) ];
	op += address_length[ ad_type ];
	switch (op_type)
		{
		case INSERT_OP:
		case KILL_OP:
		case XCOLOR_OP:
		case XTYPE_OP:
			break;	
		case MOVE_OP:
			switch (move_mode)
				{
				case 'x':
					*(op) = thisx - firstx;
					*(op+1) = thisy - firsty;
					*(op+2) = 0;
					break;
				case 'u':
					*(op+0) = *(op+1) = 0;
					*(op+2) = -calc_distance( thisx, thisy,
						firstx, firsty );
					break;
				case 'd':
					*(op+0) = *(op+1) = 0;
					*(op+2) = calc_distance( thisx, thisy,
						firstx, firsty );
					break;
				}
			break;
		case ROT_OP:

			xcen = op[0];
			ycen = op[1];
			theta = 
				arctan(thisx - xcen, thisy - ycen) - 
				arctan(lastx - xcen, lasty - ycen);
			while (theta > TWO_PI/2 ) theta -= TWO_PI;
			while (theta < -TWO_PI/2) theta += TWO_PI;
			*(op+5) += theta;
			break;
		case SIZE_OP:
			{
			register WORD p, q;
			xcen = *(op);
			ycen = *(op+1);
			p = calc_distance( thisx, thisy, xcen, ycen);
			q = calc_distance( firstx, firsty, xcen, ycen);
			if (!q)
			q = 1;
			if ( p > q * 15)
			q = p/15 + 1;
			*(op+3) = p;
			*(op+4) = q;
			}
			break;
		default:
			lprintf("unknown case in last_coors\n");
			break;
		}
	}
}

