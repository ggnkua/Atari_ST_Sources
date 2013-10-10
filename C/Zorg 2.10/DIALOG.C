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

#include "dialog.h"
#include "init.h"
#include "main.h"
#include "fenetre.h"
#include "update.h"

int rt_timer = 0;

/****************************************************************
*																*
*			recherche un dialogue associ‚ … une fenˆtre			*
*																*
****************************************************************/
t_dialog *find_dialog(windowptr thewin)
{
	t_dialog_list *win = WinDials;

	while (win != NULL && win -> dialog -> thewin != thewin)
		win = win -> next;

	if (win)
		return win -> dialog;
	else
		return NULL;
} /* find_dialog */

/****************************************************************
*																*
*					Ferme une dialog-window						*
*																*
****************************************************************/
void my_close_dialog(t_dialog *dialog)
{
	/* Dialog ge”ffnet ? */
	if (dialog -> info && dialog -> info -> di_flag > CLOSED)
	{
		t_dialog_list *win = (t_dialog_list*)&WinDials, *last;

		/* Dialog schliežen ohne Shrink-Box */
		close_dialog(dialog -> info, TRUE);
		dialog -> info = NULL;

		/* Dialog in Liste suchen und entfernen */
		while(win -> next)
			if (win -> next -> dialog == dialog)
				break;
			else
				win = win -> next;

		last = win -> next;

		/* on d‚gage de la liste */
		win -> next = win -> next -> next;

		free(last);

		WinDialCount--;

		/* attend la fin des redessins */
		Event_Timer(0, 0, TRUE);
	}
} /* my_close_dialog */

/****************************************************************
*																*
*					ouvre un dialog-window						*
*																*
****************************************************************/
int my_open_dialog(t_dialog *dialog, int dial_mode, int edit)
{
	reg exit = WinDialCount;
	t_dialog_list *win;
	DIAINFO *ex_info;		/* aktueller Dialog nach X_Form_Do */

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	if (!DialogInWindow && (dial_mode & AUTO_DIAL))
	{
		dial_mode &= ~WIN_DIAL;
		dial_mode |= SMART_FRAME;
	}

	if (dialog -> info == NULL)
	{
			dialog -> info = open_dialog(dialog -> tree, NULL, NULL, NULL, DIA_MOUSEPOS, TRUE, dial_mode, edit, NULL, NULL);

			if (dialog -> info != NULL)
			{
				/* ge”ffneten Dialogin Liste eintragen */
				win = malloc(sizeof(t_dialog_list));
				win -> dialog = dialog;
				win -> next = WinDials;
				WinDials = win;

				WinDialCount++;
			}
			else
				/* Dialog konnte nicht ge”ffnet werden (keine Fenster mehr verfgbar */
				my_alert(1, 1, X_ICN_ERROR, Messages(DIALOG_40), NULL);
	}
	else
		if (dialog -> info -> di_flag >= WINDOW)
		{
			/* la fenˆtre est d‚j… ouverte. on la passe devant */
			redraw_window(dialog -> info -> di_win, &dialog -> info -> di_win -> curr);
			window_top(dialog -> info -> di_win);
		}

	/* Waren bereits vorher Dialoge ge”ffnet ? */
	if (exit > 0 || dialog == &Dialog[PARAM_DIALOGUE] || dialog == &Dialog[WAIT])
		/* Ja, also wird die Verwaltung bereits an anderer Stelle bernommen */
		return FAIL;
	/* ansonsten Verwaltung der ge”ffneten Dialoge u. Auswertung der Benutzeraktionen */

	/* Solange Dialog ge”ffnet, Schleife wiederholen */
	while (WinDialCount > 0)
	{
		/* Auf Benutzeraktionen warten
		   exit -> angew„hltes Objekt (Bit 15 = Doppelklick)
		   ex_info -> Zeiger auf DIAINFO-Struktur des angew„hlten Dialogs
	    */
		exit = X_Form_Do(&ex_info);

		/* recherche le bon dialog */
		for (dialog = Dialog ;; dialog++)
			if (ex_info == dialog -> info)
				break;

		/* Fenster-Closer */
		if (exit == W_CLOSED)
			/* Dialog schliežen */
			my_close_dialog(dialog);
		/* Dialog wurde geschlossen, aber kein Objekt angew„hlt
		   (z.B. durch AC_CLOSE) */
		else if (exit == W_ABANDON)
			shutdown(Reset);
		else
		{
			/* enlŠve le flag double clic */
			exit &= NO_CLICK;

			/* gestion du dialog */
			if (dialog -> proc == NULL)
			{
				/* Exit-Objekt selektiert? */
				if (ob_isstate(ex_info -> di_tree, exit, SELECTED))
				{
					/* angew„hltes Objekt deselektieren und neu zeichnen */
					ob_undostate(ex_info -> di_tree, exit, SELECTED);
					ob_draw_chg(ex_info, exit, NULL, FAIL);
				}

				my_close_dialog(dialog);
			}
			else
				if ((*dialog -> proc)(dialog, exit) && dialog -> info && dialog -> info -> di_flag > CLOSED)
				{
					/* Exit-Objekt selektiert? */
					if (ob_isstate(ex_info -> di_tree, exit, SELECTED))
					{
						/* angew„hltes Objekt deselektieren und neu zeichnen */
						ob_undostate(ex_info -> di_tree, exit, SELECTED);
						ob_draw_chg(ex_info, exit, NULL, FAIL);
					}

					my_close_dialog(dialog);
				}
		}
	}

	return exit;
} /* my_open_dialog */

/****************************************************************
*																*
*		affiche une boŒte d'information (sans validation)		*
*																*
****************************************************************/
void paraminfo(char *string1, char *string2)
{
	/* efface la boŒte */
	if (string1 == NULL && string2 == NULL)
	{
		/* si c'est d‚j… effac‚ */
		if (DrawParam)
			return;

		my_close_dialog(&Dialog[PARAM_DIALOGUE]);

		/* dessin la prochaine fois */
		DrawParam = TRUE;
		return;
	}

	if (string1)
		strcpy(Dialog[PARAM_DIALOGUE].tree[PARAM_TEXT_1].ob_spec.tedinfo -> te_ptext, string1);
	else
		Dialog[PARAM_DIALOGUE].tree[PARAM_TEXT_1].ob_spec.tedinfo -> te_ptext[0] = '\0';

	if (string2)
		strcpy(Dialog[PARAM_DIALOGUE].tree[PARAM_TEXT_2].ob_spec.tedinfo -> te_ptext, string2);
	else
		Dialog[PARAM_DIALOGUE].tree[PARAM_TEXT_2].ob_spec.tedinfo -> te_ptext[0] = '\0';

	if (DrawParam)
	{
		/* on attend avant de redessiner */
		Event_Timer(0, 0, TRUE);

		my_open_dialog(&Dialog[PARAM_DIALOGUE], AUTO_DIAL|NO_ICONIFY|MODAL, FAIL);

		/* on attend le dessin de la fenˆtre */
		Event_Timer(0, 0, TRUE);

		/* ne pas tout redessiner la prochaine fois */
		DrawParam = FALSE;
	}
	else
	{
		/* permet de g‚rer les d‚placements */
		Event_Timer(0, 0, TRUE);

		/* la chaŒne est non vide */
		if (string1)
			ob_draw(Dialog[PARAM_DIALOGUE].info, PARAM_TEXT_1);

		/* la chaŒne est non vide */
		if (string2)
			ob_draw(Dialog[PARAM_DIALOGUE].info, PARAM_TEXT_2);
	}
} /* paraminfo */

/****************************************************************
*																*
*					erreur disque ou fichier					*
*																*
****************************************************************/
void error_msg(int err)
{
	char text1[60], text2[60], ligne[120];
	int icon = X_ICN_STOP;

	/* il faut redessiner entiŠrement les secteurs */
	Efface = TRUE;

	/* relache la souris */
	NoClick();

	/* on attend avant de redessiner */
	Event_Timer(0, 0, TRUE);

	switch (err)
	{
		/* GemDos */
		case -32:	/* Invlid function */
		case -33:	/* File not found */
		case -34:	/* Path not found */
		case -35:	/* No more handles */
		case -36:	/* Access denied */
		case -37:	/* Invalid handle */
			sprintf(text2, Messages(DIALOG_18-err-32));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -39:	/* Insufficient memory */
		case -40:	/* Invalid memory block adsress */
			sprintf(text2, Messages(DIALOG_24-err-39));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -46:	/* Invalid drive specification */
			sprintf(text2, Messages(DIALOG_26));
			icon = X_ICN_DISC_ERR;
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -48:	/* Cross drive rename */
		case -49:	/* No more files */
			sprintf(text2, Messages(DIALOG_27-err-48));
			icon = X_ICN_DISC_ERR;
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -58:	/* Record is already locked */
		case -59:	/* Invalid lock removal request */
			sprintf(text2, Messages(DIALOG_29-err-58));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -64:	/* Range error */
		case -65:	/* Internal error */
		case -66:	/* Invalid program load format */
		case -67:	/* Memory block growth failure */
			sprintf(text2, Messages(DIALOG_31-err-64));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -80:	/* Too many symbolic links */
			sprintf(text2, Messages(DIALOG_35));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		case -200:	/* Mount point crossed (indicator) */
			sprintf(text2, Messages(DIALOG_36));
			sprintf(text1, Messages(DIALOG_96), err);
			break;

		/* Xbios*/
		case -1:	/* Generic error */
		case -2:	/* Drive not ready */
		case -3:	/* Unknown command */
		case -4:	/* CRC error */
		case -5:	/* Bad request */
		case -6:	/* Seek error */
		case -7:	/* Unknown media */
		case -8:	/* Sector not found */
		case -9:	/* Out of paper */
		case -10:	/* Write fault */
		case -11:	/* Read fault */
		case -12:	/* inutilis‚ */
		case -13:	/* Device is write protected */
		case -14:	/* Media change detected */
		case -15:	/* Unknown device */
		case -16:	/* Bad sectors on format */
		case -17:	/* Insert other disk (request) */
			sprintf(text2, Messages(DIALOG_1-err-1));
			sprintf(text1, Messages(DIALOG_97), err);
			break;

		case Z_READ_WRITE:
		case Z_NO_BPB:
		case Z_NO_MORE_WINDOW:
		case Z_DMA_RW:
		case Z_CANT_CREATE_SCRAP:
		case Z_CLIPBOARD_NOT_INSTALLED:
		case Z_CLIPBOARD_NOT_INSTALLABLE:
		case Z_NO_CORRESPONDING_HANDLE:
		case Z_VIEWER_NOT_LOADED:
		case Z_HELP_VIEWER_NOT_LOADED:
		case Z_ERROR_WITH_VIEWER:
			strcpy(text2, Messages(DIALOG_37+err-1));
			sprintf(text1, Messages(DIALOG_98), err);
			break;

		default:
			sprintf(text1, Messages(DIALOG_99), err);
			text2[0] = '\0';
	}

	sprintf(ligne, "!%s|%s", text1, text2);
	my_alert(1, FAIL, icon, ligne, NULL);

	sprintf(ligne, "** %s, %s", text1, text2);	/* pour avoir une trace */
	ajoute(Firstwindow, ligne);
} /* error_msg */

/********************************************************************
*																	*
*						mon s‚lecteur d'objets						*
*																	*
********************************************************************/
int selecteur(char *nom, char *filtre, char *info)
{
	int no;

	if (Chemin[0] == '\0')
	{	/* Chemin[x] vaut '\0' quelque soit x */
		Chemin[0] = 'A'+Drive;
		Chemin[1] = ':';
		Dgetpath(&Chemin[2], Drive+1);
		strcat(Chemin, "\\");
	}

	if (nom[0])
		strcpy(Fichier, nom);

	if ((no = FileSelect(info, Chemin, Fichier, filtre, 0, MAX_SELECTED_FILES, FselTable)) != 0)
	{
		Dsetdrv(Chemin[0] - 'A');	/* fixe le lecteur par d‚faut */
		Dsetpath(Chemin + 2);	/* fixe le chemin correspondant */

		strcpy(nom, Chemin);
		strcat(nom, FselTable[0]);
	}

	return no;
} /* selecteur */

/********************************************************************
*																	*
*					Choix d'une unit‚ physique						*
*																	*
********************************************************************/
int choix_unit(void)
{
	DIAINFO *info;
	int exit;
	static int mode, device;

	info = open_dialog(Dialog[CHOIX_UNIT].tree, NULL, NULL, NULL, TRUE, TRUE, AUTO_DIAL|MODAL|NO_ICONIFY, 0, NULL, NULL);

	PopUpMode2.p_info = info;
	PopUpUnit2.p_info = info;

	do
	{
		exit = X_Form_Do(NULL);

		/* enlŠve le flag double clic */
		exit &= NO_CLICK;

		if (exit == CHOIX_UNIT_OK || exit == CHOIX_UNIT_ANNUL)
			break;

		switch (exit)
		{
			case HD_MODE2:
			case HD_MODE_TEXTE2:
				Popup(&PopUpMode2, POPUP_BTN_CHK, OBJPOS, 0, 0, &mode, mode*2 +1);
				break;

			case HD_MODE_BUTTON2:
				Popup(&PopUpMode2, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &mode, mode*2 +1);
				break;

			case HD_UNIT2:
			case HD_UNIT_TEXTE2:
				Popup(&PopUpUnit2, POPUP_BTN_CHK, OBJPOS, 0, 0, &device, device*2 +1);
				break;

			case HD_UNIT_BUTTON2:
				Popup(&PopUpUnit2, POPUP_CYCLE_CHK, OBJPOS, 0, 0, &device, device*2 +1);
				break;
		}
	} while (TRUE);

	if (exit!=W_ABANDON && exit!=W_CLOSED)
	{
		exit &= 0x7fff;
		ob_undostate(Dialog[CHOIX_UNIT].tree, exit, SELECTED);
	}
	close_dialog(info, TRUE);

	if (exit == CHOIX_UNIT_OK)
		return mode*8+device;
	else
		return FAIL;
} /* choix_unit */

/****************************************************************
*																*
*				Gestion d'un slide en temps r‚el				*
*																*
****************************************************************/
int real_time_slide(windowptr thewin, OBJECT *arbre, int pere, int fils, int timer, boolean (*redraw)(windowptr thewin, int pos, int fast), int sens)
{
	int pos;
	int button, x, y, bx, by;
	XEVENT event;
	WIN *win = thewin -> win;
	GRECT rect;

	MouseFlatHand();

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_BUTTON | MU_M1;
	event.ev_mm1width = 1;
	event.ev_mm1height = 1;
	event.ev_mbclicks = 1;
	event.ev_mbmask = 1;
	event.ev_mbstate = 0;

	rt_timer = timer;

	Event_Handler(rt_init, rt_message);

 	if (sens)
		/* vertical */
		pos = (int)(((double)arbre[fils].ob_y / (arbre[pere].ob_height - arbre[fils].ob_height)) * 1000.);
	else
		/* horizontal */
		pos = (int)(((double)arbre[fils].ob_x / (arbre[pere].ob_width - arbre[fils].ob_width)) * 1000.);

	button = mouse(&x, &y);
	objc_offset(arbre, pere, &bx, &by);

	while (button)
	{
		event.ev_mm1flags = 1;
		event.ev_mm1x = x;
		event.ev_mm1y = y;

		Event_Multi(&event);

		if (event.ev_mwich & MU_BUTTON)
		{
			if (sens)
			{
				arbre[fils].ob_y = event.ev_mmoy - by;
				if (arbre[fils].ob_y < 0)
					arbre[fils].ob_y = 0;
				else
					if (arbre[fils].ob_y > arbre[pere].ob_height - arbre[fils].ob_height)
						arbre[fils].ob_y = arbre[pere].ob_height - arbre[fils].ob_height;

				pos = (int)(((double)arbre[fils].ob_y / (arbre[pere].ob_height - arbre[fils].ob_height)) * 1000.);
			}
			else
			{
				arbre[fils].ob_x = event.ev_mmox - bx;
				if (arbre[fils].ob_x < 0)
					arbre[fils].ob_x = 0;
				else
					if (arbre[fils].ob_x > arbre[pere].ob_width - arbre[fils].ob_width)
						arbre[fils].ob_x = arbre[pere].ob_width - arbre[fils].ob_width;

				pos = (int)(((double)arbre[fils].ob_x / (arbre[pere].ob_width - arbre[fils].ob_width)) * 1000.);
			}

			break;
		}

		if (event.ev_mwich & MU_TIMER2)
		{
			if ((*redraw)(thewin, pos, FALSE))
			{	/* on doit redessiner ? */
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(arbre, pere, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			event.ev_mflags &= ~MU_TIMER2;

			if (!(event.ev_mwich & MU_BUTTON))
				button = 1;	/* sinon  on s'arrˆte */
		}

		if (event.ev_mwich & MU_M1)
		{
			if (sens)
			{
				arbre[fils].ob_y = event.ev_mmoy - by;
				if (arbre[fils].ob_y < 0)
					arbre[fils].ob_y = 0;
				else
					if (arbre[fils].ob_y > arbre[pere].ob_height - arbre[fils].ob_height)
						arbre[fils].ob_y = arbre[pere].ob_height - arbre[fils].ob_height;

				pos = (int)(((double)arbre[fils].ob_y / (arbre[pere].ob_height - arbre[fils].ob_height)) * 1000.);
			}
			else
			{
				arbre[fils].ob_x = event.ev_mmox - bx;
				if (arbre[fils].ob_x < 0)
					arbre[fils].ob_x = 0;
				else
					if (arbre[fils].ob_x > arbre[pere].ob_width - arbre[fils].ob_width)
						arbre[fils].ob_x = arbre[pere].ob_width - arbre[fils].ob_width;

				pos = (int)(((double)arbre[fils].ob_x / (arbre[pere].ob_width - arbre[fils].ob_width)) * 1000.);
			}

			x = event.ev_mmox;
			y = event.ev_mmoy;

			if ((*redraw)(thewin, pos, TRUE))
			{	/* on doit redessiner ? */
				window_first(win, &rect);
				while (rect.g_w && rect.g_h)
				{
					objc_draw(arbre, pere, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
					window_next(win, &rect);
				}
			}

			/* attend la fin des redessins */
			Event_Timer(0, 0, TRUE);

			event.ev_mflags |= MU_TIMER2;
			event.ev_mt2count = rt_timer;
			event.ev_mt2last = 0L;

			if (!(event.ev_mwich & MU_BUTTON))
				button = 1;	/* sinon  on s'arrˆte */
		}

	}

	MouseArrow();

	(*redraw)(thewin, pos, FALSE);

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	/* on remet la gestion normale des ‚v‚nements */
	Event_Handler(InitMsg, Messag);

	/*
	  … chaque d‚placement:
	  - appeler la fonction d'affichage en passant le position relative
	    (1-1000)
	  - lancer le timer par evnt_multi(MU_TIMER|MU_BUTTON|MU_M1,...)
	  si le timer est ‚coul‚ avant le prochain d‚placement, appeler
	  la fonction d'affichage (affiche plus complŠt et plus lent)

	  d‚brayable avec le bouton droit (idem WinX)
	*/

	return pos;
} /* real_time_slide */

/****************************************************************
*																*
*					initialisation en temps r‚el				*
*																*
****************************************************************/
int rt_init(XEVENT *evt, int events_available)
{
	return events_available;
#pragma warn -par
} /* rt_init */
#pragma warn .par

/****************************************************************
*																*
*						message en temps r‚el					*
*																*
****************************************************************/
int rt_message(XEVENT *event)
{
	return event -> ev_mwich;
} /* rt_message */

/****************************************************************
*																*
*						message en temps r‚el					*
*																*
****************************************************************/
int my_alert(int b_default, int undo, int icon, char *texts, char *buttons)
{
	return xalert(b_default, undo, icon, NULL, DialogInWindow ? APPL_MODAL : SYS_MODAL, BUTTONS_RIGHT, 0, NULL, texts, buttons);
} /* my_alert */
