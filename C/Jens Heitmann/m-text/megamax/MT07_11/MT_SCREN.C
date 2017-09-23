#include "extern.h"

char out_date[9], out_time[5];
int outw_x;

/* --------------------- */
/* | Fenster schlieûen | */
/* --------------------- */
erase_wind(w_handle)
register int w_handle;
{
register int i, j;

i = get_whandle(w_handle);

remove_all(i);

move_meml(txt_start[i], -txt_lens[i]);
for (j = 0; j < 4; j++)
	if (txt_start[j] > txt_start[i])
		txt_start[j] -= txt_lens[i];

w_handles[i] = -1;
txt_start[i] = 0;
text_pos[i] = 0;
txt_fill -= txt_lens[i];
txt_lens[i] = 0;

wind_close(w_handle);
wind_delete(w_handle);
}

/* ----------------------- */
/* | Fenster neuzeichnen | */
/* ----------------------- */
redraw(w_handle, rx, ry, rw, rh)
register int w_handle;
int rx, ry, rw, rh;
{
int dx, dy, dh, dw;
register int i;
GRECT r_rec;

r_rec.g_x = rx;
r_rec.g_y = ry;
r_rec.g_w = rw;
r_rec.g_h = rh;

wind_update(BEG_UPDATE);

mouse_off();

i = get_whandle(w_handle);

get_work(w_handle);
dx = wx;
dy = wy;
dh = wh;
dw = ww;

wind_get(w_handle, WF_FIRSTXYWH, &wx, &wy, &ww, &wh);
while (ww && wh)
	{
	if (rect_intersect(wx, wy, ww, wh, r_rec, &red_rc))
		{
		vswr_mode(vdi_handle, 1);
		clip(red_rc);
		clr_wind(red_rc);

		vswr_mode(vdi_handle, 2);
		if (ruler_flag)
			draw_lineal(i, dx, dy, dw);

		draw_border(i, dx, dy, dh);

		if (red_rc.g_y < dy + 16 && ruler_flag)
			{
			red_rc.g_h -= dy + 16 - red_rc.g_y;
			red_rc.g_y = dy + 16;
			clip(red_rc);
			}

		text_out(i, dx, dy, dh);

		if (modus[i])
			draw_backl(i, dx, dy);

		show_cursor(dx, dy, i);
		}

	wind_get(w_handle, WF_NEXTXYWH, &wx, &wy, &ww, &wh);
	}

set_fullclip();

wind_update(END_UPDATE);
}

/* -------------------- */
/* | Text neuzeichnen | */
/* -------------------- */
clr_wind(rc)
GRECT rc;
{
int xy[4];

xy[0] = rc.g_x;
xy[1] = rc.g_y;
xy[2] = rc.g_x + rc.g_w - 1;
xy[3] = rc.g_y + rc.g_h - 1;

vsf_interior(vdi_handle, 0);
vr_recfl(vdi_handle, xy);
}

/* --------------- */
/* | Clip setzen | */
/* --------------- */
clip(rc)
GRECT rc;
{
int xy[4];

xy[0] = rc.g_x;
xy[1] = rc.g_y;
xy[2] = rc.g_x + rc.g_w - 1;
xy[3] = rc.g_y + rc.g_h - 1;

vs_clip(vdi_handle, TRUE, xy);
}

/* ------------------- */
/* | Lineal zeichnen | */
/* ------------------- */
draw_lineal(w_id, wx, wy, ww)
int w_id, wx, wy, ww;
{
char lineal[259];
int dummy;
register int i;

get_work(w_handles[w_id]);

strcpy(lineal, " E ");
strcpy(lineal + 3, txt_lineal[w_id]);

i = strlen(lineal);

lineal[i++] = '|';

ww += 7;
ww >>= 3;
while(i < ww)
	lineal[i++] = ' ';

if (i > 159)
	i = 159;
lineal[i] = 0;

vst_effects(vdi_handle, 8);
vst_height(vdi_handle, 13, &dummy, &dummy, &dummy, &dummy);
vst_font(vdi_handle, 1);

v_gtext(vdi_handle, wx, wy + 15, lineal);
}

/* ---------------------------------- */
/* | zurÅckliegende Zeilen zeichnen | */
/* ---------------------------------- */
draw_backl(w_id, wx, wy)
register int w_id, wx, wy;
{
extern unsigned char *go_back();
extern unsigned char *show_oneline();

register unsigned char *l_adr, *l_beg;
register int cl, lc;

s_p = 0;
s_x = wx + 24;
s_y = wy - (!ruler_flag << 4);

l_adr = txt_start[w_id] + text_pos[w_id];

lc = 4;
while(l_adr > txt_start[w_id] && lc)
	{
	l_adr = go_back(l_adr);

	show_oneline(l_adr, txt_start[w_id] + text_pos[w_id], modus[w_id], w_id);

	s_y -= 16;
	s_p = 0;
	s_x = wx + 24;
	lc--;
	}

if (l_adr > txt_start[w_id])
	draw_backp(l_adr, wx, w_id);
}

/* ---------------------------------- */
/* | zurÅckliegende Bilder zeichnen | */
/* ---------------------------------- */
draw_backp(l_adr, wx, w_id)
register unsigned char *l_adr;
register int wx, w_id;
{
extern unsigned char *go_back();

register unsigned char *l_beg;
register int cl, lc;

s_p = 0;
s_x = wx + 24;

lc = 20;
while(l_adr > txt_start[w_id] && lc)
	{
	l_adr = go_back(l_adr);

	l_beg = l_adr + note_len(l_adr) + 5;
	do
		{
		if (*l_beg == 0x18)
			show_pic(l_beg);

		cl = calc_clen(l_beg);
		l_beg += cl;
		}while(cl > 0 && *l_beg);

	s_y -= 16;
	lc--;
	}
}

/* ----------------- */
/* | Text ausgeben | */
/* ----------------- */
text_out(w_id, wx, wy, wh)
register int w_id, wx, wy;
int wh;
{
extern unsigned char *show_oneline();

register int l;
register unsigned char *adr, *text_end;

s_p = 0;
s_x = wx + 24;
s_y = wy + (ruler_flag << 4);
outw_x = wx;

l = wh >> 4;

adr = txt_start[w_id] + text_pos[w_id];
text_end = txt_start[w_id] + txt_lens[w_id];

while(adr <= text_end && l && s_y < red_rc.g_y + red_rc.g_h - 1)
	{
	if (*adr == 0x11)
		adr += calc_clen(adr);

	if (note_len(adr) && modus[w_id])
		show_notemark();

	if (akt_id == w_id && adr - txt_start[w_id] == cursor_line[w_id])
		{
		show_oneline(line_buffer, line_buffer + buf_len, modus[w_id], w_id);
		adr += note_len(adr) + line_len(adr) + 5;
		}
	else
		if (adr < text_end)
			adr = show_oneline(adr, text_end, modus[w_id], w_id);

	l--;
	s_p = 0;
	s_x = wx + 24;
	s_y += 16;
	}
}

/* ----------------------- */
/* | Eine Zeile ausgeben | */
/* ----------------------- */
unsigned char *show_oneline(adr, text_end, mod, w_id)
register unsigned char *adr, *text_end;
register int mod, w_id;
{
int dummy, fheight = 13;
register int i;

vst_effects(vdi_handle, NORMAL);
vst_height(vdi_handle, 13, &dummy, &dummy, &fontw, &fonth);
vst_font(vdi_handle, 1);
y_ausr = 1;
out_date[0] = 0;
out_time[0] = 0;

while(adr < text_end)
	{
	switch(*adr)
		{
		case 0x00:										/* Zeilenende 	*/
			return(++adr);

		case 0x0D:										/* Absatzzeile	*/
			break;

		case 0x01:										/* Schriftart 	*/
			if (mod)
				{
				vst_effects(vdi_handle, *(++adr));
	
				if (*adr & 0xC0)						/* Kleinschrift */
					vst_height(vdi_handle, 6, &dummy, &dummy, &fontw, &fonth);
				else
					vst_height(vdi_handle, fheight, &dummy, &dummy, &fontw, &fonth);
	
				if (*adr & 0x80)
					y_ausr = 2;
				else
					y_ausr = 1;
				}
			else
				adr++;
			break;

		case 0x02:										/* Font 				*/
			if (mod)
				{
				vst_font(vdi_handle, *(++adr));
				fheight = *(++adr);
				vst_height(vdi_handle, fheight, &dummy, &dummy, &fontw, &fonth);
				}
			else
				adr += 2;
			break;

		case 0x03:										/* Druckerfont	*/
			break;

		case 0x04:										/* Zeilenheader	*/
			adr += 4 + note_len(adr);
			break;

		case 0x05:										/* Softhyphen 	*/
			show_char('~');
			break;

		case 0x06:										/* Mandatory		*/
			show_char(0xDF);
			break;

		case 0x08:										/* FÅllspace		*/
			show_char(' ');
			break;

		case 0x09:										/* TAB					*/
			show_char(' ');
			
			while (txt_lineal[w_id][s_p] == '.')
				show_char(' ');
			break;

		case 0x0B:										/* Blocksatz	*/
			break;

		case 0x0C:										/* Seitenende 	*/
			break;

		case 0x0E:										/* EinrÅckung		*/
			for (i = *(++adr); i > 0; i--)
				show_char(' ');
			break;
			
		case 0x0F:										/* RechtsbÅndig */
			i = ((int)(*(++adr) & 0x7F) << 8) | *(++adr);
			s_x += (strlen(txt_lineal[w_id]) << 3) - i;
			break;

		case 0x12:										/* Inhalt 			*/
			if (modus[w_id])
				show_inhaltmark();
			break;

		case 0x13:										/* Index				*/
			break;

		case 0x14:										/* Variable 		*/
			break;

		case 0x15:										/* Uhrzeit			*/
			if (!out_time[0])
				get_time(out_time);

			show_char(out_time[0]);
			strcpy(out_time, out_time + 1);
			break;

		case 0x16:										/* Datum				*/
			if (!out_date[0])
				get_date(out_date);

			show_char(out_date[0]);
			strcpy(out_date, out_date + 1);
			break;

		case 0x17:										/* Fester Leer. */
			break;

		case 0x18:										/* Bild 				*/
			if (mod)
				show_pic(adr);

			adr += calc_clen(adr) - 1;
			break;

		case 0x1B:										/* Sonderzeichen */
			show_char(*(++adr));
			break;

		case 0x1C:										/* Rechenwert		*/
			break;
			
		case 0x1D:										/* Rechnung			*/
			break;

		case 0x1E:										/* Fuûnote			*/
			break;
			
		default:
			show_char(*adr);
		}

	adr++;
	}

return(adr);
}

/* --------------------- */
/* | Notizmarke zeigen | */
/* --------------------- */
show_notemark()
{
int xy[10], dummy;
register int wx;

wx = outw_x;

vsl_color(vdi_handle, 1);
vsl_type(vdi_handle, 1);
vsl_width(vdi_handle, 1);
vsl_ends(vdi_handle, 0, 0);

xy[6] = xy[8] = xy[0] = wx + 15;
xy[4] = xy[2] = wx + 23;
xy[9] = xy[3] = xy[1] = s_y;
xy[7] = xy[5] = s_y + 15;
v_pline(vdi_handle, 5, xy);

xy[2] = xy[0] = wx + 17;
xy[5] = xy[1] = s_y + 11;
xy[7] = xy[3] = s_y + 4;
xy[6] = xy[4] = wx + 21;

v_pline(vdi_handle, 4, xy);
}

/* ----------------------- */
/* | Inhaltsmarke zeigen | */
/* ------------------------ */
show_inhaltmark()
{
int xy[10], dummy;
register int wx;

wx = outw_x;

vsl_color(vdi_handle, 1);
vsl_type(vdi_handle, 1);
vsl_width(vdi_handle, 1);
vsl_ends(vdi_handle, 0, 0);

xy[6] = xy[8] = xy[0] = wx + 7;
xy[4] = xy[2] = wx + 15;
xy[9] = xy[3] = xy[1] = s_y;
xy[7] = xy[5] = s_y + 15;
v_pline(vdi_handle, 5, xy);

xy[0] = wx + 9;
xy[2] = wx + 13;
xy[5] = xy[1] = xy[3] = s_y + 4;
xy[6] = xy[4] = wx + 11;
xy[7] = s_y + 11;
v_pline(vdi_handle, 4, xy);

xy[1] = xy[3] = s_y + 11;
v_pline(vdi_handle, 2, xy);
}

/* -------------------- */
/* | Zeichen ausgeben | */
/* -------------------- */
show_char(chr)
register unsigned char chr;
{
unsigned char string[2];
int cell, right, left;

if (s_y + fonth > red_rc.g_y)
	{
	string[0] = chr;
	string[1] = 0;
	v_gtext(vdi_handle, s_x, s_y + fonth * y_ausr, string);
	}

vqt_width(vdi_handle, chr, &cell, &left, &right);
s_x += cell;
s_p++;
}

/* ---------------------- */
/* | Randlinie zeichnen | */
/* ---------------------- */
draw_border(w_id, dx, dy, dh)
int w_id, dx, dy, dh;
{
int xy[4];

xy[2] = xy[0] = dx + 23;
xy[1] = dy;
xy[3] = dy + dh + 23;
v_pline(vdi_handle, 2, xy);
}

/* ----------------- */
/* | Cursor zeigen | */
/* ----------------- */
show_cursor(wx, wy, w_id)
int wx, wy, w_id;
{
unsigned char string[2];
int xy[10], dummy;
register int i;
int cell, left, right;

if (w_id != akt_id)
	return;

vswr_mode(vdi_handle, 3);
vsf_interior(vdi_handle, 1);

vst_font(vdi_handle, akt_font);
vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &dummy);
vst_effects(vdi_handle, akt_sstyle);
	
string[1] = 0;
if (c_p[akt_id] < buf_len)
	string[0] = line_buffer[c_p[w_id]];
else
	string[0] = ' ';

vqt_width(vdi_handle, string[0], &cell, &left, &right);
vqt_extent(vdi_handle, string, xy);

printf("\33H%c %d\n", string[0], cell);
if (akt_sstyle & 4)
	{
	xy[2]--;
	xy[0] = xy[2] - cell + 1;
	xy[4] = xy[6] + cell - 1;
	xy[2]--;
	}
else
	xy[4] = xy[2] = xy[0] + cell - 1;

for (i = 0; i < 8; i += 2)
	{
	xy[i] += wx + c_x[w_id] + 24;
	xy[i + 1] += wy + c_y[w_id] + (ruler_flag << 4) + 1 + ((akt_sstyle & 0x80) ? 8 : 0);
	}

xy[8] = xy[0];
xy[9] = xy[1];

/*make_rasc((long)c_c[w_id] + 1, 100L, txt_infol[w_id] + 36);
make_rasc((long)line_count[w_id] + 1, 10000L, txt_infol[w_id] + 21);

wind_set(w_handles[w_id], WF_INFO, txt_infol[w_id], 0, 0);*/

v_fillarea(vdi_handle, 5, xy);
}

/* ------------------- */
/* | Zeige Editzeile | */
/* ------------------- */
show_eline()
{
show_eline_ab(c_x[akt_id]);
}

/* ----------------------------- */
/* | Neuzeichnen ab Position x | */
/* ----------------------------- */
show_eline_ab(ab)
register int ab;
{
int dummy, chr_hg;
register long tpos_zw;
register unsigned char *l_adr;

vst_font(vdi_handle, akt_font);
vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &chr_hg);

get_work(w_handles[akt_id]);

red_rc.g_x = wx + ab + 24;
red_rc.g_y = wy + c_y[akt_id] + (ruler_flag << 4) + 1;
red_rc.g_w = ww - ab - 24;
if (red_rc.g_y - wy + chr_hg + 2 > wh - 16)
	red_rc.g_h = wh - red_rc.g_y + wy;
else
	red_rc.g_h = chr_hg + 2;

clip(red_rc);

vswr_mode(vdi_handle, 1);
clr_wind(red_rc);
vswr_mode(vdi_handle, 2);

draw_border(akt_id, wx, wy, wh);
if (modus[akt_id])
	{
	tpos_zw = text_pos[akt_id];
	text_pos[akt_id] = cursor_line[akt_id];

	text_out(akt_id, wx, wy + c_y[akt_id], wh);
	draw_backl(akt_id, wx, wy + c_y[akt_id] + (!ruler_flag << 16));
	}
else
	{
	s_x = wx + 24;
	s_y = wy + (ruler_flag << 4) + c_y[akt_id];
	show_oneline(line_buffer, line_buffer + buf_len, modus[akt_id], akt_id);
	}
	
show_cursor(wx, wy, akt_id);

text_pos[akt_id] = tpos_zw;

set_fullclip();
}

/* ------------------ */
/* | Setze Clipping | */
/* ------------------ */
set_fullclip()
{
int xy[4];

get_work(w_handles[akt_id]);

xy[0] = wx;
xy[1] = wy;
xy[2] = wx + ww - 1;
xy[3] = wy + wh - 1;
vs_clip(vdi_handle, TRUE, xy);
}

/* --------------------------- */
/* | Alles unten neuzeichnen | */
/* --------------------------- */
push_down()
{
int xy[4];

get_work(w_handles[akt_id]);

copy_block(wx, wy + c_y[akt_id] + (ruler_flag << 4), ww, wh - c_y[akt_id] - 16 - 16 * ruler_flag,
					 wx, wy + c_y[akt_id] + 16 + (ruler_flag << 4));
}

/* -------------------- */
/* | Screenblock-Copy | */
/* -------------------- */
copy_block(x1, y1, w, h, x2, y2)
int x1, y1, w, h, x2, y2;
{
int xy[8];
MFDB src, des;

mouse_off();

xy[0] = x1;
xy[1] = y1;
xy[2] = x1 + w - 1;
xy[3] = y1 + h - 1;
xy[4] = x2;
xy[5] = y2;
xy[6] = x2 + w - 1;
xy[7] = y1 + h - 1;

src.fd_addr = 0;
des.fd_addr = 0;
vro_cpyfm(vdi_handle, 3, xy, &src, &des);
}

/* -------------------- */
/* | Screenblock-Copy | */
/* -------------------- */
show_pic(adr)
register unsigned char *adr;
{
int xy[8];
MFDB src, des;
register unsigned char *pic_a;
register int width, height;

pic_a = (unsigned char *)((long)*(adr + 2) << 16 | 
													(long)*(adr + 3) << 8 | *(adr + 4));

if (pic_a)
	{
	width 	= ((int)*pic_a << 8)	| *(pic_a + 1);
	height 	= ((int)*(pic_a + 2) << 8) | *(pic_a + 3);

	src.fd_h			 = height;

	xy[5] = s_y;
	xy[7] = xy[5] + src.fd_h - 1;

	if (xy[7] >= red_rc.g_y && xy[5] < red_rc.g_y + red_rc.g_h)
		{
		src.fd_w			 = (width + 15) & ~15;

		xy[0] = 0;
		xy[1] = 0;
		xy[2] = width - 1;
		xy[3] = height - 1;
		xy[4] = s_x + *(adr + 5) * 8;
		xy[6] = xy[4] + src.fd_w - 1;
	
		src.fd_addr 	 = (long)pic_a + 4;
		src.fd_wdwidth = src.fd_w >> 4;
		src.fd_stand	 = 0;
		src.fd_nplanes = 1;
	
		des.fd_addr = 0;
	
		vro_cpyfm(vdi_handle, 7, xy, &src, &des);
		}
	}
}

/* --------------------------------- */
/* | Aktuelles Fenster neuzeichnen | */
/* --------------------------------- */
full_redraw()
{
wind_get(w_handles[akt_id], WF_WORKXYWH, &fx, &fy, &fw, &fh);
f_dial(FMD_FINISH);
}
