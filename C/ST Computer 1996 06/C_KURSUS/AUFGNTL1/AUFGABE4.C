/* Kursteil 1, Aufgabe 4 */

#include <stdio.h>

main(){
	int multiplikand,multiplikator1,multiplikator2,produkt;

	printf( "\nEin zweites kleines Multiplikationsprogramm\n" );

	printf( "\nEingabe Multiplikand: " );
	scanf( "%i",&multiplikand );
	printf( "\nEingabe erster Multiplikator: " );
	scanf( "%i",&multiplikator1 );
	printf( "\nEingabe zweiter Multiplikator: " );
	scanf( "%i",&multiplikator2 );

	produkt = multiplikand * multiplikator1 * multiplikator2;

	printf( "\n%i multipliziert mit %i und %i ergibt das Produkt %i"
						,multiplikand,multiplikator1,multiplikator2,produkt);
	getchar();
   return 0;
}/*main_ende*/


