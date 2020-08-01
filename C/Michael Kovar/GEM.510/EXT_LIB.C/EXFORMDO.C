/* extended Form_do - Routine */
/*	UnterstÅtzt nun auch Dialogboxen in Fenstern */
/*	Version 2.01 vom 18.11.1992 */
/*	Programmierer: Michael Kovar */

#include <obdefs.h>
#include <osbind.h>
#include <gemdefs.h>
#include <aesbind.h>
#include <stdio.h>
#include "window.h"
#include "event.h"

#define EDCHAR 2
#define EDEND 3
#define ROOT 0
#define NIL -1
#define MU_KEYBD 0x0001
#define MU_BUTTON 0x0002
#define TRUE 1
#define FALSE 0
#define EDSTART 0
#define EDINIT 1
#define EDITABLE 0x8

#ifndef TOUCHABLE
#define TOUCHABLE 0x0800
#endif

#define DEFAULT 0x2
#define FMD_FORWARD 0
#define FMD_BACKWARD 1
#define FMD_DEFLT 2

#define LWGET(x) ((int)*((int*)(x)))
#define OB_FLAGS(x) (tree+(x)*sizeof(OBJECT)+8)
#define OB_TYPE(x) (tree+(x)*sizeof(OBJECT)+6)

/* Verweise auf externe Variablen */

extern	WIND_DATA *windows;	/* Zugriff auf Window-Manager */
extern	ACT aktuell;		/* Zugriff auf GEM-Manager */
extern 	EVNT event;		/* Zugriff auf EVENT-Manager */
extern	EVNT_RETURN event_return;	/* dto. */

/* Definierung eigener Strukturen / Variablen */

/* Zeiger fÅr modale Dialogboxen */
static 	char dial[12];

/* Beginn Bibliothek */

/* Stellt fÅr modale Dialoboxen die entsprechenden EVENT-Routinen zur
   VerfÅgung */

void dial_init(name)
char *name;
{
	dial[0] = '\0';
	strncpy(dial, name, 11);
}

/* Stellt die InfoZeile fÅr Dialogboxen in Fenstern bereit */
char *dial_info()
{
	return(dial);
}

/* find_obj sucht das nÑchste Objekt mit Typ flag in der Dialogbox. Die
   Richtung wird durch which angegeben, gestartet wird bei start_obj. */

static int find_obj(tree, start_obj, which, flag)
register long	tree;
int		start_obj;
int		which, flag;
{
	register int obj, theflag, inc;

	obj = 0;
	inc = 1;
	switch(which)
	{
		case FMD_BACKWARD:	inc = -1;

		case FMD_FORWARD:	obj = start_obj + inc;
					break;

		case FMD_DEFLT:		flag = DEFAULT;
					break;
	}

	while(obj >= 0)
	{
		theflag = LWGET(OB_FLAGS(obj));
		if(theflag & flag)
			return(obj);
		if(theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}
	return(start_obj);
}

/* fm_inifld findet das erste editierbare Feld in der Dialogbox, falls
   exform_do() fÅr das Startobjekt 0 Åbergeben wurde */

int fm_inifld(tree, start_fld)
long	tree;
int	start_fld;
{
	if(start_fld == 0)
		start_fld = find_obj(tree, 0, FMD_FORWARD, EDITABLE);
	return(start_fld);
}


/* Bei Auftritt eines Tastaturereignisses wird das dazu passende
	Objekt herausgesucht und an den Aufrufer gemeldet */

static int taste(tree, key)
long	tree;
int	key;
{
	int	start, start_alt = 1;
	int	defkey, flag;

	if((key & 0xff) != 0)
		return(0); /* Keine Alt-Kombination */

	flag=0;
	key = (key & 0xff00);
	while(start)
	{
		start = find_obj(tree, start_alt, FMD_FORWARD, TOUCHABLE);
		if((start != start_alt) || (!flag))
		{
			flag=1;
			start_alt = start;
			defkey=(LWGET(OB_TYPE(start)) & 0xff00);
			if(key == defkey)
				return(start);		
		}
		else
			start=0;
	}
	return(0);
}

/*	Erweiterte Form_Do()-Routine, die "normale" Dialogboxen verwaltet
	und TastaturunterstÅtzt ist */

int exform_do(tree, start_fld)
register long tree; /* Objektbaumadresse */
int start_fld; /* Startfeld fÅr Textcursor */
{
	register int	edit_obj; /* momentanes Objekt */
	int		next_obj; /* nÑchstes Objekt */
	int		which, cont;
	int		idx; /* Zeichenposition innerhalb des Objekts */
	int		mx, my, mb, ks, kr, br;
	int		index;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	next_obj = fm_inifld(tree, start_fld);
	edit_obj = idx = 0;
	cont = TRUE;

	while(cont)
	{
		if((next_obj != 0) && (edit_obj != next_obj))
		{
			edit_obj = next_obj;
			next_obj = 0;
			objc_edit(tree, edit_obj, 0, &idx, EDINIT);
		}

		which = evnt_multi(MU_KEYBD | MU_BUTTON, 0x02, 0x01, 0x01,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0x0L, 0, 0,
				&mx, &my, &mb, &ks, &kr, &br);

		if(which & MU_KEYBD)
		{
			cont = form_keybd(tree, edit_obj, next_obj, kr,
					&next_obj, &kr);

			if(kr)
			{
				if((index = taste(tree, kr)) > 0)
				{
					cont = form_button(tree, index,
							1, &next_obj);
				}
				else
				{
					objc_edit(tree, edit_obj, kr,
							&idx, EDCHAR);
				}
			}
		}


		if(which & MU_BUTTON)
		{
			next_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
			if(next_obj == NIL)
			{
				Bconout(2, 7);
				next_obj = 0;
			}
			else
				cont = form_button(tree, next_obj, br,
							&next_obj);
		}

		if((!cont) || ((next_obj != 0) && (next_obj != edit_obj)))
			objc_edit(tree, edit_obj, 0, &idx, EDEND);
	}

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	return(next_obj);
}

int wexform_do()
{
	register int	cont;
	register int	index, f;

	cont = TRUE;

	/* Fenster-Index ermitteln */
	f = handle_to_index(aktuell.handle);

	/* unser Fenster? */
	if(f == -1)
		return(-1);	/* Eingabe nicht bearbeitet */

	/* Dialogbox in Fenster? */
	if(windows[f].rsc.tree == ((OBJECT *) NULL))
		return(-1);	/* Eingabe nicht bearbeitet */


	if(event_return.buffer[0] == MSG_DIALOG)
		return(-1);

	/* Bearbeitung des Dialoges */
	if((windows[f].rsc.next_obj != 0) &&
	 (windows[f].rsc.edit_obj != windows[f].rsc.next_obj))
	{
		windows[f].rsc.edit_obj = windows[f].rsc.next_obj;
		windows[f].rsc.next_obj = 0;
		objc_edit(windows[f].rsc.tree, windows[f].rsc.edit_obj,
			 0, &windows[f].rsc.idx, EDINIT);
		windows[f].rsc.ed_flag = TRUE;
	}

	/* Nur KEYBD, MU_BUTTON interessieren */
	if((EVNT_MESAG()) || (EVNT_M1()) || (EVNT_M2()) || (EVNT_TIMER()))
		return(-1);	/* Eingabe nicht bearbeitet */


		if(EVNT_KEYBD())
		{
			cont = form_keybd(windows[f].rsc.tree,
					windows[f].rsc.edit_obj, 
					windows[f].rsc.next_obj,
					event_return.key,
					&windows[f].rsc.next_obj,
					&event_return.key);

			if(event_return.key)
			{
				if((index = taste(windows[f].rsc.tree,
						event_return.key)) > 0)
				{
					cont = form_button(windows[f].rsc.tree,
						index, 1,
						&windows[f].rsc.next_obj);
				}
				else
				{
					objc_edit(windows[f].rsc.tree,
						windows[f].rsc.edit_obj,
						event_return.key,
						&windows[f].rsc.idx, EDCHAR);
				}
			}
		}


		if(EVNT_BUTTON())
		{
			windows[f].rsc.next_obj =
					objc_find(windows[f].rsc.tree, ROOT,
					MAX_DEPTH, event_return.mouse_x,
					event_return.mouse_y);

			if(windows[f].rsc.next_obj == NIL)
			{
				windows[f].rsc.next_obj = 0;
				return(-1);
			}
			else
				cont = form_button(windows[f].rsc.tree,
					windows[f].rsc.next_obj,
					event_return.times,
					&windows[f].rsc.next_obj);
		}

		if((!cont) ||
		 ((windows[f].rsc.next_obj != 0) &&
		  (windows[f].rsc.next_obj != windows[f].rsc.edit_obj)))
		{
			objc_edit(windows[f].rsc.tree,
				windows[f].rsc.edit_obj, 0,
				&windows[f].rsc.idx, EDEND);

			windows[f].rsc.ed_flag == FALSE;

			if(!cont)
			{
				wbox_message(f, windows[f].rsc.next_obj);
				return(-2);
			}

			if((windows[f].rsc.next_obj != 0) && 
			 (windows[f].rsc.edit_obj != windows[f].rsc.next_obj))
			{
			windows[f].rsc.edit_obj = windows[f].rsc.next_obj;
			windows[f].rsc.next_obj = 0;
			objc_edit(windows[f].rsc.tree, windows[f].rsc.edit_obj,
				 0, &windows[f].rsc.idx, EDINIT);
				windows[f].rsc.ed_flag = TRUE;
			}

		}

		if(! cont)
		{
			wbox_message(f, windows[f].rsc.next_obj);
			return(-2); /* Eingabe bearbeitet */
		}

	return(-2);	/* Eingabe bearbeitet */
}
