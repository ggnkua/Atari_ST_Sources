/* exemple de'utilisation de la boucle do-while */
#include <stdio.h>

/* prototypage */
int main(void);

/* Proc‚dure principal */
int main(void)
{
  int a;
  printf(" un chiffre SVP et pas un nombre : \n");
  do {
  printf("Nbre : ");
  scanf("%d", &a);
  } while ((a<0)||(a>9));
  return(0);
}
