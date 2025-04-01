/* Kursteil 1, Aufgabe 2 */

#include <stdio.h>

main(){
	int multiplikand,multiplikator,produkt;

	printf( "\nEin kleines Multiplikationsprogramm\n" );

	printf( "\nEingabe Multiplikand: " );
	scanf( "%i",&multiplikand );
	printf( "\nEingabe Multiplikator: " );
	scanf( "%i",&multiplikator );
	
	produkt = multiplikand * multiplikator;
	printf( "\n%i multipliziert mit %i ergibt das Produkt %i"
				      		,multiplikand,multiplikator,produkt);
	getchar();
   return 0;
}/*main_ende*/


