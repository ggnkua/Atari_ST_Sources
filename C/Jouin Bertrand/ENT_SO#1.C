/* exemple d'entrÇe buffÇrisÇe
   Pour falk'mag 5 par Golio Junior
*/

#include <stdio.h>

int main (void)
{ int s=0, n, c;
  printf(" Calcul de somme d'entier, entrer des entiers, terminer par ^Z\n");
  while (scanf("%d", &n)!=EOF)
  	{ s+=n;
  	}
  printf("somme : %d\n",s);
  printf("lecture au clavier des caractäres, et affichage des caractäres\n");
  printf("utilisation de getchar et putchar\n");
  while((c=getchar())!=EOF)
  	{ putchar(c);
  	}
  printf("lecture au clavier des caractäres, et affichage des caractäres\n");
  printf("utilisation de getc et putc\n");
  while((c=getc(stdin))!=EOF)
  	{ putc(c,stdout);
  	}
  return 0;
}
