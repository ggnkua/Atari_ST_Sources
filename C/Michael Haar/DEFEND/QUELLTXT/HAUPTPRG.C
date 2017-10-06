/****************************/
/*                          */
/* Defend the Earth 2       */
/*                          */
/* Geschrieben im Juli 1993 */
/* in Pure C                */
/* von Michael Haar         */
/****************************/

#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "WINDLIB.H"
#include "EASYFSEL.H"
#include "DTE2DEFS.H"

/* globale Variablen */
OBJECT *hauptmenu;
boolean prgende, pause;
int w_handle, was_multi, timergeschw;
int einstell_timergeschw;
MFDB pics, spielbild;
SPIELER spieler;
SCHUSS schuss[MAX_SCHUESSE];
int level, anz_monster, anz_level;
MONSTER bild_monster[MAX_MONSTER];
LEVEL_MONSTER level_monster[MAX_LEVEL];
EXPLOSION explosion[MAX_EXPLOSIONEN];
int waitloops, schusswieder, einstell_sw_werd, sw_werd;
char infotext[80];
char offsnd[1024], explode[1024], hiscore[2048], lebensnd[1024], lifelost[1024], schussnd[1024], titelsnd[2048];

/* Funktionsprototypen */
extern boolean prg_init(void);
extern void prg_exit(void);
extern void spielende(void);

extern void handle_menu(int msg[]);
extern void menu_tasten(int scan);

extern void steuern(int scan);
extern void maussteuern(int mx);
extern void feuer(char wer);
extern void bewege_schuesse(void);
extern void animate_explosionen(void);

extern void zeige_spieler(void);
extern void loesche_spieler(void);
extern void fensterinfo(void);

extern void bewege_monster(void);

/* Funktionen */

/* Hauptprogramm */
int main(void)
{
	int msg[8], event;
	int mx, my, mk, st, scan, clicks;
	GRECT win;

	if(!prg_init())
		return(1);

	do
	{
		event = evnt_multi(was_multi, 1, 1, 1,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							msg, timergeschw, 0,
							&mx, &my, &mk, &st, &scan, &clicks);

		/* Maus */
		if((w_handle > -1) && !pause && !waitloops)
		{
			loesche_spieler();
			maussteuern(mx);
			zeige_spieler();
		}

		if(event & MU_MESAG)
		{
			if(w_handle > -1)
			{
				handle_window(msg);
				if(msg[0] == WM_CLOSED)
					spielende();
			}
			if(event == MU_MESAG)
				handle_menu(msg);
		}
		if((event & MU_TIMER) && (w_handle > -1) && !pause)
		{
			bewege_schuesse();
			if(w_handle > -1)
				bewege_monster();
			if(w_handle > -1)
				animate_explosionen();

			if(w_handle > -1)
				if(!waitloops)
					if(!schusswieder)
						if((st & 2) || (st & 1) || mk)
							feuer(-1);

			if(w_handle > -1)
			{
				/* Neuzeichnen des Bildes */
				msg[0] = WM_REDRAW;
				wind_get(w_handle, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);
				msg[3] = w_handle;
				msg[4] = win.g_x;
				msg[5] = win.g_y;
				msg[6] = win.g_w;
				msg[7] = win.g_h;
				handle_window(msg);
			}
		}
		if(event & MU_KEYBD)
		{
			if((w_handle > -1) && !pause && !waitloops)
			{
				loesche_spieler();
				steuern(scan);
				zeige_spieler();

				if((st & 2) || (st & 1))
					if(!schusswieder)
						feuer(-1);

				/* Neuzeichnen des Bildes */
				msg[0] = WM_REDRAW;
				wind_get(w_handle, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);
				msg[3] = w_handle;
				msg[4] = win.g_x;
				msg[5] = win.g_y;
				msg[6] = win.g_w;
				msg[7] = win.g_h;
				handle_window(msg);
			}
			else if(pause)
				if((int)(scan & 0xFF) == ' ')
				{
					pause = FALSE;
					fensterinfo();
				}
			menu_tasten(scan);
		}
		if(waitloops == 1)
		{
			Dosound(lifelost);
			waitloops = 0;
		}
		else if(waitloops)
			waitloops--;
		if(schusswieder)
			schusswieder--;
	}
	while(!prgende);

	prg_exit();

	return(0);
}