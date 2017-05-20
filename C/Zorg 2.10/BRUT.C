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

#include "brut.h"
#include "dialog.h"
#include "fenetre.h"
#include "wind.h"
#include "update.h"
#include "fat.h"
#include "divers.h"
#include "init.h"

/* variables locales */
typedef struct
{
	int config;
	int champ;
	int secteur;
	int piste;
	int last_bouton;
	t_raw_floppy_entry rawfloppy[6];
} raw_floppy_var;

typedef struct
{
	int config;
	int champ;
	long hrd_secteur;
	int mode;
	int device;
	int last_bouton;
	t_raw_hard_entry rawhard[6];
} raw_hard_var;

/********************************************************************
*																	*
*				Ouvre une disquette en mode RAW						*
*																	*
********************************************************************/
void raw_floppy(int config)
{
	OBJECT *raw = Dialog[RAW_DISQUETTE].tree;
	int i, mode;
	raw_floppy_var *var = Dialog[RAW_DISQUETTE].var;

	if (config)
		for (i=DISQUETTE_PERSO1; i<=DISQUETTE_PERSO6; i++)
		{
			raw[i].ob_type = G_FBOXTEXT;
			raw[i].ob_flags |= EDITABLE;
		}
	else
		for (i=DISQUETTE_PERSO1; i<=DISQUETTE_PERSO6; i++)
		{
			raw[i].ob_type = G_BOXTEXT;
			raw[i].ob_flags &= ~EDITABLE;
		}

	if (var == NULL)
	{
		if ((var = malloc(sizeof(raw_floppy_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[RAW_DISQUETTE].var = var;

		var -> champ = SECTEURS_COUNT;
		var -> last_bouton = FAIL;
	}

	/* copie dans des variables temporaires */
	for (i=0; i<6; i++)
	{
		var -> rawfloppy[i] = RawFloppy[i];
		strcpy(raw[i + DISQUETTE_PERSO1].ob_spec.tedinfo -> te_ptext, var -> rawfloppy[i].bouton);
	}

	var -> config = config;

	if (config)
	{
		var -> last_bouton = 0;

		raw[DISQUETTE_PERSO1].ob_state |= SELECTED;

		if (RawFloppy[0].secteurs == 10)
		{
			raw[SECTEURS_10].ob_state |= SELECTED;
			raw[SECTEURS_20].ob_state &= ~SELECTED;
			raw[SECTEURS_COUNT].ob_state &= ~SELECTED;
		}
		else
			if (RawFloppy[0].secteurs == 20)
			{
				raw[SECTEURS_10].ob_state &= ~SELECTED;
				raw[SECTEURS_20].ob_state |= SELECTED;
				raw[SECTEURS_COUNT].ob_state &= ~SELECTED;
			}
			else
			{
				sprintf(raw[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext, "%d", RawFloppy[0].secteurs);
				raw[SECTEURS_10].ob_state &= ~SELECTED;
				raw[SECTEURS_20].ob_state &= ~SELECTED;
				raw[SECTEURS_COUNT].ob_state |= SELECTED;
			}

		if (RawFloppy[0].pistes == 80)
		{
			raw[PISTES_80].ob_state |= SELECTED;
			raw[PISTES_82].ob_state &= ~SELECTED;
			raw[PISTES_COUNT].ob_state &= ~SELECTED;
		}
		else
			if (RawFloppy[0].pistes == 82)
			{
				raw[PISTES_80].ob_state &= ~SELECTED;
				raw[PISTES_82].ob_state |= SELECTED;
				raw[PISTES_COUNT].ob_state &= ~SELECTED;
			}
			else
			{
				sprintf(raw[PISTES_COUNT].ob_spec.tedinfo -> te_ptext, "%d", RawFloppy[0].pistes);
				raw[PISTES_80].ob_state &= ~SELECTED;
				raw[PISTES_82].ob_state &= ~SELECTED;
				raw[PISTES_COUNT].ob_state |= SELECTED;
			}

		if (RawFloppy[0].faces > 1)
		{
			raw[SIMPLE_FACE].ob_state &= ~SELECTED;
			raw[DOUBLE_FACE].ob_state |= SELECTED;
		}
		else
		{
			raw[SIMPLE_FACE].ob_state |= SELECTED;
			raw[DOUBLE_FACE].ob_state &= ~SELECTED;
		}

		if (RawFloppy[0].device == 'A')
		{
			raw[LECTEUR_A].ob_state |= SELECTED;
			raw[LECTEUR_B].ob_state &= ~SELECTED;
		}
		else
		{
			raw[LECTEUR_A].ob_state &= ~SELECTED;
			raw[LECTEUR_B].ob_state |= SELECTED;
		}
	}
	
	Dialog[RAW_DISQUETTE].proc = raw_floppy_proc;
	if (config)
		mode = AUTO_DIAL|MODAL|NO_ICONIFY;
	else
		mode = AUTO_DIAL;
	my_open_dialog(&Dialog[RAW_DISQUETTE], mode, config ? DISQUETTE_PERSO1 : FAIL);
} /* raw_floppy */

/********************************************************************
*																	*
*			Ouvre une disquette en mode RAW (gestion)				*
*																	*
********************************************************************/
boolean raw_floppy_proc(t_dialog *dialog, int exit)
{
	raw_floppy_var *var = dialog -> var;

	switch (exit)
	{
		case DISQUETTE_ANNULE:
			/* Exit-Objekt selektiert? */
			if (var -> config && var -> last_bouton > FAIL && ob_isstate(dialog -> tree, var -> last_bouton +DISQUETTE_PERSO1, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, var -> last_bouton +DISQUETTE_PERSO1, SELECTED);
				ob_draw_chg(dialog -> info, var -> last_bouton +DISQUETTE_PERSO1, NULL, FAIL);
			}
			return TRUE;

		case DISQUETTE_PERSO1:
		case DISQUETTE_PERSO2:
		case DISQUETTE_PERSO3:
		case DISQUETTE_PERSO4:
		case DISQUETTE_PERSO5:
		case DISQUETTE_PERSO6:
			if (var -> config && var -> last_bouton > FAIL)
			{
				/* Sauvegarde l'‚tat de l'ancienne d‚finition */
	
				if (dialog -> tree[SECTEURS_10].ob_state & SELECTED)
					var -> rawfloppy[var -> last_bouton].secteurs = 10;
				else
					if (dialog -> tree[SECTEURS_20].ob_state & SELECTED)
						var -> rawfloppy[var -> last_bouton].secteurs = 20;
					else
						var -> rawfloppy[var -> last_bouton].secteurs = atoi(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext);
	
				if (dialog -> tree[PISTES_80].ob_state & SELECTED)
					var -> rawfloppy[var -> last_bouton].pistes = 80;
				else
					if (dialog -> tree[PISTES_82].ob_state & SELECTED)
						var -> rawfloppy[var -> last_bouton].pistes = 82;
					else
						var -> rawfloppy[var -> last_bouton].pistes = atoi(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext);
	
				if (dialog -> tree[SIMPLE_FACE].ob_state & SELECTED)
					var -> rawfloppy[var -> last_bouton].faces = 1;
				else
					var -> rawfloppy[var -> last_bouton].faces = 2;
	
				if (dialog -> tree[LECTEUR_A].ob_state & SELECTED)
					var -> rawfloppy[var -> last_bouton].device = 'A';
				else
					var -> rawfloppy[var -> last_bouton].device = 'B';
	
				strcpy(var -> rawfloppy[var -> last_bouton].bouton, dialog -> tree[var -> last_bouton + DISQUETTE_PERSO1].ob_spec.tedinfo -> te_ptext);
			}
	
			/* affiche l'‚tat de la nouvelle d‚finition */
			if (var -> rawfloppy[exit-DISQUETTE_PERSO1].secteurs == 10)
			{
				ob_select(dialog -> info, dialog -> tree, SECTEURS_10, TRUE, TRUE);
				ob_select(dialog -> info, dialog -> tree, SECTEURS_20, FALSE, TRUE);
				ob_select(dialog -> info, dialog -> tree, SECTEURS_COUNT, FALSE, TRUE);
			}
			else
				if (var -> rawfloppy[exit-DISQUETTE_PERSO1].secteurs == 20)
				{
					ob_select(dialog -> info, dialog -> tree, SECTEURS_10, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, SECTEURS_20, TRUE, TRUE);
					ob_select(dialog -> info, dialog -> tree, SECTEURS_COUNT, FALSE, TRUE);
				}
				else
				{
					sprintf(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> rawfloppy[exit-DISQUETTE_PERSO1].secteurs);
					ob_select(dialog -> info, dialog -> tree, SECTEURS_10, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, SECTEURS_20, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, SECTEURS_COUNT, TRUE, TRUE);
					ob_draw(dialog -> info, SECTEURS_COUNT);
				}
	
			if (var -> rawfloppy[exit-DISQUETTE_PERSO1].pistes == 80)
			{
				ob_select(dialog -> info, dialog -> tree, PISTES_80, TRUE, TRUE);
				ob_select(dialog -> info, dialog -> tree, PISTES_82, FALSE, TRUE);
				ob_select(dialog -> info, dialog -> tree, PISTES_COUNT, FALSE, TRUE);
			}
			else
				if (var -> rawfloppy[exit-DISQUETTE_PERSO1].pistes == 82)
				{
					ob_select(dialog -> info, dialog -> tree, PISTES_80, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, PISTES_82, TRUE, TRUE);
					ob_select(dialog -> info, dialog -> tree, PISTES_COUNT, FALSE, TRUE);
				}
				else
				{
					sprintf(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> rawfloppy[exit-DISQUETTE_PERSO1].pistes);
					ob_select(dialog -> info, dialog -> tree, PISTES_80, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, PISTES_82, FALSE, TRUE);
					ob_select(dialog -> info, dialog -> tree, PISTES_COUNT, TRUE, TRUE);
					ob_draw(dialog -> info, PISTES_COUNT);
				}
	
			if (var -> rawfloppy[exit-DISQUETTE_PERSO1].faces > 1)
			{
				ob_select(dialog -> info, dialog -> tree, SIMPLE_FACE, FALSE, TRUE);
				ob_select(dialog -> info, dialog -> tree, DOUBLE_FACE, TRUE, TRUE);
			}
			else
			{
				ob_select(dialog -> info, dialog -> tree, SIMPLE_FACE, TRUE, TRUE);
				ob_select(dialog -> info, dialog -> tree, DOUBLE_FACE, FALSE, TRUE);
			}
	
			if (var -> rawfloppy[exit-DISQUETTE_PERSO1].device == 'A')
			{
				ob_select(dialog -> info, dialog -> tree, LECTEUR_A, TRUE, TRUE);
				ob_select(dialog -> info, dialog -> tree, LECTEUR_B, FALSE, TRUE);
			}
			else
			{
				ob_select(dialog -> info, dialog -> tree, LECTEUR_A, FALSE, TRUE);
				ob_select(dialog -> info, dialog -> tree, LECTEUR_B, TRUE, TRUE);
			}
	
			ob_draw(dialog -> info, var -> champ);
	
			if (var -> config)
			{
				var -> champ = exit;
				var -> last_bouton = exit - DISQUETTE_PERSO1;
			}

			/* Exit-Objekt selektiert? */
			if ((!var -> config) && ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			break;
	
		case SECTEURS_COUNT:
		case SECTEURS_10:
		case SECTEURS_20:
			ob_draw(dialog -> info, var -> champ);
			var -> champ = SECTEURS_COUNT;
			break;
	
		case PISTES_COUNT:
		case PISTES_80:
		case PISTES_82:
			ob_draw(dialog -> info, var -> champ);
			var -> champ = PISTES_COUNT;
			break;
	
		case SECTEURS_PLUS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> secteur = atoi(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> secteur < 99)
				var -> secteur++;

			sprintf(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> secteur);
			ob_draw(dialog -> info, SECTEURS_COUNT);
			var -> champ = SECTEURS_COUNT;
			break;
	
		case SECTEURS_MOINS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> secteur = atoi(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> secteur > 1)
				var -> secteur--;
	
			sprintf(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> secteur);
			ob_draw(dialog -> info, SECTEURS_COUNT);
			var -> champ = SECTEURS_COUNT;
			break;
	
		case PISTES_PLUS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> piste = atoi(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> piste < 99)
				var -> piste++;

			sprintf(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> piste);
			ob_draw(dialog -> info, PISTES_COUNT);
			var -> champ = PISTES_COUNT;
			break;
	
		case PISTES_MOINS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> piste = atoi(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> piste > 1)
				var -> piste--;
	
			sprintf(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext, "%d", var -> piste);
			ob_draw(dialog -> info, PISTES_COUNT);
			var -> champ = PISTES_COUNT;
			break;
	}

	if (var -> config)
	{
		/* Sauvegarde l'‚tat de la d‚finition courante */
		if (dialog -> tree[SECTEURS_10].ob_state & SELECTED)
			var -> rawfloppy[var -> last_bouton].secteurs = 10;
		else
			if (dialog -> tree[SECTEURS_20].ob_state & SELECTED)
				var -> rawfloppy[var -> last_bouton].secteurs = 20;
			else
				var -> rawfloppy[var -> last_bouton].secteurs = atoi(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext);

		if (dialog -> tree[PISTES_80].ob_state & SELECTED)
			var -> rawfloppy[var -> last_bouton].pistes = 80;
		else
			if (dialog -> tree[PISTES_82].ob_state & SELECTED)
				var -> rawfloppy[var -> last_bouton].pistes = 82;
			else
				var -> rawfloppy[var -> last_bouton].pistes = atoi(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext);

		if (dialog -> tree[SIMPLE_FACE].ob_state & SELECTED)
			var -> rawfloppy[var -> last_bouton].faces = 1;
		else
			var -> rawfloppy[var -> last_bouton].faces = 2;

		if (dialog -> tree[LECTEUR_A].ob_state & SELECTED)
			var -> rawfloppy[var -> last_bouton].device = 'A';
		else
			var -> rawfloppy[var -> last_bouton].device = 'B';

		strcpy(var -> rawfloppy[var -> last_bouton].bouton, dialog -> tree[var -> last_bouton + DISQUETTE_PERSO1].ob_spec.tedinfo -> te_ptext);
	}
	else
	{
		/* Sauvegarde l'‚tat de la d‚finition courante */
		if (dialog -> tree[SECTEURS_10].ob_state & SELECTED)
			var -> secteur = 10;
		else
			if (dialog -> tree[SECTEURS_20].ob_state & SELECTED)
				var -> secteur = 20;
			else
				var -> secteur = atoi(dialog -> tree[SECTEURS_COUNT].ob_spec.tedinfo -> te_ptext);

		if (dialog -> tree[PISTES_80].ob_state & SELECTED)
			var -> piste = 80;
		else
			if (dialog -> tree[PISTES_82].ob_state & SELECTED)
				var -> piste = 82;
			else
				var -> piste = atoi(dialog -> tree[PISTES_COUNT].ob_spec.tedinfo -> te_ptext);
	}

	if (exit == DISQUETTE_OK)
	{
		int i;

		/* Exit-Objekt selektiert? */
		if (ob_isstate(dialog -> tree, exit, SELECTED))
		{
			/* angew„hltes Objekt deselektieren und neu zeichnen */
			ob_undostate(dialog -> tree, exit, SELECTED);
			ob_draw_chg(dialog -> info, exit, NULL, FAIL);
		}

		/* Exit-Objekt selektiert? */
		if (var -> last_bouton > FAIL && ob_isstate(dialog -> tree, var -> last_bouton +DISQUETTE_PERSO1, SELECTED))
		{
			/* angew„hltes Objekt deselektieren und neu zeichnen */
			ob_undostate(dialog -> tree, var -> last_bouton +DISQUETTE_PERSO1, SELECTED);
			ob_draw_chg(dialog -> info, var -> last_bouton +DISQUETTE_PERSO1, NULL, FAIL);
		}

		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		if (var -> config)
		{
			/* recopie dans les vraies variables */
			for (i=0; i<6; i++)
				RawFloppy[i] = var -> rawfloppy[i];
		}
		else
			open_raw_floppy(var -> secteur, var -> piste, dialog -> tree[SIMPLE_FACE].ob_state & SELECTED ? 1 : 2, dialog -> tree[LECTEUR_A].ob_state & SELECTED ? 0 : 1);

		return TRUE;
	}

	return FALSE;
} /* raw_floppy_proc */

/********************************************************************
*																	*
*				Ouvre un disque dur en mode RAW						*
*																	*
********************************************************************/
void raw_hard(int config)
{
	OBJECT *raw = Dialog[RAW_DISQUE_DUR].tree;
	int i, mode;
	raw_hard_var *var = Dialog[RAW_DISQUE_DUR].var;

	if (config)
		for (i=HD_PERSO1; i<=HD_PERSO6; i++)
		{
			raw[i].ob_type = G_FBOXTEXT;
			raw[i].ob_flags |= EDITABLE;
		}
	else
		for (i=HD_PERSO1; i<=HD_PERSO6; i++)
		{
			raw[i].ob_type = G_BOXTEXT;
			raw[i].ob_flags &= ~EDITABLE;
		}

	if (var == NULL)
	{
		if ((var = malloc(sizeof(raw_hard_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[RAW_DISQUE_DUR].var = var;

		var -> champ = HD_SECTEUR_COUNT;
		if (RawHard[0].device > 31)
		{
			var -> device = RawHard[0].device -32;
			var -> mode = 3;
		}
		else
			if (RawHard[0].device > 15)
			{
				var -> device = RawHard[0].device -16;
				var -> mode = 2;
			}
			else
				if (RawHard[0].device > 7)
				{
					var -> device = RawHard[0].device -8;
					var -> mode = 1;
				}
				else
				{
					var -> device = RawHard[0].device;
					var -> mode = 0;
				}

		var -> last_bouton = FAIL;
	}

	/* copie dans des variables temporaires */
	for (i=0; i<6; i++)
	{
		var -> rawhard[i] = RawHard[i];
		strcpy(raw[i + HD_PERSO1].ob_spec.tedinfo -> te_ptext, var -> rawhard[i].bouton);
	}

	var -> config = config;
	
	if (config)
	{
		int mode, unit;

		/* affiche la d‚finition du premier bouton */
		sprintf(raw[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext, "%ld", var -> rawhard[0].size);

		unit = var -> rawhard[0].device;

		if (unit >= 24)
		{
			unit -= 24;
			mode = 3;
		}
		else
			if (unit >= 16)
			{
				unit -= 16;
				mode = 2;
			}
			else
				if (unit >= 8)
				{
					unit -= 8;
					mode = 1;
				}
				else
					mode = 0;

		raw[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[mode*2 +1].ob_spec.free_string;
		raw[HD_UNIT].ob_spec.tedinfo -> te_ptext = PopUpUnit.p_menu[unit*2 +1].ob_spec.free_string;

		raw[HD_PERSO1].ob_state |= SELECTED;

		var -> last_bouton = 0;
	}

	Dialog[RAW_DISQUE_DUR].proc = raw_hard_proc;
	if (config)
		mode = AUTO_DIAL|MODAL|NO_ICONIFY;
	else
		mode = AUTO_DIAL;
	my_open_dialog(&Dialog[RAW_DISQUE_DUR], mode, config ? HD_PERSO1 : FAIL);
} /* raw_hard */

/********************************************************************
*																	*
*			Ouvre un disque dur en mode RAW (gestion)				*
*																	*
********************************************************************/
boolean raw_hard_proc(t_dialog *dialog, int exit)
{
	raw_hard_var *var = dialog -> var;
	int unit;

	switch (exit)
	{
		case HD_ANNULER:
			/* Exit-Objekt selektiert? */
			if (var -> config && var -> last_bouton > FAIL && ob_isstate(dialog -> tree, var -> last_bouton +HD_PERSO1, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, var -> last_bouton +HD_PERSO1, SELECTED);
				ob_draw_chg(dialog -> info, var -> last_bouton +HD_PERSO1, NULL, FAIL);
			}
			return TRUE;

		case HD_PERSO1:
		case HD_PERSO2:
		case HD_PERSO3:
		case HD_PERSO4:
		case HD_PERSO5:
		case HD_PERSO6:
			if (var -> config && var -> last_bouton > FAIL)
			{
				/* sauvegarde l'‚tat de l'ancien bouton */
				unit = var -> device + var -> mode*8;

				var -> rawhard[var -> last_bouton].device = unit;
				var -> hrd_secteur = atol(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext);
				var -> rawhard[var -> last_bouton].size = var -> hrd_secteur;

				strcpy(var -> rawhard[var -> last_bouton].bouton, dialog -> tree[var -> last_bouton + HD_PERSO1].ob_spec.tedinfo -> te_ptext);
			}

			/* affiche l'‚tat du nouveau bouton */
			sprintf(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext, "%ld", var -> rawhard[exit - HD_PERSO1].size);
			unit = var -> rawhard[exit - HD_PERSO1].device;

			if (unit >= 24)
			{
				unit -= 24;
				var -> mode = 3;
			}
			else
				if (unit >= 16)
				{
					unit -= 16;
					var -> mode = 2;
				}
				else
					if (unit >= 8)
					{
						unit -= 8;
						var -> mode = 1;
					}
					else
						var -> mode = 0;

			var -> device = unit;
			dialog -> tree[HD_MODE].ob_spec.tedinfo -> te_ptext = PopUpMode.p_menu[var -> mode*2 +1].ob_spec.free_string;
			dialog -> tree[HD_UNIT].ob_spec.tedinfo -> te_ptext = PopUpUnit.p_menu[unit*2 +1].ob_spec.free_string;

			ob_draw(dialog -> info, HD_MODE);
			ob_draw(dialog -> info, HD_MODE_BUTTON);
			ob_draw(dialog -> info, HD_UNIT);
			ob_draw(dialog -> info, HD_UNIT_BUTTON);
			ob_draw(dialog -> info, HD_SECTEUR_COUNT);

			ob_draw(dialog -> info, var -> champ);

			if (var -> config)
			{
				var -> champ = exit;
				var -> last_bouton = exit - HD_PERSO1;
			}

			/* Exit-Objekt selektiert? */
			if ((!var -> config) && ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;

		case HD_MODE:
		case HD_MODE_TEXTE:
			PopUpMode.p_info = dialog -> info;
			Popup(&PopUpMode, POPUP_BTN_CHK, OBJPOS, 0, 0, &var -> mode, var -> mode*2 +1);
			break;

		case HD_MODE_BUTTON:
			PopUpMode.p_info = dialog -> info;
			Popup(&PopUpMode, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> mode, var -> mode*2 +1);
			break;

		case HD_SECTEUR_PLUS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> hrd_secteur = atol(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> hrd_secteur < 9999999L)
				var -> hrd_secteur++;

			sprintf(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext, "%ld", var -> hrd_secteur);
			var -> champ = HD_SECTEUR_COUNT;
			ob_draw(dialog -> info, var -> champ);
			break;

		case HD_SECTEUR_MOINS:
			ob_select(dialog -> info, dialog -> tree, exit, FALSE, TRUE);
			var -> hrd_secteur = atol(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext);
			if (var -> hrd_secteur > 1L)
				var -> hrd_secteur--;

			sprintf(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext, "%ld", var -> hrd_secteur);
			var -> champ = HD_SECTEUR_COUNT;
			ob_draw(dialog -> info, var -> champ);
			break;

		case HD_UNIT_TEXTE:
		case HD_UNIT:
			PopUpUnit.p_info = dialog -> info;
			Popup(&PopUpUnit, POPUP_BTN_CHK, OBJPOS, 0, 0, &var -> device, var -> device*2 +1);
			break;

		case HD_UNIT_BUTTON:
			PopUpUnit.p_info = dialog -> info;
			Popup(&PopUpUnit, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &var -> device, var -> device*2 +1);
			break;
	}

	unit = var -> device + var -> mode*8;
	var -> hrd_secteur = atol(dialog -> tree[HD_SECTEUR_COUNT].ob_spec.tedinfo -> te_ptext);

	if (var -> config && var -> last_bouton > FAIL)
	{
		/* sauvegarde l'‚tat du bouton actuel */
		var -> rawhard[var -> last_bouton].device = unit;
		var -> rawhard[var -> last_bouton].size = var -> hrd_secteur;

		strcpy(var -> rawhard[var -> last_bouton].bouton, dialog -> tree[var -> last_bouton + HD_PERSO1].ob_spec.tedinfo -> te_ptext);
	}

	if (exit == HD_OK)
	{
		int i;

		/* Exit-Objekt selektiert? */
		if (ob_isstate(dialog -> tree, exit, SELECTED))
		{
			/* angew„hltes Objekt deselektieren und neu zeichnen */
			ob_undostate(dialog -> tree, exit, SELECTED);
			ob_draw_chg(dialog -> info, exit, NULL, FAIL);
		}

		/* Exit-Objekt selektiert? */
		if (var -> last_bouton > FAIL && ob_isstate(dialog -> tree, var -> last_bouton +HD_PERSO1, SELECTED))
		{
			/* angew„hltes Objekt deselektieren und neu zeichnen */
			ob_undostate(dialog -> tree, var -> last_bouton +HD_PERSO1, SELECTED);
			ob_draw_chg(dialog -> info, var -> last_bouton +HD_PERSO1, NULL, FAIL);
		}

		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		if (var -> config)
		{
			/* recopie dans les vraies variables */
			for (i=0; i<6; i++)
				RawHard[i] = var -> rawhard[i];
		}
		else
			open_raw_hard(unit, var -> hrd_secteur);

		return TRUE;
	}

	return FALSE;
} /* raw_hard_proc */

/********************************************************************
*																	*
*				ouverture d'une disquette en RAW					*
*																	*
********************************************************************/
void open_raw_floppy(char secteur, char piste, char face, char lecteur)
{
	register windowptr thewin;
	int len;
	int err;
	char titre[61];

	sprintf(titre, Messages(BRUT_1), lecteur+'A');
	if ((thewin = new_window(SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, titre, NULL, secteurproc, RAW_FLOPPY, 3)) != NULL)
	{
		if ((thewin -> fonction.secteur.secteurBin = sector_alloc(512)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		/* entr‚e dans le menu */
		get_menu_entry(thewin, titre+1);

		thewin -> fonction.secteur.sector_size = 1;
		thewin -> fonction.secteur.page = 0;

		thewin -> fonction.raw_floppy.secteur = 1;
		thewin -> fonction.raw_floppy.piste = 0;
		thewin -> fonction.raw_floppy.face = 0;

		thewin -> fonction.raw_floppy.max_secteur = secteur;
		thewin -> fonction.raw_floppy.max_piste = piste-1;
		thewin -> fonction.raw_floppy.max_face = face-1;
		thewin -> fonction.raw_floppy.lecteur = lecteur;

		thewin -> fonction.raw_floppy.secteur = 0;
		thewin -> fonction.raw_floppy.max = piste * face * secteur -1;

		thewin -> fonction.raw_floppy.ascii = TRUE;
		thewin -> fonction.raw_floppy.dirty = FALSE;
		thewin -> fonction.raw_floppy.curseur_x = FAIL;
		thewin -> fonction.raw_floppy.curseur_y = FAIL;
		thewin -> fonction.raw_floppy.goto_liste = NULL;
		thewin -> fonction.raw_floppy.decimal = TRUE;

		if ((thewin -> fonction.raw_floppy.slide = make_slide(&thewin -> win -> work, thewin -> fonction.raw_floppy.max)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		if ((err = Floprd(thewin -> fonction.raw_floppy.secteurBin, 0L, lecteur, 1, 0, 0, 1)) != 0)
		{
			error_msg(err);
			if (err == -14)
				change_disque(Drive, TRUE);
		}

		len = sprintf(thewin -> fonction.raw_floppy.Ligne[0], Messages(FENETRE_11), 1, secteur, 0, piste-1, 0, face-1, 0, piste*secteur*face-1);

		for (; len<SECTEURLINESIZE*2; len++)	/* on efface la fin de la ligne */
			thewin -> fonction.secteur.Ligne[0][len] = ' ';
		thewin -> fonction.secteur.Ligne[0][SECTEURLINESIZE*2-1] = '\0';

		strncpy(thewin -> fonction.raw_floppy.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[3], "                                                                    ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[4], "0000  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[5], "0020  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[6], "0040  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[7], "0060  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[8], "0080  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[9], "00A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[10], "00C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[11], "00E0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[12], "0100  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[13], "0120  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[14], "0140  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[15], "0160  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[16], "0180  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[17], "01A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[18], "01C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_floppy.Ligne[19], "01E0  ", SECTEURLINESIZE);

		convert_sect(thewin -> fonction.raw_floppy.secteurBin, thewin -> fonction.raw_floppy.Ligne, TRUE);

		make_frontwin(thewin);

		if (err)
			redraw_window(thewin -> win, &thewin -> win -> work);

		sprintf(titre, Messages(BRUT_3), lecteur+'A');
		ajoute(Firstwindow, titre);
	}
} /* open_raw_floppy */

/********************************************************************
*																	*
*				ouverture d'un disque dur en RAW					*
*																	*
********************************************************************/
void open_raw_hard(int unit, long secteur)
{
	windowptr thewin;
	int len, err;
	char titre[61];

	if (unit < 8)
		sprintf(titre, Messages(BRUT_4), unit);
	else
		if (unit < 16)
			sprintf(titre, Messages(BRUT_5), unit-8);
		else
			if (unit < 24)
				sprintf(titre, Messages(BRUT_6), unit-16);
			else
				sprintf(titre, Messages(BRUT_7), unit-24);

	if ((thewin = new_window(SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE, titre, NULL, secteurproc, RAW_HARD, 3)) != NULL)
	{
		if ((thewin -> fonction.secteur.secteurBin = sector_alloc(512)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		/* entr‚e dans le menu */
		get_menu_entry(thewin, titre+1);

		thewin -> fonction.secteur.sector_size = 1;
		thewin -> fonction.secteur.page = 0;

		thewin -> fonction.raw_hard.secteur = 0;
		thewin -> fonction.raw_hard.device = unit;

		thewin -> fonction.raw_hard.max = secteur;

		thewin -> fonction.raw_hard.ascii = TRUE;
		thewin -> fonction.raw_hard.dirty = FALSE;
		thewin -> fonction.raw_hard.curseur_x = FAIL;
		thewin -> fonction.raw_hard.curseur_y = FAIL;
		thewin -> fonction.raw_hard.goto_liste = NULL;
		thewin -> fonction.raw_hard.decimal = TRUE;

		if ((thewin -> fonction.raw_floppy.slide = make_slide(&thewin -> win -> work, secteur)) == NULL)
		{
			dispose_window(thewin);
			return;
		}

		if ((err = my_DMAread(0L, 1, thewin -> fonction.raw_hard.secteurBin, unit)) != 0)
			error_msg(err);

		len = sprintf(thewin -> fonction.raw_hard.Ligne[0], Messages(FENETRE_12), 0L, secteur);

		for (; len<SECTEURLINESIZE*2; len++)	/* on efface la fin de la ligne */
			thewin -> fonction.secteur.Ligne[0][len] = ' ';
		thewin -> fonction.secteur.Ligne[0][SECTEURLINESIZE*2-1] = '\0';

		strncpy(thewin -> fonction.raw_hard.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[3], "                                                                    ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[4], "0000  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[5], "0020  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[6], "0040  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[7], "0060  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[8], "0080  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[9], "00A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[10], "00C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[11], "00E0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[12], "0100  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[13], "0120  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[14], "0140  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[15], "0160  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[16], "0180  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[17], "01A0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[18], "01C0  ", SECTEURLINESIZE);
		strncpy(thewin -> fonction.raw_hard.Ligne[19], "01E0  ", SECTEURLINESIZE);

		convert_sect(thewin -> fonction.raw_hard.secteurBin, thewin -> fonction.raw_hard.Ligne, TRUE);

		if (unit < 8)
			sprintf(titre, Messages(BRUT_9), unit);
		else
			if (unit < 16)
				sprintf(titre, Messages(BRUT_10), unit-8);
			else
				if (unit < 24)
					sprintf(titre, Messages(BRUT_11), unit-16);
				else
					sprintf(titre, Messages(BRUT_12), unit-24);

		make_frontwin(thewin);

		if (err)
			redraw_window(thewin -> win, &thewin -> win -> work);

		ajoute(Firstwindow, titre);
	}
} /* open_raw_hard */

/********************************************************************
*																	*
*				lit une suite de secteur en continue				*
*																	*
********************************************************************/
int my_floppy_read(char *buffer,
	int taille,		/* nombre de secteurs … charger */
	int offset,		/* num‚ro du secteur … partir de 1 */
	int secteurs,	/* taille d'une piste */
	int faces,		/* nombre de faces */
	char lecteur)	/* 0 ou 1 */
{
	int secteur, piste, face;
	int i, err;

	i = offset / (secteurs * faces);	/* piste */
	offset -= i * secteurs * faces;		/* secteur sur les 2 pistes */
	face = offset >= secteurs ? offset -= secteurs, 1 : 0;
	secteur = offset+1;
	piste = i;

	i = secteurs - secteur +1;	/* la fin de la piste */
	if (i > taille)
		i = taille;

	if ((err = Floprd(buffer, 0L, lecteur, secteur, piste, face, i)) != 0)
		return err;

	taille -= i;
	while (taille > 0)
	{	/* il en reste … lire */
		buffer += i*512L;
		i = secteurs;	/* au max une piste entiŠre */
		if (i > taille)
			i = taille;

		if (faces > 1)	/* 2 faces */
			if (face == 0)	/* mˆme piste */
				err = Floprd(buffer, 0L, lecteur, 1, piste, ++face, i);
			else
			{
				err = Floprd(buffer, 0L, lecteur, 1, ++piste, 0, i);
				face = 0;
			}
		else	/* 1 face */
			err = Floprd(buffer, 0L, lecteur, 1, ++piste, 0, i);

		if (err)
			return err;

		taille -= i;
	}
	return 0;
} /* my_floppy_read */

/********************************************************************
*																	*
*						Rwabs plus g‚n‚ral							*
*																	*
********************************************************************/
int my_rwabs(int rwflag, char *buff /* au lieu de (void *) */, int cnt, long recnr /* au lieu de (int) */, int dev)
{
	long err = 0;

	if (dev < 0)	/* utilise Fread et Fwrite */
	{
		long len;

		dev = -dev;

		if ((len = Fseek(recnr * 512L, dev, 0)) < 0)	/* on se d‚place */
		{
			error_msg((int)len);
			return (int)len;
		}

#ifndef TEST_VERSION
		if (rwflag == 0)
		{
#endif
			len = Fread(dev, cnt * 512L, buff);
			if (len < 0)
			{
				error_msg((int)len);
				return (int)len;
			}
			if (len < 512L)
				for (; len<512L; len++)
					buff[len] = '\0';
#ifndef TEST_VERSION
		}
		else
			if ((len = Fwrite(dev, cnt * 512L, buff)) < 0)
			{
				error_msg((int)len);
				return (int)len;
			}
#endif
	}
	else
	{
#ifndef TEST_VERSION
		/* ‚criture ? */
		if (rwflag == 1)
			/* la partition n'est plus bonne */
			StructureTest[dev] = FALSE;
#endif

		/* on peut utiliser Rwabs ? */
		if (recnr < 0x10000L && (!ZorgInf || dev<2))	/* tiens sur un (signed int) */
#ifdef TEST_VERSION
			err = (int)Rwabs(0, buff, cnt, (unsigned int)recnr, dev);
#else
			err = (int)Rwabs(rwflag, buff, cnt, (unsigned int)recnr, dev);
#endif
		else
		/* on sort de l'ensemble de def de rwabs */
			if (Partition[dev].devno >= 0 && recnr < Partition[dev].size)
#ifdef TEST_VERSION
				err = my_DMAread(Partition[dev].start + recnr*(Partition[dev].bpb.recsiz/512), cnt*(Partition[dev].bpb.recsiz/512), buff, Partition[dev].devno);
#else
				if (rwflag == 1)
					err = my_DMAwrite(Partition[dev].start + recnr*(Partition[dev].bpb.recsiz/512), cnt*(Partition[dev].bpb.recsiz/512), buff, Partition[dev].devno);
				else
					err = my_DMAread(Partition[dev].start + recnr*(Partition[dev].bpb.recsiz/512), cnt*(Partition[dev].bpb.recsiz/512), buff, Partition[dev].devno);
#endif
			else
				err = -15;	/* P‚riph‚rique inconnu */
	}

	if (err)
		error_msg((int)err);

	return (int)err;
} /* my_rwabs */

/********************************************************************
*																	*
*				DMAread ou ma routine suivant devno					*
*																	*
********************************************************************/
int my_DMAread(long sector, int count, char *buffer, int devno)
{
	int err = 0;

	if (devno < 24)
		err = DMAread(sector, count, buffer, devno);
	else
		err = hard_read(sector, count, buffer, devno - 16);

	return err;
} /* my_DMAread */

/********************************************************************
*																	*
*				DMAwrite ou ma routine suivant devno				*
*																	*
********************************************************************/
#ifndef TEST_VERSION
int my_DMAwrite(long sector, int count, char *buffer, int devno)
{
	int err;

	if (devno < 24)
		err = DMAwrite(sector, count, buffer, devno);
	else
		err = hard_write(sector, count, buffer, devno - 16);

	return err;
} /* my_DMAwrite */
#endif

/********************************************************************
*																	*
*				malloc un bout de RAM pour un secteur				*
*																	*
********************************************************************/
void *sector_alloc(unsigned int size)
{
	char *tmp;

	if ((tmp = malloc((size_t)size)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return NULL;
	}
	else
	{
		memset(tmp, 0, (size_t)size);
		return tmp;
	}
} /* sector_alloc */

/********************************************************************
*																	*
*					free un bout de RAM pour un secteur				*
*																	*
********************************************************************/
void sector_free(void *ptr)
{
	free(ptr);
} /* sector_free */
