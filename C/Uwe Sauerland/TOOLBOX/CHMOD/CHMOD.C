/* PROGRAMM	chmod
** VERSION	1.0
** DATUM	3. Dezember 1987
** AUTOR	Uwe Sauerland
** ZWECK	MSDOS File Attribute „ndern
**
*/

#include <ext.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

void found
(
	char *pathname,
	int setwrite, int sethidden, int setsystem, int setarchived
)
{
	int attribs;

	attribs = Fattrib(pathname, 0, 0);
	if (setwrite + sethidden + setsystem + setarchived == -4)
		/* display mode */
		printf
		(
			"%c%c%c%c %s\n",
			attribs & FA_RDONLY ? 'r' : 'w',
			attribs & FA_HIDDEN ? 'h' : '.',
			attribs & FA_SYSTEM ? 's' : '.',
			attribs & FA_ARCH   ? 'a' : '.',
			pathname
		);
	else
	{	/* set new mode */
#define	setmode(mode,flag)						\
		if (mode >= 0)							\
		{										\
			attribs &= ~flag;					\
			if (mode > 0)						\
				attribs |= flag;				\
		}

		setmode(setwrite, FA_RDONLY);
		setmode(sethidden, FA_HIDDEN);
		setmode(setsystem, FA_SYSTEM);
		setmode(setarchived, FA_ARCH);
		Fattrib(pathname, 1, attribs);
	}
}

void changemode
(
	char *pathname,
	int setwrite, int sethidden, int setsystem, int setarchived
)
{
	struct ffblk ffb;

	if (! findfirst(pathname, &ffb, FA_SYSTEM | FA_HIDDEN | FA_RDONLY))
	{
		found(ffb.ff_name, setwrite, sethidden, setsystem, setarchived);
		while (! findnext(&ffb))
			found(ffb.ff_name, setwrite, sethidden, setsystem, setarchived);
	}
}

void main(int argc, char *argv[])
{
	int i;
	int setwrite = -1, sethidden = -1, setsystem = -1, setarchived = -1;
	char pathname[81] = "*.*";

	for (i = 1; i < argc; i++)
	{
		if (*argv[i] == '-' || *argv[i] == '+')
		{
			if (strchr(argv[i], '?') != NULL)
			{
				fprintf(stderr, "usage: chmod +/-whsa <file>\n");
				fprintf(stderr, "\tset/reset Write, Hidden, System or Archived bit\n");
				exit(1);
			}
			if (strchr(argv[i], 'w') != NULL)
				setwrite = *argv[i] == '+' ? 0 : 1;
			if (strchr(argv[i], 'h') != NULL)
				sethidden = *argv[i] == '+' ? 1 : 0;
			if (strchr(argv[i], 's') != NULL)
				setsystem = *argv[i] == '+' ? 1 : 0;
			if (strchr(argv[i], 'a') != NULL)
				setarchived = *argv[i] == '+' ? 1 : 0;
		}
		else
			strcpy(pathname, argv[i]);
	}
	changemode(pathname, setwrite, sethidden, setsystem, setarchived);
}
