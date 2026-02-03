#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>

/* MODUL	ibm screen
** VERSION	1.0
** DATUM	7. August 1987
** AUTOR	Uwe Sauerland
** ZWECK	Nachtrag der aus Turbo-Pascal bekannten Bildschirm Routinen.
**
*/

void gotoxy(int x, int y)
{
	putch('\033');
	putch('E');
	putch(32 + y);
	putch(32 + x);
}

void clrscr(void)
{
	putch('\033');
	putch('E');
}

void clreol(void)
{
	putch('\033');
	putch('K');
}

void clreos(void)
{
	putch('\033');
	putch('J');
}


/* PROGRAMM	more
** VERSION	2.0
** DATUM	9. Dezember 1987
** AUTOR	Uwe Sauerland
** ZWECK	Filter: nach jeweils SCRNLEN-1 Zeilen wird die Ausgabe angehal-
**			ten und eine Information ber den verbleibenden Rest ausgege-
**			ben.
**/

#define FALSE	0
#define TRUE	1

#define SCRNLEN	25
#define LINELEN	80

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

long size;
int show_size, noscroll = FALSE;

char *fname;

void congets(char *s)
{
	int ch, i = 0;

	while ((ch = getch() & 0xFF) != '\r')
	{
		if (ch == '\b')
		{
			if (i > 0)
			{
				putch('\b'); putch(' '); putch('\b');
				--i;
			}
		}
		else
			putch(s[i++] = (char) ch);
	}
	s[i] = '\0';
}

char *match(char *s1, char *s2, int ignorecase)
{
	char str1[LINELEN+1], str2[LINELEN+1];

	strcpy(str1, s1);
	strcpy(str2, s2);
	if (ignorecase)
	{
		strupr(str1);
		strupr(str2);
	}
	return strstr(str1, str2);
}

void help(void)
{
	clrscr();
	printf("MORE commands\n");
	printf("ÿÿÿÿÿÿÿÿÿÿÿÿÿ\n\n");
	printf("[space]\t\t\tdisplay another screenfull\n");
	printf("[return]\t\tdisplay the next line in file\n");
	printf("f\t\t\tdisplay the name of the file being displayed\n");
	printf("Cntrl-C, ESC, q, Q\texit from more\n");
	printf("h\t\t\tHelp command; this screen\n");
	printf("/string\t\t\tscan for next occurence of string\n");
	printf("\\string\t\t\tscan for string, but ignore character case\n");
	printf("n\t\t\tscan for the most recent scanned string again\n");
	printf("'\t\t\tgo to the point where the last scan started\n");
	printf("#\t\t\trestart from the beginning of the file\n");
	printf("x\t\t\tgo to next file\n");
	printf("\npress any key to continue...");
	getch();
	clrscr();
}

void more(FILE *source)
{
	static int lines = 0;
	int ch = 0, scanmode = FALSE, ignorecase = FALSE;
	long done = 0L;
	long pagestart = 0L, scanstart = 0L, scancont = 0L;
	char linbuf[LINELEN+1], scanstr[LINELEN+1];

	if (source == stdin)
	{
		pagestart = scanstart = -1L;
	}
	else
	{
		pagestart = scanstart = 0L;
	}

	while (fgets(linbuf, LINELEN+1, source) != NULL)
	{
		if (scanmode)
		{
			if (match(linbuf, scanstr, ignorecase) == NULL)
				continue;
			else
			{
				scanmode = FALSE;
				scancont = source == stdin ? -1L : ftell(source);
			}
		}
		if (noscroll)
			clreol();
		printf("%s", linbuf);
		done += strlen(linbuf);
		++lines;

		if (lines >= SCRNLEN - 1)
		{	/* page is full */
			printf("---- more ");
			if (show_size)
				printf("(%d%%) ", (int) ((done * 100) / size));
			printf("---- ");
			for (;;)
			{	/* now look for command */
				ch = getch() & 0xFF;
				switch (ch)
				{
					case 'q': case 'Q':
					case 3:	/* Cntrl-C	*/
					case 27: /* ESC */
						exit(0);
					case 'f':
						if (source != stdin)
						{
							printf("\rfile: %s ", fname);
							clreol();
						}
						continue;
					case 'h':
						help();
					case '.':
						if (pagestart >= 0)
						{
							fseek(source, pagestart, SEEK_SET);
							done = pagestart;
						}
						lines = 0;
						break;
					case 'x':
						lines = 0;
						putchar('\r');
						clreol();
						return;
					case '\\':
						ignorecase = TRUE;
						printf("\r\\"); clreol();
						congets(scanstr);
						if (! strlen(scanstr))
							continue;
						if (scanstart >= 0)
							scanstart = ftell(source);
						scanmode = TRUE;
						lines = 0;
						clrscr();
						break;
					case '/':
						ignorecase = FALSE;
						printf("\r/"); clreol();
						congets(scanstr);
						if (! strlen(scanstr))
							continue;
						if (scanstart >= 0)
							scanstart = ftell(source);
						scanmode = TRUE;
						lines = 0;
						clrscr();
						break;
					case 'n':
						if (strlen(scanstr))
						{
							if (scancont >= 0L)
								fseek(source, scancont, SEEK_SET);
							scanmode = TRUE;
							lines = 0;
							clrscr();
						}
						break;
					case '\'':
						if (scanstart >= 0)
						{
							fseek(source, scanstart, SEEK_SET);
							done = scanstart;
						}
						lines = 0;
						break;
					case '#':
						if (pagestart >= 0)
						{
							rewind(source);
							done = pagestart = 0L;
							lines = 0;
							clrscr();
						}
						break;
					case '\r': /* [ENTER] */
						--lines;
						break;
					case ' ':
					default:
						lines = 0;
						break;
				}
				break;
			}
			putchar('\r'); clreol();
			if (noscroll && ch != '\r')
				gotoxy(0, 0);
			pagestart = source == stdin ? -1L : ftell(source);
		}
	}
}

FILE *open_source(char *pname, char *mode)
{
	struct ffblk finfo;

	if (findfirst(pname, &finfo, FA_SYSTEM | FA_HIDDEN))
		return NULL;
	else
	{
		size = finfo.ff_fsize;
		return fopen(pname, mode);
	}
}

void main(int argc, char *argv[])
{
	int i, sourcespec = FALSE;
	FILE *source, *open_source();

	if (argc < 2)
	{
		show_size = FALSE;
		more(stdin);
	}
	else
	{
		show_size = TRUE;
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] == '-')
			{
				if (strchr(argv[i], '?') != NULL)
				{
					fprintf(stderr, "usage: more -c  { <file> }\n");
					fprintf(stderr, "\tc\tclear each line rather than scrolling.\n");
					fprintf(stderr, "\t\tpress h for help\n");
					exit(0);
				}
				if (strchr(argv[i], 'c') != NULL)
				{
					noscroll = TRUE;
					clrscr();
				}
			}
			else
			{
				sourcespec = TRUE;
				size = 0L; fname = argv[i];
				if ((source = open_source(fname, "r")) != NULL)
					more(source);
				else
					fprintf(stderr, "couldn't open %s\n", argv[i]);
				fclose(source);
			}
		}
		if (! sourcespec)
		{
			show_size = FALSE;
			more(stdin);
		}
	}
	if (noscroll)
		clreos();
}
