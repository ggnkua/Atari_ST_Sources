/*****************************************************************
**																**
**		Autor: Albertus Grunwald								**
**																**
**		Entwickelt mit Turbo C (9.3.1990)						**
**																**
*****************************************************************/

#include <tos.h>
#include <math.h>
#include <stdio.h>

#define PIXX	 640  /* bei anderer Auflîsung */
#define PIXY	 400  /* entsprechend anpassen */
#define BACK	   1
#define PAINT	   1

#define PARM  200.0e9	   /* Meter    */
#define DT	 86400.0*500   /* Sekunden */
#define SCHR   0.0e9	   /* Schwarzschildradius */

typedef struct
{	double x,
		   y;
}vector;

struct Koerper
{	double Masse;
	vector Ort,
		   Gesch;

}Planet,Komet,
/*			Masse	   Ort_X	 Ort_Y	  Gesch_X	Gesch_Y  */
  Sonne ={ 50.0e23,{	 0.0,	   0.0},{	  0.0,		0.0}},
  Planet={	5.0e23,{ 110.0e9,	   0.0},{	  0.0,	  -55.0}},
  Komet ={	1.0e23,{ 160.9e9,  760.0e9},{	  0.0,	  -50.0}};

vector	Beschl;  /* Beschleunigung ist Kraft ohne Eigenmasse */
vector	Loeschen= {0.0, 0.0};

double G = 6.672e-11;
double Wirkzeit= DT;

int *Scr;

void get_besch( struct Koerper *von, struct Koerper *auf);
void make_aenderung( struct Koerper *aend);
void paint( int x, int y );
void draw_circle( int x, int y, int r, int f);
void cls( void);


void main(void)
{	int i;

	Setcolor(0,0);	   /* Farben invertieren */
	Setcolor(1,0x777);

	Cconout(27);	   /* Bildschirm lîschen */
	Cconout('E');

	Scr=Physbase();    /* Setzen des Bildschirmpointers
												fÅr 'paint' */
	for(i=1;i<7;i++)   /* Sonne malen */
		draw_circle(PIXX/2, PIXY/2, i, PAINT);

	draw_circle(PIXX/2, PIXY/2, PIXY/2-1, PAINT);
										/* Orientierungskreis */

	while((i=(int)Kbshift(-1))==0)
	 {
		Beschl= Loeschen;	/* alte Beschleunigung lîschen */
		get_besch(&Planet,&Komet);	/* énderung des Kometen */
		get_besch(&Sonne,&Komet);
		make_aenderung(&Komet);
		paint((int)(Komet.Ort.x/PARM * PIXX/2) + PIXX/2,  /* x */
			  (int)(Komet.Ort.y/PARM * PIXX/2) + PIXY/2); /* y */

		Beschl= Loeschen;	/* alte Beschleunigung lîschen */
		get_besch(&Sonne,&Planet);	/* énderung des Planeten */
		get_besch(&Komet,&Planet);
		make_aenderung(&Planet);
		paint((int)(Planet.Ort.x/PARM * PIXX/2) + PIXX/2,  /* x */
			  (int)(Planet.Ort.y/PARM * PIXX/2) + PIXY/2); /* y */
 
	 }
	if((i&0x4)!=0)	/* Bei <CONTROL> wird das Bild gespeichert */
	 {	int fd;
		fd= Fcreate("PLANET.PIC",1);	 
		Fwrite(fd,32000L,Physbase());
		Fclose(fd);
	 }
	Setcolor(0,0x777); /*  Farben zurÅcksetzen */
	Setcolor(1,0);
}

/******************  Beschleunigung bestimmen  *******************
*
*  Berechnung der Kraft von Kîrper 'von' auf Kîrper 'auf' und
*  aufaddieren.
*
*/

void get_besch( struct Koerper *von, struct Koerper *auf )
{	double kraft,x,y,abstand;

	x= von->Ort.x - auf->Ort.x; 			  /* delta_x */
	y= von->Ort.y - auf->Ort.y; 			  /* delta_y */
	abstand= sqrt( pow(x,2.0)+pow(y,2.0));	  /* Abstand */

	abstand-= SCHR;  /* Subtraktion des Schwarzschildradius */

	kraft= G * von->Masse / pow( abstand, 3.0);

	Beschl.x += kraft * x;	/* Aufaddieren der KrÑfte  */
	Beschl.y += kraft * y;	/*	 ( ohne Eigenmasse)    */

}

/*********************	énderungen vornehmen  ********************
*
*	Berechnung der Wirkung in Ort und Geschwindigkeit
*	auf den Kîrper 'aend'.
*/

void make_aenderung( struct Koerper *aend)
{
	aend->Gesch.x+= Beschl.x * Wirkzeit;
	aend->Gesch.y+= Beschl.y * Wirkzeit;

	aend->Ort.x+= aend->Gesch.x * Wirkzeit;
	aend->Ort.y+= aend->Gesch.y * Wirkzeit;
}

/**********************  Kreis zeichnen  *************************
*
*	Zeichnen eines Kreises um das Pixel (x,y) mit Radius r
*	und Farbe f nach dem Satz von Pythagoras.
*	Es wird nur ein Achtelkreis berechnet. Der Vollkreis
*	entsteht durch Spiegeln.
*/

void draw_circle(int x, int y, int r, int f)
{
	register int i,j;

	if (f)
		for (i=0; i<=(r+1)*0.75; i++)
		{
			j=sqrt((double) r*r - i*i);
			paint(x+i,y+j);
			paint(x+i,y-j);
			paint(x-i,y+j);
			paint(x-i,y-j);
			paint(x+j,y+i);
			paint(x+j,y-i);
			paint(x-j,y+i);
			paint(x-j,y-i);
		}
}

/*************************	Pixel setzen  ************************
*
*	Setzen eines Pixel mit den Koordinaten (x,y). Damit nicht
*	wild in den Speicher geschrieben wird, testet das Programm
*	die Koordinaten (Clipping). Anschlieûend wird das Word und
*	das zu setzende Pixel berechnet.
*/

void paint( int x, int y)
{	x = x>PIXX-2 || x<1 ?0:x;  /* Clipping */
	y = y>PIXY-2 || y<1 ?0:y;

	if(x>0 && y>0)
		Scr[y*40+x/16] |= (int) (1<<(15 - x & 0xF));
	 /* 	  ^Word^  odern mit einer um ^ verschobenen 1	  */
}

/****************************************************************/
/****************************************************************/
/*

   ! Ab hier wird nicht mehr compiliert !

*****************  Daten Komet stîrt Planet **********************

#define PARM  200.0e9	   /* Meter    */
#define DT	 86400.0*500   /* Sekunden */
#define SCHR   0.0e9	   /* Schwarzschildradius */

  Sonne ={ 50.0e23,{	 0.0,	   0.0},{	  0.0,		0.0}},
  Planet={	5.0e23,{ 110.0e9,	   0.0},{	  0.0,	  -55.0}},
  Komet ={	1.0e23,{ 160.9e9,  760.0e9},{	  0.0,	  -50.0}};

*******************  Daten Merkur  *******************************

#define PARM   80.0e9	   /* Meter    */
#define DT	 86400.0/10    /* Sekunden */
#define SCHR   1.0e9	   /* Schwarzschildradius */

  Sonne ={ 1.99e30,{	 0.0,	   0.0},{	  0.0,		0.0}},
  Planet={	3.2e23,{  50.0e9,	   0.0},{	  0.0,	-30.0e3}},
  Komet ={	1.0e00,{ 1.0e100,	   0.0},{	  0.0,		0.0}};


	 ! Ab hier wird wieder compiliert ! */

/***************************  ENDE	*****************************/
