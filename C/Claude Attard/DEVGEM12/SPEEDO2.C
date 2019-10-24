/*											SPEEDO2.C
	Programme d'exemple d'impression sous SpeedoGDOS
			Claude ATTARD pour ST Mag - D‚cembre 1994
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

#define FILEMETA "MON_META.GEM"

int ap_id;													/* Identificateur d'application GEM */
int nb_fontssc = 0, nb_fontsim = 0, nb_fontsmf = 0;	/* Nbre fontes par station */
int hscreen, hprinter, hmeta;				/* Handles VDI ‚cran, imprimante et Meta */
int wscr, hscr;											/* Largeur hauteur ‚cran */
int wimp, himp;											/* Largeur hauteur page imprimante */
int wmtf = 2100, hmtf = 2970;				/* Largeur et hauteur page MetaFile */
/* #] D‚finitions :																									*/ 
/* #[ Prototypage :																									*/
void main (void);
void affichage (void);
void impression (void);
void metafile (void);
void open_vwork (void);
int open_iwork (void);
int open_mwork (void);
/* #] Prototypage :																									*/ 
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
	ap_id = appl_init ();							/* D‚clarer l'application au GEM */
	graf_mouse (ARROW, 0);						/* Souris : flŠche */
	if (vq_vgdos () == GDOS_FSM)			/* Si Speedo est bien l… */
	{
		open_vwork ();									/* Ouverture station virtuelle ‚cran */
		nb_fontssc = vst_load_fonts (hscreen, 0);	/* Charger fontes ‚cran */
		affichage ();															/* Afficher les fontes */
		if (Cprnos ())									/* Si imprimante disponible */
		{
			if (open_iwork ())						/* Si ouverture station imprimante */
			{
				nb_fontsim = vst_load_fonts (hprinter, 0);	/* Charger fontes imprimante */
				impression ();															/* Trac‚ et impression */
				vst_unload_fonts (hprinter, 0);							/* D‚charger les fontes */
			}
			v_clswk (hprinter);						/* Fermeture station imprimante */
		}

		if (open_mwork ())							/* Si ouverture station Meta File */
			metafile ();									/* Trac‚ et cr‚ation fichier Meta */
		v_clswk (hmeta);								/* Fermeture station Meta */
  
		vst_unload_fonts (hscreen, 0);	/* D‚charger fontes ‚cran */
		v_clsvwk (hscreen);							/* Fermeture station virtuelle ‚cran */
	}
	appl_exit ();											/* Virer l'application GEM */
	exit (0);													/* Quitter */
}
/* #] main () Initialisations et gestion :													*/ 
/* #[ affichage () Affichage des fontes :														*/
void affichage (void)
{
int i = 2, x, y, w, h, d, id, pxy[4], clip[4], pts[8], maxi = 0;
char chaine[35];

	v_hide_c (hscreen);								/* Cacher la souris */

	clip[0] = 0;											/* Coordonn‚es du clipping : */
	clip[1] = 0;											/* tout l'‚cran. */
	clip[2] = wscr;
	clip[3] = hscr;
	vs_clip (hscreen, TRUE, clip);		/* Clipper */

		/* "Vider" l'‚cran */
	pxy[0] = pxy[1] = 0;							/* Coordonn‚es */
	pxy[2] = wscr;
	pxy[3] = hscr;
	vsf_interior (hscreen, FIS_PATTERN);	/* Trame */
	vsf_style (hscreen, 8);								/* Trame 100% */
	vsf_color (hscreen, 0);								/* Couleur blanche */
	vsf_perimeter (hscreen, FALSE);				/* Pas de bordure */
	v_bar (hscreen, pxy);									/* Effacer */

	vswr_mode (hscreen, MD_TRANS);				/* Ecriture en mode transparent */

	vst_alignment (hscreen, 1, 5, &d, &d);	/* Alignement texte : haut centr‚ */
	vst_color (hscreen, 1);									/* Texte en noir */
	x = wscr / 2;														/* Au milieu en largeur */
	y = 10;																	/* A 10 pixels du haut */
	while ((i <= (nb_fontssc + 1)) && (y < hscr))
	{		/* Pour chaque fonte tant qu'on est sur l'‚cran */
		id = vqt_name (hscreen, i, chaine);		/* Nom et identificateur fonte */
		if (chaine[32] == 1)									/* Si fonte vectorielle */
		{
			vst_font (hscreen, id);										/* Activer fonte */
			vst_arbpt (hscreen, 9, &d, &d, &w, &h);		/* Taille 9 */
			vst_setsize (hscreen, 18, &d, &d, &d, &d);	/* 2 fois plus large */
			vst_skew (hscreen, 300);									/* Italisation */
			vqt_f_extent (hscreen, chaine, pts);			/* Coordonn‚es rectangle texte */
			maxi = max (maxi, pts[4] - pts[6]);				/* Enregistrer largeur maxi */
			v_ftext (hscreen, x, y, chaine);					/* Afficher chaŒne */
			y += h;																		/* Ligne suivante */
		}
		i++;																	/* Fonte suivante */
	}

	pxy[0] = pxy[2] = (wscr / 2) - (maxi / 2) - 10;	/* Ligne de gauche */
	pxy[1] = 10;
	pxy[3] = y;
	v_pline (hscreen, 2, pxy);											/* Tracer ligne */
	pxy[0] = pxy[2] = (wscr / 2) + (maxi / 2) + 10;	/* Ligne de droite */
	v_pline (hscreen, 2, pxy);											/* Tracer ligne */

	vs_clip (hscreen, FALSE, clip);		/* D‚clipper */
	v_show_c (hscreen, TRUE);					/* Montrer souris */
	Bconin (2);		/* Attendre pression d'une touche */
}
/* #] affichage () Affichage des fontes :														*/ 
/* #[ impression () Impression des fontes :													*/
void impression (void)
{
int i = 2, x, y, w, h, d, id, pxy[4], clip[4], pts[8], maxi = 0;
char chaine[35];

	v_clear_disp_list (hprinter);		/* Vider station */

	clip[0] = 0;										/* Clipper toute la surface disponible */
	clip[1] = 0;
	clip[2] = wimp;
	clip[3] = himp;
	vs_clip (hprinter, TRUE, clip);

	vswr_mode (hprinter, MD_TRANS);	/* Mode transparent */

	vst_alignment (hprinter, 1, 5, &d, &d);	/* Alignement texte : haut centr‚ */
	vst_color (hprinter, 1);								/* Couleur du texte : noire */
	x = wimp / 2;														/* Position de d‚part */
	y = 200;
	while ((i <= (nb_fontsim + 1)) && (y < himp))
	{			/* Pour chaque fonte et tant qu'on est sur la "page" */
		id = vqt_name (hprinter, i, chaine);	/* Nom et identificateur fonte */
		if (chaine[32] == 1)									/* Si fonte vectorielle */
		{
			vst_font (hprinter, id);										/* Activer fonte */
			vst_arbpt (hprinter, 9, &d, &d, &w, &h);		/* ARBitrary PoinT : 9 */
			vst_setsize (hprinter, 18, &d, &d, &d, &d);	/* 2 fois plus large */
			vst_skew (hprinter, 300);										/* Italisation */
			vqt_f_extent (hprinter, chaine, pts);				/* Coord. rectangle texte */
			maxi = max (maxi, pts[4] - pts[6]);					/* Enregistrer largeur maxi */
			v_ftext (hprinter, x, y, chaine);						/* Afficher chaŒne */
			y += h;																			/* Ligne suivante */
		}
		i++;																	/* Fonte suivante */
	}

	pxy[0] = pxy[2] = (wimp / 2) - (maxi / 2) - 10;	/* Ligne de gauche */
	pxy[1] = 200;
	pxy[3] = y;
	v_pline (hprinter, 2, pxy);											/* Tracer ligne */
	pxy[0] = pxy[2] = (wimp / 2) + (maxi / 2) + 10;	/* Ligne de droite */
	v_pline (hprinter, 2, pxy);											/* Tracer ligne */

	vs_clip (hprinter, FALSE, clip);								/* D‚clipper */

	v_updwk (hprinter);				/* Imprimer */
	v_clrwk (hprinter);				/* Ejecter feuille */
	Bconin (2);		/* Attendre pression d'une touche */
}
/* #] impression () Impression des fontes :													*/ 
/* #[ metafile () Ecrit dans le fichier meta :											*/
void metafile (void)
{
int pxy[4], clip[4], d;

	clip[0] = 0;											/* Clipper toute la surface disponible */
	clip[1] = 0;
	clip[2] = wmtf;
	clip[3] = hmtf;
	vs_clip (hmeta, TRUE, clip);

	vswr_mode (hmeta, MD_TRANS);				/* Mode transparent */

	vsl_color (hmeta, 1);								/* Couleur lignes : noir */
	vsl_type (hmeta, SOLID);						/* Type lignes : pleines */
	vsl_width (hmeta, 1);								/* Largeur lignes : 1 */
	vsl_ends (hmeta, SQUARE, SQUARE);		/* Extr‚mit‚s lignes : carr‚es */

	pxy[0] = 10;										/* PremiŠre diagonale */
	pxy[1] = 10;
	pxy[2] = 2090;
	pxy[3] = 2960;
	v_pline (hmeta, 2, pxy);

	pxy[0] = 2100;									/* Seconde diagonale */
	pxy[1] = 10;
	pxy[2] = 10;
	pxy[3] = 2960;
	v_pline (hmeta, 2, pxy);

	vsf_perimeter (hmeta, TRUE);				/* Tracer pourtour */
	vsf_interior (hmeta, FIS_HOLLOW);		/* Int‚rieur blanc */
	vsf_color (hmeta, 1);            		/* Couleur noire */
	v_circle (hmeta, 1000, 1000, 500);	/* Tracer cercle */

	vst_font (hmeta, 1);											/* Activer fonte systŠme */
	vst_height (hmeta, 20, &d, &d, &d, &d);		/* Taille 20 */
	v_gtext (hmeta, 500, 500, "Texte");				/* Ecrire un texte */

	vs_clip (hmeta, FALSE, clip);			/* D‚clipper */
}
/* #] metafile () Ecrit dans le fichier meta :											*/ 
/* #[ open_vwork () Ouvrir station travail virtuelle :							*/
void open_vwork (void)
{
int i, a, b;

	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* R‚glages par d‚faut */
	_VDIParBlk.intin[10] = 2;													/* Coordonn‚es RC */
	_VDIParBlk.intin[0] = Getrez () + 2;
	hscreen = graf_handle (&a, &b, &i, &i);						/* Handle station ‚cran */
	v_opnvwk (_VDIParBlk.intin, &hscreen, _VDIParBlk.intout);	/* Ouvrir station */
	wscr = _VDIParBlk.intout[0];											/* Largeur ‚cran */
	hscr = _VDIParBlk.intout[1];											/* Hauteur ‚cran */
}
/* #] open_vwork () Ouvrir station travail virtuelle :							*/ 
/* #[ open_iwork () Ouvrir station travail physique :								*/
int open_iwork (void)
{
int i, ok;
char nom[50];

	_VDIParBlk.intin[0] = 21;					/* Imprimante */
	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* Par d‚faut */
	_VDIParBlk.intin[10] = 2;	 				/* Coordonn‚es RC */

	v_opnwk (_VDIParBlk.intin, &hprinter, _VDIParBlk.intout);	/* Ouvrir station physique */
	wimp = _VDIParBlk.intout[0];					/* Largeur imprimante */
	himp = _VDIParBlk.intout[1];					/* Hauteur imprimante */
	vqt_devinfo (hprinter, 21, &ok, nom);	/* Driver disponible ? */
	return (ok);
}
/* #] open_iwork () Ouvrir station travail physique :								*/ 
/* #[ open_mwork () Ouvrir station meta fichier :										*/
int open_mwork (void)
{
int i, ok;
char nom[15];

	_VDIParBlk.intin[0] = 31;					/* Fichier meta */
	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* Par d‚faut */
	_VDIParBlk.intin[10] = 2;	 				/* Coordonn‚es RC */

	v_opnwk (_VDIParBlk.intin, &hmeta, _VDIParBlk.intout);	/* Ouverture station */
	vm_filename (hmeta, FILEMETA);			/* Changer le nom du fichier Meta */
	vqt_devinfo (hmeta, 31, &ok, nom);	/* Driver disponible ? */

	if (ok)
	{
		Fdelete ("GEMFILE.GEM");					/* D‚truire le fichier par d‚faut */
		v_meta_extents (hmeta, 0, 0, wmtf, hmtf);	/* Fixer les coordonn‚es */
		vm_pagesize (hmeta, wmtf, hmtf);					/* Fixer dimensions de la page */
		vm_coords (hmeta, 0, hmtf, wmtf, 0);			/* SystŠme de coordonn‚es */
	}
	return (ok);
}
/* #] open_mwork () Ouvrir station meta fichier :										*/ 

