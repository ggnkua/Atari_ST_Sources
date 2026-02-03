/* PROGRAMM Text-Statistik
 * VERSION 2.0
 * DATUM   17. Juli 1987
 * AUTOR   Uwe Sauerland
 * ZWECK   zÑhlt Zeichen, Wîrter, SÑtze und Zeilen im Eingabestrom
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#define FALSE	0
#define TRUE	1

#define ist_buchstabe(c)								\
		(												\
			isalpha(c) ||								\
			((char) c >= 'Ä' && (char) c <= 'ö') ||		\
			((char) c >= '†' && (char) c <= '•') ||		\
			(char) c == '·'								\
		)

#define ist_vokal(c)									\
		(												\
			toupper(c) == 'A' || toupper(c) == 'E'  ||	\
			toupper(c) == 'I' || toupper(c) == 'O'  ||	\
			toupper(c) == 'U' || toupper(c) == 'Y'  ||	\
			((char) c  >= 'Å' && (char)  c  <= 'Ü') ||	\
			((char) c  >= 'à' && (char)  c  <= 'ö')		\
		)

#define ist_konsonant(c)	(ist_buchstabe(c) && ! ist_vokal(c))

#define ist_satzende(c)									\
		(												\
			(char) c == '.' || (char) c == ':' ||		\
			(char) c == '!' || (char) c == '≠' ||		\
			(char) c == '?' || (char) c =='®'			\
		)

#define ist_zeilenende(c)	((char) c == '\n')


const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

int einsilbig(char wort[])
{
	int i, silben;

	silben = (ist_vokal(wort[0])) ? 1 : 0;
	for (i = 0; i < strlen(wort) - 1; ++i)
		if
		(
			(
				(ist_konsonant(wort[i]) || i == 0) &&
				ist_vokal(wort[i + 1])
			) ||
			(
				(toupper(wort[i]) == 'U') &&
				(toupper(wort[i + 1]) == 'E')
			)
		)
			++silben;
	return silben <= 1;
}

void scantext
(
	FILE *source,
	unsigned long *zeichen,
	unsigned long *woerter,
	unsigned long *saetze,
	unsigned long *zeilen,
	unsigned long *einsilber
)
{
	int ch, i = 0, abkuerzung = TRUE;
	char wort[1024];

	while ((ch = fgetc(source)) != EOF)
	{
		if (ist_buchstabe(ch))
		{
			wort[0] = (char) (i = 0);
			while (ist_buchstabe(ch))
			{
				(*zeichen)++;
				wort[i] = ch;
				wort[++i] = 0;
				if ((ch = fgetc(source)) == EOF)
					return;
			}
			if (ist_satzende(ch) && strlen(wort) > 1)
				abkuerzung = FALSE;
			else
			{
				(*woerter)++;
				if (einsilbig(wort))
				{
					(*einsilber)++;
				}
			}
		}
		(*zeichen)++;
		if (ist_satzende(ch))
		{
			if (abkuerzung)
				abkuerzung = FALSE;
			else
				(*saetze)++;
		}
		if (ist_zeilenende(ch))
		{
			(*zeilen)++;
			(*zeichen)--;
		}
	}
}

void showstat
(
	unsigned long zeichen,
	unsigned long woerter,
	unsigned long saetze,
	unsigned long zeilen,
	unsigned long einsilber,
	int disp_nrei
)
{
	double nrei, nosw, sl;

	printf("Zeichen: %10lu\n", zeichen);
	printf("Wîrter : %10lu\n", woerter);
	printf("SÑtze  : %10lu\n", saetze);
	printf("Zeilen : %10lu\n", zeilen);
	if (disp_nrei && saetze && woerter)
	{
		sl = (double) woerter / (double) saetze;
		nosw = (double) einsilber / (double) woerter * 100.0;
		nrei = 1.599 * nosw - 1.015 * sl - 31.517;
		putchar('\n');
		printf("Ì Wîrter je Satz : %13.2f\n", sl);
		printf("Einsilbige Wîrter: %13.2f\n", nosw);
		printf("Lesbarkeitsindex : %13.2f\n", nrei);
	}
}

void tstat(FILE *source, int gennrei)
{
	unsigned long zeichen = 0L, woerter = 0L, saetze  = 0L, zeilen  = 0L;
	unsigned long einsilber = 0L;

	scantext(source, &zeichen, &woerter, &saetze, &zeilen, &einsilber);
	showstat(zeichen, woerter, saetze, zeilen, einsilber, gennrei);
}

void main(int argc, char *argv[])
{
	int i, gennrei = FALSE;
	FILE *source = stdin;

	if (argc < 2)
		tstat(stdin, FALSE);
	else
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{
				if (strchr(argv[i], '?') != NULL)
				{
					fprintf(stderr, "usage: wc -nrei { <file> }\n");
					fprintf(stderr, "\tnrei\tgenerate new reading ease index\n");
					exit(0);
				}
				if (! strcmp(argv[i], "-nrei"))
					gennrei = TRUE;
			}
			else if ((source = fopen(argv[i], "r")) == NULL)
				fprintf(stderr, "couldn't open %s\n", argv[i]);
			else
			{
				printf("\nscanning file %s\n", argv[i]);
				tstat(source, gennrei);
				fclose(source);
			}
		}
}
