/*		  		3D-Grafikdemo 1 				*/
/*			(C) 1990 Frank Mathy, TOS			*/

#include <math.h>
#include <ext.h>
#include <graphics.h>
#define KANTEN 6

/* Allgemeine Daten												*/

int treiber=DETECT;						/* Treibertyp			*/
int modus;								/* Grafikmodus			*/
int maxx,maxy;							/* Maximale Koordinaten	*/
int xcenter,ycenter;					/* Bildmittelpunkt		*/
double xscale,yscale;					/* Skalierungsfaktoren	*/
double auge = -450;						/* Augenposition		*/

enum achsen { XACHSE,YACHSE,ZACHSE };	/* Rotationsachsen		*/
enum { X0=0,Y0=1,Z0=2,X1=3,Y1=4,Z1=5 };	/* Indizes im k[]-Feld	*/

/* Dreidimensionale Daten										*/

double k[KANTEN][6] = { { -40,-20,-10, 30,-30,-20 },/* 1 nach 2	*/
					{ -40,-20,-10, 0,-20,20		},	/* 1 nach 3 */
					{ -40,-20,-10, 0,20,0		},	/* 1 nach 4	*/
					{ 30,-30,-20, 0,-20,20		},	/* 2 nach 3	*/
					{ 30,-30,-20, 0,20,0		},	/* 2 nach 4 */
					{ 0,-20,20, 0,20,0			}};	/* 3 nach 4 */

double xpos=0,ypos=0,zpos=0;			/* Position des Objekts	*/

void init_all(void)					/* Initialisierungen	*/
	{
	initgraph(&treiber,&modus,"");	/* BGI initialisieren	*/
	graphdefaults();				/* Normaleinstellungen	*/
	maxx=getmaxx();				/* Maximale X-Koordinate	*/
	maxy=getmaxy();				/* Maximale Y-Koordinate	*/
	xcenter=maxx/2;					/* Bildmittelpunkt		*/
	ycenter=maxy/2;
	xscale=maxx/160;
	yscale=maxy/100;
	setviewport(0,0,maxx,maxy,1);	/* Zeichenfenster		*/
	}

void exit_all(void)					/* Beenden des Programmes*/
	{
	setallpalette(getdefaultpalette());/* Alte Farbpalette		*/
	closegraph();					/* BGI-Arbeiten beenden	*/
	}

/* Rotieren der Kanten um g Grad								*/

void rotate(enum achsen richtung, double grad)
	{
	double rad,sinus,cosinus,merkx,merky,merkz;
	int i;
	rad=grad/180.0*M_PI;				/* In Bogenmaž			*/
	sinus=sin(rad);						/* Sinuswert			*/
	cosinus=cos(rad);					/* Cosinuswert			*/
	switch(richtung)
		{
		case XACHSE:	for(i=0; i<KANTEN; i++)
							{
							merky=k[i][Y0];	/* Werte merken...	*/
							merkz=k[i][Z0];	/* und neuberechnen	*/
							k[i][Y0]=cosinus*merky - sinus*merkz;
							k[i][Z0]=sinus*merky + cosinus*merkz;
							merky=k[i][Y1];	/* Werte merken...	*/
							merkz=k[i][Z1];	/* und neuberechnen	*/
							k[i][Y1]=cosinus*merky - sinus*merkz;
							k[i][Z1]=sinus*merky + cosinus*merkz;
							}
						break;
		case YACHSE:	for(i=0; i<KANTEN; i++)
							{
							merkx=k[i][X0];	/* Werte merken...	*/
							merkz=k[i][Z0];	/* und neuberechnen	*/
							k[i][X0]=cosinus*merkx - sinus*merkz;
							k[i][Z0]=sinus*merkx + cosinus*merkz;
							merkx=k[i][X1];	/* Werte merken...	*/
							merkz=k[i][Z1];	/* und neuberechnen	*/
							k[i][X1]=cosinus*merkx - sinus*merkz;
							k[i][Z1]=sinus*merkx + cosinus*merkz;
							}
						break;
		case ZACHSE:	for(i=0; i<KANTEN; i++)
							{
							merkx=k[i][X0];	/* Werte merken...	*/
							merky=k[i][Y0];	/* und neuberechnen	*/
							k[i][X0]=cosinus*merkx - sinus*merky;
							k[i][Y0]=sinus*merkx + cosinus*merky;
							merkx=k[i][X1];	/* Werte merken...	*/
							merky=k[i][Y1];	/* und neuberechnen	*/
							k[i][X1]=cosinus*merkx - sinus*merky;
							k[i][Y1]=sinus*merkx + cosinus*merky;
							}
						break;
		}
	}


/* Projektion der Koordinaten von 3D --> 2D						*/
void projection(double x,double y,double z,int *px,int *py)
	{
	double distance;
	distance = z+zpos - (double) auge;	/* Abstand des Punktes	*/
	*px=xcenter + (int) (((double)-auge*x/distance)+xpos)*xscale;
	*py=ycenter - (int) (((double)-auge*y/distance)+ypos)*yscale;
									/* Koordinaten umrechnen	*/
	}

/* Darstellung der Grafik										*/
void draw_all(void)
	{
	int i,x0,y0,x1,y1;
	cleardevice();						/* Bildschirm l”schen	*/
	for(i=0; i<KANTEN; i++)				/* Alle Kanten			*/
		{
		projection(k[i][0],k[i][1],k[i][2],&x0,&y0);
		projection(k[i][3],k[i][4],k[i][5],&x1,&y1);
		line(x0,y0,x1,y1);				/* Kante darstellen		*/
		}
	}

/* Hauptschleifen des Programmes								*/
void main(void)
	{
	char z;
	init_all();						/* BGI initialisieren		*/

	do	{
		draw_all();					/* Grafik darstellen		*/
		z=(char) getch();			/* Tasteneingabe			*/
		switch(z)
			{
			case 'x':	rotate(XACHSE,10);	/* Rotieren		*/
						break;
			case 'X':	rotate(XACHSE,-10);
						break;
			case 'y':	rotate(YACHSE,10);		/* Rotieren		*/
						break;
			case 'Y':	rotate(YACHSE,-10);
						break;
			case 'z':	rotate(ZACHSE,10);
						break;
			case 'Z':	rotate(ZACHSE,-10);
						break;
			case 'a':	if(auge<-25) auge+=10;	/* Augposition	*/
						break;
			case 'A':	if(auge>-500) auge-=10;
						break;
			case '4':	xpos-=5;				/* Verschieben	*/
						break;
			case '6':	xpos+=5;
						break;
			case '2':	ypos-=5;
						break;
			case '8':	ypos+=5;
						break;
			case '+':	zpos-=5;
						break;
			case '-':	zpos+=5;
						break;
			}
		} while((z!='q') &&(z!='Q'));
	exit_all();								/* BGI abmelden	*/
	}
