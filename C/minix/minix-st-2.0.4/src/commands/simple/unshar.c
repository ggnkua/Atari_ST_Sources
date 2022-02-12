/* unshar - extract files from a shell archive	Author: Warren Toomey */

/* Copyright 1989 by Warren Toomey	wkt@cs.adfa.oz.au[@uunet.uu.net]
 *
 * You may freely copy or distribute this code as long as this notice
 * remains intact.
 *
 * You may modify this code, as long as this notice remains intact, and
 * you add another notice indicating that the code has been modified.
 *
 * You may NOT sell this code or in any way profit from this code without
 * prior agreement from the author.
 *
 * Modified by Andy Tanenbaum, Nov. 1992
 * Modified by Bruce Evans, Jan. 1993
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Methods of unsharing */
#define UNKNOWN	0
#define BRUTAL	1

/* Whitespace indicators */
#define WHITE	0
#define NOWHITE 1

/* Leading character indicators */
#define NOX	0
#define YESX	1

/* Misc. constants */
#define BUFSIZE	512		/* Size of line buffer */

/* Emulation types available */
#define NUMTOKS    4		/* NUMTOKS must equal # of emulation types */
#define SED	   1
#define GRES 	   2
#define CAT	   3

/* The list of emulation types. */
static char *token[NUMTOKS] = {"", "sed", "gres", "cat"};

/* Global variables */
int table;			/* Generate a table, or extract */
int numext;			/* Number of files to extract */
unsigned long nulchars;		/* # Nuls discarded from input */
unsigned long overrunchars;	/* # Chars overruning line buffers */
char *exfile[100];		/* Files to extract */

extern char *optarg;

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(int fgetline, (FILE * zin, int how, char *buf, size_t max));
_PROTOTYPE(char *getstring, (char *buf));
_PROTOTYPE(int firstword, (char *buf));
_PROTOTYPE(int mustget, (char *s1));
_PROTOTYPE(void extract, (int how, char *file, char *end, char *lead));
_PROTOTYPE(void getnames, (char *buf, char *file, char *word));
_PROTOTYPE(void disembowel, (void));
_PROTOTYPE(void usage, (void));

int main(argc, argv)
int argc;
char *argv[];
{
  int i, c, first;
  int method;			/* Method of unsharing */

  method = BRUTAL;		/* Only BRUTAL currently available */
  table = 0;			/* Don't generate a table */
  numext = 0;			/* Initially no files to extract */

  while ((c = getopt(argc, argv, "x:tbv")) != EOF) switch (c) {
	    case 't':
		table = 1;	/* Get the various options */
		break;

	    case 'b':	method = BRUTAL;	break;
	    case 'x':
		exfile[numext] = (char *) malloc(strlen(optarg) + 1);
		strcpy(exfile[numext++], optarg);
		break;

	    default:	usage();
	}

  if (argc == 1) {
	first = argc;		/* Find first file argument */
  } else {
	for (first = 1; first < argc; first++)
		if (argv[first][0] != '-') break;
  }

  if (first == argc) {		/* If no file argument use stdin only */
	switch (method) {
	    case BRUTAL:
		disembowel();	/* Unshar brutally! */
		break;

	    default:
		fprintf(stderr, "unshar: Unknown method of unsharing\n");
		exit(1);
	}
  } else {
	for (i = first; i < argc; i++) {	/* open stdio with every
						 * file */
		if (table) printf("%s:\n", argv[i]);
		if (freopen(argv[i], "r", stdin) != stdin) {
			perror("unshar");
			exit(1);
		}
		switch (method) {
		    case BRUTAL:
			disembowel();	/* Unshar brutally! */
			break;

		    default:
			fprintf(stderr,"unshar: Unknown method of unsharing\n");
			exit(1);
		}
	}
  }
  return(0);
}

int fgetline(zin, how, buf, max)
FILE *zin;
int how;			/* Ignore leading whitespace if how=NOWHITE */
char *buf;
size_t max;			/* Buffer size, must be >= 2 */
{
/* Get a line from a file */
  int ch = 0;
  char *limit = buf + max - 1;

  *buf = 0;			/* Null the buffer */
  if (how == NOWHITE) {		/* If skip any whitespace */
	while (((ch = getc(zin)) == ' ') || (ch == '\t'));
	if (ch == EOF) return(EOF);	/* Returning EOF or 0 */
	if (ch == '\n') return (0);
	*buf++ = ch;		/* Put char in buffer */
  }
  while ((ch = getc(zin)) != '\n') {	/* Now get the line */
	if (ch == EOF) {
		*buf = 0;
		return(EOF);
	}
	if (ch == 0) {
		nulchars++;
		continue;
	}
	if (buf == limit)
		overrunchars++;
	else
		*buf++ = ch;
  }

  *buf = 0;			/* Finally null-terminate the buffer */
  return(0);			/* and return */
}

char *getstring(buf)
char *buf;
{
/* Get the next string from the buffer ignoring any quotes. */
  char out[BUFSIZE];
  char *temp = out;
  char inquotes = 0, ok = 1;
  while ((*buf == ' ') || (*buf == '\t'))
	buf++;			/* Skip whitespace */

  *temp = 0;
  while (ok) {			/* Parse line */
	switch (*buf) {
	    case '\"':
	    case '\'':
		buf++;
		inquotes = !inquotes;	/* Toggle inquotes */
		break;

	    case 0:
	    case '\n':		/* Stop on <, >, NULL */
	    case '>':		/* \n, and sometimes */
	    case '<':	ok = 0;	break;	/* space & tab */
	    case '\t':
	    case ' ':
		if (!inquotes) ok = 0;
	    case '\\':
		if (!inquotes) {/* Ignore backquotes */
			buf++;
			break;
		}

	    default:
		*temp++ = *buf++;	/* Copy chars :-) */
	}
  }
  *temp = 0;
  return(out);
}

int firstword(buf)
char *buf;
{
/* Return token value of the first word in the buffer.  Assume no leading
 * white space in the buffer.
 */
  int i;

  for (i = 1; i < NUMTOKS; i++)
	if (strncmp(buf, token[i], strlen(token[i])) == 0) return(i);

  return(UNKNOWN);
}

int mustget(s1)
char *s1;
{
/* Return 1 if s1 is in he list of files to extract.  Else return 0. */
  int i;

  if (numext == 0) return(0);
  for (i = 0; i < numext; i++)
	if (!strcmp(s1, exfile[i])) return(1);
  return(0);
}

void extract(how, file, end, lead)
int how;		/* If how==YESX, ignore 1st char on each line */
char *file;
char *end;
char *lead;
{
/* Extract file, up until end word */
  FILE *zout;
  char line[BUFSIZE];
  char *temp;
  int ch, match;
  size_t n;

  n = strlen(lead);
  zout = fopen(file, "w");	/* Open output file */
  if (zout == NULL) {
	perror("unshar");
	return;
  }
  while (1) {
	ch = fgetline(stdin, WHITE, line, sizeof line);
	temp = line;
	if (ch == EOF) {
		fprintf(zout, "%s\n", line);
		fclose(zout);
		return;
	}
	if (strcmp(temp, end) == 0) {	/* If end word */
		fclose(zout);	/* close the file */
		return;
	}
	match = strncmp(temp, lead, n);
	if ((how == YESX) && (match == 0))
		temp += n;	/* Skip any lead */
	fprintf(zout, "%s\n", temp);
  }
}

void getnames(buf, file, word)	/* Get the file & end word */
char *buf, *file, *word;	/* from the buffer */
{
  char *temp;

  temp = buf;

  while (*temp != 0) {		/* Scan along buffer */
	switch (*temp) {	/* Get file or end word */
	    case '>':
		strcpy(file, getstring(++temp));	/* Get the file name */
		break;
	    case '<':
		if (*(++temp) == '<') ++temp;	/* Skip 2nd < */
		strcpy(word, getstring(temp));	/* Get next word */
		break;
	    default:	temp++;
	}
  }
}

void disembowel()
{				/* Unshar brutally! */
  char buf[BUFSIZE];		/* Line buffer */
  char file[BUFSIZE];		/* File name */
  char word[BUFSIZE];		/* Word buffer */
  char lead_string[BUFSIZE];	/* lead string */
  char *p, *p1;
  int ch;

  overrunchars = nulchars = 0;
  while (1) {
	ch = fgetline(stdin, NOWHITE, buf, sizeof buf);
	if (ch == EOF) {
		if (nulchars + overrunchars != 0) fprintf(stderr,
				"unshar: Discarded %lu characters from input.  Output may be garbled\n",
				nulchars + overrunchars);
		return;
	}
	switch (firstword(buf)) {	/* Extract, depending on first word */
	    case CAT:
		getnames(buf, file, word);

		/* Find the leading string. */
		p = buf;
		while (*p != '/') p++;
		p++;
		if (*p == '^') p++;	/* ^ has no width */
		p1 = p;
		while (*p1 != '/') p1++;
		strncpy(lead_string, p, (size_t) (p1 - p));

		if (table == 0) {
			if ((numext == 0) || (mustget(file))) {
				printf("unshar: Extracting  %s\n", file);
				extract(NOX, file, word, lead_string);
			}
		} else {
			printf("  %s\n", file);
		}
		break;

	    case GRES:
	    case SED:
		getnames(buf, file, word);

		/* Find the leading string. */
		p = buf;
		while (*p != '/') p++;
		p++;
		if (*p == '^') p++;	/* ^ has no width */
		p1 = p;
		while (*p1 != '/') p1++;
		strncpy(lead_string, p, (size_t) (p1 - p));

		if (table == 0) {
			if ((numext == 0) || (mustget(file))) {
				printf("unshar: Extracting  %s\n", file);
				extract(YESX, file, word, lead_string);
			}
		} else {
			printf("  %s\n", file);
		}
		break;
	    default:	break;
	}
  }
}

void usage()
{
  fprintf(stderr, "Usage: unshar [-t] [-b] [-v] [-xfile] [file(s)]\n");
  exit(0);
}
