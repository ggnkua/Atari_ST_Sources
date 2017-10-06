#include <tos.h>
#include "cltr.h"
/*
typdef enum {
	S_START,			/* 1  spielanfang */
	S_NEW,				/* 2Z neuer stein */
	S_LEFT,				/* 4z stein nach links */
	S_CANT_LEFT,		/* 4z stein nach links unm”glich */
	S_RIGHT,			/* 4z stein nach rechts */
	S_CANT_RIGHT,		/* 4z stein nach rechts unm”glich */
	S_ROTATE,			/* 4z rotiere */
	S_CANT_ROTATE,		/* 4z rotieren unm”glich */
	S_ROT_CCW,			/* 4z rotiere counterclockwise */
	S_CANT_ROT_CCW,		/* 4z rotiere counterclockwise unm”glich */
	S_STEPDOWN,			/* 3Z schritt nach unten */
	S_DROPDOWN,			/* 3Z schritt nach unten im freien fall */
	S_DOWN,				/* 2Z stein unten angekommen */
	S_REMOVE,			/* 1  entferne steine */
	S_ABORT,			/* 1  spiel wurde abgebrochen */
	S_GAMEOVER,			/* 1  spiel ist zu ende */
	S_HISCORE,			/* 1  neuer hiscore erreicht */
	S_NOHISCORE,		/* 1  kein neuer hiscore erreicht */
						/* ^ soundlevel, aufrufe werden nur compiliert, wenn
						     SOUND_LEVEL>=soundlevel 
						   z Routine SEHR zeitkritisch (sollte schnell beendet werden)
						   Z Routine zeitkritisch (sollte schnell beendet werden)
					    */
} SOUND_FKT;
*/

#if SOUND_LEVEL>0
int triple_ping[] = {
    0x0900,0x0A00,0x0034,0x0100,0x0B09,0x0C10,0x0D00,0x0810,0x07FE,
    0xFF04,
    0x0900,0x0A00,0x0034,0x0100,0x0B09,0x0C10,0x0D00,0x0810,0x07FE,
    0xFF04,
    0x0900,0x0A00,0x0034,0x0100,0x0B09,0x0C10,0x0D00,0x0810,0x07FE,
    0xFF00,
};

void init_sound(int argc,char *argv[])
							/* parameters are READONLY */
{
}

void do_sound(SOUND_FKT sound)
{
	if ( !opts.sound )		/* optionen beachten ! */
		return;

	if ( sound==S_REMOVE )
		Dosound(triple_ping);
}

#endif
