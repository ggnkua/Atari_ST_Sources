	/* Traduction de Monsieur/Madame */
	/* DeuxiŠme possibilit‚ */
#include "string.h"
#include "stdio.h"
#include "tos.h"

	/* D‚claration des constantes */
#define TRUE 1
#define FALSE 0

	/* D‚claration de la seule fonction */
int main (void);

	/* D‚claration des variables */
int monsieur = FALSE;	/* On veut une madame */
char t[50];		/* Un peu de place pour le texte … afficher */
int app_id;		/* On a besoin de cet identificateur pour l'alerte de fin */

int main (void)
{
	app_id = appl_init ();	/* D‚lcare l'application … l'AES */
	
	/* Remarquez que nous n'avons pas d‚clar‚ les chaines en constantes,
		car le Pure C sait g‚rer les instructions suivantes automatiquement.
		L'int‚rˆt des constantes, c'est que quand vous traduisez le logiciel,
		il n'y a pas besoin de parcourir tout le source: tout est au d‚but. */
	if (monsieur)			/* Le != 0 est ici implicite */
	{
		strcpy (t, "Bonjour");
		strcat (t, " ");		/* Ajoute un espace */
		strcat (t, "Monsieur");	/* Ajoute monsieur */
	}
	else
	{
		strcpy (t, "Bonjour");
		strcat (t, " ");		/* Ajoute un espace */
		strcat (t, "Madame");	/* Ajoute madame */
	}
	
	printf (t);
	printf ("\n");		/* AmŠne la curseur … la ligne */
	
	/* Nous mettons ici une boite d'alerte fin de programme */
	form_alert (1, "[3][Fin du programme.|DeuxiŠme ligne.][ OK ]");
	/* Expication : 3=Icone STOP, "|"=aller … la ligne, "1"=num‚ro
		du bouton par d‚faut. */
	
	appl_exit ();			/* Quitte l'AES */
	return 0;
}
