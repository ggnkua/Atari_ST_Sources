/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>
#include <math.h>

#include "globals.h"
#include "zorg.h"

#include "fenetre.h"
#include "curseur.h"
#include "deplace.h"
#include "dialog.h"
#include "divers.h"
#include "fat.h"
#include "info.h"
#include "init.h"
#include "ouvre.h"
#include "secteur.h"
#include "update.h"
#include "wind.h"

/****************************************************************
*																*
*		assigne une touche de fonction … une fenˆtre			*
*																*
****************************************************************/
void get_menu_entry(windowptr thewin, char *nom)
{
	int keys = 0, i;
	windowptr cur_win;

	for (cur_win = Firstwindow; cur_win != NULL; cur_win = cur_win -> next)
		if (cur_win -> menu_entry > FAIL)
			keys |= 1 << cur_win -> menu_entry;

	for (i=0; i<10; i++)
		if ((keys & (1 << i)) == 0)
		{
			thewin -> menu_entry = i;
			break;
		}

	if (i < 10)
	{
		/* texte du menu */
		get_max_name(nom, MenuShortCuts[6].menu[WINDOW_LIST_1 - CHOIX_FONTE +thewin -> menu_entry].text, MenuShortCuts[6].size -SHORTCUT_SIZE -1, TRUE);

		/* actif */
		menu_ienable(Menu, WINDOW_LIST_1 + thewin -> menu_entry, TRUE);

		/* popup des raccourcis claviers */
		strncpy(PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 +thewin -> menu_entry].ob_spec.free_string +1, MenuShortCuts[6].menu[WINDOW_LIST_1 - CHOIX_FONTE +thewin -> menu_entry].text, MenuShortCuts[6].size -SHORTCUT_SIZE -1);
		PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 +thewin -> menu_entry].ob_state &= ~DISABLED;
	}
} /* get_window_entry */

/****************************************************************
*																*
*					flip/flap les ascenseurs					*
*																*
****************************************************************/
void ascenseurs(windowptr thewin)
{
	WIN *win = thewin -> win;
	int x, y, w, h;
	int gadgets = win -> gadgets, vdi_handle = win -> vdi_handle;
	GRECT max = win -> max, curr = win -> curr;
	void (*redraw_proc)(int ,WIN *, GRECT *) = win -> redraw;
	int i;

	if (thewin -> kind_c & VSLIDE)
	{
		gadgets ^= VSLIDE;
		gadgets ^= UPARROW;	/* on a forcement les flŠches avec */
		gadgets ^= DNARROW;
	}

	if (thewin -> kind_c & HSLIDE)
	{
		gadgets ^= HSLIDE;
		gadgets ^= LFARROW;	/* idem pr‚c‚dement */
		gadgets ^= RTARROW;
	}

	if (thewin -> kind_c & SIZER)
		gadgets ^= SIZER;

	wind_get(win -> handle, WF_FULLXYWH, &x, &y, &w, &h);

	close_window(win, FALSE);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	if ((win = open_window(thewin -> title, thewin -> title, thewin -> info, NULL, gadgets, FALSE, 10, 10, &max, &curr, NULL, redraw_proc, NULL, 0)) == NULL)
	{
		my_alert(1, FAIL, X_ICN_ALERT, Messages(LANCE_3), NULL);
		shutdown(Reset);
	}

	thewin -> win = win;

	for (i=0; i<WinEntrees; i++)
		if (Windows[i].fenetre == thewin)
		{
			Windows[i].type = gadgets;
			break;
		}

	/* on change la station VDI associ‚e */
	win -> vdi_handle = vdi_handle;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	taille_ideale(thewin);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	make_frontwin(thewin);
} /* ascenseurs */

/****************************************************************
*																*
*				ajoute un texte dans une fenˆtre				*
*																*
****************************************************************/
void ajoute(windowptr thewin, char *text)
{
	WIN *win = thewin -> win;
	int len = (int)strlen(text) +1, ligne, LineNumberMax = thewin -> fonction.text.LineNumberMax;
	char *c;
	float a, b;
	int taille_page, vslide;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* plus de place dans le tampon des lignes */
	if (thewin -> fonction.text.LineNumber == LineNumberMax)
	{
		/* le plus vieux texte est celui suivant le dernier entr‚ (le tableau est plein) */
		ligne = thewin -> fonction.text.CurrentLine;

		thewin -> fonction.text.LineNumber--;
		thewin -> fonction.text.ligne--;

		/* libŠre le texte de cette ligne */
		if (thewin -> fonction.text.Ligne[ligne] > thewin -> fonction.text.debut)
		{
			/* la ligne se trouve … la fin du bloc libre */
			/* [/////---------....../////] */
			/*       ^libre   ^ligne */

			/* on rajoute la longueur de la ligne effac‚e */
			thewin -> fonction.text.reste += (int)(thewin -> fonction.text.Ligne[ligne == LineNumberMax ? 0 : ligne +1] - thewin -> fonction.text.Ligne[ligne]);
		}
		/* sinon la ligne se trouve avant le bloc libre */
			/* [     .../////////////-----] */
			/*       ^ligne lib‚r‚e  ^bloc libre */
			/* on ne fait rien, la place sera utilis‚ lorsque le bloc libre sera trop petit */

		thewin -> fonction.text.Ligne[ligne] = NULL;
	}

libere:
	if (len > thewin -> fonction.text.reste)
	{
		char **Ligne = thewin -> fonction.text.Ligne;

		/* recherche l'indice du plus vieux texte */
		ligne = thewin -> fonction.text.CurrentLine;

		while (Ligne[ligne] == NULL)
			if (++ligne == LineNumberMax) /* !! num‚rote … partir de 0 */
				ligne = 0;

		/* on l'a trouv‚ */
		if (Ligne[ligne] < thewin -> fonction.text.debut && Ligne[ligne] > thewin -> fonction.text.Text)
		{
			/* la derniŠre ligne se trouve avant le bloc libre */
			/* et */
			/* il y a de la place entre le d‚but et la derniŠre ligne */
			/* [    ..../////////////--] *
			/*      ^ligne           ^bloc libre */

			thewin -> fonction.text.debut = thewin -> fonction.text.Text;
			thewin -> fonction.text.reste = (int)(thewin -> fonction.text.Ligne[ligne] - thewin -> fonction.text.Text);

			/* la ligne n'est pas lib‚r‚e mais le bloc libre est juste d‚plac‚ */
			goto libere;
		}

		thewin -> fonction.text.LineNumber--;
		thewin -> fonction.text.ligne--;

		/* libŠre le texte de cette ligne */
		if (thewin -> fonction.text.Ligne[ligne] > thewin -> fonction.text.debut)
			if (thewin -> fonction.text.Ligne[ligne == LineNumberMax ? 0 : ligne +1] > thewin -> fonction.text.Text)
			{
				/* la ligne se trouve … la fin du bloc libre */
				/* [/////---------....../////] */
				/*       ^libre   ^ligne */

				/* on rajoute la longueur de la ligne effac‚e */
				thewin -> fonction.text.reste = (int)(thewin -> fonction.text.Ligne[ligne == LineNumberMax ? 0 : ligne +1] - thewin -> fonction.text.debut);
			}
			else
			{
				/* la ligne se trouve … la fin du bloc libre et il n'y a rien aprŠs */
				/* [/////---------......    ] */
				/*       ^libre   ^ligne   ^fin du bloc */

				/* on rajoute la longueur de la ligne effac‚e */
				thewin -> fonction.text.reste = thewin -> fonction.text.TextSize - (int)(thewin -> fonction.text.debut - thewin -> fonction.text.Text);
			}
		/* sinon la ligne se trouve avant le bloc libre */
			/* [     .../////////////-----] */
			/*       ^ligne lib‚r‚e  ^bloc libre */
			/* on ne fait rien, la place sera utilis‚ lorsque le bloc libre sera trop petit */

		thewin -> fonction.text.Ligne[ligne] = NULL;
		goto libere;
	}

	/* copie la chaŒne dans le tampon de texte */
	c = thewin -> fonction.text.debut;
	thewin -> fonction.text.Ligne[thewin -> fonction.text.CurrentLine] = c;

	for (; *text;)
		*c++ = *text++;
	*c++ = '\0';

	thewin -> fonction.text.LineNumber++;
	thewin -> fonction.text.ligne++;

	/* fait avancer CurrentLine */
	if (++thewin -> fonction.text.CurrentLine ==  LineNumberMax)
		thewin -> fonction.text.CurrentLine = 0;

	if (++thewin -> fonction.text.PrintLine ==  LineNumberMax)
		thewin -> fonction.text.PrintLine = 0;

	/* r‚actualise d‚but et reste */
	thewin -> fonction.text.debut = c;
	thewin -> fonction.text.reste -= len;

	/* update window */
	wind_update(BEG_UPDATE);

	MouseOff();

	/* d‚cale l'‚cran pour afficher le nouvelle ligne */
	scroll_down(thewin, 1);

	/*	r‚actualise l'ascenseur	*/
	wind_set(win -> handle, WF_VSLSIZE, min(1000, (win -> work.g_h / thewin -> fonction.text.taille_h) * 1000 / (thewin -> fonction.text.LineNumber - 1)), 0, 0, 0);

	taille_page = floor(win -> work.g_h / thewin -> fonction.text.taille_h); /* nombre de lignes par page */
	if (thewin -> fonction.text.LineNumber -1 - taille_page)
	{
		a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
		b = a * (taille_page -1);
		vslide = max(0, (int)(a * thewin -> fonction.text.ligne - b));
	}
	else
		vslide = 1000;
	wind_set(win -> handle, WF_VSLIDE, vslide, 0, 0, 0);

	MouseOn();

	wind_update(END_UPDATE);
} /* ajoute */

/****************************************************************
*																*
*			donne le fichier associ‚ au cluster 				*
*																*
****************************************************************/
void secteur_file(windowptr thewin)
{
	if (thewin -> type == OCCUP)
		if (thewin -> fonction.occup.fichier)
		{
			thewin -> fonction.occup.fichier = FALSE;
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);

			sprintf(thewin -> title, Messages(INFO_39), thewin -> fonction.occup.device +'A');
			window_name(thewin -> win, thewin -> title, thewin -> title);

			return;
		}
		else
		{
			int device = thewin -> fonction.occup.device;
			BPB bpb = Bpb[device];

			if (load_arbo(thewin -> fonction.occup.device))
				return;

			if (!Cluster[device])
				if ((Cluster[device] = calloc(bpb.numcl +2L, sizeof(char *))) == NULL)
				{
					error_msg(Z_NOT_ENOUGH_MEMORY);
					return;
				}
				else
					if (ManageVFAT)
						create_map_vfat((dir_elt_vfat *)Arbo[device], (dir_elt_vfat **)Cluster[device], FAT[device]);
					else
						create_map_short(Arbo[device], Cluster[device], FAT[device]);

			thewin -> fonction.occup.fichier = TRUE;
		}

	if (thewin -> type == SECTEUR)
	{
		WIN *win = thewin -> win;
		int device = thewin -> fonction.secteur.device;
		BPB bpb = Bpb[device];
		if (thewin -> fonction.secteur.fichier)
		{
			thewin -> fonction.secteur.fichier = FALSE;
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);

			if (device < 2)
				sprintf(thewin -> title, Messages(FENETRE_1), 'A'+device);
			else
				sprintf(thewin -> title, Messages(FENETRE_2), 'A'+device);
			window_name(win, thewin -> title, thewin -> title);

			return;
		}

		if (load_arbo(device))
			return;

		if (!Cluster[device])
			if ((Cluster[device] = calloc(bpb.numcl +2L, sizeof(char *))) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);
				return;
			}
			else
				if (ManageVFAT)
					create_map_vfat((dir_elt_vfat *)Arbo[device], (dir_elt_vfat **)Cluster[device], FAT[device]);
				else
					create_map_short(Arbo[device], Cluster[device], FAT[device]);

		print_secteur_file(thewin);
		thewin -> fonction.secteur.fichier = TRUE;
	}

	menu_icheck(Menu, FICHIER_ASSOCIE, 1);
} /* secteur_file */

/****************************************************************
*																*
*			affiche le fichier associ‚ au cluster				*
*																*
****************************************************************/
void print_secteur_file(windowptr thewin)
{
	WIN *win = thewin -> win;
	int device = thewin -> fonction.secteur.device;
	long secteur = thewin -> fonction.secteur.secteur;
	BPB bpb = Bpb[device];

	sprintf(thewin -> title, " %c: ", 'A'+device);

	if (secteur == 0)
		strcat(thewin -> title, Messages(FENETRE_3));
	else
		if (secteur < bpb.fatrec)
			strcat(thewin -> title, Messages(FENETRE_4));
		else
			if (secteur < bpb.fatrec + bpb.fsiz)
				strcat(thewin -> title, Messages(FENETRE_5));
			else
				if (secteur < bpb.datrec)
					strcat(thewin -> title, Messages(FENETRE_6));
				else
					if (ManageVFAT)
						get_name_from_cluster_vfat(device, (unsigned int)floor((float)(secteur - bpb.datrec) / bpb.clsiz +2), thewin -> title +1, MAX_TITLE-1);
					else
						get_name_from_cluster_short(device, (unsigned int)floor((float)(secteur - bpb.datrec) / bpb.clsiz +2), thewin -> title +1, MAX_TITLE-1);

	window_name(win, thewin -> title, thewin -> title);
} /* print_secteur_file */

/****************************************************************
*																*
*				update la fenetre d'un secteur					*
*																*
****************************************************************/
void secteur_window_update(windowptr thewin, int fast)
{
	WIN *win = thewin -> win;
	int i, len;
	int slide, sect;
	BPB bpb = Bpb[thewin -> fonction.secteur.device];

	/* num‚rotation */
	for (i=0; i<MAX_DEVICES; i++)
		sprintf(thewin -> fonction.secteur.Ligne[i+4], "%04lX  ", thewin -> fonction.secteur.page*512L + i*32);

	/* r‚affiche le curseur */
	if (thewin -> fonction.secteur.curseur_y >= 0)
		thewin -> fonction.fichier.Ligne[thewin -> fonction.secteur.curseur_y+4][4] = '';

	/* remplis la fenˆtre */
	convert_sect(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

	/* met … jour les compteurs */
	switch (thewin -> type)
	{
		case SECTEUR:
			len = sprintf(thewin -> fonction.secteur.Ligne[0], thewin -> fonction.secteur.decimal ? Messages(FENETRE_7) : Messages(FENETRE_8),
			 thewin -> fonction.secteur.secteur, thewin -> fonction.secteur.max, 
			 (unsigned int)floor((double)(thewin -> fonction.secteur.secteur - bpb.datrec) / bpb.clsiz +2), bpb.numcl+1);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';

			update_slide(thewin);
			break;

		case FICHIER:
			if (thewin -> fonction.fichier.curseur_x < 0)
				len = sprintf(thewin -> fonction.fichier.Ligne[0], thewin -> fonction.fichier.decimal ? Messages(CURSEUR_1) : Messages(CURSEUR_2),
				 ((thewin -> fonction.fichier.secteur*thewin -> fonction.fichier.sector_size)+thewin -> fonction.fichier.page)*512L, thewin -> fonction.fichier.size,
				 (unsigned int)floor((float)(thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur] - bpb.datrec)/bpb.clsiz +2.),
				 thewin -> fonction.fichier.secteur, thewin -> fonction.fichier.max);
			else
				len = sprintf(thewin -> fonction.fichier.Ligne[0], thewin -> fonction.fichier.decimal ? Messages(CURSEUR_1) : Messages(CURSEUR_2),
				 ((thewin -> fonction.fichier.secteur*thewin -> fonction.fichier.sector_size)+thewin -> fonction.fichier.page)*512L + thewin -> fonction.fichier.curseur_x/2 + thewin -> fonction.fichier.curseur_y*32, thewin -> fonction.fichier.size,
				 (unsigned int)floor((float)(thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur] - bpb.datrec)/bpb.clsiz +2),
				 thewin -> fonction.fichier.secteur, thewin -> fonction.fichier.max);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';

			update_slide(thewin);
			break;

		case FICHIER_FS:
			if (thewin -> fonction.fichier_fs.curseur_x < 0)
				len = sprintf(thewin -> fonction.fichier_fs.Ligne[0], thewin -> fonction.fichier_fs.decimal ? Messages(CURSEUR_3) : Messages(CURSEUR_4),
				 thewin -> fonction.fichier_fs.secteur*512L, thewin -> fonction.fichier_fs.size);
			else
				len = sprintf(thewin -> fonction.fichier_fs.Ligne[0], thewin -> fonction.fichier_fs.decimal ? Messages(CURSEUR_3) : Messages(CURSEUR_4),
				 thewin -> fonction.fichier_fs.secteur*512L + thewin -> fonction.fichier_fs.curseur_x/2 + thewin -> fonction.fichier_fs.curseur_y*32, thewin -> fonction.fichier_fs.size);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';

			update_slide(thewin);
			break;

		case RAW_FLOPPY:
			sect = (int)thewin -> fonction.raw_floppy.secteur;
			slide = sect / (thewin -> fonction.raw_floppy.max_secteur * (thewin -> fonction.raw_floppy.max_face +1));	/* piste */
			sect -= slide * (thewin -> fonction.raw_floppy.max_secteur * (thewin -> fonction.raw_floppy.max_face +1));
			thewin -> fonction.raw_floppy.face = sect >= thewin -> fonction.raw_floppy.max_secteur ? sect -= thewin -> fonction.raw_floppy.max_secteur, 1 : 0;
			thewin -> fonction.raw_floppy.real_secteur = sect+1;
			thewin -> fonction.raw_floppy.piste = slide;

			len = sprintf(thewin -> fonction.raw_floppy.Ligne[0], thewin -> fonction.raw_floppy.decimal ? Messages(FENETRE_11) : Messages(FENETRE_13),
			 thewin -> fonction.raw_floppy.real_secteur, thewin -> fonction.raw_floppy.max_secteur,
			 thewin -> fonction.raw_floppy.piste, thewin -> fonction.raw_floppy.max_piste,
			 thewin -> fonction.raw_floppy.face, thewin -> fonction.raw_floppy.max_face,
			 (int)thewin -> fonction.raw_floppy.secteur,
			 (int)thewin -> fonction.raw_floppy.max);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';

			update_slide(thewin);
			break;

		case RAW_HARD:
			len = sprintf(thewin -> fonction.raw_hard.Ligne[0], thewin -> fonction.raw_hard.decimal ? Messages(FENETRE_12) : Messages(FENETRE_14), thewin -> fonction.raw_hard.secteur, thewin -> fonction.raw_hard.max);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';

			update_slide(thewin);
			break;
	}

	Efface = FALSE;

	if (fast)
	{
		GRECT box = win -> work;
		box.g_h = win -> work.g_h - (thewin -> fonction.fichier.ligne - 3)*thewin -> fonction.fichier.taille_h - (thewin -> fonction.fichier.taille_pt == 9 ? 2 : 3);

		redraw_window(win, &box);
	}
	else
		redraw_window(win, &win -> work);
} /* secteur_window_update */

/****************************************************************
*																*
*					met l'ascenseur … jour						*
*																*
****************************************************************/
void update_slide(windowptr thewin)
{
	OBJECT *slide = thewin -> fonction.secteur.slide;
	GRECT work = thewin -> win -> work;

	slide[SLIDER_FOND].ob_x = work.g_x + work.g_w - slide[SLIDER_FOND].ob_width;
	slide[SLIDER_FOND].ob_y = work.g_y;
	slide[SLIDER_FOND].ob_height = work.g_h;

	slide[SLIDER_PERE].ob_height = work.g_h - 2*slide[SLIDER_PERE].ob_y + (aes_version >= 0x330 ? 1 : 0);

	slide[SLIDER_BAS].ob_y = slide[SLIDER_FOND].ob_height - slide[SLIDER_BAS].ob_height - (aes_version >= 0x330 ? 2 : 1);

	/* hauteur */
	slide[SLIDER_FILS].ob_height = thewin -> fonction.secteur.max ? (int)(slide[SLIDER_PERE].ob_height / (thewin -> fonction.secteur.max * thewin -> fonction.secteur.sector_size)) : slide[SLIDER_PERE].ob_height;
	if (slide[SLIDER_FILS].ob_height < slide[SLIDER_FILS].ob_width * gr_ch/16)
		slide[SLIDER_FILS].ob_height = slide[SLIDER_FILS].ob_width * gr_ch/16;

	/* position */
	if (thewin -> fonction.secteur.max > 1)
		slide[SLIDER_FILS].ob_y = (int)(((thewin -> fonction.secteur.secteur * thewin -> fonction.secteur.sector_size + thewin -> fonction.secteur.page) * (slide[SLIDER_PERE].ob_height - slide[SLIDER_FILS].ob_height))/(thewin -> fonction.secteur.max * thewin -> fonction.secteur.sector_size -1));
} /* update_slide */

/****************************************************************
*																*
*					taille id‚ale								*
*																*
****************************************************************/
void taille_ideale(windowptr thewin)
{
	WIN *win = thewin -> win;
	GRECT rect = win -> work, out;
	int redraw = TRUE;
	int handle = win -> handle;
	float a, b;
	int ligne, Tligne, taille_page, line_number, i;
	int g_w = thewin -> fonction.text.taille_w, g_h = thewin -> fonction.text.taille_h;

	if (thewin == Firstwindow)
		get_info(0, thewin, &out);
	else
	{
		switch (thewin -> type)
		{
			case SECTEUR:
			case FICHIER:
			case FICHIER_FS:
			case RAW_HARD:
			case RAW_FLOPPY:
				rect.g_w = 70*g_w + thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;
				rect.g_h = g_h*20 +2;
				break;

			case TAMPON:
				rect.g_w = 70*g_w +1;
				rect.g_h = g_h*19 +1;
				break;

			case OCCUP:
				{
					int size_x, size_y, nx;
					unsigned int numcl = Bpb[thewin -> fonction.occup.device].numcl +1;	/* +1 : marque de fin */

					if (gr_ch == 16)
						size_x = (int)floor(sqrt((win -> work.g_h-3.0)*(win -> work.g_w-3.0)/(double)numcl));
					else
						size_x = (int)floor(sqrt((2*(win -> work.g_h-3.0))*(win -> work.g_w-3.0)/(double)numcl));
					nx = (int)floor((win -> work.g_w-3.0)/size_x);
					size_y = (int)floor((win -> work.g_h-3.0)/ceil((double)numcl/(double)nx));

					if (size_y < 2 && size_x > 2)
					{
						size_x--;
						nx = (int)floor((win -> work.g_w-3.0)/size_x);
						size_y = (int)floor((win -> work.g_h-3.0)/(int)ceil((double)numcl/(double)nx));
					}

					if (size_x>1 && size_y>1)
					{
						rect.g_w = size_x * nx + 3;
						rect.g_h = size_y * (int)ceil((double)numcl/(double)nx) + 3;
					}
				}
		}

		window_calc(WC_BORDER, win -> gadgets, &rect, &out);

		for (i=0; i<WinEntrees; i++)
			if (Windows[i].fenetre == thewin)
			{
				Windows[i].box = out;
				break;
			}
	}

	if (win -> work.g_h < rect.g_h || win -> work.g_w < rect.g_w || rect.g_x!=win -> work.g_x || rect.g_y!=win -> work.g_y)
		redraw = FALSE;

	window_size(win, &out);

	switch (thewin -> type)
	{
		case SECTEUR:
		case RAW_FLOPPY:
		case RAW_HARD:
		case FICHIER:
		case FICHIER_FS:
			update_slide(thewin);
			break;
	}

	switch (thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case TEXT:
		case TAMPON:
		case RAW_FLOPPY:
		case RAW_HARD:
			if (thewin -> fonction.text.ligne != thewin -> fonction.text.LineNumber-1 || thewin -> fonction.text.colonne)
			{
				thewin -> fonction.text.colonne = 0;
				redraw = TRUE;
			}

			wind_set(handle, WF_HSLSIZE, (int)(win -> work.g_w *1000. / max_w), 0, 0, 0);
			wind_set(handle, WF_HSLIDE, (int)(thewin -> fonction.text.colonne * 8000./(max_w - win -> work.g_w)), 0, 0, 0);

			taille_page = win -> work.g_h / thewin -> fonction.text.taille_h;
			ligne = thewin -> fonction.text.ligne; 
			line_number = thewin -> fonction.text.LineNumber -1;
			if (ligne <= line_number);
			{
				Tligne = thewin -> fonction.text.PrintLine;

				/* scroll vers le bas */
				while (ligne < line_number)
				{
					if (Tligne++ == line_number) /* on reboucle */
						Tligne = 0;
					ligne++;
				}

				thewin -> fonction.text.ligne = ligne;
				thewin -> fonction.text.PrintLine = Tligne;
			}
	
			wind_set(handle, WF_VSLSIZE, min(1000, taille_page * 1000 / line_number), 0, 0, 0);

			a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
			b = a * (taille_page -1);
			wind_set(handle, WF_VSLIDE, max(0, (int)(a * ligne - b)), 0, 0, 0);

			if (redraw)
				redraw_window(win, &win -> work);
			break;
	}

	if (Zone.g_w)
		Zone = win -> work;
} /* taille_ideale */

/****************************************************************
*																*
*					choix de la fonte							*
*																*
****************************************************************/
void choix_fonte(windowptr thewin)
{
	WIN *win = thewin -> win;
	float a, b;
	FONTSEL fs = {NULL,NULL,NULL,NULL,0,NORMAL,FS_GADGETS_STANDARD,FS_FNT_BITMAP,8,10,{0,0},{TRUE,DIA_MOUSEPOS,FALSE,TRUE,TRUE,FS_ACT_NONE},NULL,NULL,0,0,0,BLACK};
	int dummy, i;

	fs.size = thewin -> fonction.text.taille_pt;
	if ((thewin -> type == TEXT || thewin -> type >= TAMPON) && FontSelect(DialogInWindow ? FSEL_WIN : FSEL_DIAL, &fs) == FS_OK)
	{
		thewin -> fonction.text.taille_pt = fs.size;

		vst_point(thewin -> win -> vdi_handle, fs.size, &dummy, &dummy, &thewin -> fonction.text.taille_w, &thewin -> fonction.text.taille_h);

		for (i=0; i<WinEntrees; i++)
			if (Windows[i].fenetre == thewin)
			{
				Windows[i].fonction.texte.texte_pt = fs.size;
				break;
			}

		/* repositionne l'ascenseur vertical */
		wind_set(win -> handle, WF_VSLSIZE, min(1000, (win -> work.g_h / thewin -> fonction.text.taille_h) * 1000 / (thewin -> fonction.text.LineNumber -1)), 0, 0, 0);

		a = 1000. / (thewin -> fonction.text.LineNumber - (win -> work.g_h / thewin -> fonction.text.taille_h));
		b = a * (win -> work.g_h / thewin -> fonction.text.taille_h -1);
		wind_set(win -> handle, WF_VSLIDE, max(0, (int)(a * thewin -> fonction.text.ligne - b)), 0, 0, 0);

		taille_ideale(thewin);
	}
} /* choix_fonte */

/****************************************************************
*																*
*			regarde o— on clique et fait ce qu'il faut			*
*																*
****************************************************************/
boolean do_mouse(windowptr thewin, int mousex, int mousey, int double_clic)
{
	GRECT box;
	int object, x, y;
	OBJECT *slide = thewin -> fonction.secteur.slide;
	WIN *win = thewin -> win;
	GRECT rect;

	box = thewin -> win -> work;

	if (thewin -> type != TAMPON && (object = objc_find(slide, ROOT, MAX_DEPTH, mousex, mousey)) != FAIL)
	{	/* ascenseur de d‚placement */
		switch (object)
		{
			case SLIDER_HAUT:
				ob_dostate(thewin -> fonction.secteur.slide, SLIDER_HAUT, SELECTED);
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(thewin -> fonction.secteur.slide, SLIDER_HAUT, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}

				previous_secteur(thewin);

				ob_undostate(thewin -> fonction.secteur.slide, SLIDER_HAUT, SELECTED);
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(thewin -> fonction.secteur.slide, SLIDER_HAUT, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}
				break;

			case SLIDER_BAS:
				ob_dostate(thewin -> fonction.secteur.slide, SLIDER_BAS, SELECTED);
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(thewin -> fonction.secteur.slide, SLIDER_BAS, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}

				next_secteur(thewin);

				ob_undostate(thewin -> fonction.secteur.slide, SLIDER_BAS, SELECTED);
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(thewin -> fonction.secteur.slide, SLIDER_BAS, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}
				break;
				
			case SLIDER_PERE:
				objc_offset(slide, SLIDER_FILS, &x, &y);
				if (mousey < y)
					previous_bloc(thewin);
				else
					next_bloc(thewin);
				break;
					
			case SLIDER_FILS:
				if (double_clic)
				{
					/* attend qu'on relache la souris */
					NoClick();

					goto_secteur(thewin);
				}
				else
					if (thewin -> fonction.fichier.max > 1)
						real_time_slide(thewin, slide, SLIDER_PERE, SLIDER_FILS, ScrollTimer, update_goto, 1);

				return FALSE;	/* ne pas lancer le timer */
		}
	}
	else
	{ /* d‚place le curseur */
		int top;

		x = (mousex - box.g_x)/thewin -> fonction.text.taille_w - 6 + thewin -> fonction.text.colonne;
		y = thewin -> fonction.text.ligne -4 - (box.g_y + box.g_h - mousey)/thewin -> fonction.text.taille_h;

		/* la fenˆtre au premier plan */
		wind_get(0,  WF_TOP, &top);

		if (double_clic || ((x < 0 || x > 63 || y<0 || y > 15) && top != thewin -> win -> handle))
		{
			make_frontwin(thewin);
			return FALSE;
		}

		if (x < 0)
			x = 0;
		else
			if (x > 63)
				x = 63;
		if (thewin -> fonction.secteur.ascii || !(Kbshift(FAIL) & ~(1<<4)))
			x &= ~1;

		if (y < 0)
			y = 0;
		else
			if (y > 15)
				y = 15;

		if (thewin -> fonction.secteur.curseur_x < 0)
		{
			update_curseur(thewin, x, y, FAIL, FAIL, TRUE);
			menu_icheck(Menu, CURSEUR_VISIBLE, 1);
		}
		else
			update_curseur(thewin, x, y, thewin -> fonction.secteur.curseur_x, thewin -> fonction.secteur.curseur_y, TRUE);

		thewin -> fonction.secteur.curseur_x = x;
		thewin -> fonction.secteur.curseur_y = y;
	}

	return TRUE;
} /* do_mouse */

/****************************************************************
*																*
*			regarde o— on clique et fait ce qu'il faut			*
*																*
****************************************************************/
void do_mouse_occupation(windowptr thewin, int mousex, int mousey)
{
	GRECT work = thewin -> win -> work;
	BPB bpb = Bpb[thewin -> fonction.occup.device];
	unsigned int clst, numcl = bpb.numcl +1;
	int size_x, size_y, large = thewin -> win -> work.g_x + thewin -> win -> work.g_w-2;
	int nx;

	if (gr_ch == 16)
		size_x = (int)floor(sqrt((work.g_h-3.0)*(work.g_w-3.0)/(double)numcl));
	else
		size_x = (int)floor(sqrt((2*(work.g_h-3.0))*(work.g_w-3.0)/(double)numcl));
	nx = (int)floor((work.g_w-3.0)/size_x);
	size_y = (int)floor((work.g_h-3.0)/(int)((double)numcl/(double)nx));

	if (size_y < 2 && size_x > 2)
	{
		size_x--;
		nx = (int)floor((work.g_w-3.0)/size_x);
		size_y = (int)floor((work.g_h-3.0)/(int)ceil((double)numcl/(double)nx));
	}

	if (size_x < 1 || size_y < 1)
		return;

	large -= size_x-1;

	clst = nx*(int)((mousey - work.g_y -2)/size_y) + (mousex - work.g_x -2)/size_x +2;
	if (clst > numcl)
		strcpy(thewin -> title, Messages(INFO_2));
	else
	{
		int len;

		if (thewin -> fonction.occup.decimal)
			sprintf(thewin -> title, "%u ", clst);
		else
			sprintf(thewin -> title, "$%04X ", clst);

		len = (int)strlen(thewin -> title);
		if (ManageVFAT)
			get_name_from_cluster_vfat(thewin -> fonction.occup.device, clst, thewin -> title + len, MAX_TITLE-len);
		else
			get_name_from_cluster_short(thewin -> fonction.occup.device, clst, thewin -> title + len, MAX_TITLE-len);
	}

	window_name(thewin -> win, thewin -> title, thewin -> title);
} /* do_mouse_occupation */
