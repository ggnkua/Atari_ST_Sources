/*											SPEEDO.C
	Programme d'exemple de programmation sous SpeedoGDOS
			Claude ATTARD pour ST Mag - Novembre 1994
*/

/* #[ D‚finitions :																									*/
#include <stdio.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <tos.h>

enum {FALSE, TRUE};
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

int ap_id;								/* Identificateur d'application */
int nb_fontssc = 0;				/* Nbre fontes charg‚es */
int handlesc;							/* Handle VDI */
int wscr, hscr;						/* Largeur et hauteur ‚cran */
/* #] D‚finitions :																									*/ 
/* #[ Prototypage :																									*/
void main (void);
void load_fontspeedo (void);
void affichage (void);
void open_vwork (void);

void vst_kern (int h, int tmode, int pmode, int *tracks, int *pairs);
/* #] Prototypage :																									*/ 
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
	ap_id = appl_init ();						/* D‚clarer l'application */
	graf_mouse (ARROW, 0);					/* Souris -> flŠche */
	open_vwork ();									/* Ouverture station virtuelle ‚cran */
	load_fontspeedo ();							/* Charger fontes */
	affichage ();										/* Affichage */
	vst_unload_fonts (handlesc, 0);	/* D‚charger fontes */
	v_clsvwk (handlesc);						/* Fermer station virtuelle */
	appl_exit ();										/* Terminer */
	exit (0);												/* Quitter */
}
/* #] main () Initialisations et gestion :													*/ 
/* #[ load_fontspeedo () : Chargement fontes Speedo :								*/
void load_fontspeedo (void)
{
	if (vq_vgdos () == GDOS_FSM)
		nb_fontssc = vst_load_fonts (handlesc, 0);
}
/* #] load_fontspeedo () : Chargement fontes Speedo :								*/ 
/* #[ affichage () Affichage des fontes :														*/
void affichage (void)
{
int i = 2, x, y, w, h, d, id, pxy[4], clip[4], pts[8], maxi = 0;
char chaine[35];

	v_hide_c (handlesc);							/* Cacher la souris */

	clip[0] = 0;											/* Coordonn‚es du clipping : */
	clip[1] = 0;											/* tout l'‚cran. */
	clip[2] = wscr;
	clip[3] = hscr;
	vs_clip (handlesc, TRUE, clip);		/* Clipper */

		/* "Vider" l'‚cran */
	pxy[0] = pxy[1] = 0;							/* Coordonn‚es */
	pxy[2] = wscr;
	pxy[3] = hscr;
	vsf_interior (handlesc, FIS_PATTERN);	/* Trame */
	vsf_style (handlesc, 8);							/* Trame 100% */
	vsf_color (handlesc, 0);							/* Couleur blanche */
	vsf_perimeter (handlesc, FALSE);			/* Pas de bordure */
	v_bar (handlesc, pxy);								/* Effacer */

	vswr_mode (handlesc, MD_TRANS);				/* Ecriture en mode trasparent */

	vst_alignment (handlesc, 1, 5, &d, &d);	/* Alignement texte : haut centr‚ */
	vst_color (handlesc, 1);								/* Texte en noir */
	x = wscr / 2;														/* Au milieu en largeur */
	y = 10;																	/* A 10 pixels du haut */
	while ((i <= (nb_fontssc + 1)) && (y < hscr))
	{		/* Pour chaque fonte tant qu'on est sur l'‚cran */
		id = vqt_name (handlesc, i, chaine);	/* Nom et identificateur fonte */
		if (chaine[32] == 1)									/* Si fonte vectorielle */
		{
			vst_font (handlesc, id);									/* Activer fonte */
			vst_arbpt (handlesc, 9, &d, &d, &w, &h);	/* Taille 9 */
			vst_setsize (handlesc, 18, &d, &d, &d, &d);	/* 2 fois plus large */
			vst_skew (handlesc, 300);									/* Italisation */
			vqt_f_extent (handlesc, chaine, pts);			/* Coordonn‚es rectangle texte */
			maxi = max (maxi, pts[4] - pts[6]);				/* En registrer largeur maxi */
			v_ftext (handlesc, x, y, chaine);					/* Afficher chaŒne */
			y += h;																		/* Ligne suivante */
		}
		i++;																	/* Fonte suivante */
	}

	pxy[0] = pxy[2] = (wscr / 2) - (maxi / 2) - 10;	/* Ligne de gauche */
	pxy[1] = 10;
	pxy[3] = y;
	v_pline (handlesc, 2, pxy);											/* Tracer ligne */
	pxy[0] = pxy[2] = (wscr / 2) + (maxi / 2) + 10;	/* Ligne de droite */
	v_pline (handlesc, 2, pxy);											/* Tracer ligne */

	vs_clip (handlesc, FALSE, clip);		/* D‚clipper */
	v_show_c (handlesc, TRUE);					/* Montrer souris */
	Bconin (2);													/* Attendre pression d'une touche */
}
/* #] affichage () Affichage des fontes :														*/ 
/* #[ open_vwork () Ouvrir station travail virtuelle :							*/
void open_vwork (void)
{
int i, a, b;

	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* Rempli tableau intin */
	_VDIParBlk.intin[10] = 2;									/* Coordonn‚es ‚cran */
	_VDIParBlk.intin[0] = Getrez () + 2;			/* Selon r‚solution */
	handlesc = graf_handle (&a, &b, &i, &i);	/* R‚cup‚rer handle du GEM */
	v_opnvwk (_VDIParBlk.intin, &handlesc, _VDIParBlk.intout);	/* Ouvrir station */
	wscr = _VDIParBlk.intout[0];							/* Largeur ‚cran en points */
	hscr = _VDIParBlk.intout[1];							/* Hauteur ‚cran en points */
}
/* #] open_vwork () Ouvrir station travail virtuelle :							*/ 

