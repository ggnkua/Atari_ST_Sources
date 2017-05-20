/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
/*#define TEST_VERSION*/

#include <e_gem.h>
#include <string.h>

#include "zorg.h"
#include "globals.h"

#include "brut.h"
#include "config.h"
#include "desk.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "fenetre.h"
#include "init.h"
#include "menu.h"
#include "ouvre.h"
#include "wind.h"

#define _sysbase	0x4F2

/****************************************************************
*																*
*						init resources							*
*																*
****************************************************************/
boolean init_resources(void)
{
	int i;

	/* l'adresse des messages */
	rsrc_gaddr(R_TREE, TEXTES, &Messages);

/* erweiterte Objekte sowie Images/Icons anpassen */
	for (i=0; i<MENU; i++)	/* pas le menu */
	{
		rsrc_gaddr(R_TREE, i, &Dialog[i].tree);
		Dialog[i].var = NULL;
		Dialog[i].proc = NULL;
		Dialog[i].thewin = NULL;
		Dialog[i].info = NULL;

		if (i == PRESENTATION)
			fix_objects(Dialog[i].tree, (TEST_SCALING|DARK_SCALING), 8, 16);
		else
			fix_objects(Dialog[i].tree, NO_SCALING, 8, 16);
	}

	rsrc_gaddr(R_TREE, POPUP_UNIT, &PopUpUnit.p_menu);
	fix_objects(PopUpUnit.p_menu, NO_SCALING, 8, 16);
	PopUpUnit.p_parent = HD_UNIT_TEXTE;
	PopUpUnit.p_button = HD_UNIT;
	PopUpUnit.p_cycle = HD_UNIT_BUTTON;
	PopUpUnit.p_wrap = TRUE;
	PopUpUnit.p_set = TRUE;
	PopUpUnit.p_func = NULL;
	Dialog[RAW_DISQUE_DUR].tree[HD_UNIT].ob_spec.tedinfo -> te_ptext = PopUpUnit.p_menu[1].ob_spec.free_string;

	rsrc_gaddr(R_TREE, POPUP_ACCESS, &PopUpMode.p_menu);
	fix_objects(PopUpMode.p_menu, NO_SCALING, 8, 16);
	PopUpMode.p_parent = HD_MODE_TEXTE;
	PopUpMode.p_button = HD_MODE;
	PopUpMode.p_cycle = HD_MODE_BUTTON;
	PopUpMode.p_wrap = TRUE;
	PopUpMode.p_set = TRUE;
	PopUpMode.p_func = NULL;
	Dialog[RAW_DISQUE_DUR].tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[1].ob_spec.free_string;

	PopUpUnit2.p_menu = PopUpUnit.p_menu;
	PopUpUnit2.p_parent = HD_UNIT_TEXTE2;
	PopUpUnit2.p_button = HD_UNIT2;
	PopUpUnit2.p_cycle = HD_UNIT_BUTTON2;
	PopUpUnit2.p_wrap = TRUE;
	PopUpUnit2.p_set = TRUE;
	PopUpUnit2.p_func = NULL;
	Dialog[CHOIX_UNIT].tree[HD_UNIT2].ob_spec.tedinfo -> te_ptext = PopUpUnit2.p_menu[1].ob_spec.free_string;

	PopUpMode2.p_menu = PopUpMode.p_menu;
	PopUpMode2.p_parent = HD_MODE_TEXTE2;
	PopUpMode2.p_button = HD_MODE2;
	PopUpMode2.p_cycle = HD_MODE_BUTTON2;
	PopUpMode2.p_wrap = TRUE;
	PopUpMode2.p_set = TRUE;
	PopUpMode2.p_func = NULL;
	Dialog[CHOIX_UNIT].tree[HD_MODE2].ob_spec.tedinfo -> te_ptext = PopUpMode2.p_menu[1].ob_spec.free_string;

	return FALSE;
} /* init_resources */

/****************************************************************
*																*
*			init_menu  -  Met … jour les raccourcis clavier		*
*																*
****************************************************************/
boolean init_menu(void)
{
	int dropdowns, title, entree, menu_idx, entree_idx, size_title;
	long size, malloc_size;
	char *ptr;

	rsrc_gaddr(R_TREE, MENU, &Menu);

	/* Menu[0] a deux fils bar (ob_head) et dropdowns (ob_tail) */

	/* bar a un fils active (ob_head ou ob_tail c'est le mˆme) */
	/* active a autant de fils que d'entr‚es de menu */

	/* dropdowns a autant de fils que d'entr‚e de menu */
	/* chacun de ses fils contient les entr‚es correspondantes */

	dropdowns = Menu[0].ob_head;	/* bar */
	dropdowns = Menu[dropdowns].ob_head;	/* active */

	/* pour chaque menu */
	for (title = Menu[dropdowns].ob_head; title != dropdowns; title = Menu[title].ob_next)
		NbMenus++;

	/* alloue de la m‚moire et la met … z‚ro */
	if ((MenuShortCuts = calloc(NbMenus, sizeof(t_menu))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	/* pour chaque menu */
	menu_idx = 0;
	for (title = Menu[dropdowns].ob_head; title != dropdowns; title = Menu[title].ob_next, menu_idx++)
		/* num‚ro du menu */
		MenuShortCuts[menu_idx].menuid = title;

	dropdowns = Menu[0].ob_tail;	/* dropdowns */

	/* pour chaque menu */
	menu_idx = 0;
	malloc_size = 0L;
	for (title = Menu[dropdowns].ob_head; title != dropdowns; title = Menu[title].ob_next, menu_idx++)
	{
		size = 0L;	/* taille initiale */

		/* son fils est un G_BOX contenant les entr‚es */
		for (entree = Menu[title].ob_head; entree != title; entree = Menu[entree].ob_next)
		{
			/* un menu de plus */
			MenuShortCuts[menu_idx].nb_entrees++;
			size = MAX(size, strlen(Menu[entree].ob_spec.free_string));
		}

		MenuShortCuts[menu_idx].size = (int)size +SHORTCUT_SIZE;
		MenuShortCuts[menu_idx].offset = (int)size;
		if ((MenuShortCuts[menu_idx].menu = calloc(MenuShortCuts[menu_idx].nb_entrees, sizeof(t_menu_entry))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return TRUE;
		}

		malloc_size += (size +SHORTCUT_SIZE +1) * MenuShortCuts[menu_idx].nb_entrees;	/* +1 pour les '\0' */
	}

	MenuShortCuts[0].nb_entrees = 1;	/* on ne compte pas les accessoires */

	if ((MenuText = malloc(malloc_size)) == NULL)
	{
		for (title=0; title<NbMenus; title++)
			free(MenuShortCuts[title].menu);

		free(MenuShortCuts);

		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	ptr = MenuText;

	/* pour chaque menu */
	menu_idx = 0;
	for (title = Menu[dropdowns].ob_head; title != dropdowns; title = Menu[title].ob_next, menu_idx++)
	{
		/* son fils est un G_BOX contenant les entr‚es */
		entree_idx = 0;
		for (entree = Menu[title].ob_head; entree != title; entree = Menu[entree].ob_next, entree_idx++)
		{
			sprintf(ptr, "%-*s", MenuShortCuts[menu_idx].size, Menu[entree].ob_spec.free_string);
			ptr[MenuShortCuts[menu_idx].offset] = '\0';

			/* met … jour la nouvelle entr‚e */
			Menu[entree].ob_spec.free_string = ptr;
			MenuShortCuts[menu_idx].menu[entree_idx].itemid = entree;
			MenuShortCuts[menu_idx].menu[entree_idx].text = ptr;
			MenuShortCuts[menu_idx].menu[entree_idx].state = FAIL;
			MenuShortCuts[menu_idx].menu[entree_idx].key = FAIL;
			MenuShortCuts[menu_idx].menu[entree_idx].new_state = FAIL;
			MenuShortCuts[menu_idx].menu[entree_idx].new_key = FAIL;

			/* on avance d'une entr‚e */
			ptr += MenuShortCuts[menu_idx].size+1;
		}
	}

	if ((PopUpMenuTree = calloc(NbMenus +1L, sizeof(OBJECT))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	size_title = 0;
	for (title=0; title<NbMenus; title++)
		size_title = max(size_title, (int)strlen(Menu[MenuShortCuts[title].menuid].ob_spec.free_string));

	if ((PopUpMenuText = calloc(NbMenus, size_title+1)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	PopUpMenuTree[0].ob_next = FAIL;
	PopUpMenuTree[0].ob_head = 1;
	PopUpMenuTree[0].ob_tail = NbMenus;
	PopUpMenuTree[0].ob_type = G_BOX;
	PopUpMenuTree[0].ob_flags = 0;
	PopUpMenuTree[0].ob_state = SHADOWED;
	PopUpMenuTree[0].ob_spec.obspec.character = 0;
	PopUpMenuTree[0].ob_spec.obspec.framesize = FAIL;
	PopUpMenuTree[0].ob_spec.obspec.framecol = 1;
	PopUpMenuTree[0].ob_spec.obspec.textcol = 1;
	PopUpMenuTree[0].ob_spec.obspec.textmode = 0;
	PopUpMenuTree[0].ob_spec.obspec.fillpattern = 0;
	PopUpMenuTree[0].ob_spec.obspec.interiorcol = 0;
	PopUpMenuTree[0].ob_x = 0;
	PopUpMenuTree[0].ob_y = 0;
	PopUpMenuTree[0].ob_width = (size_title +4) * gr_cw +2;
	PopUpMenuTree[0].ob_height = NbMenus * gr_ch +2;

	ptr = PopUpMenuText;
	for (title=1; title<=NbMenus; title++)
	{
		PopUpMenuTree[title].ob_next = title+1;
		PopUpMenuTree[title].ob_head = PopUpMenuTree[title].ob_tail = FAIL;
		PopUpMenuTree[title].ob_type = G_STRING;
		PopUpMenuTree[title].ob_flags = SELECTABLE;
		PopUpMenuTree[title].ob_state = 0;
		sprintf(ptr, "  %s", Menu[MenuShortCuts[title-1].menuid].ob_spec.free_string);
		PopUpMenuTree[title].ob_spec.free_string = ptr;
		ptr += strlen(ptr)+1;
		PopUpMenuTree[title].ob_x = 1;
		PopUpMenuTree[title].ob_y = 1 + gr_ch*(title-1);
		PopUpMenuTree[title].ob_width = (size_title +4) * gr_cw;
		PopUpMenuTree[title].ob_height = gr_ch;
	}
	PopUpMenuTree[NbMenus].ob_next = 0;
	PopUpMenuTree[NbMenus].ob_flags |= LASTOB;

	strcpy(Dialog[CONFIG_MENU].tree[MENU_TITLE].ob_spec.tedinfo -> te_ptext, PopUpMenuText);

	PopUpMenu.p_menu = PopUpMenuTree;
	PopUpMenu.p_parent = TITLE;
	PopUpMenu.p_button = MENU_TITLE;
	PopUpMenu.p_cycle = TITLE_BUTTON;
	PopUpMenu.p_wrap = TRUE;
	PopUpMenu.p_set = TRUE;

	if ((PopUpEntry = (POPUP *)calloc(NbMenus, sizeof(POPUP))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	if ((PopUpEntryTree = (OBJECT **)calloc(NbMenus, sizeof(OBJECT *))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	if ((PopUpEntryText = calloc(NbMenus, sizeof(char *))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return TRUE;
	}

	/* construction des arborescences des PopUp */
	for (title=0; title<NbMenus; title++)
	{
		if ((PopUpEntryTree[title] = (OBJECT *)calloc(MenuShortCuts[title].nb_entrees +1L, sizeof(OBJECT))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return TRUE;
		}

		PopUpEntryTree[title][0].ob_next = FAIL;
		PopUpEntryTree[title][0].ob_head = 1;
		PopUpEntryTree[title][0].ob_tail = MenuShortCuts[title].nb_entrees;
		PopUpEntryTree[title][0].ob_type = G_BOX;
		PopUpEntryTree[title][0].ob_flags = 0;
		PopUpEntryTree[title][0].ob_state = SHADOWED;
		PopUpEntryTree[title][0].ob_spec.obspec.character = 0;
		PopUpEntryTree[title][0].ob_spec.obspec.framesize = FAIL;
		PopUpEntryTree[title][0].ob_spec.obspec.framecol = 1;
		PopUpEntryTree[title][0].ob_spec.obspec.textcol = 1;
		PopUpEntryTree[title][0].ob_spec.obspec.textmode = 0;
		PopUpEntryTree[title][0].ob_spec.obspec.fillpattern = 0;
		PopUpEntryTree[title][0].ob_spec.obspec.interiorcol = 0;
		PopUpEntryTree[title][0].ob_x = 0;
		PopUpEntryTree[title][0].ob_y = 0;
		PopUpEntryTree[title][0].ob_width = (MenuShortCuts[title].size - SHORTCUT_SIZE +2) * gr_cw +2;
		PopUpEntryTree[title][0].ob_height = MenuShortCuts[title].nb_entrees * gr_ch +2;

		if ((PopUpEntryText[title] = calloc(MenuShortCuts[title].nb_entrees, MenuShortCuts[title].size+1)) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return TRUE;
		}

		ptr = PopUpEntryText[title];
		for (entree=1; entree<=MenuShortCuts[title].nb_entrees; entree++)
		{
			PopUpEntryTree[title][entree].ob_next = entree+1;
			PopUpEntryTree[title][entree].ob_head = PopUpEntryTree[title][entree].ob_tail = FAIL;
			PopUpEntryTree[title][entree].ob_type = G_STRING;
			PopUpEntryTree[title][entree].ob_flags = SELECTABLE;
			PopUpEntryTree[title][entree].ob_state = 0;
			sprintf(ptr, " %s", MenuShortCuts[title].menu[entree-1].text);
			PopUpEntryTree[title][entree].ob_spec.free_string = ptr;
			if (ptr[1] == '-')
				PopUpEntryTree[title][entree].ob_state |= DISABLED;
			ptr += strlen(ptr)+1;
			PopUpEntryTree[title][entree].ob_x = 1;
			PopUpEntryTree[title][entree].ob_y = 1 + gr_ch*(entree-1);
			PopUpEntryTree[title][entree].ob_width = (MenuShortCuts[title].size - SHORTCUT_SIZE +2) * gr_cw;
			PopUpEntryTree[title][entree].ob_height = gr_ch;
		}
		PopUpEntryTree[title][MenuShortCuts[title].nb_entrees].ob_next = 0;
		PopUpEntryTree[title][MenuShortCuts[title].nb_entrees].ob_flags |= LASTOB;

		PopUpEntry[title].p_menu = PopUpEntryTree[title];
		PopUpEntry[title].p_parent = ENTREE;
		PopUpEntry[title].p_button = MENU_ENTREE;
		PopUpEntry[title].p_cycle = ENTREE_BUTTON;
		PopUpEntry[title].p_wrap = TRUE;
		PopUpEntry[title].p_set = TRUE;
	}

	/* raccourcis par d‚faut */
	shortcut_key(SCANDOWN << 8, 0, MenuShortCuts[5].menu[0].text + MenuShortCuts[5].offset, FALSE);
	shortcut_key(SCANUP << 8, 0, MenuShortCuts[5].menu[1].text + MenuShortCuts[5].offset, FALSE);
	shortcut_key(SCANDOWN << 8, K_LSHIFT, MenuShortCuts[5].menu[2].text + MenuShortCuts[5].offset, FALSE);
	shortcut_key(SCANUP << 8, K_LSHIFT, MenuShortCuts[5].menu[3].text + MenuShortCuts[5].offset, FALSE);

	size = (MenuShortCuts[5].offset + 3) * gr_cw;
	Menu[SECTEUR_SUIVANT-1].ob_width = (int)size;
	for (entree = SECTEUR_SUIVANT; entree != SECTEUR_SUIVANT-1; entree = Menu[entree].ob_next)
		Menu[entree].ob_width = (int)size;

	PopUpEntryTree[5][1].ob_state |= DISABLED;
	PopUpEntryTree[5][2].ob_state |= DISABLED;
	PopUpEntryTree[5][3].ob_state |= DISABLED;
	PopUpEntryTree[5][4].ob_state |= DISABLED;

	return FALSE;
} /* init_menu */

/****************************************************************
*																*
*	shutdown - is the code that closes down the application.	*
*	This routine is called when errors occurs and guarantees	*
*	that all window's will be closed properly before exiting.	*
*																*
****************************************************************/
void shutdown(reset_flag)
	int reset_flag;
{
	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* Sauvegarde la configuration */
	if (SaveConfig && my_alert(1, 2, X_ICN_QUESTION, Messages(INIT_1), Messages(BOOT_32)) == 0)
		save_config();

#ifdef TEST_VERSION
	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	my_alert(FAIL, FAIL, X_ICN_INFO, Messages(MAIN_8), NULL);
#endif

	/* Clean up memory */
	cleanup();

	/* bye ... */
	if (reset_flag)
		reset();

	/* Shut down the application */
	close_rsc(TRUE, 0);
} /* shutdown */

/****************************************************************
*																*
*							reset								*
*																*
****************************************************************/
void reset(void)
{
	long l=0L;
	int cookie;

	/* r‚cupŠre le cookie du processeur */
	cookie = get_cookie('_CPU', &l);

	if (Super((void *)1L) == 0L)	/* si on est en mode utilisateur */
		Super(0L);	/* on passe en mode superviseur	*/
	
	/* si c'est un 68020 ou plus ou qu'il n'y a pas de cookie */
	if (l >= 20L || cookie == FALSE)
	{
		void (*routine)(void);

		/* num‚ro de version du TOS */
		if ((*(SYSHDR **)_sysbase) -> os_version == 0x402)
			routine = (void (*)())0xE03932L;	/* TOS 4.02 Falcon */
		else
			routine = (*(SYSHDR **)_sysbase) -> os_start;	/* le reste */

		(*routine)();
	}
	else
		reset000();
} /* reset */

/****************************************************************
*																*
*	cleanup - releases the memory used by the application.		*
*																*
****************************************************************/
void cleanup(void)
{
	windowptr thewin;
	t_dialog_list *win;
	
	int i;

	/* ferme tous les dialog */
	for (win = WinDials; win; win = win -> next)
		my_close_dialog(win -> dialog);

	/* Close down the windows */
	if (Firstwindow -> next)
		for (thewin = Firstwindow -> next; thewin; thewin = thewin -> next)
			fermer(thewin -> win -> handle);

	/* fermer la fenˆtre principale */
	dispose_window(Firstwindow);

	/* Remet le bureau normal */
	init_desk(FALSE);

	/* LibŠre la m‚moire alou‚e */
	if (Boot)
		free(Boot);

	if (DeadSector)
		free(DeadSector);

	for (i=0; i<MAX_DEVICES; i++)
	{
		if (FAT[i])
			free(FAT[i]);

		if (Arbo[i])
			if (ManageVFAT)
				free_arbo_vfat((dir_elt_vfat *)Arbo[i]);
			else
				free_arbo_short(Arbo[i]);

		if (Cluster[i])
			free(Cluster[i]);
	}

	free(Tampon -> fonction.text.Text);
	free(Tampon -> fonction.text.Ligne);
	free(Tampon);

	/* liste de position des fenˆtres */
	if (Windows)
		free(Windows);

	/* textes des menus pour les raccourcis clavier */
	free(MenuText);

	for (i=0; i<NbMenus; i++)
		free(MenuShortCuts[i].menu);

	free(MenuShortCuts);

	/* les structures associ‚es au windialogs */
	for (i=0; i<MENU; i++)	/* pas le menu */
		if (Dialog[i].var)
			free (Dialog[i].var);

	free(PopUpMenuTree);
	free(PopUpMenuText);

	free(PopUpEntry);
	for (i=0; i<NbMenus; i++)
	{
		free(PopUpEntryTree[i]);
		free(PopUpEntryText[i]);
	}
} /* cleanup */

/********************************************************************
*																	*
*				initialise une structure d'ascenseur				*
*																	*
********************************************************************/
OBJECT *make_slide(work, max)
	GRECT *work;
	long max;
{
	OBJECT *slide, *origine;
	static int modif = TRUE;

	if ((slide = calloc(5, sizeof(OBJECT))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return NULL;
	}

	rsrc_gaddr(R_TREE, SLIDER, &origine);

	if (modif)
	{
		/* modifier l'arbre en fonction de la r‚solution et de l'AES */
		origine[SLIDER_FOND].ob_spec.obspec.framesize = 0;	/* pas de cadre */

		origine[SLIDER_FILS].ob_y = 0;

#if FALSE
		/* test avec un ascenseur en 2D */
		aes_version = 0x300;

		origine[SLIDER_PERE].ob_flags &= ~FL3DBAK;
		origine[SLIDER_FILS].ob_flags &= ~FL3DBAK;
		origine[SLIDER_HAUT].ob_flags &= ~FL3DBAK;
		origine[SLIDER_BAS].ob_flags &= ~FL3DBAK;
#endif

		if (aes_version >= 0x330)
		{	/* AES >= 3.3, relief */
			if (gr_ch == 16)	/* fonte 8*16 */
				origine[SLIDER_PERE].ob_y = origine[SLIDER_HAUT].ob_height + 9;
		}
		else
		/* AES < 3.3 */
			if (gr_ch == 16)	/* fonte 8*16 */
			{
				origine[SLIDER_FOND].ob_width -= 2;

				origine[SLIDER_PERE].ob_x -= 1;
				origine[SLIDER_PERE].ob_y -= 15;

				origine[SLIDER_HAUT].ob_x -= 1;
				origine[SLIDER_HAUT].ob_y -= 2;

				origine[SLIDER_BAS].ob_x -= 1;
			}
			else
			{	/* fonte 8*8 */
				origine[SLIDER_FOND].ob_width -= 2;

				origine[SLIDER_PERE].ob_x -= 1;
				origine[SLIDER_PERE].ob_y -= 6;

				origine[SLIDER_HAUT].ob_x -= 1;
				origine[SLIDER_HAUT].ob_y -= 2;

				origine[SLIDER_BAS].ob_x -= 1;
			}

		modif = FALSE;
	}

	/* on copie les arbres */
	memcpy(slide, origine, 5*sizeof(OBJECT));

	/* ajuste les taille */
	slide[SLIDER_FOND].ob_x = work -> g_x + work -> g_w - slide[SLIDER_FOND].ob_width;
	slide[SLIDER_FOND].ob_y = work -> g_y;
	slide[SLIDER_FOND].ob_height = work -> g_h;

	slide[SLIDER_PERE].ob_height = work -> g_h - 2*slide[SLIDER_PERE].ob_y + (aes_version >= 0x330 ? 1 : 0);

	slide[SLIDER_BAS].ob_y = slide[SLIDER_FOND].ob_height - slide[SLIDER_BAS].ob_height - (aes_version >= 0x330 ? 2 : 1);

	if (max == 0)	/* problŠme avec les fichiers vides */
		max = 1;

	slide[SLIDER_FILS].ob_height = (int)(slide[SLIDER_PERE].ob_height / max);
	if (slide[SLIDER_FILS].ob_height < slide[SLIDER_FILS].ob_width * gr_ch/16)
		slide[SLIDER_FILS].ob_height = slide[SLIDER_FILS].ob_width * gr_ch/16;

	return slide;
} /* make_slide */

/********************************************************************
*																	*
*				initialise le lecteur par d‚faut					*
*																	*
********************************************************************/
void init_drive(void)
{
	char text[80];
	int x, y;

	Drive = Dgetdrv();

	sprintf(text, Drive < 2 ? Messages(INIT_2) : Messages(INIT_3), 'A' + Drive);
	ajoute(Firstwindow, text);

	if (Bureau)
	{
		objc_offset(Bureau, 1+15, &x, &y);
		form_dial(FMD_START, 0, 0, 0, 0, 0, y, x+Bureau[1].ob_width, Bureau[1].ob_height);

		Bureau[1 + Drive].ob_state |= SELECTED;

		form_dial(FMD_FINISH, 0, 0, 0, 0, 0, y, x+Bureau[1].ob_width, Bureau[1].ob_height);
	}
} /* init_drive */
