#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

int ap_id, handle, buf[8];
int xd, yd, wd, hd;	/* Coordonn‚es du bureau */
char *titre[] = {" Titre de la fenˆtre 0 ",
								 " Titre de la fenˆtre 1 ",
								 " Titre de la fenˆtre 2 "};
char *infos[] = {" Infos de la fenˆtre 0 ",
								 " Infos de la fenˆtre 1 ",
								 " Infos de la fenˆtre 2 "};
int lin[3] = {0, 0, 0}, col[3] = {0, 0, 0};	/* 1ø lignes et colonnes des fenˆtres */
int ful[3] = {0, 0, 0};				/* Flag pour le traitement du "plein ‚cran" */
int lt[3], ht[3], hwind[3];		/* Largeur et hauteur totales, handles */

	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

void main (void);
void open_work (void);
void open_wind (int index);
void boucle (void);
void redraw (int x, int y, int w, int h);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void dessin (int index);
void sliders (int index);
void vslider (void);
void hslider (void);
void fulled (void);
void arrow (void);

void main (void)
{
int wcell, hcell, dummy;

	ap_id = appl_init ();						/* D‚clarer l'application */
	wind_get (0, WF_WORKXYWH, &xd, &yd, &wd, &hd); /* Dimensions bureau */
	open_work ();										/* Ouvrir station de travail */
		/* Tailles de cellules de caractŠres : */
	vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);
	lt[0] = lt[1] = lt[2] = 60 * wcell;	/* Largeur totale des fenˆrtes */
	ht[0] = ht[1] = ht[2] = 50 * hcell;	/* Hauteur totale des fenˆtres */
	open_wind (0);						/* Ouvrir fenˆtre 0 */
	sliders (0);							/* Actualiser les sliders fenˆtres 0 */
	open_wind (1);						/* Ouvrir fenˆtre 1 */
	sliders (1);							/* Actualiser les sliders fenˆtres 1 */
	open_wind (2);						/* Ouvrir fenˆtre 2 */
	sliders (2);							/* Actualiser les sliders fenˆtres 2 */
	graf_mouse (ARROW, 0);		/* Souris en forme de flŠche */
	boucle ();								/* Boucle principale du programme */
	appl_exit ();							/* Quitter */
}

void open_work (void)
{
int i, a, b;

	for (i = 0 ; i < 10 ; _VDIParBlk.intin[i++] = 1);
	_VDIParBlk.intin[10]=2;
	_VDIParBlk.intin[0] = Getrez()+2;		/* Le numero de la r‚solution d'ouverture */
																			/* de la station virtuelle d‚pend de la r‚solution */
	handle = graf_handle (&a, &b, &i, &i);
	v_opnvwk (_VDIParBlk.intin, &handle, _VDIParBlk.intout);
}

void open_wind (int index)
{
	hwind[index] = wind_create (0x0FFF, xd, yd, wd, hd);	/* Cr‚er la fenˆtre */
	if (hwind[index])						/* Si elle est correctement cr‚‚e */
	{
		wind_set (hwind[index], WF_NAME, titre[index]);	/* Titre */
		wind_set (hwind[index], WF_INFO, infos[index]);	/* Ligne d'infos */
		wind_set (hwind[index], WF_HSLIDE, 0);					/* Position HSLID */
		wind_set (hwind[index], WF_VSLIDE, 0);					/* Position VSLID */
		wind_set (hwind[index], WF_HSLSIZE, 1000);			/* Taille HSLIDE */
		wind_set (hwind[index], WF_VSLSIZE, 1000);			/* Taille VSLIDE */
		wind_open (hwind[index],												/* Ouverture de la fenˆtre */
							 xd + (index * wd / 3), yd + (index * hd / 3),
							 wd / 3, hd / 3);
	}
}

void boucle (void)
{
int top, dummy, quit = 0;

	while (! quit)
	{
		evnt_mesag (buf);		/* Attente des message envoy‚s par le GEM */
		switch (buf[0])			/* Selon le type de message */
		{
		case WM_REDRAW :					/* Message de REDRAW */
			redraw (buf[4], buf[5], buf[6], buf[7]);
			break;
		case WM_TOPPED :					/* Message de TOPPED */
			wind_set (buf[3], WF_TOP);	/* Mettre la fenˆtre au 1ø plan */
			break;
		case WM_CLOSED :					/* Message de CLOSED */
			wind_close (buf[3]);		/* Fermer la fenˆtre */
			wind_delete (buf[3]);		/* D‚truire la fenˆtre */
			wind_get (0, WF_TOP, &top, &dummy, &dummy, &dummy);
			if (! top)		/* Si toutes les fenˆtres sont ferm‚es */
				quit = 1;		/* On peut quitter */
			break;
		case WM_FULLED :					/* Message de FULLED */
			fulled ();
			break;
		case WM_ARROWED :					/* Message de ARROWED */
			arrow ();
			break;
		case WM_HSLID :						/* Message de HSLID */
			hslider ();
			break;
		case WM_VSLID :						/* Message de VSLID */
			vslider ();
			break;
		case WM_SIZED :						/* Messages de SIZED */
				/* Nouvelles coordonn‚es : */
			wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
			if (buf[3] == hwind[0])		/* Selon la fenˆtre concern‚e */
			{
				ful[0] = 0;							/* Annuler le flag de pleine ouverture */
				sliders (0);						/* R‚ajuster les sliders */
			}
			else if (buf[3] == hwind[1])
			{
				ful[1] = 0;
				sliders (1);
			}
			else
			{
				ful[2] = 0;
				sliders (2);
			}
			break;
		case WM_MOVED :						/* Message de MOVED */
				/* Nouvelles coordonn‚es : */
			wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
			break;
		}
	}
}

void redraw (int x, int y, int w, int h)
{
GRECT r, rd;
int index;

	if (buf[3] == hwind[0])		/* Chercher l'index de la fenˆtre */
		index = 0;
	else if (buf[3] == hwind[1])
		index = 1;
	else
		index = 2;

	rd.g_x = x;		/* Coordonn‚es rectangle … redessiner */
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;

	v_hide_c (handle);	/* Virer la souris */
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris */

		/* Demande les coord. et dimensions du 1ø rectangle de la liste */
	wind_get (buf[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur... */
	{
		if (rc_intersect (&rd, &r))	/* Si intersection des 2 zones */
		{
			set_clip (1, &r);		/* Clipping ON */
			dessin (index);			/* Dessiner la fenˆtre */
			set_clip (0, &r);		/* Clipping OFF */
		}
			/* Rectangle suivant */
		wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris */
	v_show_c (handle, 1);				/* Rappeler la souris */
}

int rc_intersect (GRECT *p1, GRECT *p2)
	/* Calcule l'intersection de 2 rectangles */
{
int tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}

void set_clip (int clip_flag, GRECT *area)
{
int pxy[4];

	pxy[0] = area->g_x;
	pxy[1] = area->g_y;
	pxy[2] = area->g_w + area->g_x - 1;
	pxy[3] = area->g_h + area->g_y - 1;
	vs_clip (handle, clip_flag, pxy);
}

void dessin (int index)
{
char buffer[65];
int pxy[4], xw, yw, ww, hw, x, y, i, wcell, hcell, dummy;
		/* Taille cellules de caractŠres : */
	vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);	/* Coordonn‚es zone de travail */

	pxy[0] = xw;								/* Pr‚parer effacement fenˆtre */
	pxy[1] = yw;
	pxy[2] = xw + ww - 1;
	pxy[3] = yw + hw - 1;
	vswr_mode (handle, MD_REPLACE);		/* Dessin en mode Remplacement */
	vsf_color (handle, 0);						/* Couleur blanche */
	v_bar (handle, pxy);							/* "Vider" la fenˆtre */

	y = yw - lin[index];	/* Positionner l'affichage des lignes */
	x = xw - col[index];
	vst_alignment (handle, 0, 5, &dummy, &dummy);	/* Alignement en haut … gauche */
	for (i = 0 ; i < 50 ; i++)		/* 50 lignes */
	{
			/* Pr‚parer une ligne : */
		sprintf (buffer, " Fenˆtre %d, ligne num‚ro %d. C'est beau, hein que ouais ?", index, i + 1);
		v_gtext (handle, x, y, buffer);	/* L'afficher */
		y += hcell;											/* Position ligne suivante */
	}
}

void sliders (int index)
{
int slide, xw, yw, ww, hw;
		/* Coordonn‚es zone de travail : */
	wind_get (hwind[index], WF_WORKXYWH, &xw, &yw, &ww, &hw);

	wind_set (hwind[index], WF_VSLSIZE,					/* Taille slider vertical */
						(int)((double)1000 * (double)((double)hw /
						(double)ht[index])));
	lin[index] = min (lin[index], ht[index] - hw);	/* Calculer la ligne */
	lin[index] = max (0, lin[index]);

	wind_set (hwind[index], WF_HSLSIZE,					/* Taille slider horizontal */
						(int)((double)1000 * (double)((double)ww /
						(double)lt[index])));
	col[index] = min (col[index], lt[index] - ww);	/* Calculer la colonne */
	col[index] = max (0, col[index]);

	slide = lin[index] * 1000.0 / (ht[index] - hw);	/* Position vertical */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (hwind[index], WF_VSLIDE, slide);

	slide = col[index] * 1000.0 / (lt[index] - ww);	/* Position horizontal */
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (hwind[index], WF_HSLIDE, slide);
}

void vslider (void)
{
int index, slide, xw, yw, ww, hw;

	if (buf[3] == hwind[0])
		index = 0;
	else if (buf[3] == hwind[1])
		index = 1;
	else
		index = 2;
	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la ligne : */
	lin[index] = ((long)slide * (ht[index] - (long)hw) / 1000.0);
	if (lin[index] + hw > ht[index])
		lin[index] = ht[index] - hw;
	if (lin[index] < 0)
		lin[index] = 0;
	wind_set (buf[3], WF_VSLIDE, slide);
	redraw (xw, yw, ww, hw);	/* R‚affichage */
}

void hslider (void)
{
int index, slide, xw, yw, ww, hw;

	if (buf[3] == hwind[0])
		index = 0;
	else if (buf[3] == hwind[1])
		index = 1;
	else
		index = 2;
	slide = buf[4];
	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
		/* Calcul de la colonne : */
	col[index] = ((long)slide * (lt[index] - (long)ww) / 1000.0);
	if (col[index] + ww > lt[index])
		col[index] = lt[index] - ww;
	if (col[index] < 0)
		col[index] = 0;
	wind_set (buf[3], WF_HSLIDE, slide);
	redraw (xw, yw, ww, hw);	/* R‚affichage */
}

void fulled (void)
{
int index, x, y, w, h;

	if (buf[3] == hwind[0])		/* Chercher l'index de la fenˆtre */
		index = 0;
	else if (buf[3] == hwind[1])
		index = 1;
	else
		index = 2;

	if (ful[index])						/* Si elle est d‚j… plein pot */
	{
		wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h);	/* Coord. pr‚c‚dentes */
		wind_set (buf[3], WF_CURRXYWH, x, y, w, h);			/* Nouvelles coord. */
		ful[index] = 0;										/* Annuler flag */
	}
	else											/* Sinon */
	{
		wind_set (buf[3], WF_CURRXYWH, xd, yd, wd, hd);	/* Coord. maxi */
		ful[index] = 1;										/* Positionner flag */
	}
	sliders (index);
}

void arrow (void)
{
int index, xw, yw, ww, hw, wcell, hcell, dummy;

		/* La taille des cellules de caractŠres sert pour les d‚calages
			 d'une ligne ou d'une colonne. */
	vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);
	if (buf[3] == hwind[0])
		index = 0;
	else if (buf[3] == hwind[1])
		index = 1;
	else
		index = 2;

	wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
	switch (buf[4])
	{
	case WA_UPPAGE :				/* Page vers le haut */
		if (lin[index] > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			lin[index] = max (lin[index] - hw, 0);	/* Nouvelle ligne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas */
		if ((lin[index] + hw) < ht[index])	/* Si pas d‚j… … la fin */
		{
			lin[index] = min (lin[index] + hw, ht[index] - hw);	/* Nouvelle ligne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut */
		if (lin[index] > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			lin[index] -= hcell;	/* Nouvelle ligne */
			if (lin[index] < 0)
				lin[index] = 0;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas */
		if ((lin[index] + hw) < ht[index])	/* Si pas d‚j… … la fin */
		{
			lin[index] += hcell;	/* Nouvelle ligne */
			if (lin[index] + hw > ht[index])
				lin[index] = ht[index] - hw;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_LFPAGE :				/* Page vers la gauche */
		if (col[index] > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			col[index] = max (col[index] - ww, 0);	/* Nouvelle colonne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_RTPAGE :				/* Page vers la droite */
		if ((col[index] + ww) < lt[index])	/* Si pas d‚j… … la fin */
		{
			col[index] = min (col[index] + ww, lt[index] - ww);	/* Nouvelle colonne */
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_LFLINE :				/* Ligne vers la gauche */
		if (col[index] > 0)	/* Si on n'est pas d‚j… au d‚but */
		{
			col[index] -= wcell;	/* Nouvelle colonne */
			if (col[index] < 0)
				col[index] = 0;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	case WA_RTLINE :				/* Ligne vers la droite */
		if ((col[index] + ww) < lt[index])	/* Si pas d‚j… … la fin */
		{
			col[index] += wcell;	/* Nouvelle colonne */
			if (col[index] + ww > lt[index])
				col[index] = lt[index] - ww;
			redraw (xw, yw, ww, hw);	/* R‚affichage */
			sliders (index);					/* Actualiser les sliders */
		}
		break;
	}
}


