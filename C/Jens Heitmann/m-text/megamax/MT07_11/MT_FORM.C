#include "extern.h"

/* ------------ */
/* | Textinfo | */
/* ------------ */
text_info()
{
register int i, eo;
int mousek, dummy;

rsrc_gaddr(ROOT, TXT_INFO, &form_adr);

for (i = 0; i < 10; i++)
	{
	form_adr[i + TI_LINE1].ob_spec.tedinfo->te_ptext = txt_infos[akt_id][i];
	form_adr[i + TI_BEAR1].ob_spec.free_string = txt_bearb[akt_id][i];
	}

if (txt_bearb[akt_id][0][0] == 'E')
	{
	form_adr[EINZ_SWT].ob_state |= CROSSED;
	for (i = 0; i < 10; i++)
		form_adr[i + TI_BEAR1].ob_spec.free_string = "\0";
	}
else
	form_adr[EINZ_SWT].ob_state &= ~CROSSED;

form_adr[TI_BEARE].ob_spec.tedinfo->te_ptext = txt_bearb[akt_id][10];
if (txt_first[akt_id])
	{
	form_adr[TI_LINEA].ob_flags |= EDITABLE;
	form_adr[TI_BEARE].ob_flags |= HIDETREE;
	form_adr[TI_BEARE].ob_flags &= ~EDITABLE;
	form_adr[EINZ_SWT].ob_flags |= TOUCHEXIT;
	form_adr[PASS_SWT].ob_flags |= TOUCHEXIT;

	if (! *form_adr[TI_LINEA].ob_spec.tedinfo->te_ptext)
		get_date( form_adr[TI_LINEA].ob_spec.tedinfo->te_ptext );

	form_draw();

	do
		{
		eo = form_do(form_adr, 0) & 0x7FFF;
		switch(eo)
			{
			case EINZ_SWT:
				form_adr[eo].ob_state ^= CROSSED;
				objc_draw(form_adr, eo, MAX_DEPTH, fx, fy, fw, fh);
				do
					{
					graf_mkstate(&dummy, &dummy, &mousek, &dummy);
					}while(mousek & 1);

				if (form_adr[eo].ob_state & CROSSED)
					txt_bearb[akt_id][0][0] = 'E';
				else
					txt_bearb[akt_id][i][0] = 0;
				break;

			case PASS_SWT:
				form_adr[eo].ob_state ^= CROSSED;
				objc_draw(form_adr, eo, MAX_DEPTH, fx, fy, fw, fh);
				do
					{
					graf_mkstate(&dummy, &dummy, &mousek, &dummy);
					}while(mousek & 1);
				break;
			}

		}while(eo != TI_OK);

	form_adr[eo].ob_state &= ~SELECTED;
	form_end();
	}
else
	{
	form_adr[EINZ_SWT].ob_flags &= ~TOUCHEXIT;
	form_adr[PASS_SWT].ob_flags &= ~TOUCHEXIT;

	if (! *form_adr[TI_BEARE].ob_spec.tedinfo->te_ptext)
		get_date( form_adr[TI_BEARE].ob_spec.tedinfo->te_ptext );

	form_adr[TI_LINEA].ob_flags &= ~EDITABLE;
	if (txt_bearb[akt_id][0][0] == 'E')
		{
		form_adr[TI_BEARE].ob_flags |= HIDETREE;
		form_adr[TI_BEARE].ob_flags &= ~EDITABLE;

		dialog(TI_LINE1);
		}
	else
		{
		form_adr[TI_BEARE].ob_flags &= ~HIDETREE;
		form_adr[TI_BEARE].ob_flags |= EDITABLE;

		dialog(TI_BEARE);
		}
	}
}

/* -------------------- */
/* | Springe zu Zeile | */
/* -------------------- */
jmp_line()
{
register char *adr;
register int eo;
long line_num;

rsrc_gaddr(ROOT, GOTO, &form_adr);

adr = form_adr[LINE_NUM].ob_spec.tedinfo->te_ptext;

*adr = 0;

eo = dialog(LINE_NUM) & 0x7FFF;

if (eo == GOTO_OK)
	{
	if (*adr)
		sscanf(adr, "%ld", &line_num);

	if (line_num > 0)
		goto_line(line_num);
	}
}

/* ------------------------ */
/* | Sonderzeichen setzen | */
/* ------------------------ */
setsonder()
{
register int eo, eo_c, i;
register char *adr;
int key, mousek, mousey, mousex, dummy;
int ox, oy;

rsrc_gaddr(ROOT, SONDER_Z, &form_adr);

adr = form_adr[SOND_EDT].ob_spec.tedinfo->te_ptext;

form_draw();

do
	{
	eo = form_do(form_adr, SOND_EDT);
	eo_c = eo & 0x7FFF;

	if (form_adr[eo_c].ob_flags & EXIT)
		form_adr[eo_c].ob_state &= ~SELECTED;

	if (eo_c >= LINE1 && eo_c <= LINEA)
		{
		graf_mkstate(&mousex, &mousey, &mousek, &dummy);
		objc_offset(form_adr, eo_c, &ox, &oy);
		if (eo_c	> LINE2)
			key = 96;
		else
			key = 0;

		key += 16 * (eo_c - LINE1);
		key += (mousex - ox) / (form_adr[eo_c].ob_width / 16);
		}
	else
		key = 0;

	if (!(eo & 0x8000) && eo != SONDR_OK && eo != SOND_CAN)
		{
		if (strlen(adr) > 33)
			strcpy(adr, adr + 1);

		adr[strlen(adr) + 1] = 0;
		adr[strlen(adr)    ] = key;
		objc_draw(form_adr, SOND_EDT, 0, fx, fy, fw, fh);
		}

	}while(eo_c != SONDR_OK && !(eo & 0x8000) && eo_c != SOND_CAN);

f_dial(FMD_SHRINK);
f_dial(FMD_FINISH);

if ( (eo & 0x8000) && key)
		edit(key);

if (eo_c == SONDR_OK)
	for (i = 0; i < strlen(adr); i++)
		edit(adr[i]);
}

/* --------------- */
/* | Formatieren | */
/* --------------- */
set_frmt()
{
register int eo;

rsrc_gaddr(ROOT, TEXT_FMT, &form_adr);

eo = dialog(0);
form_alert(1, "[1][Textformatierung |noch nicht m”glich][ OK ]");
}

/* ------------- */
/* | Einrcken | */
/* ------------- */
set_einr()
{
register int eo, i, cl;
int ein_stp;
char *einr_byt;

rsrc_gaddr(ROOT, EINRUECK, &form_adr);

if (!(form_adr[EINR_STD].ob_state & SELECTED) || (keyst & 3))
	{
	do
		{
		eo = dialog(0) & 0x7FFF;

		if (sscanf(form_adr[EINR_NUM].ob_spec.tedinfo->te_ptext, "%d", &ein_stp) == EOF)
			ein_stp = 999;

		if (ein_stp > 250)
			{
			ein_stp = 250;
			make_rasc((long)ein_stp, 100L, form_adr[EINR_NUM].ob_spec.tedinfo->te_ptext);
			continue;
			}
		else
			break;
			
		}while(1);
	}
else
	{
	eo = EINR_OK;
	}
	
if (eo == EINR_OK)
	if (sscanf(form_adr[EINR_NUM].ob_spec.tedinfo->te_ptext, "%d", &ein_stp) != EOF)
		{
		i = 0;
		do
			{
			cl = calc_clen(&line_buffer[i]);
		
			if (line_buffer[i] == 0xE)
				{
				line_buffer[i + 1] = ein_stp;
				c_p[akt_id] = skip_control();
				break;
				}

			if (cl == -1)
				{
				einr_byt = "\16";
				einr_byt[1] = ein_stp;
				insert_bytes(0, einr_byt, 2);
				break;
				}
			
			i += cl;
				
			}while(1);
			
		show_eline_ab(0);
		}
}

/* -------------------------- */
/* | Kopf-/Fužzeilen setzen | */
/* -------------------------- */
set_kfuss()
{
register int eo, i, typ = 0, j;

rsrc_gaddr(ROOT, KOPFFUSS, &form_adr);

do
	{
	for (i = 0; i <= 12; i += 12)
		for (j = KF_G; j <= G_KF_R; j += ((j == KF_G) ? 2 : 3))
			if (!typ)
				strncpy(form_adr[j + i].ob_spec.free_string, "Kopfzeilen", 10);
			else
				strncpy(form_adr[j + i].ob_spec.free_string, "Fužzeilen ", 10);

	if (!typ)
		strcpy(form_adr[SWTCH_KF].ob_spec.free_string, "Fužzeilen");
	else
		strcpy(form_adr[SWTCH_KF].ob_spec.free_string, "Kopfzeilen");
		
	for (i = 0; i < 12; i++)
		form_adr[kf_anp[i]].ob_spec.tedinfo->te_ptext = kopffuss[akt_id][i + typ * 12];
		
	eo = dialog(0);

	if (eo == SWTCH_KF)
		typ = !typ;
		
	}while(eo != KF_OK);

for (i = 0; i < 24; i++)
	for (j = strlen(kopffuss[akt_id][i]) + 1; j < 26; kopffuss[akt_id][i][j++] = 0);
}

/* ---------------- */
/* | Programminfo | */
/* ---------------- */
prg_info()
{
extern long calc_words();

register int i;
rsrc_gaddr(ROOT, PRG_INFO, &form_adr);
for (i = 0; i < 4; i++)
	if (w_handles[i] != -1)
		{
		form_adr[FILE_1 + (i << 1)].ob_spec.free_string = rindex(pathes[i], '\\') + 1;
		form_adr[FILE_1 + (i << 1)].ob_flags &= ~HIDETREE;

		make_rasc(txt_lens[i], 1000000L, form_adr[SIZE_1 + (i << 1)].ob_spec.free_string);
		form_adr[SIZE_1 + (i << 1)].ob_flags &= ~HIDETREE;

		make_rasc(total_lines[i], 1000000L, form_adr[LINES_1 + (i << 1)].ob_spec.free_string);
		form_adr[LINES_1 + (i << 1)].ob_flags &= ~HIDETREE;

		make_rasc(calc_words(txt_start[i], txt_lens[i]), 1000000L, form_adr[WORDS_1 + (i << 1)].ob_spec.free_string);
		form_adr[WORDS_1 + (i << 1)].ob_flags &= ~HIDETREE;
		}
	else
		{
		form_adr[FILE_1 + (i << 1)].ob_flags |= HIDETREE;
		form_adr[SIZE_1 + (i << 1)].ob_flags |= HIDETREE;
		form_adr[LINES_1 + (i << 1)].ob_flags |= HIDETREE;
		form_adr[WORDS_1 + (i << 1)].ob_flags |= HIDETREE;
		}

make_rasc(mtext_mlen, 1000000L, form_adr[ALL_MEM].ob_spec.free_string + 19);
make_rasc(mtext_mlen - txt_fill - pic_sub, 1000000L, form_adr[FREE_MEM].ob_spec.free_string + 21);

dialog(0);
}

/* ----------------- */
/* | W”rter z„hlen | */
/* ----------------- */
long calc_words(adr, len)
register unsigned char *adr;
long len;
{
register char f1 = FALSE;
register int cl;
register long i, wc = 0;
register unsigned char *end;

end = adr + len;
while(adr < end)
	{
	cl = calc_clen(adr);
	
	if (cl == -1)
		{
		if (!f1 && *adr != ' ' && *adr != '.' && *adr != ',' && *adr != ';' &&
				*adr != '?' && *adr != '!')
			f1 = TRUE;

		if (f1 && (*adr == ' ' || *adr == '.' || *adr == ',' || *adr == ';' ||
				*adr == '?' || *adr == '!'))
			{
			wc++;
			f1 = FALSE;
			}
		}

	if (*adr == 0xD && f1)
		{
		f1 = FALSE;
		wc++;
		}

	adr += abs(cl);
	}
	
return(wc);
}

/* ----------------- */
/* | Dialog fhren | */
/* ----------------- */
dialog(f_edit)
int f_edit;
{
register int eo;

form_draw();

eo = form_do(form_adr, f_edit);

if (form_adr[eo & 0x7FFF].ob_flags & EXIT)
	form_adr[eo & 0x7FFF].ob_state &= ~SELECTED;

form_end();

return(eo);
}

/* ------------------ */
/* | Dialog beenden | */
/* ------------------ */
form_end()
{
f_dial(FMD_SHRINK);
f_dial(FMD_FINISH);
}

/* --------------------- */
/* | Formular zeichnen | */
/* --------------------- */
form_draw()
{
form_center(form_adr, &fx, &fy, &fw, &fh);
f_dial(FMD_START);
f_dial(FMD_GROW);

objc_draw(form_adr, ROOT, MAX_DEPTH, fx, fy, fw, fh);
}

/* ------------------------ */
/* | Verkrzter Form-Dial | */
/* ------------------------ */
f_dial(type)
int type;
{
form_dial(type, 0, 0, 0, 0, fx, fy, fw, fh);
}
