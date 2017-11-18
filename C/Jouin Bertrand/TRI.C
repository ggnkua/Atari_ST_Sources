/* programme de tri d'un tableau de nombre */

#include <stdio.h>

/* prototypage */
void saisie(int, int []);
void tri(int, int[]);
void affiche(int, int[]);
void swap(int *, int *);
int main(void);

/* fonction de saisie */
void saisie(int a, int tableau[])
{ int compteur;
  for (compteur=0; compteur<a;)
  	{
       printf(" Entrer un nombre : ");
       scanf("%u", &tableau[compteur++]);
    }
  printf("\n");
}

/* fonction de tri */
void tri(int a, int tableau[])
{ int i,j;
  for (i=0; i<a; i++)
  	for (j=i; j<a; j++)
  		if (tableau[i]>tableau[j])
  				swap(tableau+i, tableau+j);
}

/* fonction d'affichage */
void affiche(int a, int tableau[])
{ int compteur;
  int *pointeur=tableau;
  for (compteur=0; compteur<a; compteur++)
  	printf(" Nbre : %u\n", *pointeur++);
}

/* fonction de swap */
void swap(int *a, int *b)
{ int temp;
  temp=*a;
  *a=*b;
  *b=temp;
}

int main(void)
{ int tab[10], nbre;
  printf(" Programme de tri\nnombre d'entier (1-10) :"); 
  scanf("%u", &nbre);
  saisie(nbre, tab);
  printf("tableau tri‚ :\n");
  tri(nbre, tab);
  affiche(nbre, tab);
  return 0;
}
