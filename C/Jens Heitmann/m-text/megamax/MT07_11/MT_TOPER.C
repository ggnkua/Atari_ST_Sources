#include "extern.h"

/* ----------------- */
/* | Zeile l”schen | */
/* ----------------- */
kill_line()
{
extern unsigned char *go_back();

register unsigned char *l_adr, *l_adr2;
register int len;

if (cursor_line[akt_id] < txt_lens[akt_id])
	{
	l_adr = txt_start[akt_id] + cursor_line[akt_id];
	len = note_len(l_adr) + line_len(l_adr) + 5;

	move_mem(l_adr, -len);
	txt_fill -= len;
	txt_lens[akt_id] -= len;

	if (*l_adr == 0x11)
		{
		l_adr2 = go_back(l_adr);

		if (*l_adr2 == 0x11 && l_adr2 + calc_clen(l_adr2) < l_adr)
			l_adr2 += calc_clen(l_adr2);

		if (*l_adr2 != 0x11)
			l_adr2 += note_len(l_adr2) + line_len(l_adr2) + 5;

		if (*l_adr2 == 0x11 && l_adr2 < l_adr)
			{
			len = calc_clen(l_adr2);
			move_mem(l_adr2, -len);
			txt_fill -= len;
			txt_lens[akt_id] -= len;
			cursor_line[akt_id] -= len;
			l_adr -= len;

			if (l_adr2 < txt_start[akt_id] + text_pos[akt_id])
				text_pos[akt_id] -= len;
			}
		}

	if (*l_adr == 0x11)
		cursor_line[akt_id] += calc_clen(l_adr);

	l_adr = txt_start[akt_id] + text_pos[akt_id];
	if (*l_adr == 0x11)
		text_pos[akt_id] += calc_clen(l_adr);
	
	total_lines[akt_id]--;
	get_eline();
	full_redraw();
	}
}

/* ------------------------------- */
/* | Gehe zu V-Slider - Position | */
/* ------------------------------- */
go_vpos(pos)
register int pos;
{
register long lc;
register unsigned char *l_adr;

set_eline();

get_work(w_handles[akt_id]);

first_line[akt_id] = lc = (long)pos * (total_lines[akt_id] - (wh >> 4) + ruler_flag) / 1000;

l_adr = txt_start[akt_id];
while(lc--)
	{
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	}
if (*l_adr == 0x11)
	l_adr += calc_clen(l_adr);

text_pos[akt_id] = l_adr - txt_start[akt_id];

lc = c_y[akt_id] >> 4;
line_count[akt_id] = first_line[akt_id];
while(lc--)
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;

	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	line_count[akt_id]++;
	}
cursor_line[akt_id] = l_adr - txt_start[akt_id];

search_lineal(l_adr);
get_eline();
full_redraw();
}

/* --------------------- */
/* | Gehe zum Textende | */
/* --------------------- */
go_end()
{
extern unsigned char *go_back();

register unsigned char *l_adr;
register int lc = 1;

set_eline();

get_work(w_handles[akt_id]);

cursor_line[akt_id] = txt_lens[akt_id];
line_count[akt_id] = first_line[akt_id] = total_lines[akt_id];

l_adr = txt_start[akt_id] + cursor_line[akt_id];
while(l_adr > txt_start[akt_id] && lc < (wh >> 4) - ruler_flag)
	{
	l_adr = go_back(l_adr);

	first_line[akt_id]--;	
	lc++;
	}
if (*l_adr == 0x11)
	l_adr += calc_clen(l_adr);

text_pos[akt_id] = l_adr - txt_start[akt_id];
c_y[akt_id] = (line_count[akt_id] - first_line[akt_id]) << 4;

search_lineal(l_adr);
get_eline();
full_redraw();
}

/* ---------------------------------------- */
/* | Seite nach oben, ohne Cursorbewegung | */
/* ---------------------------------------- */
beg_pgup()
{
extern unsigned char *go_back();

register unsigned char *l_adr;
register int lc = 1;
int dummy, fheight;

set_eline();

get_work(w_handles[akt_id]);

l_adr = txt_start[akt_id] + text_pos[akt_id];
while (first_line[akt_id] > 0 && lc < (wh >> 4))
	{
	l_adr = go_back(l_adr);

	first_line[akt_id]--;
	lc++;
	}
if (*l_adr == 0x11)
	l_adr += calc_clen(l_adr);

text_pos[akt_id] = l_adr - txt_start[akt_id];

l_adr = txt_start[akt_id] + cursor_line[akt_id];
while(--lc)
	{
	l_adr = go_back(l_adr);
	line_count[akt_id]--;
	}
if (*l_adr == 0x11)
	l_adr += calc_clen(l_adr);

cursor_line[akt_id] = l_adr - txt_start[akt_id];

search_lineal(l_adr);
get_eline();
full_redraw();
}

/* ----------------------------------------- */
/* | Seite nach unten, ohne Cursorbewegung | */
/* ----------------------------------------- */
beg_pgdwn()
{
register unsigned char *l_adr;
register int lc = 1;

set_eline();

get_work(w_handles[akt_id]);
l_adr = txt_start[akt_id] + text_pos[akt_id];

while (first_line[akt_id] <= total_lines[akt_id] - (wh >> 4) + ruler_flag && lc < (wh >> 4))
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	first_line[akt_id]++;
	lc++;
	}

text_pos[akt_id] = l_adr - txt_start[akt_id];

l_adr = txt_start[akt_id] + cursor_line[akt_id];
while(--lc)
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	line_count[akt_id]++;
	}

cursor_line[akt_id] = l_adr - txt_start[akt_id];

search_lineal(l_adr);
get_eline();
full_redraw();
}

/* ---------------------------------------- */
/* | Zeile nach oben, ohne Cursorbewegung | */
/* ---------------------------------------- */
beg_oneup()
{
extern unsigned char *go_back();

int dummy, fheight;

get_work(w_handles[akt_id]);

if (first_line[akt_id] > 0)
	{
	text_pos[akt_id] = go_back(txt_start[akt_id] + text_pos[akt_id]) - txt_start[akt_id];
	first_line[akt_id]--;
	
	vst_font(vdi_handle, akt_font);
	vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &fheight);
	while (c_y[akt_id] + fheight > wh)
		line_up();

	c_y[akt_id] += 16;
	get_work(w_handles[akt_id]);
	copy_block(wx, wy + 16 * ruler_flag, ww, wh - 16 - 16 * ruler_flag, wx, wy + 16 + 16 * ruler_flag);

	redraw(w_handles[akt_id], wx, wy + 16 * ruler_flag, ww, 16);	
	}
}

/* ----------------------------------------- */
/* | Zeile nach unten, ohne Cursorbewegung | */
/* ----------------------------------------- */
beg_onedown()
{
register unsigned char *l_adr;

get_work(w_handles[akt_id]);

if (first_line[akt_id] <= total_lines[akt_id] - (wh >> 4) + ruler_flag)
	{
	l_adr = txt_start[akt_id] + text_pos[akt_id];
	text_pos[akt_id] += note_len(l_adr) + line_len(l_adr) + 5;
	first_line[akt_id]++;
	
	if (c_y[akt_id] - 16 < 0)
		line_down();

	c_y[akt_id] -= 16;
	copy_block(wx, wy + 16 + 16 * ruler_flag, ww, wh - 16 - 16 * ruler_flag, wx, wy + 16 * ruler_flag);

	get_work(w_handles[akt_id]);
	redraw(w_handles[akt_id], wx, wy + wh - 16, ww, 16);	
	}
}

/* ------------------------------ */
/* | Festes Zeilenende erfassen | */
/* ------------------------------ */
set_paragraph()
{
register int rlen;
register unsigned char *l_adr;

get_work(w_handles[akt_id]);

if (c_c[akt_id])
	{
	insert_bytes(c_p[akt_id], "\r", 1);

	if (c_p[akt_id] < buf_len)
		{
		insert_bytes(c_p[akt_id], "\0\4\200\0\0\0\1\0", 8);
		line_buffer[c_p[akt_id] - 1] = akt_sstyle;
		line_buffer[c_p[akt_id] - 4] = ((buf_len - c_p[akt_id] + 3) >> 8) | 0x80;
		line_buffer[c_p[akt_id] - 3] = buf_len - c_p[akt_id] + 3;

		set_eline();

		l_adr = txt_start[akt_id] + cursor_line[akt_id];
		l_adr[3] = ((c_p[akt_id] - 7) >> 8) | 0x80;
		l_adr[4] = c_p[akt_id] - 7;
		get_eline();
		show_eline_ab(-24);
		}

	line_down();
	cursor_tobeg();
	}
else
	{
	set_eline();

	add_empty();
	get_eline();

	show_eline_ab(-24);
	line_down();
	}

total_lines[akt_id]++;

if (line_gadr < txt_start[akt_id] + txt_lens[akt_id])
	{
	show_cursor(wx, wy, akt_id);
	push_down();
	show_eline_ab(-24);
	}
else
	show_eline_ab(-24);
}

/* ------------------- */
/* | Zeichen l”schen | */
/* ------------------- */
del_char()
{
memmove(line_buffer + c_p[akt_id], line_buffer + c_p[akt_id] + 1, buf_len - c_p[akt_id]);
buf_len--;
line_redundanz();
c_p[akt_id] = skip_control();
show_eline();
}

/* --------------------- */
/* | Zeichen schreiben | */
/* --------------------- */
write_char(key)
register int key;
{
register int i;

if (!(key & 0xFF))
	return;

if (c_p[akt_id] > buf_len)
	buf_len = c_p[akt_id];

memmove(line_buffer + c_p[akt_id] + 1, line_buffer + c_p[akt_id], 511 - c_p[akt_id]);
line_buffer[c_p[akt_id]] = key;
buf_len++;

i = 0;
while (i < c_p[akt_id])
	{
	if (line_buffer[i] == 0xD)
		{
		memmove(line_buffer + i, line_buffer + i + 1, c_p[akt_id] - i);
		line_buffer[c_p[akt_id]] = 0xD;
		c_p[akt_id]--;
		break;
		}

	i += abs(calc_clen(&line_buffer[i]));
	}

show_eline();
char_right();
}

/* ---------------------- */
/* | Gehe an Textbeginn | */
/* ---------------------- */
go_textbeg()
{
set_eline();

line_count[akt_id] = 0;
first_line[akt_id] = 0;
if (*txt_start[akt_id] == 0x11)
	{
	text_pos[akt_id] = calc_clen(txt_start[akt_id]);
	get_lineal(txt_start[akt_id]);
	}
else
	text_pos[akt_id] = 0;

cursor_line[akt_id] = text_pos[akt_id];

get_eline();
c_c[akt_id] = 0;
c_y[akt_id] = 0;
c_p[akt_id] = skip_control();

full_redraw();
}

/* ------------------------- */
/* | Gehe nach obeen links | */
/* ------------------------- */
go_screenb()
{
extern unsigned char *go_back();

register unsigned char *l_adr, *s_adr;

set_eline();
get_work(w_handles[akt_id]);

show_cursor(wx, wy, akt_id);

l_adr = cursor_line[akt_id] + txt_start[akt_id];
s_adr = text_pos[akt_id] + txt_start[akt_id];
while(l_adr > s_adr)
	{
	l_adr = go_back(l_adr);
	line_count[akt_id]--;
	}
cursor_line[akt_id] = text_pos[akt_id];

get_eline();

c_c[akt_id] = 0;
c_y[akt_id] = 0;
c_p[akt_id] = skip_control();

show_cursor(wx, wy, akt_id);
}

/* ----------------------- */
/* | Springe zu Zeile ln | */
/* ----------------------- */
goto_line(ln)
register long ln;
{
register unsigned char *line_adr;
int fheight, dummy;

set_eline();

get_work(w_handles[akt_id]);

c_c[akt_id] = 0;
c_y[akt_id] = 0;
cursor_line[akt_id] = 0;
line_count[akt_id] = 0;

line_adr = txt_start[akt_id];
ln--;
while(ln-- && line_adr < txt_start[akt_id] + txt_lens[akt_id])
	{
	if (*line_adr == 0x11)
		line_adr += calc_clen(line_adr);

	line_adr += note_len(line_adr) + line_len(line_adr) + 5;
	line_count[akt_id]++;
	}
if (*line_adr == 0x11)
	line_adr += calc_clen(line_adr);

cursor_line[akt_id] = line_adr - txt_start[akt_id];

c_y[akt_id] = line_count[akt_id] * 16;
get_eline();

vst_font(vdi_handle, akt_font);
vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &fheight);

line_adr = txt_start[akt_id];
first_line[akt_id] = 0;
while(c_y[akt_id] > wh - fheight - 16 * ruler_flag)
	{
	if (*line_adr == 0x11)
		line_adr += calc_clen(line_adr);

	line_adr += note_len(line_adr) + line_len(line_adr) + 5;

	c_y[akt_id] -= 16;
	first_line[akt_id]++;
	}
calc_slider();
text_pos[akt_id] = line_adr - txt_start[akt_id];

full_redraw();
}

/* -------------------- */
/* | Zeile nach unten | */
/* -------------------- */
line_down()
{
extern unsigned char *skip_note();
int fheight, dummy;
register unsigned char *line_adr, *l_adr;

set_eline();

line_adr = txt_start[akt_id] + cursor_line[akt_id];
line_adr += note_len(line_adr) + line_len(line_adr) + 5;
if (*line_adr == 0x11)
	{
	get_lineal(line_adr);
	line_adr += calc_clen(line_adr);
	}

if (line_adr <= txt_start[akt_id] + txt_lens[akt_id])
  {
  cursor_line[akt_id] = line_adr - txt_start[akt_id];

  get_work(w_handles[akt_id]);

  mouse_off();
  show_cursor(wx, wy, akt_id);
  c_y[akt_id] += 16;
  line_count[akt_id]++;
  get_eline();

	vst_font(vdi_handle, akt_font);
	vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &fheight);
	if (c_y[akt_id] + fheight > wh - 16 * ruler_flag)
		while (c_y[akt_id] + fheight > wh - 16 * ruler_flag)
			{
			l_adr = txt_start[akt_id] + text_pos[akt_id];
			if (*l_adr == 0x11)
				l_adr += calc_clen(l_adr);
	
			l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	
			if (*l_adr == 0x11)
				l_adr += calc_clen(l_adr);
	
			c_y[akt_id] -= 16;
	
			text_pos[akt_id] = l_adr - txt_start[akt_id];
			first_line[akt_id]++;
			copy_block(wx, wy + 16 + 16 * ruler_flag, ww, wh - 16 - 16 * ruler_flag, wx, wy + 16 * ruler_flag);
			show_eline_ab(-24);
	
			calc_slider();
			}
	else
  	show_cursor(wx, wy, akt_id);
  }
}

/* ------------------- */
/* | Zeile nach oben | */
/* ------------------- */
line_up()
{
extern unsigned char *go_back();
register unsigned char *line_adr, *l_adr;

if (line_count[akt_id])
  {
  set_eline();

  line_adr = txt_start[akt_id] + cursor_line[akt_id];
  line_adr = go_back(line_adr);
	if (*line_adr == 0x11)
		line_adr += calc_clen(line_adr);

	l_adr = line_adr + line_len(line_adr) + note_len(line_adr) + 5;
	if (*l_adr == 0x11)
		search_lineal(line_adr);

  cursor_line[akt_id] = line_adr - txt_start[akt_id];

  get_work(w_handles[akt_id]);

  mouse_off();
  show_cursor(wx, wy, akt_id);

  c_y[akt_id] -= 16;
  line_count[akt_id]--;

  get_eline();

	if (c_y[akt_id] < 0)
		{
		l_adr = txt_start[akt_id] + text_pos[akt_id];
		l_adr = go_back(l_adr);

		c_y[akt_id] += 16;

		text_pos[akt_id] = l_adr - txt_start[akt_id];
		first_line[akt_id]--;
		copy_block(wx, wy + 16 * ruler_flag, ww, wh - 16 - 16 * ruler_flag, wx, wy + 16 + 16 * ruler_flag);
		show_eline_ab(-24);
	
		calc_slider();
		}
	else
	  show_cursor(wx, wy, akt_id);
  }
}

/* ----------------------- */
/* | Zeichen nach rechts | */
/* ----------------------- */
char_right()
{
int cell, left, right;

get_work(w_handles[akt_id]);

mouse_off();
show_cursor(wx, wy, akt_id);

c_c[akt_id]++;
c_p[akt_id] = skip_cont_ab(c_p[akt_id], 1);

show_cursor(wx, wy, akt_id);
}

/* ---------------------- */
/* | Zeichen nach links | */
/* ---------------------- */
char_left()
{
int cell, left, right;

if (c_c[akt_id])
  {
 	get_work(w_handles[akt_id]);

  mouse_off();
  show_cursor(wx, wy, akt_id);

  c_c[akt_id]--;
  c_p[akt_id] = skip_control();

  show_cursor(wx, wy, akt_id);
  }
}

/* ------------------------ */
/* | Cursor an Zeilenende | */
/* ------------------------ */
cursor_toend()
{
get_work(w_handles[akt_id]);

mouse_off();
show_cursor(wx, wy, akt_id);

c_p[akt_id] = buf_len + 1;
calc_ccol();
c_p[akt_id] = skip_control();

show_cursor(wx, wy, akt_id);
}

/* -------------------------- */
/* | Cursor an Zeilenanfang | */
/* -------------------------- */
cursor_tobeg()
{
get_work(w_handles[akt_id]);

mouse_off();
show_cursor(wx, wy, akt_id);

c_c[akt_id] = 0;
c_p[akt_id] = skip_control();

show_cursor(wx, wy, akt_id);
}

/* --------------- */
/* | Fett an/aus | */
/* --------------- */
set_bold()
{
set_sstyle(1);
}

/* ----------------- */
/* | Kursiv an/aus | */
/* ----------------- */
set_ital()
{
set_sstyle(4);
}

/* ------------------------- */
/* | Unterstreichen an/aus | */
/* ------------------------- */
set_under()
{
set_sstyle(8);
}

/* --------------- */
/* | Hell an/aus | */
/* --------------- */
set_light()
{
set_sstyle(2);
}

/* ------------------- */
/* | Outlined an/aus | */
/* ------------------- */
set_outl()
{
set_sstyle(16);
}

/* -------------------- */
/* | Subscript an/aus | */
/* -------------------- */
set_sub()
{
if (akt_sstyle & 0x40)
	set_super();

set_sstyle(0x80);
}

/* ---------------------- */
/* | Superscript an/aus | */
/* ---------------------- */
set_super()
{
if (akt_sstyle & 0x80)
	set_sub();

set_sstyle(0x40);
}
