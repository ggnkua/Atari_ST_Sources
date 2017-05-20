/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#define SIZEBUFFLOP 21	/* nombre de secteurs pour le buffer de recherche sur une disquette */
#define SIZEBUFHARD	64	/* idem mais pour une partition */

#include <e_gem.h>
#include <string.h>

#include "globals.h"
#include "zorg.h"

#include "search.h"
#include "dialog.h"
#include "update.h"
#include "deplace.h"
#include "fenetre.h"
#include "fat.h"
#include "brut.h"
#include "divers.h"
#include "secteur.h"
#include "curseur.h"

char SearchSound[] = {0x00, 0x9E, 0x01, 0x02, 0x02, 0xE8, 0x03, 0x03, 0x04, 0xD1, 0x05, 0x07, 0x07, 0xF8, 0x08, 0x10, 0x09, 0x10, 0x0A, 0x10, 0x0B, 0x6F, 0x0C, 0xA3, 0x0D, 0x00, 0x80, 0x00, 0xFF, 0x00};

/****************************************************************
*																*
*					cherche une chaŒne 							*
*																*
****************************************************************/
void search_secteur(windowptr thewin, boolean diff_majmin, boolean start_to_end)
{
	char *buffer, *buffer_frontiere;
	OBJECT *search = Dialog[WAIT].tree;
	int taille, start;
	long secteur = thewin -> fonction.secteur.secteur, max = thewin -> fonction.secteur.max;
	int width, i;
	char *secteur_text;
	char pattern[SEARCH_PATTERN_SIZE];
	long offset;
	int size_buff_sect;
	int dummy;

#ifndef TEST_VERSION
	if (thewin -> fonction.secteur.dirty && write_secteur(thewin, MENU_DEPLACEMENT))
			return;
#endif

	thewin -> fonction.secteur.dirty = FALSE;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	search[WAIT_MESSAGE].ob_spec.free_string = Messages(SEARCH_2);
	search[WAIT_INFO].ob_spec.tedinfo -> te_ptext = Messages(REORG_14);

	width = search[SLIDE_PERE].ob_width -3;
	search[SLIDE_FILS].ob_width = (int)((long)width * secteur / max) +3;

	secteur_text = search[INDICATEUR_WAIT].ob_spec.tedinfo -> te_ptext;
	sprintf(secteur_text, "%ld", secteur);
	sprintf(search[MAX_WAIT].ob_spec.free_string, "/%ld", max);

	my_open_dialog(&Dialog[WAIT], AUTO_DIAL|NO_ICONIFY|MODAL, FAIL);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* allocation des buffers, on d‚passe un peu … cause de l'approximation de la taille dans and_buffer() */
	buffer = malloc(20L+ 512L * (thewin -> fonction.secteur.device < 2 ? SIZEBUFFLOP : SIZEBUFHARD));
	if (buffer == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return;
	}

	if ((buffer_frontiere = malloc(20L+ SEARCH_PATTERN_SIZE*2L + 16L)) == NULL)
	{
		free(buffer);
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return;
	}
	/* mise … z‚ro */
	memset(buffer_frontiere, 0, 20L+ SEARCH_PATTERN_SIZE*2L + 16L);

	/* pr‚pare le pattern */
	if (diff_majmin)
		for (i=0; i<SearchLength; i++)
			pattern[i] = SearchString[i];
	else
		for (i=0; i<SearchLength; i++)
			pattern[i] = SearchString[i] & ~('a'-'A');

	/* octet de d‚part */
	start = thewin -> fonction.secteur.curseur_x < 0 ? thewin -> fonction.secteur.page *512 : thewin -> fonction.secteur.page *512 + thewin -> fonction.secteur.curseur_y*32 + thewin -> fonction.secteur.curseur_x/2 +1;

	/* recherche d'abord dans le secteur en m‚moire */
	memcpy(buffer, thewin -> fonction.secteur.secteurBin, thewin -> fonction.secteur.sector_size*512L);
	if ((offset = search_pattern(buffer + start, thewin -> fonction.secteur.sector_size*512L - start, pattern, diff_majmin, start_to_end)) >= 0)
	{
		my_close_dialog(&Dialog[WAIT]);
		free(buffer_frontiere);
		free(buffer);
		search_found(thewin, secteur, offset + start);
		return;
	}

	/* remplis de n'importe quoi sauf du motif recherch‚ */
	memset(buffer_frontiere, SearchString[0] ^ 0xAA, (long)SEARCH_PATTERN_SIZE);

	/* nombre max de secteurs … lire */
	size_buff_sect = (thewin -> fonction.secteur.device < 2 ? SIZEBUFFLOP : SIZEBUFHARD) / thewin -> fonction.secteur.sector_size;

	/* taille du bloc … lire */
	if (max - secteur > (long)size_buff_sect)
		taille = size_buff_sect;
	else
		taille = (int)(max - secteur);

	while (taille > 0)
	{
		/* charge le buffer */
		if ((taille = load_buffer(thewin, buffer, secteur, taille, start_to_end)) < 0)
		{	/* erreur */
			my_close_dialog(&Dialog[WAIT]);
			free(buffer);
			return;
		}

		/* recherche sur la frontiŠre */
		memcpy(buffer_frontiere + SEARCH_PATTERN_SIZE, buffer, (long)SEARCH_PATTERN_SIZE);
		if ((offset = search_pattern(buffer_frontiere, SEARCH_PATTERN_SIZE, pattern, diff_majmin, start_to_end)) >= 0)
		{
			my_close_dialog(&Dialog[WAIT]);
			free(buffer_frontiere);
			free(buffer);
			search_found(thewin, secteur-taille, offset + (thewin -> fonction.secteur.device < 2 ? SIZEBUFFLOP*512L - SEARCH_PATTERN_SIZE : SIZEBUFHARD*512L - SEARCH_PATTERN_SIZE));
			return;
		}

		/* recherche en cours */
		if ((offset = search_pattern(buffer+start, taille * thewin -> fonction.secteur.sector_size * 512L - start, pattern, diff_majmin, start_to_end)) >= 0)
		{
			my_close_dialog(&Dialog[WAIT]);
			free(buffer_frontiere);
			free(buffer);
			search_found(thewin, secteur, offset+start);
			return;
		}

		/* on n'a un d‚calage que la premiŠre fois */
		start = 0;

		/* copie la fin du bloc pour la frontiŠre */
		memcpy(buffer_frontiere, buffer + (thewin -> fonction.secteur.device < 2 ? SIZEBUFFLOP*512L - SEARCH_PATTERN_SIZE : SIZEBUFHARD*512L - SEARCH_PATTERN_SIZE), (long)SEARCH_PATTERN_SIZE);

		/* on avance */
		secteur += taille;

		/* taille du bloc … lire */
		if (max - secteur > (long)size_buff_sect)
			taille = size_buff_sect;
		else
			taille = (int)(max - secteur);

		/* test les boutons */
		if (evnt_multi(MU_TIMER | MU_BUTTON,
		 256+1, 3, 0,	/* button */
		 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* mouse */
		 NULL,	/* message */
		 1, 0,	/* timer */
		 &dummy, &dummy, &dummy, &dummy, &dummy, &dummy) == MU_BUTTON
		 && my_alert(1, 2, X_ICN_QUESTION, Messages(SEARCH_3), Messages(BOOT_32)) == 0)
		{	/* on n'a pas trouv‚ mais on s'arrˆte */
			my_close_dialog(&Dialog[WAIT]);
			free(buffer_frontiere);
			free(buffer);
			search_found(thewin, secteur, -1L);
			return;
		}

		/* met … jour la barre */
		search[SLIDE_FILS].ob_width = (int)((long)width * secteur / max) +3;
		ob_draw(Dialog[WAIT].info, SLIDE_FILS);

		/* met … jour le compteur */
		sprintf(secteur_text, "%ld", secteur);
		ob_draw(Dialog[WAIT].info, INDICATEUR_WAIT);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);
	}

	free(buffer_frontiere);
	free(buffer);

	my_close_dialog(&Dialog[WAIT]);

	/* un petit bruit */
	if (Sound)
		Cconout(7);
} /* search_secteur */

/****************************************************************
*																*
*							on a trouv‚							*
*																*
****************************************************************/
void search_found(windowptr thewin, long secteur, long offset)
{
	int curseur_x = thewin -> fonction.secteur.curseur_x, curseur_y = thewin -> fonction.secteur.curseur_y;

	if (offset >= 0)
	{
		int offset_in_page;

		/* un petit bruit */
		if (Sound)
			Dosound(SearchSound);

		/* d‚calage dans une page */
		offset_in_page = (int)(offset & 511L);

		/* nouvelle position du curseur */
		thewin -> fonction.secteur.curseur_x = 2 * (offset_in_page & 31);
		thewin -> fonction.secteur.curseur_y = offset_in_page/32;

		if (curseur_x < 0)
		{
			update_curseur(thewin, thewin -> fonction.secteur.curseur_x, thewin -> fonction.secteur.curseur_y, FAIL, FAIL, FALSE);
			menu_icheck(Menu, CURSEUR_VISIBLE, 1);
		}
		else
			update_curseur(thewin, thewin -> fonction.secteur.curseur_x, thewin -> fonction.secteur.curseur_y, curseur_x, curseur_y, FALSE);
	}
	else
		if (curseur_x > 0)
		{
			thewin -> fonction.secteur.curseur_x = thewin -> fonction.secteur.curseur_y = FAIL;
			update_curseur(thewin, FAIL, FAIL, curseur_x, curseur_y, FALSE);
			menu_icheck(Menu, CURSEUR_VISIBLE, 0);
		}

	/* nouvelle page */
	thewin -> fonction.secteur.page = (int)((offset & (thewin -> fonction.secteur.sector_size * 512L -1))/ 512L);

	/* nouveau secteur */
	thewin -> fonction.secteur.secteur = secteur + offset / (thewin -> fonction.secteur.sector_size * 512L);

	/* on le charge */
	read_secteur(thewin, MENU_DEPLACEMENT);

	/* et on met la fenˆtre … jour */
	secteur_window_update(thewin, FALSE);
} /* search_found */

/****************************************************************
*																*
*		charge size octets du 'disque' … partir de sect			*
*																*
****************************************************************/
int load_buffer(windowptr thewin, char *buffer, long secteur, int size /* nombre de secteur */, boolean start_to_end)
{
	int i, err = 0;

	switch (thewin -> type)
	{
		case SECTEUR:
			/* on d‚borde ? */
			if (secteur+size > thewin -> fonction.secteur.max)
				size = (int)(thewin -> fonction.secteur.max - secteur);

			if (my_rwabs(0, buffer, size, secteur, thewin -> fonction.secteur.device))
				return FAIL;
			break;

		case FICHIER:
			/* on d‚borde ? */
			if (secteur+size > thewin -> fonction.fichier.max)
				size = (int)(thewin -> fonction.fichier.max - secteur);

			/* pour chaque secteur */
			for (i=0; i<size; i++, secteur++)
			{
				if (my_rwabs(0, buffer, 1, thewin -> fonction.fichier.table[secteur], thewin -> fonction.fichier.device))
					return FAIL;
				buffer += thewin -> fonction.secteur.sector_size * 512L;
			}
			break;

		case FICHIER_FS:
			/* on d‚borde ? */
			if (secteur+size > thewin -> fonction.fichier_fs.max)
				size = (int)(thewin -> fonction.fichier_fs.max - secteur);

			my_rwabs(0, buffer, size, secteur, thewin -> fonction.fichier_fs.file_desc);
			break;

		case RAW_FLOPPY:
			/* on d‚borde ? */
			if (secteur+size > thewin -> fonction.raw_floppy.max)
				size = (int)(thewin -> fonction.raw_floppy.max - secteur);

			if ((err = my_floppy_read(buffer,  size, (int)secteur, thewin -> fonction.raw_floppy.max_secteur, thewin -> fonction.raw_floppy.max_face+1, thewin -> fonction.raw_floppy.lecteur)) != 0)
			{
				error_msg(err);
				return FAIL;
			}
			break;

		case RAW_HARD:
			/* on d‚borde ? */
			if (secteur+size > thewin -> fonction.raw_hard.max)
				size = (int)(thewin -> fonction.raw_hard.max - secteur);

			if ((err = my_DMAread(secteur, size, buffer, thewin -> fonction.raw_hard.device)) != 0)
			{
				error_msg(err);
				return FAIL;
			}
			break;
	}

	/* retourne le nombre de secteurs lus */
	return size;
#pragma warn -par
} /* load_buffer */
#pragma warn .par

/****************************************************************
*																*
*					recherche une chaŒne						*
*																*
****************************************************************/
long search_pattern(char *buffer, long size, char *pattern, boolean diff_majmin, boolean start_to_end)
{
	if (!diff_majmin)
		and_buffer(buffer, size);

	if (start_to_end)
		return search_pattern_ste(buffer, size, pattern, SearchLength);
	else
		return search_pattern_ets(buffer, size, pattern, SearchLength);
} /* search_pattern */

/****************************************************************
*																*
*					recherche une chaŒne						*
*																*
****************************************************************/
void search_first(windowptr thewin)
{
	OBJECT *search = Dialog[SEARCH].tree;
	static int first_time = TRUE;

	{
		char text[160];

		sprintf(text, Messages(SEARCH_5), thewin -> title);
		ajoute(Firstwindow, text);
	}

	if (first_time)
	{
		search[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext[0] = '\0';
		search[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext[0] = '\0';
		first_time = FALSE;
	}

	Dialog[SEARCH].proc = search_proc;
	Dialog[SEARCH].thewin = thewin;
	my_open_dialog(&Dialog[SEARCH], AUTO_DIAL, ob_isstate(search, ASCII_ACTIF, SELECTED) ? SEARCH_ASCII : SEARCH_HEXA);
} /* search_first */

/********************************************************************
*																	*
*					cherche une chaŒne (gestion)					*
*																	*
********************************************************************/
boolean search_proc(t_dialog *dialog, int exit)
{
	char *text;
	int c, i;

	switch (exit)
	{
		case SEARCH_ANNULER:
			return TRUE;

		case ASCII_ACTIF:
			ob_set_cursor(dialog -> info, SEARCH_ASCII, MAX_EDIT, TRUE);
			break;

		case HEXA_ACTIF:
			ob_set_cursor(dialog -> info, SEARCH_HEXA, MAX_EDIT, TRUE);
			break;

		case SEARCH_CALC:
			if (dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext[0] == '\0' && dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext[0] == '\0')
				break;

			if (ob_isstate(dialog -> tree, ASCII_ACTIF, SELECTED) && dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext[0] == '\0')
			{
				ob_dostate(dialog -> tree, HEXA_ACTIF, SELECTED);
				ob_undostate(dialog -> tree, ASCII_ACTIF, SELECTED);
				ob_set_cursor(dialog -> info, SEARCH_HEXA, MAX_EDIT, TRUE);

				ob_draw_chg(dialog -> info, ASCII_ACTIF, NULL, FAIL);
				ob_draw_chg(dialog -> info, HEXA_ACTIF, NULL, FAIL);
			}
			else
				if (ob_isstate(dialog -> tree, HEXA_ACTIF, SELECTED) && dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext[0] == '\0')
				{
					ob_undostate(dialog -> tree, HEXA_ACTIF, SELECTED);
					ob_dostate(dialog -> tree, ASCII_ACTIF, SELECTED);
					ob_set_cursor(dialog -> info, SEARCH_ASCII, MAX_EDIT, TRUE);

					ob_draw_chg(dialog -> info, ASCII_ACTIF, NULL, FAIL);
					ob_draw_chg(dialog -> info, HEXA_ACTIF, NULL, FAIL);
				}

			if (ob_isstate(dialog -> tree, ASCII_ACTIF, SELECTED))
			{
				strcpy(SearchString, dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext);
				SearchLength = (int)strlen(SearchString);
			}
			else
			{
				text = dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext;
				for (i=0; i<SEARCH_PATTERN_SIZE && text[i*2]; i++)
				{
					sscanf(&text[i*2], "%02x", &c);
					SearchString[i] = c;
				}
				SearchString[i] = '\0';
				SearchLength = i;
			}

			text = dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext;
			for (i=0; i<SearchLength; i++)
				if (SearchString[i])
					text[i] = (unsigned char)SearchString[i];
				else
					text[i] = '.';
			text[i] = '\0';

			text = dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext;
			for (i=0; i<min(20, SearchLength); i++)
				sprintf(&text[i*2], "%02X", (unsigned char)SearchString[i]);
			text[2*i] = '\0';

			ob_draw(dialog -> info, SEARCH_ASCII);
			ob_draw(dialog -> info, SEARCH_HEXA);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;
	}

	if (exit == SEARCH_GO)
	{
		/* Exit-Objekt selektiert? */
		if (ob_isstate(dialog -> tree, exit, SELECTED))
		{
			/* angew„hltes Objekt deselektieren und neu zeichnen */
			ob_undostate(dialog -> tree, exit, SELECTED);
			ob_draw_chg(dialog -> info, exit, NULL, FAIL);
		}

		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		if (dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext[0] == '\0' && dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext[0] == '\0')
		{
			menu_ienable(Menu, CHERCHER_NOUVEAU, 0);
			my_alert(1, FAIL, X_ICN_STOP, Messages(SEARCH_4), NULL);
			return TRUE;
		}

		if (ob_isstate(dialog -> tree, ASCII_ACTIF, SELECTED) && dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext[0] == '\0')
		{
			ob_dostate(dialog -> tree, HEXA_ACTIF, SELECTED);
			ob_undostate(dialog -> tree, ASCII_ACTIF, SELECTED);
			ob_set_cursor(dialog -> info, SEARCH_HEXA, MAX_EDIT, TRUE);

			ob_draw_chg(dialog -> info, ASCII_ACTIF, NULL, FAIL);
			ob_draw_chg(dialog -> info, HEXA_ACTIF, NULL, FAIL);
		}
		else
			if (ob_isstate(dialog -> tree, HEXA_ACTIF, SELECTED) && dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext[0] == '\0')
			{
				ob_undostate(dialog -> tree, HEXA_ACTIF, SELECTED);
				ob_dostate(dialog -> tree, ASCII_ACTIF, SELECTED);
				ob_set_cursor(dialog -> info, SEARCH_ASCII, MAX_EDIT, TRUE);

				ob_draw_chg(dialog -> info, ASCII_ACTIF, NULL, FAIL);
				ob_draw_chg(dialog -> info, HEXA_ACTIF, NULL, FAIL);
			}

		if (ob_isstate(dialog -> tree, ASCII_ACTIF, SELECTED))
		{
			strcpy(SearchString, dialog -> tree[SEARCH_ASCII].ob_spec.tedinfo -> te_ptext);
			SearchLength = (int)strlen(SearchString);
		}
		else
		{
			text = dialog -> tree[SEARCH_HEXA].ob_spec.tedinfo -> te_ptext;
			for (i=0; i<20 && text[i*2]; i++)
			{
				sscanf(&text[i*2], "%02x", &c);
				SearchString[i] = c;
			}
			SearchString[i] = '\0';
			SearchLength = i;
		}

		menu_ienable(Menu, CHERCHER_NOUVEAU, 1);

		switch (dialog -> thewin -> type)
		{
			case SECTEUR:
				if (SavePos)
					marquer_position(dialog -> thewin);

				search_secteur(dialog -> thewin, ob_isstate(dialog -> tree, DIFF_MAJ_MIN, SELECTED), TRUE);

				if (dialog -> thewin -> fonction.secteur.fichier)
					print_secteur_file(dialog -> thewin);
				break;

			case FICHIER:
			case FICHIER_FS:
			case RAW_FLOPPY:
			case RAW_HARD:
				if (SavePos)
					marquer_position(dialog -> thewin);

				search_secteur(dialog -> thewin, ob_isstate(dialog -> tree, DIFF_MAJ_MIN, SELECTED), TRUE);
				break;

			case TAMPON:
				search_tampon(dialog -> thewin, ob_isstate(dialog -> tree, DIFF_MAJ_MIN, SELECTED));
		}

		return TRUE;
	}

	return FALSE;
} /* search_proc */

/****************************************************************
*																*
*				recherche la chaŒne suivante					*
*																*
****************************************************************/
void search_next(windowptr thewin)
{
	int diff_majmin;

	{
		char text[160];

		sprintf(text, Messages(SEARCH_5), thewin -> title);
		ajoute(Firstwindow, text);
	}

	diff_majmin = Dialog[SEARCH].tree[DIFF_MAJ_MIN].ob_state & SELECTED;

	switch (thewin -> type)
	{
		case SECTEUR:
			if (SavePos)
				marquer_position(thewin);

			search_secteur(thewin, diff_majmin, TRUE);

			if (thewin -> fonction.secteur.fichier)
				print_secteur_file(thewin);
			break;

		case FICHIER:
		case FICHIER_FS:
		case RAW_FLOPPY:
		case RAW_HARD:
			if (SavePos)
				marquer_position(thewin);

			search_secteur(thewin, diff_majmin, TRUE);
			break;

		case TAMPON:
			search_tampon(thewin, diff_majmin);
	}
} /* search_next */

/****************************************************************
*																*
*				cherche une chaŒne dans le tampon				*
*																*
****************************************************************/
void search_tampon(windowptr thewin, boolean diff_majmin)
{
	register char *buffer, search_char;
	register int i, j;
	int start, curseur_x = thewin -> fonction.fichier.curseur_x, curseur_y = thewin -> fonction.fichier.curseur_y;

	buffer = Tampon -> fonction.tampon.secteurBin;
	start = curseur_x < 0 ? 0 : thewin -> fonction.fichier.curseur_y*32 + curseur_x/2 +1;

	search_char = SearchString[0];
	if (diff_majmin)
	{
		for (i=start; i<512; i++)
			if (buffer[i] == search_char)
			{
				for (j=1; j<SearchLength && i+j<512 && buffer[i+j] == SearchString[j]; j++)
					;
				if (j == SearchLength)
				{
					thewin -> fonction.fichier.curseur_x = 2*(i&31);
					thewin -> fonction.fichier.curseur_y = i/32;
					if (curseur_x < 0)
					{
						update_curseur(thewin, 2*(i&31), i/32, FAIL, FAIL, FALSE);
						menu_icheck(Menu, CURSEUR_VISIBLE, 1);
					}
					else
						update_curseur(thewin, 2*(i&31), i/32, curseur_x, curseur_y, FALSE);

					Efface = FALSE;
					redraw_window(thewin -> win, &thewin -> win -> work);
					return;
				}
			}
	}
	else
	{
		for (i=start; i<512; i++)
			if ((buffer[i] & 0xDF) == (search_char & 0xDF))
			{
				for (j=1; j<SearchLength && i+j<512 && (buffer[i+j] & 0xDF) == (SearchString[j] & 0xDF); j++)
					;
				if (j == SearchLength)
				{
					thewin -> fonction.fichier.curseur_x = 2*(i&31);
					thewin -> fonction.fichier.curseur_y = i/32;
					if (curseur_x < 0)
					{
						update_curseur(thewin, 2*(i&31), i/32, FAIL, FAIL, FALSE);
						menu_icheck(Menu, CURSEUR_VISIBLE, 1);
					}
					else
						update_curseur(thewin, 2*(i&31), i/32, curseur_x, curseur_y, FALSE);

					Efface = FALSE;
					redraw_window(thewin -> win, &thewin -> win -> work);
					return;
				}
			}
	}
} /* search_tampon */
