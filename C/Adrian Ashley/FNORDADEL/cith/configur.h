/*
 * configur.h - defines and extern declarations for configur
 *
 * 90Nov21 AA	Renamed three of them back again -- we can use the lib now.
 * 90Aug28 AA	Four functions subordinate to msgscan() renamed to avoid
 *		conflict with library functions.
 * 90Jul21 AA	Created.
 */

#ifndef _CONFIGUR_H
#define _CONFIGUR_H

/* function declarations for cfg.c */

#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

void setupdefaults _P((void));
void parsecnfg _P((void));
void buildevent _P((char *line));
void addevent _P((struct evt_type *evt));
void buildpoll _P((char *line));
void buildarch _P((char *line));
int decodeday _P((char *when));
int readXstring _P((char *line, int maxsize, int flag));
int readDstring _P((char *from));
void readString _P((char *source, char *destination, char doproc));
void doformat _P((char *s));
void dependerr _P((char *errorstring));
void setflag _P((int arg, long mask));
void setvariable _P((char *var, int arg));
void set_audit _P((int x, short bit));
void checkdepend _P((int depend[]));
void exists _P((OFFSET where));
void openfiles _P((void));
void querysysop _P((void));
int msgscan _P((void));
void getmsg _P((void));
void roomscan _P((void));
void verifyroomok _P((int slot));
int logscan _P((void));
int logsort _P((const struct lTable *s1, const struct lTable *s2));
int floorscan _P((void));
int netscan _P((int init));
int normID _P((LABEL source, LABEL dest));
void zapscan _P((void));
int getx _P((int i));
int putx _P((void));
int msginit _P((void));
void realmsginit _P((int fl));
int roominit _P((int which));
void writenewroom _P((int slot));
int loginit _P((void));
int floorinit _P((void));
void cleanup _P((void));

#undef _P

/* #defines */
#define MSGS 0		/* indices into tozap[] array */
#define LOG 1
#define NET 2
#define FLOOR 3

#define NONE 0		/* values for roomsmissing */
#define SOME 1
#define ALL 2

#define ANYTOZAP() \
(tozap[MSGS] || tozap[LOG] || tozap[NET] || tozap[FLOOR] || roomsmissing)

#define CFG	"ctdlcnfg.sys"

#define DEPENDSIZE 16

#define	NODETITLE   0	/* sys */
#define	SYSDIR      1	/* sys */
#define ROOMDIR	    2	/* sys */
#define	HELPDIR     3	/* sys */
#define	MSGDIR      4	/* sys */
#define	AUDITDIR    5
#define	NETDIR      6	/* network */
#define	RECEIPTDIR  7	/* network */
#define	NETPREFIX   8	/* network */
#define NETSUFFIX   9	/* network */
#define	NODENAME   10	/* network */
#define	NODEID     11	/* network */
#define	MESSAGEK   12	/* sys */
#define LTABSIZE   13	/* sys */
#define	SYSBAUD    14	/* sys */
#define HOLDDIR	   15

/* miscellaneous */
#define myrealloc(ptr,size)	(size == 0 ? ptr : realloc(ptr,size))

#endif /* _CONFIGUR_H */
