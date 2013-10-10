#include <support.h>

#include "global.h"
#include "av.h"
#include "ausgabe.h"
#include "clipbrd.h"
#include "edit.h"
#include "error.h"
#include "file.h"
#include "find.h"
#include "icon.h"
#include "kurzel.h"
#include "makro.h"
#include "memory.h"
#include "poslist.h"
#include "printer.h"
#include "projekt.h"
#include "olga.h"
#include "rsc.h"
#include "se.h"
#include "set.h"
#include "text.h"
#include "version.h"
#include "window.h"
#include "winlist.h"
#include "options.h"

extern void	menu_help(int title, int item);

static char	buffer[MAX_LINE_LEN];


/*
 * Autosave
*/
bool	as_text, as_prj;
bool	as_text_ask, as_prj_ask;
int	as_text_min, as_prj_min;

void set_autosave_options(void)
{
	int	antw;

	set_state(autosave, ASTEXT, SELECTED, as_text);
	set_int(autosave, ASTMIN, as_text_min);
	set_state(autosave, ASTASK, SELECTED, as_text_ask);

	set_state(autosave, ASPROJ, SELECTED, as_prj);
	set_int(autosave, ASPMIN, as_prj_min);
	set_state(autosave, ASPASK, SELECTED, as_prj_ask);

	antw = simple_mdial(autosave, ASTMIN) & 0x7fff;
	if (antw == ASOK)
	{
		as_text = get_state(autosave, ASTEXT, SELECTED);
		as_text_min = get_int(autosave, ASTMIN);
		if (as_text_min == 0)
			as_text = FALSE;
		if (as_text_min > 59)
			as_text_min = 59;
		as_text_ask = get_state(autosave, ASTASK, SELECTED);

		as_prj = get_state(autosave, ASPROJ, SELECTED);
		as_prj_min = get_int(autosave, ASPMIN);
		if (as_prj_min == 0)
			as_prj = FALSE;
		if (as_prj_min > 59)
			as_prj_min = 59;
		as_prj_ask = get_state(autosave, ASPASK, SELECTED);

		do_all_icon(ALL_TYPES, DO_AUTOSAVE);
	}
}


/*
 * Globale Optionen
*/
bool	clip_on_disk, wind_cycle, f_to_desk;
int	transfer_size, bin_line_len;
int	fg_color, bg_color;
bool	save_opt, overwrite, blinking_cursor, ctrl_mark_mode, olga_autostart,
		emu_klammer;
PATH	helpprog;
char	bin_extension[BIN_ANZ][MUSTER_LEN+1];

static void do_avopen(WINDOWP window)
{
	send_avwinopen(window->handle);
}

static void do_avclose(WINDOWP window)
{
	send_avwinclose(window->handle);
}

static void set_popcolor(int s_obj, int d_obj)
{
	OBSPEC	spec;
	int		color;
					
	spec.index = get_obspec(popups, s_obj);
	color = spec.obspec.interiorcol;			/* neue Farbe holen */
	spec.index = get_obspec(globalop, d_obj);
	spec.obspec.interiorcol = color;			/* neue Farbe setzen */
	set_obspec(globalop, d_obj, spec.index);
}


void set_global_options(void)
{
	int	antw, i;
	bool	old_cycle, new_cycle, new_fg, new_bg;
	bool	close = FALSE;
	char	n[23] = "";
	MDIAL	*dial;
	PATH	new_helpprog;
	
	old_cycle = wind_cycle;
	set_state(globalop, GOASAVE, SELECTED, save_opt);
	set_state(globalop, GOCLIP, DISABLED, (clip_dir[0] == EOS));
	set_state(globalop, GOCLIP, SELECTED, clip_on_disk);
	set_state(globalop, GOBLINK, SELECTED, blinking_cursor);
	set_state(globalop, GOCTRL, SELECTED, ctrl_mark_mode);
	set_state(globalop, GOAVWIN, SELECTED, wind_cycle);
	set_state(globalop, GOAVKEY, SELECTED, f_to_desk);
	set_state(globalop, GOOLGA, SELECTED, olga_autostart);
	set_state(globalop, GOKLAMMER, SELECTED, emu_klammer);

	set_state(globalop, GOWDIAL, DISABLED, !prn->pdlg_avail);
	set_state(globalop, GOWDIAL, SELECTED, prn->use_pdlg);

	set_int(globalop, GOTRANS, transfer_size);

	if (helpprog[0] != EOS)
		make_shortpath(helpprog, n, 22);
	else
		strcpy(n, "");
	set_string(globalop, GOHELPNAME, n);
	strcpy(new_helpprog, helpprog);

	set_int(globalop, GOBLEN, bin_line_len);
	for (i = 4; i < BIN_ANZ; i++)
		set_string(globalop, i - 4 + GOBEXT1, bin_extension[i]);

	get_string(popups, fg_color + CPWHITE, n);
	set_string(globalop, GOFCPOP, n);
	set_popcolor(fg_color + CPWHITE - 16, GOFCOL);
	get_string(popups, bg_color + CPWHITE, n);
	set_string(globalop, GOBCPOP, n);
	set_popcolor(bg_color + CPWHITE - 16, GOBCOL);
	new_fg = fg_color;
	new_bg = bg_color;

	dial = open_mdial(globalop, GOTRANS);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{				
				case GOHELP :
					menu_help(TOPTIONS, MGLOBALO);
					break;
					
				case GOHELPSEL :
					if (select_single(new_helpprog, "", rsc_string(FINDHPSTR)))
					{
						make_shortpath(new_helpprog, n, 22);
						set_string(globalop, GOHELPNAME, n);
						redraw_mdobj(dial, GOHELPNAME);
					}
					break;
		
				case GOFCSTR :
				case GOFCPOP :
					if (antw == GOFCPOP)
						i = handle_popup(globalop, GOFCPOP, popups, COLORPOP, POP_OPEN);
					else
						i = handle_popup(globalop, GOFCPOP, popups, COLORPOP, POP_CYCLE);
					if (i > 0)
					{
						set_popcolor(i - 16, GOFCOL);
						redraw_mdobj(dial, GOFCOL);
						new_fg = i - CPWHITE;
					}
					break;

				case GOBCSTR :
				case GOBCPOP :
					if (antw == GOBCPOP)
						i = handle_popup(globalop, GOBCPOP, popups, COLORPOP, POP_OPEN);
					else
						i = handle_popup(globalop, GOBCPOP, popups, COLORPOP, POP_CYCLE);
					if (i > 0)
					{
						set_popcolor(i - 16, GOBCOL);
						redraw_mdobj(dial, GOBCOL);
						new_bg = i - CPWHITE;
					}
					break;

				default:
					close = TRUE;
					break;
			}
			if (!close)
			{
				set_state(globalop, antw, SELECTED, FALSE);
				redraw_mdobj(dial, antw);
			}
		}
		set_state(globalop, antw, SELECTED, FALSE);
		close_mdial(dial);
		if (antw == GOOK)
		{
			save_opt = get_state(globalop, GOASAVE, SELECTED);
			if (clip_dir[0] != EOS)
				clip_on_disk = get_state(globalop, GOCLIP, SELECTED);
			blinking_cursor = get_state(globalop, GOBLINK, SELECTED);
			ctrl_mark_mode = get_state(globalop, GOCTRL, SELECTED);
			prn->use_pdlg = get_state(globalop, GOWDIAL, SELECTED);
			olga_autostart = get_state(globalop, GOOLGA, SELECTED);
			emu_klammer = get_state(globalop, GOKLAMMER, SELECTED);
			transfer_size = get_int(globalop, GOTRANS);
			if (transfer_size == 0)
				transfer_size = 1;
	
			new_cycle = get_state(globalop, GOAVWIN, SELECTED);
			if (old_cycle && !new_cycle)						/* war an, nun aus */
			{
				do_all_window(CLASS_ALL, do_avclose);
				wind_cycle = new_cycle;
			}
			if (new_cycle && !old_cycle)						/* nun an, war aus */
			{
				wind_cycle = new_cycle;
				do_all_window(CLASS_ALL, do_avopen);
			}
			f_to_desk = get_state(globalop, GOAVKEY, SELECTED);
	
			bin_line_len = get_int(globalop, GOBLEN);
			if (bin_line_len < 1) 
				bin_line_len = 1;
			if (bin_line_len > MAX_LINE_LEN) 
				bin_line_len = MAX_LINE_LEN;
			for (i = 4; i < BIN_ANZ; i++)
				get_string(globalop, i - 4 + GOBEXT1, bin_extension[i]);
	
			strcpy(helpprog, new_helpprog);

			if (new_fg != fg_color || new_bg != bg_color) 
			{
				fg_color = new_fg;
				bg_color = new_bg;
				color_change();
			}
			
			if (olga_autostart)
				init_olga();
		}
	}
}

/*
 * Klammerpaare
*/
char	klammer_auf[11],
		klammer_zu[11];

void set_klammer_options(void)
{
	int	antw;
	char	s1[11], s2[11];
	
	set_string(klammer, KPAUF, klammer_auf);
	set_string(klammer, KPZU, klammer_zu);
	antw = simple_mdial(klammer, KPAUF);
	if (antw == KPOK)
	{
		get_string(klammer, KPAUF, s1);
		get_string(klammer, KPZU, s2);
		if (strlen(s1) == strlen(s2))
		{
			strcpy(klammer_auf, s1);
			strcpy(klammer_zu, s2);
		}
		else
			note(1, 0, KLAMMERERR);
	}
}



/*
 * Lokale Optionen
*/
LOCOPT	local_options[LOCAL_ANZ];

static int 	active_local_option;
static bool	krz_changed = FALSE;

static void null_locopt(LOCOPT *lo)
{
	strcpy(lo->muster, "");
	lo->tab = FALSE;
	lo->tabsize = 8;
	lo->einruecken = FALSE;
	strcpy(lo->wort_str,"A-Za-z0-9");
	str2set(lo->wort_str,lo->wort_set);
	lo->umbrechen  = FALSE;
	lo->format_by_load = FALSE;
	lo->format_by_paste = FALSE;
	strcpy(lo->umbruch_str,"");
	str2set(lo->umbruch_str,lo->umbruch_set);
	lo->lineal_len = 0;
	strcpy(lo->backup_ext, "");
	lo->backup = FALSE;
	lo->show_end = FALSE;
}

static void option_fill(void)
{
	char 		str[13] = "";
	LOCOPTP	lo;

	lo = &local_options[active_local_option];

	if (active_local_option < 2)
		strcpy(str, " ");
	else
		strcpy(str, " *.");
	strcat(str, lo->muster);
	set_string(localop, OTYPE, str);

	set_state(localop, OTAB, SELECTED, lo->tab);
	set_int(localop, OTABSIZE, lo->tabsize);
	set_state(localop, OEINRUCK, SELECTED, lo->einruecken);
	set_string(localop, OWORT, lo->wort_str);
	set_state(localop, OUMBRUCH, SELECTED, lo->umbrechen);
	set_state(localop, OFORMLOAD, SELECTED, lo->format_by_load);
	set_state(localop, OFORMPASTE, SELECTED, lo->format_by_paste);
	set_string(localop, OUMBTEXT, lo->umbruch_str);
	set_state(localop, OBACKUP, SELECTED, lo->backup);
	set_string(localop, OEXT, lo->backup_ext);
	set_int(localop, OLINEAL, lo->lineal_len);
	if (lo->kurzel[0] != EOS)
		file_name(lo->kurzel, str, FALSE);
	else
		strcpy(str, rsc_string(KURZELSTR));
	set_string(localop, OKURZELNAME, str);
	set_state(localop, OSHOWEND, SELECTED, lo->show_end);
}

static void option_get(void)
{
	LOCOPTP	lo;

	lo = &local_options[active_local_option];
	lo->tab = get_state(localop, OTAB, SELECTED);
	lo->tabsize = get_int(localop, OTABSIZE);
	if (lo->tabsize < 1 || lo->tabsize > 50)
		lo->tabsize = 3;
	lo->umbrechen = get_state(localop, OUMBRUCH, SELECTED);
	lo->einruecken = get_state(localop, OEINRUCK, SELECTED);
	get_string(localop, OUMBTEXT, lo->umbruch_str);
	str2set(lo->umbruch_str,lo->umbruch_set);
	lo->format_by_load = get_state(localop, OFORMLOAD, SELECTED);
	lo->format_by_paste = get_state(localop, OFORMPASTE, SELECTED);
	lo->backup = get_state(localop, OBACKUP, SELECTED);
	get_string(localop, OEXT, lo->backup_ext);
	lo->lineal_len = get_int(localop, OLINEAL);
	if (lo->lineal_len < 3 || lo->lineal_len > MAX_LINE_LEN) 
		lo->lineal_len = 65;
	get_string(localop, OWORT, lo->wort_str);
	str2set(lo->wort_str,lo->wort_set);
	lo->show_end = get_state(localop, OSHOWEND, SELECTED);
}


static void config_muster(void)
{
	int	i, antw;
	char 	str[MUSTER_LEN+1];

	for (i = MFIRST; i <= MLAST; i++)
		set_string(muster, i, local_options[i + 2 - MFIRST].muster);

	antw = simple_mdial(muster, MFIRST);
	if (antw == MOK)
	{
		for (i = MFIRST; i <= MLAST; i++)
		{
			get_string(muster, i, str);
			strcpy(local_options[i + 2 - MFIRST].muster, str);
		}

		/* wurde der aktive gelîscht? */
		if (local_options[active_local_option].muster[0] == EOS)
		{
			active_local_option = 0;
			set_string(localop, OTYPE, " *");
		}
	}
}


static bool build_popup(POPUP *pop)
{
	char	str[MUSTER_LEN + 4];
	int	i;

	strcpy(str, " ");
	strcat(str, local_options[0].muster);			/* * */
	create_popup(pop, LOCAL_ANZ, MUSTER_LEN+2, str);

	strcpy(str, " ");										/* Binary */
	strcat(str, local_options[1].muster);
	append_popup(pop, str);

	for (i = 2; i < LOCAL_ANZ; i++)
	{
		if (local_options[i].muster[0] != EOS)
		{
			strcpy(str, " *.");
			strcat(str, local_options[i].muster);
			append_popup(pop, str);
		}
	}

	append_popup(pop, "--");
	append_popup(pop, rsc_string(CHAGESTR));
	
	fix_popup(pop->tree, TRUE);
	
	return (pop->tree != NULL);
}


void set_local_options(void)
{
	int		antw, y;
	WINDOWP 	window;
	PATH		save_name;
	POPUP		pop;
	bool		close = FALSE;
	MDIAL		*dial;
	LOCOPT	*backup;
	
	active_local_option = 0;
	window = winlist_top();

	if ((window != NULL) && (window->class == CLASS_EDIT))
	{
		TEXTP t_ptr = get_text(window->handle);

		active_local_option = (int)(t_ptr->loc_opt - local_options);
	}

	option_fill();

	strcpy(save_name, local_options[active_local_option].kurzel);
	backup = (LOCOPT *)malloc(LOCAL_ANZ * sizeof(LOCOPT));
	memcpy(backup, local_options, (LOCAL_ANZ * sizeof(LOCOPT)));

	build_popup(&pop);
	
	dial = open_mdial(localop, OTABSIZE);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case OTYPESTR :
				case OTYPE :
					if (antw == OTYPE)
						y = handle_popup(localop, OTYPE, pop.tree, 0, POP_OPEN) - 1;
					else
						y = handle_popup(localop, OTYPE, pop.tree, 0, POP_CYCLE) - 1;
					if (y >= 0 && y != active_local_option)
					{
						if (y == pop.akt_item - 1)
						{
							config_muster();
							free_popup(&pop);		/* Popup neu aufbauen */
							build_popup(&pop);
							set_string(localop, OTYPE, " *");
						}
						else
						{
							option_get();
							active_local_option = y;
						}
						option_fill();
						redraw_mdobj(dial, OBOX);
					}
					break;
				case OKURZEL:
					if (shift_pressed())
					{
						strcpy(local_options[active_local_option].kurzel, "");
						krz_changed = TRUE;
						set_string(localop, OKURZELNAME, rsc_string(KURZELSTR));
						redraw_mdobj(dial, OKURZELNAME);
					}
					else
					{
						if (select_single(local_options[active_local_option].kurzel, 
												"*.krz", rsc_string(FINDKURZELSTR)))
						{
							FILENAME str;
							
							file_name(local_options[active_local_option].kurzel, str, FALSE);
							krz_changed = TRUE;
							set_string(localop, OKURZELNAME, str);
						}
					}
					break;
		
				case LCHELP :
					menu_help(TOPTIONS, MLOCALOP);
					break;

				default:
					close = TRUE;
					break;
			}
			if (!close)
			{
				set_state(localop, antw, SELECTED, FALSE);
				redraw_mdobj(dial, antw);
			}
		}
		set_state(localop, antw, SELECTED, FALSE);
		close_mdial(dial);
		free_popup(&pop);

		if (antw == OOK)
		{
			option_get();
			update_loc_opt();
			absatz_edit();
			ch_kurzel(local_options[active_local_option].kurzel, TRUE);
		}
		else
		{
			strcpy(local_options[active_local_option].kurzel, save_name);
			memcpy(local_options, backup, (LOCAL_ANZ * sizeof(LOCOPT)));
		}
		free(backup);
	}
}


/*
 * Defaulteinstellungen
*/
void init_default_var(void)
{
	int 		i;
	char		*c;

	font_id = 1;
	font_pts = 10;

	s_grkl     = FALSE;
	s_vorw	  = TRUE;
	s_global	  = TRUE;
	s_quant    = FALSE;
	s_wort	  = FALSE;
	s_round	  = FALSE;
	r_modus	  = RP_FIRST;
	s_str[0] = EOS;
	r_str[0] = EOS;
	ff_rekursiv= FALSE;
	ff_mask[0] = EOS;
	for (i = 0; i < HIST_ANZ; i++)
	{
		s_history[i][0] = EOS;
		r_history[i][0] = EOS;
	}
	rp_box_x	  = 0;
	rp_box_y	  = 0;

	save_opt	  = FALSE;
	wind_cycle = FALSE;
	clip_on_disk = TRUE;
	overwrite  = FALSE;
	transfer_size = 100;

	c = getenv("STGUIDE");
	if (c != NULL)
		strcpy(helpprog, c);
	else
		helpprog[0] = EOS;
		
	blinking_cursor = TRUE;
	ctrl_mark_mode = FALSE;
	f_to_desk = FALSE;
	
	for (i = 0; i < FEHLERANZ; i++)
		error[i][0] = EOS;

	for (i = 0; i < LOCAL_ANZ; i++)
		null_locopt(&local_options[i]);

	/* Default 1: * */
	strcpy(local_options[0].muster, "*");
	local_options[0].tab        = TRUE;
	local_options[0].tabsize    = 8;
	local_options[0].einruecken = TRUE;
	strcpy(local_options[0].umbruch_str,"- \t");
	str2set(local_options[0].umbruch_str,local_options[0].umbruch_set);
	local_options[0].lineal_len = 70;
	strcpy(local_options[0].backup_ext, "BAK");
	local_options[0].backup = FALSE;
	local_options[0].show_end = FALSE;

	/* Default 2: BinÑr */
	strcpy(local_options[1].muster, rsc_string(BINSTR));
	local_options[1].tab = FALSE;
	local_options[1].tabsize = 1;
	strcpy(local_options[1].backup_ext, "BAK");
	local_options[1].backup = TRUE;

	strcpy(bin_extension[0], "prg");
	strcpy(bin_extension[1], "app");
	strcpy(bin_extension[2], "tos");
	strcpy(bin_extension[3], "ttp");
	for (i = 4; i < BIN_ANZ; i++)	
		bin_extension[i][0] = EOS;

	se_autosave = FALSE;
	se_autosearch = FALSE;
	for (i = 0; i < SHELLANZ; i++)
	{
		se_shells[i].name[0] = EOS;
		se_shells[i].makefile[0] = EOS;
	}

	umlaut_from = 0;
	umlaut_to = 0;

	as_text 		= FALSE;
	as_text_min = 0;
	as_text_ask = FALSE;
	as_prj 		= FALSE;
	as_prj_min = 0;
	as_prj_ask = FALSE;

	bin_line_len = 80;

	strcpy(klammer_auf, "({[<\"\'");
	strcpy(klammer_zu, ")}]>\"\'");

	fg_color = BLACK;
	bg_color = WHITE;
	
	olga_autostart = FALSE;
	emu_klammer = FALSE;
}


/*
 * Datei
*/
#define CFGNAME	"qed.cfg"

static PATH			cfg_path = "";
static FILENAME	dsp_name;			/* Name der Display-Datei */
static FILE			*fd;
static LOCOPTP		lo = NULL;
static int			muster_nr = 1;

static bool get_cfg_path(void)
{
	bool	found = FALSE;
	PATH	env, p_for_save = "";
	
	if (path_from_env("QED", cfg_path))			/* 1. $QED */
	{
		strcat(cfg_path, CFGNAME);
		strcpy(p_for_save, cfg_path);
		found = file_exists(cfg_path);
	}

	if (!gl_debug)
	if (!found && path_from_env("HOME", env))	/* 2. $HOME */
	{
		bool	h = FALSE;
		
		strcpy(cfg_path, env);
		strcat(cfg_path, CFGNAME);
		if (p_for_save[0] == EOS)
		{
			h = TRUE;
			strcpy(p_for_save, cfg_path);
		}
		found = file_exists(cfg_path);
		if (!found)										/* 2a. $HOME/defaults */
		{
			strcpy(cfg_path, env);
			strcat(cfg_path, "defaults\\");
			if (path_exists(cfg_path))
			{
				strcat(cfg_path, CFGNAME);
				if (p_for_save[0] == EOS || h)
					strcpy(p_for_save, cfg_path);
				found = file_exists(cfg_path);
			}
		}		
	}

	if (!found && gl_appdir[0] != EOS)			/* 3. Startverzeichnis */
	{
		strcpy(cfg_path, gl_appdir);
		strcat(cfg_path, CFGNAME);
		if (p_for_save[0] == EOS)
			strcpy(p_for_save, cfg_path);
		found = file_exists(cfg_path);
	}

	if (!found && file_exists(CFGNAME))			/* 4. aktuelles Verzeichnis */
	{
		get_path(cfg_path, 0);
		strcat(cfg_path, CFGNAME);
		if (p_for_save[0] == EOS)
			strcpy(p_for_save, cfg_path);
		found = TRUE;
	}

	if (!found)
		strcpy(cfg_path, p_for_save);

	sprintf(dsp_name, "%04d%04d.qed", gl_desk.g_x + gl_desk.g_w, gl_desk.g_y + gl_desk.g_h);
/*
debug("cfg_path: %s (%d)\n", cfg_path, found);
*/
	return found;
}

/******************************************************************************/
/* Dateioperation: Laden																		*/
/******************************************************************************/
void read_cfg_bool(char *str, bool *val)
{
	if (stricmp(str, "TRUE") == 0)
		*val = TRUE;
	if (stricmp(str, "FALSE") == 0)
		*val = FALSE;
}

void read_cfg_str(char *str, char *val)
{
	val[0] = EOS;
	if ((str[0] == '"') && (str[1] == '"'))	/* nur "" -> leer */
		return;
	else
	{
		int	len, i, j;
		
		if (str[0] == '"')
		{
			len = (int)strlen(str);
			j = 0;
			i = 1;
			while ((str[i] != '\"') && (i < len))
			{
				if ((str[i] == '\\') && (str[i+1] == '"'))
					i++;
				val[j++] = str[i++];
			}
			val[j] = EOS;
		}
	}
}


static void parse_line(POSENTRY **arglist, char *zeile)
{
	char	var[30], *p, tmp[80];
	int	x, i, d;
	long	y;
	PATH	filename;
					
	p = strchr(zeile, '=');
	if (p != NULL)
	{
		strncpy(var, zeile, p-zeile);
		var[p-zeile] = EOS;
		strcpy(buffer, p+1);

		/* Autosave */
		if (strcmp(var, "AutoSavePrj") == 0)
			read_cfg_bool(buffer, &as_prj);
		else if(strcmp(var, "AutoSavePrjAsk") == 0)
			read_cfg_bool(buffer, &as_prj_ask);
		else if(strcmp(var, "AutoSavePrjMin") == 0)
			as_prj_min = atoi(buffer);
		else if(strcmp(var, "AutoSaveText") == 0)
			read_cfg_bool(buffer, &as_text);
		else if(strcmp(var, "AutoSaveTextAsk") == 0)
			read_cfg_bool(buffer, &as_text_ask);
		else if(strcmp(var, "AutoSaveTextMin") == 0)
			as_text_min = atoi(buffer);

		/* BinÑr-Extensions */
		else if (strcmp(var, "BinExtension") == 0)
		{
			read_cfg_str(buffer, tmp);
			for (i = 0; i < BIN_ANZ; i++)
			{
				if (stricmp(bin_extension[i], tmp) == 0)	/* schon drin */
					break;
				if (bin_extension[i][0] == EOS)
				{
					strcpy(bin_extension[i], tmp);
					break;
				}
			}
		}

		/* DefaultPrj */
		else if(strcmp(var, "DefaultPrj") == 0)
		{
			read_cfg_str(buffer, def_prj_path);
			set_def_prj();
		}
		
		/* Fehlerzeilen */
		else if(strcmp(var, "Error") == 0)
		{
			read_cfg_str(buffer, tmp);
			set_errorline(tmp);
		}
		
		/* Globales */
		else if (strcmp(var, "GlobalAutosaveCfg") == 0)
			read_cfg_bool(buffer, &save_opt);
		else if (strcmp(var, "GlobalBgColor") == 0)
			bg_color = atoi(buffer);
		else if (strcmp(var, "GlobalBinLineLen") == 0)
			bin_line_len = atoi(buffer);
		else if (strcmp(var, "GlobalBlinkCursor") == 0)
			read_cfg_bool(buffer, &blinking_cursor);
		else if (strcmp(var, "GlobalCtrlBlock") == 0)
			read_cfg_bool(buffer, &ctrl_mark_mode);
		else if (strcmp(var, "GlobalEmuKlammer") == 0)
			read_cfg_bool(buffer, &emu_klammer);
		else if (strcmp(var, "GlobalFgColor") == 0)
			fg_color = atoi(buffer);
		else if (strcmp(var, "GlobalFtoDesk") == 0)
			read_cfg_bool(buffer, &f_to_desk);
		else if (strcmp(var, "GlobalGEMClip") == 0)
			read_cfg_bool(buffer, &clip_on_disk);
		else if (strcmp(var, "GlobalOlga") == 0)
			read_cfg_bool(buffer, &olga_autostart);
		else if (strcmp(var, "GlobalOverwrite") == 0)
			read_cfg_bool(buffer, &overwrite);
		else if (strcmp(var, "GlobalTransSize") == 0)
			transfer_size = atoi(buffer);
		else if (strcmp(var, "GlobalWindCycle") == 0)
			read_cfg_bool(buffer, &wind_cycle);

		/* Hilfe-Programm */
		else if (strcmp(var, "HelpProgram") == 0)
			read_cfg_str(buffer, helpprog);
		
		/* Klammerpaare */
		else if (strcmp(var, "KlammerAuf") == 0)
			read_cfg_str(buffer, klammer_auf);
		else if (strcmp(var, "KlammerZu") == 0)
			read_cfg_str(buffer, klammer_zu);
			
		/* Lokales */
		else if (strcmp(var, "LocalBegin") == 0)
		{
			read_cfg_str(buffer, tmp);

			/* SonderfÑlle */
			if (strcmp(tmp, "*") == 0)
				muster_nr = 0;
			else if (strcmp(tmp, rsc_string(BINSTR)) == 0)
				muster_nr = 1;
			else
				muster_nr++;

			lo = &(local_options[muster_nr]);
			strcpy(lo->muster, tmp);
		}
		else if (strcmp(var, "LocalEnd") == 0)
		{
			lo = NULL;
			if (muster_nr == 0)
				muster_nr = 1;
		}
		else if ((strcmp(var, "LocalBackup") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->backup));
		else if ((strcmp(var, "LocalBackupExt") == 0) && (lo != NULL))
			read_cfg_str(buffer, lo->backup_ext);
		else if ((strcmp(var, "LocalInsert") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->einruecken));
		else if ((strcmp(var, "LocalKurzel") == 0) && (lo != NULL))
			read_cfg_str(buffer, lo->kurzel);
		else if ((strcmp(var, "LocalTab") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->tab));
		else if ((strcmp(var, "LocalTabSize") == 0) && (lo != NULL))
			lo->tabsize = atoi(buffer);
		else if ((strcmp(var, "LocalUmbruch") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->umbrechen));
		else if ((strcmp(var, "LocalUmbruchLineLen") == 0) && (lo != NULL))
			lo->lineal_len = atoi(buffer);
		else if ((strcmp(var, "LocalUmbruchIns") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->format_by_paste));
		else if ((strcmp(var, "LocalUmbruchLoad") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->format_by_load));
		else if ((strcmp(var, "LocalUmbruchAt") == 0) && (lo != NULL))
		{
			read_cfg_str(buffer, lo->umbruch_str);
			str2set(lo->umbruch_str, lo->umbruch_set);
		}
		else if ((strcmp(var, "LocalUmbruchShow") == 0) && (lo != NULL))
			read_cfg_bool(buffer, &(lo->show_end));
		else if ((strcmp(var, "LocalWordSet") == 0) && (lo != NULL))
		{
			read_cfg_str(buffer, lo->wort_str);
			str2set(lo->wort_str,lo->wort_set);
		}		

		/* Makro */
		else if (strcmp(var, "Makro") == 0)
			set_makro_str(buffer);

		/* Marken */
		else if (strcmp(var, "Marke") == 0)
		{
			read_cfg_str(buffer, filename);
			d = sscanf(buffer + strlen(filename) + 3, "%d \"%[^\"]\" %ld %d", &i, tmp, &y, &x);
			if (d != 4)		/* altes Format (<4.10) ohne " um tmp */
				sscanf(buffer + strlen(filename) + 3, "%d %s %ld %d", &i, tmp, &y, &x);
			set_marke(i, tmp, filename, y, x);
		}

		/* offenen Dateien */
		else if (strcmp(var, "OpenPrj") == 0)
		{
			read_cfg_str(buffer, filename);
			insert_poslist(arglist, filename, 0, 0);
		}
		else if (strcmp(var, "OpenText") == 0)
		{
			read_cfg_str(buffer, filename);
			sscanf(buffer + strlen(filename) + 3, "%ld %d", &y, &x);
			insert_poslist(arglist, filename, x, y);
		}
		
		/* Drucker */
		else if (prn_get_cfg(var, buffer))
			/* do nothing */ ;

		/* Ersetzen */
		else if (strcmp(var, "ReplaceBox") == 0)
			sscanf(buffer, "%d %d", &rp_box_x, &rp_box_y);
		else if (strcmp(var, "ReplaceMode") == 0)
			r_modus = atoi(buffer);
		else if (strcmp(var, "ReplaceStr") == 0)
			read_cfg_str(buffer, r_str);
		else if (strcmp(var, "ReplaceHistory") == 0)
		{
			read_cfg_str(buffer, tmp);
			for (i = 0; i < HIST_ANZ; i++)
				if (r_history[i][0] == EOS)
					break;
			if (i < HIST_ANZ)
				strcpy(r_history[i], tmp);
		}
		else if (strcmp(var, "ReplaceUmlautFrom") == 0)
			umlaut_from = atoi(buffer);
		else if (strcmp(var, "ReplaceUmlautTo") == 0)
			umlaut_to = atoi(buffer);

		/* Suchen */
		else if (strcmp(var, "SearchFileMask") == 0)
			read_cfg_str(buffer, ff_mask);
		else if (strcmp(var, "SearchFileRek") == 0)
			read_cfg_bool(buffer, &ff_rekursiv);
		else if (strcmp(var, "SearchDown") == 0)
			read_cfg_bool(buffer, &s_vorw);
		else if (strcmp(var, "SearchGlobal") == 0)
			read_cfg_bool(buffer, &s_global);
		else if (strcmp(var, "SearchGrkl") == 0)
			read_cfg_bool(buffer, &s_grkl);
		else if (strcmp(var, "SearchHistory") == 0)
		{
			read_cfg_str(buffer, tmp);
			for (i = 0; i < HIST_ANZ; i++)
				if (s_history[i][0] == EOS)
					break;
			if (i < HIST_ANZ)
				strcpy(s_history[i], tmp);
		}
		else if (strcmp(var, "SearchQuant") == 0)
			read_cfg_bool(buffer, &s_quant);
		else if (strcmp(var, "SearchRound") == 0)
			read_cfg_bool(buffer, &s_round);
		else if (strcmp(var, "SearchWord") == 0)
			read_cfg_bool(buffer, &s_wort);
		else if (strcmp(var, "SearchStr") == 0)
			read_cfg_str(buffer, s_str);
			
		/* SE-Protokoll */
		else if (strcmp(var, "SESave") == 0)
			read_cfg_bool(buffer, &se_autosave);
		else if (strcmp(var, "SESearch") == 0)
			read_cfg_bool(buffer, &se_autosearch);
		else if (strcmp(var, "SEShellName") == 0)
		{
			read_cfg_str(buffer, tmp);
			for (i = 0; i < SHELLANZ; i++)
				if (se_shells[i].name[0] == EOS)
					break;
			if (i < SHELLANZ)
				strcpy(se_shells[i].name, tmp);
		}

		/* Fensterfont */
		else if (strcmp(var, "WinFontID") == 0)
			font_id = atoi(buffer);
		else if (strcmp(var, "WinFontSize") == 0)
			font_pts = atoi(buffer);

		/* Fensterposition */
		else if (strcmp(var, "Window") == 0)
		{
			int	class;
			GRECT	size;
			
			sscanf(buffer, "%d %d %d %d %d", &class, &size.g_x, &size.g_y,
																 &size.g_w, &size.g_h);
			add_winlist(class, &size);
		}


		/* Unbekannte Zeile */
		else
		{
			if (strlen(var) > 28)
				var[28] = EOS;
			snote(1, 0, WRONGINF, var);
		}
	}
	else
	{
		if (strlen(zeile) > 28)
			zeile[28] = EOS;
		snote(1, 0, WRONGINF, zeile);
	}
}

void option_load(POSENTRY **list)
{
	PATH	tmp;

	if (!get_cfg_path())					/* keine qed.cfg gefunden */
		return;

	fd = fopen(cfg_path, "r");
	if (fd != NULL)
	{
		/* 1. Zeile auf ID checken */
		fgets(buffer, (int)sizeof(buffer), fd);
		if (strncmp(buffer, "ID=qed", 6) == 0)
		{
			while (fgets(buffer, (int)sizeof(buffer), fd) != NULL)
			{
				if (buffer[strlen(buffer) - 1] == '\n')
					buffer[strlen(buffer) - 1] = EOS;
				parse_line(list, buffer);
			}
		}
		else
		{
			/* Zeile kurzhacken */
			if (strlen(buffer) > 28)
				buffer[28] = EOS;
			snote(1, 0, WRONGINF, buffer);
		}
		fclose(fd);
		fd = NULL;

		/* Bildschirm-abhÑngige Parameter sichern */
		split_filename(cfg_path, tmp, NULL);
		strcat(tmp, dsp_name);
		fd = fopen(tmp, "r");
		if (fd != NULL)
		{
			/* 1. Zeile auf ID checken */
			fgets(buffer, (int)sizeof(buffer), fd);
			if (strncmp(buffer, "ID=qed display configuration", 28) == 0)
			{
				while (fgets(buffer, (int)sizeof(buffer), fd) != NULL)
				{
					if (buffer[strlen(buffer) - 1] == '\n')
						buffer[strlen(buffer) - 1] = EOS;
					parse_line(list, buffer);
				}
			}
			else
			{
				/* Zeile kurzhacken */
				if (strlen(buffer) > 28)
					buffer[28] = EOS;
				snote(1, 0, WRONGINF, buffer);
			}

			fclose(fd);
			fd = NULL;
			
			if (gl_planes == 1)
			{
				fg_color = BLACK;
				bg_color = WHITE;
			}
			set_drawmode();
			
		}
		/* Zum Schluû noch 'pdlg.qed' */
		prn_get_cfg("PdlgRead", cfg_path);
	}
}


/******************************************************************************/
/* Dateioperation: Speichern																	*/
/******************************************************************************/
void write_cfg_str(char *var, char *value)
{
	if (strchr(value, '\"') != NULL)	/* " in value fÅhrt zu \" in der Datei */
	{
		int	len, i;

		fprintf(fd, "%s=\"", var);
		len = (int)strlen(value);
		for (i = 0; i < len; i++)
		{
			if (value[i] == '\"')
				fputc('\\', fd);
			fputc(value[i], fd);
		}
		fprintf(fd, "\"\n");
	}
	else
		fprintf(fd, "%s=\"%s\"\n", var, value);
}

void write_cfg_int(char *var, int value)
{
	fprintf(fd, "%s=%d\n", var, value);
}

void write_cfg_long(char *var, long value)
{
	fprintf(fd, "%s=%ld\n", var, value);
}

void write_cfg_bool(char *var, bool bool)
{
	char	str[6];
	
	if (bool)
		strcpy(str, "TRUE");
	else
		strcpy(str, "FALSE");
	fprintf(fd, "%s=%s\n", var, str);
}

static void save_open_text(TEXTP t_ptr)
{
	WINDOWP	w = get_window(t_ptr->link);

	if (!t_ptr->namenlos)
	{
		if (w->class == CLASS_EDIT)
		{
			fprintf(fd, "OpenText=\"%s\" %ld %d\n", t_ptr->filename, t_ptr->ypos,
							bild_pos(t_ptr->xpos, t_ptr->cursor_line, t_ptr->loc_opt->tab, t_ptr->loc_opt->tabsize));
		}
		if (w->class == CLASS_PROJEKT)
			write_cfg_str("OpenPrj", t_ptr->filename); 
	}
}

void option_save(void)
{
	int		i, x;
	long		y;
	char		tmp[50];
	LOCOPTP	lo;

	fd = fopen(cfg_path, "w");
	if (fd != NULL)
	{
		/* ID zur identifizierung */
		fprintf(fd, "ID=qed %s\n", QED_VERSION);
	
		/* Autosave */	
		write_cfg_bool("AutoSavePrj", as_prj);
		write_cfg_bool("AutoSavePrjAsk", as_prj_ask);
		write_cfg_int("AutoSavePrjMin", as_prj_min);
		write_cfg_bool("AutoSaveText", as_text);
		write_cfg_bool("AutoSaveTextAsk", as_text_ask);
		write_cfg_int("AutoSaveTextMin", as_text_min);

		/* BinÑr-Extionsions */	
		for (i = 4; i < BIN_ANZ; i++)
			if (bin_extension[i][0] != EOS)
				write_cfg_str("BinExtension", bin_extension[i]);

		/* Defaultprojekt */
		write_cfg_str("DefaultPrj", def_prj_path);
	
		/* Fehlerzeilen */	
		for (i = 0; i < FEHLERANZ; i++)
		{
			if (error[i][0] != EOS)
				write_cfg_str("Error", error[i]);
		}
	
		/* Globales */
		write_cfg_bool("GlobalAutosaveCfg", save_opt);
		write_cfg_int ("GlobalBinLineLen", bin_line_len);
		write_cfg_bool("GlobalBlinkCursor", blinking_cursor);
		write_cfg_bool("GlobalCtrlBlock", ctrl_mark_mode);
		write_cfg_bool("GlobalEmuKlammer", emu_klammer);
		write_cfg_bool("GlobalFtoDesk", f_to_desk);
		write_cfg_bool("GlobalGEMClip", clip_on_disk);
		write_cfg_bool("GlobalOlga", olga_autostart);
		write_cfg_bool("GlobalOverwrite", overwrite);
		write_cfg_int ("GlobalTransSize", transfer_size);
		write_cfg_bool("GlobalWindCycle", wind_cycle);
	
		/* Hilfeprogramm */
		write_cfg_str("HelpProgram", helpprog);
	
		/* Klammerpaare */
		write_cfg_str("KlammerAuf", klammer_auf);
		write_cfg_str("KlammerZu", klammer_zu);

		/* Lokales */	
		for (i = 0; i < LOCAL_ANZ; i++)
		{
			lo = &local_options[i];
			if (lo->muster[0] != EOS)
			{
				write_cfg_str("LocalBegin", lo->muster);			
				write_cfg_bool("LocalBackup", lo->backup);
				write_cfg_str("LocalBackupExt", lo->backup_ext);
				write_cfg_bool("LocalInsert", lo->einruecken);
				write_cfg_str("LocalKurzel", lo->kurzel);
				write_cfg_bool("LocalTab", lo->tab);
				write_cfg_int("LocalTabSize", lo->tabsize);
				write_cfg_bool("LocalUmbruch", lo->umbrechen);
				write_cfg_int("LocalUmbruchLineLen", lo->lineal_len);
				write_cfg_bool("LocalUmbruchIns", lo->format_by_paste);
				write_cfg_bool("LocalUmbruchLoad", lo->format_by_load);
				write_cfg_str("LocalUmbruchAt", lo->umbruch_str);
				write_cfg_bool("LocalUmbruchShow", lo->show_end);
				write_cfg_str("LocalWordSet", lo->wort_str);
				write_cfg_str("LocalEnd", lo->muster);			
			}
		}
	
		/* Makros */
		for (i = 0; i < MAKRO_ANZ; i++)
		{
			if (get_makro_str(i, buffer))
				fprintf(fd, "Makro=%s\n", buffer);
		}
		
		/* Marken */
		for (i = 0; i < MARKEN_ANZ; i++)
		{
			if (get_marke(i, tmp, buffer, &y, &x))
				fprintf(fd, "Marke=\"%s\" %d \"%s\" %ld %d\n", buffer, i, tmp, y, x);
		}
	
		/* Drucker */
		prn_save_cfg(cfg_path);

		/* Ersetzen */
		write_cfg_int("ReplaceMode", r_modus);
		write_cfg_str("ReplaceStr", r_str);
		for (i = 0; i < HIST_ANZ; i++)
		{
			if (r_history[i][0] != EOS)
				write_cfg_str("ReplaceHistory", r_history[i]);
		}
		write_cfg_int("ReplaceUmlautFrom", umlaut_from);				
		write_cfg_int("ReplaceUmlautTo", umlaut_to);				

		/* Suchen */
		write_cfg_str("SearchFileMask", ff_mask);
		write_cfg_bool("SearchFileRek", ff_rekursiv);
		write_cfg_bool("SearchDown", s_vorw);
		write_cfg_bool("SearchGlobal", s_global);
		write_cfg_bool("SearchGrkl", s_grkl);
		for (i = 0; i < HIST_ANZ; i++)
		{
			if (s_history[i][0] != EOS)
				write_cfg_str("SearchHistory", s_history[i]);
		}
		write_cfg_bool("SearchQuant", s_quant);
		write_cfg_bool("SearchRound", s_round);
		write_cfg_bool("SearchWord", s_wort);
		write_cfg_str("SearchStr", s_str);

		/* SE-Protokoll */
		write_cfg_bool("SESave", se_autosave);
		write_cfg_bool("SESearch", se_autosearch);
		for (i = 0; i < SHELLANZ - 1; i++)
		{
			if (se_shells[i].name[0] != EOS)
				write_cfg_str("SEShellName", se_shells[i].name);
		}			
		
		fclose(fd);
		fd = NULL;

		/* Bildschirm-abhÑngige Parameter sichern */
		split_filename(cfg_path, tmp, NULL);
		strcat(tmp, dsp_name);
		fd = fopen(tmp, "w");
		if (fd != NULL)
		{
			fprintf(fd, "ID=qed display configuration\n");

			/* Farb-Infos */
			write_cfg_int("GlobalBgColor", bg_color);
			write_cfg_int("GlobalFgColor", fg_color);

			/* geladene Dateien */
			do_all_text(save_open_text);

			/* Pos. der Replace-Ask-Box */
			fprintf(fd, "ReplaceBox=%d %d\n", rp_box_x, rp_box_y);

			/* Fensterfont */	
			write_cfg_int("WinFontID", font_id);
			write_cfg_int("WinFontSize", font_pts);
	
			/* Fensterposition */
			save_winlist(fd);

			fclose(fd);
			fd = NULL;
		}
	}
	else
		note(1, 0, WRITEERR);
}

