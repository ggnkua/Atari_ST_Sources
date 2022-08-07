
overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\io.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\perspect.h"
#include "..\\include\\color.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"


struct point center_point = 
	{
	VXMAX/2, VYMAX/2, NEW_GROUND_Z, 0,
	};

struct point apparent_center;


extern struct cursor center_cursor;
extern struct cursor zxrot_cursor;
extern struct cursor zyrot_cursor;
extern struct cursor rotate_cursor;

WORD rot_mode; /*this guy is stuffed by the vroutines*/

show_center_point()
{
register struct cursor *cursor;

center_point.z = ground_z;
switch( rot_mode )
	{
	case 'x':
		cursor = &zyrot_cursor;
		break;
	case 'y':
		cursor = &zxrot_cursor;
		break;
	case 's':
	case 'z':
		cursor = &center_cursor;
		break;
	}
zscale_point(&center_point, &apparent_center);
dshow_cursor(cursor, apparent_center.x, apparent_center.y);
}

dshow_cursor(cursor, x, y)
register struct cursor *cursor;
register WORD x, y;
{
show_cursor(cursor, x, y, cycle_color);
set_d2_back();
show_cursor(cursor, x, y, cycle_color);
set_d2_front();
}

unshow_center_point()
{
register struct cursor *cursor;

switch( rot_mode )
	{
	case 'x':
	cursor = &zyrot_cursor;
	break;
	case 'y':
	cursor = &zxrot_cursor;
	break;
	case 's':
	case 'z':
	cursor = &center_cursor;
	break;
	}
zscale_point(&center_point, &apparent_center);
set_d2_back();
show_cursor(cursor,apparent_center.x, apparent_center.y, 0);
set_d2_front();
show_cursor(cursor,apparent_center.x, apparent_center.y, 0);
}

move_center_point(m, sel, vis, prompt)
struct menu *m;
struct selection *sel;
register struct virtual_input *vis;
char *prompt;
{
register WORD dx_app, dy_app, dx, dy;
register struct cursor *cursor;

prompt = lsprintf("%s - first select center", prompt);
show_help(prompt);

center_point.z = ground_z;
zscale_point(&center_point, &apparent_center);
switch( rot_mode )
	{
	case 'x':
		cursor = &zyrot_cursor;
		break;
	case 'y':
		cursor = &zxrot_cursor;
		break;
	case 's':
	case 'z':
		cursor = &center_cursor;
		break;
	}

new_cursor(cursor);

for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (in_menu(m, vis)) 
		{
		reuse_input();
		return(0);
		}
	if (vis->result & CANCEL || (keypress(vis) && vis->data == ' '))
		{
		show_center_point();
		return(1); /*on cancel with no menu reuse old center*/
		}
	if (pjstdn(vis))
		break;
	}


dx_app = vis->curx - apparent_center.x;
dy_app = vis->cury - apparent_center.y;
dx = inv_zscale_distance( dx_app, center_point.z);
dy = inv_zscale_distance( dy_app, center_point.z);
center_point.x += dx;
center_point.y += dy;

show_center_point();
return(1);
}

