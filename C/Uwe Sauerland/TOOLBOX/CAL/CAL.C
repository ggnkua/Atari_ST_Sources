/* PROGRAMM	Kalender
 * VERSION	1.0
 * DATUM	27. Juli 1987
 * AUTOR	Uwe Sauerland
 * ZWECK	Erzeugung eines Jahreskalenders fÅr das angegebene Jahr
 *
 */

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

#include <stdio.h>

const char *monats[12] =
{	
	"Januar", "Februar", "MÑrz", "April", "Mai", "Juni", "Juli",
	"August", "September", "Oktober", "November", "Dezember"
};

const char *wtags[7] =
{
	"Mon", "Die", "Mit", "Don", "Fre", "Sbd", "Son"
};

const int mlaenge[2][12] =
{
	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
	31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

#define MSIZE 37

int jahrestafel[12][MSIZE];

long juldat(int tag, int monat, int jahr)
{
	return	(long) (365.25  * (monat > 2 ? jahr : jahr - 1)) +
		(long) (30.6001 * (monat > 2 ? monat + 1 : monat + 13)) +
		(long) tag + 1720982L;
}

#define wochentag(t,m,j)	((int) (juldat((t), (m), (j)) % 7L))
#define schaltjahr(j)		(j % 400 == 0 || (j % 4 == 0 && j % 100 != 0))

void gen_monat(int monat, int jahr)
{
	int t, offset;

	for (offset = 0; offset < wochentag(1, monat + 1, jahr); offset++)
		jahrestafel[monat][offset] = 0;
	for (t = 0; t < mlaenge[schaltjahr(jahr) ? 1 : 0][monat]; t++)
		jahrestafel[monat][offset + t] = t + 1;
	while (offset + t < MSIZE)
		jahrestafel[monat][offset + t++] = 0;
}

void gen_jahr(int jahr)
{
	int m;
	for (m = 0; m < 12; m++)
		gen_monat(m, jahr);
}

void druck_monat(int monat, int jahr)
{
	int wtag, i, offset;

	printf("Kalender fÅr %s %d\n", monats[monat], jahr);
	for (i = 0; i < 27; i++) putchar('-'); putchar('\n');

	for (wtag = 0; wtag < 7; wtag++)
	{
		printf("%3s ", wtags[wtag]);
		for (offset = wtag; offset < MSIZE; offset += 7)
			if (jahrestafel[monat][offset])
				printf("%2d ", jahrestafel[monat][offset]);
			else
				printf("   ");
		putchar('\n');
	}
}

void druck_jahr(int jahr)
{
	int quartal, wtag, monat, i, offset;

	printf("%40s %d\n\n", "Kalender fÅr das Jahr", jahr);

	for (quartal = 0; quartal < 12; quartal += 3)
	{
		printf("    %-17s       %-17s       %-17s\n",
			monats[quartal], monats[quartal + 1], monats[quartal + 2]);
		for (i = 0; i < 70; i++) putchar('-'); putchar('\n');
		for (wtag = 0; wtag < 7; wtag++)
		{
			for (monat = quartal; monat < quartal + 3; monat++)
			{
				printf("%3s ", wtags[wtag]);
				for (offset = wtag; offset < MSIZE; offset += 7)
					if (jahrestafel[monat][offset])
						printf("%2d ", jahrestafel[monat][offset]);
					else
						printf("   ");
				if (monat < quartal + 2)
					if (wtag < 2)
						printf("  ");
					else
						printf("     ");
			}
			putchar('\n');
		}
		putchar('\n');
	}
}

void main(int argc, char *argv[])
{
	int jahr, monat;

	if (argc < 2)
		fprintf(stderr, "usage: cal [<monat>] <jahr>\n");
	else if (argc < 3)
	{
		sscanf(argv[1], "%d", &jahr);
		gen_jahr(jahr);
		druck_jahr(jahr);
	}
	else
	{
		sscanf(argv[1], "%d", &monat);
		sscanf(argv[2], "%d", &jahr);
		gen_monat(monat - 1, jahr);
		druck_monat(monat - 1, jahr);
	}
}
