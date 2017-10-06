/*
generic -- a pseudo-template code processor

		     WARNING   WARNING   WARNING
This code is basically a hack.  Only a bare minimum of error checking is
done.  Use caution.

Usage:
		     parm 1 ---\    /--- parm 2
			     vvvvv vvv
    generic fred.zg joebob:1 alice:257 harvey:17
		    ^^^^^^^^ ^^^^^^^^^ ^^^^^^^^^
			\--------|---------/
			  parameter groups

Output file name is input file name without the trailing 'g'.

If there is a line in the input file beginning with "@0", it is removed
and all lines above it appear only once in the output.  All other lines
appear once per parameter group.  A '@' followed by a digit from 1 to 9
is replaced by the corresponding parameter from the current parameter
group.  The text "@@" is replaced by a single '@'.  All other text
passes through unchanged.

Example:

Input file:
--------------------
This is a test.
@0
This is @1 a @2.
--------------------

Command:
generic fred.zg only:test not:drill

Output:
--------------------
This is a test.
This is only a test.
This is not a drill.
--------------------
*/

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define LINEBUF 1024

char *line = 0;
size_t size;
FILE *inf, *outf;
char *parms[9];
fpos_t seekpoint;


int getline()
{
  register char *s, *t;
  ptrdiff_t dp;

  if (!line)
    line = malloc(size = LINEBUF);
  s = line;
  if (!fgets(s, size, inf)) {
    return 0;
  }
  t = s + strlen(s);
  for (;;) {
    if (t[-1] != '\n') {
      if (size - (t - s) < LINEBUF) {
	dp = t - s;
	size += LINEBUF;
	s = (char *)realloc(s, size);
	t = s + dp;
      }
      if (!fgets(t, (int)(size - (t - s)), inf)) {
	*t = '\0';
	break;
      }
      t += strlen(t);
    } else
      break;
  }
  *t = '\0';
  line = s;
  return 1;
}

void set_parms(s) register char *s;
{
  register char *t;
  register int i;

  for (i = 0; i <9; i++)
    parms[i] = 0;
  for (i = 0; i < 9 && *s; i++) {
    t = strchr(s, ':');
    if (!t)
      t = s + strlen(s);
    *t = '\0';
    parms[i] = s;
    s = t + 1;
  }
}

void process_line()
{
  register char *s, *t;

  s = line;
  if (*s == '@' && s[1] == '0') {
    fgetpos(inf, &seekpoint);
    return;
  }
  for (;;) {
    t = strchr(s, '@');
    if (!t) {
      fputs(s, outf);
      return;
    }
    *t++ = '\0';
    fputs(s, outf);
    if (*t == '@') {
      fputc('@', outf);
      s = t + 1;
      continue;
    }
    if (!isdigit(*t) || *t == '0') {
      fputc('@', outf);
      s = t;
      continue;
    }
    if (parms[*t - '1'])
      fputs(parms[*t - '1'], outf);
    s = t + 1;
  }
}

main(argc, argv) int argc; char *argv[];
{
  char buf[512];
  register char *s = buf;
  register int i;

  if (argc < 3) {
    fprintf(stderr, "usage: %s infile parmlist [parmlist ...]\n", argv[0]);
    exit(1);
  }
  if (!(inf = fopen(argv[1], "r"))) {
    fprintf(stderr, "%s: cannot open input file %s\n", argv[0], argv[1]);
    exit(1);
  }
  fgetpos(inf, &seekpoint);
  strcpy(buf, argv[1]);
  s += strlen(s) - 1;
  if (*s == 'g') *s = '\0'; else {*++s = 'g'; *++s = '\0';}
  if (!(outf = fopen(buf, "w"))) {
    fprintf(stderr, "%s: cannot open output file %s\n", argv[0], buf);
    exit(1);
  }
  for (i = 2; i < argc; i++) {
    set_parms(argv[i]);
    while (getline())
      process_line();
    fsetpos(inf, &seekpoint);
  }
  fclose(inf);
  fclose(outf);
  return 0;
}
