/* strip68 - strip symbols from .PRG file */

/*
 *  
 *  strip68 [-e] file[.prg]
 *
 */
#ifdef BSD
#include <stdio.h>
#endif

#define	EOS	'\0'


int debug = 0;			/* debugging level */
int equate = 0;			/* 1, strip only equates */


/*
 *
 *
 */
main(argc, argv)
     int argc;
     char **argv;
{
  int argno;
  char *argstr;
  int fd;
  char fname[200];

  for (argno = 1; argno < argc; ++argno)
    if (*argv[argno] == '-')
      {
	for (argstr = argv[argno]+1; *argstr != EOS;)
	  switch (*argstr++)
	    {
	    case 'x':
	    case 'X':
	      if (*argstr >= '0' && *argstr <= '9')
		debug = *argstr++ - '0';
	      else debug = 1;
	      break;

	    case 'e':
	    case 'E':
	      equate = 1;
	      break;

	    default:
#ifdef ST
	      printf("Unknown option: `%c'\n", *--argstr);
#endif
#ifdef BSD
	      fprintf(stderr, "Unknown option: `%c'\n", *--argstr);
#endif
	      exit(1);
	    }
      } else {
	strcpy(fname, argv[argno]);
	fext(fname, ".prg", 0);
	if ((fd = open(fname, 0)) < 0)
	  {
#ifdef ST
	    printf("cannot open: '%s'\n", fname);
#endif
#ifdef BSD
	    fprintf(stderr, "cannot open: '%s'\n", fname);
#endif
	    exit(1);
	  }
	process(fd);
	close(fd);
      }
}


process(fd)
     int fd;
{
  int magic;
  long x, tsize, dsize, ssize;
  long getlong();
  int getword();

  magic = getword(fd);
  if (magic != 0x601a)
    error("bad header");

  tsize = getlong(fd);
  dsize = getlong(fd);
  x = getlong(fd);
  ssize = getlong(fd);

}
