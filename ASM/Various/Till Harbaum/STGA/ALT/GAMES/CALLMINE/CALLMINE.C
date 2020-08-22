/*

	Demo zur MINESWEEPER-Interprozess-Kommunikation
	
	(auf den speziellen Wunsch eines Users hat Minesweeper
	eine Solver-Schnittstelle, die ich hiermit dokumentiere,
	vielleicht hat ja noch jemand Lust, sich an dieser nicht
	ganz einfachen Aufgabe zu versuchen, ich harre der Dinge 
	die da kommen werden ...)

	(c) 1993 by Till Harbaum
	
*/

#define ZU 			0
#define MARKIERT 	1
#define OFFEN 		2

#include <stdio.h>
#include <aes.h>

int appl_id,mines_id;

int main()
{
  int  msg[16];
  char string[100];

  appl_id = appl_init( );	/* beim AES anmelden */

  /* Nach Accessory suchen */
  if((mines_id=appl_find("MINSWEEP"))>=0)
  {
  	 msg[0]=42;			/* Anfrage 				*/
  	 msg[1]=appl_id;	/* eigene Nummer 		*/
  	 msg[2]=0;			/* keine weiteren Daten */
	 appl_write(mines_id,16,msg);
	 evnt_mesag(msg);	/* auf Antwort warten 	*/

	 /* die Antwort beinhaltet: 				*/
	 /* msg[3]: Breite des Spielfeldes 			*/
	 /* msg[4]: H”he des Spielfeldes   			*/
	 /* msg[5]: Anzahl Bomben 					*/
	 /* msg[6]: Window-ID (<=0 Window ist zu) 	*/
	 /* msg[7]: Menu-ID zum ™ffnen (s.u.)		*/
	 /* msg[8]: Spiel im Gange oder zuende		*/
	 sprintf(string,"[1][ Minesweeper meldet: | X:%d Y:%d B:%d W:%d L:%d ][ OK ]",msg[3],msg[4],msg[5],msg[6],msg[8]);
	 form_alert(1,string);

	 /* Minesweeper-Spielfeld ”ffnen, wenn nicht schon offen */
	 if(msg[6]<=0)
	 {
       msg[0]=AC_OPEN;
       msg[1]=appl_id;
       msg[2]=0;
	   msg[4]=msg[7];
       appl_write(mines_id,16,msg);
       evnt_timer(2000,0);		/* Ne Sekunde zum Bildaufbau geben */
	 }
	 
	 /* ggf. Feld 0,0 offen?? */
	 msg[0]=43;	 		/* Feldanfrage 			*/
  	 msg[1]=appl_id;	/* eigene Nummer 		*/
  	 msg[2]=2;			/* zwei weitere Daten 	*/
  	 msg[3]=0;
  	 msg[4]=0;			/* Feld 0,0				*/
	 appl_write(mines_id,16,msg);
	 evnt_mesag(msg);	/* auf Antwort warten 	*/
	 
	 /* Liefert in msg[3]: 0-ZU 1-MARKIERT 2-OFFEN */
	 /* und, falls OFFEN in msg[4] die Anzahl Bomben */
	 /* in dee N„he !!!!! */
	 if(msg[3]==ZU)
	 {
	   msg[0]=44;	 		/* ™ffnen 				*/
  	   msg[1]=appl_id;		/* eigene Nummer 		*/
  	   msg[2]=2;			/* zwei weitere Daten 	*/
  	   msg[3]=0;
  	   msg[4]=0;			/* Feld 0,0				*/
	   appl_write(mines_id,16,msg);

	   form_alert(1,"[1][ Das Feld 0,0 ist | jetzt offen ][ OK ]");

	   msg[0]=43;	 		/* Feldanfrage 			*/
  	   msg[1]=appl_id;		/* eigene Nummer 		*/
  	   msg[2]=2;			/* zwei weitere Daten 	*/
  	   msg[3]=0;
  	   msg[4]=0;			/* Feld 0,0				*/
	   appl_write(mines_id,16,msg);
	   evnt_mesag(msg);		/* auf Antwort warten 	*/
	   if(msg[3]==OFFEN)	/* Feld offen?			*/
	   {
	     sprintf(string,"[1][ Anzahl Bomben in | der Umgebung: %d ][ Aha ]",msg[4]);
	     form_alert(1,string);
	   } 
	 }
	 else
	   form_alert(1,"[1][ Das Feld 0,0 war | schon offen ][ OK ]");

	 /* Feld markieren */
	 msg[0]=45;	 			/* markieren 			*/
  	 msg[1]=appl_id;		/* eigene Nummer 		*/
  	 msg[2]=2;				/* zwei weitere Daten 	*/
  	 msg[3]=5;
  	 msg[4]=5;				/* Feld 5,5				*/
	 appl_write(mines_id,16,msg);
	 form_alert(1,"[1][ Das Feld 5,5 ist | jetzt markiert ][ OK ]");

	 /* Testen, ob Spiel noch l„uft 						*/
	 msg[0]=46;	 					/* ™ffnen 				*/
  	 msg[1]=appl_id;				/* eigene Nummer 		*/
  	 msg[2]=0;						/* zwei weitere Daten 	*/
	 appl_write(mines_id,16,msg);
	 evnt_mesag(msg);				/* auf Antwort warten 	*/
	 /* msg[3] bedeutet: 0 Spiel lief noch nie 				*/
	 /*		             1 Spiel l„uft                      */
	 /*                  2 Spiel wurde verloren             */
	 /*                  3 Spiel wurde gewonnen             */
	 if(msg[3]==1)
	 	form_alert(1,"[1][ Das Spiel | l„uft noch! ][ OK ]");

	 /* 10 Sekunden Minesweeper laufen lassen */
     evnt_timer(5000,0);
  }
  else
    form_alert(1,"[1][ Kein Minesweeper da! ][ OK ]");

  return(0);
}