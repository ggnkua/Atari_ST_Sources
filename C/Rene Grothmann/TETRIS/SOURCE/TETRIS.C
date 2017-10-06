#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h> 
#include <tos.h>
#include <time.h>
#include <scancode.h>
#include "tetris.h"

#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))

/* Diese Felder werden gewoehnlich nicht direkt angesprochen */
int cntlr[12],
	intin[128],
	intout[128],
	ptsin[128],
	ptsout[128];
	
/* Fuer v_openvwk() */
int work_in[12],
	work_out[57]; /* enthaelt Infos ueber Bildschirm */
	
/* handle ist der fuer VDI-Aufrufe noetige Handle */
int	handle,phys_handle;

/* Soll Hoehe und Breite von Buchstaben enthalten */
int gl_hchar,gl_wchar,gl_hbox,gl_wbox;

/* Nummer der Applikation, z.B. um ein Accessory anzumelden */
int gl_apid;

OBJECT *menu_tree; /* Enthaelt Resource-Adresse des Menues */
int wi_handle,wi2_handle; /* Handle des Fensters */
int xdesk,ydesk,wdesk,hdesk; /* Groesse des gesamten 
								Arbeitsbereiches */

/* Problemabhaengige Variablen */
#define ELEMENTS 0
int xw,yw,hw,ww,xstein,ystein,hstein,wstein;
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
long punkte=0,reihen=0;
int color;
int screen=0;	/* Flag ob zweiter Bildschirm benutzt */
char *scr_adr,*phys_adr;
long scr_size;
MFDB mfdb1,mfdb2;
typedef char STRING[32]; 
STRING namen[2][10];  /* Namen in Highscore */
long score[2][10];
int puffer;  /* Tastaturpuffer benutzt ? */
#define clear_buffer() while (Bconstat(2)) Bconin(2);
unsigned char old_tast;
int old_rate;
int rep_rate=5,start_rep=5,t_faktor;
int moved;  /* Stein zuletzt bewegt? */
time_t timer;

int open_vwork(void)
/* Oeffnet den Bildschirm als Arbeitsstation */
{	register int i;
	if ((gl_apid=appl_init()) != -1)
	{	for (i=1; i<10; work_in[i++]=0);
		work_in[10]=2; /* Benutze Pixel-Koordinaten */
		phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
		work_in[0]=handle=phys_handle;
		v_opnvwk(work_in,&handle,work_out);
		return 1; /* Erfolg! */
	}
	else return 0;
}

int close_vwork(void)
/* Schliesst Bildschirm als Arbeitsstation und meldet Applikation 
	ab */
{	v_clsvwk(handle);
	if (appl_exit()==0) return 1;
	return 0;
}

int dialog(int tree, int start)
/* Dies ist ein einfaches Dialogprogramm, das ein Formular aufbaut,
	zentriert, zeichnet, bearbeitet und wieder loescht */
{	OBJECT *tree_addr;
	int x,y,w,h,ret;
	if (rsrc_gaddr(R_TREE,tree,&tree_addr)==0) return 0;
	form_center(tree_addr,&x,&y,&w,&h);
	graf_mouse(M_OFF,0);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	objc_draw(tree_addr,0,25,x,y,w,h);
	graf_mouse(M_ON,0);
	ret=form_do(tree_addr,start); /* Hier muss der Benutzer das
			Formular bearbeiten */
	tree_addr[ret].ob_state &= ~SELECTED; /* Exit-Object wieder auf
			nicht selektiert umstellen */
	graf_mouse(M_OFF,0);
	form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h); /* kann entfernt werden */
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	graf_mouse(M_ON,0);
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
	(char *)info[INFOVERS].ob_spec=__DATE__;
	dialog(INFOF,0); /* Exit-Button interessiert nicht */
}

void size_window(void)
{	int w,h;
	wind_calc(1,ELEMENTS,xdesk,ydesk,wdesk,hdesk,&xw,&yw,&ww,&hw);
	hw=(hw/20)*20; 
	w=(((hw/20)*work_out[4])/work_out[3]+1)*10;
	if (w>ww) ww=(ww/20)*20; 
	else ww=w;
	hstein=hw/20; wstein=ww/10;
	wind_calc(0,ELEMENTS,xw,yw,ww,hw,&xw,&yw,&ww,&hw);
	xw=xdesk+(wdesk-ww)/2-7*gl_wbox;
	if (xw<0) xw=0;
	yw=ydesk+(hdesk-hw)/2;
	wind_calc(1,ELEMENTS,xw,yw,ww,hw,&xstein,&ystein,&h,&w);
}

int open_windows(void)
/* Oeffnet ein Fenster in maximaler Groesse */
{	wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
		/* Beschaffe Groesse des Arbeitsbereiches */
	if ((wi_handle=wind_create(ELEMENTS,
			xdesk,ydesk,wdesk,hdesk))<0)
		/* Melde Fenster an, falls noch moeglich */
	{ form_alert(1,"[3][Kein Fenster mehr frei][Abbruch]"); return 1;}
	graf_mouse(M_OFF,0);
	size_window() ;
	wind_open(wi_handle,xw,yw,ww,hw); /* Oeffne Fenster */
	if ((wi2_handle=wind_create(0,xdesk,ydesk,wdesk,hdesk))<0)
	{ form_alert(1,"[3][Kein Fenster mehr frei][Abbruch]"); return 1;}
	wind_open(wi2_handle,xw+ww+gl_wbox,yw,6*gl_wbox+1,2*gl_hbox+1);
	graf_mouse(M_ON,0);
	return 0;
}

void close_windows(void)
/* Schliesst Fenster und meldet es ab */
{	int x,y,b,h;
	wind_close(wi_handle); /* Schliessen */
	wind_close(wi2_handle);
	wind_delete(wi_handle); /* Abmelden */
	wind_delete(wi2_handle);
}

int rc_intersect(int x, int y, int w, int h,
	int *x1, int *y1, int *w1, int *h1)
/* Unterprogramm, das den Schnitt zweier Rechtecke ausrechnet */
{	int x2,y2;
	x2=max(x,*x1);
	y2=max(y,*y1);
	*w1=min(x+w,*x1+*w1)-x2;
	*h1=min(y+h,*y1+*h1)-y2;
	*x1=x2; *y1=y2;
	return ((*w1>0)&&(*h1>0));
}

void stein(int i,int j,int pattern)
{	int c,r,box[4];
	box[0]=(i-4)*wstein+xstein;
	box[1]=(j-4)*hstein+ystein;
	box[2]=box[0]+wstein-1;
	box[3]=box[1]+hstein-1;
	if (color>1) 
	{	vsf_interior(handle,0);
		vsf_perimeter(handle,1);
		vsf_color(handle,1);
		v_bar(handle,box);
		vsf_color(handle,color);
		vsf_interior(handle,1);
		box[0]++; box[1]++; box[2]--; box[3]--;
		v_bar(handle,box);
	}
	else
	{	vsf_color(handle,1);
		vsf_perimeter(handle,1);
		vsf_interior(handle,2);
		vsf_style(handle,pattern);
	}
	v_bar(handle,box);
}

void leer(int i,int j)
{	int c,r,box[4];
	box[0]=(i-4)*wstein+xstein;
	box[1]=(j-4)*hstein+ystein;
	box[2]=box[0]+wstein-1;
	box[3]=box[1]+hstein-1;
	vsf_color(handle,0);
	vsf_interior(handle,1);
	v_bar(handle,box);
}

void draw_all(void)
{	int i,j;
	for (i=4; i<14; i++)
		for (j=4; j<24; j++)
		    if (back[i][j])
		    	stein(i,j,back[i][j]);
		    else
		    	leer(i,j);
}

void draw_punkte(void)
{	int p[4];
	char t[16];
	wind_get(wi2_handle,WF_WORKXYWH,&p[0],&p[1],&p[2],&p[3]);
	p[2]+=p[0]; p[3]+=p[1]; p[2]--; p[3]--; 
	vsf_interior(handle,1);
	vsf_perimeter(handle,0);
	vsf_color(handle,0);
	v_bar(handle,p);
	vst_color(handle,1);
	ltoa(punkte,t,10);
	v_gtext(handle,p[0]+gl_wchar,p[1]+gl_hchar,t);
	ltoa(reihen,t,10);
	v_gtext(handle,p[0]+gl_wchar,p[1]+2*gl_hchar,t);
}

void redraw(int whandle, int p[4])
/* Neuzeichnung eines Fensters mit Handle whandle in einem Rechteck
	p, gegeben durch linke obere Ecke, rechte untere Ecke */
{	int i,j;
	if (whandle==wi_handle) /* Nur wenn es mein Fenster ist! */
	{	vsf_interior(handle,1); vsf_color(handle,0); v_bar(handle,p);
		for (i=4; i<14; i++)
		  for (j=4; j<24; j++)
		    if (back[i][j]) 
		    	stein(i,j,back[i][j]); 
	}
	else if (whandle==wi2_handle) draw_punkte();
}

void do_redraw(int whandle, int x, int y, int w, int h)
/* Uebernimmt allgemein das Neuzeichnen von Fenstern. Ruft daher
redraw auf. Die Fenster werden in Teilrechtecken neu gezeichnet. */
{	int x1,y1,w1,h1,box[4];
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE); /* Sperre Bildschirmzugriff fuer GEM */
	wind_get(whandle,WF_FIRSTXYWH,&x1,&y1,&w1,&h1);
		/* erstes neu zu zeichnendes Rechteck */
	while((w1>0)&&(h1>0))
	{	if (rc_intersect(x,y,w,h,&x1,&y1,&w1,&h1))
		{	box[0]=x1; box[1]=y1; box[2]=w1+x1-1; box[3]=h1+y1-1;
			vs_clip(handle,1,box); /* Clipping gleich hier! */
			redraw(whandle,box); /* Zeichne neu */
		}
		wind_get(whandle,WF_NEXTXYWH,&x1,&y1,&w1,&h1);
			/* Naechstes Rechteck */
	}
	wind_update(END_UPDATE); /* Gib GEM wieder frei! */
	graf_mouse(M_ON,0);
}

void copy_window(void)
/* Kopiert das Fenster vom zweiten Schirm */
{	int p[8];
	p[0]=p[4]=xstein; p[1]=p[5]=ystein; 
	p[2]=p[6]=xstein+10*wstein-1; p[3]=p[7]=ystein+20*hstein-1;
	Vsync();
	vro_cpyfm(handle,3,p,&mfdb2,&mfdb1);
}

void copy_to(void)
/* Kopiert das Fenster vom zweiten Schirm */
{	int p[8];
	p[0]=p[4]=xstein; p[1]=p[5]=ystein; 
	p[2]=p[6]=xstein+10*wstein-1; p[3]=p[7]=ystein+20*hstein-1;
	vro_cpyfm(handle,3,p,&mfdb1,&mfdb2);
}

void select_stone(void)
/* Waehlt einen der Steine per Zufall aus */
{	int i,j,n=(Random()%7);
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

int move_stone(void)
/* versucht, Stein zu bewegen. */
{	int b[18][28],i,j,down;
	long taste;
	/* Mache Backup von Stellung mit fallendem Stein */
	for (i=4; i<14; i++)
		for (j=4; j<24; j++)
			b[i][j]=sit[i][j];
	/* Falls Taste: */
	moved=0;
	if (!puffer) waitfor(t_faktor*rep_rate); 
	if (Bconstat(2))
	{	taste=Bconin(2);
		switch (taste>>16)
		{	case 0x4d : taste='6'; break;
			case 0x4b : taste='4' ; break;
			case 0x50 : taste='5' ; break;
			case 0x48 : taste='2' ; break;
			case 0x44 : taste=1; break;
		}
		switch (taste&0xFF)
		{	case '6' : js++; down=try_stone(); js--;
				is++; if (!try_stone()) { is--; clear_buffer(); }
					else moved=1;
				if (!down) goto nofall;
				break;
			case '4' : js++; down=try_stone(); js--;
				is--; if (!try_stone()) { is++; clear_buffer(); }
					else moved=1; 
				if (!down) goto nofall;
				break;
			case '5' : turn_stone(); 
				if (!try_stone()) { turn_back(); clear_buffer(); }
					else moved=1; 
				break;
			case ' ' :
			case '2' :
				do { js++; punkte+=2; } 
					while (try_stone()) ;
				js--; punkte-=2; clear_buffer(); break;
			case 27 : wind_update(END_UPDATE);
				graf_mouse(M_ON,0);
				ende=(form_alert(1,
					"[2][Pause...          ][Ok|Stop]")==2);
				graf_mouse(M_OFF,0);
				wind_update(BEG_UPDATE);
				break;
			case 1 : wind_update(END_UPDATE);
				graf_mouse(M_ON,0);
				ende=(form_alert(2,
					"[2][Pause...          ][Ok|Stop]")==2);
				graf_mouse(M_OFF,0);
				wind_update(BEG_UPDATE);
				break;
		}
	}
	/* Versuche Fall */
	if (clock()>timer+delay)
	{	js++; 
		if (!try_stone()) js--; 
		else { moved=1; punkte++; timer=clock(); }
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
	if (screen) { Setscreen(scr_adr,(void *)-1,-1); copy_to(); }
	for (i=4; i<14; i++)
		for (j=4; j<24; j++)
			if (b[i][j]!=sit[i][j])
				if (sit[i][j]) stein(i,j,sit[i][j]);
				else leer(i,j);
	if (screen) { Setscreen(phys_adr,(void *)-1,-1); copy_window(); }
	if ((!puffer)&&moved) clear_buffer(); 
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

int remove_voll(void)
/* Entfernt volle Reihen */
{	int i,j,k,erg=0,voll,voll1=0;
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
	if (voll1) draw_all();
	return erg;
}

void best(void)
{	OBJECT *o;
	int i,j;
	static STRING name="unbekannt";
	static STRING sc[10];
	if (rsrc_gaddr(R_TREE,BESTF,&o)==0) return;
	((TEDINFO *)o[BNAME].ob_spec)->te_ptext=name;
	((TEDINFO *)o[BNAME].ob_spec)->te_txtlen=16;
	(char *)o[BSPEED].ob_spec=(speed?"(schnell)":"(lahm)   ");
	/* Setze Highscores ein */
	for (i=0; i<10; i++)
	{	((TEDINFO *)o[B1+i].ob_spec)->te_ptext=namen[speed][i];
		((TEDINFO *)o[B1+i].ob_spec)->te_txtlen=16;
		ltoa(score[speed][i],sc[i],10);
		((TEDINFO *)o[S1+i].ob_spec)->te_ptext=sc[i];
		((TEDINFO *)o[S1+i].ob_spec)->te_txtlen=8;
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

void setrate(void)
{	Kbrate(start_rep,rep_rate);
}

void resetrate(void)
{		Kbrate(old_rate>>8,old_rate&0xff);
}

void play(void)
{	int i,j,p[4],x,y,w,h;
	wind_get(wi_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
	wind_get(wi_handle,WF_WORKXYWH,&xw,&yw,&ww,&hw);
	if ((w<ww)||(h<hw)) return;
	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	p[0]=xdesk; p[1]=ydesk; p[2]=wdesk+xdesk; p[3]=ydesk+hdesk;
	vs_clip(handle,1,p);
	empty_board();
	delay=maxdelay; punkte=0; reihen=0; setrate();
	draw_all(); draw_punkte();
	ende=0;
	while (1)
	{	select_stone(); timer=clock();
		clear_buffer();
		if (!try_stone()) break;
		if (ende) break;
		punkte+=5;
		while ((move_stone())&&(!ende)) ;
		for (i=4; i<14; i++)
			for (j=0; j<24; j++)
				back[i][j]=sit[i][j];
		reihen+=remove_voll();
		draw_punkte();
		wait();
		delay=min(max(mindelay,
				(maxdelay>50)?(100-punkte/200):(maxdelay-reihen/6)),
			maxdelay);
	}
	resetrate();
	wind_update(END_UPDATE);
	graf_mouse(M_ON,0);
	clear_buffer();
	best();
}

void setdelay(void)
{	if (maxdelay>40)
	{	maxdelay=40; menu_icheck(menu_tree,MENQUICK,1); speed=1; }
	else
	{	maxdelay=100; menu_icheck(menu_tree,MENQUICK,0); speed=0; }
}

void setscreen(void)
{	if (screen) 
	{	menu_icheck(menu_tree,MENSCR,0);
		screen=0;
		free(scr_adr);
	}
	else
	{	scr_adr=(char *)(((long)malloc(scr_size+256)+256)&0xFFFFFF00);
		if (scr_adr!=0)
		{	menu_icheck(menu_tree,MENSCR,1);
			screen=1; mfdb2.fd_addr=scr_adr;
		}
	}
}

void setcolors(void)
{	if (color==1) { color=2; menu_icheck(menu_tree,MENCOLOR,1); }
	else { color=1; menu_icheck(menu_tree,MENCOLOR,0); }
}

void setpuffer(void)
{	puffer=!puffer;
	menu_icheck(menu_tree,MENTAST,puffer);
}


void load_score(void)
{	FILE *sco;
	int i,sp;
	if ((sco=fopen("tetris.sco","r"))>0)
	{	for (sp=0; sp<2; sp++)
		for (i=0; i<10; i++)
		fscanf(sco,"%s %ld\n",namen[sp][i],&score[sp][i]);
		fclose(sco);
	}
}

void save_score(void)
{	FILE *sco;
	int i,sp;
	if ((sco=fopen("tetris.sco","w"))>0)
	{	for (sp=0; sp<2; sp++)
		for (i=0; i<10; i++)
		{	if (namen[sp][i][0]<'1') 
				memcpy(namen[sp][i],"unbekannt",32);
			fprintf(sco,"%s %ld\n",namen[sp][i],score[sp][i]); 
		}
		fclose(sco);
	}
}

void init(void)
{	int i,tt;
	unsigned char *adr;
	long old_stack;
	empty_board();
	/* Setze Farben */
	if (work_out[13]<=2) menu_ienable(menu_tree,MENCOLOR,0);
	else {	menu_icheck(menu_tree,MENCOLOR,1); color=2; }
	/* Baue Memory Form Description Block auf */
	mfdb2.fd_nplanes=1; i=2; while (i<work_out[13]) 
		{ i*=2; mfdb2.fd_nplanes++; }
	mfdb2.fd_w=(work_out[0]+1); mfdb2.fd_h=(work_out[1]+1);
	mfdb2.fd_wdwidth=(work_out[0]+1)>>4;
	mfdb2.fd_stand=0;
	mfdb1.fd_addr=0;
	/* Standart? */
	if ((long)(work_out[0]+1)*(work_out[1]+1)*mfdb2.fd_nplanes/8
					==32000) 
		setscreen();
	phys_adr=Physbase();
	/* Highscore=0 */
	for (i=0; i<10; i++)
	{	memcpy(namen[0][i],"unbekannt",32); 
		memcpy(namen[1][i],"unbekannt",32); 
		score[0][i]=0; score[1][i]=0; }
	load_score();
	/* Tastaturpuffer an */
	menu_icheck(menu_tree,MENTAST,1); puffer=1;
	setdelay(); /* schnell */
	tt=Tickcal(); /* Fšr Tastaturwiederholrate */
	rep_rate=1000/(tt*10);
	start_rep=rep_rate;
	t_faktor=CLK_TCK/(1000/tt);
	if (t_faktor<1) t_faktor=1;
	/* Tastenklick aus */
	old_stack=Super(0l);
	adr=(char *)0x00000484;
	old_tast=*adr;
	*adr=2;
	Super((void *)old_stack);
	/* Lies Wiederholung */
	old_rate=Kbrate(-1,-1);
}

void reinit(void)
{	char *adr;
	long old_stack;
	old_stack=Super(0l);
	adr=(char *)0x0484;
	*adr=old_tast;
	Super((void *)old_stack);
	Kbrate(old_rate>>8,old_rate&0xff);
	save_score();
	if (screen) free(scr_adr);
}	

int main_loop(void)
/* Der Ereignisverwalter. Reagiert auf verschiedene Ereignisse */
{	int ende=0;
	int msgbuf[8];
	int mx,my,mb,state,key,clicks,evt;
	if (rsrc_gaddr(R_TREE,MENMENU,&menu_tree)==0) return 1;
		/* Beschafft Adresse des Menuebaumes in der Resource */
	graf_mouse(M_OFF,0);
	menu_bar(menu_tree,1); /* Zeichne Menue */
	if (open_windows()) return 1; /* Oeffne Fenster */
	graf_mouse(M_ON,0);
	graf_mouse(ARROW,0); /* Maus ist Pfeil */
	init();
	do
	{	evt=evnt_multi(MU_KEYBD|MU_MESAG, 
							/* welche Ereignisse? */
			1,3,1, /* 1 Mausklick, beide Maustasten gedrueckt */
			0,600,20,39,20,	/* erstes zu ueberwachendes Rechteck */
			1,600,20,39,20, /* zweites " */
			msgbuf,
			30000,0,	/* Timer auf 30 Sekunden einstellen */
			&mx,&my,&mb,&state,&key,&clicks);
		if (evt & MU_MESAG) /* Message eingetroffen? */
		{	switch(msgbuf[0])
			{ case MN_SELECTED : /* Menue angewaehlt */
				{	switch(msgbuf[4])
					{ case MENQUIT : ende=1; break; 
					  case MENINFO : show_info(); break;
					  case MENQUICK : setdelay(); break;
					  case MENCOLOR : setcolors(); break;
					  case MENSCR : setscreen(); break;
					  case MENGO : play(); break;
					  case MENSCORE : save_score(); break;
					  case MENTAST : setpuffer(); break;
					  case MENLOOK : punkte=0; best(); break;
					}
					menu_tnormal(menu_tree,msgbuf[3],1);
				}
			  case WM_REDRAW : do_redraw(msgbuf[3],msgbuf[4],
			  		msgbuf[5],msgbuf[6],msgbuf[7]); break;
			  		/* Fenster neu zu zeichnen */
			  case WM_CLOSED : ende=1;
			}
		}
		else if (evt & MU_KEYBD) /* Taste gedrueckt */
			{ if (key==0x2e03) ende=1; /* Control-C? */
			  switch (key)
			  { case F1 : play(); break; 
			    case F10 : setdelay(); break;
			    case F9 : setpuffer(); break;
			    case F2 : punkte=0; best(); break;
			  }
			}	
		if (ende) 
			ende=(form_alert(1,"[2][Programm beenden][OK|Nein]")==1);
	} while (!ende);
	graf_mouse(M_OFF,0);
	close_windows(); /* Schliesse Fenster */
	menu_bar(menu_tree,0); /* Loesche Menue */
	graf_mouse(M_ON,0);
	reinit();
	return 0;
}

main()
/* Hauptprogramm */
{	if (open_vwork()) /* Arbeitstation aufmachen */
	{	if (rsrc_load("tetris.rsc")==0)  /* Resource laden */
		{	form_alert(1,"[3][Resource nicht gefunden][Abbruch]");
			return close_vwork();}
		main_loop(); /* Hauptschleife */
		rsrc_free(); /* Speicher klar */
		return close_vwork(); /* Arbeitsstation schliessen */
	}
	else form_alert(1,"[3][Fehler bei der Initialisierung][Abbruch]");
	return 0; /* Alles klar */
}
