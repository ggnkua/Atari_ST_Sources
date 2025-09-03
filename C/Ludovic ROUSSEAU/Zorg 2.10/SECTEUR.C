/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>

#include "globals.h"
#include "zorg.h"

#include "brut.h"
#include "curseur.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "fenetre.h"
#include "secteur.h"

/****************************************************************
*																*
*				affiche la position en d‚cimal					*
*																*
****************************************************************/
void affichage_decimal(windowptr thewin)
{
	if (thewin -> type == OCCUP)
	{
		thewin -> fonction.occup.decimal ^= 1;

		menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.occup.decimal);
	}
	else
	{
		thewin -> fonction.secteur.decimal ^= 1;

		menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.secteur.decimal);

		secteur_window_update(thewin, FALSE);
	}
} /* affichage_decimal */

/****************************************************************
*																*
*					secteur en texte ASCII						*
*																*
****************************************************************/
void secteur_ascii(windowptr thewin)
{
	if (!thewin -> fonction.secteur.ascii)
		switch (thewin -> type)
		{
			case SECTEUR:
			case FICHIER:
			case FICHIER_FS:
			case RAW_FLOPPY:
			case RAW_HARD:
				thewin -> fonction.secteur.ascii = TRUE;

				menu_icheck(Menu, VISU_ASCII, 1);
				menu_icheck(Menu, VISU_HEXA, 0);

				secteur_window_update(thewin, FALSE);

				update_curseur(thewin, thewin -> fonction.secteur.curseur_x &= ~1, thewin -> fonction.secteur.curseur_y, thewin -> fonction.secteur.curseur_x, thewin -> fonction.secteur.curseur_y, thewin -> fonction.secteur.curseur_x>=0);
				break;

			case TAMPON:
				thewin -> fonction.secteur.ascii = TRUE;

				menu_icheck(Menu, VISU_ASCII, 1);
				menu_icheck(Menu, VISU_HEXA, 0);

				convert_sect(thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

				Efface = FALSE;
				redraw_window(thewin -> win, &thewin -> win -> work);

				update_curseur(thewin, thewin -> fonction.secteur.curseur_x &= ~1, thewin -> fonction.secteur.curseur_y, thewin -> fonction.secteur.curseur_x, thewin -> fonction.secteur.curseur_y, thewin -> fonction.secteur.curseur_x>=0);
				break;
	}
} /* secteur_ascii */

/****************************************************************
*																*
*				secteur en texte hexad‚cimal					*
*																*
****************************************************************/
void secteur_hexa(windowptr thewin)
{
	if (thewin -> fonction.secteur.ascii)
		switch (thewin -> type)
		{
			case SECTEUR:
			case FICHIER:
			case FICHIER_FS:
			case RAW_FLOPPY:
			case RAW_HARD:
				thewin -> fonction.secteur.ascii = FALSE;

				menu_icheck(Menu, VISU_ASCII, 0);
				menu_icheck(Menu, VISU_HEXA, 1);

				secteur_window_update(thewin, FALSE);
				break;

			case TAMPON:
				thewin -> fonction.secteur.ascii = FALSE;

				menu_icheck(Menu, VISU_ASCII, 0);
				menu_icheck(Menu, VISU_HEXA, 1);

				convert_sect(thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

				Efface = FALSE;
				redraw_window(thewin -> win, &thewin -> win -> work);
				break;
	}
} /* secteur_hexa */

/****************************************************************
*																*
*						recharge le secteur						*
*																*
****************************************************************/
void load_secteur(windowptr thewin, int menu)
{
	if (!thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_1), Messages(BOOT_32)) == 1 || thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_2), Messages(BOOT_32)) == 1)
		return;

	if (read_secteur(thewin, menu))
		return;

	thewin -> fonction.secteur.dirty = FALSE;

	convert_sect(thewin -> fonction.secteur.page*512 + thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

	redraw_window(thewin -> win, &thewin -> win -> work);
} /* load_secteur */

/****************************************************************
*																*
*						sauve le secteur						*
*																*
****************************************************************/
#ifndef TEST_VERSION
void save_secteur(windowptr thewin, int menu)
{
	if (!thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_3), Messages(BOOT_32)) == 1 || thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_4), Messages(BOOT_32)) == 1)
		return;

	if (write_secteur(thewin, menu))
		return;

	thewin -> fonction.secteur.dirty = FALSE;
} /* save_secteur */
#endif

/****************************************************************
*																*
*			charge le secteur sans poser de question			*
*																*
****************************************************************/
int read_secteur(windowptr thewin, int title)
{
	int err = 0;

	switch (thewin -> type)
	{
		case SECTEUR:
			if (my_rwabs(0, thewin -> fonction.secteur.secteurBin, 1, thewin -> fonction.secteur.secteur, thewin -> fonction.secteur.device) == -14)
			{
				menu_tnormal(Menu, title, 1);
				change_disque(thewin -> fonction.secteur.device, TRUE);
				err = -14;
			}
			break;

		case FICHIER:
			if (my_rwabs(0, thewin -> fonction.fichier.secteurBin, 1, thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur], thewin -> fonction.fichier.device) == -14)
			{
				menu_tnormal(Menu, title, 1);
				change_disque(thewin -> fonction.fichier.device, TRUE);
				err = -14;
			}
			break;

		case FICHIER_FS:
			my_rwabs(0, thewin -> fonction.fichier_fs.secteurBin, 1, thewin -> fonction.fichier_fs.secteur, thewin -> fonction.fichier_fs.file_desc);
			break;

		case RAW_FLOPPY:
			if ((err = my_floppy_read(thewin -> fonction.raw_floppy.secteurBin,  1, (int)thewin -> fonction.raw_floppy.secteur, thewin -> fonction.raw_floppy.max_secteur, thewin -> fonction.raw_floppy.max_face+1, thewin -> fonction.raw_floppy.lecteur)) != 0)
			{
				error_msg(err);
				if (err == -14)
				{
					menu_tnormal(Menu, title, 1);
					change_disque(0, TRUE);
				}
			}
			break;

		case RAW_HARD:
			if ((err = my_DMAread(thewin -> fonction.raw_hard.secteur, 1, thewin -> fonction.raw_hard.secteurBin, thewin -> fonction.raw_hard.device)) != 0)
				error_msg(err);
			break;
	}

	return err;
} /* read_secteur */

/****************************************************************
*																*
*			sauve le secteur sans 'trop' poser de question		*
*																*
****************************************************************/
#ifndef TEST_VERSION
int write_secteur(windowptr thewin, int title)
{
	int err = 0;

	/* secteur pas sale ou (sale et pas … sauver) */
	if (title == MENU_DEPLACEMENT && (!thewin -> fonction.secteur.dirty || thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_4), Messages(BOOT_32)) == 1))
		return 0;

	switch (thewin -> type)
	{
		case SECTEUR:
			if (my_rwabs(1, thewin -> fonction.secteur.secteurBin, 1, thewin -> fonction.secteur.secteur, thewin -> fonction.secteur.device) == -14)
			{
				menu_tnormal(Menu, title, 1);
				change_disque(thewin -> fonction.secteur.device, TRUE);
			}
			break;

		case FICHIER:
			if (my_rwabs(1, thewin -> fonction.fichier.secteurBin, 1, thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur], thewin -> fonction.fichier.device) == -14)
			{
				menu_tnormal(Menu, title, 1);
				change_disque(thewin -> fonction.fichier.device, TRUE);
			}
			break;

		case FICHIER_FS:
			my_rwabs(1, thewin -> fonction.fichier_fs.secteurBin, 1, thewin -> fonction.fichier_fs.secteur, thewin -> fonction.fichier_fs.file_desc);
			break;

		case RAW_FLOPPY:
			if ((err = Flopwr(thewin -> fonction.raw_floppy.secteurBin, 0L, thewin -> fonction.raw_floppy.lecteur, thewin -> fonction.raw_floppy.real_secteur, thewin -> fonction.raw_floppy.piste, thewin -> fonction.raw_floppy.face, 1)) != 0)
			{
				error_msg(err);
				if (err == -14)
				{
					menu_tnormal(Menu, title, 1);
					change_disque(0, TRUE);
				}
			}
			break;

		case RAW_HARD:
			if ((err = my_DMAwrite(thewin -> fonction.raw_hard.secteur, 1, thewin -> fonction.raw_hard.secteurBin, thewin -> fonction.raw_hard.device)) != 0)
				error_msg(err);
			break;
	}

	return err;
} /* write_secteur */
#endif