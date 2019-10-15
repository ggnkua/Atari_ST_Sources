#include <tos.h>
#include <stdio.h>

int main() {
 DOSTIME timeptr;
 int handle,time,date;
 int Tag,Monat,Jahr,Sec,Minuten,Stunden;
	handle = Fopen("FDATIME.C",0);	/* Datei ”ffnen */
	Fdatime(&timeptr,handle,0); /* Datum und Zeit ermitteln */
	time = timeptr.time; date = timeptr.date;

	Tag	= date & 31;              /* date AND 31 */
	Monat = (date>>5) & 15;      /* (date DIV 32) AND 15 */
	Jahr = 1980+((date>>9) & 63);/* (date DIV 512) AND 63 */
	Sec = (time & 31)*2;         /* (time AND 31) * 2 */
	Minuten = (time>>5) & 63;    /* (time DIV 32) AND 63 */
	Stunden = (time>>11) & 31;   /* (time DIV 2048) AND 31 */

	printf("\n%d.%d.%d %d:%d.%d",Tag,Monat,Jahr,Stunden,Minuten,Sec);
	getchar();	Fclose(handle); return 0; }
