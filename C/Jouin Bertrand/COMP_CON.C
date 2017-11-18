/* exemple de compilation conditionnelle */
/* par Golio junior pour Falk'mag 4 */

#include <stdio.h>

#ifndef macro_definie
#define macro_definie
#endif

#define magique 12345

int main()
{ int a;
#if magique==12345
  a=1;
#else
  a=0;
#endif
  printf(" Valeur de a : %d\n",a);

#ifdef macro_definie
  printf(" macro_definie est definie\n");
#endif

#undef macro_definie

#ifdef macro_definie
  printf(" la, il y a une erreur dans votre pr‚processeur !\n");
#else
  printf(" macro_definie n'est plus definie\n");
#endif

  return 0;
}
