/**********************************************/
/* BEISPIEL fÅr universielles CPX-Modul				*/
/**********************************************/
/* CPX-Modul:		NEC-POWER											*/
/* ------------------------------------------	*/
/* Funktionen:																*/
/*		DIP-Schalterkonfiguration fÅr NEC P20/30*/
/* Ersteller:																	*/
/*		Hartmut Klindtworth, 11.04.1993					*/
/* Copyright 1993 by MAXON-Verlag, Eschborn		*/
/**********************************************/

/* ACHTUNG: alle mit (!) gekennzeichnete Ein-	*/
/*					trÑge mÅssen bei Benutzung einer	*/
/*					anderen RSC-Datei und anderer Auf-*/
/*					gabe des Programmes geÑndert wer-	*/
/*					den.															*/

/* Die normalen, Åblichen Header-Dateien ----	*/
#include <portab.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <stddef.h>
#include <stdio.h>

/* DEFINES ----------------------------------	*/
#define	TRUE		1
#define	FALSE		0
#define	NIL			0L
#define BSETZE(X,Y) (X=(X |  ((1L)<<Y)))
#define BCLEAR(X,Y)	(X=(X & ~((1L)<<Y)))
#define BTESTE(X,Y)	((X & ((1L)<<Y)) ? 1 : 0)

#define	MESSAGE	-1				/* Messager-Event		*/
#define	SLIDER_MINSIZE	6	/* Slidermindestgr.	*/
#define	VISIBLE					4	/* Anzahl der sicht-*/
													/*		baren EintrÑge*/
#define	HORIZONTAL			1	/* Art des Sliders	*/
#define	VERTICAL				0	/* Art des Sliders	*/
						/* Anzahl der gesamten Strings (!)*/
#define	MAX_STRINGS	 114	
					/* Anzahl der maximalen EintrÑge (!)*/
#define	MAX_ACTIVE	  27
					/* Maximale LÑnge eines Eintrags (!)*/
#define MAX_ACTLEN	  19

		/*	Spezielle Defines fÅr die Ausgabe (!)	*/
#define NEC				stdprn	/* Standardausgabe	*/
#define ONLINE		Bcostat(0)==-1
									/* Leitet Befehlsfolge ein!	*/
#define START			"\x1c\x6D\x02"
			/* Reset im Druckerkonfig, damit 	wird	*/
			/*		der Drucker wieder in die Konfi-	*/
			/*		guration zurÅckgesetzt, in der er	*/
			/*		ab Werk geliefert wird.						*/
#define RESET			"\x1c\x6D\x02\x7f\x00\x00\x00"

/* GLOBALE VARIABLEN	-----------------------	*/

/* Deklaration der zu sichernden Variablen .. */
typedef struct	
{
	LONG	nec_flags[MAX_ACTIVE];				/* (!)	*/
	WORD	num;			/* Anzahl aktiver EintrÑge	*/							
	WORD	begin;		/* Erster sichtbare Eintrag	*/
} ANZEIGE;
/*	ACHTUNG! Dies steht am Anfang des Daten-	*/
/*			segmentes. Alles vorher ist nur zur		*/
/*			Deklaration gedacht.									*/
ANZEIGE anzeige=	/* Standardkonfiguration, 	*/
{ 								/* Ñndert sich natÅrlich (!)*/
{									/* Anzahl von MAX_ACTIVE (!)*/
	 1L, 128L, 1L, 1L, 2L, 1L, 1L, 2L,
1024L,   1L, 1L, 2L, 2L, 1L, 4L, 1L, 1L, 2L, 1L,
	 2L,  64L, 1L, 1L, 1L, 2L,
	16L,  16L
}, 0,0};


/* Resource-Datei deshalb erst hier einladen 	*/
#include "NEC_RSCM.C"	/* Evtl. andere Name (!)*/
#include "NEC_RSCM.H"	/* Evtl. andere Name (!)*/
#include <xcontrol.h>	/* Standard-Headerfile	*/

/* sonstige globale Variablen ---------------	*/
WORD 	errno;		/* Damit der Linker Ruhe gibt!*/
WORD	_FilSysV;	/*				"							"			*/
CPX_PARAMS *params;	
								/* vom Kontrollfeld Åbergebe-	*/
								/*		ner Zeiger auf die Kon-	*/
								/*		trollfeld-Funktionen		*/
OBJECT *haupt;	/* Zeiger auf Dialogbox				*/
WORD	actlines[VISIBLE]=
						 { ZEILE1, ZEILE2, ZEILE3, ZEILE4 };
WORD	actbut[VISIBLE]=
				 { BUTTON1, BUTTON2, BUTTON3, BUTTON4 };
WORD	nec_max[MAX_ACTIVE]=
{		/* éndert sich natÅrlich, da es angibt 		*/
		/*		wieviele maximale EintrÑge fÅr das 	*/
		/*		Popup zu erwarten sind! (!)					*/
	 2,11, 2,19, 2, 2, 2, 2,
	12, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2,
	 3, 8, 2, 3, 2, 3,
	 9, 9
};									 /* insg.: 114 Strings		*/

/* Ab hier beginnt die Eingabe der Strings fÅr*/
/*		die Anzeige im Pop-Up. Sie mÅssen natÅr-*/
/*		geÑndert werden, wenn andere Einstellun-*/
/*		gen vorgenommen werden sollen.			(!)	*/
/*	Alle Anzeigestrings: 1. Pop-Up, 2. Button	*/
char	*nec_config[MAX_STRINGS*2]=
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
	"TIMES PS  ",	"TIMES",	"BOLD PS   ",	"BOLD",
	"HIGH SPEED",	"SPEEDY",	"NORMAL",		"NORMAL",				
	"USA    ",		"USA",	"FRANCE ",		"FRA",
	"GERMANY",		"GER",	"ENGLAND",		"ENG",
	"DANEMA1",		"DM1",	"SWEDEN ",		"SWD",
	"ITALIEN",		"ITL",	"SPAIN 2",		"SPA",
	"JAPAN  ",		"JPN",	"NORWEGE",		"NOR",
	"DANEMA2",		"DM2",	"HOLLAND",		"NET",
	"TöRKEI ",		"TUK",	"SPAIN 2",		"SP2",
	"LATEINA",		"LA",		"MULTILI",		"MUL",
	"PORTUGA",		"POR",	"CAN-FRE",		"CFR",
	"NORWEG2",		"NR2",	"ITALIC",		"ITALIC",
	"IBM   ",		"IBM",		"OFF",			"OFF",
	"ON ",			"ON",			"UNIDIREC",		"UNI",
	"BIDIREC ",		"BI",		"QUIET",			"ON",
	"LOUD ",			"OFF",
	"   3 ZOLL",			"3 ZOLL",
	"  3\xab" " ZOLL",	"3\xab" " ZOLL",
	"   4 ZOLL",			"4 ZOLL",
	"  5\xab" " ZOLL",	"5\xab" " ZOLL",
	"   6 ZOLL",	"6 ZOLL",	
	"   7 ZOLL",	"7 ZOLL",
	"   8 ZOLL",	"8 ZOLL",
	"  8\xab" " ZOLL",	"8\xab" " ZOLL",
	"  11 ZOLL",	"11 ZOLL",
	"11.6 ZOLL",	"11.6 \"",
	"  12 ZOLL",	"12 ZOLL",
	"  14 ZOLL",	"14 ZOLL",
	"ON ",			"ON",	"OFF",			"OFF",
	"6",				"8",	"6",				"8",	
	"DISABLE",		"OFF",	"ENABLE ",		"ON",
	"DISABLE",		"OFF",	"ENABLE ",		"ON",
	"ACRYLIC","ACRYLIC",	"ROLLER ",		"ROLLER",
	"CR ONLY  ",	"CR ONLY",
	"CR & LF  ",	"CR & LF",
	"CR W/O PO",	"CR W/O",
	"LF & CR",		"LF & CR",
	"LF ONLY",		"LF ONLY",
	"ON ",			"ON",		"OFF",			"OFF",
	"ON ",			"ON",		"OFF",			"OFF",
	"COLUMN 1 ","COL 1","COLUMN 35",	"COL 35",
	"8 KB Buffer  ",	"8 KB B.",
	"4 KB/ 96 Char",	"4 KB/96",
	"\xab" " KB/128 Char",	"\xab" " K/128",
	"  150 Baud",	"150",	"  300 Baud",		"300",
	"  600 Baud",	"600",	" 1200 Baud",		"1200",
	" 2400 Baud",	"2400",	" 4800 Baud",	"4800",
	" 9600 Baud",	"9600",	"19200 Baud",	"19200",
	"8 BITS",			"8 BITS", "7 BITS",		"7 BITS",
	"NONE",				"NONE",		"ODD ",				"ODD",
	"EVEN",				"EVEN",		"DISABLE",		"OFF",
	"ENABLE ",		"ON",	"ETX/ACK   ",	"ETX/ACK",
	"X-ON/X-OFF",	"X-ON",	"REPETITION",	"REPETI.",	
	"-4",	"-4",	"-3",	"-3",	"-2",	"-2",
	"-1",	"-1",	" 0",	"0",	" 1",	"1",
	" 2",	"2",	" 3",	"3",	" 4",	"4",
	"-4",	"-4",	"-3",	"-3",	"-2",	"-2",
	"-1",	"-1",	" 0",	"0",	" 1",	"1",
	" 2",	"2",	" 3",	"3",	" 4",	"4"	
};	
				
/*	Alle Namen der Konfigurationsparameter:		*/
char *nec_names[MAX_ACTIVE]=
{
	"TYPEST.+PITCH SEL.",	"PRINT STYLE",
	"12 CPI DRAFT SPEED",	"LANGUAGE CHAR SET",
	"DEFAULT CHAR SET",		"SHAPE OF ZERO",
	"GRAPHIS PRINT DIR.",	"QUIET MODE",
	"FF LENGTH",					"SKIP OVER EMU.",
	"LINES PER INCH",			"0 MARGIN EMU.",
	"AUTO TEAR OFF",			"CUTTER POSITION",
	"CR FUNCTION",				"LF FUNCTION",
	"BUFFER FULL LF",			"PULL TRACTOR",
	"SHEET FEEDER LM",		"DOWNLOAD CAPACITY",
	"BAUD RATE",					"WORD LENGTH",
	"PARITY CHECK",				"DCD SIGNALS",
	"COMMUNIC. PROT.",		"DRAFT HORIZ. ALL.",
	"LQ HORIZ. ALIGNEMT"
};

/* Prototypen fÅr PURE C --------------------	*/
CPX_INFO * cdecl init(CPX_PARAMS *par);
WORD cdecl main(GRECT *curr_wind);
OBJECT *get_traddr(WORD tree_index);
void redraw_object(OBJECT *tree, WORD object,
															 WORD unbedingt);
void init_slider(WORD *slider_pos, WORD draw);
void wind_center(OBJECT *tree, WORD *x, WORD *y,
														 WORD *w, WORD *h);
void into_resource(WORD draw);
void move_vslider(OBJECT *tree, WORD parent,
								WORD slider, WORD *slider_pos);
void pos_vslider(OBJECT *tree, WORD parent, 
								WORD slider, WORD *slider_pos);
void scroll_up(void);
void scroll_down(void);
void pulldown( WORD button, WORD objc_button);
void buttonclick(WORD button,WORD objc_button);
WORD berechne_index(WORD bank, WORD nr,
																	 WORD zeige);


/* Funktionen ------------------------------- */

/* Initialisierung des Moduls:								*/
/*	öbergabeparameter: 												*/
/*	-	Zeiger auf die zur VerfÅgung stehenden	*/
/*		Funktionen															*/
/*	1. Aufruf bei Laden des Headers						*/
/*		 (par->booting==TRUE)										*/
/*		 RÅckgabe: 0 bei Set-Only, 1 sonst			*/
/*	2. Aufruf bei Laden des eigentlichen			*/
/*		 Programms (par->booting==FALSE)				*/
/*		 RÅckgabe: Adresse CPX_INFO-Strukturen	*/

CPX_INFO * cdecl init(CPX_PARAMS *par)
{
	static 	CPX_INFO info={ main, 0L, 0L, 0L, 0L,
													 0L, 0L, 0L, 0L, 0L };
	
	/* Laden des Headers=>alle Parameter setzen */
	if(par->booting) 	
	{	/* Wert !=0 => Arbeit weitergefÅhrt wird	*/
		return((CPX_INFO *)1L);	
	}
	else
	{	params=par;
		if(!params->rsc_init)
		{	(*(params->do_resource))(NUM_OBS, 
					NUM_FRSTR, NUM_FRIMG, NUM_TREE,
					rs_object, rs_tedinfo, rs_strings,
					rs_iconblk, rs_bitblk, rs_frstr,
					rs_frimg, rs_trindex, rs_imdope);

			/* globale Variablen initialiseren	*/
			haupt=get_traddr(HAUPT);
		}
		return(&info);
	}
}
/* Funktionen ------------------------------- */
/* Aufruf nach einem Doppelklick auf das Icon	*/
/*	 	im Auswahlfenster:											*/
/*	 	Zeichnen der Dialogbox, Behandlung der	*/
/*	 	Buttons																	*/
/* öbergabeparameter: Koordinaten des Fen-		*/
/*		sterarbeitsbereiches										*/
/* RÅckgabe:																	*/
/*		FALSE, wenn der Dialog mittels do_form()*/
/*					 abgearbeitet wird								*/
/*		TRUE, falls eigene Event-Routinen				*/
/*					 benutzt werden sollen.						*/
WORD cdecl main(GRECT *curr_wind)
{
	WORD	button_nr;	/* Nr. angewÑhlter Button	*/
	WORD	i,u;				/* Schleifenvariable			*/
	WORD	bank,zaehl;	/* Druckini.-Variablen		*/
			/* Message-Buffer fÅr Infos vom CPX			*/
	WORD	msg_buff[8];
			/* ZurÅckgelieferte Nr. des EXIT-Feldes	*/
	WORD	button;
			/* Flag zum Verlassen des Moduls				*/
	WORD	abort_flag=FALSE;
	WORD	slider_pos;	/* Slider-Position				*/
	WORD	increment;	/* Flag: inc. oder dec.		*/
	void	(*function)();/* Zeiger auf Funktion	*/
	WORD	max;				/* Berechn. maxi. EintrÑge*/

		/* Koordinaten der Dialogbox eintragen.		*/
	haupt[ROOT].ob_x=curr_wind->g_x;
	haupt[ROOT].ob_y=curr_wind->g_y;

	anzeige.num=MAX_ACTIVE;		/* Maximal-Anzahl	*/
		/*	Der 1. Eintrag ist	beim Start an	der */
	anzeige.begin=0;	/*		Stelle 0 zu finden.	*/
							/* In das Resource alle Daten		*/
							/*		eintragen, nicht zeichnen.*/
	into_resource(FALSE);	

		/* Slider-Grîûe und -Position	initialis.	*/
	init_slider(&slider_pos,FALSE);

							/* 		und Dialogbox zeichnen		*/
	objc_draw(haupt, ROOT, MAX_DEPTH, 
						haupt[ROOT].ob_x, haupt[ROOT].ob_y,
						haupt[ROOT].ob_width,
						haupt[ROOT].ob_height);

	do				/* Dialogbox abarbeiten, bis ein	*/
	{					/*		Exit-Obj. angeklickt wurde	*/
						/* neuer form_do()-Aufruf					*/
		button=(*params->do_form)(haupt,0,msg_buff);
						/* Doppelklick ausmaskieren.			*/
		if(button>=0)	button &= 0x7fff;
						/* Slider-Variablen vorinitialis.	*/
		increment=1;	function=scroll_up;
		button_nr=1;	/* Buttonummer intialisieren*/
		switch(button)
		{				/* Button auswerten								*/
			case ARRDOWN:					/* Pfeil hinunter */
					increment=-1;
					function=scroll_down;
			case ARRUP:						/* Pfeil hoch 		*/
						/* Bestimmung der nichtdarstell-	*/
						/*		baren Elemente							*/
					max=((max=anzeige.num-VISIBLE)<0) ? 
																				0 : max;
						/* 	öbergabe an die Scrollfunkt.	*/
					(*params->inc_slider)(haupt, SLBACK,
						  SLIDER, button, increment, 0, max,
						  &slider_pos, VERTICAL, function);
					break;					
			case SLIDER:
					move_vslider(haupt, SLBACK, SLIDER,
																	 &slider_pos);
					break;
			case SLBACK:
					pos_vslider(haupt, SLBACK, SLIDER,
																	 &slider_pos);
					break;
			case BUTTON4:	button_nr++;
			case BUTTON3:	button_nr++;
			case BUTTON2:	button_nr++;
			case BUTTON1:
					pulldown(button_nr+anzeige.begin,
																			 button);
					break;
			case ZEILE4:	button_nr++;
			case ZEILE3:	button_nr++;
			case ZEILE2:	button_nr++;
			case ZEILE1:
					buttonclick(button_nr+anzeige.begin, 
										actbut[button_nr-1]);
					break;
			case SICHERN:
					haupt[button].ob_state &= ~SELECTED;
					/* NÑchste Zeilen bitte nur ver-		*/
					/*		wenden, falls es sinnvoll fÅr	*/
					/*		andere Programme ist.		(!)		*/
					i=form_alert(1,
							"[2][ |     Drucker mit diesen|"
							"Einstellungen intialisieren?| ]"
							"[Drucken|RESET|ABBRUCH]");
					if(i<3)
					{									/* Drucker an?		*/
						if(ONLINE)
						{				/* Starsequenz schicken.	*/
							fputs(START,NEC);
							if(i==2)	/* Falls nur RESET:		*/
							{
								Cprnout(127);	Cprnout(0);
								Cprnout(0);		Cprnout(0);
							}
							else
							{		/*	bank, zaehl initialisi.	*/ 
								bank=1;zaehl=1;
								for(i=0; i<MAX_ACTIVE; i++)
								{	/* 27 EintrÑge durchgehen		*/
									switch(i)
									{/* Neue Banken evtl. eintr.*/
										case 8:	
												 bank=2; zaehl=1; break;
										case 19:
												 bank=3; zaehl=1; break;
										case 25:
												 bank=4; zaehl=1; break;
									};
											/* Banknr. angeben!			*/
									Cprnout(bank);	
											/* Referenznr. angeben!	*/
									Cprnout(zaehl);
									for(u=0; u<nec_max[i]; u++)
				if(BTESTE(anzeige.nec_flags[i],u)==TRUE)
										{/* Gesetzes Bit senden		*/
											Cprnout(u+1);
											break;
										};
									zaehl++;
								}
								/*	Fertig! Drucker mitteilen	*/
								Cprnout(0);
							}					

							/* Dies ist wieder allgemein-		*/
							/*		gÅltig. Sollte in jedem		*/
							/*		Programm aufgefÅhrt sein.	*/

							if((*params->alert)(0))
							if(! ( (*params->write_config)
									(&anzeige,sizeof(anzeige)) ) )
							{
								(*params->alert)(2);
							};

						}else
							form_alert(1,"[ | Drucker nicht "
													"online! ][ABBRUCH]");
					}
					redraw_object(haupt,ROOT,TRUE);
					break;										
			case OK:
			case ABBRUCH:
					haupt[button].ob_state &= ~SELECTED;
					abort_flag=TRUE;	break;	
			case MESSAGE:
					switch(msg_buff[0])
					{
									/* Nicht notwendig					*/
						case WM_REDRAW:
									break; 	
						case WM_CLOSED:
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
/**********************************************/
/* Liefert Adresse einer Dialogbox					 	*/
/*			(neue rsrc_gaddr()-Routine)	--------	*/
/*	öbergabeparameter: Baum-Index							*/
/*	RÅckgabeparameter: Zeiger auf Dialogbox		*/		
OBJECT *get_traddr(WORD tree_index)
{
	WORD i,j;
	for(i=0,j=0; i<=tree_index; i++)
				while(rs_object[j++].ob_next!=-1);
	return(&rs_object[--j]);
}
/**********************************************/
/* Neuzeichnen eines Objekts ----------------	*/
/* mit Hilfe der vom Kontrollfeld gelieferten */
/*												 		 Rechteck-Liste */
/*	öbergabeparemeter: Zeiger auf Objektbaum,	*/ 
/*										 Objekt-index,					*/
/*										 Flag: Alles zeichnen?	*/
/*	RÅckgabeparameter: Keine									*/
void redraw_object(OBJECT *tree, WORD object,
																 WORD unbedingt)
{
	GRECT *clip_ptr, clip, xywh;
	/* absolute Objekt-Koordinaten berechnen		*/
	objc_offset(tree, object,&xywh.g_x,&xywh.g_y);
	xywh.g_w=tree[object].ob_width;
	xywh.g_h=tree[object].ob_height;

	if(unbedingt)
	{		/* Objekt neu zeichnen									*/	
		objc_draw(tree, object, MAX_DEPTH, xywh.g_x,
									 xywh.g_y,xywh.g_w, xywh.g_h);
	}else
	{
			/* erstes Rechteck holen								*/
		clip_ptr=(*params->rci_first)(&xywh);
		
			/* solange noch Rechtecke da sind				*/
		while(clip_ptr)
		{
			/* clip_ptr:Zeiger auf lokale Variable!	*/
			clip=*clip_ptr;			/* deshalb kopieren	*/
			
			/* Objekt neu zeichnen									*/	
			objc_draw(tree,object,MAX_DEPTH,clip.g_x,
									 clip.g_y,clip.g_w,clip.g_h);
			/* nÑchstes Rechteck holen							*/
			clip_ptr=(*params->rci_next)();
		}
	}	
}
/**********************************************/
/* Slider-Position und -Grîûe initialisieren	*/
/*	öbergabeparameter: Zeiger auf die beiden	*/
/*										 Sliderpositionen				*/
/*										 Zeichnenflag						*/
/*		RÅckgabeparameter: keine								*/
void init_slider(WORD *slider_pos, WORD draw)
{
	WORD	max;
	
			/* Slider-Grîûe einstellen							*/
	(*params->size_slider)(haupt, SLBACK, SLIDER,
							 	anzeige.num, VISIBLE, VERTICAL,
							 	SLIDER_MINSIZE);
			/* Slider-Position einstellen						*/
	*slider_pos=((max=anzeige.num-VISIBLE)<0)
																		 ? 0 : max;
	(*params->pos_vslider)(haupt, SLBACK, SLIDER,
										 *slider_pos, 0, max, NIL);
	if(draw) redraw_object(haupt, SLBACK, FALSE);
}
/**********************************************/
/* Dialogbox im Fenster zentrieren ----------	*/
/*	öbergabeparameter: Zeiger auf Dialogbox,	*/
/*										 Koordinaten						*/
/*	RÅckgabeparameter: indirekt Åber Koordin.	*/
void wind_center(OBJECT *tree, WORD *x, WORD *y,
															 WORD *w, WORD *h)
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
/**********************************************/
/* Namensliste in die Dialogbox eintragen ---	*/
/*	öbergabeparameter: Zeichen-Flag						*/
/*	RÅckgabeparameter: KEINE									*/
void into_resource(WORD draw)
{
	WORD 	i,u;
 				/*	Alle mîglichen Anzeigen eintragen */
	for(i=0; i<VISIBLE; i++)		
	{
		if( anzeige.begin + i < anzeige.num)	
		{			/* Anzeigedaten im Bereich des Dar-	*/
					/*					stellbaren.							*/
	haupt[actlines[i]].ob_spec.tedinfo->te_ptext=
										nec_names[anzeige.begin+i];
	for(u=0; u<nec_max[anzeige.begin+i]; u++)
		if(
		BTESTE(anzeige.nec_flags[anzeige.begin+i],u)
																				 ==TRUE)
		haupt[actbut[i]].ob_spec.tedinfo->te_ptext=
			nec_config[berechne_index(anzeige.begin+i
																				,u,1)];
					/* Zeiger auf die Buffer-Rolle			*/
					/*		und die richtige Nr. auswÑhlen*/
					/* Als TOUCHEXIT markieren.					*/
			haupt[actlines[i]].ob_flags=TOUCHEXIT;
		}
		else
		{			/* Der Rest wird nicht dargestellt	*/
					/*	Er wird versteckt und nicht an-	*/
					/*		wÑhlbar.											*/		
			haupt[actlines[i]].ob_flags=HIDETREE;
		}
	}
	if(draw)	redraw_object(haupt,HAUPTWIN,TRUE);
}
/**********************************************/
/* Vertikalen Slider verschieben ------------	*/
/*	öbergabeparameter: Zeiger auf Dialogbox,  */
/*									 Index-Slider-Hintergrund	*/
/*								 	 Index Slider,						*/
/*									 Zeiger auf Slider-Posi.	*/
/*	RÅckgabeparameter: Keine									*/
void move_vslider(OBJECT *tree, WORD parent, 
									WORD slider, WORD *slider_pos)
{
	WORD max;
	max=((max=anzeige.num-VISIBLE)<0) ? 0 : max;
	(*params->move_vslider)(tree, parent, slider,
											 0, max, slider_pos, NIL);
	/* je nach Slider-Position die Namensliste neu
																		 ausgeben	*/
	anzeige.begin=((max=anzeige.num-VISIBLE-
											*slider_pos)<0) ? 0 : max;
	into_resource(TRUE);
}	
/**********************************************/
/* Vertikalen Slider positionieren ----------	*/
/*	öbergabeparameter: Zeiger auf Dialogbox,	*/
/*									 Index-Slider-Hintergrund	*/
/*								 	 Index Slider, Zeiger auf */
/*                   Slider-Position					*/
/*	RÅckgabeparameter: Keine									*/
void pos_vslider(OBJECT *tree, WORD parent,
									WORD slider, WORD *slider_pos)
{
	WORD 	my,y;
	WORD	dummy;
	WORD	max, temp;
	/* Koordinaten einlesen	*/
	graf_mkstate(&dummy, &my, &dummy, &dummy);
	objc_offset(tree, slider, &dummy, &y);
	/* je nach Mausposition entweder nach oben 	*/
	/*	oder unten scrollen											*/
	if(my<y)
		*slider_pos=((max=anzeige.num-VISIBLE)<=
			(temp=*slider_pos+VISIBLE)) ? max : temp;
	else
		*slider_pos=((max=*slider_pos-VISIBLE)<0)
																		 ? 0 : max;
									/* Slider neu positionieren	*/
	max=((max=anzeige.num-VISIBLE)<0) ? 0 : max;
	(*params->pos_vslider)(tree,parent, slider,
										  *slider_pos, 0, max, NIL);
									/* Namensliste neu ausgeben	*/
	anzeige.begin=((max=anzeige.num-VISIBLE-
											*slider_pos)<0) ? 0 : max;
	into_resource(TRUE);
	redraw_object(tree, parent, TRUE);
}
/**********************************************/
/* Im Fenster nach oben scrollen ------------	*/
/*	öbergabeparameter: Keine									*/
/*	RÅckgabeparameter: Keine									*/
void scroll_up(void)
{
	if(anzeige.begin>0)
	{		anzeige.begin--;	into_resource(TRUE); }
}
/**********************************************/
/* Im Fenster nach unten scrollen -----------	*/
/*	öbergabeparameter: Keine									*/
/*	RÅckgabeparameter: Keine									*/
void scroll_down(void)
{
	if(anzeige.begin+VISIBLE<anzeige.num)
	{		anzeige.begin++;	into_resource(TRUE);	}
}		
/**********************************************/
/* Pulldown-MenÅ generieren, darstellen und   */
/*  auswerten ------------------------------	*/
/* öbergabeparameter: angklickter Button,			*/
/*		 aus dem das MenÅ "herausklappen" soll	*/
/*		 Objectnr., da Pull-Down dort erscheint	*/
/* RÅckgabeparameter: Keine										*/
void pulldown( WORD button, WORD objc_button)
{
	WORD	i;
	WORD	num_items;
	WORD	index, checked;
	char	*pull_adr[MAX_ACTLEN];
	char	pull_buff[MAX_ACTLEN][17];
	GRECT	button_xywh,window_xywh;
						/* Lîschen des Anzeigebuffers			*/
	memset(pull_buff,0,sizeof(pull_buff));
	button--;
	num_items=nec_max[button];
	for(i=0; i<num_items; i++)
	{			/* LeereintrÑge fÅr Haken							*/
		strcpy(pull_buff[i],"  ");	
				/*	Pulldownbuffer mit den EintrÑgen	*/
				/*		vollschreiben.									*/
		strcat(pull_buff[i],	
				nec_config[berechne_index(button,i,0)]);
		strcat(pull_buff[i]," ");	/* Leereintrag	*/
		if(BTESTE(anzeige.nec_flags[button],i)==TRUE)
				index=i;	/* Index abgehakter Eintrag	*/
	}
	/* absolute Button-Koordinaten berechnen		*/
	objc_offset(haupt,objc_button,
						&button_xywh.g_x, &button_xywh.g_y);
	button_xywh.g_w=haupt[objc_button].ob_width;
	button_xywh.g_h=haupt[objc_button].ob_height;
	
	/* absolute Koordinaten der Dialogbox 			*/
	objc_offset(haupt,ROOT,	&window_xywh.g_x,
														 &window_xywh.g_y);
	window_xywh.g_w=haupt[ROOT].ob_width;
	window_xywh.g_h=haupt[ROOT].ob_height;

	/* Adressen der einzelnen EintrÑge					*/
	/*						in das öbergabe-Array Eintrag.*/
	for(i=0; i<num_items; i++)
		pull_adr[i]=pull_buff[i];
	/* Pull-Down-MenÅ zeichnen lassen und Index */
	/*	des angeklickten Eintrags zurÅckliefern	*/
	checked=(*params->do_pulldown)(pull_adr,
				 num_items, index, IBM, &button_xywh,
				 &window_xywh);
	if(checked>=0)
	{ 				/* Eintrag auf Null setzen				*/
		anzeige.nec_flags[button]=0L;
						/* Entsprechendes Bit setzen			*/
		BSETZE(anzeige.nec_flags[button],checked);
		into_resource(FALSE);
		redraw_object(haupt, objc_button, TRUE);
	}
}
/**********************************************/
/* Pulldown-MenÅ generieren, darstellen und 	*/
/*	auswerten ------------------------------	*/
/* öbergabeparameter: angklickter Button,			*/
/*		 aus dem das MenÅ "herausklappen" soll	*/
/*		 Objectnummer, Pull-Down dort erscheint	*/
/* RÅckgabeparameter: Keine										*/
void buttonclick( WORD button, WORD objc_button)
{
	WORD	i;
	WORD	num_items;
	WORD	checked;
	button--;
	num_items=nec_max[button];
	for(i=0; i<num_items; i++)
		if(BTESTE(anzeige.nec_flags[button],i)==TRUE)
				checked=((i+1)==num_items) ? 0 : (i+1);
						/* Eintrag auf Null setzen				*/
	anzeige.nec_flags[button]=0L;	
						/* Entsprechendes Bit setzen			*/
	BSETZE(anzeige.nec_flags[button],checked);
	into_resource(FALSE);
	redraw_object(haupt, objc_button, TRUE);
}
/**********************************************/
/* Index im Anzeigefeld berechnen -----------	*/
/*	öbergabeparameter: Banknummer,						*/
/*					Nummer in der entsprechenden Bank,*/
/*					Button oder Popup?								*/
/*	RÅckgabeparameter: Absolute Stringnummer	*/
WORD berechne_index(WORD bank, WORD nr,
																		 WORD zeige)
{	
	WORD i,anzahl=0;
	for(i=0; i<bank; i++) 	anzahl+=(nec_max[i]*2);
	anzahl+=(nr*2);		anzahl+=zeige;		
	return(anzahl);
}
