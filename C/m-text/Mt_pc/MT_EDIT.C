#include "extern.h"

static short calc_flag = FALSE;

/* ----------------------------- */
/* | Umschalten in Editormodus | */
/* ----------------------------- */
void swtch_edt(void)
{
if (modus[akt_id])
	{
	menu_icheck(menu_adr, MN_EDIT, TRUE);
	menu_icheck(menu_adr, MN_BRIEF, FALSE);

	modus[akt_id] = FALSE;
	full_redraw();
	}
}

/* ---------------------------- */
/* | Umschalten in Briefmodus | */
/* ---------------------------- */
void swtch_brf(void)
{
if (!modus[akt_id])
	{
	menu_icheck(menu_adr, MN_EDIT, FALSE);
	menu_icheck(menu_adr, MN_BRIEF, TRUE);

	modus[akt_id] = TRUE;
	full_redraw();
	}
}

/* ------------- */
/* | Editieren | */
/* ------------- */
void edit(int key)
{
if (akt_id == -1)
	return;

switch(key)
	{
	case 0x5000:												/* Cursor runter	*/
		line_down();
		break;

	case 0x4800:												/* Cursor hoch			*/
		line_up();
		break;

	case 0x4D00:												/* Cursor rechts		*/
		char_right();
		break;

	case 0x4B00:												/* Cursor links 		*/
		char_left();
		break;

	case 0x7400:												/* Control rechts 	*/
		cursor_toend();
		break;

	case 0x7300:												/* Control links		*/
		cursor_tobeg();
		break;

	case 0x537F:												/* Delete 					*/
		del_char();
		break;

	case 0x531F:												/* Control + Delete */
		kill_line();
		break;

	case 0xf09: 												/* TAB							*/
		break;

	case 0x4700:												/* Home 						*/
		go_screenb();
		break;

	case 0x7700:												/* Control + Home 	*/
		go_textbeg();
		break;

	case 0x4737:												/* Shift + Home 		*/
		go_end();
		break;

	case 0x6100:												/* UNDO							*/
		get_eline();
		show_eline_ab(0);
		break;

	case 0xD:
	case 0x1c0d:												/* Return 					*/
	case 0x720d:												/* Enter						*/
		set_paragraph();
		break;

	case 0x0e08:												/* Backspace				*/
		char_left();
		memmove(line_buffer + c_p[akt_id], line_buffer + c_p[akt_id] + 1, 511 - c_p[akt_id]);
		buf_len--;
		line_redundanz();
		c_p[akt_id] = skip_control();
		show_eline();
		break;

	default:
		if ((unsigned char)key > (unsigned char)31)
			write_char(key);
	}
}

/* ----------------------- */
/* | Zeile zurck suchen | */
/* ----------------------- */
unsigned char *go_back(unsigned char *line_adr)
{
line_adr -= 2;

while((*line_adr != 0x4 || *(line_adr - 1)) && line_adr > txt_start[akt_id])
	line_adr--;

if (line_adr > txt_start[akt_id])
	return(line_adr);

return(txt_start[akt_id]);
}

/* ------------------ */
/* | Zeile auslesen | */
/* ------------------ */
void get_eline(void)
{
extern unsigned char *skip_note();
register int i, zlen, cl;

if (akt_id == -1)
	return;

line_gadr = txt_start[akt_id] + cursor_line[akt_id];
if (line_gadr == txt_start[akt_id] + txt_lens[akt_id])
	i = zlen = 0;
else
	{
	i = zlen = line_len(line_gadr);
	line_gadr += note_len(line_gadr) + 5;
	memmove(line_buffer, line_gadr, --i);
	}

old_blen = zlen;
buf_len = i;

for (; i < 512; line_buffer[i++] = 0x08);

c_p[akt_id] = skip_control();

calc_slider();
}

/* ------------------------------ */
/* | Kontrollbytes berspringen | */
/* ------------------------------ */
int skip_control(void)
{
akt_sstyle = NORMAL;
akt_font = 1;
akt_fheight = 13;

c_x[akt_id] = 0;

return(skip_cont_ab(0, c_c[akt_id]));
}

/* ---------------------------------------- */
/* | Kontrollbytes berspringen ab Offset | */
/* ---------------------------------------- */
int skip_cont_ab(int j, int i)
{
register int cl, zw;
int cell, left, right, dummy;

i++;

vst_font(vdi_handle, akt_font);
vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &dummy);

while(i)
	{
	if (j < buf_len)
		{
		switch( line_buffer[j] )
			{
			case 0x0:
			case 0xD:
				j++;
				break;
									
			case 0x01:
				if (modus[akt_id])
					akt_sstyle = line_buffer[j + 1];
	
				j += 2;
				break;
	
			case 0x02:
				if (modus[akt_id])
					{
					akt_font = line_buffer[j + 1];
					akt_fheight = line_buffer[j + 2];
	
					vst_font(vdi_handle, akt_font);
					vst_height(vdi_handle, akt_fheight, &dummy, &dummy, &dummy, &dummy);
					}
					
				j += 3;
				break;
	
			case 0xF:
				zw = ((int)(line_buffer[j + 1] & 0x7F) << 8) | line_buffer[j + 2];
				if (zw)
					c_x[akt_id] += ((int)strlen(txt_lineal[akt_id]) << 3) - zw;

				j += 3;
				break;
	
			case 0xE:
				vqt_width(vdi_handle, ' ', &cell, &left, &right);
				c_x[akt_id] += cell * line_buffer[j + 1];
				j += 2;
				break;
				
			default:
				cl = calc_clen( &line_buffer[j] );
	
				if (cl == -1)
					{
					i--;
					if (i)
						{
						vqt_width(vdi_handle, line_buffer[j], &cell, &left, &right);
						c_x[akt_id] += cell;	
						j++;
						}
					}
				else
					j += cl;
			}
		}
	else
		{
		i--;
		if (i)
			{
			vqt_width(vdi_handle, ' ', &cell, &left, &right);
			c_x[akt_id] += cell * i;
			i = 0;
			}
		}
	}

if (akt_sstyle & 0xC0)
	akt_fheight = 6;

set_checks();

return(j);
}

/* --------------------- */
/* | Checkmarks setzen | */
/* --------------------- */
void set_checks(void)
{
static int last_sstyle = -1;

if (last_sstyle != akt_sstyle)
	{
	if ((last_sstyle ^ akt_sstyle) & 1)
		menu_icheck(menu_adr, MN_BOLD, akt_sstyle & 1);

	if ((last_sstyle ^ akt_sstyle) & 2)
		menu_icheck(menu_adr, MN_LIGHT, akt_sstyle & 2);

	if ((last_sstyle ^ akt_sstyle) & 4)
		menu_icheck(menu_adr, MN_ITALC, akt_sstyle & 4);

	if ((last_sstyle ^ akt_sstyle) & 8)
		menu_icheck(menu_adr, MN_UNDER, akt_sstyle & 8);

	if ((last_sstyle ^ akt_sstyle) & 16)
		menu_icheck(menu_adr, MN_OUTL, akt_sstyle & 16);

	if ((last_sstyle ^ akt_sstyle) & 0x80)
		menu_icheck(menu_adr, MN_SUBS, akt_sstyle & 0x80);

	if ((last_sstyle ^ akt_sstyle) & 0x40)
		menu_icheck(menu_adr, MN_SUPER, akt_sstyle & 0x40);

	last_sstyle = akt_sstyle;
	}

}

/* ------------------- */
/* | Zeile speichern | */
/* ------------------- */
void set_eline(void)
{
register unsigned char *line_adr;

line_adr = txt_start[akt_id] + cursor_line[akt_id];

if (line_gadr == txt_start[akt_id] + txt_lens[akt_id])
	if (!buf_len)
		return;
	else
		{
		move_mem((char *)line_adr, buf_len - old_blen + 6);

		txt_fill += buf_len - old_blen + 6;
		txt_lens[akt_id] += buf_len - old_blen + 6;

		line_adr[0] = 0x4;
		line_adr[1] = 0;
		line_adr[2] = 0;

		line_gadr = line_adr + 5;
		total_lines[akt_id]++;
		}
else
	{		
	move_mem((char *)line_gadr, buf_len - old_blen + 1);

	txt_fill += buf_len - old_blen + 1;
	txt_lens[akt_id] += buf_len - old_blen + 1;
	}

calc_align();

line_buffer[buf_len++] = 0;

*(line_adr + 3) = (buf_len >> 8) | 0x80;
*(line_adr + 4) = buf_len;

memmove(line_gadr, line_buffer, buf_len);
}

/* ------------------------- */
/* | Ausrichtung berechnen | */
/* ------------------------- */
void calc_align(void)
{
register char *line_adr, *line_end;
register int cl, i, j;

line_adr = line_buffer;
line_end = line_adr + buf_len;
while(line_adr < line_end)
	{
	cl = calc_clen(line_adr);
	if (cl == -1)
		break;
		
	if (*line_adr == 0xF)
		{
		i = 3;
		j = 0;
		while(line_adr + i < line_end)
			{
			cl = calc_clen(&line_adr[i]);
			
			if (cl == -1)
				j++;
			
			i += abs(cl);
			}	
			
		line_adr[1] = 0x80;
		line_adr[2] = 0;
		c_x[akt_id] = 0;
		
		skip_cont_ab(0, j);

		line_adr[1] = (c_x[akt_id] >> 8) | 0x80;
		line_adr[2] = c_x[akt_id];

		show_eline_ab(0);
		break;
		}
		
	line_adr += cl;
	}
}

/* ---------------------------- */
/* | Kontrollzeichenredundanz | */
/* ---------------------------- */
void line_redundanz(void)
{
int c_arr[20];
register int j, k, cl;

for (k = 0; k < 20; c_arr[k++] = -1);

j = 0;
while(j < buf_len)
	{
	cl = calc_clen(&line_buffer[j]);

	if (line_buffer[j] == 0xE && line_buffer[j] == 0)
		{
		memmove(&line_buffer[j], &line_buffer[j] + 2, buf_len - 2);
		buf_len -= 2;
		cl = 0;
		}
		
	if (cl == -1)
		for (k = 0; k < 20; c_arr[k++] = -1);
	else
		if (line_buffer[j] < 20 && line_buffer[j] != 9 && line_buffer[j] != 8 &&
				line_buffer[j] != 0x18)
			if (c_arr[line_buffer[j]] > -1)
				{
				for (k = 0; k < 20; k++)
					if (c_arr[k] > c_arr[line_buffer[j]])
						c_arr[k] -= calc_clen(&line_buffer[c_arr[line_buffer[j]]]);

				j -= calc_clen(&line_buffer[c_arr[line_buffer[j]]]);
				buf_len -= calc_clen(&line_buffer[c_arr[line_buffer[j]]]);

				memmove(line_buffer + c_arr[line_buffer[j]],
				       	line_buffer + c_arr[line_buffer[j]] + 
							 	calc_clen(&line_buffer[c_arr[line_buffer[j]]]),
  						 	buf_len + calc_clen(&line_buffer[c_arr[line_buffer[j]]]) -
							 	c_arr[line_buffer[j]]);

				c_arr[line_buffer[j]] = j;
				}
			else
				c_arr[line_buffer[j]] = j;

	j += abs(cl);
	}
}

/* ------------------------ */
/* | Leerzeile hinzufgen | */
/* ------------------------ */
void add_empty(void)
{
register unsigned char *l_adr;

l_adr = txt_start[akt_id] + cursor_line[akt_id];
move_mem(l_adr, 7);
memmove(l_adr, "\4\0\0\0\2\r\0", 7);
txt_fill += 7;
txt_lens[akt_id] += 7;
}

/* ---------------------------- */
/* | Bytes in Buffer einfgen | */
/* ---------------------------- */
void insert_bytes(int des, char *src, int len)
{
memmove(line_buffer + des + len, line_buffer + des, 512 - len - des);
memmove(line_buffer + des, src, len);
buf_len += len;

c_p[akt_id] = skip_control();
}

/* --------------------- */
/* | Speicher schieben | */
/* --------------------- */
move_mem(char *von, int dif)
{
register long a;

a = (mtext_mem + txt_fill) - von;

memmove(von + dif, von, a);
 
/*if (dif > 0)
	{
	while(a >= 32760)
		{
		memmove(von + a - 32760 + dif, von + a - 32760, 32760);
		a -= 32760; 
		}

	if (a > 0)
		memmove(von + dif, von, (int)a);
	}
else
	if (dif < 0)
		{
		while(a > 32760)
			{
			memmove(von, von - dif, 32760);
			a -= 32760; 
			von += 32760;
			}

		if (a > 0)
			memmove(von, von - dif, (int)a);	
		}*/
}

/* ------------------------------------- */
/* | Speicher schieben (long distance) | */
/* ------------------------------------- */
move_meml(char *von, long dif)
{
register long a;

a = (mtext_mem + txt_fill) - von;
memmove(von +  dif, von, a);
/*if (dif > 0)
	{
	while(a >= 32760)
		{
		memmove(von + a - 32760 + dif, von + a - 32760, 32760);
		a -= 32760; 
		}

	if (a > 0)
		memmove(von + dif, von, (int)a);
	}
else
	if (dif < 0)
		{
		while(a > 32760)
			{
			memmove(von, von - dif, 32760);
			a -= 32760; 
			von += 32760;
			}

		if (a > 0)
			memmove(von, von - dif, (int)a);	
		}*/
}

/* ------------------- */
/* | Z„hle Spalte ab | */
/* ------------------- */
void calc_ccol(void)
{
register int i, j;

c_c[akt_id] = -1;

i = 0;
while(i < c_p[akt_id])
	{
	j = calc_clen(&line_buffer[i]);

	if (j < 0)
		c_c[akt_id]++;

	i += abs(j);
	}

if (c_c[akt_id] == -1)
	c_c[akt_id] = 0;
}

/* ------------------- */
/* | Textstil setzen | */
/* ------------------- */
void set_sstyle(int type)
{
register int a, j;

if (!c_c[akt_id])
	a = 0;
else
	{
	c_x[akt_id] = 0;
	akt_sstyle = NORMAL;
	akt_font = 1;
	akt_fheight = 13;

	a = skip_cont_ab(0, c_c[akt_id] - 1);
	skip_cont_ab(a, 1);
	}

akt_sstyle ^= type;
for (; a < c_p[akt_id]; a++)
	{
	if (line_buffer[a] == 0x01)
		{
		line_buffer[a + 1] = akt_sstyle;
		break;
		}

	j = calc_clen(&line_buffer[a]);
	if (j > -1)
		a += j - 1;
	}

if (a == c_p[akt_id])
	{
	memmove(line_buffer + c_p[akt_id] + 2, line_buffer + c_p[akt_id], buf_len - c_p[akt_id] + 1);
	line_buffer[c_p[akt_id]] = 0x01;
	line_buffer[c_p[akt_id] + 1] = akt_sstyle;
	buf_len += 2;
	c_p[akt_id] += 2;
	}

for (a += 2; a < buf_len; a++)
	{
	if (line_buffer[a] == 0x01)
		if ((line_buffer[a + 1] & type) != (akt_sstyle & type))
			line_buffer[a + 1] ^= type;
		else
			break;

	j = calc_clen(&line_buffer[a]);
	if (j > -1)
		a += j - 1;
	}

set_checks();
show_eline();
}

/* --------------- */
/* | Font setzen | */
/* --------------- */
void set_fontd(int fontnr, int fonthg)
{
register int a, j;

if (!c_c[akt_id])
	a = 0;
else
	{
	c_x[akt_id] = 0;
	akt_sstyle = NORMAL;
	akt_font = 1;
	akt_fheight = 13;

	a = skip_cont_ab(0, c_c[akt_id] - 1);
	skip_cont_ab(a, 1);
	}

for (; a < c_p[akt_id]; a++)
	{
	if (line_buffer[a] == 0x02)
		{
		line_buffer[a + 1] = fontnr;
		line_buffer[a + 2] = fonthg;
		break;
		}

	j = calc_clen(&line_buffer[a]);
	if (j > -1)
		a += j - 1;
	}

if (a == c_p[akt_id])
	{
	memmove(line_buffer + c_p[akt_id] + 3, line_buffer + c_p[akt_id], buf_len - c_p[akt_id]);
	line_buffer[c_p[akt_id]] = 0x02;
	line_buffer[c_p[akt_id] + 1] = fontnr;
	line_buffer[c_p[akt_id] + 2] = fonthg;
	buf_len += 3;
	c_p[akt_id] += 3;
	}

akt_font = fontnr;
akt_fheight = fonthg;

full_redraw();
}

/* ------------------------------- */
/* | Kontrollbytel„nge ermitteln | */
/* ------------------------------- */
int calc_clen(char *adr)
{
switch(*adr)
	{
	case 0x01:
	case 0x03:
	case 0x0E:
		return(2);

	case 0x02:
	case 0x0F:
		return(3);

	case 0x04:
		return(5);

	case 0x0D:
	case 0x00:
	case 0x12:
		return(1);

	case 0x11:
		return(strlen(adr) + 1);

	case 0x18:
		return(strlen(adr + 6) + 7);

	default:
		return(-1);
	}
}

/* -------------------- */
/* | Notizl„nge holen | */
/* -------------------- */
int note_len(unsigned char *line_adr)
{
register int l;

l = ((int)*(line_adr + 1) << 8) + *(line_adr + 2);

return(l & 0x7FFF);
}

/* --------------------- */
/* | Zeilenl„nge holen | */
/* --------------------- */
int line_len(unsigned char *line_adr)
{
register int l;

l = ((int)*(line_adr + 3) << 8) + *(line_adr + 4);

return(l & 0x7FFF);
}

/* -------------------- */
/* | Calc-Flag setzen | */
/* -------------------- */
void calc_slider(void)
{
calc_flag = TRUE;
}

/* -------------------- */
/* | Slider berechnen | */
/* -------------------- */
void do_slider_calc(void)
{
register int rel_pos, rel_hg;
static int old_pos[4] = {0, 0, 0, 0};
static int old_hg[4] = {0, 0, 0, 0};
static int old_hpos[4] = {0, 0, 0, 0};
static int old_hlen[4] = {0, 0, 0, 0};

if (calc_flag)
	{
	get_work(w_handles[akt_id]);
	
	if (ruler_flag)
		wh -= 16;
	
	if (total_lines[akt_id] > (wh >> 4))
		{
		rel_pos = first_line[akt_id] * 1000 / (total_lines[akt_id] - (wh >> 4) + 1);
		rel_hg = (wh >> 4) * 1000 / (total_lines[akt_id] + 1);
		}
	else
		{
		rel_pos = 0;
		rel_hg	= 1000;
		}
	
	if (rel_pos != old_pos[akt_id])
		{
		wind_set(w_handles[akt_id], WF_VSLIDE, rel_pos, 0, 0, 0);
		old_pos[akt_id] = rel_pos;
		}
	
	if (rel_hg != old_hg[akt_id])
		{
		wind_set(w_handles[akt_id], WF_VSLSIZE, rel_hg, 0, 0, 0);
		old_hg[akt_id] = rel_hg;
		}
	
	if (ruler_flag)
		wh += 16;
	
	if (strlen(txt_lineal[akt_id]) > (ww >> 3) - 3)
		{
		rel_pos = (long)0 * 1000 / (strlen(txt_lineal[akt_id]) + 3 - (ww >> 3)); /* ! */
		rel_hg = (long)((ww >> 3) - 3) * 1000 / strlen(txt_lineal[akt_id]);
		}
	else
		{
		rel_pos = 0;
		rel_hg	= 1000;
		}
	
	if (rel_pos != old_hpos[akt_id])
		{
		wind_set(w_handles[akt_id], WF_HSLIDE, rel_pos, 0, 0, 0);
		old_hpos[akt_id] = rel_pos;
		}
	
	if (rel_hg != old_hlen[akt_id])
		{
		wind_set(w_handles[akt_id], WF_HSLSIZE, rel_hg, 0, 0, 0);
		old_hlen[akt_id] = rel_hg;
		}

	calc_flag = FALSE;
	}
}

/* ----------------- */
/* | Cursor setzen | */
/* ----------------- */
void set_cursor(void)
{
register int p;
register unsigned char *l_adr;
int dummy;

if (!modus[akt_id])
	return;
	
graf_mkstate(&mousex, &mousey, &mousek, &dummy);
if (mousek & 2)
	{
	move_pic();
	return;
	}

p = ((mousey - wy) >> 4) - ruler_flag;

if (((p + ruler_flag) << 4) > wh - 16 || mousex > wx + ww)
	return;

if (mousex < wx + 24 && mousex >= wx + 15)
	{
	note_click(p);
	return;
	}

if (mousex < wx + 15 && mousex >= wx + 7)
	{
	inhlt_click(p);
	return;
	}

if (first_line[akt_id] + p > total_lines[akt_id])
	return;

mouse_off();

show_cursor(wx, wy, akt_id);

set_eline();

c_y[akt_id] = p << 4;
l_adr = txt_start[akt_id] + text_pos[akt_id];
line_count[akt_id] = first_line[akt_id] + p;

while(p--)
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);
	}

cursor_line[akt_id] = l_adr - txt_start[akt_id];

search_lineal(l_adr);
get_eline();

calc_cofx(mousex - wx - 24);

show_cursor(wx, wy, akt_id);
}

/* ------------------ */
/* | Notiz anzeigen | */
/* ------------------ */
void note_click(int p)
{
register unsigned char *l_adr;

l_adr = txt_start[akt_id] + text_pos[akt_id];

while(p--)
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);
	}

if (note_len(l_adr))
	{
	note_dialog(l_adr);
	full_redraw();
	}
}

/* ------------------ */
/* | Notiz anzeigen | */
/* ------------------ */
void inhlt_click(int p)
{
register unsigned char *l_adr;

l_adr = txt_start[akt_id] + text_pos[akt_id];

while(p--)
	{
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);
	}

if (note_len(l_adr))
	{
	note_dialog(l_adr);
	full_redraw();
	}
}

/* ---------------------- */
/* | Zeichen nach Pos x | */
/* ---------------------- */
void calc_cofx(int xd)
{
register int p, c;

akt_sstyle = NORMAL;
akt_font = 1;
akt_fheight = 13;
c_x[akt_id] = 0;
c = 0;
p = 0;

do
	{
	p = skip_cont_ab(p, 1);
	c++;
	}while(c_x[akt_id] <= xd);

c_c[akt_id] = c - 1;
c_p[akt_id] = skip_control();
}

/* ------------------ */
/* | Notiz erzeugen | */
/* ------------------ */
void new_note(void)
{
if (cursor_line[akt_id] == txt_lens[akt_id] && !buf_len)
	add_empty();
else
	set_eline();

note_dialog(txt_start[akt_id] + cursor_line[akt_id]);
full_redraw();

get_eline();
}

/* ------------------------------------- */
/* | Etwas aus oberen Speicher l”schen | */
/* ------------------------------------- */
void remove_one(unsigned char *kil_adr, long len)
{
register unsigned char *mov_adr;
register int i, cl, type;
register unsigned char *adr, *l_beg;
unsigned char *comp_adr, *l_pos, *new_adr;
fontform *fnt;

while(kil_adr > mtext_mem + mtext_mlen - pic_sub)
	{
	mov_adr = 0;

	for (i = 0; i < 4; i++)
		if (w_handles[i] > -1)
			{
			adr = txt_start[i];
			while(adr < txt_start[i] + txt_lens[i])
				{
				if (*adr == 0x11)
					adr += calc_clen(adr);
			
				l_beg = adr + note_len(adr) + 5;
				do
					{
					if (*l_beg == 0x18)
						{
						comp_adr = (unsigned char *)(((long)*(l_beg + 2) << 16) | ((long)*(l_beg + 3) << 8) | (long)*(l_beg + 4));
	
						if (comp_adr > mov_adr && comp_adr < kil_adr)
							{
							mov_adr = comp_adr;
							l_pos = l_beg + 1;
							type = 0;
							}
						}
	
					cl = calc_clen(l_beg);
					l_beg += cl;
					}while(cl > 0 && *l_beg);
			
				adr += note_len(adr) + line_len(adr) + 5;
				}

			fnt = fnt_point[i];
			comp_adr = (unsigned char *)&fnt_point[i];
			if (fnt > 0)
				do
					{
					if ((long)fnt > (long)mov_adr && (long)fnt < (long)kil_adr)
						{
						mov_adr = (unsigned char *)fnt - 4;
						l_pos = comp_adr;
						type = 1;
						}
				
					comp_adr = (unsigned char *)&fnt[0].next;
					fnt = (fontform *)fnt[0].next;

					}while(fnt);
			}

	if (!mov_adr)
		break;

	new_adr = mov_adr + len;
	if ((int)new_adr == 4 || !(char)new_adr)
		{
		new_adr -= 2;
		len -= 2;
		}

	memmove(new_adr, mov_adr, (int)(kil_adr - mov_adr));
	kil_adr = mov_adr;

	if (type)
		new_adr += 4;

	*(l_pos + 1) = (long)new_adr >> 16;
	*(l_pos + 2) = (long)new_adr >> 8;
	*(l_pos + 3) = (unsigned char)new_adr;

	if (type)
		{
		fnt = (fontform *)new_adr;
		fnt[0].ch_ofst = (int *)((long)fnt[0].ch_ofst + len);
		fnt[0].fnt_dta  = (int *)((long)fnt[0].fnt_dta + len);
		}
	}

pic_sub -= len;

if (fnt_point[akt_id] > 0)
	{
	vst_unload_fonts(vdi_handle, 1);
	inst_font();
	}
}

/* ------------------------ */
/* | Inhaltsmarker setzen | */
/* ------------------------ */
void set_inhlt(void)
{
register int i, cl;

i = 0;
do
	{
	cl = calc_clen(&line_buffer[i]);

	if (line_buffer[i] == 0x12)
		{
		memmove(&line_buffer[i], &line_buffer[i + 1], --buf_len - i);
		break;
		}
	
	if (cl == -1)
		{
		memmove(line_buffer + 1, line_buffer, buf_len++);
		line_buffer[0] = 0x12;
		}
			
	i += cl;
	}while(cl > -1);

get_work(w_handles[akt_id]);
redraw(w_handles[akt_id], wx, wy, wx + 24, wy + wh - 1);
}

/* --------------------------- */
/* | Datum in Text schreiben | */
/* --------------------------- */
void writ_date(void)
{
insert_bytes(c_p[akt_id], "\26\26.\26\26.\26\26\26\26", 10);
show_eline();

show_cursor(wx, wy, akt_id);

c_c[akt_id] += 10;
c_p[akt_id] = skip_cont_ab(c_p[akt_id], 10);

show_cursor(wx, wy, akt_id);
}

/* -------------------------- */
/* | Zeit in Text schreiben | */
/* -------------------------- */
void writ_time(void)
{
insert_bytes(c_p[akt_id], "\25\25.\25\25", 5);
show_eline();

show_cursor(wx, wy, akt_id);

c_c[akt_id] += 5;
c_p[akt_id] = skip_cont_ab(c_p[akt_id], 5);

show_cursor(wx, wy, akt_id);
}
