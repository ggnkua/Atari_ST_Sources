#include <tos.h>
#include <gem.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>

#include "sdump.h"

#ifdef GEMDUMP							/* anpassung fÅr GEMDUMP */

#	include "gemdump.rsh"				/* resourcen */
#	include "gemdump.h"

	extern XINST inst;					/* definiert in gd_start.s */
	extern int ev_time;
	extern int althelp;
	extern long ah_time;
	int scr_nr;
 	int evnts=MU_MESAG;
 
	int do_store_img(char *name,MFDB *buffer,int wid,int hght,COLOR *col,int xflag);
	void make_name(char *name);
	long do_init_vbl(void),do_exit_vbl(void);

#	define init_vbl()		Supexec(do_init_vbl)
#	define exit_vbl()		Supexec(do_exit_vbl)

#	define _store_img		do_store_img
#	define _make_name		make_name
#	define MENUE_ENTRY		"  GEM-Dump"
#	define PARAM_SAVE		"C:\\GEMDUMP.ACC"
#	define PARAM_EXT		"*.ACC"
#	define PAR_OFF			32

#else									/* anpassung fÅr SCRDUMP */

#	include "scrdump.rsh"				/* resourcen */
#	include "scrdump.h"

#	define inst				dump->inst
#	define scr_nr			dump->nr
#	define _store_img		dump->store_img
#	define _make_name		dump->make_name
#	define MENUE_ENTRY		"  ScreenDump"
#	define PARAM_SAVE		"C:\\AUTO\\XALTHELP.PRG"
#	define PARAM_EXT		"*.PRG"
#	define PAR_OFF			30
#endif

OBJECT *dialog;							/* globale variable */
int handle,dummy;
int planes,screen_w,screen_h;

/*
    cookie-routine
		get_cookie liefert zeiger zu cookie mit id 'cookie' oder 0l falls nicht gefunden
*/
typedef struct
{
	long	id,
			*ptr;
} COOKJAR;

long *get_cookie(long cookie)	
{
long	sav;
COOKJAR	*cookiejar;
int	i = 0;

	sav=Super((void *)1L);
	if ( sav==0L )
		sav=Super(0L);

	cookiejar=*((COOKJAR **)0x05a0l);

	if ( sav!=-1L )
		Super((void *)sav);

	if ( cookiejar ) {
		while ( cookiejar[i].id ) {
			if ( cookiejar[i].id==cookie )
				return cookiejar[i].ptr;
			i++;
		}
	}
	return 0l;
}

/*
	clipping fÅr fenster
*/
#define min(a,b)	((a)<(b))?(a):(b)
#define max(a,b)	((a)>(b))?(a):(b)

int check_recs(int x,int y,int dx,int dy,int *x1,int *y1,int *dx1,int *dy1)
{		/* 'clippt' rechteck in x1,y1,dx1,dy1 mit rechteck in x,y,dx,dy */
		/* rÅckgabe: TRUE falls rechteck Åbrigbleibt, sonst FALSE */
int hx1,hy1,hx2,hy2;

	hx2=min(x+dx,*x1+*dx1);
	hy2=min(y+dy,*y1+*dy1);
	hx1=max(x,*x1);
	hy1=max(y,*y1);
	*x1=hx1; *y1=hy1;
	*dx1=hx2-hx1; *dy1=hy2-hy1;
	return (hx2>hx1)&&(hy2>hy1);
}

/*
	erzeuge puffer mit grîûe dx/dy in MFDB help
	gebe lÑnge zurÅck falls erfolgreich
	sonst 0l
*/
long set_fdb(int dx,int dy,MFDB *help)
{
long len;

	help->fd_w=dx;
	help->fd_h=dy; 
	help->fd_wdwidth=help->fd_w/16;
	if ( dx&15 )
		help->fd_wdwidth++;
	help->fd_nplanes=planes;
	help->fd_stand=0;
	help->fd_r1=help->fd_r2=help->fd_r3=0;

	len=(long)help->fd_wdwidth*2l*(long)help->fd_h*(long)planes;
	help->fd_addr=Malloc(len);
	if ( help->fd_addr )
		return len;
	return 0;
}

/*
	draw_objc
	undraw_objc
		zeichne dialog mit pufferung des hintergrundes (falls mîglich)
*/
int draw_objc(OBJECT *objc_addr,int *x,int *y,int *dx,int *dy,MFDB *buffer)
{
int xy[8];
int ret;
MFDB screen;

	form_center(objc_addr, x,y,dx,dy);
	buffer->fd_addr=0L;
	screen.fd_addr=0L;

	if ( set_fdb(*dx+1,*dy+1,buffer) ) {
		check_recs(0,0,screen_w,screen_h,x,y,dx,dy);
		xy[0]=*x; xy[1]=*y; xy[2]=*x+*dx; xy[3]=*y+*dy;
		xy[4]=0; xy[5]=0; xy[6]=*dx; xy[7]=*dy;
		v_hide_c(handle);
		vro_cpyfm(handle,3,xy,&screen,buffer);
		v_show_c(handle,1);
		ret=1;
	}
	if ( buffer->fd_addr==0L ) {
		form_dial(FMD_START, *x,*y,*dx,*dy, *x,*y,*dx,*dy);
		ret=0;
	}
	objc_draw(objc_addr, 0,5, *x,*y,*dx,*dy);
	return(ret);
}

void undraw_objc(int x,int y,int dx,int dy,MFDB *buffer,int flag)
{
int xy[8];
MFDB screen;

	if ( flag ) {
		screen.fd_addr=0L;
		xy[0]=0; xy[1]=0; xy[2]=dx; xy[3]=dy;
		xy[4]=x; xy[5]=y; xy[6]=x+dx; xy[7]=y+dy;
		v_hide_c(handle);
		vro_cpyfm(handle,3,xy,buffer,&screen);
		v_show_c(handle,1);
		Mfree(buffer->fd_addr);
	}
	else {
		form_dial(FMD_FINISH, x,y,dx,dy, x,y,dx,dy);
	}
}

/*
	initialisiere vdi
*/
void init_vdi(void)
{
int i;
int work_in[12],work_out[58];

     handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
     for ( i=0; i<10; i++ )
     	work_in[i]=1;
     work_in[10]=2;

     v_opnvwk(work_in,&handle,work_out);

	screen_w=work_out[0]+1;
	screen_h=work_out[1]+1;
/*
	pix_wid=work_out[3];		/* should be used in save-img */
	pix_hght=work_out[4];		/* not yet implemented */
*/

	vq_extnd(handle,1,work_out);
	planes=work_out[4];
}

#ifdef GEMDUMP							/* spezielle routinen fÅr GEMDUMP */

/*
	lese 200Hz-ZÑhler aus
*/
static long _gettimer(void)
{
	return *(long*)0x4BA;
}
long gettimer(void)
{
	return Supexec(_gettimer);
}

/*
	ermittle konvertierungstabelle fÅr farben
*/
void get_conv_tab(char *conv_tab)
{
int i,j;
unsigned int c;
int set,col;
int ger_buf[8],std_buf[8];
int xy[]={0,0,0,0,0,0,0,0};
MFDB screen={0,0,0,0,0,0,0,0,0},
	 ger=	{0,1,1,1,0,0,0,0,0},
	 std=	{0,1,1,1,1,0,0,0,0};

	vswr_mode(handle,MD_REPLACE);
	vsm_type(handle,1);
	vsm_height(handle,1);
	wind_update(BEG_UPDATE);

	v_get_pixel(handle,0,0,&set,&col);

	ger.fd_nplanes=std.fd_nplanes=planes;
	ger.fd_addr=ger_buf;
	std.fd_addr=std_buf;

	for ( i=0; i<(1<<planes); i++ ) {
		vsm_color(handle,i);
		v_pmarker(handle,1,xy);
		vro_cpyfm(handle,S_ONLY,xy,&screen,&ger);
		vr_trnfm(handle,&ger,&std);
		conv_tab[i]=0;
		for ( j=0; j<planes; j++ ) {
			c=std_buf[j];
			c>>=15;
			c<<=j;
			conv_tab[i]|=(char)c;
		}
	}

	if ( set )
		vsm_color(handle,col);
	else
		vsm_color(handle,WHITE);

	v_pmarker(handle,1,xy);
	wind_update(END_UPDATE);
}

/*
	lese farben ein
*/
void get_colors(COLOR *col)
{
char conv_tab[256];
int i;

	get_conv_tab(conv_tab);
	for ( i=0; i<(1<<planes); i++ )
		vq_color(handle,i,0,(int*)&col[conv_tab[i]]);
}

/*
	speichere den ganzen bildschirm (gem-konform)
*/
int gem_screen(void)
{
MFDB std,buffer,screen;
long len;
COLOR colors[256];
char name[64];
int xy[8];
int err;

	_make_name(name);
	err=-39;							/* speicherfehler */
										/* (wird Åberschrieben, wenn er nicht eintritt */

										/* puffer fÅr screen anlegen */
	if ( (len=set_fdb(screen_w,screen_h,&buffer))!=0l ) {
		memset(buffer.fd_addr,0,len);
		screen.fd_addr=0l;
		xy[0]=xy[1]=xy[4]=xy[5]=0;
		xy[2]=xy[6]=screen_w-1;
		xy[3]=xy[7]=screen_h-1;
										/* kopiere screen */
		vro_cpyfm(handle,3,xy,&screen,&buffer);
										/* zweiter puffer zum konvertieren */
										/* (vr_trnfm geht nicht mit screen als quelle) */
		if ( set_fdb(screen_w,screen_h,&std)!=0l ) {
			std.fd_stand=1;
										/* konvertieren */
			vr_trnfm(handle,&buffer,&std);
			if ( inst.ximg )
				get_colors(colors);
										/* und speichern */
			err=_store_img(name,&std,screen_w,screen_h,colors,inst.ximg);
			Mfree(std.fd_addr);
		}
		Mfree(buffer.fd_addr);
	}
	return err;
}
#endif

/*
	rufe dateiselector auf
*/
int fsel(char *path,char *sel,int *button,char *label)
{
int h;

	if ( *path==0 ) {
		*path=Dgetdrv()+'A';
		strcpy(path+1,":\\*.*");
	}

	if ( _GemParBlk.global[0]>=0x130 )
		h=fsel_exinput(path,sel,button,label);
	else
		h=fsel_input(path,sel,button);

	if ( h==0 )		/* fehler -> abbruch */
		*button=0;

	return h;
}

/*
	hole dateinamen via fileselector
*/
int get_name(char *name,char *ext,char *label)
{
char path[64],file[32],*h;
int button;

	strcpy(path,name);
	h=strrchr(path,'\\');
	if ( h ) {
		h++;
		strcpy(file,h);
		*h=0;
		strcat(path,ext);
	}
	else
		*file=0;

	fsel(path,file,&button,label);

	if ( button ) {
		strcpy(name,path);
		h=strrchr(path,'\\');
		if ( h ) 
			h++;
		else
			h=file;
		strcpy(h,file);
		return 1;
	}
	return 0;
}

/*
	haupt-routine nach acc/prg aufruf
*/
void do_work(void)
{
int ret,err;
int x,y,w,h,flag;
MFDB buffer,screen;
char name[64];
#ifndef GEMDUMP
	SCREEN_DUMP *dump;					/* zeiger auf cookie */
#endif

	init_vdi();							/* init vdi */
										/* setzt screen_w,screen_h,planes */
  	screen.fd_addr=0l;

#ifndef GEMDUMP
										/* cookie suchen */
	dump=(SCREEN_DUMP*)get_cookie('SDMP');
										/* kein keks da, falscher keks? */
	if ( !dump || dump->magic!='TMMW' ) {
		form_alert(1,"[3][ | Cookie nicht gefunden! | ][Abbruch]");
		return;							/* und tschÅss */
	}
#endif
										/* dialog voreinstellen */
	strcpy(objc_tedstr(dialog,PATH),inst.file);
	if ( inst.ximg )
		objc_select(dialog,XIMG);
	else
		objc_unselect(dialog,XIMG);
	objc_unselect(dialog,RESET);
#ifdef GEMDUMP
	if ( inst.althelp )
		objc_select(dialog,ALTHELP);
	else
		objc_unselect(dialog,ALTHELP);
#endif

	wind_update(BEG_UPDATE);
										/* zeichne dialog */
	flag=draw_objc(dialog,&x,&y,&w,&h,&buffer);
	do {								/* bearbeite dialog */
		ret=form_do(dialog,0)&0x7FFF;
		if ( ret==SELECT ) {			/* namen via fsel eingeben */
		  char *c,*t=objc_tedstr(dialog,PATH);

			objc_unselect(dialog,SELECT);
			if ( get_name(t,"*.IMG","Pfad fÅr ScreenDump einstellen") ) {
				c=strrchr(t,'\\');
				if ( !strcmp(c,"\\*.IMG") ) {
					*(c+1)=0;
					strcat(t,"SCR");
				}
				else {
					c=strrchr(t,'.');
					if ( !strcmp(c,".IMG") )
						*c=0;
				}
			}
			objc_draw(dialog,0,10,x,y,w,h);
		}
	} while ( ret==SELECT );
	objc_unselect(dialog,ret);
	undraw_objc(x,y,w,h,&buffer,flag);
	if ( !flag ) {						/* hintergrund war nicht gesichert */
		wind_update(END_UPDATE);		/* -> gebe aes zeit zum restaurieren */
		evnt_timer(250,0);				/*		des hintergrundes */
		wind_update(BEG_UPDATE);
	}

	if ( ret!=CANCEL ) {				/* daten einlesen */
		strcpy(inst.file,objc_tedstr(dialog,PATH));
		if ( objc_selected(dialog,XIMG) )
			inst.ximg=1;
		else
			inst.ximg=0;

		if ( objc_selected(dialog,RESET) )
			scr_nr=0;

#ifdef GEMDUMP							/* zus. opt von GEMDUMP */
		if ( inst.althelp && !objc_selected(dialog,ALTHELP) ) {
			inst.althelp=0;
			evnts&=~MU_TIMER;
			exit_vbl();
		}
		else if ( !inst.althelp && objc_selected(dialog,ALTHELP) ) {
			if ( init_vbl() ) {
				inst.althelp=1;			/* nur wenn init_vbl erfolgreich */
				evnts|=MU_TIMER;
			}
		}
#endif
	}

	err=0;

	if ( ret==SAVE ) {					/* speichern */
	  char name[64];
	  int f_id;
	  long id;
		strcpy(name,PARAM_SAVE);
		if ( get_name(name,PARAM_EXT,"Parameter speichern") ) {
			f_id=Fopen(name,FO_RW);
			Fseek(PAR_OFF,f_id,0);
			Fread(f_id,4,&id);
			if ( id=='TMMW' ) {
				Fwrite(f_id,sizeof(inst),&inst);
			}
			Fclose(f_id);
		}
	}
										/* fenster oder rahmen speichern */
	else if ( ret==WINDOW || ret==DRAG ) {
	  long len;
	  int mx,my,mb;
	  int wi,x,y,w,h,xy[8];

		wind_update(BEG_MCTRL);

										/* ermittle koordinaten */
		if ( ret==WINDOW ) {				/* fenster */
			graf_mouse(POINT_HAND,0l);
			evnt_button(2+3+256,3,0,&mx,&my,&mb,&dummy);
			if ( mb==1 ) {
				wi=wind_find(mx,my);
				wind_get(wi,WF_WORKXYWH,&x,&y,&w,&h);
			}
		}
		else {								/* rahmen */
			graf_mouse(THIN_CROSS,0l);
			evnt_button(2+3+256,3,0,&x,&y,&mb,&dummy);
			if ( mb==1 ) {
				graf_rubberbox(x,y,-screen_w,-screen_h,&w,&h);
				if ( w<0 )
					{ x+=w; w=-w; }
				if ( h<0 )
					{ y+=h; h=-h; }
			}
		}
		graf_mouse(ARROW,0l);
		wind_update(END_MCTRL);

											/* speichern wenn links-klick */
		if ( mb==1 ) {
			err=-39;						/* speicherfehler */
											/* (wird Åberschrieben, wenn er nicht eintritt */
			check_recs(0,0,screen_w,screen_h,&x,&y,&w,&h);
			if ( (len=set_fdb(w,h,&buffer))!=0l ) {
				memset(buffer.fd_addr,0,len);
				xy[0]=x; xy[1]=y; xy[2]=x+w-1; xy[3]=y+h-1;
				xy[4]=0; xy[5]=0; xy[6]=w-1; xy[7]=h-1;
				screen.fd_addr=0;
				v_hide_c(handle);
				vro_cpyfm(handle,3,xy,&screen,&buffer);
				v_show_c(handle,1);
				_make_name(name);
#ifdef GEMDUMP 								/* fÅr GEMDUMP: transformiere nach std */
				{ MFDB std;
				  COLOR colors[256];
					if ( (len=set_fdb(w,h,&std))!=0l ) {
						std.fd_stand=1;
						vr_trnfm(handle,&buffer,&std);
						if ( inst.ximg )
							get_colors(colors);
						_store_img(name,&std,w,h,colors,inst.ximg);
						Mfree(std.fd_addr);
					}
					Mfree(buffer.fd_addr);
				}
#else
				err=_store_img(name,&buffer,w,h,0l,inst.ximg);
				Mfree(buffer.fd_addr);
#endif
			}
		}
	}
	else if ( ret==SCREEN ) {			/* ganzer bildschirm */
#ifdef GEMDUMP
		err=gem_screen();						/* gem konform */
#else
		_make_name(name);					/* xbios/vdi-esc/line-a-vars */
		err=_store_img(name,&screen,0,0,0l,inst.ximg);
#endif
	}

	if ( err<0 ) {						/* fehler ausgeben */
		if ( err==-1000 )
			form_alert(1,"[3][ Schreibfehler! | Platte voll?! | ][Abbruch]");
		else
			form_error(-err-31);
	}

	wind_update(END_UPDATE);
	v_clsvwk(handle);
}

/*
	acc-schleife
*/	
int main(void)
{
int gl_apid,acc_id;
int message[8];
OBJECT *ob;
#ifdef GEMDUMP
int evnt;
#endif

		/* anmelden beim aes */
	gl_apid=appl_init();

		/* dialog initialisieren */
	dialog=rs_object;
	ob=dialog;
	do {
		rsrc_obfix(ob,0);
	} while ( !(objc_flags(ob++,0)&LASTOB) );


	/*
		ACC
	*/
	if ( !_app ) {
		acc_id=menu_register(gl_apid,MENUE_ENTRY);
										/* anmelden */

#ifdef GEMDUMP
		if ( inst.althelp ) {			/* alt/help-abfrage einschalten */
			init_vbl();
			evnts|=MU_TIMER;
		}
#endif

		while ( TRUE ) {				/* acc-schleife */
#ifdef GEMDUMP 								/* fÅr GEMDUMP */
			evnt=evnt_multi(evnts, 0,0,0, 0,0,0,0,0, 0,0,0,0,0,
					 message, ev_time,0, &dummy, &dummy,&dummy,&dummy,&dummy,&dummy);

										/* timer-evnt, althelp flag ein, zeit passt noch */
			if ( evnt&MU_TIMER && althelp && gettimer()-ah_time<200 ) {					
				init_vdi();
				gem_screen();
				v_clsvwk(handle);
				althelp=0;
			}
										/* acc-aufruf */
			else if ( evnt&MU_MESAG && message[0]==AC_OPEN && message[4]==acc_id ) {
				do_work();
			}
#else										/* fÅr SCRDUMP (kein TIMER_EVNT) */
			evnt_mesag(message);
			if ( message[0]==AC_OPEN && message[4]==acc_id ) {
				do_work();
			}
#endif
		}
	}
	else {			/* programm */
		graf_mouse(ARROW,0l);
		do_work();
	}
	appl_exit();
	return 0;
}
