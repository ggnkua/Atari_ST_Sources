/**************************************************************************/
/*																		  */
/*							VIERFREI.C									  */
/*																		  */
/*						Version vom 21.12.93							  */
/*																		  */
/**************************************************************************/


/*------------------------------------------------------------------------*/
/*																		  */
/*		Liste der zu '#include'nden Files								  */
/*																		  */
/*------------------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#include "VIERFREI.H"				/* Headerfile fÅr Resource			  */


/*------------------------------------------------------------------------*/
/*																		  */
/*		einige '#define's												  */
/*																		  */
/*------------------------------------------------------------------------*/


#define	N			52				/* Anzahl der Karten				  */
#define NUM_COLUMNS	8				/* Anzahl der Reihen				  */

#define CARD_WIDTH	64				/* Breite einer Karte (in Pixeln)	  */
#define	CARD_LENGTH	93				/* LÑnge einer Karte (in Pixeln)	  */

#define CARD_SIZE	186L			/* fÅr Bild einer Karte benîtigter	  */
									/* Speicher (in Byte)				  */
#define	CARD_X_SPAC	10				/* horizontaler Abstand der Karten	  */
#define	CARD_Y_SPAC	15				/* vertikaler Abstand der Karten	  */

#define	TOP_ROW		102				/* y-Position der Reihen (relativ zur */
									/* ArbeitsflÑche des Fensters)		  */
#define	NO_CARD		-1				/* 'Kartennummer' fÅr Stellen, wo	  */
									/* keine (!) Karte liegt			  */
#define	HIST_LEN	250L			/* Anzahl der ZÅge, fÅr die jeweils	  */
									/* Speicher alloziert wird (zwecks	  */
									/* RÅcknahme ...)					  */
#define	ON			1
#define	OFF			0

#define	BLACK		1
#define	WHITE		0

#define	NORM		1
#define	INVERS		0

#define	F1			59				/* Scancodes verschiedener Tasten	  */
#define	F2			60
#define	F3			61
#define F4			62
#define	F10			68
#define	UNDO		97
#define	DELETE		83

#define ESC			0x1B			/* ASCII-Codes der Zeichen			  */
#define BACKSPACE	0x08
#define RETURN		0x0D			/* <RETURN> und <ENTER>				  */

#define S_TEXT	ob_spec.tedinfo->te_ptext		/* fÅr Text-Objekte		  */

#define MIN(x,y)	(((x) < (y)) ? (x) : (y))	/* Minimum zweier Zahlen  */
#define MAX(x,y)	(((x) > (y)) ? (x) : (y))	/* Maximum zweier Zahlen  */

#define	_hz_200		0x04BAL			/* Adresse des ZÑhler des 200 Hz -	  */
									/* Interrupts						  */


/*------------------------------------------------------------------------*/
/*																		  */
/*		Funktionsdeklarationen											  */
/*																		  */
/*------------------------------------------------------------------------*/


int init_history(void);
int extend_history(void);
int shorten_history(void);
void take_move_back(void);
void save_move(int source, int dest);
int show_box(int ob_no);
int on_mouse_event(int mox, int moy, int mbutton);
int find_card(int x, int y);
int is_touch_possible(int card_no);
int get_move_length(int card_no);
int find_where_to(int x, int y);
int is_enough_room(int cards_to_move, int dest);
int get_max_no(int place, int temp);
int is_move_possible(int source, int dest);
void wait_for_left_release(void);
void move_card(int source, int dest, int mbox_flag);
void take_away(int source);
void move_multi_cards(int source, int dest);
void move_temp_to_column(int *free_temp, int *act_temp, int max_temp,
																  int dest);
int move_single_card(int source_column, int final_card, int *free_place,
														int act_free_place);
int move_column_to_temp(int source_column, int final_card, int *free_temp,
														int *act_free_temp);
void move_multi_to_temp(int card_no);
void show_card(int card_no, int clip_flag);
void shuffle(void);
double make_seed(void);
double random_generator(void);
void show_all(int all_flag);
void show_column(int col_no, int card_x, int clip_flag);
int automatic_remove(void);
void set_wind_header(char *title);
void paint_background(void);
void clear_column(int col, int clip_flag);
int gem_init(char *title);
void gem_exit(void);
int make_cards(void);
void reverse_card(long *source, long *dest);
int select_game(char *title);
void wind_redraw(int *rr, OBJECT *wind);
int intersect(int *rr, int *ar);
void move_window(int x, int y, OBJECT *wind);
int resize_window(char *title);
void i_to_a(char *s, long number, int n);


/*------------------------------------------------------------------------*/
/*																		  */
/*		Deklaration einiger struct's									  */
/*																		  */
/*------------------------------------------------------------------------*/


struct Card								/* Struktur fÅr Karten (und auch  */
{										/* fÅr End- und Zwischenablage)	  */
	int x;								/* x- und y- Position der Karte	  */
	int y;
	int h;								/* sichtbare Hîhe der Karte		  */
	int column;							/* Spalte oder Ablage, auf der	  */
										/* die Karte liegt				  */
	int prev_card;						/* Nummer der vorhergehenden und  */
	int next_card;						/* der nÑchsten Karte			  */
};										

/* Achtung : Bei den Card-Strukturen fÅr End- und Zwischenablage enthÑlt  */
/* 			 prev_card die Nummer der darauf liegenden (obersten) Karte ! */

struct Column							/* Struktur fÅr Reihen			  */
{
	int first_card;						/* Nummer der obersten Karte	  */
	int x;								/* x-Position der Reihe			  */
	int h;								/* LÑnge der Reihe (in Pixeln)	  */
	int	del_y;							/* LÑnge der gezeigten Teils von  */
};										/* Karten, die Åberlagert sind	  */
		

/*------------------------------------------------------------------------*/
/*																		  */
/*		globale Variable												  */
/*																		  */
/*------------------------------------------------------------------------*/


int ap_id;							/* ID der eigenen Applikation		  */
int wkst_handle;					/* Handle der Workstation			  */
int wind_handle;					/* Handle des Fensters				  */
int nplanes;						/* Anzahl der Bitplanes				  */
int wox, woy, wow, woh,				/* Auûen- und Innenmaûe des Fensters  */
	wwx, wwy, www, wwh;
OBJECT *menu;						/* Adresse des Menues				  */
long *pic;							/* Adresse der Bilder der Karten	  */
double seed;						/* akt. Seed des Zufallgenerators	  */
double old_seed;					/* Startseed des Zufallgenerators	  */
struct Card card[N + 8];			/* Strukturen fÅr Karten sowie End-	  */
									/* und Zwischenablage (Endablage ab	  */
									/* N bis (N + 3), Zwischenablage ab	  */
									/* (N + 4) bis (N + 7)				  */
struct Column column[NUM_COLUMNS];	/* Strukturen fÅr die Reihen		  */
char *history;						/* Pointer auf Array fÅr Speicherung  */
									/* der bisherigen ZÅge				  */
int no_history = OFF;				/* gesetzt, wenn nicht die ZÅge nicht */
									/* gepeichert werden kînnen			  */
long move_no;						/* Anzahl der bisherigen ZÅge		  */
int remaining_cards;				/* Anzahl der restlichen Karten		  */
int scr_x, scr_y;					/* maximale Bildschirmgrîûe			  */
int clip_array[4];					/* Array fÅr Cliping				  */


/*------------------------------------------------------------------------*/
/*																		  */
/*		Hier fÑngt das eigentliche Programm (endlich) an ...			  */
/*																		  */
/*------------------------------------------------------------------------*/


main()
{
	int mwhich,						/* Variablen fÅr evnt_multi()		  */
		mbuf[8],
		mox, moy,
		mbutton, mokstate,
		mkreturn, mbreturn;
	int top_window;					/* Handle des obersten Fensters		  */
	char wind_name[] = " VIERFREI #       ";	/* Titel des Fensters	  */
	int quit_flag = OFF;			/* Flag, bei Programmende gesetzt	  */
	
	
	/* Applikation anmelden, Workstation anmelden und Fenster îffnen	  */

	if (!gem_init(wind_name))
		return(0);
	
	/* Resource-File einlesen und Objektadressen bestimmen				  */

	if (!rsrc_load("VIERFREI.RSC"))
	{
		wind_delete(wind_handle);
		gem_exit();
		return(0);
	}

	rsrc_gaddr(R_TREE, MENU, &menu);

	/* Menue-Zeile anzeigen												  */

	menu_bar(menu, ON);

	/* Bilder der Karten vorbereiten									  */

	if (!make_cards())
	{
		menu_bar(menu, OFF);
		rsrc_free();
		wind_delete(wind_handle);
		gem_exit();
		return(0);
	}

	/* Erstes Spiel vorbereiten											  */

	if (!init_history())
		menu_ienable(menu, T1E4, OFF);
	old_seed = seed = make_seed();
	set_wind_header(wind_name);
	shuffle();

	graf_mouse(ARROW, 0);

	/* In einer Loop auf Tastatur-, Maus- oder Message-Ereignisse warten  */
	/* und diesen entsprechend verzweigen ...							  */

	do
	{
		mwhich = evnt_multi(MU_KEYBD | MU_BUTTON | MU_MESAG,
							1, 1, 1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							mbuf, 0, 0, &mox, &moy, &mbutton,
							&mokstate, &mkreturn, &mbreturn);

	/* Reaktion auf Messages ...										  */

		if (mwhich & MU_MESAG)
		{
			switch (mbuf[0])
			{
				case WM_CLOSED :				  /* Close-Box angeklickt */
					quit_flag = ON;
					break;

				case WM_REDRAW :				   /* REDRAW-Aufforderung */
					wind_redraw(mbuf + 4, (OBJECT *) 0L);
					break;

				case WM_TOPPED :		/* Fenster wurde oberstes Fenster */
					wind_set(wind_handle, WF_TOP);
					break;

				case WM_MOVED :				  /* Fenster wurde verschoben */
					move_window(mbuf[4], mbuf[5], (OBJECT *) 0L);
					break;

				case WM_FULLED :				   /* FULL-Box angeklickt */
					if (resize_window(wind_name))
						quit_flag = ON;
					break;
			}
		}

	/* Bei Tastatureingabe Anklicken von MenueeintrÑgen simulieren ...	  */

		if (mwhich & MU_KEYBD)
		{
			switch(mkreturn >> 8)
			{
				case F1 :					  /* neues (zufÑlliges) Spiel */
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E0;
					menu_tnormal(menu, T1, INVERS);
					break;

				case F2 :			   /* neues Spiel (entsprechend Zahl) */
					if (menu[T1E1].ob_state & DISABLED)
						break;
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E1;
					menu_tnormal(menu, T1, INVERS);
					break;

				case F3 :					   /* altes Spiel wiederholen */
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E2;
					menu_tnormal(menu, T1, INVERS);
					break;

				case F4 :								 /* öber VIERFREI */
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T0;
					mbuf[4] = T0E0;
					menu_tnormal(menu, T0, INVERS);
					break;

				case F10 :								 /* Spiel beenden */
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E5;
					menu_tnormal(menu, T1, INVERS);
					break;

				case DELETE :				   /* automatisches Entfernen */
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E3;
					menu_tnormal(menu, T1, INVERS);
					break;

				case UNDO :					  /* letzten Zug zurÅcknehmen */
					if (no_history)
						break;
					mwhich |= MU_MESAG;
					mbuf[0] = MN_SELECTED;
					mbuf[3] = T1;
					mbuf[4] = T1E4;
					menu_tnormal(menu, T1, INVERS);
					break;
			}
		}

	/* Handle des derzeitig obersten Fensters bestimmen - ist es nicht	  */
	/* das eigene wird auf die folgenden Events *nicht* reagiert		  */

		wind_get(wind_handle, WF_TOP, &top_window);

		if (wind_handle != top_window)
		{
			if ((mwhich & MU_MESAG) && (mbuf[0] == MN_SELECTED))
				menu_tnormal(menu, mbuf[3], NORM);
			continue;
		}

	/* Reaktion auf Anklicken eines Menu-Eintrags						  */

		if ((mwhich & MU_MESAG) && (mbuf[0] == MN_SELECTED))
		{
			switch (mbuf[4])
			{
				case T0E0 :							 /* öber VIERFREI ... */
					if (show_box(ABOUT))
						quit_flag = ON;
					break;

				case T1E0 :					  /* neues (zufÑlliges) Spiel */
					old_seed = seed;
					set_wind_header(wind_name);
					shuffle();
					show_all(ON);
					break;

				case T1E1 :			   /* neues Spiel (entsprechend Zahl) */
					if (!select_game(wind_name))
						break;
					shuffle();
					show_all(ON);
					break;

				case T1E2 :					   /* altes Spiel wiederholen */
					seed = old_seed;
					shuffle();
					show_all(ON);
					break;

				case T1E3 :					   /* automatisches Entfernen */
					if (automatic_remove())
					{
						if (show_box(GRAT))
							quit_flag = ON;
					}
					break;

				case T1E4 :					  /* letzten Zug zurÅcknehmem */
					take_move_back();
					break;

				case T1E5 :								 /* Spiel beenden */
					quit_flag = ON;
					break;
			}

			menu_tnormal(menu, mbuf[3], NORM);
		}

	/* Reaktion auf DrÅcken der linken Maustaste						  */

		if (mwhich & MU_BUTTON)
		{
			if (on_mouse_event(mox, moy, mbutton))
			{
				if (show_box(GRAT))
					quit_flag = ON;
			}
		}

	} while (!quit_flag);

	/* Speicherplatz fÅr Speicherung der ZÅge und die Bilder der Karten	  */
	/* freigeben														  */

	if (history)
	{
		while (!shorten_history())
			;
		Mfree(history);
	}

	Mfree(pic);

	/* Menue-Zeile entfernen und Speicher fÅr Resource freigeben		  */

	menu_bar(menu, OFF);
	rsrc_free();

	/* Fenster und Workstation schlieûen								  */

	wind_delete(wind_handle);
	gem_exit();

	/* das war's ...													  */

	return(0);
}


/*------------------------------------------------------------------------*/
/* init_history()														  */
/*	Alloziert Speicher fÅr Speicherung der ZÅge							  */
/* <-  1 = alles ok, 0 : kein Speicher frei								  */
/*------------------------------------------------------------------------*/


int init_history(void)
{
	char **ptr;


	/* Platz fÅr Speichern der ZÅge allozieren - gespeichert wird jeweils */
	/* nur die Nummer der Ausgangs- und Zielreihe (bzw. des End- oder	  */
	/* Zwischenablageplatzes). Die letzten Byte in 'history' dienen zur	  */
	/* mîglichen Erweiterung des Speicherplatzes, wenn mehr als HIST_LEN  */
	/* SpielzÅge stattgefunden haben - sie werden zunÑchst auf NULL ge-	  */
	/* setzt, so daû klar ist, daû noch kein weiterer Speicher alloziert  */
	/* ist.																  */

	if ((history = (char *) Malloc(2L * HIST_LEN * sizeof(char) + 
												   sizeof(char *))) == NULL)
	{
		menu_ienable(menu, T1E4, OFF);
		no_history = ON;
		return(0);
	}

	ptr = (char **) (history + 2L * HIST_LEN);
	*ptr = (char *) 0L;

	return(1);
}


/*------------------------------------------------------------------------*/
/* extend_history()														  */
/*	Alloziert zusÑtzlichen Speicher fÅr Speicherung der ZÅge				  */
/* <-  1 = alles ok, 0 = kein weiterer Speicher mehr frei				  */
/*------------------------------------------------------------------------*/


int extend_history(void)
{
	char *ptr, **old_ptr;


	/* Zur Erweiterung des Platzes fÅr die Speicherung der bisherigen	  */
	/* SpielzÅge wird weiterer Speicherplatz alloziert, dessen Adresse	  */
	/* in die letzten Byte des vorher allozierten Speicherplatzes ge-	  */
	/* schrieben wird - die letzten Byte des neu allozierten Speichers	  */
	/* werden zunÑchst auf NULL gesetzt, so daû klar ist, daû dies der	  */
	/* zuletzt allozierte Speicherplatz ist.							  */
	
	old_ptr = (char **) (history + 2L * HIST_LEN);
	ptr = (char *) *old_ptr;

	while (ptr != (char *) 0L)
	{
		old_ptr = (char **) (ptr + 2L * HIST_LEN);
		ptr = (char *) *old_ptr;
	};

	if ((*old_ptr = (char *) Malloc(2L * HIST_LEN *
									sizeof(char) + sizeof(char *))) == NULL)
	{
		menu_ienable(menu, T1E4, OFF);
		no_history = ON;
		while (!shorten_history())
			;
		return(0);
	}
	else
	{
		old_ptr = (char **) ((char *) *old_ptr + 2L * HIST_LEN);
		*old_ptr = (char *) 0L;
		return(1);
	}
}


/*------------------------------------------------------------------------*/
/* shorten_history()													  */
/*	Gibt das letzte zusÑtzlich fÅr die Speicherung der ZÅge allozierte	  */
/*	SpeicherstÅck wieder frei.											  */
/* <-  1 = aller zusÑtzlicher Speicher ist bereits freigegeben, 0 = es	  */
/*	   gibt noch weitere allozierte Speicherbereiche					  */
/*------------------------------------------------------------------------*/


int shorten_history(void)
{
	char *ptr, *temp, **old_ptr;


	temp =  history;
	ptr = *((char **) (history + 2L * HIST_LEN));

	/* Falls die letzten Byte des zu Anfang allozierten Speicherbereichs  */
	/* NULL sind gibt es keine weiteren freizugebenden Speicherbereiche	  */

	if (ptr == (char *) 0L)
		return(1);

	/* Sonst muû man sich bis zum am letzten allozierten Speicherbereich  */
	/* durchhangeln (daran erkennbar, daû seine letzten Byte NULL sind)	  */

	do
	{
		old_ptr = (char **) (temp + 2L * HIST_LEN);
		temp = ptr;
		ptr = *((char **) (ptr + 2L * HIST_LEN));
	} while (ptr != (char *) 0L);

	/* Diesen Bereich freigeben und die letzten Byte des zuvor allozier-  */
	/* ten Speicherbereich auf NULL setzen								  */

	Mfree(temp);

	*old_ptr = (char *) 0L;

	return(0);
}


/*------------------------------------------------------------------------*/
/* save_move()															  */
/*	Speichert einen Zug ab												  */
/* ->  Nummer der Ausgangs- und der Zielreihe							  */
/*------------------------------------------------------------------------*/


void save_move(int source, int dest)
{
	char *ptr;
	long temp_move_no;


	if (no_history)
		return;

	/* Zuerst einmal durch die History durchhangeln (s.o.) ...			  */

	temp_move_no = move_no;

	ptr = history;

	while (temp_move_no >= HIST_LEN)
	{
		ptr = *((char **) (ptr + 2L * HIST_LEN));
		temp_move_no -= HIST_LEN;
	}

	/* Nun die ZÅge abspeichern ...										  */

	*(ptr + 2L * temp_move_no) = (char) source;
	*(ptr + 2L * temp_move_no + 1) = (char) dest;

	move_no++;

	/* Wenn die History voll ist neuen Speicher allozieren ...			  */

	if ((move_no % HIST_LEN) == 0)
		extend_history();
}


/*------------------------------------------------------------------------*/
/* take_move_back()														  */
/*	Nimmt den letzten Zug zurÅck										  */
/*------------------------------------------------------------------------*/


void take_move_back(void)
{
	char *ptr;
	long temp_move_no;
	int source_col, source, dest_col, dest;
	int dest_x, dest_y;


	/* Sind keine ZÅge gespeichert oder ist man beim ersten Zug angelangt */
	/* gehts natÅrlich nicht weiter zurÅck ...							  */

	if ((no_history) || (move_no == 0))
	{
		Cconout('\a');
		return;
	}

	move_no--;

	/* Sonst zuerst einmal durch die History durchhangeln (s.o.) ...	  */

	temp_move_no = move_no;

	ptr = history;

	while (temp_move_no >= HIST_LEN)
	{
		ptr = *((char **) (ptr + 2L * HIST_LEN));
		temp_move_no -= HIST_LEN;
	}

	/* ... die gespeicherten Zug holen ...								  */

	dest_col = (int) *(ptr + 2L * temp_move_no);
	source_col = (int) *(ptr + 2L * temp_move_no + 1);

	/* ... und die Karte erst entfernen und dann wieder an der alte Posi- */
	/* tion zeichnen :													  */

	/* Dazu die unterste Karte der Reihe bestimmen, von der die Karte	  */
	/* wieder entfernt werden muû ...									  */

	if (source_col >= N)
		source = card[source_col].prev_card;
	else
	{
		source = column[source_col].first_card;
		while (card[source].next_card != NO_CARD)
			source = card[source].next_card;
	}

	/* ... und das selbe fÅr die Zielreihe								  */

	if (dest_col >= N)
	{
		dest = card[dest_col].prev_card;

		dest_x = card[dest_col].x;
		dest_y = card[dest_col].y;
	}
	else
	{
		dest = column[dest_col].first_card;

		dest_x = column[dest_col].x;
		dest_y = wwy + TOP_ROW;

		if (dest != NO_CARD)
		{
			while (card[dest].next_card != NO_CARD)
				dest = card[dest].next_card;
			dest_y = card[dest].y;
		}
	}

	/* Karte von der alten Position lîschen, eine sich von ihrer alten	  */
	/* zur neuen Position bewegende Box zeichnen und die Karte an die	  */
	/* Zielreihe anhÑngen												  */

	take_away(source);

	graf_mbox(CARD_WIDTH, CARD_LENGTH, card[source].x, card[source].y,
															dest_x, dest_y);

	if (dest_col >= N)
	{
		card[dest_col].prev_card = source;

		card[source].x = card[dest_col].x;
		card[source].y = card[dest_col].y;
		card[source].h = CARD_LENGTH;
		card[source].column = dest_col;
		card[source].prev_card = card[source].next_card = NO_CARD;

		show_card(source, ON);
	}
	else
	{
		if (dest != NO_CARD)
		{
			card[dest].next_card = source;
			card[dest].h = column[dest_col].del_y;
			card[source].prev_card = dest;
			card[source].y = card[dest].y + column[dest_col].del_y;
		}
		else
		{
			card[source].prev_card = NO_CARD;
			column[dest_col].first_card = source;
			card[source].y = wwy + TOP_ROW;
		}

		card[source].next_card = NO_CARD;
		card[source].column = dest_col;
		card[source].x = column[dest_col].x;
		card[source].h = CARD_LENGTH;

		if ((card[source].y + CARD_LENGTH) < (wwy + wwh - 1))
		{
			show_card(source, ON);
			if (column[dest_col].h == 0)
				column[dest_col].h = CARD_LENGTH;
			else
				column[dest_col].h += column[dest_col].del_y;
		}
		else
			show_column(dest_col, column[dest_col].x, ON);
	}

	/* Wurde die Karte von der Endablage zurÅckgenommen, Anzahl der auf	  */
	/* der SpielflÑche verbliebenen Karten inkrementieren				  */

	if ((source_col >= N) && (source_col < N + 4))
		remaining_cards++;

	/* U. U. den Speicherplatz zur Speicherung der ZÅge verkleinern		  */

	if ((move_no % HIST_LEN) == HIST_LEN - 1)
		shorten_history();
}


/*------------------------------------------------------------------------*/
/* show_box()															  */
/*  Zeigt Gratulationsbox bei erfolgreicher Beendigung eines Spiels bzw.  */
/*	Box mit Informationen Åber das Spiel.								  */
/* ->  Objektnummer der darzustellenden Box								  */
/* <-  1 = Spiel beenden, 0 = weitermachen								  */
/*------------------------------------------------------------------------*/


int show_box(int ob_no)
{
	int mwhich,							/* Variablen fÅr evnt_multi()	  */
		mbuf[8],
		mox, moy,
		mbutton, mokstate,
		mkreturn, mbreturn;
	OBJECT *box;						/* Pointer auf darzustellende Box */
	int quit_flag = OFF;				/* gesetzt, wenn alles fertig ist */


	/* Adresse der Box besorgen, Box vorbereiten und darstellen			  */

	rsrc_gaddr(R_TREE, ob_no, &box);

	if ((scr_x - wwx < box->ob_width + 10) ||
										(scr_y - wwy < box->ob_height + 10))
		return(0);

	box->ob_x = MIN(wwx + (www - box->ob_width) / 2,
										 (scr_x + wwx - box->ob_width) / 2);
	box->ob_y = MIN(wwy + (wwh - box->ob_height) / 2,
										(scr_y + wwy - box->ob_height) / 2);

	/* Wenn es sich um die Gratulationsbox handelt, die Anzahl der benî-  */
	/* tigten ZÅge eintragen											  */

	if (ob_no == GRAT)
		i_to_a(box[GNUMBER].S_TEXT, move_no, 5);

	objc_draw(box, R_TREE, 1, MAX(box->ob_x - 5, 0),
					  MAX(box->ob_y - 5, 0), MIN(box->ob_width + 10, scr_x),
										   MIN(box->ob_height + 10, scr_y));

	/* MOVER und FULLER des Fensters ausschalten						  */

	wind_set(wind_handle, WF_KIND, CLOSER | NAME);

	/* Auf Messages, Anklicken von 'OK' oder DrÅcken der Return-Taste	  */
	/* warten															  */

	do
	{
		mwhich = evnt_multi(MU_BUTTON | MU_KEYBD | MU_MESAG,
							1, 1, 1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							mbuf, 0, 0,
							&mox, &moy, &mbutton,
							&mokstate, &mkreturn, &mbreturn);

	/* Reaktion auf Messages ...										  */

		if (mwhich & MU_MESAG)
		{
			switch (mbuf[0])		   /* Nach Art der Message verzweigen */
			{
				case WM_REDRAW :			  /* REDRAW-Message empfangen */
					wind_redraw(mbuf + 4, (OBJECT *) 0L);
					wind_redraw(mbuf + 4, box);
					break;

				case WM_TOPPED :		/* Fenster wurde oberstes Fenster */
					wind_set(wind_handle, WF_TOP);
					break;

				case WM_CLOSED :						 /* Spiel beenden */
					return(1);

				case MN_SELECTED :	   /* nur auf Spiel beenden reagieren */
					menu_tnormal(menu, mbuf[3], NORM);
					if ((mbuf[3] == T1) && (mbuf[4] == T1E5))
						return(1);
					break;
			}
		}

	/* Abbrechen, wenn 'OK' angeklickt oder RETURN gedrÅckt wurde		  */

		if (mwhich & MU_BUTTON)
		{
			if (((ob_no == GRAT) &&
						(GREADY == objc_find(box, 0, 1, mox, moy))) ||
				((ob_no == ABOUT) &&
						(AREADY == objc_find(box, 0, 1, mox, moy))))
			quit_flag = ON;
		}

		if ((mwhich & MU_KEYBD) && ((mkreturn & 0xFF) == RETURN))
			quit_flag = ON;

	} while (!quit_flag);

	/* Von der Box Åberdeckten Teil des Spielfeld neu zeichnen ...		  */

	clip_array[0] = MAX(box->ob_x - 5, 0);
	clip_array[1] = MAX(box->ob_y - 5, 0);
	clip_array[2] = MIN(box->ob_x + box->ob_width + 4, scr_x);
	clip_array[3] = MIN(box->ob_y + box->ob_height + 4, scr_y);
	vs_clip(wkst_handle, ON, clip_array);

	show_all(OFF);

	/* ... und FULLER und MOVER des Fensters wieder anschalten			  */

	wind_set(wind_handle, WF_KIND, CLOSER | NAME | FULLER | MOVER);

	return(0);
}


/*------------------------------------------------------------------------*/
/* on_mouse_event()														  */
/*	1. Testen, ob eine Karte angeklickt wurde							  */
/*	2. Testen, ob die Karte Åberhaupt bewegt werden kann				  */
/*	3. Box um die Karte mit der Maus verschieben lassen					  */
/*	4. Zielkarte feststellen											  */
/*	5. bei mehreren zu verschiebenden Karten testen, ob genÅgend freie	  */
/*	   PlÑtze fÅr diese Aktion vorhanden sind							  */
/*	6. Funktionen zum Verschieben der Karte(n) aufrufen					  */
/*																		  */
/* ->  x- und y-Position der Maus beim DrÅcken des Buttons sowie Zustand  */
/*	   der Mausbuttons													  */
/* <-  1 = Spiel ist zu Ende, 0 = noch nicht alle Karten abgelegt		  */
/*------------------------------------------------------------------------*/


int on_mouse_event(int mox, int moy, int mbutton)
{
	int del_x, del_y;
	int touched_card, cards_to_move, where_to;


	/* Herausfinden welche Karte angeklickt wurde						  */

	if ((touched_card = find_card(mox, moy)) == NO_CARD)
	{
		wait_for_left_release();
		return(0);
	}

	/* Untersuchen ob die angeklickte Karte Åberhaupt bewegt werden kann  */
	/* und um wieviele es sich handelt (bei ZÅgen, bei denen beide Maus-  */
	/* buttons gedrÅckt sind, also eine Reihe auf die Zwischenablage ge-  */
	/* schoben werden soll, mÅssen die zu verschiebenden Karten *nicht*	  */
	/* aneinanderpassen)												  */

	if (((cards_to_move = is_touch_possible(touched_card)) == 0) &&
															 (mbutton != 3))
	{
		wait_for_left_release();
		return(0);
	}

	/* Wenn beide Mausbuttons gedrÅckt sind, versuchen, die Karte(n) in	  */
	/* die Zwischenablage zu verschieben								  */

	if (mbutton & 2)
	{
		move_multi_to_temp(touched_card);
		return(0);
	}

	/* Sonst die Karte(n) in Form von Dragbox (mit Grîûe entsprechend der */
	/* Maûe der zu verschiebenden Karte(n)) verschieben lassen, Maus	  */
	/* dabei als Hand darstellen										  */

	graf_mouse(FLAT_HAND, 0);

	del_x = mox - card[touched_card].x - 2;
	del_y = moy - card[touched_card].y;

	graf_dragbox(CARD_WIDTH - 4, get_move_length(touched_card),
							 card[touched_card].x + 2, card[touched_card].y,
											wwx, wwy, www, wwh, &mox, &moy);
	graf_mouse(ARROW, 0);

	mox += del_x;
	moy += del_y;

	/* Ziel des Verschiebens feststellen								  */

	if ((where_to = find_where_to(mox, moy)) == NO_CARD)
		return(0);

	/* Untersuchen ob zu verschiebende Karte Åberhaupt an das Ziel paût	  */

	if (!is_move_possible(touched_card, where_to))
	{
		if (card[touched_card].column != where_to)
			Cconout('\a');
		return(0);
	}

	/* Bei mehr als einer zu verschiebenden Karte untersuchen ob genÅgend */
	/* freie PlÑtze zur VerfÅgung stehen								  */

	if ((cards_to_move > 1) && !is_enough_room(cards_to_move, where_to))
	{
		Cconout('\a');
		return(0);
	}

	/* Wenn alle Bedingungen erfÅllt sind kann endlich verschoben werden  */

	if (cards_to_move == 1)
		move_card(touched_card, where_to, OFF);
	else
		move_multi_cards(touched_card, where_to);

	if (remaining_cards == 0)
		return(1);
	else
		return(0);
}


/*------------------------------------------------------------------------*/
/* find_card()															  */
/*	Stellt die Nummer der Karte an der Mausposition fest.				  */
/* ->  x- und y-Position der Maus										  */
/* <-  Nummer der angeklickten Karte (bzw. NO_CARD, wenn sich an der ent- */
/*	   sprechenden Stelle gar keine Karte befindet)						  */
/*------------------------------------------------------------------------*/


int find_card(int x, int y)
{
	int i;

	/* Positionen aller Karten mit der angeklickten Stelle vergleichen	  */

	for (i = 0; i < N; i++)
	{
		if ((x >= card[i].x) && (x < card[i].x + CARD_WIDTH) &&
							(y >= card[i].y) && (y < card[i].y + card[i].h))
			return(i);
	}

	return(NO_CARD);
}


/*------------------------------------------------------------------------*/
/* is_touch_possible()													  */
/*	Testet, ob die angeklickte Karte Åberhaupt den Regeln entsprechend	  */
/*	bewegt werden kann.													  */
/* ->  Nummer der zu bewegenden Karte									  */
/* <-  1 = alles ok, 0 = Karte kann nicht bewegt werden					  */
/*------------------------------------------------------------------------*/


int is_touch_possible(int card_no)
{
	int i, count;


	/* Zug von der Zwischenablage aus ist immer mîglich					  */

	if (card[card_no].column >= N + 4)
		return(1);

	/* RÅcknahme eines Karte von der Endablage ist verboten !			  */

	if (card[card_no].column >= N)
		return(0);

	/* Zug mit der letzten Karte einer Reihe ist im Prinzip immer mîglich */

	if ((i = card[card_no].next_card) == NO_CARD)
		return(1);

	/* Sonst muû ÅberprÅft werden ob die folgenden Karten in geordneter	  */
	/* Form vorliegen und dabei gleichzeitig zÑhlen, wieviele Karten zu	  */
	/* verschieben sind													  */

	count = 1;
	do
	{

	/* (card_no & 1) ergibt die Farbe einer Karte (nÑmlich 0 fÅr schwarz  */
	/* und 1 fÅr rot), wÑhrend mit (card_no >> 2) ihr Wert bestimmt wird  */

		if (((card_no & 1) ^ (i & 1)) && ((card_no >> 2) - 1 == (i >> 2)))
		{
			card_no = i;
			i = card[i].next_card;
			count++;
		}
		else
			return(0);
	} while (i != NO_CARD);

	return(count);
}


/*------------------------------------------------------------------------*/
/* get_move_length()													  */
/*	Stellt fest, wie lang (in Pixeln) die zu bewegende Reihe von Karten	  */
/*	ist.																  */
/* ->  Nummer der obersten zu bewegenden Karte							  */
/* <-  LÑnge (in Pixeln) der zu verschiebenden Reihe					  */
/*------------------------------------------------------------------------*/


int get_move_length(int card_no)
{
	if (card[card_no].column < N)
		return(column[card[card_no].column].h + TOP_ROW + wwy -
														   card[card_no].y);
	else
		return(CARD_LENGTH);
}


/*------------------------------------------------------------------------*/
/* find_where_to()														  */
/*	Stellt die Nummer der Reihe fest, an die die zu bewegende(n) Karte(n) */
/*	angelegt werden soll(en).											  */
/* ->  x- und y-Position der Zielkarte									  */
/* <-  Nummer der Zielreihe (bzw. NO_CARD wenn keine vorhanden)			  */
/*------------------------------------------------------------------------*/


int find_where_to(int x, int y)
{
	int i;


	/* Nach passender Reihe suchen ...									  */

	if (y >= wwy + TOP_ROW)
	{
		for (i = 0; i < NUM_COLUMNS; i++)
			if ((x >= column[i].x) && (x < column[i].x + CARD_WIDTH))
				return(i);
		return(NO_CARD);
	}

	/* ... sonst mit Positionen der End- und Zwischenablage vergleichen	  */

	for (i = N; i < N + 8; i++)
	{
		if ((x >= card[i].x) && (x < card[i].x + CARD_WIDTH) &&
							(y >= card[i].y) && (y < card[i].y + card[i].h))
			return(i);
	}

	return(NO_CARD);
}


/*------------------------------------------------------------------------*/
/* is_enough_room()														  */
/*	Testet, ob genÅgend freie PlÑtze in der Zwischenablage sowie leere	  */
/*	Reihen vorhanden sind, um die geplante Verschiebung durchzufÅhren.	  */
/* ->  Zahl der zu verschiebenden Karten und Nummer der Zielreihe		  */
/* <-  1 = alles ok, 0 = nicht genÅgend freie PlÑtze					  */
/*------------------------------------------------------------------------*/


int is_enough_room(int no, int dest)
{
	int free_temp = 0, free_place = 0;
	int i;


	/* Ein Mehrfachzug auf die End- oder Zwischenablage ist nicht mîglich */

	if (dest >= NUM_COLUMNS)
		return(0);

	/* Jetzt feststellen wieviele freie Reihen und leere Zwischenablage-  */
	/* plÑtze es gibt													  */

	for (i = 0; i < NUM_COLUMNS; i++)
		if (column[i].first_card == NO_CARD)
			free_place++;

	for (i = N + 4; i < N + 8; i++)
		if (card[i].prev_card == NO_CARD)
			free_temp++;

	/* Falls die Zielposition einer der freien PlÑtze ist, so kann er	  */
	/* nicht als Zwischenlagerplatz genutzt werden						  */

	if (column[dest].first_card == NO_CARD)
		free_place--;

	/* Nun berechnen wieviele Karten maximal bewegt werden kînnen		  */

	if (get_max_no(free_place, free_temp) >= no)
		return(1);
	else
		return(0);
}


/*------------------------------------------------------------------------*/
/* get_max_no()															  */
/*	Berechnet, wieviele Karten bei gegebener Anzahl von freien Reihen und */
/*	freien PlÑtzen in der Zwischenablage verschoben werden kînnen		  */
/* ->  Anzahl der freien Reihen und ZwischenablageplÑtze				  */
/* <-  Anzahl der maximal zu verschiebenden Karten						  */
/*------------------------------------------------------------------------*/


int get_max_no(int place, int temp)
{
	int max_no = 0;


	/* Bei bester Ausnutzung der PlÑtze passen auf die erste freie Reihe  */
	/* (temp + 1) Karten (temp ist die Anzahl der freien Zwischenablage-  */
	/* plÑtze), auf die zweite 2 * (temp + 1) usw., und zum Schluû kîn-	  */
	/* nen noch temp Karten in die Zwischenablage gelegt werden und eine  */
	/* weitere Karte verschoben werden.									  */

	while (place > 0)
		max_no += place-- * (temp + 1);

	return(max_no + temp + 1);
}



/*------------------------------------------------------------------------*/
/* is_move_possible()													  */
/*	Untersucht, ob ein Verschieben (den Spielregeln entsprechend) mîglich */
/*	ist.																  */
/* ->  Nummer der (obersten) zu bewegenden Karte und Nummer der Zielreihe */
/* <-  1 = alles ok, 0 = Zug ist nicht mîglich							  */
/*------------------------------------------------------------------------*/


int is_move_possible(int source, int dest)
{
	int j;


	/* RÅcknahme von der Endablage ist nicht erlaubt !					  */

	if ((card[source].column >= N) && (card[source].column < N + 4))
		return(0);

	/* Bei Reihe als Ziel auf KompatibilitÑt mit dem Wert der letzten	  */
	/* Karte in der Reihe untersuchen									  */

	if (dest <= NUM_COLUMNS)
	{
		if ((j = column[dest].first_card) == NO_CARD)
			return(1);
		while (card[j].next_card != NO_CARD)
			j = card[j].next_card;

		return(((source & 1) ^ (j & 1)) &&
										 ((j >> 2) == ((source >> 2) + 1)));
	}

	/* Bei Ablage auf der Endablage untersuchen, ob die Karte paût		  */

	if (dest < N + 4)
	{
		if (card[dest].prev_card == NO_CARD)
		{
			if (dest - N != source)
				return(0);
			else
				return(1);
		}

		if (((card[dest].prev_card & 3) == (source & 3)) &&
						 ((card[dest].prev_card >> 2) + 1 == (source >> 2)))
			return(1);
		else
			return(0);
	}

	/* Bei Zwischenablage als Ziel untersuchen, ob die Position frei ist  */

	if ((dest < (N + 8)) && (card[dest].prev_card == NO_CARD))
		return(1);
	else
		return(0);
}


/*------------------------------------------------------------------------*/
/* wait_for_left_release()												  */
/*	Wartet auf Loslassen der linken Maustaste.							  */
/*------------------------------------------------------------------------*/


void wait_for_left_release(void)
{
	int dummy;

	evnt_button(0, 1, 0, &dummy, &dummy, &dummy, &dummy);
}


/*------------------------------------------------------------------------*/
/* move_card()															  */
/*	Verschiebt einzelne Karte.											  */
/* ->  Nummer der zu verschiebenden Karte, Nummer der Zielreihe (bzw.	  */
/*	   End- oder Zwischenablage) sowie Flag, das anzeigt, ob MBOX beim	  */
/*	   Verschieben gezeigt werden soll									  */
/*------------------------------------------------------------------------*/


void move_card(int source, int dest, int mbox_flag)
{
	int j, dest_x, dest_y;


	/* AES an Aktionen auf dem Bildschirm hindern						  */

	wind_update(BEG_UPDATE);

	/* Falls erwÅnscht, MBOX von der Ausgangskarte zur Zielkarte anzeigen */

	if (mbox_flag)
	{
		if (dest >= N)				/* Karte auf End- oder Zwischenablage */
		{
			graf_mbox(CARD_WIDTH, CARD_LENGTH, card[source].x,
								card[source].y, card[dest].x, card[dest].y);
		}
		else									 /* Anlegen an eien Reihe */
		{
			j = column[dest].first_card;
			if (j != NO_CARD)					  /* Zielreihe nicht leer */
			{
				while (card[j].next_card != NO_CARD)
					j = card[j].next_card;

				dest_x = card[j].x;
				dest_y = card[j].y;
			}
			else								   /* Zielreihe noch leer */
			{
				dest_x = column[dest].x;
				dest_y = wwy + TOP_ROW;
			}

			graf_mbox(CARD_WIDTH, CARD_LENGTH, card[source].x,
										   card[source].y, dest_x , dest_y);
		}
	}

	/* Zug abspeichern ...												  */

	if (!(menu[T1E4].ob_state & DISABLED))
		save_move(card[source].column, dest);

	/* Karte von ihrer alten Position entfernen							  */

	take_away(source);

	/* bei Ablage auf End- oder Zwischenablage :						  */

	if (dest >= N)
	{
		card[source].x = card[dest].x;
		card[source].y = card[dest].y;
		card[source].h = CARD_LENGTH;
		card[source].column = dest;
		card[source].prev_card = card[source].next_card = NO_CARD;
		card[dest].prev_card = source;
		show_card(source, ON);

	/* Bei Ablage auf Endablage Restkartenzahl dekrementieren			  */

		if ((dest >= N) && (dest < N +4))
			remaining_cards--;

	/* AES-Aktionen auf dem Bildschirm wieder zulassen und fertig		  */

		wind_update(END_UPDATE);
		return;
	}
	
	/* bei Ablage am Ende einer Reihe									  */

	j = column[dest].first_card;
	if (j != NO_CARD)					  /* Reihe enthÑlt schon Karte(n) */
	{
		while (card[j].next_card != NO_CARD)
			j = card[j].next_card;
		card[source].x = card[j].x;
		card[source].y = card[j].y + column[card[j].column].del_y;
		card[source].h = CARD_LENGTH;
		card[source].column = card[j].column;
		card[j].next_card = source; 
		card[source].prev_card = j;
		card[source].next_card = NO_CARD;
		card[j].h = column[dest].del_y;
	}
	else				  /* sonst bildet die neue Karte eine neue Reihe  */
	{
		card[source].x = column[dest].x;
		card[source].y = wwy + TOP_ROW;
		card[source].h = CARD_LENGTH;
		card[source].column = dest;
		card[source].prev_card = card[source].next_card = NO_CARD;
		column[dest].first_card = source;
	}

	/* Wenn die Reihe durch die neue Karte zu lang wird, um noch in das	  */
	/* Fenster zu passen, muû die ganze Reihe neu gezeichnet werden,	  */
	/* sonst nur die neue Karte ans Ende der Reihe zeichnen				  */

	if ((card[source].y + CARD_LENGTH) < (wwy + wwh - 1))
	{
		show_card(source, ON);
		if (column[card[source].column].h == 0)
			column[dest].h = CARD_LENGTH;
		else
			column[card[source].column].h +=
										  column[card[source].column].del_y;
	}
	else
		show_column(card[source].column, column[card[source].column].x, ON);

	/* AES-Aktionen auf dem Bildschirm wieder zulassen					  */

	wind_update(END_UPDATE);
}


/*------------------------------------------------------------------------*/
/* take_away()															  */
/*	Entfernt Karte von ihrer augenblicklichen Position.					  */
/* ->  Nummer der zu entfernenden Karte									  */
/*------------------------------------------------------------------------*/


void take_away(int card_no)
{
	int i;


	/* Clipping auf Bereich der Karte einstellen						  */

	clip_array[0] = MAX(card[card_no].x, 0);
	clip_array[1] = MAX(card[card_no].y, 0);
	clip_array[2] = MIN(card[card_no].x + CARD_WIDTH - 1, scr_x);
	clip_array[3] = MIN(card[card_no].y + CARD_LENGTH - 1, scr_y);

	vs_clip(wkst_handle, ON, clip_array);

	/* Wenn die Karte in einer Reihe liegt muû sie mit dem Muster des	  */
	/* Hintergrunds Åbermalt werden und die darÅberliegenden Karten z. T. */
	/* neu gemalt werden, u. U. muû bei gestauchten Reihen auch die ganze */
	/* Reihe neu gezeichnet werden										  */

	if (card[card_no].column < NUM_COLUMNS)
	{
		paint_background();

		i = card[card_no].prev_card;
		if (i != NO_CARD)
		{
			card[i].h = CARD_LENGTH;
			card[i].next_card = NO_CARD;
			if (column[card[card_no].column].del_y == CARD_Y_SPAC)
			{
				show_card(i, ON);
				column[card[card_no].column].h -= CARD_Y_SPAC;
			}
			else
				show_column(card[card_no].column,
										column[card[card_no].column].x, ON);
		}

	/* Bei der Zwischenablage muû nur diese neu (leer) gezeichnet werden, */
	/* bei der Endablage u. U. die darunterliegende Karte				  */

		else
		{
			column[card[card_no].column].first_card = NO_CARD;
			column[card[card_no].column].h = 0;
		}
	}
	else
	{
		if (card[card_no].column >= N + 4)
			card[card[card_no].column].prev_card = NO_CARD;
		else
		{
			if (card_no > 3)
				card[card[card_no].column].prev_card -= 4;
			else
				card[card[card_no].column].prev_card = NO_CARD;
		}

		if (card[card[card_no].column].prev_card == NO_CARD)
			show_card(card[card_no].column, ON);
		else
			show_card(card[card[card_no].column].prev_card, ON);
	}
}


/*------------------------------------------------------------------------*/
/* move_multi_cards()													  */
/*	Verschiebt eine ganze Reihe von Karten								  */
/* ->  Nummer der obersten Karte der zu verschiebenden Reihe und Nummer	  */
/*	   der Zielreihe													  */
/*------------------------------------------------------------------------*/


void move_multi_cards(int source, int dest)
{
	int free_place[NUM_COLUMNS], max_place = 0, num_place;
	int free_temp[4], max_temp = 0, num_temp;
	int i, k, place_first = OFF;


	/* Zuerst die Lage der freien Reihen sowie ihre Anzahl bestimmen -	  */
	/* eine leere Zielreihe darf aber nicht berÅcksichigt werden !		  */

	for (i = 0; i < NUM_COLUMNS; i++)
	{
		if (i == dest)
			continue;
		if (column[i].first_card == NO_CARD)
			free_place[max_place++] = i;
	}

	/* Ebenso die Position und Anzahl der freien ZwischenablageplÑtze	  */

	for (i = N + 4; i < N + 8; i++)
	{
		if (card[i].prev_card == NO_CARD)
			free_temp[max_temp++] = i;
	}

	/* Nun kommt die groûe Hin- und Herschieberei ...					  */

	free_place[max_place] = dest;

	num_temp = max_temp;
	num_place = max_place;

	/* Solange noch nicht alle freien PlÑtze belegt sind ...			  */

	k = 0;
	while (k < max_place)
	{
		num_place = max_place;

	/* Alle freien PlÑtze Åber die Zwischenablage mit Karten belegen -	  */
	/* wenn die letzte zu verschiebende Karte dabei erreicht wird ab-	  */
	/* brechen															  */

		while (num_place > k)
		{
			if (move_column_to_temp(card[source].column, source, free_temp,
																 &num_temp))
				goto reverse_multi;

			if (move_single_card(card[source].column, source, free_place,
															 num_place - 1))
			{
				place_first = ON;
				goto reverse_multi;
			}

			move_temp_to_column(free_temp, &num_temp, max_temp,
											 *(free_place + num_place - 1));
			num_place--;
		}

	/* Und diese auf die freien PlÑtze verteilten Karten wieder auf	den	  */
	/* am weitesten links liegenden freien PlÑtze umschichten			  */

		while (++num_place < max_place)
		{
			move_column_to_temp(*(free_place + num_place), NO_CARD,
													  free_temp, &num_temp);
			move_single_card(*(free_place + num_place), NO_CARD,
															 free_place, k);
			move_temp_to_column(free_temp, &num_temp, max_temp,
														 *(free_place + k));
		}

		k++;
	}

	/* Zum Schluû auch noch die wieder freien ZwischenablageplÑtze mit	  */
	/* Karten fÅllen													  */

	move_column_to_temp(card[source].column, source, free_temp, &num_temp);

reverse_multi:

	/* Jetzt als erstes die letzte (oberste) Karte der zu verschiebenden  */
	/*  Reihe an die Zielreihe anlegen ...								  */

	move_single_card(card[source].column, NO_CARD, free_place, max_place);

	/* ... und die Zwischenablage daran anlegen	(gegebenfalls vorher noch */
	/* die einzelne Karte vom freien Platz holen) 						  */

	if (place_first)
		move_single_card(*(free_place + num_place - 1), NO_CARD, free_place,
																 max_place);

	move_temp_to_column(free_temp, &num_temp, max_temp, dest);

	/* Zum Schluû die gesamten auf die freien PlÑtze umgeschichteten Kar- */
	/* ten anlegen. Zuerst die nicht vollstÑndig umgelegten Haufen wieder */
	/* in richtiger Ordnung an die Zielreihe anlegen ...				  */

	k = num_place;
	while (k < max_place)
	{
		if (column[*(free_place + k)].first_card == NO_CARD)
			continue;

		move_column_to_temp(*(free_place + k), NO_CARD,
													  free_temp, &num_temp);
		move_single_card(*(free_place + k), NO_CARD, free_place, max_place);
		move_temp_to_column(free_temp, &num_temp, max_temp,
												 *(free_place + max_place));
		k++;
	}

	/* ... dann die restlichen Haufen auseinandernehmen und an die Ziel-  */
	/* reihe anlegen													  */

	while (num_place-- > 0)
	{
		/* Wenn keine Karte auf der Reihe liegt, nÑchste Reihe probieren  */

		if (column[*(free_place + num_place)].first_card == NO_CARD)
			continue;

		/* Reihe in Einzelteile zerlegen ...							  */

		k = max_place - 1;
		while (k > num_place)
		{
			move_column_to_temp(*(free_place + num_place), NO_CARD,
													  free_temp, &num_temp);
			move_single_card(*(free_place + num_place), NO_CARD, free_place,
																		 k);
			move_temp_to_column(free_temp, &num_temp, max_temp,
														 *(free_place + k));
			k--;
		}

		/* ... und nacheinander an der Zielreihe anlegen				  */

		k = num_place;
		while (k < max_place)
		{
			move_column_to_temp(*(free_place + k), NO_CARD,
													  free_temp, &num_temp);
			move_single_card(*(free_place + k), NO_CARD,
													 free_place, max_place);
			move_temp_to_column(free_temp, &num_temp, max_temp,
												 *(free_place + max_place));
			k++;
		}
	}
}


/*------------------------------------------------------------------------*/
/* move_temp_to_column()												  */
/*	Legt den Inhalt der Zwischenablage, der dort vorher mit der Funktion  */
/*	move_column_to_temp() abgelegt wurde in richtiger Reihenfolge wieder  */
/*	an einer Reihe an. (Diese Funktion wird nur von move_multi_cards()	  */
/*	benîtigt.)															  */
/* ->  Pointer auf Liste der von move_column_to_temp() verwendeten freien */
/*	   PlÑtze in der Zwischenablage, Pointer auf Anzahl der zu verschie-  */
/*	   benden Karten, maximale Anzahl der freien PlÑtze in der Zwischen-  */
/*	   ablage sowie Nummer der Zielreihe								  */
/*------------------------------------------------------------------------*/


void move_temp_to_column(int *free_temp, int *act_temp, int max_temp,
																   int dest)
{
	int next;


	/* Zuerst die letzte Karte der Zielreihe bestimmen					  */

	next = column[dest].first_card;
	while (card[next].next_card != NO_CARD)
		next = card[next].next_card;

	/* Nun alle Karten von der Zwischenablage auf die Reihe schieben	  */

	while (++(*act_temp) < max_temp)
		move_card(card[*(free_temp + *act_temp)].prev_card, dest, ON);
}


/*------------------------------------------------------------------------*/
/* move_single_card()													  */
/*	Verschiebt eine einzelne Karte von einer Reihe zu einer anderen.	  */
/*	(Diese Funktion wird nur von move_multi_cards() benîtigt.)			  */
/* ->  Nummer der Ausgangsreihe, Nummer der obersten Karte der insgesamt  */
/*	   zu bewegenden Reihe, Liste der leeren Reihen sowie Anzahl der	  */
/*	   freien Reihen													  */
/* <-  1 = Karte Åber der bewegten Karte ist die oberste Karte der insge- */
/*	   samt zu bewegenden Reihe, 0 = sonst								  */
/*------------------------------------------------------------------------*/


int move_single_card(int source_column, int final_card, int *free_place,
														 int act_free_place)
{
	int next, inter;

	/* Wenn gar keine Karte da ist sofort abbrechen						  */

	if ((next = column[source_column].first_card) == NO_CARD)
		return(0);

	/* Sonst die zu verschiebende Karte bestimmen ...					  */
	
	while (card[next].next_card != NO_CARD)
		next = card[next].next_card;

	inter = card[next].prev_card;

	/* ... und verschieben												  */

	move_card(next, *(free_place + act_free_place), ON);

	if (inter == final_card)
		return(1);
	else
		return(0);
}


/*------------------------------------------------------------------------*/
/* move_column_to_temp()												  */
/*	Verschiebt die Karten aus einer Reihe in die Zwischenablage, bis die- */
/*	gefÅllt ist oder aber die nÑchste zu verschiedene Karte die oberste	  */
/*	Karte der zu verschiebenden Reihe ist. (Diese Funktion wird nur von	  */
/*	move_multi_cards() benîtigt.)										  */
/* ->  Nummer der Ausgangsreihe, Nummer der letzten Åberhaupt zu ver-	  */
/*	   schiebenden Karte, Array mit Nummern der freien Zwischenablage-	  */
/*	   plÑtze sowie Pointer auf deren Anzahl							  */
/* <-  1 = Karte Åber der bewegten Karte ist die oberste Karte der insge- */
/*	   samt zu bewegenden Reihe, 0 = sonst								  */
/*------------------------------------------------------------------------*/


int move_column_to_temp(int source_column, int final_card, int *free_temp,
														 int *act_free_temp)
{
	int next, inter;


	/* Wenn gar keine Karte da ist sofort abbrechen						  */

	if ((next = column[source_column].first_card) == NO_CARD)
		return(0);

	/* Sonst erst einmal die unterste zu verschiebende Karte bestimmen	  */

	while (card[next].next_card != NO_CARD)
		next = card[next].next_card;

	/* Nun soviele Karten in die Zwischenablage schieben, bis sie entwe-  */
	/* der voll ist oder die nÑchste zu verschiebende Karte die oberste	  */
	/* der zu verschiebenden Reihe ist (oder die Reihe leer ist)		  */

	(*act_free_temp)--;
	while (*act_free_temp >= 0)
	{
		inter = card[next].prev_card;

		move_card(next, *(free_temp + *act_free_temp), ON);
		(*act_free_temp)--;

		if (inter == NO_CARD)
			return(0);

		if (inter == final_card)
			return(1);
		else
			next = inter;
	}

	return(0);
}


/*------------------------------------------------------------------------*/
/* move_multi_to_temp()													  */
/*	Verschiebt mehrere Karten gleichzeitig in die Zwischenablage.		  */
/* ->  Nummer der obersten Karte der zu verschiebenden Reihe			  */
/*------------------------------------------------------------------------*/


void move_multi_to_temp(int card_no)
{
	int free_temp[4], num_temp = 0, i, no = 1, next;


	/* Zuerst Anzahl der freien ZwischenablageplÑtze bestimmen und Array  */
	/* mit ihren Nummern besetzen										  */

	for (i = N + 4; i < N + 8; i++)
	{
		if (card[i].prev_card == NO_CARD)
			free_temp[num_temp++] = i;
	}

	/* Anzahl der auf Zwischenablage zu verschienenden Karten bestimmen	  */

	next = card_no;
	while ((next = card[next].next_card) != NO_CARD)
		no++;

	/* Abbruch, wenn die Anzahl der freien PlÑtze nicht ausreicht		  */

	if (no > num_temp)
	{
		Cconout('\a');
		wait_for_left_release();
		return;
	}

	/* Karten auf die Zwischenablage verschieben						  */

	move_column_to_temp(card[card_no].column, card[card_no].prev_card,
													 free_temp, & num_temp);

	/* Warten, bis der linke Mausbutton wieder losgelassen ist (anderen-  */
	/* falls befindet sich die Maus u. U. noch auf einer Karte und die	  */
	/* gedrÅcken Mausbuttons wÅrden als Befehlswiederholung interpretiert */

	wait_for_left_release();
}


/*------------------------------------------------------------------------*/
/* show_card()															  */
/*	Dient zur tatsÑchliche Darstellung einer Karte auf dem Bildschirm.	  */
/* ->  Nummer der darzustellenden Karte sowie Flag, das anzeigt, ob Clip- */
/*	   ping-Bereich gesetzt werden soll (bei Aufruf dieser Funktion durch */
/*	   wind_redraw() ist Clipping bereits gesetzt)						  */
/*------------------------------------------------------------------------*/


void show_card(int card_no, int clip_flag)
{
	int copy_array[8];
	MFDB source, dest;


	/* MFDBs fÅr Kopieren der Karten vorbereiten						  */

	source.fd_w = CARD_WIDTH;
	source.fd_h = CARD_LENGTH;
	source.fd_wdwidth = CARD_WIDTH / 16;
	source.fd_stand = 0;
	source.fd_nplanes = nplanes;
	
	dest.fd_addr = 0L;

	/* Array mit Positionen fÅrs Kopieren vorbereiten					  */

	copy_array[0] = copy_array[1] = 0;
	copy_array[2] = CARD_WIDTH - 1;
	copy_array[3] = CARD_LENGTH - 1;

	copy_array[4] = card[card_no].x;
	copy_array[5] = card[card_no].y;
	copy_array[6] = copy_array[4] + CARD_WIDTH - 1;
	copy_array[7] = copy_array[5] + CARD_LENGTH - 1;

	v_hide_c(wkst_handle);

	/* Wenn Clipping gesetzt werden soll, dies auf Bereich der Karte ein- */
	/* stellen															  */

	if (clip_flag)
	{
		clip_array[0] = MAX(copy_array[4], 0);
		clip_array[1] = MAX(copy_array[5], 0);
		clip_array[2] = MIN(copy_array[6], scr_x);
		clip_array[3] = MIN(copy_array[7], scr_y);
		vs_clip(wkst_handle, ON, copy_array + 4);
	}

	/* Maske auf neue Position (mit AND-VerknÅpfung) kopieren			  */

	source.fd_addr = (void *) (pic + 57 * CARD_SIZE * nplanes);
	vro_cpyfm(wkst_handle, S_AND_D, copy_array, &source, &dest);

	/* Karte (mit OR-VerknÅpfung) auf neue Position kopieren		  	  */

	source.fd_addr = (void *) (pic + MIN(card_no, N + 4) * CARD_SIZE *
																   nplanes);
	vro_cpyfm(wkst_handle, S_OR_D, copy_array, &source, &dest);

	v_show_c(wkst_handle, 0);
}


/*------------------------------------------------------------------------*/
/* shuffle()															  */
/*	Dient zum Mischen der Karten sowie der anschlieûenden Verkettung der  */
/*	Karten zu Listen fÅr die einzelnen Reihen.							  */
/*------------------------------------------------------------------------*/


void shuffle(void)
{
	int s_array[N];					/* Array fÅr Mischen der Karten		  */
	int index, i, j, k;
	double f_index;


	/* ZÑhler fÅr Anzahl der bereits erfolgten ZÅge auf Null setzen und	  */
	/* den fÅr Anzahl der Karten auf der SpielflÑche auf N				  */

	move_no = 0;
	remaining_cards = N;

	/* Speicherbereiche fÅr Speicherung der ZÅge des letzten Spiels frei- */
	/* geben															  */

	if (no_history)
	{
		if (history)
		{
			no_history = OFF;
			menu_ienable(menu, T1E4, ON);
		}
	}
	else
	{
		while (!shorten_history())
			;
	}

	/* Array fÅrs Mischen (geordnet) vorbesetzen						  */

	for (i = 0; i < N; i++)
		*(s_array + i) = i;

	/* Mischen, indem zuerst die letzte Karte mit irgendeiner anderen	  */
	/* vertauscht wird, dann die vorletzte, dann die vorvorletzte ...	  */

	for (i = N - 1; i > 0; i--)
	{
		f_index = (double) i * random_generator();
		index = (int) (2.0 * f_index) - (int) f_index;
		k = *(s_array + i);
		*(s_array + i) = *(s_array + index);
		*(s_array + index) = k;
	}

	/* Liste der Karten verketten (erste Karte hat keinen VorgÑnger, die  */
	/* letzte keinen Nachfolger)										  */

	card[*s_array].prev_card = NO_CARD;
	card[*s_array].next_card = *(s_array + 1);

	for (i = 1; i < N - 1; i++)
	{
		card[*(s_array + i)].prev_card = *(s_array + i - 1);
		card[*(s_array + i)].next_card = *(s_array + i + 1);
	}

	card[*(s_array + N - 1)].prev_card = *(s_array + N - 2);
	card[*(s_array + N - 1)].next_card = NO_CARD;

	/* Liste in Teilketten fÅr einzelne Reihen zerlegen (die erste Karte  */
	/* in einer Reihe hat keinen VorgÑnger, die letzte keinen Nachfolger) */

	for (i = *s_array, j = 0; j < NUM_COLUMNS; j++)
	{
		column[j].first_card = i;
		card[i].prev_card = NO_CARD;

		for (k = 0; k < ((j < 4) ? 6 : 5); k++)
			i = card[i].next_card;

		k = card[i].next_card;
		card[i].next_card = NO_CARD;
		i = k;
	}

	/* Zeiger in den Strukturen fÅr End- und Zwischenablage auf die dar-  */
	/* auf liegende Karte auf 'keine Karte' setzen						  */

	for (i = N; i < N + 8; i++)
		card[i].prev_card = NO_CARD;
}


/*------------------------------------------------------------------------*/
/* show_all()															  */
/*	Neudarstellung des gesamten Spielfeldes, also Zeichnen des Hinter-	  */
/*	grundes, der Zwischen-und Endablage sowie der Karten. Auûerdem werden */
/*	dabei diverse EintrÑge in den Strukturen fÅr die Karten gesetzt.	  */
/* ->  Flag, das anzeigt, ob die gesamte SpielflÑche oder nur ein Aus-	  */
/*	   schnitt neu gezeichnet werden muû - im ersten Fall muû vorher	  */
/*	   der entsprechende Clipping-Bereich gesetzt sein					  */
/*------------------------------------------------------------------------*/


void show_all(int all_flag)
{
	int i, j, card_x;


	/* Hintergrund zeichnen												  */

	if (all_flag)
	{
		wind_update(BEG_UPDATE);
		clip_array[0] = MAX(wwx, 0);
		clip_array[1] = MAX(wwy, 0);
		clip_array[2] = MIN(wwx + www - 1, scr_x);
		clip_array[3] = MIN(wwy + wwh - 1, scr_y);
		vs_clip(wkst_handle, ON, clip_array);
	}

	paint_background();

	/* PlÑtze fÅr die Zwischenablage zeichnen, vorher einige EintrÑge in  */
	/* den Strukturen (neu) setzen										  */

	card_x = wwx + CARD_X_SPAC;
	for (i = N + 4; i < N + 8; i++, card_x += CARD_WIDTH + CARD_X_SPAC)
	{
		card[i].x = card_x;
		card[i].y = wwy + 3;
		card[i].h = CARD_LENGTH;
		if (card[i].prev_card == NO_CARD)
			show_card(i, all_flag);
		else
		{
			j = card[i].prev_card;
			card[j].x = card_x;
			card[j].y = wwy + 3;
			card[j].h = CARD_LENGTH;
			show_card(j, all_flag);
		}
	}

	/* PlÑtze fÅr Endablage zeichnen, ebenfalls einige EintrÑge in den	  */
	/* Strukuren (neu) setzen											  */

	card_x = wwx + MAX((www - 4 * (CARD_WIDTH + CARD_X_SPAC)),
							  (www - 8 * CARD_WIDTH - 7 * CARD_X_SPAC) / 2);
	for (i = N; i < N + 4; i++, card_x += CARD_WIDTH + CARD_X_SPAC)
	{
		
		card[i].x = card_x;
		card[i].y = wwy + 3;
		card[i].h = CARD_LENGTH;
		if (card[i].prev_card == NO_CARD)
			show_card(i, all_flag);
		else
		{
			j = card[i].prev_card;
			while (j >= 0)
			{
				card[j].x = card_x;
				card[j].y = wwy + 3;
				card[j].h = CARD_LENGTH;
				j -= 4;
			}
			show_card(card[i].prev_card, all_flag);
		}
	}

	/* Karten auslegen indem alle Reihen gezeichnet werden				  */

	card_x = wwx + (www - NUM_COLUMNS * CARD_WIDTH - (NUM_COLUMNS - 1) *
														   CARD_X_SPAC) / 2;
	for (i = 0; i < NUM_COLUMNS; i++, card_x += CARD_WIDTH + CARD_X_SPAC)
		show_column(i, card_x, all_flag);

	/* AES-Aktionen auf dem Bildschirm wieder zulassen					  */

	if (all_flag)
		wind_update(END_UPDATE);
}


/*------------------------------------------------------------------------*/
/* show_column()														  */
/*	Darstellung einer ganzen Reihe inklusive der Berechnung der öber-	  */
/*	lappungslÑnge der Karten.											  */
/* ->  Nummer der Reihe, deren x-Position sowie Flag, das anzeigt, ob	  */
/*	   kein Clipping gesetzt wird (nur fÅr Weitergabe an show_card()	  */
/*	   und clear_column() von Bedeutung)	 							  */
/*------------------------------------------------------------------------*/


void show_column(int col_no, int card_x, int clip_flag)
{
	int j, k;
	int card_y, del_y;


	/* Paramter in Struktur fÅr Reihe setzen							  */

	column[col_no].x = card_x;
	column[col_no].h = 0;
	column[col_no].del_y = CARD_Y_SPAC;

	/* Schon fertig, wenn die Reihe keine Karte enthÑlt					  */

	if ((k = column[col_no].first_card) == NO_CARD)
		return;

	/* Sonst Anzahl der Karten in der Reihe bestimmen und daraus die	  */
	/* öberlappungsbreite der Karten berechnen							  */

	j = 1;
	while ((k = card[k].next_card) != NO_CARD)
		j++;

	card_y = wwy + TOP_ROW;
	if (j > 1)
		del_y = MIN(CARD_Y_SPAC, (wwh - CARD_LENGTH - TOP_ROW) / (j - 1));

	column[col_no].del_y = del_y;

	/* Bereich der Reihe vollstÑndig lîschen ...						  */

	clear_column(col_no, clip_flag);

	/* ... und alle Karten der Reihe nach neu zeichnen					  */

	k = column[col_no].first_card;
	do
	{
		card[k].x = card_x;
		card[k].y = card_y;
		card[k].column = col_no;
		if (card[k].next_card != NO_CARD)
			card[k].h = del_y;
		else
			card[k].h = CARD_LENGTH;

		show_card(k, clip_flag);

		column[col_no].h += card[k].h;
		card_y += del_y;
		k = card[k].next_card;
	} while (k != NO_CARD);
}


/*------------------------------------------------------------------------*/
/* automatic_remove()													  */
/*	Entfernt alle Karten aus dem Spiel, fÅr die dies mîglich ist und die  */
/*	mit Sicherheit nicht mehr im Verlauf des Spiels gebraucht werden.	  */
/* <-  1 = Spiel ist zu Ende, 0 = noch nicht alle Karten abgelegt		  */
/*------------------------------------------------------------------------*/


int automatic_remove(void)
{
	int i, j;
	int value;
	int no_remove;


	/* Solange Karten entfernen, bis keine zu entfernende Karte mehr ge-  */
	/* funden wird														  */

	do
	{
		no_remove = ON;

		/* Zuerst mîgliche ZÅge von der Zwischenablage aus untersuchen	  */

		for (i = N + 4; i < N + 8; i++)
		{

		/* NÑchsten Platz testen, wenn der aktuelle Zwischenablageplatz	  */
		/* keine Karte enthÑlt											  */

			if (card[i].prev_card == NO_CARD)
				continue;

		/* Ebenfalls, wenn Karte nicht auf entsprechende Endablage paût	  */

			value = card[i].prev_card >> 2;
			if (value - 1 !=
						 (card[(card[i].prev_card & 3) + N].prev_card >> 2))
				continue;

		/* Oder auch, wenn niedrigere Karten der Gegenfarbe noch nicht	  */
		/* abgelegt sind (auûer bei As und 2)							  */

			if (value > 1)
			{
				if (card[i].prev_card & 1)
				{
					if (((card[N].prev_card >> 2 ) < value - 1) ||
								((card[N + 2].prev_card >> 2 ) < value - 1))
						continue;
				}
				else
				{
					if (((card[N + 1].prev_card >> 2 ) < value - 1) ||
								((card[N + 3].prev_card >> 2 ) < value - 1))
						continue;
				}
			}

		/* Sonst Karte auf Endablage legen und Flag zurÅcksetzen		  */

			move_card(card[i].prev_card, N + (card[i].prev_card & 3), ON);
			no_remove = OFF;
		}

		/* Nun auch alle Reihen untersuchen								  */

		for (i = 0; i < NUM_COLUMNS; i++)
		{

		/* Weiter mit nÑchster Reihe wenn die Reihe keine Karten enthÑlt  */

			if ((j = column[i].first_card) == NO_CARD)
				continue;

		/* Letzte Karte der Reihe bestimmen								  */

			for ( ; card[j].next_card != NO_CARD; j = card[j].next_card)
				;

		/* Weiter mit nÑchster Reihe, wenn Karte nicht auf die entspre-	  */
		/* chende Endablage paût										  */

			value = j >> 2;
			if (value - 1 != (card[(j & 3) + N].prev_card >> 2))
				continue;

		/* Oder wenn niedrigere Karten der Gegenfarbe noch nicht abgelegt */
		/* sind (auûer bei As und 2)									  */

			if (value > 1)
			{
				if (j & 1)
				{
					if (((card[N].prev_card >> 2 ) < value - 1) ||
								((card[N + 2].prev_card >> 2 ) < value - 1))
						continue;
				}
				else
				{
					if (((card[N + 1].prev_card >> 2 ) < value - 1) ||
								((card[N + 3].prev_card >> 2 ) < value - 1))
						continue;
				}
			}

		/* Sonst Karte auf Endablage legen und Flag zurÅcksetzen		  */

			move_card(j, N + (j & 3), ON);
			no_remove = OFF;
		}
	} while (!no_remove);

	if (remaining_cards == 0)
		return(1);
	else
		return(0);
}


/*------------------------------------------------------------------------*/
/* make_seed()															  */
/*	Berechnet (aus ZÑhler des 200-Hz-Timer-Interrupts und dem Datum) eine */
/*	sechsstellige Pseudozufallszahl (0 <= x < 1), die als Ausgangszahl	  */
/*	fÅr den Zufallsgenerators fÅr das Mischen verwendet wird.			  */
/* <-  Pseudozufallszahl												  */
/*------------------------------------------------------------------------*/


double make_seed(void)
{
	long old_stack, temp;


	/* Als Startwert des Zufallsgenerators die Summe aus Zahl der Timer-  */
	/* Interrupts und Datum (mod 1,000,000) verwenden					  */

	old_stack = Super(NULL);
	temp = *(long *) _hz_200;
	Super((void *) old_stack);

	temp += Gettime();

	return((double) (temp % 1000000L) * 1.E-6);
}


/*------------------------------------------------------------------------*/
/* random_generator()													  */
/*	Pseudozufallsgenerator fÅr Zahlen 0 <= x < 1						  */
/* <- neue Pseudozufallszahl											  */
/*------------------------------------------------------------------------*/


double random_generator(void)
{
	/* Zufallsgenerator aus dem Handbuch zum HP-41 (liefert	1,000,000	  */
	/* verschiedene Zahlen zwischen 0 und 0.999999), dabei sicherstellen, */
	/* daû nicht durch Rundungsfehler mehr als 6 Stellen auftreten		  */

	seed = fmod(9821.0 * seed + 0.211327, 1.0);
	seed = (floor(seed * 2.E6) - floor(seed * 1.E6)) * 1.E-6;
	return(seed);
}



/*------------------------------------------------------------------------*/
/* set_window_header()													  */
/*	Setzt die Startzufallszahl fÅr das aktuelle Spiel in die Titelzeile	  */
/*	des Fensters des Spiels (Wert der Zahl zwischen 0 und 999999).		  */
/* ->  Pointer auf String mit Titelzeile								  */
/*------------------------------------------------------------------------*/


void set_wind_header(char *title)
{
	ltoa((long) (old_seed * 1.E6), title + 11, 10);
	strcat(title, " ");
	wind_set(wind_handle, WF_NAME, (int) ((long) title >> 16),
										 (int) ((long) title & 0x0000FFFF));
}


/*------------------------------------------------------------------------*/
/* paint_background()													  */
/*	Zeichnen des Hintergrundes des Spielfeldes.							  */
/*------------------------------------------------------------------------*/


void paint_background(void)
{
	int clear_array[4];


	/* Array mit Maûen der sichtbaren ArbeitsflÑche des Fensters besetzen */

	clear_array[0] = wwx;
	clear_array[1] = wwy;
	clear_array[2] = MIN(wwx + www - 1, scr_x);
	clear_array[3] = MIN(wwy + wwh - 1, scr_y);

	/* Maus ausschalten und mit Muster des Hintergrundes Åbermalen		  */

	graf_mouse(M_OFF, 0);
	v_bar(wkst_handle, clear_array);
	graf_mouse(M_ON, 0);
}


/*------------------------------------------------------------------------*/
/* clear_column()														  */
/*	Lîscht den Bereich einer Reihe durch öbermalen mit dem Muster des	  */
/*	Spielfeldhintergrundes.												  */
/* ->  Nummer der zu lîschenden Reihe und Flag, das anzeigt, ob Clipping- */
/*	   Bereich auf den gesamten Bereich der Reihe gesetzt werden soll	  */
/*	   oder auf nur SchnitflÑche mit bereits gesetzten Clipping-Bereich	  */
/*------------------------------------------------------------------------*/


void clear_column(int col, int clip_flag)
{
	int old_clip[4], i;


	/* Wenn Flag nicht gesetzt, alten Clippingbereich zwischenspeichern	  */
	/* und Clipping auf SchnittflÑche mit der Reihe setzen				  */

	if (!clip_flag)
	{
		if ((column[col].x + CARD_WIDTH - 1 < clip_array[0]) ||
				(column[col].x > clip_array[2]) ||
					(wwy + wwh - 1 < clip_array[1]) ||
						(wwy + TOP_ROW > clip_array[3]))
			return;

		for (i = 0; i < 4; i++)
			old_clip[i] = clip_array[i];

		clip_array[0] = MAX(MAX(column[col].x, clip_array[0]), 0);
		clip_array[1] = MAX(MAX(wwy + TOP_ROW, clip_array[1]), 0);
		clip_array[2] = MIN(MIN(column[col].x + CARD_WIDTH - 1,
													 clip_array[2]), scr_x);
		clip_array[3] = MIN(MIN(wwy + wwh - 1, clip_array[3]), scr_y);
	}
	else
	{
		clip_array[0] = MAX(column[col].x, 0);
		clip_array[1] = MAX(wwy + TOP_ROW, 0);
		clip_array[2] = MIN(column[col].x + CARD_WIDTH - 1, scr_x);
		clip_array[3] = MIN(wwy + wwh - 1, scr_y);
	}

	vs_clip(wkst_handle, ON, clip_array);

	/* öbermalen durch Hintergrundmuster								  */

	paint_background();

	/* U. U. wieder alten Clippingbereich setzen						  */

	if (!clip_flag)
	{
		for (i = 0; i < 4; i++)
			clip_array[i] = old_clip[i];
		vs_clip(wkst_handle, ON, clip_array);
	}
}


/*------------------------------------------------------------------------*/
/* gem_init()															  */
/*	Meldet eine Applikation an, îffnet eine virtuelle Workstation (mit	  */
/*	dem Handle 'wkst_handle') und erzeugt ein unterlegtes Fenster (mit	  */
/*  dem Handle 'wind_handle').											  */
/* ->  Pointer auf String mit Titel des Fensters						  */
/* <-  1 bei erfolgreichem Abschluû, 0 bei Fehler						  */
/*------------------------------------------------------------------------*/


int gem_init(char *title)
{
	int work_in[11],				  /* Eingabe- und Ausgabeparameter 	  */
		work_out[57];				  /* fÅr ôffnen der Workstation		  */
	int gl_hchar,					  /* Hîhe und Breite eines Zeichens	  */
		gl_wchar,					  /* aus dem Standardzeichensatz	  */
		gl_hbox,					  /* und die einer Box, in die die    */
		gl_wbox;					  /* Zeichen hineinpassen			  */


	if ((ap_id = appl_init()) == -1)			/* Applikation anmelden   */
		return(0);								/* ... miûlungen		  */

	wkst_handle = graf_handle(&gl_wchar, &gl_hchar,	  /* Handle der Work- */
							  &gl_wbox, &gl_hbox);	  /* station besorgen */

	work_in[0]  = wkst_handle;	   /* verschiedene Parameter der zu îff-  */
								   /* nenden Workstation festsetzen		  */
	work_in[1]  = 1;			   /* Linientyp = durchgezogen			  */
	work_in[2]  = BLACK;		   /* Linienfarbe = schwarz				  */
	work_in[3]  = 1;			   /* Markertyp = Punkt					  */
	work_in[4]  = BLACK;		   /* Markerfarbe = schwarz				  */
	work_in[5]  = 0;			   /* Textstil = Normalschrift			  */
	work_in[6]  = BLACK;		   /* Textfarbe = schwarz				  */
	work_in[7]  = 2;			   /* FÅlltyp							  */
	work_in[8]  = 8;			   /* FÅllmuster-Index					  */
	work_in[9]  = WHITE;		   /* FÅllmuster-Farbe					  */
	work_in[10] = 2;			   /* Rasterkoordinaten					  */

	v_opnvwk(work_in, &wkst_handle, work_out);	 /* Workstation îffnen	  */

	/* Anzahl der Bitplanes berechnen									  */

	nplanes = 0;
	while (work_out[13] >>= 1)
		nplanes++;

	/* grîûte mîgliche Bildschirmkoordinaten speichern					  */

	scr_x = work_out[0];
	scr_y = work_out[1];

	/* verschieden Attribute der Workstation setzen						  */

	vswr_mode(wkst_handle, MD_REPLACE);
	vsf_interior(wkst_handle, FIS_PATTERN);
	vsf_style(wkst_handle, 4);
	vsf_color(wkst_handle, BLACK);
	vsf_perimeter(wkst_handle, OFF);
	
	/* Fenster mit Mindestgrûe des Arbeitsbereichs von 600 * 300 Punkten  */
	/* îffnen															  */	

	wind_get(0, WF_WORKXYWH, &wox, &woy, &wow, &woh);
	wind_calc(WC_WORK, NAME | CLOSER | FULLER | MOVER, wox, woy, wow, woh,
													&wwx, &wwy, &www, &wwh);

	if ((www < 600) || (wwh < 300))
	{
		gem_exit();
		return(0);
	}

	/* ArbeitsflÑche so setzen, daû das gesamte Fenster maximal den Bild- */
	/* schirm bei TT-Medium-Auflîsung Åberdeckt - es wÑre Blîdsinn auch	  */
	/* bei Groûbildschirmen allen Platz zu okkupieren ...				  */

	www = MIN(www, 638);
	wwh = MIN(wwh, 442);

	wind_calc(WC_BORDER, NAME | CLOSER | FULLER | MOVER, wwx, wwy, www, wwh,
													&wox, &woy, &wow, &woh);

	wind_handle = wind_create(NAME | CLOSER | FULLER | MOVER, wox, woy, wow,
																	   woh);
	if (wind_handle < 0)		 /* kein Fenster mehr da ? -> Abbruch ... */
	{
		gem_exit();
		return(0);
	}

	wind_set(wind_handle, WF_NAME, (int) ((long) title >> 16),
										 (int) ((long) title & 0x0000FFFF));

	if (!wind_open(wind_handle, wox, woy, wow, woh))
	{
		wind_delete(wind_handle);
		gem_exit();
		return(0);
	}

	return(1);
}


/*------------------------------------------------------------------------*/
/* gem_exit() schlieût die virtuelle Workstation und meldet die Applika-  */
/* tion ab.																  */
/*------------------------------------------------------------------------*/


void gem_exit()
{
	v_clsvwk(wkst_handle);						/* Workstation schliessen */
	appl_exit();								/* Applikation abmelden	  */
}


/*------------------------------------------------------------------------*/
/* make_cards()															  */
/*	Dient zum Herstellen der Bilder der Karten - die Bilder sind zum Teil */
/*	im File 'VIERFREI.DAT' gespeichert, werden von dort in den vorher	  */
/*	allozierten Speicherbereich eingelesen und nachbearbeitet.			  */
/*	Ist eine ziemliche schweinische Bitfiddelei, deshalb auch nicht	son-  */
/*	derlich gut kommentiert - 'tschuldigung ...							  */
/*------------------------------------------------------------------------*/


int make_cards(void)
{
	int i, j, k;
	int value;
	long *act_pic;
	long card_pic[1316];
	int *from, *to;
	unsigned long kl_farbe[28];
	unsigned long gr_farbe[60];
	long act_card;
	FILE *fp;


	/* Speicherplatz fÅr Bilder der Karten allozieren					  */

	if ((pic = (long *) Malloc(CARD_SIZE * (N + 6) * nplanes *
													 sizeof(long))) == NULL)
		return(0);

	/* File mit Daten fÅr Bilder der Karten îffnen						  */

	if ((fp = fopen("VIERFREI.DAT", "rb")) == NULL)
	{
		Mfree(pic);
		return(0);
	}

	/* Halbbilder der Karten einlesen									  */

	if (fread((void *) card_pic, sizeof(long), 1316, fp) != 1316)
	{
		Mfree(pic);
		return(0);
	}

	/* Muster fÅr kleine Darstellung von Kreuz, Pik, Herz und Karo ein-	  */
	/* lesen ...														  */

	if (fread((void *) kl_farbe, sizeof(long), 28, fp) != 28)
	{
		Mfree(pic);
		return(0);
	}

	/* ... und das selbe fÅr die Muster fÅr die groûe Darstellung		  */

	if (fread((void *) gr_farbe, sizeof(long), 60, fp) != 60)
	{
		Mfree(pic);
		return(0);
	}

	fclose(fp);

	/* Bilder aller Karten aus den Daten erzeugen						  */

	act_pic = pic;
	for (k = 0; k < 52; k++, act_pic += CARD_SIZE)
	{

		value = k & 3;
		act_card = (k >> 2) * 94;
		for (i = 0; i < 94; i++)
			act_pic[i] = card_pic[act_card++];

		/* linke kleine Farbe nach act_pic								  */

		switch (k >> 2)
		{
			case 0 : case 1 : case 2 : case 3 : case 4 :
			case 5 : case 6 : case 7 : case 8 :
				for (i = 0; i < 7; i++)
					act_pic[6 + 2 * i] |= kl_farbe[value * 7 + i] >> 13;
				break;

			case 9 :
				for (i = 0; i < 7; i++)
					act_pic[6 + 2 * i] |= kl_farbe[value * 7 + i] >> 14;
				break;

			case 10 : case 11 : case 12 :
				for (i = 0; i < 7; i++)
					act_pic[6 + 2 * i] |= kl_farbe[value * 7 + i] >> 12;
				break;
		}

		/* rechte kleine Farbe nach act_pic								  */

		switch (k >> 2)
		{
			case 0 : case 1 : case 2 : case 3 : case 4 :
			case 5 : case 6 : case 7 : case 8 :
				for (i = 0; i < 7; i++)
					act_pic[7 + 2 * i] |= kl_farbe[value * 7 + i] >> 12;
				break;

			case 9 :
				for (i = 0; i < 7; i++)
					act_pic[7 + 2 * i] |= kl_farbe[value * 7 + i] >> 11;
				break;

			case 10 : case 11 : case 12 :
				for (i = 0; i < 7; i++)
					act_pic[23 + 2 * i] |= kl_farbe[value * 7 + i] >> 20;
				break;
		}

		/* groûe Farbe (teilweise) nach act_pic							  */

		switch (k >> 2)
		{
			case 1 :												 /* 2 */
				for (i = 0; i < 15; i++)
				{
					act_pic[46 + 2 * i] |= gr_farbe[value * 15 + i] >> 25;
					act_pic[47 + 2 * i] |= gr_farbe[value * 15 + i] << 7;
				}
				break;

			case 2 :												 /* 3 */
				for (i = 0; i < 15; i++)
				{
					act_pic[40 + 2 * i] |= gr_farbe[value * 15 + i] >> 25;
					act_pic[41 + 2 * i] |= gr_farbe[value * 15 + i] << 7;
				}
				break;

			case 3 :												 /* 4 */
				for (i = 0; i < 15; i++)
				{
					act_pic[46 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[47 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 4 :												 /* 5 */
				for (i = 0; i < 15; i++)
				{
					act_pic[46 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[47 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 5 :												 /* 6 */
				for (i = 0; i < 15; i++)
				{
					act_pic[40 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[41 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 6 :												 /* 7 */
				for (i = 0; i < 15; i++)
				{
					act_pic[40 + 2 * i] |= gr_farbe[value * 15 + i] >> 14;
					act_pic[41 + 2 * i] |= gr_farbe[value * 15 + i] >> 3;
				}
				break;

			case 7 :												 /* 8 */
				for (i = 0; i < 15; i++)
				{
					act_pic[26 + 2 * i] |= gr_farbe[value * 15 + i] >> 14;
					act_pic[27 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
					act_pic[60 + 2 * i] |= gr_farbe[value * 15 + i] >> 14;
					act_pic[61 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 8 :												 /* 9 */
				for (i = 0; i < 15; i++)
				{
					act_pic[22 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[23 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
					act_pic[56 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[57 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 9 :												/* 10 */
				for (i = 0; i < 15; i++)
				{
					act_pic[22 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[23 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
					act_pic[62 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[63 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
					act_pic[42 + 2 * i] |= gr_farbe[value * 15 + i] >> 25;
					act_pic[43 + 2 * i] |= gr_farbe[value * 15 + i] << 7;
				}
				break;

			case 10 :											  /* Bube */
				for (i = 0; i < 15; i++)
					act_pic[20 + 2 * i] |= gr_farbe[value * 15 + i] >> 6;
				break;

			case 11 :											  /* Dame */
				for (i = 0; i < 15; i++)
					act_pic[18 + 2 * i] |= gr_farbe[value * 15 + i] >> 11;
				break;

			case 12 :											 /* Kînig */
				for (i = 0; i < 15; i++)
					act_pic[20 + 2 * i] |= gr_farbe[value * 15 + i] >> 12;
				break;
		}

		/* Karte punktspiegeln											  */

		for (i = 94, j = i - 3; i < 186; j -= 2, i += 2)
			reverse_card(act_pic + j, act_pic + i);

		/* fÅr einige Karten nochmal groûe Farbe nach act_pic			  */

		switch (k >> 2)
		{
			case 0 : case 2 : case 4 : case 8 :			   /* As, 3, 5, 9 */
				for (i = 0; i < 15; i++)
				{
					act_pic[78 + 2 * i] |= gr_farbe[value * 15 + i] >> 25;
					act_pic[79 + 2 * i] |= gr_farbe[value * 15 + i] << 7;
				}
				break;

			case 5 :												 /* 6 */
				for (i = 0; i < 15; i++)
				{
					act_pic[78 + 2 * i] |= gr_farbe[value * 15 + i] >> 13;
					act_pic[79 + 2 * i] |= gr_farbe[value * 15 + i] >> 4;
				}
				break;

			case 6 :												 /* 7 */
				for (i = 0; i < 15; i++)
				{
					act_pic[78 + 2 * i] |= gr_farbe[value * 15 + i] >> 8;
					act_pic[79 + 2 * i] |= gr_farbe[value * 15 + i] >> 10;
					act_pic[78 + 2 * i] |= gr_farbe[value * 15 + i] >> 25;
					act_pic[79 + 2 * i] |= gr_farbe[value * 15 + i] << 7;
				}
				break;
		}
	}

	/* Nun die Karten mit nur den Farbsymbolen (fÅr die Endablage) sowie  */
	/* die leere Karte (fÅr die Zwischenablagen) vorbereiten			  */

	for (k = 0; k < 5; k++, act_pic += CARD_SIZE)
	{
		act_card = 1222L;
		for (i = 0; i < 94; i++)
			act_pic[i] = card_pic[act_card++];
		for (i = 94, j = i - 3; i < 186; j -= 2, i += 2)
			reverse_card(act_pic + j, act_pic + i);

		if (k == 4)
			continue;
		else
		{
			for (i = 0; i < 15; i++)
			{
				act_pic[78 + 2 * i] |= gr_farbe[k * 15 + i] >> 25;
				act_pic[79 + 2 * i] |= gr_farbe[k * 15 + i] << 7;
			}
		}
	}

	/* Maske fÅr die Karten erzeugen - 'per Hand', da ich vergessen hatte */
	/* sie in den Datenfile einzubauen ...								  */

	act_pic[0] = act_pic[184] = 0xFE000000L;
	act_pic[1] = act_pic[185] = 0x0000007FL;
	act_pic[2] = act_pic[182] = 0xF8000000L;
	act_pic[3] = act_pic[183] = 0x0000001FL;
	act_pic[4] = act_pic[180] = 0xF0000000L;
	act_pic[5] = act_pic[181] = 0x0000000FL;
	act_pic[6] = act_pic[8] = act_pic[176] = act_pic[178] = 0xE0000000L;
	act_pic[7] = act_pic[9] = act_pic[177] = act_pic[179] = 0x00000007L;

	for (i = 10; i < 176; )
	{
		act_pic[i++] = 0xC0000000L;
		act_pic[i++] = 0x00000003L;
	}

	if (nplanes == 1)
		return(1);

	/* FÅr Auflîsungen mit mehr als einer Bitplane (z. B. TT-Medium) die  */
	/* Bilder der Karten fÅr die Bitplanes im Speicher umkopieren		  */

	from = (int *) (pic + CARD_SIZE * (N + 6));
	to = (int *) (pic + CARD_SIZE * (N + 6) * nplanes);

	while (from-- != (int *) pic)
	{
		to -= nplanes;
		for (i = 0; i < nplanes; i++)
			*(to + i) = *from;
	}

	return(1);
}


/*------------------------------------------------------------------------*/
/* reverse_card()														  */
/*	Dient zum Spiegeln einer Zeile einer Karte.							  */
/* ->  Pointer auf Ausgangszeile und Pointer auf Zielzeile				  */
/*------------------------------------------------------------------------*/


void reverse_card(long *source, long *dest)
{
	int k;

	*dest = *(dest + 1) = 0L;
	for (k = 0; k < 32; k++)
	{
		*dest <<= 1;
		*dest |= (*source >> k) & 1;
		*(dest + 1) <<= 1;
		*(dest + 1) |= (*(source - 1) >> k) & 1;
	}
}


/*------------------------------------------------------------------------*/
/* select_game()														  */
/*	Dient zur Auswahl eines Spiels entsprechend einer zu editierenden	  */
/*	Zahl. Beim Editieren kînnen BACKSPACE- und ESCAPE-Taste verwendet	  */
/*	werden.																  */
/* ->  Pointer auf String mit Title des Fensters						  */
/* <-  1 = neues Spiel starten, 0 = Abbruch des Editierens, nichts tun	  */
/*------------------------------------------------------------------------*/


int select_game(char *title)
{
	int mwhich,						/* Variablen fÅr evnt_multi()		  */
		mbuf[8],
		mox, moy,
		mbutton, mokstate,
		mkreturn, mbreturn;
	OBJECT *form;					/* Pointre auf Auswahlbox			  */
	long number;
	char *str,						/* zwei Pointer auf (oder in) den	  */
		 *help_str;					/* zu editierenden String			  */
	int cur_pos = 0,				/* Position des Cursors im String	  */
		max_len;					/* maximale LÑnge des Strings		  */
	int x, y, w, h;					/* Koordinaten und Maûe des Strings	  */
	int cur_line[4];				/* Coordinaten des Cursors			  */
	int cell_width,					/* Breite eines Buchstabens			  */
		dummy;						/* Dummy-Variable					  */
	int top_window;
	int quit_flag = OFF;			/* gesetzt bei Ende des Editierens	  */



	/* Adresse der Auswahlbox besorgen und ihre Position berechnen		  */

	rsrc_gaddr(0, GETNUM, &form);

	form->ob_x = MIN((scr_x + wwx - form->ob_width) / 2,
										  wwx + (www - form->ob_width) / 2);
	form->ob_y = MIN((scr_y  + wwy - form->ob_height) / 2,
										 wwy + (wwh - form->ob_height) / 2);

	/* Neuen Seed in die Zahl eintragen									  */

	number = (long) (seed * 1.E6);
	str = help_str = form[NUMBER].S_TEXT;
	ltoa(number, str, 10);

	/* Falls noch Stellen frei sind, diese mit '_'s auffÅllen			  */

	while (*help_str++ != '\0')
		cur_pos++;

	max_len = form[NUMBER].ob_spec.tedinfo->te_txtlen - 1;
	while (help_str < str + max_len)
		*help_str++ = '_';

	*--help_str = '\0';

	/* Auswahlbox zeichnen												  */

	objc_draw(form, 0, 1, MAX(form->ob_x - 5, 0), MAX(form->ob_y - 5, 0),
		 MIN(form->ob_width + 10, scr_x), MIN(form->ob_height + 10, scr_y));

	str += cur_pos - 1;

	/* Koordinaten und Maûe des Strings besorgen und Clipping setzen	  */

	x = form->ob_x + form[NUMBER].ob_x;
	y = form->ob_y + form[NUMBER].ob_y;
	w = form[NUMBER].ob_width;
	h = form[NUMBER].ob_height;

	clip_array[0] = MAX(form->ob_x - 5, 0);
	clip_array[1] = MAX(form->ob_y - 5, 0);
	clip_array[2] = MIN(form->ob_x + form->ob_width + 4, scr_x);
	clip_array[3] = MIN(form->ob_y + form->ob_height + 4, scr_y);

	vs_clip(wkst_handle, ON, clip_array);

	/* Zum Schluû der Vorbereitungen den Cursor zeichnen				  */

	vqt_width(wkst_handle, ' ', &cell_width, &dummy, &dummy);

	cur_line[0] = cur_line[2] = x + cell_width * cur_pos;
	cur_line[1] = y;
	cur_line[3] = y + h - 1;

	v_hide_c(wkst_handle);
	v_pline(wkst_handle, 2, cur_line);
	v_show_c(wkst_handle, OFF);

	/* Tastaturbuffer leeren											  */

	while (Cconis())
		Crawcin();

	/* Es folgt die Loop, in der der String editiert wird (als Reaktion	  */
	/* entweder auf einen Mausklick oder einen Tastendruck), auûerdem	  */
	/* mÅssen Messages behandelt werden									  */

	do
	{
		mwhich = evnt_multi(MU_KEYBD | MU_BUTTON | MU_MESAG,
							1, 1, 1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							mbuf, 0, 0, &mox, &moy, &mbutton,
							&mokstate, &mkreturn, &mbreturn);

	/* Messages auswerten ...											  */

		if (mwhich & MU_MESAG)
		{
			switch (mbuf[0])
			{

	/* Bei REDRAW-Message mÅssen sowohl das Spielfeld mit Karten als auch */
	/* das darÅberliegende Formular neu gezeichnet werden - wenn das ei-  */
	/* gene Fenster dabei das oberste wird, muû auûerdem sicherheitshal-  */
	/* ber der Cursor neu gezeichnet werden								  */

				case WM_REDRAW :
					wind_redraw(mbuf + 4, (OBJECT *) 0L);
					wind_redraw(mbuf + 4, form);

					wind_get(wind_handle, WF_TOP, &top_window);
					if (wind_handle == top_window)
					{
						v_hide_c(wkst_handle);
						v_pline(wkst_handle, 2, cur_line);
						v_show_c(wkst_handle, OFF);
					}
					break;

	/* Bei TOPPED-Message muû das Fenster neu gesetzt werden, REDRAW ge-  */
	/* schieht daraufhin automatisch, weil das AES von sich aus eine	  */
	/* REDRAW-Message schickt											  */

				case WM_TOPPED :		/* Fenster wurde oberstes Fenster */
					wind_set(wind_handle, WF_TOP);
					break;

	/* Bei Anklicken von MenueeintrÑgen nur den Menuetitel wieder normal  */
	/* darstellen, sonst nicht darauf reagieren							  */	

				case MN_SELECTED :
					menu_tnormal(menu, mbuf[3], NORM);
					break;
			}
		}

	/* Reaktion auf Tastatur-Ereignisse ...								  */

		if (mwhich & MU_KEYBD)
		{
			switch (mkreturn & 0xFF)
			{

	/* bei ESC den gesamten String lîschen (d.h. alle EintrÑge durch '_'  */
	/* ersetzen und den Cursor an den Anfang malen						  */

				case ESC :
					str = form[NUMBER].S_TEXT;
					while (*str)
						*str++ = '_';
					str = form[NUMBER].S_TEXT - 1;
					objc_draw(form, NUMBER, 0, x, y, w, h);

					v_hide_c(wkst_handle);
					if (cur_pos == max_len)
					{
						vsl_color(wkst_handle, WHITE);
						v_pline(wkst_handle, 2, cur_line);
						vsl_color(wkst_handle, BLACK);
					}
					cur_pos = 0;

					cur_line[0] = cur_line[2] = x;
					v_pline(wkst_handle, 2, cur_line);
					v_show_c(wkst_handle, OFF);
					break;

	/* bei BACKSPACE das links vom Cursor stehende Zeichen lîschen (d.h.  */
	/* durch '_' ersetzen) und den Cursor verschieben					  */

				case BACKSPACE :
					if (cur_pos == 0)			  /* wenn String leer ist */
						break;

					v_hide_c(wkst_handle);

					*str-- = '_';
					objc_draw(form, NUMBER, 0, x, y, w, h);

					if (cur_pos-- == max_len)
					{
						vsl_color(wkst_handle, WHITE);
						v_pline(wkst_handle, 2, cur_line);
						vsl_color(wkst_handle, BLACK);
					}

					cur_line[0] = cur_line[2] -= cell_width;
					v_pline(wkst_handle, 2, cur_line);
					v_show_c(wkst_handle, OFF);
					break;

	/* Bei RETURN oder ENTER beenden des Editierens indem das Anklicken	  */
	/* von 'Fertig' simuliert wird										  */

				case RETURN :
					mwhich |= MU_BUTTON;
					objc_offset(form, NREADY, &mox, &moy);
					break;

	/* Neue Zeichen werden nur akzeptiert, wenn es sich um Zahlen handelt */
	/* und der String nicht bereits voll ist							  */

				default :
					if (!isdigit(mkreturn & 0xFF) || (cur_pos == max_len))
						break;

					*++str = mkreturn & 0xFF;
					objc_draw(form, NUMBER, 0, x, y, w, h);

					cur_pos++;
					cur_line[0] = cur_line[2] += cell_width;
					v_pline(wkst_handle, 2, cur_line);
					v_show_c(wkst_handle, OFF);
					break;
			}
		}

	/* Reaktion auf Mausklicks											  */

		if (mwhich & MU_BUTTON)
		{
			/* Testen, welcher Button angeklickt wurde und entsprechend	  */
			/* verzweigen												  */

			switch (objc_find(form, 0, 1, mox, moy))
			{
				case NREADY :									/* Fertig */
					quit_flag = 1;
					break;

				case QUIT :									   /* Abbruch */
					quit_flag = -1;
					break;
			}
		}

	} while (!quit_flag);

	/* Cursor lîschen													  */

	if (cur_pos == max_len)
	{
		v_hide_c(wkst_handle);
		vsl_color(wkst_handle, WHITE);
		v_pline(wkst_handle, 2, cur_line);
		vsl_color(wkst_handle, BLACK);
		v_show_c(wkst_handle, OFF);
	}

	/* Bei Abbruch Auswahlbox lîschen und fertig						  */

	if (quit_flag == -1)
	{
		show_all(OFF);
		return(0);
	}

	/* Sonst editierte Zahl auswerten und Seed entsprechend setzen		  */

	help_str = form[NUMBER].S_TEXT;
	while (isdigit(*help_str))
		help_str++;

	*help_str = '\0';

	old_seed = seed = ((double) atol(form[NUMBER].S_TEXT) * 1.E-6);
	set_wind_header(title);

	return(1);
}


/*------------------------------------------------------------------------*/
/* wind_redraw()														  */
/*	Dient sowohl zur Wiederherstellung des Fensterinhaltes als auch von	  */
/*	Objekten, wenn eine REDRAW-Message eingegangen ist.					  */
/* ->  Pointer auf Array mit Maûen des wiederherzustellenden Rechtecks	  */
/*	   sowie Pointer auf wiederherzustellendes Objekt (wenn dieser NULL	  */
/*	   ist, muû ein Fenster neu gezeichnet werden, sonst ein Objekt)	  */
/*------------------------------------------------------------------------*/


void wind_redraw(int *rr, OBJECT *wind)
{
	int ar[4];			/* Maûe des aktuell neu zu zeichnenden Rechtecks  */


	/* AES-Aktionen auf dem Bildschirm unterbinden						  */

	wind_update(BEG_UPDATE);

	/* Maûe des ersten neu zu zeichnenden Rechtecks aus der Rechteckliste */
	/* besorgen															  */

	wind_get(wind_handle, WF_FIRSTXYWH, ar, ar + 1, ar + 2, ar + 3);

	/* Neu zeichnen, solange wiederholen bis Hîhe oder Breite des nÑch-	  */
	/* sten wiederherzustellenden Rechtecks ungleich Null ist			  */	

	while (ar[2] || ar[3])
	{

	/* Wenn das aktuelle Rechteck sich mit dem gesamten wiederherzustel-  */
	/* lenden Rechteck Åberschneidet, dieses neu zeichenen				  */

		if (intersect(rr, ar))
		{
			clip_array[0] = MAX(ar[0], 0);
			clip_array[1] = MAX(ar[1], 0);
			clip_array[2] = MIN(ar[0] + ar[2] - 1, scr_x);
			clip_array[3] = MIN(ar[1] + ar[3] - 1, scr_y);
			vs_clip(wkst_handle, ON, clip_array);

	/* Je nach Wert des Objektpointers Fenster oder Formular neu zeichnen */

			if (wind == (OBJECT *) 0L)
				show_all(OFF);
			else
				objc_draw(wind, R_TREE, 1, ar[0], ar[1], ar[2], ar[3]);
		}

	/* Und Maûe des nÑchsten neu zu zeichnenden Rechtecks holen			  */

		wind_get(wind_handle, WF_NEXTXYWH, ar, ar + 1, ar + 2, ar + 3);
	}

	/* AES-Aktionen auf dem Bildschirm wieder zulassen					  */

	wind_update(END_UPDATE);
}


/*------------------------------------------------------------------------*/
/* intersect()															  */
/*	Stellt fest, ob sich zwei Rechtecke Åberschneiden und gibt die Maûe	  */
/*	des öberschneidungsbereich im zweiten Åbergebenen Array zurÅck.		  */
/*	(Entsprechend 'ATARI Profibuch' von Jankowski/Rabich/Reschke)		  */
/* ->  Pointer auf Array's mit den Maûen zweier Rechtecke				  */
/* <-  1 = Rechtecke Åberschneiden sich, 0 = sie Åberschneiden sich nicht */
/*------------------------------------------------------------------------*/


int intersect(int *rr, int *ar)
{
	int ix, iy, iw, ih;


	/* Positionen des linken oberen und rechten unteren Punktes der		  */
	/* SchnittflÑche bestimmen											  */

	ix = MAX(rr[0], ar[0]);
	iy = MAX(rr[1], ar[1]);
	iw = MIN(rr[0] + rr[2], ar[0] + ar[2]);
	ih = MIN(rr[1] + rr[3], ar[1] + ar[3]);

	/* Daraus Position und Maûe der SchittflÑche berechnen (und in den	  */
	/* zweiten Åbergebenen Array eintragen)								  */

	ar[0] = ix;
	ar[1] = iy;
	ar[2] = iw - ix;
	ar[3] = ih - iy;

	return((iw > ix) && (ih > iy));
}


/*------------------------------------------------------------------------*/
/* move_window()														  */
/*	Dient zur AusfÅhrung aller notwendigen Aktionen beim Verschieben des  */
/*	Fensters. Der zusÑtzliche Åbergebene Objektpointer ist nur beim Ver-  */
/*	schieben des auf kleinste Maûe geschrumpften Fensters von Bedeutung,  */
/*	da dessen Inhalt durch ein Objekt gegeben ist.						  */
/* ->  neue x- und y-Position des Fensters sowie Objekt-Pointer			  */
/*------------------------------------------------------------------------*/


void move_window(int x, int y, OBJECT *wind)
{
	int del_x, del_y;
	OBJECT *ob;


	/* Grîûe der Verschiebung berechnen									  */

	del_x = x - wox;
	del_y = y - woy;

	/* Neue Position der linken oberen Ecke des Fensterinneren bestimmen  */

	wwx += del_x;
	wwy += del_y;

	/* Neue x- und y-Position des FensterÑuûeren setzen					  */

	wox = x;
	woy = y;

	wind_set(wind_handle, WF_CURRXYWH, wox, woy, wow, woh);

	/* Objekt fÅr Fensterinneres bei kleinstmîglichem Fenster setzen	  */

	if (wind != (OBJECT *) 0L)
	{
		wind->ob_x = wwx;
		wind->ob_y = wwy;
	}

	/* Wenn die Verschiebung nur zu grîûeren x- oder y-Werten erfolgt	  */
	/* durch Neuzeichnen des Fensters die Positionen der Karten usw.	  */
	/* neu berechnen (andernfalls erfolt dies bei der sonst automatisch	  */
	/* folgenden REDRAW-Message)										  */

	if (((del_x > 0) && (del_y >= 0)) || ((del_x >= 0) && (del_y > 0)))
	{
		if (wind == (OBJECT *) 0L)
			show_all(ON);
	}

	/* Nun noch bei nicht verkleinertem Fenster untersuchen ob die Boxen  */
	/* fÅr Starten eines Spiels entsprechend einer einzugebenden Zahl	  */
	/* bzw. mit Informationen Åber das Spiel noch in das verschobene Fen- */
	/* ster passen und die zugehîrigen MenueeintrÑge entsprechend setzen  */

	if (wind != (OBJECT *) 0L)
		return;

	rsrc_gaddr(R_TREE, GETNUM, &ob);
	if ((ob->ob_width + 10 > scr_x - wwx) ||
										 (ob->ob_height + 10 > scr_y - wwy))
		menu_ienable(menu, T1E1, OFF);
	else
		menu_ienable(menu, T1E1, ON);

	rsrc_gaddr(R_TREE, ABOUT, &ob);
	if ((ob->ob_width + 10 > scr_x - wwx) ||
										 (ob->ob_height + 10 > scr_y - wwy))
		menu_ienable(menu, T0E0, OFF);
	else
		menu_ienable(menu, T0E0, ON);
}


/*------------------------------------------------------------------------*/
/* resize_window()														  */
/*	Dient zum Verkleinern des Fensters und aller nachfolgenden Aktionen,  */
/*	bis das Fenster schlieûlich wieder auf die ursprÅngliche Grîûe ge-	  */
/*	bracht wird.														  */
/* ->  Pointer auf normalen String mit Fenstertitel						  */
/* <-  1 = Spiel sofort beenden, 0 = Spiel normal fortsetzen			  */
/*------------------------------------------------------------------------*/


int resize_window(char *title)
{
	OBJECT *wind;					/* Pointer auf Objekt mit Inhalt des  */
									/* verkleinerten Fensters			  */
	int owow, owoh;					/* ursprÅngliche Maûe des Fensters	  */
	char *new_title = "";			/* Titel des verleinerten Fensters	  */
	int mbuf[8];					/* Buffer fÅr Messages				  */


	/* Adresse des Objekts mit Inhalt des verkleinerten Fensters besorgen */

	rsrc_gaddr(R_TREE, WIND, &wind);

	/* Neue Maûe des Fensters berechnen und Fenster entsprechend setzen	  */

	owow = wow;
	owoh = woh;
	wind_calc(WC_BORDER, CLOSER | FULLER | MOVER, wwx, wwy,
				   wind->ob_width, wind->ob_height, &wox, &woy, &wow, &woh);
	wind_set(wind_handle, WF_NAME, (int) ((long) new_title >> 16),
									 (int) ((long) new_title & 0x0000FFFF));
	wind_set(wind_handle, WF_KIND, CLOSER | FULLER | MOVER);
	wind_set(wind_handle, WF_CURRXYWH, wox, woy, wow, woh);

	/* Objekt mit Inhalt des verkleinerten Fensters zeichnen			  */

	wind->ob_x = wwx;
	wind->ob_y = wwy;
	objc_draw(wind, R_TREE, 1, wwx, wwy, wind->ob_width, wind->ob_height);

	/* Verschieden MenueeintrÑge disablen								  */

	menu_ienable(menu, T0E0, OFF);
	menu_ienable(menu, T1E0, OFF);
	menu_ienable(menu, T1E1, OFF);
	menu_ienable(menu, T1E2, OFF);
	menu_ienable(menu, T1E3, OFF);
	menu_ienable(menu, T1E4, OFF);

	/* Nun auf Messages warten, bis das Fenster wieder vergrîûert wird	  */

	do
	{
		evnt_mesag(mbuf);

		switch (mbuf[0])
		{
			case WM_REDRAW :				  /* Redraw-Message empfangen */
				wind_redraw(mbuf + 4, wind);
				break;

			case WM_MOVED :					  /* Fenster wurde verschoben */
				move_window(mbuf[4], mbuf[5], wind);
				break;

			case WM_TOPPED :			/* Fenster wurde oberstes Fenster */
				wind_set(wind_handle, WF_TOP);
				break;

			case WM_CLOSED :				/* CLOSE-Box wurde angeklickt */
				return(1);

			case MN_SELECTED :				   /* Menueeintrag angeklickt */
				if ((mbuf[3] == T1) && (mbuf[4] == T1E5))
					return(1);							 /* Spiel beenden */
				else
					menu_tnormal(menu, mbuf[3], NORM);
				break;
		}

	} while (mbuf[0] != WM_FULLED);

	/* Disablete MenueeintrÑge wieder enablen							  */

	menu_ienable(menu, T0E0, ON);
	menu_ienable(menu, T1E0, ON);
	menu_ienable(menu, T1E1, ON);
	menu_ienable(menu, T1E2, ON);
	menu_ienable(menu, T1E3, ON);
	menu_ienable(menu, T1E4, ON);

	/* Fenster wieder auf ursprÅngliche Grîûe bringen					  */

	wow = owow;
	woh = owoh;
	wind_set(wind_handle, WF_NAME, (int) ((long) title >> 16),
										 (int) ((long) title & 0x0000FFFF));
	wind_set(wind_handle, WF_KIND, NAME | CLOSER | FULLER | MOVER);
	wind_set(wind_handle, WF_CURRXYWH, wox, woy, wow, woh);

	return(0);
}


/*------------------------------------------------------------------------*/
/* i_to_a()																  */
/*	Wandelt eine positive Integerzahl rechtsbÅndig in einen String mit	  */
/*	festgelegter LÑnge ein.												  */
/* ->  Pointer auf String fÅr die Zahl, zu wandelnde Zahl sowie LÑnge des */
/*	   Strings															  */
/*------------------------------------------------------------------------*/


void i_to_a(char *s, long number, int n)
{
	*(s + n--) = '\0';					 /* Nullbyte ans Ende des Strings */
	
	for ( ; n >= 0; number /= 10) 				 /* String von hinten mit */
		*(s + n--) = number % 10 + '0';					/* Ziffern fÅllen */
	while (*s == '0')							 /* fÅhrende Nullen durch */
		*s++ = ' ';								   /* Leerzechen ersetzen */
}