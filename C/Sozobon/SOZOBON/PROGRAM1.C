#include <stdio.h>
     
main()
{
  char sprog[10];
  int c, i;
  
  printf("\nHvilket sprog taler du?: ");
  i = 0;
  while ((c = getchar()) != '\n')
  {
    sprog[i++] = c;
  }
  sprog[i] = '\n';
  printf("Du taler alts† %s", sprog);
  getchar();
}
