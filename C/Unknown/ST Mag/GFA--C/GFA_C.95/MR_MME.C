	/* Traduction de Monsieur/Madame */
	/* PremiŠre possibilit‚ */
#include "string.h"
#include "stdio.h"
#include "tos.h"

	/* D‚claration des constantes */
#define TRUE 1
#define FALSE 0

	/* Les chaines a$,b$ et c$ n'‚tant pas modifi‚es au cours
		du programme, ce sont en C des constantes, on les d‚lcare
		donc ici. */
#define STR_A "Bonjour"
#define STR_B "Mr rigolo"
#define STR_C "Mme rigolote"

	/* D‚claration de la seule fonction */
int main (void);

	/* D‚claration des variables */
int monsieur = FALSE;
char t[50];		/* Un peu de place pour le texte … afficher */

int main (void)
{
	if (monsieur != 0)
	{
		/* t est au d‚part vide, on y met le bonjour */
		strcpy (t, STR_A);
		strcat (t, " ");		/* Ajoute un espace */
		strcat (t, STR_B);	/* Ajoute monsieur */
	}
	else
	{
		strcpy (t, STR_A);
		strcat (t, " ");		/* Ajoute un espace */
		strcat (t, STR_C);	/* Ajoute madame */
	}
	
	printf (t);
	printf ("\n");		/* AmŠne la curseur … la ligne */
	
	return 0;
}
