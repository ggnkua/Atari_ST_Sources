/* Kursteil 1, Beispielprogramm 4 */

/* Ein kleines Additionsprogramm */

#include <stdio.h>

main(){
	int summand1,summand2,summe;  /* Definition Variablen des Typs Integer */           
	summand1 = 22;                /* FÅllen einer Variablen mit einer Zahl */
	summand2 =  4;
	
	summe = summand1 + summand2;                      /* Rechnung: 22+4=26 */
	
	printf( "%i plus %i ergibt %i\n" ,summand1,summand2,summe );
	                /* %i gibt einen Integerwert in einer Zeichenkette aus */  
	getchar();
   return 0;
}/*main_ende*/
