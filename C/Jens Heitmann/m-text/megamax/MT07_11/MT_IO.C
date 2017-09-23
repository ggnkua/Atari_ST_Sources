#include "extern.h"

/* -------------- */
/* | Text laden | */
/* -------------- */
load_text()
{
extern long read_pack();

register int i, f_handle;
FILE *inf_f;
char buf[42];

for (i = 0; i < 4 && w_handles[i] > -1; i++);

if (i == 4)
	{
	form_alert(1, ONLY_4);
	return(FALSE);
	}

if ( fsel(pathes[i], ".TXT") )
	{
	akt_id = i;
	f_handle = Fopen( pathes[i], 0);
	if (f_handle == -33)
		if (form_alert(1, NEW_ASK) == 2)
 			return(FALSE);
		else
			init_new(i);

	open_txtw(i);

	c_x[i] = 0;
	c_y[i] = 0;
	c_c[i] = 0;
	line_count[i] = 0;
	first_line[i] = 0;

	if (f_handle > 0)
		{
		txt_first[i] = FALSE;

		inf_f = fopen(pathes[i], "rb");
		
		if (inf_f)
			{
			load_info("   Lade...", DOING);
			load_info(pathes[i], LOADFILE);

			fgets(buf, 6, inf_f);

			if (!strncmp(buf, "MTU", 3))
				txt_type[akt_id] = 0;
			else
				if (!strncmp(buf, "MTP", 3))
					txt_type[akt_id] = 1;

			for (i = 0; i < 10; i++)
				{
				fgets(buf, 42, inf_f);
				*strchr(buf, '\r') = 0;
				strcpy(txt_infos[akt_id][i], buf);
				}

			fgets(buf, 34, inf_f);
			*strchr(buf, '\r') = 0;
			strcpy(txt_bearb[akt_id][0], buf);

			if (txt_bearb[akt_id][0][0] != 'E')
				for (i = 1; i < 10; i++)
					{
					fgets(buf, 34, inf_f);
					*strchr(buf, '\r') = 0;
					strcpy(txt_bearb[akt_id][i], buf);
					}

			txt_bearb[akt_id][10][0] = 0;

			for (i = 0; i < 4; i++)
				{
				fgets(buf, 15, inf_f);
				*strchr(buf, '\r') = 0;
				strcpy(txt_fonts[akt_id][i], buf);
				}

			if (!txt_type[akt_id])
				for (i = 0; i < 24; i++)
					{
					fgets(buf, 28, inf_f);
					*strchr(buf, '\r') = 0;
					strcpy(kopffuss[akt_id][i], buf);
					}

			Fseek(ftell(inf_f), f_handle, 0);

			fclose(inf_f);
			}

		txt_start[akt_id] = mtext_mem + txt_fill;
		if (!txt_type[akt_id])
			txt_lens[akt_id] = Fread(f_handle, mtext_mlen - txt_fill, txt_start[akt_id]);
		else
			{
			read_pack(kopffuss[akt_id], f_handle);
			txt_lens[akt_id] = read_pack(txt_start[akt_id], f_handle);
			}

		txt_fill += txt_lens[akt_id];

		Fclose(f_handle);
		}	

	if (*txt_start[akt_id] == 0x11)
		{
		get_lineal(txt_start[akt_id]);
		cursor_line[akt_id] = calc_clen(txt_start[akt_id]);
		}
	else
		cursor_line[akt_id] = 0;

	text_pos[akt_id] = cursor_line[akt_id];

	load_txt_fonts();
	load_pictures();
	restyle_notes();
	load_info(0L, -1);
	mouse_on();

	if (txt_bearb[akt_id][0][0] != 'E')
		text_info();

	get_eline();
	}

return(FALSE);
}

/* ---------------------- */
/* | Altnotizen sperren | */
/* ---------------------- */
restyle_notes()
{
register unsigned char *l_adr, *l_end;

l_adr = txt_start[akt_id];
l_end = l_adr + txt_lens[akt_id];
while(l_adr < l_end)
	{
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	if (note_len(l_adr))
		if (*(l_adr + 5) == 0xFE)
			*(l_adr + 5) = 0xFF;

	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	}
}

/* ------------------- */
/* | Textfonts laden | */
/* ------------------- */
load_txt_fonts()
{
char load_fnt[80];
register int i;

strcpy(load_fnt, font_path);
for (i = 0; i < 4; i++)
	if (txt_fonts[akt_id][i][0])
		{
		strcpy(rindex(load_fnt, '\\') + 1, txt_fonts[akt_id][i]);
		load_info(load_fnt, FILE2);
		load_font_in(load_fnt, i + 2);
		vqt_name(vdi_handle, i + 2, tfont_names[akt_id][i]);
		}
}

/* ---------------------- */
/* | Textfenster ”ffnen | */
/* ---------------------- */
open_txtw(i)
register int i;
{
get_work(0);

w_handles[i] = wind_create(NAME|INFO|CLOSER|FULLER|MOVER|SIZER|UPARROW|
													 DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE,
													 wx, wy, ww, wh);

wind_set(w_handles[i], WF_NAME, pathes[i], 0, 0);
wind_set(w_handles[i], WF_INFO, txt_infol[i], 0, 0);

wind_open(w_handles[i], w_koor[i][0], w_koor[i][1], w_koor[i][2], w_koor[i][3]);
}

/* ----------------------------- */
/* | Neuen Text initialisieren | */
/* ----------------------------- */
init_new(index)
register int index;
{
register int i;

txt_lens[index] = 10;
txt_start[index] = mtext_mem + txt_fill;
memmove(txt_start[index], "\21NPS110AA\0", 10);
txt_fill += 10;

for (i = 0; i < 10; i++)
	{
	txt_infos[index][i][0] = 0;
	txt_bearb[index][i][0] = 0;
	}

txt_bearb[index][10][0] = 0;
txt_first[index] = TRUE;
txt_type[index] = 1;
}

/* ---------------------- */
/* | Text speichern als | */
/* ---------------------- */
save_tsva()
{
register int i, f_handle, eo;
FILE *inf_f;

rsrc_gaddr(ROOT, FILE_TYP, &form_adr);
eo = dialog(0) & 0x7FFF;

switch(eo)
	{
	case MT_COMP:
		txt_type[akt_id] = 1;
		break;

	case MT_UNCMP:
		txt_type[akt_id] = 0;
		break;
	
	case TYP_ABBR:
		return;
	}

if ( fsel(pathes[akt_id], ".TXT") )
	save_text();
}

/* ------------------ */
/* | Text speichern | */
/* ------------------ */
save_text()
{
register int i, f_handle;
FILE *inf_f;

set_eline();
lock_notes();

inf_f = fopen(pathes[akt_id], "bw");
	
if (inf_f)
	{
	if (!txt_type[akt_id])
		fputs("MTU\r\n", inf_f);
	else
		fputs("MTP\r\n", inf_f);

	for (i = 0; i < 10; i++)
		{
		fputs(txt_infos[akt_id][i], inf_f);
		fputs("\r\n", inf_f);
		}

	if (txt_bearb[akt_id][0][0] == 'E')
		fputs(txt_bearb[akt_id][0], inf_f);
	else
		{
		for (i = 1; i < 10; i++)
			{
			fputs(txt_bearb[akt_id][i], inf_f);
			fputs("\r\n", inf_f);
			}
	
		if (!txt_first[akt_id])
			{
			fwrite(txt_bearb[akt_id][10], 1, 2, inf_f);
			putc('.', inf_f);
	
			fwrite(txt_bearb[akt_id][10] + 2, 1, 2, inf_f);
			putc('.', inf_f);
		
			fwrite(txt_bearb[akt_id][10] + 4, 1, 4, inf_f);
			putc(' ', inf_f);
			fputs(txt_bearb[akt_id][10] + 8, inf_f);
			}
		}

	fputs("\r\n", inf_f);

	for (i = 0; i < 4; i++)
		{
		fputs(txt_fonts[akt_id][i], inf_f);
		fputs("\r\n", inf_f);
		}

	if (!txt_type[akt_id])
		for (i = 0; i < 24; i++)
			{
			fputs(kopffuss[akt_id][i], inf_f);
			fputs("\r\n", inf_f);
			}
		
	fclose(inf_f);

	f_handle = Fopen( pathes[akt_id], 2);
	if (f_handle > 0)
		{
		Fseek(0L, f_handle, 2);

		switch(txt_type[akt_id])
			{
			case 0:
				load_info("Speichere...", DOING);
				load_info(pathes[akt_id], LOADFILE);
				Fwrite(f_handle, txt_lens[akt_id], txt_start[akt_id]);
				break;

			case 1:
				load_info("Packe...", DOING);
				load_info(pathes[akt_id], LOADFILE);
				write_pack(kopffuss[akt_id], 624L, f_handle);
				write_pack(txt_start[akt_id], txt_lens[akt_id], f_handle);
				break;
			}

		Fclose(f_handle);
		}	
	}

get_eline();

unlock_notes();
}

/* ---------------------- */
/* | Notizen vorsperren | */
/* ---------------------- */
lock_notes()
{
register unsigned char *l_adr, *l_end;

l_adr = txt_start[akt_id];
l_end = l_adr + txt_lens[akt_id];
while(l_adr < l_end)
	{
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	if (note_len(l_adr))
		if (*(l_adr + 5) == 0xFD)
			*(l_adr + 5) = 0xFE;

	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	}
}

/* ---------------------- */
/* | Notizen entsperren | */
/* ---------------------- */
unlock_notes()
{
register unsigned char *l_adr, *l_end;

l_adr = txt_start[akt_id];
l_end = l_adr + txt_lens[akt_id];
while(l_adr < l_end)
	{
	if (*l_adr == 0x11)
		l_adr += calc_clen(l_adr);

	if (note_len(l_adr))
		if (*(l_adr + 5) == 0xFE)
			*(l_adr + 5) = 0xFD;

	l_adr += note_len(l_adr) + line_len(l_adr) + 5;
	}
}

/* ------------	*/
/* | Ladeinfo | */
/* ------------ */
load_info(string, typ)
register char *string;
register int typ;
{
extern int fx, fy, fw, fh;
OBJECT *inf_adr;

switch(typ)
	{
	case DOING:
		rsrc_gaddr(ROOT, LOAD_INF, &inf_adr);
		inf_adr[DOING].ob_spec.free_string = string;
		inf_adr[FILE2].ob_flags |= HIDETREE;
		break;

	case LOADFILE:
		string = rindex(string, '\\') + 1;

		rsrc_gaddr(ROOT, LOAD_INF, &inf_adr);
		inf_adr[LOADFILE].ob_spec.free_string = string;

		form_center(inf_adr, &fx, &fy, &fw, &fh);
		objc_draw(inf_adr, ROOT, MAX_DEPTH, fx, fy, fw, fh);
		break;

	case FILE2:
		string = rindex(string, '\\') + 1;

		rsrc_gaddr(ROOT, LOAD_INF, &inf_adr);
		inf_adr[FILE2].ob_flags &= ~HIDETREE;
		strcpy(inf_adr[FILE2].ob_spec.free_string + 1, string);
		strcat(inf_adr[FILE2].ob_spec.free_string, ")");

		form_center(inf_adr, &fx, &fy, &fw, &fh);
		objc_draw(inf_adr, ROOT, MAX_DEPTH, fx, fy, fw, fh);
		break;

	case -1:
		rsrc_gaddr(ROOT, LOAD_INF, &inf_adr);
		form_center(inf_adr, &fx, &fy, &fw, &fh);
		f_dial(FMD_FINISH);
	}
}

