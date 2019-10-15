/******************************************************************
* DFHT_DMO.C
*
* Zusammenlinken mit DFHT.C, PLAYER.O (Sampleplayer, TOS 6/91)
*
* Diese Demo zeigt dier Verwendung der DFHT als Digitalfilter
*
* Autor: R.A.P. (C) Copyright 1991 by TOS MAGAZIN
* Compiler: LASER C
* 
******************************************************************/

#include <osbind.h>							/* TOS-Bindings */
#include <linea.h>							/* Zwecks Grafik */
#include <stdio.h>							/* u. a. lmalloc() */

/***** DFHT Definitionen *****/
extern error();								/* Wenn schon da... */
extern dfht();
extern float power();

extern int _verbose;						/* Kommentare? */

/***** PLAYER Definitionen (siehe TOS MAGAZIN 6/91) *****/
extern init_sam();
extern play_off();
extern play_sam();

#define LAENGE		8192L					/* Soviel Platz */
#define BITS		13   		 			/* Soviele Bits */
#define TOPBP		3600
#define BB			220
#define O_TIMER	64							/* Original-Tonhoehe */
#define BRUMM		450

#define uchar		unsigned char			/* Sample hat 8 Bit */

char fname[]={"YEAH_N.PAT"};				/* Filename */

uchar *o_bytes;								/* Original-Sample 8 Bit */
float *o_floats;							/* Original Sample (float) */
float *p_floats;							/* Power Spektrum (float) */

lineaport *la;								/* LINE A Variable */

/***** load(): Einladen des Samples *****/
load(){
	int fd;
	register long i;

	printf("8-Bit Sample laden: '%s'...\n",fname);	
	if((o_bytes=(uchar*)lmalloc(LAENGE))==NULL) error("load(): Speicher voll");
	if((fd=Fopen(fname,0))<0)error("Datei fehlt");
	for(i=0;i<LAENGE; o_bytes[i++]=127);		/* Alles loeschen! (Zero: 127)*/	
	if(Fread(fd,LAENGE,o_bytes)<0) error("Datei defekt"); 
	Fclose(fd);
}
/***** to_floats(): Sample nach float umrechnen *****/
to_floats(){
	register long i;

	puts("Sample in (float) umrechnen...");	
	for(i=0;i<LAENGE; i++) o_floats[i]=o_bytes[i]-127;	/* -128..127 */
}
/***** to_uchars(): Sample nach uchar umrechnen *****/
to_uchars(){
	register long i;
	register int v;

	puts("Sample in (uchar, 8-Bit Format) umrechnen...");	
	for(i=0;i<LAENGE; i++){
		v=o_floats[i]+127.5;				/* -128..127 */
		if(v<0) v=0; else if(v>255) v=255;	/* begrenzen */
		o_bytes[i]=v;
	}
}

/***** box(): Box zeichnen *****/
box(x1,y1,x2,y2)
int x1,y1,x2,y2;{
	a_line(x1,y1,x2,y1);
	a_line(x1,y1,x1,y2);	
	a_line(x2,y1,x2,y2);
	a_line(x1,y2,x2,y2);
}

/***** the_power(): Powerspektrum berechnen und zeichnen *****/
the_power(){
	register long i;
	float maxp;
	long zofa=LAENGE/1024L;					/* Zoomfaktor */
	int x,y,oy=150,ox=64;

	puts("Powerspektrum berechnen...");	
	if((p_floats=(float*)lmalloc((LAENGE/2) * sizeof(float)))==NULL) 
		error("the_power(): Speicher voll");

	if(!zofa) zofa=1;						/* Zoomfaktor: >=1 */
	maxp=power(o_floats,p_floats,BITS);		/* Maximum finden */
	puts("\033E********** Powerspektrum: **********");
	puts("Das Powerspektrum, Betr„ge der Amplituden der Frequenzen zum");
	printf("Quadrat, von 0 bis %ld Schwingungen:\n",LAENGE/2-1);
	box(62,48,577,152);
	for(i=0;i< (LAENGE/2); i++){
		x=i/zofa+64;						/* X-Koordinate */
		y=150.5-p_floats[i]/maxp*100.0;		/* Y-Koordinate (gerundet) */
		a_line(ox,oy,x,y);
		ox=x;
		oy=y;
	}

	x=BRUMM/zofa+64;
	box(x-1,154,x+1,164);					/* Stoerung markieren */
	x=TOPBP/zofa+64;
	box(x,154,575,164);						/* Rauschen markieren */
	printf("\033Y%c An den Marken befinden sich die Stoerungen!\n",32+11);
	
	printf("\033Y%c Der Sample selbst (%ld Abtastwerte):\n",32+14,LAENGE);
	box(62,248,577,352);
	oy=300;ox=64;	
	zofa=LAENGE/512L;						/* Zoomfaktor anpassen */
	for(i=0;i< LAENGE; i++){
		x=i/zofa+64;						/* X-Koordinate */
		y=350-(o_bytes[i]*100)/256;			/* Y-Koordinate */
		a_line(ox,oy,x,y);
		ox=x;
		oy=y;
	}
	printf("\033Y%c ",32+23);				/* Cursor position. */
}

/***** play(): Sample spielen, gegebenfalls nochmal *****/
play(str,sam,t,len)
long len;
uchar *sam;
char *str;
int t;{
	printf("Sample '%s' abspielen, Wiederholen: <SPACE>, Weiter: <RETURN>\n",str);
	while(Cconis()) Cnecin();				/* Tastenbuffer leeren */
	do{
		play_sam(sam,len,t); 			/* !!! LAENGE > 256 !!! */
	}while((Cnecin()&255)==' ');
	play_off();
}

/***** no_noise(): Rauschen + Peak entfernen *****/
no_noise(){
	register long i;

	puts("Hoehenrauschen und Peak entfernen...");
	for(i=TOPBP; i<LAENGE/2 ;i++){
		o_floats[i]=0;
		o_floats[LAENGE-i]=0;
	}
	o_floats[BRUMM]=0;			/* PEAK entfernen */
}


/***** main(): ### M A I N ###  *****/
main(){

	int fd;
	init_sam();								/* Sampleplayer initialisieren */

	la=a_init();
	la-> linemask=-1;						/* VOLL */
	la-> plane0=-1;							/* SCHWARZ */
	la-> writemode=0;						/* REPLACE */

	puts("\033E### TOS MAGAZIN: Diskrete Hartley Transformation by R.A.P. 1991 ####");
	puts("### Stellen Sie Ihren Lautsprecher auf volle Lautstaerke! ###\n");
	puts("Diese Demo zeigt die Verwendung der DFHT als Digitalfilter.");
	puts("Aus einem 8-Bit Sample wird eine Stoerfrequenz und Rauschen");
	puts("bei hoeheren Frequenzen entfernt:");
	puts("Mit der DFHT wird der Sample in seine Frequenzkomponenten");
	puts("zerlegt. Danach werden die Amplituden der unerwuenschten");
	puts("Frequenzkomponenten zu 0 gemacht und der Sample wieder zusammen-");
	puts("gesetzt. Die DFHT benoetigt einige Zeit, da sie in Fliesskomma-");
	puts("arithmetik arbeitet.\n");

	_verbose=1;								/* dfht(): Blabla... ON */

	if((o_floats=(float*)lmalloc(LAENGE * sizeof(float)))==NULL) 
		error("to_floats(): Speicher voll");

	load();									/* 8-Bit Sample laden */

	to_floats();							/* Umwandeln nach Fliesskomma */
	puts("Sample transformieren (zerlegen)...");
	dfht(o_floats,BITS,0);					/* DFHT-Analyse */
	the_power();							/* Power Spektrum Zeichnen */
	
	play("Verrauschter Sample",o_bytes,O_TIMER,8192L);
	
	no_noise();
	puts("Sample transformieren (zusammensetzen)...");
	dfht(o_floats,BITS,1);					/* Ruecktransformation */
	to_uchars();
	to_floats();
	puts("Sample transformieren (neu analysieren)...");
	dfht(o_floats,BITS,0);					/* Hintransformation */
	the_power();
	play("Gefilterter Sample",o_bytes,O_TIMER,8192L);		/* Laut! */

	puts("Programm-Ende: <RETURN>");
	getchar();
}

