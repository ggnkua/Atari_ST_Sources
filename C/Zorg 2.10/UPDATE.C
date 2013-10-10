/********************************************************************
*																	*
*				ZORG is copyright 1991-1998 by Ludovic ROUSSEAU		*
*																	*
*				read the file COPYING for redistribution			*
*																	*
********************************************************************/
#include <e_gem.h>
#include <math.h>

#include "globals.h"
#include "zorg.h"

#include "update.h"
#include "string.h"
#include "wind.h"

/****************************************************************
*																*
*			affiche l'occupation d'un disque					*
*																*
****************************************************************/
void occupationproc(int first, WIN *win, GRECT *clip)
{
	int vdi_handle = win -> vdi_handle;
	unsigned int i;
	windowptr thewin = findwindowptr(win -> handle);
	BPB bpb = Bpb[thewin -> fonction.occup.device];
	unsigned int numcl = bpb.numcl +1, *fat = FAT[thewin -> fonction.occup.device];
	int size_x, size_y, large = win -> work.g_x+win -> work.g_w-2;
	int cx1, cx2, x, y, nx;
	GRECT box;
	GRECT work = win -> work;

	MouseOff();	/* cache la souris */

	if (thewin -> fonction.occup.trame_fond > 0 && thewin -> fonction.occup.trame_fond < 7)
	{
		vsf_interior(vdi_handle, FIS_PATTERN);
		vsf_style(vdi_handle, thewin -> fonction.occup.trame_fond);
	}
	else
		vsf_interior(vdi_handle, FIS_SOLID);
	
	vsf_color(vdi_handle, thewin -> fonction.occup.couleur_fond);

	box = *clip;
	box.g_w += box.g_x;
	box.g_h += box.g_y;
	v_bar(vdi_handle, (int *)&box);

	if (thewin -> fonction.occup.trame_blocs > 0 && thewin -> fonction.occup.trame_blocs < 7)
	{
		vsf_interior(vdi_handle, FIS_PATTERN);
		vsf_style(vdi_handle, thewin -> fonction.occup.trame_blocs);
	}
	else
		vsf_interior(vdi_handle, FIS_SOLID);

	vsf_color(vdi_handle, thewin -> fonction.occup.couleur_blocs);

	if (gr_ch == 16)
		size_x = (int)floor(sqrt((work.g_h-3.0)*(work.g_w-3.0)/(double)numcl));
	else
		size_x = (int)floor(sqrt((2*(work.g_h-3.0))*(work.g_w-3.0)/(double)numcl));
	nx = (int)floor((work.g_w-3.0)/size_x);
	size_y = (int)floor((work.g_h-3.0)/(int)ceil((double)numcl/(double)nx));

	if (size_y < 2 && size_x > 2)
	{
		size_x--;
		nx = (int)floor((work.g_w-3.0)/size_x);
		size_y = (int)floor((work.g_h-3.0)/(int)ceil((double)numcl/(double)nx));
	}

	if (size_x<2 || size_y<2)
	{
		MouseOn();	/* remet la souris */
		return;
	}

	large -= size_x-1;

	x = work.g_x+2;
	y = work.g_y+2;
	numcl += 1;
	if (clip -> g_x <= work.g_x && clip -> g_y <= work.g_y)
	{
		cx1 = clip -> g_x - size_x;
		cx2 = clip -> g_x + clip -> g_w + size_x;

		for (i=2; i<numcl; i++)
		{
			if (fat[i] && x<=cx2 && x>=cx1)
				if (fat[i] >= 0xFFF0 && fat[i] <= 0xFFF7)
				{
					if (thewin -> fonction.occup.trame_bad_blocs > 0 && thewin -> fonction.occup.trame_bad_blocs < 7)
					{
						vsf_interior(vdi_handle, FIS_PATTERN);
						vsf_style(vdi_handle, thewin -> fonction.occup.trame_bad_blocs);
					}
					else
						vsf_interior(vdi_handle, FIS_SOLID);

					vsf_color(vdi_handle, thewin -> fonction.occup.couleur_bad_blocs);

					box.g_x = x;
					box.g_y = y;
					box.g_w = box.g_x + size_x-2;
					box.g_h = box.g_y + size_y-2;
					v_bar(vdi_handle, (int *)&box);

					if (thewin -> fonction.occup.trame_blocs > 0 && thewin -> fonction.occup.trame_blocs < 7)
					{
						vsf_interior(vdi_handle, FIS_PATTERN);
						vsf_style(vdi_handle, thewin -> fonction.occup.trame_blocs);
					}
					else
						vsf_interior(vdi_handle, FIS_SOLID);

					vsf_color(vdi_handle, thewin -> fonction.occup.couleur_blocs);
				}
				else
				{
					box.g_x = x;
					box.g_y = y;
					box.g_w = box.g_x + size_x-2;
					box.g_h = box.g_y + size_y-2;
					v_bar(vdi_handle, (int *)&box);
				}
			x += size_x;
			if (x > large)
			{
				x = work.g_x+2;
				y += size_y;
				if (y > clip -> g_y + clip -> g_h)
					break;
			}
		}
	}
	else
	{
		unsigned int start;

		/* on 'saute' la premiŠre ligne */
		if (clip -> g_y == work.g_y)
			clip -> g_y += 2;

		y = clip -> g_y - (clip -> g_y - work.g_y-2) % size_y;

		start = 2;
		for (cx2=work.g_y+2; cx2<y; cx2 += size_y)
			start += nx;

		cx1 = clip -> g_x - size_x;
		cx2 = clip -> g_x + clip -> g_w + size_x;
		for (i=start; i<numcl; i++)
		{
			if (fat[i] && x<=cx2 && x>=cx1)
				if (fat[i] >= 0xFFF0 && fat[i] <= 0xFFF7)
				{
					if (thewin -> fonction.occup.trame_bad_blocs > 0 && thewin -> fonction.occup.trame_bad_blocs < 7)
					{
						vsf_interior(vdi_handle, FIS_PATTERN);
						vsf_style(vdi_handle, thewin -> fonction.occup.trame_bad_blocs);
					}
					else
						vsf_interior(vdi_handle, FIS_SOLID);

					vsf_color(vdi_handle, thewin -> fonction.occup.couleur_bad_blocs);

					box.g_x = x;
					box.g_y = y;
					box.g_w = box.g_x + size_x-2;
					box.g_h = box.g_y + size_y-2;
					v_bar(vdi_handle, (int *)&box);

					if (thewin -> fonction.occup.trame_blocs > 0 && thewin -> fonction.occup.trame_blocs < 7)
					{
						vsf_interior(vdi_handle, FIS_PATTERN);
						vsf_style(vdi_handle, thewin -> fonction.occup.trame_blocs);
					}
					else
						vsf_interior(vdi_handle, FIS_SOLID);

					vsf_color(vdi_handle, thewin -> fonction.occup.couleur_blocs);
				}
				else
				{
					box.g_x = x;
					box.g_y = y;
					box.g_w = box.g_x + size_x-2;
					box.g_h = box.g_y + size_y-2;
					v_bar(vdi_handle, (int *)&box);
				}
			x += size_x;
			if (x > large)
			{
				x = work.g_x+2;
				y += size_y;
				if (y > clip -> g_y + clip -> g_h)
					break;
			}
		}
	}

	if (i == numcl)
	{
		if (thewin -> fonction.occup.trame_end > 0 && thewin -> fonction.occup.trame_end < 7)
		{
			vsf_interior(vdi_handle, FIS_PATTERN);
			vsf_style(vdi_handle, thewin -> fonction.occup.trame_end);
		}
		else
			vsf_interior(vdi_handle, FIS_SOLID);

		vsf_color(vdi_handle, thewin -> fonction.occup.couleur_end);

		box.g_x = x;
		box.g_y = y;
		box.g_w = box.g_x + size_x-2;
		box.g_h = box.g_y + size_y-2;
		v_bar(vdi_handle, (int *)&box);
	}

	MouseOn();	/* remet la souris */
#pragma warn -par
} /* occupationproc */
#pragma warn .par

/****************************************************************
*																*
*				affiche le texte d'un secteur					*
*																*
****************************************************************/
void secteurproc(int first, WIN *win, GRECT *clip)
{
	int vdi_handle = win -> vdi_handle;
	windowptr thewin = findwindowptr(win -> handle);
	GRECT rect;

	rect = *clip;
	rect.g_w += rect.g_x -1;
	rect.g_h += rect.g_y -1;

	MouseOff();	/* cache la souris */

	/* efface la partie … r‚afficher */
	if (Efface)
		rc_sc_clear(clip);

	/* affiche l'ascenseur de d‚placement */
	if (thewin -> type != TAMPON)
	{
		GRECT box;

		redraw_slide(thewin , clip);

		/* reclip pour ne pas effacer l'ascenseur */
		box = win -> work;
		box.g_w += box.g_x - thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

		/* intersection du clip et de la surface de travail moins l'ascenseur */
		if (box.g_w < rect.g_w)
			rect.g_w = box.g_w;

		/* il fallait juste redessiner l'ascensseur */
		if (rect.g_w < rect.g_x)
		{
			MouseOn();	/* remet la souris */
			return;
		}

		vs_clip(vdi_handle, 1, (int *)&rect);
	}

	aff_text(thewin, &rect);

	/* redessine le curseur */
 	if (thewin -> fonction.fichier.curseur_x >= 0 && thewin -> fonction.fichier.ligne != 21)
 	{
		int xon, yon;
		GRECT box;
		int g_w = thewin -> fonction.secteur.taille_w, g_h = thewin -> fonction.secteur.taille_h;

		vst_color(vdi_handle, thewin -> fonction.secteur.couleur_curseur);

		xon = thewin -> win -> work.g_x + (thewin -> fonction.fichier.curseur_x +6 - thewin -> fonction.fichier.colonne)*g_w;
		yon = thewin -> win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne -3)*g_h -2;
		v_gtext(vdi_handle, xon, yon, "");

		xon = thewin -> win -> work.g_x + (4 - thewin -> fonction.fichier.colonne)*g_w;
		yon = thewin -> win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne - thewin -> fonction.fichier.curseur_y -4)*g_h -2;
		v_gtext(vdi_handle, xon, yon, "");

		xon = thewin -> fonction.fichier.curseur_x/2;
		yon = thewin -> fonction.fichier.curseur_y;

		vswr_mode(vdi_handle, MD_XOR);
		box.g_x = thewin -> win -> work.g_x + (xon*2+6 - thewin -> fonction.fichier.colonne)*g_w;
		box.g_y = thewin -> win -> work.g_y + thewin -> win -> work.g_h - (thewin -> fonction.fichier.ligne - yon-3)*g_h;
		box.g_w = box.g_x + g_w*2 -1;
		box.g_h = box.g_y + g_h-1;
		v_bar(vdi_handle, (int *)&box);		/* 'black' the interior */

		/* mode texte */
		vswr_mode(vdi_handle, MD_REPLACE);
		vst_color(vdi_handle, thewin -> fonction.secteur.couleur_texte);
	}

	MouseOn();	/* remet la souris */
#pragma warn -par
} /* secteurproc */
#pragma warn .par

/****************************************************************
*																*
*				affiche le texte de la fenˆtre					*
*																*
****************************************************************/
void textproc(int first, WIN *win, GRECT *clip)
{
	MouseOff();

	rc_sc_clear(clip);

	aff_text(findwindowptr(win -> handle), clip);

	MouseOn();
#pragma warn -par
} /* textproc */
#pragma warn .par

/****************************************************************
*																*
*						redessine l'ascenseur					*
*																*
****************************************************************/
void redraw_slide(windowptr thewin, GRECT *clip)
{
	if (Efface)
		objc_draw(thewin -> fonction.secteur.slide, ROOT, MAX_DEPTH, clip -> g_x, clip -> g_y, clip -> g_w, clip -> g_h);
	else
		objc_draw(thewin -> fonction.secteur.slide, SLIDER_PERE, MAX_DEPTH, clip -> g_x, clip -> g_y, clip -> g_w, clip -> g_h);
} /* redraw_slide */

/****************************************************************
*																*
*				affiche le texte de la fenˆtre					*
*																*
****************************************************************/
void aff_text(windowptr thewin, GRECT *clip)
{
	int tx, ty, h;
	int g_h = thewin -> fonction.secteur.taille_h;
	int ligne;
	char **text = thewin -> fonction.text.Ligne;
	int colonne = thewin -> fonction.text.colonne;
	int vdi_handle = thewin -> win -> vdi_handle;

	/* position de d‚part */
	tx = thewin -> win -> work.g_x;
	ty = thewin -> win -> work.g_y + thewin -> win -> work.g_h -2;

	/* derniŠre ligne */
	ligne = thewin -> fonction.text.PrintLine;

	h = clip -> g_y + clip -> g_h;

	/* on part dans la fenˆtre de clipping
		tant que le texte est dessous on remonte */
	while (ty > h+g_h && text[ligne] != NULL && ligne != thewin -> fonction.text.CurrentLine)
	{
		ty -= g_h;
		ligne = ligne>0 ? ligne-1 : thewin -> fonction.text.LineNumberMax-1;
	}

	while (thewin -> fonction.text.Ligne[ligne] != NULL && ty >= clip -> g_y-g_h && ligne != thewin -> fonction.text.CurrentLine)
	{
		if (colonne)
		{
			register int col;

			for (col = 0; col<colonne && text[ligne][col] != 0; col++)
				;
			if (col == colonne)
				v_gtext(vdi_handle, tx, ty, text[ligne]+col);
		}
		else
			v_gtext(vdi_handle, tx, ty, text[ligne]);

		ligne = ligne>0 ? ligne-1 : thewin -> fonction.text.LineNumberMax-1;
		ty -= g_h;
	}
} /* aff_text */
