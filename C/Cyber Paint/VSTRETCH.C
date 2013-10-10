
#include "flicker.h"
#include "flicmenu.h"

Cel *rs_cel;	/* used here and in vrotate too */
Byte_cel *rs_bcel;	/* used here and in vrotate too */

print_proportion()	
{
char s[40];

sprintf(s, "(%d %d) x %ld%%  y %ld%%",
	rs_cel->width, rs_cel->height,
	(long)100*rs_cel->width/rs_bcel->width,
	(long)100*rs_cel->height/rs_bcel->height);
colblock(black, 0, 0, CH_WIDTH*strlen(s), CH_HEIGHT);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}

/* return positive result to show how many times bigger new is than old,
	negative for how many times smaller */
integer_prop(new, old)	
WORD new, old;
{
register WORD result;
register WORD temp;

if ((temp = new - old) >= 0)
	{
	result = 1;
	}
else
	{
	result = -1;
	}
result += temp>>4;	/* every 16 pixels add another factor */
return(result);
}

calc_prop(a, prop)
WORD a, prop;
{
if (prop >= 0)
	return(a*prop);
else
	{
	prop = -prop;
	return( (a+(prop>>1))/prop);
	}
}

which_3(min, max, val)
WORD min, max;
register WORD val;
{
if (val < min)
	return(0);
if (val < max)
	return(1);
return(2);
}

which_nine()
{
register Cel *c;

c = rs_cel;
return( which_3(c->xoff, c->xoff+c->width, mouse_x) +
	3*which_3(c->yoff, c->yoff+c->height, mouse_y) );
}

see_stretch()
{
hide_mouse();
unundo();
print_proportion();
rub_paste(rs_cel, 0, 0);
show_mouse();
see_buffer();
}

static WORD new_height;
static WORD new_width;

stretch0()	/* proportional xy upper left stretch  with integer constraints*/
{
register Cel *rs;
register WORD orgxoff, orgyoff;
register WORD owidth, oheight;
WORD prop;

rs = rs_cel;
orgxoff = rs->xoff + rs->width;
orgyoff = rs->yoff + rs->height;
owidth = rs->width;
oheight = rs->height;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = orgxoff - mouse_x;
		prop = integer_prop(new_width, owidth);
		new_width = calc_prop(owidth, prop);
		new_height = calc_prop(oheight, prop);
		if (new_width <= 0)
			new_width = 1;
		if (new_height <= 0)
			new_height = 1;
		if (new_width != rs->width || new_height != rs->height)
			{
			free_cel(rs);
			rs_bcel->xoff = orgxoff - new_width;
			rs_bcel->yoff = orgyoff - new_height;
			if ((rs = rs_cel = 
				stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
				return(0);
			see_stretch();
			}
		else
			see_buffer();
		}
	check_input();
	}
return(1);
}

stretch1()	/* stretch up  with integer constraints*/
{
WORD orgyoff;
WORD owidth, oheight;

orgyoff = rs_cel->yoff + rs_cel->height;
new_width = owidth = rs_cel->width;
oheight = rs_cel->height;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_height = orgyoff - mouse_y;
		new_height = calc_prop(oheight, integer_prop(new_height, oheight) );
		if (new_height <= 0)
			new_height = 1;
		if (new_height != rs_cel->height)
			{
			free_cel(rs_cel);
			rs_bcel->yoff = orgyoff - new_height;
			if ((rs_cel = 
				stretch_byte_cel(rs_bcel, owidth, new_height)) == NULL)
				return(0);
			see_stretch();
			}
		else
			see_buffer();
		}
	check_input();
	}
return(1);
}

stretch2()	/* upper right independent x/y stretch with integer contraints*/
{
WORD orgxoff, orgyoff;
WORD owidth, oheight;

orgxoff = rs_cel->xoff;
orgyoff = rs_cel->yoff + rs_cel->height;
owidth = rs_cel->width;
oheight = rs_cel->height;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = mouse_x - orgxoff;
		new_width = calc_prop(owidth, integer_prop(new_width, owidth) );
		if (new_width <= 0)
			new_width = 1;
		new_height = orgyoff - mouse_y;
		new_height = calc_prop(oheight, integer_prop(new_height, oheight) );
		if (new_height <= 0)
			new_height = 1;
		if (new_width != rs_cel->width || new_height != rs_cel->height)
			{
			free_cel(rs_cel);
			rs_bcel->yoff = orgyoff - new_height;
			if ((rs_cel = 
				stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
				return(0);
			see_stretch();
			}
		else
			see_buffer();
		}
	check_input();
	}
return(1);
}

stretch3()	/* middle left ... stretch left with integer constraints*/	
{
WORD orgxoff;
WORD oheight, owidth;

orgxoff = rs_cel->xoff + rs_cel->width;
new_height = oheight = rs_cel->height;
owidth = rs_cel->width;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = orgxoff - mouse_x;
		new_width = calc_prop(owidth, integer_prop(new_width, owidth) );
		if (new_width <= 0)
			new_width = 1;
		if (new_width != rs_cel->width)
			{
			free_cel(rs_cel);
			rs_bcel->xoff = orgxoff - new_width;
			if ((rs_cel = 
				stretch_byte_cel(rs_bcel, new_width, oheight)) == NULL)
				return(0);
			see_stretch();
			}
		else
			see_buffer();
		}
	check_input();
	}
return(1);
}

stretch4()	/* middle - don't stretch, just move */
{
register Cel *c;
register WORD dx, dy;

dx = dy = 0;
c = rs_cel;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		dx += mouse_x - lastx;
		dy += mouse_y - lasty;
		hide_mouse();
		unundo();
		print_cel_pos(c, dx, dy);
		rub_paste(c, dx, dy);
		show_mouse();
		see_buffer();
		}
	check_input();
	}
clipping->xoff = rs_bcel->xoff = c->xoff += dx;
clipping->yoff = rs_bcel->yoff = c->yoff += dy;
return(1);
}

stretch5()	/* middle right ... stretch right */
{
WORD orgxoff;

new_height = rs_cel->height;
orgxoff = rs_cel->xoff;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = mouse_x - orgxoff;
		if (new_width <= 0)
			new_width = 1;
		free_cel(rs_cel);
		if ((rs_cel = stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
			return(0);
		see_stretch();
		}
	check_input();
	}
return(1);
}

stretch6()	/* lower left - free floating x/y stretch */
{
WORD orgxoff, orgyoff;
WORD owidth, oheight;

orgxoff = rs_cel->xoff + rs_cel->width;
orgyoff = rs_cel->yoff;
owidth = rs_cel->width;
oheight = rs_cel->height;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = orgxoff - mouse_x;
		if (new_width <= 0)
			new_width = 1;
		new_height = mouse_y - orgyoff;
		if (new_height <= 0)
			new_height = 1;
		free_cel(rs_cel);
		rs_bcel->xoff = orgxoff - new_width;
		if ((rs_cel = stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
			return(0);
		see_stretch();
		}
	check_input();
	}
return(1);
}

stretch7()	/* lower middle ... stretch down */
{
WORD orgyoff;

new_width = rs_cel->width;
orgyoff = rs_cel->yoff;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_height = mouse_y - orgyoff;
		if (new_height <= 0)
			new_height = 1;
		free_cel(rs_cel);
		if ((rs_cel = stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
			return(0);
		see_stretch();
		}
	check_input();
	}
return(1);
}

stretch8()	/* lower right, proportional xy stretch */
{
WORD orgxoff;
WORD owidth, oheight;

orgxoff = rs_cel->xoff;
owidth = rs_cel->width;
oheight = rs_cel->height;
for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		new_width = mouse_x - orgxoff;
		if (new_width <= 0)
			new_width = 1;
		new_height = (long)oheight*new_width/owidth;
		if (new_height <= 0)
			new_height = 1;
		free_cel(rs_cel);
		if ((rs_cel = stretch_byte_cel(rs_bcel, new_width, new_height)) == NULL)
			return(0);
		see_stretch();
		}
	check_input();
	}
return(1);
}

Vector stretchers[9] =
	{ stretch0, stretch1, stretch2, stretch3, stretch4, stretch5,
		stretch6, stretch7, stretch8};

stretch_clip()
{
register Cel *c;
WORD i;
WORD niner;	/* which one of nine areas mouse is in */
WORD outofmem;
WORD w, h;
WORD iw, ih;
WORD cenx, ceny;

if ((c = clipping) == NULL)
	{
	top_line("Nothing to Stretch!");
	return;
	}
if ( (rs_bcel = cel_to_byte(c)) == NULL)
	{
	outta_memory();
	return;
	}
if ((rs_cel = clone_cel(clipping)) == NULL)
	{
	outta_memory();
	rs_cleanup();
	return;
	}
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
see_stretch();
for (;;)
	{
	if (clip_vinit())	/* on left button down move it a bit... */
		{
		if (!(*stretchers[which_nine(rs_cel)])())
			{
			outofmem = 1;
			break;
			}
		}
	else
		{	/* on right button make stretch cel into clipping cel */
		outofmem = 0;
		wait_rup();
		break;
		}
	}
hide_mouse();
unundo();
if (select_mode == 0)
	do_paste(rs_cel, 0, 0);
uninit_some_tools();
if (select_mode != 0 && !outofmem)
	multiple_stretch();
show_mouse();
rs_cleanup();
if (outofmem)
	outta_memory();
dirtys();
super_center();
}

static WORD w, h, cenx, ceny;

multi_stretch_func(i, ds)
WORD i, ds;
{
WORD iw, ih;

iw =  sscale_by(new_width-w, i, ds)+w;
ih =  sscale_by(new_height-h, i, ds)+h;
free_cel(rs_cel);
if ((rs_cel = stretch_byte_cel(rs_bcel, iw, ih)) == NULL)
	{
	return(0);
	}
rs_cel->xoff = cenx - (iw>>1);
rs_cel->yoff = ceny - (ih>>1);
do_paste(rs_cel, 0, 0);
return(1);
}

multiple_stretch()
{
w = clipping->width;
h = clipping->height;
cenx = clipping->xoff + (w>>1);
ceny = clipping->yoff + (h>>1);
qdo_many(multi_stretch_func, 1);
}



rs_cleanup()
{
free_cel(rs_cel);
rs_cel = NULL;
free_byte_cel(rs_bcel);
rs_bcel = NULL;
}
