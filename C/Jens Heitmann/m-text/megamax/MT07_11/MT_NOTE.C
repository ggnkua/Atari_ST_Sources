#include "extern.h"

/* ------------------------ */
/* | Anzeigen der Notizen | */
/* ------------------------ */
dsp_notes()
{
extern unsigned char *go_back();

register unsigned char *l_adr;
register int eo, akt_d = -1, i;
unsigned char *notes[12];
long lines[12];
int dummy, mousey, ob_y;

set_eline();

rsrc_gaddr(ROOT, SHOWNOTE, &form_adr);

get_notes(notes, lines, txt_start[akt_id], 0L, 1);
form_adr[SN_SLD].ob_y = 0;

form_draw();

do
	{
	if (lines[11] == -1)
		{
		form_adr[SN_SLD].ob_y = form_adr[SN_SLDB].ob_height - form_adr[SN_SLD].ob_height;

		for (i = 11; i > 0 && lines[i] == -1; i--);
		get_notes(notes, lines, notes[i], lines[i], -1);
		}

	if (lines[0] == -1)
		{
		form_adr[SN_SLD].ob_y = 0;

		for (i = 0; i < 11 && lines[i] == -1; i++);
		get_notes(notes, lines, notes[i], lines[i], 1);
		}

	objc_draw(form_adr, SN_BKG, MAX_DEPTH, fx, fy, fw, fh);
	objc_draw(form_adr, SN_SLDB, MAX_DEPTH, fx, fy, fw, fh);

	eo = form_do(form_adr, 0);

	if ((eo & 0x7FFF) >= SN_LINE1 && (eo & 0x7FFF) <= SN_LINEC)
		akt_d = (eo & 0x7FFF) - SN_LINE1;
	else
		switch(eo & 0x7FFF)
			{
			case SN_SHOW:
				form_adr[SN_SHOW].ob_state &= ~SELECTED;

				if (akt_d > -1)
					{
					note_dialog(notes[akt_d]);

					rsrc_gaddr(ROOT, SHOWNOTE, &form_adr);
					form_draw();
					}
				break;
		
			case SN_SLDB:
				graf_mkstate(&dummy, &mousey, &dummy, &dummy);
				objc_offset(form_adr, SN_SLD, &dummy, &ob_y);

				if (mousey < ob_y && lines[0] > -1)
					get_notes(notes, lines, notes[0], lines[0], -1);

				if (mousey > ob_y + form_adr[SN_SLD].ob_height && lines[11] > -1)
					get_notes(notes, lines, notes[11], lines[11], 1);

				break;

			case SN_UP:
				if (lines[0] > -1)
					get_notes(notes, lines, notes[10], lines[10], -1);
				break;

			case SN_DOWN:
				if (lines[11] > -1)
					get_notes(notes, lines, notes[1], lines[1], 1);
				break;

			default:
				eo &= 0x7FFF;
			}

	}while(eo != SN_CANC && eo != SN_JMP);

form_adr[eo].ob_state &= ~SELECTED;
form_end();

if (eo == SN_JMP && akt_d > -1)
	{
	cursor_line[akt_id] = notes[akt_d] - txt_start[akt_id];
	line_count[akt_id] = lines[akt_d];

	get_work(w_handles[akt_id]);

	if (first_line[akt_id] > line_count[akt_id] || first_line[akt_id] < line_count[akt_id] - (wh >> 4))
		{
		first_line[akt_id] = lines[akt_d];
		l_adr = notes[akt_d];
		while(first_line[akt_id] > total_lines[akt_id] - (wh >> 4) && first_line[akt_id] > 0)
			{
			l_adr = go_back(l_adr);
			first_line[akt_id]--;
			}

		text_pos[akt_id] = l_adr - txt_start[akt_id];
		}

	c_y[akt_id] = (line_count[akt_id] - first_line[akt_id]) << 4;
	get_eline();
	full_redraw();
	}
else
	get_eline();
}

/* ------------------ */
/* | Notizen suchen | */
/* ------------------ */
get_notes(array, line_num, start, l, dir)
unsigned char *array[12];
register unsigned char *start;
register long *line_num;
short dir;
register long l;
{
extern unsigned char *go_back();

register int cnt, i;

for (i = 0; i < 12; array[i++] = (unsigned char *)"\0" - 5)
	line_num[i] = -1;

if (dir == 1)
	{
	cnt = 0;
	while(cnt < 12 && start < txt_start[akt_id] + txt_lens[akt_id])
		{
		if (*start == 0x11)
			start += calc_clen(start);

		if (note_len(start))
			{
			array[cnt] = start;
			line_num[cnt++] = l;
			}

		l++;
		start += note_len(start) + line_len(start) + 5;
		}
	}
else
	{
	cnt = 11;
	while(cnt > -1 && start > txt_start[akt_id] && *start != 0x11)
		{
		if (note_len(start))
			{
			array[cnt] = start;
			line_num[cnt--] = l;
			}

		l--;
		start = go_back(start);
		}
	}

for (i = 0; i < 12; i++)
	if (*(array[i] + 5) > 0xFC)
		form_adr[SN_LINE1 + i].ob_spec.free_string = (char *)array[i] + 6;
	else
		form_adr[SN_LINE1 + i].ob_spec.free_string = (char *)array[i] + 5;
}

/* ----------------------------- */
/* | Notiz anzeigen/bearbeiten | */
/* ----------------------------- */
note_dialog(line_adr)
register unsigned char *line_adr;
{
register unsigned char *l_adr;
register int i, eo, len_of_note;
int mousek, dummy;
char notiz[310];
char note_line[7][40];

mouse_on();

rsrc_gaddr(ROOT, NOTE_DIA, &form_adr);

for (i = 0; i < 7; i++)
	form_adr[N_LINE1 + i].ob_spec.tedinfo->te_ptext = note_line[i];

l_adr = line_adr + 5;
if (*l_adr > 0xFC)
	{
	form_adr[N_LOCK].ob_state |= CROSSED;

	if (*l_adr > 0xFD)
		{
		form_adr[N_KILL].ob_state |= DISABLED;
		form_adr[N_LOCK].ob_flags &= ~TOUCHEXIT;

		for (i = NOTE_SW; i <= N_LINE7; form_adr[i++].ob_flags &= ~EDITABLE);
		}

	l_adr++;
	}
else
	{
	for (i = NOTE_SW; i <= N_LINE7; form_adr[i++].ob_flags |= EDITABLE);

	form_adr[N_LOCK].ob_state &= ~CROSSED;
	form_adr[N_KILL].ob_state &= ~DISABLED;
	form_adr[N_LOCK].ob_flags |= TOUCHEXIT;
	}

if (note_len(line_adr))
	{
	strcpy( form_adr[NOTE_SW].ob_spec.tedinfo->te_ptext, l_adr);
	l_adr += strlen(l_adr) + 1;

	for (i = 0; i < 7; i++)
		{
		strcpy( note_line[i], l_adr);
		l_adr += strlen(l_adr) + 1;
		}
	}
else
	{
	form_adr[NOTE_SW].ob_spec.tedinfo->te_ptext[0] = 0;

	for (i = 0; i < 7; i++)
		note_line[i][0] = 0;
	}

form_draw();

do
	{
	eo = form_do(form_adr, 0) & 0x7FFF;

	if (eo == N_LOCK)
		{
		form_adr[N_LOCK].ob_state ^= CROSSED;
		objc_draw(form_adr, N_LOCK, 0, fx, fy, fw, fh);
		do
			{
			graf_mkstate(&dummy, &dummy, &mousek, &dummy);
			}while(mousek & 1);
		}

	}while(eo == N_LOCK);

form_adr[eo].ob_state &= ~SELECTED;

l_adr = line_adr + 5;
if (eo == N_OK && *l_adr < 0xFE)
	{
	notiz[0] = 0;
	if (form_adr[N_LOCK].ob_state & CROSSED)
		{
		notiz[0] = 0xFD;
		notiz[1] = 0;
		}

	strcat(notiz, form_adr[NOTE_SW].ob_spec.tedinfo->te_ptext);
	len_of_note = strlen(notiz) + 1;
	for (i = 0; i < 7; i++)
		{
		strcpy(notiz + len_of_note, note_line[i]);
		len_of_note += strlen( note_line[i] ) + 1;
		}
	}

if (eo == N_KILL && *l_adr < 0xFE)
	len_of_note = 0;

if ((eo == N_KILL || eo == N_OK ) && *l_adr < 0xFE)
	{
	i = len_of_note - note_len(line_adr);

	if (i)
		{
		move_mem(line_adr + 5, i);
		txt_fill += i;
		txt_lens[akt_id] += i;

		if (line_adr < text_pos[akt_id] + txt_start[akt_id])
			text_pos[akt_id] += i;

		if (line_adr < cursor_line[akt_id] + txt_start[akt_id])
			cursor_line[akt_id] += i;

		if (line_adr < line_gadr)
			line_gadr += i;
		}

	memmove(line_adr + 5, notiz, len_of_note);
	*(line_adr + 1) = (len_of_note >> 8) | 0x80;
	*(line_adr + 2) = len_of_note;
	}

form_end();
}
