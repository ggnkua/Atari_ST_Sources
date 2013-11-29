
#include "flicker.h"
#include "flicmenu.h"

extern Cel *rs_cel;
extern Byte_cel *rs_bcel;
static WORD angle, first_angle, last_angle;
static WORD cenx, ceny;
char axis = 'z';

print_degrees()	
{
char s[16];

sprintf(s, "%ld degrees", (((long)360*angle+0x200)/0x400)&0x3ff );
colblock(black, 0, 0, CH_WIDTH*strlen(s), CH_HEIGHT);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}

rot_lines()
{
Point poly[3];
set_solid_line();
set_acolor(oppositec[0]);
poly[0].x = firstx;
poly[0].y = firsty;
poly[1].x = cenx;
poly[1].y = ceny;
poly[2].x = mouse_x;
poly[2].y = mouse_y;
thin_polyline(poly, 3);
}

see_rotate()
{
hide_mouse();
unundo();
print_degrees();
rub_paste(rs_cel, 0, 0);
rot_lines();
show_mouse();
see_buffer();
}

get_angle()
{
angle = (-arctan(mouse_y - ceny, mouse_x - cenx) - first_angle)&0x3ff;
}

xyzrotate(constrain)	
WORD constrain;
{
WORD mod;
long p;

last_angle = -2222;	/* just arbitrary impossible value */
mod = 1024/constrain;
mod >>= 1;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		get_angle();
		p = angle + mod;
		p *= constrain;
		p  &= 0xfffffc00;	/* mask out lower 10 bits */
		angle = p/constrain;
		if (last_angle != angle)
			{
			free_cel(rs_cel);
			if ((rs_cel = rot_byte_cel(rs_bcel, angle, axis)) == NULL)
				{
				return(0);
				}
			last_angle = angle;
			}
		see_rotate();
		}
	check_input();
	}
return(1);
}


rotate0()	/* rotate	30 degrees at a time */
{
axis = 'z';
return(xyzrotate(12));
}

rotate1()	/* rotate around x 22.5 degrees at a time */
{
axis = 'x';
return(xyzrotate(16));
}

rotate2()	/* rotate 45 degrees at a time */
{
axis = 'z';
return(xyzrotate(8));
}

rotate3()	/* rotate around y 22.5 degrees at a time */
{
axis = 'y';
return(xyzrotate(16));
}

rotate5()	/* rotate one degree at a time around y*/
{
axis = 'y';
return(xyzrotate(1024) );
}

rotate6()	/* rotate 22.5 degrees at a time */
{
axis = 'z';
return(xyzrotate(16));
}

rotate7()	/* rotate one degree at a time around x*/
{
axis = 'x';
return(xyzrotate(1024) );
}

rotate8()	/* rotate one degree at a time in xy plane */
{
axis = 'z';
return(xyzrotate(1024) );
}


extern int stretch4();

Vector rotaters[9] =
	{ rotate0, rotate1, rotate2, rotate3, stretch4, rotate5,
		rotate6, rotate7, rotate8};


rotate_clip()
{
Cel *c;
WORD i;
WORD outofmem;

if ((c = clipping) == NULL)
	{
	top_line("Nothing to Rotate!");
	return;
	}
if ( (rs_bcel = cel_to_byte(c)) == NULL)
	{
	outta_memory();
	return;
	}
if ((rs_cel = clone_cel(c)) == NULL)
	{
	rs_cleanup();
	outta_memory();
	return;
	}
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
rub_paste(rs_cel, 0, 0);
show_mouse();
see_buffer();
for (;;)
	{
	cenx = rs_cel->xoff + (rs_cel->width>>1);
	ceny = rs_cel->yoff + (rs_cel->height>>1);
	if (clip_vinit())
		{
		first_angle = -arctan(mouse_y - ceny, mouse_x - cenx);
		if (!(*rotaters[which_nine(rs_cel)])())
			{
			outofmem = 1;
			break;
			}
		}
	else
		{	
		outofmem = 0;
		wait_rup();
		break;
		}
	}
hide_mouse();
unundo();
if (select_mode == 0)
	{
	do_paste(rs_cel, 0, 0);
	dirtys();
	}
uninit_some_tools();
if (select_mode != 0 && !outofmem)
	{
	multiple_rotate();
	}
show_mouse();
rs_cleanup();
if (outofmem)
	outta_memory();
super_center();
}

multi_rot_func(i, ds)
WORD i, ds;
{
WORD iangle;

iangle = sscale_by(angle, i, ds);
free_cel(rs_cel);
if ((rs_cel = rot_byte_cel(rs_bcel, iangle, axis)) == NULL)
	{
	return(0);
	}
do_paste(rs_cel, 0, 0);
return(1);
}

multiple_rotate()
{
angle &= 0x3ff;
if (angle == 0)
	angle = 1024;
qdo_many(multi_rot_func, select_mode == 2 && angle == 1024);
}

