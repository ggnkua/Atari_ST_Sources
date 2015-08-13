/* Dr. Thomas Redelberger, Noc 1999 */
/* tcp/ip lpd printer server fo Atari ST computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpd.c 1.2 1999/12/30 12:55:34 Thomas Exp Thomas $
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

#define NULL		( ( void * ) 0L )
#define TIMEOUT	10			/* TCP timeout seconds */
#define LTIMEOUT	30

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
	static char qn[] = "LP1_QN";
/*	static char rp[] = "LP1_RP";*/
/*	static char rm[] = "LP1_RM";*/
	static char lp[] = "LP1_LP";
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
	clock_t tQuit;

#if 0
uiPrintf(uiH, "   %s|L: %ld|N: %s", pCnt, fileLen, fileNam);
#endif
	if ( (fh=Fcreate(fileNam, 0)) < 0 ) {
		uiPrintf(uiH, uiPrERR, "dumpFile|cannot create file");
		return;
	}


	for (eFlag=1,accuLen=0; eFlag; ) {
		tQuit = clock() + LTIMEOUT * CLK_TCK;	/* time to quit at */

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
#define NBUFF 256
	char buff[NBUFF];
	long len;
	
	fileNam[0] = 'd';			/* force data file */

	if ( (fi=Fopen(fileNam, FO_READ)) >= 0 ) {
		if ( (fo=Fcreate(prDevice, 0)) < 0)
			fo=Fopen(prDevice, FO_WRITE);
		/* Fopen may return < 0 for devices like PRN: ! */
		if ( fo > -31) {
	
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
