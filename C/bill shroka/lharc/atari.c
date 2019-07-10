#ifdef atarist
#include <stdio.h>
#include <osbind.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <ctype.h>
#include <stddef.h>
#include <support.h>

#define FALSE	0
#define TRUE	1
#define ISWILD(X)	((X == '*')||(X == '?'))

/* extern char ** environ; */
#ifdef __GNUC__
size_t __DEFAULT_BUFSIZ__ = 32768L;
long 	_stksize = -1L;
#endif

char	**targv = (char **)NULL;
int	targc = 0;
char	dirbuf[256];
int	wildcard = 0, desktop = 0;
char 	arcshpath[256];
int     fullpath = TRUE;

static struct _dta statbuf;
static char *cmd;
/* static char * __junkenvironment = "\0\0\0\0"; */

static void expnd_args(char *s);
static int handl_wild(char *s);
static char *mkpathname(char *spec, char *file);
static void add_targv(char *s);

main (argc, argv)
int argc;
char **argv;
{
  struct _dta *olddta;
  int i;
  char *temp;

  _malloczero(1);
  olddta = (struct _dta *)Fgetdta ();
  Fsetdta (&statbuf);

  if (argv[0][0] == '\0') 
    {
      add_targv("lharc");
      desktop++;
#if 0
      environ = __junkenvironment; /* desktop does'nt valid have env */
#endif
    }
  else
    add_targv(argv[0]);

  cmd = argv[1];

  for (i = 1; i < argc; i++) 
    {
/*
 *  This prevents expnd_args from expanding directories.  We want opendir in
 *  lharc.c to do this so that we get the proper dir entries in the archive
 */
      if (desktop) 
	{
	  fullpath = FALSE;
	  if (temp = strstr (argv[i], "*.*")) 
	    {
	      wildcard++;
	      strncpy (arcshpath, argv[i], (strlen (argv[i]) - strlen (temp)) - 1);
	    }
	}

      if (wildcard && desktop)
	{
	  if ((strpbrk (argv[1], "AaMmUuCc")) && (strlen (arcshpath) > 3))
	    expnd_args (arcshpath);
	  else
	    expnd_args (argv[i]);
	}
      else
	expnd_args (argv[i]);
    }

  Fsetdta (olddta);

  add_targv("");                /* ensure space in targv */
  targv[--targc] = NULL;	/* unfortunate unix semantics */

  getwd (dirbuf);
  lzmain (targc, targv);
}

/*
 * Expand command line args
 */
static void expnd_args(s)
register char *s;
{
  char next_arg[128];
  register char *p;
  register int contains_wild;

  while(*s != '\0')
    {
      p = next_arg;
      while(isspace(*s)) 
	s++; /* skip leading space */
      if(*s != '\0')
	{
	  contains_wild = FALSE;
	  while(!isspace(*s) && (*s != '\0'))
	    {
	      contains_wild |= ISWILD(*s);
	      *p++ = *s++;
	    }
	  *p = '\0';

	  if(contains_wild)
	    {
	      if(handl_wild(next_arg))
		return;
	    }
	  else
	    add_targv(next_arg);
	} /* If */
    } /* while */

}

/*
 * expand wild card arguments. Return TRUE on error.
 */
static int handl_wild(s)
char *s;
{
  char *path;

  if (strpbrk (cmd, "EeXx"))
    return FALSE;

  path = strchr (cmd, 'z');

  if(Fsfirst(s, (path ? FA_DIR : 0)) != 0)
    {
      /* No match */
      fprintf(stderr,"No Match for %s\n", s);
      return TRUE;
    }
  if ((strcmp (statbuf.dta_name, ".") != 0) && (strcmp (statbuf.dta_name, "..") != 0))
    add_targv(mkpathname (s, statbuf.dta_name));

  while(Fsnext() == 0)
    {
      if ((strcmp (statbuf.dta_name, ".") != 0) && (strcmp (statbuf.dta_name, "..") != 0))
	add_targv(mkpathname (s, statbuf.dta_name));
    }

  return FALSE;
}

/*
 * Given spec with a trailing wildcard and a base will name construct pathname
 *
 */
static char *mkpathname(spec, file)
register char *spec, *file;
{
  register char *p;

  if(((p = strrchr (spec, '\\')) == (char *)NULL))
    /* no path name */
    return file;

  while(*file != '\0')
    *++p = *file++;
  *++p = '\0';
	
  return spec;
}

#define CHUNK_SIZE 16

static void add_targv(char *s)
{
  static size_t allocsize = 0;
  static int avail = 0;
  char temp[FILENAME_MAX];

  if(avail == 0)
    { /* need more mem */
      allocsize += (CHUNK_SIZE * sizeof(char **));
      avail = CHUNK_SIZE;
      targv = (char **)((targv == (char **)NULL) ? malloc(allocsize)
			: realloc(targv, allocsize));
      if(!targv)
	error("out of memory");
    }
  dos2unx (s, temp);
  targv[targc++] = strdup (temp);
  avail--;
}
#endif /* atarist */
