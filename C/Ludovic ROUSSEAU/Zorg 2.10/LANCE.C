/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>
#include <screen.h>
#include <ctype.h>

#include "globals.h"
#include "zorg.h"

#include "lance.h"
#include "dialog.h"
#include "fat.h"
#include "fenetre.h"
#include "init.h"
#include "ouvre.h"
#include "update.h"
/* variables locales */
typedef struct
{
	char nom[FILENAME_MAX];
} lance_prg_var;

/****************************************************************
*																*
*		lance un programe externe avec des paramŠtres			*
*																*
****************************************************************/
void lance_prg(void)
{
	lance_prg_var *var = Dialog[LANCE_PRG].var;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(lance_prg_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[LANCE_PRG].var = var;

		var -> nom[0] = '\0';
	}

	Dialog[LANCE_PRG].proc = lance_prg_proc;
	my_open_dialog(&Dialog[LANCE_PRG], AUTO_DIAL, FAIL);
} /* lance_prg */

/****************************************************************
*																*
*	lance un programe externe avec des paramŠtres (gestion)		*
*																*
****************************************************************/
boolean lance_prg_proc(t_dialog *dialog, int exit)
{
	lance_prg_var *var = Dialog[LANCE_PRG].var;
	char nom[FILENAME_MAX] = "", text[FILENAME_MAX];
	char nom_court[61];
	t_dialog_list *win;
	int dummy, handle;
	long err;
	char param[61];
	float a, b;
	int ligne, taille_page, line_number;
	windowptr thewin;
	int tos = ClearScreen;

	switch (exit)
	{
		case LANCE_ANNULER:
			return TRUE;

		case PROGRAM_NAME:
			tos = ob_isstate(dialog -> tree, EFFACER_ECRAN, SELECTED);
			if(selecteur(nom, tos ? "*.TOS,*.TTP" : "*.PRG,*.APP,*.GTP", Messages(LANCE_1)))
			{
				if (strlen(nom)>60)
				{
					get_max_name(nom, nom_court, 59, FALSE);
					strcpy(dialog -> tree[PROGRAM_NAME].ob_spec.tedinfo -> te_ptext, nom_court+1);
				}
				else
					strcpy(dialog -> tree[PROGRAM_NAME].ob_spec.tedinfo -> te_ptext, nom);
			}
			strcpy(var -> nom, nom);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;
	}

	if (exit != LANCE_OK)
		return FALSE;

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	/* ferme tous les dialog */
	for (win = WinDials; win; win = win -> next)
		my_close_dialog(win -> dialog);

	sprintf(text, Messages(LANCE_2), dialog -> tree[PROGRAM_NAME].ob_spec.tedinfo -> te_ptext, dialog -> tree[COMMAND_LINE].ob_spec.tedinfo -> te_ptext);
	ajoute(Firstwindow, text);

	MakePause = dialog -> tree[PAUSE].ob_state & SELECTED;
	ClearScreen = dialog -> tree[EFFACER_ECRAN].ob_state & SELECTED;
	FlushCache = dialog -> tree[VIDE_CACHE].ob_state & SELECTED;

	if (FlushCache)
		for (dummy=0; dummy<MAX_DEVICES; dummy++)
			change_disque(dummy, FALSE);

	MouseOff();

	menu_enable(FALSE);	/* efface le menu */	menu_install(Menu,FALSE);
	if (aes_version>=0x0140)		shel_write(1, ClearScreen ? 0 : 1, 0, var -> nom, dialog -> tree[COMMAND_LINE].ob_spec.tedinfo -> te_ptext);
	appl_exit();	appl_init();
	/* ferme les fenˆtres (garde le contenu quand mˆme) */
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
	{
		handle = thewin -> win -> handle;

		wind_close(handle);
		wind_delete(handle);
	}

	if (aes_version>=0x0140)		wind_new();
	wind_set(0, WF_NEWDESK, 0, 0, 0);	/* d‚gage mon bureau */

	form_dial(FMD_FINISH, 0, 0, max_w, max_h, 0, 0, max_w, max_h);
	MouseOn();
	MouseBee();

	if (ClearScreen)
	{
		int bouton = 1, dummy;

		while (bouton)
			vq_mouse(x_handle, &bouton, &dummy, &dummy);

		MouseOff();
		v_enter_cur(x_handle);
	}

	appl_exit();	
	Dsetdrv(toupper(var -> nom[0])-'A');
	Dsetpath(Chemin);
	sprintf(param, "%c%s", (int)strlen(dialog -> tree[COMMAND_LINE].ob_spec.tedinfo -> te_ptext), dialog -> tree[COMMAND_LINE].ob_spec.tedinfo -> te_ptext);
	err = Pexec(0, var -> nom, param, NULL);

	if (MakePause)
		Bconin(2);

	ap_id = appl_init();

	if (aes_version>=0x0140)		wind_new();
	if (ClearScreen)
	{
		v_exit_cur(x_handle);
		MouseOn();	
	}

	MouseOff();

	menu_install(Menu,TRUE);	menu_enable(TRUE);
	wind_set(0, WF_NEWDESK, (int)((long)Bureau >> 16), (int)((long)Bureau & 0xFFFF), 0); /* remet mon bureau */
	form_dial(FMD_FINISH, 0, 0, 0, 0, desk.g_x, desk.g_y, desk.g_w, desk.g_h);

	/* recr‚‚ les fenˆtres */
	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
	{
		/* Create the information for the window.  Max size is the desktop. */
		handle = wind_create(thewin -> win -> gadgets, desk.g_x, desk.g_y, desk.g_w, desk.g_h);

		if (handle < 0)
		{
			my_alert(1, FAIL, X_ICN_ALERT, Messages(LANCE_3), NULL);
			reset();
		}
		thewin -> win -> handle = handle;

		/* Set the title for the window. */
		if (thewin -> win -> gadgets & NAME)
			window_name(thewin -> win, thewin -> title, thewin -> title);

		if (thewin -> win -> gadgets & INFO)
			window_info(thewin -> win, thewin -> info);

		if (BottomIsMeaningful)
			wind_open(handle, thewin -> win -> curr.g_x, thewin -> win -> curr.g_y, thewin -> win -> curr.g_w, thewin -> win -> curr.g_h);

		switch (thewin -> type)
		{
			case SECTEUR:
			case FICHIER:
			case FICHIER_FS:
			case TEXT:
			case RAW_FLOPPY:
			case RAW_HARD:
				wind_set(handle, WF_HSLSIZE, (int)(thewin -> win -> work.g_w *1000. / max_w), 0, 0, 0);
				wind_set(handle, WF_HSLIDE, (int)(thewin -> fonction.text.colonne * 8000./(max_w - thewin -> win -> work.g_w)), 0, 0, 0);

				taille_page = thewin -> win -> work.g_h / thewin -> fonction.text.taille_h;
				ligne = thewin -> fonction.text.ligne; 
				line_number = thewin -> fonction.text.LineNumber -1;
		
				wind_set(handle, WF_VSLSIZE, min(1000, taille_page * 1000 / line_number), 0, 0, 0);
		
				a = 1000. / (line_number - taille_page);
				b = a * (taille_page -1);
				wind_set(handle, WF_VSLIDE, max(0, (int)(a * ligne - b)), 0, 0, 0);
				break;
		}
	}

	if (!BottomIsMeaningful)
	{
		/* r‚-ouvre les fenˆtres dans le bon ordre */
		dummy = 0;
		for (thewin = Firstwindow; thewin; thewin = thewin -> next)
			dummy = max(dummy, thewin -> place);

		for (; dummy>=0 ;dummy--)
			for (thewin = Firstwindow; thewin; thewin = thewin -> next)
				if (thewin -> place == dummy)
					/* Draw the window. */
					wind_open(thewin -> win -> handle, thewin -> win -> curr.g_x, thewin -> win -> curr.g_y, thewin -> win -> curr.g_w, thewin -> win -> curr.g_h);
	}

	MouseArrow();
	MouseOn();

	if (err < 0)
		error_msg((int)err);
	else
	{
		sprintf(param, Messages(LANCE_4), err);
		my_alert(1, FAIL, X_ICN_INFO, param, NULL);
	}

	if (aes_version>=0x0140)		shel_write(1, 1, 0, "", "");
	return TRUE;
} /* lance_prg_proc */
