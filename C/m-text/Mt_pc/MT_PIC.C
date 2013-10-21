#include "extern.h"

/* --------------- */
/* | Bild suchen | */
/* --------------- */
unsigned char *search_pic(int *height, int *width, int *y)
{
extern unsigned char *go_back();

register unsigned char *l_adr, *l_beg, *pic_a;
register int cl;

get_work(w_handles[akt_id]);

y[0] = wy + ruler_flag * 16;

l_adr = txt_start[akt_id] + text_pos[akt_id];
while(l_adr < txt_start[akt_id] + txt_lens[akt_id])
	{
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	l_beg = l_adr + 5 + note_len(l_adr);
	do
		{
		if (*l_beg == 0x18)
			{
			pic_a = (unsigned char *)(((long)*(l_beg + 2) << 16) | ((long)*(l_beg + 3) << 8) | (long)*(l_beg + 4));
			width[0] 	= ((int)*pic_a << 8)	| *(pic_a + 1);
			height[0] 	= ((int)*(pic_a + 2) << 8) | *(pic_a + 3);

			if (mousey > y[0] && mousey < y[0] + height[0] && mousex > wx + ((int)*(l_beg + 5) << 3) && mousex < wx + ((int)*(l_beg + 5) << 3) + width[0])
				return(l_beg);
			}

		cl = calc_clen(l_beg);
		l_beg += cl;
		}while(cl != -1 && *l_beg);

	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	y[0] += 16;
	}

y[0] = wy + ruler_flag * 16;

l_adr = txt_start[akt_id] + text_pos[akt_id];
while(l_adr > txt_start[akt_id])
	{
	l_beg = l_adr + 5 + note_len(l_adr);
	do
		{
		if (*l_beg == 0x18)
			{
			pic_a = (unsigned char *)(((long)*(l_beg + 2) << 16) | ((long)*(l_beg + 3) << 8) | (long)*(l_beg + 4));
			width[0] 	= ((int)*pic_a << 8)	| *(pic_a + 1);
			height[0] 	= ((int)*(pic_a + 2) << 8) | *(pic_a + 3);

			if (mousey > y[0] && mousey < y[0] + height[0] && mousex > wx + ((int)*(l_beg + 5) << 3) && mousex < wx + ((int)*(l_beg + 5) << 3) + width[0])
				return(l_beg);
			}

		cl = calc_clen(l_beg);
		l_beg += cl;
		}while(cl != -1 && *l_beg);

	l_adr = go_back(l_adr);
	y[0] -= 16;
	}

return(0);
}

/* -------------------- */
/* | Bild verschieben | */
/* -------------------- */
void move_pic(void)
{
extern unsigned char *go_back();

register unsigned char *pic_pos, *l_adr;
register int i, p, cl;
int height, width, y, endx, endy;
char pic_block[80];

set_eline();

pic_pos = search_pic(&height, &width, &y);

if (pic_pos)
	{
	get_work(0);
	graf_dragbox(width, height, mousex - (width >> 1), y,
							 wx, wy, ww, wh + height, &endx, &endy);

	get_work(w_handles[akt_id]);

	if ( ((endy - wy) >> 4) == ((y - wy) >> 4) && endx >= wx + 24)
		{
		pic_pos[5] = (endx - wx - 24) >> 3;
		full_redraw();
		}
	else
		if ( endx >= wx + 24)
			{
			pic_pos[5] = (endx - wx - 24) >> 3;

			p = ((endy - wy) >> 4) - ruler_flag;
			if (p + first_line[akt_id] < total_lines[akt_id])
				{
				l_adr = go_back(pic_pos);
				if (*l_adr == 0x11)
					l_adr += calc_clen(l_adr);

				cl = calc_clen(pic_pos);
				i = line_len(l_adr) - cl;

				memmove(pic_block, pic_pos, cl);
				move_mem(pic_pos, -cl);

				if (pic_pos < cursor_line[akt_id] + txt_start[akt_id])
					cursor_line[akt_id] -= cl;

				if (pic_pos < text_pos[akt_id] + txt_start[akt_id])
					text_pos[akt_id] -= cl;
	
				l_adr[3] = (i >> 8) | 0x80;
				l_adr[4] = i;
	
				l_adr = txt_start[akt_id] + text_pos[akt_id];
				while(p--)
					{
					l_adr += note_len(l_adr) + line_len(l_adr) + 5;
					
					if (*l_adr == 0x11)
						l_adr += calc_clen(l_adr);
					}
	
				move_mem(l_adr + 5 + note_len(l_adr), cl);
				memmove(l_adr + 5 + note_len(l_adr), pic_block, cl);

				if (l_adr < cursor_line[akt_id] + txt_start[akt_id])
					cursor_line[akt_id] += cl;

				i = line_len(l_adr) + cl;
				l_adr[3] = (i >> 8) | 0x80;
				l_adr[4] = i;
				}

			full_redraw();
			}
	}
get_eline();
}

/* ------------------- */
/* | Bilder einladen | */
/* ------------------- */
void load_pictures(void)
{
register int cl;
register unsigned char *adr, *l_beg;

total_lines[akt_id] = 0;

adr = txt_start[akt_id];
while(adr < txt_start[akt_id] + txt_lens[akt_id])
	{
	if (*adr == 0x11)
		adr += calc_clen(adr);

	l_beg = adr + note_len(adr) + 5;
	do
		{
		if (*l_beg == 0x18)
			load_picin(l_beg + 1, FILE2);

		cl = calc_clen(l_beg);
		l_beg += cl;
		}while(cl > 0 && *l_beg);

	adr += note_len(adr) + line_len(adr) + 5;
	total_lines[akt_id]++;
	}
}

/* ----------------- */
/* | Bild einladen | */
/* ----------------- */
void load_picin(char *pic_block, int inf_typ)
{
extern FILE *img_f;
char pic_path[80];
long chunk;

strcpy(pic_path, pathes[akt_id]);
strcpy(rindex(pic_path, '\\') + 1, pic_block + 5);

img_f = fopen(pic_path, "rb");
if (img_f)
	{
	load_info(pic_path, inf_typ);

	fread(&chunk, 4, 1, img_f);
	fseek(img_f, 0L, 0);

	if (chunk == 'FORM')
		get_iff();
	else
		get_img();

	fclose(img_f);
	}
else
	img_mem = 0;

*(pic_block++) = 0x80;
*(pic_block++) = (long)img_mem >> 16;
*(pic_block++) = (int)img_mem >> 8;
*(pic_block++) = (char)img_mem;
}

/* ------------------- */
/* | Bild hinzuladen | */
/* ------------------- */
void add_pic(void)
{
unsigned char line_add[80];
register int lc;
register unsigned char *pic_a;
register int height;

if (fsel(pic_fpath, ".I*"))
	{
	set_eline();

	strcpy(line_add + 6, pic_fpath + (rindex(pathes[akt_id], '\\') - pathes[akt_id]) + 1);
	line_add[0] = 0x18;
	line_add[5] = c_c[akt_id];
	load_info("   Lade...", DOING);
	load_picin(line_add + 1, LOADFILE);
	load_info(0L, -1);

	pic_a = (unsigned char *)((long)line_add[2] << 16 | 
													  (long)line_add[3] <<  8 | line_add[4]);

	if (pic_a)
		{
		height 	= ((int)*(pic_a + 2) << 8) | *(pic_a + 3);
		lc = (height + 15) >> 4;

		while(lc--)
			add_empty();
		}

	get_eline();
	insert_bytes(0, line_add, strlen(line_add + 6) + 7);

	full_redraw();
	}
}

/* -------------------------- */
/* | Bild an Cursor l”schen | */
/* -------------------------- */
void kill_pic(void)
{
extern unsigned char *go_back();

register unsigned char *pic_adr;
int height, width, y;
register int len;

set_eline();

get_work(w_handles[akt_id]);

mousex = wx + c_x[akt_id];
mousey = wy + c_y[akt_id] + (ruler_flag << 4);
pic_adr = search_pic(&height, &width, &y);

if (pic_adr)
	{
	remove_pic(pic_adr);
	
	len = calc_clen(pic_adr);
	move_mem(pic_adr, -len);
	txt_fill -= len;
	txt_lens[akt_id] -= len;
	
	if (pic_adr < cursor_line[akt_id] + txt_start[akt_id])
		cursor_line[akt_id] -= len;
	
	if (pic_adr < text_pos[akt_id] + txt_start[akt_id])
		text_pos[akt_id] -= len;
	
	pic_adr = go_back(pic_adr);
	len = line_len(pic_adr) - len;
	*(pic_adr + 3) = (len >> 8) | 0x80;
	*(pic_adr + 4) = len;

	full_redraw();
	}

get_eline();
}

/* ---------------- */
/* | Bild l”schen | */
/* ---------------- */
void remove_pic(unsigned char *pic_adr)
{
register long len;
int height, width;

pic_adr = (unsigned char *)(((long)*(pic_adr + 2) << 16) | ((long)*(pic_adr + 3) << 8) | (long)*(pic_adr + 4));
width 	= ((int)*pic_adr << 8)	| *(pic_adr + 1);
height 	= ((int)*(pic_adr + 2) << 8) | *(pic_adr + 3);
len = (((width + 15) >> 4) << 1) * height + 4;

remove_one(pic_adr, len);
}

/* -------------------------------------- */
/* | Alle Bilder eines Textes entfernen | */
/* -------------------------------------- */
void remove_all(int id)
{
register int cl;
register unsigned char *adr, *l_beg;

adr = txt_start[id];
while(adr < txt_start[id] + txt_lens[id])
	{
	if (*adr == 0x11)
		adr += calc_clen(adr);

	l_beg = adr + note_len(adr) + 5;
	do
		{
		if (*l_beg == 0x18)
			remove_pic(l_beg);

		cl = calc_clen(l_beg);
		l_beg += cl;
		}while(cl > 0 && *l_beg);

	adr += note_len(adr) + line_len(adr) + 5;
	}

remove_allf(id);
}
