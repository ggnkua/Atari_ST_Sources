/* exemple d'utilisation des unions */
/* par Golio Junior pour Falk'mag 4 */

#include <stdio.h>

typedef union entier_flottant
	{ char caractere[2];
	  int entier;
	  long entier_long;
	  float flottant;
	} ENTIER_FLOTTANT;

int main(void)
{ ENTIER_FLOTTANT et, une, _union;
  et.caractere[0]='A';
  et.caractere[1]='B';
  printf(" Taille de l'union : %d\n", sizeof(et));
  printf(" Valeur sous forme entiere de et : %d\n", et.entier);
  une.entier_long=0;
  une.flottant=1.2563E-12;
  printf(" Valeur sous forme entier long de une : %ld\n", une.entier_long);
  _union.entier_long=(long)et.entier+une.entier_long;
  printf(" Valeur sous forme entier long de _union : %ld\n", _union.entier_long);
  return 0;
}