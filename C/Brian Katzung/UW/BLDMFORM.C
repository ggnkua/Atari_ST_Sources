#include <stdio.h>

main (ac, av)
char	**av;
{
	char	**ap, *cp;
	int	xhot, yhot, nplanes;
	int	maskcolor, datacolor;
	char	*datafn, *maskfn;
	char	*name;
	short	gemfmt = 0;
	short	rename = 0;

	if (ac < 2)
	{
		printf("usage:  -xypMDmdnG xhot yhot planes mcolor dcolor\n");
		printf("\t\tmaskfn datafn mformname\n");
		printf("or:     -dnR datafn newmformname\n");
		exit(0);
	}

	xhot = 0;
	yhot = 0;
	nplanes = 1;
	maskcolor = 0;
	datacolor = 1;
	maskfn = (char *) 0;
	datafn = (char *) 0;
	name = "mform";

	for (ap = av + 1; *ap && **ap == '-'; )
		for (cp = *ap++ + 1; *cp; ++cp)
			switch (*cp)
			{
			case 'x':
				xhot = atoi(*ap++);
				break;
			case 'y':
				yhot = atoi(*ap++);
				break;
			case 'p':
				nplanes = atoi(*ap++);
				break;
			case 'M':
				maskcolor = atoi(*ap++);
				break;
			case 'D':
				datacolor = atoi(*ap++);
				break;
			case 'm':
				maskfn = *ap++;
				break;
			case 'd':
				datafn = *ap++;
				break;
			case 'n':
				name = *ap++;
				break;
			case 'G':
				++gemfmt;
				break;
			case 'R':
				++rename;
				break;
			}

	if (rename)
		chgname(datafn, name);

	if (gemfmt)
	{
		printf("/* GEM Icon Definition: */\n");
		printf("#define %s_W 0x0010\n", name);
		printf("#define %s_H 0x0028\n", name);
		printf("#define %sSIZE 0x0028\n", name);
		printf("short %s[%sSIZE] =\n{ ", name, name);
		hexw(5, xhot, yhot, nplanes, maskcolor, datacolor);
	}
	else
	{
		printf("#ifndef USER_DEF\n#include <gemdefs.h>\n#endif\n");
		printf("MFORM\t%s[1] = {\n\t%d,\t%d,\t%d,\t%d,\t%d,\n",
			name, xhot, yhot, nplanes, maskcolor, datacolor);
	}

	domask(maskfn, gemfmt);
	if (!gemfmt)
		fputs("\t },\n", stdout);
	domask(datafn, gemfmt);

	if (gemfmt)
		fputs("0x0000, 0x0000, 0x0000", stdout);
	else
		fputs("\t }", stdout);
	fputs("\n};\n\n", stdout);
	exit(0);
}

domask (fn, gemfmt)
char	*fn;
{
	char	line[80];
	int	h0, h1, h2, h3;
	FILE	*fd;

	if (fd = fopen(fn, "r"))
	{
		*line = '\0';
		while (fgets(line, sizeof(line), fd) && *line != '{');
		if (*line == '{')
		{
			do
				if (gemfmt)
				{
					sscanf(line + 1,
						" 0x%x, 0x%x, 0x%x, 0x%x",
						&h0, &h1, &h2, &h3);
					hexw(4, h0, h1, h2, h3);
				}
				else
					printf("\t %s", line);
			while (fgets(line, sizeof(line), fd) && *line != '}');
		}
		fclose(fd);
	}
}

hexw (count, h0)
{
	int	*ap;
	static	int	col;

	for (ap = &h0; --count >= 0; )
		printf("0x%04x,%s", *ap++, (++col % 4)? " ": "\n  ");
}

chgname (datafn, name)
char	*datafn, *name;
{
	FILE	*fd;
	char	line[80];
	register char	*cp;

	if (fd = fopen(datafn, "r"))
	{
		while (fgets(line, sizeof(line), fd) != NULL &&
			strncmp(line, "short", 5))
			fputs(line, stdout);
		printf("short %s", name);
		for (cp = line; *cp && *cp != '['; ++cp);
		fputs(cp, stdout);
		while (fgets(line, sizeof(line), fd) != NULL)
			fputs(line, stdout);
		fclose(fd);
	}

	exit(0);
}
