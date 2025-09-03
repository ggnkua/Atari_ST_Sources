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

#include "wind.h"
#include "ouvre.h"
#include "dialog.h"
#include "init.h"
#include "update.h"
#include "fat.h"
#include "divers.h"
#include "brut.h"
#include "fenetre.h"

#define rect_set(clip, x1, y1, x2, y2) \
	clip -> g_x = x1; \
	clip -> g_y = y1; \
	clip -> g_w = x2; \
	clip -> g_h = y2;

typedef void (*R_PROC)(WIN *,GRECT *);	/* voir proto.h de EGem */

/****************************************************************
*																*
*	do_window - determines the type of window event	and then	*
*	calls the appropriate function to handle the event.			*
*																*
****************************************************************/
void do_window(int message[8])
{
	int handle;

	handle = message[3];

	if (findwindowptr(handle) == NULL)
		return;

	switch (message[0])
	{
		case WM_ONTOP:
		case WM_NEWTOP:		/* la fenˆtre passe devant */
		case WM_TOPPED:
			make_frontwin(findwindowptr(handle));
			break;

		case WM_MOVED:		/* la fenˆtre est boug‚e ou agramdie */
		case WM_SIZED:
			do_resize(message);
			break;

		case WM_FULLED:		/* plein taille */
			do_fullsize(handle);
			break;

		case WM_CLOSED:		/* fermeture */
			fermer(handle);
			break;

		case WM_ARROWED:
			slide_window(message);
			break;

		case WM_HSLID:
			H_slide_window(message);
			break;

		case WM_VSLID:
			V_slide_window(message);
			break;

		case WM_UNTOPPED:	/* n'est plus devant */
			untopped(message);
			break;

		case WM_BOTTOM:		/* passe au fond */
			cycle_window();
			break;

		case WM_REDRAW:		/* redessin */
			break;
	}
} /* do_window */

/****************************************************************
*																*
*				la fenˆtre active ne l'est plus					*
*		Un accessoire ou une application … pris le devant		*
*																*
****************************************************************/
void untopped(int message[8])
{
	register windowptr thewin;
	int top;

	wind_get(0, WF_TOP, &top);

	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if (thewin -> win -> handle == top)
			break;

	if (!thewin)
	{
		/* remet un pointeur normal, c'est peut-ˆtre pas celui qu'il faut mais c'est mieux que rien */
		MouseArrow();

		/* ne test plus la sortie du rectangle */
		Zone.g_w = Zone.g_h = 0;
	}
#pragma warn -par
} /* untopped */
#pragma warn .par

/****************************************************************
*																*
*		cycle les fenˆtres, la derniŠre devient la premiŠre		*
*																*
****************************************************************/
void cycle_window(void)
{
	int handle, themax = 0;
	windowptr thewin = NULL;

	if (BottomIsMeaningful)
	{
		wind_get(0, WF_TOP, &handle);
		wind_set(handle, WF_BOTTOM);

		wind_get(0, WF_TOP, &handle);
		thewin = findwindowptr(handle);
	}
	else
	{
		for (thewin = Firstwindow; thewin; thewin = thewin -> next)
			themax = max(themax, thewin -> place);

		for (thewin = Firstwindow; thewin; thewin = thewin -> next)
			if (thewin -> place == themax)
				break;
	}

	if (thewin)
		make_frontwin(thewin);
} /* cycle_window */

/****************************************************************
*																*
*		H_slide_window - gŠre l'ascenseur horizontal			*
*																*
****************************************************************/
void H_slide_window(int message[8])
{
	int handle = message[3];
	register windowptr thewin = findwindowptr(handle);
	int caractere, pos, last_pos, delta;

	/* taille d'un caractŠre dans l'ascenseur */
	caractere = 8000 / (max_w - thewin -> win -> work.g_w);

	/* calcul la nouvelle position de l'ascenseur */
	pos = (message[4] / caractere)*caractere;

	/* r‚cupŠre l'ancienne */
	wind_get(handle, WF_HSLIDE, &last_pos);

	/* si c'est la mˆme on ne bouge pas */
	if (last_pos == pos)
		return;

	/*	actualise la place du curseur	*/
	wind_set(handle, WF_HSLIDE, pos);

	/* nouvelle coordonn‚e */
	/* toute la partie texte est commune au differents types de fenˆtres qui ont un ascensseur horizontal */
	delta = (message[4] / caractere) - thewin -> fonction.text.colonne;
	thewin -> fonction.text.colonne += delta;

	if (delta > 0)
		scroll_left(thewin, delta);
	else
		scroll_right(thewin, -delta);
} /* H_slide_window */

/****************************************************************
*																*
*		V_slide_window - gŠre l'ascenseur vertical				*
*																*
****************************************************************/
void V_slide_window(int message[8])
{
	int handle = message[3];
	register windowptr thewin = findwindowptr(handle);
	int delta, vslide, i, ligne = thewin -> fonction.text.ligne, Tligne = thewin -> fonction.text.PrintLine;
	float a, b;
	int taille_page = floor(thewin -> win -> work.g_h / thewin -> fonction.text.taille_h); /* nombre de lignes par page */

	a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
	b = a * (taille_page -1);

	if (a<=0)	/* pas assez de lignes pour pouvoir d‚placer quoi que ce soit */
		return;

	/* ancienne position */
	wind_get(handle, WF_VSLIDE, &vslide);

	delta = (int)floor((message[4]-vslide)/a);

	if (delta == 0)
		return;

	if (delta<0)
	{
		delta = -delta;

		/* on d‚place vers le haut */
		for (i = 0; i < delta && ligne >= taille_page; i++)
		{
			if (!Tligne--)	/* si == 0, on reboucle (tableau circulaire) */
				Tligne = thewin -> fonction.text.LineNumberMax-1;
			ligne--;
		}
		thewin -> fonction.text.ligne = ligne;
		thewin -> fonction.text.PrintLine = Tligne;

		if (thewin -> fonction.text.LineNumber -1 - taille_page)
			vslide = max(0, min(1000, (int)(a * ligne - b)));
		else
			vslide = 1000;

		scroll_up(thewin, delta);
	}
	else
	{
		/* on d‚place vers le bas */
		for (i = 0; i < delta && ligne < thewin -> fonction.text.LineNumber -1; i++)
		{
			if (Tligne++ == thewin -> fonction.text.LineNumberMax-1) /* on reboucle */
				Tligne = 0;
			ligne++;
		}
		thewin -> fonction.text.ligne = ligne;
		thewin -> fonction.text.PrintLine = Tligne;

		if (thewin -> fonction.text.LineNumber -1 - taille_page)
			vslide = min(1000, (int)(a * ligne - b));
		else
			vslide = 1000;

		scroll_down(thewin, delta);
	}

	/*	r‚actualise l'ascenseur	*/
	if (vslide >= 0)
		wind_set(handle, WF_VSLIDE, vslide);
} /* V_slide_window */

/****************************************************************
*																*
*			slide_window - gŠre les ascenseurs					*
*																*
****************************************************************/
void slide_window(int message[8])
{
	int handle = message[3];
	int hslide = FAIL, vslide = FAIL;
	windowptr thewin = findwindowptr(handle);
	WIN *win = thewin -> win;
	int update = TRUE;

	if (thewin -> kind_c & VSLIDE)
	{
		int page, Tligne = thewin -> fonction.text.PrintLine, ligne = thewin -> fonction.text.ligne;
		int taille_page = floor(win -> work.g_h / thewin -> fonction.text.taille_h); /* nombre de lignes par page */
		float a, b;

		a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
		b = a * (taille_page -1);

		switch (message[4]) {
			case WA_UPPAGE:		/* une page vers le haut */
				for (page = 0; page < taille_page && ligne >= taille_page ; page++)
				{
					if (!Tligne--) /* si == 0 */
						Tligne = thewin -> fonction.text.LineNumberMax-1;
					ligne--;
				}
				thewin -> fonction.text.PrintLine = Tligne;
				thewin -> fonction.text.ligne = ligne;
				if (thewin -> fonction.text.LineNumber -1 - taille_page)
					vslide = max(0, min(1000, (int)(a * ligne - b)));
				else
					vslide = 1000;
				break;

			case WA_DNPAGE:		/* une page vers le bas */
				for (page = 0; page < taille_page && ligne < thewin -> fonction.text.LineNumber -1; page++)
				{
					if (Tligne++ == thewin -> fonction.text.LineNumberMax-1)
						Tligne = 0;
					ligne++;
				}
				thewin -> fonction.text.PrintLine = Tligne;
				thewin -> fonction.text.ligne = ligne;
				if (thewin -> fonction.text.LineNumber -1 - taille_page)
					vslide = min(1000, (int)(a * ligne - b));
				else
					vslide = 1000;
				break;

			case WA_UPLINE:		/* une ligne vers le haut */
				if (ligne >= taille_page)
				{
					if (!Tligne--) /* si == 0 */
						Tligne = thewin -> fonction.text.LineNumberMax-1;

					thewin -> fonction.text.ligne = --ligne;
					thewin -> fonction.text.PrintLine = Tligne;

					scroll_up(thewin, 1);
				}
				update = FALSE;
				if (thewin -> fonction.text.LineNumber -1 - taille_page)
					vslide = min(1000, (int)(a * (float)ligne - b));
				else
					vslide = 1000;
				break;

			case WA_DNLINE:		/* une ligne vers le bas */
				if (ligne < thewin -> fonction.text.LineNumber -1)
				{
					if (Tligne++ == thewin -> fonction.text.LineNumberMax-1)
						Tligne = 0;

					thewin -> fonction.text.ligne = ++ligne;
					thewin -> fonction.text.PrintLine = Tligne;

					scroll_down(thewin, 1);
				}
				update = FALSE;
				if (thewin -> fonction.text.LineNumber -1 - taille_page)
					vslide = min(1000, (int)(a*ligne -b));
				else
					vslide = 1000;
				break;
		}

		/*	r‚actualise l'ascenseur	*/
		if (vslide >= 0)
			wind_set(handle, WF_VSLIDE, vslide);
	}

	if (thewin -> kind_c & HSLIDE)
	{
		int tranche, caractere;

		wind_get(handle, WF_HSLSIZE, &tranche);
		tranche = tranche < 500 ? 1000/(1000./tranche-1) : 1000;

		/* taille d'un caractŠre dans l'ascenseur */
		caractere = 8000 / (max_w - win -> work.g_w);

		wind_get(handle, WF_HSLIDE, &hslide);

		switch (message[4]) {
			case WA_LFPAGE:		/* une page vers la gauche */
				hslide = max(1, hslide-tranche);

				/* nouvelle coordonnee */
				thewin -> fonction.text.colonne = hslide /8000. * (max_w - win -> work.g_w);
				break;

			case WA_RTPAGE:		/* une page vers la droite */
				hslide = min(1000, hslide+tranche);

				/* nouvelle coordonnee */
				thewin -> fonction.text.colonne = hslide /8000. * (max_w - win -> work.g_w);
				break;

			case WA_LFLINE:		/* une colonne vers la gauche */
				hslide = max(1, hslide-caractere);

				if (thewin -> fonction.text.colonne)
				{
					thewin -> fonction.text.colonne--;
					scroll_right(thewin, 1);
				}

				update = FALSE;
				break;

			case WA_RTLINE:		/* une colonne vers la droite */
				hslide = min(1000, hslide+caractere);

				if (thewin -> fonction.text.colonne < (max_w - win -> work.g_w) / gr_cw)
				{
					thewin -> fonction.text.colonne++;
					scroll_left(thewin, 1);
				}

				update = FALSE;
		}

		/*	r‚actualise l'ascenseur	*/
		if (hslide >= 0)
			wind_set(handle, WF_HSLIDE, hslide);
	}

	if (update)
		/*	update la fenˆtre */
		redraw_window(win, &win -> work);
} /* slide_window */

/****************************************************************
*																*
*			scroll d'une colonne vers la gauche					*
*				avec un d‚placement de bloc						*
*																*
****************************************************************/
void scroll_left(windowptr thewin, int delta)
{
	GRECT rect, rect2, clip, work;
	WIN *win = thewin -> win;
	int vdi_handle = win -> vdi_handle;

	wind_update(BEG_UPDATE);
	MouseOff();

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

	rc_intersect(&desk, &work);

	delta *= gr_cw;

	/* update window */
	window_first(win, &rect);
	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);	/* pas l'ascenseur */

		clip = rect;
		clip.g_w += clip.g_x -1;
		clip.g_h += clip.g_y -1;

		/* reclipage pour le d‚placement */
		vs_clip(vdi_handle, 1, (int *)&clip);

		if (rc_sc_scroll(&rect, delta, 0, &rect2))
			(*(R_PROC) win->redraw)(win, &rect);

		/* bloc suivant */
		window_next(win, &rect);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* scroll_left */

/****************************************************************
*																*
*			scroll d'une colonne vers la droite					*
*				avec un d‚placement de bloc						*
*																*
****************************************************************/
void scroll_right(windowptr thewin, int delta)
{
	GRECT rect, rect2, clip, work;
	WIN *win = thewin -> win;
	int vdi_handle = win -> vdi_handle;

	wind_update(BEG_UPDATE);
	MouseOff();

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

	rc_intersect(&desk, &work);

	delta *= gr_cw;

	/* update window */
	window_first(win, &rect);
	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);	/* pas l'ascenseur */
		clip = rect;
		clip.g_w += clip.g_x -1;
		clip.g_h += clip.g_y -1;

		/* reclipage pour le d‚placement */
		vs_clip(vdi_handle, 1, (int *)&clip);

		if (rc_sc_scroll(&rect, -delta, 0, &rect2))
			(*(R_PROC) win->redraw)(win, &rect);

		/* bloc suivant */
		window_next(win, &rect);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* scroll_right */

/****************************************************************
*																*
*	scroll d'une ligne vers le bas avec un d‚placement de bloc	*
*																*
****************************************************************/
void scroll_up(windowptr thewin, int delta)
{
	GRECT rect, rect2, work, clip;
	WIN *win = thewin -> win;
	int vdi_handle = win -> vdi_handle;
	int taille = thewin -> fonction.text.taille_h;

	wind_update(BEG_UPDATE);
	MouseOff();

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

	rc_intersect(&desk, &work);

	delta *= taille;

	/* update window */
	window_first(win, &rect);
	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);	/* pas l'ascenseur */
		clip = rect;
		clip.g_w += clip.g_x -1;
		clip.g_h += clip.g_y -1;

		/* reclipage pour le d‚placement */
		vs_clip(vdi_handle, 1, (int *)&clip);

		if (rc_sc_scroll(&rect, 0, -delta, &rect2))
			(*(R_PROC) win->redraw)(win, &rect);

		/* bloc suivant */
		window_next(win, &rect);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* scroll_up */

/****************************************************************
*																*
*	scroll d'une ligne vers le haut avec un d‚placement de bloc	*
*																*
****************************************************************/
void scroll_down(windowptr thewin, int delta)
{
	GRECT rect, rect2, work, clip;
	WIN *win = thewin -> win;
	int vdi_handle = win -> vdi_handle;
	int taille = thewin -> fonction.text.taille_h;

	wind_update(BEG_UPDATE);
	MouseOff();

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

	rc_intersect(&desk, &work);

	delta *= taille;

	/* update window */
	window_first(win, &rect);

	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);	/* pas l'ascenseur */
		clip = rect;
		clip.g_w += clip.g_x -1;
		clip.g_h += clip.g_y -1;

		/* reclipage pour le d‚placement */
		vs_clip(vdi_handle, 1, (int *)&clip);

		if (rc_sc_scroll(&rect, 0, delta, &rect2))
			(*(R_PROC) win->redraw)(win, &rect);

		/* bloc suivant */
		window_next(win, &rect);
	}

	MouseOn();
	wind_update(END_UPDATE);
} /* scroll_down */

/****************************************************************
*																*
*	do_fullsize - draws the window at it's fully defined size.	*
*	If the window is at it's full size then this routines		*
*			restores the window to it's previous size.			*
*																*
****************************************************************/
void do_fullsize(int handle)
{
	windowptr thewin = findwindowptr(handle);
	WIN *win = thewin -> win;

	/* on remet les anciennes */
	if (win -> fulled)
		window_size(win, &win -> prev);
	else
		window_size(win, &win -> max);

	if (win -> gadgets & HSLIDE)	/* la fenˆtre … aussi un ascenseur vertical */
	{
		thewin -> fonction.text.colonne = min(thewin -> fonction.text.colonne, (max_w - win -> work.g_w)/8);
		wind_set(handle, WF_HSLSIZE, (int)(win -> work.g_w *1000. / max_w), 0, 0, 0);
		wind_set(handle, WF_HSLIDE, (int)(thewin -> fonction.text.colonne * 8000./(max_w - win -> work.g_w)));
	}

	if (thewin -> kind_c & VSLIDE)	/* la fenˆtre … aussi un ascenseur vertical */
	{
		float a, b;
		int ligne, Tligne, taille_page, line_number;

		taille_page = win -> work.g_h / thewin -> fonction.text.taille_h;
		ligne = thewin -> fonction.text.ligne; 
		if (ligne < taille_page);
		{
			Tligne = thewin -> fonction.text.PrintLine;
			line_number = thewin -> fonction.text.LineNumber -1;

			/* scroll vers le bas */
			while (ligne < taille_page && ligne < line_number)
			{
				if (Tligne++ == line_number) /* on reboucle */
					Tligne = 0;
				ligne++;
			}

			thewin -> fonction.text.ligne = ligne;
			thewin -> fonction.text.PrintLine = Tligne;
		}
	
		wind_set(handle, WF_VSLSIZE, min(1000, taille_page * 1000 / line_number), 0, 0, 0);

		if (thewin -> fonction.text.LineNumber -1 - taille_page)
		{
			a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
			b = a * (taille_page -1);
			Tligne = max(0, (int)(a * ligne - b));
		}
		else
			Tligne = 1000;
		wind_set(handle, WF_VSLIDE, Tligne);
	}

	switch(thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case RAW_FLOPPY:
		case RAW_HARD:
		case FICHIER_FS:
			update_slide(thewin);
			break;
	}

	/* si on repasse … l'ancienne taille */
	if (!win -> fulled)
		redraw_window(win, &win -> work);

	if (Zone.g_w)
		Zone = win -> work;
} /* do_fullsize */

/****************************************************************
*																*
*		do_resize - redraws the window at it's new postion		*
*		and updates all of the window's position records.		*
*																*
****************************************************************/
void do_resize(int message[8])
{
	int handle = message[3];
	int redraw, i;
	windowptr thewin = findwindowptr(handle);
	WIN *win = thewin -> win;
	GRECT rect, tmp = win -> curr;

	rect = *(GRECT *)&message[4];

	window_size(win, &rect);

	/* si la fenˆtre est plus petite, on force un redessin	*/
	redraw = win -> curr.g_w <= tmp.g_w && win -> curr.g_h < tmp.g_h || win -> curr.g_w < tmp.g_w && win -> curr.g_h <= tmp.g_h;

	for (i=0; i<WinEntrees; i++)
		if (Windows[i].fenetre == thewin)
		{
			Windows[i].box = win -> curr;
			break;
		}

	if (thewin -> win -> gadgets & HSLIDE)	/* la fenˆtre … aussi un ascenseur vertical */
	{
		float a, b;
		int ligne, Tligne, taille_page, line_number;

		thewin -> fonction.text.colonne = min(thewin -> fonction.text.colonne, (max_w - win -> work.g_w)/8);
		wind_set(handle, WF_HSLSIZE, (int)(win -> work.g_w *1000. / max_w), 0, 0, 0);
		wind_set(handle, WF_HSLIDE, (int)(thewin -> fonction.text.colonne * 8000./(max_w - win -> work.g_w)));

		taille_page = win -> work.g_h / thewin -> fonction.text.taille_h;
		ligne = thewin -> fonction.text.ligne; 
		if (ligne < taille_page);
		{
			Tligne = thewin -> fonction.text.PrintLine;
			line_number = thewin -> fonction.text.LineNumber -1;

			/* scroll vers le bas */
			while (ligne < taille_page && ligne < line_number)
			{
				if (Tligne++ == line_number) /* on reboucle */
					Tligne = 0;
				ligne++;
			}

			thewin -> fonction.text.ligne = ligne;
			thewin -> fonction.text.PrintLine = Tligne;
		}
	
		wind_set(handle, WF_VSLSIZE, min(1000, taille_page * 1000 / line_number), 0, 0, 0);

		if (thewin -> fonction.text.LineNumber -1 - taille_page)
		{
			a = 1000. / (thewin -> fonction.text.LineNumber - taille_page);
			b = a * (taille_page -1);
			Tligne = max(0, (int)(a * ligne - b));
		}
		else
			Tligne = 1000;
		wind_set(handle, WF_VSLIDE, Tligne);
	}

	switch (thewin -> type)
	{
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case RAW_FLOPPY:
		case RAW_HARD:
			update_slide(thewin);
			break;
	}

	if (redraw)
		redraw_window(win, &win -> work);

	if (Zone.g_w)
		Zone = win -> work;
} /* do_resize */

/****************************************************************
*																*
*						findwindowptr							*
*		find the window record associated with the window		*
*		handle and return a pointer to that window record.		*
*																*
****************************************************************/
windowptr findwindowptr(int handle)
{
	register windowptr thewin;

	for (thewin = Firstwindow; thewin; thewin = thewin -> next)
		if (thewin -> win -> handle == handle)
			break;

	return thewin;
} /* findwindowptr */

/****************************************************************
*																*
* r‚cupŠre les coordonn‚es … partir du fichier de configuration *
*																*
****************************************************************/
t_win_coord *get_info(int no, windowptr thewin, GRECT *rect)
{
	int i;
	t_win_coord *retour;

	switch (no)
	{
		case 0:
		case 1:
		case 2:
			Windows[no].fenetre = thewin;
			retour = &Windows[no];
			break;

		case 3:
			for (i=3; i<WinEntrees; i++)
				if (Windows[i].fenetre == NULL)
				{
					Windows[i].fenetre = thewin;
					retour = &Windows[i];
					break;
				}

			if (i == WinEntrees)
			{
				t_win_coord *new;

				/* la liste des positions est pleine, on se d‚brouille seul */

				if ((new = calloc(WinEntrees+8, sizeof(*Windows))) == NULL)
				{
					error_msg(Z_NOT_ENOUGH_MEMORY);
					retour = NULL;
				}
				else
				{
					/* les anciennes coordon‚es */
					for (i=0; i<WinEntrees; i++)
						new[i] = Windows[i];

					/* on reprend la premiŠre fenˆtre */
					for (i=WinEntrees; i<WinEntrees+8; i++)
					{
						new[i] = new[3];
						new[i].fenetre = thewin;
					}

					free(Windows);
					Windows = new;

					Windows[WinEntrees].fenetre = thewin;
					retour = &Windows[WinEntrees];
				}
			}
			break;
	}

	*rect = retour -> box;

	return retour;
} /* get_info */

/****************************************************************
*																*
*			new_window  -	create & draw a new window.			*
*																*
****************************************************************/
windowptr new_window(int thekind, char *title, char *info, void (*redraw_proc)(int ,WIN *, GRECT *), int type, int no)
{
	windowptr thewin;
	WIN *win;
	GRECT rect;
	t_win_coord *window;

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

	{
		size_t taille;
		char *ptr;

		switch (type)
		{
			case TEXT:
				taille = TEXTSIZE + LINENUMBER *4 + 50000L;
				break;

			case SECTEUR:
			case FICHIER:
			case FICHIER_FS:
			case TAMPON:
			case RAW_FLOPPY:
			case RAW_HARD:
				taille = 50000L;
				break;

			case OCCUP:
				taille = 1000L;
		}	
		if ((ptr = malloc(taille)) == NULL)
		{
			error_msg(Z_NOT_ENOUGH_MEMORY);
			return NULL;
		}
		free(ptr);
	}

	/* Allocate space for window record. */
	thewin = (windowptr)malloc(sizeof(windowrec));

	/* Initialize window data structure. */
	thewin -> next		= NULL;
	thewin -> kind_c	= thekind;	/* … la cr‚ation */
	thewin -> type		= type;
	thewin -> menu_entry = FAIL;
	thewin -> place 	= 0;

	/* initialise la fenˆtre suivant son type */
	switch (type)
	{
		case TEXT:	/* c'est du texte ligne … ligne */
		case SECTEUR:
		case FICHIER:
		case FICHIER_FS:
		case TAMPON:
		case RAW_FLOPPY:
		case RAW_HARD:
			if ((thewin -> fonction.text.Text = malloc(type == TEXT ? (size_t)TEXTSIZE : (size_t)SECTEURSIZE)) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);

				free(thewin);

				return NULL;
			}

			if ((thewin -> fonction.text.Ligne = (char **)malloc(type == TEXT ? (size_t)LINENUMBER * sizeof(char *) : (size_t)SECTEURLINE * sizeof(char *))) == NULL)
			{
				error_msg(Z_NOT_ENOUGH_MEMORY);

				free(thewin -> fonction.text.Text);
				free(thewin);

				return NULL;
			}

			if (type == TEXT)
			{
				register int k;
				register char **r;

				/* le bloc contient une ligne vide */
				thewin -> fonction.text.TextSize = TEXTSIZE;
				thewin -> fonction.text.LineNumberMax = LINENUMBER;
				thewin -> fonction.text.LineNumber = thewin -> fonction.text.CurrentLine = 1;
				thewin -> fonction.text.taille_pt = gr_ch == 8 ? 9 : 10;
				thewin -> fonction.text.taille_w = gr_cw;
				thewin -> fonction.text.taille_h = gr_ch;
				thewin -> fonction.text.reste = TEXTSIZE;
				thewin -> fonction.text.debut = thewin -> fonction.text.Text+1;
				thewin -> fonction.text.PrintLine = thewin -> fonction.text.ligne = thewin -> fonction.text.colonne = 0;

				/* une ligne vide */
				thewin -> fonction.text.Text[0] = '\0';

				/* initialise le tableau … NULL sauf le premier ‚lement qui pointe sur le bloc de text */
				r = thewin -> fonction.text.Ligne;
				r[0] = thewin -> fonction.text.Text;	/* ligne vide */
				for(k=1; k<LINENUMBER; k++)
					r[k] = NULL;
			}
			else
			{
				int k;

				/* le bloc contient d‚ja toutes les lignes remplies */
				thewin -> fonction.secteur.TextSize = SECTEURSIZE;
				thewin -> fonction.secteur.LineNumberMax = SECTEURLINE;
				thewin -> fonction.secteur.LineNumber = SECTEURLINE-2;
				thewin -> fonction.secteur.CurrentLine = SECTEURLINE-2;
				thewin -> fonction.secteur.taille_pt = gr_ch == 8 ? 9 : 10;
				thewin -> fonction.secteur.taille_w = gr_cw;
				thewin -> fonction.secteur.taille_h = gr_ch;
				thewin -> fonction.secteur.PrintLine = SECTEURLINE-3;
				thewin -> fonction.secteur.ligne = SECTEURLINE-3;
				thewin -> fonction.secteur.colonne = 0;

				/* chaque ligne … 0 */
				*thewin -> fonction.secteur.Text = '\0';

				for (k=1; k<SECTEURLINE; k++)	/* la premiŠre ligne est deux fois plus grande */
					thewin -> fonction.secteur.Text[(k+1) * SECTEURLINESIZE] = '\0';

				/* un pointeur sur chaque ligne */
				thewin -> fonction.secteur.Ligne[0] = thewin -> fonction.secteur.Text;

				for (k=1; k<SECTEURLINE; k++)
					thewin -> fonction.secteur.Ligne[k] = &thewin -> fonction.secteur.Text[(k+1) * SECTEURLINESIZE];
			}
			break;
	}

	/* r‚cupŠre la taille d'aprŠs le fichier de configuration */
	window = get_info(no, thewin, &rect);

	/* ouvre la fenˆtre */
	win = open_window(title, title, info, NULL, window -> type, TRUE, 10, 10, &desk, &rect, NULL, redraw_proc, NULL, 0);

	thewin -> win = win;

	/* Check for error. */
	if (win == NULL)
	{
		error_msg(Z_NOT_ENOUGH_MEMORY);
		return NULL;
	}

	if (!open_work(&win -> vdi_handle, work_out))
	{
		my_alert(1, FAIL, X_ICN_STOP, Messages(MAIN_9), NULL);
		close_window(win, FALSE);
		return NULL;
	}

	if (type >= TAMPON)
	{	/* secteur */
		int dummy;

		thewin -> fonction.secteur.couleur_curseur = window -> fonction.texte.curseur_c;
		thewin -> fonction.secteur.trame_curseur = window -> fonction.texte.curseur_t;
		thewin -> fonction.text.couleur_texte = window -> fonction.texte.texte_c;
		thewin -> fonction.text.taille_pt = window -> fonction.texte.texte_pt;

		vst_point(win -> vdi_handle, thewin -> fonction.text.taille_pt, &dummy, &dummy, &thewin -> fonction.text.taille_w, &thewin -> fonction.text.taille_h);
		vst_color(win -> vdi_handle, thewin -> fonction.secteur.couleur_texte);
		vsf_interior(win -> vdi_handle, FIS_SOLID);
		vswr_mode(win -> vdi_handle, MD_REPLACE);
		vsf_perimeter(win -> vdi_handle, 0);

		thewin -> fonction.text.couleur_fond = window -> fonction.texte.background_c;
		thewin -> fonction.text.trame_fond = window -> fonction.texte.background_t;
	}
	else
		if (type == TEXT)
		{ /* texte */
			int dummy;

			thewin -> fonction.text.couleur_texte = window -> fonction.texte.texte_c;
			thewin -> fonction.text.taille_pt = window -> fonction.texte.texte_pt;

			vst_point(win -> vdi_handle, thewin -> fonction.text.taille_pt, &dummy, &dummy, &thewin -> fonction.text.taille_w, &thewin -> fonction.text.taille_h);
			vst_color(win -> vdi_handle, thewin -> fonction.secteur.couleur_texte);
			vsf_interior(win -> vdi_handle, FIS_SOLID);
			vswr_mode(win -> vdi_handle, MD_REPLACE);
			vsf_perimeter(win -> vdi_handle, 0);

			thewin -> fonction.text.couleur_fond = window -> fonction.texte.background_c;
			thewin -> fonction.text.trame_fond = window -> fonction.texte.background_t;
		}
		else
		{ /* occupation */
			thewin -> fonction.occup.couleur_fond = window -> fonction.occup.background_c;
			thewin -> fonction.occup.trame_fond = window -> fonction.occup.background_t;

			thewin -> fonction.occup.couleur_blocs = window -> fonction.occup.blocs_c;
			thewin -> fonction.occup.trame_blocs = window -> fonction.occup.blocs_t;

			thewin -> fonction.occup.couleur_bad_blocs = window -> fonction.occup.bad_blocs_c;
			thewin -> fonction.occup.trame_bad_blocs = window -> fonction.occup.bad_blocs_t;

			thewin -> fonction.occup.couleur_selected = window -> fonction.occup.selected_c;
			thewin -> fonction.occup.trame_selected = window -> fonction.occup.selected_t;

			thewin -> fonction.occup.couleur_fragment = window -> fonction.occup.fragmented_c;
			thewin -> fonction.occup.trame_fragment = window -> fonction.occup.fragmented_t;

			thewin -> fonction.occup.couleur_end = window -> fonction.occup.end_marq_c;
			thewin -> fonction.occup.trame_end = window -> fonction.occup.end_marq_t;

			vsf_perimeter(win -> vdi_handle, 0);
		}

	/* Set the title for the window. */
	if (thekind & NAME)
	{
		strncpy(thewin -> title, title, MAX_TITLE+1);
		window_name(win, thewin -> title, thewin -> title);
	}

	if (thekind & INFO)
	{
		strncpy(thewin -> info, info, MAX_TITLE+1);
		window_info(win, thewin -> info);
	}

	/* initialise les ascenseurs */
	if (thewin -> win -> gadgets & HSLIDE)
		wind_set(win -> handle, WF_HSLSIZE, (int)(win -> work.g_w *1000. / max_w), 0, 0, 0);

	if (thewin -> win -> gadgets & VSLIDE)
	{
		wind_set(win -> handle, WF_VSLSIZE, 1000);
		wind_set(win -> handle, WF_VSLIDE, 1000);
	}

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

	return thewin;
} /* new_window */

/****************************************************************
*																*
*						dispose_window							*
*		Closes the window and disposes the storage for			*
*						the window record.						*
*																*
****************************************************************/
void dispose_window(windowptr thewin)
{
	int x;
#ifndef TEST_VERSION
	int err;
#endif

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

#ifndef TEST_VERSION
	if (thewin -> type >= SECTEUR && thewin -> fonction.secteur.dirty && my_alert(1, 2, X_ICN_QUESTION, Messages(SECTEUR_4), Messages(BOOT_32)) == 0)
		switch (thewin -> type)	/* on sauve avant de fermer */
		{
			case SECTEUR:
				my_rwabs(1, thewin -> fonction.secteur.secteurBin, 1, thewin -> fonction.secteur.secteur, thewin -> fonction.secteur.device);
				/* on ne change_disque() pas car dispose_window() serait appel‚ dans un change_disque() sans fin */
				break;
	
			case FICHIER:
				my_rwabs(1, thewin -> fonction.fichier.secteurBin, 1, thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur], thewin -> fonction.fichier.device);
				break;
	
			case FICHIER_FS:
				my_rwabs(1, thewin -> fonction.fichier_fs.secteurBin, 1, thewin -> fonction.fichier_fs.secteur, thewin -> fonction.fichier_fs.file_desc);
				if ((err = Fclose(-thewin -> fonction.fichier_fs.file_desc)) != 0)
					error_msg(err);
				break;
	
			case RAW_FLOPPY:
				if ((err = Flopwr(thewin -> fonction.raw_floppy.secteurBin, 0L, thewin -> fonction.raw_floppy.lecteur, thewin -> fonction.raw_floppy.real_secteur, thewin -> fonction.raw_floppy.piste, thewin -> fonction.raw_floppy.face, 1)) != 0)
					error_msg(err);
				break;
	
			case RAW_HARD:
				if (my_DMAwrite(thewin -> fonction.raw_hard.secteur, 1, thewin -> fonction.raw_hard.secteurBin, thewin -> fonction.raw_hard.device))
					error_msg(Z_READ_WRITE);
				break;
		}
#endif

	close_work(thewin -> win -> vdi_handle);
	close_window(thewin -> win, TRUE);

	{
		/* Remove window record from window list. */
		register windowptr winptr = (windowptr)&Firstwindow;

		while(winptr -> next)
			if (winptr -> next == thewin)
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
			int place = thewin -> place;

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

		/* Release window storage. */
		switch (thewin -> type)
		{
			case TEXT:
				free(thewin -> fonction.text.Text);
				free(thewin -> fonction.text.Ligne);
				break;

			case TAMPON:
				menu_ienable(Menu, OUVRIR_TAMPON, 1);
				break;

			case FICHIER:
				free(thewin -> fonction.fichier.table);
				/* ne pas mettre de break, on continue */

			case SECTEUR:
				sector_free(thewin -> fonction.secteur.secteurBin);

			case FICHIER_FS:
			case RAW_FLOPPY:
			case RAW_HARD:
				free(thewin -> fonction.fichier.slide);
				free(thewin -> fonction.secteur.Text);
				free(thewin -> fonction.secteur.Ligne);
				if (thewin -> fonction.secteur.goto_liste)
				{
					t_goto *courant, *last;

					courant = thewin -> fonction.secteur.goto_liste;
					last = NULL;
					while (courant)
					{
						last = courant;
						courant = courant -> suivant;
						free(last);
					}
				}

				for (x=0; x<WinEntrees; x++)
					if (Windows[x].fenetre == thewin)
						Windows[x].fenetre = NULL;
				break;
		}

		if (thewin -> menu_entry > FAIL)
		{
			memset(MenuShortCuts[6].menu[WINDOW_LIST_1 - CHOIX_FONTE +thewin -> menu_entry].text, ' ', MenuShortCuts[6].size -SHORTCUT_SIZE -1);
			menu_ienable(Menu, WINDOW_LIST_1 +thewin -> menu_entry, FALSE);
			menu_icheck(Menu, WINDOW_LIST_1 +thewin -> menu_entry, FALSE);
			*(PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 +thewin -> menu_entry].ob_spec.free_string +1) = '\0';
			PopUpEntryTree[6][WINDOW_LIST_1 - CHOIX_FONTE +1 +thewin -> menu_entry].ob_state |= DISABLED;
		}

		free(thewin);
	}

	/* attend la fin des redessins */
	Event_Timer(0, 0, TRUE);

} /* dispose_window */

/****************************************************************
*																*
*			make_frontwin - Force a window to the front.		*
*																*
****************************************************************/
void make_frontwin(windowptr thewin)
{
	int place, i;

	wind_set(thewin -> win -> handle, WF_TOP, 0, 0, 0, 0);
	Thefrontwin = thewin;

	Zone = thewin -> win -> work;

	for (i=0; i<10; i++)
		menu_icheck(Menu, WINDOW_LIST_1 +i, FALSE);

	if (thewin -> menu_entry > FAIL)
		menu_icheck(Menu, WINDOW_LIST_1 + thewin -> menu_entry, TRUE);

	switch (thewin -> type)
	{
		case SECTEUR:
			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FERMER, 1);

			menu_ienable(Menu, FICHIER_ASSOCIE, 1);
			menu_icheck(Menu, FICHIER_ASSOCIE, thewin -> fonction.secteur.fichier);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);	/* voir case TAMPON: */
			menu_ienable(Menu, RETOUR_INITIAL, 1);

			menu_icheck(Menu, VISU_ASCII, thewin -> fonction.secteur.ascii);
			menu_icheck(Menu, VISU_HEXA, 1-thewin -> fonction.secteur.ascii);
			menu_ienable(Menu, VISU_ASCII, 1);
			menu_ienable(Menu, VISU_HEXA, 1);

			menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.secteur.decimal);
			menu_ienable(Menu, AFFICHE_DECIMAL, 1);

			menu_icheck(Menu, CURSEUR_VISIBLE, thewin -> fonction.secteur.curseur_x < 0 ? 0 : 1);
			menu_ienable(Menu, CURSEUR_VISIBLE, 1);
			Menu[MENU_DEPLACEMENT].ob_state &= ~DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);
			menu_ienable(Menu, COPIER_SECTEUR, 1);
			menu_ienable(Menu, COLLER_SECTEUR, 1);
			menu_ienable(Menu, RETOUR_INITIAL, 1);
			menu_ienable(Menu, ECHANGER_TAMPON, 1);
			menu_ienable(Menu, CHOIX_FONTE, 1);
			break;

		case FICHIER:
		case FICHIER_FS:
			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FERMER, 1);

			menu_ienable(Menu, FICHIER_ASSOCIE, 0);
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);	/* voir case TAMPON: */
			menu_ienable(Menu, RETOUR_INITIAL, 1);

			menu_icheck(Menu, VISU_ASCII, thewin -> fonction.secteur.ascii);
			menu_icheck(Menu, VISU_HEXA, 1-thewin -> fonction.secteur.ascii);
			menu_ienable(Menu, VISU_ASCII, 1);
			menu_ienable(Menu, VISU_HEXA, 1);

			menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.secteur.decimal);
			menu_ienable(Menu, AFFICHE_DECIMAL, 1);

			menu_icheck(Menu, CURSEUR_VISIBLE, thewin -> fonction.secteur.curseur_x < 0 ? 0 : 1);
			menu_ienable(Menu, CURSEUR_VISIBLE, 1);
			Menu[MENU_DEPLACEMENT].ob_state &= ~DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 1);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);
			menu_ienable(Menu, COPIER_SECTEUR, 1);
			menu_ienable(Menu, COLLER_SECTEUR, 1);
			menu_ienable(Menu, RETOUR_INITIAL, 1);
			menu_ienable(Menu, ECHANGER_TAMPON, 1);
			menu_ienable(Menu, CHOIX_FONTE, 1);
			break;

		case RAW_FLOPPY:
		case RAW_HARD:
			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FERMER, 1);

			menu_ienable(Menu, FICHIER_ASSOCIE, 0);
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);	/* voir case TAMPON: */
			menu_ienable(Menu, RETOUR_INITIAL, 1);

			menu_icheck(Menu, VISU_ASCII, thewin -> fonction.secteur.ascii);
			menu_icheck(Menu, VISU_HEXA, 1-thewin -> fonction.secteur.ascii);
			menu_ienable(Menu, VISU_ASCII, 1);
			menu_ienable(Menu, VISU_HEXA, 1);

			menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.secteur.decimal);
			menu_ienable(Menu, AFFICHE_DECIMAL, 1);

			menu_icheck(Menu, CURSEUR_VISIBLE, thewin -> fonction.secteur.curseur_x < 0 ? 0 : 1);
			menu_ienable(Menu, CURSEUR_VISIBLE, 1);
			Menu[MENU_DEPLACEMENT].ob_state &= ~DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 1);
			menu_ienable(Menu, COPIER_SECTEUR, 1);
			menu_ienable(Menu, COLLER_SECTEUR, 1);
			menu_ienable(Menu, RETOUR_INITIAL, 1);
			menu_ienable(Menu, ECHANGER_TAMPON, 1);
			menu_ienable(Menu, CHOIX_FONTE, 1);
			break;

		case TAMPON:
			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FERMER, 1);

			menu_ienable(Menu, FICHIER_ASSOCIE, 0);	/* pas de fichier associ‚ */
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 0);	/* on ne sauve pas */
			menu_ienable(Menu, RETOUR_INITIAL, 0);	/* pas de reload non plus */

			menu_icheck(Menu, VISU_ASCII, thewin -> fonction.secteur.ascii);
			menu_icheck(Menu, VISU_HEXA, 1-thewin -> fonction.secteur.ascii);
			menu_ienable(Menu, VISU_ASCII, 1);
			menu_ienable(Menu, VISU_HEXA, 1);

			menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.secteur.decimal);
			menu_ienable(Menu, AFFICHE_DECIMAL, 1);

			menu_icheck(Menu, CURSEUR_VISIBLE, thewin -> fonction.secteur.curseur_x < 0 ? 0 : 1); /* curseur affich‚ */
			menu_ienable(Menu, CURSEUR_VISIBLE, 1);
			Menu[MENU_DEPLACEMENT].ob_state |= DISABLED;	/* pas de d‚placement */

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 0);
			menu_ienable(Menu, COPIER_SECTEUR, 0);
			menu_ienable(Menu, COLLER_SECTEUR, 0);
			menu_ienable(Menu, RETOUR_INITIAL, 0);
			menu_ienable(Menu, ECHANGER_TAMPON, 0);
			menu_ienable(Menu, CHOIX_FONTE, 1);
			break;

		case TEXT:
			/* pas de pointeur en doigt */
			Zone.g_w = Zone.g_h = 0;

			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FERMER, thewin != Firstwindow);

			menu_icheck(Menu, VISU_ASCII, 0);
			menu_icheck(Menu, VISU_HEXA, 0);
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);
			menu_ienable(Menu, VISU_ASCII, 0);
			menu_ienable(Menu, VISU_HEXA, 0);
			menu_ienable(Menu, FICHIER_ASSOCIE, 0);
			menu_ienable(Menu, AFFICHE_DECIMAL, 0);

			menu_ienable(Menu, CURSEUR_VISIBLE, 0);
			menu_icheck(Menu, CURSEUR_VISIBLE, 0);
			Menu[MENU_DEPLACEMENT].ob_state |= DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 0);
			menu_ienable(Menu, COPIER_SECTEUR, ClipBoard);
			menu_ienable(Menu, COLLER_SECTEUR, 0);
			menu_ienable(Menu, RETOUR_INITIAL, 0);
			menu_ienable(Menu, ECHANGER_TAMPON, 0);
			menu_ienable(Menu, CHOIX_FONTE, 1);
			break;

		case OCCUP:
			/* pas de pointeur en doigt */
			Zone.g_w = Zone.g_h = 0;

			menu_icheck(Menu, ASCENSEURS, thewin -> win -> gadgets & SIZER);

			menu_ienable(Menu, FICHIER_ASSOCIE, 1);
			menu_icheck(Menu, FICHIER_ASSOCIE, thewin -> fonction.occup.fichier);

			menu_ienable(Menu, AFFICHE_DECIMAL, 1);
			menu_icheck(Menu, AFFICHE_DECIMAL, thewin -> fonction.occup.decimal);

			menu_ienable(Menu, FERMER, 1);

			menu_icheck(Menu, VISU_ASCII, 0);
			menu_icheck(Menu, VISU_HEXA, 0);
			menu_ienable(Menu, VISU_ASCII, 0);
			menu_ienable(Menu, VISU_HEXA, 0);

			menu_ienable(Menu, CURSEUR_VISIBLE, 0);
			menu_icheck(Menu, CURSEUR_VISIBLE, 0);
			Menu[MENU_DEPLACEMENT].ob_state |= DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 0);
			menu_ienable(Menu, COPIER_SECTEUR, 0);
			menu_ienable(Menu, COLLER_SECTEUR, 0);
			menu_ienable(Menu, RETOUR_INITIAL, 0);
			menu_ienable(Menu, ECHANGER_TAMPON, 0);
			menu_ienable(Menu, CHOIX_FONTE, 0);
			break;

		default:
			/* pas de pointeur en doigt */
			Zone.g_w = Zone.g_h = 0;

			menu_icheck(Menu, ASCENSEURS, 0);

			menu_ienable(Menu, FERMER, 0);

			menu_icheck(Menu, VISU_ASCII, 0);
			menu_icheck(Menu, VISU_HEXA, 0);
			menu_icheck(Menu, FICHIER_ASSOCIE, 0);
			menu_ienable(Menu, VISU_ASCII, 0);
			menu_ienable(Menu, VISU_HEXA, 0);
			menu_ienable(Menu, FICHIER_ASSOCIE, 0);
			menu_ienable(Menu, AFFICHE_DECIMAL, 0);

			menu_ienable(Menu, CURSEUR_VISIBLE, 0);
			menu_icheck(Menu, CURSEUR_VISIBLE, 0);
			Menu[MENU_DEPLACEMENT].ob_state |= DISABLED;

			menu_ienable(Menu, VISU_TEXTE, 0);

			menu_ienable(Menu, SAUVER_SECTEUR, 0);
			menu_ienable(Menu, COPIER_SECTEUR, 0);
			menu_ienable(Menu, COLLER_SECTEUR, 0);
			menu_ienable(Menu, RETOUR_INITIAL, 0);
			menu_ienable(Menu, ECHANGER_TAMPON, 0);
			menu_ienable(Menu, CHOIX_FONTE, 0);
	}

	menu_bar(Menu, 1);

	if (!BottomIsMeaningful)
	{
		place = thewin -> place;
		thewin -> place = FAIL;
		for (thewin = Firstwindow; thewin; thewin = thewin -> next)
			if (thewin -> place < place)
				thewin -> place++;
	}
} /* make_frontwin */
