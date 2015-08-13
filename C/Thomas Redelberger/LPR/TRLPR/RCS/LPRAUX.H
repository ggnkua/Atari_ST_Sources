head	1.2;
access;
symbols
	TRLPR11B:1.2
	TRLPR10B:1.1;
locks
	Thomas:1.2; strict;
comment	@ * @;


1.2
date	99.12.30.13.03.18;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.11.13.17.09.50;	author Thomas;	state Exp;
branches;
next	;


desc
@@


1.2
log
@Much cleaner interface for common function to lpr and lp.
JOBDEF structure introduced
@
text
@/* Dr. Thomas Redelberger, Nov 1999 */
/* tcp/ip lpr printer client functions for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpraux.h 1.1 1999/11/13 17:09:50 Thomas Exp Thomas $
*/


typedef struct {
	char* hostName;
	char* userName;
	char* rmHost;
	char* rmPrinter;
	int   optNoBanner;
	int   optSendMail;
	char* optNCopies;
	char* optNIndent;
	char* optNWidth;
	char* optTitle;
	char  optFormat[3];
	char  filler1;
	char* spoolDir;
	char  spoolFile[12];
} JOBDEF;



int lprInit(JOBDEF* jd);

int lprLookupQueue(JOBDEF* pjd, char *queue);

int lprConnect(char* host);

void lprPrintfile(
	JOBDEF* pjd,
	char* oriFileName,
	char* spoolFileFullName,
	int cnId,
	void (*meter)(long totLen, long accumLen, long actLen) );
@


1.1
log
@Initial revision
@
text
@d5 1
a5 1
$Id$
d9 16
a24 1
extern int tcpBuffSize;
a25 11
extern int optNoBanner;
extern int optSendMail;
extern char* rmPrinter;
extern char* optNCopies;
extern char* optNIndent;
extern char* optNWidth;
extern char* optTitle;
extern char  optFormat[];		/* defaults to binary */
extern char* rmHost;
extern char* userName;
extern char* hostName;
d28 1
d30 1
a30 1
void getSpoolFilePath(char *path);
d32 1
a32 1
void getSpoolFileName(char *spoolFileName);
d34 2
a35 5
int initLpr(void);

int connect(char* host);

void printfile(
a37 1
	char *spoolFileName,
@
