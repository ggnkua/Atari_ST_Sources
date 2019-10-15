/****************************************************/
/*                                                  */
/*      	Funktions-Plotter						*/
/*		    Demonstration fÅr einen schnellen       */
/*			Formel-Interpreter						*/
/*			erstellt mit TURBO C 2.0				*/
/*													*/
/*			(c) 1991 by Richard Kurz				*/
/*			Vogelherdbogen 62						*/
/*			7992 Tettnang							*/
/*													*/
/*			TOS Magazin								*/
/*													*/
/****************************************************/
/*													*/
/*	Hier im Modul FPLOT.C befindet sich das GEM-	*/
/*	GerÅst sowie der Funktionsplotter. 				*/
/*	Die Kommunikation mit dem Formel-Interpreter	*/
/*	findet Åber die Funktionen "make_pcode",		*/
/*	"evalute" und die Variable "fehler" statt.		*/
/*	Meine Kommentare in FPLOT.C halten sich in		*/
/*	Grenzen, da die hier verwendeten Funktionen		*/
/*	nicht zum Thema Formelinterpretation gehîren.	*/
/*	Man mîge mir verzeihen!							*/
/*													*/
/****************************************************/

#include <vdi.h>
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h> 
#include <string.h> 
#include <math.h> 
#include <errno.h> 
#include "fplot.h"
#include "eval.h"

#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))

/*	LÑnger sollte die Formel nicht werden			*/
#define MAXEINGABE 40

/*	öber diese Variable werden Fehlermeldungen		*/
/*	von den Funktionen "make_pcode" und "evalute"	*/
/*	zurÅckgegeben.									*/
extern int fehler;

/*	Die Åblichen GEM-Basteleien						*/
int handle;
int apid;
int max_x, max_y;
int workin[12], workout[57], px[128], msgbuff[8];

/*	Globale Variablen								*/
int w_handle, wx, wy, ww, wh;
int fertig=FALSE;
char eingabe[MAXEINGABE]="40*(SIN(X/25)+0.6*SIN(3*X/25))"; 
OBJECT *menu;
OBJECT *dialog;
OBJECT *info;
OBJECT *hilfe;
MFDB buffer;
MFDB schirm={NULL};

/*	Eine handvoll Prototypen						*/
int	buffer_init(void);
void handle_buffer(int f);
int open_window(void);
void close_window(int wh);
int rc_intersect(GRECT *r1,GRECT *r2);
void clipping(int x,int y,int w,int h,int m);
void redraw_window(int x,int y,int w,int h);
void w_cls(void);
int handle_dialog(OBJECT *o);
void handle_fehler(void);
int handle_file(int flag);
void fplot(int xs,int ys,int xm,int ym);
void schleife(void);

int buffer_init(void)
/*	Hier wird Speicher fÅr einen Puffer geholt	*/
/*	und die MFDB's initialisiert, um den 		*/
/*	Bildschirminhalt sichern zu kînnen.			*/
/*	Dies ist nîtig um die Redraw-Aufrufe in		*/
/*	aktzeptablem Speed ablaufen zu lassen.		*/
/*	Ja, ich bin mir der Verschwendung von 		*/
/*	Speicher (cirka 6kB) bewuût, hatte aber		*/
/*  keine Lust es zu Ñndern! Selber machen ist	*/
/*	angesagt.									*/
{
	int x,y,p;
	
	x=max_x+1;
	y=max_y+1;
	vq_extnd(handle,1,workout);
	p=workout[4];
	
	buffer.fd_wdwidth=(x+16)/16; 
	buffer.fd_addr=malloc((long)buffer.fd_wdwidth*2L*(long)y*(long)p);
	if(buffer.fd_addr==NULL)
	{
		Cconout('\a');
		form_alert(1,"[3][ |Leider ist der Speicher|zu knapp][ Schade ]");
		return(FALSE);
	}
	buffer.fd_w=x;
	buffer.fd_h=y;
	buffer.fd_stand=1;
	buffer.fd_nplanes=p;
	return(TRUE);
} /* buffer_init */

void handle_buffer(int f)
/* 	Wird TRUE Åbergeben, sichert handle_buffer	*/
/*	den Bildschirminhalt, bei FALSE geht's 		*/
/*	umgekehrt.									*/
{
	graf_mouse(M_OFF,0);
	px[0]=px[1]=px[4]=px[5]=0;
	px[2]=px[6]=max_x;
	px[3]=px[7]=max_y;
	if(f)
	{
		vs_clip(handle,0,px);
		vro_cpyfm(handle,S_ONLY,px,&schirm,&buffer); 
	}
	else
	{
		vro_cpyfm(handle,S_ONLY,px,&buffer,&schirm); 
	}
	graf_mouse(M_ON,0);
} /* handle_buffer */

int open_window(void)
/* ôffnet ein Fenster	*/
{
   	int x,y,w,h;
   	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
   	if ((w_handle=wind_create(NAME|CLOSER|INFO,x,y,w,h))<0)
   	{
      	form_alert(1,"[3][Kann kein Fenster îffnen.][ Pech ]");
      	return(FALSE);
   	}
   	graf_mouse(M_OFF,0);
   	wind_set(w_handle,WF_NAME," Funktions-Plotter ",0,0);
   	wind_set(w_handle,WF_INFO,eingabe,0,0);
   	graf_growbox(0,0,0,0,x,y,w,h);
   	wind_open(w_handle,x,y,w,h);
   	wind_get(w_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);
   	graf_mouse(M_ON,0);
   	return(TRUE);
} /* open_window */

void close_window(int wh)
/* Macht das Gegenteil von open_window	*/
{
	int x,y,w,h;

	wind_get(wh,WF_CURRXYWH,&x,&y,&w,&h);
	wind_close(wh);
	graf_shrinkbox(0,0,0,0,x,y,w,h);
	wind_delete(wh);
} /* close_window */

int rc_intersect(GRECT *r1,GRECT *r2)
/* Stellt fest, ob sich zwei Rechtecke schneiden	*/
{
   int x,y,w,h;

   x=max(r2->g_x,r1->g_x);
   y=max(r2->g_y,r1->g_y);
   w=min(r2->g_x+r2->g_w,r1->g_x+r1->g_w);
   h=min(r2->g_y+r2->g_h,r1->g_y+r1->g_h);
   r2->g_x=x;
   r2->g_y=y;
   r2->g_w=w-x;
   r2->g_h=h-y;
   return((w>x)&&(h>y));
} /* rc_intersect */

void clipping(int x,int y,int w,int h,int m)
/* Vereinfachung des vs_clip-Aufrufs	*/
{
   px[0]=x; px[1]=y;
   px[2]=x+w-1; px[3]=y+h-1;
   vs_clip(handle,m,px);
} /* clipping */

void redraw_window(int x,int y,int w,int h)
/*	Die REDRAW-Meldungen vom AES werden abgearbeitet	*/
{
   GRECT r1,r2;

   r2.g_x=px[0]=x; 
   r2.g_y=px[1]=y;
   r2.g_w=w;
   r2.g_h=h;
   px[2]=x+w-1;
   px[3]=y+h-1;

   graf_mouse(M_OFF,0);
   wind_get(w_handle,WF_FIRSTXYWH,&r1.g_x,&r1.g_y,&r1.g_w,&r1.g_h);
   while (r1.g_w && r1.g_h)
   {
      if (rc_intersect(&r2,&r1)==TRUE)
      { 
         clipping(r1.g_x,r1.g_y,r1.g_w,r1.g_h,TRUE);
         handle_buffer(FALSE);
      }
      wind_get(w_handle,WF_NEXTXYWH,&r1.g_x,&r1.g_y,&r1.g_w,&r1.g_h);
   }
   clipping(r1.g_x,r1.g_y,r1.g_w,r1.g_h,FALSE);
   graf_mouse(M_ON,0);
} /* redraw_window */

void w_cls(void)
/* Der Fensterinhalt wird gelîscht */
{
	vsf_color(handle,0);
	px[0]=wx; px[1]=wy; 
	px[2]=ww+wx-1; px[3]=wh+wy-1;
 	graf_mouse(M_OFF,0);  
	v_bar(handle,px);
	graf_mouse(M_ON,0);  
} /* w_cls */

int handle_dialog(OBJECT *o)
/* Vereinfachung der Dialogbearbeitung	*/
{
	int x,y,w,h,e;
	
	form_center(o,&x,&y,&w,&h);	
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
	objc_draw(o,0,2,x,y,w,h);
	e=form_do(o,0) & 0x7fff;
	o[e].ob_state &= ~SELECTED;
	form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	return(e);
} /* handle_dialog */

void handle_fehler(void)
/*	Fehler werden im Klartext ausgegeben	*/
{
	char *s;
	
	switch(fehler)
	{
		case 1: s=" Syntax Fehler"; break;
		case 2: s=" Math. öberlauf"; break;
		case 3: s=" Stack öberlauf"; break;
		case 4: s=" Zahl verlangt"; break;
		case 5: s=" Pcode voll"; break;
		default: s=" Interner Fehler"; break;
	}
	Cconout('\a');
   	wind_set(w_handle,WF_INFO,s,0,0);
   	fehler=0;
   	errno=0;
}/* handle_fehler */

int handle_file(int flag)
/* Datei-Angelegenheiten */
{
	static char fname[14],pfad[128],fn[128];
	int fp;
	char *s;

	if(!pfad[0])
	{
		pfad[0]=Dgetdrv()+'A';
		pfad[1]=':';
		Dgetpath(&pfad[2],0);
		strcat(pfad,"\\*.FNX");
	}
	if((Sversion()>>8)<=20)
	{
		if(!fsel_input(pfad,fname,&fp)) return(-1);
	}
	else
	{
		if(flag==MFSICH) s="Funktion sichern";
		else s="Funktion laden";
		if(!fsel_exinput(pfad,fname,&fp,s)) return(-1);
	}
	if(!fp) return(TRUE);
	strcpy(fn,pfad);
	s=strrchr(fn,'\\');
	if(s!=NULL) strcpy(++s,fname);
	else strcpy(fn,fname);
	
	if(flag==MFSICH)
	{
		fp=Fcreate(fn,0);
		if(fp<0) return(fp);
		if(Fwrite(fp,MAXEINGABE-1,eingabe)<MAXEINGABE-1) return(-1);
	}
	else
	{
		fp=Fopen(fn,0);
		if(fp<0) return(fp);
		if(Fread(fp,MAXEINGABE-1,eingabe)<MAXEINGABE-1) return(-1);
	}
	return(Fclose(fp));
} /* handle_file */

void fplot(int xs,int ys,int xm,int ym)
/* 	Schau, Schau, ein Funktionsplotter!	*/
{
	int	xoff=(xm-xs)/2,
		yoff=ym-(ym-ys)/2,
		v=100,
		py,ply,
		erg,x,y;
			
	for(x=0;x<=v;x+=2)
	{
		if(Cconis()) return;
		ply=yoff*2;
		for(y=v;y>=-v;y-=2)
		{
			erg=evalute(sqrt(x*x+y*y))-y/2;
			if(fehler) return;
			py=yoff-erg;
			if(py<ply)
			{
				ply=py;
				px[1]=px[3]=py;
				px[0]=px[2]=xoff+x;
				v_pline(handle,2,px);
				px[0]=px[2]=xoff-x;
				v_pline(handle,2,px);
			}
		}
	}	
}/* fplot */

void schleife(void)
/* 	Hier nun die Hauptschleife, das ganze dreht */
/*	sich um einen event_mesag Aufruf			*/
{
	int i;
	char *ez;
	
	ez=dialog[EZ1].ob_spec.tedinfo->te_ptext;
	strcpy(ez,eingabe);
  	do
	{
   		evnt_mesag(msgbuff);
   		wind_update(BEG_UPDATE); 
		switch(msgbuff[0])
		{
    		case MN_SELECTED:
	   			switch(msgbuff[4])
     			{
					case MINFO:
						handle_dialog(info);
						break;
					case MHILFE:
						handle_dialog(hilfe);
						break;
					case MENDE:
		    			close_window(w_handle);
						fertig=TRUE;
						break;
					case MFLADEN:
					case MFSICH:
						if(handle_file(msgbuff[4])<0)
						{
							form_alert(1,"[3][ |Datei Fehler][ Okay ]");
							strcpy(eingabe,ez);
						}
						else
						   	wind_set(w_handle,WF_INFO,eingabe,0,0);
						break;
					case MFEINGA:
						strcpy(ez,eingabe);
						i=handle_dialog(dialog);
						if(i==EFERTIG || i==ESTART)
						{
							strupr(ez);
							*eingabe=0;
							strcpy(eingabe,ez);
						   	wind_set(w_handle,WF_INFO,eingabe,0,0);
						   	if(i==EFERTIG) break;
						}
						else
						{
							*ez=0;
							strcpy(ez,eingabe);
							break;
						}
					case MSTART:
						w_cls();						
				   		graf_mouse(M_OFF,0);  
						clipping(wx,wy,ww,wh,1);
						if(make_pcode(eingabe))
						{
							fplot(wx,wy,wx+ww-1,wy+wh-1);
						}
						if(fehler) handle_fehler();
				   		graf_mouse(M_ON,0);  
						handle_buffer(TRUE);
					default:
						break;
    	   		}
	   	       	menu_tnormal(menu,msgbuff[3],1);
    	       	break;
			case WM_REDRAW:
    			redraw_window(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
		    	break;
    		case WM_CLOSED:               
	         	close_window(w_handle);
       		 	fertig=TRUE;
		     	break;
    		case WM_TOPPED:
	      	case WM_NEWTOP:
	         	wind_set(msgbuff[3],WF_TOP,0,0,0,0);
	         	wind_get(msgbuff[3],WF_WORKXYWH,&wx,&wy,&ww,&wh);
	      		break;
    		default:
    			break;
   		}
    	wind_update(END_UPDATE);
	} while (!fertig);
} /* schleife */

void main(void)
/* Der Nabel des C-Programmes	*/
{
	int i,fx,fy,fw,fh;

   	if ((apid=appl_init())!=-1)
   	{
      	handle=graf_handle(&i,&i,&i,&i);
      	for (i=1;i<10;workin[i++]=1);
      	workin[10]=2;
      	workin[0]=handle;
      	v_opnvwk(workin,&handle,workout);
        max_x=workout[0];
        max_y=workout[1];
		if (rsrc_load("FPLOT.RSC")>0)
		{
      		rsrc_gaddr(0,MENU,&menu);
      		rsrc_gaddr(0,DIALOG,&dialog);
      		rsrc_gaddr(0,EINFO,&info);
      		rsrc_gaddr(0,HILFE,&hilfe);
      		graf_mouse(M_OFF,0);  
      		menu_bar(menu,1); 
      		graf_mouse(M_ON,0);
      		graf_mouse(ARROW,0);
			if(open_window()==TRUE)
			{
				w_cls();
				form_center(info,&fx,&fy,&fw,&fh);
				objc_draw(info,0,1,fx,fy,fw,fh);
				if(buffer_init())
				{
					handle_buffer(TRUE);
		      		schleife();
					free(buffer.fd_addr);
		      	}
			}
      		graf_mouse(M_OFF,0);
      		menu_bar(menu,0);   
      		graf_mouse(M_ON,0);
      		rsrc_free();      
		}
		else
		{
			Cconout('\a');
    		form_alert(1,"[3][FPLOT.RSC nicht gefunden.][ Pech ]");
    	}
   	}
   	else
   	{
		Cconout('\a');
      	fprintf(stderr,"Fehler bei der Programminitialisierung!");
      	exit(-1);
   	}
   	v_clsvwk(handle);
   	appl_exit();
   	exit(0);
} /* main */
