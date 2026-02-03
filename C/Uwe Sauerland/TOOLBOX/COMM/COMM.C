/* PROGRAMM	comm
** VERSION	1.0
** DATUM	1. August 1987
** AUTOR	Uwe Sauerland
** ZWECK	Anzeiger gleicher Zeilen in zwei sortierten Dateien.
**			Spalte 1 enth„lt Zeilen, die nur in Datei1 enthalten sind.
**			Spalte 2 enth„lt Zeilen, die nur in Datei2 enthalten sind.
**			Spalte 3 enth„lt Zeilen, die in beiden Dateien enthalten
**			sind.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define FALSE	0
#define TRUE	1
#define LEN	1024

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

int next(FILE *f, char *s)
{
	if (fgets(s, LEN, f) != NULL)
		return FALSE;
	else
	{
		strcpy(s, "");
		return TRUE;
	}
}

int compare(char *l1, char *l2)
{
	if (! *l1)
		return 1;
	else if (! *l2)
		return -1;
	else
		return strcmp(l1, l2);
}

void comm(FILE *f1, FILE *f2, int col1, int col2, int col3)
{
	char l1[LEN], l2[LEN];
	int eof1, eof2;

	eof1 = next(f1, l1);
	eof2 = next(f2, l2);

	while (! (eof1 && eof2))
	{
		while (compare(l1, l2) == 0)
		{
			if (col3)
				printf("\t\t%s", l1);

			eof1 = next(f1, l1);
			eof2 = next(f2, l2);

			if (eof1 || eof2)
				break;
		}

		if (compare(l1, l2) < 0 && ! eof1)
			while (compare(l1, l2) < 0)
			{
				if (col1)
					printf("%s", l1);
				if (eof1 = next(f1, l1))
					break;
			}
		else if (compare(l1, l2) > 0 && ! eof2)
			while (compare(l1, l2) > 0)
			{
				if (col2)
					printf("\t%s", l2);
				if (eof2 = next(f2, l2))
					break;
			}
	}
}

void help(void)
{
	fprintf(stderr, "usage: comm -123 <file1> [ <file2> ]\n");
	fprintf(stderr, "\t-123\tsupresses display of column 1, 2, 3\n");
	exit(0);
}

void main(int argc, char *argv[])
{
	FILE *file1 = NULL, *file2 = NULL;
 	int i, col1 = TRUE, col2 = TRUE, col3 = TRUE;

	if (argc < 2)
		help();
	else
	{
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{
				if (strchr(argv[i], '?') != NULL)
					help();
				if (strchr(argv[i], '1') != NULL)
					col1 = FALSE;
				if (strchr(argv[i], '2') != NULL)
					col2 = FALSE;
				if (strchr(argv[i], '3') != NULL)
					col3 = FALSE;
			}
			else
			{
				if (file1 == NULL)
				{
					if ((file1 = fopen(argv[i], "r")) == NULL)
					{
						fprintf(stderr, "couldn't open %s\n", argv[i]);
						exit(1);
					}
				}
				else
				{
					if ((file2 = fopen(argv[i], "r")) == NULL)
					{
						fprintf(stderr, "couldn't open %s\n", argv[i]);
						exit(1);
					}
				}
			}
		}
		if (file2 == NULL)
			file2 = stdin;
		comm(file1, file2, col1, col2, col3);
	}
}
