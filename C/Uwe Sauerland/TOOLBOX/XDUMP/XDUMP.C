/* PROGRAMM	xdump
** VERSION	2.0
** DATUM	30. Juli 1987
** AUTOR	Uwe Sauerland
** ZWECK	extended dump
**/

#include <stdio.h>
#include <string.h>

#define FALSE	0
#define TRUE	1

#define ALEN	79
#define HLEN	26
#define HALEN	16

typedef unsigned char BYTE;

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

int ascii = TRUE, hex = TRUE;

void dispbuffer(int len, BYTE buffer[])
{
	int i;

	if (! hex)		/* then it's ascii */
		for (i = 0; i < len; i++)
			printf("%c", (int) buffer[i] < 32 ? 'ú' : (char) buffer[i]);
	else if (! ascii)	/* should be hex */
		for (i = 0; i < len; i++)
			printf("%02X ", (int) buffer[i]);
	else			/* both formats required */
	{
		for (i = 0; i < len; i++)
			printf("%02X ", (int) buffer[i]);
		for (i = 0; i < (48 - len * 3); i++)
			putchar(' ');
		printf("            ");
		for (i = 0; i < len; i++)
			printf("%c", (int) buffer[i] < 32 ? 'ú' : (char) buffer[i]);
	}
	putchar('\n');
}

void dumpline(FILE *source)
{
	BYTE buffer[ALEN];

	strncpy(buffer, "", ALEN);	/* fill buffer with '\0' */
	if (! hex)
		dispbuffer(fread(buffer, sizeof(BYTE), ALEN, source), buffer);
	else if (! ascii)
		dispbuffer(fread(buffer, sizeof(BYTE), HLEN, source), buffer);
	else
		dispbuffer(fread(buffer, sizeof(BYTE), HALEN, source), buffer);
}

void dumpfile(char *fname)
{
	FILE *source;

	if ((source = fopen(fname, "rb")) == NULL)
		fprintf(stderr, "couldn't open %s\n", fname);
	else
	{
		printf("dumping %s\n", fname);
		while (! feof(source))
			dumpline(source);
	}
	fclose(source);
	putchar('\n');
}

void main(int argc, char *argv[])
{
	int i;

	if (argc < 2)
	{
		fprintf(stderr, "usage: xdump [ -ha ] <file> { <file> }\n");
		fprintf(stderr, "options:\n\n");
		fprintf(stderr, "\th\thex only\n");
		fprintf(stderr, "\ta\tascii only\n");
	}
	else
	{
		for (i = 1; i < argc; i++)
		{
			if (*argv[i] != '-')
				dumpfile(argv[i]);
			else
			{
				strupr(argv[i]);
				if (strchr(argv[i], 'A') != NULL)
					hex = ! (ascii = TRUE);
				if (strchr(argv[i], 'H') != NULL)
					hex = ! (ascii = FALSE);
				if (strchr(argv[i], 'A') != NULL && strchr(argv[i], 'H') != NULL)
					hex = (ascii = TRUE);					
			}
		}
	}
}
