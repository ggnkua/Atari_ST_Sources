#include <dirent.h>
#include <keycodes.h>
#include <support.h>
#include <stat.h>
#include <time.h>

#include "global.h"
#include "aktion.h"
#include "av.h"
#include "ausgabe.h"
#include "clipbrd.h"
#include "comm.h"
#include "dd.h"
#include "edit.h"
#include "event.h"
#include "kurzel.h"
#include "file.h"
#include "find.h"
#include "icon.h"
#include "memory.h"
#include "menu.h"
#include "options.h"
#include "printer.h"
#include "rsc.h"
#include "set.h"
#include "text.h"
#include "window.h"
#include "projekt.h"


/* exprortierte Variablen **************************************************/
int		prj_type;
PATH		def_prj_path;

/****** DEFINES ************************************************************/

#define KIND	(NAME|CLOSER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|SMALLER)
#define FLAGS	(WI_FONTSIZE|WI_REDRAW)

#define TEMP_LINK 101

/****** TYPES **************************************************************/

typedef struct			/* fÅr Dreaddir */
{
	long		inode;
	FILENAME name;
} DIRENTRY;

/****** VAR ****************************************************************/
static int	do_find_icon;
static PATH	df_path;
static int	def_icon;						/* Icon fÅr Defaultprojekt */

/****** FUNCTIONS **********************************************************/

static void	p_icon_exist		(int icon, SET actions);
static bool	p_icon_test			(int icon, int action);
static int	p_icon_edit			(int icon, int action);
static bool	p_icon_drag			(int icon, int source);
static void	draw_line			(WINDOWP window, int line);
static void	wi_draw				(WINDOWP window, GRECT *d);
static void	wi_click 			(WINDOWP window, int m_x, int m_y, int bstate, int kstate, int breturn);
static void	wi_unclick			(WINDOWP window);
static bool	wi_key				(WINDOWP window, int kstate, int kreturn);
static void	wi_snap				(WINDOWP window, GRECT *new, int mode);
static void	wi_iconify			(WINDOWP window);
static void	wi_uniconify		(WINDOWP window);
static bool	find_files			(char *pfad, bool rekursiv, char *df_muster, int icon, int tmp_icon);
static void	get_prj_line		(int link, int line, char *str);
static int	del_from_projekt	(int link, int line);
static bool	open_prj 			(int icon);
static void	destruct 			(int icon);
static void	crt_prj				(WINDOWP window);
static int	crt_new_prj			(char *filename);
static void	info_projekt		(int icon);
static void	select_def_prj 	(void);

/*****************************************************************************/

/*
 * do_for_prj()
 *	bei DO_OPEN, DO_DELETE und Info-Scan -> Aktion auf Projekt selbst
*/
static void do_for_prj(int icon, SET s, int (*do_it)(int,int), bool verbose)
{
	TEXTP 	t_ptr, t_ptr2;
	ZEILEP 	lauf;
	int		min, i, anz, soll, erg;
	PATH		name, prj;
	FILENAME file;
	char		*p;
	
	t_ptr = get_text(icon);
	if (t_ptr->namenlos)
		strcpy(prj, t_ptr->filename);
	else
		file_name(t_ptr->filename, prj, FALSE);
	strcat(prj, ": ");
	p = strrchr(prj, ' ') + 1;						/* p zeigt auf das Ende */
	
	if (verbose)
	{
		t_ptr2 = get_text(icon);
		if (t_ptr2->namenlos)
			strcpy(file, t_ptr2->filename);
		else
			file_name(t_ptr2->filename,file, FALSE);
		strcpy(p, file);
		start_aktion(prj, TRUE, setcard(s));
	}

	min = setmin(s);
	/* So wg. DO_DELETE */
	for (i=setmax(s); i>=min; i--)
	{
		if (setin(s,i))
		{
			lauf = get_line(&t_ptr->text,i);
			lauf->info |= MARKED;
		}
	}
	soll = setcard(s);
	anz = i = 0;
	while (TRUE)
	{
		lauf = get_line(&t_ptr->text,i);
		if (lauf == NULL) 
			break;
		if (IS_MARKED(lauf))
		{
			anz++;
			lauf->info &= (~MARKED);				/* sonst Endlosschleife */
			if (verbose)
			{
				get_prj_line(icon,i,name);
				if (name[0] == EOS) 
					break;
				file_name(name,file, FALSE);
				strcpy(p, file);
				if (!do_aktion(prj, anz))
				{
					if (anz < soll && note(1, 2, BREAK) == 1) 
						break;
					else
						redraw_aktion();
				}
			}
			erg = (*do_it)(icon,i);
			if (erg < 0) 
				break;
		}
		else
			i++;
	}
	lauf = FIRST(&t_ptr->text);
	while (!IS_TAIL(lauf))
	{
		lauf->info &= (~MARKED);
		NEXT(lauf);
	}
	if (verbose) 
		end_aktion();
}

/*
 * bei Sub-Info und Find -> Aktion auf Element(e) des Projekts
*/
static bool do_find(int icon);

static void do_for_prj2(int icon, SET s, int aktion, bool verbose)
{
	int		i, t_icon, anz, soll, antw;
	TEXTP 	t_ptr, t_ptr2;
	PATH		name, prj;
	FILENAME file;
	char		*p;
	
	t_ptr = new_text(TEMP_LINK);					/* Temp-Text zum Laden der Elemente */
	if (t_ptr == NULL) 
		return;

	if (verbose)
	{
		t_ptr2 = get_text(icon);					/* Name des Projekts ermitteln */
		if (t_ptr2->namenlos)
			strcpy(file, t_ptr2->filename);
		else
			file_name(t_ptr2->filename,file, FALSE);
		
		strcpy(prj, file);
		strcat(prj, ": ");
		p = strrchr(prj, ' ') + 1;					/* p zeigt auf das Ende */
		strcpy(p, file);
		start_aktion(prj, TRUE, setcard(s));
	}

	soll = setcard(s);
	for (i=setmin(s),anz=0; anz<soll; i++)
	{
		if (setin(s,i))
		{
			anz++;
			get_prj_line(icon,i,name);
			if (name[0] == EOS) 
				break;
			file_name(name, file, FALSE);

			t_icon = text_still_loaded(name);
			if (t_icon < 0)
			{
				set_text_name(t_ptr, name, FALSE);
				antw = load(t_ptr, FALSE);
				if (antw != 0)
					open_error(name, antw);
				t_icon = TEMP_LINK;			
			}
/*
			do_it(t_icon);
*/
			switch (aktion)
			{
				case DO_INFO :
					info_edit(t_icon);
					break;
				
				case DO_FIND :
					t_ptr2 = get_text(t_icon);
					if ((ff_mask[0] == EOS) || filematch(t_ptr2->filename, ff_mask, t_ptr2->filesys))
						do_find(t_icon);
					else
						file[0] = EOS;			/* nicht in Aktion-Box eintragen! */
					break;

				default:
					debug("do_for_prj2(): unbekannte Aktion %d\n", aktion);
					break;
			}			

			if (t_icon == TEMP_LINK) 
				clear_text(t_ptr);

			if (verbose)
			{
				if (file[0] != EOS)
					strcpy(p, file);
				if (!do_aktion(prj, anz))
				{
					if (anz < soll && note(1, 2, BREAK) == 1) 
						break;
					else
						redraw_aktion();
				}
			}
		}
	}
	destruct_text(t_ptr);
	if (verbose)
		end_aktion();
}

static bool delete_prj(int icon)
{
	TEXTP 	t_ptr = get_text(icon);
	int		antw;
	FILENAME name;

	if (t_ptr->moved!=0)
	{
		if (quick_close)
			antw = 1;
		else
		{
			if (t_ptr->namenlos)
				strcpy(name, t_ptr->filename);
			else
				file_name(t_ptr->filename, name, FALSE);
			antw = snote(1, 3, MOVED, name);
		}
		if (antw == 1)
		{
			if (do_icon(icon,DO_SAVE)<0)
				return (FALSE);
		}
		if (antw == 3) 
			return(FALSE);
	}
	return (TRUE);
}

static void chg_prj_name(int icon)
{
	WINDOWP 		window;
	FILENAME 	name;
	TEXTP 		t_ptr = get_text(icon);

	file_name(t_ptr->filename, name, TRUE);
	window = get_window (icon);
	set_wtitle(window, name);
}

/***************************************************************************/
/* Operation vorhanden ?																	*/
/***************************************************************************/

static void p_icon_exist(int icon, SET actions)
{
	setclr(actions);
	if (icon & SUB_ICON)
	{
		setincl(actions,DO_OPEN);
		setincl(actions,DO_DELETE);
		setincl(actions,DO_INFO);
		setincl(actions,DO_HELP);
	}
	else
	{
		WINDOWP window = get_window(icon);
		TEXTP t_ptr = get_text(icon);

		if ((window->flags & WI_ICONIFIED) || (window->flags & WI_SHADED))
		{
			setincl(actions, DO_DELETE);
		}
		else
		{
			if (window->flags & WI_OPEN)
				setincl(actions, DO_CLOSE);
			setincl(actions, DO_DELETE);
			setincl(actions, DO_SELALL);
			setincl(actions, DO_OPEN);
			setincl(actions, DO_INFO);
			setincl(actions, DO_FIND);
			if (!t_ptr->namenlos)
				setincl(actions, DO_ABAND);
			setincl(actions, DO_SAVE);
			setincl(actions, DO_SAVENEW);
			setincl(actions, DO_UPDATE);
			setincl(actions, DO_PRINT);
			setincl(actions, DO_HELP);
			setincl(actions, DO_ADD);
			if (t_ptr->moved)
				setincl(actions, DO_AUTOSAVE);
		}
	}
}

/***************************************************************************/
/* Operation testen																			*/
/***************************************************************************/

static bool p_icon_test(int icon, int action)
{
	bool	erg;

	if (icon & SUB_ICON)		/* Aktion auf selektierten Eintrag */
	{
		switch(action)
		{
			case DO_OPEN:	
				erg = TRUE; 
				break;
			case DO_DELETE:	
				erg = TRUE; 
				break;
			case DO_INFO:	
				erg = TRUE; 
				break;
			case DO_HELP:	
				erg = TRUE; 
				break;
			default:	
				erg = FALSE;
		}
	}
	else							/* Aktion auf Projekt selbst */
	{
		FILENAME name;
		TEXTP 	t_ptr = get_text(icon);

		switch(action)
		{
			case DO_SELALL:
				erg = TRUE; 
				break;
			case DO_CLOSE:
			case DO_DELETE:	
				erg = delete_prj(icon); 
				break;
			case DO_OPEN:
				erg = TRUE; 
				break;
			case DO_INFO:
				erg = TRUE; 
				break;
			case DO_FIND:
				erg = findfile_dial(t_ptr->filename, TRUE); 
				break;
			case DO_ABAND:
				if (t_ptr->namenlos)
					erg = FALSE;
				else
				{
					erg = TRUE;
					if (!ist_leer(&t_ptr->text) && t_ptr->moved!=0)
					{
						file_name(t_ptr->filename, name, FALSE);
						erg = (snote(1, 2, ABANDON, name) == 1);
					}
				}
				break;
			case DO_SAVE:
				erg = TRUE; 
				break;
			case DO_SAVENEW:
				erg = TRUE; 
				break;
			case DO_UPDATE :
				erg = TRUE; 
				break;
			case DO_PRINT	:
				erg = TRUE; 
				break;
			case DO_HELP	:
				erg = TRUE; 
				break;
			case DO_ADD 	:
				erg = findfile_dial(df_path, FALSE);
				break;
			case DO_AUTOSAVE :
				if (as_prj && t_ptr->moved)
				{
					int	btn;
					long	min;

					min = (int)((time(NULL) - t_ptr->asave) / 60L);
					if (min >= as_prj_min)
					{
						if (as_prj_ask)				/* Nachfrage ? */
						{
							FILENAME 	name;

							if (t_ptr->namenlos)
								strcpy(name, t_ptr->filename);
							else
								file_name(t_ptr->filename, name, FALSE);
							Bconout(2, 7);
							btn = snote(2, 3, ASAVEASK, name);
							if (btn == 1)
								as_prj = FALSE;
						}
						else
							btn = 2;

						t_ptr->asave = time(NULL);
						erg = (btn == 2);
					}
					else
						erg = FALSE;
				}
				else
				{
					t_ptr->asave = time(NULL);
					erg = FALSE;
				}
				break;
			default:
				erg = FALSE;
		}
	}
	return erg;
}

/***************************************************************************/
/* Operation durchfÅhren																	*/
/***************************************************************************/

static int do_open(int prj_icon, int i)
{
	PATH	name;
	int	icon;
	bool	prj;

	get_prj_line(prj_icon, i, name);
	prj = filematch(name, "*.QPJ", -1);
	if (prj)
	{
		if (shift_pressed())
			return load_edit(name, FALSE);			/* Laden als Text und îffnen */
		else
			return load_projekt(name);					/* Laden als Projekt und îffnen */
	}
	else
	{
		icon = load_edit(name, FALSE);				/* Laden als Text und îffnen */
		return icon;
	}
}

static bool do_find(int icon)
{
	int	erg = 0;
	TEXTP t_ptr = get_text(icon);

	erg = start_find(t_ptr,TRUE);
	if (erg == 1)
		add_to_projekt(do_find_icon, t_ptr->filename, TRUE);
	return (erg != -1);
}

static int p_icon_edit(int icon, int action)
{
	PATH	name;
	int	erg;

	erg = 0;
	if (icon & SUB_ICON)
	{
		WINDOWP 	window;
		SET		help;

		icon &= (~SUB_ICON);
		window = get_window(icon);
		if (sel_window==window)
			setcpy(help,sel_objs);
		else
			setclr(help);
		switch (action)
		{
			case DO_OPEN	:
				do_for_prj(icon,help,do_open,FALSE);
				break;
			case DO_DELETE	:
				do_for_prj(icon,help,del_from_projekt,FALSE);
				break;
			case DO_INFO	:
				do_for_prj2(icon, help, DO_INFO, FALSE);
				break;
			case DO_HELP	:
				erg = call_hyp(rsc_string(HYPPRJSTR));
				break;
		}
		erg = 1;
	}
	else
	{
		TEXTP 	t_ptr = get_text(icon);
		WINDOWP 	window = get_window(icon);
		int		i;
		SET		help;
		FILENAME file;
		PATH		h;

		switch(action)
		{
			case DO_CLOSE	:
			case DO_DELETE	:
				if (icon == def_icon)
				{
					def_icon = -1;
					set_def_prj();
				}
				destruct(icon);
				erg = 1;
				break;
			case DO_SELALL :
				if (window != sel_window)
					unclick_window();
				if (!ist_leer(&t_ptr->text))
				{
					sel_window = window;
					for (i = (int) t_ptr->text.lines; (--i)>=0; )
						setincl(sel_objs,i);
					redraw_window(window,&window->work);
				}
				erg = 1;
				break;
			case DO_OPEN	:
				if (!open_prj (icon))
					erg = -1;
				else
					erg = 1;
				break;
			case DO_INFO	:
				info_projekt(icon);
				erg = 1;
				break;
			case DO_FIND	:
				setclr(help);
				for (i = (int) t_ptr->text.lines; (--i)>=0; )
					setincl(help,i);
				do_find_icon = crt_new_prj("");
				if (do_find_icon < 0)
					break;
				if (do_icon(do_find_icon, DO_OPEN) < 0)
				{
					note(1, 0, NOWINDOW);
					icon_edit(icon, DO_DELETE);
					break;
				}
				do_for_prj2(icon, help, DO_FIND, TRUE);
				t_ptr = get_text(do_find_icon);
				if (t_ptr->moved)									/* etwas gefunden? */
				{
					t_ptr->moved = 0;
					window = get_window(do_find_icon);
					if (t_ptr->namenlos)
						strcpy(h, t_ptr->filename);
					else
						file_name(t_ptr->filename, h, TRUE);
					change_window(window, h, FALSE);
					set_sliders(window, VERTICAL, SLPOS+SLSIZE);
					redraw_window(window,&window->work);
				}
				else
					icon_edit(do_find_icon, DO_DELETE);	/* wenn nicht, gleich wieder zu */
				erg = 1;
				break;
			case DO_ABAND	:
				strcpy(name, t_ptr->filename);
				desire_y = window->doc.y+1;
				close_window(window);
				destruct_text(t_ptr);
				del_icon(icon);
				icon = load_projekt(name);
				if (icon > 0)
				{
					t_ptr = get_text(icon);
					if (t_ptr!=NULL)
					{
						i = (int) (desire_y - window->doc.y);
						arrow_window(window,WA_DNLINE,i);
						restore_edit();
						open_prj(icon);

						memset(msgbuff, 0, (int) sizeof(msgbuff));
						msgbuff[0] = WM_TOPPED;
						msgbuff[3] = window->handle;
						send_msg(gl_apid);
		
						erg = 1;
					}
				}
				break;
			case DO_SAVE	:
				if (!t_ptr->namenlos)
				{
					if (save(t_ptr) < 0)
						erg = -1;
					else
					{
						file_name(t_ptr->filename, h, TRUE);
						change_window(window, h, FALSE);
						erg = 1;
					}
					break;
				}
				/* Bei Namenlos zu DO_SAVENEW */
			case DO_SAVENEW:
				if (!t_ptr->namenlos)
					strcpy(name, t_ptr->filename);
				else
					strcpy(name, "");
				if (save_new(name, "*.qpj", rsc_string(SAVEPRJSTR)))
				{
					set_extension(name,"qpj");
					if ((erg=save_as(t_ptr,name))==0)
					{
						if (t_ptr->namenlos || note(1, 2, GETNAME) == 1)
						{
							set_text_name(t_ptr, name, FALSE);
							chg_prj_name(icon);
							t_ptr->moved = 0;
							t_ptr->file_date_time = file_time(name,NULL,NULL);
							t_ptr->readonly = file_readonly(name);
						}
						file_name(t_ptr->filename, h, TRUE);
						change_window(window, h, FALSE);
						erg = 1;
					}
				}
				break;
			case DO_UPDATE :
				redraw_window(window, &window->work);
				erg = 1;
				break;
			case DO_PRINT	:
				if (t_ptr->namenlos)
					strcpy(file, t_ptr->filename);
				else
					file_name(t_ptr->filename, file, FALSE);
				if (prn_start_dial(NULL))
					txt_drucken(file,t_ptr);
				erg = 1;
				break;
			case DO_HELP	:
				erg = call_hyp(rsc_string(HYPPRJSTR));
				break;
			case DO_ADD :
				if (df_path[0]!=EOS)			 /* Pfad durchsuchen */
				{
					graf_mouse(HOURGLASS, NULL);
					strcpy(h, df_path);
/*
					if (fs_case_sens(df_path) == NO_CASE)
						str_toupper(ff_mask);
*/
					find_files(h, ff_rekursiv, ff_mask, icon, TEMP_LINK);
					graf_mouse(ARROW, NULL);
					redraw_window(window, &window->work);
				}
				break;
			case DO_AUTOSAVE:
				p_icon_edit(icon, DO_SAVE);
				break;
		}
	}
	return erg;
}

/***************************************************************************/
/* Ein Icon wurde auf ein Projekt-Icon geschoben									*/
/***************************************************************************/

static bool p_icon_drag(int icon, int source)
{
	WINDOWP 	window = get_window(icon);
	bool	erg = FALSE;
	PATH		h;

 	if ((window->flags & WI_ICONIFIED) || (window->flags & WI_SHADED))
 		return FALSE;

	switch (source)
	{
		case DRAGDROP_FILE :
			if (drag_filename[0] != EOS)
			{
				erg = add_to_projekt(icon, drag_filename, TRUE);
				drag_filename[0] = EOS;
			}
			break;
		case DRAGDROP_PATH :
			if (drag_filename[0] != EOS)
			{
				strcpy(df_path, drag_filename);
				erg = findfile_dial(df_path, FALSE);
				if (erg)
				{
					graf_mouse(HOURGLASS, NULL);
					strcpy(h, df_path);
/*
					if (fs_case_sens(df_path) == NO_CASE)
						str_toupper(ff_mask);
*/
					find_files(h, ff_rekursiv, ff_mask, icon, TEMP_LINK);
					graf_mouse(ARROW, NULL);
					redraw_window(window, &window->work);
				}
				drag_filename[0] = EOS;
			}
			break;
		case DRAGDROP_DATA :
			Bconout(2, 7);
			erg = FALSE;
			break;
		default:
			if (debug_level)
				debug("projekt.p_icon_drag(): Unbekannter Mode %d\n", source);
	}
	return erg;
}
/***************************************************************************/

/*
 * Dateien fÅr Projekt suchen.
 */
static bool find_files(char *pfad, bool rekursiv, char *df_muster, int icon, int tmp_icon)
{
	TEXTP t_ptr;
	char 	*ptr;
	bool	raus;
	int	t_icon;
	PATH	suchPfad;
	DIR	*dh;

	if (s_str[0] != EOS)
	{
		t_ptr = new_text(tmp_icon);
		if (t_ptr == NULL) 
			return FALSE;
	}
	strcpy(suchPfad, pfad);
	ptr = pfad + strlen(pfad);
	dh = opendir(suchPfad);
	if (dh != NULL)
	{
		struct dirent	*entry;
		struct stat		st;

		do_find_icon = icon;
		if (dh < 0)
			return FALSE;
		raus = FALSE;
		entry = readdir(dh);
		while (entry != NULL && !raus)
		{
			strcpy(ptr, entry->d_name);
			if (stat(pfad, &st) == 0)
			{
				if ((rekursiv) && (st.st_mode & S_IFDIR) && strcmp(entry->d_name, ".") && strcmp(entry->d_name, ".."))
				{
					strcat(ptr, "\\");
					raus = find_files(pfad, rekursiv, df_muster, icon, tmp_icon + 1);
				}

				if (!(st.st_mode & S_IFDIR) && filematch(entry->d_name, df_muster, -1))
				{
					if (s_str[0] != EOS)
					{
						if ((t_icon = text_still_loaded(pfad)) < 0)
						{
							set_text_name(t_ptr, pfad, FALSE);
							if (load(t_ptr, FALSE) < 0)
								if (note(2, 0, BREAK) == 1)
									break;
							if (!do_find(tmp_icon))
								raus = TRUE;
							clear_text(t_ptr);
						}
						else
						{
							if (!do_find(t_icon))
								raus = TRUE;
						}
					}
					else
						add_to_projekt(icon, pfad, TRUE);
				}
			}
			entry = readdir(dh);
			if (check_for_abbruch() && note(1, 2, BREAK) == 1)
				raus = TRUE;
		} /* while */
		if (entry != NULL)
			raus = TRUE;
		closedir(dh);
		if (s_str[0] != EOS)
			destruct_text(t_ptr);
		return raus;
	}
	return FALSE;
}

/***************************************************************************/

static void get_prj_line(int link, int line, char *str)
{
	TEXTP 	t_ptr = get_text(link);
	ZEILEP	lauf;

	lauf = get_line(&t_ptr->text,line);
	if (lauf != NULL)
		strcpy(str, TEXT(lauf));
	else
		str[0] = EOS;
}

/***************************************************************************/

static int del_from_projekt (int link, int line)
{
	TEXTP 	t_ptr = get_text(link);
	ZEILEP	lauf;
	FILENAME	name;
	
	lauf = get_line(&t_ptr->text,line);
	if (lauf!=NULL)
	{
		WINDOWP window = get_window(link);

		unclick_window();
		if (t_ptr->text.lines>1)
		{
			col_delete(&t_ptr->text, lauf);
			window->doc.h--;
			set_sliders(window, VERTICAL, SLPOS+SLSIZE);
			redraw_window(window,&window->work);
		}
		else
		{
			REALLOC(&lauf,0,-lauf->len);
			redraw_window(window,&window->work);
		}
		t_ptr->moved++;
		if (t_ptr->namenlos)
			strcpy(name, t_ptr->filename);
		else
			file_name(t_ptr->filename, name, TRUE);
		change_window(window, name, TRUE);				/* '*' in den Titel */
	}
	return 1;
}

bool add_to_projekt (int link, char *name, bool draw)
{
	int		erg, i;
	TEXTP 	t_ptr = get_text(link);
	PATH		file;

/*
	if (fs_case_sens(name) == NO_CASE)
		str_toupper(name);
*/
	strcpy(file,name);
/*
	if (!make_normalpath(file)) 
		return FALSE;
*/
	erg = 1; 
	i = 0;
	get_prj_line(link,i,file);

	/* Beim Vergleich case-ignore, damit GROSS und klein hintereinander kommen */
	while (file[0] != EOS && (erg = stricmp(file, name)) < 0)
	{
		i++;
		get_prj_line(link,i,file);
	}
	if (erg) 			/* noch nicht vorhanden */
	{
		WINDOWP window = get_window(link);

		if (ist_leer(&t_ptr->text))
		{
			INSERT(&FIRST(&t_ptr->text),0,(int)strlen(name),name);
			window->doc.h++;
		}
		else
		{
			ZEILEP new, lauf;

			if (i==0)
				lauf = &t_ptr->text.head;
			else
				lauf= get_line(&t_ptr->text,i-1);
			new = new_col(name,(int)strlen(name));
			col_insert(lauf,new);
			t_ptr->text.lines++;
			window->doc.h++;
			if (draw)
				set_sliders(window, VERTICAL, SLPOS+SLSIZE);
		}
		if (draw)
			redraw_window(window,&window->work);
		t_ptr->moved++;
		if (t_ptr->namenlos)
			strcpy(file, t_ptr->filename);
		else
			file_name(t_ptr->filename, file, TRUE);
		change_window(window, file, TRUE);					/* '*' in den Titel */
		return TRUE;
	}
	return FALSE;
}

int load_projekt(char *name)
/* return: <=0 wurde nicht geladen */
/* 		  0	weitere Texte versuchen sinnvoll */
/* 		  <0	weiter Texte versuchen nicht sinnvoll */
{
	int		err, icon;
	WINDOWP 	window;
	FILENAME datei;
	PATH		path;
	TEXTP 	t_ptr;
	ZEILEP	lauf;

	store_path(name);

	split_filename(name, path, datei);
	if ((icon = text_still_loaded(name)) >= 0)	/* schon geladen */
	{
		if (do_icon(icon, DO_OPEN) < 0)				/* nur Fenster auf */
			note(1, 0, NOWINDOW);
		return icon;
	}
	icon = crt_new_prj(name);
	if (icon<0)
	{
		note(1, 0, NOTEXT);
		return -1;
	}
	t_ptr = get_text(icon);;
	if ((err = load(t_ptr, TRUE)) == -33)		/* File not Found */
	{
		if (path_exists(path))
		{
			if (snote(1, 2, NEWTEXT, datei) == 2)
			{
				icon_edit(icon,DO_DELETE);
				return 0;
			}
		}
		else
		{
			snote(1, 0, READERR, datei);
			icon_edit(icon,DO_DELETE);
			return 0;
		}
	}
	else if (err)										/* anderer Fehler */
	{
		snote(1, 0, READERR, datei);
		icon_edit(icon,DO_DELETE);
		return 0;
	}

	window = get_window(icon);
	window->doc.y = 0;

	if (err == 0)					/* nur wenn fehlerfrei geladen wurde! */
	{
		/* Zeilenenden sÑubern */
		strip_endings(t_ptr);
	
		/* Leerzeilen entfernen */
		lauf = FIRST(&t_ptr->text);
		while (!IS_TAIL(lauf))
		{
			ZEILEP	l = lauf->nachf;
	
			if (lauf->len == 0)
			{
				col_delete(&t_ptr->text, lauf);
				t_ptr->moved++;
			}
			lauf = l;
		}
	
		if (t_ptr->moved)
		{
			file_name(t_ptr->filename, datei, TRUE);
			change_window(window, datei, TRUE);
		}
	}

	window->doc.h = t_ptr->text.lines;
	if (do_icon(icon,DO_OPEN) < 0)
	{
		note(1, 0, NOWINDOW);
		icon_edit(icon,DO_DELETE);
		icon = -2;
	}

	if (strcmp(name, def_prj_path) == 0)		/* Default-Prj wurde geladen */
	{
		def_icon = icon;
		set_def_prj();
	}
	return icon;
}

static void destruct(int icon)
{
	TEXTP 	t_ptr = get_text(icon);
	WINDOWP 	window = get_window(icon);

	close_window(window);
	destruct_text(t_ptr);
	del_icon(icon);
	do_all_icon(prj_type,DO_UPDATE); 	/* Projekte updaten */
}

/***************************************************************************/
/* Anlegen eines neuen Projekts															*/
/***************************************************************************/

int new_projekt(void)
{
	int	icon;

	icon = crt_new_prj("");
	if (icon < 0)
	{
		note(1, 0,NOTEXT);
		return -1;
	}
	if (do_icon(icon, DO_OPEN) < 0)
	{
		note(1, 0, NOWINDOW);
		icon_edit(icon, DO_DELETE);
		icon = -3;
	}
	return icon;
}

int crt_new_prj(char *filename)
{
	WINDOWP	win;
	bool		namenlos;
	TEXTP 	t_ptr;
	PATH		name;

	strcpy(name, filename);
	if (name[0] == EOS)
	{
		strcpy(name, rsc_string(NAMENLOS));
		namenlos = TRUE;
	}
	else
		namenlos = FALSE;

	/* Fenster anlegen */
	win = create_window(KIND, CLASS_PROJEKT, crt_prj);
	if (win == NULL)
		return -1;
	if (!add_icon(prj_type, win->handle))
		return -1;

	/* Text kreiern */
	t_ptr = new_text(win->handle);
	if (t_ptr == NULL)
	{
		del_icon(win->handle);
		return -1;
	}
	set_text_name(t_ptr, name, namenlos);

	if (t_ptr->namenlos)
		strcpy(name, t_ptr->filename);
	else
		file_name(t_ptr->filename, name, TRUE);
	set_wtitle(win, name);
	set_winfo(win, "");

	if (!namenlos)
		do_all_icon(prj_type,DO_UPDATE); 	/* Projekte updaten */

	t_ptr->asave = time(NULL);

	return win->handle;
}

/***************************************************************************/
/* Kreieren eines Fensters 																*/
/***************************************************************************/
static void crt_prj(WINDOWP window)
{
	int	initw, inith;

	if (window->work.g_w == 0 || window->work.g_h == 0)
	{
		/* Keine Grîûe bekannt. */
		initw  = font_wcell * 13;
		inith  = (gl_desk.g_h / font_hcell) * font_hcell - 7 * font_hcell;
		window->work.g_x	= (font_wcell + 2) * 8;
		window->work.g_y	= 60;
		window->work.g_w	= initw;
		window->work.g_h	= inith;
	}
	
	window->flags		= FLAGS;
	window->doc.w		= 13;
	window->doc.h		= 0;
	window->xfac		= font_wcell;
	window->yfac		= font_hcell;
	window->w_width	= initw/font_wcell;
	window->w_height	= inith/font_hcell;
	window->draw		= wi_draw;
	window->click		= wi_click;
	window->unclick	= wi_unclick;
	window->key 		= wi_key;
	window->snap		= wi_snap;
	window->iconify	= wi_iconify;
	window->uniconify = wi_uniconify;
}

/***************************************************************************/
/* ôffnen des Objekts																		*/
/***************************************************************************/
static bool open_prj (int icon)
{
	bool	ok = TRUE;
	WINDOWP 	window = get_window(icon);

	if (window->flags & WI_ICONIFIED)
		uniconify_window(window, NULL);
	else if (window->flags & WI_SHADED)
		shade_window(window, -1);
	else if (window->flags & WI_OPEN)
		top_window (window);
	else
		ok = open_window (window);
	return ok;
}

/***************************************************************************/

static void draw_line (WINDOWP window, int line)
{
	TEXTP t_ptr;
	GRECT	r;

	t_ptr = get_text(window->handle);
	if (line >= t_ptr->text.lines) 
		return;
	line -= (int)window->doc.y;
	if (line < 0) 
		return;
	if (line>=window->w_height) return;
	r.g_x = window->work.g_x;
	r.g_y = window->work.g_y + line * font_hcell;
	r.g_w = window->work.g_w;
	r.g_h = font_hcell;
	redraw_window(window, &r);
}

static void wi_draw (WINDOWP window, GRECT *d)
{
	ZEILEP lauf;
	TEXTP t_ptr;
	int	line, y, x, i, link;
	PATH	name, str;

	set_clip(TRUE,d);
	line = (int)window->doc.y;
	y = window->work.g_y;
	x = window->work.g_x;
	i = window->w_height;
	if (d->g_y > y)
	{
		int anz;

		anz = (d->g_y - y) / font_hcell;
		line += anz;
		y += anz * font_hcell;
		i -= anz;
	}
	if (d->g_y + d->g_h < window->work.g_y + window->work.g_h)
	{
		int anz;

		anz = ((window->work.g_y + window->work.g_h)-(d->g_y + d->g_h)) / font_hcell;
		i -= anz;
	}
	link = window->handle;
	t_ptr = get_text(link);
	lauf = get_line(&t_ptr->text,line);
	if (lauf!=NULL)
	{
		while ((--i)>=0)
		{
			get_prj_line(link, line, str);
			if (str[0] == EOS)
			{
				i++;
				break;
			}

			if (text_still_loaded(str) >= 0) 
				name[0] = '*';
			else 
				name[0] = ' ';
			make_shortpath(str, name + 1, window->w_width - 1);
			if (window == sel_window && setin(sel_objs,line))
				out_sb(x, y, window->work.g_w, name);
			else
				out_s(x, y, window->work.g_w, name);
			line++;
			y += font_hcell;
		}
	}
	for (; (--i)>=0; y += font_hcell)
		fill_area(x, y, window->work.g_w, font_hcell, bg_color);
}

/***************************************************************************/
int drag_box(int x, int y, int w, int h, int *m_x, int *m_y, int *bstate, int *kstate)
{
	int	wh, d;
	
	graf_mouse(FLAT_HAND, NULL);
	graf_dragbox(w, h, x, y, gl_desk.g_x, gl_desk.g_y, gl_desk.g_w, gl_desk.g_h, &d, &d);
	graf_mouse(ARROW, NULL);
	graf_mkstate(m_x, m_y, bstate, kstate);
	wh = wind_find(*m_x, *m_y);
	return wh;
}

static void	wi_click (WINDOWP window, int m_x, int m_y, int bstate, int kstate, int breturn)
{
	int		y;
	GRECT		*s = &window->work;
	PATH		str;
	SET		new_obj;
	
	if (bstate & 2)								/* Rechtsklick */
		return;

	if (!inside(m_x, m_y, s))
		return;

	if (sel_window != window)
		unclick_window();
	set_winfo(window,"");

	y = (int)(window->doc.y) + (m_y - s->g_y) / font_hcell;
	get_prj_line(window->handle, y, str);
	if (str[0] == EOS)
		return;

	setclr(new_obj);
	setincl(new_obj, y);									/* Aktuelles Objekt */

	if (kstate & (K_RSHIFT|K_LSHIFT))
	{
		setxor(sel_objs, new_obj);
		if (setcmp(sel_objs, NULL))
			sel_window = NULL;
		else
			sel_window = window;
		draw_line (window, y);
		if (!setin (sel_objs, y))
		{
			graf_mkstate(&m_x, &m_y, &bstate, &kstate);
			if (bstate & 1)						/* Immernoch gedrÅckt ? */
				evnt_button(1, 1, 0, &m_x, &m_y, &bstate, &kstate);
			return;
		}
	}
	else 														/* noch nicht angeklickt */
	{
		graf_mkstate(&m_x, &m_y, &bstate, &kstate);
		if (!(bstate & 1))								/* Immernoch gedrÅckt -> nichts tun */
		{
			bool	re_sel;

			re_sel = setcmp(new_obj, sel_objs);
			unclick_window ();							/* Alle Objekte lîschen */

			/* re_sel ist TRUE, wenn ein Eintrag zum zweiten Mal selektiert wurde
			 * -> wieder deselektieren.
			*/
			if (!re_sel)
			{
				setincl(sel_objs, y);
				sel_window = window;
			}
			draw_line(window, y);
		}
	}
	if (breturn == 1 && (bstate & 1))				/* Zieh-Operation */
	{
		GRECT		first;
		int		num_objs, i, obj;
		WINDOWP	qed_win;

		graf_mkstate(&m_x, &m_y, &bstate, &kstate);
		if (!(bstate & 1))
			return; 											/* Immernoch gedrÅckt ? */

		if (window == sel_window)
			setcpy(new_obj, sel_objs);
		num_objs = 0;
		for (i = 0; i < window->w_height; i++)
		{
			if (setin(new_obj, i + (int)window->doc.y))
			{
				if (num_objs == 0)		/* Abmessungen des ersten merken */
				{
					first.g_x = s->g_x;
					first.g_y = s->g_y + (i * font_hcell);
					first.g_w = s->g_w;
				}
				num_objs++;
			}
		}
		obj = drag_box(first.g_x, first.g_y, first.g_w, font_hcell * num_objs, &m_x, &m_y, &bstate, &kstate);
		qed_win = get_window(obj);
		if (qed_win)												/* eigenes Fenster */
		{
			if (qed_win != window && (qed_win->class == CLASS_PROJEKT ||
											  qed_win->class == CLASS_EDIT))
			{
				drag_data_size = num_objs;
				for (i = 0; i < window->w_height; i++)
					if (setin(new_obj, i + (int)window->doc.y))
					{
						get_prj_line(window->handle, i + (int)window->doc.y, drag_filename);
						if (drag_filename[0] == EOS)
							break;
						if ((kstate & K_ALT) || (qed_win->class == CLASS_PROJEKT))
							icon_drag(qed_win->handle, DRAGDROP_FILE);
						if (kstate & (K_LSHIFT|K_RSHIFT))
							icon_drag(qed_win->handle, DRAGDROP_PATH);
					}
				drag_data_size = 0;
			}
		}
		else															/* fremdes Fenster */
		{
			/* 
			 * Bisher wird immer an den Desktop geschickt,
			 * aber nur, wenn dieser AV_DRAG_ON_WINDOW kann.
			*/
			if ((av_shell_id >= 0) && (av_shell_status & 512))
			{		
				if (num_objs > 1)
				{
					drag_data_size = (long)num_objs * sizeof(PATH);
					drag_data = (char *)malloc(drag_data_size);
					strcpy(drag_data, "");
				}
				else
				{
					drag_data_size = 0L;
					drag_data = NULL;
				}
					
				i = check_avobj(m_x, m_y);
				if (i == 1 || i == 2)						/* Papierkorb/Shredder */
				{
					setcpy(sel_objs, new_obj);
					do_icon(window->handle+SUB_ICON, DO_DELETE);
				}
				else
				{
					for (i=0; i<window->w_height; i++)
					{
						if (setin(new_obj, i + (int)window->doc.y))
						{
							get_prj_line(window->handle, i + (int)window->doc.y, drag_filename);
							if (drag_filename[0] != EOS)
							{
								if (num_objs > 1)
								{
									if (drag_data[0] != EOS)
										strcat(drag_data, " ");
									strcat(drag_data, drag_filename);
								}
								/*	else steht das Arg in drag_filename */
							}
						}
					} /* for */
	
					if (num_objs > 1)
						send_avdrag(obj, m_x, m_y, kstate, DRAGDROP_DATA);
					else
						send_avdrag(obj, m_x, m_y, kstate, DRAGDROP_PATH);
				}
				if (drag_data_size > 0)
				{
					free(drag_data);
					drag_data_size = 0;
				}
			} /* if av_ */
		} /* if !my_window */
	}
	if (breturn == 2)										/* Doppelklick */
	{
		unclick_window();
		sel_window = window;
		setincl(sel_objs,y);
		draw_line(window,y);
		graf_mkstate(&m_x, &m_y, &bstate, &kstate);
		if (bstate & 1)									/* Immernoch gedrÅckt ? */
			evnt_button(1, 1, 0, &m_x, &m_y, &bstate, &kstate);
		do_icon(window->handle + SUB_ICON, DO_OPEN);
	}
}

/***************************************************************************/

static void wi_unclick (WINDOWP window)
{
	SET	help;
	int	i, max;

	setcpy(help,sel_objs);
	setclr(sel_objs);
	max = setmax(help);
	for (i=setmin(help); i<=max; i++)
		if (setin(help,i))
			draw_line(window,i);
	set_winfo(window,"");
}

/***************************************************************************/

static void sel_line(WINDOWP window, int line)
{
	if (sel_window!=NULL)
		unclick_window();
	sel_window = window;
	setincl(sel_objs,line);
	draw_line(window,line);
	line -= (int) window->doc.y;
	if (line<0)
		arrow_window(window,WA_UPLINE,-line);
	else
	{
		line -= (window->w_height-1);
		if (line>0)
			arrow_window(window,WA_DNLINE,line);
	}
}


static void shift_up(WINDOWP window)
{
	int	i;

	if (window->doc.h == 0)
		return;
	if (sel_window == window)
	{
		i = setmin(sel_objs);
		if (i == 0)
			return ;
		i -= window->w_height;
		if (i < 0)
			i = 0;
		sel_line(window,i);
	}
	else
		sel_line(window, (int)window->doc.h-1);
}

static void shift_down(WINDOWP window)
{
	int	i;

	if (window->doc.h == 0)
		return ;
	if (sel_window == window)
	{
		i = setmin(sel_objs);
		if (i == window->doc.h - 1)
			return ;
		i += window->w_height;
		if (i >= window->doc.h)
			i = (int) window->doc.h - 1;
		sel_line(window,i);
	}
	else
		sel_line(window,0);
}

static bool	wi_key(WINDOWP window, int kstate, int kreturn)
{
	bool	erg;
	int	nkey, i;
	int	ascii_code;
	bool	shift, ctrl, alt;
	
	/* Key konvertieren */	
	nkey = gem_to_norm(kstate, kreturn);
	nkey &= ~(NKF_RESVD|NKF_SHIFT|NKF_CTRL|NKF_CAPS);
	ascii_code = nkey & 0x00FF;
	shift = (kstate & (K_RSHIFT|K_LSHIFT)) != 0;
	ctrl = (kstate & K_CTRL) != 0;
	alt = (kstate & K_ALT) != 0;
	
	/* Damit F-Tasten zum System-Desktop kommen! */
	if ((kreturn >= 0x3B00 && kreturn <= 0x4400) ||
		 (kreturn >= 0x5400 && kreturn <= 0x5D00))
		return FALSE;

	erg = FALSE;
	if ((nkey & NKF_FUNC) && shift)
	{
		nkey &= ~NKF_FUNC;
		switch (nkey)
		{
			case NK_CLRHOME :
				v_slider(window, 1000);
				sel_line(window, (int)window->doc.h - 1);
				erg = TRUE;
				break;
			case NK_UP	:
				shift_up(window);
				erg = TRUE;
				break;
			case NK_DOWN:
				shift_down(window);
				erg = TRUE;
				break;
			default:
				erg = FALSE;
				break;
		}
	}
	else if (nkey & NKF_FUNC)
	{
		nkey &= ~NKF_FUNC;
		switch (nkey)
		{
			case NK_RET :
			case (NK_ENTER|NKF_NUM) :
				do_icon(window->handle + SUB_ICON, DO_OPEN);
				erg = TRUE;
				break;
			case NK_CLRHOME :
				v_slider(window, 0);
				sel_line(window,0);
				erg = TRUE;
				break;
			case NK_UP :
				if (window->doc.h == 0)
					break;
				if (sel_window == window)
				{
					i = setmin(sel_objs);
					if (i == 0)
						break;
					i--;
					if (i < 0)
						i = 0;
					sel_line(window,i);
				}
				else
					sel_line(window, (int)window->doc.h - 1);
				erg = TRUE;
				break;
			case NK_DOWN:
				if (window->doc.h == 0)
					break;
				if (sel_window == window)
				{
					i = setmin(sel_objs);
					if (i==window->doc.h-1)
						break;
					i++;
					if (i >= window->doc.h)
						i = (int) window->doc.h-1;
					sel_line(window,i);
				}
				else
					sel_line(window,0);
				erg = TRUE;
				break;
			case NK_HELP :
				erg = FALSE;				/* DO_HELP wird von key_global verteilt */
				break;
			case NK_M_PGUP:				/* Mac: page up -> shift-up */
				shift_up(window);
				erg = TRUE;
				break;
			case NK_M_PGDOWN:				/* Mac: page down -> shift-down */
				shift_down(window);
				erg = TRUE;
				break;
			case NK_M_END:					/* Mac: end -> shift-home */
				v_slider(window, 1000);
				sel_line(window, (int)window->doc.h - 1);
				erg = TRUE;
				break;
			case NK_DEL :
				do_icon(window->handle + SUB_ICON, DO_DELETE);
				erg = TRUE;
				break;
			default:
				if (!ctrl && !alt && !shift && ascii_code)
				{
					if (sel_window == window)
						unclick_window();
					else
						set_winfo(window,"");
					erg = TRUE;
				}
				else
					erg = FALSE;
				break;
		}
	}
	else
	{
		int		l;
		FILENAME name;
		PATH		str, info;
		char		asc;
		
		/* Auto-Locator */
/*
		asc = nkc_toupper(ascii_code);
*/
		asc =ascii_code;
		strcpy(info, window->info);
		l = (int)strlen(info);
		info[l++] = asc;
		info[l] = EOS;
		i = 0;
		do
		{
			get_prj_line(window->handle,i,str);
			i++;
			if (str[0] == EOS)
				break;
			file_name(str,name, FALSE);
/*
			str_toupper(name);
*/
		}
		while (strnicmp(name, info, l) != 0);
		if (str[0]!=EOS)
		{
			sel_line(window,i-1);
			set_winfo(window,info);
		}
		erg = TRUE;
	}
	return erg;
}

/***************************************************************************/

static void	wi_snap(WINDOWP window, GRECT *new, int mode)
{
	int w, ex, pxy[8];

	/* zunÑchst Platz fÅr min. 1+Filename+1 im Fenster */
	vqt_extent(vdi_handle, "x", pxy);
	ex = pxy[2] - pxy[0];
	w = new->g_w;
	if (w < 14 * ex)
		w = 14 * ex;

	/* nun noch Platz fÅr Fenstertitel (1+8+1) */
	if (w < gl_wchar * 10)
		w = gl_wchar * 10;

	new->g_w = w;
}


static void wi_iconify(WINDOWP window)
{
	TEXTP 	t_ptr = get_text(window->handle);
	FILENAME short_name;

	if (t_ptr->namenlos)
		strcpy(short_name, t_ptr->filename);
	else
		make_shortpath(t_ptr->filename, short_name, 8);
	set_wtitle(window, short_name);
}


static void wi_uniconify(WINDOWP window)
{
	TEXTP 	t_ptr = get_text(window->handle);
	FILENAME name;

	if (t_ptr->namenlos)
		strcpy(name, rsc_string(NAMENLOS));
	else
		file_name(t_ptr->filename, name, TRUE);
	set_wtitle(window, name);
}

/***************************************************************************/
/* Info des Objekts																			*/
/***************************************************************************/

static long 	i_len, i_bytes;
static int		i_anz, i_icon;
	
static int count(int icon, int i)
{
	PATH	name;

	i_anz++;
	get_prj_line(icon, i, name);
	if ((icon = text_still_loaded(name))>=0)
	{
		TEXTP t_ptr;

		t_ptr = get_text(icon);
		i_bytes += textring_bytes(&t_ptr->text);
		i_len += t_ptr->text.lines;
		return 1;
	}
	else
	{
		long	b,l;
		int	antw;

		antw = infoload(name,&b,&l);
		i_bytes += b;
		i_len += l;
		return (antw == 0) ? 1 : 0;
	}
}

static void info_projekt(int icon)
{
	char 	str[32], date[11];
	TEXTP t_ptr = get_text(icon);
	int	r_anz, i, antw;
	SET	all;
	bool	close = FALSE;
	MDIAL	*dial;
	
	set_state(prjinfo, IPRJSCAN, DISABLED, FALSE);
	i_icon = icon;
	make_shortpath(t_ptr->filename, str, 30);
	set_string(prjinfo, PRJNAME, str); 		/* Name mit Pfad */
	if (ist_leer(&t_ptr->text))
		r_anz = 0;
	else
		r_anz = (int)t_ptr->text.lines;
	set_int(prjinfo, PRJFILES, r_anz);		/* Dateien-Anzahl */
	set_string(prjinfo, PRJLEN , "??"); 	/* LÑnge in Bytes unbekannt */
	set_string(prjinfo, PRJZEILE , "??");	/* LÑnge in Zeilen unbekannt */
	if (t_ptr->namenlos)
	{
		strcpy(str, "");
		strcpy(date, "--");
	}
	else
		file_time (t_ptr->filename, date, str);
	set_string(prjinfo, PRJDATUM, date);	/* Datum */
	set_string(prjinfo, PRJZEIT, str); 		/* Uhrzeit */

	dial = open_mdial(prjinfo, 0);
	if (dial != NULL)
	{
		while (!close)
		{
			antw = do_mdial(dial) & 0x7fff;
			switch (antw)
			{
				case IPRJSCAN:
					if (ist_leer(&t_ptr->text))
						r_anz = 0;
					else
						r_anz = (int) t_ptr->text.lines;
					i_anz = 0;
					i_bytes = 0;
					i_len = 0;
					setclr(all);
					for (i = r_anz; (--i)>=0; )
						setincl(all, i);
					do_for_prj(i_icon, all, count, TRUE);
					if (r_anz == i_anz)									/* alle durchlaufen */
						ltoa(i_bytes, str, 10);
					else
						str[0] = EOS;
					set_string(prjinfo, PRJLEN , str); 			/* LÑnge in Bytes */
					if (r_anz == i_anz)
						ltoa(i_len, str, 10);
					else
						str[0] = EOS;
					set_string (prjinfo, PRJZEILE , str);		/* LÑnge in Zeilen */
					if (r_anz == i_anz)								/* alle durchlaufen */
						set_state(prjinfo, IPRJSCAN, DISABLED, TRUE);
					set_state(prjinfo, IPRJSCAN, SELECTED, FALSE);
					redraw_mdobj(dial, 0);
					break;
		
				default:
					close = TRUE;
					break;
			}
		}
		set_state(prjinfo, antw, SELECTED, FALSE);
		close_mdial(dial);
	}
}

/******************************************************************************/
/* Default-Projekt																				*/
/******************************************************************************/

void	open_def_prj(void)
{
	if (def_prj_path[0] != EOS && shift_pressed())	/* altes abmelden */
	{
		def_prj_path[0] = EOS;
		def_icon = -1;
	}
	else if (def_prj_path[0] != EOS) 				/* bekanntes îffnen */
		load_projekt(def_prj_path);
	else
		select_def_prj(); 								/* nix bekannt, also auswÑhlen */
	set_def_prj(); 										/* MenÅ anpassen */
}


void	add_to_def(void)
{
	WINDOWP w;

	w = real_top();
	if (w == NULL)
		return;
	if (w->handle != def_icon)
	{
		TEXTP t_ptr = get_text(w->handle);

		if (!t_ptr->namenlos)
			add_to_projekt(def_icon, t_ptr->filename, TRUE);
	}
}


static void	select_def_prj(void)
{
	PATH	name = "";

	if (select_single(name, "*.qpj", rsc_string(DEFPRJ2STR)))
	{
		strcpy(def_prj_path, name);
		load_projekt(def_prj_path);
	}
}


void set_def_prj(void)
{
	FILENAME n = "";

	if (def_icon == -1 || def_prj_path[0] == EOS)
	{
		menu_ienable(menu, MTAKEPRJ, FALSE);
		menu_icheck(menu, MPROJEKT, FALSE);
	}
	else
	{
		menu_ienable(menu, MTAKEPRJ, TRUE);
		menu_icheck(menu, MPROJEKT, TRUE);
	}

	/* Name ins MenÅ eintragen */
	if (def_prj_path[0] != EOS)
		file_name(def_prj_path, n, FALSE);
	else
		strcpy(n, rsc_string(DEFPRJSTR));
	fillup_menu(MPROJEKT, n, 2);
}

void find_on_disk(void)
{
	int	icon;
	TEXTP	t_ptr;
	
	icon = crt_new_prj("");
	if (icon < 0) 
		return;
	if (do_icon(icon, DO_OPEN) < 0)
	{
		note(1, 0, NOWINDOW);
		icon_edit(icon, DO_DELETE);
	}
	do_icon(icon, DO_ADD);
	t_ptr = get_text(icon);
	if (!t_ptr->moved)			/* nichts gefunden */
		icon_edit(icon, DO_DELETE);
}

/******************************************************************************/
/* Initialisierung																				*/
/******************************************************************************/

void init_projekt(void)
{
	get_path(df_path, 0);							/* Aktuellen Pfad holen */
	prj_type = decl_icon_type(p_icon_test, p_icon_edit, p_icon_exist, p_icon_drag);
	def_prj_path[0] = EOS;
	def_icon = -1;
}
