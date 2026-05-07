#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

#define	EOS	'\0'

int kwnum = 1;			/* current op# for kwgen output */

FILE *kfp;			/* keyword file */


int lineno = 0;

main(argc, argv)
int argc;
char **argv;
{
	char *namv[256];
	char *s;
	int namcnt;
	char ln[256];

	if (argc == 2)
		if ((kfp = fopen(argv[1], "w")) == NULL)
			error("Cannot create: %s", argv[1]);

	while (gets(ln) != NULL)
	{
		++lineno;			/* bump line# */
		if (*ln == '#')		/* ignore comments */
			continue;

		/*
		 *  Tokenize line (like the way "argc, argv" works)
		 *  and pass it to the parser.
		 */
		namcnt = 0;
		s = ln;
		while (*s)
			if (isspace(*s))
				++s;
			else
			{
				namv[namcnt++] = s;
				while (*s && !isspace(*s))
					++s;
				if (isspace(*s))
					*s++ = EOS;
			}

		if (namcnt)
			procln(namcnt, namv);
	}
}


/*
 *  Parse line
 */
procln(namc, namv)
int namc;
char **namv;
{
	int i, j;
	char *s;

	if (namc == 1)		/* alias for previous entry */
	{
		fprintf(kfp, "%s\t%d\n", namv[0], kwnum-1+1000);
		return;
	}

	if (namc < 5)
	{
		fprintf(stderr, "%d: missing fields\n", lineno);
		exit(1);
	}

	if (*namv[0] != '-')		/* output keyword name */
		fprintf(kfp, "%s\t%d\n", namv[0], kwnum + 1000);

	printf("/*%4d %-6s*/  {", kwnum, namv[0]);

	if (*namv[1] == '!')
		printf("CGSPECIAL");
	else for (s = namv[1], i=0; *s; ++s)
		printf("%sSIZ%c", (i++ ? "|" : ""), *s);
	printf(", %s, %s, ", namv[2], namv[3]);

	if (*namv[4] == '%')		/* enforce little fascist percent signs */
	{
		for (i=1, j=0; i < 17; ++i)
		{
			j <<= 1;
			if (namv[4][i] == '1' ||
				  isupper(namv[4][i]))
				++j;
		}
		printf("0x%04x, ", j);
	}
	else printf("%s, ", namv[4]);

	if (namc == 7 &&
		  *namv[6] == '+')
		printf("%d, ", kwnum+1);
	else printf("0, ");

	printf("%s},\n", namv[5]);

	++kwnum;
}


error(s, s1)
char *s, *s1;
{
	fprintf(stderr, s, s1);
	fprintf(stderr, "\n");
	exit(1);
}
