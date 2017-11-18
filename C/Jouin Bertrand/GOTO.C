/* calcul de moyenne avec  plusieurs nombres */
#include <stdio.h>

/* prototypage */
int main(void);

/* fonction principal */
int main(void)
{ int nb=0, compteur;
  float som, sai;
  som=sai=0;
  printf(" Programme de calcul de moyenne \n");
  while(1)
  { printf(" Combien de nombres pour le calcul de la moyenne ? ");
    scanf("%u", &nb);
    for (compteur=0; compteur++<nb;)
    	{ scanf("%e", &sai);
    	  if (sai==-1) goto fin;
    		else som+=sai;
    	}
    printf(" moyenne : %e\n", som/nb);
  }
  fin:
  printf (" Au revoir \n");
  return 0;
}
