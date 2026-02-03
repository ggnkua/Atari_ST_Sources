/* PROGRAMM     Print file
** VERSION      1.0
** DATUM        19. Februar 1987
** AUTOR        Uwe Sauerland
** ZWECK        formatierte Ausgabe von Textfiles
**
**		Optionen:
**			-p[l|z|r][t|r]	Seitennummern drucken
**			-h		Dateikopfzeile erzeugen
**			-n		Zeilen nummerieren
**			-f		Seitenvorschub mit Linefeeds
**
**		Parameter:
**			+h "text"	Kopfzeile
**			+f "text"	Fuázeile
**			+l <number>	Linker Rand (Zeichen)
**			+r <number>	Rechter Rand (Zeichen)
**			+t <number>	Oberer Rand (Zeilen)
**			+b <number>	Unterer Rand (Zeilen)
**			+p <number>	Seitenl„nge (Zeilen)
**			+w <number>	Seitenbreite (Spalten)
**			+c <number>	Zeichengr”áe (Zeichen/Zoll)
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ext.h>

#define FALSE	0
#define TRUE	1

#define PNLEFT		0x01
#define PNCENTER	0x02
#define PNRIGHT		0x04
#define PNTOP		0x08
#define PNBOTTOM	0x10

#define chrcat(s,c)	s[strlen(s)+1]='\0';s[strlen(s)]=c
#define lastchar(s)	s[strlen(s)-1]

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1988";


int	pagplace = FALSE, numlines = FALSE;

char	headln[81] = {0};
char	footln[81] = {0};
char	fname[81] = "® stdin ¯";

int	leftmarg = 10, rightmarg = 0, topmarg = 1, botmarg = 5;
int	paglen = 72, pagwidth = 80, charpitch = 10, oldpitch = 10;
int	useff = TRUE, filehead = FALSE;

void printmarg(int marg)
{
	int i;

	for (i = 0; i < marg; ++i)
		putchar(' ');
}

void pagenumber(unsigned pagnum, unsigned actwidth, unsigned pagline)
{
	char result[1024];
	int i;

	if (pagplace & pagline)
	{
		sprintf(result, "page %d", pagnum);

		if (pagline == PNBOTTOM)
			putchar('\n');
		printmarg(leftmarg);
		if (pagplace & PNCENTER)
		{
			for (i = 0; i < (actwidth - strlen(result)) / 2; ++i)
				putchar(' ');
		}
		else if (pagplace & PNRIGHT)
		{
			for (i = 1; i < (actwidth - strlen(result)); ++i)
				putchar(' ');
		}
		printf("%s\n", result);
		if (pagline == PNTOP)
			putchar('\n');
	}
}

void pagehead(unsigned *paglin, unsigned *pagnum, unsigned actwidth)
{
	int i;

	for (i = 0; i < topmarg; ++i)
		putchar('\n');

	++(*pagnum);
	if (filehead)
	{
		struct date da;
		struct time ti;

		getdate(&da);
		gettime(&ti);
		
		sprintf
		(
			headln, "%d. %d. %4d\t%02d:%02d\tfile: %s\tpage %d",
			da.da_day, da.da_mon, da.da_year, ti.ti_hour, ti.ti_min,
			fname, *pagnum
		);
	}
	else if (pagplace)
	{
		*paglin += 2;
		pagenumber(*pagnum, actwidth, PNTOP);
	}
	if (strlen(headln) > 0)
	{
		printmarg(leftmarg);
		printf("%s\n\n", headln);
		*paglin += 2;
	}
}

void pagefoot(unsigned pagnum, unsigned actwidth)
{
	int i;

	if (strlen(footln))
	{
		putchar('\n');
		printmarg(leftmarg);
		printf("%s\n", footln);
	}
	pagenumber(pagnum, actwidth, PNBOTTOM);
	if (useff && (botmarg > 0))
		putchar('\f');
	else
		for (i = 0; i < botmarg; ++i)
			putchar('\n');
}

int readline(FILE *source, char *curlin, int max)
{
	int i, ch;

	strcpy(curlin, ""); i = 0;

	while ((i < max) && ! feof(source))
	{
		ch = fgetc(source);
		switch (ch)
		{
			case '\n':
				chrcat(curlin, '\n');
				i = max;
				break;
			case '\t':
				chrcat(curlin, ' '); ++i;
				while (i % 8)
				{
					chrcat(curlin, ' ');
					++i;
				}
				break;
			default:
				chrcat(curlin, (char) ch);
				++i;
				break;
		}
	}

	return strlen(curlin);
}

void printline(char *curlin, unsigned *paglin, unsigned *pagnum, unsigned actwidth)
{
	for (; *curlin; ++curlin)
	{
		if (paglen && *curlin == '\f')
		{
			for (; *paglin < paglen - topmarg - botmarg; ++(*paglin))
				putchar('\n');
			pagefoot(*pagnum, actwidth);
			paglin = 0;
			pagehead(paglin, pagnum, actwidth);
			if (strlen(footln) > 0)
				paglin += 2;
		}
		else
			putchar(*curlin);
	}
	putchar('\n');
}

void pr(FILE *source)
{
	char curlin[1024];			/* that should be enough!! */
	unsigned linum = 0, pagnum = 0, paglin = 0;
	unsigned actwidth, i;

	actwidth = pagwidth - leftmarg - rightmarg;
	if (numlines)
		actwidth -= 8;

	while (readline(source, curlin, actwidth))
	{
		if (paglen && paglin == 0)
		{
			pagehead(&paglin, &pagnum, actwidth);
			if (strlen(footln) > 0)
				paglin += 2;
		}
		printmarg(leftmarg);
		if (numlines)
		{
			++linum;
			printf("%5u: ", linum);
		}
		if (lastchar(curlin) == '\n')
			lastchar(curlin) = '\0';
		printline(curlin, &paglin, &pagnum, actwidth);
		if (paglen && ++paglin >= paglen - topmarg - botmarg)
		{
			pagefoot(pagnum, actwidth);
			paglin = 0;
		}
	}
	if (paglen && paglin)
	{
		if ((pagplace & PNBOTTOM) || strlen(footln))
			for (; paglin < paglen - topmarg - botmarg; ++paglin)
				putchar('\n');
		pagefoot(pagnum, actwidth);
	}
}

void main(int argc, char *argv[])
{
	int i;
	char parm;
	FILE *source = stdin;

	if (argc < 2)
		/* stdin --> filter --> stdout */;
	else
	{
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{
				/* get options */;
				if (*(argv[i] + 1) == '?')
				{
					fprintf(stderr, "usage: pr -p[l³c³r][t³b] -h -n -f +h \"header\" +f \"footer\" ...\n");
					fprintf(stderr, "\t\t +l <n> +r <n> +t <n> +b <n> +p <n> +w <n> +c <n>\n");
					fprintf(stderr, "\t-p\tpage number at left³center³right top³bottom (-p = -pcb)\n");
					fprintf(stderr, "\t-h\tcreate a file descriptive header\n");
					fprintf(stderr, "\t-n\tprint line numbers\n");
					fprintf(stderr, "\t-f\tdon't use form feeds\n");
					fprintf(stderr, "\t+h\tdefine headline\n");
					fprintf(stderr, "\t+f\tdefine footline\n");
					fprintf(stderr, "\t+l\tset left margin\n");
					fprintf(stderr, "\t+r\tset right margin\n");
					fprintf(stderr, "\t+t\tset top margin\n");
					fprintf(stderr, "\t+b\tset bottom margin\n");
					fprintf(stderr, "\t+p\tset page length (lines)\n");
					fprintf(stderr, "\t+w\tset page width (columns)\n");
					fprintf(stderr, "\t+c\tset character pitch (cpi) and recalc margins\n");
					exit(0);
				}
				if (*(argv[i] + 1) == 'p')
				{
					if (strchr(argv[i], 'l') != NULL)
						pagplace = PNLEFT;
					else if (strchr(argv[i], 'c') != NULL)
						pagplace = PNCENTER;
					else if (strchr(argv[i], 'r') != NULL)
						pagplace = PNRIGHT;
					else
						pagplace = PNCENTER;
					if (strchr(argv[i], 't') != NULL)
						pagplace |= PNTOP;
					else if (strchr(argv[i], 'b') != NULL)
						pagplace |= PNBOTTOM;
					else
						pagplace |= PNBOTTOM;
				}
				else if (*(argv[i] + 1) == 'h')
					filehead = TRUE;
				else if (*(argv[i] + 1) == 'n')
					numlines = TRUE;
				else if (*(argv[i] + 1) == 'f')
					useff = FALSE;
			}
			else if (*argv[i] == '+')
			{
				/* get parameters */;
				parm = *(argv[i++] + 1);
				switch(parm)
				{
					case 'h':
						strcpy(headln, argv[i]);
						break;
					case 'f':
						strcpy(footln, argv[i]);
						break;
					case 'l':
						sscanf(argv[i], "%d", &leftmarg);
						break;
					case 'r':
						sscanf(argv[i], "%d", &rightmarg);
						break;
					case 't':
						sscanf(argv[i], "%d", &topmarg);
						break;
					case 'b':
						sscanf(argv[i], "%d", &botmarg);
						break;
					case 'p':
						sscanf(argv[i], "%d", &paglen);
						break;
					case 'w':
						sscanf(argv[i], "%d", &pagwidth);
						break;
					case 'c':
						sscanf(argv[i], "%d", &charpitch);
						pagwidth = (pagwidth / oldpitch) * charpitch;
						leftmarg = (leftmarg / oldpitch) * charpitch;
						rightmarg = (rightmarg / oldpitch) * charpitch;
						oldpitch = charpitch;
						break;
				}
			}
			else if ((source = fopen(argv[i], "r")) != NULL)
			{
				strcpy(fname, argv[i]);
				pr(source);
				fclose(source);
			}
			else
			{
				fprintf(stderr, "couldn't open %s\n", argv[i]);
				exit(1);
			}
		}
	}

	if (source == stdin)
		pr(source);
}
