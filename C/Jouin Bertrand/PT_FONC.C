/* exemple de pointeur sur une fonction */
/* Par Golio Junior */

#include <stdio.h>

int fonction_pointe(int a, int b)
{ return a+b;
}

int main(void)
{ int (*fonction)(int a, int b);
  int resul=11;
  fonction=fonction_pointe;
  resul=fonction(10, resul);
  printf(" resultat : %d",resul);

  return 0;
}
