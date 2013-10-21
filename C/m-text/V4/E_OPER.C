#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <define.h>
#include <string.h>
#include <linea.h>

#include "vdi_font.h"

extern int vdi_handle;

extern OBJECT *font_back; 							/* Pointer auf Objektb„ume */
extern int fx, fy, fw, fh; 							/* Koordinaten des Hintergrundes */
extern int bx, by; 											/* Position der Editorbox */
extern int hs, ws; 											/* Gr”že eines Editpunktes */
extern unsigned long s_buf[96][3]; 			/* Arbeitsbereich */
extern int f_row;
extern int f_col;									
extern int s_pwidth; 										/* Breite des Zeichen im Arbeitsb. */
extern int mousex, mousey; 							/* mousex, mousey */

/* -------------------------- */
/* | Editorbereich zeichnen | */
/* -------------------------- */
draw_edit()
{
int xy[4];
register int r, s, x;
register unsigned long b;
unsigned long w;

hide_mouse();

vsf_interior(vdi_handle, 1);
vswr_mode(vdi_handle, 1);

objc_draw(font_back, F_BKG, MAX_DEPTH, fx, fy, fw, fh);

xy[0] = xy[2] = bx;
xy[1] = by;
xy[3] = by + font_back[F_BKG].ob_height;

for (r = 0; r < 32; r++)
	{
	v_pline(vdi_handle, 2, xy);
	xy[0] += ws;
	xy[2] += ws;
	}

xy[0] = bx;
xy[2] = bx + font_back[F_BKG].ob_width;
xy[1] = by;
xy[3] = by;
for (r = 0; r < 32; r++)
	{
	v_pline(vdi_handle, 2, xy);
	xy[1] += hs;
	xy[3] += hs;
	}

for (r = 0; r < 32; r++)
	{
	xy[0] = bx;
	xy[1] = by + r * hs;
	xy[2] = xy[0] + ws;
	xy[3] = xy[1] + hs;

	get_bits(s_buf[r + f_row], &w, 32, f_col);

	for (b = 0x80000000; b > 0; b /= 2)
		{
		if (w & b)
			v_bar(vdi_handle, xy);

		xy[0] += ws;
		xy[2] += ws;
		}
	}

set_linemarker();

show_mouse();
}

/* -------------------------- */
/* | Punkt im Font zeichnen | */
/* -------------------------- */
draw_fpoint()
{
int mousek, dummy;
int x, y, xy[4], xa, ya, pel, index;
register int b;
register unsigned long bit;

xa = mousex - bx;
xa /= ws;
ya = mousey - by;
ya /= hs;

xy[0] = bx + xa * ws;
xy[1] = by + ya * hs;
xy[2] = xy[0] + ws;
xy[3] = xy[1] + hs;
hide_mouse();
v_get_pixel(vdi_handle, xy[0] + (ws >> 1), xy[1] + (hs >> 1), &pel, &index);

vswr_mode(vdi_handle, 1);

if (pel == 1)
	b = 0;
else
	b = 1;

vsf_interior(vdi_handle, b);

v_bar(vdi_handle, xy);
show_mouse();

if (!b)
	set_bits(s_buf[ya + f_row], 0L, 1, xa + f_col);
else
	set_bits(s_buf[ya + f_row], 0x80000000L, 1, xa + f_col);

if (f_col + xa + 1 > s_pwidth && b)
	{
	s_pwidth = xa + 1;
	set_scale();
	}

do
	{
	graf_mkstate(&mousex, &mousey, &mousek, &dummy);

	x = mousex - bx;
	x /= ws;
	y = mousey - by;
	y /= hs;

	if (x >= 0 && x < 32 && y >= 0 && y < 32 && mousek == 1)
		if (x != xa || y != ya)
			{
			xy[0] = bx + x * ws;
			xy[1] = by + y * hs;
			xy[2] = xy[0] + ws;
			xy[3] = xy[1] + hs;

			hide_mouse();
			v_bar(vdi_handle, xy);
			show_mouse();

			if (!b)
				set_bits(s_buf[y + f_row], 0L, 1, x + f_col);
			else
				set_bits(s_buf[y + f_row], 0x80000000L, 1, x + f_col);

			xa = x;
			ya = y;

			if (x + 1 > s_pwidth && b)
				{
				s_pwidth = x + 1;
				set_scale();
				}
			}

	}while(mousek == 1);

show_character();
}

/* -------------------------- */
/* | Editorzeile nach unten | */
/* -------------------------- */
edit_dwn()
{
register int i;
register unsigned long zw;
MFDB src, des;
int xy[8];
unsigned long w;

if (f_row < 64)
	{
	f_row++;

	set_linemarker();
	
	src.fd_addr = 0L;
	src.fd_stand = 1;
	
	des.fd_addr = 0L;
	des.fd_stand = 1;
	
	xy[0] = xy[4] = bx;
	xy[6] = xy[2] = xy[0] + font_back[F_BKG].ob_width;
	
	xy[1] = by + hs;
	xy[3] = xy[1] + font_back[F_BKG].ob_height - hs;
	xy[5] = by;
	xy[7] = xy[3] - hs;
	
	hide_mouse();
	Vsync();
	vro_cpyfm(vdi_handle, 3, xy, &src, &des);
	show_mouse();
	
	vswr_mode(vdi_handle, 1);
	
	xy[1] = by + 31 * hs;
	xy[3] = xy[1] + hs;
	xy[0] = bx;
	xy[2] = bx + ws;

	get_bits(s_buf[f_row + 31], &w, 32, f_col);
	for (zw = 0x80000000; zw > 0; zw /= 2)
		{
		if (w & zw)
			vsf_interior(vdi_handle, 1);
		else
			vsf_interior(vdi_handle, 0);
	
		v_bar(vdi_handle, xy);
	
		xy[0] += ws;
		xy[2] += ws;
		}
	}
}

/* ------------------------- */
/* | Editorzeile nach oben | */
/* ------------------------- */
edit_up()
{
register unsigned long zw;
register int i;
MFDB src, des;
int xy[8];
unsigned long w;

if (f_row)
	{
	f_row--;
	
	set_linemarker();

	src.fd_addr = 0L;
	src.fd_stand = 1;
	
	des.fd_addr = 0L;
	des.fd_stand = 1;
	
	xy[0] = xy[4] = bx;
	xy[6] = xy[2] = xy[0] + font_back[F_BKG].ob_width;
	
	xy[1] = by;
	xy[3] = xy[1] + font_back[F_BKG].ob_height - hs;
	xy[5] = by + ws;
	xy[7] = xy[3] + hs;
	
	hide_mouse();
	Vsync();
	vro_cpyfm(vdi_handle, 3, xy, &src, &des);
	show_mouse();
	
	vswr_mode(vdi_handle, 1);
	
	xy[1] = by;
	xy[3] = xy[1] + hs;
	xy[0] = bx;
	xy[2] = bx + ws;

	get_bits(s_buf[f_row], &w, 32, f_col);
	for (zw = 0x80000000; zw > 0; zw /= 2)
		{
		if (w & zw)
			vsf_interior(vdi_handle, 1);
		else
			vsf_interior(vdi_handle, 0);
	
		v_bar(vdi_handle, xy);
	
		xy[0] += ws;
		xy[2] += ws;
		}
	}
}

/* --------------------------- */
/* | Editorspalte nach links | */
/* --------------------------- */
edit_rgt()
{
unsigned int zw;
register int i;
MFDB src, des;
int xy[8];

if (f_col < 64)
	{
	f_col++;

	set_scale();
		
	src.fd_addr = 0L;
	src.fd_stand = 1;
	
	des.fd_addr = 0L;
	des.fd_stand = 1;
	
	xy[0] = bx + ws;
	xy[5] = xy[1] = by;
	xy[2] = xy[0] + font_back[F_BKG].ob_width - ws;
	xy[3] = xy[1] + font_back[F_BKG].ob_height;
	xy[4] = bx;
	xy[6] = xy[2] - ws;
	xy[7] = xy[3];
	
	hide_mouse();
	Vsync();
	vro_cpyfm(vdi_handle, 3, xy, &src, &des);
	show_mouse();
	
	vswr_mode(vdi_handle, 1);
	
	xy[0] = bx + 31 * ws;
	xy[2] = xy[0] + ws;
	for (i = 0; i < 32; i++)
		{
		xy[1] = by + i * hs;
		xy[3] = xy[1] + hs;
	
		get_bits(s_buf[f_row + i], &zw, 1, f_col + 31);
		if (zw)
			vsf_interior(vdi_handle, 1);
		else
			vsf_interior(vdi_handle, 0);
	
		v_bar(vdi_handle, xy);
		}
	}
}

/* ---------------------------- */
/* | Editorspalte nach rechts | */
/* ---------------------------- */
edit_lft()
{
unsigned int zw;
register int i;
MFDB src, des;
int xy[8];

if (f_col > 0)
	{
	f_col--;

	set_scale();
		
	src.fd_addr = 0L;
	src.fd_stand = 1;
	
	des.fd_addr = 0L;
	des.fd_stand = 1;
	
	xy[0] = bx;
	xy[4] = bx + ws;
	xy[1] = xy[5] = by;
	xy[6] = bx + font_back[F_BKG].ob_width;
	xy[7] = by + font_back[F_BKG].ob_height;
	xy[2] = xy[6] - ws;
	xy[3] = xy[7];
	
	hide_mouse();
	Vsync();
	vro_cpyfm(vdi_handle, 3, xy, &src, &des);
	show_mouse();
	
	vswr_mode(vdi_handle, 1);
	
	xy[0] = bx;
	xy[2] = xy[0] + ws;
	for (i = 0; i < 32; i++)
		{
		xy[1] = by + i * hs;
		xy[3] = xy[1] + hs;
	
		get_bits(s_buf[f_row + i], &zw, 1, f_col);
		if (zw)
			vsf_interior(vdi_handle, 1);
		else
			vsf_interior(vdi_handle, 0);
	
		v_bar(vdi_handle, xy);
		}
	}
}

