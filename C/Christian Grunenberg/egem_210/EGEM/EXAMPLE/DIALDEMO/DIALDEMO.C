
/* Dialog-Beispielprogramm zur EnhancedGEM-Library Version 2.10
   (c) 1994 C. Grunenberg (lÑuft nur als Programm) */

#include <e_gem.h>
#include <string.h>
#include <time.h>

#include "scroller.c"
#include "dialdemo.h"

/* Makro zum einfacheren Ermitteln der X_TEXT-Struktur */
#define get_xtext(tree,obj)	((X_TEXT *) tree[obj].ob_spec.userblk->ub_parm)

char *rsc = "dialdemo.rsc";
char *entry = "  DialDemo";
char *xacc_name = "DialogDemo";
char *av_name = "DIALDEMO";

char *title = "DialogDemo";			/* Fenstertitel */
char *chg_title = "* DialogDemo";	/*  - " - nach VerÑnderung */
char *small_title = "DialDemo";		/*  - " - im ikonifizierten Zustand */

/* Text fÅr die Beispiel-Alert-Box */
char *alert_text = 
"_ Erweiterte Alertboxen: ||"\
" Diese kînnen bis zu 16 Zeilen Text sowie|"\
" 5 Buttons, welche Åber Hotkeys bedient|"\
" werden kînnen, enthalten.|"\
" Neben 18 vordefinierten Icons kînnen auch|"\
" benutzerdefinierte Icons beliebiger Grîûe|"\
" verwendet werden.||"\
"!@      ZusÑtzlich kann jede Zeile mit|"\
"~      Textattributen versehen werden!";

/* benîtigte Prototypen */
void HandleDialog(void);
void do_alert(OBJECT *,int,int,int,int);
void do_help(OBJECT *,int,int,int,int);
void val_2_str(char *dest,long val);

/* Hilfetext und benîtigte Variablen/Strukturen */
extern char *help[];
extern int help_lines,line_help_h,view_help_lines;
extern int old_line,first_line,scroll_help;
extern USERBLK helpblk;

/* Zeiger auf ObjektbÑume sowie DIAINFO-Strukturen fÅr Dialoge */

DIAINFO *ex_info;		/* aktueller Dialog nach X_Form_Do */
OBJECT *icon_tree;		/* benutzer-definiertes Alert-Box-Icon */
OBJECT *menu;			/* Drop-Down-MenÅ */

OBJECT *dialog_tree, *help_tree, *text_tree, *demo_tree;
OBJECT *alerts_tree, *frames_tree, *edit_tree, *xacc_tree;
DIAINFO dialog_info, help_info, text_info, demo_info;
DIAINFO alerts_info, frames_info, edit_info, xacc_info;

/* Struktur fÅr Popup-Funktion initialisieren */
POPUP pop = { &dialog_info,0l,POPINFO,POPBTN,POPCYCLE,TRUE,TRUE };

/* System-Zeit bei Programmstart (in Milisekunden) */
long start_time;				

/* Zeitpunkt des letzten Timer-Events (- " -) */
long last_timer2,last_timer3,last_timer4;

/* Buffer fÅr Text-Scroller */
char scroller[] = "                                     ";
int scroll_pos = 0;		/* Position des Text-Scrollers */

/* Hotkeys fÅr Slider */

SLKEY sl_help_keys[] = {
{ sl_key(SCANUP,0), 0, SL_UP },
{ sl_key(SCANDOWN,0), 0, SL_DOWN },
{ sl_key(SCANUP,0), K_RSHIFT|K_LSHIFT, SL_PG_UP },
{ sl_key(SCANDOWN,0), K_RSHIFT|K_LSHIFT , SL_PG_DN },
{ sl_key(SCANUP,0), K_CTRL, SL_START },
{ sl_key(SCANDOWN,0), K_CTRL, SL_END },
{ sl_key(SCANHOME,0), 0, SL_START },
{ sl_key(SCANHOME,0), K_RSHIFT|K_LSHIFT, SL_END} };

SLKEY sl_alert_keys[] = {
{ sl_key(SCANLEFT,0), 0, SL_UP },
{ sl_key(SCANRIGHT,0), 0, SL_DOWN },
{ sl_key(CTRLLEFT,0), K_CTRL, SL_START },
{ sl_key(CTRLRIGHT,0), K_CTRL, SL_END }};

/* Strukturen fÅr Slider im Hilfe-Dialog */
SLINFO sl_help = {&help_info,HELPPAR,HELPSLID,HELPUP,HELPDOWN,0,0,0,VERT_SLIDER,SL_LINEAR,100,0,do_help,&sl_help_keys[0],8},
	   *sl_help_list[] = {&sl_help,NULL};

/* Strukturen fÅr Slider im Alert-Dialog */
SLINFO sl_alert = {&alerts_info,PARENT,SLIDE,LEFT,RIGHT,0,0,X_ICN_MAX+2,HOR_SLIDER,SL_LINEAR,100,0,do_alert,&sl_alert_keys[0],4},
	   *sl_alert_list[] = {&sl_alert,NULL};

/***********************************************************************
 Funktionen werden von graf_rt_slider() aufgerufen, sobald sich die
 Sliderposition geÑndert hat. Dadurch kînnen entsprechende Objekte neu
 gezeichnet oder gesetzt werden
************************************************************************/

void do_alert(OBJECT *obj,int pos,int prev,int max_pos,int top)
{
	reg char *text=ob_get_text(obj,0,0);
	reg int val=pos;

	/* Slider-Wert in String umrechnen */
	if (val==0)
		strcpy(text,"None");
	else if (val==(X_ICN_MAX+2))
		strcpy(text,"User");
	else
		val_2_str(text,val);
}

void do_help(OBJECT *obj,int pos,int prev,int max_pos,int top)
{
	old_line = prev;
	first_line = pos;
	scroll_help = TRUE;
	ob_draw_chg(&help_info,HELPVIEW,NULL,FAIL,top);
	scroll_help = 0;
}

/***********************************************************************
 Long-Wert in Dezimal-String konvertieren
***********************************************************************/

long digits[] = {10000,1000,100,10};

void val_2_str(char *dest,long val)
{
	reg long *d = digits,x;
	reg int i,all = FALSE;

	for (i=0;i<4;i++)
	{
		x = *d++;
		if (all || val>=x)
		{
			*dest++ = val/x + '0';
			val %= x;
			all = TRUE;
		}
	}

	*dest++ = val + '0';
	*dest++ = '\0';
}

/***********************************************************************
 Objekte des Xacc/AV-Dialoges setzen und neuzeichnen
***********************************************************************/

void set_xacc_av(void)
{
	reg XAcc *xacc;
	reg int first,xacc_cnt=0,av_cnt=0;
	static int list[] = {XACCCNT,AVCNT,AVSERVER,0};

	/* erste Applikation suchen */
	first = 1;
	while ((xacc=find_app(first))!=NULL)
	{
		/* XAcc-Applikation? */
		if (xacc->flag & XACC)
			xacc_cnt++;
		/* AV-Applikation? */
		if (xacc->flag & AV)
			av_cnt++;
		/* nÑchste Applikation suchen */
		first=0;
	}

	val_2_str(ob_get_text(xacc_tree,XACCCNT,0),xacc_cnt);
	val_2_str(ob_get_text(xacc_tree,AVCNT,0),av_cnt);

	ob_set_text(xacc_tree,AVSERVER,(AvServer>=0) ? "AV-Server vorhanden" : "Kein AV-Server");

	/* ...und Objekte neuzeichnen, sofern Dialog geîffnet */
	ob_draw_list(&xacc_info,list,NULL);
}

/***********************************************************************
 Alle Dialoge schlieûen sowie optional Beenden der Applikation
 (MenÅleiste lîschen, Resource freigeben, Abmeldung bei AES und VDI)
***********************************************************************/

void ExitExample(int all)
{
	/* alle geîffneten Dialoge schlieûen */
	close_all_dialogs();

	if (all)
		/* MenÅleiste entfernen, Resource freigeben, Abmeldung bei AES, VDI
		   und Protokollen und Programm beenden */
		close_rsc(0);
}

/***********************************************************************
 Resource und ObjektbÑume initialsieren
***********************************************************************/

void init_resource(void)
{
    X_TEXT *text;
	OBJECT *obj;
	int i;

/* Adressen der ObjektbÑume (Dialoge,MenÅs,Popups) ermitteln */
	rsrc_gaddr(R_TREE, POP, &pop.p_menu);		/* Popup-MenÅ */
	rsrc_gaddr(R_TREE, MENU, &menu);			/* Pull-Down-MenÅ */
	rsrc_gaddr(R_TREE, EGEMICON, &iconified);	/* ikonifizierte Darstellung */
	rsrc_gaddr(R_TREE, INFODIAL, &demo_tree);
	rsrc_gaddr(R_TREE, DIALOG, &dialog_tree);
	rsrc_gaddr(R_TREE, TEXTDIAL, &text_tree);
	rsrc_gaddr(R_TREE, ALERTS, &alerts_tree);
	rsrc_gaddr(R_TREE, RAHMEN, &frames_tree);
	rsrc_gaddr(R_TREE, EDITDEMO, &edit_tree);
	rsrc_gaddr(R_TREE, HELPDIAL, &help_tree);
	rsrc_gaddr(R_TREE, ALERTICN, &icon_tree);
	rsrc_gaddr(R_TREE, XACCDEMO, &xacc_tree);

/* erweiterte Objekte sowie Images/Icons anpassen */
	for (i=0;i<=XACCDEMO;i++)
	{
		rsrc_gaddr(R_TREE, i, &obj);
		fix_objects(obj,TEST_SCALING|DARK_SCALING,8,16);
	}

/*  Zeichensatz und Grîûe des GDOS-Attribut-Texts setzen */
	text = get_xtext(text_tree,GDOSTEXT);
	text->font_id = 0;
	text->font_size = -9;

/*  VDI-Schreibmodus des XOR-Textes setzen */
	get_xtext(text_tree,XORTEXT)->mode = MD_XOR;

/*  Text-Scroller setzen */
	ob_set_text(demo_tree,SCROLLER,scroller);

/* Erstellungsdatum und Versionsnummer im Informationsdialog setzen */
	ob_set_text(demo_tree,DATE,__DATE__);
	strcpy(ob_get_text(demo_tree,VERS,FALSE)+8,E_GEM_VERSION);

/* Hilfe-Dialog auf benutzerdefiniertes Objekt setzen */
	obj = &help_tree[HELPVIEW];
	obj->ob_type = G_USERDEF;
	obj->ob_spec.userblk = &helpblk;

/* Slider-Struktur und benîtigte Variablen zur Darstellung setzen  */
	i = obj->ob_height;
	line_help_h = gr_sh+2;
	sl_help.sl_page = view_help_lines = (i/line_help_h)-1;
	sl_help.sl_max = help_lines;

/* Koordinaten des Fenster-Objektes anpassen */
	obj->ob_y += (i - (obj->ob_height = view_help_lines*line_help_h))>>1;

/* Koordinaten der Slider-Objekte anpassen */

	help_tree[HELPUP].ob_x -= 2;
	help_tree[HELPUP].ob_y += 2;

	help_tree[HELPDOWN].ob_x -= 2;
	help_tree[HELPDOWN].ob_y -= 2;

	obj = &help_tree[HELPPAR];
	obj->ob_x -= 2;
	obj->ob_y = help_tree[HELPUP].ob_y + help_tree[HELPUP].ob_height + 1;
	obj->ob_height = help_tree[HELPDOWN].ob_y - obj->ob_y;

/* Help-Slider-Objekte initialisieren */
	graf_set_slider(&sl_help,help_tree,GRAF_SET);

/* Alertbox-Slider-Objekte initialisieren */
	graf_set_slider(&sl_alert,alerts_tree,GRAF_SET);
	do_alert(&alerts_tree[SLIDE],sl_alert.sl_pos,0,0,0);

/* XAcc/AV-Dialogobjekte initialisieren */
	set_xacc_av();

/* (Eingabe-) Felder in verschiedenen Dialogen zurÅcksetzen */
	ob_clear_edit(dialog_tree);
	ob_clear_edit(edit_tree);

	ob_get_text(xacc_tree,TIMEDEMO,TRUE);
}

/***********************************************************************
 Dialog îffnen und in Liste der geîffneten Dialoge eintragen bzw. falls
 der Dialog schon geîffnet ist, diesen in den Vordergrund bringen.
***********************************************************************/

void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode)
{
	reg SLINFO **slider = NULL;
	reg char *name = title,*icon_name = small_title;
	reg int center = TRUE;

	switch (info->di_flag)
	{
	/* Fensterdialog bereits geîffnet ? */
	case WINDOW:
	case WIN_MODAL:
		/* Dialog in den Vordergrund holen */
		window_top(info->di_win);
		break;
	/* Dialog geschlossen ? */
	case CLOSED:
		/* Dialog îffnen (zur Mausposition, keine Grow-Boxen) */
		if (info==&help_info)
		{
			icon_name = name = "Hilfe";
			slider = sl_help_list;
		}
		else if (info==&xacc_info)
		{ /* XAcc/AV-Info-Dialog in linker, oberer Desktop-Ecke îffnen */
			xacc_tree->ob_x = desk.g_x+2;
			xacc_tree->ob_y = desk.g_y+2;
			center = FAIL;
		}
		else if (info==&alerts_info)
			slider = sl_alert_list;

		if (open_dialog(tree,info,name,icon_name,NULL,center,FALSE,dial_mode,0,slider)==FALSE)
			/* Dialog konnte nicht geîffnet werden (z.B. keine Fenster mehr ver-
			   fÅgbar */
			xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,"Keine freien Fenster mehr!","[Ok");
		else if (info==&help_info)
			/* ansonsten Info-Zeile des Hilfe-Dialogs setzen */
			window_info(help_info.di_win," Ein Fensterdialog mit Infozeile und Echtzeitschieber...");
	}

	/* Verwaltung der geîffneten Dialoge u. Auswertung der Benutzeraktionen */
	HandleDialog();
}

/***********************************************************************
 MenÅauswertungsroutine, welche bei Bedarf den zu einem Hotkey gehîrenden
 MenÅpunkt ermittelt und die zu diesem MenÅpunkt gehîrende Funktion aus-
 fÅhrt
***********************************************************************/

/* Struktur, welche die vorhandenen MenÅpunkte (bzw. Buttons im Haupt-
   dialog) sowie die dazugehîrigen Dialoge definiert */

typedef struct
{
	int	object,shortcut,state;	/* MenÅeintrag, Hotkeytaste, -status */
	DIAINFO *info;				/* Zeiger auf DIAINFO-Struktur des Dialogs */
	OBJECT **tree;				/* Zeiger auf Objektbaum */
	int mode;					/* Art des Dialogs */
} MENUITEM;

MENUITEM items[] = {
{INFOBOX, 'I', K_CTRL, &demo_info, &demo_tree, AUTO_DIAL},
{QUIT, 'Q', K_CTRL, NULL, NULL, FAIL},
{ATTRMENU, 'T', K_CTRL, &text_info, &text_tree, AUTO_DIAL},
{EDITMENU, 'E', K_CTRL, &edit_info, &edit_tree, AUTO_DIAL},
{ALRTMENU, 'A', K_CTRL, &alerts_info, &alerts_tree, AUTO_DIAL},
{XACCMENU, 'X', K_CTRL, &xacc_info, &xacc_tree, WIN_DIAL},
{TITLMENU, 'R', K_CTRL, &frames_info, &frames_tree, AUTO_DIAL},
{FLYMENU, 'F', K_CTRL, &dialog_info, &dialog_tree, FLY_DIAL},
{WINMENU, 'D', K_CTRL, &dialog_info, &dialog_tree, WIN_DIAL},
{MODMENU, 'M', K_CTRL, &dialog_info, &dialog_tree, WIN_DIAL|MODAL},
{HELPMENU, 'H', K_CTRL, &help_info, &help_tree, WIN_DIAL|WD_INFO}
};

#define ITEMS sizeof(items)

int MenuSelect(int object,int scan,int state)
{
	reg MENUITEM *item=items;
	reg int index,key;

	if (object<0)
	{
		/* Eintrag zu Tastatur-Ereignis ermitteln */
		key = scan_2_ascii(scan,state);
		for (index=0;index<ITEMS;index++,item++)
			if (item->shortcut==key && item->state==state)
				break;
	}
	else
	{
		/* Eintrag zu MenÅpunkt ermitteln */
		for (index=0;index<ITEMS;index++,item++)
			if (item->object==object)
				break;
	}

	if (index>=ITEMS)
		return (FALSE);	/* kein entsprechender Eintrag gefunden */

	/* MenÅpunkte 'Fenster wechseln' und 'Fenster schlieûen' werden
	   inklusive der dazugehîrigen Hotkeys automatisch verwaltet */

	if (item->object==QUIT)
		ExitExample(1);	/* Applikation beenden */
	else
		OpenDialog(item->info,*item->tree,item->mode);	/* Dialog îffnen */

	return (TRUE);
}

/***********************************************************************
 Verwaltung der geîffneten Dialoge und Auswertung der Benutzeraktionen
***********************************************************************/

static int already_handling = FALSE;

void HandleDialog(void)
{
	reg int double_click,exit;

	/* Wird die Verwaltung bereits Åbernommen? */
	if (already_handling)
		return;
	else
		already_handling = TRUE;

	for (;;)
	{
		/* Auf Benutzeraktionen warten
		   exit -> angewÑhltes Objekt (Bit 15 = Doppelklick)
		   ex_info -> Zeiger auf DIAINFO-Struktur des angewÑhlten Dialogs
	    */
		exit = X_Form_Do(&ex_info);

		if (exit==W_CLOSED)
			/* Fenster-Closer -> Dialog schlieûen */
			close_dialog(ex_info,FALSE);
		else if (exit==W_ABANDON)
			/* Dialog wurde geschlossen, aber kein Objekt angewÑhlt (z.B. AP_TERM),
			   oder es waren keine Dialoge mehr geîffnet */
			break;
		else
		{
			/* Doppelklick erfassen und aus Wert fÅr Exit-Objekt ausmaskieren */
			exit ^= (double_click = exit & 0x8000);

			/* angewÑhltes Objekt deselektieren und neu zeichnen */
			ob_select(ex_info,ex_info->di_tree,exit,CLEAR_STATE,TRUE);

			/* Demonstrations-Dialog */
			if (ex_info==&dialog_info)
			{
				switch (exit)
				{
				/* Popup-Infotext/-button/-cycleobjekt angewÑhlt */
				case POPINFO:
				case POPBTN:
				case POPCYCLE:
					/* Falls Cycle-Objekt angewÑhlt wurde oder das Popup-MenÅ
					   mit Alternate-Shift-Hotkey aufgerufen wurde, nÑchsten
					   Eintrag ermitteln, ansonsten Popup aufrufen */
					Popup(&pop,(exit==POPCYCLE || double_click) ? POPUP_CYCLE_CHK : POPUP_BTN_CHK,
						  OBJPOS,0,0,NULL,FAIL);
					if (dialog_info.di_flag==WINDOW && dialog_info.di_win->name==title)
						/* neue Titelzeile des unmodalen Dialogs setzen */
						window_name(dialog_info.di_win,chg_title,small_title);
					break;
				/* Hilfe-Button -> Hilfe-Dialog îffnen */
				case HELP:
					OpenDialog(&help_info,help_tree,WIN_DIAL|WD_INFO);
					break;
				/* Suchen-Button -> Warnung (Disketten-Fehler) ausgeben */
				case SEARCH:
					xalert(1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,"Keine Datei gefunden!","[Ok");
					break;
				/* Ansonsten Dialog schlieûen */
				default:
					close_dialog(ex_info,FALSE);
				}
			}
			/* Alert-Boxen-Dialog */
			else if (ex_info==&alerts_info && exit==DOALERT)
			{
				/* Alertbox entsprechend den Einstellungen darstellen */
				BITBLK *user = NULL;
				int align,center,icon,modal;

				/* einheitliche Button-Breite? */
				align = ob_isstate(alerts_tree,BTNWIDTH,SELECTED);

                /* System-modale Alert-Box ? */
                modal = ob_isstate(alerts_tree,SYSMODAL,SELECTED) ? SYS_MODAL : APPL_MODAL;

				/* Ausrichtung der Buttons */
				center = ob_radio(alerts_tree,ALERTOPT,FAIL);

				/* gewÅnschtes Icon */
				icon = sl_alert.sl_pos;
				if (icon==0)
					icon = FAIL;	/* kein Icon */
				else if (icon==X_ICN_MAX+2)
				{
					/* benutzerdefiniertes Icon */
					icon = FAIL;
					user = icon_tree[USERICON].ob_spec.bitblk;
				}
				else
					icon--;

				xalert(2,1,icon,user,modal,center,align,(modal==SYS_MODAL) ? NULL : title,alert_text,"[Huh-Huh|[This sucks!");
				if (user)
					xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,"That was cool!","[Yeah!");
			}
			/* ansonsten Dialog schlieûen */
			else
				close_dialog(ex_info,FALSE);
		}
	}

	already_handling = FALSE;
}

/***********************************************************************
 Initialisierungs-Routine, welche von X_Form_Do bzw. Event_Multi aufge-
 rufen wird und die Event-Struktur setzt sowie die Ereignisse, die von der
 Applikation benîtigt werden, zurÅckgibt
***********************************************************************/

int InitMsg(XEVENT *evt,int events_available)
{
	/* auf Nachrichten und TastendrÅcke warten */
	reg int flags = MU_MESAG|MU_KEYBD;

	/* Protokoll-Dialog geîffnet und 2. Timer verfÅgbar? */
	if (xacc_info.di_flag>CLOSED && (events_available & MU_TIMER2))
	{
		evt->ev_mt2count = 1000;		/* ein Event pro Sekunde */
		evt->ev_mt2last = last_timer2;
		flags |= MU_TIMER2;		/* auf 2. Timer-Event warten */
	}

	/* Informations-Dialog geîffnet und 3/4. Timer verfÅgbar? */
	if (demo_info.di_flag>CLOSED)
	{
		/* Farbe vorhanden? */
		if ((events_available & MU_TIMER3) && colors>2)
		{
			evt->ev_mt3count = 1000/3;	/* 3 Events pro Sekunde */
			evt->ev_mt3last = last_timer3;
			flags |= MU_TIMER3;		/* auf 3. Timer-Event warten */
		}

		if (events_available & MU_TIMER4)
		{
			evt->ev_mt4count = 1000/12;	/* 12 Events pro Sekunde */
			evt->ev_mt4last = last_timer4;
			flags |= MU_TIMER4;		/* auf 4. Timer-Event warten */
		}
	}

	/* benîtigte und verfÅgbare Events zurÅckgeben */
	return (flags & events_available);
}

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten, TastendrÅcke, Timer ), welche sowohl
 von Event_Multi() als auch von X_Form_Do() aufgerufen wird
***********************************************************************/

int Messag(XEVENT *event)
{
	reg X_TEXT *text;
	reg DIAINFO *info;
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	reg int used = 0;

	/* 2. Timer-Event auswerten */
	if (ev & MU_TIMER2)
	{
		last_timer2 = event->ev_mt2last;
		val_2_str(ob_get_text(xacc_tree,TIMEDEMO,0),(last_timer2-start_time)/1000);
		ob_draw(&xacc_info,TIMEDEMO);
		used |= MU_TIMER2;	/* Timer ausgewertet */
	}

	/* 3. Timer-Event auswerten */
	if (ev & MU_TIMER3)
	{
		last_timer3 = event->ev_mt3last;
		text = get_xtext(demo_tree,DEDICATE);
		if (++text->color>=colors)
			text->color = 1;
		ob_draw(&demo_info,DEDICATE);
		used |= MU_TIMER3;	/* Timer ausgewertet */
	}

	/* 4. Timer-Event auswerten */
	if (ev & MU_TIMER4)
	{
		last_timer4 = event->ev_mt4last;

		strcpy(&scroller[0],&scroller[1]);
		scroller[sizeof(scroller)-2] = scroll_text[scroll_pos++];
		if (scroll_pos>=sizeof(scroll_text))
			scroll_pos = 0;

		ob_draw(&demo_info,SCROLLER);
		used |= MU_TIMER4;	/* Timer ausgewertet */
	}

	/* Nachricht vom AES ? */
	if (ev & MU_MESAG)
	{
		/* Nachrichtenereignis wurde ausgewertet */
		used |= MU_MESAG;

		switch (*msg)
		{
		/* MenÅeintrag angeklickt ? */
		case MN_SELECTED:
			/* MenÅeintrag deselektieren */
			menu_select(msg[3],0);

			/* gewÅnschte Funktion ausfÅhren */
			if (MenuSelect(msg[4],0,0)==FALSE)
				/* Nachricht konnte nicht ausgewertet werden
				   (sollte NIE vorkommen) */
				used &= ~MU_MESAG;
			break;
		/* Applikation beenden/rÅcksetzen */
		case AP_TERM:
			ExitExample(1);
			break;
		/* Applikation hat sich an- oder abgemeldet */
		case XACC_AV_INIT:
		case XACC_AV_EXIT:
			set_xacc_av();
			break;
		/* Wurde eine Eingabe in einem Dialog vorgenommen oder ein
		   Objekt (de-) selektiert? */
		case OBJC_CHANGED:
		case OBJC_EDITED:
			info = *(DIAINFO **) &msg[4];
			if (info!=&help_info && info->di_flag==WINDOW && info->di_win->name==title)
				/* neue Titelzeile des unmodalen Dialogs setzen */
				window_name(info->di_win,chg_title,small_title);
			break;
		default:
		/* unbekannte Nachricht konnte nicht ausgewertet werden */
			used &= ~MU_MESAG;
		}
	}

	/* Tastatur-Ereignis auswerten */
	if ((ev & MU_KEYBD) && MenuSelect(FAIL,event->ev_mkreturn,event->ev_mmokstate))
		used |= MU_KEYBD;	/* Tastaturereignis wurde ausgewertet */

	return (used);
}

void main()
{
	/* Wurde die Demo als Accessory gestartet? */
	if (!_app)
		exit(-1); /* Ja -> Demo beenden */

	/* Start-Zeit setzen */
	last_timer2 = last_timer3 = last_timer4 = start_time = clock()*5;

	/* Resource-File laden und Bibliothek sowie AES und VDI initialisieren
	   (keine anwendungspezifische AV/VA/XAcc-Nachrichtenauswertung) */
	if (open_rsc(rsc,entry,xacc_name,av_name,0,0,0)==TRUE)
	{
		/* Resource-Datei bzw. ObjektbÑume initialisieren */
		init_resource();

		/* Routinen zur Ereignisauswertung anmelden */
		Event_Handler(InitMsg,Messag);

		/* Hotkeys und MenÅpunkte fÅr Fenster wechseln/schlieûen setzen */
		CycleCloseWindows('W','U',CYCLE,CLOSE);

		/* Dialog-Optionen setzen, u.a. Hintergrundbedienung von
		  Fensterdialogen u. TastendrÅcke an Dialog unter Mauszeiger,
		  Return selektiert DEFAULT-Objekt bei letztem Eingabefeld */
		dial_options(TRUE,TRUE,FALSE,TRUE,FAIL,TRUE,FALSE,FALSE,TRUE);

		/* Dialog-Farben und FÅllmuster setzen */
        dial_colors(7,(colors>=16) ? YELLOW : WHITE,GREEN,RED,MAGENTA,BLUE,CYAN,RED);

		title_options(FALSE,RED,FALSE);	/* Titel-Optionen setzen */
		check_image(5,NULL);			/* HÑkchen als Image fÅr Check-Boxen */

		menu_install(menu,TRUE);		/* Pull-Down-MenÅ anmelden */

		/* XAcc/AV-Info-Dialog îffnen */
		OpenDialog(&xacc_info,xacc_tree,WIN_DIAL);

        /* Auf Ereignis (Nachrichten/TastendrÅcke) warten und dieses
           auswerten. In diesem Fall werden die benîtigten Events be-
           reits durch die Funktionen InitMsg() und Messag() gesetzt und
           ausgewertet. ZusÑtzlich kînnte man natÅrlich hier noch wei-
           tere Events angeben, die speziell ausgewertet werden, oder
           den Event_Handler abmelden und alle Ereignisse hier auswerten.
           Dann mÅûte man allerdings die Funktion Event_Multi in eine
           Endlosschleife integrieren */
		Event_Multi(NULL);	/* und los geht's */
	}
}
