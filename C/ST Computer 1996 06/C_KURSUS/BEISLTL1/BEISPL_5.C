/* Kursteil 1, Beispielprogramm 5 */

/* Additionsprogramm mit Eingabe */

#include <stdio.h>

main(){
	int summand1,summand2,summe;            
	
	printf( "Ein kleines Additionsprogramm\n\n" );
	
	printf( "\nEingabe erster Summand : " );
	scanf( "%i" ,&summand1 );                 /* & bezeichnet eine Adresse */
	
	printf( "\nEingabe zweiter Summand: " );
	scanf( "%i" ,&summand2 );
	
	summe = summand1 + summand2;                     
	
	printf( "\n%i plus %i ergibt: %i", summand1,summand2,summe );
	getchar();
   return 0;
}/*main_ende*/
