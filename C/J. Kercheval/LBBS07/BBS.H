/* LazyBBS header - bbs.h */

#define LAZYVERS	"0.7"			/* version number */
#define LAZYNAME	"LazyBBS"		/* program name */

/* setup */
#define D_MAXDOWN	300				/* max download KB per day */
/*efine CHAT_HOTKEY	'\0xf'  	*/	/* ctrl-O to chat at every prompt */
#define	S_TIMEOUT	300				/* 300 s = 5mn inactivity timeout */
#define D_TIMEOUT	45				/* 45 mn login / session max */

/* system dependancies UNIX */
#ifdef UNIX
/* #include <alib.h> ansi fake libs */
#define SYSSTRSEPAR "/"
#define SYSSEPAR '/' 
#define MACHINE "Unix"
/*efine DO_ECHO_MYSELF echo ourselves what the guy typed */
/* define clock_t and CLK_TCK if not already done (needed on News-OS) */
#ifndef clock_t
#define clock_t long
#endif
#ifndef CLK_TCK
#define CLK_TCK 1000
#endif
#define min(a,b) ((a)>(b)?(b):(a))
#define max(a,b) ((a)<(b)?(b):(a))
#endif

/* system dependancies ATARI ST */
#ifdef ATARI
#define SYSSTRSEPAR	"\\"
#define SYSSEPAR '\\'
#define MACHINE "Atari ST"
#define DO_ECHO_MYSELF
#endif

/* constants and default values */
#define CLS_STRING	"\033E\033[2J\r" /* VT52 then VT100 screen clear */
#define ERASE_LINE  "\033[2K\r"		/* VT100 erase line */
#define MAXTRIES	3				/* max tries (passwd,bad answers,etc) */
#define MAXKEYS		50				/* max # of choices in menu */
#define MORELINE	21

/* config files */
#define LOGINFILE	"users.cfg"		/* text file containing users */
#define CONFIGFILE	"bbs.cfg"
#define QUESTFILE	"question.txt"	/* new user questions */
#define ANSWERFILE  "answers.txt"	/* answsers */
#define CFGFILE		"bbs.cfg"
#define DEFLOGFILE	"bbs.log"		/* default log file */
#define AREASFILE	""

/* menus and std pages */
#define TOPMENU		"top.mnu"
#define HOTNEWS		"hotnews.txt"
#define INTRO		"intro.txt"
#define WELCOME		"welcome.txt"
#define BYE			"bye.txt"
#define FILESBBS	"files.bbs"

/* internal limits */
#define BBSOK 		0
#define BBSFAIL 	1
#define BBSSTR	 	150	/* generic string */
#define BBSSEPAR 	'!'	/* separator in user's file */
#define ECHOCHAR	0	/* get_string echo char? */
#define MAXECHO		400	/* max number of areas */
#define FBBSCUTLEN  45	/* download() */
#define FBBSSTART	31

/* typedefs */
typedef struct
{
	char first_name[BBSSTR];		/* first name */
	char last_name[BBSSTR];			/* last name */
	char password[BBSSTR];			/* password */
	char address[BBSSTR];			/* address */
	char flags[BBSSTR];				/* flags */
	int last_login;					/* last login day */
	int downkb;						/* download kb today */
	int calls;						/* number of calls */
} BBSLOGIN;

typedef struct {
	char file[BBSSTR];    /* Name of HDR/MSG */
	char name[BBSSTR];	/* Fido Name */
	char desc[BBSSTR];	/* Description */
	char group[BBSSTR];	/* Group */
} ECHOLIST;

/* end of bbs.h */