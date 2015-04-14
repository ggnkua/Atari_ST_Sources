/****************************************************************/
/*								*/
/* VECTOR - GUARDIAN						*/
/*								*/
/* Nach dem Programm WATCH VECTOR von GUIDO LEISTER 		*/
/* vom 19.03.88 mit LATTICE-C-3.04 fÅr C'T 7/88			*/
/*								*/
/* Erweiterte Version mit VBL-Routinen, Laufwerksabfrage sowie	*/
/* Codierung in MARK-WILLIAMS-C-2.1.7 von MARCUS UNTERBERG	*/
/* am 31.01.89 fÅr ST-MAGAZIN					*/
/*								*/
/****************************************************************/
/*								*/
/* Ein Programm zur periodischen öberwachung von fÅr die Ver-	*/
/* breitung von Virusprogrammen relevater System-Vektoren.	*/
/*								*/
/* Gemeldete énderungen kînnen Åbernommen werden, wenn eine	*/
/* énderung planmÑûig auftritt, wie es regelmÑûig mit Ram-Disks */
/* der Fall sein wird (aber auch eigene Treiber und Routinen).	*/
/*								*/
/* Sie kînnen auf die Ur-Werte zurÅckgesetzt werden. Tritt da-	*/
/* bei kein Systemabsturz auf, so sollte bei wiederholter Mel-  */
/* dung die Sitzung beendet und der Rechner abgeschaltet werden.*/
/* Ein Virus-Verdacht liegt dann nahe.				*/
/*								*/
/* öberwacht werden die HDV-Vektoren, die beim Einsatz einer	*/
/* Hard-Disk bestimmte Werte aufweisen, sofern keine eigenen	*/
/* Treiber verwendet werden. 					*/
/* Anmerkung: PrÅfung auf HDV erfolgt nur bei aktivem Laufwerk	*/
/* C, das auch eine Ram-Disk sein kann. Dann tritt unbedingt 	*/
/* eine Meldung auf, die mit EGAL zu beantworten ist.		*/
/*								*/
/* Ebenfalls Åberwacht werden die VBL-Vektoren. Kontrolliert	*/
/* werden die Anzahl der EintrÑge (normal 8) in die Routinen-	*/
/* Tabelle von TOS, sowie die Adresse dieser Tabelle.		*/
/*								*/
/* Auf die hier gezeigte Art und Weise kînnen noch weitaus mehr */
/* Vektoren und Register (!) Åberwacht werden - auf Kosten von	*/
/* Rechenzeit. Das DDR-Register (0xfffa05) ist dabei interessant*/
/*								*/
/*				Marcus Unterberg		*/
/*								*/
/****************************************************************/

#include	<aesbind.h>
#include	<osbind.h>
#include	<bios.h>


/* Vektoren fuer TOS auf ROM */
/*			06.02.86		22.04.87 */

#define	VEC_BPB		0xfc0de6L 	/*	0xfc0fca */
#define	VEC_RW		0xfc10d2L 	/*	0xfc12b6 */
#define	VEC_BOOT	0xfc137cL	/*	0xfc1560 */
#define	VEC_MEDIACH	0xfc0f96L	/*	0xfc117a */

#define	VEC_QUEUE	0x4ceL
#define	VEC_NUMVBL	0x8


/* Umstellung von peekl und pokel mittels casting
   zur Vermeidung von Fehlfunktion bei Einsatz im
   Supervisor-Modus */

#define	peekl(lp)	(*((long *)lp))
#define pokel(lp,l)	(*((long *)lp) = l)
#define	peekw(wp)	(*((int *)wp))
#define	pokew(wp,w)	(*((int *)wp) = w)


main()
{
	int dummy;
	
	long bpb 	= VEC_BPB;
	long rw  	= VEC_RW;
	long boot	= VEC_BOOT;
	long media	= VEC_MEDIACH;

	long queue	= VEC_QUEUE;
	int num		= VEC_NUMVBL;

	long drivemap;
	long drvmask = 4L; /* binÑr: (FFF) 0100 */

	long *txt1 = "[2][Vector-Guardian aktiv| |M. Unterberg 1989| ][ OK ]";
	long *txt2 = "[2][HDV-Vektor(en) verbogen|? Virus ?| ][ RöCK | EGAL ]";
	long *txt3 = "[2][VBL-Vektor(en) verbogen|? Virus ?| ][ RöCK | EGAL ]";

	appl_init(); /* Accessory-typische Applikations-Anmeldung */

	evnt_timer(10000,0); /* Warten auf "Systemberuhigung" */

	form_alert(1,txt1); /* AktivitÑtsmeldung */

	drivemap = Drvmap(); /* Angeschlossene Laufwerke */

	for(;;) { /* Accessory-typische Endlosschleife */

		evnt_timer(1000,0); /* Periodische Abfrage spart Zeit */

		/* Wenn Laufwerk C existiert */
		if(drvmask & drivemap) {

		/* Wenn énderungen aufgetreten sind */
		if((pel(0x472L) != bpb) || (pel(0x476L) != rw ) ||
		   (pel(0x47aL) != boot) || (pel(0x47eL) != media)) {

			dummy = form_alert(0,txt2);
			switch (dummy) {

				/* ZurÅcksetzen gewÅnscht */
				case 1 :
					pol(0x472L,bpb);
					pol(0x476L,rw);
					pol(0x47aL,boot);
					pol(0x47eL,media);
				break;

				/* öbernahme gewÅnscht, z.B. bei Ram-Disk */
				case 2 :
					bpb 	= pel(0x472L);
					rw	= pel(0x476L);
					boot	= pel(0x47aL);
					media	= pel(0x47eL);
				break;

			}/* switch */

		} /* if */
		} /* if */

		if((pew(0x454L) != num) || (pel(0x456L) != queue)) {

			dummy = form_alert(0,txt3);
			switch (dummy) {

				/* ZurÅcksetzen */
				case 1 :
					pow(0x454L,num);
					pol(0x456L,queue);
				break;

				/* öbernahme, z.B. bei eigenen VBL-Routinen */
				case 2 :
					num 	= pew(0x454L);
					queue 	= pel(0x456L);
				break;

			}/* switch */

		}/* if */

	}/* for */

}/* main */

/****************************************************************/
/*								*/
/* Nachfolgende Routinen sind erforderlich, weil die Abarbei-	*/
/* tung mehrerer peeks und pokes unter einem Super-Aufruf nicht	*/
/* fehlerfrei ablÑuft.						*/
/*								*/
/****************************************************************/

pel(vector)
long vector;
{
	long sp;
	long wert;

	sp = Super(0L);
	wert = peekl(vector);
	Super(sp);

	return(wert);
}


pol(vector,wert)
long vector, wert;
{
	long sp;

	sp = Super(0L);
	pokel(vector,wert);
	Super(sp);
}

pew(vector)
long vector;
{
	long sp;
	int wert;

	sp = Super(0L);
	wert = peekw(vector);
	Super(sp);

	return(wert);
}

pow(vector,wert)
long vector;
int wert;
{
	long sp;

	sp = Super(0L);
	pokew(vector,wert);
	Super(sp);
}
