/*
*	Object Exchange Protocol Demoprogramm 0.71
*
*	énderungen:
*	 31.01.1995	al - Ersterstellung
*	 01.02.1995	al - Debugging
*	 11.02.1995	al - Debugging
*	 18.02.1995	al - Source nach Rev. 0.5 geÑndert
*	 28.02.1995	al - Source nach Rev. 0.6 geÑndert
*	 03.03.1995	al - Globalen OEPD-Buffer implementiert
*	 30.03.1995	al - Anpassung an OLGA/OEP-Initialisierung
*	 04.04.1995	al - Source nach Rev. 0.7 geÑndert
*	 29.05.1995	al - geringfÅgige öberarbeitung des Sources
*
*	(c) 1995 Alexander Lorenz
*/

#include <tos.h>
#include <aes.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include "demo.h"
#include "util.h"
#include "window.h"
#include "dialogs.h"
#include "oep.h"
#include "dd.h"
#include "oep_demo.h"
#include "dragdrop.h"


WORD apid;						/* AES-ID unserer Applikation */
WORD rsc;						/* TRUE = Resource geladen */

WORD gem_ver;					/* AES-Version */
WORD multi;						/* TRUE = Multitasking-OS */

WORD events, evnt_art;			/* Variablen fÅr AES-Events */
WORD mx, my, button, clicks;
WORD k_state, key;

WORD wind_hdl = 0;				/* Windowhandle */
BYTE wind_title[10];			/* Buffer fÅr Fenstertitel */

OBJECT *menue;					/* Adresse des MenÅbaums */

DATAINFO datainfo;				/* Struktur fÅr Datum/Zeit-Objekt */

OEPD_HEADER oepd_global;		/* globale OEPD-Struktur anlegen */
WORD apid_oepdcoming;			/* OEPD-Daten kamen von dieser APP */
OEP oep;						/* globale OEP-Struktur anlegen */



VOID main()
{
	WORD msg[8];

	/*
	*	Initialisieren
	*/

	init();


	/*
	*	MenÅzeile anmelden, Desk-Eintrag Ñndern, Mausform setzen
	*/
	
	wind_update(BEG_UPDATE);
	menu_bar(menue, 1);
	if (gem_ver >= 0x400)
		menu_register(apid, "  OEP-Demo ");

	graf_mouse(ARROW, 0L);
	wind_update(END_UPDATE);


	/*
	*	Hauptschleife
	*/
	
	events = MU_MESAG|MU_BUTTON;
	
	while (TRUE)
	{
		msg[0] = 0;

		evnt_art = evnt_multi(events, 261, 3, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					msg, 0, 0, &mx, &my, &button,
					&k_state, &key, &clicks);

		if (evnt_art & MU_MESAG)
		{
			messages(msg);
		}
		
		if (evnt_art & MU_BUTTON)
		{
			m_button(clicks, mx, my);
		}
	}
	
}


VOID init()
{
	/*
	*	Programminit
	*/
	
	apid = appl_init();
	if (apid < 0)
	{
		exit(1);
	}
	else
	{
		gem_ver = _GemParBlk.global[0];
	
		if (_GemParBlk.global[1] == 1)
			multi = FALSE;
		else
			multi = TRUE;
	}


	/*
	*	Resource laden
	*/
	
	if (rsrc_load("OEP_DEMO.RSC") == 0)
	{
		rsc = FALSE;
		ende();
	}
	else
	{
		rsc = TRUE;
	}
	

	rsrc_gaddr(R_TREE, MENUE, &menue);	/* Adresse des MenÅs ermitteln */

	init_datainfo(&datainfo);	/* Datum/Zeit eintragen */
	fill_datainfo(&datainfo);	/* Daten in interne Struktur Åbernehmen */


	/*
	*	Object Exchange Protocol Init
	*/
	
	oep.apid = apid;				/* Struktur initialisieren */
	oep.manager = NO_MANAGER;		/* kein Manager bekannt */
	oep.ok = FALSE;					/* OEP ist nicht verfÅgbar */
	oep.version = 0;
	oep.config = 0;

	oep.manager = ole_manager("OEPMANGR", "OEPMANAGER");

	if (oep.manager != NO_MANAGER)
		ole_init(oep.manager);		/* Wir melden uns beim Manager an */
}


VOID ende()
{
	/*
	*	Beim OLE-Manager abmelden
	*/
	
	if (oep.manager != NO_MANAGER)
		ole_exit(oep.manager);

	
	/*
	*	MenÅzeile abmelden, Resource freigeben
	*/
	
	if (rsc == TRUE)
	{
		wind_update(BEG_UPDATE);
		menu_bar(menue, 0);
		wind_update(END_UPDATE);
	
		rsrc_free();
		menue = NULL;
	}
	
	
	/*
	*	Fenster freigeben
	*/
	
	if (wind_hdl > 0)
		win_close(wind_hdl, NULL);
	

	/*
	*	Dem AES tschÅss sagen...
	*/
	
	appl_exit();
	

	/*
	*	...und wech.
	*/
	
	exit(0);
}


VOID menu(WORD msg[])
{
	/*
	*	Welcher MenÅeintrag wurde denn gewÑhlt?
	*/

	BYTE *c;
	
	
	if (msg[4] == M_ABOUT)
	{
		/*
		*	About-Dialogbox
		*/
		
		about();
	}
	else if (msg[4] == M_OPEN)
	{
		/*
		*	Fenster îffnen
		*/
		
		if (wind_hdl == 0)
		{
			sprintf(wind_title, "Demo %d", apid);
			wind_hdl = win_open(wind_title, &datainfo);
		}
		else
			win_top(wind_hdl);
	}
	else if (msg[4] == M_CLOSE)
	{
		/*
		*	Fenster schlieûen
		*/
		
		if (wind_hdl > 0)
		{
			win_close(wind_hdl, &datainfo);
			wind_hdl = 0;
		}
	}
	else if (msg[4] == M_UPDATE)
	{
		/*
		*	Aktualisieren
		*/
		
		if (oep.manager == NO_MANAGER || oep.ok == FALSE || multi == FALSE)
		{
			rsrc_gaddr(R_STRING, NOMANAGER, &c);
			form_alert(1, c);
		}
		else
		{
			if (datainfo.cid != 0L)
				oep_update(oep.manager, OEP_OBJECT, datainfo.cid, apid);
		}
	}
	else if (msg[4] == M_QUIT)
	{
		/*
		*	Ende
		*/
		
		ende();
	}
	
	
	/*
	*	MenÅtitel wieder normal darstellen
	*/
	
	if (msg[4] > 0)
		menu_tnormal(menue, msg[3], 1);
}


VOID messages(int msg[])
{
	/*
	*	Eventmessage auswerten
	*/
	
	WORD flg;
	LONG link, ret;
	OEPD_HEADER oepd;
	OBJECT *data;
	

	switch(msg[0])
	{
		case MN_SELECTED:
			menu(msg);
			break;

		case WM_REDRAW:
			redraw(msg[3], msg[4], msg[5], msg[6], msg[7]);
			break;

		case WM_TOPPED:
			win_top(msg[3]);
			break;

		case WM_CLOSED:
			if (wind_hdl > 0 && msg[3] == wind_hdl)
			{
				win_close(wind_hdl, &datainfo);
				wind_hdl = 0;
			}
			break;

		case WM_MOVED:
			win_move(msg[3], msg[4], msg[5], msg[6], msg[7]);
			break;

		case WM_BOTTOMED:
			win_bottom(msg[3]);
			break;

		case AP_TERM:
			ende();
			break;

		case AP_DRAGDROP:
			dd_rec(msg, &datainfo);
			rsrc_gaddr(R_TREE, DATA, &data);
			if (strncmp(data[DATA_DT].ob_spec.tedinfo->te_ptext, datainfo.string, 14L) != 0)
			{
				strncpy(data[DATA_DT].ob_spec.tedinfo->te_ptext, datainfo.string, 14L);
				win_draw(wind_hdl);
			}
			break;

		case OLE_INIT:
			/*
			*	Wer uns diese Message schickt, hat wohl ein Problem...
			*	(oder sind wir vielleicht ein OLE-Manager?)
			*/
			break;
			
		case OLE_EXIT:
			/*
			*	Ein OLE-Manager verlÑsst das System. Sollte es unser OEP-Manager
			*	sein, mÅssen wir die Manager-ID in der OEP-Struktur lîschen.
			*/

			if (oep.manager == msg[1])
			{
				oep.manager = NO_MANAGER;
				oep.ok = FALSE;
			}
			break;

		case OLE_NEW:
			/*
			*	Ein OLE-Manager wurde (nach-)gestartet. Wenn er OEP unterstÅtzt,
			*	melden wir uns bei ihm an.
			*/
			
			if ((msg[5] & OL_OEP) && ((oep.manager == NO_MANAGER) || (oep.manager != msg[1])))
			{
				ole_init(msg[1]);			/* Wir melden uns beim neuen Manager an */

				/*
				*	Wir Åbernehmen hier _nicht_ die AES-ID, denn der neue Manager
				*	kînnte fÅr uns keinen Speicherplatz haben (oder sonst was).
				*	Also bleiben wir erst mal beim bekannten, bis der neue sich
				*	mit OEP_CONFIG bei uns meldet.
				*/
			}
			break;

		case OEP_CONFIG:
			oep.config = msg[3];		/* Konfiguration Åbernehmen */
			oep.version = msg[5];		/* Versionsnummer Åbernehmen */
			oep.ok = TRUE;				/* Der Manager kann wirklich OEP */

			if (oep.manager == NO_MANAGER || oep.manager != msg[1])
			{
				if (oep.manager != NO_MANAGER)
					ole_exit(oep.manager);	/* Beim alten Manager abmelden */
				
				oep.manager = msg[1];		/* AES-ID des neuen Managers Åbernehmen */

				/*
				*	BEMERKUNG: An dieser Stelle kînnten Protokoll-spezifische 
				*	MenÅpunkte (z.B. "Aktualisieren") zugÑnglich gemacht werden!
				*/
											
				link_doc(&datainfo);		/* Benutzte Objekthandle anmelden */
			}
			break;

		case OEP_LINK:
			/*
			*	Welches Objekt ist's denn?
			*/
			
			link = (msg[4] << 16) | msg[5];

			if ((link > 0L) && (link == datainfo.cid))
			{
				/*
				*	Das ist unser Objekt...
				*/
				
				if (msg[3] & OEP_LINK_FREE)
				{
					/*
					*	Wir sollen den Link vergessen,
					*	also tun wir's auch...
					*/
					
					unlink_doc(&datainfo);
					datainfo.id = 0L;
					datainfo.cid = 0L;
				}
			}
			break;

		case OEP_DATA:
			/*
			*	Welches Objekt ist's denn?
			*/

			link = (msg[4] << 16) | msg[5];

			if ((link > 0L) && (link == datainfo.cid) && (msg[3] & OEP_OBJECT))
			{
				/*
				*	Das angeforderte Objekt bearbeiten wir momentan...
				*/
				
				flg = 1;
			}
			else
			{
				/*
				*	Das angeforderte Objekt kennen wir nicht,
				*	oder es wurde kein Objekt angefordert
				*/

				flg = -1;
			}
			
			if ((link == 0L && flg == -1) || (link > 0L && flg != -1))
			{
				oepd.type = 0;
				
				oep_filldata(&datainfo, &oepd);
				fill_datainfo(&datainfo);
				
				if (flg == -1)
				{
					oepd.type &= ~OEP_OBJECT;
					ret = oep_senddata(msg[1], &oepd);
				}
				else
				{
					oepd.type |= OEP_OBJECT;
					ret = oep_senddata(msg[1], &oepd);
				
					if (ret != -2L)
						ret = (long) dd_send(msg[1], 0, -1, -1, ".TXT", (char *) &datainfo.string, 14L);
				}
			}
			break;

		case OEP_UPDATE:
			/*
			*	Welches Objekt ist's denn?
			*/
			
			link = (msg[4] << 16) | msg[5];	/* Welches Objekt wurde verÑndert? */
			
			if (link != 0L && link == datainfo.cid)
			{
				/*
				*	Das Objekt bearbeiten wir momentan,
				*	also fordern wir die neuen/verÑnderten Daten an...
				*/
				
				oep_data(msg[6], msg[3], link);
			}
			break;

		default:
			break;
	}
}


VOID redraw(int handle, int x, int y, int w, int h)
{
	/*
	*	Fensterinhalt zeichnen
	*/
	
	GRECT full, box, area;

	area.g_x = x;	/* Bereich der neu gezeichnet werden soll */
	area.g_y = y;
	area.g_w = w;
	area.g_h = h;

	wind_update(BEG_UPDATE);

	wind_get(DESK, WF_WORKXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
	wind_get(handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	while(box.g_w && box.g_h)
	{
		if (rc_intersect(&full, &box))
		{
			if (rc_intersect(&area, &box))
				win_redraw(handle, box.g_x, box.g_y, box.g_w, box.g_h);
		}
		
		wind_get(handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}

	wind_update(END_UPDATE);
}


VOID m_button(WORD clicks, WORD mx, WORD my)
{
	/*
	*	Mausklick-Routine
	*/
	
	WORD handle, winid, owner, x, y, w, h;
	WORD button, k_state, p1, p2, p3, p4;
	
	
	handle = wind_find(mx, my);

	if (handle > 0 && handle == wind_hdl)
	{
		/*
		*	Klick auf unser Fenster - Maustaste noch gedrÅckt?
		*/
		
		graf_mkstate(&x, &y, &button, &k_state);
		
		if (button != 0)
		{
			/*
			*	Box verschieben
			*/
			
			wind_update(BEG_UPDATE);
			wind_get(DESK, WF_WORKXYWH, &p1, &p2, &p3, &p4);
			wind_get(handle, WF_WORKXYWH, &x, &y, &w, &h);
			graf_dragbox(w, h, x, y, p1, p2, p3, p4, &x, &y);
			graf_mkstate(&mx, &my, &button, &k_state);
			wind_update(END_UPDATE);
			
			/*
			*	Welches Fenster liegt denn da?
			*/
			
			winid = wind_find(mx, my);
			
			if (winid >= 0)
			{
				/*
				*	Und wem gehîrt das Fenster?
				*/
				
				wind_get(winid, WF_OWNER, &owner, &x, &x, &x);

				if (owner >= 0)
				{
					/*
					*	Drag&Drop durchfÅhren
					*/
					
					make_dd(owner, winid, mx, my);
				}
			}
		}
		else
		{
			if (clicks >= 2)
			{
				/*
				*	...war mindestens ein Doppelklick
				*/
				
				fill_datainfo(&datainfo);
				init_change(&datainfo);

				if (change() == 1 && wind_hdl > 0)
					win_draw(wind_hdl);
			}
		}
	}
}


VOID make_dd(WORD target_apid, WORD winid, WORD mx, WORD my)
{
	/*
	*	Objekthandle anfordern und Drag&Drop durchfÅhren
	*/
	
	LONG link, ret;
	OEPD_HEADER oepd;

	link = 0L;
	oepd.type = 0;

	if (target_apid != apid)
	{
		/*
		*	D&D darf nicht an uns selbst gehen...
		*/
		
		if (oep.manager != NO_MANAGER)
		{
			/*
			*	OEP-Manager vorhanden
			*/
			
			if (datainfo.id <= 0L)
			{
				/*
				*	Neues Objekthandle anfordern
				*/
				
				datainfo.id = 0L;
				datainfo.date = Tgetdate();
				datainfo.time = Tgettime();
				datainfo.systime = clock();
				oep_filldata(&datainfo, &oepd);
				fill_datainfo(&datainfo);
				oep_filldata(NULL, &oepd);
				oepd.type |= OEP_OBNEW;
	
				link = oep_senddata(oep.manager, &oepd);
				datainfo.id = link;
				datainfo.cid = link;
			}
			else
			{
				/*
				*	Bestehendes Objekthandle konvertieren
				*/
				
				oep_filldata(&datainfo, &oepd);
				fill_datainfo(&datainfo);
				oepd.type |= OEP_OBCONV;
	
				link = oep_senddata(oep.manager, &oepd);
				datainfo.cid = link;
			}
		}
	
		if (link > 0L)
		{
			/*
			*	OEPD an Zielapp. senden
			*/
			
			oepd.type &= ~OEP_OBNEW;
			oepd.type &= ~OEP_OBCONV;
			oep_filldata(&datainfo, &oepd);
			oepd.type |= OEP_OBJECT;
	
			ret = oep_senddata(target_apid, &oepd);
		}
		else
			ret = 0L;
		
	
		if (ret != -2)
		{
			/*
			*	Wenn kein Timeout eintrat -> Daten senden
			*/
			
			ret = (LONG) dd_send(target_apid, winid, mx, my, ".TXT", (char *) &datainfo.string, 14L);
		}
	}
}


VOID init_change(DATAINFO *datainfo)
{
	/*
	*	Interne Datenstruktur in Dialogbox kopieren
	*/
	
	OBJECT *change;
	
	rsrc_gaddr(R_TREE, CHANGE, &change);
	
	strcpy(change[CHANGE_DT].ob_spec.tedinfo->te_ptext, datainfo->string);
}


void init_datainfo(DATAINFO *datainfo)
{
	/*
	*	Datum/Zeit in interne Datenstruktur eintragen
	*/
	
	BYTE string[10];
	UWORD dummy;
	OBJECT *data;
	
	rsrc_gaddr(R_TREE, DATA, &data);
	
	strcpy(datainfo->string, data[DATA_DT].ob_spec.tedinfo->te_ptext);

	dummy = Tgetdate();
	sprintf(string, "%02d%02d%d", dummy & 0x1F, (dummy >> 5) & 0xF, ((dummy >> 9) & 0xEF) + 1980);
	strcpy(datainfo->string, string);

	dummy = Tgettime();
	sprintf(string, "%02d%02d%02d", (dummy >> 11) & 0x1F, (dummy >> 5) & 0x3F, (dummy & 0x1F) * 2);
	strcat(datainfo->string, string);

	strcpy(data[DATA_DT].ob_spec.tedinfo->te_ptext, datainfo->string);
}


VOID fill_datainfo(DATAINFO *datainfo)
{
	/*
	*	Daten aus Dialogbox in interne Datenstruktur Åbernehmen
	*/
	
	OBJECT *data;
	
	rsrc_gaddr(R_TREE, DATA, &data);
	
	strcpy(datainfo->string, data[DATA_DT].ob_spec.tedinfo->te_ptext);
}
