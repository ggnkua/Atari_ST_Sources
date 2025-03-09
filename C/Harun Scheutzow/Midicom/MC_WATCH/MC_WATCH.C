#define _COOKIE_H
#include <e_gem.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "..\MC_LIB\mc_LIB.h"

#include "mc_watch.rh"
#define WM_CLOSE 22
#define AC_CLOSE 41

EVENT event;

/* Dialog-STUFF */
OBJECT *dial_tree;
DIAINFO dial_info;

syspar		mc_sys;
all_proc		mc_procs;
procs			backup;

int			available=0;

/* Liste von Zeigern auf DIAINFO-Strukturen der ge”ffneten Dialoge */
DIAINFO *wins[2];
/* Anzahl der ge”ffneten Dialoge */
int win_cnt;

void OpenDialog(DIAINFO *info,OBJECT *tree,int obj,DIAINFO *parent,int dial_mode);
void CloseDialog(DIAINFO *info);
void main_work(int exit,DIAINFO *ex_info);


void FULL_EXIT(int all)
{
	/* alle ge”ffneten Dialoge schliežen */
	while (--win_cnt>=0)
		close_dialog(wins[win_cnt],FALSE);

	if (all)
	{
		/* Resource freigeben, Abmeldung bei AES und VDI */
		close_rsc();
		/* Programm beenden */
		exit(0);
	}

	win_cnt=0;
}

void	set_parms(void)
{
char	*hlp;
	if (memcmp(backup,mc_procs,sizeof(procs)))
	{
		memcpy(backup,mc_procs,sizeof(procs));
		hlp=ob_get_text(dial_tree,NAME0,FALSE);
		if (strlen((*mc_procs)[0].r_name))
			strcpy(hlp,(*mc_procs)[0].r_name);
		ob_set_text(dial_tree,NAME0,hlp);

		hlp=ob_get_text(dial_tree,NAME1,FALSE);
		if (strlen((*mc_procs)[1].r_name))
			strcpy(hlp,(*mc_procs)[1].r_name);
		ob_set_text(dial_tree,NAME1,hlp);

		hlp=ob_get_text(dial_tree,NAME2,FALSE);
		if (strlen((*mc_procs)[2].r_name))
			strcpy(hlp,(*mc_procs)[2].r_name);
		ob_set_text(dial_tree,NAME2,hlp);

		hlp=ob_get_text(dial_tree,NAME3,FALSE);
		if (strlen((*mc_procs)[3].r_name))
			strcpy(hlp,(*mc_procs)[3].r_name);
		ob_set_text(dial_tree,NAME3,hlp);

		hlp=ob_get_text(dial_tree,NAME4,FALSE);
		if (strlen((*mc_procs)[4].r_name))
			strcpy(hlp,(*mc_procs)[4].r_name);
		ob_set_text(dial_tree,NAME4,hlp);

		hlp=ob_get_text(dial_tree,NAME5,FALSE);
		if (strlen((*mc_procs)[5].r_name))
			strcpy(hlp,(*mc_procs)[5].r_name);
		ob_set_text(dial_tree,NAME5,hlp);

		hlp=ob_get_text(dial_tree,NAME6,FALSE);
		if (strlen((*mc_procs)[6].r_name))
			strcpy(hlp,(*mc_procs)[6].r_name);
		ob_set_text(dial_tree,NAME6,hlp);
	
		hlp=ob_get_text(dial_tree,P01,FALSE);
		if (strlen((*mc_procs)[0].my_name[0]))
			strcpy(hlp,(*mc_procs)[0].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P01,hlp);
	
		hlp=ob_get_text(dial_tree,P02,FALSE);
		if (strlen((*mc_procs)[0].my_name[1]))
			strcpy(hlp,(*mc_procs)[0].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P02,hlp);
	
		hlp=ob_get_text(dial_tree,P03,FALSE);
		if (strlen((*mc_procs)[0].my_name[2]))
			strcpy(hlp,(*mc_procs)[0].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P03,hlp);
	
		hlp=ob_get_text(dial_tree,P04,FALSE);
		if (strlen((*mc_procs)[0].my_name[3]))
			strcpy(hlp,(*mc_procs)[0].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P04,hlp);
	
		hlp=ob_get_text(dial_tree,P05,FALSE);
		if (strlen((*mc_procs)[0].my_name[4]))
			strcpy(hlp,(*mc_procs)[0].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P05,hlp);
	
		hlp=ob_get_text(dial_tree,P06,FALSE);
		if (strlen((*mc_procs)[0].my_name[5]))
			strcpy(hlp,(*mc_procs)[0].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P06,hlp);
	
		hlp=ob_get_text(dial_tree,P11,FALSE);
		if (strlen((*mc_procs)[1].my_name[0]))
			strcpy(hlp,(*mc_procs)[1].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P11,hlp);
	
		hlp=ob_get_text(dial_tree,P12,FALSE);
		if (strlen((*mc_procs)[1].my_name[1]))
			strcpy(hlp,(*mc_procs)[1].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P12,hlp);
	
		hlp=ob_get_text(dial_tree,P13,FALSE);
		if (strlen((*mc_procs)[1].my_name[2]))
			strcpy(hlp,(*mc_procs)[1].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P13,hlp);
	
		hlp=ob_get_text(dial_tree,P14,FALSE);
		if (strlen((*mc_procs)[1].my_name[3]))
			strcpy(hlp,(*mc_procs)[1].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P14,hlp);
	
		hlp=ob_get_text(dial_tree,P15,FALSE);
		if (strlen((*mc_procs)[1].my_name[4]))
			strcpy(hlp,(*mc_procs)[1].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P15,hlp);
	
		hlp=ob_get_text(dial_tree,P16,FALSE);
		if (strlen((*mc_procs)[1].my_name[5]))
			strcpy(hlp,(*mc_procs)[1].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P16,hlp);
	
		hlp=ob_get_text(dial_tree,P21,FALSE);
		if (strlen((*mc_procs)[2].my_name[0]))
			strcpy(hlp,(*mc_procs)[2].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P21,hlp);
	
		hlp=ob_get_text(dial_tree,P22,FALSE);
		if (strlen((*mc_procs)[2].my_name[1]))
			strcpy(hlp,(*mc_procs)[2].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P22,hlp);
	
		hlp=ob_get_text(dial_tree,P23,FALSE);
		if (strlen((*mc_procs)[2].my_name[2]))
			strcpy(hlp,(*mc_procs)[2].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P23,hlp);
	
		hlp=ob_get_text(dial_tree,P24,FALSE);
		if (strlen((*mc_procs)[2].my_name[3]))
			strcpy(hlp,(*mc_procs)[2].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P24,hlp);
	
		hlp=ob_get_text(dial_tree,P25,FALSE);
		if (strlen((*mc_procs)[2].my_name[4]))
			strcpy(hlp,(*mc_procs)[2].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P25,hlp);
	
		hlp=ob_get_text(dial_tree,P26,FALSE);
		if (strlen((*mc_procs)[2].my_name[5]))
			strcpy(hlp,(*mc_procs)[2].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P26,hlp);
	
		hlp=ob_get_text(dial_tree,P31,FALSE);
		if (strlen((*mc_procs)[3].my_name[0]))
			strcpy(hlp,(*mc_procs)[3].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P31,hlp);
		
		hlp=ob_get_text(dial_tree,P32,FALSE);
		if (strlen((*mc_procs)[3].my_name[1]))
			strcpy(hlp,(*mc_procs)[3].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P32,hlp);
	
		hlp=ob_get_text(dial_tree,P33,FALSE);
		if (strlen((*mc_procs)[3].my_name[2]))
			strcpy(hlp,(*mc_procs)[3].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P33,hlp);
	
		hlp=ob_get_text(dial_tree,P34,FALSE);
		if (strlen((*mc_procs)[3].my_name[3]))
			strcpy(hlp,(*mc_procs)[3].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P34,hlp);
	
		hlp=ob_get_text(dial_tree,P35,FALSE);
		if (strlen((*mc_procs)[3].my_name[4]))
			strcpy(hlp,(*mc_procs)[3].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P35,hlp);
	
		hlp=ob_get_text(dial_tree,P36,FALSE);
		if (strlen((*mc_procs)[3].my_name[5]))
			strcpy(hlp,(*mc_procs)[3].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P36,hlp);

		hlp=ob_get_text(dial_tree,P41,FALSE);
		if (strlen((*mc_procs)[4].my_name[0]))
			strcpy(hlp,(*mc_procs)[4].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P41,hlp);
	
		hlp=ob_get_text(dial_tree,P42,FALSE);
		if (strlen((*mc_procs)[4].my_name[1]))
			strcpy(hlp,(*mc_procs)[4].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P42,hlp);
	
		hlp=ob_get_text(dial_tree,P43,FALSE);
		if (strlen((*mc_procs)[4].my_name[2]))
			strcpy(hlp,(*mc_procs)[4].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P43,hlp);
	
		hlp=ob_get_text(dial_tree,P44,FALSE);
		if (strlen((*mc_procs)[4].my_name[3]))
			strcpy(hlp,(*mc_procs)[4].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P44,hlp);
	
		hlp=ob_get_text(dial_tree,P45,FALSE);
		if (strlen((*mc_procs)[4].my_name[4]))
			strcpy(hlp,(*mc_procs)[4].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P45,hlp);
	
		hlp=ob_get_text(dial_tree,P46,FALSE);
		if (strlen((*mc_procs)[4].my_name[5]))
			strcpy(hlp,(*mc_procs)[4].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P46,hlp);
	
		hlp=ob_get_text(dial_tree,P51,FALSE);
		if (strlen((*mc_procs)[5].my_name[0]))
			strcpy(hlp,(*mc_procs)[5].my_name[0]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P51,hlp);
		
		hlp=ob_get_text(dial_tree,P52,FALSE);
		if (strlen((*mc_procs)[5].my_name[1]))
			strcpy(hlp,(*mc_procs)[5].my_name[1]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P52,hlp);
	
		hlp=ob_get_text(dial_tree,P53,FALSE);
		if (strlen((*mc_procs)[5].my_name[2]))
			strcpy(hlp,(*mc_procs)[5].my_name[2]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P53,hlp);
	
		hlp=ob_get_text(dial_tree,P54,FALSE);
		if (strlen((*mc_procs)[5].my_name[3]))
			strcpy(hlp,(*mc_procs)[5].my_name[3]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P54,hlp);
	
		hlp=ob_get_text(dial_tree,P55,FALSE);
		if (strlen((*mc_procs)[5].my_name[4]))
			strcpy(hlp,(*mc_procs)[5].my_name[4]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P55,hlp);
		
		hlp=ob_get_text(dial_tree,P56,FALSE);
		if (strlen((*mc_procs)[5].my_name[5]))
			strcpy(hlp,(*mc_procs)[5].my_name[5]);
		else
			strcpy(hlp,"-- leer --");
		ob_set_text(dial_tree,P56,hlp);

		hlp=ob_get_text(dial_tree,ID,FALSE);
		sprintf(hlp,"%d",mc_sys->my_num);
		ob_set_text(dial_tree,ID,hlp);

		ob_draw_chg(&dial_info,ANZEIGE,NULL,FAIL,FALSE);
	}
}


void init_resource(void)
{
/* Adressen der Objektb„ume (Dialoge,Mens,Popups) ermitteln */

	rsrc_gaddr(R_TREE, ANZEIGE, &dial_tree);

/* erweiterte Objekte sowie Images/Icons anpassen */

	fix_objects(dial_tree,NO_SCALING);

}

/***********************************************************************
 Initialisierungs-Routine, welche von X_Form_Do aufgerufen wird und
 die Event-Struktur setzt sowie die Ereignisse, die von der Applikation
 ben”tigt werden, zurckgibt
***********************************************************************/

int InitMsg(EVENT *evt)
{
	/* Nachrichten und Tastendrcke auswerten */
	evt->ev_mtlocount=300;
	evt->ev_mthicount=0;
	evt->ev_mflags |= MU_MESAG|MU_TIMER;
	return (MU_MESAG|MU_TIMER);
}


/***********************************************************************
 Ereignisauswertung (AES-Nachrichten und Tastendrcke), welche sowohl
 von der Hauptschleife in der Funktion main() als auch von X_Form_Do()
 aufgerufen wird
***********************************************************************/

void Messag(EVENT *event)
{
	register int ev = event->ev_mwich,*msg = event->ev_mmgpbuf;
	/* Nachricht vom AES ? */
	if (ev & MU_MESAG)
	{
		switch (*msg)
		{
		case AP_TERM:
		case AC_CLOSE:
			FULL_EXIT(0);
			break;
		/* Accessory ”ffnen (Hauptdialog ”ffnen) */
		case AC_OPEN:
			available=get_mc_sys(&mc_sys,&mc_procs);
			set_parms();
			OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
			return;
		}
	}
	if (ev & MU_TIMER) set_parms();
}

void OpenDialog(DIAINFO *info,OBJECT *tree,int obj,DIAINFO *parent,int dial_mode)
{
register	int 	double_click,exit=win_cnt;
			DIAINFO *ex_info;

	/* Button in bergeordnetem Dialog zurcksetzen ? */
	if (parent && obj>FAIL)
	{
		/* Button deselektieren und neuzeichnen */
		ob_undostate(parent->di_tree,obj,SELECTED);
		ob_draw_chg(parent,obj,NULL,FAIL,FALSE);
	}

	switch (info->di_flag)
	{
	/* Fensterdialog bereits ge”ffnet ? */
	case WINDOW:
	case WIN_MODAL:
		/* Dialog in den Vordergrund holen */
		wind_set(info->di_handle,WF_TOP);
		break;
	/* Dialog geschlossen ? */
	case CLOSED:
		/* Dialog ”ffnen (zur Mausposition, keine Grow-Boxen) und bei Erfolg
		   in Liste eintragen */
		if (open_dialog(tree,info,"MIDI_COM Prozess-Kontrolle",TRUE,FALSE,dial_mode))
			wins[win_cnt++]=info;
	}

	/* Waren bereits vorher Dialoge ge”ffnet ? */
	if (exit>0)
		/* Ja, also wird die Verwaltung bereits an anderer Stelle bernommen */
		return;

	/* Verwaltung der ge”ffneten Dialoge und Auswertung der Benutzeraktionen */

	/* Solange Dialog ge”ffnet, Schleife wiederholen */
	while (win_cnt>0)
	{
		/* Auf Benutzeraktionen warten
		   exit -> angew„hltes Objekt (Bit 15 = Doppelklick)
		   ex_info -> Zeiger auf DIAINFO-Struktur des angew„hlten Dialogs
	    */
		exit = X_Form_Do(&ex_info, 0, InitMsg, Messag);

		/* Fenster-Closer */
		if (exit == W_CLOSED)
			/* Dialog schliežen */
			CloseDialog(ex_info);
	}
}

/***********************************************************************
 Dialog schliežen und aus Liste der ge”ffneten Dialoge entfernen
***********************************************************************/

void CloseDialog(DIAINFO *info)
{
	/* Dialog ge”ffnet ? */
	if (info->di_flag>CLOSED)
	{
		int i;

		/* Dialog schliežen ohne Shrink-Box */
		close_dialog(info,FALSE);

		/* Dialog in Liste suchen und entfernen */
		for (i=0;i<win_cnt;i++)
			if (wins[i]==info)
				break;

		for (win_cnt--;i<win_cnt;i++)
			wins[i] = wins[i+1];
	}
}

void main_work(int exit,DIAINFO *ex_info)
{
	switch(exit)
	{
	default:
	/* Resource freigeben, Abmeldung bei AES und VDI */
		FULL_EXIT(TRUE);
	}
}


int main(void)
{
	/* Resource-File laden und Bibliothek sowie AES und VDI initialisieren */
	switch (open_rsc("MC_watch.RSC","  MC_Watch"))
	{
		/* Resource-Datei konnte nicht geladen werden */
		case FAIL:
			form_alert(1, "[3][MCCONTR.RSC not found!][Cancel]");
			break;
		/* Fehler w„hrend der Inititialisierung von AES/VDI */
		case FALSE:
			form_alert(1, "[3][Couldn't open|workstation!][Cancel]");
			break;
		case TRUE:
		{
			/* wind_update(BEG_UPDATE/END_UPDATE)-Klammerung fr Accessories
			   w„hrend der Initialisierung */
			wind_update(BEG_UPDATE);

			/* Resource (Objektb„ume) initialisieren */
			init_resource();

			/* Hintergrundbedienung von Fensterdialogen sowie Fliegen mit nicht-
			   selektierbaren Objekten ausschalten */
			dial_options(TRUE,TRUE,TRUE,TRUE,FALSE,FALSE);

			wind_update(END_UPDATE);

			/* Falls Applikation als Programm gestartet, Pull-Down-Men zeichnen
			   und Hauptdialog ”ffnen */
			if (_app)
			{
				available=get_mc_sys(&mc_sys,&mc_procs);
				set_parms();
				OpenDialog(&dial_info,dial_tree,0,NULL,AUTO_DIAL);
				FULL_EXIT(TRUE);
			}
            /* Auf Ereignis (Nachrichten/Tastendrcke) warten und dieses auswerten */
			event.ev_mflags	= MU_MESAG;
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
