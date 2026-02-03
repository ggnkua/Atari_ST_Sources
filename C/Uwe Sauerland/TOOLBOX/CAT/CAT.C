/* PROGRAMM	cat
 * VERSION	1.0
 * DATUM	31. Juli 1987
 * AUTOR	Uwe Sauerland
 * ZWECK	gibt alle als Parameter angegebenen Files als ein File aus
 *
 */

#include <stdio.h>

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

void cat(FILE *source)
{
	int ch;

	while ((ch = fgetc(source)) != EOF)
		putchar(ch);
}

void main(int argc, char *argv[])
{
	int i;
	FILE *source;

	if (argc < 2)
		cat(stdin);
	else
		for (i = 1; i < argc; i++)
		{
			if ((source = fopen(argv[i], "r")) != NULL)
				cat(source);
			else
				fprintf(stderr, "couldn't open %s\n", argv[i]);
			fclose(source);
		}
}
