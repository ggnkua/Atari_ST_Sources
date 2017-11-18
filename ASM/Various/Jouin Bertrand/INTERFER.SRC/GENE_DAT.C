/* g‚n‚rateur de fichier DAT : fichier image */
/* par Golio Junior */

#include <stdio.h>
#include <math.h>

/* nom du fichier cr‚‚ */
static char nom[]="e:\inter.dat";

/* fonction math‚matique de generation */
int fonction(int x, int y)
{  return (int)(31.0*cos(8*M_PI*sqrt((float)x*x+(float)y*y)/188));
}

/* fonction d'affichage d'un point dans un groupe en mode … plan */
void affiche(unsigned int memoire[], int offset, int couleur)
{
#define NB_PLAN	8
  unsigned int compteur, Pos_Bit;
  Pos_Bit=(0x8000)>>offset;
  for (compteur=1; compteur<=NB_PLAN; compteur++)
  	{ if (couleur % 2)
  		{ memoire[compteur]|=Pos_Bit;
  		}
  	  else
  	    { memoire[compteur]&=~Pos_Bit;
  	    }
  	  couleur/=2;
  	}
}

int main(void)
{ int x, y, xbis;
  int temp;
  unsigned int groupe[8];
  FILE *fichier;
    
  if ((fichier=fopen(nom, "wb"))<0)
  	{ printf(" Impossible d'ouvrir le fichier %s \n",nom);
  	  return -1;
  	}
  else
  	{ /* routine de generation */
  	  y=0;
  	  for (y=-200; y<=199; y++)
    	  { printf(" y : %d \n", y);
       		for (x=-320; x<=319; x+=16)
    			{ for (xbis=0; xbis<=15; xbis++)
    				{ temp=fonction(x+xbis,y);
    				  affiche(groupe, xbis, temp);
    				}
    	  		  if ((fwrite(groupe, 2, 8, fichier))!=8)
    	  		  	{ printf(" erreur d'ecriture \n");
    	  		  	  goto fin;
    	  		  	}
                }
          }
      fin:
      if (fclose(fichier))
      	{ printf(" erreur de fermeture \n");
      	}
      return 0;
  	}
}