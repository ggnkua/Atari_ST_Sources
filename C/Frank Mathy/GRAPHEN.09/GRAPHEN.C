/*		  Graphentheorie - Programm V 0.9		*/
/*			(C) 1991 Frank Mathy/TOS			*/

#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>						/* Vordef. Maximalwerte	*/

#include "GRAPHEN.H"					/* Resource-Definitionen*/

#define MAXECKEN 50						/* Maximale Eckenzahl	*/
#define UNENDLICH 10000					/* Unendlich-Wert		*/

int	work_in[12],
	work_out[57];						/* Externe Variablen	*/

int ap_id;								/* Applikationsnummer	*/
int p_handle;							/* Physik. Handle		*/
int handle;								/* Virtuelles Handle	*/
int zb,zh,bb,bh;						/* Zeichenausmaûe		*/
int m_x,m_y,m_f;						/* Bildsch.-Parameter	*/
int deskx,desky,deskw,deskh;			/* Grîûe des Desktops	*/
int wx,wy,wb,wh;						/* Grîûe des Fensters	*/

int msg[8];								/* GEM-Mitteilungen		*/

char pfad[80] = "A:";					/* Suchpfad				*/
char dateiname[80];						/* Dateiname			*/
char pfadname[80];						/* Pfadname				*/

char *edatum;							/* Eingegebenes Datum	*/

OBJECT *menu;							/* Zeiger auf MenÅbaum	*/
OBJECT *input;							/* Zeiger auf MenÅbaum	*/

int window;								/* Fensterhandle		*/
char *wtitel = " Graphentheorie-Programm V 0.9 von Frank Mathy/TOS (C) 1991";
char *leerinfo = "Bitte Option aus dem MenÅ wÑhlen...";
										/* Fenstertitel/-info	*/
int ende=0;								/* Programmende-Flagge	*/

/* Graphentheorie-Variablen										*/

int digraph=0,bewertet=0;				/* Art des Graphen		*/
unsigned char mindisplay=1;				/* Darstellung ab		*/

/* Datenfelder fÅr den Graphen									*/

int ezahl=0;							/* Eckenzahl			*/
int ex[MAXECKEN],ey[MAXECKEN];			/* Eckenkoordinaten		*/
unsigned am[MAXECKEN][MAXECKEN];		/* Adjazenzmatrix 		*/
unsigned saveam[MAXECKEN][MAXECKEN];	/* Sicherheitspuffer*/
unsigned char show[MAXECKEN][MAXECKEN];	/* Darstellungsmatrix	*/
unsigned char alist[MAXECKEN][MAXECKEN-1];	/* Adjazenzliste	*/
unsigned char azahl[MAXECKEN];

void open_work(void)
	{
	int i;
	ap_id=appl_init();					/* Applikationsnummer	*/
	p_handle=graf_handle(&zb,&zh,&bb,&bh); /* Bildschirm-Handle	*/
	for(i=0; i<10; i++) work_in[i]=1;	/* Auf Eins setzen		*/
	work_in[10]=2;						/* Koordinatensystem	*/
	handle=p_handle;					/* Kopieren				*/
	v_opnvwk(work_in,&handle,work_out);	/* Virtuelle erîffnen	*/
	m_x=work_out[0];
	m_y=work_out[1];
	m_f=work_out[39];
	}

void close_work(void)
	{
	v_clsvwk(handle);					/* Virtuelle abmelden	*/
	appl_exit();						/* Anwendung abmelden	*/
	}

int load_resource(void)
	{
	int test;
	test=rsrc_load("GRAPHEN.RSC");		/* Resource-Datei laden	*/
	if(!test)	form_alert(1,
	"[3][ Kann die Resource-Datei | nicht laden...][ Abbruch ]");
										/* Mitteilung ausgeben	*/
	return(test);						/* ErgebniszurÅckgeben	*/
	}

void fix_resource(void)					/* Adressen ermitteln	*/
	{
	rsrc_gaddr(R_TREE,MENU,&menu);		/* Adresse des MenÅs	*/
	rsrc_gaddr(R_TREE,INFIELD,&input);	/* Adresse des Dialogs	*/

	edatum=input[INPUT].ob_spec.tedinfo->te_ptext;
											/* Eingabetext		*/
	}

void kill_resource(void)
	{
	rsrc_free();
	}

void set_vdi(void)						/* VDI-Parameter setzen	*/
	{
	int i;
	vsf_interior(handle,1);				/* FÅlle Vordergrundf.	*/
	vsf_perimeter(handle,0);			/* Umrandung aus		*/
	vsl_color(handle,1);				/* Linienfarbe 1		*/
	vst_alignment(handle,1,1,&i,&i);	/* Textausrichtung		*/
	}

int min(int w1,int w2)					/* Minimums-Funktion	*/
	{
	return((w1<w2) ? w1 : w2);			/* Kleinerer Wert		*/
	}

int max(int w1,int w2)					/* Maximums-Funktion	*/
	{
	return((w1>w2) ? w1 : w2);			/* Grîûerer Wert		*/
	}

void schnittmenge(int *x1,int *y1,int *b1,int *h1,
					int x2,int y2,int b2,int h2)
										/* Schnittrechteck		*/
	{
	int sx,sy,sx2,sy2;					/* Schnittkoordinaten	*/
	
	sx=max(*x1,x2);						/* X1-Schnittkoordinate	*/
	sy=max(*y1,y2);						/* Y1-Schnittkoordinate	*/
	sx2=min((*x1)+(*b1)-1,x2+b2-1);		/* X2-Schnittkoordinate	*/
	sy2=min((*y1)+(*h1)-1,y2+h2-1);		/* Y2-Schnittkoordinate	*/
	
	*x1=sx;								/* Ergebnis Åbergeben	*/
	*y1=sy;
	*b1=sx2-sx+1;
	*h1=sy2-sy+1;
	}

void fn_concat(char *pfadname,char *pfad,char *dateiname)
	{									/* Erstelle Pfadnamen	*/
	strcpy(pfadname,pfad);				/* Pfad kopieren		*/
	
	while(*pfadname++);					/* Ende finden			*/
	pfadname--;							/* Letztes Zeichen		*/
	while(((*pfadname--)!=92)&&(*pfadname));/* Bis Balken		*/
	pfadname+=2;						/* öbernÑchstes Zeichen	*/
	strcpy(pfadname,dateiname);			/* Dateinamen anhÑngen	*/
	}

void menu_install(void)					/* MenÅ installieren	*/
	{
	menu_bar(menu,1);					/* MenÅ einschalten		*/
	menu_icheck(menu,DIGRAPH,digraph);	/* HÑkchen einstellen	*/
	menu_icheck(menu,BEWERTET,bewertet);
	}

void exit_menu(void)
	{
	menu_bar(menu,0);					/* MenÅ ausschalten		*/
	}

void create_window(void)				/* Fenster erstellen	*/
	{
	window=wind_create(NAME|INFO,deskx,desky,deskw,deskh);
											/* Kartei-Fenster	*/
	wind_set(window,WF_NAME,wtitel);		/* Titel setzen		*/
	wind_set(window,WF_INFO,leerinfo);		/* Info setzen		*/
	graf_growbox(deskw/2-10,deskh/2-10,20,20,
				deskx,desky,deskw,deskh);	/* Animation zeigen	*/	
	wind_open(window,deskx,desky,deskw,deskh);/* Fenster îffnen	*/
	wind_get(window,WF_WORKXYWH,&wx,&wy,&wb,&wh);
	}

void erase_window(void)					/* Fenster lîschen		*/
	{
	wind_close(window);					/* Schlieûe Fenster		*/
	wind_delete(window);				/* Fenster lîschen		*/
	graf_shrinkbox(deskw/2-10,deskh/2-10,20,20,
				deskx,desky,deskw,deskh);	/* Animation zeigen	*/	
	}

int select_datei(void)
	{
	int taste;
	fsel_input(pfad,dateiname,&taste);		/* Dateinamen holen	*/
	fn_concat(pfadname,pfad,dateiname);		/* Pfadname setzen	*/
	return(taste);
	}

void redraw_desk(void)					/* Desktop neuzeichnen	*/
	{
	form_dial(FMD_FINISH,wx,wy,wb,wh,wx,wy,wb,wh);/* Neuzeichnen*/
	}

int inside(int tx,int ty,int tb,int th,
			int rx,int ry,int rb,int rh)	/* Innerhalb ?		*/
	{
	return((tx+tb>rx)&&(tx<rx+rb)&&(ty+th>ry)&&(ty<ry+rh));
	}

/* Funktionen zur Bearbeitung der GEM-Elemente					*/

void wind_redraw(int rwind,int rx,int ry,int rb,int rh)
	{
	int i,j;
	int wrx,wry,wrb,wrh;				/* Fenster-Koordinaten	*/
	int sx,sy,sb,sh;					/* Schnittmenge			*/
	int xy[4];							/* FÅr Zeichenfunktionen*/
	int z,s;							/* Zeile und Spalte		*/
	int clip[4];						/* Clipping-Variablen	*/
	char htext[80];						/* Hilfs-Zeichenkette	*/
	int x1,x2,y1,y2,xm,ym,dx,dy;		/* Rechenvariablen		*/

	wind_update(BEG_UPDATE);		/* GEM-AES informieren	*/
	v_hide_c(handle);				/* Mauszeiger aus		*/
	vsl_color(handle,1);			/* Linienfarbe			*/
	if(digraph) vsl_ends(handle,2,1);	/* Pfeilsp. ein		*/
	else vsl_ends(handle,2,2);		/* Pfeilspitzen aus		*/
	wind_get(rwind,WF_FIRSTXYWH,
				&wrx,&wry,&wrb,&wrh);/* Erstes Rechteck		*/
	while(wrb&&wrh)					/* Solange Rechtecke	*/
		{
		sx=wrx; sy=wry; sb=wrb; sh=wrh;	/* Als Schnittkoord.*/
		schnittmenge(&sx,&sy,&sb,&sh,rx,ry,rb,rh);
									/* Schnittmenge ber.	*/
		if((sb>0)&&(sh>0))			/* Wenn Schnittbereich	*/
		{
		vsf_color(handle,0);		/* Hintergrundfarbe		*/
		clip[0]=sx; clip[1]=sy;		/* Linke obere Ecke		*/
		clip[2]=sx+sb-1;			/* Rechte untere Ecke	*/
		clip[3]=sy+sh-1;
		vs_clip(handle,1,clip);		/* Clipping einschalten	*/
		v_bar(handle,clip);			/* GefÅlltes Rechteck	*/

		vsf_color(handle,1);		/* Zeichenfarbe 1		*/
		if(ezahl) for(i=0; i<ezahl; i++) /* Punkte zeichnen	*/
				{
				xy[0]=ex[i]-1+wx; 	xy[1]=ey[i]-1+wy;
				xy[2]=xy[0]+2;		xy[3]=xy[1]+2;
				v_bar(handle,xy);	/* Rechteck				*/
				}		
		for(z=0; z<ezahl; z++)
		for(s=digraph ? 0 : z; s<ezahl; s++)
		{
		if((show[z][s]>=mindisplay)&&(show[z][s]<=3)&&
			z!=s)
									/* Wenn darzustellen	*/
			{
			switch(show[z][s])
				{
				case 1:	vsl_type(handle,1);	/* Durchgezogen	*/
						vsl_width(handle,1);/* Normalstark	*/
						break;
				case 2:	vsl_type(handle,1);	/* Durchgezogen	*/
						vsl_width(handle,5);/* Fett			*/
						break;
				case 3:	vsl_type(handle,3);	/* Punktiert	*/
						vsl_width(handle,1);/* Normalstark	*/
						break;
				}
			if(digraph)
				{
				x1=ex[z]+wx;	y1=ey[z]+wy;	/* Anfangspunkt	*/
				x2=ex[s]+wx;	y2=ey[s]+wy;	/* Endpunkt		*/
				xm=(x1+x2)>>1;					/* Mittelpunkt	*/
				ym=(y1+y2)>>1;
				dx=((x2-x1)*5)/11;				/* Stauchen		*/
				dy=((y2-y1)*5)/11;
				xy[0]=xm-dx;	xy[1]=ym-dy;	/* Koordinaten	*/
				xy[2]=xm+dx;	xy[3]=ym+dy;
				xy[1]+=(z>s)*2-1;		/* Geraden versetzen	*/
				xy[3]+=(z>s)*2-1;
				}
			else
				{
				xy[0]=ex[z]+wx;	xy[1]=ey[z]+wy;	/* Anfangspunkt	*/
				xy[2]=ex[s]+wx; xy[3]=ey[s]+wy;	/* Endpunkt		*/
				}
			v_pline(handle,2,xy);		/* Kante zeichnen		*/
			if(bewertet)
				{
				if(digraph)
					{
					x1=wx+ex[z]+((ex[s]-ex[z])<<1)/3;	/* Koordin.	*/
					y1=wy+ey[z]+((ey[s]-ey[z])<<1)/3;
					}
				else
					{
					x1=wx+((ex[s]+ex[z])>>1);
					y1=wy+((ey[s]+ey[z])>>1);
					}
				itoa((int) am[z][s],htext,10);
				v_gtext(handle,x1,y1,htext);
				}
			}
		}
		}
		wind_get(rwind,WF_NEXTXYWH,
				&wrx,&wry,&wrb,&wrh);	/* NÑchstes Rechteck*/
		}
	v_show_c(handle,1);				/* Mauszeiger ein		*/
	wind_update(END_UPDATE);		/* GEM-AES informieren	*/
	}

void do_window(void)
	{
	switch(msg[0])
	{
	case WM_REDRAW:	wind_redraw(msg[3],msg[4],msg[5],msg[6],msg[7]);
					break;
	case WM_NEWTOP:
	case WM_TOPPED:
		wind_set(msg[3],WF_TOP);		/* Aktuelles Fenster	*/
		break;
	}	
	}

int do_dialog(int alt)					/* Dialog bearbeiten	*/
	{
	int dx,dy,db,dh,wert;
	
	if(alt>0) sprintf(edatum,"%d",alt);		/* Wert eintragen	*/
	else edatum[0]=0;						/* Leerfeld			*/
	form_center(input,&dx,&dy,&db,&dh);	/* Dialog zentrieren	*/
	form_dial(FMD_START,dx,dy,db,dh,dx,dy,db,dh);	
	objc_draw(input,ROOT,MAX_DEPTH,dx,dy,db,dh);
	do	{
		form_do(input,INPUT);			/* Dialog ausfÅhren		*/
		wert=atoi(edatum);				/* Wert einlesen		*/
		objc_change(input,OKKNOPF,0,dx,dy,db,dh,NORMAL,1);
		} while(!wert);					/* Bis Eingabe OK		*/
	form_dial(FMD_SHRINK,dx+db/2,dy+dh/2,1,1,
				dx,dy,db,dh);			/* Schrumpfende Box		*/
	form_dial(FMD_FINISH,dx,dy,db,dh,
				dx,dy,db,dh);			/* Platz freigeben		*/
	return(wert);						/* Taste zurÅckgeben	*/
	}

/* Eigentliches Graphentheorie-Programm							*/

void noprell(void)						/* Entprellen			*/
	{
	int i;
	evnt_button(1,1,0,&i,&i,&i,&i);		/* Bis Taste losgelassen*/
	}

void save_matrix(void)				/* Adjazenzmatrix sichern	*/
	{
	int z,s;
	for(z=0; z<MAXECKEN; z++)
		for(s=0; s<MAXECKEN; s++)
			saveam[z][s]=am[z][s];		/* Matrix merken		*/
	}
	
void clear_matrix(void)				/* Adjazenzmatrix sichern	*/
	{
	int z,s;
	for(z=0; z<MAXECKEN; z++)
		for(s=0; s<MAXECKEN; s++)
			am[z][s]=0;					/* Matrix lîschen		*/
	}
	
void restore_matrix(void)			/* Alte Adjazenzmatrix		*/
	{
	int z,s;
	for(z=0; z<MAXECKEN; z++)
		for(s=0; s<MAXECKEN; s++)
			am[z][s]=saveam[z][s];		/* Matrix zurÅckholen	*/
	}

void reset_show(void)				/* Attribute aus			*/
	{
	int z,s;
	for(z=0; z<MAXECKEN; z++)
		for(s=0; s<MAXECKEN; s++)
			show[z][s]=(am[z][s]>0);	/* Normale Attribute	*/
	}

int searchpoint(int x,int y)
	{
	int i,result=-1,wx,wy;
	long mindist=LONG_MAX,dist,dx,dy;
	wx=(long) x;						/* Konvertieren			*/
	wy=(long) y;
	if(ezahl) for(i=0; i<ezahl; i++)
		{
		dx=(long) ex[i] - wx;			/* AbstÑnde berechnen	*/
		dy=(long) ey[i] - wy;
		dist=dx*dx+dy*dy;				/* Quadrat. Gesamtabst.	*/
		if(dist<mindist)				/* Wenn kleinster		*/
			{
			mindist=dist;
			result=i;					/* Punkt nehmen			*/
			}
		}
	if(mindist>100) result=-1;			/* Bei zu groûem Abstand*/
	return(result);
	}

void all_new(void)				/* Alles lîschen				*/
	{
	int i,z,s;
	i=form_alert(1,"[2][ Soll alles | gelîscht | werden...? ][ Nein | Ja ]");
	if(i==2)
		{
		ezahl=0;
		for(z=0; z<MAXECKEN; z++)
			for(s=0; s<MAXECKEN; s++)
				am[z][s]=show[z][s]=0;		/* Felder lîschen	*/
		wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
		}
	}

void add_points(void)
	{
	int button,key,mx,my;
	wind_set(window,WF_INFO,"Ecken hinzufÅgen - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh)&&(ezahl<MAXECKEN-1))
	{
	ex[ezahl]=mx-wx;						/* Punkt zufÅgen	*/
	ey[ezahl++]=my-wy;
	wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void move_points(void)
	{
	int button,key,mx,my,ap;
	wind_set(window,WF_INFO,"Ecke verschieben - Ecke wÑhlen - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);			/* Punkt suchen	*/
	if(ap!=-1)
		{
		wind_set(window,WF_INFO,"Ecke verschieben - Neue Position wÑhlen");
		evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
		noprell();
		if((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
			{
			ex[ap]=mx-wx;					/* Neue Position	*/
			ey[ap]=my-wy;
			wind_redraw(window,wx,wy,wb,wh);/* Neuzeichnen		*/
			}
		}
	wind_set(window,WF_INFO,"Ecke verschieben - Ecke wÑhlen - FÅr Ende bitte hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void del_points(void)
	{
	int button,key,mx,my,ap,i,z,s;
	wind_set(window,WF_INFO,"Ecken lîschen - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);			/* Punkt suchen		*/
	if(ap!=-1)
		{
		for(i=ap; i<ezahl; i++)
			{
			ex[i]=ex[i+1];					/* Koordinaten vers.*/
			ey[i]=ey[i+1];
			}
		ezahl--;							/* Eine Ecke weniger*/
		if(ap!=MAXECKEN-1)			/* Wenn nicht letzter Punkt	*/
		{
		for(z=ap; z<MAXECKEN-1; z++)
			for(s=0; s<MAXECKEN; s++)
				{
				am[z][s]=am[z+1][s];		/* Zeilen hochsch.	*/
				show[z][s]=show[z+1][s];
				}
		for(s=ap; s<MAXECKEN-1; s++)
			for(z=0; z<MAXECKEN; z++)
				{
				am[z][s]=am[z][s+1];		/* Spalten linkss.	*/
				show[z][s]=show[z][s+1];
				}
		}
		for(i=0; i<MAXECKEN; i++)
			am[i][MAXECKEN-1]=am[MAXECKEN-1][i]=show[i][MAXECKEN-1]=show[MAXECKEN-1][i]=0;
		wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
		}
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void eckeninfo(void)
	{
	int button,key,mx,my,ap,i;
	char text[80];
	wind_set(window,WF_INFO,"Eckeninfo (Ecke wÑhlen) - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		if(!digraph)
			{
			int grad=0;
			for(i=0; i<ezahl; i++)
				if(am[ap][i]) grad++;
			sprintf(text,"[0][ Ecke %d | Position: (%d,%d) | Grad = %d ][ OK ]",
						ap,ex[ap],ey[ap],grad);
			}
		else
			{
			int egrad=0,agrad=0;
			for(i=0; i<ezahl; i++)
				{
				if(am[ap][i]) agrad++;
				if(am[i][ap]) egrad++;
				}
			sprintf(text,"[0][ Ecke %d | Position: (%d,%d) | Eingrad = %d | Ausgrad = %d ][ OK ]",
						ap,ex[ap],ey[ap],egrad,agrad);
			}
		form_alert(1,text);					/* Daten ausgeben	*/
		}
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void add_lines(void)
	{
	int button,key,mx,my,ap,ep;
	wind_set(window,WF_INFO,"Kante hinzufÅgen (Anfangsecke) - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		wind_set(window,WF_INFO,"Kante hinzufÅgen (Endecke)");
		evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
		noprell();
		ep=searchpoint(mx-wx,my-wy);
		if((ep!=-1)&&(ep!=ap)&&(!am[ap][ep]))
			{
			am[ap][ep]= bewertet ? do_dialog(0) : 1;
			show[ap][ep]=1;
			if(!digraph)							/* Nicht bewertet	*/
				{
				am[ep][ap]=am[ap][ep];
				show[ep][ap]=1;
				}
			wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/
			}
		}
	wind_set(window,WF_INFO,"Kante hinzufÅgen (Anfangsecke) - FÅr Ende bitte hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void del_lines(void)
	{
	int button,key,mx,my,ap,ep;
	wind_set(window,WF_INFO,"Kante lîschen (Anfangsecke) - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		wind_set(window,WF_INFO,"Kante lîschen (Endecke)");
		evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
		noprell();
		ep=searchpoint(mx-wx,my-wy);
		if((ep!=-1)&&(ep!=ap)&&(am[ap][ep]))
			{
			am[ap][ep]=show[ap][ep]=0;
			if(!digraph) am[ep][ap]=show[ep][ap]=0;
			wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/
			}
		}
	wind_set(window,WF_INFO,"Kante lîschen (Anfangsecke) - FÅr Ende bitte hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void set_values(void)
	{
	int button,key,mx,my,ap,ep;
	wind_set(window,WF_INFO,"Bewertung Ñndern (Anfangsecke wÑhlen) - FÅr Ende bitte hier klicken...");
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		wind_set(window,WF_INFO,"Bewertung Ñndern (Endecke wÑhlen)");
		evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
		noprell();
		ep=searchpoint(mx-wx,my-wy);
		if((ep!=-1)&&(ep!=ap)&&(am[ap][ep]))
			{
			am[ap][ep]=do_dialog(am[ap][ep]);	/* Einlesen		*/
			if(!digraph) am[ep][ap]=am[ap][ep];
			wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen	*/
			}
		}
	wind_set(window,WF_INFO,"Bewertung Ñndern (Anfangsecke wÑhlen) - FÅr Ende bitte hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten	*/
	noprell();
	}
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void warshall(void)
	{
	int button,key,mx,my,ap,i;
	int iter,z,s;
	wind_update(BEG_MCTRL)		;		/* GEM-AES informieren	*/
	save_matrix();						/* Alte Matrix sichern		*/

	for(iter=0; iter<ezahl; iter++)		/* Warshall-Algorithmus		*/
		for(z=0; z<ezahl; z++)
			for(s=0; s<ezahl; s++)
				if((am[z][iter])&&(am[iter][s]))
					{
					if(!am[z][s]) show[z][s]=4;		/* Markieren	*/
					am[z][s]=1;			/* Kante setzen(erreichbar)	*/
					}
	
	wind_set(window,WF_INFO,"Warshall-Erreichbarkeiten (Anfangssecke wÑhlen) - FÅr Ende hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		for(i=0; i<ezahl; i++)
			{
			if(show[ap][i]==4) show[ap][i]=3;	/* Gestrichelt		*/
			if(!digraph&&(show[i][ap]==4)) show[i][ap]=3;
			}
		wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/	
		}
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten	*/
	noprell();
	if(ap!=-1) for(i=0; i<ezahl; i++)
		{
		if(show[ap][i]==3) show[ap][i]=4;	/* Nicht sichtbar	*/
		if(!digraph&&(show[i][ap]==3)) show[i][ap]=4;
		}
	}
	wind_set(window,WF_INFO,leerinfo);
	restore_matrix();						/* Alte Matrix		*/
	reset_show();							/* Normaldarstellung*/
	wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/
	wind_update(END_MCTRL);				/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void floyd(void)
	{
	int button,key,mx,my,ap;
	int iter,z,s,i;
	wind_set(window,WF_INFO,"Floyd - kÅrzeste Wege (Anfangsecke wÑhlen) - FÅr Ende hier klicken...");
	wind_update(BEG_MCTRL);				/* GEM-AES informieren		*/
	save_matrix();						/* Alte Matrix sichern		*/

	for(z=0; z<ezahl; z++)				/* Matrix initialisieren	*/
		for(s=0; s<ezahl; s++)
			if(!am[z][s])
				if(z==s) 	am[z][s]=0;
				else		am[z][s]=UNENDLICH;

	for(iter=0; iter<ezahl; iter++)		/* Floyd-Algorithmus	*/
		for(z=0; z<ezahl; z++)
			for(s=0; s<ezahl; s++)
				if(am[z][s]>am[z][iter]+am[iter][s])
					{
					am[z][s]=am[z][iter]+am[iter][s];
					show[z][s]=4;		/* Markieren			*/
					}

	for(z=0; z<ezahl; z++)				/* Matrix korrigieren	*/
		for(s=0; s<ezahl; s++)
			if(am[z][s]==UNENDLICH)
				am[z][s]=0;

	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ap=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if(ap!=-1)
		{
		for(i=0; i<ezahl; i++)
			{
			if(show[ap][i]==4) show[ap][i]=3;	/* Gestrichelt		*/
			if((show[i][ap]==4)&&!digraph)
				show[i][ap]=3;
			}
		wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/	
		}
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten		*/
	noprell();
	if(ap!=-1) for(i=0; i<ezahl; i++)
			{
			if(show[ap][i]==3) show[ap][i]=4;	/* Unsichtbar		*/
			if((show[i][ap]==3)&&!digraph)
				show[i][ap]=4;
			}
	}
	restore_matrix();							/* Alte Matrix		*/
	reset_show();								/* Normaldarstellung*/
	wind_redraw(window,wx,wy,wb,wh);			/* Neuzeichnen		*/
	wind_update(END_MCTRL);					/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void dijkstra(void)
	{
	int button,key,mx,my,ap,ep;
	int iter,i,j,minwert,mineck;
	unsigned char s[MAXECKEN];
	unsigned d[MAXECKEN],w[MAXECKEN];
	char text[80];

	wind_set(window,WF_INFO,"Dijkstra - kÅrzeste Wege (Anfangsecke wÑhlen) - FÅr Ende hier klicken...");
	wind_update(BEG_MCTRL);				/* GEM-AES informieren		*/

	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	ap=searchpoint(mx-wx,my-wy);			/* Punkt suchen		*/
	noprell();


	if((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh)&&(ap!=-1))
	{
	/* Jetzt folgt der Dijkstra-Algorithmus						*/
	
	for(i=0; i<ezahl; i++)			/* Felder initialisieren	*/
		{
		s[i]=(i==ap) ? 1 : 0;				/* Menge setzen		*/
		d[i]=(am[ap][i]>0) ? am[ap][i] : UNENDLICH;	/* AbstÑnde	*/
		w[i]=(d[i]<UNENDLICH) ? ap : 0;		/* RÅcksprÅnge		*/
		}

	for(iter=1; iter<ezahl; iter++)			/* Iterationen		*/
		{
		mineck=minwert=UNENDLICH;			/* Initialisieren	*/
		for(i=0; i<ezahl; i++)				/* Durchsuche nach	*/
			if((d[i]<minwert)&&(!s[i]))		/* Minimaler Kante	*/
				{
				mineck=i;					/* Minimale Ecke	*/
				minwert=d[i];
				}
		if(mineck==UNENDLICH) break;		/* Wenn keine Kante	*/
		else s[mineck]=1;					/* In Menge eintr.	*/

		for(i=0; i<ezahl; i++)				/* FÅr alle Ecken...*/
			if((am[mineck][i])&&(d[i]>d[mineck]+am[mineck][i])&&(!s[i]))
				{							/* Wenn besser err.	*/
				d[i]=d[mineck]+am[mineck][i];	/* Neue Distanz	*/
				w[i]=mineck;					/* Neuer Weg	*/
				}
		}

	wind_set(window,WF_INFO,"Dijkstra - kÅrzeste Wege (Endecke wÑhlen) - FÅr Ende hier klicken...");
	evnt_button(1,1,1,&mx,&my,&button,&key);/* Maustasten	*/
	noprell();
	while((mx>=wx)&&(mx<wx+wb)&&(my>=wy)&&(my<wy+wh))
	{
	ep=searchpoint(mx-wx,my-wy);				/* Punkt suchen		*/
	if((ep!=-1)&&(ep!=ap))
		{
		if(d[ep]!=UNENDLICH)
			{
			sprintf(text,"Abstand = %d, bitte neue Endecke wÑhlen oder Ende...",d[ep]);
			wind_set(window,WF_INFO,text);
			reset_show();						/* Normaldarstellung*/
			i=ep;
			while(i!=ap)
				{
				show[w[i]][i]=2;				/* Weg markieren	*/
				if(!digraph) show[i][w[i]]=2;	/* Wenn kein Digraph*/
				i=w[i];							/* Neuer Punkt		*/
				}
			wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
			}
		else
			{
			wind_set(window,WF_INFO,"Endpunkt nicht erreichbar, bitte neue Endecke wÑhlen oder Ende...");
			reset_show();						/* Normaldarstellung*/
			wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
			}
		}
	evnt_button(1,1,1,&mx,&my,&button,&key);	/* Maustasten		*/
	noprell();
	}
	}
	wind_set(window,WF_INFO,leerinfo);
	reset_show();								/* Normaldarstellung*/
	wind_redraw(window,wx,wy,wb,wh);			/* Neuzeichnen		*/
	wind_update(END_MCTRL);					/* GEM-AES informieren	*/
	}

void prim(void)					/* Prim-Algorithmus fÅr MAB		*/
	{
	int z,s,ij_wert,i,j,u[MAXECKEN],uzahl=0,kosten=0;
	char text[80];

	wind_update(BEG_MCTRL);					/* GEM-AES informieren	*/
	for(z=0; z<ezahl; z++)
		for(s=0; s<ezahl; s++)
			show[z][s]=0;					/* Nicht darstellen	*/
	for(i=1; i<ezahl; i++) u[i]=0;			/* Menge lîschen	*/
	u[0]=1;									/* Erste Ecke eintr.*/
	uzahl++;

	while(uzahl<ezahl)						/* Bis alle Ecken	*/
		{
		ij_wert=UNENDLICH;
		for(z=0; z<ezahl; z++)				/* Ab Zeile 1		*/
			for(s=0; s<ezahl; s++)
				if((am[z][s]<ij_wert)&&am[z][s]&&u[z]&&!u[s])
					{						/* Kriterien erfÅllt*/
					i=z;	j=s;			/* Position merken	*/
					ij_wert=am[z][s];		/* Wert merken		*/
					}
		if(ij_wert==UNENDLICH) break;
		else								/* Kante gefunden	*/
			{
			show[i][j]=show[j][i]=1;		/* Kante darstellen	*/
			kosten+=ij_wert;				/* Kosten erhîhen	*/
			u[j]=1;							/* In Menge eintr.	*/
			uzahl++;
			}
		}
	
	if(ij_wert!=UNENDLICH)
		sprintf(text,"Prim-MAB mit Kosten %d, fÅr Ende bitte klicken...",kosten);
	else
		sprintf(text,"Kein zusammenhÑngender Graph, fÅr Ende bitte klicken...");
	wind_set(window,WF_INFO,text);
	wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
	evnt_button(1,1,1,&i,&i,&i,&i);		/* Maustasten		*/
	noprell();
	
	reset_show();						/* Normaldarstellung*/
	wind_redraw(window,wx,wy,wb,wh);	/* Neuzeichnen		*/
	wind_update(END_MCTRL);					/* GEM-AES informieren	*/
	wind_set(window,WF_INFO,leerinfo);
	}

void lade_daten(void)						/* Daten einlesen	*/
	{
	char text[4];
	int datei,z,s,w2b,w2h,i;
	dateiname[0]=0;								/* Namen lîschen*/
	wind_set(window,WF_INFO,"Lade Graphen...");
	if(select_datei())						/* Dateinamen lesen	*/
		if((datei=Fopen(pfadname,0))>=0)		/* Datei îffnen	*/
		{
		graf_mouse(BUSYBEE,0);					/* Mauszeiger	*/
		Fread(datei,4L,text);					/* Header		*/
		if(!strncmp(text,"GRAP",4))
		{
		for(z=0; z<MAXECKEN; z++)
			for(s=0; s<MAXECKEN; s++)
				am[z][s]=0;					/* Matrix lîschen	*/
		Fread(datei,sizeof(digraph),&digraph);	/* Flaggen		*/
		Fread(datei,sizeof(bewertet),&bewertet);
		Fread(datei,sizeof(ezahl),&ezahl);
		Fread(datei,sizeof(w2b),&w2b);			/* Andere Grîûe	*/
		Fread(datei,sizeof(w2h),&w2h);
		Fread(datei,sizeof(int)*ezahl,ex);		/* Koordinaten	*/
		Fread(datei,sizeof(int)*ezahl,ey);
		for(z=0; z<ezahl; z++)
			Fread(datei,ezahl*sizeof(unsigned),&am[z][0]);
		Fclose(datei);
		
		if((w2b!=wb)||(w2h!=wh))
			{
			wind_set(window,WF_INFO,"Konvertiere Koordinaten");
			for(i=0; i<ezahl; i++)
			{
			ex[i]=(int) (((long)ex[i] * (long)wb)/(long) w2b);
			ey[i]=(int) (((long)ey[i] * (long)wh)/(long) w2h);
			}
			}
		}
		else form_alert(1,"[3][ | Falsches | Dateiformat... ][ OK ]");
		}
		else form_alert(1,"[3][ | Diskettenfehler... ][ OK ]");
	for(z=0; z<ezahl; z++)
		for(s=0; s<ezahl; s++)
			show[z][s]=(am[z][s]>0);	/* Darstellungsmatrix	*/
	menu_icheck(menu,DIGRAPH,digraph);	/* HÑkchen setzen		*/
	menu_icheck(menu,BEWERTET,bewertet);
	wind_redraw(window,wx,wy,wb,wh);		/* Neuzeichnen		*/
	wind_set(window,WF_INFO,leerinfo);
	graf_mouse(THIN_CROSS,0);				/* Mauszeiger		*/
	}

void sichere_daten(void)					/* Datenspeicherung	*/
	{
	int datei,z;
	wind_set(window,WF_INFO,"Sichere Graphen...");
	if(select_datei())						/* Dateinamen lesen	*/
		{
		if(strchr(dateiname,(int) '.')==NULL)
			strcat(pfadname,".GPH");
		if((datei=Fcreate(pfadname,0))>=0)	/* Datei erzeugen	*/
		{
		graf_mouse(BUSYBEE,0);					/* Mauszeiger	*/
		Fwrite(datei,4L,"GRAP");				/* Header		*/
		Fwrite(datei,sizeof(digraph),&digraph);	/* Flaggen		*/
		Fwrite(datei,sizeof(bewertet),&bewertet);
		Fwrite(datei,sizeof(ezahl),&ezahl);
		Fwrite(datei,sizeof(wb),&wb);			/* Fenstermaûe	*/
		Fwrite(datei,sizeof(wh),&wh);
		Fwrite(datei,sizeof(int)*ezahl,ex);		/* Koordinaten	*/
		Fwrite(datei,sizeof(int)*ezahl,ey);
		for(z=0; z<ezahl; z++)					/* Adj.-Matrix	*/
			Fwrite(datei,ezahl*sizeof(unsigned),&am[z][0]);
		Fclose(datei);
		}
		else form_alert(1,"[3][ | Diskettenfehler... ][ OK ]");
		}
	wind_set(window,WF_INFO,leerinfo);
	graf_mouse(THIN_CROSS,0);					/* Mauszeiger	*/
	}

/* Hauptschleifen des Programmes								*/

void do_menu(void)							/* MenÅ-Bearbeitung	*/
	{
	int i,z,s,p[4];
	char text[80];
	switch(msg[4])
		{
		case INFORM:	i=0;						/* ZÑhler 0	*/
						for(z=0; z<ezahl; z++)
							for(s=0; s<ezahl; s++)
								if(am[z][s]) i++;
						if(!digraph) i>>=1;		/* Kein Digraph	*/
						sprintf(text,"[1][ Graphentheorie-Programm V 0.9| (C) 1991 Frank Mathy/TOS | %d Ecken | %d Kanten ][ OK ]",ezahl,i);
						form_alert(1,text);
						break;
		case LOAD:		lade_daten();
						break;
		case SAVE:		sichere_daten();
						break;
		case DRUCK:		if(Cprnos())
							{
							v_hide_c(handle);
							Scrdmp();		/* Hardcopy		*/
							v_show_c(handle,1);
							}
						else form_alert(1,"[3][ | Drucker nicht | bereit... ][ OK ]");
						break;
		case END:		ende=form_alert(1,"[2][ | Wollen Sie die | Arbeit beenden...? ][ Nein | Ja ]")-1;
						break;
		case EADD:		add_points();	/* Punkte hinzufÅgen	*/
						break;
		case EDEL:		del_points();	/* Punkte lîschen		*/
						break;
		case EMOVE:		move_points();	/* Punkte verschieben	*/
						break;
		case EINFO:		eckeninfo();	/* Info zu Ecken		*/
						break;
		case KADD:		add_lines();	/* Kanten hinzufÅgen	*/
						break;
		case KDEL:		del_lines();	/* Kanten lîschen		*/
						break;
		case VALUE:		set_values();	/* Bewertungen setzen	*/
						break;
		case ERASE:		all_new();		/* Alles lîschen		*/
						break;
		case WARSHALL:	warshall();		/* Erreichbarkeit		*/
						break;
		case FLOYD:		floyd();		/* KÅrzeste Wege		*/
						break;
		case DIJKSTRA:	dijkstra();		/* Dijkstra-Algorithmus	*/
						break;
		case PRIM:		prim();			/* Prim-Alg. fÅr MAB	*/
						break;
		case DIGRAPH:	if(digraph)
							{
							i=form_alert(1,"[2][ Umschalten auf | ungerichtete | Graphen...? ][ Ja | Nein ]");
							if(i==1)
								{
								for(z=0; z<MAXECKEN; z++) for(s=0; s<=z; s++)
									{
									am[z][s]=am[s][z]=max(am[z][s],am[s][z]);
									show[z][s]=show[s][z]=max(show[z][s],show[s][z]);
									}
								menu_icheck(menu,DIGRAPH,digraph=0);
								wind_redraw(window,wx,wy,wb,wh);
								}
							}
						else
							{
							menu_icheck(menu,DIGRAPH,digraph=1);
							wind_redraw(window,wx,wy,wb,wh);
							}
						break;
		case BEWERTET:	menu_icheck(menu,BEWERTET,bewertet^=1);
						wind_redraw(window,wx,wy,wb,wh);
						break;
		}
	menu_tnormal(menu,msg[3],1);			/* Kopfzeile normal	*/
	}

void zentral(void)
	{
	int event,i,mx,my,button,tasten,clicks,asc;
	do
	{
	i=ezahl>1;
	menu_ienable(menu,EDEL,i);	/* MenÅpunkte ein-/ausschalten	*/
	menu_ienable(menu,EMOVE,i);
	menu_ienable(menu,EINFO,i);
	menu_ienable(menu,KADD,i);
	menu_ienable(menu,KDEL,i);
	menu_ienable(menu,ERASE,i);
	menu_ienable(menu,SAVE,i);
	menu_ienable(menu,DRUCK,i);
	menu_ienable(menu,WARSHALL,i&&!bewertet);
	menu_ienable(menu,DIJKSTRA,i&&bewertet);
	menu_ienable(menu,FLOYD,i&&bewertet);
	menu_ienable(menu,PRIM,i&&bewertet&&!digraph);
	menu_ienable(menu,TSUCH,0);
	menu_ienable(menu,BSUCH,0);
	menu_ienable(menu,VALUE,bewertet);
	event=evnt_multi(MU_BUTTON|MU_MESAG,
											/* Aktive Events	*/
					2,1,1,					/* Maustasten-Event	*/
					0,0,0,0,0,				/* Mausbewegung 1	*/
					0,0,0,0,0,				/* Mausbewegung 2	*/
					msg,					/* Mitteilungs-Event*/
					0,0,					/* Timer-Event 		*/
					&mx,&my,				/* Mausposition		*/
					&button,&tasten,		/* Tastenwerte		*/
					&asc,					/* ASCII-Tastenwert	*/
					&clicks);				/* Tastenclicks		*/
	
	if(event&MU_BUTTON) event=0;	
	if(event&MU_MESAG)
		switch(msg[0])
			{
			case MN_SELECTED:	do_menu();
								break;
			case WM_REDRAW:		
			case WM_NEWTOP:
			case WM_TOPPED:		do_window();
								break;
			}
	} while(!ende);
	}

void main(void)
	{
	int test,z,s,i;

	for(z=0; z<MAXECKEN; z++)
		for(s=0; s<MAXECKEN; s++)
			am[z][s]=show[z][s]=0;	/* Matrizen lîschen			*/
	
	pfad[0]=Dgetdrv()+65;			/* Laufwerksnummer			*/
	Dgetpath(&pfad[2],0);			/* Aktueller Pfad			*/
	strcat(pfad,"\\*.GPH");			/* Extension				*/
	
	open_work();					/* Arbeitsstation îffnen	*/
	set_vdi();						/* VDI-Parameter setzen		*/
	wind_get(0,WF_WORKXYWH,&deskx,
				&desky,&deskw,&deskh);/* Grîûe des Desktop		*/
	test=load_resource();			/* Resource-Datei laden		*/
	graf_mouse(THIN_CROSS,0);		/* Mauszeigerform			*/
	
	if(test)
		{
		fix_resource();				/* Objektadresse ermitteln	*/
		menu_install();				/* MenÅ einschalten			*/
		create_window();			/* Fenster erstellen		*/
		
		zentral();					/* Hauptschleife			*/
		
		erase_window();				/* Fenster lîschen			*/
		exit_menu();				/* MenÅ ausschalten			*/		
		kill_resource();			/* Resourcen freigeben		*/
		}

	close_work();					/* Arbeitsstation schlieûen	*/
	}
