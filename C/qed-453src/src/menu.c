#include <errno.h>

#include "global.h"
#include "av.h"
#include "block.h"
#include "clipbrd.h"
#include "edit.h"
#include "error.h"
#include "file.h"
#include "find.h"
#include "icon.h"
#include "kurzel.h"
#include "makro.h"
#include "memory.h"
#include "menu.h"
#include "options.h"
#include "printer.h"
#include "projekt.h"
#include "rsc.h"
#include "se.h"
#include "set.h"
#include "text.h"
#include "umbruch.h"
#include "window.h"

/****** VARIABLES ************************************************************/

/* Menuenummer zu einer Aktion */
int menu_nr[] =	{MUNDO, MCUT, MCOPY, MPASTE, MSELALL, MCLOSE, -1, 
		  						 MINFO, -1, MLEFT, MRIGHT, MFORMAT, MPRINT, MABAND, 
		  						 MSAVE, MSAVENEW, -1, MFNDGOON, MADD, MGOTO, MSSTRIP,
		  						 MSTAB2LZ, -1, MSLZ2TAB, -1, MZEICHEN, MSWAP, MSMALL, 
		  						 MBIG, MSMALLBIG, MCAPS, MUMLAUTE, -1, MFEHLERSPRUNG, 
		  						 MDELETE, MSORT, MTOPLINE};

/*****************************************************************************/

static void	mclearup 	(void);

/*****************************************************************************/
static void info_dial(void)
{
	int	antw;

	antw = simple_mdial(about, 0) & 0x7fff;
	if (antw == AINFO)
		simple_mdial(about2, 0);
}

/*****************************************************************************/
void	set_overwrite(bool over)
{
	if (overwrite && !over) 	/* einfgen */
	{
		overwrite = FALSE;
		menu_icheck(menu, MOOVERW, FALSE);
		menu_icheck(menu, MOEINF, TRUE);
	}
	else				/* berschreiben */
	{
		overwrite = TRUE;
		menu_icheck(menu, MOOVERW, TRUE);
		menu_icheck(menu, MOEINF, FALSE);
	}
}

/***************************************************************************/
bool prepare_quit(void)
{
	int	anz, i;
	int	ic, icp[MAX_ICON_ANZ];
	SET	actions;

	if (makro_rec)
		return FALSE;

	/* Erst alle testen, dann alle killen */
	anz = all_icons(icp);
	i = anz;
	while ((--i)>=0)
	{
		ic = icp[i];
		if (ic!=0)
		{
			icon_exist(ic, actions);
			if (setin(actions, DO_DELETE))
				if (!icon_test(ic, DO_DELETE))
					return FALSE;
		}
	}
	if ((!save_opt) != (!shift_pressed()))
		option_save();
	i = anz;
	while ((--i)>=0)
	{
		ic = icp[i];
		if (ic!=0)
		{
			icon_exist(ic, actions);
			if (setin(actions, DO_DELETE))
				icon_edit(ic, DO_DELETE);
		}
	}
	return TRUE;
}

void do_quit(void)
{
	kill_memory();
	done = TRUE;
}

/*****************************************************************************/
void set_menu(int item, bool yes)
{
	if (((menu[item].ob_state & DISABLED) == 0) != yes)
		menu_ienable(menu, item, yes);
}

void mark_menu(int item, bool yes)
{
	if (((menu[item].ob_state & CHECKED) != 0) != yes)
		menu_icheck(menu, item, yes);
}

void fillup_menu(int item, char *new_text, int free)
{
	int	len, max_len;
	char *str;

	str = menu[item].ob_spec.free_string + free;
	len = (int) strlen(new_text);
	max_len = (int) strlen(str) - 4;		/* ' ?? ' Shortcut nicht berscrieben! */
	if (len > max_len)
		len = max_len;
	memcpy(str, new_text, len);
	str += len; 
	len = max_len - len; 					/* Restl„nge */
	while ((--len) >= 0)
		*str++ = ' ';
}

static void set_MCOPY(char *n)
{
	fillup_menu(MCOPY, n, 2);
	set_menu(MCOPY, TRUE);
}


void update_menu (void)
{
	WINDOWP	window;
	SET		all_actions;
	int		i, nr;

	setclr(all_actions);
	window = winlist_top();

	if (sel_window != NULL) /* Aktion fr selektierte Objekte */
	{
		icon_exist(sel_window->handle + SUB_ICON, all_actions);
		mark_menu(MSEL, FALSE);
		set_menu(MSEL, FALSE);
		set_menu(MSETMARK, FALSE);
	}
	else							/* Aktionen fr oberstes Fenster */
	{
		if (window != NULL)
			icon_exist(window->handle, all_actions);

		if (window != NULL && window->class == CLASS_EDIT && 
			 !(window->flags & WI_ICONIFIED) && !(window->flags & WI_SHADED))
		{
			TEXTP t_ptr = get_text(window->handle);

			mark_menu(MSEL, (!ctrl_mark_mode && t_ptr->blk_mark_mode));
			set_menu(MSEL, !ctrl_mark_mode);
			set_menu(MSETMARK,TRUE);
		}
		else
		{
			mark_menu(MSEL,FALSE);
			set_menu(MSEL,FALSE);
			set_menu(MSETMARK,FALSE);
		}
	}

	i = num_openwin(CLASS_ALL);
	set_menu(MCYCLE, ((i >= 2) || wind_cycle));

	i = num_openwin(CLASS_EDIT);
	set_menu(MHINTER, (i >= 2));
	set_menu(MNEBEN, (i >= 2));
	set_menu(MUNTER, (i >= 2));

	mark_menu(MSRECORD, makro_rec);

	for (i = DO_ANZ; (--i) >= 0; )
	{
		nr = menu_nr[i];
		if (nr > -1)
			set_menu(nr, setin(all_actions,i));
	}
	if (setin(all_actions, DO_LINECOPY))
		set_MCOPY(rsc_string(LCOPYSTR));
	else if (setin(all_actions, DO_COPY))
		set_MCOPY(rsc_string(COPYSTR));

	setup_semenu();				/* -> se.c */
}


/***************************************************************************/
static void multitest_action(SET icons, SET action)
{
	int	icp[MAX_ICON_ANZ], ic;
	SET	help;
	int	i;

	i = all_icons(icp);
	setclr(action);
	while ((--i)>=0)
	{
		ic = icp[i];
		if(setin(icons,ic))
		{
			icon_exist(ic,help);
			setor(action,help);
		}
	}
}

/*****************************************************************************/
static void do_multi_action(int action)
{
	int	icp[MAX_ICON_ANZ], ic;
	SET	sel_icons;
	int	i, anz;

	anz = all_icons(icp);
	setcpy(sel_icons, sel_objs);
	for (i=0; i<anz; i++)				/* In dieser Reihenfolge! */
	{
		ic = icp[i];
		if (setin (sel_icons, ic))
		{
			if (do_icon(ic,action)<0 && action==DO_OPEN)
			{
				note(1, 0, NOWINDOW);
				break;
			}
		}
	}
}

void do_action(int action)
{
	if (sel_window != NULL)			/* Namen in Projekt selektiert */
	{
		if (do_icon(sel_window->handle+SUB_ICON, action) < 0 && action == DO_OPEN)
			note(1, 0, NOWINDOW);
	}
	else
	{
		WINDOWP w = winlist_top();

		if (w != NULL)
			do_icon(w->handle,action);
		else
			call_hyp("main");
	}
}


void menu_help(int title, int item)
{
	char	help[128], str[128];
	int	i;
	
	/* Spezial-F„lle: besonderer Text */
	if (item >= MMARKE1 && item <= MMARKE5)
		strcpy(str, rsc_string(HYPMARKESTR));
	else if (item == MPROJEKT)
		strcpy(str, rsc_string(DEFPRJSTR));
	else if (title == TSHELL)
		strcpy(str, "Shell");
	else if (item >= MHINTER && item <= MUNTER)
		strcpy(str, rsc_string(HYPANORDSTR));
	else
	{
		/* Spezial-Fall: Item ummappen */
		if (item == MOEINF)
			item = MOOVERW;

		get_string(menu, item, help);
		
		/* die fhrenden ' ' berspringen */
		i = 0;
		while (help[i] == ' ')
			i++;
		strcpy(str, help+i);

		/* Eintrag endet bei zwei ' ' oder zwei '.' */
		i = 0;
		while (((str[i] != ' ') || (str[i+1] != ' ')) &&
				 ((str[i] != '.') || (str[i+1] != '.')) &&
				 str[i] != EOS)
			i++;
		str[i] = EOS;
	}
	if (str[0] != EOS)
		call_hyp(str);
}


static bool menu_key(int kstate, int kreturn)
{
	int	title, item;
	
	update_menu();

	/* Shift ausblenden wegen global_shift! */
	kstate &= ~(K_LSHIFT|K_RSHIFT);

	if (is_menu_key(kreturn, kstate, &title, &item))
	{
		handle_menu(title, item, FALSE);
		return TRUE;
	}
	return FALSE;
}


/*
 * Globale Tasten auswerten, die bergeordnete Funktionen ausl”sen.
*/
bool	key_global(int kstate, int kreturn)
{
	int	scan;
	
	scan = kreturn >> 8;
	
	wake_mouse();

	if (scan == 0x62)			/* HELP */
	{
		do_action(DO_HELP);
		return TRUE;
	}

	else if (scan == 0x52)	/* INS: Overwrite toggln, da doppelter Men-Shortcut */
	{
		set_overwrite(!overwrite);
		return TRUE;
	}
									/* Alt+Funktionstasten => Programmende mit Returncode */
	else if ((kstate & K_ALT) && (scan >= 0x3B && scan <= 0x44))
	{
		return_code = (scan - 0x3B) + 1;
		quick_close = TRUE;
		if (prepare_quit())
			do_quit();
		else
			return_code = 0;
		return TRUE;
	}
	
	/* F1-F20: Makro */
	else if ((scan >= 0x3B && scan <= 0x44) || (scan >= 0x54 && scan <= 0x5D))
	{
		/* Makro abspielen */
		if (!start_play(kreturn, 1) && f_to_desk)
			send_avkey(kstate, kreturn);
		return TRUE;
	}
	return (menu_key(kstate, kreturn));
}


void handle_menu(int title, int item, bool ctrl)
{
	WINDOWP	w;
	int		action, antw, anz;
	char 		str[10];

	if (ctrl)
		menu_help(title, item);
	else
	{
		w = winlist_top();
		action = -1;
		switch (item)
		{
			case MABOUT :
				info_dial();
				break;

/* Datei */
			case MNEWTEXT	:
				new_edit();
				break;

			case MOPEN	 :
				if (sel_window == NULL)
					select_multi(FALSE);
				else
					action = DO_OPEN;
				break;

			case MADD	:
				action = DO_ADD;
				break;

			case MNEWPROJ :
				new_projekt();
				break;

			case MOPENBIN :
				if (sel_window == NULL)
					select_multi(TRUE);
				else
					debug("\aBinOpen aus Projekt geht noch nicht!\n");
				break;

			case MDELETE :
				action = DO_DELETE;
				break;

			case MSAVE:
				action = DO_SAVE;
				break;

			case MSAVENEW:
				action = DO_SAVENEW;
				break;

			case MABAND :
				action = DO_ABAND;
				break;

			case MPRINT :
				action = DO_PRINT;
				break;

			case MINFO	 :
				if (w == NULL)
					info_dial();
				else
					action = DO_INFO;
				break;

			case MQUIT2 :
				quick_close = TRUE;
				/* kein break! */
			case MQUIT :
				if (prepare_quit())
				{
					menu_tnormal(menu, title, TRUE);
					do_quit();
				}
				break;

/* Bearbeiten */
			case MUNDO	 :
				action = DO_UNDO;
				break;

			case MCUT	 :
				action = DO_CUT;
				break;

			case MCOPY	 :
				if (w!=NULL && w->class==CLASS_EDIT)
				{
					TEXTP t_ptr = get_text(w->handle);
					if (t_ptr->block)
						action = DO_COPY;
					else
						action = DO_LINECOPY;
				}
				break;

			case MPASTE :
				action = DO_PASTE;
				break;

			case MSEL	 :
				if (w!=NULL && w->class==CLASS_EDIT)
				{
					TEXTP t_ptr = get_text(w->handle);
					if (t_ptr->blk_mark_mode)
						t_ptr->blk_mark_mode = FALSE;
					else
					{
						blk_demark(t_ptr);
						restore_edit();
						blk_mark(t_ptr,0);
						t_ptr->blk_mark_mode = TRUE;
					}
				}
				break;

			case MSELALL :
				action = DO_SELALL;
				break;

			case MFORMAT :
				action = DO_FORMAT;
				break;

			case MSWAP:
				action = DO_SWAPCHAR;
				break;

			case MLEFT	 :
				action = DO_LEFT;
				break;

			case MRIGHT :
				action = DO_RIGHT;
				break;

			case MSORT :
				action = DO_SORT;
				break;

			case MSMALLBIG :
				action = DO_CHNG_SMBG;
				break;

			case MBIG:
				action = DO_SMALL2BIG;
				break;

			case MSMALL :
				action = DO_BIG2SMALL;
				break;

			case MCAPS:
				action = DO_CAPS;
				break;

/* Fenster */
			case MCYCLE :
				if ((wind_cycle) && (send_avkey(4, 0x1117)))	/* ^W */
					break;
				cycle_window();
				break;

			case MCLOSE :
				action = DO_CLOSE;
				break;

			case MTOPLINE :
				action = DO_TOPLINE;
				break;

			case MHINTER :
			case MNEBEN :
			case MUNTER :
				arrange_window(item);
				break;

/* Suchen */
			case MFIND	 :
				action = DO_FIND;
				break;

			case MFNDGOON:
				action = DO_FINDNEXT;
				break;

			case MFNDFILE :
				find_on_disk();
				break;

			case MGOTO	 :
				action = DO_GOTO;
				break;

			case MSETMARK:
				if (w!=NULL)
					config_marken(get_text(w->handle));
				break;

			case MMARKE1 :
			case MMARKE2 :
			case MMARKE3 :
			case MMARKE4 :
			case MMARKE5 :
				goto_marke(item-MMARKE1);
				break;

/* Spezial */
			case MSRECORD:
				if (makro_rec)
					end_rec(TRUE);
				else
					start_rec();
				break;

			case MSPLAY :
				if (shift_pressed())
				{
					set_string(makrorep, MREPANZ, "");
					antw = simple_mdial(makrorep, MREPANZ);
					if (antw == MREPOK)
					{
						get_string(makrorep, MREPANZ, str);
						anz = atoi(str);
					}
					else
						break;
				}
				else
					anz = 1;
				start_play(-1, anz);
				break;

			case MSMAKRO :
				makro_dial();
				break;

			case MZEICHEN:
				action = DO_ZEICHTAB;
				break;

			case MUMLAUTE:
				action = DO_UMLAUT;
				break;

			case MFEHLER:
				fehler_box();
				break;

			case MFEHLERSPRUNG:
				action = DO_FEHLER;
				break;

			case MSSTRIP :
				action = DO_STRIPLINES;
				break;

			case MSTAB2LZ:
				action = DO_TAB2LZ;
				break;

			case MSLZ2TAB:
				action = DO_LZ2TAB;
				break;

/* Optionen */
			case MOEINF:
				set_overwrite(FALSE);
				break;

			case MOOVERW:
				set_overwrite(TRUE);
				break;

			case MOFONT :
				select_font();
				break;

			case MGLOBALO:
				set_global_options();
				break;

			case MLOCALOP:
				set_local_options();
				break;

			case MAUTOSAVE :
				set_autosave_options();
				break;

			case MKLAMMER :
				set_klammer_options();
				break;

			case MPRINTER :
				prn_cfg_dial();
				break;

			case MPROJEKT :
				open_def_prj();
				break;

			case MTAKEPRJ :
				add_to_def();
				break;

			case MSOPTION:
				option_save();
 				break;

/* Shell */
			case MSOPT :
			case MSQUIT :
			case MSMAKEFILE :
			case MSSHELL :
			case MSCOMP :
			case MSMAKE :
			case MSMAKEALL :
			case MSLINK :
			case MSEXEC :
			case MSMAKEEXEC :
				handle_es(item);

			default:
				break;
		}
		if (action!=-1)
			do_action(action);
	} 
	menu_tnormal(menu, title, TRUE);
}
