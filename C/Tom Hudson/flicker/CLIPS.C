
#include "flicker.h"


char bap_line_buf[320];	/* byte-a-pixel line buffer */
char fittingc[16];	/* best fit lookup */

Cel *clipping = NULL;

Cel *
alloc_cel(w, h)
register WORD w, h;
{
register Cel *cel;

if ((cel = Alloc_a(Cel)) == NULL)
	return(NULL);
cel->image_size = Raster_block(w, h);
if ( mem_free - cel->image_size - (cel->image_size>>2) < 8000 ||
	(cel->image = (WORD *)alloc(cel->image_size)) == NULL)
	{
	Free_a(cel);
	return(NULL);
	}
cel->width = w;
cel->height = h;
cel->mask = NULL;
return(cel);
}

free_cel(cel)
register Cel *cel;
{
if (cel == NULL)
	return;
mfree(cel->image, cel->image_size);
if (cel->mask)
	mfree(cel->mask, cel->image_size>>2);
Free_a(cel);
}

mask_cel(cel)
register Cel *cel;
{
if ((cel->mask = (WORD *)alloc(cel->image_size>>2)) == NULL)
	return(0);
calc_mask(cel->image, cel->mask, cel->image_size>>3);
return(1);
}

do_paste(x, y)
WORD x, y;
{
if (nozero_flag)
	nozero_celblit(x, y, clipping);
else
	copy_celblit(x, y, clipping);
}

rub_paste(x, y)
register WORD x, y;
{
do_paste(x, y);
x += clipping->xoff;
y += clipping->yoff;
draw_frame(white, x, y, x+clipping->width-1, y+clipping->height-1);
}

clip_vinit()
{
for (;;)
	{
	check_input();
	see_buffer();
	if (EDN)
		break;
	}
firstx = mouse_x;
firsty = mouse_y;
return(PDN);
}


paste_clip()
{
register Cel *cel;

if ((cel = clipping) == NULL)
	{
	top_line("Nothing to Paste!");
	return;
	}
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
rub_paste(0, 0);
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
			rub_paste(mouse_x - firstx, mouse_y - firsty);
			show_mouse();
			see_buffer();
			}
		check_input();
		}
	cel->xoff += mouse_x - firstx;
	cel->yoff += mouse_y - firsty;
	}
hide_mouse();
unundo();
do_paste(0, 0);
show_mouse();
see_buffer();
uninit_some_tools();
}

end_vclip()
{
register Cel *cel;

free_cel(clipping);
if ((cel = clipping = alloc_cel(x_1 - x_0, y_1 - y_0)) == NULL)
	{
	outta_memory();
	return;
	}
cel->xoff = x_0;
cel->yoff = y_0;
hide_mouse();
unundo();
clip_from_screen(cel, cscreen);
if (!mask_cel(cel))
	{
	outta_memory();
	free_cel(cel);
	clipping = NULL;
	}
show_mouse();
}

cut_clip()
{
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
lines_cursor();
see_buffer();
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
		lines_cursor();
		see_buffer();
		}
	}
if (RDN)
	{
	uninit_some_tools();
	return;
	}
firstx = mouse_x;
firsty = mouse_y;
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
		draw_frame(white, x_0, y_0, x_1, y_1);
		show_mouse();
		see_buffer();
		}
	}
x_1++;
y_1++;
end_vclip();
uninit_some_tools();
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
draw_frame(white, x_0, y_0, x_1-1, y_1-1);
maybe_zoom();
wait_a_jiffy(12);	/* delay 1/5th second so looks like doing something */
end_vclip();
maybe_zoom();
}

pop_cel()	/* show cel momentarily */
{
save_undo();
rub_paste(0, 0);
maybe_zoom();
wait_a_jiffy(20);
see_screen_ix();
}


cfit_clip()
{
WORD i;
char *image;
WORD line_bytes;
WORD pixels16;
register Cel *cel;

if ((cel = clipping) == NULL)
	return;
hide_mouse();
make_fittingc(cel->cmap);
line_bytes = Raster_line(cel->width);
pixels16 = line_bytes>>3;
i = cel->height;
image = (char *)cel->image;
while (--i >= 0)
	{
	conv_buf(image, bap_line_buf, pixels16);
	xbytes(bap_line_buf, fittingc, cel->width);
	iconv_buf(bap_line_buf, image, pixels16);
	image += line_bytes;
	}
show_mouse();
copy_words(sys_cmap, cel->cmap, COLORS);
pop_cel();
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

