/*******************************/
/* Monsterfunktionen fÅr DTE 2 */
/*******************************/

#include <stdlib.h>
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
void level_monster_init(void);
void levelstart_monster_init(int lnr);
void bewege_monster(void);
boolean noch_monster_da(void);

extern void zeige_monster(int nr);
extern void loesche_monster(int nr);

extern void feuer(char wer);
extern void spieler_getroffen(int wer);

/* Funktionen */
void level_monster_init(void)
{
	level_monster[0].anz_monster = 1;
	level_monster[0].monster[0].art = 1;
	level_monster[1].anz_monster = 4;
	level_monster[1].monster[0].art = 1;
	level_monster[1].monster[1].art = 1;
	level_monster[1].monster[2].art = 1;
	level_monster[1].monster[3].art = 1;
	level_monster[2].anz_monster = 10;
	level_monster[2].monster[0].art = 1;
	level_monster[2].monster[1].art = 1;
	level_monster[2].monster[2].art = 1;
	level_monster[2].monster[3].art = 1;
	level_monster[2].monster[4].art = 1;
	level_monster[2].monster[5].art = 1;
	level_monster[2].monster[6].art = 1;
	level_monster[2].monster[7].art = 1;
	level_monster[2].monster[8].art = 1;
	level_monster[2].monster[9].art = 1;
	level_monster[3].anz_monster = 2;
	level_monster[3].monster[0].art = 2;
	level_monster[3].monster[1].art = 2;
	level_monster[4].anz_monster = 5;
	level_monster[4].monster[0].art = 2;
	level_monster[4].monster[1].art = 2;
	level_monster[4].monster[2].art = 2;
	level_monster[4].monster[3].art = 2;
	level_monster[4].monster[4].art = 2;
	level_monster[5].anz_monster = 12;
	level_monster[5].monster[0].art = 2;
	level_monster[5].monster[1].art = 2;
	level_monster[5].monster[2].art = 2;
	level_monster[5].monster[3].art = 2;
	level_monster[5].monster[4].art = 2;
	level_monster[5].monster[5].art = 2;
	level_monster[5].monster[6].art = 2;
	level_monster[5].monster[7].art = 2;
	level_monster[5].monster[8].art = 2;
	level_monster[5].monster[9].art = 2;
	level_monster[5].monster[10].art = 2;
	level_monster[5].monster[11].art = 2;
	level_monster[6].anz_monster = 3;
	level_monster[6].monster[0].art = 3;
	level_monster[6].monster[1].art = 3;
	level_monster[6].monster[2].art = 3;
	level_monster[7].anz_monster = 6;
	level_monster[7].monster[0].art = 3;
	level_monster[7].monster[1].art = 3;
	level_monster[7].monster[2].art = 3;
	level_monster[7].monster[3].art = 3;
	level_monster[7].monster[4].art = 3;
	level_monster[7].monster[5].art = 3;
	level_monster[8].anz_monster = 14;
	level_monster[8].monster[0].art = 3;
	level_monster[8].monster[1].art = 3;
	level_monster[8].monster[2].art = 3;
	level_monster[8].monster[3].art = 3;
	level_monster[8].monster[4].art = 3;
	level_monster[8].monster[5].art = 3;
	level_monster[8].monster[6].art = 3;
	level_monster[8].monster[7].art = 3;
	level_monster[8].monster[8].art = 3;
	level_monster[8].monster[9].art = 3;
	level_monster[8].monster[10].art = 3;
	level_monster[8].monster[11].art = 3;
	level_monster[8].monster[12].art = 3;
	level_monster[8].monster[13].art = 3;
	level_monster[9].anz_monster = 2;
	level_monster[9].monster[0].art = 4;
	level_monster[9].monster[1].art = 4;
	level_monster[10].anz_monster = 6;
	level_monster[10].monster[0].art = 4;
	level_monster[10].monster[1].art = 4;
	level_monster[10].monster[2].art = 4;
	level_monster[10].monster[3].art = 4;
	level_monster[10].monster[4].art = 4;
	level_monster[10].monster[5].art = 4;
	level_monster[11].anz_monster = 12;
	level_monster[11].monster[0].art = 4;
	level_monster[11].monster[1].art = 4;
	level_monster[11].monster[2].art = 4;
	level_monster[11].monster[3].art = 4;
	level_monster[11].monster[4].art = 4;
	level_monster[11].monster[5].art = 4;
	level_monster[11].monster[6].art = 4;
	level_monster[11].monster[7].art = 4;
	level_monster[11].monster[8].art = 4;
	level_monster[11].monster[9].art = 4;
	level_monster[11].monster[10].art = 4;
	level_monster[11].monster[11].art = 4;

	anz_level = 12;
}

void levelstart_monster_init(int lnr)
{
	int i;

	anz_monster = level_monster[lnr].anz_monster;
	for(i = 0; i < MAX_MONSTER; i++)
		bild_monster[i].art = 0;
	for(i = 0; i < anz_monster; i++)
	{
		bild_monster[i].art = level_monster[lnr].monster[i].art;
		bild_monster[i].stufe = 0;
		bild_monster[i].x = random(SPIELBREITE - 17) + 1;
		bild_monster[i].y = random(32) + 1;
		switch(bild_monster[i].art)
		{
			case 1:
				bild_monster[i].xpl = (random(3) - 1) * 64;
				bild_monster[i].ypl = 64;
			break;
			case 2:
				bild_monster[i].xpl = (random(11) - 5) * 64;
				bild_monster[i].ypl = (random(11) - 5) * 64;
			break;
			case 3:
				bild_monster[i].xpl = (random(11) - 5) * 64;
				bild_monster[i].ypl = (random(2) - 1) * 64;
			break;
			case 4:
				if(random(2))
					bild_monster[i].xpl = 64;
				else
					bild_monster[i].xpl = -64;
				do
					bild_monster[i].ypl = (random(3) - 1) * 64;
				while(bild_monster[i].ypl / 64 == 0);
				bild_monster[i].richtung = random(2);
			break;
		}
	}
}

void bewege_monster(void)
{
	int i;

	for(i = 0; i < MAX_MONSTER; i++)
		if(bild_monster[i].art > 0)
			loesche_monster(i);
	for(i = 0; i < MAX_MONSTER; i++)
		if(bild_monster[i].art > 0)
		{
			switch(bild_monster[i].art)
			{
				case 1:
					bild_monster[i].x += bild_monster[i].xpl / 64;
					if((bild_monster[i].x < 1) || (bild_monster[i].x > SPIELBREITE - 17))
					{
						bild_monster[i].xpl = -bild_monster[i].xpl;
						if(bild_monster[i].x < 1)
							bild_monster[i].x = 1;
						else
							bild_monster[i].x = SPIELBREITE - 16;
						if(bild_monster[i].xpl == 0)
							bild_monster[i].xpl = 64;
					}
					if((bild_monster[i].x > spieler.pos) && (bild_monster[i].x < spieler.pos + 16))
						if(random(10) == 0)
							feuer(i);

					bild_monster[i].y += bild_monster[i].ypl / 64;
					if(bild_monster[i].ypl > -1)
						bild_monster[i].ypl += bild_monster[i].ypl / 8;
					else
						bild_monster[i].ypl += -bild_monster[i].ypl / 8;
					if(bild_monster[i].ypl / 64 == 0)
						bild_monster[i].ypl = 64 + random(64);
					if((bild_monster[i].y < bild_monster[i].ypl / 64) || (bild_monster[i].y > SPIELHOEHE - (16 + bild_monster[i].ypl / 64)))
					{
						bild_monster[i].ypl = -bild_monster[i].ypl;
						if(bild_monster[i].y < 1)
							bild_monster[i].y = 1;
						else
							bild_monster[i].y = SPIELHOEHE - 16;
						if(bild_monster[i].ypl == 0)
							bild_monster[i].ypl = 64;
					}
				break;
				case 2:
					bild_monster[i].x += bild_monster[i].xpl / 64;
					if((bild_monster[i].x < 1) || (bild_monster[i].x > SPIELBREITE - 17))
					{
						bild_monster[i].xpl = -bild_monster[i].xpl + random(128);
						if(bild_monster[i].x < 1)
							bild_monster[i].x = 1;
						else
							bild_monster[i].x = SPIELBREITE - 16;
						if(bild_monster[i].xpl == 0)
							bild_monster[i].xpl = (random(5) - 2) * 64;
						bild_monster[i].ypl += (random(3) - 1) * 64;
					}
					if((bild_monster[i].x > spieler.pos - 16) && (bild_monster[i].x < spieler.pos + 32))
						if(random(7) == 0)
							feuer(i);

					bild_monster[i].y += bild_monster[i].ypl / 64;
					if((bild_monster[i].y < 1) || (bild_monster[i].y > SPIELHOEHE * 3 / 4))
					{
						bild_monster[i].ypl = -bild_monster[i].ypl + random(128);
						if(bild_monster[i].y < 1)
							bild_monster[i].y = 1;
						else
							bild_monster[i].y = SPIELHOEHE * 3 / 4;
						if(bild_monster[i].ypl == 0)
							bild_monster[i].ypl = (random(5) - 2) * 64;
						bild_monster[i].xpl += (random(3) - 1) * 64;
					}
				break;
				case 3:
					bild_monster[i].x += bild_monster[i].xpl / 64;
					if((bild_monster[i].x < 1) || (bild_monster[i].x > SPIELBREITE - 17))
					{
						bild_monster[i].xpl = -bild_monster[i].xpl + random(128);
						if(bild_monster[i].x < 1)
							bild_monster[i].x = 1;
						else
							bild_monster[i].x = SPIELBREITE - 16;
						if(bild_monster[i].xpl == 0)
							bild_monster[i].xpl = (random(5) - 2) * 64;
						bild_monster[i].ypl += (random(3) - 1) * 64;
					}
					if((bild_monster[i].x > spieler.pos - 16) && (bild_monster[i].x < spieler.pos + 32))
						if(random(8) == 0)
							feuer(i);
					if(random(40) == 0)
						feuer(i);

					bild_monster[i].y += bild_monster[i].ypl / 64;
					if((bild_monster[i].y < 1) || (bild_monster[i].y > SPIELHOEHE / 2))
					{
						bild_monster[i].ypl = -bild_monster[i].ypl + random(128);
						if(bild_monster[i].y < 1)
							bild_monster[i].y = 1;
						else
							bild_monster[i].y = SPIELHOEHE / 2;
						if(bild_monster[i].ypl == 0)
							bild_monster[i].ypl = (random(5) - 2) * 64;
						bild_monster[i].xpl += (random(3) - 1) * 64;
					}
				break;
				case 4:
					bild_monster[i].x += bild_monster[i].xpl / 64;
					if(bild_monster[i].richtung == 0)
					{
						if(bild_monster[i].xpl > -1)
							bild_monster[i].xpl += -bild_monster[i].xpl / 16;
						else
							bild_monster[i].xpl += bild_monster[i].xpl / 16;
					}
					else
					{
						if(bild_monster[i].xpl > -1)
							bild_monster[i].xpl += bild_monster[i].xpl / 16;
						else
							bild_monster[i].xpl += -bild_monster[i].xpl / 16;
					}
					if(bild_monster[i].xpl / 64 == 0)
						if(bild_monster[i].xpl > -1)
						{
							bild_monster[i].xpl = 64 + random(64);
							bild_monster[i].richtung = 1;
						}
						else
						{
							bild_monster[i].xpl = -64 - random(64);
							bild_monster[i].richtung = 0;
						}
					if((bild_monster[i].x < 1) || (bild_monster[i].x > SPIELBREITE - 16))
					{
						bild_monster[i].xpl = -bild_monster[i].xpl;
						if(bild_monster[i].x < 1)
							bild_monster[i].x = 1;
						else
							bild_monster[i].x = SPIELBREITE - 16;
					}

					bild_monster[i].y += bild_monster[i].ypl / 64;
					if((bild_monster[i].y < 1) || (bild_monster[i].y > SPIELHOEHE - 17))
					{
						bild_monster[i].ypl = -bild_monster[i].ypl;
						if(bild_monster[i].y < 1)
							bild_monster[i].y = 1;
						else
							bild_monster[i].y = SPIELHOEHE - 16;
						if(bild_monster[i].ypl == 0)
							bild_monster[i].ypl = 64;
					}

					if(random(30) == 0)
						feuer(i);
				break;
			}
			if(bild_monster[i].y > SPIELHOEHE - 32)
				if((bild_monster[i].x + 8 > spieler.pos) && (bild_monster[i].x + 8 < spieler.pos + 16))
					spieler_getroffen(i);

			bild_monster[i].stufe++;
			if(bild_monster[i].stufe > 11)
				bild_monster[i].stufe = 0;
			zeige_monster(i);
		}
}

boolean noch_monster_da(void)
{
	int i;

	for(i = 0; i < MAX_MONSTER; i++)
		if(bild_monster[i].art > 0)
			return(TRUE);
	return(FALSE);
}