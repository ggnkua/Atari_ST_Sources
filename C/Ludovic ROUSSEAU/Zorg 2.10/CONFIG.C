/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>

#include "globals.h"
#include "zorg.h"

#include "zorg_inf.h"

#include "config.h"
#include "brut.h"
#include "desk.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "fenetre.h"
#include "init.h"
#include "main.h"
#include "menu.h"
#include "tampon.h"
#include "update.h"

#define ZORG_INF_VERSION	8

/* variables locales */
typedef struct
{
	POPUP popup_gadget;
	POPUP popup_couleur;
	POPUP popup_trame;
	int gadget;
	int couleur;
	int trame;
	struct
	{
		char couleur;
		char trame;
	} choix[9];
		/* 0 : Texte				*/
		/* 1 : Fond					*/
		/* 2 : Curseur				*/
		/* ------------------------ */
		/* 3 : Blocs occupÇs		*/
		/* 4 : Mauvais blocs		*/
		/* 5 : Fichier fragementÇ	*/
		/* 6 : Fichier sÇlÇctionnÇ	*/
		/* 7 : Marqueur de fin		*/
	windowptr thewin;
} couleurs_var;

typedef struct
{
	int menu;
	int entree;
	int key;
	int state;
} raccourcis_var;

typedef struct
{
	char zerochar;
} config_gene_var;

typedef struct
{
	t_raw_floppy_entry rawfloppy[6];
	t_raw_hard_entry rawhard[6];
} config_dsk_var;

#define MAXUNITS 16
typedef struct
{	/* voir The Atari Compendium B.14 */
	WORD puns;
	BYTE pun[MAXUNITS];
	LONG ptr_start[MAXUNITS];
	LONG P_cookie;
	LONG *P_cookptr;
	UWORD P_version;
	UWORD P_max_sector;
	LONG reserved[MAXUNITS];
} pun_ptr;

/********************************************************************
*																	*
*						Choix des couleurs							*
*																	*
********************************************************************/
void couleur(windowptr thewin)
{
	couleurs_var *var = Dialog[COULEURS].var;
	int i;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(couleurs_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[COULEURS].var = var;

		rsrc_gaddr(R_TREE, POPUP_GADGETS, &var -> popup_gadget.p_menu);
		fix_objects(var -> popup_gadget.p_menu, NO_SCALING, 8, 16);
		var -> popup_gadget.p_parent = GADGET;
		var -> popup_gadget.p_button = GADGET_TITLE;
		var -> popup_gadget.p_cycle = GADGET_BUTTON;
		var -> popup_gadget.p_wrap = TRUE;
		var -> popup_gadget.p_set = TRUE;
		var -> popup_gadget.p_func = NULL;

		rsrc_gaddr(R_TREE, POPUP_COULEURS, &var -> popup_couleur.p_menu);
		fix_objects(var -> popup_couleur.p_menu, NO_SCALING, 8, 16);
		var -> popup_couleur.p_parent = COULEUR;
		var -> popup_couleur.p_button = COULEUR_TITLE;
		var -> popup_couleur.p_cycle = COULEUR_BUTTON;
		var -> popup_couleur.p_wrap = TRUE;
		var -> popup_couleur.p_set = FALSE;
		var -> popup_couleur.p_func = NULL;

		rsrc_gaddr(R_TREE, POPUP_TRAMES, &var -> popup_trame.p_menu);
		fix_objects(var -> popup_trame.p_menu, NO_SCALING, 8, 16);
		var -> popup_trame.p_parent = TRAME;
		var -> popup_trame.p_button = TRAME_TITLE;
		var -> popup_trame.p_cycle = TRAME_BUTTON;
		var -> popup_trame.p_wrap = TRUE;
		var -> popup_trame.p_set = FALSE;
		var -> popup_trame.p_func = NULL;
	}

	for (i=0; i<8; i++)
		var -> choix[i].couleur = var -> choix[i].trame = 0;

		/* 0 : Texte				*/
		/* 1 : Fond					*/
		/* 2 : Curseur				*/
		/* ------------------------ */
		/* 3 : Blocs occupÇs		*/
		/* 4 : Mauvais blocs		*/
		/* 5 : Fichier fragementÇ	*/
		/* 6 : Fichier sÇlÇctionnÇ	*/
		/* 7 : Marqueur de fin		*/

	switch (thewin -> type)
	{
		case OCCUP:
			var -> choix[1].couleur = thewin -> fonction.occup.couleur_fond;
			var -> choix[1].trame = thewin -> fonction.occup.trame_fond;

			var -> choix[3].couleur = thewin -> fonction.occup.couleur_blocs;
			var -> choix[3].trame = thewin -> fonction.occup.trame_blocs;

			var -> choix[4].couleur = thewin -> fonction.occup.couleur_bad_blocs;
			var -> choix[4].trame = thewin -> fonction.occup.trame_bad_blocs;

			var -> choix[5].couleur = thewin -> fonction.occup.couleur_fragment;
			var -> choix[5].trame = thewin -> fonction.occup.trame_fragment;

			var -> choix[6].couleur = thewin -> fonction.occup.couleur_selected;
			var -> choix[6].trame = thewin -> fonction.occup.trame_selected;

			var -> choix[7].couleur = thewin -> fonction.occup.couleur_end;
			var -> choix[7].trame = thewin -> fonction.occup.trame_end;

			var -> couleur = var -> choix[3].couleur;
			var -> trame = var -> choix[3].trame;
			var -> gadget = 3;
			break;

		case TAMPON:
		case SECTEUR:
		case FICHIER:
		case RAW_FLOPPY:
		case RAW_HARD:
		case FICHIER_FS:
			var -> choix[2].couleur = thewin -> fonction.secteur.couleur_curseur;
			var -> choix[2].trame = thewin -> fonction.secteur.trame_curseur;
			/* on continue */

		case TEXT:
			var -> choix[0].couleur = thewin -> fonction.text.couleur_texte;

			var -> choix[1].couleur = thewin -> fonction.text.couleur_fond;
			var -> choix[1].trame = thewin -> fonction.text.trame_fond;

			var -> couleur = var -> choix[0].couleur;
			var -> trame = var -> choix[0].trame;
			var -> gadget = 0;
			break;
	}

	Dialog[COULEURS].tree[GADGET_TITLE].ob_spec.tedinfo -> te_ptext = var -> popup_gadget.p_menu[var -> gadget >= 3 ? var -> gadget*2 + 2 : var -> gadget*2 + 1].ob_spec.free_string;
	Dialog[COULEURS].tree[COULEUR_TITLE].ob_spec.obspec.interiorcol = var -> couleur;
	Dialog[COULEURS].tree[TRAME_TITLE].ob_spec.obspec.fillpattern = var -> trame;

	var -> thewin = thewin;

	Dialog[COULEURS].proc = couleur_proc;
	my_open_dialog(&Dialog[COULEURS], AUTO_DIAL, FAIL);
} /* couleur */

/********************************************************************
*																	*
*						Choix des couleurs (gestion)				*
*																	*
********************************************************************/
boolean couleur_proc(t_dialog *dialog, int exit)
{
	couleurs_var *var = dialog -> var;
	int ret, i;

	switch (exit)
	{
		case COULEURS_ANNULER:
			return TRUE;

		case GADGET:
		case GADGET_TITLE:
			var -> choix[var -> gadget].couleur = var -> couleur;
			var -> choix[var -> gadget].trame = var -> trame;

			if (var -> gadget >= 3)
				ret = var -> gadget*2 + 2;
			else
				ret = var -> gadget*2 + 1;
			var -> popup_gadget.p_info = dialog -> info;
			if ((ret = Popup(&var -> popup_gadget, POPUP_BTN_CHK, OBJPOS, 0, 0, NULL, ret)) != 0)
				if (ret >= 8)
					var -> gadget = (ret -2)/2;
				else
					var -> gadget = (ret -1)/2;

			var -> couleur = var -> choix[var -> gadget].couleur;
			var -> trame = var -> choix[var -> gadget].trame;

			dialog -> tree[COULEUR_TITLE].ob_spec.obspec.interiorcol = var -> couleur;
			ob_draw(dialog -> info, COULEUR_TITLE);
			ob_draw(dialog -> info, COULEUR_BUTTON);

			dialog -> tree[TRAME_TITLE].ob_spec.obspec.fillpattern = var -> trame;
			ob_draw(dialog -> info, TRAME_TITLE);
			ob_draw(dialog -> info, TRAME_BUTTON);
			break;

		case GADGET_BUTTON:
			var -> choix[var -> gadget].couleur = var -> couleur;
			var -> choix[var -> gadget].trame = var -> trame;

			if (var -> gadget >= 3)
				var -> gadget = var -> gadget*2 + 2;
			else
				var -> gadget = var -> gadget*2 + 1;
			var -> popup_gadget.p_info = dialog -> info;
			Popup(&var -> popup_gadget, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> gadget, var -> gadget);

			var -> couleur = var -> choix[var -> gadget].couleur;
			var -> trame = var -> choix[var -> gadget].trame;

			dialog -> tree[COULEUR_TITLE].ob_spec.obspec.interiorcol = var -> couleur;
			ob_draw(dialog -> info, COULEUR_TITLE);
			ob_draw(dialog -> info, COULEUR_BUTTON);

			dialog -> tree[TRAME_TITLE].ob_spec.obspec.fillpattern = var -> trame;
			ob_draw(dialog -> info, TRAME_TITLE);
			ob_draw(dialog -> info, TRAME_BUTTON);
			break;

		case COULEUR:
		case COULEUR_TITLE:
			var -> popup_couleur.p_info = dialog -> info;
			Popup(&var -> popup_couleur, POPUP_BTN_CHK, OBJPOS, 0, 0, &var -> couleur, var -> couleur *2 +1);
			dialog -> tree[COULEUR_TITLE].ob_spec.obspec.interiorcol = var -> couleur;
			ob_draw(dialog -> info, COULEUR_TITLE);
			ob_draw(dialog -> info, COULEUR_BUTTON);
			break;

		case COULEUR_BUTTON:
			var -> popup_couleur.p_info = dialog -> info;
			Popup(&var -> popup_couleur, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> couleur, var -> couleur *2 +1);
			var -> couleur++;
			dialog -> tree[COULEUR_TITLE].ob_spec.obspec.interiorcol = var -> couleur;
			ob_draw(dialog -> info, COULEUR_TITLE);
			ob_draw(dialog -> info, COULEUR_BUTTON);
			break;

		case TRAME:
		case TRAME_TITLE:
			var -> popup_trame.p_info = dialog -> info;
			Popup(&var -> popup_trame, POPUP_BTN, OBJPOS, 0, 0, &var -> trame, var -> trame+1);
			dialog -> tree[TRAME_TITLE].ob_spec.obspec.fillpattern = var -> trame;
			ob_draw(dialog -> info, TRAME_TITLE);
			ob_draw(dialog -> info, TRAME_BUTTON);
			break;

		case TRAME_BUTTON:
			var -> popup_trame.p_info = dialog -> info;
			Popup(&var -> popup_trame, POPUP_CYCLE, OBJPOS, 0, 0, &var -> trame, var -> trame+1);
			dialog -> tree[TRAME_TITLE].ob_spec.obspec.fillpattern = var -> trame;
			ob_draw(dialog -> info, TRAME_TITLE);
			ob_draw(dialog -> info, TRAME_BUTTON);
			break;

		case COULEURS_APPLIQU:
		case COULEURS_OK:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			var -> choix[var -> gadget].couleur = var -> couleur;
			var -> choix[var -> gadget].trame = var -> trame;

			if (var -> thewin -> type >= TEXT)
			{
				/* Texte */
				var -> thewin -> fonction.text.couleur_texte = var -> choix[0].couleur;
				vst_color(var -> thewin -> win -> vdi_handle, var -> choix[0].couleur);

				/* Fond */
				var -> thewin -> fonction.text.couleur_fond = var -> choix[1].couleur;
				var -> thewin -> fonction.text.trame_fond = var -> choix[1].trame;

				for (i=0; i<WinEntrees; i++)
					if (Windows[i].fenetre == var -> thewin)
					{
						Windows[i].fonction.texte.texte_c = var -> choix[0].couleur;

						Windows[i].fonction.texte.background_c = var -> choix[1].couleur;
						Windows[i].fonction.texte.background_t = var -> choix[1].trame;
						break;
					}

				if (DialogInWindow && exit != COULEURS_OK)
					redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
				else
					if (exit != COULEURS_OK)
					{
						close_dialog(dialog -> info, FALSE);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
						dialog -> info = open_dialog(dialog -> tree, NULL, NULL, NULL, DIA_LASTPOS, FALSE, FLY_DIAL|SMART_FRAME, FAIL, NULL, NULL);
					}
					else
					{
						my_close_dialog(dialog);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
					}
			}

			if (var -> thewin -> type >= TAMPON)
			{
				/* Curseur */
				var -> thewin -> fonction.secteur.couleur_curseur = var -> choix[2].couleur;
				var -> thewin -> fonction.secteur.trame_curseur = var -> choix[2].trame;

				for (i=0; i<WinEntrees; i++)
					if (Windows[i].fenetre == var -> thewin)
					{
						Windows[i].fonction.texte.curseur_c = var -> choix[2].couleur;
						Windows[i].fonction.texte.curseur_t = var -> choix[2].trame;
						break;
					}

				if (DialogInWindow && exit != COULEURS_OK)
					redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
				else
					if (exit != COULEURS_OK)
					{
						close_dialog(dialog -> info, FALSE);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
						dialog -> info = open_dialog(dialog -> tree, NULL, NULL, NULL, DIA_LASTPOS, FALSE, FLY_DIAL|SMART_FRAME, FAIL, NULL, NULL);
					}
					else
					{
						my_close_dialog(dialog);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
					}
			}

			if (var -> thewin -> type == OCCUP)
			{
				/* Fond */
				var -> thewin -> fonction.occup.couleur_fond = var -> choix[1].couleur;
				var -> thewin -> fonction.occup.trame_fond = var -> choix[1].trame;

				/* Blocs occupÇs */
				var -> thewin -> fonction.occup.couleur_blocs = var -> choix[3].couleur;
				var -> thewin -> fonction.occup.trame_blocs = var -> choix[3].trame;

				/* Mauvais blocs */
				var -> thewin -> fonction.occup.couleur_bad_blocs = var -> choix[4].couleur;
				var -> thewin -> fonction.occup.trame_bad_blocs = var -> choix[4].trame;

				/* fichier fragmentÇ */
				var -> thewin -> fonction.occup.couleur_fragment = var -> choix[5].couleur;
				var -> thewin -> fonction.occup.trame_fragment = var -> choix[5].trame;

				/* fichier selectionnÇ */
				var -> thewin -> fonction.occup.couleur_selected = var -> choix[6].couleur;
				var -> thewin -> fonction.occup.trame_selected = var -> choix[6].trame;

				/* Marqueur de fin */
				var -> thewin -> fonction.occup.couleur_end = var -> choix[7].couleur;
				var -> thewin -> fonction.occup.trame_end = var -> choix[7].trame;

				for (i=0; i<WinEntrees; i++)
					if (Windows[i].fenetre == var -> thewin)
					{
						Windows[i].fonction.occup.background_c = var -> choix[1].couleur;
						Windows[i].fonction.occup.background_t = var -> choix[1].trame;

						Windows[i].fonction.occup.blocs_c = var -> choix[3].couleur;
						Windows[i].fonction.occup.blocs_t = var -> choix[3].trame;

						Windows[i].fonction.occup.bad_blocs_c = var -> choix[4].couleur;
						Windows[i].fonction.occup.bad_blocs_t = var -> choix[4].trame;

						Windows[i].fonction.occup.fragmented_c = var -> choix[5].couleur;
						Windows[i].fonction.occup.fragmented_t = var -> choix[5].trame;

						Windows[i].fonction.occup.selected_c = var -> choix[6].couleur;
						Windows[i].fonction.occup.selected_t = var -> choix[6].trame;

						Windows[i].fonction.occup.end_marq_c = var -> choix[7].couleur;
						Windows[i].fonction.occup.end_marq_t = var -> choix[7].trame;
						break;
					}

				if (DialogInWindow && exit != COULEURS_OK)
					redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
				else
					if (exit != COULEURS_OK)
					{
						close_dialog(dialog -> info, FALSE);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
						dialog -> info = open_dialog(dialog -> tree, NULL, NULL, NULL, DIA_LASTPOS, FALSE, FLY_DIAL|SMART_FRAME, FAIL, NULL, NULL);
					}
					else
					{
						my_close_dialog(dialog);
						redraw_window(var -> thewin -> win, &var -> thewin -> win -> work);
					}
			}
			break;
	}

	if (exit == COULEURS_OK)
		return TRUE;
	else
		return FALSE;
} /* couleur_proc */

/********************************************************************
*																	*
*				Configuration des raccourcis clavier				*
*																	*
********************************************************************/
void raccourcis_clavier(void)
{
	raccourcis_var *var = Dialog[CONFIG_MENU].var;
	int title, entree;
	int old_conf;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(raccourcis_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[CONFIG_MENU].var = var;

		var -> menu = 0;
		var -> entree = 0;
		var -> key = MenuShortCuts[0].menu[0].key;
		var -> state = MenuShortCuts[0].menu[0].state;

		for (title=0; title<NbMenus; title++)
			for (entree=0; entree<MenuShortCuts[title].nb_entrees; entree++)
			{
				MenuShortCuts[title].menu[entree].new_state = MenuShortCuts[title].menu[entree].state;
				MenuShortCuts[title].menu[entree].new_key = MenuShortCuts[title].menu[entree].key;
			}

		Dialog[CONFIG_MENU].tree[MENU_TITLE].ob_spec.tedinfo -> te_ptext = PopUpMenuText;
		Dialog[CONFIG_MENU].tree[MENU_ENTREE].ob_spec.tedinfo -> te_ptext = PopUpEntryText[0];
		shortcut_key(var -> key, var -> state, Dialog[CONFIG_MENU].tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
	}

	old_conf = DialogInWindow;
	DialogInWindow = TRUE;
	Dialog[CONFIG_MENU].proc = raccourcis_proc;
	my_open_dialog(&Dialog[CONFIG_MENU], AUTO_DIAL, FAIL);
	DialogInWindow = old_conf;
} /* raccourcis_clavier */

/********************************************************************
*																	*
*			Configuration des raccourcis clavier (proc)				*
*																	*
********************************************************************/
boolean raccourcis_proc(t_dialog *dialog, int exit)
{
	raccourcis_var *var = dialog -> var;
	int key;
	int title, entree;

	switch(exit)
	{
		case MENU_ANNULER:
			return TRUE;

		case TITLE:
		case MENU_TITLE:
			PopUpMenu.p_info = dialog -> info;
			Popup(&PopUpMenu, POPUP_BTN_CHK, OBJPOS, 0, 0, &var -> menu, var -> menu +1);

			var -> entree = 0;
			while (ob_isstate(PopUpEntryTree[var -> menu], var -> entree+1, DISABLED))
				var -> entree++;

			dialog -> tree[MENU_ENTREE].ob_spec.tedinfo -> te_ptext = PopUpEntryTree[var ->menu][var -> entree +1].ob_spec.free_string;

			ob_draw(dialog -> info, MENU_ENTREE);
			ob_draw(dialog -> info, ENTREE_BUTTON);

			var -> state = MenuShortCuts[var -> menu].menu[var -> entree].new_state;
			var -> key = MenuShortCuts[var -> menu].menu[var -> entree].new_key;
			shortcut_key(var -> key, var -> state, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
			ob_draw(dialog -> info, SHORT_CUT);
			break;

		case TITLE_BUTTON:
			PopUpMenu.p_info = dialog -> info;
			Popup(&PopUpMenu, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> menu, var -> menu +1);

			var -> entree = 0;
			while (ob_isstate(PopUpEntryTree[var -> menu], var -> entree+1, DISABLED))
				var -> entree++;

			dialog -> tree[MENU_ENTREE].ob_spec.tedinfo -> te_ptext = PopUpEntryTree[var ->menu][var -> entree +1].ob_spec.free_string;

			ob_draw(dialog -> info, MENU_ENTREE);
			ob_draw(dialog -> info, ENTREE_BUTTON);

			var -> state = MenuShortCuts[var -> menu].menu[var -> entree].new_state;
			var -> key = MenuShortCuts[var -> menu].menu[var -> entree].new_key;
			shortcut_key(var -> key, var -> state, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
			ob_draw(dialog -> info, SHORT_CUT);
			break;

		case ENTREE:
		case MENU_ENTREE:
			PopUpEntry[var -> menu].p_info = dialog -> info;
			Popup(&PopUpEntry[var -> menu], POPUP_BTN_CHK, OBJPOS, 0, 0, &var -> entree, var -> entree +1);

			var -> state = MenuShortCuts[var -> menu].menu[var -> entree].new_state;
			var -> key = MenuShortCuts[var -> menu].menu[var -> entree].new_key;
			shortcut_key(var -> key, var -> state, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
			ob_draw(dialog -> info, SHORT_CUT);
			break;

		case ENTREE_BUTTON:
			PopUpEntry[var -> menu].p_info = dialog -> info;
			Popup(&PopUpEntry[var -> menu], POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> entree, var -> entree +1);

			var -> state = MenuShortCuts[var -> menu].menu[var -> entree].new_state;
			var -> key = MenuShortCuts[var -> menu].menu[var -> entree].new_key;
			shortcut_key(var -> key, var -> state, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
			ob_draw(dialog -> info, SHORT_CUT);
			break;

		case FAIL:
			key = scantoascii(var -> key);
			if (key == 0)
				key = var -> key & 0xFF00;	/* scan code */
			else
				key = UpperChar(key);

			if (key == ' ')	/* annule le raccourcis */
			{
				var -> state = FAIL;
				MenuShortCuts[var -> menu].menu[var -> entree].new_state = FAIL;

				shortcut_key(' ', 0, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);
				ob_draw(dialog -> info, SHORT_CUT);

				break;
			}

			for (title=0; title<NbMenus; title++)
				for (entree=0; entree<MenuShortCuts[title].nb_entrees; entree++)
					if (MenuShortCuts[title].menu[entree].new_state == var -> state && MenuShortCuts[title].menu[entree].new_key == key && (title != var -> menu || entree != var -> entree))
						if (my_alert(1, FAIL, X_ICN_QUESTION, Messages(CONFIG_7), Messages(BOOT_32)) == 1)
							goto hop;	/* on garde l'ancien */
						else
							MenuShortCuts[title].menu[entree].new_state = FAIL;

			shortcut_key(key, var -> state, dialog -> tree[SHORT_CUT].ob_spec.tedinfo -> te_ptext, TRUE);

			MenuShortCuts[var -> menu].menu[var -> entree].new_state = var -> state;
			MenuShortCuts[var -> menu].menu[var -> entree].new_key = key;
			ob_draw(dialog -> info, SHORT_CUT);
hop:
			break;

		case MENU_APPLIQUER:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			SaveConfig = TRUE;

			for (title=0; title<NbMenus; title++)
				for (entree=0; entree<MenuShortCuts[title].nb_entrees; entree++)
				{
					MenuShortCuts[title].menu[entree].state = MenuShortCuts[title].menu[entree].new_state;
					MenuShortCuts[title].menu[entree].key = MenuShortCuts[title].menu[entree].new_key;
				}

			set_shortcuts();
			break;;

		case MENU_OK:
			SaveConfig = TRUE;

			for (title=0; title<NbMenus; title++)
				for (entree=0; entree<MenuShortCuts[title].nb_entrees; entree++)
				{
					MenuShortCuts[title].menu[entree].state = MenuShortCuts[title].menu[entree].new_state;
					MenuShortCuts[title].menu[entree].key = MenuShortCuts[title].menu[entree].new_key;
				}

			set_shortcuts();
			return TRUE;
	}

	return FALSE;
} /* raccourcis_proc */

/********************************************************************
*																	*
*			affiche la configuration Ö mettre dans ZORG.INF			*
*																	*
********************************************************************/
void config_generale(void)
{
	config_gene_var *var = Dialog[CONFIG_GENE_DIAL].var;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(config_gene_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[CONFIG_GENE_DIAL].var = var;

		var -> zerochar = ZeroChar;
	}

	Dialog[CONFIG_GENE_DIAL].proc = config_generale_proc;
	my_open_dialog(&Dialog[CONFIG_GENE_DIAL], AUTO_DIAL, FAIL);
} /* config_generale */

/********************************************************************
*																	*
*		affiche la configuration Ö mettre dans ZORG.INF (gestion)	*
*																	*
********************************************************************/
boolean config_generale_proc(t_dialog *dialog, int exit)
{
	config_gene_var *var = dialog -> var;

	switch(exit)
	{
		case CONFIG_GENE_ANNU:
			return TRUE;

		case CARACTERE_NUL:
			var -> zerochar = m_ascii_box(var -> zerochar, TRUE);
			dialog -> tree[CARACTERE_NUL].ob_spec.obspec.character = var -> zerochar;
			ob_undostate(dialog -> tree, exit, SELECTED);
			ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			break;

		case CONFIG_GENE_APPL:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			BlocSize = atoi(dialog -> tree[TAILLE_BLOC].ob_spec.tedinfo -> te_ptext);
			ScrollTimer = atoi(dialog -> tree[TEMPS_LATENCE].ob_spec.tedinfo -> te_ptext);
			SavePos = ob_isstate(dialog -> tree, SAVE_CUR_POS, SELECTED);
			Sound = ob_isstate(dialog -> tree, SOUND, SELECTED);
			DialogInWindow = ob_isstate(dialog -> tree, DIALOG_IN_WINDOW, SELECTED);
			MultiWarning = ob_isstate(dialog -> tree, MULTI_WARNING, SELECTED);

			if (ZeroChar != var -> zerochar)
			{
				windowptr thewin;

				ZeroChar = var -> zerochar;

				/* redessine les fenàtres concernÇes */
				for (thewin = Firstwindow; thewin; thewin = thewin -> next)
					if (thewin -> type >= TAMPON)
					{
						convert_sect(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

						redraw_window(thewin -> win, &thewin -> win -> work);
					}
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			break;

		case CONFIG_GENE_SAUV:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			BlocSize = atoi(dialog -> tree[TAILLE_BLOC].ob_spec.tedinfo -> te_ptext);
			ScrollTimer = atoi(dialog -> tree[TEMPS_LATENCE].ob_spec.tedinfo -> te_ptext);
			SavePos = ob_isstate(dialog -> tree, SAVE_CUR_POS, SELECTED);
			ResetFlag = ob_isstate(dialog -> tree, RESET_FLAG, SELECTED);
			Tos40xBug = ob_isstate(dialog -> tree, TOS_40X_BUG, SELECTED);
			Sound = ob_isstate(dialog -> tree, SOUND, SELECTED);
			DialogInWindow = ob_isstate(dialog -> tree, DIALOG_IN_WINDOW, SELECTED);
			MultiWarning = ob_isstate(dialog -> tree, MULTI_WARNING, SELECTED);

			if (ZeroChar != var -> zerochar)
			{
				windowptr thewin;

				ZeroChar = var -> zerochar;

				/* redessine les fenàtres concernÇes */
				for (thewin = Firstwindow; thewin; thewin = thewin -> next)
					if (thewin -> type >= TAMPON)
					{
						convert_sect(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

						redraw_window(thewin -> win, &thewin -> win -> work);
					}
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			save_config();

			SaveConfig = FALSE;
			return TRUE;

		case CONFIG_GENE_OK:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			my_close_dialog(dialog);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			BlocSize = atoi(dialog -> tree[TAILLE_BLOC].ob_spec.tedinfo -> te_ptext);
			ScrollTimer = atoi(dialog -> tree[TEMPS_LATENCE].ob_spec.tedinfo -> te_ptext);
			SavePos = ob_isstate(dialog -> tree, SAVE_CUR_POS, SELECTED);
			ResetFlag = ob_isstate(dialog -> tree, RESET_FLAG, SELECTED);
			Tos40xBug = ob_isstate(dialog -> tree, TOS_40X_BUG, SELECTED);
			Sound = ob_isstate(dialog -> tree, SOUND, SELECTED);
			DialogInWindow = ob_isstate(dialog -> tree, DIALOG_IN_WINDOW, SELECTED);

			if (ZeroChar != var -> zerochar)
			{
				windowptr thewin;

				ZeroChar = var -> zerochar;

				/* redessine les fenàtres concernÇes */
				for (thewin = Firstwindow; thewin; thewin = thewin -> next)
					if (thewin -> type >= TAMPON)
					{
						convert_sect(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

						redraw_window(thewin -> win, &thewin -> win -> work);
					}
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			SaveConfig = TRUE;

			return TRUE;
	}

	return FALSE;
} /* config_generale_proc */

/********************************************************************
*																	*
*			affiche la configuration Ö mettre dans ZORG.INF			*
*																	*
********************************************************************/
void config_disques(void)
{
	config_dsk_var *var = Dialog[CONFIG_DSK_DIAL].var;
	int i;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(config_dsk_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[CONFIG_DSK_DIAL].var = var;

		/* copie dans des variables temporaires */
		for (i=0; i<6; i++)
		{
			var -> rawfloppy[i] = RawFloppy[i];
			var -> rawhard[i] = RawHard[i];
		}
	}

	Dialog[CONFIG_DSK_DIAL].proc = config_disques_proc;
	my_open_dialog(&Dialog[CONFIG_DSK_DIAL], AUTO_DIAL, FAIL);
} /* config_disques */

/********************************************************************
*																	*
*		affiche la configuration Ö mettre dans ZORG.INF (gestion)	*
*																	*
********************************************************************/
boolean config_disques_proc(t_dialog *dialog, int exit)
{
	config_dsk_var *var = dialog -> var;
	int i;
	long stack;
	pun_ptr	*pun;

	switch(exit)
	{
		case CONFIG_DSK_ANNUL:
			for (i=0; i<6; i++)
			{
				RawFloppy[i] = var -> rawfloppy[i];
				RawHard[i] = var -> rawhard[i];
			}
			return TRUE;

		case CONFIG_DISQUES:
			stack = Super(0);
			pun = *(pun_ptr **)0x516;

			for (i=2; i<MAX_DEVICES; i++)
				if (pun -> pun[i] != 0xFF)
				{
					Partition[i].start = pun -> ptr_start[i];
					Partition[i].devno = pun -> pun[i];
				}
				else
				{
					Partition[i].start = 0;
					Partition[i].devno = FAIL;
				}

			Super((void *)stack);

			for (i=2; i<MAX_DEVICES; i++)
				if (Partition[i].devno >= 0)
				{
					Partition[i].bpb = my_getbpb(i);
					Partition[i].size = Partition[i].bpb.datrec + Partition[i].bpb.numcl * Partition[i].bpb.clsiz;
				}

			SaveConfig = TRUE;

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;

		case CONF_RAW_FLOPPY:
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			raw_floppy(TRUE);
			break;

		case CONF_RAW_HARD:
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			raw_hard(TRUE);
			break;

		case CONFIG_DSK_SAUVE:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			ResetFlag = ob_isstate(dialog -> tree, RESET_FLAG, SELECTED);
			Tos40xBug = ob_isstate(dialog -> tree, TOS_40X_BUG, SELECTED);
			KeepStructure = ob_isstate(dialog -> tree, KEEP_CACHE, SELECTED);
			{
				boolean tmp;

				tmp = ob_isstate(dialog -> tree, MANAGE_VFAT, SELECTED);
				if (tmp != ManageVFAT)
				{
					int i;

					for (i=0; i<MAX_DEVICES; i++)
						change_disque(i, TRUE);

					ManageVFAT = tmp;
				}
			}

			save_config();

			SaveConfig = FALSE;
			return TRUE;

		case CONFIG_DSK_OK:
			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			my_close_dialog(dialog);

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			ResetFlag = ob_isstate(dialog -> tree, RESET_FLAG, SELECTED);
			Tos40xBug = ob_isstate(dialog -> tree, TOS_40X_BUG, SELECTED);
			KeepStructure = ob_isstate(dialog -> tree, KEEP_CACHE, SELECTED);
			{
				boolean tmp;

				tmp = ob_isstate(dialog -> tree, MANAGE_VFAT, SELECTED);
				if (tmp != ManageVFAT)
				{
					int i;

					for (i=0; i<MAX_DEVICES; i++)
						change_disque(i, TRUE);

					ManageVFAT = tmp;
				}
			}

			SaveConfig = TRUE;

			return TRUE;
	}

	return FALSE;
} /* config_disques_proc */

/********************************************************************
*																	*
*				lit le fichier de configuration						*
*																	*
********************************************************************/
boolean read_config(void)
{
	int fd, i, choix, device;
	raccourcis_var raccourcis;

	/* on met Ö zÇro les entrÇes BPB */
	for (i=0; i<MAX_DEVICES; i++)
	{
		Bpb[i].recsiz = 0;
		Bpb[i].clsiz = 0;
		Bpb[i].clsizb = 0;
		Bpb[i].rdlen = 0;
		Bpb[i].fsiz = 0;
		Bpb[i].fatrec = 0;
		Bpb[i].datrec = 0;
		Bpb[i].numcl = 0;
		Bpb[i].bflags = 0;
	}

	/* on met aussi Ö zÇro les entrÇes de description des partitions */
	for (i=0; i<MAX_DEVICES; i++)
	{
		Partition[i].start = 0;
		Partition[i].size = 0;
		Partition[i].devno = FAIL;	/* trÇs important, rend la dÇfinition impropre */

		Partition[i].bpb.recsiz = 0;
		Partition[i].bpb.clsiz = 0;
		Partition[i].bpb.clsizb = 0;
		Partition[i].bpb.rdlen = 0;
		Partition[i].bpb.fsiz = 0;
		Partition[i].bpb.fatrec = 0;
		Partition[i].bpb.datrec = 0;
		Partition[i].bpb.numcl = 0;
		Partition[i].bpb.bflags = 0;
	}

	/* trouve le fichier avec le chemin complet */
	shel_find(ConfigFileName);

	if ((fd = (int)Fopen(ConfigFileName, FO_READ)) < 0)
		my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_1), NULL);
	else
	{
		Fread(fd, sizeof(int), &choix);
		if (choix != ZORG_VERSION)
		{
			my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_4), NULL);
			Fclose(fd);	/* on ferme pour ne plus le lire */
		}
		else
		{
			Fread(fd, sizeof(int), &choix);
			if (choix != ZORG_INF_VERSION)
			{
				my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_5), NULL);
				Fclose(fd);
			}
		}

		while (Fread(fd, sizeof(int), &choix) > 0)
			switch (choix)
			{
				case WIN_DEF:
					/* taille des caractäres */
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);

					if (choix != gr_ch)
					{
						Fclose(fd);
						continue;
					}

					/* taille de l'Çcran */
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);

					if (choix != desk.g_w)
					{
						Fclose(fd);
						continue;
					}

					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);

					if (choix != desk.g_h)
					{
						Fclose(fd);
						continue;
					}

					if (Fread(fd, sizeof(int), &WinEntrees) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);

					if ((Windows = calloc(WinEntrees, sizeof(*Windows))) == NULL)
						return TRUE;

					if (Fread(fd, WinEntrees * sizeof(*Windows), Windows) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);

					for (i=0; i<WinEntrees; i++)
						Windows[i].fenetre = NULL;
					break;

				case CARACTERE_ZERO_DEF:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ZeroChar = choix;
					break;

				case FLOPPY_RAW:
					if (Fread(fd, sizeof(t_raw_floppy_entry)*6, RawFloppy) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					break;

				case HARD_RAW:
					if (Fread(fd, sizeof(t_raw_hard_entry)*6, RawHard) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					break;

				case ZORG_INF:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ZorgInf = choix;
					break;

				case CLEAR_SCREEN:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ClearScreen = choix;
					break;

				case FLUSH_CACHE:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					FlushCache = choix;
					break;

				case MAKE_PAUSE:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					MakePause = choix;
					break;

				case BLOC_SIZE:
					if (Fread(fd, sizeof(int), &BlocSize) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					break;

				case TOS_40x_BUG:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					Tos40xBug = choix;
					break;

				case SOUND_FLAG:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					Sound = choix;
					break;

				case SAVE_POS:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					SavePos = choix;
					break;

				case SCROLL_TIMER:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ScrollTimer = choix;
					break;

				case RESET_FLAG_INF:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ResetFlag = choix;
					break;

				case SHORTCUTS:
					if (Fread(fd, sizeof(raccourcis_var), &raccourcis) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					MenuShortCuts[raccourcis.menu].menu[raccourcis.entree].key = raccourcis.key;
					MenuShortCuts[raccourcis.menu].menu[raccourcis.entree].state = raccourcis.state;
					break;

				case DEVICE:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					if (Fread(fd, sizeof(t_partition), &Partition[choix]) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					break;

				case DIALOG_WINDOW:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					DialogInWindow = choix;
					break;

				case MULTI_WARNING_FLAG:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					MultiWarning = choix;
					break;

				case KEEP_STRUCTURE:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					KeepStructure = choix;
					break;

				case MANAGE_VFAT_OPT:
					if (Fread(fd, sizeof(int), &choix) < 0)
						my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_3), NULL);
					ManageVFAT = choix;
					break;

				default:
					my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_4), NULL);
					Fclose(fd);	/* on ferme pour ne plus le lire */
			}

		Fclose(fd);
	}

	/* Mise en place des choix par dÇfaut */

	/* check l'entrÇe de menu */
	menu_icheck(Menu, ZorgInf ? DONNEES_ZORG : DONNEES_SYSTEME, 1);

	/* boåte de configuration */
	Dialog[CONFIG_GENE_DIAL].tree[CARACTERE_NUL].ob_spec.obspec.character = ZeroChar;

	if (SavePos)
		ob_dostate(Dialog[CONFIG_GENE_DIAL].tree, SAVE_CUR_POS, SELECTED);

	if (Sound)
		ob_dostate(Dialog[CONFIG_GENE_DIAL].tree, SOUND, SELECTED);

	if (DialogInWindow)
		ob_dostate(Dialog[CONFIG_GENE_DIAL].tree, DIALOG_IN_WINDOW, SELECTED);

	if (MultiWarning)
		ob_dostate(Dialog[CONFIG_GENE_DIAL].tree, MULTI_WARNING, SELECTED);

	if (ResetFlag)
		ob_dostate(Dialog[CONFIG_DSK_DIAL].tree, RESET_FLAG, SELECTED);

	if (Tos40xBug)
		ob_dostate(Dialog[CONFIG_DSK_DIAL].tree, TOS_40X_BUG, SELECTED);

	if (KeepStructure)
		ob_dostate(Dialog[CONFIG_DSK_DIAL].tree, KEEP_CACHE, SELECTED);

	if (ManageVFAT)
		ob_dostate(Dialog[CONFIG_DSK_DIAL].tree, MANAGE_VFAT, SELECTED);

	sprintf(Dialog[CONFIG_GENE_DIAL].tree[TAILLE_BLOC].ob_spec.tedinfo -> te_ptext, "%d", BlocSize);

	sprintf(Dialog[CONFIG_GENE_DIAL].tree[TEMPS_LATENCE].ob_spec.tedinfo -> te_ptext, "%d", ScrollTimer);

	/* boåte de lancement de programmes */
	if (ClearScreen)
		ob_dostate(Dialog[LANCE_PRG].tree, EFFACER_ECRAN, SELECTED);

	if (FlushCache)
		ob_dostate(Dialog[LANCE_PRG].tree, VIDE_CACHE, SELECTED);

	if (MakePause)
		ob_dostate(Dialog[LANCE_PRG].tree, PAUSE, SELECTED);

	Dialog[LANCE_PRG].tree[PROGRAM_NAME].ob_spec.tedinfo -> te_ptext[0] = '\0';
	Dialog[LANCE_PRG].tree[COMMAND_LINE].ob_spec.tedinfo -> te_ptext[0] = '\0';

	/* les choix par dÇfaut correspondant au permier bouton */
	if (RawFloppy[0].secteurs == 10)
		ob_dostate(Dialog[RAW_DISQUETTE].tree, SECTEURS_10, SELECTED);
	else
		if (RawFloppy[0].secteurs == 20)
			ob_dostate(Dialog[RAW_DISQUETTE].tree, SECTEURS_20, SELECTED);
		else
		{
			sprintf(Dialog[RAW_DISQUETTE].tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext, "%d", RawFloppy[0].secteurs);
			ob_dostate(Dialog[RAW_DISQUETTE].tree, SECTEURS_COUNT, SELECTED);
		}

	if (RawFloppy[0].pistes == 80)
		ob_dostate(Dialog[RAW_DISQUETTE].tree, PISTES_80, SELECTED);
	else
		if (RawFloppy[0].pistes == 82)
			ob_dostate(Dialog[RAW_DISQUETTE].tree, PISTES_82, SELECTED);
		else
		{
			sprintf(Dialog[RAW_DISQUETTE].tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext, "%d", RawFloppy[0].pistes);
			ob_dostate(Dialog[RAW_DISQUETTE].tree, PISTES_COUNT, SELECTED);
		}

	if (RawFloppy[0].faces > 1)
		ob_dostate(Dialog[RAW_DISQUETTE].tree, DOUBLE_FACE, SELECTED);
	else
		ob_dostate(Dialog[RAW_DISQUETTE].tree, SIMPLE_FACE, SELECTED);

	if (RawFloppy[0].device == 'B')
		ob_dostate(Dialog[RAW_DISQUETTE].tree, LECTEUR_B, SELECTED);
	else
		ob_dostate(Dialog[RAW_DISQUETTE].tree, LECTEUR_A, SELECTED);

	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO1].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[0].bouton);
	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO2].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[1].bouton);
	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO3].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[2].bouton);
	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO4].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[3].bouton);
	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO5].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[4].bouton);
	sprintf(Dialog[RAW_DISQUETTE].tree[DISQUETTE_PERSO6].ob_spec.tedinfo -> te_ptext, "%s", RawFloppy[5].bouton);

	/* affiche la config par dÇfaut */
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext, "%ld", RawHard[0].size);

	device = RawHard[0].device;
	if (device >= 24)
	{
		device -= 24;
		Dialog[RAW_DISQUE_DUR].tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[7].ob_spec.free_string;
	}
	else
		if (device >= 16)
		{
			device -= 16;
			Dialog[RAW_DISQUE_DUR].tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[5].ob_spec.free_string;
		}
		else
			if (device >= 8)
			{
				device -= 8;
				Dialog[RAW_DISQUE_DUR].tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[3].ob_spec.free_string;
			}
			else
				Dialog[RAW_DISQUE_DUR].tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[1].ob_spec.free_string;

	Dialog[RAW_DISQUE_DUR].tree[HD_UNIT].ob_spec.tedinfo -> te_ptext = PopUpUnit.p_menu[device*2 +1].ob_spec.free_string;

	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO1].ob_spec.tedinfo -> te_ptext, "%s", RawHard[0].bouton);
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO2].ob_spec.tedinfo -> te_ptext, "%s", RawHard[1].bouton);
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO3].ob_spec.tedinfo -> te_ptext, "%s", RawHard[2].bouton);
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO4].ob_spec.tedinfo -> te_ptext, "%s", RawHard[3].bouton);
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO5].ob_spec.tedinfo -> te_ptext, "%s", RawHard[4].bouton);
	sprintf(Dialog[RAW_DISQUE_DUR].tree[HD_PERSO6].ob_spec.tedinfo -> te_ptext, "%s", RawHard[5].bouton);

	set_shortcuts();

	/* positions des fenàtres */
	if (WinEntrees == 0)
	{
		WinEntrees = 16;

		if ((Windows = calloc(WinEntrees, sizeof(*Windows))) == NULL)
			return TRUE;

		/* premiäre fenàtre */
		Windows[0].box = desk;
		Windows[0].box.g_y += Windows[0].box.g_h / 4;
		Windows[0].box.g_h = Windows[0].box.g_h - Windows[0].box.g_h / 4;
		Windows[0].type = SIZER | MOVER | FULLER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE;
		Windows[0].fenetre = NULL;

		Windows[0].fonction.texte.texte_c = BLACK;
		Windows[0].fonction.texte.texte_pt = gr_ch == 8 ? 9 : 10;
		Windows[0].fonction.texte.curseur_c = Windows[0].fonction.texte.curseur_t = 0;
		Windows[0].fonction.texte.background_c = WHITE;
		Windows[0].fonction.texte.background_t = 0;

		/* tampon */
		Windows[1].box.g_x = desk.g_x;
		Windows[1].box.g_y = desk.g_y;
		Windows[1].box.g_w = 70*gr_cw + 1;
		Windows[1].box.g_h = gr_ch*19 +1;
		window_calc(WC_BORDER, MOVER | FULLER | CLOSER | NAME, &Windows[1].box, &Windows[1].box);
		Windows[1].type = MOVER | FULLER | CLOSER | NAME;
		Windows[1].fenetre = NULL;

		Windows[1].fonction.texte.texte_c = BLACK;
		Windows[1].fonction.texte.texte_pt = gr_ch == 8 ? 9 : 10;
		Windows[1].fonction.texte.curseur_c = BLACK;
		Windows[1].fonction.texte.curseur_t = 0;
		Windows[1].fonction.texte.background_c = WHITE;
		Windows[1].fonction.texte.background_t = 0;

		/* occupation */
		Windows[2].box = desk;
		Windows[2].type = SIZER | MOVER | FULLER | CLOSER | NAME;
		Windows[2].fenetre = NULL;

		Windows[2].fonction.occup.background_c = WHITE;
		Windows[2].fonction.occup.background_t = 0;

		Windows[2].fonction.occup.blocs_c = BLACK;
		Windows[2].fonction.occup.blocs_t = 7;

		Windows[2].fonction.occup.bad_blocs_c = RED;
		Windows[2].fonction.occup.bad_blocs_t = 7;

		Windows[2].fonction.occup.fragmented_c = BLACK;
		Windows[2].fonction.occup.fragmented_t = 4;

		Windows[2].fonction.occup.selected_c = RED;
		Windows[2].fonction.occup.selected_c = 7;

		Windows[2].fonction.occup.end_marq_c = RED;
		Windows[2].fonction.occup.end_marq_c = 7;

		/* secteur */
		for (i=3; i<WinEntrees; i++)
		{
			OBJECT *slide;

			Windows[i].box.g_x = desk.g_x;
			Windows[i].box.g_y = desk.g_y;
			rsrc_gaddr(R_TREE, SLIDER, &slide);
			Windows[i].box.g_w = 70*gr_cw + slide[SLIDER_FOND].ob_width;
			Windows[i].box.g_h = gr_ch*20 +2;
			window_calc(WC_BORDER, MOVER | FULLER | CLOSER | NAME, &Windows[i].box, &Windows[i].box);
			Windows[i].type = MOVER | FULLER | CLOSER | NAME;
			Windows[i].fenetre = NULL;

			Windows[i].fonction.texte.texte_c = BLACK;
			Windows[i].fonction.texte.texte_pt = gr_ch == 8 ? 9 : 10;
			Windows[i].fonction.texte.curseur_c = BLACK;
			Windows[i].fonction.texte.curseur_t = 0;
			Windows[i].fonction.texte.background_c = WHITE;
			Windows[i].fonction.texte.background_t = 0;
		}
	}

	return FALSE;
} /* read_config */

/********************************************************************
*																	*
*					Sauve la Configuration							*
*																	*
********************************************************************/
boolean save_config(void)
{
	int fd, choix, title, entree, i;
	raccourcis_var raccourcis;
	char nom[FILENAME_MAX];

	strcpy(Chemin, ConfigFileName);
	GetPath(Chemin);
	strcpy(nom, GetFilename(ConfigFileName));
	if(!selecteur(nom, "*.INF", Messages(CONFIG_8)))
		return TRUE;

	strcpy(ConfigFileName, nom);
	if ((fd = (int)Fcreate(ConfigFileName, 0)) < 0)
	{
		my_alert(1, FAIL, X_ICN_INFO, Messages(CONFIG_2), NULL);
		return TRUE;
	}

	/* version du fichier ZORG.INF */
	choix = ZORG_VERSION;
	Fwrite(fd, sizeof(int), &choix);
	choix = ZORG_INF_VERSION;
 	Fwrite(fd, sizeof(int), &choix);

	/* caractäre zÇro */
	choix = CARACTERE_ZERO_DEF;
	Fwrite(fd, sizeof(int), &choix);
	choix = ZeroChar;
 	Fwrite(fd, sizeof(int), &choix);
		
	/* disquette */
	choix = FLOPPY_RAW;
	Fwrite(fd, sizeof(int), &choix);
	Fwrite(fd, sizeof(t_raw_floppy_entry)*6, RawFloppy);

	/* disque dur */
	choix = HARD_RAW;
	Fwrite(fd, sizeof(int), &choix);
	Fwrite(fd, sizeof(t_raw_hard_entry)*6, RawHard);

	/* drapeaux divers */
	choix = ZORG_INF;
	Fwrite(fd, sizeof(int), &choix);
	choix = ZorgInf;
	Fwrite(fd, sizeof(int), &choix);

	choix = CLEAR_SCREEN;
	Fwrite(fd, sizeof(int), &choix);
	choix = ClearScreen;
	Fwrite(fd, sizeof(int), &choix);

	choix = FLUSH_CACHE;
	Fwrite(fd, sizeof(int), &choix);
	choix = FlushCache;
	Fwrite(fd, sizeof(int), &choix);

	choix = MAKE_PAUSE;
	Fwrite(fd, sizeof(int), &choix);
	choix = MakePause;
	Fwrite(fd, sizeof(int), &choix);

	choix = BLOC_SIZE;
	Fwrite(fd, sizeof(int), &choix);
	choix = BlocSize;
	Fwrite(fd, sizeof(int), &choix);

	choix = TOS_40x_BUG;
	Fwrite(fd, sizeof(int), &choix);
	choix = Tos40xBug;
	Fwrite(fd, sizeof(int), &choix);

	choix = SOUND_FLAG;
	Fwrite(fd, sizeof(int), &choix);
	choix = Sound;
	Fwrite(fd, sizeof(int), &choix);

	choix = SAVE_POS;
	Fwrite(fd, sizeof(int), &choix);
	choix = SavePos;
	Fwrite(fd, sizeof(int), &choix);

	choix = SCROLL_TIMER;
	Fwrite(fd, sizeof(int), &choix);
	choix = ScrollTimer;
	Fwrite(fd, sizeof(int), &choix);

	choix = RESET_FLAG_INF;
	Fwrite(fd, sizeof(int), &choix);
	choix = ResetFlag;
	Fwrite(fd, sizeof(int), &choix);

	choix = KEEP_STRUCTURE;
	Fwrite(fd, sizeof(int), &choix);
	choix = KeepStructure;
	Fwrite(fd, sizeof(int), &choix);

	choix = SHORTCUTS;
	for (title=0; title<NbMenus; title++)
		for (entree=0; entree<MenuShortCuts[title].nb_entrees; entree++)
			if (MenuShortCuts[title].menu[entree].state != FAIL)
			{
				Fwrite(fd, sizeof(int), &choix);

				raccourcis.menu = title;
				raccourcis.entree = entree;
				raccourcis.key = MenuShortCuts[title].menu[entree].key;
				raccourcis.state = MenuShortCuts[title].menu[entree].state;
				Fwrite(fd, sizeof(raccourcis_var), &raccourcis);
			}

	choix = DEVICE;
	for (i=2; i<MAX_DEVICES; i++)
		if (Partition[i].devno >= 0)
		{
			Fwrite(fd, sizeof(int), &choix);

			Fwrite(fd, sizeof(int), &i);
			Fwrite(fd, sizeof(t_partition), &Partition[i]);
		}

	choix = DIALOG_WINDOW;
	Fwrite(fd, sizeof(int), &choix);
	choix = DialogInWindow;
	Fwrite(fd, sizeof(int), &choix);

	choix = MULTI_WARNING_FLAG;
	Fwrite(fd, sizeof(int), &choix);
	choix = MultiWarning;
	Fwrite(fd, sizeof(int), &choix);

	/* ca doit àtre la derniäre dÇfinition */

	/* positions des fenàtres */
	choix = WIN_DEF;
	Fwrite(fd, sizeof(int), &choix);
	choix = gr_ch;
	Fwrite(fd, sizeof(int), &choix);
	choix = desk.g_w;
	Fwrite(fd, sizeof(int), &choix);
	choix = desk.g_h;
	Fwrite(fd, sizeof(int), &choix);

	Fwrite(fd, sizeof(int), &WinEntrees);
	Fwrite(fd, sizeof(*Windows)*WinEntrees, Windows);

	choix = MANAGE_VFAT_OPT;
	Fwrite(fd, sizeof(int), &choix);
	choix = ManageVFAT;
	Fwrite(fd, sizeof(int), &choix);

	/* fermeture */
	Fclose(fd);

	return FALSE;
} /* save_config */
