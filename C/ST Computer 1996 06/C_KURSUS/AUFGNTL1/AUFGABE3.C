/* Kursteil 1, Aufgabe 3 */

#include <stdio.h>

main(){
	int dividend,divisor,quotient;

	printf( "\nEin kleines Divisionsprogramm\n" );
	
	printf( "\nEingabe Dividend: " );
	scanf( "%i",&dividend );
	printf( "\nEingabe Divisor: " );
	scanf( "%i",&divisor );
	
	quotient = dividend / divisor;
	
	printf( "\n%i dividiert durch %i ergibt den Quotienten %i"
						,dividend,divisor,quotient );
	getchar();
   return 0;
}/*main_ende*/


