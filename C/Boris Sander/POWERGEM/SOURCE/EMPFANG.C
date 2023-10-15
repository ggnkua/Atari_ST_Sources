/* ---------------------------------------------------------------------- */
/* Fenster: externe Nachricht empfangen und anzeigen                      */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <aes.h>
#include "header.h"
#include "demo.h"
#include "powergem.h"

/* Prototyp ------------------------------------------------------------- */
void show_msg(void);

char message[40]; /* Nachrichten-Buffer */

/* ---------------------------------------------------------------------- */
/* Funktion zum Lesen der externen Nachricht                              */
/* ---------------------------------------------------------------------- */
void empfaenger(int msgbuff[8])
{
	struct A_CNTRL *app_cntrl;  /* Zeiger auf A_CNTRL-Struktur */
	
	app_cntrl = get_app_cntrl(); /* A_CNTRL-Struktur suchen */
	appl_read(app_cntrl->ap_id, msgbuff[2], message); /* Nachricht lesen */
	show_msg(); 									  /* und anzeigen */	
} 



/* ---------------------------------------------------------------------- */
/* externe Nachricht anzeigen                                             */
/* ---------------------------------------------------------------------- */
void show_msg(void)
{
	struct WINDOW *win;   /* Zeiger auf WINDOW-Struktur */

	win = create_dial(SHOWMSG, 0, NAME|CLOSER|MOVER, 0,0,0,0);

	if (win)     /* Hat's geklappt ? */
	{
		set_text(win, MESSAGE, message, 37);  /* FTEXT-Buffer setzen */
		
		/* Button-Aktion: break_dial beendet Dialog  */
		button_action(win, EXITMSG, break_dial, FALSE); 
		open_window(win, "Externe Nachricht", "\0"); 
	}
}