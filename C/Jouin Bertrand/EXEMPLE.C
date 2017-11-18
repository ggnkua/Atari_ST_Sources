/* exemple stupide d'utilisation des instructions conditionelles */
#include <stdio.h>

/* prototypage */
int main(void);

int main(void)
{ int a;
  printf(" Entrez une valeur de a : ");
  scanf("%u", &a);
  printf(" test de if\n");
  if ((a>10)&&(a<15)) printf("a est sup‚rieur … 10 et inf‚rieur … 15\n");
                 else printf("a n'est pas dans l'encadrement\n");
  printf(" test du switch\n");
  switch (a)
   {
    case 18 : printf("a vaut 18\n");
    case 2  : printf("a vaut 2\n");
    default : printf("a vaut toujours quelquechose \n");
   }
  printf(" test du switch am‚lior‚\n");
  switch (a)
   {
    case 18 : { printf("a vaut 18\n");
                break; }
    case 2  : { printf("a vaut 2\n");
                break; }
    default : { printf("a vaut toujours quelquechose \n");
                break; }
   }
  printf(" Return S.V.P ");
  scanf("%u", &a);
  return(0);  /* tout c'est bien pass‚ */
}
