/* PROGRAMM	display Time & Date
 * VERSION	2.2
 * DATUM	9. Mвz 1988
 * AUTOR	Uwe Sauerland
 * ZWECK	Anzeige des aktuellen Datums und der aktuellen Zeit.
 *
 */

#include <stdio.h>
#include <ext.h>
#include <string.h>
#include <stdlib.h>

#define FALSE		0
#define TRUE		1

#define ZEILE		81

#define DIGTIME		1
#define WESSIMODE	2
#define	GRUSS		4


const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1988";


long juldat(unsigned char tag, unsigned char monat, int jahr)
{
	return
		(long) (365.25  * (monat > 2 ? jahr : jahr - 1)) +
		(long) (30.6001 * (monat > 2 ? monat + 1 : monat + 13)) +
		(long) tag + 1720982L;
}

#define wochentag(t,m,j)	((juldat((t), (m), (j)) + 1L) % 7L)

char *datum(long wtag, unsigned char tag, unsigned char monat, int jahr)
{
	static char result[ZEILE];

	const char *tags[7] =
	{
		"Sonntag", "Montag", "Dienstag", "Mittwoch",
		"Donnerstag", "Freitag", "Sonnabend"
	};

	const char *monats[12] =
	{
		"Januar", "Februar", "Mвz", "April", "Mai", "Juni", "Juli",
		"August", "September", "Oktober", "November", "Dezember"
	};

	sprintf
	(
		result, "%s, der %d. %s %d",
		tags[wtag], (int) tag, monats[monat - 1], jahr
	);
	return result;
}

char *gruss(unsigned char std)
{
	if (std < 3)
		return "n Morgen";
	else if (std < 10)
		return "n Morgen";
	else if (std < 12)
		return "n Tag";
	else if (std < 15)
		return "n Tag";
	else if (std < 18)
		return "n Tag";
	else if (std < 23)
		return "n Abend";
	else
		return "n Abend";
}

char *tageszeit(unsigned char std)
{
	if (std < 3)
		return "nachts";
	else if (std < 10)
		return "morgens";
	else if (std < 12)
		return "vormittags";
	else if (std < 15)
		return "mittags";
	else if (std < 18)
		return "nachmittags";
	else if (std < 23)
		return "abends";
	else
		return "nachts";
}	

char *stds[12] =
{
	"eins", "zwei", "drei", "vier", "f］f", "sechs",
	"sieben", "acht", "neun", "zehn", "elf", "zw罵f"
};

char *zeit(unsigned char std, unsigned char min)
{
	static char result[ZEILE];

	char *inquarters;
	char *quarters[4] =
	{
		"\b", "viertel", "halb", "dreiviertel"
	};

	int s = std;
	int quarter = min / 15;
	int inquarter = min % 15;

	if (inquarter > 7)
	{
		quarter = (quarter + 1) % 4;
		++std;
	}
	else if (quarter > 0)
		++std;

	std = std % 12;
	if (std == 0)
		std = 12;

	if (inquarter == 0)
		inquarters = "genau";
	else if (inquarter < 3)
		inquarters = "kurz nach";
	else if (inquarter < 5)
		inquarters = "gleich f］f nach";
	else if (inquarter == 5)
		inquarters = "f］f nach";
	else if (inquarter < 8)
		inquarters = "gerade f］f nach";
	else if (inquarter < 10)
		inquarters = "gleich f］f vor";
	else if (inquarter == 10)
		inquarters = "f］f vor";
	else if (inquarter < 13)
		inquarters = "gerade f］f vor";
	else
		inquarters = "kurz vor";

	sprintf(result, "%s %s %s (%s)\n", inquarters, quarters[quarter], stds[std - 1], tageszeit(s));
	return result;
}

char *wessizeit(unsigned char std, unsigned char min)
{
	static char result[ZEILE];

	char *halfs[2] =
	{
		"\b", "halb"
	};

	char *inhalfs;

	int s = std;
	int half = (min > 17 && min < 43) ? 1 : 0;
	int inhalf = min % 30;

	if (min > 17)
		++std;
	std = std % 12;
	if (std == 0)
		std = 12;

	if (inhalf == 0)
		inhalfs = "genau";
	else if (inhalf < 3)
		inhalfs = "kurz nach";
	else if (inhalf < 5)
		inhalfs = "gleich f］f nach";
	else if (inhalf == 5)
		inhalfs = "f］f nach";
	else if (inhalf < 8)
		inhalfs = "gerade f］f nach";
	else if (inhalf < 10)
		inhalfs = "gleich zehn nach";
	else if (inhalf == 10)
		inhalfs = "zehn nach";
	else if (inhalf < 13)
		inhalfs = "gerade zehn nach";
	else if (inhalf < 15)
		inhalfs = (min < 30) ? "gleich viertel nach" : "gleich viertel vor";
	else if (inhalf == 15)
		inhalfs = (min < 30) ? "viertel nach" : "viertel vor";
	else if (inhalf < 18)
		inhalfs = (min < 30) ? "gerade viertel nach" : "gerade viertel vor";
	else if (inhalf < 20)
		inhalfs = "gleich zehn vor";
	else if (inhalf == 20)
		inhalfs = "zehn vor";
	else if (inhalf < 23)
		inhalfs = "gerade zehn vor";
	else if (inhalf < 25)
		inhalfs = "gleich f］f vor";
	else if (inhalf == 25)
		inhalfs = "f］f vor";
	else if (inhalf < 28)
		inhalfs = "gerade f］f vor";
	else
		inhalfs = "kurz vor";

	sprintf(result, "%s %s %s (%s)\n", inhalfs, halfs[half], stds[std - 1], tageszeit(s));
	return result;
}

void main(int argc, char *argv[])
{
	struct date dt;
#define jahr	dt.da_year
#define monat	dt.da_mon
#define tag		dt.da_day

	struct time zt;
#define std		zt.ti_hour
#define min		zt.ti_min
#define sek		zt.ti_sec

	int mode = FALSE;

	if (argc > 1)
	{
		if (*argv[1] == '-')
		{
			if (strchr(argv[1], '?') != NULL)
			{
				fprintf(stderr, "usage: td -dgw\n");
				fprintf(stderr, "\td\tZeit digital anzeigen\n");
				fprintf(stderr, "\tg\tBegr≪ung entsprechend der Tageszeit ausgeben.\n");
				fprintf(stderr, "\tw\tZeit wessigerecht ausgeben\n");
				exit(0);
			}
			if (strchr(argv[1], 'w') != NULL)
				mode |= WESSIMODE;
			if (strchr(argv[1], 'd') != NULL)
				mode |= DIGTIME;
			if (strchr(argv[1], 'g') != NULL)
				mode |= GRUSS;
		}
	}

	getdate(&dt);
	gettime(&zt);

	if (mode & GRUSS)
		printf("\nGute%s!\n\n", gruss(std));

	printf
	(
		"Heute ist %s\n",
		datum
		(
			wochentag(tag, monat, jahr),
			tag, monat, jahr
		)
	);

	printf("Es ist ");
	if (mode & DIGTIME)
		printf("%02d:%02d:%02d Uhr\n", std, min, sek);
	else
		puts(mode & WESSIMODE ? wessizeit(std, min) : zeit(std, min));
}
