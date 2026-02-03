/* PROGRAMM	TEE
** VERSION	1.0
** DATUM	5. Oktober 1988
** AUTOR	Uwe Sauerland
** ZWECK	Richtet eine Abzweigung in eine Datei in einer Pipe ein.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

void tee(FILE *dest)
{
	int ch;

	while ((ch = getchar()) != EOF)
	{
		putchar(ch);
		if (dest != stdout)
			fputc(ch, dest);
	}
}

void main(int argc, char *argv[])
{
	int i;
	FILE *dest = stdout;

	if (argc < 2)
		/* stdin --> filter --> stdout */;
	else
	{
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{
				/* get options */;
				if (strchr(argv[i], '?') != NULL)
				{
					fprintf(stderr, "usage: tee <file>\n");
					exit(0);
				}
			}
			else if ((dest = fopen(argv[i], "w")) == NULL)
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
	}

	tee(dest);
	if (dest != stdout)
		fclose(dest);
}
