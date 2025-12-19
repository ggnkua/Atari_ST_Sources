#include <stdio.h>
#include "mygetopt.h"

char *Optarg = 0;
int Optind = 0;
static char *Nextchar = 0;

int my_getopt (argc, argv, optstring)
int argc;
char ** argv;
char * optstring;
{
  char ch;
  if (! (Nextchar && *Nextchar)) {
    Optind ++;
    if (Optind >= argc) {
      Nextchar = 0;
      return EOF;
    }
    Nextchar = argv [Optind];
    if (*Nextchar != '-') {
      Nextchar = 0;
      return EOF;
    }
    Nextchar ++;
    if (*Nextchar == '-') {
      /* End of Options */
      Optind ++;
      Nextchar = 0;
      return EOF;
    }
    if (! *Nextchar) {
      Nextchar = 0;
      return EOF;
    }
  }
  ch = *Nextchar ++;
  while (*optstring) {
    if (ch == *optstring) break;
    optstring ++;
    if (*optstring == ':') optstring ++;
  }
  if (ch != *optstring) {
    fprintf (stderr, "my_getopt: Unknown option %c\n", ch);
    return '?';
  }
  if (optstring [1] == ':') {
    if (! (Nextchar && *Nextchar)) {
      Optind ++;
      if (Optind >= argc) {
	fprintf (stderr, "my_getopt: Option without argument: %c\n", ch);
      }
      Nextchar = argv [Optind];
    }
    Optarg = Nextchar;
    Nextchar = 0;
  }
  return ch;
}
