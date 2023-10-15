/* ---------------------------------------------------------------------- */
/* Demoprogramm zur PowerGEM Library                                      */
/* von Boris Sander														  */
/* Copyright (c) 1992/93 by ICP - Innovativ Computer-Presse GmbH & Co. KG */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <aes.h>
#include <scancode.h>
#include "powergem.h"
#include "demo.h"
#include "header.h"

/* Prototyp -------------------------------------------------------------- */
void main(void);

int handle; /* VDI-Handle von PowerGEM */

/* ---------------------------------------------------------------------- */
/* Hauptinitialisierung													  */
/* ---------------------------------------------------------------------- */
void main(void)
{
	handle = get_handle();     /* VDI-Handle von PowerGEM bernehmen */

	if (init_powergem("DEMO.RSC", MENU))  /* PowerGEM initialisieren */
	{
		init_text();       /* Textbuffer fr Textfenster vorbereiten */
		set_button_fnc(draw_desk_box);   /* Aktion bei Desktop-Klick */

		/* Funktionen des Mens anmelden ------------------ */
		menu_action(POWERGEM, MENINFO,  CNTRL_I, show_info); 
		menu_action(TEST,     DODIAL,   CNTRL_D, show_dial);
		menu_action(TEST,     SETTIMER, CNTRL_T, show_beep);
		menu_action(TEST,     DOGRAFIK, CNTRL_G, show_grafik);
		menu_action(TEST,     DOTEXT,   ALT_T,   show_text);
		menu_action(TEST,     QUIT,     CNTRL_Q, exit_prg);

		msg_action(OWNMSG, empfaenger); /* Neuer Nachrichtentyp anmelden */

		/* Zu berwachende Ereignisse festlegen -> multi */
		watch_events(MU_MESAG|MU_BUTTON|MU_KEYBD, 2,1,1); 
		graf_mouse(ARROW, NULL);
		multi(); 
	}
}

/* ---------------------------------------------------------------------- */
/* Gummiband auf Desktop aufziehen   									  */
/* ---------------------------------------------------------------------- */
void draw_desk_box(int x, int y, int mb, int ks)
{
	if (mb == 1 && ks == 0)
		graf_rubberbox(x,y,10,10,&x,&y);
}

/* ---------------------------------------------------------------------- */
/* Gummiband zeichnen (nur wenn Maus innerhalb des Fensters win)          */
/* ---------------------------------------------------------------------- */
void draw_win_box(struct WINDOW *win, int x, int y, int mb, int ks)
{
	if ((win) && mb == 1 && ks == 0)
		graf_rubberbox(x,y,10,10,&x,&y);
}

/* ---------------------------------------------------------------------- */
/* Programm verlassen													  */
/* ---------------------------------------------------------------------- */
void exit_prg(void)
{
	if (form_alert(2, "[2][Soll das Programm wirklich|beendet werden?]"
							"[Ja|Nein]") == 1)
		exit_powergem();  /* PowerGEM abmelden */
}
	