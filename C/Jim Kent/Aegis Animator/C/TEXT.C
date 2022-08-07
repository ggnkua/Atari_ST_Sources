
overlay "find"

#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\font.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\clip.h"
#include "..\\include\\animath.h"
#include "..\\include\\color.h"
#include "..\\include\\io.h"  /*for vtext*/
#include "..\\include\\cursor.h"
#ifdef SUN
#include <std..\\include\\io.h>
#endif SUN



struct vterm 
	{
	WORD vt_cur_x, vt_cur_y;
	WORD vt_color;
	struct rast_font vt_font;
	Square vt_sq;
	int vt_cur_char;
	int vt_cur_line;
	char *vt_char_image;
	WORD vt_lines_in_screen;
	};


Square vt_sq;
static struct rast_font v_font;
static int vt_color;
static WORD cursor_x, cursor_y;
static int vt_cur_char;
static int vt_cur_line;
static WORD lines_in_screen;

init_vterm(sq,pen_color,font)
Square *sq;
struct rast_font *font;
int pen_color;
{
WORD i;

copy_structure(sq, &vt_sq, sizeof(Square) );
copy_structure(font, &v_font, sizeof(struct rast_font) );

lines_in_screen = (sq->Y - sq->y)/CHAR_HEIGHT;

cursor_x = sq->x;
cursor_y = sq->y;
vt_cur_char = 0;
vt_cur_line = 0;
vt_color = pen_color;
}

#ifdef LATER
abt_ani_function(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
gen_help_function(m, sel, vis, abt_ani_string);
}
#endif LATER

#ifdef SLUFFED
gen_help_function(m, sel, vis, string)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
register char *string;
{
extern struct rast_font sail_font;
extern Square terminal_square;
register char c;

init_vterm(&terminal_square, 1, &sail_font);
colblock(0, vt_sq.x, vt_sq.y, vt_sq.X, vt_sq.Y);
while ( c = *string++)
	printer_emulator(c);
for (;;)
	{
	vis = await_input(USE_CURSOR);
	if (vis->result & CANCEL)
		break;
	if (vis->result & MENUPICKED)
		{
		reuse_input();
		break;
		}
	}
draw_cur_frame(m);
}
#endif SLUFFED
	


#ifdef SLUFFED
typedef int picture;
scroll_vterm()
{
extern picture *cur_pix;

if ( lines_in_screen > 1) 
	vanilla_copy(
		cur_pix, vt_sq.x, vt_sq.y+CHAR_HEIGHT,
		cur_pix, vt_sq.x, vt_sq.y,
		vt_sq.X - vt_sq.x, CHAR_HEIGHT*(lines_in_screen-1) );
colblock(0, vt_sq.x, vt_sq.y + CHAR_HEIGHT*(lines_in_screen-1),
	vt_sq.X, vt_sq.Y);
}
#endif SLUFFED


#ifdef SLUFFED
printer_emulator(c)
char c;
{
static WORD escaped = 0;
register Square *square = &vt_sq;

if (cursor_x >= square->X - CHAR_WIDTH) /*at end of line wrap around*/
	{
	cursor_x = square->x;
	vt_cur_char = 0;
	cursor_y += CHAR_HEIGHT;
	vt_cur_line++;
	if (vt_cur_line >= lines_in_screen) /* if past bottom scroll line*/
		{
		cursor_y -= CHAR_HEIGHT;
		scroll_vterm();
		--vt_cur_line;
		}
	}
switch(c)
	{
	case '\n':
	case '\r':
		cursor_x = square->x;
		cursor_y += CHAR_HEIGHT;
		vt_cur_line++;
		if (vt_cur_line >= lines_in_screen) /* if past bottom scroll line*/
			{
			cursor_y -= CHAR_HEIGHT;
			scroll_vterm();
			--vt_cur_line;
			}
		break;
	case '\t':
		cursor_x += 5*CHAR_WIDTH;
		break;
	case '\b':
		cursor_x -= CHAR_WIDTH;
		break;
	default:
		cursor_x += 
		show_char(&v_font, c, cursor_x, cursor_y, vt_color);
		break;
	}
}
#endif SLUFFED


WORD help_on = 1;

show_help(string)
char *string;
{
if (help_on)
	bottom_line(string);
}

