/*
	METRONOM-PROGRAMM
	
	Gibt den eingegebenen Metronom-Takt Åber den Monitor-
	Lautsprecher aus.
	
	
	Vorgabemîglichkeiten fÅr das Tempo:
	1. als Metronomzahl (in beats per minute)
	2. als x Takte in y Minuten
	3. Åber die ST-Tastatur
	
  
  	(cl) by Wolfgang "amadeus" Schmidt
  		ST VISION
  		Postfach 1651
  		
  		6070 Langen
  	
  	(cl) copyleft i.S. der Free Software Foundation, Cambridge/MA/USA
  	= Jedem ist erlaubt eine Kopie der Software (incl. Quellcode)
  	  zu erwerben, mir dem Recht, weitere Kopien zu verteilen und
  	  die eigene Kopie (mit Quellen-Hinweis) zu modifizieren; er
  	  darf niemandem dieses Recht verweigern.
*/


#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>
 

#define  CLS 		printf("\033E")	  	/* Bildschirm lîschen; Home */
#define  CURS_VIS	printf("\033e")		/* Cursor sichtbar machen */
#define  CURS_INVIS printf("\033f")		/* Cursor unsichtbar machen */
#define  C_INVERS   printf("\033p")		/* Inverse Darstellung */
#define  C_NORMAL	printf("\033q")		/* Normale Darstellung */
#define  CLS_END    printf("\033J")	    /* Lôschen bis Screen-Ende */
#define  C_POSSET(a,b)   printf("\033Y%c%c", (a)+32, (b)+32)


void tp_info(void);
int get_bpm(void);
int get_tempo(void);
long systime (void);
void gi_tick(long wait);
void metronom(int bpm); 


int ton1[16] = {56,2,0,0,0,0,0,0, 56,2,0,0,0,0,0,0};        /* Stimme 1 */
int ton2[16] = {123,1,0,0,0,0,0,0, 123,1,0,0,0,0,0,0};
int ton3[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};
int i=0;
char ta[10];     /* Zeichenkette fÅr die Taktart (4/4, 3/4, 6/8,..) */



int main()
{
int bpm = 0, ea = 0;

  
 	do
 	{
 	 
 		CLS;					/* Clear Screen */
 		C_INVERS;
 		printf("*** Das ATARI-Metronom ***");
 		printf(" V. 1.00         von amadeus / ST VISION / 07.1990 ***\n\n\n");
		C_NORMAL;

		printf("  1 = Tempoeingabe in Metronomzahlen (beats per minute)\n");
		printf("  2 = Tempoeingabe in x Takten/ y Sekunden\n");
		printf("  3 = Tempovorgabe Åber die ST-Tastatur\n");
	 	printf("  0 = Ende\n");
		
		CURS_VIS;
		printf ("\n  Eingabeart: ");
		scanf("%d", &ea);
		
		C_POSSET(4,1);
		CLS_END;
		
		 
		if (ea>0)
		{
			
	 		switch(ea)
	 		{
	 		case 1:
 				tp_info();
 				printf("\nGewÅnschtes Tempo  [0=Ende]: ");
 				scanf("%d", &bpm);
 				break;
	 		
 			case 2:
				bpm = get_bpm();
				tp_info();
 				printf("\nGewÅnschtes Tempo = %d\n", bpm);
 			    break;
 			
 			case 3:
 				bpm = get_tempo();
 				break;
 			
 			default:
 				bpm = 0;
 			}
 			
 			CURS_INVIS;
 			if (bpm>0)
 			{
 				printf("\n\nMetronom stoppen mit einem Tastendruck.\n");
 		
 		  		metronom(bpm);
 			}
 		}
 	}	
    while (bpm>0 && ea>0);
    


	CURS_INVIS;
	return(0);
}


/* Holt sich als Eingaben Taktart und Anzahl der Takte pro y Sekunden */
/* und rechnet diese in bpm um.										  */

int get_bpm(void)
{
int i_zaehler, i_nenner, xtakte, ysek = 0, bpm=0;
char *t_nenner, *t_zaehler, *py;

			do
			{
				printf("\nTaktschlagart (2/4, 6/8,...): ");
				scanf("%s", ta);
				strcat(ta, "/");
				
				t_zaehler = strtok(ta, "/, ");
				if (t_zaehler)
				{					 
					t_nenner = strtok(NULL, "/, ");
				}
			} while ((t_nenner == NULL || t_zaehler == NULL) && !Cconis());
				
			i_zaehler = atoi(t_zaehler);
			i_nenner  = atoi(t_nenner);
			
			do
			{
				printf("\nx Takte in y Sekunden: x,y= ");
				scanf("%s", ta);
				strcat(ta, ",");
				xtakte = atoi(strtok(ta, ", "));
				py = strtok(NULL, ", ");
				if (py != NULL)  ysek = atoi(py);
			} while (ysek == 0);
			
			if (ysek>0)
			{
				bpm = i_zaehler*xtakte*60/ysek;
				C_POSSET(4,0);
				CLS_END;
				printf("Takt = %d/%d\n", i_zaehler, i_nenner);
				printf("%d Takte in %d Sekunden\n", xtakte, ysek);
			}
			
			return(bpm);
			
}
		
		
void tp_info()
{
		printf("\nMetronomzahlen und Tempobezeichungen:\n\n");
	 	printf(" 40 ~  60 = largo (breit, langsam)\n");
 		printf(" 60 ~  66 = larghetto (etwas breit)\n");
 		printf(" 66 ~  76 = adagio (langsam, ruhevoll)\n");
 		printf(" 76 ~ 108 = andante (ruhig, gehend)\n");
 		printf("108 ~ 120 = moderato (mÑûig bewegt)\n");
 		printf("120 ~ 168 = allegro (heiter, lebhaft, schnell)\n");
	 	printf("168 ~ 208 = presto (schnell)\n");
 		printf("208 ~     = prestissimo (Ñuûerst schnell)\n");
}


/* get_tempo()												*/
/* ermitteln des Tempos durch Schlagen des Taktes auf der   */
/* ST-Tastatur.                                             */
 
int get_tempo(void)
{
long t1=0, t2=0, t3=0, tsys, talt, tmittel;
long key;


	printf("\nBitte Tempo Åber die ST-Tastatur vorgeben.\n");
	printf("SPACE = Tempoangabe  /  RETURN = Ende der Vorgabe\n");
	
	tsys = systime();
	
	do
	{	
		talt = tsys;
		key = Cnecin();
		
		if ((key&255) != 13)
		{ 
			tsys = systime();
			if (t1 == 0L)
			{
				t1 = tsys-talt; t2 = t1;  t3 = t1;
			}
			else
			{
				t1 = t2;  t2 = t3;  t3 = tsys - talt;
			}
			tmittel = 60L*3L*200L/(t1+t2+t3);
			C_POSSET(10,3);
			printf("Mittleres Tempo = %ld  ", tmittel);
		}
	} while ((key&255) != 13);
	
	return ((int)tmittel);
}



/* gi_tick()												*/
/* erzeugt einen kurzen "Tick" mit dem Rauschgenerator des  */
/* GI-Soundchips											*/
/* long wait := Warteschleife in 1/200s fÅr die einzelnen Ticks */

void gi_tick(long wait)
{
long st;
 
	Giaccess( 247, 7+128);    /* Rausch-Kanal 1 einschalten */
	
	Giaccess( 16, 8+128);   	/* LautstÑrke */
	
	Giaccess( 25, 6+128);   		/* Lowbyte des Oszis */
	Giaccess( 9, 13+128);  		/* HÅllkurve 1 */
	
	Giaccess( 0, 11+128);  		/* HÅllkurve low */
	Giaccess( 3, 12+128);  	    /* HÅllkurve high */
	
	st = systime();
	while (systime()-st < wait); /* Zeitschleife (in 1/200 s) */
		
	Giaccess( 0, 8+128);  		/* LautstÑrke auf Null */
	Giaccess( 255, 7+128);      /* alle KanÑle off */

}


/* metronom()												*/
/* gibt pro Beat einen Tick Åber den Rauschgenerator des	*/
/* GI-Soundchips aus										*/
/* int bpm := beats per minute								*/

void metronom(int bpm)
{
long wait = 0L;

	if (bpm > 0L) 
		{
		wait = (long)200*60/bpm;
		while (!Cconis())				/* warte auf Tastendruck */
			gi_tick(wait);
			
		Cnecin();						/* Keyboard-Puffer sÑubern */
		}
}


/*-----------------------------------------------------------------*/
long systime ()                            /* Timer-Wert ermitteln */
{
   long l, *p, stack;
  p = (long*)0x4baL;            /* Pointer auf 200 Hz System Timer */   
   stack = gemdos (0x20, 0L);   /* Supervisor Modus einschalten    */                  
   l = *p;                      /* Timer-Wert kopieren             */        
   gemdos (0x20, stack);        /* User Modus einschalten          */                      
   return   (l);                /* Timer-Wert zurÅckgeben          */                     
}
