/********************************************************************/
/*								WATOR_G.C							*/
/*						GEM-Modul fÅr WATOR.PRG						*/
/*																	*/
/*	R. Geisler  1988							Sprache: Megamax C	*/
/********************************************************************/


#include <ctype.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <string.h>
#include "wator.h"
#define XMAX 79						/*	Maximalgrîûe des Ozeans		*/
#define YMAX 45
#define EMPTY 32					/*	Codes fÅr Simulation		*/
#define FISH 250
#define SHARK 111
#define BAR 7
#define TRUE 1						/*	logische Werte				*/
#define FALSE 0
#define NO_ATTR 0					/*	fÅr Dateifunktionen			*/
#define WRONLY 1
#define OCN 0						/*	Fensternummern				*/
#define PRO 1
#define PHA 2
#define LOW 0						/*	Auflîsung					*/
#define HIGH 2
#define Ntot(t, ob, n) ntoa(n, ((TEDINFO *)(t)[ob].ob_spec)->te_ptext)
#define Tton(t, ob) aton(((TEDINFO *)(t)[ob].ob_spec)->te_ptext)
#define Form_error(err) form_error(-31>(err)?-31-(err):32767)


struct ocean						/*	Variablen fÅr Simulation...	*/
{	
	unsigned char state;
	char moved;
	int age;
	int starve;
}
pos[XMAX][YMAX];
int nfish=400, nshark=40, fbreed=3, sbreed=10, starve=3, xsize=40, 
	ysize=40;
struct windows						/*	Variablen fÅr Fenster...	*/
{	
	int kind;
	GRECT curr;
	GRECT work;
	char *name;
	char *info;
	int handle;
	FDB fdb;
}
wi[]=
{
	{	
		NAME|CLOSER|MOVER, 159, 40, 322, 340
	},
	{	
		NAME|CLOSER|FULLER|MOVER|INFO|SIZER, 420, 30, 190, 360
	},
	{	
		NAME|CLOSER|MOVER, 30, 30, 340, 360
	}
};
int slot[8], xdesk, ydesk, wdesk, hdesk, gl_wbox, gl_hbox;
FDB scrfdb;
int handle, contrl[12], intin[128], ptsin[128], intout[128],
	ptsout[128], work_out[57], work_in[11]=	/*	Variablen fÅr VDI	*/
{	
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2
};
int xmax=XMAX, ymax=YMAX, area;		/*	fÅr Ozean					*/
int invl=2, pwid=51, plot=TRUE;		/*	fÅr Protokoll				*/
int xpha=30, ypha=30, wpha=280, hpha=280, fscal=100, sscal=25, 
	curve=TRUE;						/*	fÅr Phasendiagramm			*/
unsigned int aton(), time;			/*	sonstige Variablen...		*/
int mmode=FISH, cfish, cshark, run, fd, m1flags, mox, moy, dummy;
OBJECT *menu_t, *about_t, *ocnpar_t, *propar_t, *phapar_t, *file_t, 
	*string_t;


main()								/*	Hauptfunktion				*/
{	
	if(init())
		multi();
	quit();
}


init()								/*	Programm initialisieren		*/
{	
	int no;
	appl_init();					/*	AES...						*/
	handle=graf_handle(&dummy, &dummy, &gl_wbox, &gl_hbox);	
	v_opnvwk(work_in, &handle, work_out);	/*	VDI...				*/
	vst_height(handle, 6, &dummy, &dummy, &dummy, &dummy);
	vsm_type(handle, 2);
	if(!rsrc_load("wator.rsc"))		/*	Resources...				*/
	{	
		graf_mouse(ARROW, 0L);
		form_alert(1, "[3][|WATOR.RSC fehlt!][ABBRUCH]");
		return FALSE;
	}
	graf_mouse(ARROW, 0L);
	rsrc_gaddr(R_TREE, MENU_T, &menu_t);
	rsrc_gaddr(R_TREE, ABOUT_T, &about_t);
	rsrc_gaddr(R_TREE, OCNPAR_T, &ocnpar_t);
	rsrc_gaddr(R_TREE, PROPAR_T, &propar_t);
	rsrc_gaddr(R_TREE, PHAPAR_T, &phapar_t);
	rsrc_gaddr(R_TREE, FILE_T, &file_t);
	rsrc_gaddr(R_TREE, STRING_T, &string_t);
	strcpy(((TEDINFO *)file_t[PATH].ob_spec)->te_ptext, "WATOR.OUT");
	if(Getrez()!=HIGH)				/*	y-Auflîsung anpassen		*/
	{	
		ymax=21;
		ysize/=2;
		nfish/=2;
		nshark/=2;
		wi[OCN].curr.g_y=20;
		wi[PRO].curr.g_y/=2;
		wi[PRO].curr.g_h/=2;
		ypha/=2;
		hpha/=2;
		wi[PHA].curr.g_y/=2;
		wi[PHA].curr.g_h/=2;
	}
	if(Getrez()==LOW)				/*	x-Auflîsung anpassen		*/
	{	
		xmax=38;
		xsize/=2;
		nfish/=2;
		nshark/=2;
		wi[OCN].curr.g_x=79;
		pwid=11;
		wi[PRO].curr.g_x=120;
		xpha/=2;
		wpha/=2;
		wi[PHA].curr.g_x/=2;
		wi[PHA].curr.g_w/=2;
	}
	for(no=0; no<3; no++)			/*	Fenster...					*/
		if(!buf_alloc(no))
		{	
			form_alert(1, string_t[AL_MEM].ob_spec);
			return FALSE;
		}
	wi[OCN].name=string_t[TI_OCN].ob_spec;
	wi[PRO].name=string_t[TI_PRO].ob_spec;
	wi[PRO].info=string_t[IN_PRO].ob_spec;
	wi[PHA].name=string_t[TI_PHA].ob_spec;
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	menu_bar(menu_t, 1);			/*	Desktop aufbauen			*/
	new_ocn();
	wi_create(OCN);
	run=FALSE;
	return TRUE;					/*	in Ordnung					*/
}


multi()								/*	Event-Verarbeitung			*/
{	
	int evt, msg[8];
	for(; ; )
	{	
		evt=evnt_multi(MU_BUTTON|MU_M1|MU_MESAG|MU_TIMER, 1, 1, 1,
			m1flags, wi[OCN].work.g_x, wi[OCN].work.g_y, 
			wi[OCN].work.g_w, wi[OCN].work.g_h, 0, 0, 0, 0, 0, 
			msg, 0, 0, &mox, &moy, &dummy, &dummy, &dummy, &dummy);	
		if(evt&MU_BUTTON)			/*	Mausknopf-Event				*/
			ev_button();
		if(evt&MU_M1)				/*	Maus-Event					*/
			ev_mouse();
		if(evt&MU_MESAG)			/*	Message-Event				*/
			switch(msg[0])
			{
				case MN_SELECTED:	/*	MenÅ-Message				*/
				switch(msg[3])
				{
					case DESK:			/*	Info zeigen				*/
					use_form(about_t, 0);
					break;
					
					case FILE:
					switch(msg[4])
					{
						case F_OPEN:	/*	Datei îffnen			*/
						f_open();
						break;		
						
						case F_CLOSE:	/*	schlieûen				*/
						f_close();
						break;
						
						case F_HEADER:	/*	Kopf schreiben			*/
						f_header();
						break;
						
						case QUIT:	/*	Programmende				*/
						return;
					}
					break;

					case WINDOWS:
					switch(msg[4])
					{
						case OCEAN:	/*	Ozean						*/
						if(!wi_create(OCN))
							form_alert(1, string_t[AL_WIND].ob_spec);
						break;
						
						case PHASEDIA:	/*	Phasendiagramm			*/
						if(!wi_create(PHA))
							form_alert(1, string_t[AL_WIND].ob_spec);
						break;
						
						case PROTOCOL:	/*	Protokoll				*/
						if(!wi_create(PRO))
							form_alert(1, string_t[AL_WIND].ob_spec);
						break;
						
						case M_FISH:	/*	Fische setzen			*/
						mmode=FISH;
						break;
						
						case M_SHARK:	/*	Haie ...				*/
						mmode=SHARK;
						break;
						
						case M_BAR:		/*	Barrieren ...			*/
						mmode=BAR;
						break;
						
						case M_EMPTY:	/*	lîschen					*/
						mmode=EMPTY;
					}
					menu_icheck(menu_t, M_EMPTY, mmode==EMPTY);
					menu_icheck(menu_t, M_FISH, mmode==FISH);
					menu_icheck(menu_t, M_SHARK, mmode==SHARK);
					menu_icheck(menu_t, M_BAR, mmode==BAR);
					break;
									
					case PARAMS:
					switch(msg[4])
					{	
						case PROPARS:	/*	Parameter fÅr Protokoll	*/
						dial_pro();
						break;
						
						case PHAPARS:	/*	... Phasendiagramm		*/
						dial_pha();
						break;
						
						case OCNPARS:	/*	... Ozean				*/
						dial_ocn();
						break;
							
						case NEW:	/*	Neustart					*/
						new_ocn();
						break;
												
						case START:	/*	Start						*/
						run=TRUE;
						break;
						
						case STOP:	/*	Stop						*/
						run=FALSE;
					}
				}
				menu_tnormal(menu_t, msg[3], TRUE);
				break;
				
				case WM_REDRAW:		/*	Fenster-Messages...			*/
				wi_redraw(slot[msg[3]], msg[4], msg[5], msg[6], 
					msg[7]);
				break;
				
				case WM_TOPPED:
				wi_top(slot[msg[3]]);
				break;
				
				case WM_CLOSED:
				wi_delete(slot[msg[3]]);
				break;
				
				case WM_FULLED:
				wi_full(slot[msg[3]]);
				break;
				
				case WM_SIZED:
				
				case WM_MOVED:
				wi_move(slot[msg[3]], msg[4], msg[5], msg[6], 
					msg[7]);
			}
		if(run)						/*	Iteration durchfÅhren		*/
		{
			time++;
			s_iterate();
			disp_ocn();
			disp_pha();
			disp_pro();
			if(cfish==area||cfish==0)	/*	Simulation beendet		*/
				run=FALSE;
		}
		menu_ienable(menu_t, F_OPEN, !fd);
		menu_ienable(menu_t, F_CLOSE, fd);
		menu_ienable(menu_t, F_HEADER, fd);
		menu_ienable(menu_t, START, !run);
		menu_ienable(menu_t, STOP, run);
	}
}


quit()								/*	Programm beenden			*/
{	
	int no;
	for(no=0; no<3; no++)
		wi_delete(no);
	v_clsvwk(handle);
	appl_exit();
	Pterm0();
}


ev_button()							/*	Mausknopf-Event, Ozean		*/
{									/*	 editieren					*/
	static char line[2];
	int x, y, xc, yc;
	x=(mox-wi[OCN].work.g_x)/8;		/*	Position editieren			*/
	y=(moy-wi[OCN].work.g_y)/8;
	if(!m1flags||x<0||x>xsize||y<0||y>ysize)	/*	doch nicht		*/
		return;
	xc=x*8;
	yc=y*8+6;
	line[0]=pos[x][y].state=mmode;
	buf_beg(OCN);					/*	in Puffer schreiben			*/
	v_gtext(handle, xc, yc, line);
	buf_end();
	wi_redraw(OCN, min(mox-8, xdesk+wdesk-16),
		min(moy-8, ydesk+hdesk-16), 16, 16);
}


ev_mouse()							/*	Maus-Event, Cursor Ñndern	*/
{	
	int wthandle;
	if(m1flags)						/*	Fenster verlassen			*/
	{	
		graf_mouse(ARROW, 0L);
		m1flags=FALSE;
	}
	else							/*	in Fenster eintreten		*/
	{
		wind_get(0, WF_TOP, &wthandle, &dummy, &dummy, &dummy);
		if(wthandle&&wthandle==wi[OCN].handle)	/*	falls aktiv		*/
		{	
			graf_mouse(OUTLN_CROSS, 0L);
			m1flags=TRUE;
		}
	}
}


disp_ocn()							/* 	Ozean zeichnen,	Bewohner 	*/
{									/*	 zÑhlen						*/
	char line[XMAX+1];
	int i, x, y, yc=-2;
	line[xsize]=cfish=cshark=0;
	buf_beg(OCN);					/*	in Puffer schreiben			*/
	for(y=0; y<ysize; y++)
	{	
		for(x=0; x<xsize; x++)
		{	
			line[x]=pos[x][y].state;
			if(pos[x][y].state==FISH)
				cfish++;
			else if(pos[x][y].state==SHARK)
				cshark++;
		}
		v_gtext(handle, 0, yc+=8, line);
	}
	buf_end();
	wi_redraw(OCN, xdesk, ydesk, wdesk, hdesk);
}


disp_pro()							/*	Protokoll schreiben			*/
{	
	int i, ofish, oshark, xy[8];
	static char line[81];
	if(time%invl)					/*	doch nicht					*/
		return;
	buf_scrol(PRO, 8);				/*	Puffer abwÑrts scrollen		*/
	for(i=0; i<22+pwid; i++)		/*	Zahlenwerte					*/
		line[i]=' ';
	ntoj(cfish, line+1);
	ntoj(cshark, line+8);
	ntoj(time, line+15);
	if(plot)						/*	Populationskurve			*/
	{
		ofish=(long)pwid*cfish/area;
		oshark=(long)pwid*cshark/area;
		line[21+ofish]='x';
		line[21+oshark]='o';
	}
	else
		ofish=oshark=0;
	line[22+pwid]=0;
	buf_beg(PRO);					/*	in Puffer schreiben			*/
	v_gtext(handle, 0, 7, line);
	buf_end();
	wi_redraw(PRO, xdesk, ydesk, wdesk, hdesk);
	strcpy(line+22+max(ofish, oshark), "\r\n");	/*	in Datei		*/
	f_write(line);
}


disp_pha()							/*	Phasendiagramm zeichnen		*/
{
	static xy[4];
	xy[2]=xy[0];					/*	Linie berechnen				*/
	xy[3]=xy[1];
	xy[0]=min((int)(xpha+100L*wpha*cfish/fscal/area), work_out[0]);
	xy[1]=max((int)(ypha+hpha-100L*hpha*cshark/sscal/area), 0);
	buf_beg(PHA);					/*	in Puffer zeichnen			*/
	if(curve)
		v_pline(handle, 2, xy);
	else
		v_pmarker(handle, 1, xy);
	buf_end();
	wi_redraw(PHA, xdesk, ydesk, wdesk, hdesk);
}


new_ocn()							/*	Ozean initialisieren,		*/
{	
	time=0;							/*	 Neustart der Simulation	*/
	run=TRUE;
	graf_mouse(HOURGLASS, 0L);		/*	Biene						*/
	s_setup();						/*	kann einige Sekunden dauern	*/
	graf_mouse(ARROW, 0L);
	f_header();						/*	Datei-Kopf schreiben		*/
	area=xsize*ysize;				/*	Fenstergrîûe anpassen		*/
	wi[OCN].curr.g_w=xsize*8+2;
	wi[OCN].curr.g_h=ysize*8+gl_hbox+1;
	wi_move(OCN, wi[OCN].curr.g_x, wi[OCN].curr.g_y, wi[OCN].curr.g_w,
		wi[OCN].curr.g_h);
	disp_ocn();
	new_pro();						/*	Åbrige Fenster initial.		*/
	new_pha();
}


new_pro()							/*	Protokoll initialisieren	*/
{	
	buf_clear(PRO);
	disp_pro();
}


new_pha()							/*	Phasendiagramm initial.		*/
{	
	int xy[6];
	disp_pha();
	buf_clear(PHA);
	buf_beg(PHA);
	xy[0]=xy[2]=xpha;				/*	Koordinatenachsen			*/
	xy[4]=xpha+wpha;
	xy[1]=ypha;
	xy[3]=xy[5]=ypha+hpha;
	vsl_ends(handle, 1, 1);
	v_pline(handle, 3, xy);	
	vsl_ends(handle, 0, 0);
	vst_rotation(handle, 2700);		/*	Beschriftung				*/
	v_gtext(handle, xpha/4, ypha, string_t[PH_SHRKS].ob_spec);
	vst_rotation(handle, 0);
	v_gtext(handle, xpha+wpha-48, ypha*7/4+hpha, 
		string_t[PH_FISH].ob_spec);
	buf_end();
}


dial_ocn()							/*	Dialog Ozean				*/
{	
	Ntot(ocnpar_t, NFISH, nfish);
	Ntot(ocnpar_t, FBREED, fbreed);
	Ntot(ocnpar_t, NSHARK, nshark);
	Ntot(ocnpar_t, SBREED, sbreed);
	Ntot(ocnpar_t, STARVE, starve);
	Ntot(ocnpar_t, XWID, xsize);
	Ntot(ocnpar_t, YWID, ysize);
	if(P_OK==use_form(ocnpar_t, NSHARK))
	{	
		xsize=min(xmax, Tton(ocnpar_t, XWID));
		ysize=min(ymax, Tton(ocnpar_t, YWID));
		nfish=min(xsize*ysize, Tton(ocnpar_t, NFISH));
		nshark=min(xsize*ysize-nfish, Tton(ocnpar_t, NSHARK));
		fbreed=Tton(ocnpar_t, FBREED);
		sbreed=Tton(ocnpar_t, SBREED);
		starve=Tton(ocnpar_t, STARVE);
		new_ocn();
	}
}


dial_pro()							/*	Dialog Protokoll			*/
{	
	Ntot(propar_t, INTERV, invl);
	objc_change(propar_t, PLOT, 0, 0, 0, 0, 0, 
		plot?SELECTED:NORMAL, FALSE);
	if(PRO_OK==use_form(propar_t, INTERV))
	{	
		plot=propar_t[PLOT].ob_state==SELECTED;
		invl=Tton(propar_t, INTERV);
		new_pro();
	}
}


dial_pha()							/*	Dialog Phasendiagramm		*/
{	
	Ntot(phapar_t, FSCAL, fscal);
	Ntot(phapar_t, SSCAL, sscal);
	objc_change(phapar_t, CURVE, 0, 0, 0, 0, 0, 
		curve?SELECTED:NORMAL, FALSE);
	objc_change(phapar_t, POINTS, 0, 0, 0, 0, 0, 
		curve?NORMAL:SELECTED, FALSE);
	if(PHA_OK==use_form(phapar_t, FSCAL))
	{	
		curve=phapar_t[CURVE].ob_state==SELECTED;
		fscal=Tton(phapar_t, FSCAL);
		sscal=Tton(phapar_t, SSCAL);
		new_pha();
	}
}


f_open()							/*	Datei îffnen				*/
{	
	char *path;
	if(F_OK==use_form(file_t, 0L))
	{
		path=((TEDINFO *)file_t[PATH].ob_spec)
			->te_ptext;
		if(0<=Fsfirst(path, NO_ATTR)&&1==form_alert(1,
			string_t[AL_APP].ob_spec))
		{	
			fd=Fopen(path, WRONLY);
			Fseek(0L, fd, 2);
		}
		else
			fd=Fcreate(path, NO_ATTR);
		if(-3>fd)					/*	Fehler aufgetreten			*/
		{	
			Form_error(fd);			/*	GEMDOS-Fehler melden		*/
			fd=0;
		}
	}
}


f_header()							/*	Kopf fÅr Protokolldatei		*/
{	
	char line[41];
	int i;
	f_write("\r\n");
	f_write(string_t[HD_1].ob_spec);	/*	1. Zeile				*/
	f_write(string_t[HD_2].ob_spec);
	f_write("\r\n");
	strcpy(line, string_t[HD_3].ob_spec);	/*	2. Zeile			*/
	ntoj(nfish, line+6);
	ntoj(fbreed, line+17);
	ntoj(nshark, line+28);
	f_write(line);
	strcpy(line, string_t[HD_4].ob_spec);
	ntoj(sbreed, line+4);
	ntoj(starve, line+16);
	ntoj(xsize, line+28);
	ntoj(ysize, line+33);
	f_write(line);
	f_write("\r\n\n");
	f_write(string_t[HD_5].ob_spec);	/*	3. Zeile				*/
	f_write("\r\n");
	for(i=0; i<22+pwid; i++)		/*	Strich						*/
		f_write("-");
	f_write("\r\n");
}


f_write(string)						/*	String in Datei schreiben	*/
char *string;
{	
	if(!fd)
		return;
	if(0>=Fwrite(fd, (long)strlen(string), string))
	{	
		form_alert(1, string_t[AL_FILE].ob_spec);
		f_close();
	}
}


f_close()							/*	Datei schlieûen				*/
{	
	int err;
	if(0>(err=Fclose(fd)))
		Form_error(err);
	fd=0;
}


use_form(addr, start_ob)			/*	Dialog fÅhren				*/
int start_ob;
OBJECT *addr;
{
	int x, y, w, h, ex_ob;
	form_center(addr, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	objc_draw(addr, 0, 99, x, y, w, h);
	ex_ob=form_do(addr, start_ob);
	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
	objc_change(addr, ex_ob, 0, x, y, w, h, NORMAL, 0);
	return(ex_ob);
}


ntoa(n, a)							/*	natÅrliche Zahl => String	*/
char *a;
unsigned n;
{	
	int c, i=0, j=0;
	do
	{	
		a[i++]='0'+n%10;
		n/=10;
	}
	while(n);
	a[i]=0;
	while(j<i)						/*	umkehren					*/
	{	
		c=a[j];
		a[j++]=a[--i];
		a[i]=c;
	}
}


ntoj(n, j)							/*	n rechtsbÅndig ausgeben		*/
unsigned n;
char *j;
{	
	char a[6];
	ntoa(n, a);
	strncpy(j+5-strlen(a), a, strlen(a));
}


unsigned aton(a)					/*	String => natÅrliche Zahl	*/
char *a;
{	
	int i=0;
	unsigned n=0;
	while(!isdigit(a[i]))
		if(!a[i++])
			return 0;
	while(isdigit(a[i]))
	{	
		n*=10;
		n+=a[i++]-'0';
	}
	return n;
}
