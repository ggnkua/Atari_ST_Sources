/* exemple de manipulation de char */
#include <stdio.h>

/* prototypage */
int main(void);

/* Proc‚dure principal */
int main(void)
{
  char a;
  int b;
  printf(" un caractŠre SVP : ");
  scanf("%c", &a);
  b=(int)a;
  printf("valeur ASCII du caractŠre frapp‚ : %u\n",b);
  printf("caractŠre frapp‚ : %c\n",b);
  printf(" Return S.V.P \n");
  scanf("%u", &a);
  return(0);
}
