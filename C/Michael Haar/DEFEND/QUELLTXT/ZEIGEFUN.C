/*******************************/
/* Anzeigefunktionen fÅr DTE 2 */
/*******************************/

#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "WINDLIB.H"
#include "EASYFSEL.H"
#include "DTE2DEFS.H"
#include "DTE2GLBL.H"

/* globale Variablen */

/* Funktionsprototypen */
void w_redraw(int work[]);
void zeige_spieler(void);
void loesche_spieler(void);
void zeige_schuss(int nr);
void loesche_schuss(int nr);
void zeige_explosion(int nr);
void zeige_monster(int nr);
void loesche_monster(int nr);
void fensterinfo(void);
void loesche_feld(int x, int y);

/* Funktionen */
void w_redraw(int work[])
{
	int xy[8], colind[2];
	GRECT win;

	wind_get(w_handle, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);

	xy[0] = work[0] - win.g_x;
	xy[1] = work[1] - win.g_y;
	xy[2] = work[2] - win.g_x - 1;
	xy[3] = work[3] - win.g_y - 1;
	xy[4] = work[0];
	xy[5] = work[1];
	xy[6] = work[2] - 1;
	xy[7] = work[3] - 1;
	colind[0] = 1;
	colind[1] = 0;
	vrt_cpyfm(handle, MD_REPLACE, xy, &spielbild, &screen_mfdb, colind);
}

void zeige_spieler(void)
{
	int xy[8];

	xy[0] = 0;
	xy[2] = 15;
	xy[4] = spieler.pos;
	xy[5] = SPIELHOEHE - 16;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[1] = 16;
	xy[3] = 31;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
	xy[1] = 0;
	xy[3] = 15;
	vro_cpyfm(handle, S_OR_D, xy, &pics, &spielbild);
}

void loesche_spieler(void)
{
	int xy[8];

	xy[4] = spieler.pos;
	xy[5] = SPIELHOEHE - 16;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[0] = 0;
	xy[1] = 16;
	xy[2] = 15;
	xy[3] = 31;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
}

void zeige_schuss(int nr)
{
	int xy[8];

	switch(schuss[nr].art)
	{
		case 1:
		case 3:
			xy[0] = 16;
			xy[2] = 31;
		break;
		case 2:
		case 4:
			xy[0] = 32;
			xy[2] = 47;
		break;
	}
	xy[4] = schuss[nr].x;
	xy[5] = schuss[nr].y;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[1] = 16;
	xy[3] = 31;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
	xy[1] = 0;
	xy[3] = 15;
	vro_cpyfm(handle, S_OR_D, xy, &pics, &spielbild);
}

void loesche_schuss(int nr)
{
	int xy[8];

	xy[4] = schuss[nr].x;
	xy[5] = schuss[nr].y;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	switch(schuss[nr].art)
	{
		case 1:
		case 3:
			xy[0] = 16;
			xy[2] = 31;
		break;
		case 2:
		case 4:
			xy[0] = 32;
			xy[2] = 47;
		break;
	}
	xy[1] = 16;
	xy[3] = 31;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
}

void zeige_explosion(int nr)
{
	int xy[8];

	if(explosion[nr].art > 0)
		xy[0] = 48 + (explosion[nr].art - 2) / 3 * 16;
	else
		xy[0] = 176;
	xy[2] = xy[0] + 15;
	xy[4] = explosion[nr].x;
	xy[5] = explosion[nr].y;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[1] = 16;
	xy[3] = 31;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
	if(explosion[nr].art > 0)
		xy[0] = 48 + (explosion[nr].art - 1) / 3 * 16;
	else
		xy[0] = 176;
	xy[2] = xy[0] + 15;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
	xy[1] = 0;
	xy[3] = 15;
	vro_cpyfm(handle, S_OR_D, xy, &pics, &spielbild);
}

void zeige_monster(int nr)
{
	int xy[8];

	xy[0] = (bild_monster[nr].art - 1) * 32 + bild_monster[nr].stufe / 6 * 16;
	xy[2] = xy[0] + 15;
	xy[4] = bild_monster[nr].x;
	xy[5] = bild_monster[nr].y;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[1] = 48;
	xy[3] = 63;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
	xy[1] = 32;
	xy[3] = 47;
	vro_cpyfm(handle, S_OR_D, xy, &pics, &spielbild);
}

void loesche_monster(int nr)
{
	int xy[8];

	xy[0] = (bild_monster[nr].art - 1) * 32 + bild_monster[nr].stufe / 6 * 16;
	xy[2] = xy[0] + 15;
	xy[4] = bild_monster[nr].x;
	xy[5] = bild_monster[nr].y;
	xy[6] = xy[4] + 15;
	xy[7] = xy[5] + 15;
	xy[1] = 48;
	xy[3] = 63;
	vro_cpyfm(handle, S_AND_D, xy, &pics, &spielbild);
}

void fensterinfo(void)
{
	char str[10];

	if(pause)
		strcpy(infotext, " SPIELPAUSE ");
	else
	{
		strcpy(infotext, " Leben: ");
		strcat(infotext, itoa((int)spieler.leben, str, 10));
		strcat(infotext, " Punkte: ");
		strcat(infotext, itoa(spieler.punkte, str, 10));
		strcat(infotext, " Level: ");
		strcat(infotext, itoa(level + 1, str, 10));
	}
	wind_set(w_handle, WF_INFO, infotext);
}

void loesche_feld(int x, int y)
{
	int xy[8];

	xy[0] = 176;
	xy[1] = 0;
	xy[2] = 191;
	xy[3] = 15;
	xy[4] = x;
	xy[5] = y;
	xy[6] = x + 15;
	xy[7] = y + 15;
	vro_cpyfm(handle, S_ONLY, xy, &pics, &spielbild);
}