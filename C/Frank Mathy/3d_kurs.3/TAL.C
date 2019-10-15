/*		TOS-Animation-Language-3D ("TAL")	*/
/*		(C) 1990 Frank Mathy, TOS			*/
/*		Version 1.1, 24.11.1990				*/
/*		Hidden-Line, Schattierung			*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ext.h>
#include <graphics.h>
#include <ctype.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <tos.h>

#define TRUE 1
#define FALSE 0
#define ERROR (-1)
#define FILEEND (-2)
#define OBJECT 1
#define ENDOBJECT 2
#define TRIANGLE 3
#define RECTANGLE 4
#define PLACE 100
#define DRAW 101
#define GETKEY 102
#define CAMERA 103
#define COMMENT 104
#define CLEAR 105
#define VECTOR 106
#define HIDDEN 107
#define SHADED 108
#define SAVE 109

/* Je nach Speichergrîûe kînnen die drei nachfolgenden Konstanten	*/
/* geÑndert werden, um beispielsweise Grafiken aus mehr als 1000	*/
/* Dreiecken darstellen zu kînnen...								*/

#define MAXOB 10						/* Maximale Objektdef.	*/
#define MAXPL 30						/* Maximale Objektdarst.*/
#define MAXTRI 1000						/* Maximale Dreieckszahl*/

/* LÑnge einer Bildschirmseite fÅr den SAVE-Befehl */

#define PICBYTES 32000					/* öblicher Wert		*/

/* GEM-Variablen */

int	work_in[12],
	work_out[57];						/* Externe Variablen	*/

int ap_id;								/* Applikationsnummer	*/
int p_handle;							/* Physik. Handle		*/
int handle;								/* Virtuelles Handle	*/

/* Allgemeine Daten												*/

int 	treiber=DETECT,					/* Treibertyp			*/
		modus,							/* Grafikmodus			*/
		maxx,maxy,						/* Maximale Koordinaten	*/
		xcenter,ycenter,				/* Bildmittelpunkt		*/
		dzeile=1;						/* Dateizeile			*/
char	picnr='A';						/* Bildkennung			*/

/* Dreidimensionale Daten										*/

double	kamx=0,kamy=0,kamz=0,			/* Kameraposition		*/
		kamwx=0,kamwy=0,kamwz=0,		/* Kameradrehung		*/
		lightx,lighty,lightz,lightlen,	/* Lichtrichtung		*/
	 	xscale,yscale,					/* Skalierungsfaktoren	*/
		auge = -500;					/* Augposition			*/		

struct	{
		int first,last;				/* Dreiecke von Objekt	*/
		} obs[MAXOB];

struct	{
		int ob;						/* Objektnummer			*/
		float x,y,z;				/* Position				*/
		float rx,ry,rz;				/* Rotation				*/
		float scalex,scaley,scalez;	/* Skalierungsfaktoren	*/
		} place[MAXPL];

struct tri	{
			float x[3],y[3],z[3];	/* Koordinaten			*/
			} obtri[MAXTRI];

struct tri2	{
			float x[3],y[3],z[3];	/* Koordinaten			*/
			float distance;			/* Mittlerer Abstand	*/
			unsigned shade;			/* Helligkeit			*/
			} drawtri[MAXTRI];

enum { M_VECTOR,M_HIDDEN,M_SHADED } dispmode=M_VECTOR;

int tricnt=0;						/* Definierte Dreiecke	*/
int disptri=0;						/* Darzustellende Dreie.*/
int dispcnt=0;						/* Darzustellende Obj.	*/

/* GEM-Initialisierung */

void open_work(void)
	{
	int i,p[4];
	ap_id=appl_init();					/* Applikationsnummer	*/
	p_handle=graf_handle(&i,&i,&i,&i);	/* Bildschirm-Handle	*/
	for(i=0; i<10; i++) work_in[i]=1;	/* Auf Eins setzen		*/
	work_in[10]=2;						/* Koordinatensystem	*/
	handle=p_handle;					/* Kopieren				*/
	v_opnvwk(work_in,&handle,work_out);	/* Virtuelle erîffnen	*/
	vsf_color(handle,1);				/* FÅllfarbe			*/
	vsf_interior(handle,2);				/* Schraffur			*/
	vsf_perimeter(handle,0);			/* Kein Rand			*/
	p[0]=p[1]=0;						/* Clipping				*/
	p[2]=maxx;
	p[3]=maxy;
	vs_clip(handle,1,p);
	}

void close_work(void)
	{
	v_clsvwk(handle);					/* Virtuelle abmelden	*/
	appl_exit();						/* Anwendung abmelden	*/
	}

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
	open_work();					/* GEM initialisieren	*/
	}

void exit_all(void)					/* Beenden des Programmes*/
	{
	close_work();					/* GEM abmelden			*/
	setallpalette(getdefaultpalette());/* Alte Farbpalette	*/
	closegraph();					/* BGI-Arbeiten beenden	*/
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

int next_line(FILE *datei)
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

/* Bildschirminhalt speichern */

void savepic(void)
	{
	char name[80];
	int datei;
	sprintf(name,"BILD_%c.DOO",picnr++);
	if(picnr=='Z') picnr='A';
	datei=Fcreate(name,0);			/* Datei îffnen	*/
	if(datei>=0)
		{
		Fwrite(datei,PICBYTES,Logbase());	/* Schreiben	*/
		Fclose(datei);
		}
	}

/* Einlesen von wzahl Werten in das Feld w[] */

int werte_einlesen(FILE *datei,float *w,int wzahl)
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
				z=next_line(datei);
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

int befehl_einlesen(FILE *datei)		/* Befehl einlesen */
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
	if(!strcmp("vector",befehl)) return(VECTOR);
	if(!strcmp("hidden",befehl)) return(HIDDEN);
	if(!strcmp("shaded",befehl)) return(SHADED);
	if(!strcmp("save",befehl)) return(SAVE);
	return(ERROR);
	}

/* Dreieck hinzufÅgen */

void addtriangle(float *p1,float *p2,float *p3)
	{
	obtri[tricnt].x[0]=p1[0];	/* Koordinaten merk.*/
	obtri[tricnt].y[0]=p1[1];
	obtri[tricnt].z[0]=p1[2];
	obtri[tricnt].x[1]=p2[0];
	obtri[tricnt].y[1]=p2[1];
	obtri[tricnt].z[1]=p2[2];
	obtri[tricnt].x[2]=p3[0];
	obtri[tricnt].y[2]=p3[1];
	obtri[tricnt].z[2]=p3[2];	
	tricnt++;					/* NÑchstes Dreieck	*/
	}

/* Objekt aus einer Datei einlesen */

int getobject(FILE *datei)
	{
	int cmd,obnr,test;
	float k[12];
	test=werte_einlesen(datei,&k[0],1);		/* Objektnummer	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Objektnummer fehlt...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	obnr=(int) k[0];						/* Objektnummer		*/
	obs[obnr].first=tricnt;					/* Erstes Dreieck	*/
	while(((cmd=befehl_einlesen(datei))!=ENDOBJECT)&&(cmd!=FILEEND))
		{
		test=TRUE;
		switch(cmd)							/* Zeichenbefehl	*/
			{
			case TRIANGLE:	test=werte_einlesen(datei,&k[0],9);
							if(test==ERROR)
								{
								printf("Zeile %d: Fehlerhafte Dreieckskoordinaten...\n",dzeile);
								fclose(datei);
								return(FILEEND);
								}
							else if(tricnt<MAXTRI-1)
								{
								obs[obnr].last=tricnt;		/* Letztes Dreieck	*/	
								addtriangle(&k[0],&k[3],&k[6]);	/* Dreieck		*/
								}
							break;
			case RECTANGLE:	test=werte_einlesen(datei,&k[0],12);
							if(test==ERROR)
								{
								printf("Zeile %d: Fehlerhafte Rechteckskoordinaten...\n",dzeile);
								fclose(datei);
								return(FILEEND);
								}
							else if(tricnt<MAXTRI-2)
								{
								obs[obnr].last=tricnt+1;	/* Letztes Dreieck	*/	
								addtriangle(&k[0],&k[3],&k[6]);	/* Dreiecke		*/
								addtriangle(&k[0],&k[9],&k[6]);
								}
							break;
			case COMMENT:	test=next_line(datei);
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

int setobject(FILE *datei)
	{
	int test;
	float k[9];
	test=werte_einlesen(datei,&k[0],1);		/* Objektnummer	*/
	if(test==FILEEND) return(test);
	if(test==ERROR)
		{
		printf("Zeile %d: Objektnummer fehlt...\n",dzeile);
		fclose(datei);
		return(FILEEND);
		}
	place[dispcnt].ob=(int) k[0];			/* Objektnummer			*/
	test=werte_einlesen(datei,&k[0],9);		/* Objektposition etc.	*/
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

int setcamera(FILE *datei)
	{
	int test;
	float k[7];
	test=werte_einlesen(datei,&k[0],7);			/* Koordinaten	*/
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

int setshade(FILE *datei)
	{
	int test;
	float k[3];
	test=werte_einlesen(datei,&k[0],3);		/* Licht-Koordinaten	*/
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
	dispmode=M_SHADED;							/* Modus setzen		*/
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
			for(i=0; i<3; i++)
				{
				drawtri[disptri].x[i]=obtri[tri].x[i];	/* Dreieck kopieren	*/
				drawtri[disptri].y[i]=obtri[tri].y[i];
				drawtri[disptri].z[i]=obtri[tri].z[i];
				}
			scaletri(&drawtri[disptri],sx,sy,sz);	/* Dreieck skalieren*/
			rotatetri(&drawtri[disptri],rx,ry,rz);	/* Dreieck rotieren	*/
			translatetri(&drawtri[disptri],tx,ty,tz);	/* Translation	*/
			disptri++;								/* NÑchstes Dreieck	*/
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
		}
	}

/* Vergleiche den Abstand zweier Dreiecke vom Ursprung */

int compare_tri(struct tri2 *t1,struct tri2 *t2)
	{
	return((int) t2->distance - t1->distance);	/* Vergleich	*/
	}

/* Dreiecke nach Abstand sortieren */

void sort_triangles(void)
	{
	int tri;
	float xm,ym,zm;			/* Mittelpunkt des Dreiecks */
	for(tri=0; tri<disptri; tri++)
		{
		xm=(drawtri[tri].x[0]+drawtri[tri].x[1]+drawtri[tri].x[2])/3;
		ym=(drawtri[tri].y[0]+drawtri[tri].y[1]+drawtri[tri].y[2])/3;
		zm=(drawtri[tri].z[0]+drawtri[tri].z[1]+drawtri[tri].z[2])/3;
		drawtri[tri].distance=(float) 
			sqrt((double) xm*xm + ym*ym + (zm-auge)*(zm-auge));
		}
	qsort(&drawtri[0],(size_t) disptri,sizeof(struct tri2),
			compare_tri);	/* Dreiecke sortieren		*/
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
		color=(nx*lightx+ny*lighty+nz*lightz)/(nlen*lightlen);
		color*=color;					/* Quadrieren		*/
		drawtri[tri].shade=(unsigned) ((1.0-color)*8.5);
		}
	}

/* Projektion der Koordinaten von 3D --> 2D					*/
void projection(double x,double y,double z,int *px,int *py)
	{
	register double distance;
	distance = z - (double) auge;	/* Abstand des Punktes	*/
	*px=xcenter + (int) ((double)-auge*x/distance)*xscale;
	*py=ycenter - (int) ((double)-auge*y/distance)*yscale;
	}

/* Dreieck im Vektor-Modus darstellen	*/

void draw_tri(int nr)
	{
	int i,x[3],y[3];
	for(i=0; i<3; i++)
		projection(	(double) drawtri[nr].x[i],
					(double) drawtri[nr].y[i],
					(double) drawtri[nr].z[i],
					&x[i],&y[i]);		/* In 2D-Koordinaten	*/
	if(drawtri[nr].z[0]>=0)				/* Linien zeichnen		*/
		{
		if(drawtri[nr].z[1]>=0) line(x[0],y[0],x[1],y[1]);
		if(drawtri[nr].z[2]>=0) line(x[0],y[0],x[2],y[2]);
		}
	if((drawtri[nr].z[1]>=0)&&(drawtri[nr].z[2]>=0))
		line(x[1],y[1],x[2],y[2]);
	}

/* Dreieck im Hidden-Line-oder Shaded-Modus darstellen	*/

void draw_hiddentri(int nr)
	{
	int i,p[8];
	if((drawtri[nr].z[0]>=0)&&(drawtri[nr].z[1]>=0)&&(drawtri[nr].z[2]>=0))
		{	/* Wenn nicht hinter Kamera */
		for(i=0; i<3; i++)
			projection(	(double) drawtri[nr].x[i],(double) drawtri[nr].y[i],
						(double) drawtri[nr].z[i],&p[2*i],&p[2*i+1]);
		p[6]=p[0];					/* Endpunkt					*/
		p[7]=p[1];
		fillpoly(4,p);				/* Hintergrund ausstanzen	*/
		drawpoly(4,p);				/* Polygon umranden			*/
		}
	}

void fill_tri(int nr)
	{
	int i,p[8];
	if((drawtri[nr].z[0]>=0)&&(drawtri[nr].z[1]>=0)&&(drawtri[nr].z[2]>=0))
		{	/* Wenn nicht hinter Kamera */
		for(i=0; i<3; i++)
			projection(	(double) drawtri[nr].x[i],(double) drawtri[nr].y[i],
						(double) drawtri[nr].z[i],&p[2*i],&p[2*i+1]);
		p[6]=p[0];							/* Endpunkt			*/
		p[7]=p[1];
		vsf_style(handle,drawtri[nr].shade); 	/* FÅllmuster	*/
		v_fillarea(handle,4,p);				/* Zeichnen			*/
		}
	}

/* Grafik darstellen	*/

void draw_graphic(void)
	{
	int tri;
	cleardevice();						/* Bildschirm lîschen	*/
	switch(dispmode)
		{
		case M_VECTOR:	for(tri=0; tri<disptri; tri++)
							draw_tri(tri);
						break;
		case M_HIDDEN:	setfillstyle(EMPTY_FILL,1);
						for(tri=0; tri<disptri; tri++)
							draw_hiddentri(tri);
						break;
		case M_SHADED:	for(tri=0; tri<disptri; tri++)
							fill_tri(tri);
						break;
		}
	}

/* Darstellen der 3D-Grafik */

void darstellen(void) 
	{
	disptri=0;				/* Neue Dreiecksliste			*/
	place_objects();		/* Objekte in Dreiecksliste		*/
	if(dispmode==M_SHADED)
		shade_triangles();	/* Dreiecke schattieren			*/
	place_camera();			/* Kamera plazieren				*/
	if(dispmode!=M_VECTOR)
		sort_triangles();	/* Dreiecke sortieren			*/
	draw_graphic();			/* Grafik darstellen			*/
	}

/* Die Datei name wird ausgefÅhrt */

void ausfuehren_datei(const char *name)
	{
	int befehl,test=TRUE;
	FILE *datei;
	init_all();						/* BGI initialisieren		*/
	if(strchr(name,(int)'.')==NULL) strcat(name,".3D");
	if((datei=fopen(name,"r"))!=NULL)
		{
		do	{
			befehl=befehl_einlesen(datei);
			test=TRUE;
			switch(befehl)
				{
				case OBJECT:	test=getobject(datei);
								break;	/* Objekt eintragen			*/
				case ENDOBJECT:	printf("Zeile %d: >>ENDOBJECT<< ohne >>OBJECT<<...\n",dzeile);
								break;	/* Objektende				*/
				case TRIANGLE:
				case RECTANGLE:	printf("Zeile %d: Falscher Befehl auûerhalb >>OBJECT<<-Definition...\n",dzeile);
								break;	/* Falscher Befehl			*/
				case PLACE:		test=setobject(datei);
								break;	/* Objekt plazieren			*/
				case DRAW:		darstellen();
								break;	/* Grafik darstellen		*/
				case GETKEY:	getch();
								break;	/* Auf Tastendruck warten	*/
				case CAMERA:	test=setcamera(datei);
								break;	/* Kameraposition setzen	*/
				case COMMENT:	test=next_line(datei);
								break;	/* Kommentar Åberspringen	*/
				case ERROR:		printf("Zeile %d: Syntaxfehler...\n",dzeile);
								break;	/* Syntaxfehler				*/
				case CLEAR:		dispcnt=0;
								break;	/* 3D-Welt lîschen			*/
				case VECTOR:	dispmode=M_VECTOR;
								break;	/* Vektorgrafik-Modus		*/
				case HIDDEN:	dispmode=M_HIDDEN;
								break;	/* Hidden-Line-Modus		*/
				case SHADED:	test=setshade(datei);
								break;	/* Schattierte Darstellung	*/
				case SAVE:		savepic();
								break;	/* Bildschirm abspeichern	*/
				}
			} while((befehl!=FILEEND)&&(test!=FILEEND));
		}
	else printf("Kann Datei >>%s<< nicht îffnen...\n",name);	/* Fehler	*/
	}

/* Hauptfunktion des Programmes									*/
void main(int argc, const char *argv[])
	{
	char dname[80];
	if(argc>1) ausfuehren_datei(argv[1]);
	else
		{
		printf("Dateiname: ");
		scanf("%s",dname);
		ausfuehren_datei(dname);
		}
	exit_all();								/* BGI abmelden	*/
	}
