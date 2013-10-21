#include "extern.h"

/* ----------------- */
/* | Lineal an/aus | */
/* ----------------- */
void rul_onoff(void)
{
ruler_flag = !ruler_flag;

menu_icheck(menu_adr, MN_RULER, ruler_flag);
full_redraw();
}

/* ---------------- */
/* | Neues Lineal | */
/* ---------------- */
void edit_ruler(unsigned char *lineal_adr)
{
register int eo, r_whndl, i, c;
char old_lineal[259], old_linpar[6];
int dummy, mousek, inp, rpos;

strcpy(old_lineal, txt_lineal[akt_id]);
strncpy(old_linpar, txt_linpar[akt_id], 6);

rsrc_gaddr(ROOT, NEW_RULR, &form_adr);

form_center(form_adr, &fx, &fy, &fw, &fh);

r_whndl = wind_create(0, fx, fy, fw, fh);
wind_open(r_whndl, fx, fy, fw, fh);

form_adr[ST_10CPI].ob_state &= ~SELECTED;
form_adr[ST_12CPI].ob_state &= ~SELECTED;
form_adr[ST_17CPI].ob_state &= ~SELECTED;
form_adr[ST_05CPI].ob_state &= ~SELECTED;

make_asc((long)strlen(txt_lineal[akt_id]), 100L, form_adr[RULR_LEN].ob_spec.tedinfo->te_ptext);
form_adr[COLUMNS].ob_spec.free_string[0] = txt_linpar[akt_id][3];

if (txt_linpar[akt_id][4] > '0')
	{
	form_adr[LINE_SPC].ob_spec.free_string[0] = txt_linpar[akt_id][4];
	if (txt_linpar[akt_id][5] == '5')
		form_adr[LINE_SPC].ob_spec.free_string[1] = 0xAB;
	else
		form_adr[LINE_SPC].ob_spec.free_string[1] = ' ';
	}
else
	{
	form_adr[LINE_SPC].ob_spec.free_string[0] = 0xAB;
	form_adr[LINE_SPC].ob_spec.free_string[1] = 0;
	}

if (txt_linpar[akt_id][0] == 'P')
	form_adr[ST_PROP].ob_state |= SELECTED;
else
	form_adr[ST_PROP].ob_state &= ~SELECTED;

if (txt_linpar[akt_id][2] == 'T')
	{
	form_adr[TAB_JMP].ob_state |= SELECTED;
	form_adr[TAB_SPC].ob_state &= ~SELECTED;
	}
else
	{
	form_adr[TAB_SPC].ob_state |= SELECTED;
	form_adr[TAB_JMP].ob_state &= ~SELECTED;
	}

form_draw();

switch(txt_linpar[akt_id][1])
	{
	case 'P':
		form_adr[ST_10CPI].ob_state |= SELECTED;
		objc_draw(form_adr, ST_10CPI, MAX_DEPTH, fx, fy, fw, fh);
		break;

	case 'E':
		form_adr[ST_12CPI].ob_state |= SELECTED;
		objc_draw(form_adr, ST_12CPI, MAX_DEPTH, fx, fy, fw, fh);
		break;

	case 'S':
		form_adr[ST_17CPI].ob_state |= SELECTED;
		objc_draw(form_adr, ST_17CPI, MAX_DEPTH, fx, fy, fw, fh);
		break;

	case 'B':
		form_adr[ST_05CPI].ob_state |= SELECTED;
		objc_draw(form_adr, ST_05CPI, MAX_DEPTH, fx, fy, fw, fh);
		break;
	}

do
	{
	graf_mkstate(&dummy, &dummy, &mousek, &dummy);
	if (ruler_flag && (mousek != 1 || eo == COL_DWN || eo == COL_UP))
		{
		get_work(w_handles[akt_id]);
		redraw(w_handles[akt_id], wx, wy, ww, 16);
		mouse_on();
		}

	make_asc((long)strlen(txt_lineal[akt_id]), 100L, form_adr[RULR_LEN].ob_spec.tedinfo->te_ptext);
	objc_draw(form_adr, RULR_LEN, MAX_DEPTH, fx, fy, fw, fh);

	form_adr[COLUMNS].ob_spec.free_string[0] = txt_linpar[akt_id][3];
	objc_draw(form_adr, COLUMNS, MAX_DEPTH, fx, fy, fw, fh);

	if (txt_linpar[akt_id][4] > '0')
		{
		form_adr[LINE_SPC].ob_spec.free_string[0] = txt_linpar[akt_id][4];
		if (txt_linpar[akt_id][5] == '5')
			form_adr[LINE_SPC].ob_spec.free_string[1] = 0xAB;
		else
			form_adr[LINE_SPC].ob_spec.free_string[1] = ' ';
		}
	else
		{
		form_adr[LINE_SPC].ob_spec.free_string[0] = 0xAB;
		form_adr[LINE_SPC].ob_spec.free_string[1] = 0;
		}
	objc_draw(form_adr, LINE_SPC, MAX_DEPTH, fx, fy, fw, fh);
	
	eo = form_do(form_adr, 0) & 0x7FFF;
	switch(eo)
		{
		case ST_10CPI:
		case ST_12CPI:
		case ST_17CPI:
		case ST_05CPI:
			break;

		case SET_RTAB:
			if (sscanf(form_adr[TAB_WDTH].ob_spec.tedinfo->te_ptext, "%d", &inp) != EOF)
				for (i = 0, c = 0; i < strlen(txt_lineal[akt_id]); i++)
					if (txt_lineal[akt_id][i] != ' ')
						{
						c++;
						if (c == inp)
							{
							txt_lineal[akt_id][i] = 'T';
							c = 0;
							}
						else
							txt_lineal[akt_id][i] = '.';
						}
					else
						c = 0;
			break;

		case SET_RLEN:
			if (sscanf(form_adr[RULR_LEN].ob_spec.tedinfo->te_ptext, "%d", &inp) != EOF)
				{
				if (inp > 254)
					inp = 254;
					
				while(strlen(txt_lineal[akt_id]) > inp)
					txt_lineal[akt_id][strlen(txt_lineal[akt_id]) - 1] = 0;

				while(strlen(txt_lineal[akt_id]) < inp)
					strcat(txt_lineal[akt_id], ".");
				}
			break;

		case RULR_UP:
			if (strlen(txt_lineal[akt_id]) < 254)
				strcat(txt_lineal[akt_id], ".");
			break;

		case RULR_DWN:
			if (strlen(txt_lineal[akt_id]) > 0)
				txt_lineal[akt_id][strlen(txt_lineal[akt_id]) - 1] = 0;
			break;

		case LSPC_UP:
			if (txt_linpar[akt_id][4] < '4')
				if (txt_linpar[akt_id][5] == '0')
					txt_linpar[akt_id][5] = '5';
				else
					{
					txt_linpar[akt_id][5] = '0';
					txt_linpar[akt_id][4]++;
					}
			break;

		case LSPC_DWN:
			if (txt_linpar[akt_id][4] > '0')
				if (txt_linpar[akt_id][5] == '0')
					{
					txt_linpar[akt_id][5] = '5';
					txt_linpar[akt_id][4]--;
					}
				else
					txt_linpar[akt_id][5] = '0';
			break;

		case COL_DWN:
			if (txt_linpar[akt_id][3] > '1')
				{
				txt_linpar[akt_id][3]--;

				inp = strlen(txt_lineal[akt_id]);
				c = txt_linpar[akt_id][3] - '1';
				if (inp > c * 4)
					{
					inp -= c * 3;
					inp /= c + 1;
					rpos = 0;

					do
						{
						for (i = inp; i > 0; i--)
							txt_lineal[akt_id][rpos++] = '.';

						if (c)
							for (i = 3; i > 0; i--)
								txt_lineal[akt_id][rpos++] = ' ';

						}while(c--);

					txt_lineal[akt_id][rpos] = 0;
					}
				}
			break;

		case COL_UP:
			if (txt_linpar[akt_id][3] < '9')
				{
				txt_linpar[akt_id][3]++;

				inp = strlen(txt_lineal[akt_id]);
				c = txt_linpar[akt_id][3] - '1';
				if (inp > c * 4)
					{
					inp -= c * 3;
					inp /= c + 1;
					rpos = 0;

					do
						{
						for (i = inp; i > 0; i--)
							txt_lineal[akt_id][rpos++] = '.';

						if (c)
							for (i = 3; i > 0; i--)
								txt_lineal[akt_id][rpos++] = ' ';

						}while(c--);

					txt_lineal[akt_id][rpos] = 0;
					}
				}
			break;
		}
	}while(eo != RULR_OK && eo != RULR_CNC);

form_adr[eo].ob_state &= ~SELECTED;

if (eo == RULR_CNC)
	{
	strcpy(txt_lineal[akt_id], old_lineal);
	strncpy(txt_linpar[akt_id], old_linpar, 6);
	}
else
	{
	if (form_adr[TAB_SPC].ob_state & SELECTED)
		txt_linpar[akt_id][2] = 'S';
	else
		txt_linpar[akt_id][2] = 'T';

	if (form_adr[ST_PROP].ob_state & SELECTED)
		txt_linpar[akt_id][0] = 'P';
	else
		txt_linpar[akt_id][0] = 'N';
	
	if (form_adr[ST_10CPI].ob_state & SELECTED)
		txt_linpar[akt_id][1] = 'P';

	if (form_adr[ST_12CPI].ob_state & SELECTED)
		txt_linpar[akt_id][1] = 'E';

	if (form_adr[ST_17CPI].ob_state & SELECTED)
		txt_linpar[akt_id][1] = 'S';

	if (form_adr[ST_05CPI].ob_state & SELECTED)
		txt_linpar[akt_id][1] = 'B';

	add_ruler(lineal_adr);
	calc_slider();
	}

f_dial(FMD_SHRINK);
f_dial(FMD_FINISH);

wind_close(r_whndl);
wind_delete(r_whndl);
}

/* ---------------- */
/* | Lineal holen | */
/* ---------------- */
void get_lineal(char *adr)
{
register int i, j, k;

strncpy(txt_linpar[akt_id], adr + 1, 6);

j = 0;
i = 7;
while(adr[i])
	switch(adr[i])
		{
		case 'A':														/* n Points */
			for (k = adr[i + 1]; k > 0; k--)
				txt_lineal[akt_id][j++] = '.';
			i += 2;
			break;

		case 'B':														/* 3 Spaces */
			for (k = 3; k > 0; k--)
				txt_lineal[akt_id][j++] = ' ';
			i++;
			break;

		default:
			txt_lineal[akt_id][j++] = adr[i++];
		}

txt_lineal[akt_id][j] = 0;	

if (ruler_flag)
	{
	get_work(w_handles[akt_id]);
	redraw(w_handles[akt_id], wx, wy, ww, 16);
	}
}

/* -------------------------------- */
/* | Suche zurckliegendes Lineal | */
/* -------------------------------- */
void search_lineal(unsigned char *adr)
{
extern unsigned char *searchl_it();
register unsigned char *l_adr;

l_adr = searchl_it(adr);
get_lineal(l_adr);
}

/* ----------------- */
/* | Lineal suchen | */
/* ----------------- */
unsigned char *searchl_it(unsigned char *adr)
{
extern unsigned char *go_back();
register unsigned char *l_adr;

while(adr > txt_start[akt_id])
	{
	adr = go_back(adr);

	if (*adr == 0x11)
		return(adr);

	l_adr = adr + note_len(adr) + line_len(adr) + 5;
	if (*l_adr == 0x11)
		return(l_adr);
	}
}

/* ------------------- */
/* | Lineal einfgen | */
/* ------------------- */
void add_ruler(unsigned char *l_adr)
{
extern unsigned char *go_back();

char ruler[259];
register int l;

pack_ruler(ruler);

l_adr = go_back(l_adr);
if (*l_adr != 0x11 && l_adr > txt_start[akt_id])
	l_adr += note_len(l_adr) + line_len(l_adr) + 5;

if (*l_adr != 0x11)
	{
	move_mem(l_adr, 8 + strlen(ruler));
	*l_adr = 0x11;
	txt_fill += 8 + strlen(ruler);
	txt_lens[akt_id] += 8 + strlen(ruler);

	if (l_adr <= txt_start[akt_id] + text_pos[akt_id])
		text_pos[akt_id] += 8 + strlen(ruler); 

	if (l_adr <= txt_start[akt_id] + cursor_line[akt_id])
		cursor_line[akt_id] += 8 + strlen(ruler); 

	if (l_adr <= line_gadr)
		line_gadr += 8 + strlen(ruler); 
	}
else
	if (strlen(l_adr) != strlen(ruler) + 7)
		{
		l = strlen(l_adr);

		move_mem(l_adr + 1, strlen(ruler) + 7 - l); 
		txt_fill += strlen(ruler) + 7 - l; 
		txt_lens[akt_id] += strlen(ruler) + 7 - l; 

		if (l_adr <= txt_start[akt_id] + text_pos[akt_id])
			text_pos[akt_id] += strlen(ruler) + 7 - l; 

		if (l_adr <= txt_start[akt_id] + cursor_line[akt_id])
			cursor_line[akt_id] += strlen(ruler) + 7 - l; 

		if (l_adr <= line_gadr)
			line_gadr += strlen(ruler) + 7 - l;
		}

memmove(l_adr + 1, txt_linpar[akt_id], 6);
strcpy(l_adr + 7, ruler);
}

/* ----------------- */
/* | Lineal packen | */
/* ----------------- */
void pack_ruler(unsigned char *p_adr)
{
register int i, j;

i = 0;
j = 0;
while(i < strlen(txt_lineal[akt_id]))
	{
	if (txt_lineal[akt_id][i] != '.' || txt_lineal[akt_id][i + 1] != '.')
		if (txt_lineal[akt_id][i] == ' ')
			{
			p_adr[j++] = 'B';
			i += 3;
			}
		else
			p_adr[j++] = txt_lineal[akt_id][i++];
	else
		{
		p_adr[j++] = 'A';
		p_adr[j] = 0;
		while(txt_lineal[akt_id][i++] == '.')
			p_adr[j]++;

		i--;
		j++;
		}
	}
p_adr[j] = 0;
}

/* -------------------- */
/* | Tabulator setzen | */
/* -------------------- */
void set_tab(void)
{
register int p;

p = (mousex - wx - 24) >> 3;
if (p >= 0)
	{
	switch(txt_lineal[akt_id][p])
		{
		case '.':
			txt_lineal[akt_id][p] = 'T';
			break;

		case 'T':
			txt_lineal[akt_id][p] = 'D';
			break;

		case 'D':
			txt_lineal[akt_id][p] = '.';
			break;
		}

	add_ruler(searchl_it(txt_start[akt_id] + cursor_line[akt_id]));

	redraw(w_handles[akt_id], wx, wy, ww, 16);
	}
}

/* ---------------- */
/* | Neues Lineal | */
/* ---------------- */
void new_ruler(void)
{
edit_ruler(txt_start[akt_id] + cursor_line[akt_id]);
}

/* ---------------- */
/* | Neues Lineal | */
/* ---------------- */
void edit_aktruler(void)
{
edit_ruler(searchl_it(txt_start[akt_id] + cursor_line[akt_id]));
}

/* ------------------ */
/* | Lineal l”schen | */
/* ------------------ */
void del_ruler(void)
{
register unsigned char *r_pos;
register int len;

r_pos = searchl_it(txt_start[akt_id] + cursor_line[akt_id]);
if (r_pos > txt_start[akt_id])
	{
	len = calc_clen(r_pos);
	move_mem(r_pos, -len);
	txt_fill -= len;
	txt_lens[akt_id] -= len;

	cursor_line[akt_id] -= len;
	line_gadr -= len;

	if (r_pos < text_pos[akt_id] + txt_start[akt_id])
		text_pos[akt_id] -= len;

	search_lineal(txt_start[akt_id] + cursor_line[akt_id]);
	}
}
