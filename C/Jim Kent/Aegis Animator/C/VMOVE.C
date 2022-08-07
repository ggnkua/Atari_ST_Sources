
overlay "vtools"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\io.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\menu.h"


extern WORD *make_opcode();
extern WORD **expand_act_list();

WORD move_mode;

vmove(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
extern struct cursor grab_cursor;

#ifdef DEBUG
lprintf("vmove( control%lx )\n",control);
#endif DEBUG

move_mode = 'x';

if (no_polys_check() )
	return;

show_help("move from side to side");
vgeneric(m, sel, vis, (cur_sequence->next_poly_list), MOVE_OP, s_mode,
	&grab_cursor, "release button at destination");
}

extern struct cursor size_cursor;
extern struct cursor center_cursor;
vz(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct cursor *cursor;

extern WORD z_direction;
extern struct cursor in_cursor, out_cursor;

#ifdef DEBUG
lprintf("vmove( control%lx )\n",control);
#endif DEBUG

if (no_polys_check() )
	return;

move_mode = z_direction;
switch(move_mode)
	{
	case 'u':
	show_help("move out of screen");
	cursor = &out_cursor;
	vgeneric(m, sel, vis, (cur_sequence->next_poly_list), MOVE_OP, s_mode,
		&out_cursor, "moves out as far as you move to side" );
	break;
	case 'd':
	show_help("move into screen");
	cursor = &in_cursor;
	vgeneric(m, sel, vis, (cur_sequence->next_poly_list), MOVE_OP, s_mode,
		&in_cursor, "moves in as far as you move to side" );
	break;
	}
}



