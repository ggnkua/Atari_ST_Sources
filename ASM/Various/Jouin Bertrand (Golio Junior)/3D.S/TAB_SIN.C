/* g‚n‚rateur de fichier DAT contenant une fonction math‚matique */
/* par Golio Junior */

#include <stdio.h>
#include <math.h>

#define X_MIN	0
#define X_MAX	M_PI*2

#define TAILLE_TABLEAU	256

/* nom du fichier cr‚‚ */
static char nom[]="sin.dat";

int fonction(float x)
{ return (int)(sin(x)*256);
}

int main(void)
{ int i, y;
  float x;
  FILE *fichier;

  if ((fichier=fopen(nom, "w"))==NULL)
  	{ printf(" Impossible d'ouvrir le fichier %s \n",nom);
  	  return -1;
  	}
  	else
  	{ /* routine de generation */
	  for (i=0; i<TAILLE_TABLEAU; i++)
	    { x=i*(X_MAX-X_MIN)/TAILLE_TABLEAU;
	      y=fonction(x);
	      fprintf(fichier, "\tdc.w $%X\n", y);
	    }
	  fclose(fichier);
	}
  return 0;
}