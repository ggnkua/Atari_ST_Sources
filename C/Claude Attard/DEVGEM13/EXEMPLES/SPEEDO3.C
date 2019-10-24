/*							SPEEDO3.C
			Programme d'exemple d'impression
			d'images bitmap sous SpeedoGDOS
	Claude ATTARD pour ST Mag - Janvier 1994
*/

/* #[ D‚finitions :																									*/
#include <stdio.h>
#include <stdlib.h>
#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include "xwk.h"

enum {FALSE, TRUE};

#define IMAGE "IMAGE.PI3"

int ap_id;													/* Identificateur d'application */
int nb_fontsme = 0;									/* Nbre fontes m‚moire */
int handlesc;												/* Handle VDI ‚cran */
int handleim;												/* Handle VDI imprimante */
int handleme;												/* Handle VDI m‚moire */
int wmem, hmem;
long adr;
MFDB nul = {0}, mem;
/* #] D‚finitions :																									*/ 
/* #[ Prototypage :																									*/
void main (void);
void memory (void);
void imprime (void);
void open_vwork (void);
int open_iwork (void);
int open_memw (void);
/* #] Prototypage :																									*/ 
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
	ap_id = appl_init ();							/* D‚clarer l'application au GEM */
	graf_mouse (ARROW, 0);						/* Souris : flŠche */
	if (vq_vgdos () == GDOS_FSM)			/* Si Speedo est bien l… */
	{
		open_vwork ();									/* Ouverture station virtuelle ‚cran */
		if (open_memw ())								/* Ouverture station memoire */
		{
			nb_fontsme = vst_load_fonts (handleme, 0);	/* Charger fontes */
			memory ();														/* Travail en m‚moire */
			vst_unload_fonts (handleme, 0);				/* D‚charger fontes */
			v_clswk (handleme);										/* Fermeture station m‚moire */
		}
		v_clsvwk (handlesc);						/* Fermeture station virtuelle ‚cran */
	}
	appl_exit ();											/* Virer l'application GEM */
	exit (0);													/* Quitter */
}
/* #] main () Initialisations et gestion :													*/ 
/* #[ memory () :				*/
void memory (void)
{
int pxy[8], clip[4], color[2] = {BLACK, WHITE}, id, d, fh;
char chaine[35];
void *adimg;
MFDB img;

	v_hide_c (handlesc);						/* Cacher la souris */
	clip[0] = 0;										/* Clipper toute la surface disponible */
	clip[1] = 0;
	clip[2] = wmem;
	clip[3] = hmem;
	vs_clip (handleme, TRUE, clip);

		/* Remplissage MFDB memory */
	mem.fd_addr = (void *)adr;
	mem.fd_w = wmem;
	mem.fd_h = hmem;
	mem.fd_wdwidth = (wmem + 15) / 16;
	mem.fd_stand = 1;
	mem.fd_nplanes = 1;

	vswr_mode (handleme, MD_TRANS);		/* Mode transparent */

		/* Tracer un cercle … l'‚cran */
	v_clrwk (handlesc);										/* Effacer l'‚cran */
	vsf_interior (handlesc, 0);						/* Int‚rieur blanc */
	vsf_color (handlesc, 1);							/* Couleur noire */
	vsf_perimeter (handlesc, TRUE);				/* Voir contour */
	v_circle (handlesc, 320, 200, 50);		/* Cercle */
		/* Copie zone ‚cran vers m‚moire */
	pxy[0] = 270;
	pxy[1] = 150;
	pxy[2] = 370;
	pxy[3] = 250;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = 100;
	pxy[7] = 100;
	vrt_cpyfm (handlesc, 1, pxy, &nul, &mem, color);	/* Copie raster */
	v_clrwk (handlesc);

		/* Tracer une ligne diagonale en m‚moire */
	pxy[0] = 10;
	pxy[1] = 10;
	pxy[2] = 630;
	pxy[3] = 390;
	v_pline (handleme, 2, pxy);

		/* Tracer un carr‚ en m‚moire */
	pxy[0] = 100;
	pxy[1] = 100;
	pxy[2] = 490;
	pxy[3] = 210;
	vsf_interior (handleme, 0);						/* Int‚rieur blanc */
	vsf_color (handleme, 1);
	vsf_perimeter (handleme, TRUE);
	v_bar (handleme, pxy);

		/* Extrait d'une image PI3 vers la m‚moire */
		/* Chargement de l'image : */
	adimg = (void *)malloc(32000);						/* R‚server m‚moire pour l'image */
	if (adimg)																/* Si m‚moire bien ‚serv‚e */
	{
		fh = (int)Fopen (IMAGE, FO_READ);				/* Ouvrir le fichier image */
		if (fh >= 0)														/* Si fichier bien ouvert */
		{
			Fseek (34, fh, 0);										/* Sauter l'entˆte */
			Fread (fh, 32000, adimg);							/* Lire les donn‚es */
			Fclose (fh);													/* Fermer le fichier */
			img.fd_addr = (void *)adimg;					/* Pr‚parer le MFDB */
			img.fd_w = 640;
			img.fd_h = 400;
			img.fd_wdwidth = 40;
			img.fd_stand = 1;
			img.fd_nplanes = 1;
		/* Copie zone image vers m‚moire : */
			pxy[0] = 140;													/* x de l'image */
			pxy[1] = 10;													/* y de l'image */
			pxy[2] = pxy[0] + 370;								/* x + largeur de l'image */
			pxy[3] = pxy[1] + 90;									/* y + hauteur de l'image */
			pxy[4] = 110;													/* x en m‚moire */
			pxy[5] = 110;													/* y en m‚moire */
			pxy[6] = pxy[4] + 370;								/* x + largeur en m‚moire */
			pxy[7] = pxy[5] + 90;									/* y + hauteur en m‚moire */
			vrt_cpyfm (handlesc, 1, pxy, &img, &mem, color);	/* Copie raster */
		}
		free (adimg);														/* Lib‚rer m‚moire image */
	}

	vswr_mode (handleme, MD_REPLACE);		/* Mode opaque */
		/* Ecriture d'un texte */
	if (nb_fontsme)											/* S'il y a des fontes */
	{
		id = vqt_name (handleme, 2, chaine);			/* On prend la premiŠre */
		vst_font (handleme, id);									/* On l'active */
		vst_arbpt (handleme, 10, &d, &d, &d, &d);	/* Taille 10 */
		v_ftext (handleme, 400, 300, chaine);			/* Ecriture du nom */
	}

	vs_clip (handleme, FALSE, clip);								/* D‚clipper */

		/* Recopier m‚moire vers ‚cran */
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = 640;
	pxy[3] = 399;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = 639;
	pxy[7] = 399;
	vrt_cpyfm (handlesc, 1, pxy, &mem, &nul, color);	/* Copie raster */

	imprime ();													/* Impression */

	v_show_c (handlesc, TRUE);					/* Montrer souris */
	Bconin (2);		/* Attendre pression d'une touche */
}
/* #] memory () :				*/ 
/* #[ imprime :					*/
void imprime (void)
{
	if (Cprnos ())									/* Si imprimante disponible */
	{
		if (open_iwork ())						/* Si ouverture station imprimante */
		{
			xv_updwk (handleim, (int *)adr);	/* Impression du buffer */
			v_clrwk (handleim);					/* Ejecter feuille */
			v_clswk (handleim);					/* Fermeture station imprimante */
		}
	}
}
/* #] imprime :					*/ 
/* #[ open_vwork () Ouvrir station travail virtuelle :							*/
void open_vwork (void)
{
int i, a, b;

	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* R‚glages par d‚faut */
	_VDIParBlk.intin[10] = 2;													/* Coordonn‚es RC */
	_VDIParBlk.intin[0] = Getrez () + 2;							/* Selon r‚solution */
	handlesc = graf_handle (&a, &b, &i, &i);					/* Handle station ‚cran */
	v_opnvwk (_VDIParBlk.intin, &handlesc, _VDIParBlk.intout);	/* Ouvrir station */
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

	xv_opnwk (&handleim, wmem, hmem);	/* Ouverture station */

	vqt_devinfo (handleim, 21, &ok, nom);	/* Driver disponible ? */
	return (ok);
}
/* #] open_iwork () Ouvrir station travail physique :								*/ 
/* #[ open_memw () :		*/
int open_memw (void)
{
int i, ok;
char nom[50];

	_VDIParBlk.intin[0] = 61;					/* M‚moire */
	for (i = 1 ; i < 10 ; _VDIParBlk.intin[i++] = 1);	/* Par d‚faut */
	_VDIParBlk.intin[10] = 2;	 				/* Coordonn‚es RC */
	xv_opnwk (&handleme, 640, 400);		/* Ouverture station */
		/* R‚cup‚ration des donn‚es */
	wmem = _VDIParBlk.intout[0];			/* Largeur */
	hmem = _VDIParBlk.intout[1];			/* Hauteur */
	adr = _VDIParBlk.contrl[0];				/* Adresse */
	adr <<= 16;
	adr += _VDIParBlk.contrl[1];
	v_updwk (handleme);								/* Effacer le buffer */

	vqt_devinfo (handleme, 61, &ok, nom);	/* Driver disponible ? */
	return (ok);
}
/* #] open_memw () :		*/ 

