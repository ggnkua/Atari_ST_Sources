/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <string.h>
#include <ctype.h>

#include "globals.h"
#include "zorg.h"

#include "tampon.h"
#include "divers.h"
#include "fenetre.h"
#include "wind.h"
#include "dialog.h"
#include "init.h"
#include "update.h"
#include "fat.h"
#include "brut.h"

/****************************************************************
*																*
*				efface le tampon (met … 0)						*
*																*
****************************************************************/
void effacer_tampon(void)
{
	int i;

	for (i=0; i<512; i++)
		Tampon -> fonction.tampon.secteurBin[i] = '\0';

	/* update la fenˆtre Tampon */
	if (Menu[OUVRIR_TAMPON].ob_state & DISABLED)
	{
		convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

		Efface = FALSE;
		redraw_window(Tampon -> win, &Tampon -> win -> work);
	}
} /* effacer_tampon */

/****************************************************************
*																*
*			cr‚e un fichier vide d'une taille donn‚e			*
*																*
****************************************************************/
void creer_fichier(void)
{
	OBJECT *file_size;
	char nom[FILENAME_MAX] = "EMPTY.NEW", text[FILENAME_MAX];
	int ex, size, handle;

	if(!selecteur(nom, NULL, Messages(TAMPON_1)))
		return;

	sprintf(text, Messages(TAMPON_2), nom);
	ajoute(Firstwindow, text);

	rsrc_gaddr(R_TREE, TAILLE_FICHIER, &file_size);
	strcpy(file_size[CREATE_FILE_SIZE].ob_spec.tedinfo -> te_ptext, "1");

	ex = xdialog(Dialog[TAILLE_FICHIER].tree, NULL, NULL, NULL, TRUE, TRUE, DialogInWindow ? AUTO_DIAL|MODAL|NO_ICONIFY : FLY_DIAL|MODAL|NO_ICONIFY|SMART_FRAME);

	if (ex == CREATE_FILE_ANNU)
	{
		ajoute(Firstwindow, Messages(TAMPON_3));
		return;
	}

	size = atoi(file_size[CREATE_FILE_SIZE].ob_spec.tedinfo -> te_ptext);

	if ((handle = (int)Fcreate(nom, 0)) >! 0)
	{
		int i, err;
		char buffer[512];

		for (i=0; i<512; i++)	/* efface le buffer */
			buffer[i] = '\0';

		for (i=0; i<size; i++)	/* copie 'size' fois le buffer */
			if ((err = (int)Fwrite(handle, 512L, buffer)) < 0)
			{
				error_msg(err);
				break;
			}

		Fclose(handle);

		sprintf(text, Messages(TAMPON_4), nom, size*512L);
		ajoute(Firstwindow, text);

		if (nom[1] == ':')
			change_disque(toupper(nom[0]) -'A', TRUE);
	}
	else
	{
		error_msg(handle);
		sprintf(text, Messages(TAMPON_5), nom);
		ajoute(Firstwindow, text);
	}
} /* creer_fichier */

/****************************************************************
*																*
*				sauve le tampon dans un fichier					*
*																*
****************************************************************/
void sauver_tampon(void)
{
	int handle;
	char nom[FILENAME_MAX] = "", text[FILENAME_MAX];

	if(!selecteur(nom, "*.BUF", Messages(TAMPON_6)))
		return;

	sprintf(text, Messages(TAMPON_7), nom);
	ajoute(Firstwindow, text);

	if ((handle = (int)Fcreate(nom, 0)) >= 0)
	{
		int err;

		if ((err = (int)Fwrite(handle, 512L, Tampon -> fonction.tampon.secteurBin)) < 0)
			error_msg(err);
		else
			ajoute(Firstwindow, Messages(TAMPON_8));

		Fclose(handle);
	}
	else
		ajoute(Firstwindow, Messages(TAMPON_9));
} /* sauver_tampon */

/****************************************************************
*																*
*				met un secteur dans le tampon					*
*																*
****************************************************************/
void copier_tampon(windowptr thewin)
{
	int i;
	char scrap_path[FILENAME_MAX];

	switch (thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case RAW_FLOPPY:
		case RAW_HARD:
			for (i=0; i<512; i++)
				Tampon -> fonction.tampon.secteurBin[i] = (thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[i];

			/* update la fenˆtre Tampon */
			if (Menu[OUVRIR_TAMPON].ob_state & DISABLED) /* la fenˆtre est d‚j… ouverte */
			{
				convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

				Efface = FALSE;
				redraw_window(Tampon -> win, &Tampon -> win -> work);
			}
			ajoute(Firstwindow, Messages(TAMPON_10));

		case TEXT:
		case TAMPON:
			if (ClipBoard && scrp_read(scrap_path))
				copier_clipboard(thewin, scrap_path);
			break;
	}
} /* copier_tampon */

/****************************************************************
*																*
*					met le tampon dans un secteur				*
*																*
****************************************************************/
void coller_tampon(windowptr thewin)
{
	int i;
	char scrap_path[FILENAME_MAX];

	/* charge le tampon avec le ClipBoard */
	if (ClipBoard && scrp_read(scrap_path))
		coller_clipboard(scrap_path);

	switch (thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case RAW_FLOPPY:
		case RAW_HARD:
			for (i=0; i<512; i++)
				(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[i] = Tampon -> fonction.tampon.secteurBin[i];

			thewin -> fonction.secteur.dirty = TRUE;
			secteur_window_update(thewin, FALSE);

			ajoute(Firstwindow, Messages(TAMPON_11));
			break;
	}
} /* coller_tampon */

/****************************************************************
*																*
*					echange un secteur et le tampon				*
*																*
****************************************************************/
void echanger_tampon(windowptr thewin)
{
	char c;
	int i;

	switch (thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case RAW_FLOPPY:
		case RAW_HARD:
			for (i=0; i<512; i++)
			{
				c = (thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[i];
				(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[i] = Tampon -> fonction.tampon.secteurBin[i];
				Tampon -> fonction.tampon.secteurBin[i] = c;
			}

			thewin -> fonction.secteur.dirty = TRUE;
			secteur_window_update(thewin, FALSE);

			/* update la fenˆtre Tampon */
			if (Menu[OUVRIR_TAMPON].ob_state & DISABLED)
			{
				convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

				Efface = FALSE;
				redraw_window(Tampon -> win, &Tampon -> win -> work);
			}

			ajoute(Firstwindow, Messages(TAMPON_12));
	}
} /* echanger_tampon */

/****************************************************************
*																*
*					ouvre la fenˆtre du tampon					*
*																*
****************************************************************/
void ouvrir_tampon(void)
{
	windowptr thewin = Tampon;
	WIN *win;
	GRECT rect;
	t_win_coord *window;
	int dummy;

	/* demande la taille de la fenˆtre */
	window = get_info(1, Tampon, &rect);

	thewin -> fonction.secteur.couleur_curseur = window -> fonction.texte.curseur_c;
	thewin -> fonction.secteur.trame_curseur = window -> fonction.texte.curseur_t;
	thewin -> fonction.text.couleur_texte = window -> fonction.texte.texte_c;
	thewin -> fonction.text.taille_pt = window -> fonction.texte.texte_pt;
	thewin -> fonction.text.couleur_fond = window -> fonction.texte.background_c;
	thewin -> fonction.text.trame_fond = window -> fonction.texte.background_t;

	/* Create the information for the window.  Max size is the desktop. */
	win = open_window(thewin -> title, thewin -> title, NULL, NULL, window -> type, TRUE, 10, 10, &desk, &rect, NULL, secteurproc, NULL, 0);

	/* Check for error. */
	if (win == NULL)
	{
		error_msg(Z_NO_MORE_WINDOW);
		return;
	}

	if (!open_work(&win -> vdi_handle, work_out))
	{
		my_alert(1, FAIL, X_ICN_STOP, Messages(MAIN_9), NULL);
		close_window(win, FALSE);
		return;
	}

	thewin -> win = win;

	vst_point(win -> vdi_handle, thewin -> fonction.text.taille_pt, &dummy, &dummy, &thewin -> fonction.text.taille_w, &thewin -> fonction.text.taille_h);
	vst_color(win -> vdi_handle, thewin -> fonction.secteur.couleur_texte);
	vsf_interior(win -> vdi_handle, FIS_SOLID);
	vswr_mode(win -> vdi_handle, MD_REPLACE);
	vsf_perimeter(win -> vdi_handle, 0);

	/* Insert into windowlist. */
	{
		register windowptr winptr = (windowptr)&Firstwindow;

		while(winptr -> next)
		{
			winptr = winptr -> next;
			winptr -> place++;
		}
	
		winptr -> next = thewin;
	}

	convert_sect(thewin -> fonction.secteur.secteurBin, thewin -> fonction.text.Ligne, thewin -> fonction.secteur.ascii);

	/* initialise les ascenseurs */
	wind_set(win -> handle, WF_HSLSIZE, (int)(thewin -> win -> work.g_w *1000. / max_w), 0, 0, 0);

	wind_set(win -> handle, WF_VSLSIZE, 1000, 0, 0, 0);
	wind_set(win -> handle, WF_VSLIDE, 1000, 0, 0, 0);

	/* entr‚e dans le menu */
	get_menu_entry(thewin, thewin -> title +1);

	make_frontwin(thewin);

	menu_ienable(Menu, OUVRIR_TAMPON, 0);
	ajoute(Firstwindow, Messages(TAMPON_13));
} /* ouvrir_tampon */

/****************************************************************
*																*
*					ferme la fenˆtre de tampon					*
*					mais ne libŠre pas la m‚moire				*
*																*
****************************************************************/
void fermer_tampon(void)
{
	register windowptr winptr = (windowptr)&Firstwindow;

	/* ferme la fenˆtre */
	close_window(Tampon -> win, TRUE);

	/* Remove window record from window list. */
	while(winptr -> next)
		if (winptr -> next == Tampon)
			break;
		else
			winptr = winptr -> next;

	if (!winptr -> next)
	{
		error_msg(Z_NO_CORRESPONDING_HANDLE);
		shutdown(FALSE);
	}

	/* on d‚gage de la liste */
	winptr -> next = winptr -> next -> next;

	/* Update the front window pointer. */
	if (!BottomIsMeaningful)
	{
		int place = Tampon -> place;

		for (winptr = Firstwindow; winptr; winptr = winptr -> next)
			if (winptr -> place > place)
				winptr -> place--;

		/* recherche la nouvelle fenˆtre de niveau 0 */
		for (winptr = Firstwindow; winptr; winptr = winptr -> next)
			if (!winptr -> place)
				break;

		if (winptr)
			make_frontwin(winptr);
	}

	if (Tampon -> menu_entry > FAIL)
	{
		memset(MenuShortCuts[6].menu[WINDOW_LIST_1 - CHOIX_FONTE + Tampon -> menu_entry].text, ' ', MenuShortCuts[6].size -SHORTCUT_SIZE -1);
		menu_ienable(Menu, WINDOW_LIST_1 + Tampon -> menu_entry, FALSE);
		menu_icheck(Menu, WINDOW_LIST_1 + Tampon -> menu_entry, FALSE);
		*(PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 + Tampon -> menu_entry].ob_spec.free_string +1) = '\0';
		PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 + Tampon -> menu_entry].ob_state |= DISABLED;
	}

	/* rend le menu 'Ouvrir Tampon' cliquable */
	menu_ienable(Menu, OUVRIR_TAMPON, 1);
} /* fermer_tampon */

/****************************************************************
*																*
*		affiche une boŒte de dialogue des caractŠres ASCII		*
*																*
****************************************************************/
char m_ascii_box(char car, int modal)
{
	DIAINFO *info;
	int exit, dc;
	int mx, my, bx, dummy;

	sprintf(Dialog[ASCII].tree[ASCII_CARACTERE].ob_spec.tedinfo -> te_ptext, "%c, x%02X, %3d", car, car, car);

	if (modal)
	{
		info = open_dialog(Dialog[ASCII].tree, NULL, NULL, NULL, TRUE, TRUE, AUTO_DIAL|MODAL|NO_ICONIFY, 0, NULL, NULL);
		do
		{
			exit = X_Form_Do(NULL);

			/* enlŠve le flag double clic */
			dc = exit & DOUBLE_CLICK;
			exit &= NO_CLICK;

			if (exit == ASCII_OK)
				break;

			mouse(&mx, &my);

			/* position de la premiŠre ligne */
			objc_offset(Dialog[ASCII].tree, ASCII_LIGNE_1, &bx, &dummy);

			/* d‚termination du caractŠre */
			car = (char)((exit - ASCII_LIGNE_1)*32 + (mx - bx)/8);

			if (car == 0)
				car = ' ';

			sprintf(Dialog[ASCII].tree[ASCII_CARACTERE].ob_spec.tedinfo -> te_ptext, "%c, x%02X, %3d", car, car, car);
			ob_draw(info, ASCII_CARACTERE);

			if (dc)	/* on sort aussi avec un double clic */
				break;
		} while (TRUE);

		if (exit!=W_ABANDON && exit!=W_CLOSED)
		{
			exit &= 0x7fff;
			ob_undostate(Dialog[ASCII].tree, exit, SELECTED);
		}
		close_dialog(info, TRUE);
	}
	else
	{
		Dialog[ASCII].proc = m_ascii_box_proc;
		my_open_dialog(&Dialog[ASCII], AUTO_DIAL, FAIL);
	}

	return car;
} /* m_ascii_box */

/****************************************************************
*																*
*		affiche une boŒte de dialogue des caractŠres ASCII		*
*																*
****************************************************************/
boolean m_ascii_box_proc(t_dialog *dialog, int exit)
{
	int mx, my, bx, dummy;
	char car;

	switch (exit)
	{
		case ASCII_OK:
			return TRUE;

		default:
			mouse(&mx, &my);

			/* position de la premiŠre ligne */
			objc_offset(dialog -> tree, ASCII_LIGNE_1, &bx, &dummy);

			/* d‚termination du caractŠre */
			car = (char)((exit - ASCII_LIGNE_1)*32 + (mx - bx)/8);

			if (car == 0)
				car = ' ';

			sprintf(dialog -> tree[ASCII_CARACTERE].ob_spec.tedinfo -> te_ptext, "%c, x%02X, %3d", car, car, car);
			ob_draw(dialog -> info, ASCII_CARACTERE);
			break;
	}

	return FALSE;
} /* m_ascii_box_proc */

/****************************************************************
*																*
*			met la table des codes ASCII dans le tampon			*
*																*
****************************************************************/
void ascii_tampon(void)
{
	int i;

	for (i=0; i<256; i++)
		Tampon -> fonction.tampon.secteurBin[i] = (char)i;
	for (i=256; i<512; i++)
		Tampon -> fonction.tampon.secteurBin[i] = '\0';

	/* update la fenˆtre Tampon */
	if (Menu[OUVRIR_TAMPON].ob_state & DISABLED)
	{
		convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

		Efface = FALSE;
		redraw_window(Tampon -> win, &Tampon -> win -> work);
	}
} /* ascii_tampon */

/****************************************************************
*																*
*					cree la fenˆtre du tampon					*
*																*
****************************************************************/
void creer_tampon(void)
{
	register int k;
	register windowptr thewin;

	/* Allocate space for window record. */
	if ((Tampon = (windowptr)malloc(sizeof(windowrec))) == NULL)
		return;

	thewin = Tampon;

	/* Initialize window data structure. */
	thewin -> next = NULL;
	thewin -> kind_c = SIZER | MOVER | FULLER | CLOSER | NAME | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE;
	thewin -> type = TAMPON;
	thewin -> menu_entry = FAIL;
	thewin -> place = 0;
	strcpy(thewin -> title, Messages(TAMPON_14));

	if ((thewin -> fonction.tampon.secteurBin = sector_alloc(512)) == NULL)
	{
		free(thewin);
		Tampon = NULL;
		return;
	}

	if ((thewin -> fonction.tampon.Text = malloc((size_t)SECTEURSIZE)) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(thewin -> fonction.tampon.secteurBin);
		free(thewin);
		Tampon = NULL;
		return;
	}

	if ((thewin -> fonction.tampon.Ligne = (char **)malloc((size_t)SECTEURLINE * sizeof(char *))) == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		free(thewin -> fonction.tampon.secteurBin);
		free(thewin -> fonction.tampon.Text);
		free(thewin);
		Tampon = NULL;
		return;
	}

	/* le bloc contient d‚ja toutes les lignes remplies */
	thewin -> fonction.tampon.TextSize = SECTEURSIZE;
	thewin -> fonction.tampon.LineNumberMax = SECTEURLINE;
	thewin -> fonction.tampon.LineNumber = SECTEURLINE-2;
	thewin -> fonction.tampon.CurrentLine = SECTEURLINE-2;
	thewin -> fonction.tampon.taille_pt = gr_ch == 8 ? 9 : 10;
	thewin -> fonction.tampon.taille_w = gr_cw;
	thewin -> fonction.tampon.taille_h = gr_ch;
	thewin -> fonction.tampon.PrintLine = SECTEURLINE-3;
	thewin -> fonction.tampon.ligne = SECTEURLINE-3;
	thewin -> fonction.tampon.colonne = 0;

	/* chaque ligne … 0 */
	*thewin -> fonction.tampon.Text = '\0';

	for (k=1; k<SECTEURLINE; k++)	/* la premiŠre ligne est deux fois plus grande */
		thewin -> fonction.tampon.Text[(k+1) * SECTEURLINESIZE] = '\0';

	/* un pointeur sur chaque ligne */
	thewin -> fonction.tampon.Ligne[0] = thewin -> fonction.tampon.Text;

	for (k=1; k<SECTEURLINE; k++)
		thewin -> fonction.tampon.Ligne[k] = &thewin -> fonction.tampon.Text[(k+1) * SECTEURLINESIZE];

	thewin -> fonction.tampon.ascii = TRUE;
	thewin -> fonction.tampon.curseur_x = thewin -> fonction.tampon.curseur_y = FAIL;
	thewin -> fonction.tampon.page = 0;

	/* les champs suivant ne sont pas utilis‚ mais sont initialis‚s quand mˆme au cas ou... */
	thewin -> fonction.tampon.dirty = FALSE;
	thewin -> fonction.tampon.slide = NULL;
	thewin -> fonction.tampon.goto_liste = NULL;
	thewin -> fonction.tampon.max = 1;
	thewin -> fonction.tampon.secteur = 0;
	thewin -> fonction.tampon.sector_size = 1;

	/* secteur … 0 */
	memset(thewin -> fonction.tampon.secteurBin, 0, 512L);

	strncpy(thewin -> fonction.tampon.Ligne[0], "  Tampon", SECTEURLINESIZE*2);
	strncpy(thewin -> fonction.tampon.Ligne[1], "      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[2], "      0 1 2 3 4 5 6 7 8 9 A B C D E F 0 1 2 3 4 5 6 7 8 9 A B C D E F", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[3], "                                                                    ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[4], "0000  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[5], "0020  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[6], "0040  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[7], "0060  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[8], "0080  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[9], "00A0  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[10], "00C0  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[11], "00E0  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[12], "0100  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[13], "0120  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[14], "0140  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[15], "0160  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[16], "0180  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[17], "01A0  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[18], "01C0  ", SECTEURLINESIZE);
	strncpy(thewin -> fonction.tampon.Ligne[19], "01E0  ", SECTEURLINESIZE);
} /* creer_tampon */

/****************************************************************
*																*
*				Sauvegarde dans le ClipBoard					*
*																*
****************************************************************/
void copier_clipboard(windowptr thewin, char *scrap_path)
{
	FILE *fd;
	char scrap_file[FILENAME_MAX];
	int format = FAIL;
	long best_ext;

	scrp_clear(FALSE);

	/* fichier BINAIRE */
	if (thewin -> type >= TAMPON)
	{
		/* le fichier en binaire */
		strcpy(scrap_file, scrap_path);
		strcat(scrap_file, "SCRAP.BIN");

		/* cr‚ation du fichier */
		if ((fd = fopen(scrap_file, "wb")) == NULL)
		{
			error_msg(Z_CLIPBOARD_NOT_INSTALLED);
			return;
		}

		/* ‚criture du fichier */
		fwrite(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin, 512L, 1L, fd);

		/* fermeture */
		fclose(fd);

		format = SCF_INDEF;
		best_ext = '.BIN';
	}

	/* fichier TEXTE */
	if (thewin -> type >= TEXT)
	{
		int current, ligne, len, i;
		char buffer[255];

		/* le fichier en binaire */
		strcpy(scrap_file, scrap_path);
		strcat(scrap_file, "SCRAP.TXT");

		/* cr‚ation du fichier */
		if ((fd = fopen(scrap_file, "w")) == NULL)
		{
			error_msg(Z_CANT_CREATE_SCRAP);
			return;
		}

		/* un petit message de bienvenue */
		fprintf(fd, "ZORG realised by Ludovic Rousseau\nCopyright 1993-95\n\n");

		/* on ‚crite d'abord le titre de la fenˆtre */
		fprintf(fd, "%s\n", thewin -> title);

		/* la ligne d'info si elle existe */
		if (thewin -> win -> gadgets & INFO)
			fprintf(fd, "%s\n", thewin -> win -> info);
		
		current = thewin -> fonction.text.CurrentLine;
		for (ligne = 0; ligne < thewin -> fonction.text.LineNumber; ligne++)
			current = current > 0 ? current-1 : thewin -> fonction.text.LineNumberMax-1;

		/* ‚criture du fichier */
		for (ligne = 0; ligne < thewin -> fonction.text.LineNumber; ligne++)
		{
			len = sprintf(buffer, "%s\n", thewin -> fonction.text.Ligne[current]);
			for (i=0; i<len-1; i++)
				if (buffer[i] == 0x0A || buffer[i] == 0x0D || buffer[i] == 0x09)
					buffer[i] = ZeroChar;

			fwrite(buffer, (long)len, 1L, fd);

			current = current < thewin -> fonction.text.LineNumberMax-1 ? current+1 : 0;
		}

		/* fermeture */
		fclose(fd);

		format = SCF_TEXT;
		best_ext = '.TXT';
	}

	if (format > FAIL)
		scrp_changed(format, best_ext);
} /* copier_clipboard */

/****************************************************************
*																*
*					Lit le le ClipBoard							*
*																*
****************************************************************/
void coller_clipboard(char *scrap_path)
{
	FILE *fd;
	char scrap_file[FILENAME_MAX];

	/* le fichier en binaire */
	strcpy(scrap_file, scrap_path);
	strcat(scrap_file, "SCRAP.BIN");

	/* ouverture du fichier */
	if ((fd = fopen(scrap_file, "rb")) != NULL)
	{
		/* lecture du fichier */
		fread(Tampon -> fonction.secteur.secteurBin, 512L, 1L, fd);

		/* fermeture */
		fclose(fd);
	}
	else
	{
		/* le fichier texte */
		strcpy(scrap_file, scrap_path);
		strcat(scrap_file, "SCRAP.TXT");

		/* ouverture du fichier */
		if ((fd = fopen(scrap_file, "rb")) != NULL)
		{
			/* lecture du fichier */
			fread(Tampon -> fonction.secteur.secteurBin, 512L, 1L, fd);

			/* fermeture */
			fclose(fd);
		}
	}

	/* update la fenˆtre Tampon */
	if (Menu[OUVRIR_TAMPON].ob_state & DISABLED)
	{
		convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

		Efface = FALSE;
		redraw_window(Tampon -> win, &Tampon -> win -> work);
	}
} /* coller_clipboard */

/****************************************************************
*																*
*			test la chaŒne renvoy‚e par scrp_read()				*
*																*
****************************************************************/
boolean test_scrap_path(char *scrap_path)
{
	int len = (int)strlen(scrap_path);

	if (len == 0)
	{
		int device, err;

		/* C:\ existe ? */
		if (Drvmap() & (1<<2))
			device = 'C';
		else
			device = 'A';

		sprintf(scrap_path, "%c:\\CLIPBRD", device);

		/* cr‚e le r‚pertoire */
		if ((err = Dcreate(scrap_path)) < 0 && err != -36)
		{
			error_msg(err);
			return TRUE;
		}

		strcat(scrap_path, "\\");

		/* on pr‚vient l'AES */
		if (!scrp_write(scrap_path))
		{
			error_msg(Z_CLIPBOARD_NOT_INSTALLABLE);
			return TRUE;
		}
	}
	else
		if (scrap_path[len-1] != '\\')
		{
			if (Fsfirst(scrap_path, FA_SUBDIR))
			{
				/* c'est un r‚pertoire sans \ … la fin (C:\CLIPBRD) */
				scrap_path[len] = '\\';
				scrap_path[len+1] = '\0';
			}
			else
				/* c'est pas un r‚pertoire (C:\CLIPBRD\SCRAP.TXT) */
				*(strrchr(scrap_path, '\\')+1) = '\0';
		}

	return FALSE;
} /* test_scrap_path */

/****************************************************************
*																*
*				Actif ou D‚sactive le ClipBoard GEM				*
*																*
****************************************************************/
void clipboard_gem(windowptr thewin)
{
	char scrap_path[FILENAME_MAX];

	if (!(ClipBoard || scrp_read(scrap_path)))
	{
		error_msg(Z_CLIPBOARD_NOT_INSTALLED);
		return;
	}

	if (test_scrap_path(scrap_path))
		return;

	ClipBoard = 1-ClipBoard;

	if (ClipBoard)
	{
		char text[80];

		ajoute(Firstwindow, Messages(TAMPON_15));

		sprintf(text, Messages(TAMPON_16), scrap_path);
		ajoute(Firstwindow, text);
	}
	else
		ajoute(Firstwindow, Messages(TAMPON_17));

	menu_icheck(Menu, CLIPBOARD_GEM, ClipBoard);
	make_frontwin(thewin);

	if (ClipBoard)
		coller_clipboard(scrap_path);

	/* update la fenˆtre Tampon */
	if (Menu[OUVRIR_TAMPON].ob_state & DISABLED)
	{
		convert_sect(Tampon -> fonction.secteur.secteurBin, Tampon -> fonction.text.Ligne, Tampon -> fonction.secteur.ascii);

		Efface = FALSE;
		redraw_window(Tampon -> win, &Tampon -> win -> work);
	}
} /* clipboard_gem */
