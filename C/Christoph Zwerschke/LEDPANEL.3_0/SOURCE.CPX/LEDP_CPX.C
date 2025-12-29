/*
	LEDP_CPX, LED-Panel Config CPX

	CPX-Modul zur Konfigurierung von "LED-Panel"

	Pure-C v1.1 source code written by Th. Morus Walter

	v2.8 (12.12.1994), Th. M. Walter
		erste Version
	v2.9 (09.01.1995), Th. M. Walter, Ch. Zwerschke
		kleine Verbesserungen
	v3.0 (26.04.1995), Ch. Zwerschke
		kleine Korrektur, Font-Automatik
*/

#include <portab.h>
#include <stdlib.h>
#include <string.h>
#include "gem.h"
#include "xcontrol.h"
#include "ledpanel.h"
#include "ledp_cpx.h"

typedef struct {
	int saved;		/* 0 not set, 1 set */

	int active;		/* ab hier aus LED-Panel-Cookie-Struktur */
	long ledbits;
	int alldrvs;
	int delay;
	struct	{	int top; int right;	}	margin;
	struct	{	res1: 7; bgcol: 1; res2: 3; ledfrm: 1;
				res3: 3; ledcol: 1; } color;
	struct	{	lftspc: 1; caps: 1; cpspc: 1; rwsym: 1;
				rwspc: 1; onlya: 1; hrdspc: 1; ramspc: 1;
				allspc: 1; frespc: 1; leds: 1; datspc: 1;
				date: 1; clock: 1; time: 1; rgtspc: 1; }	setup;
	int lines;
	struct	{	char year,sec; }	dtverb;
	struct	{	char date,time; }	zero;
	struct	{	char off,on; }		clock;
	struct	{	char off,on; }		caps;
	struct	{	char caps,shft; }	keymask;
	struct	{	char hrd,ram; }		fstdrv;
} CONF;

CONF conf={0,1};	/* Einstellungen wurden nicht gespeichert */
					/* MUSS im DATA-Segment (NICHT BSS!!!) liegen */
					/* (darf also nicht nur auf 0 gesetzt sein) */
					/* MUSS erste Variable im DATA-Segment sein! */

int errno;			/* makes the linker happy */

#pragma warn -rpt /* Zeigerumwandlungen vorbergehend erlauben */
#include "ledp_cpx.rsh"	/* Resource-daten, NACH conf laden!!! */
#pragma warn .rpt /* Zeigerumwandlungen wie immer behandeln */

LEDP *ledp;			/* Zeiger auf LED-Panel-Cookie-Struktur */

CPX_PARAMS *params;

GRECT *cpx_wind; /* Arbeitsbereich des XControl-Fensters */
OBJECT *dialog1,*dialog2,*wbox; /* Objektb„ume aus der Resource */

/*
	init (!!! muž erste Funktion sein !!!)
*/

CPX_INFO *cdecl init(CPX_PARAMS *par)
{
	int cdecl do_cpx(GRECT *curr_wind);
	static CPX_INFO info={do_cpx,0l,0l,0l,0l,0l,0l,0l,0l,0l};

	if ( par->booting ) {
		/*
				Aufruf beim Booten
		*/
		if ( (*par->find_cookie)(LEDP_MAGIC,(long*)&ledp) &&
			 ledp->header.magic==LEDP_MAGIC &&
			 ledp->header.varlen==LEDP_VARLEN ) {
			/*
					LED-Panel da -> kopiere Voreinstellungen in Cookie-Struktur
			*/
			if ( conf.saved )
				memcpy(&ledp->active,&conf.active,sizeof(CONF)-sizeof(int));
			if ( ledp->header.version>=0x0300 &&
				!ledp->lines ) {	/* Font-Automatik */
				int r; graf_handle(&ledp->chrsize.w,&ledp->chrsize.h,&r,&r);
			}
		}
		return (CPX_INFO*)1l;	/* nicht set_only */
	}
	else {
		/*
				Modul aktiviert
		*/
		params=par;
		if ( !params->rsc_init ) {
			(*(params->do_resource))(NUM_OBS,NUM_FRSTR,NUM_FRIMG,NUM_TREE,
					rs_object,rs_tedinfo,rs_strings,rs_iconblk,rs_bitblk,rs_frstr,rs_frimg,rs_trindex,rs_imdope);
			dialog1=(OBJECT*)rs_trindex[DIALOG1];
			dialog2=(OBJECT*)rs_trindex[DIALOG2];
			wbox=(OBJECT*)rs_trindex[WHITEBOX];
		}
		return &info;	/* -> do_cpx wird vom XControl aufgerufen */
	}
}

/*
	Zeichne Objekt im CPX-Fenster
*/

void draw_object(OBJECT *tree,int object)
{
	objc_draw(tree,object,MAX_DEPTH,
		cpx_wind->g_x,cpx_wind->g_y,cpx_wind->g_w,cpx_wind->g_h);
}

/*
	Zeichne Objektbaum im CPX-Fenster
*/

void draw_tree(OBJECT *tree)
{
	tree[ROOT].ob_x=cpx_wind->g_x;
	tree[ROOT].ob_y=cpx_wind->g_y;
	draw_object(tree,ROOT);
}

/*
		Kopiere Einstellungen aus conf in Cookie-Struktur, zeige LED-Panel an
*/

void set_conf(CONF *conf)
{
	int x,y,w,h;

	ledp->active=0;							/* LED-Panel aus */
	x=ledp->lstrect.x; y=ledp->lstrect.y;
	w=ledp->lstrect.w; h=ledp->lstrect.h;

	if ( x<0 )
		{ w+=x; x=0; if ( w<0 ) w=0; }
	if ( w && h ) {
		wbox->ob_x=x; wbox->ob_y=y;
		wbox->ob_width=w; wbox->ob_height=h;
		ledp->lstrect.w=ledp->lstrect.h=0;
		objc_draw(wbox,0,0,x,y,w,h);
	}
	memcpy(&ledp->active,&conf->active,sizeof(CONF)-sizeof(int));
	if ( ledp->active )
		ledp->active|=0x8000;				/* erzwinge Neuzeichnen */
}

/*
		Setze Buttons fr TIME und DATE
*/

void set_timedate(void)
{
	strcpy(objc_spec(dialog2,JAHR),
		!objc_selected(dialog2,DATE) && objc_selected(dialog2,TIME) ?
		"2in1" : "Jahr");
	if ( objc_selected(dialog2,DATE) || objc_selected(dialog2,TIME) )
		objc_enabled(dialog2,JAHR);
	else
		objc_disabled(dialog2,JAHR);
	if ( objc_selected(dialog2,TIME) )
		objc_enabled(dialog2,SEK);
	else
		objc_disabled(dialog2,SEK);
}

/*
		Kopiere Einstellungen aus Cookie-Struktur nach conf,
		passe eventuell Dialog an LED-Panel-"light" an,
		setze LED-Panel Version und Datum im Dialog 1,
		setze Dialog entsprechend Einstellungen.
*/

int init_conf(CONF *conf)
{
	char *str; int i; long mask;
	static const char txt_delay[3],txt_dist[3],txt_year[5];

	/* Header berprfen */

	if ( !(*params->find_cookie)(LEDP_MAGIC,(long*)&ledp) ||
		 ledp->header.magic!=LEDP_MAGIC )
		return -1;		/* Cookie nicht gefunden */
	if ( ledp->header.varlen!=LEDP_VARLEN )
		return -2;		/* falsche LEDP-Version */

	/* Dialog an "light"-Version anpassen */

	if ( ledp->header.light ) {
		for ( i=CAPS_CHA; i<=SP2; i++ )
			objc_hide(dialog2,i);
		for ( i=SP4; i<=SP6; i++ )
			objc_hide(dialog2,i);
	}
	else {
		for ( i=CAPS_CHA; i<=SP2; i++ )
			objc_unhide(dialog2,i);
		for ( i=SP4; i<=SP6; i++ )
			objc_unhide(dialog2,i);
	}

	str=objc_tedstr(dialog1,TITEL);
	str+=13;	/* Datum eintragen */
	*str++=((ledp->header.version>>8)&0xF)+'0';
	str++;
	*str++=(ledp->header.version&0xF)+'0';
	str++;
	str++;
	*str++=((ledp->header.verdate>>28)&0xF)+'0';
	*str++=((ledp->header.verdate>>24)&0xF)+'0';
	str++;
	*str++=((ledp->header.verdate>>20)&0xF)+'0';
	*str++=((ledp->header.verdate>>16)&0xF)+'0';
	str++;
	*str++=((ledp->header.verdate>>4)&0xF)+'0';
	*str++=(ledp->header.verdate&0xF)+'0';

	/* Konfiguration bernehmen */

	memcpy(&conf->active,&ledp->active,sizeof(CONF)-sizeof(int));

	/*
		Deselektiere alles (redundant,
		weil Resource jedesmal neu geladen wird)

	for ( i=DRVIVES; i<=SWITCH1; i++ )
		objc_unselect(dialog1,i);
	for ( i=CAPS_CHA; i<=SWITCH2; i++ )
		objc_unselect(dialog2,i);

	*/

	/*
		Variable Texte auf eigene Puffer zeigen lassen
		(da es sonst Probleme mit String-Merging geben kann)
	*/

	objc_spec(dialog1,DELAY)=txt_delay;
	objc_spec(dialog2,DIST)=txt_dist;
	objc_spec(dialog2,JAHR)=txt_year;

	/* Kn”pfe voreinstellen */

	if ( conf->active ) {
		objc_select(dialog1,AKTIV1);
		objc_select(dialog2,AKTIV2);
	}

	for ( i=DRV_A,mask=1; i<=DRV_T; i++,mask+=mask ) {
		objc_enabled(dialog1,i);
		if ( conf->ledbits&mask )
			objc_select(dialog1,i);
	}
	if ( conf->alldrvs ) {
		objc_select(dialog1,DRV_ALL);
		for ( i=DRV_A; i<=DRV_T; i++ )
			objc_disabled(dialog1,i);
	}
	if ( conf->setup.onlya )
		objc_select(dialog1,DRV_BA);

	if ( conf->delay>=0 && conf->delay<100 )
		itoa(conf->delay,objc_spec(dialog1,DELAY),10);
	else
		strcpy(objc_spec(dialog1,DELAY),"6");

	dialog2[CAPS_CHA].ob_spec.obspec.character=conf->caps.on;
	dialog2[DATE_ZER].ob_spec.obspec.character=conf->zero.date;
	dialog2[TIME_ZER].ob_spec.obspec.character=conf->zero.time;

	if ( conf->color.bgcol )
		objc_select(dialog2,SCHWARZ);
	if ( conf->color.ledfrm )
		objc_select(dialog2,RUND);
	if ( conf->color.ledcol )
		objc_select(dialog2,COLOR);

	if ( conf->setup.lftspc )
		objc_select(dialog2,SP1);
	if ( conf->setup.caps )
		objc_select(dialog2,CAPS);
	if ( conf->setup.cpspc )
		objc_select(dialog2,SP2);
	if ( conf->setup.rwsym )
		objc_select(dialog2,RW);
	if ( conf->setup.rwspc )
		objc_select(dialog2,SP3);
	if ( conf->setup.leds )
		objc_select(dialog2,LEDS);
	if ( conf->setup.datspc )
		objc_select(dialog2,SP4);
	if ( conf->setup.date )
		objc_select(dialog2,DATE);
	if ( conf->setup.clock )
		objc_select(dialog2,SP5);
	if ( conf->setup.time )
		objc_select(dialog2,TIME);
	if ( conf->setup.rgtspc )
		objc_select(dialog2,SP6);

	set_timedate();
	if ( conf->dtverb.year )
		objc_select(dialog2,JAHR);
	if ( conf->dtverb.sec )
		objc_select(dialog2,SEK);

	if ( conf->setup.hrdspc )
		objc_select(dialog2,D1);
	if ( conf->setup.ramspc )
		objc_select(dialog2,D2);
	if ( conf->setup.allspc )
		objc_select(dialog2,XLUECKEN);
	if ( conf->setup.frespc )
		objc_select(dialog2,LUECKEN);

	dialog2[D1].ob_spec.obspec.character=conf->fstdrv.hrd+'A';
	dialog2[D2].ob_spec.obspec.character=conf->fstdrv.ram+'A';

	objc_select(dialog2,conf->lines+FIT);

	itoa(conf->margin.right,objc_spec(dialog2,DIST),10);

	return 0;
}

/*
		Lese Einstellungen im Dialog aus
*/

void get_button(CONF *conf)
{
	int i; long mask;

	conf->active=0;
	if ( objc_selected(dialog1,AKTIV1) )
		conf->active=1;

	conf->ledbits=0;
	for ( i=DRV_A,mask=1; i<=DRV_T; i++,mask+=mask )
		if ( objc_selected(dialog1,i) )
			conf->ledbits|=mask;
	conf->alldrvs=0;
	if ( objc_selected(dialog1,DRV_ALL) )
		conf->alldrvs=1;
	conf->setup.onlya=0;
	if ( objc_selected(dialog1,DRV_BA) )
		conf->setup.onlya=1;

	conf->delay=atoi(objc_spec(dialog1,DELAY));

	conf->caps.on=dialog2[CAPS_CHA].ob_spec.obspec.character;
	conf->zero.date=dialog2[DATE_ZER].ob_spec.obspec.character;
	conf->zero.time=dialog2[TIME_ZER].ob_spec.obspec.character;

	conf->color.bgcol=0;
	if ( objc_selected(dialog2,SCHWARZ) )
		conf->color.bgcol=1;
	conf->color.ledfrm=0;
	if ( objc_selected(dialog2,RUND) )
		conf->color.ledfrm=1;
	conf->color.ledcol=0;
	if ( objc_selected(dialog2,COLOR) )
		conf->color.ledcol=1;

	conf->setup.lftspc=0;
	if ( objc_selected(dialog2,SP1) )
		conf->setup.lftspc=1;
	conf->setup.caps=0;
	if ( objc_selected(dialog2,CAPS) )
		conf->setup.caps=1;
	conf->setup.cpspc=0;
	if ( objc_selected(dialog2,SP2) )
		conf->setup.cpspc=1;
	conf->setup.rwsym=0;
	if ( objc_selected(dialog2,RW) )
		conf->setup.rwsym=1;
	conf->setup.rwspc=0;
	if ( objc_selected(dialog2,SP3) )
		conf->setup.rwspc=1;
	conf->setup.leds=0;
	if ( objc_selected(dialog2,LEDS) )
		conf->setup.leds=1;
	conf->setup.datspc=0;
	if ( objc_selected(dialog2,SP4) )
		conf->setup.datspc=1;
	conf->setup.date=0;
	if ( objc_selected(dialog2,DATE) )
		conf->setup.date=1;
	conf->setup.clock=0;
	if ( objc_selected(dialog2,SP5) )
		conf->setup.clock=1;
	conf->setup.time=0;
	if ( objc_selected(dialog2,TIME) )
		conf->setup.time=1;
	conf->setup.rgtspc=0;
	if ( objc_selected(dialog2,SP6) )
		conf->setup.rgtspc=1;

	conf->dtverb.year=0;
	if ( objc_selected(dialog2,JAHR) )
		conf->dtverb.year=1;
	conf->dtverb.sec=0;
	if ( objc_selected(dialog2,SEK) )
		conf->dtverb.sec=1;

	conf->setup.hrdspc=0;
	if ( objc_selected(dialog2,D1) )
		conf->setup.hrdspc=1;
	conf->setup.ramspc=0;
	if ( objc_selected(dialog2,D2) )
		conf->setup.ramspc=1;
	conf->setup.allspc=0;
	if ( objc_selected(dialog2,XLUECKEN) )
		conf->setup.allspc=1;
	conf->setup.frespc=0;
	if ( objc_selected(dialog2,LUECKEN) )
		conf->setup.frespc=1;

	conf->fstdrv.hrd=dialog2[D1].ob_spec.obspec.character-'A';
	conf->fstdrv.ram=dialog2[D2].ob_spec.obspec.character-'A';

	if ( objc_selected(dialog2,ONE) )
		conf->lines=1;
	else if ( objc_selected(dialog2,TWO) )
		conf->lines=2;
	else
		conf->lines=0;

	conf->margin.right=atoi(objc_spec(dialog2,DIST));
}

/*
		Bearbeite Button in Dialog 1
*/

void do_dialog1(int objc)
{
	int i;

	if ( objc==DRV_ALL ) {
		if ( objc_selected(dialog1,DRV_ALL) )
			for ( i=DRV_A; i<=DRV_T; i++ )
				objc_disabled(dialog1,i);
		else
			for ( i=DRV_A; i<=DRV_T; i++ )
				objc_enabled(dialog1,i);
		draw_object(dialog1,DRIVES);
	}
	else if ( objc==DELAY_M || objc==DELAY_P ) {
		i=atoi(objc_spec(dialog1,DELAY));
		if ( objc==DELAY_M && i>0 )
			i--;
		else if ( objc==DELAY_P && i<99 )
			i++;
		itoa(i,objc_spec(dialog1,DELAY),10);
		draw_object(dialog1,DELAY);
	}
	else if ( objc==AKTIV1 ) {
		objc_state(dialog2,AKTIV2)=objc_state(dialog1,AKTIV1);
	}
}

/*
		Bearbeite Button in Dialog 2
*/

void do_dialog2(int objc)
{
	int i;
	static const unsigned char caps[]="C^øù";

	if ( objc==CAPS_CHA ) {
		for ( i=0; i<7; i++ )
			if ( dialog2[CAPS_CHA].ob_spec.obspec.character==caps[i] )
				break;
		if ( ++i>=7 ) i=0;
		dialog2[CAPS_CHA].ob_spec.obspec.character=caps[i];
		draw_object(dialog2,CAPS_CHA);
	}
	else if ( objc==DATE_ZER ) {
		if ( dialog2[DATE_ZER].ob_spec.obspec.character=='0' )
			dialog2[DATE_ZER].ob_spec.obspec.character='';
		else
			dialog2[DATE_ZER].ob_spec.obspec.character='0';
		draw_object(dialog2,DATE_ZER);
	}
	else if ( objc==TIME_ZER ) {
		if ( dialog2[TIME_ZER].ob_spec.obspec.character=='0' )
			dialog2[TIME_ZER].ob_spec.obspec.character='';
		else
			dialog2[TIME_ZER].ob_spec.obspec.character='0';
		draw_object(dialog2,TIME_ZER);
	}
	else if ( objc==TIME || objc==DATE ) {
		set_timedate();
		draw_object(dialog2,JAHR);
		draw_object(dialog2,SEK);
	}
	else if ( objc==L1 || objc==P1 ) {
		if ( dialog2[D1].ob_spec.obspec.character>'A' && objc==L1 )
			dialog2[D1].ob_spec.obspec.character--;
		else if ( dialog2[D1].ob_spec.obspec.character<'T' && objc==P1 )
			dialog2[D1].ob_spec.obspec.character++;
		draw_object(dialog2,D1);
	}
	else if ( objc==M2 || objc==P2 ) {
		if ( dialog2[D2].ob_spec.obspec.character>'A' && objc==M2 )
			dialog2[D2].ob_spec.obspec.character--;
		else if ( dialog2[D2].ob_spec.obspec.character<'T' && objc==P2 )
			dialog2[D2].ob_spec.obspec.character++;
		draw_object(dialog2,D2);
	}
	else if ( objc==DIST_M || objc==DIST_P ) {
		i=atoi(objc_spec(dialog2,DIST));
		if ( objc==DIST_P && i>0 )
			i--;
		else if ( objc==DIST_M && i<99 && ledp->lstrect.x>0 )
			i++;
		itoa(i,objc_spec(dialog2,DIST),10);
		draw_object(dialog2,DIST);
	}
	else if ( objc==AKTIV2 ) {
		objc_state(dialog1,AKTIV1)=objc_state(dialog2,AKTIV2);
	}
}

/*	Hauptprogramm */

int cdecl do_cpx(GRECT *curr_wind)
{
	int error,msg_buff[8],button,abort=0; OBJECT *dialog;

	cpx_wind=curr_wind; /* curr_wind global zur Verfgung stellen */

	error=init_conf(&conf);

	switch ( error ) { /* should not happen / safety first */
		case 0:
			dialog=dialog1;
			break;
		case -1:
			dialog=(OBJECT*)rs_trindex[ALERT1];
			break;
		case -2:
		default:
			dialog=(OBJECT*)rs_trindex[ALERT2];
			break;
	}

	draw_tree(dialog);

	do {
		button=(*params->do_form)(dialog,0,msg_buff);

		if ( button>=0 )
			button&=0x7FFF;

		if ( button==SWITCH1 && dialog==dialog1 ) {
			dialog[button].ob_state &= ~SELECTED;
			draw_tree(dialog=dialog2);
		}
		else if ( button==SWITCH2 && dialog==dialog2 ) {
			dialog[button].ob_state &= ~SELECTED;
			draw_tree(dialog=dialog1);
		}
		else if ( (button==SICHERN1 && dialog==dialog1) ||
				  (button==SICHERN2 && dialog==dialog2) ) {
			dialog[button].ob_state &= ~SELECTED;
			draw_object(dialog,button);
			get_button(&conf);
			conf.saved=1;
			if ( (*params->alert)(0)==1 )
				(*params->write_config)(&conf,sizeof(conf));
		}
		else if ( (button==OK1 && dialog==dialog1) ||
				  (button==OK2 && dialog==dialog2) ) {
			dialog[button].ob_state &= ~SELECTED;
			get_button(&conf);
			abort=1;
		}
		else if ( (button==ABBRUCH1 && dialog==dialog1) ||
				  (button==ABBRUCH2 && dialog==dialog2) ) {
			dialog[button].ob_state &= ~SELECTED;
			abort=1;
		}
		else if ( dialog!=dialog1 && dialog!=dialog2 )
			abort=1;
		else if ( button==-1 ) {		/* Event-Message */
			switch ( msg_buff[0] ) {
				case WM_CLOSED:
					if (!error)
						get_button(&conf);
				case AC_CLOSE:
					abort=1;
			}
		}
		else {				/* Funktions-Button aktiviert */
			if ( !error ) {
				CONF localconf;
				if ( dialog==dialog1 )
					do_dialog1(button);
				else
					do_dialog2(button);
				localconf=conf;
				get_button(&localconf);
				set_conf(&localconf);
			}
		}
	} while ( !abort );

	if ( !error )
		set_conf(&conf);
	return 0;
}
