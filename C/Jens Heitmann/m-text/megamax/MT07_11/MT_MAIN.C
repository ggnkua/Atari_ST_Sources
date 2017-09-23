/* 

	Beschreibung:			Textverarbeitung
	Autor:						Jens Heitmann
	Programmiert vom: 14.5.1990 -
*/

#include "global.h"

int old_kb[5], *kb_rec;
OBJECT *back;

/* ---------------------------- */
/* | Virtuelle Arbeitsstation | */
/* ---------------------------- */
open_vwork()
{
register int i;
int dummy;

vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);

for(i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;

v_opnvwk(work_in, &vdi_handle, work_out);
}

/* ---------------------------- */
/* | Arbeitsstation schliežen | */
/* ---------------------------- */
cls_vwork()
{
v_clsvwk(vdi_handle);
}

/* ---------------- */
/* | Hauptroutine | */
/* ---------------- */
main()
{
register int which;
register long calc;
int w1, w2, w3, w4;
int wfx, wfy, wfw, wfh;

install_prg();

do
	{
	menu_on();

	which = evnt_multi(MU_KEYBD|MU_MESAG|MU_BUTTON|MU_TIMER,
											1, 1, 1,
											0, 0, 0, 0, 0,
											0, 0, 0, 0, 0,
											msg,
											50, 0,
											&mousex, &mousey, &mousek,
											&keyst, &key, &clicks);

	if (which & MU_TIMER)
		{
		if (mousex != old_mx || mousey != old_my)
			mouse_on();

		if (akt_id > -1)
			do_slider_calc();
		}

	if (which & MU_MESAG)
		{
		if ( msg[0] == MN_SELECTED )
			mn_action();
		else
			switch( msg[0] )
				{
				case WM_REDRAW:
					redraw(msg[3], msg[4], msg[5], msg[6], msg[7]);
					break;

				case WM_CLOSED:
					erase_wind(msg[3]);
					wind_get(0, WF_TOP, &w1, &w2, &w3, &w4);
					akt_id = get_whandle(w1);
					get_eline();
					break;

				case WM_FULLED:
					wind_get(msg[3], WF_CURRXYWH, &w1, &w2, &w3, &w4);
					wind_get(msg[3], WF_FULLXYWH, &wfx, &wfy, &wfw, &wfh);

					if (w1 == wfx && w2 == wfy && w3 == wfw && w4 == wfh)
						wind_get(msg[3], WF_PREVXYWH, &wfx, &wfy, &wfw, &wfh);

					wind_set(msg[3], WF_CURRXYWH, wfx, wfy, wfw, wfh);
					w_koor[akt_id][0] = wfx;
					w_koor[akt_id][1] = wfy;
					w_koor[akt_id][2] = wfw;
					w_koor[akt_id][3] = wfh;
					break;

				case WM_ARROWED:
					switch(msg[4])
						{
						case 0:									/* Seite nach oben */
							beg_pgup();
							break;

						case 1:									/* Seite nach unten */
							beg_pgdwn();
							break;

						case 2:									/* Zeile nach oben */
							beg_oneup();
							break;
	
						case 3:									/* Zeile nach unten */
							beg_onedown();
							break;
						}
					break;

				case WM_HSLID:
					break;

				case WM_VSLID:
					go_vpos(msg[4]);
					break;

				case WM_SIZED:
					wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
					w_koor[akt_id][2] = msg[6];
					w_koor[akt_id][3] = msg[7];
					break;

				case WM_MOVED:
					wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
					w_koor[akt_id][0] = msg[4];
					w_koor[akt_id][1] = msg[5];
					break;

				case WM_TOPPED:
				case WM_NEWTOP:
					akt_id = get_whandle(msg[3]);
					wind_set(msg[3], WF_TOP, 0, 0, 0, 0);
					get_eline();
					break;
				}
		}

	if (which & MU_KEYBD)
		key_mesag();
		
	if ((which & MU_BUTTON) && akt_id > -1)
		button_mesag();
		
	}while(!exit_flg);

leave_prg();
}

/* ---------------------- */
/* | Mausknopf bet„tigt | */
/* ---------------------- */
button_mesag()
{
get_work(w_handles[akt_id]);

if (pt_inrect(mousex, mousey, wx, wy, ww, wh))
	if (ruler_flag && mousey - wy < 16 && mousey >= wy)
		{
		if (mousex < wx + 24)
			edit_aktruler();
		else
			set_tab();
		}
	else
		set_cursor();
}

/* ------------------------ */
/* | Taste wurde gedrckt | */
/* ------------------------ */
key_mesag()
{
register int ai, i;

if (key >= 0x3B00 && key <= 0x4400)
	{
	if (keyst & 8)
		send_floskel();
	else
		if (keyst & 4)
			send_funkt();
		else
			look_alternate(key);
			
	return;
	}
			
if (keyst & 8)
	look_alternate(key);
else
	if (keyst == 4)
		look_control(key);
	else
		if (key == 0x11B)
			{
			i = 4;
			ai = akt_id;
			do
				{
				ai++;
				if (ai == 4)
					ai = 0;
				}while(w_handles[ai] == -1 && --i);

			if (i)
				{
				akt_id = ai;
				wind_set(w_handles[akt_id], WF_TOP, 0, 0, 0, 0);
				get_eline();
				}
			}
		else
			edit(key);
}

/* ---------------------------- */
/* | Floskel an Editor senden | */
/* ---------------------------- */
send_floskel()
{
register int i, j, k;

k = key - 0x3B00;

for (i = 0; i < 5; i++)
	for (j = 0; j < strlen(mt_floskel[k][i]); j++)
		edit(mt_floskel[k][i][j]);
}

/* ------------------------------ */
/* | Funktionkombination senden | */
/* ------------------------------ */
send_funkt()
{
}

/* ------------------ */
/* | Menverwaltung | */
/* ------------------ */
mn_action()
{
register int i, l;
register char *m_entry;

mouse_on();

i = 0;
while (i < M_POINTS && msg[4] != menu_id[i])
	i++;

m_entry = menu_adr[msg[4]].ob_spec.free_string;
l = strlen(m_entry);

if (m_entry[l - 3] == 'F')
	if (m_entry[l - 1] == '0')
		funk_blink(9);
	else
		funk_blink(m_entry[l - 2] - '1');
		
if (i < M_POINTS)
	(*rout[i])();

menu_tnormal(menu_adr, msg[3], TRUE);
}

/* -------------------------- */
/* | Alternate-Taste suchen | */
/* -------------------------- */
look_alternate(key)
unsigned int key;
{
register int mp;
int w_msg[8];

mp = alt_tab[key >> 8];
if (mp & 0x8000 )
	{
  if ( !(menu_adr[mp & 0x7FFF].ob_state & DISABLED))
		{
		w_msg[0] = MN_SELECTED;
		w_msg[1] = ap_id;
		w_msg[2] = 0;
		w_msg[3] = 3;														/* ! */
		w_msg[4] = mp & 0x7FFF;

		appl_write(ap_id, 16, w_msg);
		}
	}
else
	edit(key);
}

/* ------------------------ */
/* | Control-Taste suchen | */
/* ------------------------ */
look_control()
{
register int mp;
int w_msg[8];

mp = cntrl_tab[key >> 8];
if (mp & 0x8000 )
	{
  if (!(menu_adr[mp & 0x7FFF].ob_state & DISABLED) )
		{
		w_msg[0] = MN_SELECTED;
		w_msg[1] = ap_id;
		w_msg[2] = 0;
		w_msg[3] = 3;														/* ! */
		w_msg[4] = mp & 0x7FFF;

		appl_write(ap_id, 16, w_msg);
		}
	}	
else
	edit(key);
}

/* ----------------------------- */
/* | Blinke mit Funktionstaste | */
/* ----------------------------- */
funk_blink(ind)
register int ind;
{
back[F1_BUT + (ind << 2)].ob_state ^= SELECTED;
redraw_w0(F1_BUT + (ind << 2));

evnt_timer(150, 0);

back[F1 + (ind << 2)].ob_state &= ~SHADOWED;
back[F1_BUT + (ind << 2)].ob_state ^= SELECTED;
redraw_w0(F1 + (ind << 2));
back[F1 + (ind << 2)].ob_state &= ~SHADOWED;
}

/* --------------------------- */
/* | Hintergrund neuzeichnen | */
/* --------------------------- */
redraw_w0(ind)
register int ind;
{
int w0x, w0y, w0w, w0h;

wind_get(0, WF_FIRSTXYWH, &w0x, &w0y, &w0w, &w0h);
while (w0w > 0 && w0h > 0)
	{
	objc_draw(back, ind, 1, w0x, w0y, w0w, w0h);
	wind_get(0, WF_NEXTXYWH, &w0x, &w0y, &w0w, &w0h);
	}
}

/* -------------------------------- */
/* | Programmumgebung vorbereiten | */
/* -------------------------------- */
install_prg()
{
register int i;

ap_id = appl_init();
open_vwork();

kb_rec = (int *)Iorec(1);
for (i = 0; i < 5; i++)
	old_kb[i] = kb_rec[i + 2];

kb_rec[2] = 10;
kb_rec[3] = 0;
kb_rec[4] = 0;
kb_rec[5] = 2;
kb_rec[6] = 8;

rsrc_load("M_TEXT.RSC");
rsrc_gaddr(ROOT, TXT_MENU, &menu_adr);

graf_mouse(ARROW, 0L);

init_mtext();
init_rsc();

menu_bar(menu_adr, TRUE);
}

/* ------------------------------------- */
/* | Programmumgebung wiederherstellen | */
/* ------------------------------------- */
leave_prg()
{
register int i;

if (off_flag)
	graf_mouse(M_ON, 0L);

if (fnt_point[akt_id])
	vst_unload_fonts(vdi_handle, 1);

for (i = 0; i < 5; i++)
	kb_rec[i + 2] = old_kb[i];

cls_vwork();
appl_exit();
}

/* --------------------------------- */
/* | Initialisierungen durchfhren | */
/* --------------------------------- */
init_mtext()
{
register int i, j;
int a, b;

scrtchp = (long)Malloc(2048L);

mtext_mlen = (long)Malloc(-1L) - 75000;
mtext_mem = (unsigned char *)Malloc(mtext_mlen);

/*printf("\033H%lx\n", mtext_mem);*/

memset(mtext_mem, 0, mtext_mlen);

pathes[0][0] = Dgetdrv();
pathes[0][1] = ':';
Dgetpath(pathes[0] + 2, 0);
strcat(pathes[0] + 2, "\\");
pathes[0][0] += 'A';

strcpy(pathes[1], pathes[0]);
strcpy(pathes[2], pathes[0]);
strcpy(pathes[3], pathes[0]);

pic_fpath[0] = pathes[0][0];
del_file[0] = font_path[0] = pathes[0][0];

for (i = 0; i < 68; txt_lineal[0][i++] = '.');
txt_lineal[0][68] = 0;

strcpy(txt_lineal[1], txt_lineal[0]);
strcpy(txt_lineal[2], txt_lineal[0]);
strcpy(txt_lineal[3], txt_lineal[0]);

strncpy(txt_linpar[0], "NPS110", 6);
strncpy(txt_linpar[1], txt_linpar[0], 6);
strncpy(txt_linpar[2], txt_linpar[0], 6);
strncpy(txt_linpar[3], txt_linpar[0], 6);

strcpy(txt_infol[0], "  Seite: 999, Zeile: 99999, Spalte: 999          Einfgen ");
strcpy(txt_infol[1], txt_infol[0]);
strcpy(txt_infol[2], txt_infol[0]);
strcpy(txt_infol[3], txt_infol[0]);

vst_alignment(vdi_handle, 0, 3, &a, &b);
vsf_perimeter(vdi_handle, FALSE);

load_cfg();

get_work(0);
for (i = 0; i < 4; i++)
	{
	w_koor[i][0] = wx;
	w_koor[i][1] = wy;
	w_koor[i][2] = ww - (3 - i) * 10;
	w_koor[i][3] = wh - i * 10;
	}
}

/* ------------------- */
/* | RSC vorbereiten | */
/* ------------------- */
init_rsc()
{
OBJECT *form;
register int i, j;
											 
rsrc_gaddr(ROOT, SONDER_Z, &form);
form[LINE3].ob_spec.free_string[1] = 0;
form[LINEA].ob_spec.free_string[31] = 0x7F;
for (i = LINE3; i <= LINEA; i++)
	for (j = 1; j < 33; j += 2)
		form[i].ob_spec.free_string[j] += 0x80;
		
*form[SOND_EDT].ob_spec.tedinfo->te_ptext = 0;

rsrc_gaddr(ROOT, SET_FONT, &form);
form[FONT_S].ob_state |= SELECTED;

rsrc_gaddr(ROOT, EINRUECK, &form);
*form[EINR_NUM].ob_spec.tedinfo->te_ptext = 0;

rsrc_gaddr(ROOT, FIND_REP, &form);
form[SR_CURSR].ob_state |= SELECTED;
form[SR_CRDWN].ob_state |= SELECTED;
*form[FIND_STR].ob_spec.tedinfo->te_ptext = 0;
*form[REPL_STR].ob_spec.tedinfo->te_ptext = 0;

rsrc_gaddr(ROOT, DISK_FMT, &form);
form[DRIVE_A].ob_state |= SELECTED;
form[NORM_FMT].ob_state |= SELECTED;
form[ONE_SIDE].ob_state |= SELECTED;

rsrc_gaddr(ROOT, PRT_MENU, &form);
form[TO_PRINT].ob_state |= SELECTED;
form[NO_INHLT].ob_state |= SELECTED;
form[NO_INDEX].ob_state |= SELECTED;
form[PRT_PICS].ob_state |= SELECTED;
form[NO_MAIL].ob_state |= SELECTED;
form[PRT_DRFT].ob_state |= SELECTED;
form[PRT_TEXT].ob_state |= SELECTED;

rsrc_gaddr(ROOT, NOTE_DIA, &form);
form[N_LOCK].ob_state |= SELECTED;
for (i = N_LINE2; i <= N_LINE7; i++)
	{
	form[i].ob_spec.tedinfo->te_ptmplt = form[N_LINE1].ob_spec.tedinfo->te_ptmplt;
	form[i].ob_spec.tedinfo->te_pvalid = form[N_LINE1].ob_spec.tedinfo->te_pvalid;
	form[i].ob_spec.tedinfo->te_txtlen = 40;
	form[i].ob_spec.tedinfo->te_tmplen = 40;
	}

rsrc_gaddr(ROOT, NEW_RULR, &form);
*form[TAB_WDTH].ob_spec.tedinfo->te_ptext = 0;

rsrc_gaddr(ROOT, TXT_INFO, &form);
form[EINZ_SWT].ob_state |= SELECTED;
form[PASS_SWT].ob_state |= SELECTED;

for (i = TI_LINE1; i <= TI_LINE9; i++)
	{
	form[i].ob_spec.tedinfo->te_ptmplt = form[TI_LINE1].ob_spec.tedinfo->te_ptmplt;
	form[i].ob_spec.tedinfo->te_pvalid = form[TI_LINE1].ob_spec.tedinfo->te_pvalid;
	form[i].ob_spec.tedinfo->te_tmplen = 40;
	form[i].ob_spec.tedinfo->te_txtlen = 40;
	}

form[TI_LINEA].ob_spec.tedinfo->te_txtlen = 34;
form[TI_BEARE].ob_spec.tedinfo->te_txtlen = 29;

rsrc_gaddr(ROOT, KOPFFUSS, &form);
for (i = 0; i < 12; i++)
	{
	form[kf_anp[i]].ob_spec.tedinfo->te_ptmplt = form[G_LFT_1].ob_spec.tedinfo->te_ptmplt;
	form[kf_anp[i]].ob_spec.tedinfo->te_pvalid = form[G_LFT_1].ob_spec.tedinfo->te_pvalid;
	form[kf_anp[i]].ob_spec.tedinfo->te_txtlen = 26;
	form[kf_anp[i]].ob_spec.tedinfo->te_tmplen = 26;
	}

rsrc_gaddr(ROOT, FLOSKEL, &form);
for (i = FLSK_L1; i <= FLSK_L5; i++)
	{
	form[i].ob_spec.tedinfo->te_ptmplt = form[FLSK_L1].ob_spec.tedinfo->te_ptmplt;
	form[i].ob_spec.tedinfo->te_pvalid = form[FLSK_L1].ob_spec.tedinfo->te_pvalid;
	form[i].ob_spec.tedinfo->te_tmplen = 40;
	form[i].ob_spec.tedinfo->te_txtlen = 40;
	}

get_work(0);
rsrc_gaddr(ROOT, BACKGRND, &back);

back[ROOT].ob_x = wx;
back[ROOT].ob_y = wy;
back[ROOT].ob_width = ww;
back[ROOT].ob_height = wh;

ww = (ww - 20) / 10;
wx += 10;
wy = wh - back[F1].ob_height - 20;
for (i = 0; i < 40; i += 4)
	{
	back[F1 + i].ob_x = wx;
	back[F1 + i].ob_y = wy;
	back[F1 + i].ob_width = ww;
	back[F1_BUT + i].ob_width = ww;
	back[F1_BUT + i].ob_type = G_BOX;
	back[F1_BUT].ob_spec.index |= 0xFF0000;
	back[F1_TXT + i].ob_width = ww;

	back[F1_TXT + i].ob_spec.tedinfo->te_ptext = f_text[((i < 36) ? i / 4 + 1 : 0)];
	wx += ww;
	}

wind_set(0, WF_NEWDESK, back, 0, 0);
full_redraw();
}

/* ----------------- */
/* | File-Selektor | */
/* ----------------- */
fsel(st_path, ext)
char *st_path, *ext;
{
char path[80], file[14];
int st, button;

strcpy( path, st_path );
strcpy( rindex(path, '\\') + 1, "*" );
strcat( path, ext );
strcpy( file, rindex(st_path, '\\') + 1 );

st = fsel_input(path, file, &button);

if (button)
	{
	strcpy(st_path, path);
	strcpy(rindex(st_path, '\\') + 1, file);
	}

if (button & st)
	return(TRUE);
else
	return(FALSE);
}

/* ------------------------- */
/* | Windowindex ermitteln | */
/* ------------------------- */
get_whandle(w_handle)
register int w_handle;
{
register int i;

for (i = 0; i < 4 && w_handles[i] != w_handle; i++);

if (i == 4)
	return(-1);

return(i);
}

/* ------------- */
/* | CFG laden | */
/* ------------- */
load_cfg()
{
FILE *cfg_h;
register int i, j;
register char *xx, *xf;
char string[80];

cfg_h = fopen("M_TEXT.CFG", "r");
if (cfg_h)
	{
	for (i = 0; i < M_POINTS; i++)	
		{
		do
			{
			fgets(string, 79, cfg_h);
			}while( !strchr(string, '='));

			if (strchr(string, '\n'))
				*strchr(string, '\n') = 0;

			if ( strchr(string, '=') )
				{
				xx = strchr(string, '=') + 2;
				if (!strncmp(xx, "..", 2))
					xx = "  ";

				if (*xx == '~')
					*xx = 0x7;

				strncpy(rindex(menu_adr[menu_id[i]].ob_spec.free_string, 'x') - 1, xx, 2);

				if (*xx == 0x7)
					{
					xx++;

					for (j = 0; j < ALT_NUM; j++)
						if (alt_tab[j] == *((unsigned char *)xx) )
							alt_tab[j] = menu_id[i] | 0x8000;
					}
				else
					if (*xx == '^')
						{
						xx++;

						for (j = 0; j < CNTRL_NUM; j++)
							if (cntrl_tab[j] == *((unsigned char *)xx) )
								cntrl_tab[j] = menu_id[i] | 0x8000;
						}
					else
						if (*xx == 'F')
							{
							alt_tab[0x3B + *(xx + 1) - '1'] = menu_id[i] | 0x8000;
	
							if (*(xx + 1) == '0')
								{
								j = strlen(menu_adr[menu_id[i]].ob_spec.free_string);
								menu_adr[menu_id[i]].ob_spec.free_string[j - 2] = '1';
								menu_adr[menu_id[i]].ob_spec.free_string[j - 1] = '0';
								}

							xf = strchr(xx, ':');
							if (xf)
								{
								do
									{
									xf++;
									}while(*xf == ' ' || *xf == '\t');

								strcpy(f_text[*(xx + 1) - '0'], xf);
								}
							}
				}
		}

	fclose(cfg_h);
	}
}

/* ------------------------- */
/* | Menpunkte aktivieren | */
/* ------------------------- */
menu_on()
{
register int f = TRUE, i, fk, l;
register char *m_entry;

if (akt_id == -1)
	f = FALSE;

menu_ienable(menu_adr, MN_TINFO, f);
menu_ienable(menu_adr, MN_TSAVE, f);
menu_ienable(menu_adr, MN_TSVAS, f);
menu_ienable(menu_adr, MN_GOTO, f);
menu_ienable(menu_adr, MN_SONDR, f);
menu_ienable(menu_adr, MN_FORMT, f);
menu_ienable(menu_adr, MN_EINR, f);
menu_ienable(menu_adr, MN_REPL, f);
menu_ienable(menu_adr, MN_RLNEW, f);
menu_ienable(menu_adr, MN_CALC, f);
menu_ienable(menu_adr, MN_TPRNT, f);
menu_ienable(menu_adr, MN_RULER, f);
menu_ienable(menu_adr, MN_RLDEL, f);
menu_ienable(menu_adr, MN_BRIEF, f);
menu_ienable(menu_adr, MN_EDIT, f);
menu_ienable(menu_adr, MN_DATE, f);
menu_ienable(menu_adr, MN_TIME, f);

f &= modus[akt_id];
menu_ienable(menu_adr, MN_BOLD, f);
menu_ienable(menu_adr, MN_ITALC, f);
menu_ienable(menu_adr, MN_UNDER, f);
menu_ienable(menu_adr, MN_LIGHT, f);
menu_ienable(menu_adr, MN_OUTL, f);
menu_ienable(menu_adr, MN_SUBS, f);
menu_ienable(menu_adr, MN_SUPER, f);
menu_ienable(menu_adr, MN_CFONT, f);
menu_ienable(menu_adr, MN_PAINT, f);
menu_ienable(menu_adr, MN_CPFNT, f);
menu_ienable(menu_adr, MN_KILLP, f);
menu_ienable(menu_adr, MN_KFUSS, f);
menu_ienable(menu_adr, MN_PLOAD, f);
menu_ienable(menu_adr, MN_NOTE, f);
menu_ienable(menu_adr, MN_NOTSH, f);
menu_ienable(menu_adr, MN_INHLT, f);

for (i = 0; i < M_POINTS; i++)
	{
	m_entry = menu_adr[menu_id[i]].ob_spec.free_string;
	l = strlen(m_entry);
	
	if (m_entry[l - 3] == 'F')
		if (m_entry[l - 1] == '0')
			fk = 9;
		else
			fk = m_entry[l - 2] - '1';
	else
		fk = -1;
	
	if (fk > -1)
		{
		fk <<= 2;

		if (menu_adr[menu_id[i]].ob_state & DISABLED)
			l = G_BOX;
		else
			l = G_IBOX;
			
		if (back[F1_BUT + fk].ob_type != l)
			{
			back[F1_BUT + fk].ob_type = l;

			if (l == G_BOX)
				{
				back[F1_BUT + fk].ob_spec.index |= 0xFF0000;
				redraw_w0(F1_BUT + fk);
				}
			else
				{
				back[F1_BUT + fk].ob_spec.index &= 0xFF00FFFF;
				back[F1 + fk].ob_state &= ~SHADOWED;
				redraw_w0(F1 + fk);
				back[F1 + fk].ob_state |= SHADOWED;
				}
			}
		}
	}	
}

/* ---------------------- */
/* | Programm verlassen | */
/* ---------------------- */
quit_prg()
{
exit_flg = TRUE;
}

/* ------------------------ */
/* | Datum holen DDMMYYYY | */
/* ------------------------ */
get_date(s_adr)
char *s_adr;
{
							
dateinfo d_info;

strcpy(s_adr, "99999999");

d_info.realdate = Tgetdate();

make_asc((long)d_info.part.day, 10L, s_adr);
make_asc((long)d_info.part.month, 10L, s_adr + 2);
make_asc((long)d_info.part.year + 1980, 1000L, s_adr + 4);
}

/* --------------------- */
/* | Zeit holen HHMMSS | */
/* --------------------- */
get_time(s_adr)
char *s_adr;
{
timeinfo t_info;

strcpy(s_adr, "9999");

t_info.realtime = Tgettime();

make_asc((long)t_info.part.hours, 10L, s_adr);
make_asc((long)t_info.part.minutes, 10L, s_adr + 2);
}

/* ---------------------- */
/* | Erzeugt ASCII-Zahl | */
/* ---------------------- */
make_asc(zahl, teiler, adr)
register long zahl, teiler;
register char *adr;
{
register int i = 0;

while (teiler > 0)
  {
  adr[i]=(char)(zahl / teiler) + 48;
  i++;
  zahl -= (zahl / teiler) * teiler;
  teiler /= 10;
  }
}

/* ------------------------------------ */
/* | Erzeuge rechtsbndige ASCII-Zahl | */
/* ------------------------------------ */
make_rasc(zahl_r, teiler_r, adr_r)
register long zahl_r, teiler_r;
register char *adr_r;
{
make_asc(zahl_r, teiler_r, adr_r);

while(adr_r[0] == (char)48 && adr_r[1] >= (char)0x30 && adr_r[1] <= (char)0x39)
  {
  adr_r[0] = (char)0x20;
  adr_r ++;
  }
}

/* ------------ */
/* | Maus aus | */
/* ------------ */
mouse_off()
{
int dummy;

if (!off_flag)
	{
	vq_mouse(vdi_handle, &dummy, &old_mx, &old_my);

	graf_mouse(M_OFF, 0L);
	off_flag = TRUE;
	}
}

/* ------------------ */
/* | Maus wieder an | */
/* ------------------ */
mouse_on()
{
if (off_flag)
	{
	graf_mouse(M_ON, 0L);
	off_flag = FALSE;
	}
}

/* ---------------------------- */
/* | Arbeitsbereich ermitteln | */
/* ---------------------------- */
get_work(handle)
int handle;
{
wind_get(handle, WF_WORKXYWH, &wx, &wy, &ww, &wh);
}
