
#include "flicker.h"

extern blur_line(), edge_line(), iedge_line(), 
	life_line(), anti_line();

static Vector box_vector, box_init;

char *blbuf1, *blbuf2, *blbuf3;	/* buffers */
char *blur_out;
char need_clookup;
WORD scolor;
static WORD line_bytes;
static char *image;
static WORD width;
static WORD pixels8;
static WORD pixels16;
static Cel *cel;



static blur_cleanup()
{
gentle_free(blbuf1);
gentle_free(blbuf2);
gentle_free(blbuf3);
gentle_free(blur_out);
}

blur_setup(c)
Cel *c;
{
blbuf1 = blbuf2 = blbuf3 = blur_out = NULL;

if ((cel = c) == NULL)
	return(0);
width = cel->width;
pixels16 = (width+15)&0xfff0;
if ((blur_out = (char *)begmem(pixels16)) == NULL)
	{
	return(0);
	}
if ((blbuf1 = (char *)begmem(pixels16+2)) == NULL)
	{
	return(0);
	}
if ((blbuf2 = (char *)begmem(pixels16+2)) == NULL)
	{
	return(0);
	}
if ((blbuf3 = (char *)begmem(pixels16+2)) == NULL)
	{
	return(0);
	}
hide_mouse();
line_bytes = pixels16>>1;
pixels8 = line_bytes+1;
pixels16 >>= 4;

image = (char *)c->image;
}

do_one_blur()
{
WORD i;

if (box_init != NULL)
	{
	if (!(*box_init)())
		return;
	}
if (need_clookup)
	make_clookup();
word_zero(blur_out, pixels16/sizeof(WORD) );
/* set up the first 3 lines */
conv_buf(image, blbuf1+1, pixels16);
blbuf1[0] = blbuf1[1];
blbuf1[width+1] = blbuf1[width];
copy_words(blbuf1,blbuf2,pixels8);	/* second line starts out 
									(just a boundary condition) copy of 1st */
conv_buf(image+line_bytes, blbuf3+1, pixels16);
blbuf3[0] = blbuf3[1];
blbuf3[width+1] = blbuf3[width];
i = cel->height;
while (--i >= 0)
	{
	(*box_vector)(width);
	iconv_buf(blur_out, image, pixels16);
	image += line_bytes;
	copy_words(blbuf2,blbuf1,pixels8);
	copy_words(blbuf3,blbuf2,pixels8);
	if (i > 1)	/* last line reuse blbuf3 */
		{
		conv_buf(image+line_bytes, blbuf3+1, pixels16);
		blbuf3[0] = blbuf3[1];
		blbuf3[width+1] = blbuf3[width];
		}
	}
}

multi_blur_func()
{
image = (char *)cscreen;
do_one_blur();
return(1);
}

#ifdef SLUFFED
blur_clip()
{
if (!blur_setup(clipping))
	{
	blur_cleanup();
	return;
	}

do_one_blur();

blur_cleanup();
gentle_free(cel->mask);
mask_cel(cel);
show_mouse();
pop_cel();
}
#endif SLUFFED

box_filter()
{
screen_cel.image = cscreen;
if (blur_setup(&screen_cel))
	{
	if (select_mode == 0)
		{
		copy_screen(cscreen, uscreen); /* save undo */
		multi_blur_func();
		dirtys();
		}
	else
		qdo_many(multi_blur_func, 0);
	}
blur_cleanup();
show_mouse();
maybe_see_buffer();
}

blur_frame()
{
need_clookup = 1;
box_vector = blur_line;
box_filter();
}

mblur_frame()
{
msetup();
blur_frame();
mrecover();
}

edge_frame()
{
need_clookup = 0;
box_vector = edge_line;
box_filter();
}

medge_frame()
{
msetup();
edge_frame();
mrecover();
}


iedge_frame()
{
need_clookup = 0;
wait_ednkey();
if (PJSTDN)
	{
	hide_mouse();
	scolor = getdot(mouse_x, mouse_y);
	box_vector = iedge_line;
	box_filter();
	}
}

miedge_frame()
{
msetup();
iedge_frame();
mrecover();
}

extern WORD many_direction;

static char crys_first;

crys_copy()
{
WORD result;

if (!tween_mode)
	return(1);
result = 1;
if (crys_first != 0)
	{
	if (many_direction > 0)
		copy_screen(prev_screen, cscreen);
	else
		copy_screen(next_screen, cscreen);
	}
else
	{
	if (select_mode != 0)	/* not frames */
		result = 0;
	}
crys_first = 1;
return(result);
}


crystalize()
{
crys_first = 0;
need_clookup = 0;
box_init = crys_copy;
box_vector = life_line;
box_filter();
box_init = NULL;
}

mcrystalize()
{
msetup();
crystalize();
mrecover();
}


anti_frame()
{
need_clookup = 1;
box_vector = anti_line;
box_filter();
}

manti_frame()
{
msetup();
anti_frame();
mrecover();
}

