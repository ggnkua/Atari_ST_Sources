/* g‚n‚rateur de fichier palette de degrade */
/* par Golio Junior */

#include <stdio.h>
#include <math.h>

/* nom du fichier cr‚‚ */
static char nom[]="e:\inter_tc.pal";

int main(void)
{ int Nbre, CompD_R, CompD_V, CompD_B, CompA_R, CompA_V, CompA_B;
  int Comp_R, Comp_V, Comp_B, compteur, offset;
  float Pas_R, Pas_V, Pas_B;
  unsigned int palette[64];
  unsigned int temp;
  unsigned long a;
  FILE *fichier;
    
  if ((fichier=fopen(nom, "wb"))<0)
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
  	      printf(" No de la premiŠre couleur : ");
  	      scanf("%d",&offset);
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
		  	{ Comp_R=(int)32*((float)CompD_R+Pas_R*compteur)/1000;
		  	  Comp_V=(int)32*((float)CompD_V+Pas_V*compteur)/1000;
		  	  Comp_B=(int)32*((float)CompD_B+Pas_B*compteur)/1000;
		  	  palette[offset+compteur]=Comp_R*2048+Comp_V*64+Comp_B;
		  	}
  	    } while (Nbre!=0);
  	  /* generation de la palette */
  	  for(a=-(long)(32768L); a!=(long)(32768L-1); a=a+1)
  	  	{ temp=palette[(a>>8)%64];
  	  	  if (fwrite(&temp, 2, 1, fichier)!=1)
  	  	  	{ printf(" erreur d'ecriture \n");
  	  	  	}
  	  	  temp=palette[a%64];
  	  	  if (fwrite(&temp, 2, 1, fichier)!=1)
  	  	  	{ printf(" erreur d'ecriture \n");
  	  	  	}
  	  	}
      if (fclose(fichier))
      	{ printf(" erreur de fermeture \n");
  		}
      return 0;
  	}
}