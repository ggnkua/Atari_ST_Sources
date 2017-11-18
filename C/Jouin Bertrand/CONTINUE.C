/* calcul de moyenne avec  plusieurs nombres */
#include <stdio.h>

/* prototypage */
int main(void);
float saisie(int);

/* fonction de saisie */
float saisie(int a)
{ int compteur;
  float som, sai;
  som=0;
  sai=0;
  for (compteur=1;   compteur<=a;
       compteur++)
        { printf(" Nombre : ");
          scanf ("%e", &sai);
          if (sai==0) continue;
          printf("addition du nombre saisi\n");
          som=som+sai;
        }
  printf("\n");
  return som;
}

/* fonction principal */
int main(void)
{ int nb=0;
  float som;
  printf(" Programme de calcul de moyenne \n");
  do
  { printf(" Combien de nombres pour le calcul de la moyenne (0 pour quitter) ? ");
    scanf("%u", &nb);
    if (nb!=0) { som=saisie(nb);
                 printf(" moyenne : %e\n", som/nb);
               }
  }
  while (nb!=0);
  printf (" Au revoir \n");
  return 0;
}
