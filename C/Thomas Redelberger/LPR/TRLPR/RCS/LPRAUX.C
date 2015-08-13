head	1.2;
access;
symbols
	TRLPR11B:1.2
	TRLPR10B:1.1;
locks
	Thomas:1.2; strict;
comment	@ * @;


1.2
date	99.12.30.12.55.34;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.11.13.17.09.50;	author Thomas;	state Exp;
branches;
next	;


desc
@Auxiliary files with common functions for lpr, lp and lpd
@


1.2
log
@Version to use DEFAULT.CFG instead of printcap
@
text
@/* Dr. Thomas Redelberger, Nov 1999 */
/* tcp/ip lpr printer client functions for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpraux.c 1.1 1999/11/13 17:09:50 Thomas Exp Thomas $
*/

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <tos.h>

#include "transprt.h"		/* access to STinG */
#include "lpraux.h"			/* my lpr functions */
#include "lprui.h"			/* user interface */

#define	NULL ((void*) 0L)

#define	YIELDMS		50L


#define min(a,b) (((a) < (b)) ? (a) : (b))


/* defaults */
#define	DEF_RP	"lp"			/* convention */
#define	DEF_RM	"127.0.0.1"		/* this machine */
#define	DEF_SD	".\\"			/* current dir */





#define LPR_REM_PORT	515		/* remote port used by lp daemon */
#define LPR_LOC_PORT	721		/* to 731 inclusive used by this client */


static int tcpBuffSize = 1500;



/************************************************************************************************/
/************************************************************************************************/

int lprLookupQueue(JOBDEF* pjd, char *queue)
{
	char i;
	char *p, *q;
	static char qn[] = "LPA_QN";
	static char rp[] = "LPA_RP";
	static char rm[] = "LPA_RM";
	static char sd[] = "LPA_SD";

	/* find queue in default.cfg */

	for (i='A'; i<='Z'; i++) {
		qn[2] = i;
		q = getvstr(qn);
#if 0
		/* LPx must be ascending with no holes */
		if (q[0] == '0') return -1;					/* nothing found */
#else
		/* LPx need not be ascending */
		if (q[0] == '0') continue;					/* this does not exist */
#endif
		if (strcmp(q, queue) == 0) break;			/* found */
	}

	if (i > 'Z') return -1;		/* nothing found */

	sd[2] = rm[2] = rp[2] = i;	/* set to entry found */

	/* look if a remote queue was specified */
	p = getvstr(rp);
	if (p[0] != '0')
		pjd->rmPrinter = p;		/* yes */
	else
		pjd->rmPrinter = q;		/* no, defaults to name of local queue */

	/* remote host */
	p = getvstr(rm);
	if (p[0] != '0')
		pjd->rmHost = p;		/* yes */
	else
		pjd->rmHost = DEF_RM;

	/* spool directory */
	p = getvstr(sd);
	if (p[0] != '0')
		pjd->spoolDir = p;		/* yes */
	else
		pjd->spoolDir = DEF_SD;		/* yes */

	return 0;
}	/* lookupQueue */



/************************************************************************************************/
/************************************************************************************************/

static void getSpoolFileName(char *spoolFileName, char *hostName)
{
	long JobNum = ( clock() / CLK_TCK ) % 1000L;

	/* construct spool file name */
	strcpy(spoolFileName, "fA___");
	ltoa(JobNum, spoolFileName+2, 10);
	/* put leading zeros */
	if (spoolFileName[4] == '\0'		/* 2 digits only */
	||	spoolFileName[4] == '_') {		/* 1 digit only */
		spoolFileName[4] = spoolFileName[3];
		spoolFileName[3] = spoolFileName[2];
		spoolFileName[2] = '0';
	}
	if (spoolFileName[4] == '\0') {		/* was 1 digits */
		spoolFileName[4] = spoolFileName[3];
		spoolFileName[3] = spoolFileName[2];
		spoolFileName[2] = '0';
	}
	strcat(spoolFileName, hostName);
}


/************************************************************************************************/
/* get the environment																			*/
/************************************************************************************************/

int lprInit(JOBDEF* pjd)
{
	char *p;
	char spoolFileName[50];				/* temporary */

	memset(pjd, 0, sizeof(JOBDEF));		/* set to known state */
	pjd->optFormat[0] = 'l';			/* binary is default */
	pjd->optFormat[1] = 'd';			/* 'd' for data file */
	

	if ( (p = getenv("TCPWND")) != NULL ) tcpBuffSize = atoi(p);

/* user name on local host AND on remote host (for *nix systems mandatory) */
	pjd->userName = getvstr("USERNAME");
	if (pjd->userName[0] == '0'
	||  pjd->userName[0] == '1' && pjd->userName[1] == '\0') {
		uiPrintf(uiH, uiPrERR, "USERNAME missing in default.cfg");
		return -1;
	}

/* local host */
	pjd->hostName = getvstr("HOSTNAME");
	if (pjd->hostName[0] == '0'
	||  pjd->hostName[0] == '1' && pjd->hostName[1] == '\0') {
		uiPrintf(uiH, uiPrERR, "HOSTNAME missing in default.cfg");
		return -1;
	}
	strtok(pjd->hostName,".");		/* chop off domainname */

/* spool file name */
	getSpoolFileName(spoolFileName, pjd->hostName);
	strncpy(pjd->spoolFile, spoolFileName, 8);	/* sorry, no more for TOS */

/* these are the defaults */

/* remote queue name */
	pjd->rmPrinter = DEF_RP;

/* remote host */
	pjd->rmHost = DEF_RM;

/* spool directory */
	pjd->spoolDir = DEF_SD;

	return 0;
}



/************************************************************************************************/
/* open a connection and return tcp connection handle, 0 if error				*/
/************************************************************************************************/

int16 lprConnect(char* host)
{
	CAB cab;
	int16 tcpHndl, state;

/* remote and local port numbers for lpr connection */

	cab.rport = LPR_REM_PORT;
	cab.lport = LPR_LOC_PORT+(int)(Random() % 10);
	cab.lhost = 0;

	if (resolve(host, NULL, &(cab.rhost), 1) < 1) {
		uiPrintf(uiH, uiPrERR, "unknown remote host");
		return 0;
	}

	if( (tcpHndl = TCP_open((uint32)&cab, TCP_ACTIVE, 0, tcpBuffSize)) <= 0 ) {
		uiPrintf(uiH, uiPrERR, "could not open connection");
		return 0;
	}

    if ( (state = TCP_wait_state(tcpHndl, TESTABLISH, 30)) < 0 ) {
		uiPrintf(uiH, uiPrERR, "%s", get_err_text(state));
		return 0;
    }

	return tcpHndl;
}



#define TIMEOUT	10	/* seconds */

/************************************************************************************************/
/************************************************************************************************/

static void output(int16 cnId, char *o_str, int o_len)
{
	int16 rc;
	clock_t to = clock() + TIMEOUT * CLK_TCK;	/* time to quit at */

	/* wait if previous stuff was not yet sent */
	while ( (rc = TCP_send(cnId, o_str, o_len)) == E_OBUFFULL) {
		if (clock() > to) {
			uiPrintf(uiH, uiPrERR, "output: send timed out");
			return;
		}
		uiYield(uiH, YIELDMS);
	} 

	if (rc != E_NORMAL) {
		uiPrintf(uiH, uiPrERR, "output: %s", get_err_text(rc));
	}

}	/* end output */


/************************************************************************************************/
/************************************************************************************************/

#define RESPONSESIZE	1

static int16 getResponse(int16 cnId)
{
	char response[RESPONSESIZE];
	int16 nInQueue;
	int16 rc;
	clock_t to = clock() + TIMEOUT * CLK_TCK;	/* time to quit at */

	/* poll for input */
	while ( (nInQueue = CNbyte_count(cnId)) <= 0 ) {
		if (clock() > to) {
			uiPrintf(uiH, uiPrERR, "get timed out");
			return -1;
		}
		uiYield(uiH, YIELDMS);
	} 

	rc = CNget_block(cnId, response, min(nInQueue, RESPONSESIZE) );
	if (rc != min(nInQueue, RESPONSESIZE)) {
		uiPrintf(uiH, uiPrERR, "get failed");
		return -1;
	}

	return response[0];
}	/* getResponse */
#undef RESPONSESIZE

#if 0
/************************************************************************************************/
/************************************************************************************************/

void lprGetSpoolFilePath(char *path)
{
	char *s;

	if ( (s=getenv("TMPDIR")) == NULL) {
		if ( (s=getenv("TEMP")) == NULL) {
			if ( (s=getenv("TEMP")) == NULL) {
				s = ".\\";
			}
		}
	}
	strcpy(path, s);

	/* make shure it ends with a slash */
	if (path[strlen(path)-1] != '\\')
		strcat(path, "\\");
}
#endif

/************************************************************************************************/
/************************************************************************************************/

#define FILEBUFFSIZE	256

void lprPrintfile(
	JOBDEF* pjd,
	char* oriFileName,
	char* spoolFileFullName,
	int16 cnId,
	void (*meter)(long totLen, long accumLen, long actLen) )
{
	char fileBuff[FILEBUFFSIZE];
	long fileLength;
	long lenData = 0;
	long lenSent = 0;    
	char o_str[100];
	int	fin;
	char rc;
	char *eM;

	if ( (fin=Fopen(spoolFileFullName, FO_READ)) < 0) {
		eM = "cannot open spool file for read"; goto errExit;
	}

	fileLength = Fseek(0, fin, 2);	/* position to end */
	Fseek(0, fin, 0);

	/* start the lprd protocol for this file */

/* command 0x02 "receive  printer job" */

	o_str[0] = 0x02;
	o_str[1] = '\0';
	strcat(o_str, pjd->rmPrinter);
	strcat(o_str, "\n");
	output(cnId, o_str, (int)strlen(o_str));

	if ( getResponse(cnId) != 0x00 ) {
		uiPrintf(uiH, uiPrERR, "unknown queue|>%s<|on remote host", pjd->rmPrinter);
		return;
	}



/* subcommand 0x02 "receive control file" */

	/* build the control file */
	strcpy(fileBuff,   "H");
	strcat(fileBuff, pjd->hostName);	/* mandatory */
	strcat(fileBuff, "\nP");
	strcat(fileBuff, pjd->userName);	/* mandatory */
	strcat(fileBuff, "\nN");
	strcat(fileBuff, oriFileName);		/* mandatory */
	strcat(fileBuff, "\n");

	if (pjd->optSendMail) {
		strcat(fileBuff,   "M");
		strcat(fileBuff, pjd->userName);
		strcat(fileBuff, "\n");
	}

	if (!pjd->optNoBanner) {
		strcat(fileBuff,   "C");
		strcat(fileBuff, pjd->hostName);	/* class for banner */
		strcat(fileBuff, "\nJ");
		strcat(fileBuff, oriFileName);		/* job name for banner */
		strcat(fileBuff, "\nL");
		strcat(fileBuff, pjd->userName);	/* banner */
		strcat(fileBuff, "\n");
	}

#if 0	/* not supported */
	strcat(fileBuff,   "U");
	strcat(fileBuff, spoolFileName);	/* unlink data file */
	strcat(fileBuff, "\n");
#endif

	if (pjd->optNCopies) {
		strcat(fileBuff,   "#");
		strcat(fileBuff, pjd->optNCopies);
		strcat(fileBuff, "\n");
	}

	if (pjd->optNIndent) {
		strcat(fileBuff,   "I");
		strcat(fileBuff, pjd->optNIndent);
		strcat(fileBuff, "\n");
	}

	if (pjd->optNWidth) {
		strcat(fileBuff,   "W");
		strcat(fileBuff, pjd->optNWidth);
		strcat(fileBuff, "\n");
	}

	if (pjd->optTitle) {
		strcat(fileBuff,   "T");
		strcat(fileBuff, pjd->optTitle);
		strcat(fileBuff, "\n");
	}

	strcat(fileBuff, pjd->optFormat);
	strcat(fileBuff, pjd->spoolFile);
	strcat(fileBuff, "\n");

#ifdef DEBUG
	uiPrintf(uiH, uiPrOK, "%s", fileBuff);
#endif

	o_str[0] = 0x02;
	ltoa(strlen(fileBuff), o_str+1, 10);
	strcat(o_str, " c");
	strcat(o_str, pjd->spoolFile);
	strcat(o_str, "\n");

	output(cnId, o_str, (int)strlen(o_str));
	rc = getResponse(cnId);
	if        (rc == 0x01) {
		eM = "connection messed up, try again"; goto errExit;
	} else if (rc == 0x02) {
		eM = "server out of storage space"; goto errExit;
	} else if (rc != 0x00) {
		eM = "no ack on sub command 3"; goto errExit;
	}

	output(cnId, fileBuff, (int)strlen(fileBuff));

	fileBuff[0] = 0;
	output(cnId, fileBuff, 1);	/* terminator */

	if ( getResponse(cnId) != 0x00 ) {
		eM = "control file not properly transferred"; goto errExit;
	}


/* subcommand 0x03 "receive data file" */

	o_str[0] = 0x03;
	ltoa(fileLength, o_str+1, 10);
	strcat(o_str, " d");
	strcat(o_str, pjd->spoolFile);
	strcat(o_str, "\n");
#ifdef DEBUG
	uiPrintf(uiH, uiPrOK, "%s", o_str+1);
#endif
	output(cnId, o_str, (int)strlen(o_str));

	rc = getResponse(cnId);
	if        (rc == 0x01) {
		eM = "connection messed up, try again"; goto errExit;
	} else if (rc == 0x02) {
		eM = "server out of storage space"; goto errExit;
	} else if (rc != 0x00) {
		eM = "unknown"; goto errExit;
	}


	while ( (lenData = Fread(fin, min(FILEBUFFSIZE, fileLength), fileBuff)) > 0) {
		lenSent += lenData;

		if (meter != NULL)
			(*meter)(fileLength, lenSent, lenData);

		output(cnId, fileBuff, (int)lenData);
	}


	fileBuff[0] = 0;
	output(cnId, fileBuff, 1);	/* terminator */

	Fclose(fin);

	if ( getResponse(cnId) != 0x00 ) {
		eM = "data file not properly transferred"; goto errExit;
	}
#ifdef DEBUG
	uiPrintf(uiH, uiPrOK, "file closed");
#endif
	return;

errExit:
	uiPrintf(uiH, uiPrERR, "%s", eM);
}	/* print_file */

#undef FILEBUFFSIZE
@


1.1
log
@Initial revision
@
text
@d5 1
a5 1
$Id$
d13 3
a15 1
#include "transprt.h"
d19 1
d22 2
d25 5
a29 3
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define RESPONSESIZE	1024
#define FILEBUFFSIZE	1000
a31 16
int tcpBuffSize = 1500;
char response[RESPONSESIZE];
char fileBuff[FILEBUFFSIZE];


int optNoBanner = FALSE;
int optSendMail = FALSE;
char* rmPrinter;
char* optNCopies;
char* optNIndent;
char* optNWidth;
char* optTitle;
char  optFormat[] = "ld";		/* defaults to binary */
char* rmHost;
char* userName;
char* hostName;
d38 86
d129 1
a129 1
int initLpr()
d132 6
d141 7
a147 2
	if ( (rmPrinter = getenv("PRINTER")) == NULL )
		rmPrinter = "lp";
d149 6
a154 6
	if ( (userName = getenv("USER")) == NULL ) {
		userName = getvstr("USERNAME");
		if (userName[0] == '0') {
			Cconws("lpr: error: no USER in env or USERNAME in default.cnf\r\n");
			return -1;
		}
d156 5
d162 4
a165 8
	if ( (hostName = getenv("HOST")) == NULL ) {
		hostName = getvstr("HOSTNAME");
		if (hostName[0] == '0') {
			Cconws("lpr: error: no HOST in env or HOSTNAME in default.cnf\r\n");
			return -1;
		}
	}
	strtok(hostName,".");   /* chop off domainname */
d167 2
d170 2
a171 7
	if ( (rmHost = getenv("PRINTHOST")) == NULL ) {
		rmHost = getvstr("PRINTHOST");
		if (rmHost[0] == '0') {
			Cconws("lpr: error: no PRINTHOST in env or default.cnf\r\n");
			return -1;
		}
	}
d182 1
a182 1
int16 connect(char* host)
d194 1
a194 1
		Cconws("lpr: error: unknown host\r\n");
d199 1
a199 1
		Cconws("lpr: error: could not open connection\r\n");
d204 1
a204 3
		Cconws("lpr: error: ");
		Cconws(get_err_text(state));
		Cconws("\r\n");
d221 1
a221 1
	clock_t to = clock() + (clock_t)TIMEOUT * CLK_TCK;	/* time to quit at */
d223 2
a224 3
	while (TRUE) {
		rc = TCP_send(cnId, o_str, o_len);
		if (rc != E_OBUFFULL) break;
d226 1
a226 1
			Cconws("lpr: error: output: send timed out\r\n");
d229 1
d233 1
a233 3
		Cconws("lpr: error: output: ");
		Cconws(get_err_text(rc));
		Cconws("\r\n");
d242 3
a244 1
static int16 get_response(int16 cnId)
d246 1
d249 1
a249 1
	clock_t to = clock() + (clock_t)TIMEOUT * CLK_TCK;	/* time to quit at */
d252 1
a252 3
	while (TRUE) {
		nInQueue = CNbyte_count(cnId);
		if (nInQueue > 0) break;
d254 2
a255 2
			Cconws("lpr: error: get timed out\r\n");
			return 0;
d257 1
d262 2
a263 2
		Cconws("lpr: error: get failed\r\n");
		return 0;
d266 3
a268 3
	return nInQueue;
}

d270 1
d274 1
a274 1
void getSpoolFilePath(char *path)
d291 1
a291 26


/************************************************************************************************/
/************************************************************************************************/

void getSpoolFileName(char *spoolFileName)
{
	long JobNum = ( clock() / CLK_TCK ) % 1000L;

	/* construct spool file name */
	strcpy(spoolFileName, "fA___");
	ltoa(JobNum, spoolFileName+2, 10);
	/* put leading zeros */
	if (spoolFileName[4] == '_') {
		spoolFileName[4] = spoolFileName[3];
		spoolFileName[3] = spoolFileName[2];
		spoolFileName[2] = '0';
	}
	if (spoolFileName[4] == '_') {
		spoolFileName[4] = spoolFileName[3];
		spoolFileName[3] = spoolFileName[2];
		spoolFileName[2] = '0';
	}
	strcat(spoolFileName, hostName);
}

d296 1
d298 2
a299 1
void printfile(
a301 1
	char *spoolFileName,
d305 1
d311 2
d315 1
a315 2
		Cconws("lpr: error: cannot open spool file for read\r\n");
		return;
d327 1
a327 1
	strcat(o_str, rmPrinter);
d331 2
a332 4
	get_response(cnId);

	if (*response != 0x00) {
		Cconws("lpr: error: lp server didn't accept printer\r\n");
d342 1
a342 1
	strcat(fileBuff, hostName);			/* mandatory */
d344 1
a344 1
	strcat(fileBuff, userName);			/* mandatory */
d349 1
a349 1
	if (optSendMail) {
d351 1
a351 1
		strcat(fileBuff, userName);
d355 1
a355 1
	if (!optNoBanner) {
d357 1
a357 1
		strcat(fileBuff, hostName);		/* class for banner */
d359 1
a359 1
		strcat(fileBuff, oriFileName);	/* job name for banner */
d361 1
a361 1
		strcat(fileBuff, userName);		/* banner */
d371 1
a371 1
	if (optNCopies) {
d373 1
a373 1
		strcat(fileBuff, optNCopies);
d377 1
a377 1
	if (optNIndent) {
d379 1
a379 1
		strcat(fileBuff, optNIndent);
d383 1
a383 1
	if (optNWidth) {
d385 1
a385 1
		strcat(fileBuff, optNWidth);
d389 1
a389 1
	if (optTitle) {
d391 1
a391 1
		strcat(fileBuff, optTitle);
d395 2
a396 2
	strcat(fileBuff, optFormat);
	strcat(fileBuff, spoolFileName);
d400 1
a400 1
	Cconws(fileBuff);
d406 1
a406 1
	strcat(o_str, spoolFileName);
d410 7
a416 11
	get_response(cnId);

	if        (*response == 0x01) {
		Cconws("lpr: error: connection messed up, try again\r\n");
		return;
	} else if (*response == 0x02) {
		Cconws("lpr: error: server out of storage space\r\n");
		return;
	} else if (*response != 0x00) {
		Cconws("lpr: error: no ack on sub command 3\r\n");
		return;
d424 2
a425 5
	get_response(cnId);

	if (*response != 0x00) {
		Cconws("lpr: error: control file not properly transferred\r\n");
		return;
d434 1
a434 1
	strcat(o_str, spoolFileName);
d437 1
a437 2
	Cconws(o_str+1);
	Cconws("\r");
d441 7
a447 11
	get_response(cnId);

	if        (*response == 0x01) {
		Cconws("lpr: error: connection messed up, try again\r\n");
		return;
	} else if (*response == 0x02) {
		Cconws("lpr: error: server out of storage space\r\n");
		return;
	} else if (*response != 0x00) {
		Cconws("lpr: error: unknown\r\n");
		return;
a451 1

d466 2
a467 5
	get_response(cnId);

	if (*response != 0x00) {
		Cconws("lpr: error: data file not properly transferred, aborting\r\n");
		return;
d470 1
a470 1
	Cconws("\r\nfile closed\r\n");
d472 1
d474 2
d477 2
@
