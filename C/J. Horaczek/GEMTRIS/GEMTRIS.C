/* gemtris.c vom 21.10.91, 12:12 */
/*								*/
/*	Einige Fehler behoben		*/
/*								*/
/*	HJ	22.09.91				*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h> 
#include <tos.h>
#include <time.h>
#include <scancode.h>
#include "gemtrrsc.h"
#include "gemtrrsc.rsh"

int imin(int a, int b)
{
	return((a<b) ? a : b);	
}

int imax(int a, int b)
{
	return((a>b) ? a : b);	
}

int lmin(long a, long b)
{
	return((a<b) ? (int)a : (int)b);	
}

int lmax(long a, long b)
{
	return((a>b) ? (int)a : (int)b);	
}

extern int _app;

/* Fuer v_openvwk() */
int work_in[12],
	work_out[57]; /* enthaelt Infos ueber Bildschirm */
	
/* handle ist der fuer VDI-Aufrufe noetige Handle */
int	handle,phys_handle;

/* Soll Hoehe und Breite von Buchstaben enthalten */
int gl_hchar,gl_wchar,gl_hbox,gl_wbox;

/* Nummer der Applikation, z.B. um ein Accessory anzumelden */
int gl_apid;

/* xy-Array */
int pxyarr[4];

OBJECT *menu_tree; /* Enthaelt Resource-Adresse des Menues */
int wi_handle; /* Handle des Fensters */
int wi_x=0, wi_y=0;
char wi_qname[]=" GEMtris+ ";
char wi_sname[]=" GEMtris- ";
char wi_name[40]="";
char wi_info[40]="";
int xdesk,ydesk,wdesk,hdesk; /* Groesse des gesamten 
								Arbeitsbereiches */

/* Problemabhaengige Variablen */
#define ELEMENTS (NAME|FULLER|MOVER|INFO)
int xw,yw,hw,ww,xstein,ystein,hstein,wstein;
int steinsize=8;
int sit[18][28];	/* aktuelle Situation plus zwei Randfelder */
int back[18][28];	/* aktuelle Situation ohne fallenden Stein */
int st[4][4];	/* fallender Stein */
int st1[4][4];
int fig[7][4][4]=
	{0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,
	 0,0,0,0,0,2,2,2,0,2,0,0,0,0,0,0,
	 0,0,0,0,3,3,3,0,0,0,3,0,0,0,0,0,
	 0,0,0,0,0,4,4,4,0,0,4,0,0,0,0,0,
	 0,0,0,0,0,0,5,5,0,5,5,0,0,0,0,0,
	 0,0,0,0,0,6,6,0,0,0,6,6,0,0,0,0,
	 0,0,0,0,0,7,7,0,0,7,7,0,0,0,0,0}
	 ;	/* moegliche Steine */
int is,js;	/* Position des fallenden Steines */
long delay,maxdelay=100,mindelay=0,speed;
int ende;
long punkte=0L,reihen=0L;
#define MAXPUNKTE 99999999L
#define MAXREIHEN 99999L
char *scr_adr,*phys_adr;
long scr_size;
MFDB mfdb1,mfdb2;
typedef char STRING[32]; 
STRING namen[2][10];  /* Namen in Highscore */
long score[2][10];
unsigned char old_tast;
int old_rate;
int rep_rate=5,start_rep=5,t_faktor;
int moved;  /* Stein zuletzt bewegt? */
clock_t timer;

int open_vwork(void)
/* Oeffnet den Bildschirm als Arbeitsstation */
{	register int i;
	if ((gl_apid=appl_init()) != -1)
	{	for (i=1; i<10; work_in[i++]=1);
		work_in[10]=2; /* Benutze Pixel-Koordinaten */
		phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
		work_in[0]=handle=phys_handle;
		v_opnvwk(work_in,&handle,work_out);
		if (handle > 0) return 1; /* Erfolg! */
	}
	return 0;
}

int close_vwork(void)
/* Schliesst Bildschirm als Arbeitsstation und meldet Applikation 
	ab */
{	v_clsvwk(handle);
	if (appl_exit()==0) return 1;
	return 0;
}

void keyclr(void)
/*	terminiert erst dann, wenn keine Taste mehr gedrckt ist */
{
unsigned int ev;
int eb, ek, d;
unsigned long delay;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	delay= Kbrate(-1, -1);
	ek= (int)(delay & 0xff);
	eb= (int)((delay>>8) & 0xff);
	delay= imax(eb, ek);
	delay= (delay*Tickcal()) + 10L;
	do
	{
		evnt_timer(0, 0);
		ev= evnt_multi(MU_KEYBD|MU_TIMER,
			0, 0, 0,
			0, 0,0,0,0,
			0, 0,0,0,0,
			NULL,
			(int)(delay & 0xffff), (int)(delay>>16),
			&d, &d, &eb, &ek, &d, &d);
	} while ((ev & MU_KEYBD) || eb || ek);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void kbufclr(void)
/*	liest den Tastaturpuffer leer. */
{
	int evres, d;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	evnt_timer(0, 0);
	do
	{
		evres= evnt_multi(MU_KEYBD|MU_TIMER,
				0, 0, 0,
				0, 0,0,0,0,
				0, 0,0,0,0,
				NULL,
				0, 0,
				&d, &d, &d, &d, &d, &d);
	} while (evres & MU_KEYBD);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

int dialog(int tree, int start)
/* Dies ist ein einfaches Dialogprogramm, das ein Formular aufbaut,
	zentriert, zeichnet, bearbeitet und wieder loescht */
{	OBJECT *tree_addr;
	int x,y,w,h,ret;
	if (rsrc_gaddr(R_TREE,tree,&tree_addr)==0) return 0;
	wind_update(BEG_UPDATE);
	form_center(tree_addr,&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	objc_draw(tree_addr,0,25,x,y,w,h);
	keyclr();
	ret=form_do(tree_addr,start) & 0xff;
	keyclr();
	tree_addr[ret].ob_state &= ~SELECTED; /* Exit-Object wieder auf
			nicht selektiert umstellen */
	form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	wind_update(END_UPDATE);
	return ret; /* Der Knopf mit dem das Formular verlassen wurde */
}

void redraw_all(void)
{	form_dial(FMD_FINISH,0,0,0,0,xdesk,ydesk,wdesk,hdesk);
}

void show_info(void)
/* Ruft die Programminformation auf, in die vorher das Erstellungs-
	datum eingetragen wurde */
{	OBJECT *info;
	if (rsrc_gaddr(R_TREE,INFOF,&info)==0) return;
	info[INFOVERS].ob_spec.free_string=__DATE__;
	dialog(INFOF,0); /* Exit-Button interessiert nicht */
}

void nowind_msg(void)
{
	wind_update(BEG_UPDATE);
	form_alert(1, rs_frstr[WINDERR]);
	wind_update(END_UPDATE);
}

void size_window(void)
{	int w,h;
	wind_calc(1,ELEMENTS,xdesk,ydesk,wdesk,hdesk,&xw,&yw,&ww,&hw);
	hw=imin(hw/20,steinsize)*20;
	w=(((hw/20)*work_out[4])/work_out[3]+1)*10;
	if (w>ww) ww=(ww/20)*20; 
	else ww=w;
	hstein=hw/20; wstein=ww/10;
	wind_calc(0,ELEMENTS,xw,yw,ww,hw,&xw,&yw,&ww,&hw);
	xw=imin(wi_x+ww,xdesk+wdesk)-ww;
	yw=imin(wi_y+hw,ydesk+hdesk)-hw;
	xw=(imax(xw,xdesk)+15) & ~15;
	yw=imax(yw,ydesk);
	wind_calc(1,ELEMENTS,xw,yw,ww,hw,&xstein,&ystein,&h,&w);
}

int open_window(void)
/* Oeffnet ein Fenster in maximaler Groesse, wenn noch nicht offen */
{	if (wi_handle>0)
	{	/* Fenster bereits offen */
		wind_set(wi_handle,WF_TOP,wi_handle);
		return 0;
	}
	wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
	if ((wi_handle=wind_create(ELEMENTS,xdesk,ydesk,wdesk,hdesk))<=0)
	{ nowind_msg(); return 1;}
	size_window() ;
	wind_set(wi_handle,WF_NAME,wi_name);
	wind_set(wi_handle,WF_INFO,wi_info);
	wind_open(wi_handle,xw,yw,ww,hw); /* Oeffne Fenster */
	pxyarr[0]=xdesk; pxyarr[1]=ydesk;
	pxyarr[2]=xdesk+wdesk-1; pxyarr[3]=ydesk+hdesk-1;
	vs_clip(handle,1,pxyarr);
	return 0;
}

void move_window(int hndl, int x, int y, int w, int h)
/* Fenster verschieben */
{	if ((hndl == wi_handle) && (wi_handle > 0))
	{
		x=imin(x+w,xdesk+wdesk)-w;
		y=imin(y+h,ydesk+hdesk)-h;
		x=(imax(x,xdesk)+15) & ~15;
		y=imax(y,ydesk);
		wind_set(wi_handle,WF_CURRXYWH,x,y,w,h);
		wi_x=x;
		wi_y=y;
		wind_get(wi_handle,WF_WORKXYWH,&x,&y,&w,&h);
		xstein=x;
		ystein=y;
	}
}

void close_window(void)
/* Schliesst Fenster und meldet es ab */
{	if (wi_handle > 0)
	{
		wind_close(wi_handle); /* Schliessen */
		wind_delete(wi_handle); /* Abmelden */
		wi_handle=-1;
	}
}

void stein_size(int wh)
{
	if ((wh==wi_handle)&&(wi_handle>0))
	{	if (steinsize<8) steinsize=8; else steinsize++;
		size_window();
		wind_set(wi_handle,WF_CURRXYWH,xw,yw,ww,hw);
		form_dial(FMD_FINISH,xw,yw,ww,hw,xw,yw,ww,hw);
		if (hstein<steinsize) steinsize=8;
	}
}

int rc_intersect(int x, int y, int w, int h,
	int *x1, int *y1, int *w1, int *h1)
/* Unterprogramm, das den Schnitt zweier Rechtecke ausrechnet */
{	int x2,y2;
	x2=imax(x,*x1);
	y2=imax(y,*y1);
	*w1=imin(x+w,*x1+*w1)-x2;
	*h1=imin(y+h,*y1+*h1)-y2;
	*x1=x2; *y1=y2;
	return ((*w1>0)&&(*h1>0));
}

void stein(int i,int j,int pattern)
{	int box[4];
	if (wi_handle <= 0) return;
	box[0]=(i-4)*wstein+xstein;
	box[1]=(j-4)*hstein+ystein;
	box[2]=box[0]+wstein-1;
	box[3]=box[1]+hstein-1;
	vsf_perimeter(handle,1);
	vsf_color(handle,1);
	vsf_interior(handle,2);
	vsf_style(handle,pattern);
	v_bar(handle,box);
}

void leer(int i,int j)
{	int box[4];
	if (wi_handle <= 0)	return;
	box[0]=(i-4)*wstein+xstein;
	box[1]=(j-4)*hstein+ystein;
	box[2]=box[0]+wstein-1;
	box[3]=box[1]+hstein-1;
	vsf_color(handle,0);
	vsf_interior(handle,1);
	v_bar(handle,box);
}

void draw_punkte(void)
{	if (wi_handle<=0) return;
	strcpy(wi_info,"  ");
	ltoa(reihen,&(wi_info[strlen(wi_info)]),10);
	strcat(wi_info," : ");
	ltoa(punkte,&(wi_info[strlen(wi_info)]),10);
	wind_set(wi_handle,WF_INFO,wi_info);
}

void redraw(void)
/* Neuzeichnung eines Fensters */
{	int i,j;
	for (i=4; i<14; i++)
	  for (j=4; j<24; j++)
	    if (back[i][j]) 
	    	stein(i,j,back[i][j]);
	    else
	    	leer(i,j);
}

void top_redraw(void)
/* zeichnet Top-Fenster neu */
{	int w;
	wind_update(BEG_UPDATE);
	wind_get(0,WF_TOP,&w);
	if ((w==wi_handle) && (wi_handle>0))
	{
		graf_mouse(M_OFF,NULL);
		redraw();
		graf_mouse(M_ON,NULL);
	}
	wind_update(END_UPDATE);
}

void do_redraw(int whandle, int x, int y, int w, int h)
/* Uebernimmt allgemein das Neuzeichnen von Fenstern. Ruft daher
redraw auf. Die Fenster werden in Teilrechtecken neu gezeichnet. */
{	int x1,y1,w1,h1;
	if (whandle!=wi_handle) return;
	wind_update(BEG_UPDATE); /* Sperre Bildschirmzugriff fuer GEM */
	graf_mouse(M_OFF,0);
	wind_get(whandle,WF_FIRSTXYWH,&x1,&y1,&w1,&h1);
		/* erstes neu zu zeichnendes Rechteck */
	while((w1>0)&&(h1>0))
	{	if (rc_intersect(x,y,w,h,&x1,&y1,&w1,&h1))
		{	pxyarr[0]=x1; pxyarr[1]=y1;
			pxyarr[2]=w1+x1-1; pxyarr[3]=h1+y1-1;
			vs_clip(handle,1,pxyarr);
			redraw(); /* Zeichne neu */
		}
		wind_get(whandle,WF_NEXTXYWH,&x1,&y1,&w1,&h1);
			/* Naechstes Rechteck */
	}
	pxyarr[0]=xdesk; pxyarr[1]=ydesk;
	pxyarr[2]=xdesk+wdesk-1; pxyarr[3]=ydesk+hdesk-1;
	vs_clip(handle,1,pxyarr);
	graf_mouse(M_ON,0);
	wind_update(END_UPDATE); /* Gib GEM wieder frei! */
}

void select_stone(void)
/* Waehlt einen der Steine per Zufall aus */
{
int i,j;
int n = (int)(Random()%7);

	for (i=0; i<4; i++) 
		for (j=0; j<4; j++)
			st[j][i]=fig[n][i][j];
	is=6; js=2;	/* Anfangsstellung */
}

void turn_stone(void)
/* dreht Stein */
{	int i,j,h;
	for (i=0; i<4; i++)
		for (j=0; j<4; j++) st1[i][j]=st[i][j];
	h=st[0][0]; st[0][0]=st[3][0]; st[3][0]=st[3][3]; 
	st[3][3]=st[0][3]; st[0][3]=h;
	h=st[0][1]; st[0][1]=st[2][0]; st[2][0]=st[3][2]; 
	st[3][2]=st[1][3]; st[1][3]=h;
	h=st[0][2]; st[0][2]=st[1][0]; st[1][0]=st[3][1]; 
	st[3][1]=st[2][3]; st[2][3]=h;
	h=st[1][1]; st[1][1]=st[2][1]; st[2][1]=st[2][2]; 
	st[2][2]=st[1][2]; st[1][2]=h;
}

void turn_back(void)
{	int i,j;
	for (i=0; i<4; i++)
		for (j=0; j<4; j++) st[i][j]=st1[i][j];
}

int try_stone(void)
/* versucht, ob der Stein an die Stelle (is,js) passt */
{	int i,j;
	for (i=0; i<4; i++)
		for (j=0; j<4; j++)
			if ((st[i][j]!=0)&&(back[is+i][js+j]!=0)) return 0;
	return 1;
}

void waitfor(long del)
{	long t=clock();
	if (del>0) while (clock()<(t+del)) ;
}

void do_moveredraw(int whandle,int xd,int yd,int wd,int hd)
{	int x,y,w,h,i,j;
	wind_update(BEG_UPDATE);
	if ((whandle==wi_handle)&&(wi_handle>0))
	{	graf_mouse(M_OFF,0);
		wind_get(wi_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
		while((w>0)&&(h>0))
		{	if (rc_intersect(xd,yd,wd,hd,&x,&y,&w,&h))
			{	pxyarr[0]=x; pxyarr[1]=y;
				pxyarr[2]=w+x-1; pxyarr[3]=h+y-1;
				vs_clip(handle,1,pxyarr);
				
				for (i=4; i<14; i++)
					for (j=4; j<24; j++)
						if (sit[i][j]) stein(i,j,sit[i][j]);
						else leer(i,j);
			}
			wind_get(wi_handle,WF_NEXTXYWH,&x,&y,&w,&h);
		}
		pxyarr[0]=xdesk; pxyarr[1]=ydesk;
		pxyarr[2]=xdesk+wdesk-1; pxyarr[3]=ydesk+hdesk-1;
		vs_clip(handle,1,pxyarr);
		graf_mouse(M_ON,0);
	}
	wind_update(END_UPDATE);
}

int move_stone(void)
/* versucht, Stein zu bewegen. */
{	int b[18][28],i,j,down,pause,taste,msgbuf[8];

	/* Mache Backup von Stellung mit fallendem Stein */
	for (i=4; i<14; i++)
		for (j=4; j<24; j++)
			b[i][j]=sit[i][j];
	moved=0;
	pause=0;
	do
	{	j=evnt_multi(MU_KEYBD|MU_MESAG|MU_TIMER,
				1,1,1,
				0,0,0,0,0,
				0,0,0,0,0,
				msgbuf,
				0,0,
				&i,&i,&i,&i,&taste,&i);
		if (j & MU_MESAG)
		{
			switch(msgbuf[0])
			{ case AC_CLOSE : wi_handle=-1; ende=-1; break;
			  case MN_SELECTED : /* Menue angewaehlt */
					menu_tnormal(menu_tree,msgbuf[3],1);
					break;
			  case WM_REDRAW :
			  		do_moveredraw(msgbuf[3],msgbuf[4],msgbuf[5],
			  			msgbuf[6],msgbuf[7]); break;
			  		/* Fenster neu zu zeichnen */
			  case WM_TOPPED :
			  		wind_set(msgbuf[3],WF_TOP,msgbuf[3]);
			  		break;
			  case WM_MOVED  : move_window(msgbuf[3],
			  		msgbuf[4],msgbuf[5],msgbuf[6],msgbuf[7]);
			  		break;
			  case WM_FULLED : stein_size(msgbuf[3]); break;
			}
		}
		wind_get(0,WF_TOP,&i);
		if (! ((i == wi_handle) || (wi_handle <= 0)))
		{	if (! pause)
			{	pause=1;
				if (wi_handle>0)
				{	wind_set(wi_handle,WF_INFO," ..."); }
			}
		}
		else
		{	if (pause)
			{	pause=0;
				if (wi_handle>0)
				{	wind_set(wi_handle,WF_INFO,wi_info);
					timer=clock(); }
			}
		}
	} while (pause);
	if (ende<0) return 0;
	if (j & MU_KEYBD)
	{	switch (taste>>8)
		{	case 0x4d : taste='6'; break;
			case 0x4b : taste='4' ; break;
			case 0x50 : taste='5' ; break;
			case 0x48 : taste='2' ; break;
		}
		switch (taste&0xFF)
		{	case '6' : js++; down=try_stone(); js--;
				is++; if (!try_stone()) is--;
					else moved=1;
				if (!down) goto nofall;
				break;
			case '4' : js++; down=try_stone(); js--;
				is--; if (!try_stone()) is++;
					else moved=1; 
				if (!down) goto nofall;
				break;
			case '5' : turn_stone(); 
				if (!try_stone()) turn_back();
					else moved=1; 
				break;
			case ' ' :
			case '2' :
				do { js++; punkte=lmin(punkte+2,MAXPUNKTE); }
					while (try_stone()) ;
				js--; punkte-=2; break;
			case 27 :
				wind_update(BEG_UPDATE);
				ende|=(form_alert(2, rs_frstr[PAUSE])==2);
				wind_update(END_UPDATE);
				break;
		}
		/* Tastenpuffer l”schen */
		kbufclr();
	}
	/* Versuche Fall */
	if (clock()>timer+delay)
	{	js++; 
		if (!try_stone()) js--; 
		else {	moved=1;
				punkte=lmin(punkte+1,MAXPUNKTE);
				timer=clock(); }
	}
	else moved=1;
nofall:
	/* Enferne fallenden Stein */
	for (i=0; i<18; i++)
		for (j=0; j<28; j++)
			sit[i][j]=back[i][j];
	/* Setze ihn an neue Position */
	for (i=0; i<4; i++)
		for (j=0; j<4; j++)
			if (st[i][j]) sit[is+i][js+j]=st[i][j];
	
	/* Zeichne geaenderte Felder */
	wind_update(BEG_UPDATE);
	wind_get(0,WF_TOP,&i);
	if ((i==wi_handle) && (wi_handle>0))
	{	graf_mouse(M_OFF,NULL);
		for (i=4; i<14; i++)
			for (j=4; j<24; j++)
				if (b[i][j]!=sit[i][j])
				{
					if (sit[i][j])
						stein(i,j,sit[i][j]);
					else
						leer(i,j);
				}
		graf_mouse(M_ON,NULL);
	}
	else
	{	/* Fenster nicht TOP */
		do_moveredraw(wi_handle,xdesk,ydesk,wdesk,hdesk);
	}
	wind_update(END_UPDATE);
	return moved;
}

void empty_board(void)
{	int i,j;
	for (i=0; i<18; i++)
		for (j=0; j<28; j++)
			back[i][j]=((i<4)||(i>=14)||(j>=24));
}

void wait(void)
{	long t=clock();
	while (clock()<(t+delay)) ;
}

long remove_voll(void)
/* Entfernt volle Reihen */
{	int i,j,k,voll,voll1=0;
	long erg;
	erg=0L;
	for (j=4; j<24; j++)
	{	voll=1;
		for (i=4; i<14; i++)
			if (!back[i][j]) { voll=0; break; }
		if (voll)
		{	for (k=j; k>=4; k--)
				for (i=4; i<14; i++) back[i][k]=back[i][k-1];
			voll1=1; erg++;
			wait();
		}
	}
	if (voll1) top_redraw();
	return(erg);
}

void best(void)
{	OBJECT *o;
	int i,j;
	static STRING name="???";
	static STRING sc[10];
	if (rsrc_gaddr(R_TREE,BESTF,&o)==0) return;
	o[BNAME].ob_spec.tedinfo->te_ptext=name;
	o[BNAME].ob_spec.tedinfo->te_txtlen=16;
	if (speed)
	{	o[BQUICK].ob_flags&= ~HIDETREE; o[BSLOW].ob_flags|= HIDETREE; }
	else
	{	o[BSLOW].ob_flags&= ~HIDETREE; o[BQUICK].ob_flags|= HIDETREE; }
	/* Setze Highscores ein */
	for (i=0; i<10; i++)
	{	o[B1+i].ob_spec.tedinfo->te_ptext=namen[speed][i];
		o[B1+i].ob_spec.tedinfo->te_txtlen=16;
		ltoa(score[speed][i],sc[i],10);
		o[S1+i].ob_spec.tedinfo->te_ptext=sc[i];
		o[S1+i].ob_spec.tedinfo->te_txtlen=8;
	}
	dialog(BESTF,0);
	i=0; while ((i<10)&&(score[speed][i]>=punkte)) i++;
	if (i<10)
	{	for (j=9; j>i; j--) 
		{	score[speed][j]=score[speed][j-1];
			memcpy(namen[speed][j],namen[speed][j-1],32);
		}
		score[speed][i]=punkte;
		memcpy(namen[speed][i],name,32);
	}
}

void play(void)
{	int i,j;
	wind_get(0,WF_TOP,&i);
	if ((i != wi_handle) || (wi_handle <= 0)) return;
	empty_board();
	delay=maxdelay; punkte=0L; reihen=0L;
	keyclr();
	top_redraw();
	draw_punkte();
	ende=0;
	while (1)
	{	select_stone();
		timer=clock();
		if (!try_stone()) break;
		if (ende) break;
		punkte=lmin(punkte+5,MAXPUNKTE);
		while ((move_stone())&&(!ende)) ;
		for (i=4; i<14; i++)
			for (j=0; j<24; j++)
				back[i][j]=sit[i][j];
		reihen=lmin(reihen+remove_voll(),MAXREIHEN);
		draw_punkte();
		wait();
		delay=lmin(lmax(mindelay,
				(maxdelay>50)?(100-punkte/200):(maxdelay-reihen/6)),
					maxdelay);
	}
	if (ende>=0)
		best();
}

void setdelay(void)
{	OBJECT *info;
	if (rsrc_gaddr(R_TREE,INFOF,&info)==0) return;
	if (maxdelay>40)
	{	maxdelay=40; menu_icheck(menu_tree,MENQUICK,1);
		info[FQUICK].ob_state|= CHECKED; speed=1;
		strcpy(wi_name,wi_qname);
		if (wi_handle>0) wind_set(wi_handle,WF_NAME,wi_name); }
	else
	{	maxdelay=100; menu_icheck(menu_tree,MENQUICK,0);
		info[FQUICK].ob_state&= ~CHECKED; speed=0;
		strcpy(wi_name,wi_sname);
		if (wi_handle>0) wind_set(wi_handle,WF_NAME,wi_name); }
}

void load_score(void)
{	FILE *sco;
	int i,sp;
	if ((sco=fopen("gemtris.sco","r"))>0)
	{	fscanf(sco,"%d %d\n",&wi_x,&wi_y);
		fscanf(sco,"%d\n",&steinsize);
		for (sp=0; sp<2; sp++)
			for (i=0; i<10; i++)
				fscanf(sco,"%s %ld\n",namen[sp][i],&score[sp][i]);
		fclose(sco);
	}
	if (wi_x<0) wi_x=0;
	if (wi_y<0) wi_y=0;
	if (steinsize<8) steinsize=8;
}

void save_score(void)
{	FILE *sco;
	int i,sp;
	wind_update(BEG_UPDATE);
	graf_mouse(HOURGLASS,NULL);
	if ((sco=fopen("gemtris.sco","w"))>0)
	{	fprintf(sco,"%d %d\n",wi_x,wi_y);
		fprintf(sco,"%d\n",steinsize);
		for (sp=0; sp<2; sp++)
			for (i=0; i<10; i++)
			{	if (namen[sp][i][0]<'1') 
					memcpy(namen[sp][i],"???",32);
				fprintf(sco,"%s %ld\n",namen[sp][i],score[sp][i]); 
			}
		fclose(sco);
	}
	graf_mouse(ARROW,NULL);
	wind_update(END_UPDATE);
}

void init(void)
{	int i;
	empty_board();
	/* Highscore=0 */
	for (i=0; i<10; i++)
	{	memcpy(namen[0][i],"???",32); 
		memcpy(namen[1][i],"???",32); 
		score[0][i]=0; score[1][i]=0; }
	load_score();
	wi_handle=-1;
}

void reinit(void)
{	save_score();
}	

int main_loop(void)
/* Der Ereignisverwalter. Reagiert auf verschiedene Ereignisse */
{	int ende=0,dirty,msg,evmask;
	int msgbuf[8];
	int mx,my,mb,state,key,clicks,evt;

	wind_update(BEG_UPDATE);
	init();
	if (_app)
	{	if (rsrc_gaddr(R_TREE,MENMENU,&menu_tree)==0) ende=1;
		menu_bar(menu_tree,1);
		if (open_window()) ende=1;
	}
	setdelay();
	wind_update(END_UPDATE);
	if (ende) return 1;
	dirty=0;
	do
	{	evmask=MU_KEYBD|MU_MESAG;
		if (dirty) evmask|=MU_TIMER;
		evt=evnt_multi(evmask,
			1,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuf,
			0,0,
			&mx,&my,&mb,&state,&key,&clicks);
		if (evt & MU_MESAG) /* Message eingetroffen? */
		{	msg=msgbuf[0];
			switch(msg)
			{	case AC_CLOSE:
					wi_handle=-1;
					dirty=0; break;
				case WM_REDRAW:
					do_redraw(msgbuf[3],msgbuf[4],msgbuf[5],msgbuf[6],msgbuf[7]);
					break;
			}
			if (dirty==0)
			{	switch(msgbuf[0])
				{	case AC_OPEN:
						open_window(); show_info();
						dirty=1; break;
					case MN_SELECTED:
						switch(msgbuf[4])
						{	case MENQUIT: ende=1; break; 
						  	case MENINFO: show_info();
						  		dirty=1; break;
						  	case MENQUICK: setdelay(); break;
						  	case MENGO:
								menu_tnormal(menu_tree,msgbuf[3],1);
					  			play();
					  			dirty=1; break;
						  	case MENSCORE: save_score(); break;
						  	case MENLOOK: punkte=0; best();
						  		dirty=1; break;
						}
						menu_tnormal(menu_tree,msgbuf[3],1);
						break;
			 		case WM_TOPPED:
						wind_set(msgbuf[3],WF_TOP,msgbuf[3]);
						dirty=1;
						break;
					case WM_MOVED:
						move_window(msgbuf[3],msgbuf[4],msgbuf[5],msgbuf[6],msgbuf[7]);
						dirty=1;
						break;
					case WM_FULLED:
						stein_size(msgbuf[3]); dirty=1; break;
				}
			}
		}
		if ((evt & MU_KEYBD)&&(dirty==0))
		{ if (key==CNTRL_C) ende=1;
		  switch (key)
		  { case F1 : play(); dirty=1; break; 
		    case F2 : punkte=0; best(); dirty=1; break;
		    case F3 : save_score(); break;
		    case F10: setdelay(); break;
		    case HELP : show_info(); dirty=1; break;
		  }
		  keyclr();
		}
		
		if (evt==MU_TIMER) dirty=0;
		
		if (ende)
		{
			if (_app)
			{	wind_update(BEG_UPDATE);
				ende=form_alert(1, rs_frstr[QUIT]);
				wind_update(END_UPDATE);
			}
			else
			{	ende=0;
				close_window();
			}
		}
	} while (!ende);
	wind_update(BEG_UPDATE);
	close_window(); /* Schliesse Fenster */
	if (_app)	menu_bar(menu_tree,0); /* Loesche Menue */
	reinit();
	wind_update(END_UPDATE);
	return 0;
}

main()
/* Hauptprogramm */
{
		/* NUR BEI INTERNER RSC-FILE */
	rsc_init();

	wind_update(BEG_UPDATE);

	if(open_vwork())	 	/* Arbeitstation aufmachen */
		{
		if (! _app)	
			menu_register(gl_apid, "  GEMtris ");
		else 
			graf_mouse(ARROW, NULL);
		
		/*	NUR BEI EXTERNER RSC-FILE
		if (rsrc_load("gemtris.rsc")==0)
			{	
			form_alert(1,"[3][  GEMtris: |  GEMTRIS.RSC ? ][ABORT]");
			close_vwork();
			goto exit;
			}
		*/
		
		wind_update(END_UPDATE);

		main_loop(); /* Hauptschleife */

		wind_update(BEG_UPDATE);
		
		/*	NUR BEI EXTERNER RSC-FILE
		rsrc_free();
		*/
		
		close_vwork(); /* Arbeitsstation schliessen */

		/* NUR BEI INTERNER RSC-FILE */
		rsc_exit();

		}
	else 
		form_alert(1,"[3][  GEMtris: |  Init-Error ][ABORT]");

exit:
	wind_update(END_UPDATE);
	if (! _app)
		while (1) evnt_timer(0xffff,0xffff);
	
	wind_update(BEG_UPDATE);
	
	graf_mouse(HOURGLASS,0);
	
	keyclr();
	
	wind_update(END_UPDATE);
	
	return 0; /* Alles klar */
}
