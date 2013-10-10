

#include "flicker.h"
#include "flicmenu.h"

extern struct range csegment;

char ttable[COLORS];

sep_funct()
{
WORD i;
register char *image;

image = (char *)cscreen;
i = YMAX;
while (--i >= 0)
	{
	conv_buf(image, bap_line_buf, 20);
	xbytes(bap_line_buf, ttable, 320);
	iconv_buf(bap_line_buf, image, 20);
	image += 160;
	}
return(1);
}

mcolor_separate()
{
msetup();
color_separate();
mrecover();
}

mseparate_many()
{
msetup();
separate_many();
mrecover();
}

zwait_click()
{
for (;;)
	{
	check_input();
	update_zoom();
	if (key_hit || PJSTDN || RJSTDN)
		break;
	}
}

separate_many()
{
WORD v1, v2;
register WORD i;
register char *image;

save_undo();
hide_mouse();
if (csegment.v1 <= csegment.v2)
	{
	v1 = csegment.v1;
	v2 = csegment.v2;
	}
else
	{
	v1 = csegment.v2;
	v2 = csegment.v1;
	}
image = ttable;
for (i=0; i<16; i++)
	image[i] = i;
for (i=v1; i<=v2; i++)
	image[i] = ccolor;
finish_sep();
}

color_separate()
{
register WORD i;
register char *image;

zwait_click();
if (!PJSTDN)
	return;
save_undo();
hide_mouse();
image = ttable;
for (i=0; i<16; i++)
	image[i] = i;
ttable[getdot(mouse_x, mouse_y)] = ccolor;
finish_sep();
}

finish_sep()
{
if (select_mode != 0)
	{
	qdo_many(sep_funct, 0);
	}
else
	{
	sep_funct();
	show_mouse();
	update_zoom();
	dirtys();
	}
}
