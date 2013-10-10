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

#include "deplace.h"
#include "dialog.h"
#include "fat.h"
#include "fenetre.h"
#include "curseur.h"
#include "update.h"
#include "divers.h"
#include "secteur.h"

/* variables locales */
typedef struct
{
	int ligne_abs;
	int ligne_rel;
	int nbr_lignes;
	t_goto *liste;
} goto_marque_var;

typedef struct
{
	windowptr thewin;
	long secteur, max;
	BPB bpb;
	char text[10];
} goto_secteur_var;

typedef struct
{
	windowptr thewin;
	char text[10];
	long offset;
	long size;
} goto_offset_var;

typedef struct
{
	windowptr thewin;
	char text[10];
	long secteur, max;
} goto_raw_secteur_var;

/****************************************************************
*																*
*	redessine le contenu de la boŒte de dialogue en temps r‚el	*
*																*
****************************************************************/
boolean update_goto_marque(windowptr thewin, int pos, int fast)
{
	t_dialog *dialog = find_dialog(thewin);
	goto_marque_var *var = dialog -> var;
	t_goto *liste_courant;
	int i;

	var -> ligne_abs = (int)((pos / 1000.0) * (var -> nbr_lignes-5));

	if (var -> ligne_abs > 0)
	{
		ob_doflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on peut remonter */
		ob_undostate(dialog -> tree, LISTE_UP, DISABLED);
		ob_draw(dialog -> info, LISTE_UP);
	}
	else
	{
		ob_undoflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on peut pas remonter */
		ob_dostate(dialog -> tree, LISTE_UP, DISABLED);
		ob_draw(dialog -> info, LISTE_UP);
	}

	if (var -> ligne_abs+5 >= var -> nbr_lignes)
	{
		ob_undoflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on ne peut plus descendre */
		ob_dostate(dialog -> tree, LISTE_DOWN, DISABLED);
		ob_draw(dialog -> info, LISTE_DOWN);
	}
	else
	{
		ob_doflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on peut descendre */
		ob_undostate(dialog -> tree, LISTE_DOWN, DISABLED);
		ob_draw(dialog -> info, LISTE_DOWN);
	}

	liste_courant = var -> liste;	/* initialise */

	for (i = 0; i < var -> ligne_abs; i++)	/* saute le d‚but de la liste */
		liste_courant = liste_courant -> suivant;

	for (i = 0; i < 5; i++, liste_courant = liste_courant -> suivant)
	{
		sprintf(dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
		ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
	}

	ob_undoflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
	ob_dostate(dialog -> tree, LISTE_OK, DISABLED);
	ob_draw(dialog -> info, LISTE_OK);

	ob_undoflag(dialog -> tree, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
	ob_dostate(dialog -> tree, EFFACE, DISABLED);
	ob_draw(dialog -> info, EFFACE);

	var -> ligne_rel = 0;

	ob_draw(dialog -> info, LISTE_BOX);

	dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
	ob_draw(dialog -> info, LISTE_PERE);

	return FALSE;
#pragma warn -par
} /* update_goto_marque */
#pragma warn .par

/****************************************************************
*																*
*	redessine le contenu de la boŒte de dialogue en temps r‚el	*
*																*
****************************************************************/
boolean update_goto_dialog(windowptr thewin, int pos, int fast)
{
	t_dialog *dialog = find_dialog(thewin);
	OBJECT *tree = dialog -> tree;
	goto_secteur_var *var_s = dialog -> var;
	goto_offset_var *var_o = dialog -> var;
	goto_raw_secteur_var *var_r = dialog -> var;

	switch (thewin -> type)
	{
		case SECTEUR:
			var_s -> secteur = pos * (var_s -> max /1000.);
			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var_s -> secteur);
				sprintf(tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var_s -> secteur - var_s -> bpb.datrec) / var_s -> bpb.clsiz +2));
			}
			else
			{
				sprintf(tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var_s -> secteur);
				sprintf(tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var_s -> secteur - var_s -> bpb.datrec) / var_s -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);
			break;

		case FICHIER:
		case FICHIER_FS:
			var_o -> offset = pos * (var_o -> size /1000.);
			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var_o -> offset);
				sprintf(tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext, "%d", (int)(var_o -> offset/(Thefrontwin -> fonction.fichier.sector_size * 512L)));
			}
			else
			{
				sprintf(tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var_o -> offset);
				sprintf(tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext, "$%X", (int)(var_o -> offset/(Thefrontwin -> fonction.fichier.sector_size * 512L)));
			}
			ob_draw(dialog -> info, OFFSET_ARRIVEE);
			ob_draw(dialog -> info, SECTEUR_OFFSET);
			ob_draw(dialog -> info, OFFSET_ARR_FOND);
			break;

		case RAW_HARD:
		case RAW_FLOPPY:
			var_r -> secteur = pos * (var_r -> max /1000.);
			if (thewin -> fonction.secteur.decimal)
				sprintf(tree[RAW_SECT_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var_r -> secteur);
			else
				sprintf(tree[RAW_SECT_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var_r -> secteur);
			ob_draw(dialog -> info, RAW_SECT_ARRIVEE);
			ob_draw(dialog -> info, RAW_SECT_FOND);
			break;
	}

	return FALSE;
#pragma warn -par
} /* update_goto_dialog */
#pragma warn .par

/****************************************************************
*																*
*		redessine le contenu de la fenˆtre en temps r‚el		*
*																*
****************************************************************/
boolean update_goto(windowptr thewin, int pos, int fast)
{
	long no_page, secteur;

	no_page = (thewin -> fonction.secteur.max * thewin -> fonction.secteur.sector_size -1) /1000. * pos;
	secteur = no_page / thewin -> fonction.secteur.sector_size;
	no_page -= secteur * thewin -> fonction.secteur.sector_size;

	thewin -> fonction.secteur.secteur = secteur;
	thewin -> fonction.secteur.page = (int)no_page;

	if ((!fast) && read_secteur(thewin, MENU_DEPLACEMENT) == -14)
		return FALSE;

	secteur_window_update(thewin, fast);

	if (thewin -> type == SECTEUR && thewin -> fonction.secteur.fichier)
		print_secteur_file(thewin);

	return fast;
} /* update_goto */

/****************************************************************
*																*
*					aller … la marque	 						*
*																*
****************************************************************/
void goto_marque(windowptr thewin)
{
	goto_marque_var *var = Dialog[LISTE_GOTO].var;
	OBJECT *goto_box = Dialog[LISTE_GOTO].tree;
	t_goto *liste_courant;
	int i;

	if (var == NULL)
	{
		if ((var = malloc(sizeof(goto_marque_var))) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return;
		}

		Dialog[LISTE_GOTO].var = var;
	}

	var -> ligne_abs = var -> ligne_rel = var -> nbr_lignes = 0;
	var -> liste = thewin -> fonction.secteur.goto_liste;

	/* d‚s‚lectionne les lignes */
	for (i = 0; i < 5; i++)
		ob_undostate(goto_box, LISTE_LIGNE_1, SELECTED);

	ob_undoflag(goto_box, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
	ob_dostate(goto_box, LISTE_OK, DISABLED);

	ob_undoflag(goto_box, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
	ob_dostate(goto_box, EFFACE, DISABLED);

	/* compte le nombre de lignes */
	liste_courant = thewin -> fonction.secteur.goto_liste;
	while (liste_courant)
	{
		liste_courant = liste_courant -> suivant;
		var -> nbr_lignes++;
	}

	/* initialise les ascenseurs */
	ob_undoflag(goto_box, LISTE_UP, TOUCHEXIT);	/* on est d‚j… en haut */
	ob_dostate(goto_box, LISTE_UP, DISABLED);
	goto_box[LISTE_FILS].ob_y = 0;
	if (var -> nbr_lignes > 5)
	{
		ob_doflag(goto_box, LISTE_DOWN, TOUCHEXIT);	/* on peut descendre */
		ob_undostate(goto_box, LISTE_DOWN, DISABLED);

		goto_box[LISTE_FILS].ob_height = goto_box[LISTE_PERE].ob_height *5 /var -> nbr_lignes;
		ob_doflag(goto_box, LISTE_FILS, TOUCHEXIT);
	}
	else
	{
		goto_box[LISTE_DOWN].ob_flags &= ~TOUCHEXIT;	/* toutes les lignes sont d‚j… visibles */
		ob_dostate(goto_box, LISTE_DOWN, DISABLED);

		goto_box[LISTE_FILS].ob_height = goto_box[LISTE_PERE].ob_height;
		ob_undoflag(goto_box, LISTE_FILS, TOUCHEXIT);
	}
	
	liste_courant = var -> liste;	/* initialise */

	/* initialise les entr‚es */
	for (i=0; i<5; i++)
	{
		goto_box[LISTE_LIGNE_1+i].ob_state &= ~SELECTED;

		if (liste_courant == NULL)
		{
			goto_box[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext[0] = '\0';
			ob_undoflag(goto_box, LISTE_LIGNE_1 + i, TOUCHEXIT);	/* pas s‚l‚ctionnable */
		}
		else
		{
			sprintf(goto_box[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
			ob_doflag(goto_box, LISTE_LIGNE_1 + i, TOUCHEXIT);	/* s‚l‚ctionnable */

			liste_courant = liste_courant -> suivant;
		}
	}

	Dialog[LISTE_GOTO].proc = goto_marque_proc;
	Dialog[LISTE_GOTO].thewin = thewin;
	my_open_dialog(&Dialog[LISTE_GOTO], AUTO_DIAL, FAIL);
} /* goto_marque */

/****************************************************************
*																*
*			choix dans la liste des positions (gestion)			*
*																*
****************************************************************/
boolean goto_marque_proc(t_dialog *dialog, int exit)
{
	goto_marque_var *var = dialog -> var;
	t_goto *liste_courant, *last;
	int i, ym, yb;

	switch (exit)
	{
		case LISTE_ANNULER:
			return TRUE;

		case LISTE_OK:
			liste_courant = var -> liste;

			for (i = 1; i < var -> ligne_abs + var -> ligne_rel; i++)	/* saute le d‚but de la liste */
				liste_courant = liste_courant -> suivant;
		
			if (dialog -> thewin -> fonction.secteur.curseur_x < 0)
				update_curseur(dialog -> thewin, liste_courant -> curseur_x, liste_courant -> curseur_y, FAIL, FAIL, FALSE);
			else
				update_curseur(dialog -> thewin, liste_courant -> curseur_x, liste_courant -> curseur_y, dialog -> thewin -> fonction.secteur.curseur_x, dialog -> thewin -> fonction.secteur.curseur_y, FALSE);
			dialog -> thewin -> fonction.secteur.curseur_x = liste_courant -> curseur_x;
			dialog -> thewin -> fonction.secteur.curseur_y = liste_courant -> curseur_y;
			menu_icheck(Menu, CURSEUR_VISIBLE, 1);

			dialog -> thewin -> fonction.secteur.page = liste_courant -> page;
			dialog -> thewin -> fonction.secteur.secteur = liste_courant -> secteur;

			read_secteur(dialog -> thewin, MENU_DEPLACEMENT);

			secteur_window_update(dialog -> thewin, FALSE);
			return TRUE;

		case LISTE_LIGNE_1:
		case LISTE_LIGNE_2:
		case LISTE_LIGNE_3:
		case LISTE_LIGNE_4:
		case LISTE_LIGNE_5:
			for (i = LISTE_LIGNE_1; i <= LISTE_LIGNE_5; i++)	/* toutes les lignes … 'z‚ro' */
				dialog -> tree[i].ob_state &= ~SELECTED;

			dialog -> tree[exit].ob_state |= SELECTED;	/* c'est la bonne */

			ob_doflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on peut sortir */
			ob_undostate(dialog -> tree, LISTE_OK, DISABLED);
			ob_draw(dialog -> info, LISTE_OK);

			ob_doflag(dialog -> tree, EFFACE, SELECTABLE);	/* on peut effacer */
			ob_undostate(dialog -> tree, EFFACE, DISABLED);
			ob_draw(dialog -> info, EFFACE);

			var -> ligne_rel = exit - LISTE_LIGNE_1 +1;

			ob_draw(dialog -> info, LISTE_BOX);
			break;

		case LISTE_UP:
			var -> ligne_abs--;	/* on remonte */

			ob_doflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on peut redescendre */
			ob_undostate(dialog -> tree, LISTE_DOWN, DISABLED);
			ob_draw(dialog -> info, LISTE_DOWN);

			if (var -> ligne_abs == 0)
			{
				ob_undoflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on est d‚j… en haut */
				ob_dostate(dialog -> tree, LISTE_UP, DISABLED);
				ob_draw(dialog -> info, LISTE_UP);
			}
			liste_courant = var -> liste;	/* initialise */

			for (i = 0; i < var -> ligne_abs; i++)	/* saute le d‚but de la liste */
				liste_courant = liste_courant -> suivant;

			for (i = 0; i < 5; i++, liste_courant = liste_courant -> suivant)
			{
				sprintf(dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
				ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
			}

			ob_undoflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
			ob_dostate(dialog -> tree, LISTE_OK, DISABLED);
			ob_draw(dialog -> info, LISTE_OK);

			ob_undoflag(dialog -> tree, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
			ob_dostate(dialog -> tree, EFFACE, DISABLED);
			ob_draw(dialog -> info, EFFACE);

			var -> ligne_rel = 0;

			ob_draw(dialog -> info, LISTE_BOX);

			dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
			ob_draw(dialog -> info, LISTE_PERE);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;

		case LISTE_DOWN:
			var -> ligne_abs++;	/* on descend */

			ob_doflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on peut remonter */
			ob_undostate(dialog -> tree, LISTE_UP, DISABLED);
			ob_draw(dialog -> info, LISTE_UP);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}

			if (var -> ligne_abs+5 >= var -> nbr_lignes)
			{
				ob_undoflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on ne peut plus descendre */
				ob_dostate(dialog -> tree, LISTE_DOWN, DISABLED);
				ob_draw(dialog -> info, LISTE_DOWN);
			}

			liste_courant = var -> liste;	/* initialise */

			for (i = 0; i < var -> ligne_abs; i++)	/* saute le d‚but de la liste */
				liste_courant = liste_courant -> suivant;

			for (i = 0; i < 5; i++, liste_courant = liste_courant -> suivant)
			{
				sprintf(dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
				ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
			}

			ob_undoflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
			ob_dostate(dialog -> tree, LISTE_OK, DISABLED);
			ob_draw(dialog -> info, LISTE_OK);

			ob_undoflag(dialog -> tree, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
			ob_dostate(dialog -> tree, EFFACE, DISABLED);
			ob_draw(dialog -> info, EFFACE);

			var -> ligne_rel = 0;

			ob_draw(dialog -> info, LISTE_BOX);

			dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
			ob_draw(dialog -> info, LISTE_PERE);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;

		case LISTE_FILS:
			real_time_slide(dialog -> thewin, dialog -> tree, LISTE_PERE, LISTE_FILS, Timer, update_goto_marque, TRUE);
			break;

		case LISTE_PERE:
			vq_mouse(x_handle, &i, &i, &ym);	/* position y de la souris */
			objc_offset(dialog -> tree, LISTE_FILS, &i, &yb);	/* position y du haut du FILS */
			if (ym < yb)	/* on a cliqu‚ au dessus */
				var -> ligne_abs = MAX(var -> ligne_abs - 5, 0);
			else
				var -> ligne_abs = MIN(var -> ligne_abs + 5, var -> nbr_lignes-5);

			if (var -> ligne_abs > 0)
			{
				ob_doflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on peut remonter */
				ob_undostate(dialog -> tree, LISTE_UP, DISABLED);
				ob_draw(dialog -> info, LISTE_UP);
			}
			else
			{
				ob_undoflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on peut pas remonter */
				ob_dostate(dialog -> tree, LISTE_UP, DISABLED);
				ob_draw(dialog -> info, LISTE_UP);
			}

			if (var -> ligne_abs+5 >= var -> nbr_lignes)
			{
				ob_undoflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on ne peut plus descendre */
				ob_dostate(dialog -> tree, LISTE_DOWN, DISABLED);
				ob_draw(dialog -> info, LISTE_DOWN);
			}
			else
			{
				ob_doflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on peut descendre */
				ob_undostate(dialog -> tree, LISTE_DOWN, DISABLED);
				ob_draw(dialog -> info, LISTE_DOWN);
			}

			liste_courant = var -> liste;	/* initialise */

			for (i = 0; i < var -> ligne_abs; i++)	/* saute le d‚but de la liste */
				liste_courant = liste_courant -> suivant;

			for (i = 0; i < 5; i++, liste_courant = liste_courant -> suivant)
			{
				sprintf(dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
				ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
			}

			ob_undoflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
			ob_dostate(dialog -> tree, LISTE_OK, DISABLED);
			ob_draw(dialog -> info, LISTE_OK);

			ob_undoflag(dialog -> tree, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
			ob_dostate(dialog -> tree, EFFACE, DISABLED);
			ob_draw(dialog -> info, EFFACE);

			var -> ligne_rel = 0;

			ob_draw(dialog -> info, LISTE_BOX);

			dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
			ob_draw(dialog -> info, LISTE_PERE);
			break;

		case EFFACE:
			if (var -> nbr_lignes == 1)	/* 1 seule ligne dans la liste */
			{
				liste_courant = var -> liste;
				dialog -> thewin -> fonction.secteur.goto_liste = NULL;
				var -> liste = NULL;
			}
			else
			{
				if (var -> ligne_abs + var -> ligne_rel == 1)
				{	/* on efface le premier */
					last = var -> liste -> suivant;
					*(var -> liste) = *(var -> liste -> suivant);	/* recopie le deuxiŠme dans le premier */
					var -> liste -> suivant = last;		/* il faut remettre le pointeur suivant du premier comme avant la copie */
					last = var -> liste;
				}
				else
				{
					last = var -> liste;

					for (i = 2; i < var -> ligne_abs + var -> ligne_rel; i++)	/* saute le d‚but de la liste */
						last = last -> suivant;
				}

				liste_courant = last -> suivant;
				if (liste_courant)
					last -> suivant = liste_courant -> suivant;
				else
					last -> suivant = NULL;	/* on efface le dernier */
			}
			free(liste_courant);

			var -> nbr_lignes--;
			if (var -> nbr_lignes > 5)
			{
				var -> ligne_abs = MIN(var -> ligne_abs, var -> nbr_lignes -5);	/* si on efface une des 5 derniŠres lignes */

				dialog -> tree[LISTE_FILS].ob_height = dialog -> tree[LISTE_PERE].ob_height *5 /var -> nbr_lignes;
				ob_doflag(dialog -> tree, LISTE_FILS, TOUCHEXIT);
				dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
			}
			else
			{
				var -> ligne_abs = 0;	/* toutes les lignes sont visibles */

				dialog -> tree[LISTE_FILS].ob_height = dialog -> tree[LISTE_PERE].ob_height;
				ob_undoflag(dialog -> tree, LISTE_FILS, TOUCHEXIT);
				dialog -> tree[LISTE_FILS].ob_y = 0;

				ob_undoflag(dialog -> tree, LISTE_UP, TOUCHEXIT);	/* on ne peut plus remonter */
				ob_dostate(dialog -> tree, LISTE_UP, DISABLED);
				ob_draw(dialog -> info, LISTE_UP);
			}

			if (var -> ligne_abs+5 >= var -> nbr_lignes)
			{
				ob_undoflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on ne peut plus descendre */
				ob_dostate(dialog -> tree, LISTE_DOWN, DISABLED);
				ob_draw(dialog -> info, LISTE_DOWN);
			}
			else
			{
				ob_doflag(dialog -> tree, LISTE_DOWN, TOUCHEXIT);	/* on peut descendre */
				ob_undostate(dialog -> tree, LISTE_DOWN, DISABLED);
				ob_draw(dialog -> info, LISTE_DOWN);
			}

			liste_courant = var -> liste;	/* initialise */

			for (i = 0; i < var -> ligne_abs; i++)	/* saute le d‚but de la liste */
				liste_courant = liste_courant -> suivant;

			for (i = 0; i < 5; i++)
				if (liste_courant == NULL)
				{
					dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext[0] = '\0';
					ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
				}
				else
				{
					sprintf(dialog -> tree[LISTE_LIGNE_1 + i].ob_spec.tedinfo -> te_ptext, "%7ld %5d %9ld %s", liste_courant -> secteur, liste_courant -> cluster, liste_courant -> offset, liste_courant -> text);
					ob_undostate(dialog -> tree, LISTE_LIGNE_1 + i, SELECTED);
					liste_courant = liste_courant -> suivant;
				}

			ob_undoflag(dialog -> tree, LISTE_OK, SELECTABLE | DEFAULT);	/* on ne sort pas tant qu'aucune ligne n'est s‚l‚ctionn‚e */
			ob_dostate(dialog -> tree, LISTE_OK, DISABLED);
			ob_draw(dialog -> info, LISTE_OK);

			ob_undoflag(dialog -> tree, EFFACE, SELECTABLE);	/* pas de ligne … effacer */
			ob_dostate(dialog -> tree, EFFACE, DISABLED);
			ob_draw(dialog -> info, EFFACE);

			var -> ligne_rel = 0;

			ob_draw(dialog -> info, LISTE_BOX);

			dialog -> tree[LISTE_FILS].ob_y = var -> ligne_abs*(dialog -> tree[LISTE_PERE].ob_height - dialog -> tree[LISTE_FILS].ob_height)/(var -> nbr_lignes - 5);
			ob_draw(dialog -> info, LISTE_PERE);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(dialog -> tree, exit, SELECTED))
			{
				/* angew„hltes Objekt deselektieren und neu zeichnen */
				ob_undostate(dialog -> tree, exit, SELECTED);
				ob_draw_chg(dialog -> info, exit, NULL, FAIL);
			}
			break;
	}

	return FALSE;
} /* goto_marque_proc */

/****************************************************************
*																*
*						page suivante	 						*
*																*
****************************************************************/
void next_secteur(windowptr thewin)
{
	int blocsize;

	blocsize = BlocSize;
	BlocSize = 1;
	next_bloc(thewin);
	BlocSize = blocsize;
} /* next_secteur */

/****************************************************************
*																*
*						page pr‚c‚dente							*
*																*
****************************************************************/
void previous_secteur(windowptr thewin)
{
	int blocsize;

	blocsize = BlocSize;
	BlocSize = 1;
	previous_bloc(thewin);
	BlocSize = blocsize;
} /* previous_secteur */

/****************************************************************
*																*
*				SizeBloc iŠme page suivante						*
*																*
****************************************************************/
void next_bloc(windowptr thewin)
{
	int i;
	long no_page = thewin -> fonction.secteur.secteur * thewin -> fonction.secteur.sector_size + thewin -> fonction.secteur.page;
	long max_page = thewin -> fonction.secteur.max * thewin -> fonction.secteur.sector_size -1;
	long secteur;

	if (no_page < max_page)
	{
		/* incr‚mente les pages */
		for (i=0; i < BlocSize && no_page < max_page; i++)
			no_page++;

		/* calcul le nouveau secteur et page */
		secteur = no_page / thewin -> fonction.secteur.sector_size;
		no_page -= secteur * thewin -> fonction.secteur.sector_size;

		if (secteur == thewin -> fonction.secteur.secteur)
		{	/* on reste sur le mˆme secteur */
			thewin -> fonction.secteur.page = (int)no_page;

			/* affichage */
			secteur_window_update(thewin, FALSE);
		}
		else
		{	/* on change de secteur */

#ifndef TEST_VERSION
			/* ‚crit le secteur ? */
			if (write_secteur(thewin, MENU_DEPLACEMENT))
				return;
#endif

			/* maintenant il est propre */
			thewin -> fonction.secteur.dirty = FALSE;

			/* nouvelle position */
			thewin -> fonction.secteur.secteur = secteur;
			thewin -> fonction.secteur.page = (int)no_page;

			/* un nouveau secteur */
			if (read_secteur(thewin, MENU_DEPLACEMENT) == -14)
				return;

			/* affichage */
			secteur_window_update(thewin, FALSE);

			/* infos supl‚mentaires */
			if (thewin -> type == SECTEUR && thewin -> fonction.secteur.fichier)
				print_secteur_file(thewin);
		}
	}
} /* next_bloc */

/****************************************************************
*																*
*				SizeBloc iŠme page pr‚c‚dente	 				*
*																*
****************************************************************/
void previous_bloc(windowptr thewin)
{
	int i;
	long no_page = thewin -> fonction.secteur.secteur * thewin -> fonction.secteur.sector_size + thewin -> fonction.secteur.page;
	long secteur;

	if (no_page > 0)
	{
		/* incr‚mente les pages */
		for (i=0; i < BlocSize && no_page; i++)
			no_page--;

		/* calcul le nouveau secteur et page */
		secteur = no_page / thewin -> fonction.secteur.sector_size;
		no_page -= secteur * thewin -> fonction.secteur.sector_size;

		if (thewin -> fonction.secteur.page != (int)no_page)
		{	/* changement de page */
			for (i=0; i<16; i++)
				sprintf(thewin -> fonction.secteur.Ligne[i+4], "%04lX  ", no_page*512L + i*32);
		}

		if (secteur == thewin -> fonction.secteur.secteur)
		{	/* on reste sur le mˆme secteur */
			thewin -> fonction.secteur.page = (int)no_page;

			/* affichage */
			secteur_window_update(thewin, FALSE);
		}
		else
		{	/* on change de secteur */

#ifndef TEST_VERSION
			/* ‚crit le secteur ? */
			if (write_secteur(thewin, MENU_DEPLACEMENT))
				return;
#endif

			/* maintenant il est propre */
			thewin -> fonction.secteur.dirty = FALSE;

			/* nouvelle position */
			thewin -> fonction.secteur.secteur = secteur;
			thewin -> fonction.secteur.page = (int)no_page;

			/* un nouveau secteur */
			if (read_secteur(thewin, MENU_DEPLACEMENT) == -14)
				return;

			/* affichage */
			secteur_window_update(thewin, FALSE);

			/* infos supl‚mentaires */
			if (thewin -> type == SECTEUR && thewin -> fonction.secteur.fichier)
				print_secteur_file(thewin);
		}
	}
} /* previous_bloc */

/****************************************************************
*																*
*				directement … un secteur						*
*																*
****************************************************************/
void goto_secteur(windowptr thewin)
{
	/******************* SECTEUR ********************/
	if (thewin -> type == SECTEUR)
	{
		goto_secteur_var *var = Dialog[SECTEUR_ARR].var;
		OBJECT *goto_secteur = Dialog[SECTEUR_ARR].tree;

		if (var == NULL)
		{
			if ((var = malloc(sizeof(goto_secteur_var))) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);
				return;
			}
	
			Dialog[SECTEUR_ARR].var = var;
		}

		var -> secteur = thewin -> fonction.secteur.secteur;
		var -> max = thewin -> fonction.secteur.max-1;
		var -> bpb = Bpb[thewin -> fonction.secteur.device];
		var -> thewin = thewin;

#ifndef TEST_VERSION
		if (write_secteur(thewin, MENU_DEPLACEMENT))
			return;
#endif

		thewin -> fonction.secteur.dirty = FALSE;

		goto_secteur[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (goto_secteur[SECT_ARRIVE_FOND].ob_width - goto_secteur[SECT_ARRIVE_BAR].ob_width));
		if (thewin -> fonction.secteur.decimal)
		{
			sprintf(var -> text, "%ld", var -> secteur);
			sprintf(goto_secteur[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
		}
		else
		{
			sprintf(var -> text, "$%lX", var -> secteur);
			sprintf(goto_secteur[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
		}
		strcpy(goto_secteur[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, var -> text);
	
		Dialog[SECTEUR_ARR].proc = goto_secteur_proc;
		Dialog[SECTEUR_ARR].thewin = thewin;
		my_open_dialog(&Dialog[SECTEUR_ARR], AUTO_DIAL, FAIL);
	}

	/******************* FICHIER ********************/
	/******************* FICHIER D'UN AUTRE FS ********************/
	if (thewin -> type == FICHIER || thewin -> type == FICHIER_FS)
	{
		goto_offset_var *var = Dialog[OFFSET_ARR].var;
		OBJECT *goto_offset = Dialog[OFFSET_ARR].tree;

		if (var == NULL)
		{
			if ((var = malloc(sizeof(goto_offset_var))) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);
				return;
			}
	
			Dialog[OFFSET_ARR].var = var;
		}

		var -> size = thewin -> fonction.fichier.max * thewin -> fonction.fichier.sector_size * 512L -1;
		var -> thewin = thewin;

#ifndef TEST_VERSION
		if (write_secteur(thewin, MENU_DEPLACEMENT))
			return;
#endif

		thewin -> fonction.fichier.dirty = FALSE;

		if (thewin -> fonction.fichier.curseur_x < 0)
			var -> offset = (thewin -> fonction.fichier.secteur * thewin -> fonction.fichier.sector_size + thewin -> fonction.fichier.page) * 512L;
		else
			var -> offset = (thewin -> fonction.fichier.secteur * thewin -> fonction.fichier.sector_size + thewin -> fonction.fichier.page) * 512L + thewin -> fonction.fichier.curseur_y*32 + thewin -> fonction.fichier.curseur_x/2;

		goto_offset[OFFSET_ARR_BARRE].ob_x = (int)((double)var -> offset / (double)var -> size * (goto_offset[OFFSET_ARR_FOND].ob_width - goto_offset[OFFSET_ARR_BARRE].ob_width));

		if (thewin -> fonction.secteur.decimal)
		{
			sprintf(var -> text, "%ld", var -> offset);
			sprintf(goto_offset[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext, "%d", (int)(var -> offset/(Thefrontwin -> fonction.fichier.sector_size * 512L)));
		}
		else
		{
			sprintf(var -> text, "$%lX", var -> offset);
			sprintf(goto_offset[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext, "$%X", (int)(var -> offset/(Thefrontwin -> fonction.fichier.sector_size * 512L)));
		}
		strcpy(goto_offset[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext, var -> text);

		Dialog[OFFSET_ARR].proc = goto_offset_proc;
		Dialog[OFFSET_ARR].thewin = thewin;
		my_open_dialog(&Dialog[OFFSET_ARR], AUTO_DIAL, FAIL);
	}

	/******************* RAW_FLOPPY ********************/
	/******************* RAW_HARD ********************/
	if (thewin -> type == RAW_FLOPPY || thewin -> type == RAW_HARD)
	{
		goto_raw_secteur_var *var = Dialog[RAW_SECTEUR_ARR].var;
		OBJECT *goto_secteur = Dialog[RAW_SECTEUR_ARR].tree;

		if (var == NULL)
		{
			if ((var = malloc(sizeof(goto_offset_var))) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);
				return;
			}
	
			Dialog[RAW_SECTEUR_ARR].var = var;
		}

		var -> secteur = thewin -> fonction.raw_floppy.secteur;
		var -> max = thewin -> fonction.raw_floppy.max -1;
		var -> thewin = thewin;

#ifndef TEST_VERSION
		if (write_secteur(thewin, MENU_DEPLACEMENT))
			return;
#endif

		thewin -> fonction.fichier.dirty = FALSE;

		goto_secteur[RAW_SECT_BAR].ob_x = (int)((double)var -> secteur / (double)var -> max * (goto_secteur[RAW_SECT_FOND].ob_width - goto_secteur[RAW_SECT_BAR].ob_width));

		if (thewin -> fonction.secteur.decimal)
			sprintf(var -> text, "%ld", var -> secteur);
		else
			sprintf(var -> text, "$%lX", var -> secteur);
		strcpy(goto_secteur[RAW_SECT_ARRIVEE].ob_spec.tedinfo -> te_ptext, var -> text);

		Dialog[RAW_SECTEUR_ARR].proc = goto_raw_secteur_proc;
		Dialog[RAW_SECTEUR_ARR].thewin = thewin;
		my_open_dialog(&Dialog[RAW_SECTEUR_ARR], AUTO_DIAL, FAIL);
	}
} /* goto_secteur */

/****************************************************************
*																*
*				d‚placement … un secteur (gestion)				*
*																*
****************************************************************/
boolean goto_secteur_proc(t_dialog *dialog, int exit)
{
	goto_secteur_var *var = dialog -> var;
	windowptr thewin = var -> thewin;
	int xm, xb, dummy;

	switch (exit)
	{
		case SECTEUR_ARR_ANNU:
			return TRUE;

		case SECTEUR_ARR_LIST:
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

			goto_marque(thewin);
			return TRUE;

		case SECTEUR_ARR_BOOT:
			var -> secteur = 0;
			var -> text[0] = '\0';	/* modifie l'ancien texte pour que la nouvelle valeure de secteur soit prise */

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;

		case SECTEUR_ARR_FAT1:
			var -> secteur = 1L;
			var -> text[0] = '\0';

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;

		case SECTEUR_ARR_FAT2:
			var -> secteur = (long)var -> bpb.fatrec;
			var -> text[0] = '\0';

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;

		case SECTEUR_ARR_ROOT:
			var -> secteur = (long)(var -> bpb.fatrec + var -> bpb.fsiz);
			var -> text[0] = '\0';

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;

		case SECTEUR_ARR_FRST:
			var -> secteur = (long)(var -> bpb.datrec);
			var -> text[0] = '\0';

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;

		case SECT_ARRIVE_BAR:
			real_time_slide(thewin, dialog -> tree, SECT_ARRIVE_FOND, SECT_ARRIVE_BAR, Timer, update_goto_dialog, FALSE);
			break;

		case SECT_ARRIVE_FOND:
			vq_mouse(x_handle, &dummy, &xm, &dummy);
			objc_offset(dialog -> tree, SECT_ARRIVE_BAR, &xb, &dummy);
			if (xm < xb)
				var -> secteur = MAX(var -> secteur - BlocSize, 0);
			else
				var -> secteur = MIN(var -> secteur + BlocSize, var -> max);

			dialog -> tree[SECT_ARRIVE_BAR].ob_x = (int)((float)var -> secteur / (float)var -> max * (dialog -> tree[SECT_ARRIVE_FOND].ob_width - dialog -> tree[SECT_ARRIVE_BAR].ob_width));
			ob_draw(dialog -> info, SECT_ARRIVE_FOND);

			if (thewin -> fonction.secteur.decimal)
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%d", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			else
			{
				sprintf(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%lX", var -> secteur);
				sprintf(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext, "$%X", (int)((var -> secteur - var -> bpb.datrec) / var -> bpb.clsiz +2));
			}
			ob_draw(dialog -> info, SECTEUR_ARRIVEE);
			ob_draw(dialog -> info, CLUSTER_ARRIVEE);
			break;
	}

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	if (exit == SECTEUR_ARR_OK)
	{
		/* on a modifi‚ le num‚ro de secteur ? */
		if (strcmp(var -> text, dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext))
		{
			if (dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext[0] == '$')
				sscanf(&dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext[1], "%lx", &var -> secteur);
			else
				var -> secteur = atol(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext);
		}
		else
		{ /* c'est le num‚ro de cluster qui a chang‚ */
			if (dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext[0] == '$')
				sscanf(&dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext[1], "%lx", &var -> secteur);
			else
				var -> secteur = atol(dialog -> tree[CLUSTER_ARRIVEE].ob_spec.tedinfo -> te_ptext);
			var -> secteur = (var -> secteur-2) * var -> bpb.clsiz + var -> bpb.datrec;
		}

		if (var -> secteur < 0)
			var -> secteur = 0;
		else
			if (var -> secteur > var -> max)
				var -> secteur = var -> max;
		thewin -> fonction.secteur.secteur = var -> secteur;

		/* au d‚but du secteur */
		thewin -> fonction.secteur.page = 0;

		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		if (read_secteur(thewin, MENU_DEPLACEMENT) == -14)
			return TRUE;

		secteur_window_update(thewin, FALSE);

		if (thewin -> fonction.secteur.fichier)
			print_secteur_file(thewin);

		return TRUE;
	}

	return FALSE;
} /* goto_secteur_proc */

/****************************************************************
*																*
*			d‚placement … un offset (fichier) (gestion)			*
*																*
****************************************************************/
boolean goto_offset_proc(t_dialog *dialog, int exit)
{
	goto_offset_var *var = dialog -> var;
	windowptr thewin = var -> thewin;
	int xm, xb, dummy;

	switch (exit)
	{
		case OFFSET_ARR_ANNUL:
			return TRUE;

		case OFFSET_ARR_BARRE:
			real_time_slide(thewin, dialog -> tree, OFFSET_ARR_FOND, OFFSET_ARR_BARRE, Timer, update_goto_dialog, FALSE);
			break;

		case OFFSET_ARR_FOND:
			vq_mouse(x_handle, &dummy, &xm, &dummy);
			objc_offset(dialog -> tree, OFFSET_ARR_BARRE, &xb, &dummy);
			if (xm < xb)
				var -> offset = MAX(var -> offset - BlocSize*512L, 0);
			else
				var -> offset = MIN(var -> offset + BlocSize*512L, var -> size);
			dialog -> tree[OFFSET_ARR_BARRE].ob_x = (int)((double)var -> offset / (double)var -> size * (dialog -> tree[OFFSET_ARR_FOND].ob_width - dialog -> tree[OFFSET_ARR_BARRE].ob_width));

			sprintf(dialog -> tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> offset);
			sprintf(dialog -> tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext, "%d", (int)(var -> offset/(thewin -> fonction.fichier.sector_size * 512L)));
			ob_draw(dialog -> info, SECTEUR_OFFSET);
			ob_draw(dialog -> info, OFFSET_ARRIVEE);
			ob_draw(dialog -> info, OFFSET_ARR_FOND);
			break;

		case OFFSET_ARR_LIST:
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

			goto_marque(thewin);
			return TRUE;
	}

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	if (exit == OFFSET_ARR_OK)
	{	/* on a modifi‚ l'offset d'arriv‚e */
		int slide;

		if (strcmp(dialog -> tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext, var -> text))
		{
			if (dialog -> tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext[0] == '$')
				sscanf(&dialog -> tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext[1], "%lx", &var -> offset);
			else
				var -> offset = atol(dialog -> tree[OFFSET_ARRIVEE].ob_spec.tedinfo -> te_ptext);

			var -> offset = MIN(var -> offset, var -> size);
			slide = (int)(var -> offset & 511L);

			if (thewin -> fonction.fichier.curseur_x < 0)
				update_curseur(thewin, 2*(slide&31), slide/32, FAIL, FAIL, FALSE);
			else
				update_curseur(thewin, 2*(slide&31), slide/32, thewin -> fonction.fichier.curseur_x, thewin -> fonction.fichier.curseur_y, FALSE);

			thewin -> fonction.fichier.curseur_x = 2*(slide&31);
			thewin -> fonction.fichier.curseur_y = slide/32;
			menu_icheck(Menu, CURSEUR_VISIBLE, 1);

			/* arrondi … 512 octets prŠs par d‚faut pour ˆtre en d‚but de secteur */
			var -> offset &= ~511L;
		}
		else
		{	/* non, c'est le secteur qui a ‚t‚ modifi‚ */
			if (dialog -> tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext[0] == '$')
				sscanf(&dialog -> tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext[1], "%lx", &var -> offset);
			else
				var -> offset = atol(dialog -> tree[SECTEUR_OFFSET].ob_spec.tedinfo -> te_ptext);

			var -> offset = MIN(var -> offset * thewin -> fonction.fichier.sector_size * 512L, var -> size);
		}

		if (var -> offset < 0)
			var -> offset = 0;

		thewin -> fonction.fichier.secteur = (int)(var -> offset/(thewin -> fonction.fichier.sector_size * 512L));
		thewin -> fonction.fichier.page = (int)((var -> offset - thewin -> fonction.fichier.secteur * thewin -> fonction.fichier.sector_size*512) / 512);

		my_close_dialog(dialog);

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);

		if (read_secteur(thewin, MENU_DEPLACEMENT) != -14)
			secteur_window_update(thewin, FALSE);
	}

	return FALSE;
} /* goto_offset_proc */

/****************************************************************
*																*
*			d‚placement … un secteur brut (gestion)				*
*																*
****************************************************************/
boolean goto_raw_secteur_proc(t_dialog *dialog, int exit)
{
	goto_raw_secteur_var *var = dialog -> var;
	windowptr thewin = var -> thewin;
	int xm, xb, dummy;

	switch (exit)
	{
		case RAW_SECT_ANNULER:
			return TRUE;

		case RAW_SECT_BAR:
			real_time_slide(thewin, dialog -> tree, RAW_SECT_FOND, RAW_SECT_BAR, Timer, update_goto_dialog, FALSE);
			break;

		case RAW_SECT_FOND:
			vq_mouse(x_handle, &dummy, &xm, &dummy);
			objc_offset(dialog -> tree, RAW_SECT_BAR, &xb, &dummy);
			if (xm < xb)
				var -> secteur = MAX(var -> secteur - BlocSize, 0);
			else
				var -> secteur = MIN(var -> secteur + BlocSize, var -> max);
			dialog -> tree[RAW_SECT_BAR].ob_x = (int)((double)var -> secteur / (double)var -> max * (dialog -> tree[RAW_SECT_FOND].ob_width - dialog -> tree[RAW_SECT_BAR].ob_width));

			sprintf(dialog -> tree[RAW_SECT_ARRIVEE].ob_spec.tedinfo -> te_ptext, "%ld", var -> secteur);
			ob_draw(dialog -> info, RAW_SECT_ARRIVEE);
			ob_draw(dialog -> info, RAW_SECT_FOND);
			break;

		case RAW_SECT_LISTE:
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

			goto_marque(thewin);
			return TRUE;
	}

	/* Exit-Objekt selektiert? */
	if (ob_isstate(dialog -> tree, exit, SELECTED))
	{
		/* angew„hltes Objekt deselektieren und neu zeichnen */
		ob_undostate(dialog -> tree, exit, SELECTED);
		ob_draw_chg(dialog -> info, exit, NULL, FAIL);
	}

	if (exit == RAW_SECT_OK)
	{
		if (dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext[0] == '$')
			sscanf(&dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext[1], "%lx", &var -> secteur);
		else
			var -> secteur = atol(dialog -> tree[SECTEUR_ARRIVEE].ob_spec.tedinfo -> te_ptext);

		if (var -> secteur < 0)
			var -> secteur = 0;
		else
			if (var -> secteur > var -> max)
				var -> secteur = var -> max;

		Thefrontwin -> fonction.raw_floppy.secteur = var -> secteur;

		if (read_secteur(Thefrontwin, MENU_DEPLACEMENT) != -14)
			secteur_window_update(thewin, FALSE);

		return TRUE;
	}

	return FALSE;
} /* goto_raw_secteur_proc */

/****************************************************************
*																*
*			enregistre une position dans la liste				*
*																*
****************************************************************/
void marquer_position(windowptr thewin)
{
	t_goto *liste;
	BPB bpb;
	int i, pos;
	char text[160];

	liste = thewin -> fonction.fichier.goto_liste;

	if (liste == NULL)
	{
		liste = malloc(sizeof(t_goto));
		thewin -> fonction.fichier.goto_liste = liste;
	}
	else
	{
		while (liste -> suivant)
			liste = liste -> suivant;
		liste -> suivant = malloc(sizeof(t_goto));
		liste = liste -> suivant;
	}
	liste -> suivant = NULL;

	switch (thewin -> type)
	{
		case FICHIER:
			liste -> secteur = thewin -> fonction.fichier.secteur;
			bpb = my_getbpb(thewin -> fonction.secteur.device);
			liste -> cluster = (int)((thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur] - bpb.datrec) / bpb.clsiz +2);
			liste -> page = thewin -> fonction.fichier.page;

			if (thewin -> fonction.secteur.curseur_x < 0)
			{
				liste -> curseur_x = 0;
				liste -> curseur_y = 0;
				pos = -9;
				liste -> offset = liste -> secteur * bpb.recsiz + liste -> page*512L;
			}
			else
			{
				liste -> curseur_x = thewin -> fonction.secteur.curseur_x;
				liste -> curseur_y = thewin -> fonction.secteur.curseur_y;
				pos = liste -> curseur_y*32 + liste -> curseur_x/2;
				liste -> offset = liste -> secteur * bpb.recsiz + liste -> page*512L + pos;
				pos -= 9;
			}

			if (thewin -> fonction.secteur.ascii)
				for (i=0; i<30; i++)
					liste -> text[i] = ((pos+i<0) || (pos+i>511)) ? '?' : (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] ? (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] : ZeroChar;
			else
			{
				liste -> text[0] = '$';
				pos += 5;	/* jusque 4 octets avant au lieu de 9 */
				for (i=0; i<15; i++)
					sprintf(liste -> text +i*2 +1, "%02X", ((pos+i<0) || (pos+i>511)) ? '?' : (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] ? (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] : ZeroChar);
			}
			break;

		case FICHIER_FS:
			liste -> secteur = thewin -> fonction.fichier_fs.secteur;
			liste -> cluster = 0;
			liste -> page = 0;

			if (thewin -> fonction.secteur.curseur_x < 0)
			{
				liste -> curseur_x = 0;
				liste -> curseur_y = 0;
				pos = -9;
				liste -> offset = liste -> secteur*512L;
			}
			else
			{
				liste -> curseur_x = thewin -> fonction.secteur.curseur_x;
				liste -> curseur_y = thewin -> fonction.secteur.curseur_y;
				pos = liste -> curseur_y*32 + liste -> curseur_x/2;
				liste -> offset = liste -> secteur*512L + pos;
				pos -= 9;
			}

			for (i=0; i<30; i++)
				liste -> text[i] = ((pos+i<0) || (pos+i>511)) ? '?' : thewin -> fonction.secteur.secteurBin[pos+i] ? thewin -> fonction.secteur.secteurBin[pos+i] : ZeroChar;
			break;

		case SECTEUR:
			liste -> secteur = thewin -> fonction.secteur.secteur;
			bpb = my_getbpb(thewin -> fonction.secteur.device);
			liste -> cluster = (int)((thewin -> fonction.secteur.secteur - bpb.datrec) / bpb.clsiz +2);
			liste -> page = thewin -> fonction.secteur.page;

			if (thewin -> fonction.secteur.curseur_x < 0)
			{
				liste -> curseur_x = 0;
				liste -> curseur_y = 0;
				pos = -9;
				liste -> offset = liste -> secteur * bpb.recsiz + liste -> page*512L;
			}
			else
			{
				liste -> curseur_x = thewin -> fonction.secteur.curseur_x;
				liste -> curseur_y = thewin -> fonction.secteur.curseur_y;
				pos = liste -> curseur_y*32 + liste -> curseur_x/2;
				liste -> offset = liste -> secteur * bpb.recsiz + liste -> page*512L + pos;
				pos -= 9;
			}

			for (i=0; i<30; i++)
				liste -> text[i] = ((pos+i<0) || (pos+i>511)) ? '?' : (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] ? (liste -> page*512L + thewin -> fonction.secteur.secteurBin)[pos+i] : ZeroChar;
			break;

		case RAW_FLOPPY:
			liste -> secteur = thewin -> fonction.raw_floppy.secteur;
			liste -> cluster = 0;
			liste -> page = 0;

			if (thewin -> fonction.secteur.curseur_x < 0)
			{
				liste -> curseur_x = 0;
				liste -> curseur_y = 0;
				pos = -9;
				liste -> offset = liste -> secteur * 512L;
			}
			else
			{
				liste -> curseur_x = thewin -> fonction.secteur.curseur_x;
				liste -> curseur_y = thewin -> fonction.secteur.curseur_y;
				pos = liste -> curseur_y*32 + liste -> curseur_x/2;
				liste -> offset = (liste -> secteur -1 ) * 512L + pos;
				pos -= 9;
			}

			for (i=0; i<30; i++)
				liste -> text[i] = ((pos+i<0) || (pos+i>511)) ? '?' : thewin -> fonction.secteur.secteurBin[pos+i] ? thewin -> fonction.secteur.secteurBin[pos+i] : ZeroChar;
			break;

		case RAW_HARD:
			liste -> secteur = thewin -> fonction.raw_hard.secteur;	/* il faut un long */
			liste -> offset = 0;
			liste -> cluster = 0;
			liste -> page = 0;

			if (thewin -> fonction.secteur.curseur_x < 0)
			{
				liste -> curseur_x = 0;
				liste -> curseur_y = 0;
				pos = -9;
			}
			else
			{
				liste -> curseur_x = thewin -> fonction.secteur.curseur_x;
				liste -> curseur_y = thewin -> fonction.secteur.curseur_y;
				pos = liste -> curseur_y*32 + liste -> curseur_x/2 -9;
			}

			for (i=0; i<30; i++)
				liste -> text[i] = ((pos+i<0) || (pos+i>511)) ? '?' : thewin -> fonction.secteur.secteurBin[pos+i] ? thewin -> fonction.secteur.secteurBin[pos+i] : ZeroChar;
			break;
	}

	sprintf(text, Messages(DEPLACE_1), thewin -> title, liste -> secteur, liste -> page, liste -> cluster, liste -> offset);
	ajoute(Firstwindow, text);
} /* marquer_positions */
