
#include "flicker.h"
#include "flicmenu.h"


char fittingc[16];	/* best fit lookup */

Cel *clipping = NULL;

Cel *
init_cel(w, h)
register WORD w, h;
{
register Cel *cel;

if ((cel = Alloc_a(Cel)) == NULL)
	return(NULL);
cel->image_size = Raster_block((long)w, (long)h);
cel->image = NULL;
cel->width = w;
cel->height = h;
cel->mask = NULL;
cel->xoff = cel->yoff = 0;
return(cel);
}

Cel *
alloc_cel(w, h)
register WORD w, h;
{
register Cel *cel;

if ((cel = init_cel(w, h)) == NULL)
	return(NULL);
if (  (cel->image = (WORD *)laskmem(cel->image_size)) == NULL)
	{
	Free_a(cel);
	return(NULL);
	}
word_zero(cel->image, (unsigned)(cel->image_size/sizeof(WORD)));
return(cel);
}

Cel *
clone_cel(s)
register Cel *s;
{
register Cel *d;
WORD *image;

if ((d = alloc_cel(s->width, s->height)) == NULL)
	return(NULL);
image = d->image;
*d = *s;
d->image = image;
copy_longs(s->image, d->image, s->image_size>>2);
if (s->mask)
	{
	if ( !mask_cel(d) )
		{
		free_cel(d);
		return(NULL);
		}
	}
return(d);
}


free_cel(cel)
register Cel *cel;
{
if (cel == NULL)
	return;
freemem(cel->image);
if (cel->mask)
	freemem(cel->mask);
Free_a(cel);
}

mask_cel(cel)
register Cel *cel;
{
if ((cel->mask = (WORD *)laskmem(cel->image_size>>2)) == NULL)
	return(0);
calc_mask(cel->image, cel->mask, cel->image_size>>3);
return(1);
}

do_paste_under(c, x, y, sscreen)
register Cel *c;
WORD x, y;
WORD *sscreen;	/* scratch screen */
{
WORD *ocscreen;

if (c == NULL)
	return;
if (c->image == NULL)
	return;
copy_screen(cscreen, sscreen);
zero_screen(sscreen);
ocscreen = cscreen;
cscreen = sscreen;
copy_celblit(x, y, c);
cscreen = ocscreen;
zscopy_screen(sscreen, cscreen, cscreen);
}

do_paste(c, x, y)
register Cel *c;
WORD x, y;
{
if (c == NULL)
	return;
if (c->image == NULL)
	return;
if (nozero_flag)
	nozero_celblit(x, y, c);
else
	copy_celblit(x, y, c);
}

rub_paste(c, x, y)
register Cel *c;
register WORD x, y;
{
if (c == NULL)
	return;
do_paste(c, x, y);
x += c->xoff;
y += c->yoff;
draw_frame(oppositec[0], x, y, x+c->width-1, y+c->height-1);
}

clip_vinit()
{
for (;;)
	{
	check_input();
	see_buffer();
	if (EDN || key_hit)
		break;
	}
firstx = mouse_x;
firsty = mouse_y;
return(PDN);
}

position_clip()
{
mp_clip(1);
}

paste_clip()
{
mp_clip(0);
}

paste_under()
{
mp_clip(2);
}

print_one_coor(x, y)
WORD x, y;
{
char s[16];

sprintf(s, "(%d %d)", x, y);
colblock(black, 0, 0, CH_WIDTH*strlen(s), CH_HEIGHT);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}

int_abs(x)
WORD x;
{
if (x >= 0)
	return(x);
else
	return(-x);
}

print_coors_dx(x1, y1, x2, y2)
WORD x1, y1, x2, y2;
{
char s[40];

sprintf(s, "(%d %d) %d %d (%d %d)", x1, y1, int_abs(x2-x1)+1, int_abs(y2-y1)+1,
	x2, y2);
colblock(black, 0, 0, CH_WIDTH*strlen(s), CH_HEIGHT);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}


print_cel_pos(c, dx, dy)
register Cel *c;
WORD dx, dy;
{
char s[40];

sprintf(s, "(%d %d) dx %d  dy %d",
	c->xoff+dx, c->yoff+dy,
	dx, dy);
colblock(black, 0, 0, CH_WIDTH*strlen(s), CH_HEIGHT);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}


print_position(dx, dy)	
WORD dx, dy;
{
print_cel_pos(clipping, dx, dy);
}

static WORD dx, dy;
static WORD mmode;

multipaste_func(i, ds)
WORD i;
register WORD ds;
{
register WORD x, y;

x = sscale_by(i, dx, ds);
y = sscale_by(i, dy, ds);
if (mmode == 0)
	do_paste(clipping, x, y);
else if (mmode == 2)
	do_paste_under(clipping, x, y, uscreen);
return(1);
}

mp_clip(mode)
WORD mode;
{
register Cel *cel;
WORD *save_cscreen;
WORD i;
char mem = 1;

if ((cel = clipping) == NULL)
	{
	top_line("Nothing to Paste!");
	return;
	}
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
rub_paste(cel, 0, 0);
show_mouse();
see_buffer();
if (clip_vinit())	/* on left button down move it a bit... */
	{
	for (;;)
		{
		if (!PDN)
			break;
		if (mouse_moved)
			{
			hide_mouse();
			unundo();
			rub_paste(cel, mouse_x - firstx, mouse_y - firsty);
			if (!zoom_flag)
				print_position(mouse_x-firstx, mouse_y-firsty);
			show_mouse();
			see_buffer();
			if (zoom_flag)
				{
				draw_on_screen();
				print_position(mouse_x-firstx, mouse_y-firsty);
				draw_on_buffer();
				}
			}
		check_input();
		}
	dx = mouse_x - firstx;
	dy = mouse_y - firsty;
	}
else
	dx = dy = 0;
hide_mouse();
unundo();
if (mode != 1)
	{
	if (select_mode == 0)
		{
		if (mode == 0)
			do_paste(cel, dx, dy);
		else if (mode == 2)
			do_paste_under(cel, dx, dy, pscreen);
		dirtys();
		}
	}
show_mouse();
see_buffer();
uninit_some_tools();
if ((mode != 1) && select_mode != 0)
	{
	mmode = mode;
	doit_many_times(multipaste_func, 0);
	}
cel->xoff += dx;
cel->yoff += dy;
}


snipit(screen)
WORD *screen;
{
register Cel *cel;

free_cel(clipping);
if ((cel = clipping = alloc_cel(x_1 - x_0, y_1 - y_0)) == NULL)
	{
	return(0);
	}
cel->xoff = x_0;
cel->yoff = y_0;
clip_from_screen(cel, screen);
return(1);
}

end_vclip()
{
hide_mouse();
unundo();
if (!snipit(cscreen) ||  !mask_cel(clipping))
	{
	outta_memory();
	free_cel(clipping);
	clipping = NULL;
	}
show_mouse();
}

pos_cross_hairs(xoff, yoff, v)
WORD xoff, yoff;
Vector v;
{
if (v != NULL)
	(*v)();
if (!zoom_flag)
	print_one_coor(mouse_x+xoff, mouse_y+yoff);
lines_cursor();
see_buffer();
if (zoom_flag)
	{
	draw_on_screen();
	print_one_coor(mouse_x+xoff, mouse_y+yoff);
	draw_on_buffer();
	}
for (;;)
	{
	check_input();
	if (EDN)
		{
		unundo();
		show_mouse();
		see_buffer();
		break;
		}
	if (mouse_moved)
		{
		unundo();
		if (v != NULL)
			(*v)();
		if (!zoom_flag)
			print_one_coor(mouse_x+xoff, mouse_y+yoff);
		lines_cursor();
		see_buffer();
		if (zoom_flag)
			{
			draw_on_screen();
			print_one_coor(mouse_x+xoff, mouse_y+yoff);
			draw_on_buffer();
			}
		}
	}
}

get_one_coor(xoff, yoff, v)
WORD xoff, yoff;
Vector *v;
{
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
pos_cross_hairs(xoff, yoff, v);
uninit_some_tools();
}

mget_one_coor(xoff, yoff, v)
WORD xoff, yoff;
Vector *v;
{
msetup();
get_one_coor(xoff, yoff, v);
mrecover();
}

cut_clip()
{
if (define_box())
	end_vclip();
}

define_box()
{
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
pos_cross_hairs(0, 0, NULL);
if (RDN)
	{
	uninit_some_tools();
	return(0);
	}
firstx = mouse_x;
firsty = mouse_y;
swap_d_box();
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		{
		hide_mouse();
		unundo();
		swap_d_box();
		draw_frame(oppositec[0], x_0, y_0, x_1, y_1);
		if (!zoom_flag)
			print_coors_dx(firstx, firsty, mouse_x, mouse_y);
		show_mouse();
		see_buffer();
		if (zoom_flag)
			{
			draw_on_screen();
			print_coors_dx(firstx, firsty, mouse_x, mouse_y);
			draw_on_buffer();
			}
		}
	}
x_1++;
y_1++;
hide_mouse();
unundo();
uninit_some_tools();
return(1);
}

find_clip(screen)
WORD *screen;
{
register WORD *c;
register WORD i;
register WORD temp;


y_0 = 0;
y_1 = YMAX;
c = screen;

/* figure out the first line in screen with anything in it*/
i = YMAX;
while (--i >= 0)
	{
	if (!line_zero(c) )
		break;
	c += 80;
	y_0++;
	}
if (y_0 == YMAX)
	{
	return(0);
	}

/* figure out the last line in screen with anything in it*/
c = screen + 16000 - 80;	/* c points to start of last line */
i = YMAX;
while (--i >= 0)
	{
	if (!line_zero(c) )
		break;
	c -= 80;
	--y_1;
	}

i = y_1 - y_0;		/* the horizontal slice of screen with anything in it */
x_0 = XMAX;
x_1 = 0;
while (--i >= 0)
	{
	temp = first_zeros(c);
	if ((temp) < x_0)
		x_0 = (temp);
	temp = last_zeros(c);
	if ((temp) > x_1)
		x_1 = (temp);
	c -= 80;
	}
return(1);
}


clip_clip()
{
save_undo();
hide_mouse();
if (!find_clip(cscreen))
	{
	top_line("Picture's Empty!");
	show_mouse();
	return;
	}
draw_frame(oppositec[0], x_0, y_0, x_1-1, y_1-1);
maybe_zoom();
wait_a_jiffy(12);	/* delay 1/5th second so looks like doing something */
end_vclip();
maybe_zoom();
}

pop_cel()	/* show cel momentarily */
{
save_undo();
rub_paste(clipping, 0, 0);
maybe_zoom();
wait_a_jiffy(20);
see_screen_ix();
}

cfit_cel(cel)
register Cel *cel;
{
WORD i;
char *image;
WORD line_bytes;
WORD pixels16;
char *line_buf;

if (words_same(sys_cmap, cel->cmap, COLORS) )	/* if same already relax */
	{
	return(1);
	}
line_bytes = Raster_line(cel->width);
pixels16 = line_bytes>>3;
if ((line_buf = (char *)askmem(pixels16*16)) == NULL)
	{
	return(0);
	}
make_fittingc(cel->cmap);
i = cel->height;
image = (char *)cel->image;
while (--i >= 0)
	{
	conv_buf(image, line_buf, pixels16);
	xbytes(line_buf, fittingc, cel->width);
	iconv_buf(line_buf, image, pixels16);
	image += line_bytes;
	}
copy_words(sys_cmap, cel->cmap, COLORS);
freemem(line_buf);
return(1);
}

cfit_clip()
{

if (clipping == NULL)
	return;
hide_mouse();
if (!cfit_cel(clipping))
	{
	outta_memory();
	return;
	}
pop_cel();
show_mouse();
}

#ifdef SLUFFED
usec()
{
extern WORD seg_cmap[COLORS];
if (clipping == NULL)
	return;
copy_words(sys_cmap, seg_cmap, COLORS);
put_cmap(clipping->cmap);
confirm_c_many(0, COLORS-1);
redraw_menu_frame();
}

nom_usec()
{
unzoom();
usec();
rezoom();
}
#endif SLUFFED

mask_clip()
{
hide_mouse();
mask_clipping();
pop_cel();
show_mouse();
}

make_fittingc(cmap)
register WORD *cmap;
{
register char *cc;
register WORD i;

cc = fittingc;
i = 16;
if (nozero_flag)
	{
	*cc++ = 0;	/* always map color 0 to color 0 */
	cmap++;
	}
while (--i >= 0)
	*cc++ = closest_col(*cmap++, nozero_flag);
}

