/* Kursteil 1, Aufgabe 5 */

#include <stdio.h>

main(){
	char vorname[30], nachname[30];            
	char wohnort[30],strasse[30];
	char plz[5],telnr[20];         /*mÅssen als char angemeldet werden weil*/ 
	                               /*die vorstehende Null sonst nicht aus- */
	                               /*gegeben wird. Auûerdem wird ja auch   */
	                               /*nicht damit gerechnet.                */
	int  hausnr,groesse,gewicht;
	char augenfarbe[10],haarfarbe[10];
	
	printf( "Eingabe Vorname: ");
	scanf( "%s",vorname );        
	printf( "Eingabe Nachname: ");
	scanf( "%s",nachname );                 

	printf( "Eingabe Wohnort: ");
	scanf( "%s",wohnort );
	printf( "Eingabe Postleitzahl: ");
	scanf( "%s",plz );
	
	printf( "Eingabe Straûe (als zusammenhÑngendes Wort): ");
	scanf( "%s",strasse );
	printf( "Eingabe Hausnummer: ");
	scanf( "%i",&hausnr );                 /*nicht das &-Zeichen vergessen */
	printf( "Eingabe Telefonnummer: ");
	scanf( "%s",telnr );

	printf( "Eingabe Grîûe in cm: ");
	scanf( "%i",&groesse );
	printf( "Eingabe Gewicht in Gramm: ");
	scanf( "%i",&gewicht );

	printf( "Eingabe Augenfarbe: ");
	scanf( "%s",augenfarbe );
	printf( "Eingabe Haarfarbe: ");
	scanf( "%s",haarfarbe );
	
	printf( "\nDu heiût %s %s" ,vorname,nachname );
	printf( "\nund wohnst in %s", wohnort );
	printf( "\nmit der Postleitzahl %s",plz );
	printf( "\nauf der %s", strasse );
	printf( "\nund der Hausnummer %i.", hausnr );
	printf( "\nDu bist unter %s zu erreichen,",telnr );
	printf( "\nbist %i cm groû und hast ein Gewicht von %i Gramm."
					,groesse,gewicht );	
	printf( "\nDeine Augenfarbe ist %s und Deine Haarfarbe %s."
					,augenfarbe,haarfarbe );

	getchar();
   return 0;
}/*main_ende*/


