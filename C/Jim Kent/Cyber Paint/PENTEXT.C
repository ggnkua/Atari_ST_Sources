
#include "flicker.h"


extern WORD ch_width, ch_height, cl_width, cl_height;
extern WORD cfont_prop;

static WORD tlastx, tlasty;
static WORD linestart;
static char line_buf[200];
static WORD ccount;
extern WORD properly;	/* proportional? What a wooly */


erase_char(x, y)
WORD x, y;
{
extern WORD italic_mode;
WORD w;
WORD height, ystart;

w = cl_width;
if (italic_mode)
	w += cl_height/2;
/* clip the y coordinate... */
height = cl_height;
ystart = y;
if (ystart < 0)
	{
	height += ystart;
	ystart = 0;
	if (height <= 0)
		return;
	}
if (ystart >= YMAX)
	{
	return;
	}
if (ystart + height > YMAX)
	{
	height = YMAX-ystart;
	}

if (properly)
	{
	copy_lines((char *)uscreen + ystart*Raster_line(320),
		(char *)cscreen + ystart*Raster_line(320),
		height);
	v_gtext(handle, linestart, y+ch_height, line_buf);
	}
else
	{
	copy_blit(w, cl_height, 
		x, y, uscreen, Raster_line(320), 
		x, y, cscreen, Raster_line(320));
	}
}

WORD *tcurs_back;

erase_tcursor()
{
copy_blit(cl_width, cl_height,
	0, 0, tcurs_back, Raster_line(cl_width),
	tlastx, tlasty, cscreen, Raster_line(320));
}


draw_tcursor(x, y)
WORD x, y;
{
WORD x2, y2;

tlastx = x2 = x;
tlasty = y2 = y;
x2 += cl_width-1;
y2 += cl_height-1;
copy_blit(cl_width, cl_height,
	x, y, cscreen, Raster_line(320),
	0, 0, tcurs_back, Raster_line(cl_width));
draw_frame(black, x+1, y+1, x2-1, y2-1);
draw_frame(white, x, y, x2, y2);
}


pen_text()
{
char *name, **names;
WORD dx, dy, x, y;
static char cbuf[2];
WORD extent[8];
extern WORD ch_width;
extern WORD ch_height;
extern WORD cl_width;
extern WORD cl_height;
extern WORD screen_bounds[];
char key;

properly = (cfont_prop || italic_mode); /* backspace == line redraw?? */
ccount = 0;
line_buf[0] = 0;
setup_text();
vs_clip(handle, 1, screen_bounds);
if ((tcurs_back = begmem(Raster_block(cl_width, cl_height))) == NULL)
	return;
vst_color(handle, gemctable[ccolor]);
vswr_mode(handle, 2);
linestart = firstx = x = mouse_x;
y = mouse_y - ch_height;
save_undo();
hide_mouse();
draw_tcursor(x, y);
update_zoom();
for (;;)
	{
	check_input();
	key = key_in;	/* ascii part */
	if (RJSTDN || key_hit && (key==0x1b) )
		break;
	if (key_hit)
		{
		erase_tcursor();
		switch (key)
			{
			case 0:
				break;
			case '\r':
			case '\n':
				linestart = x = firstx;
				y += cl_height;
				ccount = 0;
				line_buf[0] = 0;
				break;
			case '\b':
				if (cycle_draw)
					uncycle_ccolor();
				if (cfont_prop && ccount > 0)
					{
					vqt_extent(handle, line_buf+ccount-1, extent);
					x -= extent[2];
					}
				else
					x -= cl_width;
				if (x < linestart)
					linestart = x;
				if (ccount > 0)
					line_buf[--ccount] = 0;
				erase_char(x, y);
				break;
			default:
				if (ccount < sizeof(line_buf) - 1)
					{
					if (cycle_draw)
						{
						cycle_ccolor();
						vst_color(handle, gemctable[ccolor]);
						}
					line_buf[ccount] = key_in;
					line_buf[ccount+1] = 0;
					if (properly)
						{
						v_gtext(handle, linestart, y+ch_height, line_buf);
						}
					else
						v_gtext(handle, x, y+ch_height, line_buf+ccount);
					if (cfont_prop)
						{
						vqt_extent(handle, line_buf+ccount, extent);
						x += extent[2];
						}
					else
						x += cl_width;
					ccount += 1;
					}
				break;
			}
		draw_tcursor(x, y);
		maybe_zoom();
		}
	}
erase_tcursor();
freemem(tcurs_back);
update_zoom();
unset_text();
}

