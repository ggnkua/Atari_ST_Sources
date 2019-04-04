#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>
#include <tos.h>
#include <stdio.h>

#define	DESK	0				/* ID des Desktops */
#define	W_KIND	NAME|CLOSER|FULLER|MOVER|SIZER
#define	EV_KIND	MU_MESAG|MU_TIMER|MU_KEYBD
#define	W_NAME	"  TOS:Clocky  "
#define CNTRL_C	0x2e03		/* Scancode von CTRL-C */
#define	min(a,b)	((a) < (b) ? (a) : (b))
#define	max(a,b)	((a) > (b) ? (a) : (b))
typedef	int boolean;

extern int _app;	/* 0 = Accessory, 1 = Programm */
extern int vdi_handle,phys_handle;
extern int gl_apid;

int		Msgbuf[8]; /* Arbeitspuffer fÅr evnt_multi */
int		wind_handle = -1,
		wx,wy,ww,wh,	 /* Grîûe unseres Fensters */
		dx,dy,dw,dh;		 /* Grîûe des Desktops */
int		menuid;			 /* bei Accessory: MenÅ-ID */
boolean	w_fulled;
boolean done = 0;
int		ur_x = 50,ur_y = 30,ur_w = 130,ur_h = 150;
int		pxarray[128];	/* Array fÅr Clipping-Krd. */
int		xradius,yradius;
int		hour,min;		/* aktuelle Uhrzeit */

/* Funktionsdeklarationen (function prototyping) */
extern void close_vwork(void);
extern boolean open_vwork(void);
void do_multievent(void);
void hndl_window(void);
void do_redraw(int w_handle,int x,int y,int w,int h);
void new_size(int w_handle,int x,int y,int w,int h);
void close_window(int w_handle);
void clipping(int x,int y,int w,int h,boolean mode);
void draw_clock(void);
void line(int hndl, int x,int y,int x2,int y2);
void readtime(void);
boolean open_window(void);
boolean rc_intersect(GRECT *r1, GRECT *r2);

/* Verwaltungsroutine; bearbeitet alle Nachrichten
   von evnt_multi								   */
void do_eventmulti(void)
{
  static int lastmin = -1;
  char	wname[40];	/* Fenstername enthÑlt Uhrzeit */
  int	event,		/* Ergebnis mit Ereignissen */
  		mx,my,		/* Mauskoordinaten */
  		mbutton,	/* Mausknopf */
  		mstate,		/* Status des Mausknopfs */
  		keycode,	/* Scancode einer Tastatureingabe */
		mclicks;	/* Anzahl Mausklicks */

	if (_app) {		/* Accessory-Modus? */
		if (!open_window())	/* Fehler beim ôffnen? */
			return;
	}
	else	/* Falls Accessory, im MenÅ anmelden */
		menuid = menu_register(gl_apid,W_NAME);

	do {
		event = evnt_multi(EV_KIND,
							1,1,1,
							0,0,0,0,0,
							0,0,0,0,0,
							Msgbuf,
							10000,0, /* 10s warten */
							&mx,&my,
							&mbutton,&mstate,
							&keycode,&mclicks);

		wind_update(BEG_UPDATE);/* GEM unterbrechen*/
		if (event & MU_MESAG) /* Fensternachricht? */
			hndl_window();
		if (event & MU_TIMER) { /* Timer abgelaufen*/
			/* Schauen, ob neue Minute angebrochen.
				Wenn ja, dann darstellen		   */
			readtime();
			if ((wind_handle != -1) &&
			   (min != lastmin)) {
			 	lastmin = min;
				/* Neuen Fensternamen setzen */
				sprintf(wname," %02d:%02d ",
						hour,min);
				wind_set(wind_handle,
						WF_NAME,wname,0,0);
				/* Uhr auf neuesten Stand bringen */
				do_redraw(wind_handle,wx,wy,ww,wh);
			}
		}
		if (event & MU_KEYBD)  /* Tastaturereignis */
			if(keycode == CNTRL_C)
				if (wind_handle != -1)
					close_window(wind_handle);
		wind_update(END_UPDATE);
	} while (!done);
}

/* Arbeitet Fensterereignisse ab. */
void hndl_window(void)
{
  int hndl,x,y,w,h,oldww,oldwh;

	hndl = Msgbuf[3];	/* Fenster-ID */
	x = Msgbuf[4];	y = Msgbuf[5];
	w = Msgbuf[6];	h = Msgbuf[7];

	switch (Msgbuf[0]) {
		case AC_OPEN:	/* Accessory îffnen? */
			if ((x == menuid) && (wind_handle == -1))
				open_window();
			break;
		case AC_CLOSE:	/* Acc. wurde geschlossen */
			wind_handle = -1;
			break;
		case WM_REDRAW:	/* Fenster neu zeichnen */
			do_redraw(hndl,x,y,w,h);
			break;
		case WM_CLOSED:	/* Fenster schlieûen */
			close_window(wind_handle);
			break;
		case WM_MOVED:	/* Fenster wurde bewegt */
			new_size(hndl,x,y,w,h);
			break;
		case WM_SIZED:	/* Fenstergrîûe Ñndern */
			oldww = ww;	oldwh = wh;
accept_size:
			new_size(hndl,x,y,w,h);
			/* Bei Vergrîûerung wird Inhalt Åber
				WM_REDRAW gezeichnet, bei Verklei-
				nerung mÅssen wir das selber tuen! */
			if ((ww <= oldww) && (wh <= oldwh))
				do_redraw(hndl,wx,wy,ww,wh);
			break;
		case WM_TOPPED:	/* Fenster wurde aktiviert */
		case WM_NEWTOP:
			wind_set(hndl,WF_TOP,0,0,0,0);
			wind_get(hndl,WF_WORKXYWH,
					&wx,&wy,&ww,&wh);
			break;
		case WM_FULLED:	/* Fenster zoomen */
			if (w_fulled ^= 1)
				wind_get(hndl,WF_FULLXYWH,
						&x,&y,&w,&h);
			else
				wind_get(hndl,WF_PREVXYWH,
						&x,&y,&w,&h);
			wind_get(hndl,WF_WORKXYWH,
					&wx,&wy,&ww,&wh);
			goto accept_size;
	}
}

/* Fenster îffnen */
boolean open_window(void)
{
  int	new;

	wind_get(DESK,WF_WORKXYWH,&dx,&dy,&dw,&dh);
	if ((new = wind_create(W_KIND,dx,dy,dw,dh)) < 0) {
		form_alert(1,"[3][Kann Fenster nicht îffnen]\
[OK]");
		return 0;
	}
	graf_mouse(M_OFF,0);	/* Maus ausschalten */
	wind_set(new,WF_NAME,W_NAME,0,0);
	graf_growbox(0,0,0,0,ur_x,ur_y,ur_w,ur_h);
	wind_open(new,ur_x,ur_y,ur_w,ur_h);
	wind_get(new,WF_WORKXYWH,&wx,&wy,&ww,&wh);
	wind_handle = new;
	w_fulled = 0;
	graf_mouse(M_ON,0);		/* Maus anschalten */
	graf_mouse(ARROW,0);
	return 1;
}

/* Fenster neu zeichnen. fl = 1:alles, 0:nur Zeiger */
void do_redraw(int hndl,int x,int y,int w,int h)
{
  GRECT	t1,t2;

	t2.g_x = x;	t2.g_y = y;
	t2.g_w = w;	t2.g_h = h;
	readtime();	/* Uhrzeit holen */
	graf_mouse(M_OFF,0);	/* Maus ausschalten */

	/* Rechteckliste des AES fÅr Fenster auswerten */
	wind_get(hndl,WF_FIRSTXYWH,
			&t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2,&t1)) {
			clipping(t1.g_x,t1.g_y,t1.g_w,t1.g_h,1);
			draw_clock();
		}
		wind_get(hndl,WF_NEXTXYWH,
				&t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
	clipping(t1.g_x, t1.g_y, t1.g_w, t1.g_h, 0);
	graf_mouse(M_ON,0);
}

/* Fenstergrîûe Ñndern */
void new_size(int w_handle,int x,int y,int w,int h)
{
	ur_x = x;	ur_y = y;	ur_w = w;	ur_h = h;
	wind_set(w_handle,WF_CURRXYWH,x,y,w,h);
	wind_get(w_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);
}

/* Fenster schlieûen */
void close_window(int w_handle)
{
  int	x,y,w,h;

	wind_get(w_handle,WF_CURRXYWH,&x,&y,&w,&h);
	graf_shrinkbox(0,0,0,0,x,y,w,h);
	wind_close(w_handle);
	wind_delete(w_handle);
	wind_handle = -1;
	if (_app)	/* Im Programmodus ganz aufhîren! */
		done = 1;
}

/* Neu zu zeichnenden Fensterbereich errechnen */
boolean rc_intersect(GRECT *r1, GRECT *r2)
{
  int	x,y,w,h;

	x = max(r2->g_x, r1->g_x);
	y = max(r2->g_y, r1->g_y);
	w = min(r2->g_x + r2->g_w, r1->g_x + r1->g_w);
	h = min(r2->g_y + r2->g_h, r1->g_y + r1->g_h);
	r2->g_x = x;	r2->g_y = y;
	r2->g_w = w-x;	r2->g_h = h-y;
	return ( (boolean) ((w > x) && (h > y)) );
}

/* Clipping auf einen bestimmten Bereich setzen */
void clipping(int x,int y,int w,int h,boolean mode)
{
	pxarray[0] = x;		pxarray[1] = y;
	pxarray[2] = x+w-1;	pxarray[3] = y+h-1;
	vs_clip(vdi_handle,mode,pxarray);
}

/* Fenster und Konturen der Uhr zeichnen */
void draw_clock(void)
{
  int xinch,yinch,mx,my;
  double w;

	pxarray[0] = wx;		pxarray[1] = wy;
	pxarray[2] = wx+ww-1;	pxarray[3] = wy+wh-1;

	/* zeichne Hintergrund */
	vsf_color(vdi_handle,0);	/* FÅllfarbe weiû */
	vsf_interior(vdi_handle,1);	/* deckend fÅllen */
	vswr_mode(vdi_handle,MD_REPLACE);
	v_bar(vdi_handle,pxarray);	/* Rechteck fÅllen */
	
	/* Zeichne Uhr ohne Zeiger */
	vsl_type(vdi_handle,1);		/* durchgezogen */
	vsl_width(vdi_handle,1);	/* Linienbreite = 1*/
	vsl_ends(vdi_handle,0,0);	/* Keine Pfeile */
	mx = wx+ww/2;			my = wy+wh/2;
	xradius = ww/2;			yradius = wh/2;
	xradius -= xradius/20;	yradius -= yradius/20;
	v_ellarc(vdi_handle,mx,my,
			xradius,yradius,0,3600);

	/* Zeichne Stundensymbole */
	vsf_color(vdi_handle,1);	/* schwarz */
	xinch = xradius/40;	yinch = yradius/40;
	for (w = 0; w < (2*M_PI); w += M_PI/6) {
		pxarray[0] = mx+
			(int)((double)xradius*sin(w))-xinch;
		pxarray[1] = my+
			(int)((double)yradius*cos(w))-yinch;
		pxarray[2] = pxarray[0]+xinch*2;
		pxarray[3] = pxarray[1]+yinch*2;
		v_bar(vdi_handle,pxarray);
	}

	vsl_ends(vdi_handle,2,1);	/* Pfeilspitzen */
	/* Stundenzeiger */
	w = M_PI-(((double)((hour%12)*60+min)*M_PI)/
			  (double)360);
	vsl_width(vdi_handle,2+xradius/30);
	line(vdi_handle,mx,my,
		mx+(int)((double)(3*xradius/5)*sin(w)),
		my+(int)((double)(3*yradius/5)*cos(w)));

	/* Minutenzeiger */
	w = M_PI-(((double)min*M_PI)/(double)30);
	vsl_width(vdi_handle,2+xradius/70);
	line(vdi_handle,mx,my,
		mx+(int)((double)(9*xradius/10)*sin(w)),
		my+(int)((double)(9*yradius/10)*cos(w)));
}

/* Linie ziehen */
void line(int hndl, int x,int y,int x2,int y2)
{
	pxarray[0] = x;		pxarray[1] = y;
	pxarray[2] = x2;	pxarray[3] = y2;
	v_pline(hndl,2,pxarray);
}

/* Uhrzeit holen */
void readtime(void)
{
  unsigned long ti;

	ti = Gettime();	/* Uhrzeit holen */
	hour = ((int)ti>>11)&0x1f;
	min = ((int)ti>>5)&0x3f;
}

/* Unsere Hauptroutine */
boolean main()
{
	if (open_vwork()) {	/* VDI-Workstation îffnen */
		do_eventmulti();
		close_vwork();
	}
	else {
		form_alert(1,"[3][Initialisierungsfehler]\
[OK]");
		return -1;
	}
	return 0;
}
