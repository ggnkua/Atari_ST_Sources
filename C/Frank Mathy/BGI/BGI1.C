/*	Beispielprogramm 1 								*/
/*	Von Frank Mathy fÅr die TOS 10/90					*/
/*	FÅr Turbo C 2.0 (mit BGI-Bibliothek				*/

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <graphics.h>				/* BGI-Bibliothek		*/

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
	int i;
	int x,y;
	int x1,x2,y1,y2;
	srand(0);						/* Zufallsgenerator an	*/
	init_all();					/* Alles initialisieren	*/
	setbkcolor(WHITE);				/* Hintergrund weiû		*/
	
	while(!kbhit())				/* Solange keine Taste	*/
		{
		x1=rand()%maxx; x2=x1+maxx/2;	/* X-Koordinaten		*/
		y1=rand()%maxy; y2=y1+maxy/2;	/* Y-Koordinaten		*/
		if(x2>maxx) x2=maxx;		/* Bei zu hohen Koord.	*/
		if(y2>maxy) y2=maxy;
		setviewport(x1,y1,x2,y2,1);	/* Fenster einschalten	*/
		clearviewport();			/* Fenster lîchen		*/
		
		for(i=0; i<1000; i++)
			putpixel(rand()%maxx,rand()%maxy,1);
								/* Bildpunkte zeichnen	*/
		}
	getch();
	setbkcolor(BLACK);				/* Hintergrund schwarz	*/
	getch();
	setviewport(0,0,maxx,maxy,0);		/* Kein Fenster		*/
	exit_all();					/* Arbeit beenden		*/
	}
