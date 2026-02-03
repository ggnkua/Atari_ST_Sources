/* PROGRAMM	uniq
** VERSION	1.0
** DATUM	2. August 1987
** AUTOR	Uwe Sauerland
** ZWECK	entfernen sich wiederholender Zeilen in einer sortierten Datei
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define FALSE	0
#define TRUE	1
#define LEN	1024

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

char *get_line(FILE *source, char buffer[], int skipf, int skipc)
{
	int i;
	char *ptr;

	if (fgets(buffer, LEN, source) == NULL)
	{
		return NULL;
	}
	else
	{
		ptr = buffer;
		if (skipf > 0)
		{
			while (isspace(*ptr)) ++ptr;
			for (; skipf && *ptr; --skipf)
			{
				while (! isspace(*ptr)) ++ptr;
				while (isspace(*ptr)) ++ptr;
			}
		}
		for (; skipc && *ptr; ++ptr, --skipc);
		return ptr;
	}
}

void uniq
(
	FILE *source, FILE *dest, 
	int unq, int dbl, int cnt, int skipf, int skipc
)
{
	char oldbuf[LEN], newbuf[LEN], *old, *new, *get_line();
	int count, done = FALSE;

	if ((old = get_line(source, oldbuf, skipf, skipc)) != NULL)
	{
		do
		{
			count = 0;	/* old has no doubles */
			do
			{
				if ((new = get_line(source, newbuf, skipf, skipc)) == NULL)
				{
					done = TRUE;
					break;
				}
				else if (strcmp(new, old) == 0)
                                	++count;
			} while (strcmp(new, old) == 0);
			if ((unq && count == 0) || (dbl && count != 0) || (! (unq || dbl)))
			{
				if (cnt)
					fprintf(dest, "%d\t", count + 1);
				fprintf(dest, "%s", oldbuf);
			}
			strcpy(oldbuf, newbuf);
		} while (! done);
	}
}

void main(int argc, char *argv[])
{
	int i;
	int unq = FALSE, dbl = FALSE, cnt = FALSE;
	int skipf = 0, skipc = 0;
	FILE *source = stdin, *dest = stdout;

	for (i = 1; i < argc; i++)
	{
		if (*argv[i] == '-')
		{
			if (strchr(argv[i], '?') != NULL)
			{
				fprintf(stderr, "usage: uniq -cdu -<n> +<m> [ <source> [ <dest> ]]\n");
				fprintf(stderr, "\tc\twrite number of occurances for each line\n");
				fprintf(stderr, "\td\twrite out non-unique lines only\n");
				fprintf(stderr, "\tu\twrite out unique lines only\n");
				fprintf(stderr, "\t<n>\tignore <n> fields\n");
				fprintf(stderr, "\t<m>\tignore <m> columns\n");
				exit(0);
			}
			if (strchr(argv[i], 'u') != NULL)
				unq = TRUE;
			if (strchr(argv[i], 'd') != NULL)
				dbl = TRUE;
			if (strchr(argv[i], 'c') != NULL)
				cnt = TRUE;
			if (isdigit(*(argv[i] + 1)))
				sscanf(argv[i] + 1, "%d", &skipf);
		}
		else if (*argv[i] == '+')
			sscanf(argv[i] + 1, "%d", &skipc);
		else if (source == stdin)
		{
			if ((source = fopen(argv[i], "r")) == NULL)
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
		else
		{
			if ((dest = fopen(argv[i], "w")) == NULL)
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
	}
	uniq(source, dest, unq, dbl, cnt, skipf, skipc);
}
