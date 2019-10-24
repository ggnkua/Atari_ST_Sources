	/* Inclusions : */
#include "tos.h"
#include "stdio.h"
#include "string.h"

	/* Notre programme va afficher 20 discriminants
		en tirant a,b,c au hasard. */

	/* Constantes num‚riques */
#define TRUE 1
#define FALSE 0
#define NB_TEST 10

	/* Constantes alphanum‚riques */
#define ALERT0 "[1][Bonjour.][OK]"

	/* D‚claration des fonctions */
void main (void);
int discriminant (int a, int b, int c);

	/* Variables globales */
int mouse_x, mouse_y, mouse_k;
int discr[NB_TEST];

void main (void)
{
	int i, d;
	char str[20];			/* prend 20 octets pour cette chaine */
	
	form_alert (1, ALERT0);		/* '1' indique le bouton par d‚faut */
	
	for (i = 0 ; i < NB_TEST ; i++)			/* Parcouru NB_TEST fois */
	{
		/* On peut ‚crire une ligne de code sur plusieurs lignes : */
		d = discriminant (Random() & 0xF, Random() & 0xF,
											Random() & 0xF);
		/* Remarque : 0x20 = 32 (notation hexa du C) */
		
		if (d < 0)
			printf ("N‚gatif.\n");		/* "\n" permet d'aller … la ligne */
		else
		{
			itoa (d, str, 10);		/* int d --> char str[] en base 10 */
			printf (str);
			printf ("\n");				/* Revient … la ligne */
		}
	}
	
	while (Cconis() == FALSE)
		;				/* mettre 1 point virgule si on ne fait rien */
	
	Crawcin ();		/* Enregistre la frappe de touche */
	Pterm (0);		/* Quitte le programme */
}

int discriminant (int a, int b, int c)
{
	int d;
	
	d = b*b - 4*a*c;
	
	return d;
}
