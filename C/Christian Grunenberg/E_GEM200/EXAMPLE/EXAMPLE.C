
/* Beispielprogramm zur EnhancedGEM-Library Version 2.00
   (lÑuft als Programm und als Accessory), (c) 1994 C. Grunenberg */

#include <e_gem.h>
#include <string.h>
#include <time.h>

#include "example.h"

char *title = "EnhancedGEM "E_GEM_VERSION;
char *version = E_GEM_VERSION;

/* Text fÅr die Beispiel-Alert-Box */

char *alert_text =  "Alert-Boxen kînnen bis zu 10 Zeilen|"
                    "Text sowie 5 Buttons, welche Åber|"
                    "Hotkeys bedient werden kînnen, ent-|"
                    "halten.|"
					"Neben 18 vordefinierten Icons kîn-|"
					"nen auch benutzerdefinierte Icons|"
					"beliebiger Grîûe verwendet werden.";

/* benîtigte Prototypen */

int MenuSelect(int object,int scan,int state,int button);
void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode);
void CloseDialog(DIAINFO *info);
void ExitExample(int all);
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

OBJECT *dialog_tree, *help_tree, *text_tree, *information_tree;
OBJECT *alerts_tree, *main_tree, *frames_tree, *edit_tree, *xacc_tree;
DIAINFO dialog_info, help_info, text_info, information_info;
DIAINFO alerts_info, main_info, frames_info, edit_info, xacc_info;

/* Struktur fÅr Popup-Funktion initialisieren */
POPUP pop = { &dialog_info,0l,POPINFO,POPBTN,POPCYCLE,TRUE,TRUE };

/* Liste von Zeigern auf DIAINFO-Strukturen der geîffneten Dialoge */
DIAINFO *wins[16];

/* Anzahl der geîffneten Dialoge */
int win_cnt;

/* System-Zeit bei Programmstart (in Milisekunden) */
long start_time;

/* Letztes Timer-Ereignis (in Milisekunden) */
long last_time;

/* Hotkeys fÅr Slider */

#define SCANUP		(72<<8)
#define SCANDOWN	(80<<8)
#define SCANLEFT	(75<<8)
#define SCANRIGHT	(77<<8)
#define CTRLLEFT	(115<<8)
#define CTRLRIGHT	(116<<8)
#define SCANHOME	(71<<8)

SLKEY sl_help_keys[] = {
{ SCANUP, 0, SL_UP },
{ SCANDOWN, 0, SL_DOWN },
{ SCANUP, K_RSHIFT|K_LSHIFT, SL_PG_UP },
{ SCANDOWN, K_RSHIFT|K_LSHIFT , SL_PG_DN },
{ SCANUP, K_CTRL, SL_START },
{ SCANDOWN, K_CTRL, SL_END },
{ SCANHOME, 0, SL_START },
{ SCANHOME, K_RSHIFT|K_LSHIFT, SL_END} };

SLKEY sl_alert_keys[] = {
{ SCANLEFT, 0, SL_UP },
{ SCANRIGHT, 0, SL_DOWN },
{ CTRLLEFT, K_CTRL, SL_START },
{ CTRLRIGHT, K_CTRL, SL_END }};

/* Strukturen fÅr Slider im Hilfe-Dialog */
SLINFO sl_help =	{&help_info,HELPPAR,HELPSLID,HELPUP,HELPDOWN,0,0,0,
					VERT_SLIDER,SL_LINEAR,100,0,do_help,&sl_help_keys[0],8};
SLINFO *sl_help_list[] = {&sl_help,NULL};

/* Strukturen fÅr Slider im Alert-Dialog */
SLINFO sl_alert =	{&alerts_info,PARENT,SLIDE,LEFT,RIGHT,0,0,X_ICN_MAX+2,
					HOR_SLIDER,SL_LINEAR,100,0,do_alert,&sl_alert_keys[0],4};
SLINFO *sl_alert_list[] = {&sl_alert,NULL};

/***********************************************************************
 Funktionen wirden von graf_rt_slider() aufgerufen, sobald sich die
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

	scroll_help = top;
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
	reg int first=1,xacc_cnt=0,av_cnt=0;
	static int list[] = {XACCCNT,AVCNT,AVSERVER,0};

	while ((xacc=find_app(first))!=NULL)
	{
		if (xacc->flag & XACC)
			xacc_cnt++;
		if (xacc->flag & AV)
			av_cnt++;
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
	while (--win_cnt>=0)
		close_dialog(wins[win_cnt],FALSE);

	if (all && _app)
	{
		/* MenÅleiste entfernen */
		menu_install(menu,FALSE);
		/* Resource freigeben, Abmeldung bei AES, VDI und Protokollen */
		close_rsc();
		/* Programm beenden */
		exit(0);
	}

	win_cnt=0;
}

/***********************************************************************
 Resource und ObjektbÑume initialsieren
***********************************************************************/

void init_resource(void)
{
	OBJECT *obj;
	int i;

/* Adressen der ObjektbÑume (Dialoge,MenÅs,Popups) ermitteln */
	rsrc_gaddr(R_TREE, POP, &pop.p_menu);		/* Popup-MenÅ */

	rsrc_gaddr(R_TREE, MENU, &menu);			/* Pull-Down-MenÅ */
	rsrc_gaddr(R_TREE, EGEMICON, &iconified);	/* ikonifizierte Darstellung */

	rsrc_gaddr(R_TREE, INFODIAL, &information_tree);
	rsrc_gaddr(R_TREE, DIALOG, &dialog_tree);
	rsrc_gaddr(R_TREE, TEXTDIAL, &text_tree);
	rsrc_gaddr(R_TREE, MAIN, &main_tree);
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
		if (obj==information_tree)
			fix_objects(obj,(TEST_SCALING|DARK_SCALING),8,16);
		else
			fix_objects(obj,NO_SCALING,8,16);
	}

/* Erstellungsdatum und Versionsnummer im Informationsdialog setzen */
	ob_set_text(information_tree,DATE,__DATE__);
	strcpy(ob_get_text(information_tree,VERS,FALSE)+8,version);

/* erweiterte/benutzerdefinierte Objekte im Hilfe-Dialog setzen */

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

	/* Eingabe-Felder in verschiedenen Dialogen zurÅcksetzen */
	ob_get_text(dialog_tree,DATEI,TRUE);
	ob_get_text(dialog_tree,PFAD,TRUE);

	ob_get_text(edit_tree,EDIT1,TRUE);
	ob_get_text(edit_tree,EDIT2,TRUE);
	ob_get_text(edit_tree,EDIT3,TRUE);
	ob_get_text(edit_tree,EDIT4,TRUE);
	ob_get_text(edit_tree,EDIT5,TRUE);
	ob_get_text(edit_tree,EDIT6,TRUE);

	ob_get_text(xacc_tree,TIMEDEMO,TRUE);
}

/***********************************************************************
 Dialog îffnen und in Liste der geîffneten Dialoge eintragen bzw. falls
 der Dialog schon geîffnet ist, diesen in den Vordergrund bringen. Auûerdem
 Verwaltung der geîffneten Dialoge und Auswertung der Benutzeraktionen
***********************************************************************/

void OpenDialog(DIAINFO *info,OBJECT *tree,int dial_mode)
{
	reg SLINFO **slider = NULL;
	reg char *name = title;
	reg int double_click,exit = win_cnt,center = TRUE;

	switch (info->di_flag)
	{
	/* Fensterdialog bereits geîffnet ? */
	case WINDOW:
	case WIN_MODAL:
		/* Dialog in den Vordergrund holen */
		wind_set(info->di_win->handle,WF_TOP);
		break;
	/* Dialog geschlossen ? */
	case CLOSED:
		/* Dialog îffnen (zur Mausposition, keine Grow-Boxen) */
		if (info==&help_info)
		{
			name = "Hilfe";
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

		if (open_dialog(tree,info,name,center,FALSE,dial_mode,0,slider))
			/* geîffneten Dialogin Liste eintragen */
			wins[win_cnt++] = info;
		else
			/* Dialog konnte nicht geîffnet werden (keine Fenster mehr ver-
		        fÅgbar */
			xalert(1,1,X_ICN_ERROR,NULL,BUTTONS_CENTERED,TRUE,title,"Keine freien Fenster mehr!","[Ok");
	}

	/* Waren bereits vorher Dialoge geîffnet ? */
	if (exit>0)
		/* Ja, also wird die Verwaltung bereits an anderer Stelle Åbernommen */
		return;
	/* ansonsten Verwaltung der geîffneten Dialoge u. Auswertung der Benutzeraktionen */

	/* Solange Dialog geîffnet, Schleife wiederholen */
	while (win_cnt>0)
	{
		/* Auf Benutzeraktionen warten
		   exit -> angewÑhltes Objekt (Bit 15 = Doppelklick)
		   ex_info -> Zeiger auf DIAINFO-Struktur des angewÑhlten Dialogs
	    */
		exit = X_Form_Do(&ex_info);

		/* Fenster-Closer */
		if (exit == W_CLOSED)
			/* Dialog schlieûen */
			CloseDialog(ex_info);
		/* Dialog wurde geschlossen, aber kein Objekt angewÑhlt
		   (z.B. durch AC_CLOSE) */
		else if (exit == W_ABANDON)
			ExitExample(0);
		else
		{
			/* Doppelklick erfassen und aus Wert fÅr Exit-Objekt ausmaskieren */
			exit ^= (double_click = exit & 0x8000);

			/* Exit-Objekt selektiert? */
			if (ob_isstate(ex_info->di_tree,exit,SELECTED))
			{
				/* angewÑhltes Objekt deselektieren und neu zeichnen */
				ob_undostate(ex_info->di_tree,exit,SELECTED);
				ob_draw_chg(ex_info,exit,NULL,FAIL,FALSE);
			}

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
					break;
				/* Hilfe-Button -> Hilfe-Dialog îffnen */
				case HELP:
					OpenDialog(&help_info,help_tree,WIN_DIAL);
					break;
				/* Suchen-Button -> Warnung (Disketten-Fehler) ausgeben */
				case SEARCH:
					xalert(1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,"Keine Datei gefunden!","[Ok");
					break;
				/* Ansonsten Dialog schlieûen */
				default:
					CloseDialog(ex_info);
				}
			}
			/* Haupt-Dialog */
			else if (ex_info==&main_info)
			{
			    /* Je nach selektiertem Button entsprechenden Dialog îffnen */
				if (MenuSelect(FAIL,0,0,exit)==FALSE)
					CloseDialog(ex_info); /* ansonsten Dialog schlieûen */
			}
			/* Alert-Boxen-Dialog */
			else if (ex_info==&alerts_info && exit==DOALERT)
			{
				/* Alertbox entsprechend den Einstellungen darstellen */
				BITBLK *user = NULL;
				int align,center,icon;

				/* einheitliche Button-Breite? */
				align = ob_isstate(alerts_tree,BTNWIDTH,SELECTED);

				/* Ausrichtung der Buttons */
				if (ob_isstate(alerts_tree,BTNSLEFT,SELECTED))
					center = BUTTONS_LEFT;	/* linksbÅndig */
				else if (ob_isstate(alerts_tree,BTNSRGHT,SELECTED))
					center = BUTTONS_RIGHT;	/* rechtsbÅndig */
				else
					center = BUTTONS_CENTERED; /* zentriert */

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

				xalert(2,1,icon,user,center,align,title,alert_text,"[Huh-Huh|[This sucks!");
				if (user)
					xalert(1,1,X_ICN_ERROR,NULL,BUTTONS_CENTERED,TRUE,title,"That was cool!","[Yeah!");
			}
			/* ansonsten Dialog schlieûen */
			else
				CloseDialog(ex_info);
		}
	}
}

/***********************************************************************
 Dialog schlieûen und aus Liste der geîffneten Dialoge entfernen
***********************************************************************/

void CloseDialog(DIAINFO *info)
{
	/* Dialog geîffnet ? */
	if (info->di_flag>CLOSED)
	{
		int i;

		/* Dialog schlieûen ohne Shrink-Box */
		close_dialog(info,FALSE);

		/* Dialog in Liste suchen und entfernen */
		for (i=0;i<win_cnt;i++)
			if (wins[i]==info)
				break;

		for (win_cnt--;i<win_cnt;i++)
			wins[i] = wins[i+1];
	}
}

/***********************************************************************
 Initialisierungs-Routine, welche von X_Form_Do bzw. Event_Multi aufge-
 rufen wird und die Event-Struktur setzt sowie die Ereignisse, die von der
 Applikation benîtigt werden, zurÅckgibt
***********************************************************************/

int InitMsg(XEVENT *evt,int events_available)
{
	/* Dialog geîffnet? */
	if (xacc_info.di_flag>CLOSED && (events_available & MU_TIMER2))
	{
		evt->ev_mt2hicount = 0;
		evt->ev_mt2locount = 1000;
		evt->ev_mt2last = last_time;

		/* auf Nachrichten, TastendrÅcke und Timer-Events fÅr Anzeige der
		   vergangenen Zeit warten */
		return (MU_MESAG|MU_KEYBD|MU_TIMER2);
	}
	else
		/* ansonsten nur Nachrichten und TastendrÅcke auswerten */
		return (MU_MESAG|MU_KEYBD);
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
	int button;					/* Button im Haupt-Dialog */
	DIAINFO *info;				/* Zeiger auf DIAINFO-Struktur des Dialogs */
	OBJECT **tree;				/* Zeiger auf Objektbaum */
	int mode;					/* Art des Dialogs */
} MENUITEM;

#define ITEMS 11

MENUITEM items[] = {
{INFOBOX, 'I', K_CTRL, INFOBTN, &information_info, &information_tree, FLY_DIAL},
{QUIT, 'Q', K_CTRL, FAIL, NULL, NULL, FAIL},
{ATTRMENU, 'T', K_CTRL, TEXTBTN, &text_info, &text_tree, AUTO_DIAL},
{EDITMENU, 'E', K_CTRL, EDITBTN, &edit_info, &edit_tree, AUTO_DIAL},
{ALRTMENU, 'A', K_CTRL, ALERTBTN, &alerts_info, &alerts_tree, AUTO_DIAL},
{XACCMENU, 'X', K_CTRL, XACCBTN, &xacc_info, &xacc_tree, WIN_DIAL},
{TITLMENU, 'R', K_CTRL, FRAMEBTN, &frames_info, &frames_tree, AUTO_DIAL},
{FLYMENU, 'F', K_CTRL, FLYBTN, &dialog_info, &dialog_tree, FLY_DIAL},
{WINMENU, 'D', K_CTRL, WINBTN, &dialog_info, &dialog_tree, WIN_DIAL},
{MODMENU, 'M', K_CTRL, MODALBTN, &dialog_info, &dialog_tree, WIN_DIAL|MODAL},
{HELPMENU, 'H', K_CTRL, FAIL, &help_info, &help_tree, WIN_DIAL}
};

int MenuSelect(int object,int scan,int state,int button)
{
	reg MENUITEM *item=items;
	reg int index,key;

	if (object<0)
	{
		if (button<0)
		{
			/* Eintrag zu Tastatur-Ereignis ermitteln */
			key = scan_2_ascii(scan,state);
			for (index=0;index<ITEMS;index++,item++)
				if (item->shortcut==key && item->state==state)
					break;
		}
		else
			/* Eintrag zu angeklicktem Button im Hauptdialog ermitteln */
			for (index=0;index<ITEMS;index++,item++)
				if (item->button==button)
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
		/* Ansonsten gewÅnschten Dialog îffnen */
		OpenDialog(item->info,*item->tree,item->mode);

	return (TRUE);
}

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten, TastendrÅcke, Timer ), welche sowohl
 von Event_Multi() als auch von X_Form_Do() aufgerufen wird
***********************************************************************/

int Messag(XEVENT *event)
{
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	reg int used = 0;

	/* Timer-Event auswerten */
	if (ev & MU_TIMER2)
	{
		last_time = event->ev_mt2last;
		val_2_str(ob_get_text(xacc_tree,TIMEDEMO,0),(last_time-start_time)/1000);
		ob_draw_chg(&xacc_info,TIMEDEMO,NULL,FAIL,FALSE);
		used |= MU_TIMER2;
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
			menu_tnormal(menu,msg[3],1);

			/* gewÅnschte Funktion ausfÅhren */
			if (MenuSelect(msg[4],0,0,FAIL)==FALSE)
				/* Nachricht konnte nicht ausgewertet werden
				   (sollte NIE vorkommen) */
				used &= ~MU_MESAG;
			break;
		/* Applikation beenden/rÅcksetzen */
		case AP_TERM:
		case AC_CLOSE:
			ExitExample(0);
			break;
		/* Accessory îffnen (Hauptdialog îffnen) */
		case AC_OPEN:
			OpenDialog(&main_info,main_tree,WIN_DIAL);
			break;
		/* Applikation hat sich an- oder abgemeldet */
		case XACC_AV_INIT:
		case XACC_AV_EXIT:
			set_xacc_av();
			break;
		default:
		/* unbekannte Nachricht konnte nicht ausgewertet werden */
			used &= ~MU_MESAG;
		}
	}

	/* Tastatur-Ereignis auswerten */
	if (ev & MU_KEYBD)
	{
		/* gewÅnschte Funktion ausfÅhren */
		if (MenuSelect(FAIL,event->ev_mkreturn,event->ev_mmokstate,FAIL))
			used |= MU_KEYBD;	/* Tastaturereignis wurde ausgewertet */
	}

	return (used);
}

void main()
{
	/* Start-Zeit setzen */
	last_time = start_time = clock()*5;

	/* Resource-File laden und Bibliothek sowie AES und VDI initialisieren
	   MenÅ-Eintrag: "EnhancedGEM" (unter MTOS)
	   XAcc-Name:    "EnhancedGEM\0XDSC\01GEM-Library\0"
	   AV-Name:      "EXAMPLE"
	   keine spezielle AV/VA/XAcc-Nachrichtenauswertung
	*/
	switch (open_rsc("EXAMPLE.RSC","  EnhancedGEM",
	                 "EnhancedGEM\0XDSC\0"\
	                 "1GEM-Library\0",
	                 "EXAMPLE",0,0,0))
	{
		/* Resource-Datei konnte nicht geladen werden */
		case FAIL:
			form_alert(1, "[3][Resource-File not found|or not enough memory!][Cancel]");
			break;
		/* Fehler wÑhrend der Inititialisierung von AES/VDI */
		case FALSE:
			form_alert(1, "[3][Couldn't open|workstation!][Cancel]");
			break;
		case TRUE:
		{
			/* wind_update(BEG_UPDATE/END_UPDATE)-Klammerung fÅr Accessories
			   wÑhrend der Initialisierung */
			wind_update(BEG_UPDATE);

			/* Resource (ObjektbÑume) initialisieren */
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
            dial_colors(7,(colors>=16) ? YELLOW : WHITE,GREEN,RED,MAGENTA,BLUE,CYAN);

			/* Titel-Optionen setzen */
			title_options(FALSE,RED,FALSE);

            /* HÑkchen als Image fÅr Check-Boxen */
			check_image(5,NULL);

			/* Pull-Down-MenÅ anmelden */
			menu_install(menu,TRUE);

			wind_update(END_UPDATE);

			/* Falls als Programm gestartet, XAcc/AV-Info-Dialog îffnen */
			if (_app)
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
}
