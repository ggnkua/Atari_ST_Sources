	/* Module du projet TOTO
		 Module d'initialisation. */

#include "stdio.h"
/* Remarquez que l'on n'inclut pas le fichier TOTO.H dans ce module
	puisqu'on ne se sert pas des variables de TOTO.C, ‚conomie de compilation.
	*/

/* Remarquez que je fais comme dit le chef de rubrique parce que c'est ce
	qu'il faut faire. (bon, ‚videmment, l… c'est un peu ‚xag‚r‚ mais bon,
	c' est pour le principe.)
	*/

/* On indique qu'on veut les d‚clarations sans "extern" */
#define PRINCIPAL
#include "INITIAL.H"

void init_toto (void)
{
	/* Description :
	Affiche un petit message pour dire bonjour aux lecteurs d'STMAG.
	
		ParamŠtres :
	rien.
	
		Retour :
	rien.
	*/
	
	printf ("Bonjour, programme d'exemple pour STMAG.\nNous sommes dans le fichier INITIAL.C.\n");
}
