#include <stdio.h>
#include <string.h>
#include <stdlib.h>
char *strdup(char *s)
{
int len;
char *adr;
   if (s == 0)
      return(0);
   len = strlen(s);
   if ((adr = malloc(len+1)) == 0)
      return(0);
   strcpy(adr,s);
   return(adr);
}
