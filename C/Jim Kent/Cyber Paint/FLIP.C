
#include "flicker.h"

extern Cel *rs_cel;	/* used here and in vrotate too */

hflip()
{
register WORD i, j;
WORD pixels16;
char *bap_buf;
register char *left, *right;
char *image;
WORD linebytes;
WORD width;
register char c;

if (clipping == NULL)
	return;
width = clipping->width;
pixels16 = Pixels16(width);
if ((bap_buf = (char *)askmem(pixels16<<4)) == NULL)
	{
	outta_memory();
	return;
	}
linebytes = Raster_line(width);
image = (char *)clipping->image;
i = clipping->height;
while (--i >= 0)
	{
	conv_buf(image, bap_buf, pixels16);
	left = bap_buf;
	right = bap_buf + width;
	j = width>>1;
	while (--j >= 0)
		{
		c = *left;
		*left++ = *(--right);
		*right = c;
		}
	iconv_buf(bap_buf, image, pixels16);
	image += linebytes;
	}
freemem(bap_buf);
if (clipping->mask)
	freemem(clipping->mask);
mask_cel(clipping);
}


vflip()
{
WORD i;
WORD line_bytes;
WORD h;
char *line_buf;
register char *up, *down;

if (clipping == NULL)
	return;
line_bytes = Raster_line(clipping->width);
if ((line_buf = (char *)askmem(line_bytes)) == NULL)
	{
	outta_memory();
	return;
	}
h = clipping->height;
up = (char *)clipping->image;
down = up + (long)line_bytes * (h-1);
i = (h>>1);
while (--i >= 0)
	{
	copy_words(up, line_buf, line_bytes>>1);
	copy_words(down, up, line_bytes>>1);
	copy_words(line_buf, down, line_bytes>>1);
	up += line_bytes;
	down -= line_bytes;
	}
freemem(line_buf);
if (clipping->mask)
	freemem(clipping->mask);
mask_cel(clipping);
}

see_flip()
{
hide_mouse();
unundo();
rub_paste(clipping, 0, 0);
show_mouse();
see_buffer();
}

hvflip_clip()
{
hflip();
vflip();
see_flip();
}

hflip_clip()
{
hflip();
see_flip();
}

vflip_clip()
{
vflip();
see_flip();
}

move_clip()	/* middle - don't stretch, just move */
{

for (;;)
	{
	if (!PDN)
		break;
	if (mouse_moved)
		{
		clipping->xoff += mouse_x - lastx;
		clipping->yoff += mouse_y - lasty;
		see_flip();
		}
	check_input();
	}
}


extern int stretch4();

Vector flippers[9] =
	{ hvflip_clip,  vflip_clip, hvflip_clip, hflip_clip, move_clip,
		hflip_clip, hvflip_clip, vflip_clip, hvflip_clip};


flip_clip()
{
if ((rs_cel = clipping) == NULL)
	{
	top_line("Nothing to Flip!");
	return;
	}
save_undo();
undo_to_buf();
hide_mouse();
draw_on_buffer();
see_flip();
for (;;)
	{
	if (clip_vinit())	/* on left button down move it a bit... */
		{
		if (PJSTDN)
			(*flippers[which_nine(rs_cel)])();
		}
	else
		{	/* on right button make stretch cel into clipping cel */
		wait_rup();
		break;
		}
	}
hide_mouse();
unundo();
do_paste(rs_cel, 0, 0);
uninit_some_tools();
show_mouse();
rs_cel = NULL;
dirtys();
}


