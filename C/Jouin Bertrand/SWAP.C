/* echange de deux nombres */
#include <stdio.h>

/* prototypage */
void swap(int *, int *);
int main(void);

/* fonction de swap */
void swap(int *a, int *b)
{ int temp;
  temp=*a;
  *a=*b;
  *b=temp;
}

/* fonction principal */
int main(void)
{ int a=10, b=5;
  printf(" Programme d'echange de variable\n");
  printf(" a contient : %u, b contient %u\n",a,b);
  swap(&a,&b);
  printf(" a contient : %u, b contient %u\n",a,b);
  return 0;
}