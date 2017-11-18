/* exemple de macro */
/* par Golio Junior pour Falk'mag 4 */

#include <stdio.h>

/* et une maniŠre de d‚finir des constantes */
#define Valeur1 20
#define Valeur2 30

/* et une s‚rie de macro */
#define max(a,b) (a>b)?a:b
#define max2(a,b) ((a)>(b))?(a):(b)
#define max3(a,b,c) if ((a)>(b)) \
						{ c=a; \
						} \
						else \
						{ c=b; \
						}
#define multiplication(a,b) a*b
#define multiplication2(a,b) (a)*(b)

int affect(int a)
{ return a;
}

int main(void)
{ int a,b;
  printf(" Valeur de Valeur1 : %d\n", Valeur1);
  a=max(Valeur1, Valeur2);
  printf(" R‚sultat de max(Valeur1, Valeur2) : %d\n", a);
  a=Valeur1;
  b=Valeur2;
  printf(" R‚sultat de max2(a++, b++) : %d\n", max(++a,++b));
  /* attention cette partie ne donne pas le r‚sultat escompt‚ */
  a=Valeur1;
  b=Valeur2;
  printf(" R‚sultat de multiplication(a+10, b) : %d\n", multiplication(a+10, b));
  /* essai de l'autres forme de multiplication */
  printf(" R‚sultat de multiplication2(a+10, b) : %d\n", multiplication2(a+10, b));
  max3(Valeur1, Valeur2, a);
  printf(" R‚sultat de max3(Valeur1, Valeur2, a) : %d\n",a);
  return 0;
}