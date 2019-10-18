#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include "initgem2.h"
void main (void);
void formulaire (void);

void main (void)
{
int buf[7];					/* Buffer d'‚v‚nements */
OBJECT *adr_menu;		/* Adresse du menu */

	rsrc_load ("INITGEM2.RSC");				/* Charger le ressource */
	rsrc_gaddr (0, MENU, &adr_menu);	/* Demander adresse menu */
	menu_bar (adr_menu, 1);						/* Afficher le menu */
	graf_mouse (ARROW, 0);						/* Souris : forme de flŠche */

	do										/* BOUCLE PRINCIPALE */
	{
		evnt_mesag (buf);		/* Le GEM surveille les ‚v‚nements message */
		if (buf[0] == 10)		/* Si ‚v‚nement de menu */
		{
			switch (buf[4])		/* Selon l'option de menu cliqu‚e */
			{
			case INFOS :			/* Si c'est "Infos", afficher une alerte */
		    form_alert (1,"[1][ Comment g‚rer | un menu d‚roulant,| une boŒte d'alerte| et un formulaire.][ Ok ]");
				break;
			case FORM :				/* Si c'est "Formulaire" */
				formulaire ();	/* Afficher un formulaire */
				break;
			}
			menu_tnormal (adr_menu, buf[3], 1);	/* R‚inverser le titre de menu */
		}
	} while (buf[4] != QUITTER);	/* Fin de boucle si option "Quitter" */
	menu_bar (adr_menu, 0);	/* Virer la barre de menu */
	rsrc_free ();						/* Lib‚rer le ressource */
}

void formulaire (void)
{
int i, sel, retour, x, y, w, h;
OBJECT *adr;
char txt[11], alrt[200];
char resultat[] = "[1][Radio-bouton : %d|Texte : %s|Bouton s‚lectable : %s][ Ok ]";

	rsrc_gaddr (0, FORMULAIRE, &adr);		/* Demander adresse formulaire */
	strcpy (adr[EDIT].ob_spec.tedinfo->te_ptext, "");	/* Vider champ ‚ditable */
	form_center (adr, &x, &y, &w, &h);	/* Centrer le formulaire */
	form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);	/* Pr‚parer l'affichage */
	objc_draw (adr, 0, MAX_DEPTH, x, y, w, h);			/* Affichage par le GEM */
	retour = form_do (adr, EDIT);			/* Gestion par le GEM */
	form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);	/* Effacer formulaire */
	objc_change (adr, retour, 0, x, y, w, h, 0, 0);	/* R‚inverser bouton de sortie */

	if (retour == OK)		/* Si on est sorti avec "Confirmer" */
	{
		for (i = RB1 ; i <= RB3 ; i++)	/* Tester les radios-boutons */
			if (adr[i].ob_state & SELECTED)
				sel = i;	/* Nø du bouton s‚lectionn‚ */
		strcpy (txt, adr[EDIT].ob_spec.tedinfo->te_ptext);	/* Lire le texte saisi */
		if (adr[SELE].ob_state & SELECTED)	/* Tester ‚tat bouton s‚lectable */
			sprintf (alrt, resultat, sel, txt, "Oui");	/* Pr‚parer texte alerte */
		else
			sprintf (alrt, resultat, sel, txt, "Non");
		form_alert (1, alrt);	/* Alerte qui indique ce qui a ‚t‚ fait dans le formulaire */
	}
}
