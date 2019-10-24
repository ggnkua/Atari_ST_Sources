#include "tos.h"
#include "string.h"
#include "stdio.h"

#define CHAINE1 "Coucou bonjour.\n"
#define CHAINE2 "Hello.\n"

#define TRUE 1
#define FALSE 0

void main (void);

void main (void)
{
	char str1[] = "Ceci est un test.\n";
	char str2[100];
	int i;
	
	strcpy (str2, str1);
	strcat (str2, CHAINE1);
	printf (str2);
	
	i = strlen(CHAINE1);
	itoa (i, str2, 10);
	printf (str2);			/* Affiche la longueur de CHAINE1 */
	printf ("\n");			/* A la ligne */
	
	if (strcmp (str2, "16") == FALSE)
	{
		/* Pas de diff‚rences */
		printf ("Identique.\n");
	}
	else
		/* 1 seule ligne, je peux enlever les {}, en effet les
			commentaires ne comptent pas... */
		printf ("Diff‚rent.\n");
	
	Pterm (0);/* Le C le fait normalement pour vous mais autant le mettre. */
}
