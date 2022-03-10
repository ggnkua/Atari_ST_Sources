/* LazyTick header - tick.h */

#define LAZYVERS	"0.3"
#define LAZYNAME	"LazyTick"
#define LAZYLGID	"LTCK"

/* system dependancies UNIX */
#ifdef UNIX
#define SYSSTRSEPAR "/"
#define SYSSEPAR '/' 
#define MACHINE "Unix"
#define stricmp strcasecmp 	/* common names under unix */
#define strnicmp strncasecmp
#endif

/* system dependancies ATARI ST */
#ifdef ATARI
#define SYSSTRSEPAR	"\\"
#define SYSSEPAR '\\'
#define MACHINE "Atari ST"
#endif

/* systeme dependancies WINDOWS NT */
#ifdef WIN32
#define SYSSTRSEPAR	"\\"
#define SYSSEPAR '\\'
#define MACHINE "WinNT"
#endif

/* config files */
#define FAREASFILE	"fareas.bbs"	/* files areas list */
#define AREASFILE	"areas.bbs"		/* echomail areas list */
#define DEFLOGFILE	"lazytick.log"	/* default log file */
#define FILESBBS	"files.bbs"		/* file desc in fileareas */
#define BERMCFG1	"bermuda.cfg"	/* config file */
#define BERMCFG2	"tb.cfg"

/* internal limits */
#define BBSOK 		0
#define BBSFAIL 	1
#define BBSSTR	 	160	/* generic string */
#define MAXECHO		400	/* max number of areas */
#define NOLAZYFIX	/* disable LazyFix routines */

/* tic file limits */
#define MAXPASSNB	300
#define MAXSEEN 	2000
#define PASSLEN		80

/* structures */

typedef struct _fidonode {
	struct _fidonode *next;
	int position; /* for areafix */
	int zone;
	int net;
	int node;
	int point;
} FIDONODE;

typedef struct _echolist {
	char file[BBSSTR];  /* Name of HDR/MSG */
	char name[BBSSTR];	/* Fido Name */
	char desc[BBSSTR];	/* Description */
	char group[BBSSTR];	/* Group */
	int line;			/* areas.bbs line number for areafix */
	int modify;			/* for areafix */
	FIDONODE *firstnode;
} ECHOLIST;

typedef struct _ticfile {
	/* file ID */
	char area[BBSSTR];
	char file[BBSSTR];
	char desc[BBSSTR];
	char password[BBSSTR];
	unsigned long crc;
	unsigned long size;
	FIDONODE origin;
	FIDONODE from;
	/* Pass-thru lines (Path, App, etc) */
	char pass[MAXPASSNB][PASSLEN];
	int pass_nb;
	/* Seen by lines */
	FIDONODE seenby[MAXSEEN];
	int seenby_nb;
	/* local info */
	char filepath[BBSSTR];
} BTICFILE;

/* end of tick.h */
