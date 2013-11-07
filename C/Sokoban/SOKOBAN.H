/***********************************************************************
   You may wish to alter the following directory paths
***********************************************************************/

/* The system you're compiling under */
#define ATARIST	1
#define UNIX 0

#if ATARIST
#include <tos.h>
#define get_char() Cnecin()

#define SCREENPATH ".\\screens"
#define HELPFILE "sokoban.hlp"
#define SAVEPATH "."
#define SCOREFILE "sokoban.scr"

/* Pipe it all to stdout */
#undef stderr
#define stderr stdout

#else

#define get_char() getchar()

/**/
/* SCREENPATH: the name of the directioy where the screen file are held */
/**/
#define SCREENPATH     "/yale/games/lib/sokoban/screens"

/**/
/* HELPFILE: the full pathname of the helpfile */
/**/
#define HELPFILE       "/yale/games/lib/sokoban/sokoban.help"

/**/
/* SAVEPATH: the name of the path where save files are held */
/*           Attention: Be sure that there are no other files with */
/*                      the name <username>.sav                    */
/**/
#define SAVEPATH       "/yale/games/lib/sokoban"

/**/
/* LOCKPATH: temporary file which is created to ensure that no users */
/*           work with the scorefile at the same time                */
/**/
#define LOCKFILE       "/tmp/sok.lock"

/**/
/* SCOREFILE: the full pathname of the score file */
/**/
#define SCOREFILE      "/yale/games/lib/sokoban/sok.score"
#endif

/**/
/* MAXUSERNAME: defines the maximum length of a system's user name */
/**/
#define MAXUSERNAME    10

/**/
/* MAXSCOREENTRIES: defines the maximum numner of entries in the scoretable */
/**/
#define MAXSCOREENTRIES        50

/**/
/* SUPERUSER: defines the name of the game superuser */
/**/
#define SUPERUSER "wunk"

/**/
/* PASSWORD: defines the password necessary for creating a new score file */
/**/
#define PASSWORD "nabokos"

/*************************************************************************
********************** DO NOT CHANGE BELOW THIS LINE *********************
*************************************************************************/
#define C_PLAYER       '@'
#define C_PLAYERSTORE   '+'
#define C_WALL         '#'
#define C_GROUND       ' '
#define C_STORE                '.'
#define C_PACKET       '$'
#define C_SAVE         '*'

#define MAXROW         20
#define MAXCOL         40

typedef struct {
   short x, y;
} POS;

char *malloc();
FILE *fopen();

#define storepos( p, a, b)    p.x = a; p.y = b;

#define E_FOPENSCREEN  1
#define E_PLAYPOS1     2
#define E_ILLCHAR      3
#define E_PLAYPOS2     4
#define E_TOMUCHROWS   5
#define E_TOMUCHCOLS   6
#define E_ENDGAME      7
#define E_FOPENHELP    8
#define E_NOUSER       9
#define E_FOPENSAVE    10
#define E_WRITESAVE    11
#define E_STATSAVE     12
#define E_READSAVE     13
#define E_ALTERSAVE    14
#define E_SAVED                15
#define E_TOMUCHSE     16
#define E_FOPENSCORE   17
#define E_READSCORE    18
#define E_WRITESCORE   19
#define E_USAGE                20
#define E_ILLPASSWORD  21
#define E_LEVELTOOHIGH 22
#define E_NOSUPER      23
#define E_NOSAVEFILE   24


typedef struct {
	POS ppos;
	POS tpos1, tpos2;
	char lppc, ltp1c, ltp2c;
	short action;
} soko_state;
