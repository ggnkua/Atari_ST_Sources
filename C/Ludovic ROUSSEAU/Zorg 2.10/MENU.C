/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>

#include "zorg.h"
#include "globals.h"

#include "menu.h"

#include "boot.h"
#include "brut.h"
#include "config.h"
#include "curseur.h"
#include "deplace.h"
#include "dialog.h"
#include "fat.h"
#include "fenetre.h"
#include "info.h"
#include "init.h"
#include "lance.h"
#include "main.h"
#include "ouvre.h"
#include "reorg.h"
#include "search.h"
#include "secteur.h"
#include "tampon.h"
#include "wind.h"

/********************************************************************
*																	*
*						 Gestion du menu							*
*																	*
********************************************************************/
boolean MenuSelect(int object, int scan, int state, int button)
{
	int index, entree, key;

	if (object < 0)
	{
		/* attend qu'on relache la souris */
		NoClick();

		if (button < 0)
		{
			/* regarde la touche */
			key = scantoascii(scan);
			if (key == 0)
				key = scan & 0xFF00;	/* scan code */
			else
				key = UpperChar(key);

			for (index = 0; index < NbMenus; index++)
				for (entree = 0; entree < MenuShortCuts[index].nb_entrees; entree++)
					if (MenuShortCuts[index].menu[entree].key == key && MenuShortCuts[index].menu[entree].state == state)
					{
						if (ob_isstate(Menu, MenuShortCuts[index].menuid, DISABLED) == 0 && ob_isstate(Menu, MenuShortCuts[index].menu[entree].itemid, DISABLED) == 0)
						{
							object = MenuShortCuts[index].menu[entree].itemid;
							index = NbMenus;
						}
						break;
					}
		}
	}

	if (object < 0)
		return FALSE;	/* kein entsprechender Eintrag gefunden */

	/* Menpunkte 'Fenster wechseln' und 'Fenster schliežen' werden
	   inklusive der dazugeh”rigen Hotkeys automatisch verwaltet */

	switch (object)
	{
						/* menu Zorg */

		case INFORMATIONS:
			presentation();
			break;

						/* menu Etat */

		case INFORMATION:
			informations(Drive);
			break;

		case REPERTOIRE_LOUPE:
			if (ManageVFAT)
				open_directory_vfat();
			else
				open_directory_short();
			break;

		case TEST_STRUCTURE:
			if (ManageVFAT)
				structure_test_vfat(Drive);
			else
				structure_test_short(Drive);
			break;

		case STATISTIQUES:
			statistiques(Drive);
			break;

		case OCCUPATION:
			occupation(Drive);
			break;

		case TRACE_UN_FICHIER:
			trace_file();
			break;

		case QUITTER:
			if (Reset)
			{
				if (my_alert(1, 2, X_ICN_QUESTION, Messages(MENU_1), Messages(BOOT_32)) == 0)
					shutdown(TRUE);
			}
			else
			{
				button = my_alert(2, 3, X_ICN_QUESTION, Messages(MENU_2), Messages(MENU_4));
				if (button == 0 || button == 1 && (int)xbios(0x11) % 2)
					shutdown(FALSE);
			}
			break;

					/* menu Ouvre */

		case UNITE_LOGIQUE:
			open_disk();
			break;

		case OUVRE_DISQUETTE:
			raw_floppy(FALSE);
			break;

		case OUVRE_DISQUE_DUR:
			raw_hard(FALSE);
			break;

		case OUVRE_FICHIER:
			open_file();
			break;

		case OUVRE_FICHIER_FS:
			open_file_other_fs();
			break;

		case OUVRE_FICH_TEXTE:
			voir_fichier();
			break;

		case CREER_FICHIER:
			creer_fichier();
			break;

		case FERMER:
			fermer(Thefrontwin -> win -> handle);
			break;

		case LIRE_BOOT:
			lire_boot();
			break;

		case CHARGER_BOOT:
			charger_boot();
			break;

		case SAUVER_BOOT:
			sauver_boot();
			break;

		case ECRIRE_BOOT:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

			/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			ecrire_boot();
#endif
			break;

					/* menu Edition */

		case SAUVER_SECTEUR:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

			/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			save_secteur(Thefrontwin, MENU_EDITION);
#endif
			break;

		case COPIER_SECTEUR:
			copier_tampon(Thefrontwin);
			break;

		case COLLER_SECTEUR:
			coller_tampon(Thefrontwin);
			break;

		case ECHANGER_TAMPON:
			echanger_tampon(Thefrontwin);
			break;

		case RETOUR_INITIAL:
			load_secteur(Thefrontwin, MENU_EDITION);
			break;

		case OUVRIR_TAMPON:
			ouvrir_tampon();
			break;

		case SAUVER_TAMPON:
			sauver_tampon();
			break;

		case CHARGER_TB_ASCII:
			ascii_tampon();
			break;

		case EFFACER_TAMPON:
			effacer_tampon();
			break;

					/* menu Structure */

		case DEFRAGMENTATION:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

			/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			reconnect(Drive);
#endif
			break;

		case UNIQUE_LIBRE:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

			/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			compresse(Drive);
#endif
			break;

		case RESTO_COMPLETE:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

		/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			restauration_complete(Drive);
#endif
			break;

		case VIDE_CLST_LIBRES:
			nettoie_clusters_libres(Drive);
			break;

		case NETTOIE_REPERTOI:
#ifdef TEST_VERSION
			/* relache la souris */
			NoClick();

			/* on attend avant de redessiner */
			Event_Timer(0, 0, TRUE);

			my_alert(1, FAIL, X_ICN_STOP, Messages(MENU_6), NULL);
#else
			nettoie_repertoire(Drive);
#endif
			break;

					/* menu Deplacement */

		case SECTEUR_SUIVANT:
			next_secteur(Thefrontwin);
			break;

		case SECTEUR_PRECEDEN:
			previous_secteur(Thefrontwin);
			break;

		case BLOC_SUIVANT:
			next_bloc(Thefrontwin);
			break;

		case BLOC_PRECEDENT:
			previous_bloc(Thefrontwin);
			break;

		case MARQUER_POSITION:
			marquer_position(Thefrontwin);
			break;

		case ALLER_MARQUE:
			goto_marque(Thefrontwin);
			break;

		case ALLER_SECTEUR:
			goto_secteur(Thefrontwin);
			break;

		case CHERCHER_CHAINE:
			search_first(Thefrontwin);
			break;

		case CHERCHER_NOUVEAU:
			search_next(Thefrontwin);
			break;

					/* menu Fenˆtres */

		case CHOIX_FONTE:
			choix_fonte(Thefrontwin);
			break;

		case CHOIX_COULEURS:
			couleur(Thefrontwin);
			break;

		case TAILLE_IDEALE:
			taille_ideale(Thefrontwin);
			break;

		case ASCENSEURS:
			ascenseurs(Thefrontwin);
			break;

		case CYCLER_FENETRES:
			cycle_window();
			break;

		case WINDOW_LIST_1:
		case WINDOW_LIST_2:
		case WINDOW_LIST_3:
		case WINDOW_LIST_4:
		case WINDOW_LIST_5:
		case WINDOW_LIST_6:
		case WINDOW_LIST_7:
		case WINDOW_LIST_8:
		case WINDOW_LIST_9:
		case WINDOW_LIST_10:
			{
				windowptr thewin;

				for (thewin = Firstwindow; thewin; thewin = thewin -> next)
					if (thewin -> menu_entry == object - WINDOW_LIST_1)
						make_frontwin(thewin);
			}
			break;

						/* menu Options */

		case CONFIG_GENERALE:
			config_generale();
			break;

		case CONFIG_DSK:
			config_disques();
			break;

		case RACCOURCIS_CLAVI:
			raccourcis_clavier();
			break;

		case DONNEES_ZORG:
			from_zorg_inf(TRUE);
			break;

		case DONNEES_SYSTEME:
			from_zorg_inf(FALSE);
			break;

		case INVALIDE_CACHE:
			if (Kbshift(FAIL) & 4)
			{
				int i;

				for (i=0; i<MAX_DEVICES; i++)
					change_disque(i, FALSE);
			}
			else
				change_disque(Drive, TRUE);
			break;

		case UPDATE_SYSTEME:
			if (Kbshift(FAIL) & 4)
			{
				int i;

				for (i=0; i<MAX_DEVICES; i++)
					update_systeme(i);
			}
			else
				update_systeme(Drive);
			break;

		case VISU_TEXTE:
			really_voir_fichier(Thefrontwin -> fonction.fichier.nom);
			break;

		case VISU_ASCII:
			secteur_ascii(Thefrontwin);
			break;

		case VISU_HEXA:
			secteur_hexa(Thefrontwin);
			break;

		case AFFICHE_DECIMAL:
			affichage_decimal(Thefrontwin);
			break;

		case FICHIER_ASSOCIE:
			secteur_file(Thefrontwin);
			break;

		case CURSEUR_VISIBLE:
			curseur_on(Thefrontwin);
			break;

		case CLIPBOARD_GEM:
			clipboard_gem(Thefrontwin);
			break;

						/* menu Aide */

		case TABLE_ASCII:
			AsciiChar = m_ascii_box(AsciiChar, FALSE);
			break;

		case AIDE:
			aide();
			break;

		case EXECUTER_PROG:
			lance_prg();
			break;

		case RESET:
			if (Reset)
			{
				Reset = FALSE;
				menu_icheck(Menu, RESET, 0);
			}
			else
			{
				int button;

				button = my_alert(2, 3, X_ICN_QUESTION, Messages(MENU_3), Messages(MENU_5));
				if (button == 1)
					shutdown(TRUE);
				else
					if (button == 0)
						reset();
			}
			break;
	}

	return TRUE;
} /* MenuSelect */

/****************************************************************
*																*
*			Met en place les raccourcis clavier					*
*																*
****************************************************************/
void set_shortcuts(void)
{
	int dropdowns, title, entree, bar, delta;
	int menu_idx, entree_idx;
	char key[SHORTCUT_SIZE];
	int size;

	dropdowns = Menu[0].ob_tail;
	bar = Menu[0].ob_head;	/* bar */
	bar = Menu[bar].ob_head;	/* active */
	bar = Menu[bar].ob_head;	/* 1Šre G_BOX */

	menu_idx = 0;
	for (title = Menu[dropdowns].ob_head; title != dropdowns; title = Menu[title].ob_next, menu_idx++)
	{
		/* son fils est un G_BOX contenant les entr‚es */
		entree_idx = 0;
		size = 0;

		if (menu_idx == 0)
			/* calcul le d‚calage sur le 1er menu */
			delta = Menu[title].ob_x - Menu[bar+menu_idx].ob_x;
		else
			/* on met le menu juste au dessous de l'entr‚e */
			Menu[title].ob_x = Menu[bar+menu_idx].ob_x + delta;

		for (entree = Menu[title].ob_head; entree != title; entree = Menu[entree].ob_next, entree_idx++)
			if (MenuShortCuts[menu_idx].menu[entree_idx].itemid == entree)
			{
				if (MenuShortCuts[menu_idx].menu[entree_idx].state == FAIL)
				{
					if (MenuShortCuts[menu_idx].menu[entree_idx].text[0] == '-')	/* ‡a n'est pas raccourcissable */
						continue;

					if (menu_idx != 5 || entree_idx > 3)	/* cas des entr‚es de d‚placement */
						MenuShortCuts[menu_idx].menu[entree_idx].text[MenuShortCuts[menu_idx].offset] = '\0';	/* pas de raccourcis */

					size = MAX(size, (int)strlen(MenuShortCuts[menu_idx].menu[entree_idx].text) +1);
					continue;
				}

				shortcut_key(MenuShortCuts[menu_idx].menu[entree_idx].key, MenuShortCuts[menu_idx].menu[entree_idx].state, key, FALSE);

				strcpy(MenuShortCuts[menu_idx].menu[entree_idx].text + MenuShortCuts[menu_idx].offset, key);

				size = MAX(size, (int)strlen(MenuShortCuts[menu_idx].menu[entree_idx].text) +1);
			}

		size *= gr_cw;
		Menu[title].ob_width = size;

		if (Menu[title].ob_x + Menu[title].ob_width > max_w - 5)
			Menu[title].ob_x = max_w - 5 - Menu[title].ob_width;

		entree_idx = 0;
		for (entree = Menu[title].ob_head; entree != title; entree = Menu[entree].ob_next, entree_idx++)
		{
			Menu[entree].ob_width = size;
			if (Menu[entree].ob_spec.free_string[0] == '-')
			{
				int i;

				for (i=(int)strlen(Menu[entree].ob_spec.free_string); i<size/8; i++)
					Menu[entree].ob_spec.free_string[i] = '-';
				Menu[entree].ob_spec.free_string[size/8] = '\0';
			}
		}
	}
} /* set_shortcuts */

/****************************************************************
*																*
*			Met en place les raccourcis clavier					*
*																*
****************************************************************/
void shortcut_key(int key, int state, char *key_text, boolean fill)
{
	char *ptr = key_text;
	int i;

	if (fill)
	{
		for (i=0; i<SHORTCUT_SIZE-1; i++)
			*ptr++ = ' ';
		*ptr = '\0';
		ptr = key_text;
	}

	if (state == FAIL)
		return;
	
	if (state & K_LSHIFT || state & K_RSHIFT)
		*ptr++ = '';

	if (state & K_CTRL)
		*ptr++ = '^';

	if (state & K_ALT)
		*ptr++ = '';

	if (key < 256)
		*ptr++ = key;
	else
		switch (key >> 8)
		{
			case SCANESC:
				memcpy(ptr, "Esc", 3);
				ptr += 3;
				break;

			case SCANTAB:
				memcpy(ptr, "Tab", 3);
				ptr += 3;
				break;

			case SCANRET:
				memcpy(ptr, "Return", 6);
				ptr += 6;
				break;

			case SCANDEL:
				memcpy(ptr, "Delete", 6);
				ptr += 6;
				break;

			case SCANBS:
				memcpy(ptr, "Backspace", 9);
				ptr += 9;
				break;

			case SCANENTER:
				memcpy(ptr, "Enter", 5);
				ptr += 5;
				break;

			case SCANHELP:
				memcpy(ptr, "Help", 4);
				ptr += 4;
				break;

			case SCANUNDO:
				memcpy(ptr, "Undo", 4);
				ptr += 4;
				break;

			case SCANINS:
				memcpy(ptr, "Insert", 6);
				ptr += 6;
				break;

			case SCANHOME:
				memcpy(ptr, "ClrHome", 7);
				ptr += 7;
				break;

			case SCANUP:
				*ptr++ = '';
				break;

			case SCANDOWN:
				*ptr++ = '';
				break;

			case SCANLEFT:
				*ptr++ = '';
				break;

			case SCANRIGHT:
				*ptr++ = '';
				break;

			case SCANF1:
			case CTRLF1:
				*((int *)ptr)++ = 'F1';
				break;

			case SCANF2:
			case CTRLF2:
				*((int *)ptr)++ = 'F2';
				break;

			case SCANF3:
			case CTRLF3:
				*((int *)ptr)++ = 'F3';
				break;

			case SCANF4:
			case CTRLF4:
				*((int *)ptr)++ = 'F4';
				break;

			case SCANF5:
			case CTRLF5:
				*((int *)ptr)++ = 'F5';
				break;

			case SCANF6:
			case CTRLF6:
				*((int *)ptr)++ = 'F6';
				break;

			case SCANF7:
			case CTRLF7:
				*((int *)ptr)++ = 'F7';
				break;

			case SCANF8:
			case CTRLF8:
				*((int *)ptr)++ = 'F8';
				break;

			case SCANF9:
			case CTRLF9:
				*((int *)ptr)++ = 'F9';
				break;

			case SCANF10:
			case CTRLF10:
				memcpy(ptr, "F10", 3);
				ptr += 3;
				break;
		}

	if (!fill)
		*ptr++ = '\0';
} /* shortcut_key */

/****************************************************************
*																*
*						Appel ST-Guide							*
*																*
****************************************************************/
void aide(void)
{
	int id, msg[8];

	if ((id = AppLoaded("ST-GUIDE")) < 0)
	{
		error_msg(Z_HELP_VIEWER_NOT_LOADED);
		return;
	}

	strcpy(HelpString, "*:\\ZORG.HYP");
	*(char **)&msg[3] = HelpString;
	msg[5] = msg[6] = msg[7] = 0;

	if (!AvSendMsg(id, VA_START, msg))
		error_msg(Z_ERROR_WITH_VIEWER);
} /* aide */

/****************************************************************
*																*
*					boŒte de pr‚sentation						*
*																*
****************************************************************/
void presentation(void)
{
	Dialog[PRESENTATION].proc = presentation_proc;
	my_open_dialog(&Dialog[PRESENTATION], AUTO_DIAL, FAIL);
} /* presentation */

/****************************************************************
*																*
*					boŒte de pr‚sentation (gestion)				*
*																*
****************************************************************/
boolean presentation_proc(t_dialog *dialog, int exit)
{
	switch (exit)
	{
		case PRESENTATION_OK:
			return TRUE;

		case PRESENTATION_INF:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> info -> di_tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> info -> di_tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			my_alert(1, FAIL, X_ICN_INFO, Messages(PRESENTATION_1), NULL);
/*			my_alert(1, FAIL, X_ICN_INFO, Messages(PRESENTATION_2), NULL);
			my_alert(1, FAIL, X_ICN_INFO, Messages(PRESENTATION_3), NULL);
			my_alert(1, FAIL, X_ICN_INFO, Messages(PRESENTATION_4), NULL);*/
	}

	return FALSE;
} /* presentation_proc */
