/****************************************/
/* Initialisierungsfunktionen fÅr DTE 2 */
/****************************************/

#include <stdlib.h>
#include <time.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "WINDLIB.H"
#include "EASYFSEL.H"
#include "DTE2.H"
#include "DTE2DEFS.H"
#include "DTE2GLBL.H"

/* globale Variablen */

/* Funktionsprototypen */
boolean prg_init(void);
void prg_exit(void);
boolean spiel_start(void);
void spielende(void);
void levelstart_explosionen_init(void);
void schuesse_init(void);
void screen_init(void);
void level_start(int lnr);

extern void highscore(boolean nur_zeigen);

extern void w_redraw(int work[]);
extern void loesche_schuss(int nr);
extern void fensterinfo(void);

extern void level_monster_init(void);
extern void levelstart_monster_init(int lnr);

/* Funktionen */
boolean prg_init(void)
{
	long len;
	FILE *datei;

	srand((int)clock);

	if(gem_init() == -1)
	{
		Cconws("Initialsierungsfehler!");
		Cconin();
		return(FALSE);
	}

	if(!rsrc_load("DTE2.RSC"))
	{
		form_alert(1, "[3][ Ich kann die Datei | 'DTE2.RSC' nicht finden! ][ Abbruch ]");
		gem_exit();
		return(FALSE);
	}

	len = (long)(PICBREITE * 8) * (long)(PICHOEHE * 16);
	pics.fd_addr = malloc(len);
	if(!pics.fd_addr)
	{
		form_alert(1, "[3][ Es ist nicht genug | freier Speicher vorhanden! ][ Abbruch ]");
		rsrc_free();
		gem_exit();
		return(FALSE);
	}
	datei = fopen("GRAFIK\\BILD.PIC", "rb");
	if(datei)
	{
		fseek(datei, 6L, SEEK_SET); /* GFA-BLK-Header Åberspringen */
		fread(pics.fd_addr, len, 1, datei);
		fclose(datei);
	}
	else
	{
		form_alert(1, "[3][ Ich kann die Datei | 'BILD.PIC' nicht finden! ][ Abbruch ]");
		free(pics.fd_addr);
		rsrc_free();
		gem_exit();
		return(FALSE);
	}
	pics.fd_w = PICBREITE * 16 - 1;
	pics.fd_h = PICHOEHE * 16 - 1;
	pics.fd_wdwidth = PICBREITE;
	pics.fd_stand = 0;
	pics.fd_nplanes = 1;

	len = (long)((SPIELBREITE + 16) / 8) * (long)(SPIELHOEHE + 17);
	spielbild.fd_addr = malloc(len);
	if(!spielbild.fd_addr)
	{
		form_alert(1, "[3][ Es ist genug | Speicher frei! ][ Abbruch ]");
		free(pics.fd_addr);
		rsrc_free();
		gem_exit();
		return(FALSE);
	}
	spielbild.fd_w = SPIELBREITE + 16 - 1;
	spielbild.fd_h = SPIELHOEHE + 17 - 1;
	spielbild.fd_wdwidth = (SPIELBREITE + 16 + 15) / 16;
	spielbild.fd_stand = 0;
	spielbild.fd_nplanes = 1;

	w_handle = -1;
	prgende = FALSE;
	einstell_timergeschw = 40;
	timergeschw = 0;
	einstell_sw_werd = 3;
	sw_werd = 0;
	schusswieder = waitloops = 0;
	was_multi = MU_MESAG | MU_KEYBD;
	infotext[0] = 0;

	level_monster_init();

	datei = fopen("SOUND\\OFF.X32", "rb");
	if(datei)
	{
		fread(offsnd, 1024, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\EXPLODE.X32", "rb");
	if(datei)
	{
		fread(explode, 1024, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\HIGHSCOR.X32", "rb");
	if(datei)
	{
		fread(hiscore, 2048, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\LEBEN.X32", "rb");
	if(datei)
	{
		fread(lebensnd, 1024, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\LIFELOST.X32", "rb");
	if(datei)
	{
		fread(lifelost, 1024, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\SCHUSS.X32", "rb");
	if(datei)
	{
		fread(schussnd, 1024, 1, datei);
		fclose(datei);
	}
	datei = fopen("SOUND\\TITEL.X32", "rb");
	if(datei)
	{
		fread(titelsnd, 2048, 1, datei);
		fclose(datei);
	}

	rsrc_gaddr(0, HAUPTMEN, &hauptmenu);

	menu_ienable(hauptmenu, SPIELABB, 0);

	graf_mouse(ARROW, 0);
	graf_mouse(M_OFF, 0);
	wind_update(BEG_UPDATE);
	menu_bar(hauptmenu, 1);
	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0);

	return(TRUE);
}

void prg_exit(void)
{
	free(pics.fd_addr);
	free(spielbild.fd_addr);
	rsrc_free();
	gem_exit();
}

boolean spiel_start(void)
{
	GRECT win;
	int xy[4];

	spieler.leben = 3;
	spieler.punkte = 0;
	spieler.neues_leben = (4 - timergeschw / 20) * 100;
	level = 0;
	level_start(0);
	fensterinfo();
	timergeschw = einstell_timergeschw;
	sw_werd = einstell_sw_werd;

	wind_calc(WC_BORDER, NAME | INFO | CLOSER | MOVER,
				50, 50, SPIELBREITE, SPIELHOEHE,
				&win.g_x, &win.g_y, &win.g_w, &win.g_h);
	w_handle = open_window(" Defend the Earth 2 ", "", w_redraw,
							NAME | INFO | CLOSER | MOVER,
							0, FALSE,
							0, 0, SPIELHOEHE, SPIELBREITE,
							desk.g_x + desk.g_w / 2 - win.g_w / 2, desk.g_y + desk.g_h / 2 - win.g_h / 2, win.g_w, win.g_h,
							0, 0, 0, 0);
	if(w_handle < 0)
	{
		form_alert(1, "[3][ Es sind nicht mehr | Fenster vorhanden! ][ Abbruch ]");
		return(FALSE);
	}

	was_multi = MU_MESAG | MU_KEYBD | MU_TIMER;
	fensterinfo();

	wind_get(w_handle, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);

	menu_ienable(hauptmenu, SPIELABB, 1);

	vsf_perimeter(handle, 0);
	vsf_color(handle, 1);
	vsf_interior(handle, 0);
	xy[0] = win.g_x;
	xy[1] = win.g_y;
	xy[2] = win.g_x + win.g_w - 1;
	xy[3] = win.g_y + win.g_h - 1;
	v_bar(handle, xy);
	form_alert(1, "[1][ Es geht los! ][ START ]");

	return(TRUE);
}

void spielende(void)
{
	wind_close(w_handle);
	wind_delete(w_handle);
	w_handle = -1;
	was_multi = MU_MESAG | MU_KEYBD;
	menu_ienable(hauptmenu, SPIELABB, 0);
	highscore(FALSE);
	schusswieder = waitloops = 0;
}

void levelstart_explosionen_init(void)
{
	int i;

	for(i = 0; i < MAX_EXPLOSIONEN; i++)
		explosion[i].art = 0;
}

void schuesse_init(void)
{
	int i;

	for(i = 0; i < MAX_SCHUESSE; i++)
		if(schuss[i].art > 0)
		{
			loesche_schuss(i);
			schuss[i].art = 0;
		}
}

void screen_init(void)
{
	long len, i;

	len = (long)((SPIELBREITE + 16) / 8) * (long)(SPIELHOEHE + 17);
	for(i = 0; i < len; i++)
		*(char *)((long)spielbild.fd_addr + i) = 0;
}

void level_start(int lnr)
{
	pause = FALSE;
	spieler.pos = SPIELBREITE / 2 - 8;
	levelstart_monster_init(lnr);
	levelstart_explosionen_init();
	schuesse_init();
	screen_init();
	fensterinfo();
}