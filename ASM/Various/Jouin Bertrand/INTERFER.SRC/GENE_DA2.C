/* g‚n‚rateur de fichier DAT : fichier image */
/* par Golio Junior */

#include <stdio.h>
#include <math.h>

/* nom du fichier cr‚‚ */
static char nom[]="e:\inter_tc.dat";

/* fonction math‚matique de generation */
int fonction(int x, int y)
{  return (int)(31.0*cos(8*M_PI*sqrt((float)x*x+(float)y*y)/188));
}

int main(void)
{ int x, y;
  int temp;
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
       		for (x=-320; x<=319; x++)
    			{ temp=fonction(x,y)<<8;
    	  		  if ((fwrite(&temp, 1, 1, fichier))!=1)
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