/* ---------------------------------------------------------------------- */
/* Fenster: Timer-Event einstellen                                        */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <tos.h>
#include "header.h"
#include "demo.h"
#include "powergem.h"

/* ---------------------------------------------------------------------- */
/* Prototypen                                                             */
/* ---------------------------------------------------------------------- */void get_beep(void);
void set_beep(void);
void switcher(int obj_index, int obj_state);
void beep(void);

/* ---------------------------------------------------------------------- */
/* Globale Variablen                                                      */
/* ---------------------------------------------------------------------- */
union 
{
	unsigned long sekunden;    /* Zeitspanne in Millisekunden */
	struct 
	{						   /* Struktur zum Aufspalten in Low- und */
		unsigned int high;     /* High-Word von sekunden              */
  	    unsigned int low;
  	} words;
} timer;

boolean beep_flag = FALSE;     /* Button-Flag */
char sek[3];				   /* Buffer fÅr FTEXT */

/* ---------------------------------------------------------------------- */
/* Fenster erzeugen und îffnen                                            */
/* ---------------------------------------------------------------------- */
void show_beep(void)
{
	struct WINDOW *beep;   /* Zeiger auf WINDOW-Struktur */

	beep = create_dial(SETBEEP, 0, NAME|CLOSER|MOVER, 0,0,0, switcher);

	if (beep)  /* War noch ein Fenster frei? */
	{
		set_text(beep, TIMER, sek, 3); /* FTEXT-Buffer setzen */
		
		/* Button-Aktionen festlegen ----------------- */
		button_action(beep, TIMEROK,  get_beep,   FALSE);
		button_action(beep, TIMERSET, set_beep,   TRUE);
		button_action(beep, TIMERCNC, break_dial, FALSE);
		
		/* Fenster îffnen und zur Verwaltung freigeben  */
		open_window(beep, "Timer-Event einstellen", "\0");
	}
}			


/* ---------------------------------------------------------------------- */
/* Okay-Button gedrÅckt                                                   */
/* ---------------------------------------------------------------------- */
void get_beep(void)
{
	set_beep();    /* Dialogeinstellung Åbernehmen */
	break_dial();  /* Dialog abbrechen */
}	
 
 
/* ---------------------------------------------------------------------- */
/* Dialogeinstellung Åbernehmen                                           */
/* ---------------------------------------------------------------------- */
void set_beep(void)
{
	if (beep_flag)  /* Schalter auf EIN ? */
	{
		timer.sekunden = atol(sek) * 1000; /* Eingabe umwandeln */
		/* Ereignis anmelden ----------------------------- */
		watch_timer(timer.words.low, timer.words.high, beep);
	}
	else   /* Schalter auf AUS ? */
		watch_timer(0,0,0);  /* Ereignis abmelden */
}	



/* ---------------------------------------------------------------------- */
/* Funktion zur Auswertung der SELECTABLE-Buttons                         */
/* ---------------------------------------------------------------------- */
void switcher(int obj_index, int obj_state)
{
	switch(obj_index)  /* Nummer des selektierten Buttons */
	{ 
		case BEEPON:   /* Schalter EIN gedrÅckt */
			if (obj_state & SELECTED)
				beep_flag = TRUE;
			break;
		case BEEPOFF:  /* Schalter AUS gedrÅckt */
			if (obj_state & SELECTED)
				beep_flag = FALSE;
	}
}


/* ---------------------------------------------------------------------- */
/* Pieper                                                                 */
/* ---------------------------------------------------------------------- */
void beep(void)
{
	Bconout(2, 7);
}