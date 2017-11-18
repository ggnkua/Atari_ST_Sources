/* Fichier principal
   contient la fonction main
   
   Par Golio Junior pour Falk'mag 5
*/

#include <stdio.h>		/* inclusion des prototypes de printf et scanf */

#include "biblio.h"		/* inclusion des prototypes de som et mul */

float sous(float a, float b)
{ return a-b;
}

int main(void)
{ int choix, fin=0;
  float a, b;
  while(fin==0)
  	{ printf (" Micro calculette\n ________________\n 1 : Addition\n 2 : Soustraction\n 3 : Multiplication\n 10 : Fin\n Votre choix : ");
	  scanf("%d",&choix);
	  switch (choix)
	  	{ case 1:
	  		printf(" 1er nombre : ");
	  		scanf("%f",&a);
	  		printf(" 2nd nombre : ");
	  		scanf("%f",&b);
	  		printf("RÇsultat : %f\n", som(a,b));
	  		break;
	  	  case 2:
	  		printf(" 1er nombre : ");
	  		scanf("%f",&a);
	  		printf(" 2nd nombre : ");
	  		scanf("%f",&b);
	  		printf("RÇsultat : %f\n", sous(a,b));
	  		break;
	  	  case 3:
	  		printf(" 1er nombre : ");
	  		scanf("%f",&mul_op1);
	  		printf(" 2nd nombre : ");
	  		scanf("%f",&mul_op2);
	  		mul();
	  		printf("RÇsultat : %f\n", resul_mul);
	  	  	break;
	  	  case 10:
	  	    fin=1;
	  	  	break;
	  	}
	  printf(" %diäme utilisation\n",compteur());
	}
  return 0;
}
