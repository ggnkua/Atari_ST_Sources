/* exemple de manipulation de chaine de caractŠre */
#include <stdio.h>

/* prototypage */
int main(void);

/* Proc‚dure principal */
int main(void)
{
  char chaine[10];
  printf(" une chaine de caractŠre SVP : ");
  scanf("%s", chaine);
  printf("chaine frapp‚e : %s\n",chaine);
  printf(" Return S.V.P \n");
  scanf("%s", chaine);
  return(0);
}
