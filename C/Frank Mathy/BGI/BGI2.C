/*	Beispielprogramm 2 								*/
/*	Von Frank Mathy fÅr die TOS 10/90					*/
/*	FÅr Turbo C 2.0 (mit BGI-Bibliothek				*/

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <graphics.h>				/* BGI-Bibliothek		*/

#define XRAND rand()%maxx			/* ZufÑllige Koordinaten	*/
#define YRAND rand()%maxy
#define RRAND rand()%100
#define WRAND rand()%360				/* ZufÑllige Winkel		*/

int treiber=DETECT;					/* Treibertyp			*/
int modus;						/* Grafikmodus			*/
int maxx,maxy;						/* Maximale Koordinaten	*/
int maxc;							/* Grîûte Zeichenfarbe	*/

void init_all(void)					/* Initialisierungen	*/
	{
	initgraph(&treiber,&modus,"");	/* BGI initialisieren	*/
	graphdefaults();				/* Normaleinstellungen	*/
	maxx=getmaxx();				/* Maximale X-Koordinate	*/
	maxy=getmaxy();				/* Maximale Y-Koordinate	*/
	maxc=getmaxcolor();				/* Maximale Farbe		*/
	cleardevice();					/* Bildschirm lîschen	*/
	}

void exit_all(void)					/* Beenden des Programmes*/
	{
	setallpalette(getdefaultpalette());/* Alte Farbpalette		*/
	closegraph();					/* BGI-Arbeiten beenden	*/
	}

void main(void)
	{
	int e[8];
	srand(0);						/* Zufallsgenerator an	*/
	init_all();					/* Alles initialisieren	*/
	setpalette(0,WHITE);			/* Weiûer Hintergrund	*/
	
	e[0]=e[6]=10;	e[1]=e[7]=10;		/* Punkt 1			*/
	e[2]=maxx-20; 	e[3]=maxy/2;		/* Punkt 2			*/
	e[4]=maxx/2;	e[5]=maxy-10;		/* Punkt 3			*/
	drawpoly(4,e);					/* Dreieck zeichnen		*/
	
	setwritemode(XOR_PUT);			/* Exclusiv-Oder		*/
	while(!kbhit())				/* Solange keine Taste	*/
		{
		setcolor(rand()%maxc);		/* ZufÑllige Farbe		*/
		setlinestyle(rand()%5,rand(),NORM_WIDTH);
		
		switch(rand()%6)			/* ZufÑllige Operation	*/
			{
			case 0:	line(XRAND,YRAND,XRAND,YRAND);
					break;		/* ZufÑllige Gerade		*/
			case 1:	rectangle(XRAND,YRAND,XRAND,YRAND);
					break;		/* ZufÑlliger Rahmen	*/
			case 2:	circle(XRAND,YRAND,RRAND);
					break;		/* ZufÑlliger Kreis		*/
			case 3:	arc(XRAND,YRAND,WRAND,WRAND,RRAND);
					break;
			case 4:	ellipse(XRAND,YRAND,WRAND,WRAND,RRAND,RRAND);
					break;		/* ZufÑllige Ellipse	*/
			case 5:	cleardevice();
					break;
			}
		}


	exit_all();					/* Arbeit beenden		*/
	}
