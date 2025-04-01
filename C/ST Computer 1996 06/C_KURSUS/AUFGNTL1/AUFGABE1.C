/* Listing 1 */

#include <stdio.h>

main(){
	int minuend,subtrahend,differenz;

	printf( "\nEin kleines Subtaktionsprogramm\n" );

	printf( "\nEingabe Minuend: " );
	scanf( "%i",&minuend );
	printf( "\nEingabe Subtrahend: " );
	scanf( "%i",&subtrahend );
	
	differenz = minuend - subtrahend;

	printf( "\n%i subtrahiert mit %i ergibt die Differenz %i."
	                             ,minuend,subtrahend,differenz);
	getchar();
   return 0;
}/*main_ende*/


