/**********************************************************************/
/* MTFI 1.21: iface.c

 This file is the MTFI interface file.  If you're writing your own
 interpreter using the MTFI core, you need to modify or replace this
 file.  Using this filename is only mandatory if you don't want to
 edit the makefile.  Note that this file contains main().

     This code is Copyright 1998 Ben Olmstead.  Distribute according
 to the GNU Copyleft (see the file COPYING in the archive from which
 this file was pulled).  Considering the coding standards that the FSF
 demands for anything written for them, this probably is making them
 have fits, but then, FSF code looks like trash, even if it is easy to
 understand.
*/

/**********************************************************************/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "getopt.h"

#ifdef CURSESDEBUGGER
#include "curses.h"
#endif

#include "mtfi.h"
#include "idefs.h"
#include "ifacei.h"
/**********************************************************************/
extern const struct insset isets[];
/**********************************************************************/
int fyear = 0;
int fdim = 0;

/* This is for command-line-specified Befunge-93: if the -3 switch is */
/* used, all directive lines *will* be treated as code.  However, if  */
/* '=l b93' is found in the source file instead, errors must be       */
/* generated for any directives other than '=l b93'.                  */
int b93 = 0;

/* Have we used any Befunge-97-style directives other than '=l b93'?  */
/* If so, then we should be in Funge-97--anything else should cause   */
/* an error to be generated.                                          */
int directives = 0;
/**********************************************************************/
const char help[] =
"MTFI: Magus Technica Funge Interpreter 1.21\n"
"    mtfi [switches] [program] [more switches]\n"
"\n"
"If no program name is specified, or '-' is specified, the program\n"
"will be read from standard input.\n"
"\n"
"Switches:\n"
"  -3, --befunge-93   : adhere to the Befunge-93 standard\n"
#ifdef BEFUNGE96
"  -6, --befunge-96   : adhere to the Befunge-96 standard\n"
#endif
"  -7, --funge-97     : adhere to the Funge-97 standard\n"
/*"  -8, --funge-98     : adhere to the Funge-98 standard\n"*/
"      --unefunge     : use 1 dimension (Funge-97 and -98 only)\n"
"      --befunge      : use 2 dimensions\n"
"      --trefunge     : use 3 dimensions (Funge-97 and -98 only)\n"
"      --quadrefunge  : use 4 dimensions (Funge-97 and -98 only)\n"
"      --quintefunge  : use 5 dimensions (Funge-97 and -98 only)\n"
"      --dimensions=n : use n dimensions (1<=n<=7)\n"
"  -=, --directive-97 : treat the Befunge-97 directive to follow on\n"
"                       the command line as if it came before the\n"
"                       first line of the source file\n"
#ifdef BEFUNGE96
"  -;, --directive-96 : treat the Befunge-96 directive to follow on\n"
"                       the command line as if it came before the\n"
"                       first line of the source file\n"
#endif
#ifdef CURSESDEBUGGER
"  -d, --debug        : run curses full-screen debugger\n"
#endif
"  -h, --help         : print this help message\n"
"  -p, --preprocess   : preprocess to stdout only, no execute\n"
/*"  -t, --trace        : enable tracing\n"*/
"  -v, --version      : print version information\n"
"\n"
"Report bugs to bem@mad.scientist.com";

const char version[] =
"MTFI: Magus Technica Funge Interpreter 1.21\n"
"Copyright 1998 Ben Olmstead\n"
"This program comes with NO WARRANTY, where not prohibited by law.\n"
"You may distribute MTFI under the terms of the GNU General Public\n"
"License.  For more information, see the file COPYING which should\n"
"have come with this program.\n";

const struct option lopts[] =
{
  { "befunge", no_argument, 0, 3 },
  { "befunge-93", no_argument, 0, '3' },
#ifdef BEFUNGE96
  { "befunge-96", no_argument, 0, '6' },
#endif
#ifdef CURSESDEBUGGER
  { "debug", no_argument, 0, 'd' },
#endif
  { "dimensions", required_argument, 0, 15 },
#ifdef BEFUNGE96
  { "directive-96", required_argument, 0, ';' },
#endif
  { "directive-97", required_argument, 0, '=' },
  { "funge-97", no_argument, 0, '7' },
  { "help", no_argument, 0, 'h' },
  { "preprocess", no_argument, 0, 'p' },
  { "quadrefunge", no_argument, 0, 5 },
  { "quintefunge", no_argument, 0, 6 },
  { "trefunge", no_argument, 0, 4 },
  { "unefunge", no_argument, 0, 2 },
  { "version", no_argument, 0, 'v' },
  { NULL, 0, NULL, 0 }
};

/**********************************************************************/
int main( int argc, char **argv )
{
  FILE *i, *f;
  int x;
  int n = -1;
  unsigned char spew = 0;
  unsigned char debug = 0;
  unsigned char color;
  const char *file;
  fdat j[MAXDIM] = { 0 };
  fdat k[MAXDIM] = { 1, 0 };
  struct fmach *funge;
  char dchr = '=';
  const char *op =
    "-=:3"
#ifdef BEFUNGE96
    ";:6"
#endif
#ifdef CURSESDEBUGGER
    "d"
#endif
    "7hpv";
  i = tmpfile();
  if ( i == NULL )
  {
    fprintf( stderr, "unable to open temporary file\n", file );
  }
  opterr = 0; /* We want to do our own error messages, not getopt's */
  while ( ( x = getopt_long( argc, argv, op, lopts, NULL ) )
    != -1 )
  {
    switch ( x )
    {
#ifdef CURSESDEBUGGER
      case 'd': debug = 1; break;
#endif
      case 'p': spew = 1; break;
      case '=':
        if ( b93 )
        {
          fprintf( stderr, "-= not supported with Befunge-93\n" );
          return ( 1 );
        }
        directives = 1;
        fprintf( i, "%c%s\n", dchr, optarg );
        if ( optarg[0] == '=' )
        {
          x = 0;
          while ( !isspace( optarg[++x] ) );
          if ( optarg[x] == '\n' || optarg[x] == '\0' )
          {
            fprintf( stderr, "incomplete directive on command line\n" );
            return ( 1 );
          }
          while ( optarg[++x] == ' ' );
          dchr = optarg[x];
          if ( optarg[x] == '\n' || optarg[x] == '\0' )
          {
            fprintf( stderr, "incomplete directive on command line\n" );
            return ( 1 );
          }
        }
        break;
#ifdef BEFUNGE96
      case ';':
        if ( fyear != 0 && fyear != 96 )
        {
          fprintf( stderr, "-; only supported with Befunge-96\n" );
          return ( 1 );
        }
        fyear = 96;
        fprintf( i, ";$%s\n", optarg );
        break;
#endif
      case 15:
        x = atol( optarg );
        if ( x < 1 || x > MAXDIM )
        {
          fprintf( stderr, "invalid argument to --dimensions\n" );
          return ( 1 );
        }
        if ( x != 2 && fyear < 97 && fyear != 0 )
        {
          fprintf( stderr, "unusual dimensionality not availabe in earl"
            "y funges\n" );
          return ( 1 );
        }
        if ( fdim != 0 && fdim != x )
        {
          fprintf( stderr, "conflicting dimension options on command li"
            "ne\n" );
          return ( 1 );
        }
        fdim = x;
        break;
      case '3':
        if ( directives )
        {
          fprintf( stderr, "-= not supported with Befunge-93\n" );
          return ( 1 );
        }
        b93 = 1;
        if ( fyear != 93 && fyear != 0 )
        {
          fprintf( stderr, "conflicting language options on command lin"
            "e\n" );
          return ( 1 );
        }
        fyear = 93;
        fdim = 2;
        break;
#ifdef BEFUNGE96
      case '6':
        if ( fyear != 96 && fyear != 0 )
        {
          fprintf( stderr, "conflicting language options on command lin"
            "e\n" );
          return ( 1 );
        }
        fyear = 96;
        break;
#endif
      case '7':
        if ( fyear != 97 && fyear != 0 )
        {
          fprintf( stderr, "conflicting language options on command lin"
            "e\n" );
          return ( 1 );
        }
        fyear = 97;
        break;
      case 2: /* --unefunge, --trefunge, --quadrefunge, --quintefunge */
      case 4:
      case 5:
      case 6:
        if ( fyear != 0 && fyear < 97 )
        {
          fprintf( stderr, "unusual dimensionality not availabe in earl"
            "y funges\n" );
          return ( 1 );
        }
        if ( fdim != 0 && fdim != x - 1 )
        {
          fprintf( stderr, "conflicting dimension options on command li"
            "ne\n" );
          return ( 1 );
        }
        fdim = x - 1;
        break;
      case 3:
        if ( fdim != 0 && fdim != 2 )
        {
          fprintf( stderr, "conflicting dimension options on command li"
            "ne\n" );
          return ( 1 );
        }
        fdim = 2;
        break;
      case 'h': printf( help ); return ( 0 );
      case 'v': printf( version ); return ( 0 );
      case '?': printf( help ); return ( 1 );
      case 1:
        if ( n == -1 ) { n = optind - 1; break; }
        fprintf( stderr, "%s: can't interpret multiple files\n", optarg
          );
        return ( 1 );
    }
  }
  if ( optind != argc ) /* Meaning some luser used '--' */
  {
    if ( n == -1 )
    {
      n = optind;
      optind++;
    }
    else
    {
      fprintf( stderr, "%s: can't interpret multiple files\n", argv[
        optind] );
      return ( 1 );
    }
  }
  if ( optind != argc )
  {
    fprintf( stderr, "%s: can't interpret multiple files\n", argv[optind
      ] );
    return ( 1 );
  }
  if ( n == -1 ) file = "-"; else file = argv[n];
  if ( !strcmp( file, "-" ) )
  {
    f = stdin;
    file = "stdin";
  }
  else
  {
    f = fopen( file, "r" );
    if ( f == NULL )
    {
      fprintf( stderr, "%s: unable to open file\n", file );
      return ( 1 );
    }
  }
  while ( ( x = getc( f ) ) != EOF ) putc( x, i );
  if ( f != stdin ) fclose( f );
  fseek( i, 0, SEEK_SET );
  srand( time( NULL ) );
  funge = newfmach();
  if ( funge == NULL )
  {
    fprintf( stderr, "%s:1: unable to allocate any memory\n", file );
    return ( 1 );
  }
#ifdef CURSESDEBUGGER
  if ( debug )
  {
    initscr();       /* I'd like to have some way of using *my* error */
    leaveok( stdscr, TRUE );  /* messages, but PDCurses won't let me. */
    scrollok( stdscr, FALSE );
    nonl();
    color = has_colors();
    if ( color ) start_color();
  }
#endif
  if ( !load( i, file, j, funge, 1 ) )
  {
    fclose( i );
    destroyfmach( funge );
    return ( 1 );
  }
  if ( spew )
  {
    for ( x = 0; x < MAXDIM; x++ ) k[x] = 0;
    for ( k[1] = 0; k[1] <= funge->size[1]; k[1]++ )
    {
      for ( k[0] = 0; k[0] <= funge->size[0]; k[0]++ )
      {
        printf( "%c", get( k, funge ) );
      }
      printf( "\n" );
    }
    return ( 0 );
  }
#ifdef CURSESDEBUGGER
  if ( debug )
  {
    for ( i = 0; i < COLS; i++ )
    {
      for ( j = 0; j < LINES - 3; j++ )
      {

      }
    }
  }
  else
#endif
  {
    mtfi( funge );
  }
  x = funge->rval;
  destroyfmach( funge );
  return ( x );
}

/**********************************************************************/
int load( FILE *f, const char *fn, fdat *l, struct fmach *funge, int ip )
{
#define spiterr(x) {fprintf(stderr,"%s:%d: " x,fn,aline);return(0);}
  static int depth = 0;
  struct thread *s, *t;
  FILE *g;
  fdat scr[MAXDIM + 2];
  fdat loc[MAXDIM];
  int cic = 0;
  int lic = 1;
  int i, j, k;
  unsigned char sol = 1;
  unsigned long line = 0;
  unsigned long aline = 1;
  unsigned long col = 0;
  unsigned long maxcol = 0;
  unsigned long maxline = 0;
  unsigned char ignore;
  unsigned char putflag = 0;
  static unsigned char disable[256] = { 0 };
#ifdef BEFUNGE96
  static unsigned char remap[256];
  static unsigned char con[32];
  static fdat constants[256];
#endif
  char z[PATH_MAX + 1];
  char lid[5];
  char *lids[5] = { "b93", "u97", "b97", "t97", "q97" };
  char dchr = '=';
  int x;
#ifdef BEFUNGE96
  if ( depth == 0 ) for ( i = 0; i < 256; i++ ) remap[i] = i;
  if ( depth == 0 ) for ( i = 0; i < 32; i++ ) con[i] = 0;
#endif
  depth++;
  for ( i = 0; i < MAXDIM; i++ ) loc[i] = l[i];
  if ( !b93 && fyear != 96 && fyear != 98 )    /* scan for Funge-97- */
  {                                              /* style directives */
    while ( ( x = getc( f ) ) != EOF )
    {
      if ( x == dchr && sol )
      {
        x = getc( f );
        ignore = 0;
        if ( x == '*' ) x = getc( f ), ignore = 1;
        if ( x == FUEOF ) spiterr( "incomplete directive\n" );
        switch ( x )
        {
          case '=':
            while ( !isspace( x = getc( f ) ) );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            while ( ( x = getc( f ) ) == ' ' );
            dchr = x;
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            x = getc( f );
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            break;

          case '#':
            if ( fyear == 93 )
            {
              spiterr( "only 'l b93' or '=' may be used in Befunge-93 s"
                "ource: try using -3\n" );
            }
            do { x = getc( f ); } while ( x != '\n' || x != EOF );
            directives = aline;
            break;

          case 'l':
            while ( !isspace( x = getc( f ) ) );
            if ( x != '\t' && x != ' ' )
              spiterr( "incomplete directive\n" );
            do { x = getc( f ); } while ( x == ' ' || x == '\t' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            for ( i = 0; i < 4 && !isspace( x ); i++ )
            {
              if ( !isspace( x ) ) lid[i] = x;
              x = getc( f );
            }
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            lid[i] = 0;
            for ( i = 0; i < 5 && strcmp( lid, lids[i] ); i++ );
            switch ( i )
            {
              case 0:
                if ( directives || ( fdim != 2 && fdim != 0 ) )
                  spiterr( "only 'l b93' or '=' may be used in Befunge-"
                    "93 source: try using -3\n" );
                fdim = 2; fyear = 93; break;
              case 1:
                if ( ( fdim == 0 || fdim == 1 ) && ( fyear == 0 || fyear
                  >= 97 ) )
                {
                  fdim = 1; fyear = 97; directives = aline; break;
                }
                else
                  spiterr( "more than one language type specified\n" );
              case 2:
                if ( ( fdim == 0 || fdim == 2 ) && ( fyear == 0 || fyear
                  >= 97 ) )
                {
                  fdim = 2; fyear = 97; directives = aline; break;
                }
                else
                  spiterr( "more than one language type specified\n" );
              case 3:
                if ( ( fdim == 0 || fdim == 3 ) && ( fyear == 0 || fyear
                  >= 97 ) )
                {
                  fdim = 3; fyear = 97; directives = aline; break;
                }
                else
                  spiterr( "more than one language type specified\n" );
              case 4:
                if ( ( fdim == 0 || fdim == 4 ) && ( fyear == 0 || fyear
                  >= 97 ) )
                {
                  fdim = 4; fyear = 97; directives = aline; break;
                }
                else
                  spiterr( "more than one language type specified\n" );
              case 5: spiterr( "unknown language type\n" );
            }
#if MAXDIM < 4
              if ( fdim > MAXDIM )
                spiterr( "unsupported number of dimensions\n" );
#endif
            break;

          case 'o': /* ignore these on this pass */
          case 'i':
            if ( fyear == 93 )
            {
              spiterr( "only 'l b93' or '=' may be used in Befunge-93 s"
                "ource: try using -3\n" );
            }
            directives = aline;
            do { x = getc( f ); } while ( x != '\n' && x != EOF );
            break;

          case 'd':
            if ( fyear == 93 )
            {
              spiterr( "only 'l b93' or '=' may be used in Befunge-93 s"
                "ource: try using -3\n" );
            }
            while ( !isspace( x = getc( f ) ) );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            do
            {
              if ( x > 126 || x < 32 )
                spiterr( "invalid command character\n" );
              disable[x] = 1;
            }
            while ( isgraph( x = getc( f ) ) );
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            directives = aline;
            break;

          case 'r':
            if ( fyear == 93 )
            {
              spiterr( "only 'l b93' or '=' may be used in Befunge-93 s"
                "ource: try using -3\n" );
            }
            while ( !isspace( x = getc( f ) ) );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            do
            {
              if ( x > 126 || x < 32 )
                spiterr( "invalid command character\n" );
              if ( strchr( " !\"#$%&'()*+,-./0123456789:;<>?@ADEFGHJPQR"
                "TUVXY[\\]^_`abcdefgijnopqrsvwyz{|}~", x ) == NULL )
                spiterr( "=required command not supported in current la"
                  "nguage\n" );
            }
            while ( isgraph( x = getc( f ) ) );
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            directives = aline;
            break;

          default:
            if ( fyear == 93 )
            {
              spiterr( "only 'l b93' or '=' may be used in Befunge-93 s"
                "ource: try using -3\n" );
            }
            if ( ignore )
            {
              directives = aline;
              do { x = getc( f ); } while ( x != '\n' && x != EOF );
              break;
            }
            spiterr( "unknown directive\n" );
        }
        aline++;
      }
      else
      {
        if ( x == '\n' )
        {
          sol = 1;
          col = 0;
          aline++;
          line++;
        }
        else
        {
          sol = 0;
          col++;
          if ( col > maxcol ) maxcol = col;
        }
      }
    }
    fseek( f, 0, SEEK_SET );
    dchr = '=';
    aline = 1;
    col = 0;
    maxline = line;
    line = 0;
    sol = 1;
  }
  if ( fdim == 0 ) fdim = 2;
  if ( fyear == 0 )
  {
    if ( directives == 0 && fdim == 2 && maxcol < 80 && maxline < 25 )
      fyear = 93;
    else
      fyear = 97;
  }
  if ( fyear > 93 )
  {
    funge->topo = LAHEY;
  }
  else
  {
    funge->topo = TORUS;
    funge->nsize[0] = funge->nsize[1] = 0;
    funge->size[0] = 79;
    funge->size[1] = 24;
  }
  funge->dim = fdim;
  while ( ( x = getc( f ) ) != EOF )
  {
    if ( !b93 && ( fyear == 93 || fyear == 97 ) && x == dchr && sol )
    {
      /* Most errors will have been caught by the previous loop */
      x = getc( f );
      if ( x == '*' ) x = getc( f );
      switch ( x )
      {
        case '=':
          while ( !isspace( x = getc( f ) ) );
          while ( ( x = getc( f ) ) == ' ' );
          dchr = x;
          break;
        case 'o':
          while ( !isspace( x = getc( f ) ) );
          if ( x == '\n' || x == EOF )
            spiterr( "incomplete directive\n" );
          while ( ( x = getc( f ) ) == ' ' );
          k = 0;
          while ( x != '\n' && x != EOF )
          {
            j = 1;
            if ( x == '+' || x == '-' )
            {
              if ( x == '-' ) j = -1;
              x = getc( f );
              if ( x == '\n' ) spiterr( "incomplete directive\n" );
            }
            if ( x > '9' || x < '0' )
              spiterr( "only numbers allowed as arguments to =o\n" );
            i = x - '0';
            while ( x = getc( f ), x >= '0' && x <= '9' )
            {
              i *= 10;
              i += x - '0';
            }
            if ( k == fdim + 2 )
            {
              spiterr( "too many arguments to =o\n" );
            }
            scr[k++] = i * j;
            if ( x == ' ' )
            {
              while ( ( x = getc( f ) ) == ' ' );
            }
            else if ( x != '\n' && x != EOF )
            {
              spiterr( "only numbers allowed as arguments to =o\n" );
            }
          }
          if ( k != fdim && k != fdim + 2 )
            spiterr( "incomplete directive\n" );
          if ( k == fdim + 2 )
          {
            cic = scr[0] - 1;
            lic = scr[1] - 1;
            if ( cic >= fdim || lic >= fdim || cic < 0 || lic < 0 )
            {
              spiterr( "attempt to set pad or pdd to unused dimension" )
                ;
            }
            for ( k = 0; k < fdim; k++ ) loc[k] = scr[k + 2];
          }
          else
          {
            for ( k = 0; k < fdim; k++ ) loc[k] = scr[k];
          }
          line = col = 0;
          break;
        case 'i':
          while ( !isspace( x = getc( f ) ) );
          if ( x == '\n' || x == EOF )
            spiterr( "incomplete directive\n" );
          while ( ( x = getc( f ) ) == ' ' );
          if ( x == '\n' || x == EOF )
            spiterr( "incomplete directive\n" );
          k = 0;
          do
          {
            z[k++] = x;
          }
          while ( !isspace( x = getc( f ) ) && k <= PATH_MAX );
          if ( k > PATH_MAX ) while ( !isspace( getc( f ) ) );
          z[k] = 0;
          if ( x != '\n' && x != EOF )
          {
            i = 0;
            if ( z[0] == '-' ) j = -1, k = 1;
            else if ( z[0] == '+' ) j = 1, k = 1;
            else j = 1, k = 0;
            if ( z[k] > '9' || z[k] < '0' )
              spiterr( "non-number in coordinate section of =i\n" );
            while ( z[k] != 0 )
            {
              if ( ( z[k] > '9' || z[k] < '0' ) )
                spiterr( "non-number in coordinate section of =i\n" );
              i *= 10;
              i += z[k++] - '0';
            }
            scr[0] = i * j;
            for ( k = 1; k < fdim; k++ )
            {
              i = 0;
              while ( ( x = getc( f ) ) == ' ' );
              if ( x == '-' )
                j = -1, x = getc( f );
              else if ( x == '+' )
                j = 1, x = getc( f );
              else if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" )
              else
                j = 1;
              if ( x > '9' || x < '0' )
                spiterr( "non-number in coordinate section of =i\n" );
              while ( !isspace( x ) )
              {
                if ( ( x > '9' || x < '0' ) )
                  spiterr( "non-number in coordinate section of =i\n" );
                i *= 10;
                i += x - '0';
                x = getc( f );
              }
              scr[k] = i * j;
              while ( isspace( x ) ) x = getc( f );
              if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" );
            }
            k = 0;
            do
            {
              z[k++] = x;
            }
            while ( !isspace( x = getc( f ) ) && k <= PATH_MAX );
            if ( k > PATH_MAX ) while ( !isspace( getc( f ) ) );
            z[k] = 0;
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
          }
          else
          {
            for ( k = 0; k < fdim; k++ ) scr[k] = loc[k];
            scr[cic] += col;
            scr[lic] += line;
          }
          g = fopen( z, "r" );
          if ( g == NULL ) spiterr( "unable to open =include file\n" );
          if ( !load( g, z, scr, funge, ( funge->t == NULL ) ? 1 : 0 ) )
            return ( 0 );
          break;
        default:
          do { x = getc( f ); } while ( x != '\n' && x != EOF ); break;
      }
      aline++;
    }
#ifdef BEFUNGE96
    else if ( fyear == 96 && x == ';' && sol )
    {
      x = getc( f );
      if ( x != ' ' && x != '$' )
      {
        spiterr( "; must be followed by ' ' or '$' in Befunge-96\n" );
      }
      if ( x == ' ' )
      {
        do { x = getc( f ); } while ( x != '\n' && x != EOF );
      }
      else
      {
        x = getc( f );
        switch ( x )
        {
          case 'I':
            if ( ( x = getc( f ) ) != ' ' )
            {
              if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" );
              spiterr( "multi-character directives not supported in Bef"
                "unge-96\n" );
            }
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            k = 0;
            do
            {
              z[k++] = x;
            }
            while ( !isspace( x = getc( f ) ) && k <= PATH_MAX );
            if ( k > PATH_MAX ) while ( !isspace( getc( f ) ) );
            z[k] = 0;
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '+' || x == '-' )
            {
              if ( x == '-' ) j = -1;
              x = getc( f );
              if ( x == '\n' ) spiterr( "incomplete directive\n" );
            }
            if ( x > '9' || x < '0' )
              spiterr( "second argument to ;$C must be a decimal number"
                "\n" );
            i = x - '0';
            while ( x = getc( f ), x >= '0' && x <= '9' )
            {
              i *= 10;
              i += x - '0';
            }
            if ( x != '\n' && x != EOF && x != ' ' )
              spiterr( "second argument to ;$I must be a decimal number"
                "\n" );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            scr[0] = i * j;
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '+' || x == '-' )
            {
              if ( x == '-' ) j = -1;
              x = getc( f );
              if ( x == '\n' ) spiterr( "incomplete directive\n" );
            }
            if ( x > '9' || x < '0' )
              spiterr( "second argument to ;$C must be a decimal number"
                "\n" );
            i = x - '0';
            while ( x = getc( f ), x >= '0' && x <= '9' )
            {
              i *= 10;
              i += x - '0';
            }
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            scr[1] = i * j;
            g = fopen( z, "r" );
            if ( g == NULL ) spiterr( "unable to open ;$I file\n" );
            if ( !load( g, z, scr, funge, 0 ) ) return ( 0 );
            break;
          case 'R':
            if ( ( x = getc( f ) ) != ' ' )
            {
              if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" );
              spiterr( "multi-character directives not supported in Bef"
                "unge-96\n" );
            }
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            if ( ( i = getc( f ) ) != ' ' )
            {
              if ( i == '\n' || i == EOF )
                spiterr( "incomplete directive\n" );
              spiterr( ";$R does not support multi-character remappings"
                "\n" );
            }
            while ( ( i = getc( f ) ) == ' ' );
            if ( i == '\n' || i == EOF )
              spiterr( "incomplete directive\n" );
            remap[(unsigned char)x] = i;
            x = getc( f );
            if ( x != '\n' && x != EOF )
              spiterr( "extra characters after end of directive\n" );
            break;
          case 'C':
            if ( ( x = getc( f ) ) != ' ' )
            {
              if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" );
              spiterr( "multi-character directives not supported in Bef"
                "unge-96\n" );
            }
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '\n' || x == EOF )
              spiterr( "incomplete directive\n" );
            if ( strchr( "=abcdefklmnoqrstuwxyzABCDEFHIJKLMNOQRSUVWXYZ",
              x ) == NULL ) spiterr( "not an extensible null\n" );
            k = x;
            j = 1;
            if ( ( x = getc( f ) ) != ' ' )
            {
              if ( x == '\n' || x == EOF )
                spiterr( "incomplete directive\n" );
              spiterr( "first argument to ;$C must be a single characte"
                "r\n" );
            }
            while ( ( x = getc( f ) ) == ' ' );
            if ( x == '+' || x == '-' )
            {
              if ( x == '-' ) j = -1;
              x = getc( f );
              if ( x == '\n' ) spiterr( "incomplete directive\n" );
            }
            if ( x > '9' || x < '0' )
              spiterr( "second argument to ;$C must be a decimal number"
                "\n" );
            i = x - '0';
            while ( x = getc( f ), x >= '0' && x <= '9' )
            {
              i *= 10;
              i += x - '0';
            }
            if ( x != '\n' && x != EOF )
              spiterr( "second argument to ;$C must be a decimal number"
                "\n" );
            constants[(unsigned char)k] = i * j;
            con[(unsigned char)k / 8] |= 1 << ( k % 8 );
            break;
          case 'A': spiterr( ";$A 'null extendor' directive not support"
            "ed\n" );
          default: spiterr( "unsupported directive\n" );
        }
      }
      aline++;
    }
#endif
    else
    {
      if ( x == '\n' )
      {
        line++;
        col = 0;
        sol = 1;
        aline++;
      }
      else
      {
        if ( x != ' ' )
        {
#ifdef BEFUNGE96
          x = remap[x];
#endif
          if ( fdim == 1 && line > 0 )
          {
            spiterr( "multiple source lines not allowed in Unefunge\n" );
          }
          if ( fyear == 93 && ( line > 24 || col > 79 ) )
          {
          /* This will only happen if -3 is used on the command line. */
            spiterr( "only 25 lines and 80 columns supported in Befunge"
              "-93\n" );
          }
          for ( i = 0; i < fdim; i++ ) scr[i] = loc[i];
          scr[lic] += line;
          scr[cic] += col;
          if ( !put( x, scr, funge ) ) return ( 0 );
          if ( !putflag && fyear == 97 && ip )
          {
            t = newthread( fdim );
            if ( t == NULL ) spiterr( "out of memory" );
            t->inputn[0] = t->outputn[0] = '\0';
            t->s.apex = t->s.base = NULL;
            t->s.readd = t->s.writed = 0;
            for ( i = 0; i < fdim; i++ )
            {
              t->coord[i] = scr[i];
              t->delta[i] = 0;
              t->base[i] = 0;
            }
            t->delta[cic] = 1;
            t->inputf = stdin;
            t->outputf = stdout;
            t->ticks = 0;
            t->next = funge->t;
            if ( t->next != NULL ) t->next->prev = t;
            t->prev = NULL;
            funge->t = t;
            t->iom = t->mode = t->swim = 0;
          }
          putflag = 1;
        }
        col++, sol = 0;
      }
    }
  }
  if ( fyear != 97 && ip )
  {
    t = newthread( fdim );
    if ( t == NULL ) spiterr( "out of memory" );
    t->inputn[0] = t->outputn[0] = '\0';
    t->s.apex = t->s.base = NULL;
    t->s.readd = t->s.writed = 0;
    for ( i = 0; i < fdim; i++ )
    {
      t->coord[i] = 0;
      t->delta[i] = 0;
      t->base[i] = 0;
    }
    t->delta[0] = 1;
    t->inputf = stdin;
    t->outputf = stdout;
    t->ticks = 0;
    t->next = funge->t;
    if ( t->next != NULL ) t->next->prev = t;
    t->prev = NULL;
    funge->t = t;
    t->iom = t->mode = t->swim = 0;
  }
  depth--;
  if ( depth == 0 )
  {
    switch ( fyear )
    {
      case 93: i = 0; break;
#ifdef BEFUNGE96
      case 96: i = 4; break;
#endif
      case 97:
        switch ( fdim )
        {
          case 1:
          case 2: i = fdim; break;
          default: i = 3; break;
        }
        break;
    }
    funge->iset = (int (*(*)[96])( struct thread**, fdat, struct fmach*
      ))malloc( ( isets[i].maxmode + 1 ) * 96 * sizeof( int (*)( struct
      thread**, fdat, struct fmach* ) ) );
    if ( funge->iset == NULL ) spiterr( "out of memory\n" );
    for ( k = 0; k <= isets[i].maxmode; k++ )
    {
      for ( j = 0; j < 96; j++ )
      {
        funge->iset[k][j] = isets[i].set[k][j];
      }
    }
    for ( j = 1; j < 96; j++ )
    {
      if ( disable[j + 31] ) funge->iset[0][j] = NULL;
    }
#ifdef BEFUNGE96
    if ( fyear == 96 )
    {
      for ( k = 1; k < 96; k++ )
      {
        if ( con[( k + 31 ) / 8] & ( 1 << ( ( k + 31 ) % 8 ) ) )
        {
          funge->iset[0][k] = pu96;
          funge->udefpsh[k + 31] = constants[k + 31];
        }
      }
    }
#endif
  }
  return ( 1 );
}
#undef spiterr

/**********************************************************************/
fdat readn( FILE *f )
{
  fdat c;
  while ( !fscanf( f, "%ld", &c ) )
    if ( !fscanf( f, "%c" ) ) return ( FUEOF );
  return ( c );
}

/**********************************************************************/
fdat readc( FILE *f )
{
  char c;
  if ( !fread( &c, 1, 1, f ) ) return ( FUEOF ); else return ( c );
}

