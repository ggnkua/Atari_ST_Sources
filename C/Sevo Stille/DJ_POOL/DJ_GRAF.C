/*----------------------------------------------------------------------*/
/*				dj_grafprint()				*/
/*	   einigermaen universelle Hardcopyfunktion fr HP DeskJet	*/
/*				in Turbo C 2.0				*/
/*			Copyright Sevo Stille 9.12.1990			*/
/*----------------------------------------------------------------------*/
/*									*/
/*	Die Funktion ist auf Lesbarkeit und leichte šbersetzbarkeit	*/ 
/*	in andere Sprachen hin geschrieben, wer will, kann noch viele	*/
/*	Optimierungen durchfhren. Da sie gleich im ersten Anlauf 	*/
/*	fehlerfrei lief, habe ich sie nicht allzu grndlich auf ver-	*/
/*	steckte Fehler untersucht. 					*/
/*									*/ 
/*	Wer Fehler findet, sollte sie mir bitte melden:			*/
/*	Sevo Stille, T”plitzstrasse 7, 6000 Frankfurt 70		*/
/*									*/	
/*	Ich werde diese Funktion noch portabel fr alle C-Compiler 	*/
/*	machen und um Ausschnitte und Kompression erweitern.		*/
/*									*/
/*	Das Bild darf nur ein Bitplane haben, mu in einem zusammen-	*/
/*	h„ngenden Speicherbereich stehen und mu in der Breite auf	*/ 
/*	Bytes aufgehen. In dieser Version k”nnen deshalb Ausschnitte 	*/
/*	nur gedruckt werden, indem man sie vorher diesen Regeln ent-	*/
/*	sprechend in einen Puffer kopiert oder die Routine fr jede  	*/
/*	Zeile einzeln aufruft.						*/
/*									*/
/*----------------------------------------------------------------------*/
/*									*/
/*	Diese Routine soll der Anfang einer PD-Sammlung mit DeskJet	*/
/*	Druckroutinen fr alle wichtigen Sprachen sein.			*/
/*	Sie darf uneingeschr„nkt verwendet und modifiziert werden.	*/
/*	Allerdings sind alle aus ihr entwickelten Druckroutinen 	*/
/*	weiterhin PD und sollten mir zur Ver”ffentlichung zugesandt 	*/
/*	werden. Wer davon unabh„ngig DeskJet-Routinen geschrieben hat,	*/
/*	ist natrlich auch eingeladen, sich am DeskJet-Pool zu be-	*/
/*	teiligen. Damit wrde die Untersttzung des DeskJet/LaserJet	*/
/*	auch durch solche Programmierer, die keinen Zugang zu einem	*/
/*	entsprechenden Drucker haben, wesentlich erleichtert.		*/
/*	Dringend gebraucht werden besonders noch Routinen fr GFA-  	*/
/*	und OMIKRON-BASIC, PASCAL und MODULA.				*/
/*									*/
/*----------------------------------------------------------------------*/ 
/*									*/
/*		Die Variablen und ihre Bedeutung:			*/
/*									*/
/*	->res 		(Druckaufl”sung in dpi [75,100,150,300])	*/
/*	->w   		(Breite des auszudruckenden Bildes in Bytes)	*/
/*	->h   		(H”he des auszudruckenden Bildes in Zeilen)	*/
/*	->imgbase	(Adresse des Bildpuffers)			*/
/*	<-		(0 bei Erfolg, -1 wenn kein Drucker 		*/
/*			angeschlossen, 1 wenn Bild zu gro ist)		*/
/*									*/
/*----------------------------------------------------------------------*/

#include <tos.h>
#include <stdlib.h>
#include <string.h>


/* Testprogramm auskommentiert!
Nur zur Demonstration der Druckfunktion eine kleines und nutzloses 
Testprogramm, das den aktuellen, freilich sehr leeren, Bildschirm druckt: 

#include "dj_graf.h"
int main (void)
{
return dj_grafprint(150,80,400,Physbase());
}
*/



int dj_grafprint(int res, int w, int h, char *imgbase)
{
/*	die Variablen	*/
int i;
int laenge;

char *startgraphics;		/* Pointer auf Initialisierungsstring	*/

char low[13]="\x1B*t75R\x1B*r0A";	/* Initialisierungsstrings fr die	*/
char mid1[13]="\x1B*t100R\x1B*r0A";	/* einzelnen Aufl”sungen		*/
char mid2[13]="\x1B*t150R\x1B*r0A";
char high[13]="\x1B*t300R\x1B*r0A";

char transfer[9]="\x1B*b";	/* Zeilenanfang-String, die folgenden 	
				   Bestandteile werden mit strcat dort
				   angeh„ngt:				*/
char linewidth[5];		/* Anzahl Bytes/Zeile im Stringformat	
				   wird mit itoa gefllt		*/ 
char endchr[]="W";		/* Abschluzeichen 			*/	

char endgraphics[]="\x1B*rB";	/* Ende der Grafikbertragung		*/

/* 	ab hier gehts richtig los	*/

	if (w>res) return 1;	/* Ein kleiner Trick: Da die maximale 
				   Druckbreite in DIN A4 genau 8" ist,	
				   kann man so einfach auf šberschreitung
				   des rechten Randes testen!*/

	if (!Cprnos()) return -1;	/* Das ntzt am DeskJet nicht viel,
					   also nur ein Test, ob gar kein 
					   Drucker angeschlossen ist!	*/ 			   
	itoa(w,linewidth,10);
	strcat(transfer,linewidth);
	strcat(transfer,endchr);
	laenge=strlen(transfer);
	
	switch(res)		/* fr jede Aufl”sung das passende Kommando	*/
	{
		case 300:startgraphics=high;break;
		case 150:startgraphics=mid2;break;
		case 100:startgraphics=mid1;break;
		case 75:startgraphics=low;break;
	}	
	
	Fwrite(3,12,startgraphics);	/* Fwrite auf Standard-Handle 3=PRN	*/		
	for (i=0;i<h;i++)		/* Zeile fr Zeile:	*/
	{
		Fwrite(3,laenge,transfer);	/* Der Zeilenanfangsbefehl	*/
		Fwrite(3,w,imgbase);		/* Die Grafikdaten der Zeile	*/
		imgbase+=w;		/* n„chste Zeile, w Bytes weiter im Buffer	*/
	}
	Fwrite(3,4,endgraphics);
	return 0;
}


