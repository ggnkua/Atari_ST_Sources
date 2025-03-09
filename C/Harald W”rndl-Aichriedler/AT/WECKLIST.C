/*
	WECKLIST.C
	
	(c) 1992 by Harald W”rndl-Aichriedler
	
	V 1.00	11.06.92	Listet Weckerdaten...

*/


#include <tos.h>
#include <time.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>


#define WORK_DIR	"C:\\WECKER\\"
#define LIST_FILE	WORK_DIR "WECKLIST.BIN"
#define KOMM_STR	WORK_DIR "TIME%04i.MUP"

#define L_SIZE		200		/* 200 Listeeintr„ge zu 10 Bytes */

typedef struct
{
	time_t	next, offset;
	int kommando;
} wecke;
wecke liste[L_SIZE+1];		/* Liste mit Zeiteintr„gen */
int l_count = 0;			/* Anzahl vorhandener Elemente */
int columns = 80, on_off;

void load_list(void);
void load_str(int nr);

main()
{
	int t;
	time_t nt, off;
	
	{	/* ermittle Spaltenzahl */
		char *c = getenv("COLUMNS");
		if(c != NULL)
			columns = atol(c);
		columns -= 45;
	}
	
	load_list();

	time(&nt);
	printf("Liste mit allen Aufrufen:\n%s", asctime(localtime(&nt)));
	switch(on_off)
	{
		case 1: printf("Status: Starte bei Shell und Gemini\n"); break;
		case 2: printf("Status: Starte nur bei Gemini\n"); break;
		case 3: printf("Status: ausgeschalten\n"); break;
	}
	printf("    Zeit:                     Offset:  Nr:  Befehl:\n");
	for(t=0; t<l_count; t++)
	{
		printf("%2i  %.24s  ", t+1, asctime(localtime(&liste[t].next)));
		off = liste[t].offset;
		
		if(off)
		{
			if(!(off % 31552200L))
				printf("%1li Jahre", off/31552200L);
			else if(!(off % 2629350L))
				printf("%3li Mon", off/2629350L);
			else if(!(off % 86400L))
				printf("%2li Tage", off/86400L);
			else if(!(off % 3600L))
				printf("%3li Std", off/3600L);
			else if(!(off % 60L))
				printf("%3li Min", off/60L);
			else
				printf("%7li", off);
		}
		else
			printf("  ---  ");
		printf("  %2i   ",liste[t].kommando);
		load_str(liste[t].kommando);
	}
	return 0;
}

void load_list(void)
{
	int han;
	han = Fopen(LIST_FILE, FO_READ);
	if(han < 0)
		return;
	Fread(han, 2, &l_count);
	Fread(han, l_count*sizeof(wecke), &liste[0]);
	Fread(han, 2, &on_off);

	Fclose(han);
}

void load_str(int nr)
{
	char buf[128], *c=buf;
	int han;
	size_t anz = columns;
	
	sprintf(buf, KOMM_STR, nr);
	han = Fopen(buf, FO_READ);
	if(han < 0)
	{	
		printf("--Nicht lesbar!--\n");
		return;
	}
	anz = Fread(han, anz, buf);
	buf[anz] = '\0';
	while(!iscntrl(*c)) c++;
	*c = '\0';
	printf("%s\n", buf);
	Fclose(han);
}