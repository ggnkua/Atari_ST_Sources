/* Kursteil 1, Beispielprogramm 1 */

/* Eingabe und Ausgabe von Zeichenketten */

#include <stdio.h>

main(){
	char name[30];                          /* Zeichenkette mit 30 Zeichen */
	int alter;            
	
	printf( "Ein kleines Frageprogramm\n\n" );
	
	printf( "\nWie ist Dein Vorname ?    " );
	scanf( "%s" ,name );                    /* s = string, name hat kein & */
	
	printf( "\nWie alt bist Du ? " );
	scanf( "%i" ,&alter );
	
	printf( "\nDu heižt also %s und bist schon %i Jahre alt." ,name,alter );
	getchar();
   return 0;
}/*main_ende*/
