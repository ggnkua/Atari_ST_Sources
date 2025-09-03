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

#include "curseur.h"
#include "wind.h"

/****************************************************************
*																*
*				Affiche ou enlŠve le curseur					*
*																*
****************************************************************/
void curseur_on(windowptr thewin)
{
	if (thewin -> fonction.fichier.curseur_x < 0)
	{
		thewin -> fonction.fichier.curseur_x = -1 - thewin -> fonction.fichier.curseur_x;
		thewin -> fonction.fichier.curseur_y = -1 - thewin -> fonction.fichier.curseur_y;
		if (thewin -> fonction.secteur.ascii)
			update_curseur(thewin, thewin -> fonction.fichier.curseur_x &= ~1, thewin -> fonction.fichier.curseur_y, FAIL, FAIL, TRUE);
		else
			update_curseur(thewin, thewin -> fonction.fichier.curseur_x, thewin -> fonction.fichier.curseur_y, FAIL, FAIL, TRUE);
		menu_icheck(Menu, CURSEUR_VISIBLE, 1);
	}
	else
	{
		update_curseur(thewin, FAIL, FAIL, thewin -> fonction.fichier.curseur_x, thewin -> fonction.fichier.curseur_y, TRUE);
		thewin -> fonction.fichier.curseur_x = -1 - thewin -> fonction.fichier.curseur_x;
		thewin -> fonction.fichier.curseur_y = -1 - thewin -> fonction.fichier.curseur_y;
		menu_icheck(Menu, CURSEUR_VISIBLE, 0);
	}
} /* curseur_on */

/****************************************************************
*																*
*			edite un octet d'un fichier ou secteur				*
*																*
****************************************************************/
void edit(windowptr thewin, int key, int shift)
{
	WIN *win = thewin -> win;
	int x = thewin -> fonction.secteur.curseur_x, x1, y = thewin -> fonction.secteur.curseur_y, y1;
	int vdi_handle = win -> vdi_handle;
	int g_w = thewin -> fonction.secteur.taille_w, g_h = thewin -> fonction.secteur.taille_h;
	char c[3] = "\0\0";
	int tx, ty;
	GRECT box, rect, work;

	if (key == 0)
		return;

	if (thewin -> type != TAMPON)
		thewin -> fonction.secteur.dirty = TRUE;

	if (thewin -> fonction.secteur.ascii)
	{ /* on met le code ASCII */
		if (x & 1)
		{
			update_curseur(thewin, x & ~1, y, x, y, TRUE);
			x &= ~1;	/* arrondi le curseur sur une position texte */
		}

		(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] = key;
		thewin -> fonction.secteur.Ligne[y+4][x+6] = key;

		c[0] = (char)key;

		y1 = y;
		x1 = x<62 ? x+2 : (	y1 = y<15 ? y+1 : 0, 0);
	}
	else
		if (shift)
		{
			int quartet;

			if (x & 1)
			{
				update_curseur(thewin, x & ~1, y, x, y, TRUE);
				x &= ~1;	/* arrondi le curseur sur une position texte */
			}

			(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] = key;

			quartet = key>>4;	/* poids fort */
			quartet += quartet <= 9 ? '0' : 'A'-10;
			thewin -> fonction.secteur.Ligne[y+4][x+6] = quartet;
			c[0] = (char)quartet;

			quartet = key & 0x0F;	/* poids faible */
			quartet += quartet <= 9 ? '0' : 'A'-10;
			thewin -> fonction.secteur.Ligne[y+4][x+6] = quartet;
			c[1] = (char)quartet;

			y1 = y;
			x1 = x<62 ? x+2 : (	y1 = y<15 ? y+1 : 0, 0);
		}
		else
			/* code hexadecimal */
			if (key >= '0' && key <='9' || (key | 0x20) >= 'a' && (key | 0x20) <='f')
			{
				if (key <= '9')
				{
					c[0] = (char)key;
					thewin -> fonction.secteur.Ligne[y+4][x+6] = key;
					key -= '0';
				}
				else
				{
					c[0] = (char)(key & ~0x20);
					thewin -> fonction.secteur.Ligne[y+4][x+6] = c[0];
					key = (key | 0x20)-'a'+10;
				}

				if (x & 1)
				{ /* digit de poids faible */
					(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] &= 0xF0;
					(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] |= key;
				}
				else
				{ /* digit de poids fort*/
					(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] &= 0x0F;
					(thewin -> fonction.secteur.page*512L + thewin -> fonction.secteur.secteurBin)[x/2 + y*32] |= key<<4;
				}

				y1 = y;
				x1 = x<63 ? x+1 : (	y1 = y<15 ? y+1 : 0, 0);
			}
			else
				return;

	MouseOff();	/* cache la souris */

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width;

	rc_intersect(&desk, &work);

	/* update window */
	wind_get(win -> handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);

		/* XOR pour effacer l'ancient curseur */
		vswr_mode(vdi_handle, MD_XOR);

		rect.g_w += rect.g_x -1;
		rect.g_h += rect.g_y -1;
		vs_clip(vdi_handle, 1, (int *)&rect);

		box.g_x = win -> work.g_x + ((x & ~1) +6 - thewin -> fonction.secteur.colonne)*g_w;
		box.g_y = win -> work.g_y + win -> work.g_h - (thewin -> fonction.secteur.ligne - y -3)*g_h;
		box.g_w = box.g_x + 15;
		box.g_h = box.g_y + g_h-1;
		v_bar(vdi_handle, (int *)&box);		/* efface le curseur */

		/* replace pour le texte */
		vswr_mode(vdi_handle, MD_REPLACE);

		tx = win -> work.g_x + (x+6 - thewin -> fonction.secteur.colonne)*g_w;
		ty = win -> work.g_y + win -> work.g_h - (thewin -> fonction.secteur.ligne - y -4)*g_h -2;
		v_gtext(vdi_handle, tx, ty, c);

		vswr_mode(vdi_handle, MD_XOR);
		v_bar(vdi_handle, (int *)&box);		/* remet le curseur */

		/* bloc suivant */
		wind_get(win -> handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	}

	MouseOn();	/* remet la souris */

	thewin -> fonction.secteur.curseur_x = x1;
	thewin -> fonction.secteur.curseur_y = y1;

	update_curseur(thewin, x1, y1, x, y, TRUE);
} /* edit */

/****************************************************************
*																*
*				ajoute un texte dans une fenˆtre				*
*																*
****************************************************************/
void update_curseur(windowptr thewin, int xon, int yon, int xoff, int yoff, int affiche)
{
	WIN *win = thewin -> win;
	int g_w = thewin -> fonction.secteur.taille_w, g_h = thewin -> fonction.secteur.taille_h;
	int vdi_handle = win -> vdi_handle;
	int tx, ty;
	GRECT box, rect, work;

	if (xoff >= 0)	/* efface le curseur */
	{
		thewin -> fonction.fichier.Ligne[3][xoff+6] = ' ';
		thewin -> fonction.fichier.Ligne[yoff+4][4] = ' ';
	}

	if (xon >= 0)	/* affiche le curseur */
	{
		thewin -> fonction.fichier.Ligne[3][xon+6] = '';
		thewin -> fonction.fichier.Ligne[yon+4][4] = '';
	}

	if (thewin -> type == FICHIER)
	{
		BPB bpb = Bpb[thewin -> fonction.fichier.device];
		int len;

		if (xon < 0)
			len = sprintf(thewin -> fonction.fichier.Ligne[0], thewin -> fonction.fichier.decimal ? Messages(CURSEUR_1) : Messages(CURSEUR_2),
			 ((thewin -> fonction.fichier.secteur*thewin -> fonction.fichier.sector_size)+thewin -> fonction.fichier.page)*512L, thewin -> fonction.fichier.size,
			 (unsigned int)floor((float)(thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur] - bpb.datrec)/bpb.clsiz +2),
			 thewin -> fonction.fichier.secteur, thewin -> fonction.fichier.max);
		else
			len = sprintf(thewin -> fonction.fichier.Ligne[0], thewin -> fonction.fichier.decimal ? Messages(CURSEUR_1) : Messages(CURSEUR_2),
			 ((thewin -> fonction.fichier.secteur*thewin -> fonction.fichier.sector_size)+thewin -> fonction.fichier.page)*512L + xon/2 + yon*32, thewin -> fonction.fichier.size,
			 (unsigned int)floor((float)(thewin -> fonction.fichier.table[thewin -> fonction.fichier.secteur] - bpb.datrec)/bpb.clsiz +2),
			 thewin -> fonction.fichier.secteur, thewin -> fonction.fichier.max);

		for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
			thewin -> fonction.secteur.Ligne[0][len] = ' ';
	}
	else
		if (thewin -> type == FICHIER_FS)
		{
			int len;

			if (xon < 0)
				len = sprintf(thewin -> fonction.fichier_fs.Ligne[0], thewin -> fonction.fichier_fs.decimal ? Messages(CURSEUR_3) : Messages(CURSEUR_4),
				 thewin -> fonction.fichier_fs.secteur*512L, thewin -> fonction.fichier_fs.size);
			else
				len = sprintf(thewin -> fonction.fichier_fs.Ligne[0], thewin -> fonction.fichier_fs.decimal ? Messages(CURSEUR_3) : Messages(CURSEUR_4),
				 thewin -> fonction.fichier_fs.secteur*512L + xon/2 + yon*32, thewin -> fonction.fichier_fs.size);

			for (; len<SECTEURLINESIZE*2-1; len++)	/* efface la fin de la ligne */
				thewin -> fonction.secteur.Ligne[0][len] = ' ';
		}

	if (!affiche)
		return;

	MouseOff();	/* cache la souris */

	work = win -> work;
	if (thewin -> type >= SECTEUR)
		work.g_w -= thewin -> fonction.secteur.slide[SLIDER_FOND].ob_width-1;

	rc_intersect(&desk, &work);

	/* update window */
	wind_get(win -> handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	while (rect.g_w && rect.g_h)
	{
		rc_intersect(&work, &rect);

		rect.g_w += rect.g_x -1;
		rect.g_h += rect.g_y -1;
		vs_clip(vdi_handle, 1, (int *)&rect);

		if (xoff != FAIL)
		{
			/* efface l'ancien curseur */
			vswr_mode(vdi_handle, MD_XOR);

			box.g_x = win -> work.g_x + ((xoff & ~1) +6 - thewin -> fonction.fichier.colonne)*g_w;
			box.g_y = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne - yoff-3)*g_h;
			box.g_w = box.g_x + g_w*2 -1;
			box.g_h = box.g_y + g_h-1;
			v_bar(vdi_handle, (int *)&box);		/* black the interior */
		}

		if (xon != FAIL || xoff != FAIL)
			vswr_mode(vdi_handle, MD_REPLACE);

		if (xoff != FAIL)	/* efface le curseur */
		{
			tx = win -> work.g_x + (xoff+6 - thewin -> fonction.fichier.colonne)*g_w;
			ty = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne -3)*g_h -2;
			v_gtext(vdi_handle, tx, ty, " ");

			tx = win -> work.g_x + (4 - thewin -> fonction.fichier.colonne)*g_w;
			ty = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne - yoff -4)*g_h -2;
			v_gtext(vdi_handle, tx, ty, " ");
		}

		if (xon != FAIL)	/* affiche le curseur */
		{
			vst_color(vdi_handle, thewin -> fonction.secteur.couleur_curseur);

			tx = win -> work.g_x + (xon+6 - thewin -> fonction.fichier.colonne)*g_w;
			ty = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne -3)*g_h -2;
			v_gtext(vdi_handle, tx, ty, "");

			tx = win -> work.g_x + (4 - thewin -> fonction.fichier.colonne)*g_w;
			ty = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne - yon -4)*g_h -2;
			v_gtext(vdi_handle, tx, ty, "");
		}

		if (thewin -> type == FICHIER || thewin -> type == FICHIER_FS)
		{
			vst_color(vdi_handle, thewin -> fonction.secteur.couleur_texte);

			tx = win -> work.g_x - thewin -> fonction.fichier.colonne*g_w;
			ty = win -> work.g_y + win -> work.g_h - thewin -> fonction.fichier.ligne*g_h -2;
			v_gtext(vdi_handle, tx, ty, thewin -> fonction.fichier.Ligne[0]);
		}

		if (xon != FAIL)
		{
			vswr_mode(vdi_handle, MD_XOR);

			/* affiche le nouveau curseur */
			box.g_x = win -> work.g_x + ((xon & ~1) +6 - thewin -> fonction.fichier.colonne)*g_w;
			box.g_y = win -> work.g_y + win -> work.g_h - (thewin -> fonction.fichier.ligne - yon-3)*g_h;
			box.g_w = box.g_x + g_w*2 -1;
			box.g_h = box.g_y + g_h-1;
			v_bar(vdi_handle, (int *)&box);		/* black the interior */
		}

		/* bloc suivant */
		wind_get(win -> handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	}

	/* mode pour le texte */
	vswr_mode(vdi_handle, MD_REPLACE);
	vst_color(vdi_handle, thewin -> fonction.secteur.couleur_texte);

	MouseOn();	/* remet la souris */
} /* update_curseur */

/****************************************************************
*																*
*					curseur vers le haut						*
*																*
****************************************************************/
void curseur_up(windowptr thewin, boolean full)
{
	int y = thewin -> fonction.fichier.curseur_y, y1, x = thewin -> fonction.fichier.curseur_x;

	if (full)
		y1 = 0;
	else
		y1 = y>0 ? y-1 : 15;

	thewin -> fonction.fichier.curseur_y = y1;

	update_curseur(thewin, x, y1, x, y, TRUE);
} /* curseur_up */

/****************************************************************
*																*
*					curseur vers le bas							*
*																*
****************************************************************/
void curseur_down(windowptr thewin, boolean full)
{
	int y = thewin -> fonction.fichier.curseur_y, y1, x = thewin -> fonction.fichier.curseur_x;

	if (full)
		y1 = 15;
	else
		y1 = y<15 ? y+1 : 0;

	thewin -> fonction.fichier.curseur_y = y1;

	update_curseur(thewin, x, y1, x, y, TRUE);
} /* curseurdown */

/****************************************************************
*																*
*					curseur vers la gauche						*
*																*
****************************************************************/
void curseur_left(windowptr thewin, int ascii, boolean full)
{
	int x = thewin -> fonction.fichier.curseur_x, x1, y = thewin -> fonction.fichier.curseur_y, y1;

	y1 = y;

	if (full)
		x1 = 0;
	else
		if (ascii)
			x1 = x>1 ? x-2 : (y1 = y>0 ? y-1 : 15, 62) & ~1;
		else
			x1 = x>0 ? x-1 : (y1 = y>0 ? y-1 : 15, 63);

	thewin -> fonction.fichier.curseur_x = x1;
	thewin -> fonction.fichier.curseur_y = y1;

	update_curseur(thewin, x1, y1, x, y, TRUE);
} /* curseur_left */

/****************************************************************
*																*
*					curseur vers la droite						*
*																*
****************************************************************/
void curseur_right(windowptr thewin, int ascii, boolean full)
{
	int x = thewin -> fonction.fichier.curseur_x, x1, y = thewin -> fonction.fichier.curseur_y, y1;

	y1 = y;

	if (full)
		x1 = 62;
	else
		if (ascii)
			x1 = x<62 ? x+2 : (	y1 = y<15 ? y+1 : 0, 0) & ~1;
		else
			x1 = x<63 ? x+1 : (	y1 = y<15 ? y+1 : 0, 0);

	thewin -> fonction.fichier.curseur_x = x1;
	thewin -> fonction.fichier.curseur_y = y1;

	update_curseur(thewin, x1, y1, x, y, TRUE);
} /* curseur_right */

/****************************************************************
*																*
*				curseur vers en haut … gauche					*
*																*
****************************************************************/
void curseur_home(windowptr thewin, boolean full)
{
	int x = thewin -> fonction.fichier.curseur_x, y = thewin -> fonction.fichier.curseur_y;
	
	if (full)
	{
		thewin -> fonction.fichier.curseur_x = 62;
		thewin -> fonction.fichier.curseur_y = 15;
	}
	else
	{
		thewin -> fonction.fichier.curseur_x = 0;
		thewin -> fonction.fichier.curseur_y = 0;
	}

	update_curseur(thewin, thewin -> fonction.fichier.curseur_x, thewin -> fonction.fichier.curseur_y, x, y, TRUE);
} /* curseur_home */
