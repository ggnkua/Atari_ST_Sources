/* g‚n‚rateur de fichier palette de degrade */
/* par Golio Junior */

#include <stdio.h>
#include <math.h>

/* nom du fichier cr‚‚ */
static char nom[]="e:\inter.pal";

int main(void)
{ int Nbre, CompD_R, CompD_V, CompD_B, CompA_R, CompA_V, CompA_B;
  int Comp_R, Comp_V, Comp_B, compteur;
  float Pas_R, Pas_V, Pas_B;
  FILE *fichier;
    
  if ((fichier=fopen(nom, "w"))<0)
  	{ printf(" Impossible d'ouvrir le fichier %s \n",nom);
  	  return -1;
  	}
  else
  	{ do
  	    { /* demande du nombre d'etape du degrad‚ */
  	      printf(" Nombre d'‚tape (0 pour sortir) :");
  	      scanf("%d",&Nbre);
  	      if (!Nbre)
  	      	{ continue;
  	      	}
  	      printf(" Composantes stock‚e entre 0 et 999 \n");
  	      printf(" Composante Rouge de Depart : ");
  	      scanf("%d",&CompD_R);
  	      printf(" Composante Vert de Depart : ");
  	      scanf("%d",&CompD_V);
  	      printf(" Composante Bleu de Depart : ");
  	      scanf("%d",&CompD_B);

  	      printf(" Composante Rouge d'Arriv‚e : ");
  	      scanf("%d",&CompA_R);
  	      printf(" Composante Vert d'Arriv‚e : ");
  	      scanf("%d",&CompA_V);
  	      printf(" Composante Bleu d'Arriv‚e : ");
  	      scanf("%d",&CompA_B);

		  /* interpolation lin‚aire des 3 Composantes */
		  /* calcul des pas */
		  Pas_R=((float)(CompA_R-CompD_R))/(Nbre-1);
		  Pas_V=((float)(CompA_V-CompD_V))/(Nbre-1);
		  Pas_B=((float)(CompA_B-CompD_B))/(Nbre-1);
		  for(compteur=0; compteur<Nbre; compteur++)
		  	{ Comp_R=(int)64*((float)CompD_R+Pas_R*compteur)/1000;
		  	  Comp_V=(int)64*((float)CompD_V+Pas_V*compteur)/1000;
		  	  Comp_B=(int)64*((float)CompD_B+Pas_B*compteur)/1000;
		  	  fprintf(fichier, "     dc.b $%X, $%X, $00, $%X\n", Comp_R*4, Comp_V*4, Comp_B*4);
		  	}
  	    } while (Nbre!=0);
      if (fclose(fichier))
      	{ printf(" erreur de fermeture \n");
  		}
      return 0;
  	}
}