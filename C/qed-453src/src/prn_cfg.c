#include <gemx.h>

#include "global.h"
#include "file.h"
#include "options.h"
#include "printer.h"
#include "rsc.h"
#include "wp-print.h"

/*
 * aus cflib
*/
extern void handle_mdial_msg(int *msg);

/*
 * globale Variablen
*/
PRN_CFG	*prn;

/*
 * lokales
*/
static int	gdos_device = 21;			/* Dev-Nummer 21 .. 30 */
static char	gdos_name[80] = "";		/* Dev-Name */
static int	fnt_anz;
static bool	wp_config_read = FALSE;

#define CFGNAME	"pdlg.qed"			/* Name der Settings-Datei */

/* --------------------------------------------------------------------------- */
bool open_printer(void)
{
	int	work_out[57];
	int	i, p_xy[4];
	bool	ret = FALSE;
	
	if (prn->use_pdlg)
		prn->handle = v_opnprn(gl_phys_handle, prn->pdlg, work_out);
	else
	{
		int	work_in[16];

		work_in[0] = gdos_device;
		for (i=1; i < 10; i++)
			work_in[i] = 1;
		work_in[10] = 2;
		for (i=11; i < 16; i++)
			work_in[i] = 0;
		v_opnwk(work_in, &prn->handle, work_out);
	}
	if (prn->handle)
	{
		fnt_anz = work_out[10] + vst_load_fonts(prn->handle, 0);
	
		prn->height = work_out[1];
		p_xy[0] = 0;
		p_xy[1] = 0;
		p_xy[2] = work_out[0] - 1;
		p_xy[3] = work_out[1] + 1;
		vs_clip(prn->handle, TRUE, p_xy);
		vswr_mode(prn->handle, MD_TRANS);
		ret = TRUE;
	}
	return ret;
}


void close_printer(void)
{
	vst_unload_fonts(prn->handle, 0);
	v_clswk(prn->handle);
}


static void get_fontname(int id, char *name)
{
	int	d;
	
	if (open_printer())
	{
		for (d = 1; d <= fnt_anz; d++)
			if (vqt_name(prn->handle, d, name) == id)
				break;
		close_printer();
	}
	else
		strcpy(name, "???");
}


static bool sel_font(PRN_CFG *cfg)
{
	bool	ok = FALSE;
	int	n_id, n_pts;
	
	n_id = cfg->font_id;
	n_pts = cfg->font_pts;
	
	ok = do_fontsel((FS_M_XFSL|FS_M_MAGX), rsc_string(SELPFONTSTR), &n_id, &n_pts);
	if (ok)
	{
		cfg->font_id = n_id;
		cfg->font_pts = n_pts;
		ok = TRUE;
	}
	else if (n_id == -1 && n_pts == -1)
		note(1, 0, NOFSL);

	return ok;
}

/* --------------------------------------------------------------------------- */
/*
 * WDIALOG
*/

/*
 * Callbacks fr Sub-Dialog
*/
long cdecl init_qed_sub(PRN_SETTINGS *settings, PDLG_SUB *sub_dialog)
{
	OBJECT	*tree;
	int		offset;
	PRN_CFG	*cfg;
	char		tmp[40];
	
	cfg = (PRN_CFG *)sub_dialog->private1;
	tree = sub_dialog->tree;
	offset = sub_dialog->index_offset;

	set_int(tree, PS_GFPTS + offset, cfg->font_pts);
	get_fontname(cfg->font_id, tmp);
	set_string(tree, PS_GFNAME + offset, tmp);

	set_state(tree, PS_ALL + offset, DISABLED, !cfg->ausdruck);
	set_state(tree, PS_BLOCK + offset, DISABLED, (!cfg->ausdruck || !cfg->block));

	set_state(tree, PS_ALL + offset, SELECTED, !cfg->block);
	set_state(tree, PS_BLOCK + offset, SELECTED, cfg->block);
	
	set_state(tree, PS_ZNUM + offset, SELECTED, cfg->num_zeilen);
	set_state(tree, PS_SNUM + offset, SELECTED, cfg->num_seiten);
	
	set_int(tree, PS_RANDLEN + offset, cfg->rand_len);

	return 1;
}

long cdecl do_qed_sub(PRN_SETTINGS *settings, PDLG_SUB *sub_dialog, short exit_obj)
{
	OBJECT	*tree;
	int		offset;
	PRN_CFG	*cfg;
	
	cfg = (PRN_CFG *)sub_dialog->private1;
	tree = sub_dialog->tree;
	offset = sub_dialog->index_offset;
	switch (exit_obj - offset)
	{
		case PS_GFSEL :
			if (sel_font(cfg))
			{
				char	tmp[40];
				
				set_int(tree, PS_GFPTS + offset, cfg->font_pts);
				get_fontname(cfg->font_id, tmp);
				set_string(tree, PS_GFNAME + offset, tmp);
				redraw_obj(tree, PS_GFPTS + offset);
				redraw_obj(tree, PS_GFNAME + offset);
			}
			set_state(tree, exit_obj, SELECTED, FALSE);
			redraw_obj(tree, exit_obj);
			break;

		default:
			break;
	}
	return 1;
}

long cdecl reset_qed_sub(PRN_SETTINGS *settings, PDLG_SUB *sub_dialog)
{
	OBJECT	*tree;
	int		offset;
	PRN_CFG	*cfg;
	
	cfg = (PRN_CFG *)sub_dialog->private1;
	tree = sub_dialog->tree;
	offset = sub_dialog->index_offset;
	
	if (cfg->ausdruck)
		cfg->block = get_state(tree, PS_BLOCK + offset, SELECTED);

	cfg->num_zeilen = get_state(tree, PS_ZNUM + offset, SELECTED);
	cfg->num_seiten = get_state(tree, PS_SNUM + offset, SELECTED);
	cfg->rand_len = get_int(tree, PS_RANDLEN + offset);

	return 1;
}


static bool pdlg_dial(PRN_CFG *cfg)
{
	PRN_DIALOG		*prn_dialog;
	PRN_SETTINGS	*new;
	int				d, button, ret, handle;
	EVNT				ev;
	OBJECT			*tree;
	
	new = malloc(sizeof(PRN_SETTINGS));
	memcpy(new, cfg->pdlg, sizeof(PRN_SETTINGS));

	prn_dialog = pdlg_create(PDLG_3D);
	if (prn_dialog)
	{
		PDLG_SUB	*sub = NULL;

		disable_menu();

		/* Unterdialog einh„ngen */
		sub = malloc(sizeof(PDLG_SUB));
		if (sub)
		{
			memset(sub, 0, sizeof(PDLG_SUB));
			sub->sub_id = -1;
			rsrc_gaddr(R_TREE, PRN_ICON, &tree);
			sub->sub_icon = tree + 1;				/* Zeiger auf das Icon */
			sub->sub_tree = printer_sub;			/* Zeiger auf den Unterdialog */
			sub->init_dlg = init_qed_sub;			/* Initialisierungsfunktion */
			sub->do_dlg = do_qed_sub;				/* Behandlungsfunktion */
			sub->reset_dlg = reset_qed_sub;		/* Zurcksetzfunktion */

			sub->private1 = (long)cfg;

			pdlg_add_sub_dialogs(prn_dialog, sub);
		}

		if (cfg->ausdruck)
			handle = pdlg_open(prn_dialog, new, "qed", 0x0001, -1, -1);
		else
			handle = pdlg_open(prn_dialog, new, "qed", 0x0000, -1, -1);
		do
		{
			ev.mwhich = (short)evnt_multi(MU_KEYBD|MU_MESAG|MU_BUTTON, 2, 1, 1, 
												0, 0, 0, 0, 0,	0, 0, 0, 0, 0,
												(int*)ev.msg, 0, 
												(int*)&ev.mx, (int*)&ev.my, 
												(int*)&ev.mbutton, 
												(int*)&ev.kstate,	(int*)&ev.key, 
												(int*)&ev.mclicks);
			if (ev.mwhich & MU_MESAG)
			{
				switch (ev.msg[0])
				{
					case WM_REDRAW :
					case WM_MOVED :
					case WM_SIZED:
						if (ev.msg[3] != handle)	/* fr fremdes Fenster */
						{
							handle_mdial_msg((int *)ev.msg);
						}
						break;
	
					case WM_BOTTOMED:					/* nicht erlaubt! */
						break;
					
					case WM_TOPPED :
					case WM_NEWTOP :
					case WM_ONTOP :		
						ev.msg[0] = WM_TOPPED;		/* immer Druckerbox toppen! */
						ev.msg[3] = handle;
						break;
				}
	
			}
			ret = pdlg_evnt(prn_dialog, new, &ev, &button);
		} 
		while (ret == 1);
		
		if (button == PDLG_OK)
		{
			memcpy(cfg->pdlg, new, sizeof(PRN_SETTINGS));
			pdlg_use_settings(prn_dialog, new);
		}

		pdlg_close(prn_dialog, &d, &d);

		if (sub)
		{
			pdlg_remove_sub_dialogs(prn_dialog);
			free(sub);
		}

		pdlg_delete(prn_dialog);
		free(new);

		enable_menu();

		return (button == PDLG_OK);
	}
	return FALSE;
}


/* --------------------------------------------------------------------------- */
/*
 * qed-Dialog
*/

static void get_devinfo(int handle, int device, char *devname)
{
	if (gl_nvdi >= 0x300)
	{
		int	d;
		char	s[80];

		vq_devinfo(handle, device, &d, s, devname);
	}
	else
		sprintf(devname, "GDOS Printer %d", device);
}

static bool get_gdos_device(void)
{
	if (gdos_device == 0 || gdos_name[0] == EOS)
	{
		int	work_in[16];
		int	work_out[57];
		int	i, handle;
		
		for (i=1; i < 10; i++)
			work_in[i] = 1;
		work_in[10] = 2;
		for (i=11; i < 16; i++)
			work_in[i] = 0;
		for (i = 21; i < 31; i++)
		{
			work_in[0] = i;
			v_opnwk(work_in, &handle, work_out);
			if (handle > 0)
			{
				gdos_device = i;
				get_devinfo(handle, i, gdos_name);
				v_clswk(handle);
				break;
			}
		}
		gdos_name[32] = EOS;				/* mehr passt nicht in den G_STRING! */
	}
	return (gdos_device > 0);
}


static bool qed_cfg_dial(PRN_CFG *cfg)
{
	char		tmp[33];
	int		antw, i;
	bool		close = FALSE;
	PATH		str = "";
	MDIAL		*dial;
	
	/* GEMDOS */
	switch (cfg->wp_mode)
	{
		case ELITE:
			i = DICHTEELITE;
			break;
		case CONDENSED:
			i = DICHTECOND;
			break;
		default:
			i = DICHTEPICA;
			break;
	}
	set_string(printer, DDICHTE, (char *)get_obspec(popups, i));
	if (!wp_config_read && cfg->wp_treiber[0] != EOS)
		wp_config_read = wp_load_cfgfile(cfg->wp_treiber);
	if (wp_config_read)
		wp_get_prnname(tmp, 25);
	else
		strcpy(tmp, rsc_string(NODEVSTR));

	set_state(printer, DNLQ, DISABLED, !wp_config_read);
	set_state(printer, DDICHTE, DISABLED, !wp_config_read);
	set_state(printer, DDICHTESTR, DISABLED, !wp_config_read);

	set_state(printer, DNLQ, SELECTED, cfg->wp_nlq);
	set_string(printer, DTREIBNAME, tmp);
	set_int(printer, DPLENGTH, cfg->wp_s_len);
	set_int(printer, DPWIDTH, cfg->wp_z_len);

	/* GDOS */
	if (gl_gdos && get_gdos_device())
	{
		set_string(printer, DDEVICE, gdos_name);
		set_state(printer, DDEVICE, DISABLED, FALSE);
		set_state(printer, DFONTSEL, DISABLED, FALSE);

		set_int(printer, DPTS, cfg->font_pts);
		get_fontname(cfg->font_id, tmp);
		set_string(printer, DFONT, tmp);
	}
	else
	{
		set_string(printer, DDEVICE, rsc_string(NODEVSTR));
		set_state(printer, DDEVICE, DISABLED, TRUE);
		set_state(printer, DFONTSEL, DISABLED, TRUE);
		set_string(printer, DFONT, "--");
		set_string(printer, DPTS, "--");
	}

	dial = open_mdial(printer, DPLENGTH);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case DFONTSEL:
					if (sel_font(cfg))
					{
						set_int(printer, DPTS, cfg->font_pts);
						get_fontname(cfg->font_id, tmp);
						set_string(printer, DFONT, tmp);
					}
					break;
		
				case DTREIBER :
					if (select_single(cfg->wp_treiber, "*.cfg", rsc_string(TREIBERSTR)))
					{
						wp_config_read = wp_load_cfgfile(cfg->wp_treiber);
						if (wp_config_read)
							wp_get_prnname(str, 25);
						else
							strcpy(str, rsc_string(NODEVSTR));
						set_string(printer, DTREIBNAME, str);
						redraw_mdobj(dial, DTREIBNAME);
						set_state(printer, DNLQ, DISABLED, !wp_config_read);
						redraw_mdobj(dial, DNLQ);
						set_state(printer, DDICHTE, DISABLED, !wp_config_read);
						redraw_mdobj(dial, DDICHTE);
						set_state(printer, DDICHTESTR, DISABLED, !wp_config_read);
						redraw_mdobj(dial, DDICHTESTR);
					}
					set_state(printer, antw, SELECTED, FALSE);
					break;
		
				case DDICHTESTR :
				case DDICHTE :
					if (antw == DDICHTE)
						i = handle_popup(printer, DDICHTE, popups, DICHTEPOP, POP_OPEN);
					else
						i = handle_popup(printer, DDICHTE, popups, DICHTEPOP, POP_CYCLE);
					if (i > 0)
						cfg->wp_mode = i - DICHTEPICA;
					break;
		
				default:
					close = TRUE;
					break;
			}
			set_state(printer, antw, SELECTED, FALSE);
			if (!close)
				redraw_mdobj(dial, antw);

		}
		close_mdial(dial);
		set_state(printer, antw, SELECTED, FALSE);
		if (antw == DOK2)
		{
			cfg->wp_s_len = get_int(printer, DPLENGTH);
			if (!cfg->wp_s_len)
				cfg->wp_s_len = 65;
	
			cfg->wp_z_len = get_int(printer, DPWIDTH);
			if (!cfg->wp_z_len)
				cfg->wp_z_len = 80;
	
			cfg->wp_nlq = get_state(printer, DNLQ, SELECTED);
			return TRUE;
		}
	}
	return FALSE;
}

static bool qed_start_dial(PRN_CFG *cfg)
{
	int	antw;
	bool	start = FALSE;
	
	if (!wp_config_read && prn->wp_treiber[0] != EOS)
		wp_config_read = wp_load_cfgfile(prn->wp_treiber);

	if (gl_gdos && (gdos_device == 0))
		get_gdos_device();

	/* Allgemeine Parameter */
	set_state(print, DZNUM, SELECTED, prn->num_zeilen);
	set_state(print, DSNUM, SELECTED, prn->num_seiten);
	set_state(print, DFEED, SELECTED, prn->vorschub);
	set_state(print, DCHECK, SELECTED, prn->pruef_prn);
	set_state(print, DALL, SELECTED, !prn->block);
	set_state(print, DBLOCK, DISABLED, !prn->block);
	set_state(print, DBLOCK, SELECTED, prn->block);
	set_int(print, DRANDLEN, prn->rand_len);

	set_state(print, DGEMDOS, SELECTED, !prn->use_gdos);
	set_state(print, DGDOS, SELECTED, prn->use_gdos);

	set_state(print, DGDOS, DISABLED, (gdos_device == 0));
	set_state(print, DGDOS, SELECTED, ((gdos_device != 0) && (prn->use_gdos || !wp_config_read)));

	set_state(print, DGEMDOS, DISABLED, !wp_config_read);
	set_state(print, DGEMDOS, SELECTED, (wp_config_read && !prn->use_gdos));

	set_state(print, DPRINT, DISABLED, (!wp_config_read && (gdos_device == 0)));
	
	antw = simple_mdial(print, DRANDLEN) & 0x7fff;
	if ((antw == DOK1) || (antw == DPRINT))
	{
		prn->block = get_state(print, DBLOCK, SELECTED);
		prn->use_gdos = get_state(print, DGDOS, SELECTED);
		prn->num_zeilen = get_state(print, DZNUM, SELECTED);
		prn->num_seiten = get_state(print, DSNUM, SELECTED);
		prn->vorschub = get_state(print, DFEED, SELECTED);
		prn->pruef_prn = get_state(print, DCHECK, SELECTED);
		prn->rand_len = get_int(print, DRANDLEN);

		start = (antw == DPRINT);
	}
	return start;
}

/* --------------------------------------------------------------------------- */
/*
 * Schnittstelle nach draužen
*/
void prn_cfg_dial(void)
{
	bool		ok;
	PRN_CFG	*new;
	
	prn->ausdruck = FALSE;					/* Art des Dialogs: Konfig */
	new = malloc(sizeof(PRN_CFG));
	memcpy(new, prn, sizeof(PRN_CFG));
	
	if (prn->use_pdlg)
		ok = pdlg_dial(new);
	else
		ok = qed_cfg_dial(new);
	if (ok)
	{
		memcpy(prn, new, sizeof(PRN_CFG));
	}
	free(new);
}

bool prn_start_dial(bool *block)
{
	bool	ok = FALSE;

	prn->ausdruck = TRUE;					/* Art des Dialogs: Ausdruck */
	if (block)
		prn->block = *block;
	else
		prn->block = FALSE;

	if (prn->use_pdlg)
	{
		PRN_CFG	*new;
		
		prn->use_gdos = TRUE;
		new = malloc(sizeof(PRN_CFG));
		memcpy(new, prn, sizeof(PRN_CFG));
		ok = pdlg_dial(new);
		if (ok)
			memcpy(prn, new, sizeof(PRN_CFG));
		free(new);
	}
	else
		ok = qed_start_dial(prn);

	if (block && ok)
		*block = prn->block;

	return ok;
}


void prn_save_cfg(char *buffer)
{
	/* pdlg-Settings */
	if (prn->pdlg != NULL)
	{
		char	*pdlg_file, *p;
		FILE	*fd;
				
		pdlg_file = strdup(buffer);
		p = strrchr(pdlg_file, '\\');
		if (p)
			strcpy(p+1, CFGNAME);
		else
			strcpy(pdlg_file, CFGNAME);
		fd = fopen(pdlg_file, "wb");
		if (fd)
		{
			fwrite(prn->pdlg, 1, sizeof(PRN_SETTINGS), fd);
			fclose(fd);
		}
		free(pdlg_file);
	}	
	/* sonstige Einstellungen */
	write_cfg_bool("PrnCheck", prn->pruef_prn);
	write_cfg_int("PrnDensity", prn->wp_mode);
	write_cfg_str("PrnDriver", prn->wp_treiber);
	write_cfg_int("PrnFontId", prn->font_id);
	write_cfg_int("PrnFontSize", prn->font_pts);
	write_cfg_bool("PrnFormfeed", prn->vorschub);
	write_cfg_bool("PrnGdos", prn->use_gdos);
	write_cfg_bool("PrnLineNumers", prn->num_zeilen);
	write_cfg_int("PrnMarginLen", prn->rand_len);
	write_cfg_bool("PrnNlq", prn->wp_nlq);
	write_cfg_int("PrnPageHeight", prn->wp_s_len);
	write_cfg_bool("PrnPageNumbers", prn->num_seiten);	
	write_cfg_int("PrnPageWidth", prn->wp_z_len);
	write_cfg_bool("PrnPdlg", prn->use_pdlg);
}

bool prn_get_cfg(char *var, char *buffer)
{
	bool	ret = TRUE;

	if (var[0] != 'P')
		ret = FALSE;

	else if (strcmp(var, "PrnCheck") == 0)
		read_cfg_bool(buffer, &prn->pruef_prn);
	else if(strcmp(var, "PrnDensity") == 0)
		prn->wp_mode = atoi(buffer);
	else if(strcmp(var, "PrnDriver") == 0)
		read_cfg_str(buffer, prn->wp_treiber);
	else if(strcmp(var, "PrnFontId") == 0)
		prn->font_id = atoi(buffer);
	else if(strcmp(var, "PrnFontSize") == 0)
		prn->font_pts = atoi(buffer);
	else if (strcmp(var, "PrnFormfeed") == 0)
		read_cfg_bool(buffer, &prn->vorschub);
	else if(strcmp(var, "PrnGdos") == 0)
		read_cfg_bool(buffer, &prn->use_gdos);
	else if (strcmp(var, "PrnLineNumers") == 0)
		read_cfg_bool(buffer, &prn->num_zeilen);
	else if (strcmp(var, "PrnMarginLen") == 0)
		prn->rand_len = atoi(buffer);
	else if(strcmp(var, "PrnNlq") == 0)
		read_cfg_bool(buffer, &prn->wp_nlq);
	else if(strcmp(var, "PrnPageHeight") == 0)
		prn->wp_s_len = atoi(buffer);
	else if (strcmp(var, "PrnPageNumbers") == 0)
		read_cfg_bool(buffer, &prn->num_seiten);
	else if(strcmp(var, "PrnPageWidth") == 0)
		prn->wp_z_len = atoi(buffer);
	else if(strcmp(var, "PrnPdlg") == 0)
		read_cfg_bool(buffer, &prn->use_pdlg);

	/* Spezial-Fall: 'pdlg.qed' laden: in <buffer> ist der Pfad 'drin */
	else if(strcmp(var, "PdlgRead") == 0)
	{
		char	*pdlg_file, *p;
		FILE	*fd;
				
		pdlg_file = strdup(buffer);
		p = strrchr(pdlg_file, '\\');
		strcpy(p+1, CFGNAME);
		fd = fopen(pdlg_file, "rb");
		if (fd)
		{
			fread(prn->pdlg, 1, sizeof(PRN_SETTINGS), fd);
			fclose(fd);
		}

		/* wenn kein WDIALOG da ist, auch nicht benutzen! */
		if (!prn->pdlg_avail && prn->use_pdlg)
			prn->use_pdlg = FALSE;

		free(pdlg_file);
	}

	else
		ret = FALSE;

	return ret;
}


void init_printer(void)
{
	prn = malloc(sizeof(PRN_CFG));
	if (prn)
	{
		int	d, i;

		memset(prn, 0, sizeof(PRN_CFG));
		prn->wp_s_len = 65;
		prn->wp_z_len = 80;
		prn->font_id = 1;
		prn->font_pts = 10;	

		/* Ist WDialog installiert? */	
		prn->pdlg_avail = (appl_xgetinfo(7, &i, &d, &d, &d) && ((i & 0x17) == 0x17));
		if (prn->pdlg_avail)
		{
			PRN_DIALOG	*pd;
	
			/* Settings anlegen und default'en */
			pd = pdlg_create(0);
			if (pd)
			{
				prn->pdlg = pdlg_new_settings(pd);
				pdlg_delete(pd);
			}
			else
				prn->pdlg_avail = FALSE;
		}

		if (!prn->pdlg_avail)
		{
			/* damit die CFG erhalten bleibt! */
			prn->pdlg = malloc(sizeof(PRN_SETTINGS));
			memset(prn->pdlg, 0, sizeof(PRN_SETTINGS));
		}
	}
}

void term_printer(void)
{
	if (prn)
	{
		if (prn->pdlg_avail)
			pdlg_free_settings(prn->pdlg);
		else
			free(prn->pdlg);
		free(prn);
		prn = NULL;
	}
}
