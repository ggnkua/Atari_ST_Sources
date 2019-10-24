/* Module principal du projet TOTO
	Il faut s‚lectionner le projet TOTO.PRJ et changer les chemins qui sont
	dedans avant de compiler.
*/

#include "tos.h"
#include "stdio.h"

/* Nous incluons les d‚finitions de INITIAL.C "avec extern". */
#include "INITIAL.H"

#include "ROUT_ASM.H"		/* Pour pouvoir utiliser la routine */

/* Nous incluons nos d‚clarations sans "extern" */
#define PRINCIPAL
#include "TOTO.H"

/* Attention, si vous mettez le #define PRINCIPAL avant INITIAL.H, il y aura
une erreur. Il faut que PRINCIPAL ne soit d‚fini que pour le fichier .H de
son propre module (TOTO.H pour TOTO.C, INITIAL.H pour INITIAL.C, etc.).
*/

void main (void)
{
	long val;
	
	/* Initialisation */
	init_toto ();
	
	val = MULTIPLY (57, 32);
	
	printf ("Bonjour, nous sommes dans TOTO.C, voici le r‚sultat\nde la multiplication :\n");
	/* Attention nous n'affichons que jusqu'… 32768... */
	printf ("val = %i.\n", (int)val);
	
	Crawcin ();
	
	quitter ();
}

void quitter (void)
{
	/* Description :
	Quitte notre programme pas trŠs proprement mais c'est pour faire une
	routine de plus.
	*/
	
	Crawcin ();
	Pterm0 ();
}
