/*--------------------------------------------------------------------------\
|  FILE: Haelt_Es.C                                                         |
|---------------------------------------------------------------------------|
|  Gibt es ein Programm, das fÅr jede Eingabe entscheiden kann,             |
|  ob Haelt_Es jemals halten wird ?                                         |
\--------------------------------------------------------------------------*/


#include <stdio.h>


main ()
{  register int n;
   int Eingabe;

   printf("Zahl: ");
   scanf("%d",&Eingabe);
   getchar();
   n = Eingabe;

   while (n > 1) {
     printf("aktueller Stand: n = %d\n",n);
     if (n % 2)
          n = 3 * n + 1;
     else n /= 2;
   }

   printf("Haelt_Es hat bei Eingabe %d gehalten.\n",Eingabe);
   getchar();
}

