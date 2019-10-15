/*
	Dieses Program zeigt den Gebrauch der neuen Alertboxroutine
	in der FLY-DEAL Library
	
	written '92 by Axel SchlÅter
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <fly_deal.h>

void main()
{
	char text[180];
	int ergebnis,work_in[11],work_out[57];

	ergebnis=FLY_init(work_in,work_out);	/* Hier erfolgt die Anmeldung
											   des kompletten GEM's */
	if(ergebnis==ERROR)		/* Hat's geklappt ? */
	{
		fprintf(stderr,"ERROR: No Workstation avaliable\n");
		exit(1);
	}
	graf_mouse(ARROW,0L);	/* Den Mauszeiger als Pfeil */

	strcpy(text,"{1}{ Das ist ein Alerttest | written by Axel SchlÅter '92 |"
				" (c) by TOS 1991,92}{ [OK | [Super | [Abbruch}");
	/* Hier wird der Alerttext mit Buttons einem String zugewiesen,
	   der öbersichtlichkeit halber */
	
	ergebnis=FLY_alert(0,text);	/* Hier wird die Box dargestellt */
	
	fprintf(stdout,"Die Nummer des Ergebnis-Buttons: %d\n",ergebnis);
	
	FLY_exit();	/* Hier wird die GEM-Workstation geschlossen */
}