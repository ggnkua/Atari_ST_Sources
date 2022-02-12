/*
 * setvt: set screen resolution on Atari-ST
 * VS 20050724
 */

/*#include <stdio.h>*/
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define print(fd, str)	write((fd), (str), strlen(str))
#define stdout	1
#define stderr	2

void usage(myname)
char *myname;
{
  print(stderr, "usage: ");
  print(stderr, myname);
  print(stderr, " [25|33|50]\n");
  exit(1);
}

void main(argc, argv)
int argc;
char *argv[];
{
  char *s;

  if (argc != 2) usage(argv[0]);

  if (strncmp(argv[1], "25", 2) == 0)      s = "\033[16~";
  else if (strncmp(argv[1], "33", 2) == 0) s = "\033[12~";
  else if (strncmp(argv[1], "50", 2) == 0) s = "\033[8~";
  else usage(argv[0]);

  print(stdout, s);
  exit(0);
}
