
/*
 * Copyright (c) 1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

static char Version[] = "ld version 2.0  Copyright (c) 1991 Sozobon Ltd";

#include <stdio.h>

int mflag, vflag, symout;
int only8;
char *tmpdir;
char *oname;

#ifdef MINIX
long mstack, atol();
#endif

#ifdef TOS
#define FSEP	'\\'
#else
#define FSEP	'/'
#endif

int tb, db, trelb, drelb, orelb;

main(argc, argv)
char **argv;
{
	int i;
	char *getenv();

	setbuf(stdout, NULL);
	if ((tmpdir = getenv("TMP")) == NULL)
#ifdef TOS
		tmpdir = "\\";
#else
		tmpdir = "/tmp/";
#endif

	for (i=1; i<argc; i++)
		switch (argv[i][0]) {
		case '-':
			if (doopt(&argv[i][1], argv[i+1], 0))
				i++;
			break;
#ifdef TOS
		case '+':
			if (doopt(&argv[i][1], argv[i+1], 1))
				i++;
			break;
#endif
#ifdef MINIX
		case '=':
			mstack = atol(&argv[i][1]);
			break;
#endif
		default:
			opentmps();
			pass1(argv[i]);
			break;
		}

	pass2();
	t_exit();
	exit(0);
}

opentmps()
{
	static int didit = 0;
	int pid;
	char pname[20];

	if (didit)
		return;
	didit = 1;
	pid = getpid();
	sprintf(pname, "a%d", pid);
	tb = opent(pname);
	pname[0] = 'b';
	db = opent(pname);
	pname[0] = 'c';
	trelb = opent(pname);
	pname[0] = 'd';
	drelb = opent(pname);
	pname[0] = 'e';
	orelb = opent(pname);
}

opent(s)
char *s;
{
	int dlen, flen;
	char *bp, *mmalloc();
	int needsep;

	dlen = strlen(tmpdir);
	if (tmpdir[dlen-1] != FSEP) {
		needsep = 1;
	} else
		needsep = 0;
	flen = strlen(s);
	bp = mmalloc(dlen+flen+needsep+1);
	strcpy(bp, tmpdir);
	bp += dlen;
	if (needsep)
		*bp++ = FSEP;
	strcpy(bp, s);
	return t_open(bp);
}

doopt(s, next, lflag)
char *s, *next;
{
	int i;

#ifdef TOS
	if (lflag)
		lower(s);
#endif
	while (*s) {
		switch (*s) {
		case 'm':
			mflag++;
			break;
		case 'v':
			vflag++;
			break;
		case 't':
			symout++;
			break;
		case 'p':
		case 'b':
			/* archaic */
			break;
		case 'V':
			fprintf(stderr, "%s\n", Version);
			break;
		case 'f':
			fpass(next);
			return 1;
		case 'u':
			sundeff(next);
			return 1;
		case 'o':
			oname = next;
			return 1;
		case '8':
			only8 = 1;
			break;
		}
		s++;
	}
	return 0;
}

fpass(s)
char *s;
{
	FILE *fd;
	char buf[81];

	opentmps();
	fd = fopen(s, "r");
	if (fd == NULL) {
		fprintf(stderr, "Cant open %s\n", s);
		exit(1);
	}
	while (fscanf(fd, "%80s", buf) == 1) {
		pass1(buf);
	}
	fclose(fd);
}

fatal(s)
char *s;
{
	fprintf(stderr, "error: %s\n", s);
	t_exit();
	exit(1);
}

fatals(s, t)
char *s, *t;
{
	fprintf(stderr, "error: %s %s\n", s, t);
	t_exit();
	exit(1);
}

warns(s, t)
char *s, *t;
{
	fprintf(stderr, "warning: %s %s\n", s, t);
}

#ifdef TOS
lower(s)
char *s;
{
	char c;

	while (*s) {
		c = *s;
		if (c >= 'A' && c <= 'Z') {
			c -= 'A';
			c += 'a';
		}
		*s = c;
		s++;
	}
}
#endif

