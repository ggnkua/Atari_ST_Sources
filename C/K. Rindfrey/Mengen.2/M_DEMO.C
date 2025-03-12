/*----------------------------------------------------------------*/
/* 										Demo zur Mengen-Bibliothek       						*/
/*																																*//* 									 		 Autor:  K. Rindfrey  										*//* 									(c) 1992 Maxon Computer GmbH									*/
/*----------------------------------------------------------------*/

#include  <stdio.h>
#include  <string.h>
#include	<tos.h>
#include "m_typ.h"
#include "m_ext.h"

void prsc(bs) /* print set of char. */
 register *bs;
{
   register unsigned i, m;

   m = bs_maxcard(bs);
   printf("{ ");
   for(i = 0; i < m; i++)
      if(bs_iselem(i, bs)) printf("%c ", i);
   printf("}\n");
}

int main()
{
   BitSetDefType *setofchar;   /* Mengentyp fuer char. */
   BitSetType *bs1, *bs2, *bs3;
   char i;

	 void prsc(register *bs);
	
	
   setofchar = bs_newsettype(0,255); /* Typ definieren. */
   bs1 = bs_createset(setofchar);   /* 3 Mengen dieses */
   bs2 = bs_createset(setofchar);   /* Typs erzeugen.  */
   bs3 = bs_createset(setofchar);

   for(i = 'a'; i <= 'p'; i++)
      bs_incl(i, bs1);        /* bs1 = {'a', ... , 'p'} */
   for(i = 'k'; i <= 'y'; i++)
      bs_incl(i, bs2);        /* bs2 = {'k', ... , 'y'} */
   printf("bs1 = "); prsc(bs1);
   printf("bs2 = "); prsc(bs2);

   bs_union(bs1, bs2, bs3);
   printf("bs1 vereinigt mit bs2 = ");prsc(bs3);

   bs_inters(bs1, bs2, bs3);
   printf("bs1 geschnitten mit bs2 = bs3 = ");prsc(bs3);

   printf("Ist dies (bs3) Teilmenge von bs1 ?  ");
   if(bs_issubset(bs3, bs1)) printf("Ja\n");
   else printf("Nein\n");

   printf("bs3 hat %d Elemente\n", bs_card(bs3));

   bs_diff(bs1, bs2, bs3);
   printf("bs1 - bs2 = "); prsc(bs3);

   printf("Weiter mit bel. Taste...\n");
   gemdos(0x01);
   return(0);
}

