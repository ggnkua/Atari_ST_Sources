head	1.2;
access;
symbols
	TRLPR11B:1.2
	RAalpha:1.1;
locks
	Thomas:1.2; strict;
comment	@ * @;


1.2
date	99.12.30.12.55.34;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.11.28.15.23.10;	author Thomas;	state Exp;
branches;
next	;


desc
@Line printer spooler daemon
@


1.2
log
@Version to use DEFAULT.CFG instead of printcap
@
text
@/* Dr. Thomas Redelberger, Noc 1999 */
/* tcp/ip lpd printer server fo Atari ST computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpd.c 1.1 1999/11/28 15:23:10 Thomas Exp Thomas $
*/

#include <stdlib.h>
#include <string.h>
#include <time.h>		/* clock(), CLK_TCK */
#include <ctype.h>		/* tolower */
#include <tos.h>
#include <portab.h>
#include <aes.h>		/* evnt_multi */
#define AP_TERM	50		/* MagiC shutdown */

#include "transprt.h"		/* access to STinG */
#include "lprui.h"			/* user interface */

#define TIMEOUT	10			/* TCP timeout seconds */

/* other function declarations */

extern int link2Sting(void);			/* LNK2STNG.C */



/************************************************************************************************/
/************************************************************************************************/

static char* spoolDir = ".\\";
static char* prDevice = "PRN:";






/************************************************************************************************/
/************************************************************************************************/

static int lookupQueue(char *queue)
{
	char i;
	char *p, *q;
	static char qn[] = "LPA_QN";
/*	static char rp[] = "LPA_RP";*/
/*	static char rm[] = "LPA_RM";*/
	static char lp[] = "LPA_LP";
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

	sd[2] = lp[2] = i;	/* set to entry found */

	/* MUST have a device */
	p = getvstr(lp);
	if (p[0] != '0' && p[0] != '1')
		prDevice = p;			/* yes */
	else
		return -1;

	/* MUST have a spool directory */
	p = getvstr(sd);
	if (p[0] != '0' && p[0] != '1')
		spoolDir = p;		/* yes */
	else
		return -1;

	return 0;
}	/* lookupQueue */



#define YIELDMS			100

/************************************************************************************************/
/************************************************************************************************/

static void output(int16 cnId, char *oStr, int oLen)
{
	int16 rc;
	clock_t tQuit = clock() + TIMEOUT * CLK_TCK;	/* time to quit at */

	while ( (rc = TCP_send(cnId, oStr, oLen)) == E_OBUFFULL ) {
		if (clock() > tQuit) {
	        uiPrintf(uiH, uiPrERR, "output timed out");
			return;
		}
		uiYield(uiH, YIELDMS);
	} 

	if (rc != E_NORMAL) {
        uiPrintf(uiH, uiPrERR, "output|%s", get_err_text(rc));
	}

}	/* end output */



/************************************************************************************************/
/************************************************************************************************/

static void dumpFile(int16 cnId, char fileNam[], long fileLen)
{
	int eFlag;
	char *eM;
	long accuLen;
	int fh;
	int16 nInQueue;
	clock_t tQuit = clock() + 5 * CLK_TCK;	/* time to quit at */

#if 0
uiPrintf(uiH, "   %s|L: %ld|N: %s", pCnt, fileLen, fileNam);
#endif
	if ( (fh=Fcreate(fileNam, 0)) < 0 ) {
		uiPrintf(uiH, uiPrERR, "dumpFile|cannot create file");
		return;
	}


	for (eFlag=1,accuLen=0; eFlag; ) {

		while ( (nInQueue = CNbyte_count(cnId)) == 0 || nInQueue == E_NODATA) {
			if (clock() > tQuit) {
		        eM="timed out"; goto errExit;
			}
			uiYield(uiH, YIELDMS);		/* wait till something arrives */
		} 
	
	
		if (nInQueue > 0) {
			NDB* ndb;
	
			if ( (ndb = CNget_NDB(cnId)) != NULL ) {
				accuLen += ndb->len;
#if 0
uiPrintf(uiH, "al: %ld", accuLen);
#endif
				if (accuLen == fileLen+1) {		/* this happens at the end */
					if (Fwrite(fh, ndb->len-1, ndb->ndata) <0) {
						eM="cannot write 1"; goto errExit;
					}
					if (ndb->ndata[ndb->len-1] != '\0') {
						eM="trailing 0 ?"; goto errExit;
					}
					eFlag=0;						/* normal end */
				} else {
					if (accuLen > fileLen+1) {	/* this should never happen */
						eM="prot.mismatch"; goto errExit;
					} else {
						if (Fwrite(fh, ndb->len, ndb->ndata) <0) {
							eM="cannot write 2"; goto errExit;
						}
					}
				}
				KRfree(ndb->ptr); KRfree(ndb);	/* throw ndb away */

			} else {
		        eM="get_NDB"; goto errExit;
			}	/* if..get_NDB successful */

		} else {
			eM=get_err_text(nInQueue); goto errExit;
		}	/* if..something in Queue */

	}	/* while..more blocks to read */


	Fclose(fh);
	return;

errExit:
	uiPrintf(uiH, uiPrERR, "dumpFile|%s", eM);
	Fclose(fh);
}	/* dumpFile */



/************************************************************************************************/
/************************************************************************************************/

static void printFile(char *fileNam)
{
	int fi, fo;
#define NBUFF 80
	char buff[NBUFF];
	long len;
	
	fileNam[0] = 'd';			/* force data file */

	if ( (fi=Fopen(fileNam, FO_READ)) >= 0 ) {
		/* Fopen may return < 0 for devices like PRN: ! */
		if ( (fo=Fopen(prDevice, FO_WRITE)) > -31) {
	
			while ( (len=Fread(fi, NBUFF, buff)) > 0)
				Fwrite(fo, len, buff);
	
			Fclose(fo);
		} else {
	        uiPrintf(uiH, uiPrERR, "cannot open device|>%s<", prDevice);
		}
		Fclose(fi);
	} else {
        uiPrintf(uiH, uiPrERR, "cannot open dFile");
	}

	Fdelete(fileNam);
	fileNam[0] = 'c';			/* force control file */
	Fdelete(fileNam);
}	

	

/************************************************************************************************/
/************************************************************************************************/

static void dispatchSubCmd(int16 cnId, NDB *ndb)
{
	char *pCnt;
	char *pNam;
	char fileNam[9];
	long fileLen;
	char cmd;
	static int havCnt, havDat;

	cmd = ndb->ndata[0];	/* get copies because we are going to throw ndb away */
	pCnt = strtok(ndb->ndata+1, " ");
	pNam = strtok(NULL, "\n");
	strncpy(fileNam, pNam, 8);
	fileNam[8] = '\0';
	fileLen = atol(pCnt);		/* get file length */

	KRfree(ndb->ptr); KRfree(ndb);	/* not needed any more */

	switch (cmd) {
	case '\1':		/* Abort jobs */
		output(cnId, "\1", 1);	/* unimplemented */
		break;

	case '\2':		/* Receive control file */
		output(cnId, "\0", 1);	/* acknowledge */
		dumpFile(cnId, fileNam, fileLen);
		output(cnId, "\0", 1);	/* success */
		havCnt=1;
		if (havDat) {
			printFile(fileNam);
			havDat=0;
			havCnt=0;
		}
		break;

	case '\3':		/* Receive data file */
		output(cnId, "\0", 1);	/* acknowledge */
		dumpFile(cnId, fileNam, fileLen);
		output(cnId, "\0", 1);	/* success */
		havDat=1;
		if (havCnt) {
			printFile(fileNam);
			havDat=0;
			havCnt=0;
		}
		break;

	default:
		output(cnId, "\1", 1);		/* error */
        uiPrintf(uiH, uiPrERR, "dispatchSubCmd|funny deamon rec subcmd");
		break;
	}


}	/* dispatchSubCmd */



/************************************************************************************************/
/* 																								*/
/************************************************************************************************/

static void recvJob(int16 cnId)
{
	int16 nInQueue;
	clock_t tQuit;

	while (1) {		/* loop over subcommands */

		tQuit = clock() + TIMEOUT * CLK_TCK;	/* time to quit at */
		while ( (nInQueue = CNbyte_count(cnId)) == 0 || nInQueue == E_NODATA) {
			if (clock() > tQuit) {
		        uiPrintf(uiH, uiPrERR, "rcvJob|timed out");
				return;
			}
			uiYield(uiH, YIELDMS);		/* wait till something arrives */
		} 

		if (nInQueue == E_EOF)
			return;						/* connection closed, no more subcommands */
	
		if (nInQueue > 0) {
			NDB* ndb;
			if ( (ndb = CNget_NDB(cnId)) != NULL ) {
				dispatchSubCmd(cnId, ndb);
			} else {
		        uiPrintf(uiH, uiPrERR, "recvJob|get_NDB");
			}

		} else {
			uiPrintf(uiH, uiPrERR, "recvJob|%s", get_err_text(nInQueue));
			return;
		}

	}	/* while..more subcommands */

}	/* recvJob */



/************************************************************************************************/
/* 																								*/
/************************************************************************************************/

static void setSpoolPath(void)
{
	if (spoolDir) {
		if (spoolDir[0] != '\0'
		&&  spoolDir[1] == ':') {	/* drive spec? */
			Dsetdrv(tolower(spoolDir[0]) - 'a');
		}
	
		if (Dsetpath(spoolDir) < 0) {
	        uiPrintf(uiH, uiPrERR, "set path|>%s<", spoolDir);
		}
	}


}	/* setSpoolPath */


/************************************************************************************************/
/* 																								*/
/************************************************************************************************/

static void dispatchD(int16 cnId, NDB* ndb)
{
	strtok(ndb->ndata, "\n");	/* LF to '\0' */

	switch (ndb->ndata[0]) {
	case '\1':		/* Print any waiting jobs */
		KRfree(ndb->ptr); KRfree(ndb);
		break;		/* unimplemented */

	case '\2': {		/* Receive a printer job */
			/* look for this printer in default.cfg */
			int rc = lookupQueue(ndb->ndata+1);
			KRfree(ndb->ptr); KRfree(ndb);	/* must be done exactly here! */
			if (rc==0) {
				output(cnId, "\0", 1);	/* know this printer */
				setSpoolPath();
				recvJob(cnId);
			} else {
				output(cnId, "\1", 1);	/* unknown */
			}
		}
		break;

	case '\3':		/* Send queue state (short) */
		KRfree(ndb->ptr); KRfree(ndb);
		break;		/* unimplemented */

	case '\4':		/* Send queue state (long) */
		KRfree(ndb->ptr); KRfree(ndb);
		break;		/* unimplemented */

	case '\5':		/* Remove jobs */
		KRfree(ndb->ptr); KRfree(ndb);
		break;		/* unimplemented */

	default:
		KRfree(ndb->ptr); KRfree(ndb);
        uiPrintf(uiH, uiPrERR, "dispatchD|funny daemon cmd");
		break;
	}

}	/* end of dispatchD */



/************************************************************************************************/
/* 																								*/
/************************************************************************************************/

#define LPR_LOC_PORT	515		/* local port used by lp daemon */

static int tcpBuffSize = 1000;

static void waitRequests(void)
{
	int16 cnId, state;
	int16 nInQueue;
	int toggle, proceed=1;


	do {				/* listen again */
		if( (cnId = TCP_open(0, LPR_LOC_PORT, 0, tcpBuffSize)) <= 0 ) {
			uiPrintf(uiH, uiPrERR, "waitRequests|TCP_open");
			return;
		}
	
	    if ( (state = TCP_wait_state(cnId, TLISTEN, 30)) < 0 ) {
	        uiPrintf(uiH, uiPrERR, "waitRequests|%s", get_err_text(state));
			return;
	    }
	
	
		toggle = 10;	/* every ten waits look also for an AES message */
		while ( (nInQueue = CNbyte_count(cnId)) != E_EOF ) {	/* poll for input */
	
			/* listening or no data yet cause us to wait */
			if (nInQueue == E_LISTEN || nInQueue == 0 || nInQueue == E_NODATA) {
				if (--toggle>0) {
					uiYield(uiH, YIELDMS);
				} else {
					WORD	msgbuff[8];
					WORD	event;		/* Ergebnis mit Ereignissen */
					WORD	mx, my,		/* Mauskoordinaten */
							mbutton, 	/* Mausknopf */
							mkstate,	/* keyb shift status for mouse button */
							mclicks; 	/* Anzahl Mausklicks */
					UWORD	keycode; 	/* scancode + asciicode */

					toggle=10;
					event = evnt_multi(
						MU_MESAG | MU_TIMER,
						0, 0, 0,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						msgbuff,
					  	YIELDMS, 0,
						&mx, &my,
						&mbutton, &mkstate,
						&keycode, &mclicks);

					if ( (event & MU_MESAG) && msgbuff[0] == AP_TERM ) {
						proceed=0;		/* no more new connections */
						break;			/* end listening */
					}
				}

			} else {

				if (nInQueue > 0) {			/* otherwise there is valid data */
					NDB* ndb;
		
					if ( (ndb = CNget_NDB(cnId)) != NULL ) {
						dispatchD(cnId, ndb);
					} else {
				        uiPrintf(uiH, uiPrERR, "waitRequests|get_NDB");
						break;
					}
		
				} else {					/* catch other errors */
					uiPrintf(uiH, uiPrERR, "waitRequests|%s", get_err_text(nInQueue));
					break;
				}	/* if valid data */

			}	/* if any data */
	
		}	/* while wait for a request */
	
	
		TCP_close(cnId, TIMEOUT, NULL);	/* disconnect */

	} while (proceed);	/* while new connection shall be done */


}	/* waitRequests */



/************************************************************************************************/
/* 																								*/
/************************************************************************************************/

main(void)
{
	if ( (uiH = uiOpen("LPD")) == NULL) return -1;

	if (link2Sting() != 0) {
		uiPrintf(uiH, uiPrERR, "cannot access STinG");
		goto errExit;
	}

	waitRequests();



errExit:
	uiClose(uiH);
	return 0;
}	/* end of main */
@


1.1
log
@Initial revision
@
text
@d5 1
a5 1
$Id$
d10 2
a11 4
#include <stdarg.h>		/* vsprintf */
#include <stdio.h>		/* vsprintf */
#include <time.h>
#include <ctype.h>
d14 2
a15 2
#include <aes.h>
#define AP_TERM	50
d17 2
a18 1
#include "transprt.h"
d20 1
a20 1
#define TIMEOUT	10	/* seconds */
d22 1
d24 1
d26 2
d31 2
a32 3
void diagPrintf(char *format, ...)
{
	char buff[100];
a33 1
	va_list arglist;
a34 3
	va_start(arglist, format);
	vsprintf(buff, format, arglist);
	va_end(arglist);
a35 2
	form_alert(1, buff);
}
d42 1
a42 1
static long get_sting_cookie (void)
d44 7
a50 1
	long  *p;
d52 1
a52 3
	for (p = * (long **) 0x5a0L; *p ; p += 2)
		if (*p == 'STiK')
			return *++p;
d54 12
a65 2
	return 0L;
}
d67 1
d69 1
a69 1
TPL *tpl = NULL;
d71 5
a75 8
static int initSting(void)
{
	DRV_LIST *sting_drivers;

	if ( (sting_drivers = (DRV_LIST*) Supexec(get_sting_cookie)) == NULL )
		return -1;

	if (strcmp (sting_drivers->magic, MAGIC) != 0)
d78 5
a82 1
	if ( (tpl = (TPL*) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER)) == NULL)
a84 86
	return 0;	/* OK */
}



/************************************************************************************************/
/************************************************************************************************/

#define MAXNPR	5
static char* prName[MAXNPR];
static char* spoolDir[MAXNPR];
static char* prDevice[MAXNPR];
static int npr;


static void fixColon(char *s)
{
	while (*s != '\0') {
		if (*s == ';') *s = ':';
		s++;
	}
}



/************************************************************************************************/
/************************************************************************************************/

static int getPrintcap(void)
{
	char buff[100];
	int fh;
	int n;
	int last=0;

	if ( (fh=Fopen("printcap", FO_READ)) < 0 ) return -1;


	/* for each line */
	for (npr=0; npr<MAXNPR && !last; ) {
		char *p;

		/* read one line including CRLF */
		buff[0] = '\0';

		for (n=0; n<99; ) {
			char c;
			if ( Fread(fh, 1, &c) < 1 ) {
				last = 1;
				break;
			}
			if (c == '\r') continue;
			if (c == '\n') break;
			buff[n] = c;
			n++;
			buff[n] = '\0';		/* put terminator */
		}	/* for each char in line */

		if (buff[0] == '\0' || buff[0] == '#' ) continue;

		/* look for printer name, we must have something */
		if ( (p=strtok(buff, ":")) == NULL) goto errExit;

		if ( (prName[npr]=KRmalloc(strlen(p)+1))  == NULL ) goto errExit;
		strcpy(prName[npr], p);

		while ( (p=strtok(NULL, ":")) != NULL ) {
			if (strncmp(p, "sd=", 3) == 0) {
				if ( (spoolDir[npr]=KRmalloc(strlen(p+3)+1)) == NULL ) goto errExit;
				strcpy(spoolDir[npr], p+3);
				fixColon(spoolDir[npr]);
			}
			if (strncmp(p, "lp=", 3) == 0) {
				if ( (prDevice[npr]=KRmalloc(strlen(p+3)+1)) == NULL ) goto errExit;
				strcpy(prDevice[npr], p+3);
				fixColon(prDevice[npr]);
			}
		}	/* for each token in line */

diagPrintf ("[1][%s|%s|%s][OK]", prName[npr], spoolDir[npr], prDevice[npr]);

		 npr++;
	}	/* for each line */


	Fclose(fh);
d86 1
a86 5

errExit:
	Fclose(fh);
	return -1;
}
d102 1
a102 1
	        diagPrintf ("[3][LPD error:|output timed out][OK]");
d105 1
a105 1
		evnt_timer(YIELDMS, 0);
d109 1
a109 1
        diagPrintf ("[3][LPD error:|output|%s][OK]", get_err_text(rc));
d129 1
a129 1
diagPrintf ("[1][   %s|L: %ld|N: %s][OK]", pCnt, fileLen, fileNam);
d132 1
a132 1
		diagPrintf ("[3][LPD error:|dumpFile|cannot create file][OK]");
d143 1
a143 1
			evnt_timer(YIELDMS, 0);		/* wait till something arrives */
d153 1
a153 1
diagPrintf ("[1][al: %ld][OK]", accuLen);
d172 1
a172 2
				KRfree(ndb->ptr);	/* throw ndb away */
				KRfree(ndb);
d189 1
a189 1
	diagPrintf ("[3][LPD error:|dumpFile|%s][OK]", eM);
d191 1
a191 1
}
d198 1
a198 1
void printFile(char *fileNam, int ipr)
d208 2
a209 1
		if ( (fo=Fopen(prDevice[ipr], FO_WRITE)) >= 0) {
d216 1
a216 1
	        diagPrintf ("[3][LPD error:|open device|%s][OK]", prDevice[ipr]);
d220 1
a220 1
        diagPrintf ("[3][LPD error:|open dFile][OK]");
d233 1
a233 1
static void dispatchSubCmd(int16 cnId, NDB *ndb, int ipr)
d262 1
a262 1
			printFile(fileNam, ipr);
d274 1
a274 1
			printFile(fileNam, ipr);
d282 1
a282 1
        diagPrintf ("[3][LPD error:|dispatchSubCmd|funny deamon rec subcmd][OK]");
d287 1
a287 1
}
d295 1
a295 1
void recvJob(int16 cnId, int ipr)
d305 1
a305 1
		        diagPrintf ("[3][LPD error:|rcvJob|timed out][OK]");
d308 1
a308 1
			evnt_timer(YIELDMS, 0);		/* wait till something arrives */
d314 1
a314 4
		if (nInQueue < 0) {
			diagPrintf ("[3][LPD error:|recvJob|%s][OK]", get_err_text(nInQueue));
			return;
		} else {
a315 1
	
d317 1
a317 1
				dispatchSubCmd(cnId, ndb, ipr);
d319 1
a319 1
		        diagPrintf ("[3][LPD error:|recvJob|get_NDB][OK]");
d321 4
d329 1
a329 1
}
a335 1
#define MAXNPATH 200
d337 1
a337 1
void setSpoolPath(int ipr)
d339 4
a342 4
	if (spoolDir[ipr]) {
		if (spoolDir[ipr][0] != '\0'
		&&  spoolDir[ipr][1] == ':') {	/* drive spec? */
			Dsetdrv(tolower(spoolDir[ipr][0]) - 'a');
d345 2
a346 2
		if (Dsetpath(spoolDir[ipr]) < 0) {
	        diagPrintf ("[3][LPD error:|set path|%s][OK]", spoolDir[ipr]);
d351 1
a351 1
}
d358 1
a358 1
void dispatchD(int16 cnId, NDB* ndb)
a359 2
	int ipr;

d367 11
a377 13
	case '\2':		/* Receive a printer job */
		/* look for this printer in printcap */
		for (ipr=0; ipr<npr; ipr++)
			if (strcmp(ndb->ndata+1, prName[ipr]) == 0)
				break;

		KRfree(ndb->ptr); KRfree(ndb);
		if (ipr<npr) {
			output(cnId, "\0", 1);	/* know this printer */
			setSpoolPath(ipr);
			recvJob(cnId, ipr);
		} else {
			output(cnId, "\1", 1);	/* unknown */
d395 1
a395 1
        diagPrintf ("[3][Error: dispatchD|funny deamon cmd][OK]");
d420 1
a420 1
			diagPrintf ("[3][Error: could not open data connection][OK]");
d425 1
a425 1
	        diagPrintf ("[3][Error:|%s][OK]", get_err_text(state));
d430 1
a430 1
		toggle = 10;
d436 1
a436 1
					evnt_timer(YIELDMS, 0);
d459 2
a460 2
						proceed=0;
						goto endRequest;
d464 16
a479 2
				continue;
			}
d481 1
a481 9
			if (nInQueue > 0) {			/* otherwise there is valid data */
				NDB* ndb;
	
				if ( (ndb = CNget_NDB(cnId)) != NULL ) {
					dispatchD(cnId, ndb);
				} else {
			        diagPrintf ("[3][Error: get_NDB][OK]");
					goto endRequest;
				}
d483 1
a483 4
			} else {					/* catch other errors */
				diagPrintf ("[3][Error:|%s][OK]", get_err_text(nInQueue));
				goto endRequest;
			}	/* if valid data */
a484 1
		}	/* forever */
a485 2
	
endRequest:
d487 2
a488 1
	} while (proceed);	/* while next connection */
d495 4
d501 1
a501 6
	if (appl_init() < 0) return -1;

	if (initSting() <0) {
		form_alert(1, "[3][Error: could not|access STinG][OK]");
		goto errExit;
	}
d503 2
a504 3

	if (getPrintcap() <0) {
		form_alert(1, "[3][Error: printcap|file not present| or corrupt][OK]");
a507 1

d513 1
a513 1
	appl_exit();
d515 1
a515 1
}
@
