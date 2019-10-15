/********************************************/
/*		TOS-Animation-Language-3D ("TAL")	*/
/*		(C) 1992 Frank Mathy, TOS			*/
/*		Version 2.2, April 1992				*/
/*		Hidden-Line, Schattierung			*/
/*		Depth-Buffer, Gouraud-Shading		*/
/*      Erweitertes Beleuchtungsmodell		*/
/********************************************/
/* VORSICHT: Alte Skriptdateien vor Version */
/* 2.1 nur nach Modifikation lauffÑhig !    */
/********************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ext.h>
#include <ctype.h>
#include <string.h>
#include <tos.h>
#include <linea.h>

/* Konstanten-Deklarationen */
#define TRUE 1
#define FALSE 0
#define ERROR (-1)
#define FILEEND (-2)
#define OBJECT 1
#define ENDOBJECT 2
#define TRIANGLE 3
#define RECTANGLE 4
#define ROTATE 5
#define BALL 6
#define PLACE 100
#define DRAW 101
#define GETKEY 102
#define CAMERA 103
#define COMMENT 104
#define CLEAR 105
#define SAVE 106

#define SHADING 200
#define GOURAUD 201
#define EXTENDED 202

/* Je nach Speichergrîûe kînnen die drei nachfolgenden Konstanten	*/
/* geÑndert werden, um beispielsweise Grafiken aus mehr als 1000	*/
/* Dreiecken darstellen zu kînnen...								*/
#define MAXOB 10						/* Maximale Objektdef.	*/
#define MAXPL 30						/* Maximale Objektdarst.*/
#define MAXTRI 1000						/* Maximale Dreieckszahl*/
#define MAXSTEP 20						/* R.-Schritte/-Kanten	*/

/* Weitere allgemeine Definitionen */
#define maxx 160L				/* Bildbreite in Bildpunkten	*/
#define maxx2 (2L*maxx)			/* Bildbreite in Pixel			*/
#define xcenter ((int)maxx/2)	/* Bildmitte x					*/
#define maxy 100L				/* Bildhîhe in Bildpunkten		*/
#define maxy2 (2L*maxy)			/* Bildhîhe in Pixel			*/
#define ycenter ((int)maxy/2)	/* Bildmitte y					*/
#define d_unendl 32767			/* Unendl. Abstand fÅr z-Buffer	*/

/* Allgemeine Daten												*/
int dzeile=1;						/* Dateizeile				*/
char picnr = 'A';					/* Bilddateikennung			*/
FILE *datei;						/* Dateivariable			*/

int *d_z; 							/* Zeiger auf Depth-Buffer	*/
int a_modus,a_farben[16]; 			/* Alte Bilschirmfarben 	*/
int muster=0xffff;					/* Line-A-FÅllmuster		*/

/* Dreidimensionale Daten										*/
double	kamx=0,kamy=0,kamz=0,			/* Kameraposition		*/
		kamwx=0,kamwy=0,kamwz=0,		/* Kameradrehung		*/
		lightx,lighty,lightz,lightlen,	/* Lichtrichtung		*/
		rdiff,rparr,rrefl,				/* Koeffizienten der    */
										/* drei Beleuchtg.-Mod. */
		nexp,							/* Exponentialfaktor Li.*/
		material[6],					/* Materialkurve		*/
	 	xscale=1,yscale=1,				/* Skalierungsfaktoren	*/
		auge = -500;					/* Augposition			*/		

/* Objekttyp fÅr komplexe Objekte */
struct	{
		int first,last;				/* Dreiecke von Objekt	*/
		} obs[MAXOB];

/* Verwendungen der Objekte in 3D-Welt */
struct	{
		int ob;						/* Objektnummer			*/
		float x,y,z;				/* Position				*/
		float rx,ry,rz;				/* Rotation				*/
		float scalex,scaley,scalez;	/* Skalierungsfaktoren	*/
		} place[MAXPL];

struct tri	{
			float x[3],y[3],z[3];	/* Koordinaten			*/
			} obtri[MAXTRI];

char gouraudan[MAXTRI];	/* Gouraudmodus jeder Dreiecksdef.	*/

struct tri2	{
			float x[3],y[3],z[3];	/* Koordinaten			*/
			float distance;			/* Mittlerer Abstand	*/
			unsigned shade;			/* Dreiecksfarbe		*/
			float c[3];				/* Eckenfarben			*/
			} drawtri[MAXTRI];

char gouraudan2[MAXTRI];

enum { M_SHADING,M_GOURAUD,M_EXTENDED } dispmode=M_SHADING;

int tricnt=0;						/* Definierte Dreiecke	*/
int disptri=0;						/* Darzustellende Dreie.*/
int dispcnt=0;						/* Darzustellende Obj.	*/

/* Bildschirm initialisieren */
void screen_init(void)
	{
	int i;
	a_modus=Getrez();		/* Alte Auflîsung merken 	*/
	if(a_modus < 2)
		{
		Setscreen((void *)-1L,(void *)-1L,0);/* Niedrige Auflîsung	*/
		for(i=0; i<16; i++)
			a_farben[i]=Setcolor(i,i<8 ? i*0x111 : 0x777);
		hide_mouse();
		}
	else	
		{
		puts("Bitte in niedriger/mittlerer Auflîsung starten...");
		exit(0);
		}
	}

/* Bildschirm zurÅcksetzen */
void screen_exit(void)
	{
	int i;
	show_mouse(1);
	Setscreen((void *)-1L,(void *)-1L,a_modus);
	for(i=0;i<16;i++) Setcolor(i,a_farben[i]);
	}

/* D-Buffer lîschen */
void d_clear(void)
	{
	register long x,y;
	for(y=0; y<maxy2; y++) for(x=0; x<maxx2; x++)
		d_z[x+maxx2*y] = d_unendl; /* Alle Werte auf unendl. */
	}

/* Bildschirm lîschen */

void screen_clear(void)
	{
	d_clear();						/* D-Buffer lîschen		*/
	set_fg_bp(0);					/* Hintergrundfarbe		*/
	set_wrt_mode(REPLACE);			/* REPLACE-Modus		*/
	set_pattern(&muster,0,0);		/* Komplett fÅllen		*/
	set_clip(0,0,0,0,0);			/* Kein Clipping		*/
	filled_rect(0,0,(int) maxx2-1,(int) maxy2-1);
									/* Rechteck zeichnen	*/
	}

/* D-Buffer initialisieren */
void d_init(void)
	{
	if((d_z=malloc(maxx2*maxy2*sizeof(int)))==NULL)
		{
		puts("Nicht genug Speicher fÅr Depth-Buffer...");
		exit(0);
		}
	}

/* D-Buffer freigeben */
void d_exit(void)
	{
	free(d_z);
	}


/* Alle Initialisierungen */
void init_all(void)					/* Initialisierungen	*/
	{
	screen_init();					/* Bildschirm setzen	*/
	linea_init();				/* Line-A-Initialisierung	*/
	d_init();				/* Depth-Buffer initialisieren	*/
	screen_clear();					/* Bildschirm lîschen	*/
	}

void exit_all(void)					/* Beenden des Programmes*/
	{
	d_exit();					/* Depth-Buffer entfernen	*/
	screen_exit();			/* Alte Bildschirmeinstellung	*/
	}

/* Funktionen zur Bearbeitung der Datei							*/
int isvalue(int c)			/* Test, ob Flieûkommazeichen */
	{
	return((isdigit(c))||(c=='.')||(c=='-')||(c=='+'));
	}

/* Testet, ob Buchstabe oder Sternchen */
int isalstar(int c)
	{
	return((isalpha(c))||(c=='*'));
	}

/* Dateizeiger in nÑchste Zeile setzen */
int next_line(void)
	{
	int z;
	do	{
		z=fgetc(datei);
		if(z==10) dzeile++;
		} while((z!=10)&&(z!=EOF));
	if(z==EOF)
		{
		fclose(datei);
		return(FILEEND);
		}
	else return(TRUE);
	}

/* Einlesen von wzahl Werten in das Feld w[] */
int werte_einlesen(float *w,int wzahl)
	{
	int z,wz,p;
	char wert[80];
	
	for(wz=0; wz<wzahl; wz++)
		{
		p=0;
		do	{
			z=fgetc(datei);
			if(z==10)
				{
				dzeile++;
				return(ERROR);
				}
			if(z=='*')
				{
				z=next_line();
				if(z==EOF)
					{
					fclose(datei);
					return(FILEEND);
					}
				else return(ERROR);
				}
			} while((!isvalue(z))&&(z!=EOF)&&(p<79));
		while(isvalue(z)&&(z!=EOF)&&(z!=10)&&(p<79))
			{
			if(isvalue(z)) wert[p++]=(char) z;
			z=fgetc(datei);
			if(z==10)dzeile++;
			}
		if(z==EOF)
			{
			fclose(datei);
			return(FILEEND);
			}
		wert[p]=0;
		w[wz]=atof(wert);
		}
	return(TRUE);
	}

/* Einlesen eines Befehles und RÅckgabe der entspr. Konstante */
/* Also die Scanner-Routine des Programmes                    */
int befehl_einlesen(void)		/* Befehl einlesen */
	{
	char befehl[80];
	int p=0,z;
	do	{
		z=fgetc(datei); 
		if(z==10) dzeile++;
		} while((!isalstar(z))&&(z!=EOF)&&(p<79));
	while(isalstar(z)&&(z!=EOF)&&(z!=10)&&(p<79))
		{
		if(isalstar(z)) befehl[p++]=(char) tolower(z);
		z=fgetc(datei);
		if(z==10) dzeile++;
		}
	if(z==EOF)
		{
		fclose(datei);
		return(FILEEND);
		}
	befehl[p]=0;
	if(befehl[0]=='*') return(COMMENT);
	if(!strcmp("object",befehl)) return(OBJECT);
	if(!strcmp("endobject",befehl)) return(ENDOBJECT);
	if(!strcmp("triangle",befehl)) return(TRIANGLE);
	if(!strcmp("rectangle",befehl)) return(RECTANGLE);
	if(!strcmp("place",befehl)) return(PLACE);
	if(!strcmp("draw",befehl)) return(DRAW);
	if(!strcmp("getkey",befehl)) return(GETKEY);
	if(!strcmp("camera",befehl)) return(CAMERA);
	if(!strcmp("clear",befehl)) return(CLEAR);
	if(!strcmp("rotate",befehl)) return(ROTATE);
	if(!strcmp("ball",befehl)) return(BALL);
	if(!strcmp("save",befehl)) return(SAVE);
	if(!strcmp("shading",befehl)) return(SHADING);
	if(!strcmp("gouraud",befehl)) return(GOURAUD);
	if(!strcmp("extended",befehl)) return(EXTENDED);
	return(ERROR);
	}

/* Dreieck hinzufÅgen */
void addtriangle(float *p1,float *p2,float *p3,int gouraudmodus)
	{
	if(tricnt>=MAXTRI)
		{
		printf("Zeile %d: Zu viele Dreiecke...\n",dzeile);
		fclose(datei);			/* Datei schlieûen	*/
		exit(0);				/* Programmende		*/
		}
	obtri[tricnt].x[0]=p1[0];	/* Koordinaten merk.*/
	obtri[tricnt].y[0]=p1[1];
	obtri[tricnt].z[0]=p1[2];
	obtri[tricnt].x[1]=p2[0];
	obtri[tricnt].y[1]=p2[1];
	obtri[tricnt].z[1]=p2[2];
	obtri[tricnt].x[2]=p3[0];
	obtri[tricnt].y[2]=p3[1];
	obtri[tricnt].z[2]=p3[2];
	gouraudan[tricnt]=(char) gouraudmodus;
	tricnt++;					/* NÑchstes Dreieck	*/
	}

/* Rotationskîrper berechnen		*/
void do_rotate(int rotstep,int rotpts,float *p,int gouraudmodus)
	{
	int i,j,s;
	float pa[MAXSTEP][3];					 	/* Facette 1	*/
	float pb[MAXSTEP][3];					 	/* Facette 2	*/
	float sw;							/* Winkel pro Schritt	*/
	float hx,hz;						/* Hilfskoordinaten		*/
	
	sw=2*M_PI/(float) rotstep;
	for(i=0; i<rotpts; i++)
		{
		pa[i][0]=pb[i][0]=p[i*2];				/* Koord. initialisieren*/
		pa[i][1]=pb[i][1]=p[i*2+1];
		pa[i][2]=pb[i][2]=0;
		}
	
	for(s=1; s<=rotstep; s++)
		{
		for(i=0; i<rotpts; i++)			/* Facette rotieren		*/
			{
			hx=pb[i][0];
			hz=pb[i][2];
			pb[i][0]=cos(sw)*hx + sin(sw)*hz;
			pb[i][2]=cos(sw)*hz - sin(sw)*hx;
			}
		
		for(i=0; i<rotpts-1; i++)		/* FlÑchen hinzufÅgen	*/
			{
			addtriangle(&pa[i][0],&pb[i][0],&pa[i+1][0],gouraudmodus);
			addtriangle(&pb[i][0],&pb[i+1][0],&pa[i+1][0],gouraudmodus);
			}
		
		for(i=0; i<rotpts; i++)			/* Facette B --> A		*/
			for(j=0; j<3; j++) pa[i][j]=pb[i][j];
		}
	}


/* Objekt aus einer Datei einlesen */
int getobject(void)
	{
	int cmd,obnr,test,rotpts,rotstep,i,gouraud;
	float k[MAXSTEP*2+1],radius,w;
	test=werte_einlesen(&k[0],1);		/* Objektnummer	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Objektnummer fehlt...\n",dzeile);
		fclose(datei);
		getch();
		return(FILEEND);
		}
	obnr=(int) k[0];						/* Objektnummer		*/
	obs[obnr].first=tricnt;					/* Erstes Dreieck	*/
	while(((cmd=befehl_einlesen())!=ENDOBJECT)&&(cmd!=FILEEND))
		{
		test=TRUE;
		switch(cmd)							/* Zeichenbefehl	*/
			{
			case TRIANGLE:	test=werte_einlesen(&k[0],10);
							if(test==ERROR)
								{
								printf("Zeile %d: Fehlerhafte Dreieckskoordinaten...\n",dzeile);
								fclose(datei);
								getch();
								return(FILEEND);
								}
							else if(tricnt<MAXTRI-1)
								{
								obs[obnr].last=tricnt;		/* Letztes Dreieck	*/	
								addtriangle(&k[1],&k[4],&k[7],
									(k[0]>0));	/* Dreieck		*/
								}
							break;
			case RECTANGLE:	test=werte_einlesen(&k[0],13);
							if(test==ERROR)
								{
								printf("Zeile %d: Fehlerhafte Rechteckskoordinaten...\n",dzeile);
								fclose(datei);
								getch();
								return(FILEEND);
								}
							else if(tricnt<MAXTRI-2)
								{
								obs[obnr].last=tricnt+1;	/* Letztes Dreieck	*/	
								addtriangle(&k[1],&k[4],&k[7],
									(k[0]>0));	/* Dreiecke		*/
								addtriangle(&k[1],&k[10],&k[7],
									(k[0]>0));
								}
							break;
			case ROTATE:	test=werte_einlesen(&k[0],3);
							gouraud=(k[0]>0);
							rotstep=(int) k[1];
							rotpts=(int) k[2];
							if((test==ERROR)||(rotstep<3)||(rotstep>MAXSTEP)||
								(rotpts<2)||(rotpts>MAXSTEP))
								{
								printf("Zeile %d: Fehlerhafter Rotationskîrper...\n",dzeile);
								fclose(datei);
								getch();
								return(FILEEND);
								}
							else
								{
								test=werte_einlesen(&k[0],rotpts*2);
								if(test==ERROR)
									{
									printf("Zeile %d: Fehlerhafter Rotationskîrper...\n",dzeile);
									fclose(datei);
									return(FILEEND);
									}
								else
									{
									do_rotate(rotstep,rotpts,&k[0],
										gouraud);
									obs[obnr].last=tricnt-1;	/* Letztes Dreieck	*/	
									}
								}
							break;
			case BALL:		test=werte_einlesen(&k[0],3);
							if((test==ERROR)||(k[1]<3)||(k[1]>MAXSTEP))
								{
								printf("Zeile %d: Fehlerhafte Kugel...\n",dzeile);
								fclose(datei);
								getch();
								return(FILEEND);
								}
							else
								{
								gouraud=(k[0]>0);
								rotstep=(int) k[1];			/* Auflîsung		*/
								radius=k[2];				/* Kugelradius		*/
								for(i=0, w=-M_PI/2; i<rotstep; i++, w+=(M_PI/(rotstep-1)))
									{
									k[i*2]=radius*cos(w);	/* Kreishalbbogen	*/
									k[i*2+1]=radius*sin(w);
									}
								do_rotate(rotstep,rotstep,&k[0],
									gouraud);			/* Rotieren	*/
								obs[obnr].last=tricnt-1;	/* Letztes Dreieck	*/	
								}
							break;
			case COMMENT:	test=next_line();
							break;
			default:		printf("Zeile %d: Falscher Befehl in >>OBJECT<<-Definition...\n",dzeile);
							break;
			}
		if(test==FILEEND) return(test);
		if(test==ERROR)
			{
			printf("Zeile %d: Parameter inkorrekt...\n",dzeile);
			fclose(datei);
			return(FILEEND);
			}
		}
	return(cmd);
	}


/* Objekt in 3D-Welt setzen */
int setobject(void)
	{
	int test;
	float k[9];
	test=werte_einlesen(&k[0],1);		/* Objektnummer	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Objektnummer fehlt...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	place[dispcnt].ob=(int) k[0];			/* Objektnummer			*/
	test=werte_einlesen(&k[0],9);		/* Objektposition etc.	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Objektkoordinaten/-winkel/-skalierungsfaktoren fehlerhaft...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	place[dispcnt].x=k[0];			/* Koordinaten eintragen	*/
	place[dispcnt].y=k[1];
	place[dispcnt].z=k[2];
	place[dispcnt].rx=k[3];			/* Winkel eintragen			*/
	place[dispcnt].ry=k[4];
	place[dispcnt].rz=k[5];
	place[dispcnt].scalex=k[6];		/* Skalierungsfaktoren		*/
	place[dispcnt].scaley=k[7];
	place[dispcnt].scalez=k[8];
	dispcnt++;						/* ZÑhler erhîhen			*/
	return(TRUE);
	}


/* Kamera in 3D-Welt setzen */
int setcamera(void)
	{
	int test;
	float k[7];
	test=werte_einlesen(&k[0],7);			/* Koordinaten	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Kamerakoordinaten fehlerhaft...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	kamx=(double) k[0];					/* Kamerakoordinaten	*/
	kamy=(double) k[1];
	kamz=(double) k[2];
	kamwx=(double) k[3];				/* Kameradrehung		*/
	kamwy=(double) k[4];
	kamwz=(double) k[5];
	auge=(double) k[6];					/* Augposition			*/
	return(TRUE);
	}

/* Schattierungsmodus setzen */
int setshade(void)
	{
	int test;
	float k[3];
	test=werte_einlesen(&k[0],3);		/* Licht-Koordinaten	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Lichtkoordinaten fehlerhaft...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	lightx=(double) k[0];						/* Lichtrichtung	*/
	lighty=(double) k[1];
	lightz=(double) k[2];
	lightlen=sqrt(lightx*lightx+lighty*lighty+lightz*lightz);
	return(TRUE);
	}

/* Erweiterten Schattierungsmodus setzen */
int setextended(void)
	{
	int test,i;
	float k[13];
	test=werte_einlesen(&k[0],13);		/* Licht-Parameter*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Lichtparameter fehlerhaft...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	lightx=(double) k[0];	/* Lichtrichtung	*/
	lighty=(double) k[1];
	lightz=(double) k[2];
	lightlen=sqrt(lightx*lightx+lighty*lighty+lightz*lightz);
	rdiff=(double) k[3];	/* Koeffizienten */
	rparr=(double) k[4];
	rrefl=(double) k[5];
	rdiff/=(k[3]+k[4]+k[5]); /* Normieren */
	rparr/=(k[3]+k[4]+k[5]);
	rrefl/=(k[3]+k[4]+k[5]);
	nexp=(double) k[6];		/* Exponent */
	for(i=0; i<6; i++) /* Materialkurve */
		{
		if(k[i+7]<0) material[i]=0;
		else if(k[i+7]>1) material[i]=1;
		else material[i]=(double) k[i+7];
		}
	return(TRUE);
	}

/* Dreieck skalieren (Vergrîûern/-kleinern) */
void scaletri(struct tri2 *dreieck,double xs,double ys,double zs)
	{
	int i;
	for(i=0; i<3; i++)
		{
		dreieck->x[i]*=xs;		/* Koordinaten-Skalierung	*/
		dreieck->y[i]*=ys;
		dreieck->z[i]*=zs;
		}
	}

/* Dreieck im 3D-Raum um Ursprung rotieren */
void rotatetri(struct tri2 *dreieck,double xw,double yw,double zw)
	{
	double cosx,cosy,cosz,sinx,siny,sinz,merkx,merky,merkz;
	int i;
	xw=(xw/180.0)*M_PI;			/* In Bogenmaû					*/
	yw=(yw/180.0)*M_PI;
	zw=(zw/180.0)*M_PI;
	cosx=cos(xw);				/* Sinus und Cosinus berechnen	*/
	cosy=cos(yw);
	cosz=cos(zw);
	sinx=sin(xw);
	siny=sin(yw);
	sinz=sin(zw);
	
	for(i=0; i<3; i++)
		{
		merkx=dreieck->x[i];			/* Rotation um y-Achse	*/
		merkz=dreieck->z[i];
		dreieck->x[i]=cosy*merkx - siny*merkz;
		dreieck->z[i]=siny*merkx + cosy*merkz;
		
		merky=dreieck->y[i];			/* Rotation um x-Achse	*/
		merkz=dreieck->z[i];
		dreieck->y[i]=cosx*merky - sinx*merkz;
		dreieck->z[i]=sinx*merky + cosx*merkz;
		
		merkx=dreieck->x[i];			/* Rotation um z-Achse	*/
		merky=dreieck->y[i];
		dreieck->x[i]=cosz*merkx - sinz*merky;
		dreieck->y[i]=sinz*merkx + cosz*merky;
		}
}

/* Dreieck im 3D-Raum verschieben (Translation) */
void translatetri(struct tri2 *dreieck,double xt,double yt,double zt)
	{
	int i;
	for(i=0; i<3; i++)
		{
		dreieck->x[i]+=xt;		/* Koordinaten-Translation	*/
		dreieck->y[i]+=yt;
		dreieck->z[i]+=zt;
		}
	}

/* 3D-Objekte zur Darstellung im Raum plazieren */
void place_objects(void)
	{
	int set,tri,ob,i;
	double tx,ty,tz,rx,ry,rz;	/* Translations-/Rotationswerte */
	double sx,sy,sz;			/* Skalierungsfaktoren			*/
	if(dispcnt>0) for(set=0; set<dispcnt; set++)	/* Alle Darst.-Obj.	*/
		{
		ob=place[set].ob;							/* Objektnummer		*/
		tx=(double) place[set].x;				/* Translations-Werte	*/
		ty=(double) place[set].y;
		tz=(double) place[set].z;
		rx=(double) place[set].rx;				/* Rotations-Werte		*/
		ry=(double) place[set].ry;
		rz=(double) place[set].rz;
		sx=(double) place[set].scalex;			/* Skalierungsfaktoren	*/
		sy=(double) place[set].scaley;
		sz=(double) place[set].scalez;
		for(tri=obs[ob].first; tri<=obs[ob].last; tri++) /* Alle Dreiecke */
			{
			if(disptri>=MAXTRI)
				{
				puts("Zu viele PLACE-Befehle...");
				fclose(datei);			/* Datei schlieûen	*/
				exit(0);				/* Programmende		*/
				}
			for(i=0; i<3; i++)
				{
				drawtri[disptri].x[i]=obtri[tri].x[i];	/* Dreieck kopieren	*/
				drawtri[disptri].y[i]=obtri[tri].y[i];
				drawtri[disptri].z[i]=obtri[tri].z[i];
				}
			scaletri(&drawtri[disptri],sx,sy,sz);	/* Dreieck skalieren*/
			rotatetri(&drawtri[disptri],rx,ry,rz);	/* Dreieck rotieren	*/
			translatetri(&drawtri[disptri],tx,ty,tz);	/* Translation	*/
			gouraudan2[disptri]=gouraudan[tri];		/* Gouraudmodus		*/
			disptri++;								/* NÑchstes Dreieck	*/

			putch((int)'.');
			}
		}
	}

/* Kamera im 3D-Raum plazieren -> Verschiebung des Koordinatensystems	*/
/* durch Translation der Dreiecke, anschlieûend Rotation um Ursprung	*/
void place_camera(void)
	{
	int tri;
	for(tri=0; tri<disptri; tri++)
		{
		translatetri(&drawtri[tri],-kamx,-kamy,-(kamz+auge));	/* Translation	1	*/
		rotatetri(&drawtri[tri],kamwx,kamwy,kamwz);				/* Rotation			*/
		translatetri(&drawtri[tri],0,0,+auge);					/* Translation	2	*/
		putch((int)'.');
		}
	}

/* Dreiecks-Schattierung berechnen */
void shade_triangles(void)
	{
	int tri;
	double ax,ay,az,bx,by,bz,nx,ny,nz,nlen,color;
	for(tri=0; tri<disptri; tri++)
		{
		ax=drawtri[tri].x[1]-drawtri[tri].x[0];	/* Vektoren	*/
		ay=drawtri[tri].y[1]-drawtri[tri].y[0];
		az=drawtri[tri].z[1]-drawtri[tri].z[0];
		bx=drawtri[tri].x[2]-drawtri[tri].x[0];
		by=drawtri[tri].y[2]-drawtri[tri].y[0];
		bz=drawtri[tri].z[2]-drawtri[tri].z[0];
		nx=ay*bz-az*by;			/* Normalenvektor berechnen	*/
		ny=-ax*bz+az*bx;
		nz=ax*by-ay*bx;
		nlen=sqrt(nx*nx+ny*ny+nz*nz);	/* Normalenv.-LÑnge	*/
		color=fabs((nx*lightx+ny*lighty+nz*lightz)/(nlen*lightlen));
		drawtri[tri].shade=(unsigned) (color*28.5);
		putch((int)'.');
		}
	}

/* Erweiterte Dreiecks-Schattierung berechnen */
void extshade_triangles(void)
	{
	int tri,i;
	
	double ax,ay,az,bx,by,bz,nx,ny,nz,nlen,color;
	double sx=0,sy=0,sz=0; /* FlÑchenmittelpunkt */
	double d,alfa;
	double rx,ry,rz; /* Reflexionsvektor */
	double vx,vy,vz; /* Betrachtungsvektor */
	double cosauge; /* Cosinus des Winkels Sehstrahl, refl. Lichtstrahl */
	double cosnorm; /* Cosinus des Winkels Dreiecksnormale, Lichtstrahl */
	double help;
	int index; /* Index fÅr Tabellenzugriff */

/* Berechnung zweier Vektoren, welche die Dreiecksebene aufspannen */

	for(tri=0; tri<disptri; tri++)
		{
		ax=drawtri[tri].x[1]-drawtri[tri].x[0];
		ay=drawtri[tri].y[1]-drawtri[tri].y[0];
		az=drawtri[tri].z[1]-drawtri[tri].z[0];
		bx=drawtri[tri].x[1]-drawtri[tri].x[2];
		by=drawtri[tri].y[1]-drawtri[tri].y[2];
		bz=drawtri[tri].z[1]-drawtri[tri].z[2];

/* Nun berechnen wir den immer nîtigen Normalenvektor */
		
		nx=ay*bz-az*by;
		ny=az*bx-ax*bz;
		nz=ax*by-ay*bx;
		nlen=sqrt(nx*nx+ny*ny+nz*nz);

/* Weiterhin ermitteln wir den FlÑchenmittelpunkt */		

		for(i=0; i<3; i++)
			{
			sx+=drawtri[tri].x[i];
			sy+=drawtri[tri].y[i];
			sz+=drawtri[tri].z[i];
			}
		sx/=3;
		sy/=3;
		sz/=3;

/* Somit kînnen wir den reflektierten Lichtstrahl berechnen */

		alfa=(nx*drawtri[tri].x[0]) + (ny*drawtri[tri].y[0]) +
			 (nz*drawtri[tri].z[0]); 
			/* Rechte Seite der Ebenengleichung */
	
		d=(lightx*nx + lighty*ny + lightz*nz - alfa) /
			 (nx*nx + ny*ny + nz*nz);	/* Abstand Punkt-Ebene */

/* Letztendlich noch die Reflexion des Lichtstrahls berechnen */

		rx = lightx - 2*d*nx;
		ry = lighty - 2*d*ny;
		rz = lightz - 2*d*nz;

/* Nun mÅssen wir den Vektor vom Objekt zum Betrachter ermitteln */

		vx = -sx;
		vy = -sy;
		vz = auge-sz;

/* Den Cosinus des Winkels zwischen Seh- und refektiertem Lichstrahl */
/* ermitteln wir durch das Skalarprodukt 							 */
		
		cosauge=fabs((rx*vx + ry*vy + rz*vz) / 
		 (sqrt(rx*rx + ry*ry + rz*rz) * sqrt(vx*vx + vy*vy + vz*vz)));

		cosnorm=fabs((nx*lightx + ny*lighty + nz*lightz) / (nlen*lightlen));

		help=acos(cosnorm)*180/3.141592654; /* Ins Gradmaû (0-90 Grad) */
		index=(int) help/15;
		if(index>5) index=5;

/* Somit kînnen wir die FlÑchenhelligkeit bestimmen */
		
		color=rdiff + rparr*cosnorm + 
		      rrefl*material[index]*pow(cosauge,nexp);

		drawtri[tri].shade=(unsigned) (color*28.5);
		putch((int)'.');
		}
	}

/* Teste, ob Punkt A von Dreieck d1 gleich Punkt B von Dreieck d2 */
int gleicherpunkt(int d1,int a,int d2,int b)
	{
	return(	(drawtri[d1].x[a]==drawtri[d2].x[b])&&
			(drawtri[d1].y[a]==drawtri[d2].y[b])&&
			(drawtri[d1].z[a]==drawtri[d2].z[b]));
	}
	
/* Gouraud-Schattenwerte berechnen */
void do_gouraud(void)
	{
	register int dakt,			/* Aktuelles Dreieck		*/
				dsuch;			/* Untersuchtes Dreieck		*/
	register int e1,e2;			/* Eckennummern				*/
	unsigned long anzahl;		/* Addierte Helligkeitsw.	*/
	unsigned long hsumme;		/* Summe der Helligkeiten	*/
	
	for(dakt=0; dakt<disptri; dakt++)	/* Alle Dreiecke	*/
	  {
	  for(e1=0; e1<3; e1++)				/* Deren Ecken		*/
		{
		hsumme=(unsigned long) drawtri[dakt].shade;
		anzahl=1;
		if(gouraudan2[dakt])
		  for(dsuch=0; dsuch<disptri; dsuch++)
			if(dakt!=dsuch)		/* Alle anderen Dreicke		*/
				for(e2=0; e2<3; e2++)	/* Deren Ecken		*/
						if(gleicherpunkt(dakt,e1,dsuch,e2))
							{
							e2=3;			/* for beenden	*/
							hsumme+=(unsigned long) drawtri[dsuch].shade;
							anzahl++;
							}
		drawtri[dakt].c[e1]=hsumme/anzahl;
		}
	  putch((int) '.');
	  }
	}


/* D-Buffer-Punkt setzen, soweit z-Koordinate es erlaubt */
/* Koordinate (x,y,z) in Farbe c                         */
void d_setpixel(int x,int y,int z,int c)
	{
	int c1,c2,c3,c4,crest;
	if((z < d_z[(long)x+maxx*(long)y])   /* Wenn Lage vor bish. Punkt */
	  &&(x>=0)&&(y>=0)        /* und im Bildschirmbereich */
	  &&(x<maxx)&&(y<=maxy))
				{
				c1=c2=c3=c4=c/4;
				crest=c%4;
				if(crest>0) c1++;
				if(crest>1) c4++;
				if(crest>2) c2++;
				if(crest>3) c3++;
				d_z[(long) x + maxx * (long) y] = z;/* neues z-max fÅr Pixel */
				put_pixel(x*2,y*2,c1);     /* Punkt zeichnen        */
				put_pixel(x*2+1,y*2,c2);
				put_pixel(x*2,y*2+1,c3);      
				put_pixel(x*2+1,y*2+1,c4);
				}
	}

/* Horizontale Linie ziehen mit Farbinterpolation, von (x1,y,z1) */
/* zu (x2,y,z2) in Farben c1 bis c2. 							 */
void d_hline(int y,double x1,double z1,double c1,
				   double x2,double z2,double c2)
	{
	double fhilf;
	double tz,tc;	/* TemporÑre Werte fÅr z, Farbe		*/
	double dz,dc;	/* Delta-Werte fÅr z, Farbe			*/
	register int tix; /* TemporÑrer int-Wert fÅr x		*/
	if(x1>x2)        /* Ggf. Seiten tauschen			*/
		{
		fhilf=x1; x1=x2; x2=fhilf;
		fhilf=z1; z1=z2; z2=fhilf;
		fhilf=c1; c1=c2; c2=fhilf;
		}
	if(x1!=x2)		/* Delta-Werte berechnen			*/
		{
		dz=(z2-z1) / (x2-x1);
		dc=(c2-c1) / (x2-x1);
		}

	for(tix=(int) (x1+0.5), tz=z1, tc=c1; tix <= (int) (x2+0.5); tix++) 
		{			/* Zeile darstellen 				*/
		d_setpixel(tix, y,(int) tz,(int) tc);
		tz+=dz;
		tc+=dc;
		}
	}

/* Dreieck mit Depth-Buffer und Gouraud-Shading darstellen	*/
/* Koordinaten: x[..], y[..], z[..], Eckenfarben c[..]		*/
void d_drawtri(double *x,double *y,double *z,double *c)
	{
	double fhilf;								/* Hilfsvariable		*/
	double tx0,tz0,tc0,dx0,dz0,dc0;				/* Werte Kante 0		*/
	double tx1,tz1,tc1,dx1,dz1,dc1;				/* Werte Kante 1		*/
	int ty;										/* Scanzeile			*/
	int minp,maxp,midp;							/* Nummern der Ecken	*/
	if((y[0]==y[1])&&(y[1]==y[3])) return;		/* Wenn nur Kante->Ende */

	if((y[0]>=y[1])&&(y[0]>=y[2])) maxp=0;		/* Unterste Ecke suchen */
	else if((y[1]>=y[0])&&(y[1]>=y[2])) maxp=1;
	else maxp=2;
	if((y[0]<=y[1])&&(y[0]<=y[2])&&(maxp!=0)) minp=0;	/* Oberste 		*/
	else if((y[1]<=y[0])&&(y[1]<=y[2])&&(maxp!=1)) minp=1;
	else minp=2;
	if((minp!=0)&&(maxp!=0)) midp=0;			/* Mittlere Ecke suchen	*/
	else if((minp!=1)&&(maxp!=1)) midp=1;
	else midp=2;

	ty=(int)y[minp];							/* Erster y-Wert		*/
	tx0=tx1=x[minp];							/* Erster x-Wert		*/
	tz0=tz1=z[minp];							/* Erster z-Wert		*/
	tc0=tc1=c[minp];							/* Erster c-Wert		*/

	fhilf=y[midp]-y[minp];
	if(fhilf)
		{
		dx0=(x[midp]-x[minp])/fhilf;			/* Delta-Werte berechnen*/
		dz0=(z[midp]-z[minp])/fhilf;			/* fÅr obere Halbkante	*/
		dc0=(c[midp]-c[minp])/fhilf;
		}

	fhilf=y[maxp]-y[minp];
	dx1=(x[maxp]-x[minp])/fhilf;		   		/* Delta-Werte ber.		*/
	dz1=(z[maxp]-z[minp])/fhilf;				/* fÅr Gesamtkante		*/
	dc1=(c[maxp]-c[minp])/fhilf;

	while(ty < (int) y[midp])	   /* Bis oberere DreieckshÑlfte fertig */
		{
		d_hline(ty,tx0,tz0,tc0,tx1,tz1,tc1);    /* Zeile darstellen		*/
		ty++;									/* NÑchste Zeile		*/
		tx0+=dx0; tx1+=dx1;						/* x-Werte Ñndern		*/
		tz0+=dz0; tz1+=dz1;						/* z-Werte Ñndern		*/
		tc0+=dc0; tc1+=dc1;						/* Farbwerte Ñndern		*/
		}

	fhilf=y[maxp]-y[midp];
	if(fhilf)
		{
		dx0=(x[maxp]-x[midp])/fhilf;            /* Delta-Werte berechnen*/
		dz0=(z[maxp]-z[midp])/fhilf;			/* fÅr untere Halbkante	*/
		dc0=(c[maxp]-c[midp])/fhilf;
		}

	tx0=x[midp];								/* Nun ab mittl. Ecke	*/
	tz0=z[midp];
	tc0=c[midp];

	while(ty < ((int) y[maxp]))    /* Bis untere DreieckshÑlfte fertig */
		{
		d_hline(ty,tx0,tz0,tc0,tx1,tz1,tc1);    /* Zeile darstellen		*/
		ty++;									/* NÑchste Zeile		*/
		tx0+=dx0; tx1+=dx1;						/* x-Werte Ñndern		*/
		tz0+=dz0; tz1+=dz1;						/* z-Werte Ñndern		*/
		tc0+=dc0; tc1+=dc1;						/* Farbwerte Ñndern		*/
		}
	}

/* Dreieck <nr> im Shading-Modus darstellen	*/
void draw_shadetri(int nr)
	{
	int i;
	double x[3],y[3],z[3],c[3],t;
	if((drawtri[nr].z[0]>0)&&(drawtri[nr].z[1]>0)&&(drawtri[nr].z[2]>0))
		{								/* Wenn nicht hinter Kamera */
		for(i=0; i<3; i++)
			{
			t=(double)auge/((double)auge-(double)drawtri[nr].z[i]);
			x[i]=xcenter+xscale*t*(double)drawtri[nr].x[i];
			y[i]=ycenter-yscale*t*(double)drawtri[nr].y[i];
			z[i]=t*(double)drawtri[nr].z[i];
			switch(dispmode)
				{
				case M_SHADING:	c[i]=(double)drawtri[nr].shade;
								break;
				case M_GOURAUD:	
				case M_EXTENDED:c[i]=(double)drawtri[nr].c[i];
								break;
				}
			}
		d_drawtri(x,y,z,c);
		}
	}

/* Gesamte Grafik darstellen	*/
void draw_graphic(void)
	{
	int tri;
	screen_clear();						/* Bildschirm lîschen	*/
	for(tri=0; tri<disptri; tri++)
		draw_shadetri(tri);
	}

/* Darstellen der 3D-Grafik */
void darstellen(void) 
	{
	disptri=0;				/* Neue Dreiecksliste			*/
	printf("\33EPlaziere Objekte    ");
	place_objects();		/* Objekte in Dreiecksliste		*/
	printf("\nSchattiere Objekte  ");
	if(dispmode!=M_EXTENDED) shade_triangles();		/* Dreiecke schattieren	*/
	else extshade_triangles(); /* Erweitertes Beleuchtungsmodell */
	if((dispmode==M_GOURAUD)||(dispmode==M_EXTENDED))
		{
		printf("\nGouraud-Berechnungen");
		do_gouraud();
		}
	printf("\nPlaziere Kamera     ");
	place_camera();			/* Kamera plazieren				*/
	draw_graphic();			/* Grafik darstellen			*/
	}

/* Neochrome-Bild speichern */
void saveneo(void)
	{
	char name[80];
	int datei,farben[16],i;
	sprintf(name,"BILD_%c.PI1",picnr++);
	if(picnr>'Z') picnr='A';
	datei=Fcreate(name,0);			/* Datei îffnen	*/
	if(datei>=0)
		{
		farben[0]=0;
		Fwrite(datei,2L,farben);			/* 2 Leerbytes	*/
		for(i=0;i<16;i++)
			farben[i]=Setcolor(i,-1);		/* Farbpalette	*/
		Fwrite(datei,32L,farben);
		Fwrite(datei,32000L,Logbase());	/* Schreiben	*/
		Fclose(datei);
		}
	}


/* Die Datei <name> wird ausgefÅhrt */
void ausfuehren_datei(const char *name)
	{
	int befehl,test=TRUE;
	if(strchr(name,(int)'.')==NULL) strcat(name,".3D");
	if((datei=fopen(name,"r"))!=NULL)
		{
		do	{
			befehl=befehl_einlesen();
			test=TRUE;
			switch(befehl)
				{
				case OBJECT:	test=getobject();
								break;	/* Objekt eintragen			*/
				case ENDOBJECT:	printf("Zeile %d: >>ENDOBJECT<< ohne >>OBJECT<<...\n",dzeile);
								break;	/* Objektende				*/
				case TRIANGLE:
				case RECTANGLE:	
				case ROTATE:	
				case BALL:		printf("Zeile %d: Falscher Befehl auûerhalb >>OBJECT<<-Definition...\n",dzeile);
								break;	/* Falscher Befehl			*/
				case PLACE:		test=setobject();
								break;	/* Objekt plazieren			*/
				case DRAW:		darstellen();
								break;	/* Grafik darstellen		*/
				case GETKEY:	getch();
								break;	/* Auf Tastendruck warten	*/
				case CAMERA:	test=setcamera();
								break;	/* Kameraposition setzen	*/
				case COMMENT:	test=next_line();
								break;	/* Kommentar Åberspringen	*/
				case ERROR:		printf("Zeile %d: Syntaxfehler...\n",dzeile);
								break;	/* Syntaxfehler				*/
				case CLEAR:		dispcnt=0;
								break;	/* 3D-Welt lîschen			*/
				case SAVE:		saveneo();
								break;
				case SHADING:	dispmode=M_SHADING;
								test=setshade();
								break;	/* Shading-Modus			*/
				case GOURAUD:	dispmode=M_GOURAUD;
								test=setshade();
								break;	/* Gouraud					*/
				case EXTENDED:	dispmode=M_EXTENDED;
								test=setextended();
								break;
				}
			} while((befehl!=FILEEND)&&(test!=FILEEND));
		}
	else printf("Kann Datei >>%s<< nicht îffnen...\n",name);	/* Fehler	*/
	}

/* Hauptfunktion des Programmes		*/
void main(int argc, const char *argv[])
	{
	char dname[80];
	init_all();							/* Alles initialisieren	*/
	printf("\33E\x1bv\x1b\x0f");
	printf("TOS-Animation-Language V2.1\n(C)1992 Frank Mathy\n\n");
	if(argc>1) ausfuehren_datei(argv[1]);
	else
		{
		printf("\33eDateiname: ");
		scanf("%s",dname);
		printf("\33f");
		ausfuehren_datei(dname);
		}
	exit_all();
	}
