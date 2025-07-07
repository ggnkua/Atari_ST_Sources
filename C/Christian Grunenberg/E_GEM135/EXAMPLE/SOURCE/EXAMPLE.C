
#include <e_gem.h>
#include <string.h>
#include "example.h"

char *title = "EnhancedGEM "VERSION;
char *version = VERSION;

/* Text fÅr die Beispiel-Alert-Box */

char *alert_text =  "NatÅrlich gibt es auch Alert-Boxen,|"
					"wobei diese bis zu 10 Zeilen Text|"
					"sowie 5 Buttons, welche Åber Hotkeys|"
					"bedient werden kînnen, enthalten dÅr-|"
					"fen.|"
					"Neben 18 vordefinierten Icons kînnen|"
					"auch benutzer-definierte Icons ver-|"
					"wendet werden.";

/* Prototypen */

void CycleCloseWindow(int mode);
void OpenDialog(DIAINFO *info,OBJECT *tree,int obj,DIAINFO *parent,int dial_mode);
void CloseDialog(DIAINFO *info);
int InitMsg(EVENT *evt);
void Messag(EVENT *event);
void ExitExample(int all);

/* Hilfetext und benîtigte Variablen/Strukturen */
extern char *help[];
extern int help_lines,line_help_h,view_help_lines;
extern USERBLK helpblk;
extern SLINFO sl_help;
boolean scroll_help;

EVENT event;

/* Zeiger auf ObjektbÑume sowie DIAINFO-Strukturen fÅr Dialoge */
OBJECT *dial_tree, *help_tree, *more_tree, *pop_tree, *info_tree, *menu;
DIAINFO dial_info, help_info, more_info, infodial_info, *ex_info;

POPUP pop = { &dial_info,0l,POPINFO,POPBTN,POPCYCLE,TRUE,TRUE };

/* Liste von Zeigern auf DIAINFO-Strukturen der geîffneten Dialoge */
DIAINFO *wins[4];
/* Anzahl der geîffneten Dialoge */
int win_cnt;

/***********************************************************************
 Alle Dialoge schlieûen sowie optional Beenden der Applikation
 (MenÅleiste lîschen, Resource freigeben, Abmeldung bei AES und VDI)
***********************************************************************/

void ExitExample(int all)
{
	/* alle geîffneten Dialoge schlieûen */
	while (--win_cnt>=0)
		close_dialog(wins[win_cnt],FALSE);

	if (all)
	{
		/* MenÅleiste entfernen */
		menu_bar(menu,0);
		/* Resource freigeben, Abmeldung bei AES und VDI */
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
/* Adressen der ObjektbÑume (Dialoge,MenÅs,Popups) ermitteln */

	rsrc_gaddr(R_TREE, MENU, &menu);
	rsrc_gaddr(R_TREE, INFODIA, &info_tree);
	rsrc_gaddr(R_TREE, DIALOG, &dial_tree);
	rsrc_gaddr(R_TREE, MOREDIA, &more_tree);
	rsrc_gaddr(R_TREE, HELPDIAL, &help_tree);
	rsrc_gaddr(R_TREE, POP, &pop_tree);
	pop.p_menu = pop_tree;

/* erweiterte Objekte sowie Images/Icons anpassen */

	fix_objects(menu,NO_SCALING);
	fix_objects(dial_tree,NO_SCALING);
	fix_objects(info_tree,DARK_SCALING);
	fix_objects(more_tree,NO_SCALING);
	fix_objects(help_tree,NO_SCALING);
	fix_objects(pop_tree,NO_SCALING);

/* Ikonifizierte Darstellung von Dialog-Fenstern unter MTOS */
	rsrc_gaddr(R_TREE, EGEMICON, &iconified);
/* Icon nicht skalieren */
	fix_objects(iconified,NO_SCALING);

/* Erstellungsdatum und Versionsnummer im Informations- und 
   Haupt-Dialog setzen */

	info_tree[DATE].ob_spec.tedinfo->te_ptext = __DATE__;
	strcpy(ob_get_text(info_tree,VERS,FALSE)+8,version);
	strcpy(ob_get_text(dial_tree,TITEL,FALSE)+27,version);

	{
		reg OBJECT *obj = help_tree + HELPVIEW;

		/* Hilfe-Dialog auf benutzerdefiniertes Objekt setzen */
		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &helpblk;

		/* Slider-Struktur und benîtigte Variablen zur Darstellung setzen  */
		line_help_h = gr_sh<<1;
		sl_help.sl_page = view_help_lines = obj->ob_height/line_help_h;
		sl_help.sl_max = help_lines;

		/* Koordinaten des Parent-Objektes anpassen */
		obj = help_tree + HELPPAR;
		obj->ob_y++;
		obj->ob_height -= 2;

		/* Slider-Objekte initialisieren */
		graf_set_slider(&sl_help,help_tree,GRAF_SET);
	}

/* Eingabe-Felder in Hauptdialog zurÅcksetzen */

	ob_get_text(dial_tree,DATEI,TRUE);
	ob_get_text(dial_tree,PFAD,TRUE);
}

/***********************************************************************
 Fensterdialog rotieren (mode==0) oder schlieûen (mode!=0) 
***********************************************************************/

void CycleCloseWindow(int mode)
{
	/* Dialog geîffnet ? */
	if (win_cnt>0)
	{
		reg int i,handle = FAIL;
		int top,dummy;

		/* Handle des obersten Fensters ermitteln */
		wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);

		/* DIAINFO-Struktur des obersten Fensterdialoges suchen */
		for (i=0;i<win_cnt;i++)
			if (wins[i]->di_flag>=WINDOW && wins[i]->di_handle==top)
			{
				/* Dialog schlieûen ? */
				if (mode)
				{
					/* Falls Hauptdialog geschlossen wird, auch alle
					   anderen Dialoge schlieûen */
					if (wins[i]==&dial_info)
						ExitExample(0);
					/* ansonsten nur obersten Dialog schlieûen */
					else
						CloseDialog(wins[i]);
				}
				/* Dialog rotieren ? */
				else if (i<(win_cnt-1))
					handle = wins[i+1]->di_handle;
				else
					handle = wins[0]->di_handle;
				break;
			}

		/* Dialog nach Rotation in Vordergrund bringen */
		if (handle>0)
			wind_set(handle,WF_TOP);
	}
}

/***********************************************************************
 Dialog îffnen und in Liste der geîffneten Dialoge eintragen bzw. falls
 der Dialog schon geîffnet ist, diesen in den Vordergrund bringen. Auûerdem
 Verwaltung der geîffneten Dialoge und Auswertung der Benutzeraktionen
***********************************************************************/

void OpenDialog(DIAINFO *info,OBJECT *tree,int obj,DIAINFO *parent,int dial_mode)
{
	reg int double_click,exit=win_cnt;

	/* Button in Åbergeordnetem Dialog zurÅcksetzen ? */
	if (parent && obj>FAIL)
	{
		/* Button deselektieren und neuzeichnen */
		ob_undostate(parent->di_tree,obj,SELECTED);
		ob_draw_chg(parent,obj,NULL,FAIL,FALSE);
	}

	switch (info->di_flag)
	{
	/* Fensterdialog bereits geîffnet ? */
	case WINDOW:
	case WIN_MODAL:
		/* Dialog in den Vordergrund holen */
		wind_set(info->di_handle,WF_TOP);
		break;
	/* Dialog geschlossen ? */
	case CLOSED:
		/* Dialog îffnen (zur Mausposition, keine Grow-Boxen) und bei Erfolg
		   in Liste eintragen */
		if (open_dialog(tree,info,title,TRUE,FALSE,dial_mode))
			wins[win_cnt++]=info;
	}

	/* Waren bereits vorher Dialoge geîffnet ? */
	if (exit>0)
		/* Ja, also wird die Verwaltung bereits an anderer Stelle Åbernommen */
		return;

	/* Verwaltung der geîffneten Dialoge und Auswertung der Benutzeraktionen */

	/* Solange Dialog geîffnet, Schleife wiederholen */
	while (win_cnt>0)
	{
		/* Auf Benutzeraktionen warten
		   exit -> angewÑhltes Objekt (Bit 15 = Doppelklick)
		   ex_info -> Zeiger auf DIAINFO-Struktur des angewÑhlten Dialogs
	    */
		exit = X_Form_Do(&ex_info, 0, InitMsg, Messag);

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

			/* Haupt-Dialog */
			if (ex_info==&dial_info)
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
					OpenDialog(&help_info,help_tree,exit,ex_info,AUTO_DIAL);
					break;
				/* Mehr-Button -> Sonstiges-Dialog îffnen */
				case MORE:
					OpenDialog(&more_info,more_tree,exit,ex_info,AUTO_DIAL);
					break;
				/* Info-Button -> Informations-Dialog îffnen */
				case INFOBTN:
					OpenDialog(&infodial_info,info_tree,exit,ex_info,AUTO_DIAL|MODAL);
					break;
				/* Suchen-Button -> Alert-Box îffnen
				   -> alle mîglichen Icons nacheinander */
				case SEARCH:
					{
						static int icon = 0;
						if (xalert(3,1,icon++,NULL,title,alert_text,"[Abbruch|Gibt's [mehr?|[Ok",InitMsg,Messag)==1)
							xalert(1,0,X_ICN_STOP,NULL,title,"Leider (noch) nicht!","[Pech",InitMsg,Messag);
					}
					break;
				/* Ansonsten Dialog schlieûen */
				default:
					CloseDialog(ex_info);
				}
			}
			/* Hilfe-Dialog */
			else if (ex_info==&help_info)
			{
				/* Slider-Objekt angewÑhlt */
				if (exit!=HELPOK)
				{
					scroll_help = TRUE;
					graf_rt_slidebox(&sl_help,exit);
					scroll_help = FALSE;
				}
				/* ansonsten Dialog schlieûen */
				else
					CloseDialog(ex_info);
			}
			/* andere Dialoge schlieûen */
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
 Initialisierungs-Routine, welche von X_Form_Do aufgerufen wird und
 die Event-Struktur setzt sowie die Ereignisse, die von der Applikation
 benîtigt werden, zurÅckgibt
***********************************************************************/

int InitMsg(EVENT *evt)
{
	/* Nachrichten und TastendrÅcke auswerten */
	evt->ev_mflags |= MU_MESAG|MU_KEYBD;
	return (MU_MESAG|MU_KEYBD);
}

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten und TastendrÅcke), welche sowohl
 von der Hauptschleife in der Funktion main() als auch von X_Form_Do()
 aufgerufen wird
***********************************************************************/

void Messag(EVENT *event)
{
	reg int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;

	/* Nachricht vom AES ? */
	if (ev & MU_MESAG)
	{
		switch (*msg)
		{
		/* MenÅeintrag angeklickt ? */
		case MN_SELECTED:
			/* MenÅeintrag deselektieren */
			menu_tnormal(menu,msg[3],1);
			switch (msg[4])
			{
			/* Infodialog îffnen */
			case INFOBOX:
				OpenDialog(&infodial_info,info_tree,0,NULL,FLY_DIAL);
				break;
			/* Applikation beenden */
			case QUIT:
				ExitExample(1);
				break;
			/* Hauptdialog îffnen */
			case OPEN:
				OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
				break;
			/* Fenster wechseln/schlieûen */
			case CYCLE:
			case CLOSE:
				CycleCloseWindow(msg[4]==CLOSE);
				break;
			/* Hilfedialog îffnen */
			case HELPMENU:
				OpenDialog(&help_info,help_tree,0,NULL,AUTO_DIAL);
				break;
			}
			break;
		/* Applikation beenden/rÅcksetzen */
		case AP_TERM:
		case AC_CLOSE:
			ExitExample(0);
			break;
		/* Accessory îffnen (Hauptdialog îffnen) */
		case AC_OPEN:
			OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
			return;
		}
	}

	/* Tastatur-Ereignis und Control-Taste gedrÅckt ? */
	if ((ev & MU_KEYBD) && (event->ev_mmokstate & K_CTRL))
	{
		switch (scan_2_ascii(event->ev_mkreturn,event->ev_mmokstate))
		{
		/* 'I' -> Infodialog îffnen */
		case 'I':
			OpenDialog(&infodial_info,info_tree,0,NULL,FLY_DIAL);
			break;
		/* 'Q' -> Applikation beenden */
		case 'Q':
			ExitExample(1);
			break;
		/* 'O' -> Hauptdialog îffnen */
		case 'O':
			OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
			break;
		/* 'W' -> Fenster wechseln */
		case 'W':
			CycleCloseWindow(FALSE);
			break;
		/* 'U' -> Fenster schlieûen */
		case 'U':
			CycleCloseWindow(TRUE);
			break;
		/* 'H' -> Hilfedialog îffnen */
		case 'H':
			OpenDialog(&help_info,help_tree,0,NULL,AUTO_DIAL);
		}
	}
}

void main()
{
	/* Resource-File laden und Bibliothek sowie AES und VDI initialisieren */
	switch (open_rsc("EXAMPLE.RSC",""))
	{
		/* Resource-Datei konnte nicht geladen werden */
		case FAIL:
			form_alert(1, "[3][EXAMPLE.RSC not found!][Cancel]");
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

			/* Hintergrundbedienung von Fensterdialogen sowie Fliegen mit nicht-
			   selektierbaren Objekten ausschalten */
			dial_options(TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE);

			wind_update(END_UPDATE);			

			/* Falls Applikation als Programm gestartet, Pull-Down-MenÅ zeichnen
			   und Hauptdialog îffnen */
			if (_app)
			{
				menu_bar(menu,1);
				OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
			}

            /* Auf Ereignis (Nachrichten/TastendrÅcke) warten und dieses auswerten */
			event.ev_mflags	= MU_MESAG|MU_KEYBD;

			for (;;)
			{
				EvntMulti(&event);
				Messag(&event);
			}
		}
	}

	/* Accessories enden nie */
	if (!_app)
		for (;;) evnt_timer(0,32000);
}
