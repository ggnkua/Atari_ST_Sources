
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\menu.h"
#include "..\\include\\font.h"
#include "..\\include\\io.h"
#include "..\\include\\format.h"
#include "..\\include\\digitgau.h"
#include "..\\include\\cursor.h"


extern struct cursor up_arrow_cursor, dwn_arrow_cursor;
extern struct rast_font sail_font;

see_digit_gauge( m, s, color)
struct menu *m;
struct selection *s;
int color;
{
	register struct digit_gauge *digit_gauge;
	WORD cenx, ceny;
	WORD digit_width;
	WORD scr2, scr1;
	register  WORD i;
	WORD div;
	char *dig_format = "%3d";
	register char *str;

	cenx = m_sel_cenx(m, s);
	ceny = m_sel_ceny(m, s);
	digit_gauge = (struct digit_gauge*) s->display_data;
	digit_width = digit_gauge->digits * DIGIT_WIDTH;


	scr1 = cenx - (digit_width>>1);
	scr2 = ceny - (DIGIT_HEIGHT>>1);
	draw_frame(color,
	scr1 - 2, scr2 - 1,
	digit_width + scr1 + 1, DIGIT_HEIGHT + scr2 - 1);


	dig_format[1] = digit_gauge->digits + '0';
	str = clone_string(lsprintf(dig_format, digit_gauge->value) );
	tr_string(str, ' ', '0');
	for (i=0; i<digit_gauge->digits; i++)
	{
	show_cursor(&up_arrow_cursor,
		scr1 + DIGIT_WIDTH/2,
		scr2 - 3,
		color);
	show_cursor(&dwn_arrow_cursor,
		scr1 + DIGIT_WIDTH/2,
		scr2 +DIGIT_HEIGHT + 3,
		color);
	show_char(&sail_font, str[i], 
		scr1+1, scr2, color);
	scr1 += DIGIT_WIDTH;
	}
	free_string(str);
}

do_digit_gauge(m, s, vis)
struct menu *m;
struct selection *s;
struct virtual_input *vis;
{
	struct digit_gauge *cur_value = (struct digit_gauge*)s->function_data;
	WORD cenx, ceny;
	WORD scr1;
	int base;
	WORD i, x, y;

	cenx = m_sel_cenx(m, s);
	ceny = m_sel_ceny(m, s);
	x = vis->curx;
	y = vis->cury;
	scr1 = cenx - ((DIGIT_WIDTH * cur_value->digits)>>1) + DIGIT_WIDTH;

	i = cur_value->digits-1;
	base = 1;
	while (--i >= 0)
	base *= 10;

	i = cur_value->digits;
	while (--i >= 0)
	{
	if ( x < scr1)
		{
		if ( y < ceny) 
		cur_value->value += base;
		else
		cur_value->value -= base;
		break;
		}
	base/=10;
	scr1 += DIGIT_WIDTH;
	}
	if (cur_value->value< cur_value->min)
	cur_value->value =  cur_value->min;
	if (cur_value->value > cur_value->max)
	cur_value->value = cur_value->max;
}

