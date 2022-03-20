/************************************************************/
/*	Overlay-Starter-Programm								*/
/*  Zum automatischen Starten des Overlay-Players mit       */
/*  der Animation 'START.OZZ'                               */
/*  ------------------------------------------------------- */
/*  Starter muž unter XBOOT oder im Desktop als Autostart - */
/*  Programm angemeldet werden								*/
/************************************************************/

#include <tos.h>

void main(void)
{

	Pexec(0, "PLAY_OZZ.PRG", " START.OZZ", (void*)0L);

}

