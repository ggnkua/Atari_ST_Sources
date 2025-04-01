/* Kursteil 1, Aufgabe 6 */

#include <stdio.h>

main(){
	char name[30],datum[10],autotyp[30];            
	int strecke, verbrauch, tank, preis, zu_zahlen;
	
	printf( "Eingabe Vorname: ");
	scanf( "%s",name );          
	printf( "Eingabe heutiges Datum: ");
	scanf( "%s",datum );
	printf( "Eingabe Autotyp: ");
	scanf( "%s",autotyp );

	printf( "Eingabe gefahrene Strecke in km: ");
	scanf( "%i",&strecke );
	printf( "Eingabe Literverbrauch auf 100 km: ");
	scanf( "%i",&verbrauch );
	printf( "Eingabe Preis pro Liter in Pfennigen: ");
	scanf( "%i",&preis );                      /* in DM rechnen wir sp„ter */

	tank = strecke * verbrauch / 100;
	zu_zahlen = tank * preis;
	
	printf( "\n\n\nHallo %s !\n",name );
	printf( "\nDu bist heute, am %s, mit Deinem %s", datum,autotyp );
	printf( "\n%i km gefahren.",strecke );
	printf( "\nDa Dein %s %i Liter auf 100 km verbraucht,"
	                                  ,autotyp,verbrauch );
	printf( "\nhast Du ganze %i Liter verfahren.", tank );
	printf( "\nDer Preis pro Liter ist %i Pfennig.", preis );
	printf( "\nDie Fahrt hat Dir also %i Pfennige gekostet.", zu_zahlen );	

	getchar();
   return 0;
}/*main_ende*/


