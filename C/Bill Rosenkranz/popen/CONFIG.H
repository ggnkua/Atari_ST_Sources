/*
 *	config.h - configure popen(3)
 */

#define DEBUG				/* def to COMPILE for debugging */
#define DEBUG_ON			/* def to turn on debugging, too */
#define STANDALONE			/* def to include test main below */
#undef HAVE_ONEXIT			/* def to use onexit() to close */
					/* files, if you have onexit() */
#define SYSTEM		_xsystem	/* how to invoke a cmd line */
					/* _psystem uses gulam, _xsystem is */
					/* mine and calls system after path */
					/* is searched. note: you can rename */
					/* _xsystem to system and add it to */
					/* your library. it calls _system. */
#ifdef DEBUG
# ifdef DEBUG_ON
int	_pipdebugging = 1;		/* set to 1 to debug locally */
# else
int	_pipdebugging = 0;
# endif
#endif

#ifdef STANDALONE
/*
 *	all this does is simulate "ls -l | grep man" in current dir. note
 *	that i have my own unix-like ls command called lsu here so you will
 *	probably need to change this...
 */
# define READCMD	"lsu -l"
# define WRITCMD	"c:\\bin\\grep man"
#endif
