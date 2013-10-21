#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <define.h>
#include <string.h>
#include <linea.h>

#include "vdi_font.h"

extern int vdi_handle;

extern OBJECT *font_back; 							/* Pointer auf Objektb„ume */
extern int bx, by; 											/* Position der Editorbox */
extern int hs, ws; 											/* Gr”že eines Editpunktes */
extern unsigned long s_buf[96][3]; 			/* Arbeitsbereich */
extern int f_row;
extern int f_col;									

/* ------------------------ */
/* | Eine Zeile nach oben | */
/* ------------------------ */
one_up()
{
unsigned long z[3], w;
register int i;
register unsigned long zw;
MFDB src, des;
int xy[8];

bcopy(s_buf[0], z, 12);
for (i = 0; i < 95; i++)
	bcopy(s_buf[i + 1], s_buf[i], 12);

bcopy(z, s_buf[95], 12);

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

show_character();
}

/* ------------------------- */
/* | Eine Zeile nach unten | */
/* ------------------------- */
one_dwn()
{
register unsigned long zw;
register int i;
MFDB src, des;
int xy[8];
unsigned long z[3], w;

bcopy(s_buf[95], z, 12);
for (i = 95; i > 0; i--)
	bcopy(s_buf[i - 1], s_buf[i], 12);

bcopy(z, s_buf[0], 12);

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

show_character();
}

/* -------------------------- */
/* | Eine Spalte nach links | */
/* -------------------------- */
one_lft()
{
register unsigned long zw;
register int i;
MFDB src, des;
int xy[8];

for (i = 95; i >= 0; i--)
	{
	zw = s_buf[i][0];
	s_buf[i][0] <<= 1;
	s_buf[i][0] |= s_buf[i][1] >> 31L;

	s_buf[i][1] <<= 1;
	s_buf[i][1] |= s_buf[i][2] >> 31L;
	
	s_buf[i][2] <<= 1;
	s_buf[i][2] |= zw >> 31L;
	}

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

	if (s_buf[f_row + i][0] & 1)
		vsf_interior(vdi_handle, 1);
	else
		vsf_interior(vdi_handle, 0);

	v_bar(vdi_handle, xy);
	}

show_character();
}

/* --------------------------- */
/* | Eine Spalte nach rechts | */
/* --------------------------- */
one_rgt()
{
register unsigned long zw;
register int i;
MFDB src, des;
int xy[8];

for (i = 95; i >= 0; i--)
	{
	zw = s_buf[i][2];
	s_buf[i][2] >>= 1;
	s_buf[i][2] |= s_buf[i][1] << 31L;

	s_buf[i][1] >>= 1;
	s_buf[i][1] |= s_buf[i][0] << 31L;
	
	s_buf[i][0] >>= 1;
	s_buf[i][0] |= zw << 31L;
	}

src.fd_addr = 0L;
src.fd_stand = 1;

des.fd_addr = 0L;
des.fd_stand = 1;

xy[0] = bx;
xy[4] = bx + ws;
xy[1] = xy[5] = by;
xy[6] = xy[4] + font_back[F_BKG].ob_width - ws;
xy[7] = xy[5] + font_back[F_BKG].ob_height;
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

	if (s_buf[f_row + i][0] & 0x80000000L)
		vsf_interior(vdi_handle, 1);
	else
		vsf_interior(vdi_handle, 0);

	v_bar(vdi_handle, xy);
	}

show_character();
}

/* ----------------------- */
/* | Horizontal spiegeln | */
/* ----------------------- */
h_flip()
{
register unsigned long zw;
register int i, j;

for (i = 0; i < 48; i++)
	for (j = 0; j < 3; j++)
		{
		zw = s_buf[i][j];
		s_buf[i][j] = s_buf[95 - i][j];
		s_buf[95 - i][j] = zw;
		}

show_character();
draw_edit();
}

/* --------------------- */
/* | Vertikal spiegeln | */
/* --------------------- */
v_flip()
{
register unsigned long zw1, zw2;
register int i, j, k;

for (i = 0; i < 96; i++)
	{
	zw1 = s_buf[i][0];
	s_buf[i][0] = s_buf[i][2];
	s_buf[i][2] = zw1;
	
	for (k = 0; k < 3; k++)
		{
		zw1 = s_buf[i][k];
		zw2 = 0;

		for (j = 0; j < 32; j++)
			{
			zw2 <<= 1;

			if (zw1 & 1)
				zw2 |= 1;
	
			zw1 >>= 1;
			}

		s_buf[i][k] = zw2;
		}
	}

show_character();
draw_edit();
}

/* -------------- */
/* | Halbe H”he | */
/* -------------- */
half_height()
{
register int i;

for (i = 0; i < 48; i++)
	bcopy(s_buf[i * 2], s_buf[i], sizeof(s_buf[0]));

for (i = 48; i < 96; bzero(s_buf[i++], sizeof(s_buf[0])));

show_character();
draw_edit();
}

/* ----------------- */
/* | Doppelte H”he | */
/* ----------------- */
double_height()
{
register int i;

for (i = 95; i >= 0; i--)
	bcopy(s_buf[i / 2], s_buf[i], sizeof(s_buf[0]));

show_character();
draw_edit();
}

/* ---------------- */
/* | Halbe Breite | */
/* ---------------- */
half_width()
{
register int i, j, k;
register long zw1, zw2;

for (i = 0; i < 96; i++)
	{
	for (k = 0; k < 3; k++)
		{
		zw1 = s_buf[i][k];
		zw2 = 0;
		
		for (j = 0; j < 16; j++)
			{
			zw2 <<= 1;
			if (zw1 & 0xC0000000)
				zw2 |= 1;

			zw1 <<= 2;
			}
			
		s_buf[i][k] = zw2;
		}

	s_buf[i][0] <<= 16;
	s_buf[i][0] |= s_buf[i][1]; 
	s_buf[i][1] = s_buf[i][2] << 16;

	s_buf[i][2] = 0;
	}

show_character();
draw_edit();
}

/* ------------------- */
/* | Doppelte Breite | */
/* ------------------- */
double_width()
{
register int i, j, k;
register long zw1, zw2;

for (i = 0; i < 96; i++)
	{
	s_buf[i][2] = s_buf[i][1] >> 16;
	s_buf[i][1] = s_buf[i][0];
	s_buf[i][0] >>= 16;
	
	for (k = 0; k < 3; k++)
		{
		zw1 = s_buf[i][k];
		zw2 = 0;
		
		for (j = 0; j < 16; j++)
			{
			zw2 <<= 2;
			if (zw1 & 0x8000)
				zw2 |= 3;

			zw1 <<= 1;
			}
			
		s_buf[i][k] = zw2;
		}
	}
	
show_character();
draw_edit();
}

