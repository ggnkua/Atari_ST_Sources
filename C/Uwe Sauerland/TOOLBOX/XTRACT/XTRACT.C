/* PROGRAMM	File extract
** VERSION	2.0
** DATUM	9. M„rz 1988
** AUTOR	Uwe Sauerland
** ZWECK	Extrahieren von Ausschnitten aus Dateien
**			(Kombination aus Head und Tail)
**			Im Binaermodus gilt die Ausschnittangabe jeweils in Bytes,
**			im Textmodus in Zeilen.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	FALSE	0
#define TRUE	1
#define EDGE	0

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1988";

int binary = FALSE;

long unsigned first = EDGE, last = EDGE;


void xtract
(
	FILE *source, FILE *dest,
	long unsigned first,
	long unsigned last
)
{
	long unsigned i = 0;
	unsigned char ch;

	if (first > EDGE)
		while (i < first)
		{
			fread(&ch, sizeof(ch), 1, source);
			if (binary || ch == '\n')
				++i;
		}

	while (! feof(source))
	{
		fread(&ch, sizeof(ch), 1, source);
		if (last == EDGE || i <= last)
		{
			fwrite(&ch, sizeof(ch), 1, dest);
			if (binary || ch == '\n')
				++i;
		}
		else
			break;
	}
}

void main(int argc, char *argv[])
{
	int i;
	FILE *source = stdin, *dest = stdout;

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
					fprintf(stderr, "usage: xtract -b +f <first> +l <last> +s <skip> +n <number> ...\n");
					fprintf(stderr, "\t\t... [ <source> [ <dest> ]]\n");
					fprintf(stderr, "\t-b\tuse binary mode (f/l describe bytes rather than lines).\n");
					fprintf(stderr, "\t+f\tfirst line/byte to be extracted (default=begin of file).\n");
					fprintf(stderr, "\t+l\tlast line/byte to extract (default=end of file).\n");
					fprintf(stderr, "\t+s\tskip <skip> lines/bytes.\n");
					fprintf(stderr, "\t+n\txtract <number> lines/bytes.\n");
					exit(0);
				}
				if (strchr(argv[i], 'b') != NULL)
					binary= TRUE;
			}
			else if (*argv[i] == '+')
			{
				/* get parameters */;
				if (strchr(argv[i], 'f') != NULL)
				{
					sscanf(argv[++i], "%lu", &first);
					if (first)
						--first;
				}
				else if (strchr(argv[i], 'l') != NULL)
				{
					sscanf(argv[++i], "%lu", &last);
					if (last)
						--last;
				}
				else if (strchr(argv[i], 's') != NULL)
					sscanf(argv[++i], "%lu", &first);
				else if (strchr(argv[i], 'n') != NULL)
				{
					sscanf(argv[++i], "%lu", &last);
					if (last)
						last += first - 1;
					else
						exit(0);
				}
			}
			else if (source == stdin)
			{
				if ((source = fopen(argv[i], binary ? "rb" : "r")) == NULL)
				{
					fprintf(stderr, "couldn't open %s\n", argv[i]);
					exit(1);
				}
			}
			else if ((dest = fopen(argv[i], binary ? "wb" : "w")) == NULL)
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
	}

	/* filter(source, dest, ...) */
	xtract(source, dest, first, last);

	if (source != stdin)
		fclose(source);
	if (dest != stdout)
		fclose(dest);
}
