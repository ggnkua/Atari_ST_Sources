/*	Beispielprogramm 3 */
/*	Von Frank Mathy fÅr die TOS 10/90	*/
/*	FÅr Turbo C 2.0 (mit BGI-Bibliothek	*/

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <graphics.h>				/* BGI-Bibliothek	*/

#define XRAND rand()%maxx		/* ZufÑllige Koordinaten */
#define YRAND rand()%maxy
#define RRAND rand()%100
#define WRAND rand()%360		/* ZufÑllige Winkel	*/

int treiber=DETECT;					/* Treibertyp	*/
int modus;									/* Grafikmodus */
int maxx,maxy;							/* Maximale Koordinaten	*/
int maxc;										/* Grîûte Zeichenfarbe	*/

unsigned char muster[8] = { 8,8,28,28,42,42,73,0 };

void init_all(void)					/* Initialisierungen	*/
	{
	initgraph(&treiber,&modus,""); /* BGI Init */
	graphdefaults();			/* Normaleinstellungen */
	maxx=getmaxx();				/* Maximale X-Koordinate */
	maxy=getmaxy();				/* Maximale Y-Koordinate */
	maxc=getmaxcolor();		/* Maximale Farbe	*/
	cleardevice();				/* Bildschirm lîschen	*/
	}

void exit_all(void)			/* Beenden des Programmes */
	{
	setallpalette(getdefaultpalette()); 
												/* Alte Farbpalette */
												
	closegraph();					/* BGI-Arbeiten beenden	*/
	}

void main(void)
	{
	int e[8];
	srand(0);							/* Zufallsgenerator an	*/
	init_all();						/* Alles initialisieren	*/
	setpalette(0,WHITE);	/* Weiûer Hintergrund	*/
	
	e[0]=e[6]=10;	e[1]=e[7]=10;		/* Punkt 1 */
	e[2]=maxx-20; 	e[3]=maxy/2;	/* Punkt 2 */
	e[4]=maxx/2;	e[5]=maxy-10;		/* Punkt 3 */
	setfillpattern((char*)muster,1);	 /* def. FÅllmuster */
	setfillstyle(USER_FILL,1); /* FÅllmuster verwenden */
	fillpoly(4,e);					   /* Dreieck fÅllen */
	setfillstyle(HATCH_FILL,1);		/* Schraffur */
	floodfill(1,1,1);				 	 /* Rest schraffieren	*/
	getch();

	while(!kbhit())				/* Solange keine Taste */
		{
		setcolor(rand()%maxc);		/* ZufÑllige Farbe */
		setlinestyle(rand()%5,rand(),NORM_WIDTH);
		setfillstyle(rand()%13,1);/* ZufÑlliges FÅllmuster */
		switch(rand()%5)			/* ZufÑllige Operation	*/
			{
			case 0:	bar(XRAND,YRAND,40,80);
					break;		/* ZufÑlliges Rechteck	*/
			case 1:	bar3d(XRAND,YRAND,40,80,10,1);
					break;		/* ZufÑlliges 3D-Rechteck */
			case 2:	fillellipse(XRAND,YRAND,RRAND,RRAND);
					break;		/* ZufÑlliger Kreis	*/
			case 3:	pieslice(XRAND,YRAND,WRAND,WRAND,RRAND);
					break;		/* TortenstÅck */
			case 4:	sector(XRAND,YRAND,WRAND,WRAND,RRAND
										,RRAND);
					break;		/* Ellipsensektor */
			}
		}


	exit_all();					/* Arbeit beenden */
	}
