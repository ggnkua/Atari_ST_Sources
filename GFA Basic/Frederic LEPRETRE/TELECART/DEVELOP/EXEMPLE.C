/*************************************************************************
 *          EXEMPLE D'UTILISATION DE LA LIBRAIRIE TELECART.LIB           *
 *-----------------------------------------------------------------------*
 * F.LEPRETRE                                                   02/11/94 *
 *************************************************************************/

# include <stdio.h>
# include <telecart.h>

void main(void)
{
unsigned char CARTE[32];	/* tableau de 32 octets pour copie de la carte */
unsigned int i,t;

struct InfoCarte info;		/* structure pour recevoir le r‚sultat de l'analyse */

printf("\nExemple d'utilisation de la librairie TELECARTE ");
printf("\n(c) F. LEPRETRE   02/11/94");

/* Acquisition du num‚ro de la version de la librairie */
printf("\nNum‚ro de version de la librairie %x \n",GetVerLibTel());

/* Lecture de la t‚l‚carte */
LectureCarte(CARTE);

/* Affichage sous forme hexad‚cimale */
t=0;
for (i=0;i<32;i++)
	{
	t++;
	printf("%02X ",CARTE[i]);
	if (t==8)
		{
		printf("\n");
		t=0;
		}
	}

/* analyse de la t‚l‚carte */
info = AnalyseCarte(CARTE);

/* Affichage des caract‚ristiques de la t‚l‚carte */

if (info.Etat == HS)
	printf("\nCarte non utilisable ");
else
	if (info.Etat == EPUISEE)
		printf("\nCarte ‚puis‚e ");

/* Recherche du type de la carte (40, 50 ou 120 unit‚s) */
switch (info.TypeCarte)
		{
		case U40     :	/* carte 40 unit‚s */
						printf("\nCarte 40 unit‚s ");
						break;

		case U50	 :  /* carte 50 unit‚s */
						printf("\nCarte 50 unit‚s ");
						break;

		case U120	 :  /* carte 120 unit‚s */
						printf("\nCarte 120 unit‚s ");
						break;

		default	     :  /* Cas par d‚faut */
						printf("\nType de carte inconnu ");
						break;
		}
/* Affichage du nombre d'unit‚ non "grill‚s" */
printf("\nIl reste %d unit‚(s) ",info.Unite);

getchar();
}
