/* Beispielprogramm 5 */
/* Von Frank Mathy fÅr die TOS 10/90 */
/* FÅr Turbo C 2.0 (mit BGI-Bibliothek */

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <graphics.h>				/* BGI-Bibliothek	*/

int treiber=DETECT;					/* Treibertyp	*/
int modus;
int maxx,maxy;							/* Maximale Koordinaten	*/
int maxc;										/* Grîûte Zeichenfarbe */

void init_all(void)					/* Initialisierungen */
	{
	initgraph(&treiber,&modus,"");	/* BGI Init	*/
	graphdefaults();					/* Normaleinstellungen */
	maxx=getmaxx();						/* Maximale X-Koordinate */
	maxy=getmaxy();						/* Maximale Y-Koordinate */
	}

void exit_all(void)					/* Beenden des Programmes*/
	{
	setallpalette(getdefaultpalette());
														/* Alte Farbpalette */
	closegraph();							/* BGI-Arbeiten beenden	*/
	}

void main(void)
	{
	int i,y=0;								/* Hilfsvariablen	*/
	init_all();								/* Alles initialisieren	*/

	settextjustify(CENTER_TEXT,TOP_TEXT);	
														/* Textpositionierg.*/
	for(i=DEFAULT_FONT; i<=GOTHIC_FONT; i++)
		{
		settextstyle(i,HORIZ_DIR,2);	/* Textaussehen	*/
		outtextxy(maxx/2,y,"Textprobe");	/* Textausgabe */
		y+=textheight("Textprobe")+10;	/* Neue Textzeile	*/
		}
	settextstyle(SANS_SERIF_FONT,VERT_DIR,1);	
														/* Einstellung.*/
	setusercharsize(3,2,3,2);		/* 1.5-fach	*/
	settextjustify(CENTER_TEXT,BOTTOM_TEXT);
														/* Justage */
	outtextxy(maxx/2,maxy-20,"1.5-fach");		
														/* Textausgabe */
	
	i=getch();								/* Tastendruck		*/
	exit_all();								/* Alles abmelden		*/
	}