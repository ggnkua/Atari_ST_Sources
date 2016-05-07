#include "extern.h"
#include "global.h"

static int snd_type = -1;
long check_sam(void);

/* -----------------
	 | Fehlermeldung |
	 ----------------- */
int error(char *s1, char *s2, int but)
{
OBJECT *err_form;

rsrc_gaddr(R_TREE, ERROR, &err_form);

err_form[ERR_1].ob_spec.free_string = s1;
err_form[ERR_2].ob_spec.free_string = s2;

if (but & 2)
	err_form[ERR_OK].ob_flags &= ~HIDETREE;
else
	err_form[ERR_OK].ob_flags |= HIDETREE;

if (but & 1)
	err_form[ERR_CNC].ob_flags &= ~HIDETREE;
else
	err_form[ERR_CNC].ob_flags |= HIDETREE;

if (but & 8)
	err_form[ERR_OK].ob_flags |= DEFAULT;
else
	err_form[ERR_OK].ob_flags &= ~DEFAULT;

if (but & 4)
	err_form[ERR_CNC].ob_flags |= DEFAULT;
else
	err_form[ERR_CNC].ob_flags &= ~DEFAULT;

return dialog(err_form);
}

/* ---------------------------- */
/* | Virtuelle Arbeitsstation | */
/* ---------------------------- */
void open_vwork(void)
{
register int i;
int dummy;

vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);

for(i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;

v_opnvwk(work_in, &vdi_handle, work_out);
}

/* -----------------
	 | Select sample |
	 ----------------- */
int select_sample(void)
{
int stat, but;

stat = fsel_input(path, file, &but);
if (stat && but)
	{
	strcpy(fname, path);
	strcpy(strrchr(fname, '\\') + 1, file);
	return 1;
	}
return 0;
}

/* ---------------------------------
	 | Analyse sample (ST/STE-Sound) |
	 --------------------------------- */
void analyse_sample(int flg)
{
long a;

if (!o_bytes)
	return;
	
if (flg || snd_type == -1)
	a = check_sam();
	
if (a > total / 150 || !flg)
	{
	if (flg || snd_type == -1)
		snd_type = ask_sndtype();

	switch(snd_type)
		{
		case ST_SND:
			convert();
			break;

		case PK_SND:
			unkompakt();
			break;
		}
	}
}

/* --------------------------------
	 | load(): Einladen des Samples |
	 -------------------------------- */
void load(int flg)
{
long fd;
long i;

if (flg)
	if (!select_sample())
		return;

if (o_bytes)
	{
	free(o_bytes);
	o_bytes = (char *)NULL;
	}

if (seq_data)
	{
	free(seq_data);
	free(play_list);
	seq_data = (SEQUENZ *)NULL;
	seq_num = 0;
	lst_num = 0;
	seqs_close(-1);
	}
	
if ((fd = Fopen(fname, 0)) < 0)
	{
	error("Datei fehlt!", "\0", 0xA);
	total = 0L;
	}
else
	{
	total = Fseek(0, (int)fd, 2);

	if (total)
		{
		if ((o_bytes = (char *)malloc(total + 6L)) == NULL)
			error("Speicher voll!", "\0", 0xA);

		if (o_bytes)
			{
			graf_mouse(HOURGLASS, 0L);

			Fseek(0, (int)fd, 0);
			i = Fread((int)fd, total, o_bytes);
			graf_mouse(ARROW, 0L);
		
			if (i < total)
				error("Datei defekt!!!", "\0", 0xA);
			}
		}

	Fclose((int)fd);
	}
	
sample_name(file);
analyse_sample(flg);
}

/* --------------------------------
	 |	save(): Sichern des Samples |
	 -------------------------------- */
void save_part(int flg, char *start, long len)
{
if (flg)
	if (!select_sample())
		return;
		
save_file(fname, start, len);
}

/* ----------------
   | Save to file |
   ---------------- */
void save_file(char *fname, char *start, long len)
{
long fd;
long res;

if ((fd = Fcreate(fname, 0)) < 0)
	error("Datei konnte nicht", "angelegt werden!", 0xA);
else
	{
	graf_mouse(HOURGLASS, 0L);
	res = Fwrite((int)fd, len, start);
	graf_mouse(ARROW, 0L);
	
	if (res < 0)
		error("Datei konnte nicht kor-", "rekt geschrieben werden!", 0xA);

	Fclose((int)fd);
	}
}

/* -------------------------
	 | Set Option checkmarks |
	 ------------------------- */
void set_options(void)
{
int max_speed, l;
char *adr, tmp[6];

max_speed = ((cpu_type == 68030L) ? 2 : 1);

if (play_spd < 4)
	{
	if (play_mode == PSG && ovsm_ply && play_spd > max_speed)
		play_spd = max_speed;

	if (play_mode == PSG && !ovsm_ply && play_spd > max_speed + 1)
		play_spd = max_speed;
	}

menu_icheck(menu_adr, AUSWEICH, sub_tab);
menu_icheck(menu_adr, OVSM_FRQ, ovsm_prep);
menu_icheck(menu_adr, BAD_FRQ, badf_kill);
menu_icheck(menu_adr, SINK_MAX, sink_frq);
menu_icheck(menu_adr, FRQ_FLAT, flat_frq);
menu_icheck(menu_adr, PCK_FILT, pck_filt);
menu_icheck(menu_adr, BIT4_P, bitp_pck);
menu_icheck(menu_adr, BIT4, bit4_pck);
menu_icheck(menu_adr, PLY_OVSM, ovsm_ply);

ltoa(spd_table[play_spd], tmp, 10);
adr = menu_adr[RATE].ob_spec.free_string + 15;

l = (int)strlen(tmp);
strnset(adr, ' ', 5);
strncpy(adr + 5 - l, tmp, l);

adr = menu_adr[SET_KORR].ob_spec.free_string + 17;
if (korr_val + 1 > 9)
	{
	adr[0] = ((korr_val + 1) / 10) + '0';
	adr[1] = ((korr_val + 1) % 10) + '0';
	}
else
	{
	adr[0] = ' ';
	adr[1] = (korr_val + 1) + '0';
	}
	
if (ovsm_typ == 2)
	{
	menu_icheck(menu_adr, OVSM2, 1);
	menu_icheck(menu_adr, OVSM3, 0);
	}
else
	{
	menu_icheck(menu_adr, OVSM2, 0);
	menu_icheck(menu_adr, OVSM3, 1);
	}

if (o_bytes)
	{
	if (ovsm_prep || badf_kill || sink_frq || flat_frq)
		menu_ienable(menu_adr, DO_FILT, 1);
	else
		menu_ienable(menu_adr, DO_FILT, 0);

	menu_ienable(menu_adr, DO_LOUD, 1);
	menu_ienable(menu_adr, DO_OVSM, 1);
	menu_ienable(menu_adr, DO_PACK, 1);
	menu_ienable(menu_adr, DO_CONV, 1);
	menu_ienable(menu_adr, DO_PLAY, 1);
	menu_ienable(menu_adr, DO_SEQ, 1);
	menu_ienable(menu_adr, LOADLIST, 1);
	}
else
	{
	menu_ienable(menu_adr, DO_LOUD, 0);
	menu_ienable(menu_adr, DO_FILT, 0);
	menu_ienable(menu_adr, DO_OVSM, 0);
	menu_ienable(menu_adr, DO_PACK, 0);
	menu_ienable(menu_adr, DO_CONV, 0);
	menu_ienable(menu_adr, DO_PLAY, 0);
	menu_ienable(menu_adr, DO_SEQ, 0);
	menu_ienable(menu_adr, LOADLIST, 0);
	}
	
if (seq_num)
	{
	menu_ienable(menu_adr, EDIT_LST, 1);
	menu_ienable(menu_adr, AUTOSORT, 1);
	}
else
	{
	menu_ienable(menu_adr, EDIT_LST, 0);
	menu_ienable(menu_adr, AUTOSORT, 0);
	}
}

/* ---------------------------
	 | Menu point was selected |
	 --------------------------- */
int menu_action(void)
{
switch(msg[4])
	{
	case AB_INFO:
		do_info();
		break;

	case LOAD_SMP:
		load(1);
		sample_redraw(-1);
		set_options();
		break;

	case SAVE_SMP:
		save_part(1, o_bytes, total);
		break;

	case BATCH:
		do_batch();
		break;

	case DIR_WORK:
		dir_edit();
		break;
		
	case QUIT_PRG:
		return 1;

	case DO_LOUD:
		set_loud();
		break;
		
	case DO_FILT:
		filter();
		break;

	case DO_OVSM:
		do_oversam();
		sample_redraw(-1);
		break;

	case DO_PACK:
		kompakt(1);
		break;

	case DO_CONV:
		convert();
		sample_redraw(-1);
		break;

	case DO_PLAY:
		play(o_bytes, total);
		break;

	case OVSM_FRQ:
		ovsm_prep ^= 1;
		set_options();
		break;

	case BAD_FRQ:
		badf_kill ^= 1;
		set_options();
		break;

	case SINK_MAX:
		sink_frq ^= 1;
		set_options();
		break;

	case FRQ_FLAT:
		flat_frq ^= 1;
		set_options();
		break;

	case OVSM2:
		ovsm_typ = 2;
		set_options();
		break;

	case OVSM3:
		ovsm_typ = 3;
		set_options();
		break;

	case SET_KORR:
		select_cval();
		set_options();
		break;

	case PCK_FILT:
		pck_filt ^= 1;
		set_options();
		break;

	case BIT4_P:
		bitp_pck ^= 1;
		set_options();
		break;

	case BIT4:
		bit4_pck ^= 1;
		set_options();
		break;

	case AUSWEICH:
		sub_tab ^= 1;
		set_options();
		break;

	case RATE:
		select_rate();
		set_options();
		break;

	case PLY_OVSM:
		ovsm_ply ^= 1;
		set_options();
		break;

	case SEL_OUTP:
		select_output();
		set_options();
		break;
		
	case SET_MW:
		set_mwire();
		break;

/* ANA_SEQ 
   TST_SEQ
   EXT_CMP
   SEQ_DB 
   SAVE_SEQ */
   
  case DO_SEQ:
  	sequencer();
		set_options();
  	break;

	case AUTOSORT:
 		sequenz_cmp();
		break;
  	
  case EDIT_LST:
  	seq_list();
  	break;
  	
  case LOADLIST:
  	load_plan();
  	break;
	}

menu_tnormal(menu_adr, msg[3], 1);
return 0;
}

/* -------------
	 | Main part |
	 ------------- */
void main(void)
{
int ex = 0;
int mx, my, mb, ks, kr, br, which;

appl_init();
open_vwork();

graf_mouse(HOURGLASS, 0L);

rsrc_load("SND_TOOL.RSC");
rsrc_gaddr(R_TREE, MMENU, &menu_adr);

load_sinus();
init_field();

menu_bar(menu_adr, 1);
graf_mouse(ARROW, 0L);

path[0] = Dgetdrv() + 'A';
path[1] = ':';
Dgetpath(path + 2, 0);
strcat(path + 2, "\\*.*");
file[0] = 0;

cookie_chk();
set_options();
sample_window();
sample_redraw(-1);

do
	{
	which = evnt_multi(MU_MESAG|MU_BUTTON,
										 1, 1, 1,
										 0, 0, 0, 0, 0,
										 0, 0, 0, 0, 0,
										 msg,
										 0, 0,
										 &mx, &my, &mb, &ks, &kr, &br);
	snd_type = -1;

	if (which & MU_MESAG)
		switch(msg[0])
			{
			case MN_SELECTED:
				menu_bar(menu_adr, 0);
				ex = menu_action();
				menu_bar(menu_adr, 1);
				break;
	
			case WM_REDRAW:
				red_x = msg[4];
				red_y = msg[5];
				red_w = msg[6];
				red_h = msg[7];
				sample_redraw(msg[3]);
				seqs_redraw(msg[3]);
				break;
	
			case WM_MOVED:
				wind_set(msg[3], WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
				break;
	
			case WM_CLOSED:
				seqs_close(msg[3]);
				break;
				
			case WM_TOPPED:
			case WM_NEWTOP:
				wind_set(msg[3], WF_TOP);
				break;
	 		}

	if (which & MU_BUTTON)
		seqs_work(mx, my, br);
		
	seqs_koor();
	
	}while(!ex);

v_clsvwk(vdi_handle);
appl_exit();
}
