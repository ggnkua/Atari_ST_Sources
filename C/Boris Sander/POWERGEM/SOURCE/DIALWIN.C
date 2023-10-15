/* ---------------------------------------------------------------------- */
/* Fenster: Nichtmodaler Dialog                                           */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <string.h>
#include <aes.h>
#include "header.h"
#include "demo.h"
#include "powergem.h"

/* ---------------------------------------------------------------------- */
/* Prototypen                                                             */
/* ---------------------------------------------------------------------- */
void release(int obj_index, int state);
void set_data(void);
void take_data(void);


/* ---------------------------------------------------------------------- */
/* Globale Variablen                                                      */
/* ---------------------------------------------------------------------- */
struct 
{
	char name[21];      /* Buffer fÅr Dialog */
	char vorname[21];
	char alter[3];
	int  gefallen;
	int  geschlecht;
} temp = {"\0", "\0", "\0", 0, 0},
  person = {"\0", "\0", "\0", SEHRGUT, FEMALE};


/* ---------------------------------------------------------------------- */
/* Fenster erzeugen und îffnen                                            */
/* ---------------------------------------------------------------------- */
void show_dial(void)
{
	struct WINDOW *dialog;   /* Zeiger auf WINDOW-Struktur */
	
	dialog = create_dial(DIALDEMO, FAMNAME, NAME|CLOSER|MOVER, 0,0,0,
							   release);

	if (dialog)   /* Ist da noch ein Fensterl frei ? */
	{
		set_text(dialog, FAMNAME, temp.name,    21);/*Adressen der FTEXT- */
		set_text(dialog, VORNAME, temp.vorname, 21);/*Buffer setzen */
		set_text(dialog, ALTER,   temp.alter,    3);

		strcpy(temp.name, person.name);        /* TemporÑr-Buffer init. */
		strcpy(temp.vorname, person.vorname);
		strcpy(temp.alter, person.alter);

		unselect_btn(dialog, temp.geschlecht, FALSE); /* Button-State auf */
		unselect_btn(dialog, temp.gefallen, FALSE);   /* NORMAL setzen */

		temp.gefallen = person.gefallen;        /* Temp. Button-State */
		temp.geschlecht = person.geschlecht;	/* setzen */
	
		select_btn(dialog, person.geschlecht, FALSE);
		select_btn(dialog, person.gefallen, FALSE);

		/* Button-Aktionen anmelden ------------------- */
		button_action(dialog, ABBRUCH, break_dial, FALSE);
		button_action(dialog, OKAY,    set_data,   FALSE);
		button_action(dialog, TAKEIT,  take_data,  TRUE); 

		/* Fenster îffnen und zur Verwaltung freigeben ----------- */
		open_window(dialog, "Nichtmodaler editierbarer Dialog","\0");
	}
}


/* ---------------------------------------------------------------------- */
/* Auswertung der SELECTABLE-Buttons                                      */
/* ---------------------------------------------------------------------- */
void release(int obj_index, int state)
{
	if (state & SELECTED)
	{
		switch(obj_index)  /* Nummer des Buttons */
		{
			case SEHRGUT:
			case GUT:
			case GEHTSO:
			case SCHWACH:
				temp.gefallen = obj_index;
				break;
			case FEMALE:
			case MALE:
				temp.geschlecht = obj_index;
				break;
		}
	}
}



/* ---------------------------------------------------------------------- */
/* Okay-Button gedrÅckt                                                   */
/* ---------------------------------------------------------------------- */
void set_data(void)
{
	take_data();    /* Daten Åbernehmen und */
	break_dial();   /* Dialog beenden */
}



/* ---------------------------------------------------------------------- */
/* SETZEN-Button gedrÅckt                                                 */
/* ---------------------------------------------------------------------- */
void take_data(void)
{
	char anrede[6]; 
	char gefallen[13];
	char meldung[120];
	
	strcpy(person.name,    temp.name);
	strcpy(person.vorname, temp.vorname);
	strcpy(person.alter,   temp.alter);
	person.gefallen   = temp.gefallen;
	person.geschlecht = temp.geschlecht;

	/* form_alert-Box aufbauen ----------------- */
	switch(person.geschlecht)
	{
		case FEMALE:
			strcpy(anrede, "Frau");
			break;
		case MALE:
			strcpy(anrede, "Herr");
	}

	switch(person.gefallen)
	{
		case SEHRGUT:
			strcpy(gefallen, "Es ist toll");
			break;
		case GUT:
			strcpy(gefallen, "Es ist gut");
			break;
		case GEHTSO:
			strcpy(gefallen, "Es geht so");
			break;
		case SCHWACH:
			strcpy(gefallen, "Schwach");
	}	

	sprintf(meldung, "[3][%s %s %s,|%s Jahre alt,|stellt fest:|%s][Weiter]",
			  anrede, person.vorname, person.name, person.alter, gefallen);
	form_alert(1, meldung);
}	
