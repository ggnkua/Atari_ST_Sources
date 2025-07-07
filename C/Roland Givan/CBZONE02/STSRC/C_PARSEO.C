#include "c_includes.h"
/*
 * cbzone_parseopts.c
 *  -- Todd W Mummert, December 1990, CMU
 *
 * ATARI Mods - Roland Givan Summer/Autumn/Winter 1993
 *
 * RCS Info
 *  $Header: c_parseopts.c,v 1.1 91/01/12 02:03:36 mummert Locked $
 *
 * Parse the options, read the MOTD, etc...
 *
 * The prints in these routines will never go the game window, as it
 * does not exist.  cbzone cannot be backgrounded from the beginning
 * since the execl will block on tty output.  To allow this we create
 * yet another flag that specifies that motd is not to be read.
 */

#ifdef LATTICE
/* For the dfind() */
#include <dos.h>
#else
/* For stat() */
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef ATARI
extern int more(char *);
extern void version_dialog(char *);
#endif

#ifndef ATARI
int pager(file)
     char* file;
{
  char buf[100], *pager, *getenv();
  static char defaultpager[] = PAGER;
  FILE *f;

  if ((pager = getenv("PAGER")) == NULL)
    pager = defaultpager;
  sprintf(buf,"%s%s",TANKDIR,file);
  if ((f=fopen(buf,"r")) != NULL) {
    fclose(f);
    switch (fork()) {
    case 0:
      execl(pager,pager,buf,0);
      fprintf(stderr,"Exec of %s failed\n", pager);
      return 1;
    case -1:
      fprintf(stderr,"Unable to fork process\n");
      return 1;
    default:
      wait(0);
      break;
    }
  }
  else {
    fprintf(stderr,"File %s not found or unreadable.\n", buf);
    return 1;
  }
  return 0;
}
#else
int pager(file)
     char* file;
{
  char buf[100];

  sprintf(buf,"%s%s",TANKDIR,file);
  return(more(buf));
}
#endif

int getoptionint(s)
     char *s;
{
  char rest[100];
  int num;
  if (sscanf(s, "%d%s", &num, rest) != 1) {
    printf("Error in optional argument %s; use -help for help.\n",
           s);
#ifdef ATARI
    gem_close_down();
#else
    exit(0);
#endif
  }
  return(num);
}

/*
 * the following routine may be called in one of two ways...
 *  either w/ the display set or without...if without, then we
 *  will need to parse all the options...otherwise the resources should
 *  have taken care of most of them for us.
 *
 *  now even if the display is set, we may get options that were
 *  ambiguous.
 *
 *  since options are more than one letter, we can't use getopt.
 */
#ifndef ATARI
#define MAXOPTIONS 16	/* No idea why this is not 18! RMG */
#else
#define MAXOPTIONS 19
#endif
#define OPTIONINT 7
void parseopt(argc, argv, status)
     int argc;
     char* argv[];
     Bool status;
{
  int i;
  Bool early_exit = False;

#ifdef LATTICE
/* These are for the dfind */
  struct FILEINFO info;
  int attr=0;
#else
/* This is for STAT */
  struct stat statbuf;
#endif
  static char* optionnames[] = {
    "-xrm", "-delay", "-blocks", "-landers", "-tanks", "-missiles",
    "-salvos", "-coptersonly", "-quiet", "-scores", "-original",
    "-version", "-help", "-nooutput", "-mono", "-cursor",
    "-defaultcolormap", "-nofullscreen"
#ifdef ATARI
	,"-fast"
#endif
	};
#ifdef ATARI
  opt->loud = True;
  opt->fast = False;
  opt->output = True;

#ifndef LATTICE
#if 0	/* Can't get any variation on this to work :-( */
  if (strcmp(argv[0],"CBZONEF.PRG")==0){
	opt->fast = True;
  }
#endif
/* So we'll use this instead (probably should use it for the Lattice
version as well ! */
  if (stat("CBZONEF.PRG",&statbuf)==0){
	opt->fast = True;
  }
#else
  if (dfind(&info,"CBZONEF.PRG",attr)==0){
    opt->fast = True;
  }
#endif
#endif
  for (argc--, argv++; argc>0; argc--, argv++) {
    for (i=0; i<MAXOPTIONS; i++)
      if (!strncmp(*argv,optionnames[i],strlen(*argv)))
        break;
    if (i < OPTIONINT) {
      argc--; argv++;
    }
    switch(i) {
    case 0:                     /* xrm */
      break;
    case 1:                     /* delay */
      opt->delay = getoptionint(*argv);
      break;
    case 2:                     /* blocks*/
      opt->mblocks = getoptionint(*argv);
      break;
    case 3:                     /* landers */
      opt->mlanders = getoptionint(*argv);
      break;
    case 4:                     /* tanks */
      opt->mtanks = getoptionint(*argv);
      break;
    case 5:                     /* missiles */
      opt->mmissiles = getoptionint(*argv);
      break;
    case 6:                     /* salvos */
      opt->msalvos = getoptionint(*argv);
      break;
    case 7:                     /* copter practice */
      opt->copters = True;
      break;
    case 8:                     /* quiet mode */
      opt->loud = False;
      break;
    case 9:                     /* scores only */
      opt->scores = True;
      break;
    case 10:                    /* original */
      opt->original = True;
      break;
    case 11:                    /* version */
      opt->version = True;
      break;
    case 12:                    /* help */
      opt->help = True;
      break;
    case 13:                    /* nooutput */
      opt->output = False;
      break;
    case 14:                    /* monocolor */
      opt->mono = True;
      break;
    case 15:                    /* cursor */
      opt->cursor = True;
      break;
    case 16:                    /* default colormap */
      opt->defaultcolormap = True;
      break;
    case 17:                    /* fullscreen */
      opt->fullscreen = False;
      break;
#ifdef ATARI
    case 18:
      opt->fast = True;		/* Turn off lots of junk */
      break;			/* This option might be */
#endif				/* useful for non ataris too */
    }
  }

#ifdef ATARI
opt->mono = True;	/* only dealing with mono screens */
opt->practice = True;
#endif

  if (opt->scores || opt->help || opt->version)
    early_exit = True;
  if (opt->output) {
#ifdef ATARI
    if (opt->help){
      pager("readme.st");
    }
    pager("cbzone.mot");
#else
    pager("cbzone.motd");
#endif

    if (opt->scores){
#ifdef ATARI
      set_front();
#endif
      scores(-1);
    }

    if (opt->version){ 
#ifdef ATARI
      version_dialog(VERSION);
#else
      printf("\nVersion \"%s\"\n", VERSION);
#endif
    }

#ifdef ATARI
    if (opt->help && pager("cbzone.hel"))
#else
    if (opt->help && pager("cbzone.help"))
#endif
      printf("Sorry help information not available.\n");
  } /* end if opt->output */

  if (early_exit){
#ifdef ATARI
    gem_close_down();
#else
    exit(0);
#endif
  }

  if (!status)
    return;

  if (opt->copters)
    opt->mtanks = 0;

  if (opt->original) {
    opt->mblocks = 8;
    opt->copters = False;
    opt->mlanders = 1;
    opt->mmissiles = 1;
    opt->mtanks = 1;
#ifndef ATARI		/* Don't see why this should always be
			   a practice game! */
    opt->practice = True;
#else
    opt->practice = False;
#endif
    opt->msalvos = 1;
  }

  opt->menemies = (opt->mtanks > opt->mmissiles ?
                   opt->mtanks : opt->mmissiles);
  if (!opt->menemies) {
#ifndef ATARI
    printf("Must have at least one missile or tank.\n");
    exit(1);
#else
    opt->original=True;
    /* Do an ordinary 'original' game */
    opt->mblocks = 8;
    opt->copters = False;
    opt->mlanders = 1;
    opt->mmissiles = 1;
    opt->mtanks = 1;
    opt->msalvos = 1;
    opt->menemies = (opt->mtanks > opt->mmissiles ?
                   opt->mtanks : opt->mmissiles);
    opt->practice = False;
#endif
  }

  if (opt->msalvos == -1)
    opt->msalvos = opt->menemies;
  opt->mobjects = opt->mblocks + opt->mlanders + 2*opt->menemies +
    opt->msalvos + 1;
  opt->estart = 1;
  opt->lstart = opt->estart + opt->menemies;
  opt->sstart = opt->lstart + opt->mlanders;
  opt->bstart = opt->sstart + opt->menemies + opt->msalvos;

  if (opt->mmissiles == MMISSILES &&
      opt->mtanks == MTANKS &&
      opt->mlanders == MLANDERS &&
      opt->mblocks == MBLOCKS &&
      opt->delay <= DELAY &&
      opt->msalvos == opt->menemies)
    opt->practice = False;
#ifndef ATARI
/* Don't see why this is here either.. */
  else
    opt->practice = True;
#endif
}
