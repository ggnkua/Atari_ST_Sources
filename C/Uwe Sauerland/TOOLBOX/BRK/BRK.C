/* PROGRAMM	Multi File Index
 * MODUL	Break Source
 * VERSION	1.0
 * DATUM	4. Oktober 1987
 * AUTOR	Uwe Sauerland
 * ZWECK	Aufbrechen des Quelltextes in einzelne W”rter. Dabei werden
 *		W”rter, die nicht indiziert werden sollen, entfernt.
 *		Als W”rter gelten Zeichenketten, die mit white spaces abge-
 *		schlossen sind und mit einem Buchstaben oder einer Ziffer be-
 *		ginnen.
 *
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define FALSE	0
#define TRUE	1
#define LEN		1024

#define MAXBORINGS	1000
#define iswordch(c)	(isalnum(c) || (c >= '€' && c <= 'š') || (c >= ' ' && c <= '¥'))

static char *borelist[MAXBORINGS];
static int borings = 0;

static int readborelist(char *borename)
{
	FILE *borefile;
	char line[LEN];

	if ((borefile = fopen(borename, "r")) == NULL)
		return FALSE;
	else
		while (fgets(line, LEN, borefile) != NULL)
			if (strlen(line) - 1 > 0)
			{
				line[strlen(line) - 1] = '\0';
				borelist[borings] = (char *) malloc(strlen(line) + 1);
				strcpy(borelist[borings++], line);
			}
	return TRUE;
}

static void freeborelist(void)
{
	int i;

	for (i = 0; i < borings; free(borelist[i++]));
}

static int fcmp(char *s1, char **s2)
{
	return strcmp(s1, *s2);
}

static int isboring(char *s)
{
	return bsearch(s, borelist, borings, sizeof(char *), fcmp) == NULL ? FALSE : TRUE;
}

static void dobreak(FILE *source, FILE *dest)
{
	char line[LEN], *c;
	char word[LEN];

	while (fgets(line, LEN, source) != NULL)
	{
		for (c = line; *c;)
		{
			for(; *c && (! iswordch(*c)); ++c);
			strcpy(word, "");
			for(; *c && iswordch(*c); ++c)
				strncat(word, c, 1);
			if (! (borings && isboring(word)))
				if (strlen(word))
					fprintf(dest, "%s\n", word);
		}
	}
}

void main(int argc, char *argv[])
{
	int i;
	FILE *source = stdin, *dest = stdout;
	char *borename;

	if (argc < 2)
		/* stdin --> filter --> stdout */;
	else
	{
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{ /* get options */

				if (strchr(argv[i], '?'))
				{
					fprintf(stderr, "usage: -b<file> [ <source> [ <destination ] ]\n");
					fprintf(stderr, "\tb<fname>\tuse specified file for boring list.\n");
					exit(0);
				}
				if ((borename = strchr(argv[i], 'b')) != NULL)
					if (! readborelist(++borename))
					{
						fprintf(stderr, "couldn't open boring-file: %s.\n", borename);
						exit(1);
					}
			}
			else if (source == stdin)
			{
				if ((source = fopen(argv[i], "r")) == NULL)
				{
					fprintf(stderr, "couldn't open %s\n", argv[i]);
					exit(1);
				}
			}
			else if ((dest = fopen(argv[i], "w")) == NULL)
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
	}

	dobreak(source, dest);
	freeborelist();

	if (source != stdin)
		fclose(source);
	if (dest != stdout);
		fclose(dest);
}
