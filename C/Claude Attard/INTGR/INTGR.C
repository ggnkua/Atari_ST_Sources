/*			D‚velopper sous GEM
	Travail avec un ressource int‚gr‚
		Claude ATTARD pour ST MAG
						Juin 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <tos.h>
#include "INTGR.RSH"

	/* Prototypages */
void main (void);
void coordonnees (void);

	/* Variable globale */
int ap_id;		/* Identificateur de l'application */

void main (void)
{
int x, y, w, h; 		/* Coordonn‚es du formulaire */

	ap_id = appl_init (); /* D‚clarer l'application au GEM */
		/* Adapter les coordonn‚es des objets … la r‚solution courante */
	coordonnees ();
	graf_mouse (ARROW, 0);		/* Souris : forme de flˆche */

		/* Remplir champ ‚ditable avec le texte par d‚faut */
	strcpy (rs_trindex[PPAL][SAISIE].ob_spec.tedinfo->te_ptext, "Non ?");

	form_center (rs_trindex[PPAL], &x, &y, &w, &h); 	/* Centrer le formulaire */
	form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);		/* R‚server fond */
	objc_draw (rs_trindex[PPAL], 0, MAX_DEPTH, x, y, w, h);	/* Dessiner formulaire */
	form_do (rs_trindex[PPAL], 0);										/* Gestion par le GEM */
	form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);		/* Lib‚rer fond */

		/* Et puis on se casse parce qu'il se passe plus rien */
	appl_exit ();
}

void coordonnees (void)
{
int i, j, nb_tree;

	nb_tree = 1;		/* Dans notre programme, il n'y a qu'une arborescence */
	for (i = 0 ; i < nb_tree ; i++) 	/* Pour chaque arbre du RSC int‚gr‚, */
	{
		j = 0;													/* et chaque objet, */
		do
		{			/* Tant qu'on n'est pas au dernier objet */
			rsrc_obfix (rs_trindex[i], j);		/* Adapter coordonn‚es */
		} while (! (rs_trindex[i][j++].ob_flags & LASTOB));
	}
}

