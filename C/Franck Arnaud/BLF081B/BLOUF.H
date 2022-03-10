/*
 *	BloufGate -- A Free Fido / Usenet Gateway Program
 *	=========
 *	
 *	Header File TO EDIT FOR CONFIGURATION
 *	(use 4 spaces a TAB for nicer layout)
 *
 *	Public Domain: may be copied and sold freely
 *
 *	Originally written by Vincent Pomey and Franck Arnaud
 *	With contributions from Thierry Bousch
 */
/* ------------------------------------ Include Files */

#include	<stdio.h>
#include	<string.h>
#include	<stdarg.h>
#include	<stdlib.h>
#include	<time.h>
#include	<ctype.h>   
#include	<errno.h>

#include	"portab.h"	/* WORD, LONG, etc declarations */

/* ------------------------------------ Program Configuration */

/*#define BATCHSMTP				  *//* output batch smtp */
#define	DEBUG						/* Enable debug code */
#define	Version 		"0.8.1"		/* Version number */
#define	ProgName   		"BloufGate"	/* program name */
#define	ProdCode   		0xE8		/* FTSC registered product code for BloufGate */
#define USE_RFCID      				/* use the proposed RFCID kludge */
#define USE_CHRS					/* use CHRS kludge to describe ISO Latin-1 usenet defaults charset */
#define KILL_DUPES					/* use dupe checker */
#define MAXCROSS 		3 			/* Max number of crosspost to fido groups */

/* System dep. defintions:
	DEFAULT_CONFIG	default configuration file
	BLF_DSEPAR		directory separator
	BLF_BUFSIZE		news unbacther buffer */

#ifdef UNIX	 /* Unix: tested with GCC 2.2, GNU Libs, under Linux */

#define DEFAULT_CONFIG  "/etc/blouf.cfg"
#define BLF_DSEPAR      '/'
#define BLF_BUFSIZE 	200000
#define stricmp strcasecmp
#define strnicmp strncasecmp

#elif ST_GCC /* Atari ST: GCC, MiNT */

#define DEFAULT_CONFIG  "/etc/blouf.cfg"
#define BLF_DSEPAR      '/'
#define BLF_BUFSIZE 	200000
#include <unistd.h>

#elif ST_PUREC /* Atari ST: Turbo/Pure C */

#define DEFAULT_CONFIG 	"blouf.cfg"	/* default config */
#define BLF_DSEPAR 		'\\' 		/* Directory separator */
#define BLF_BUFSIZE		100000		/* news unbatch buffer */
#include <tos.h>
#include <ext.h>  /* getcwd etc */

#elif ST_LATTICE /* Atari ST,Tos: Lattice C 5 */

#define DEFAULT_CONFIG 	"blouf.cfg"	/* default config */
#define BLF_DSEPAR 		'\\' 		/* Directory separator */
#define BLF_BUFSIZE		100000		/* news unbatch buffer */
#include <osbind.h> /* tos, pour Fsfirst/Fsnext/Fsetdta, FGATE */
#undef min
#undef max /* disable built-in funcs (int only) */

#elif WIN32 /* Windows NT, tested with 0393BETA SDK/MCVC++ 32 */

#define DEFAULT_CONFIG 	"blouf.cfg"	/* default config */
#define BLF_DSEPAR 		'\\' 		/* Directory separator */
#define BLF_BUFSIZE		100000		/* buffer */
#include <io.h>

#elif MSDOS_MSC /* DOS with MicroSoft C 7.00, 8.00 (VC++) */

#define DEFAULT_CONFIG 	"blouf.cfg"	/* default config */
#define BLF_DSEPAR		 '\\' 		/* Directory separator */
#define BLF_BUFSIZE 	50000
/* for MSC */                                                                                                              
#include <io.h>
 
#endif /* end sysdep */

/* USER CONFIGURATION ENDS HERE */
/* ------------------------------------ Internal Program Definitions */

#define	fgets 			fblfgets 	/* enhanced fgets */
/* temporary macro used to structurize */
#define init_user(a,u,z,n,f,p) a.zone=z; a.net=n; a.node=f; a.point=p; strcpy(a.name,u);

#ifndef min
#define min(a,b) 		((a)>(b) ? (b) : (a))
#endif
#ifndef max
#define max(a,b) 		((a)<(b) ? (b) : (a))
#endif
#define	Set(a)			(1 << (a))

#ifndef TRUE
#define TRUE			1
#endif
#ifndef FALSE
#define FALSE			0
#endif

#define BLF_MAXNPART	10 			/* security to prevent infinite msg loop */

#define FAIL			1			/* return var for various funcs */
#define SUCCESS			0
#define BOUNCE			1
#define WARNING			2

#define NLLEN			30			/* Max NODELIST description len */
#define	NEWSLEN			40			/* max len of a newsgroup name */
#define	FIDOLEN			20			/* max len of a fidonet name */
#define	BLFSTR			150			/* max len of various buffer strings */
#define PASSLEN			10			/* max len of packet password */

#define RFCIDKLUDGE 	"RFCID:"	/* Implements proposed RFCID kludge */
#define RNEWSSTR 		"#! rnews "	/* in news batches...*/
#define DEFAULT_DOMAIN 	"fidonet.org"

/* ------------------------------------ Structures definitions */

typedef struct _bloufgnews{
	char	news[NEWSLEN];
	char	fido[FIDOLEN];
	int write;
	struct _bloufgnews *next;
} GATENEWS;

typedef struct
{
	int zone;
	int net;
	int node;
	int point;
	char name[BLFSTR];
} BFIDOUSER;

typedef struct _bloufnlist {
	WORD zone;
	WORD net;
	char name[BLFSTR];
	struct _bloufnlist *next;
} LISTIDX;

typedef struct _bloufulist {
	char fido[BLFSTR];
	char rfc[BLFSTR];
	struct _bloufulist *next;
} USERIDX;

typedef struct {
	int	o_zone;						/* our 4D fido address */
	int	o_net;
	int	o_node;
	int	o_point;

	int	td_net;						/* our 2d address */
	int	td_node;

	int	b_zone;						/* our boss address */
	int	b_net;
	int	b_node;

	int maxsize;					/* max size for rfc->fido */
	int outmaxsize;					/* max size fido->internet */
	int fsc0035;					/* use fsc-0035 kludges */
	int keep;						/* delete incoming files after import */
	int checkdomain;				/* check primary internet domain */
	int registered;					/* registered in xxx.fidonet.org namespace */
	int tunnelwarning;				/* bounce mail to your own FTN domain, eg fidonet.org */
	int uucpwarning;				/* warning to .uucp addresses */
	int bitnetwarning;				/* warning to .bitnet addresses */
	int startrek;					/* add galactic federation approved RFC headers */
	int fourdpkt;					/* reserved */
	int nopath;
	char pktpass[PASSLEN];			/* packet password */

	char outpkt[BLFSTR];			/* path to output fido .pkt */
	char outrfc[BLFSTR];			/* path to output rfc mail */
	char outnws[BLFSTR];			/* (opt) path to output rnews files */
	char dupefile[BLFSTR];			/* (opt) dupefile */
	char tempdir[BLFSTR];			/* temporary directory */
	char uuname[FIDOLEN];			/* name of the uucp site */
	char magic[BLFSTR];				/* name of magic file to request for help */
	char origin[BLFSTR];			/* origin line */

	char fgateann[30];				/* filegate, unused at that time */
	char fgateref[BLFSTR];
	char fgatebin[BLFSTR];
	char fgatetemp[BLFSTR];

	USERIDX *userlist;				/* user list linked list */
	LISTIDX *netlist;				/* net list linked list */
} BCONFIG;

/*------------------------------------ Global variables (defined in global.c) */

extern BCONFIG *cf;

/* ------------------------------------ Prototypes */

/* main.c */
void usage(void );
/* fug.c */
int gatemail(BFIDOUSER *, char *, char *, char *,
			struct tm *,char *);
int gatenews(char *, BFIDOUSER *,
               char *, struct tm *, char *, char *, char *);
int process_packet(char *outbound);
/* ufg.c */
int process_rfcfile(char *, FILE *, char *);
int process_news(char *, FILE *);
int process_mailbox(char *, FILE *, char *);
/* misc.c */
char *fblfgets(char *,size_t,FILE *);
FILE *create_rfcfile(char *path,
     	char *ext);
void killslash(char *s);
void mksoftcr(char *text);
void clean_string(char *s);
void strip(char *line);
int token(char *tok,
            char *line);
void fputiw(WORD b,
            FILE *a);
WORD fgetiw(FILE *fi);
void fgetf(char *str,
           int max,
           FILE *fi);
int strscan(char a,
              char *line);
int openlog(char *lfname);
void closelog(void);
void logline(const char *line, ...);
/* Prototypes for config.c */
GATENEWS *area_unix2fido(char *name);
GATENEWS *area_fido2unix(char *name);
void cleanconfig(void);
void displayconfig(void );
int openusers(char *);
char *finduser(char *);
int readconfig(char *configfile, char *condition);
int openlist(char *path);
void closelist(void);
char *findnode(int zone, int net, int node);
void setdomain(char *);
char *finddomain(int,int,int);
/* Prototypes for address.c */
void killendspace(char *);
void strdate2tm(char *, struct tm *);
void norm_rfc(char *, char *, char *);
int fido2ints(char *, int *, int *, int *, int *);
int fido2rfc(BFIDOUSER *, char *, char *, char *);
int rfc2fido(BFIDOUSER *, char *);
int bounce_net(int, char *, char *, char *, char *);
void bounce_fido(int, char *,  BFIDOUSER *, char *);
/* prototypes for pkt.c */
unsigned long msgid_serial(void );
FILE *openpacket();
void closepacket(FILE *);
void openpktmessage(FILE *,char *,
	BFIDOUSER *from, BFIDOUSER *to, char *, unsigned long, struct tm *);
void closepktmessage(FILE *);
/* prototypes killdupe.c */
int already_seen(char *);
long dupechk_open(char *);
int dupechk_seen(char *);
void dupechk_close(void);

/* eof */
