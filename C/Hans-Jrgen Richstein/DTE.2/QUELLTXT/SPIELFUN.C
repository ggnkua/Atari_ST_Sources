/*****************************/
/* Spielfunktionen fÅr DTE 2 */
/*****************************/

#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "GEM_INEX.H"
#include "WINDLIB.H"
#include "EASYFSEL.H"
#include "DTE2DEFS.H"
#include "DTE2GLBL.H"

/* globale Variablen */

/* Funktionsprototypen */
void steuern(int scan);
void maussteuern(int mx);
void feuer(char wer);
void bewege_schuesse(void);
void treffer(int snr);
void explodiere(int x, int y);
void animate_explosionen(void);
void spieler_getroffen(int wer);

extern void level_start(int lnr);
extern void spielende(void);

extern void schuesse_init(void);
extern void screen_init(void);

extern boolean noch_monster_da(void);

extern void zeige_schuss(int nr);
extern void loesche_schuss(int nr);
extern void zeige_explosion(int nr);
extern void fensterinfo(void);
extern void loesche_feld(int x, int y);

/* Funktionen */
void steuern(int scan)
{
	if((int)(scan & 0xFF) == ' ')
	{
		pause = TRUE;
		fensterinfo();
	}
	switch((int)(scan >> 8))
	{
		case 75:
			/* links */
			if(spieler.pos > 8)
				spieler.pos -= 8;
			else if(spieler.pos > 0)
				spieler.pos = 0;
		break;
		case 77:
			/* rechts */
			if(spieler.pos < SPIELBREITE - 24)
				spieler.pos += 8;
			else if(spieler.pos < SPIELBREITE - 16)
				spieler.pos = SPIELBREITE - 16;
		break;
	}
}

void maussteuern(int mx)
{
	GRECT win;

	wind_get(w_handle, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);
	mx -= win.g_x + 8;

	if((mx < spieler.pos) && (spieler.pos > 8))
		spieler.pos -= 8;
	else if((mx < spieler.pos) && (spieler.pos > 0))
		spieler.pos = 1;
	if((mx > spieler.pos) && (spieler.pos < SPIELBREITE - 24))
		spieler.pos += 8;
	else if((mx > spieler.pos) && (spieler.pos < SPIELBREITE - 16))
		spieler.pos = SPIELBREITE - 17;
}

void feuer(char wer)
{
	int i;

	i = 0;
	while((schuss[i].art > 0) && (i < MAX_SCHUESSE))
		i++;

	if(i <  MAX_SCHUESSE)
	{
		if(wer == -1)
		{
			Dosound(schussnd);
			schuss[i].art = 1;
			schuss[i].x = spieler.pos;
			schuss[i].y = SPIELHOEHE - 32;
			schusswieder = sw_werd;
		}
		else
		{
			switch(bild_monster[wer].art)
			{
				case 1:
					schuss[i].art = 2; /* Bomben nach unten */
				break;
				case 2:
					schuss[i].art = 3; /* SchÅsse nach unten */
				break;
				case 3:
					if((bild_monster[i].x > spieler.pos - 16) && (bild_monster[i].x < spieler.pos + 32))
						schuss[i].art = 3;
					else
						if((bild_monster[i].x > 16) && (bild_monster[i].x < SPIELBREITE - 16))
						{
							schuss[i].art = 4; /* Bomben schrÑg */
							schuss[i].xpl = random(5) - 2;
						}
						else
							return;
				break;
				case 4:
					schuss[i].art = 3; /* SchÅsse nach unten */
				break;
			}
			schuss[i].x = bild_monster[wer].x;
			schuss[i].y = bild_monster[wer].y + 16;
		}
		zeige_schuss(i);
	}
}

void bewege_schuesse(void)
{
	int i;

	for(i = 0; i < MAX_SCHUESSE; i++)
		if(schuss[i].art > 0)
			loesche_schuss(i);
	for(i = 0; i < MAX_SCHUESSE; i++)
		if(schuss[i].art > 0)
		{
			switch(schuss[i].art)
			{
				case 1:
					schuss[i].y -= 16;
				break;
				case 2:
					schuss[i].y += 4;
				break;
				case 3:
					schuss[i].y += 8;
				break;
				case 4:
					schuss[i].x += schuss[i].xpl;
					schuss[i].y += 4;
				break;
			}


			if((schuss[i].x > -1) && (schuss[i].x < SPIELBREITE) && (schuss[i].y > -1) && (schuss[i].y < SPIELHOEHE))
			{
				zeige_schuss(i);
				treffer(i);
			}
			else
			{
				if(schuss[i].art == 2)
					explodiere(schuss[i].x, SPIELHOEHE - 16);
				else if(schuss[i].art == 4)
					if(schuss[i].y + 16 > SPIELHOEHE)
						explodiere(schuss[i].x, SPIELHOEHE - 16);
				schuss[i].art = 0;
			}
		}
}

void treffer(int snr)
{
	int i;

	if(schuss[snr].art == 1)
	{
		for(i = 0; i < MAX_MONSTER; i++)
			if(bild_monster[i].art > 0)
				if((schuss[snr].x + 8 > bild_monster[i].x) && (schuss[snr].x + 8 < bild_monster[i].x + 16))
					if((schuss[snr].y + 4 > bild_monster[i].y) && (schuss[snr].y + 4 < bild_monster[i].y + 16))
					{
						spieler.punkte += (random((int)bild_monster[i].art) + 1) * (4 - timergeschw / 20) * (sw_werd - 1);
						if(spieler.punkte > spieler.neues_leben)
						{
							spieler.leben++;
							spieler.neues_leben += 100 * (4 - timergeschw / 20);
							Dosound(lebensnd);
						}
						fensterinfo();

						bild_monster[i].art = 0;
						explodiere(bild_monster[i].x, bild_monster[i].y);
					}
	}
	else
		if((schuss[snr].y > SPIELHOEHE - 16) && (schuss[snr].y < SPIELHOEHE))
			if((schuss[snr].x > spieler.pos) && (schuss[snr].x < spieler.pos + 16))
				spieler_getroffen(-1);
}

void explodiere(int x, int y)
{
	int i;

	loesche_feld(x, y);

	i = 0;
	while((explosion[i].art > 0) && (i < MAX_EXPLOSIONEN))
		i++;

	if(i < MAX_EXPLOSIONEN)
	{
		explosion[i].art = 1;
		explosion[i].x = x;
		explosion[i].y = y;
		zeige_explosion(i);
	}
}

void animate_explosionen(void)
{
	int i;

	for(i = 0; i < MAX_EXPLOSIONEN; i++)
		if(explosion[i].art > 0)
		{
			Dosound(explode);
			explosion[i].art++;
			if(explosion[i].art > 20)
			{
				explosion[i].art = 0;
				if(!noch_monster_da())
				{
					level++;
					if(level < anz_level)
						level_start(level);
					else
					{
						form_alert(1, "[1][ Sie haben das Spiel geschafft! | Das gibt Bonuspunkte! ][ OK ]");
						spieler.punkte += 100 * spieler.leben * (4 - timergeschw / 20) * (sw_werd - 1);
						spielende();
					}
				}
			}
			else
				if(explosion[i].y > SPIELHOEHE - 17)
					if((explosion[i].x > spieler.pos) && (explosion[i].x < spieler.pos + 16))
						spieler_getroffen(-1);
			zeige_explosion(i);
		}
}

void spieler_getroffen(int wer)
{
	if(!waitloops)
	{
		if(wer > -1)
		{
			explodiere(bild_monster[wer].x, bild_monster[wer].y);
			bild_monster[wer].art = 0;
		}
		explodiere(spieler.pos, SPIELHOEHE - 16);
		spieler.leben--;
		if(spieler.leben < 1)
			spielende();
		else
		{
			waitloops = 50;
			schuesse_init();
			spieler.pos = SPIELBREITE / 2 - 8;
			fensterinfo();
		}
	}
}