/*************************************************************************
**																								**
**										NEC - POWER											**
**																								**
**										CPX - Modul											**
**																								**
**																								**
**					(C) Copyright by Hartmut Klindtworth, 1993					**
**																								**
**																								**
**************************************************************************
**																								**
**																								**
**		Aufgabe:																				**
**		Initialisiert die Dip-Schalter der NEC-P20/P30 Drucker!				**
**																								**
*************************************************************************/







/* Die normalen, Åblichen Header-Dateien ------------------------------	*/

#include <portab.h>
#include	<tos.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <stddef.h>
#include <stdio.h>





/* DEFINES ------------------------------------------------------------	*/

#define	TRUE		1
#define	FALSE		0
#define	NIL		0L

#define BSETZE(X,Y)  	(X=(X |  ((1L)<<Y)))
#define BCLEAR(X,Y)		(X=(X & ~((1L)<<Y)))
#define BTESTE(X,Y)		((X & ((1L)<<Y)) ? TRUE : FALSE)

#define	MESSAGE	-1				/* Messager-Event ist gekommen				*/

#define	SLIDER_MINSIZE		6	/* Slider sollte mind. diese Grîûe haben	*/
#define	VISIBLE				4	/*	Anzahl der sichtbaren EintrÑge			*/
#define	HORIZONTAL			1	/* Art des Sliders								*/
#define	VERTICAL				0	/* Art des Sliders								*/
#define	ACTIV				TRUE	/* Flags zum Zeichnen							*/
#define	INACTIVE		  FALSE	/* Flags zum Zeichnen							*/


#define	MAX_STRINGS		 114	/*	Anzahl der gesamten Strings				*/
#define	MAX_ACTIVE		  27	/* Anzahl der maximalen EintrÑge				*/
#define  MAX_ACTLEN		  19	/* LÑnge des maximalen Eintrags				*/
#define	EINTRAG_LENGTH	  30	/* LÑnge der lÑngsten Eintrags				*/
#define	BUTTON_LENGTH	   8	/* LÑnge der lÑngsten Eintrags				*/

#define NEC		stdprn
#define ONLINE	Bcostat(0)==-1
#define START	"\x1c\x6D\x02"
#define RESET	"\x1c\x6D\x02\x7f\x00\x00\x00"



/* GLOBALE VARIABLEN	--------------------------------------------------	*/

/* Deklaration der zu sichernden Variablen ... */

typedef struct	
		  {
				LONG	nec_flags[MAX_ACTIVE];
				WORD	gewaehlt;	/*	Alles oder GewÑhltes anzeigen?			*/
				WORD	num;			/* Anzahl der aktiven EintrÑge				*/							
				WORD	begin;		/* erster sichtbare Eintrag					*/
		  		WORD	max_num;		/* Anzahl der maximal aktiven EintrÑge		*/
		 		char (*buffer)[EINTRAG_LENGTH];	/* Buffer fÅr Anzeige		*/
		 		char (*button)[BUTTON_LENGTH];	/* Buffer fÅr Anzeige		*/
				LONG	select_flag;/* Bit gesetzt oder nicht zeigt es an.		*/
		  } ANZEIGE;

									/*	ACHTUNG! Dies steht am Anfang des Daten-	*/
									/*		segmentes. Alles vorher ist nur zur		*/
									/*		Deklaration gedacht.							*/
ANZEIGE anzeige={ 									/* Anzahl von MAX_ACTIVE	*/
			{		1L, 128L, 1L, 1L, 2L, 1L, 1L, 2L,
				1024L,   1L, 1L, 2L, 2L, 1L, 4L, 1L, 1L, 2L, 1L,
					2L,  64L, 1L, 1L, 1L, 2L,
				  16L,  16L }, FALSE,0,0,0,NULL,NULL,0xffffffffL};



/* Resource-Datei deshalb erst hier einladen --------------------------	*/

#include "NEC_RSC.C"
#include "NEC_RSC.H"
#include <xcontrol.h>






/* sonstige globale Variablen -----------------------------------------	*/

WORD 	errno;				/* Damit der Linker Ruhe gibt!						*/
WORD	_FilSysV;			/*																*/
CPX_PARAMS *params;		/* vom Kontrollfeld Åbergebener Zeiger auf die	*/
								/* Kontrollfeld-Funktionen								*/

OBJECT *haupt;				/* Zeiger auf Dialogboxen								*/
OBJECT *conf;				/* Zeiger auf Konfigurationsbaum						*/
OBJECT *infouser;			/* Zeiger auf Informationsbox							*/
		
UWORD	aktiv_nr[30];		/* Nummer der Aktiven EintrÑge						*/

WORD	active_zeilen[VISIBLE]={	ZEILE1, ZEILE2, ZEILE3, ZEILE4 };
WORD	active_button[VISIBLE]={	BUTTON1, BUTTON2, BUTTON3, BUTTON4 };

WORD belegung[MAX_ACTIVE]=
			{
COTPS, COPSP, CODSP, COLCS, COCSD, COSOZ, COGPD, COQUI,
COFFL, COSOE, COLPI, COMEM, COATO, COCUP,	COCRF, COLFF, COBLF, COPUL, COSFL,
CODCC, COBAU, COWOR, COPAR, CODCD, COCOM,
CODHA, COLQA
			};
WORD	nec_max[MAX_ACTIVE]=
			{
				 2,11, 2,19, 2, 2, 2, 2,					/* = 42 Strings		*/
				12, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2,		/*	= 33 Strings 		*/
				 3, 8, 2, 3, 2, 3,							/* = 21 Strings		*/
				 9, 9												/*	= 18 Strings		*/
			};														/* insg.: 114			*/


char	nec_config[228][14]=
		{
			"FRONT P.", "FRONT", "SOFTWARE", "SOFT.",
			"COURIER 10",	"COU 10",
			"COURIER 12",	"COU 12",
			"PRESTI. 10",	"PRE 10",
			"PRESTI. 12",	"PRE 12",
			"QUICKG. 10",	"QGO 10",
			"QUICKG. 12",	"QGO 12",
			"DRAFTQ. 10",	"DGO 10",
			"DRAFTQ. 12",	"DGO 12",
			"HELVETICA ",	"HELVET",
			"TIMES PS  ",	"TIMES",
			"BOLD PS   ",	"BOLD",
			"HIGH SPEED",	"SPEEDY",
			"NORMAL",		"NORMAL",				
			"USA    ",		"USA",
			"FRANCE ",		"FRA",
			"GERMANY",		"GER",
			"ENGLAND",		"ENG",
			"DANEMA1",		"DM1",
			"SWEDEN ",		"SWD",
			"ITALIEN",		"ITL",
			"SPAIN 2",		"SPA",
			"JAPAN  ",		"JPN",
			"NORWEGE",		"NOR",
			"DANEMA2",		"DM2",
			"HOLLAND",		"NET",
			"TöRKEI ",		"TUK",
			"SPAIN 2",		"SP2",
			"LATEINA",		"LA",
			"MULTILI",		"MUL",
			"PORTUGA",		"POR",
			"CAN-FRE",		"CFR",
			"NORWEG2",		"NR2",
			"ITALIC",		"ITALIC",
			"IBM   ",		"IBM",
			"OFF",			"OFF",
			"ON ",			"ON",
			"UNIDIREC",		"UNI",
			"BIDIREC ",		"BI",
			"QUIET",			"ON",
			"LOUD ",			"OFF",
			"   3 ZOLL",			"3 ZOLL",
			"  3\xab" " ZOLL",	"3\xab" " ZOLL",
			"   4 ZOLL",			"4 ZOLL",
			"  5\xab" " ZOLL",	"5\xab" " ZOLL",
			"   6 ZOLL",			"6 ZOLL",
			"   7 ZOLL",			"7 ZOLL",
			"   8 ZOLL",			"8 ZOLL",
			"  8\xab" " ZOLL",	"8\xab" " ZOLL",
			"  11 ZOLL",			"11 ZOLL",
			"11.6 ZOLL",			"11.6 \"",
			"  12 ZOLL",			"12 ZOLL",
			"  14 ZOLL",			"14 ZOLL",
			"ON ",			"ON",
			"OFF",			"OFF",
			"6",				"8",
			"6",				"8",	
			"DISABLE",		"OFF",
			"ENABLE ",		"ON",
			"DISABLE",		"OFF",
			"ENABLE ",		"ON",
			"ACRYLIC",		"ACRYLIC",
			"ROLLER ",		"ROLLER",
			"CR ONLY  ",	"CR ONLY",
			"CR & LF  ",	"CR & LF",
			"CR W/O PO",	"CR W/O",
			"LF & CR",		"LF & CR",
			"LF ONLY",		"LF ONLY",
			"ON ",			"ON",
			"OFF",			"OFF",
			"ON ",			"ON",
			"OFF",			"OFF",
			"COLUMN 1 ",	"COL 1",
			"COLUMN 35",	"COL 35",
			"8 KB Buffer  ",			"8 KB B.",
			"4 KB/ 96 Char",			"4 KB/96",
			"\xab" " KB/128 Char",	"\xab" " K/128",
			"  150 Baud",		"150",
			"  300 Baud",		"300",
			"  600 Baud",		"600",
			" 1200 Baud",		"1200",
			" 2400 Baud",		"2400",
			" 4800 Baud",		"4800",
			" 9600 Baud",		"9600",
			"19200 Baud",		"19200",
			"8 BITS",			"8 BITS",
			"7 BITS",			"7 BITS",
			"NONE",				"NONE",
			"ODD ",				"ODD",
			"EVEN",				"EVEN",
			"DISABLE",		"OFF",
			"ENABLE ",		"ON",
			"ETX/ACK   ",	"ETX/ACK",
			"X-ON/X-OFF",	"X-ON",
			"REPETITION",	"REPETI.",	
			"-4",	"-4",
			"-3",	"-3",
			"-2",	"-2",
			"-1",	"-1",
			" 0",	"0",
			" 1",	"1",
			" 2",	"2",
			" 3",	"3",
			" 4",	"4",
			"-4",	"-4",
			"-3",	"-3",
			"-2",	"-2",
			"-1",	"-1",
			" 0",	"0",
			" 1",	"1",
			" 2",	"2",
			" 3",	"3",
			" 4",	"4"	
		};	
				




/* Prototypen fÅr PURE C ----------------------------------------------	*/

WORD cdecl main(GRECT *curr_wind);
OBJECT *get_traddr(WORD tree_index);
void redraw_object(OBJECT *tree, WORD object, WORD unbedingt);
void init_slider(WORD *slider_pos, WORD draw);
void wind_center(OBJECT *tree, WORD *x, WORD *y, WORD *w, WORD *h);
void init_anzeige(char (*active)[EINTRAG_LENGTH],char (*actbut)[BUTTON_LENGTH]);
void into_resource(WORD draw);
void move_vslider(OBJECT *tree, WORD parent, WORD slider, WORD *slider_pos);
void pos_vslider(OBJECT *tree, WORD parent, WORD slider, WORD *slider_pos);
void scroll_up(void);
void scroll_down(void);
WORD konfiguriere( WORD *new);
void read_select(void);
void set_select(void);
void into_box( WORD nr );
void pulldown( WORD button, WORD objc_button, char (*actbut)[BUTTON_LENGTH]);
void buttonclick( WORD button, WORD objc_button,
														 char (*actbut)[BUTTON_LENGTH]);
WORD berechne_index(WORD bank, WORD nr, WORD zeige);






/* Funktionen --------------------------------------------------------- */

					/* Initialisierung des Moduls:									*/
					/*	öbergabeparameter: Zeiger auf die zur VerfÅgung 		*/
					/*							 stehenden Funktionen					*/
					/*	1. Aufruf bei Laden des Headers (par->booting==TRUE) 	*/
					/*		RÅckgabe: 0 bei Set-Only, 1 sonst						*/
					/*	2. Aufruf bei Laden des eigentlichen Programms 			*/
					/*		(par->booting==FALSE)										*/
					/*		RÅckgabe: Adresse der CPX_INFO-Strukturen				*/

CPX_INFO * cdecl init(CPX_PARAMS *par)
{
	LONG		version;	
	char 		vdo[5]="_VDO";
	static 	CPX_INFO info={ main, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L };
	
	if(par->booting) 	/* bei Laden des Headers alle Parameter setzen		*/
	{
		/* keine Frequenz auf dem TT setzen	*/
		if(!(*par->find_cookie)(*(LONG *)vdo, &version))
				version = 0L;
		
		return((CPX_INFO *)1L);	/* Wert !=0, damit Arbeit weitergefÅhrt wird*/
	}
	else
	{
		params=par;
		
		if(!params->rsc_init)
		{
			(*(params->do_resource))(NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
			rs_object, rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk,
			rs_frstr, rs_frimg, rs_trindex, rs_imdope);
			
			/* globale Variablen initialiseren	*/
			haupt=get_traddr(HAUPT);
			conf=get_traddr(CONFMAIN);
			infouser=get_traddr(USERINFO);
		}
		
		return(&info);
	}
}








					/*	Aufruf nach einem Doppelklick auf das Icon im Aus-		*/
					/* wahlfenster: Zeichnen der Dialogbox, Behandlung der	*/
					/*					 Buttons												*/
					/*	öbergabeparameter: Koordinaten des Fensterarbeits-		*/
					/*							 bereiches									*/
					/* RÅckgabe: FALSE, wenn der Dialog mittels do_form()		*/
					/*				 		  abgearbeitet wird							*/
					/*				 TRUE, falls eigene Event-Routinen benutzt	*/
					/*						 werden sollen.								*/

WORD cdecl main(GRECT *curr_wind)
{
	WORD		button_nr;				/* Nr. des angewÑhlten Buttons			*/
	WORD		x,y,w,h;					/* Variablen zur Koordinatenermittlung	*/
	WORD		i,u;						/* Schleifenvariable							*/
	WORD		bank,zaehl;				/* Druckini.-Variablen						*/
	WORD		msg_buff[8];			/*	Message-Buffer fÅr Infos vom CPX		*/
	WORD		button;					/* ZurÅckgelieferte Nr. des EXIT-Feldes*/
	WORD		abort_flag=FALSE;		/* Flag zum Verlassen des Moduls			*/
	WORD		slider_pos;				/* Slider-Position							*/
	char		active[MAX_ACTIVE][EINTRAG_LENGTH];
											/* Reservierte PlÑtze fÅr die aktiven	*/
											/* 	Module.									*/
	char		actbut[MAX_ACTIVE][BUTTON_LENGTH];
	WORD		increment;				/* Flag, ob inc. oder dec. wird			*/
	void		(*function)();			/* Zeiger auf eine Funktion				*/
	WORD		max;						/* Berechnung maximaler EintrÑge			*/
	WORD		new;						/* Neuzeichnen und Werte setzen			*/	

	/* aktuelle Systemparameter einlesen			*/
	/*spÑter*/
	
	haupt[ROOT].ob_x=curr_wind->g_x;		/* Koordinaten der Dialogbox		*/
	haupt[ROOT].ob_y=curr_wind->g_y;		/*		eintragen.						*/

	
	if(anzeige.gewaehlt==TRUE)
	{
													/* Anwahl des entsprechenden 		*/
													/* Buttons								*/
		haupt[ALLES].ob_state  &= ~SELECTED;
		haupt[SELECT].ob_state |=  SELECTED;
		read_select();							/* Systemparameter in Dialogbox	*/
													/*		eintragen						*/
	}else
	{
													/* Anwahl des entsprechenden 		*/
													/* Buttons								*/
		haupt[ALLES].ob_state  |=  SELECTED;
		haupt[SELECT].ob_state &= ~SELECTED;
	}
	
	memset(active,0,sizeof(active));		/* Lîschen und Initialisierung 	*/
	memset(actbut,0,sizeof(actbut));		/* Lîschen und Initialisierung 	*/

	init_anzeige(active,actbut);			/* Anzeigevariablen bestimmen:	*/
													/*		EintrÑge in active, Beginn,*/
													/*		Maximalanzahl der EintrÑge	*/
	into_resource(FALSE);					/* In das Resource alle Daten		*/
													/*		eintragen, nicht zeichnen.	*/

	init_slider(&slider_pos,FALSE);		/* Slider-Grîûe und -Position		*/
													/*		initialisieren					*/


													/* 	und Dialogbox zeichnen		*/
	objc_draw(haupt, ROOT, MAX_DEPTH, haupt[ROOT].ob_x, haupt[ROOT].ob_y,
					haupt[ROOT].ob_width, haupt[ROOT].ob_height);

													/* Dialogbox abarbeiten, bis ein	*/
													/*		Exit-Objekt angeklickt		*/
	do												/*							 wurde		*/
	{
													/* neuer form_do()-Aufruf			*/
		button=(*params->do_form)(haupt, 0, msg_buff);
		
													/* Doppelklick ausmaskieren.		*/
		if(button>=0)	button &= 0x7fff;
		
													/* Slider-Variablen vorinitia-	*/
		increment=1;							/*		liseren							*/
		function=scroll_up;

		button_nr=1;							/* Buttonummer							*/
													/* angeklicktes Object auswerten	*/
		switch(button)
		{
			case ARRDOWN:						/* Pfeil hinunter betÑtigt			*/
					increment=-1;
					function=scroll_down;
					
			case ARRUP:							/* Pfeil hoch beÑtigt				*/
													/* Bestimmung der nichtdarstell-	*/
													/*		baren Elemente					*/
					max=((max=anzeige.num-VISIBLE)<0) ? 0 : max;
													/* öbergabe an die Scrollfunkt.	*/
					(*params->inc_slider)(haupt, SLBACK, SLIDER, button, 
							increment, 0, max, &slider_pos, VERTICAL,
							 function);
					break;					

			case SLIDER:
					move_vslider(haupt, SLBACK, SLIDER, &slider_pos);
					break;

			case SLBACK:
					pos_vslider(haupt, SLBACK, SLIDER, &slider_pos);
					break;

			case CONFIG:
					new=FALSE;
					haupt[button].ob_state &= ~SELECTED;
					if((abort_flag=konfiguriere( &new ))==TRUE)
						break;
					if(new==TRUE && anzeige.gewaehlt==TRUE)
					{
						memset(active,0,sizeof(active));
						memset(actbut,0,sizeof(actbut));
													/* Lîschen und Initialisierung 	*/
					
						init_anzeige(active,actbut);
													/* Anzeigevariablen bestimmen:	*/
													/*		EintrÑge in active, Beginn,*/
													/*		Maximalanzahl der EintrÑge	*/
						into_resource(FALSE);/* In das Resource alle Daten		*/
													/*		eintragen, nicht zeichnen.	*/
					
						init_slider(&slider_pos,FALSE);
													/* Slider-Grîûe und -Position		*/
													/*		initialisieren					*/
					}
													/*	Auf jeden Fall neu zeichnen	*/
					objc_draw(haupt, ROOT, MAX_DEPTH, haupt[ROOT].ob_x,
									haupt[ROOT].ob_y,	haupt[ROOT].ob_width,
									haupt[ROOT].ob_height);
					break;

			case ALLES:
					if(anzeige.gewaehlt==FALSE)	break;
					
					anzeige.gewaehlt=FALSE;

													/* Alles selektierte anwÑhlen		*/
					for(i=0; i<MAX_ACTIVE; i++)
						conf[(belegung[i])].ob_state=SELECTED;
					
			case SELECT:
					if(anzeige.gewaehlt==TRUE)	break;
					if(button==SELECT)
					{	read_select();			/* Selektion lesen					*/		
						anzeige.gewaehlt=TRUE;
					}

					memset(active,0,sizeof(active));
					memset(actbut,0,sizeof(actbut));
													/* Lîschen und Initialisierung 	*/
				
					init_anzeige(active,actbut);
													/* Anzeigevariablen bestimmen:	*/
													/*		EintrÑge in active, Beginn,*/
													/*		Maximalanzahl der EintrÑge	*/
					into_resource(FALSE);	/* In das Resource alle Daten		*/
													/*		eintragen, nicht zeichnen.	*/
					
					init_slider(&slider_pos,FALSE);
													/* Slider-Grîûe und -Position		*/
													/*		initialisieren					*/
						
													/*	Auf jeden Fall neu zeichnen	*/
					objc_draw(haupt, ROOT, MAX_DEPTH, haupt[ROOT].ob_x,
									haupt[ROOT].ob_y,	haupt[ROOT].ob_width,
									haupt[ROOT].ob_height);
					break;

			case INFORM:
				
					wind_center(infouser,&x,&y,&w,&h);
													/* INFO-Dialogbox zeichnen			*/
					objc_draw(infouser, ROOT, MAX_DEPTH, x, y, w, h);
	
													/* neuer form_do()-Aufruf			*/
					button=(*params->do_form)(infouser, 0, msg_buff);
					switch(button)
					{
						case MESSAGE:
							switch(msg_buff[0])
							{
								case WM_REDRAW:
										break; 	/* Nicht notwendig					*/
								case WM_CLOSED:
													/* Speichern der Werte				*/
													/* fÅr "resident notwen.			*/
										/* get_id(&work);
											status=work;	*/
								case AC_CLOSE:
										abort_flag=TRUE;
										break;
							}
							break;

						default:
							infouser[button].ob_state &= ~SELECTED;
							break;
					}
					button=INFORM;
					if(abort_flag)	break;
													/* Haupt-Dialogbox zeichnen		*/
					objc_draw(haupt, ROOT, MAX_DEPTH, haupt[ROOT].ob_x,
												 haupt[ROOT].ob_y, haupt[ROOT].ob_width,
								 				 haupt[ROOT].ob_height);

					break;

			case BUTTON4:
					button_nr++;
			case BUTTON3:
					button_nr++;
			case BUTTON2:
					button_nr++;
			case BUTTON1:
					pulldown(button_nr+anzeige.begin, button, actbut);
					break;

			case ZEILE4:
					button_nr++;
			case ZEILE3:
					button_nr++;
			case ZEILE2:
					button_nr++;
			case ZEILE1:
					buttonclick(button_nr+anzeige.begin, 
													active_button[button_nr-1], actbut);
					break;

			case DRUCKE:
					haupt[button].ob_state &= ~SELECTED;
					i=form_alert(1,"[2][ |     Drucker mit diesen|"
										"Einstellungen intialisieren?| ]"
										"[Drucken|RESET|ABBRUCH]");
					if(i<3)
					{
						if(ONLINE)						/* Drucker an?					*/
						{
							fputs(START,NEC);			/* Starsequenz schicken.	*/
							if(i==2)						/* Falls nur RESET, dann...*/
							{
								Cprnout(127);
								Cprnout(0);
								Cprnout(0);
								Cprnout(0);
							}
							else
							{
								bank=1;zaehl=1;		/*	Bank, zaehl initialisi.	*/ 

								for(i=0; i<MAX_ACTIVE; i++)
								{							/* 27 EintrÑge durchgehen	*/
									switch(i)
									{						/* Neue Banken evtl. eintr.*/
										case 8:	bank=2; zaehl=1; break;
										case 19: bank=3; zaehl=1; break;
										case 25:	bank=4; zaehl=1; break;
									};
									
									
									Cprnout(bank);		/* Banknr. angeben!			*/
									Cprnout(zaehl);	/* Referenznummer angeben!	*/
									for(u=0; u<nec_max[i]; u++)
										if(BTESTE(anzeige.nec_flags[i],u)==TRUE)
										{
											Cprnout(u+1);/* Gesetzes Bit senden		*/
											break;
										};
										
									zaehl++;
								}
														/*	Fertig! Drucker mitteilen	*/
								Cprnout(0);
							}					
						}else
							form_alert(1,"[ | Drucker nicht online! ][ABBRUCH]");
					}
					redraw_object(haupt,ROOT,TRUE);
					break;										


			case SICHERN:
					haupt[button].ob_state &= ~SELECTED;
					if((*params->alert)(0))
					if(! ( (*params->write_config)(&anzeige,sizeof(anzeige)) ) )
					{
						(*params->alert)(2);
					};
					redraw_object(haupt,ROOT,FALSE);
					break;										

			case ABBRUCH:
					haupt[button].ob_state &= ~SELECTED;
					abort_flag=TRUE;
					break;
			
			case OK:
					haupt[OK].ob_state &= ~SELECTED;
					abort_flag=TRUE;
					break;	

			case MESSAGE:
					switch(msg_buff[0])
					{
						case WM_REDRAW:
									break; 		/* Nicht notwendig					*/
						case WM_CLOSED:
													/* Speichern der Werte				*/
													/* fÅr "resident" notwen.			*/
									/* get_id(&work);
										status=work;	*/
						case AC_CLOSE:
									abort_flag=TRUE;
									break;
					}
					break;
		}
	}while(!abort_flag);
	haupt[button].ob_state &= ~SELECTED;
	return(FALSE);
}









/************************************************************************/
/* Liefert Adresse einer Dialogbox (neue rsrc_gaddr()-Routine)	--------	*/
/*		öbergabeparameter: Baum-Index													*/
/*		RÅckgabeparameter: Zeiger auf die Dialogbox								*/		

OBJECT *get_traddr(WORD tree_index)
{
	WORD i,j;
	
	for(i=0,j=0; i<=tree_index; i++)
		while(rs_object[j++].ob_next!=-1);
	
	return(&rs_object[--j]);
}
	
	








/************************************************************************/
/* Neuzeichnen eines Objekts ------------------------------------------	*/
/*		mit Hilfe der vom Kontrollfeld gelieferten Rechteck-Liste			*/
/*		öbergabeparemeter: Zeiger auf Objektbaum, Objekt-index,				*/
/*								 Flag, ob alles gezeichnet werden soll				*/
/*		RÅckgabeparameter: Keine														*/

void redraw_object(OBJECT *tree, WORD object, WORD unbedingt)
{
	GRECT *clip_ptr, clip, xywh;
	
	/* absolute Objekt-Koordinaten berechnen		*/
	objc_offset(tree, object, &xywh.g_x, &xywh.g_y);
	xywh.g_w=tree[object].ob_width;
	xywh.g_h=tree[object].ob_height;

	if(unbedingt)
	{
		/* Objekt neu zeichnen							*/	
		objc_draw(tree, object, MAX_DEPTH, xywh.g_x, xywh.g_y,
							xywh.g_w, xywh.g_h);
		

	}else
	{
		/* erstes Rechteck holen							*/
		clip_ptr=(*params->rci_first)(&xywh);
		
		/* solange noch Rechtecke da sind				*/
		while(clip_ptr)
		{
			/* clip_ptr: Zeiger auf lokale Variable!!	*/
			clip=*clip_ptr;		/* deshalb kopieren	*/
			
			/* Objekt neu zeichnen							*/	
			objc_draw(tree, object, MAX_DEPTH, clip.g_x, clip.g_y,
							clip.g_w, clip.g_h);
			
			/* nÑchstes Rechteck holen						*/
			clip_ptr=(*params->rci_next)();
		}

	}	
}









/************************************************************************/
/* Slider-Position und -Grîûe initialisieren --------------------------	*/
/*		öbergabeparameter: Zeiger auf die beiden Sliderpositionen			*/
/*								 Zeichnenflag												*/
/*		RÅckgabeparameter: keine														*/

void init_slider(WORD *slider_pos, WORD draw)
{
	WORD	max;
	
	/* Slider-Grîûe einstellen							*/
	(*params->size_slider)(haupt, SLBACK, SLIDER, anzeige.num, VISIBLE,
									 VERTICAL, SLIDER_MINSIZE);
	
	/* Slider-Position einstellen						*/
	*slider_pos=((max=anzeige.num-VISIBLE)<0) ? 0 : max;
	
	(*params->pos_vslider)(haupt, SLBACK, SLIDER, *slider_pos, 0, max, NIL);
	
	if(draw)
		redraw_object(haupt, SLBACK, FALSE);
}









/************************************************************************/
/* Dialogbox im Fenster zentrieren ------------------------------------	*/
/*		öbergabeparameter: Zeiger auf Dialogbox, Koordinaten					*/
/*		RÅckgabeparameter: indirekt Åber Koordinaten								*/

void wind_center(OBJECT *tree, WORD *x, WORD *y, WORD *w, WORD *h)
{
	tree[ROOT].ob_x=haupt[ROOT].ob_x+
							(haupt[ROOT].ob_width-tree[ROOT].ob_width)/2;
	tree[ROOT].ob_y=haupt[ROOT].ob_y+
							(haupt[ROOT].ob_height-tree[ROOT].ob_height)/2;

	*x=tree[ROOT].ob_x;
	*y=tree[ROOT].ob_y;
	*w=tree[ROOT].ob_width;
	*h=tree[ROOT].ob_height;
}









/************************************************************************/
/* Anzeige der Inhalte im Scrolling-Dialog eintragen ------------------	*/
/*		öbergabeparameter: Zeiger auf die Namen des Dialoges					*/
/*		RÅckgabeparameter: Anzahl der aktivierten EintrÑge indirekt Åber	*/
/*								 anzeige.max_num											*/

void init_anzeige(char (*active)[EINTRAG_LENGTH],char (*actbut)[BUTTON_LENGTH])
{
	WORD	i, k, u, nr_abs;
	
	anzeige.num=0;
	for(i=0; i<MAX_ACTIVE; i++)	/* Welche EintrÑge sind selektiert?		*/
	{										/* MAX_ACTIVE die maximale Anzahl der	*/
											/* 	EintrÑge an, die selektiet			*/
											/* 	werden kînnen.							*/
		k=conf[(belegung[i])].ob_state;
											/* Der Status der EintrÑge wird abge-	*/
											/* 	fragt. 									*/
		k &= SELECTED;					/* Mit SELECTED binÑr ge-und-et			*/
		if(k)								/* Bleibt das Bit SELECTED stehen, so	*/
		{
			aktiv_nr[anzeige.num]=i;/* 	wird die Nummer in eine Liste		*/
											/* 	eingetragen								*/
			strcpy(active[anzeige.num],
									conf[(belegung[i])].ob_spec.tedinfo->te_ptext);
											/*	In die Anzeige-Bank wird der 		 	*/
											/*		Eintrag kopiert.						*/

			nr_abs=aktiv_nr[anzeige.num];
			for(u=0; u<nec_max[nr_abs]; u++)
			{
											/*	Sehe nach, ob das Flag gesetzt ist.	*/
				if(BTESTE(anzeige.nec_flags[nr_abs],u)==TRUE)
				{
					
					strcpy(actbut[anzeige.num],
											 nec_config[berechne_index(nr_abs,u,1)]);
											/*	In das entsprechende Anzeigefeld,	*/
											/* 	hier vier StÅck, muû der Zeiger	*/
											/*		des entsprechenden Strings aus 	*/
											/*		der Box des RSC-Files auf den 	*/
											/*		Button im Hauptdialog gebogen 	*/
											/*		werden. Dabei ist die IDEE:		*/
			/*	Berechnung des absoluten Eintrages in einer Tabelle. Aus 	*/
			/*		maximal aktiven EintrÑgen, hier MAX_ACTIVE=27, wird der	*/
			/*		Eintrag anhand der Tabelle gefunden. Die nec_flags geben	*/
			/*		Aufschluû darÅber, ob dieses aktiviert ist. Falls ge-		*/
			/*		funden, dann Zeiger umpointen. Pro Bit ist ein Eintrag	*/
			/*		in nec_config resviert. Pro Eintrag existieren 2 Zahlen	*/
			/*		1. Zahl: Popupstrings, 2. Zahl: Buttonstring					*/
				}
	
			}

			anzeige.num++;				/* ZÑhler fÅr Anzahl der EintrÑge		*/			
			
		};
	}

	anzeige.max_num=anzeige.num;	/* Maximal-Anzahl ist gleich der Anzahl*/
											/*		der EintrÑge.							*/
	anzeige.buffer=active;			/* Der Zeiger auf die Anzeige-Bank 		*/
											/*		wird kopiert.							*/
	anzeige.button=actbut;			/* Der Zeiger auf die Anzeige-Bank 		*/
											/*		wird kopiert.							*/
	anzeige.begin=0;					/*	Der erste Eintrag ist beim Start an	*/
											/*		der Stelle 0 zu finden.				*/
}










/************************************************************************/
/* Namensliste in die Dialogbox eintragen -----------------------------	*/
/*		öbergabeparameter: Zeichen-Flag												*/
/*		RÅckgabeparameter: KEINE														*/

void into_resource(WORD draw)
{
	WORD 	i;

	for(i=0; i<VISIBLE; i++)			/* Alle mîglichen Anzeigen eintragen*/
	{
		if( anzeige.begin + i < anzeige.num)	
		{										/* Anzeigedaten im Bereich des Dar-	*/
												/*		stellbaren.							*/

			haupt[active_zeilen[i]].ob_spec.tedinfo->te_ptext=
											anzeige.buffer[anzeige.begin+i];

			haupt[active_button[i]].ob_spec.tedinfo->te_ptext=
											anzeige.button[anzeige.begin+i];
												/* Zeiger auf die Buffer-Rolle		*/
												/*		und die richtige Nr. auswÑhlen*/

												/*	Als TOUCHEXIT markieren.			*/
			haupt[active_zeilen[i]].ob_flags=TOUCHEXIT;

		}
		else
		{
												/* Der Rest wird nicht dargestellt	*/
												/*	Er wird versteckt und nicht an-	*/
												/*		wÑhlbar.								*/		
			haupt[active_zeilen[i]].ob_flags=HIDETREE;
		}
	}
	
	if(draw)	redraw_object(haupt, HAUPTWIN, TRUE);
}










/************************************************************************/
/* Vertikalen Slider verschieben --------------------------------------	*/
/*		öbergabeparameter: Zeiger auf Dialogbox, Index-Slider-Hintergrund	*/
/*								 Index Slider, Zeiger auf Slider-Position			*/
/*		RÅckgabeparameter: Keine														*/

void move_vslider(OBJECT *tree, WORD parent, WORD slider, WORD *slider_pos)
{
	WORD max;
	
	max=((max=anzeige.num-VISIBLE)<0) ? 0 : max;
	(*params->move_vslider)(tree, parent, slider, 0, max, slider_pos, NIL);
	
	/* je nach Slider-Position die Namensliste neu ausgeben	*/
	anzeige.begin=((max=anzeige.num-VISIBLE-*slider_pos)<0) ? 0 : max;
	
	into_resource(TRUE);
}	










/************************************************************************/
/* Vertikalen Slider positionieren ------------------------------------	*/
/*		öbergabeparameter: Zeiger auf Dialogbox, Index-Slider-Hintergrund	*/
/*								 Index Slider, Zeiger auf Slider-Position			*/
/*		RÅckgabeparameter: Keine														*/

void pos_vslider(OBJECT *tree, WORD parent, WORD slider, WORD *slider_pos)
{

	WORD 	my,y;
	WORD	dummy;
	WORD	max, temp;
	
	/* Koordinaten einlesen	*/
	graf_mkstate(&dummy, &my, &dummy, &dummy);
	objc_offset(tree, slider, &dummy, &y);
	
	/* je nach Mausposition entweder nach oben oder unten scrollen			*/
	if(my<y)
		*slider_pos=((max=anzeige.num-VISIBLE)<=(temp=*slider_pos+VISIBLE))
								 ? max : temp;
	else
		*slider_pos=((max=*slider_pos-VISIBLE)<0) ? 0 : max;
	
	/* Slider neu positionieren	*/
	max=((max=anzeige.num-VISIBLE)<0) ? 0 : max;

	(*params->pos_vslider)(tree,parent, slider, *slider_pos, 0, max, NIL);
	
	/* Namensliste neu ausgeben	*/
	anzeige.begin=((max=anzeige.num-VISIBLE-*slider_pos)<0) ? 0 : max;
	
	into_resource(TRUE);
	redraw_object(tree, parent, TRUE);
}








/************************************************************************/
/* Im Fenster nach oben scrollen --------------------------------------	*/
/*		öbergabeparameter: Keine														*/
/*		RÅckgabeparameter: Keine														*/

void scroll_up(void)
{
	if(anzeige.begin>0)
	{
		anzeige.begin--;
		into_resource(TRUE);
	}
}





/************************************************************************/
/* Im Fenster nach unten scrollen -------------------------------------	*/
/*		öbergabeparameter: Keine														*/
/*		RÅckgabeparameter: Keine														*/

void scroll_down(void)
{
	if(anzeige.begin+VISIBLE<anzeige.num)
	{
		anzeige.begin++;
		into_resource(TRUE);
	}
}		









/************************************************************************/
/*	Werte fÅr einwandfreien Dialog holen -------------------------------	*/
/*		öbergabeparameter: Keine														*/
/*		RÅckgabeparameter: Keine														*/
void read_select(void)
{
	WORD i;
	
	for(i=0; i<MAX_ACTIVE; i++)
	{
		if(	BTESTE(anzeige.select_flag, i) == TRUE)
			conf[(belegung[i])].ob_state=SELECTED;
		else
			conf[(belegung[i])].ob_state=NORMAL;
	}		
}









/************************************************************************/
/*	Werte fÅr einwandfreien Dialog setzen ------------------------------	*/
/*		öbergabeparameter: Keine														*/
/*		RÅckgabeparameter: Keine														*/
void set_select(void)
{

	WORD i;
	
	for(i=0; i<MAX_ACTIVE; i++)
	{
		if(conf[(belegung[i])].ob_state == SELECTED)
			BSETZE(anzeige.select_flag, i);
		else
			BCLEAR(anzeige.select_flag, i);
	}		
}






/************************************************************************/
/*	Verwaltet den Zusatzdialog	-----------------------------------------	*/
/*		öbergabeparameter: Keine														*/
/*		RÅckgabeparameter: Keine														*/

WORD konfiguriere( WORD *new)
{
	WORD msg_buff[8];			/*	Message-Buffer fÅr Infos vom CPX		*/
	WORD x,y,w,h;
	WORD button;
	WORD abort_flag=FALSE;
		
	read_select();

	wind_center(conf,&x,&y,&w,&h);
	
	objc_draw(conf, ROOT, MAX_DEPTH, conf[ROOT].ob_x, conf[ROOT].ob_y, w, h);


	button=(*params->do_form)(conf, 0, msg_buff);
		
													/* Doppelklick ausmaskieren.		*/
	if(button>=0)	button &= 0x7fff;


	switch(button)
	{
		case CONFOK:
				set_select();
				*new=TRUE;

		case CONFABBR:
				conf[button].ob_state &= ~SELECTED;
				break;

		case MESSAGE:
				switch(msg_buff[0])
				{
					case WM_REDRAW:
								break;
					case WM_CLOSED:
					case AC_CLOSE:
								abort_flag=TRUE;
								break;
				}
				break;
	}

	return(abort_flag);
}









/************************************************************************/
/*	Pulldown-MenÅ generieren, darstellen und auswerten -----------------	*/
/*		öbergabeparameter: angklickter Button, aus dem das MenÅ "heraus-	*/
/*								 	klappen" soll											*/
/*								 Objectnummer, da Pull-Down dort erscheint		*/
/*								 Adresse des Button-Arrays, da neuer Eintrag		*/
/*									dort eingetragen werden muû (REDRAW)			*/
/*		RÅckgabeparameter: Keine														*/

void pulldown( WORD button, WORD objc_button, char (*actbut)[BUTTON_LENGTH])
{
	WORD	i;
	WORD	nr_abs,num_items;
	WORD	index, checked;
	char	*pull_adr[MAX_ACTLEN];
	char	pull_buff[MAX_ACTLEN][17];
	GRECT	button_xywh,window_xywh;
	
												/* Lîschen des Anzeigebuffers			*/
	memset(pull_buff,0,sizeof(pull_buff));
	button--;
												/*	Berechnung des gerade in der An-	*/
	nr_abs=aktiv_nr[button];			/* 	zeige befindlichen Feldes.		*/
	num_items=nec_max[nr_abs];
	for(i=0; i<num_items; i++)
	{
		strcpy(pull_buff[i],"  ");		/* LeereintrÑge fÅr Haken				*/
												/*	Pulldownbuffer mit den EintrÑgen	*/
		strcat(pull_buff[i],				/*		vollschreiben.						*/
					nec_config[berechne_index(nr_abs,i,0)]);

		strcat(pull_buff[i]," ");		/* Leereintrag, SCHôôôN!				*/
		if(BTESTE(anzeige.nec_flags[nr_abs],i)==TRUE)
				index=i;						/*	Index abgehakter Eintrag			*/
	}
	
												/* absolute Button-Koordinaten be-	*/
												/*		rechnen								*/
	objc_offset(haupt,objc_button,&button_xywh.g_x, &button_xywh.g_y);
	button_xywh.g_w=haupt[objc_button].ob_width;
	button_xywh.g_h=haupt[objc_button].ob_height;
	
												/* absolute Koordinaten der Dialog-	*/
												/*		box ermitteln						*/
	objc_offset(haupt,ROOT,	&window_xywh.g_x, &window_xywh.g_y);
	window_xywh.g_w=haupt[ROOT].ob_width;
	window_xywh.g_h=haupt[ROOT].ob_height;

												/* Adressen der einzelnen EintrÑge	*/
												/*		in das öbergabe-Array eintrag.*/
	for(i=0; i<num_items; i++)
		pull_adr[i]=pull_buff[i];
		
												/* Pull-Down-MenÅ zeichnen lassen 	*/
												/*		und Index des angeklickten 	*/
												/*		Eintrags zurÅckliefern	lassen*/
	checked=(*params->do_pulldown)(pull_adr, num_items, index, IBM, 
					&button_xywh, &window_xywh);
	
	if(checked>=0)
	{
		anzeige.nec_flags[nr_abs]=0L;	/* Eintrag auf Null setzen				*/
												/* Entsprechendes Bit setzen			*/
		BSETZE(anzeige.nec_flags[nr_abs],checked);
	
		strcpy(actbut[button],nec_config[berechne_index(nr_abs,checked,1)]);
						
		into_resource(FALSE);
		redraw_object(haupt, objc_button, TRUE);
	}
			

}








/************************************************************************/
/*	Pulldown-MenÅ generieren, darstellen und auswerten -----------------	*/
/*		öbergabeparameter: angklickter Button, aus dem das MenÅ "heraus-	*/
/*								 	klappen" soll											*/
/*								 Objectnummer, da Pull-Down dort erscheint		*/
/*								 Adresse des Button-Arrays, da neuer Eintrag		*/
/*									dort eingetragen werden muû (REDRAW)			*/
/*		RÅckgabeparameter: Keine														*/

void buttonclick( WORD button, WORD objc_button,
														 char (*actbut)[BUTTON_LENGTH])
{
	WORD	i;
	WORD	nr_abs,num_items;
	WORD	checked;
	
	button--;
												/*	Berechnung des gerade in der An-	*/
	nr_abs=aktiv_nr[button];			/* 	zeige befindlichen Feldes.		*/
	num_items=nec_max[nr_abs];
	for(i=0; i<num_items; i++)
		if(BTESTE(anzeige.nec_flags[nr_abs],i)==TRUE)
				checked=((i+1)==num_items) ? 0 : (i+1);

	anzeige.nec_flags[nr_abs]=0L;	/* Eintrag auf Null setzen				*/
											/* Entsprechendes Bit setzen			*/
	BSETZE(anzeige.nec_flags[nr_abs],checked);

	strcpy(actbut[button],nec_config[berechne_index(nr_abs,checked,1)]);
					
	into_resource(FALSE);
	redraw_object(haupt, objc_button, TRUE);
	
}

WORD berechne_index(WORD bank, WORD nr, WORD zeige)
{
	WORD i,anzahl=0;
	
	for(i=0; i<bank; i++)
		anzahl+=(nec_max[i]*2);

	anzahl+=(nr*2);
	anzahl+=zeige;		

	return(anzahl);
}