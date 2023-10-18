/* 
#########################################################################
# PLAYDEMO.C
# Code: R.A.P. fuer TOS MAGAZIN
#########################################################################

Dieses Programm zeigt die Verwendung des Players mit LASER C.
Obwohl die Codelaenge von PLAYER nur etwa 1.5 kB betraegt,
ist das Object-File etwa 20kB lang! Das kommt daher, weil
PLAYER sich viele Tabellen im Codesegment anlegt. Allerdings
sind diese Tabellen alle mit '0' initialisiert. Da ich
sowieso jedes meiner Programme mit dem PFXPACK Programmpacker
packe, machen eine beliebige Anzahl von 0-Bytes das *.PRG
nicht laenger! 

# PFXPACK befindet sich auf der Diskette des TURBOASS.
# Beides sind Shareware-Programme! Sie finden den TURBOASS
# in jeder guten Public-Domain Sammlung!

Dieses Modul muss zusammen mit PLAYER.O gelinkt werden!

*/

#include <stdio.h>
#include <osbind.h>

/* Externe Funktionen (Ohne Underscore!) */
extern init_sam(), play_off(), volume();
extern char** play_sam();

#define SAMLEN		28600L		/* Laenge der Samples */
#define SAMANZ		7			/* 7 Samples vorhanden */
#define VERANZ		16			/* Anzahl der Versionen */


long frames;	/* ####TRACE#### */



/* Informationen zu den Samples: */
long samples;					/* Hierher laden LONG zum Rechnen */
								/* start[]: Adr. relativ zu 'samples' */
long start[SAMANZ]={0,1340,1340,3316,7572,13004,14854};
								/* len[]: Laenge des Samples */
long len[SAMANZ]={1338,1968,300,4206,5430,1800,13698};

struct {						
	unsigned key;				/* Dieser Taste entspricht der Sample */
	int sam_nr;				
	int timer;
	char *name;
} ver_liste[VERANZ]={			/* Tabelle der Samples, 1. Byte: Taste */
	0x2c,0,32,"Y: BASSDRUM HIGH" ,
	0x2d,0,48,"X: BASSDRUM NORMAL" ,
	0x2e,0,64,"C: BASSDRUM LOW" ,

	0x1E,1,32,"A: HIGHHATS OPEN" ,
	0x1F,1,48,"S: HIGHHATS OPEN V2" ,

	0x20,2,32,"D: HIGHHATS CLOSED" ,
	0x21,2,48,"F: HIGHHATS CLOSED V2" ,

	0x17,3,32,"I: LONG SNARE HIGH" ,
	0x18,3,48,"O: LONG SNARE NORMAL" ,
	0x19,3,64,"P: LONG SNARE LOW" ,

	0x30,4,96,"B: GLASS BRICHT LOW" ,
	0x31,4,48,"N: GLASS BRICHT NORMAL" ,

	0x32,5,48,"M: SNARE NORMAL", 

	0x24,6,32,"J: YEAH NORMAL",
	0x25,6,48,"K: YEAH LOW",
	0x26,6,80,"L: YEAH SUBSONIC"

	};

/* Daten laden, Speicher vom TOS */
load_samples(){
	int fd;

	if((samples=Malloc(SAMLEN)) == 0L) error("Speicher voll");
	if((fd=Fopen("SAMPLES.PAT",0))<0) error("Wo ist SAMPLES.PAT");
	if(Fread(fd,SAMLEN,samples)!=SAMLEN) error("SAMPLES.PAT defekt");
	Fclose(fd);
}

/* Behandlung von Fehlern */
error(s)
char *s;{
	printf("*** Fehler: '%s' -> Ende! ***\n",s);
	Cnecin();
	exit(-1);
}

/* Bildschirm aufbauen */
bild(){
	int i;
	long cpu;

	printf("\033E*** TOS MAGAZIN DRUMMER! CODE: R.A.P. 1991 ***\n");
	printf("ENDE -> 'Esc'\n\n");
	printf("---------------------------Sampleliste:----------------------------\n");
	for(i=0;i<VERANZ;i++){
		cpu=2021/(long)ver_liste[i].timer+1;
		printf("Nr.%02d: %-26s Rechenzeitverbrauch: %ld%c \n",i,ver_liste[i].name,cpu,'%');
	}
	printf("\nNum +: Normal Laut, Num -: Halbe Lautstaerke\n\n");
}
/*** Hier geht es los... ***/
main(){
	unsigned scan;					/* Scancode Tastatur */
	int index,i,li,pos=0,zeich='*';

	init_sam();						/* PLAYER initialisieren */
	load_samples();					/* Samples laden */
	bild();							/* Bildschirm zeichnen */
	do{
		while(!Bconstat(2)){		/* kleine Spielerei die anzeigt */
			Bconout(2,zeich);		/* dass SOUND im Interrupt laeuft */
			if(pos++>74){
				pos=0;
				Bconout(2,'\r');	/* Auf Zeilenanfang... */
				zeich^='*'^'O';		/* Wechseln von '*' und 'O' */
			}			
		}
		scan=(Bconin(2)>>16);			/* Scancode holen */
		if(scan==0x4E){
			volume(1024);				/* + Normale Lautstaerke */
		}
		else if(scan==0x4A){
			volume(512);				/* - Halbe Lautstaerke */
		}else{
			index=-1;					/* -1: nicht gefunden */
			for(i=0;i<VERANZ;i++)		/* suchen... */
				if(ver_liste[i].key==scan) index=i;
			if(index>=0){
				li=ver_liste[index].sam_nr;
				/* Den Sample spielen */
				play_sam(samples+start[li],len[li],ver_liste[index].timer);
			}
		}
	}while(scan!=1);				/* Ende: Escape   */
	play_off();						/* Zur Sicherheit */
}
