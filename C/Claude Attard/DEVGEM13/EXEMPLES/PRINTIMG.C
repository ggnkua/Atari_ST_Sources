/*							PRINTIMG.C
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
int handlesc;												/* Handle VDI ‚cran */
int handleim;												/* Handle VDI imprimante */
/* #] D‚finitions :																									*/ 
/* #[ Prototypage :																									*/
void main (void);
void chargement (void);
void imprime (void *adr);
void open_vwork (void);
int open_iwork (void);
/* #] Prototypage :																									*/ 
/* #[ main () Initialisations et gestion :													*/
void main (void)
{
	ap_id = appl_init ();							/* D‚clarer l'application au GEM */
	graf_mouse (ARROW, 0);						/* Souris : flŠche */
	if (vq_vgdos () == GDOS_FSM)			/* Si Speedo est bien l… */
	{
		open_vwork ();									/* Ouverture station virtuelle ‚cran */
		v_hide_c (handlesc);						/* Cacher la souris */
		v_clrwk (handlesc);							/* Effacer l'‚cran */
		chargement ();
		v_show_c (handlesc, TRUE);			/* Montrer souris */
		v_clsvwk (handlesc);						/* Fermeture station virtuelle ‚cran */
	}
	appl_exit ();											/* Virer l'application GEM */
	exit (0);													/* Quitter */
}
/* #] main () Initialisations et gestion :													*/ 
/* #[ chargement () :																								*/
void chargement (void)
{
int fh;
void *adimg;

	Cconws ("\n\rChargement de l'image.\n\r");
		/* Chargement de l'image : */
	adimg = (void *)malloc (32000);						/* R‚server m‚moire pour l'image */
	if (adimg)																/* Si m‚moire bien ‚serv‚e */
	{
		fh = (int)Fopen (IMAGE, FO_READ);				/* Ouvrir le fichier image */
		if (fh >= 0)														/* Si fichier bien ouvert */
		{
			Fseek (34, fh, 0);										/* Sauter l'entˆte */
			Fread (fh, 32000, adimg);							/* Lire les donn‚es */
			Fclose (fh);													/* Fermer le fichier */
			imprime (adimg);											/* Impression */
		}
		else
			Cconws ("Chargement image impossible !\n\r");
		free (adimg);														/* Lib‚rer m‚moire image */
	}
	else
		Cconws ("R‚servation m‚moire impossible !\n\r");

	Cconws ("\n\rPressez une touche.\n\r");
	Bconin (2);		/* Attendre pression d'une touche */
}
/* #] chargement () :																								*/ 
/* #[ imprime :																											*/
void imprime (void *adr)
{
	if (Cprnos ())									/* Si imprimante disponible */
	{
		if (open_iwork ())						/* Si ouverture station imprimante */
		{
			Cconws ("Impression...\n\r");
			xv_updwk (handleim, (int *)adr);	/* Impression du buffer */
			v_clrwk (handleim);					/* Ejecter feuille */
			v_clswk (handleim);					/* Fermeture station imprimante */
		}
		else
			Cconws ("Ouverture station impossible !\n\r");
	}
	else
		Cconws ("L'imprimante n'est pas disponible !\n\r");
}
/* #] imprime :																											*/ 
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

	xv_opnwk (&handleim, 640, 400);		/* Ouverture station */

	vqt_devinfo (handleim, 21, &ok, nom);	/* Driver disponible ? */
	return (ok);
}
/* #] open_iwork () Ouvrir station travail physique :								*/ 

