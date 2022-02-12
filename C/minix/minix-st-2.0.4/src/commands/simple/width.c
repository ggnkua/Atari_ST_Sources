/* width - force a file to a fixed width	Author: Andy Tanenbaum */

/* This program reads an input file (by default, stdin), and forces each
 * line to a certain length (by default 80 columns).  Lines that are
 * shorter than this are padded with spaces.  Lines that are longer are
 * truncated.  Tabs are expanded to spaces in the output.
 *
 * Examples:	width x y 	# copy x to y and make all lines 80 cols
 *		width x		# copy x to stdout and force all lines to 80
 *		width -40 x	# copy x to stdout and force to 40 cols
 *		width -30 x y	# copy x to y and force to 30 cols
 *		width -20	# copy stdin to stdout and force to 20 cols
 */

#include <stdlib.h>
#include <stdio.h>

#define MAX_WIDTH	1024	/* longest acceptable line */
#define TAB_WIDTH          8	/* spacing between tab stops */

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void process, (FILE *in, FILE *out, int width));
_PROTOTYPE(void cant_open, (char *program, char *file));
_PROTOTYPE(void usage, (char *s));

int main(argc, argv)
int argc;
char *argv[];
{

  int width, k;
  char *p;
  FILE *in, *out;

  /* Process command line. */
  p = argv[1];
  k = 1;
  width = 80;
  if (argc > 1 && *p == '-') {
	width = atoi(p + 1);
	if (width < 1 || width > MAX_WIDTH) usage(argv[0]);
	k = 2;
  }
  if (argc == k) {
	/* No file arguments. */
	process(stdin, stdout, width);
  } else if (argc == k + 1) {
	/* For example: width file   or   width -30 file */
	if ((in = fopen(argv[k], "r")) == NULL)
		cant_open(argv[0], argv[k]);
	process(in, stdout, width);
  } else if (argc == k + 2) {
	/* For example, width inf outf  or   width -30 inf outf */
	if ((in = fopen(argv[k], "r")) == NULL)
		cant_open(argv[0], argv[k]);
	if ((out = fopen(argv[k + 1], "w")) == NULL)
		cant_open(argv[0], argv[k]);
	process(in, out, width);
  } else {
	usage(argv[0]);
  }
  return(0);
}


void process(in, out, width)
FILE *in, *out;
int width;
{
/* Copy in to out and force all the lines to width. */

  int col, spaces;
  register char *p, *q;
  char in_buf[MAX_WIDTH + 1], out_buf[MAX_WIDTH + 1];

  while (fgets(in_buf, MAX_WIDTH, in) != NULL) {
	/* This loop executed once for each line in the input file. */
	p = in_buf;
	q = out_buf;
	col = 0;
	while (*p != 0) {
		/* This loop executed once for each character in the line. */
		if (*p != '\t') {
			/* Not a tab. */
			*q++ = *p++;
			col++;
		} else {
			/* Tab. */
			spaces = TAB_WIDTH - (col % TAB_WIDTH);
			col += spaces;
			while (spaces--) *q++ = ' ';
			p++;
		}
	}
	if (*(q - 1) == '\n') *(q - 1) = ' ';
	while (q < &out_buf[width]) *q++ = ' ';
	out_buf[width] = '\n';
	out_buf[width + 1] = 0;
	fputs(out_buf, out);
  }
}


void cant_open(program, file)
char *program;
char *file;
{
  fputs(program, stderr);
  fputs(": cannot open ", stderr);
  fputs(file, stderr);
  putc('\n', stderr);
  exit(1);
}


void usage(s)
char *s;
{
  fputs("Usage: ", stderr);
  fputs(s, stderr);
  fputs(" [-<width>] [infile [outfile] ]\n", stderr);
  exit(1);
}
