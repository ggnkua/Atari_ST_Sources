/* Dr. Thomas Redelberger, Nov 1999 */
/* tcp/ip lpr printer client functions for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpraux.c 1.2 1999/12/30 12:55:34 Thomas Exp Thomas $
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
	static char qn[] = "LP1_QN";
	static char rp[] = "LP1_RP";
	static char rm[] = "LP1_RM";
	static char sd[] = "LP1_SD";

	/* find queue in default.cfg */

	for (i='1'; i<='9'; i++) {
		qn[2] = i;
		q = getvstr(qn);
#if 0
		/* LPn must be ascending with no holes */
		if (q[0] == '0') return -1;					/* nothing found */
#else
		/* LPn need not be ascending */
		if (q[0] == '0') continue;					/* this does not exist */
#endif
		if (strcmp(q, queue) == 0) break;			/* found */
	}

	if (i > '9') return -1;		/* nothing found */

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

static int16 getResponse(int16 cnId)
{
	char *eM;
	int16 nInQueue;
	char  response;
	int16 respLen;
	clock_t tQuit = clock() + TIMEOUT * CLK_TCK;	/* time to quit at */

	/* poll for input */
	while ( (nInQueue = CNbyte_count(cnId)) == 0 || nInQueue == E_NODATA) {
		if (clock() > tQuit) {
	        eM="timed out"; goto errExit;
		}
		uiYield(uiH, YIELDMS);		/* wait till something arrives */
	} 

	if (nInQueue > 0) {
		NDB* ndb;

		if ( (ndb = CNget_NDB(cnId)) != NULL ) {
			response = ndb->ndata[0];
			respLen  = ndb->len;
			KRfree(ndb->ptr); KRfree(ndb);	/* throw ndb away */
			if (respLen == 1) {		/* expect a one byte response */
				return response;	/* return it */
			} else {				/* this should never happen */
				eM="prot.mismatch";
			}

		} else {
	        eM="get_NDB";
		}	/* if..get_NDB successful */

	} else {
		eM=get_err_text(nInQueue);
	}	/* if..something in Queue */


errExit:
	uiPrintf(uiH, uiPrERR, "getResponse|%s", eM);
	return -1;
}	/* getResponse */

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
