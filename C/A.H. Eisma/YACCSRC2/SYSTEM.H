/*                             *********************
 *                             *  S Y S T E M . H  *
 *                             *********************
 *
 * This file replaces the original "files." header file. It defines, for
 * the IBM PC/XT version, the target parser function source file, overriding
 * file name string defines, and other system-specific definitions and
 * parameters. 
 *
 * Bob Denny    06-Dec-80
 *
 * Edits:
 *              18-Dec-80  ZAPFILE no longer used in Decus Yacc.
 *                         Parser file renamed yypars.c
 *
 *              28-Aug-81  Temp files for RSX have specific version
 *                         numbers of 1 to avoid multi-versions. Rename
 *                         parser info file ".i".
 *
 *              12-Apr-83  Add FNAMESIZE & EX_xxx parameters.
 *
 *Scott Guthery 23-Dec-83  Adapt for the IBM PC/XT & DeSmet C compiler.
 *
 *Michiel van Loon
 *                              24-Nov-89  Adapt for ATARI-ST & TURBO-C compiler
 *
 */

/* Define WORD32 if target machine is a 32 bitter */

/*
 * Target parser source file
 */
# define PARSER    "yypars.c"

/*
 * basic size of the Yacc implementation
 */
# define HUGE      

/*
 * Table size for this Yacc
 */
# define HUGETAB   YES

/*
 * Filespec definitions
 */
# define ACTNAME   "yacc2.tmp"
# define TEMPNAME  "yacc1.tmp"
# define FNAMESIZE 24

/*
 * Exit status values
 */
# define EX_SUC    0
# define EX_WAR    1
# define EX_ERR    2
# define EX_SEV    4

/*
                Prototypes for all YACC routines
*/

void              aoutput  ( void );
int               apack    ( int * p, int n );
void              arout    ( char * s, int * v, int n );
void              aryfil   ( int * v, int n, int c );
void              cempty   ( void );
char            * chcopy   ( char * p, char * q );
int               chfind   ( int t, char * s );
void              callopt  ( void );
void              closure  ( int i );
void              cpyact   ( int offset );
void              cpfir    ( void );
void              cpres    ( void );
void              cpyunion ( void );
void              cpycode  ( void );
char            * cstash   ( char * s );
int               defin    ( int t, char * s );
void              defout   ( void );
void              error    ( char * s, ... );
int               fdtype   ( int t );
struct looksets * flset    ( struct looksets * p );
void              finact   ( void );
int               gettok   ( void );
void              gin      ( int i );
void              go2gen   ( int c );
void              go2out   ( void );
int               gtnm     ( void );
void              hideprod ( void );
int               nxti     ( void );
void              osummary ( void );
void              others   ( void );
void              output   ( void );
void              precftn  ( int r, int t, int s );
void              prlook   ( struct looksets * p );
void              putitem  ( int * ptr, struct looksets * lptr );
int               setunion ( int * a, int * b );
void              setup    ( int argc, char * * argv );
int               skipcom  ( void );
void              stagen   ( void );
int               state    ( int c );
void              stin     ( int i );
void              summary  ( void );
char            * symnam   ( int i );
int               unix_getc( FILE * iop );
int               yacc_ungetc( int c );
void              warray   ( char * s, int * v, int n );
void              wdef     ( char * s, int i );
void              wract    ( int i );
char            * writem   ( int * pp );
void              wrstate  ( int i );


/*#define debug */
