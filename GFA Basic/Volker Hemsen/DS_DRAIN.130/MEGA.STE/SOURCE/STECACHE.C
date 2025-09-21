/* 						MEGA STE CACHE CHANGE
				   	   von Volker Hemsen  05/92
				  	  erstellt mit Lattice C 5.5				*/
		
/*	Mit diesem Programm kann man einige grundlegende Systemveriablen
	ver„ndern: ste_ctl, conterm, fverify und Blitmode.
	Es l„uft als Programm und als Accessory. Bei Programmlauf werden
	die entsprechenden Werte bestimmt und in einer Dialogbox
	dargestellt. Bei Drcken des 'OK'-Buttons werden sie entsprechend
	wieder ver„ndert. Als Accessory l„uft es etwas anders: Nach dem
	Laden sucht es die Datei 'MEGASTE.INF' und stellt nach Erfolg die
	zuvor gespeicherten Werte ein. Alles andere l„uft wie beim
	Programmlauf.
	ACHTUNG!!! Dieses Programm legt keine Rcksicht auf die Hardware.
	Und wird deshalb wohl nur auf dem MEGA STE laufen.
	Es belegt ca. 7 KByte.										*/
	

#include "stecac_r.h"

/*	GEM-Variablen	*/
int ap_id,msg[11];
extern int _XMODE;

/*	Programmvariablen	*/
char ste_ctl,conterm;
int fverify,blitter;
char *ste_ctl_vec;
char *conterm_vec;
int *fverify_vec;
char pfad[81];
	
/*	Unterprogramme	*/
void dialog_dial(void);
void set_obstate(int,int);
int get_obstate(int);
void get_things(void);
void set_parameter(void);
void get_parameter(void);
void save_parameter(void);
void load_parameter(void);


/*		Installation und GEM-Verwaltung		*/
void main(void)
{
	int d;
	
	if ((ap_id=appl_init())>=0)
	{
		if (_XMODE==2)
			if ((menu_register(ap_id,"  MEGA STE Cache")<0)
				for(;;);
				
		rsrc_init();
		ste_ctl_vec=0xFFFF8E21L;
		conterm_vec=0x484L;
		fverify_vec=0x444L;
		d=Dgetdrv();						/*	Stammpfad bestimmen	*/
		pfad[0]=d+65;pfad[1]=':';
		Dgetpath(&pfad[2],d+1);
		strcat(pfad,"\\STECACHE.INF");
		
		if (_XMODE<=1)
		{
			get_parameter();
			graf_mouse(ARROW,NULL);
			dialog_dial();
		}
		else
		{
			load_parameter();
			for(;;)
			{
				evnt_mesag(msg);
				if (msg[0]==AC_OPEN)
					dialog_dial();
			}
		}
		appl_init();
	}	/*	appl_init	*/
}	/*	main	*/

/*		Darstellung und Belegung der Dialogbox		*/
void dialog_dial(void)
{
	int x,y,b,h,ex;
	GRECT rect;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	form_center(TDIAL,&x,&y,&b,&h);
	form_dial(0,0,0,0,0,x,y,b,h);
	
	set_obstate(DD16,ste_ctl&2);
	set_obstate(DDCACHE,ste_ctl&1);
	set_obstate(DDVERIFY,fverify!=0);
	set_obstate(DDKLICK,conterm&1);
	set_obstate(DDREPEAT,conterm&2);
	set_obstate(DDASC7,conterm&4);
	set_obstate(DDBLIT,blitter&1);
	
	objc_draw(TDIAL,0,3,x,y,b,h);
	do
	{
		ex=form_do(TDIAL,0);
		set_obstate(ex,0);
		if (ex==DDSAVE)
		{
			get_things();
			save_parameter();
			objc_xywh(TDIAL,ex,&rect);
			objc_draw(TDIAL,ex,2,rect.g_x,rect.g_y,rect.g_w,rect.g_h);
		}
	}
	while (ex==DDSAVE);
	if (ex==DDOK)
	{
		get_things();
		set_parameter();
	}
	form_dial(3,0,0,0,0,x,y,b,h);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

void set_obstate(int ob,int state)
{
	int *st;
	st=&TDIAL[ob].ob_state;
	if (state==0)
		*st&=0xFE;
	else
		*st|=1;
}

int get_obstate(int ob)
{
	return(TDIAL[ob].ob_state&1);
}

/*		Objekte abfragen		*/
void get_things(void)
{
	ste_ctl=get_obstate(DDCACHE)+(get_obstate(DD16)<<1);
	conterm=(get_obstate(DDKLICK)+(get_obstate(DDREPEAT)<<1)+(get_obstate(DDASC7)<<2));
	fverify=get_obstate(DDVERIFY);
	blitter=get_obstate(DDBLIT);
}

/*		Systemvariablen auslesen		*/
void set_parameter(void)
{
	long stack;
	stack=Super(0L);
	*ste_ctl_vec&=0xFC;
	*ste_ctl_vec|=ste_ctl;
	*conterm_vec&=0xF8;
	*conterm_vec|=conterm;
	*fverify_vec=fverify;
	Super((long)stack);
	Blitmode(blitter);
}

/*		Systemvariablen einstellen		*/
void get_parameter(void)
{
	long stack;
	stack=Super(0L);
	ste_ctl=*ste_ctl_vec;
	conterm=*conterm_vec;
	fverify=*fverify_vec;
	Super((long)stack);
	blitter=Blitmode(-1);
}

void save_parameter(void)
{
	int fh;
	get_things();
	fh=Fcreate(pfad,0);
	if (fh>0)
	{
		Fwrite(fh,21L,"MEGA STE CACHE CHANGE");
		Fwrite(fh,1L,&ste_ctl);
		Fwrite(fh,1L,&conterm);
		Fwrite(fh,2L,&fverify);
		Fwrite(fh,2L,&blitter);
		Fclose(fh);
	}
}

/*		Auslesen nur im ACC-Betrieb		*/
void load_parameter(void)
{
	int fh;
	fh=Fopen(pfad,0);
	if (fh>0)
	{
		Fseek(21L,fh,0);
		Fread(fh,1L,&ste_ctl);
		Fread(fh,1L,&conterm);
		Fread(fh,2L,&fverify);
		Fread(fh,2L,&blitter);
		Fclose(fh);
		set_parameter();
	}
	else
		get_parameter();
}
