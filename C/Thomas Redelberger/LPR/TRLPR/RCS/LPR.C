head	1.4;
access;
symbols
	TRLPR11B:1.4
	TRLPR10B:1.3
	TRLPR09B:1.1;
locks
	Thomas:1.4; strict;
comment	@ * @;


1.4
date	99.12.30.12.55.34;	author Thomas;	state Exp;
branches;
next	1.3;

1.3
date	99.11.13.17.07.30;	author Thomas;	state Exp;
branches;
next	1.2;

1.2
date	99.11.06.19.01.08;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.03.08.21.19.36;	author Thomas;	state Exp;
branches;
next	;


desc
@Source code for lpr.ttp
@


1.4
log
@Version to use DEFAULT.CFG instead of printcap
@
text
@/* Dr. Thomas Redelberger, Oct 1998 */
/* tcp/ip lpr printer client for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpr.c 1.3 1999/11/13 17:07:30 Thomas Exp Thomas $
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#include "transprt.h"		/* access to STinG */
#include "lpraux.h"			/* my lpr functions */
#include "lprui.h"			/* user interface */

#define TIMEOUT	10	/* seconds */


/* other function declarations */

extern int link2Sting(void);			/* LNK2STNG.C */



#ifdef METER
/************************************************************************************************/
/************************************************************************************************/

/* do not moarn unused parameters */
#pragma warn -par

static void printPercent(long fileLength, long accumLength, long actLength)
{
		uiPrintf(uiH, uiPrOK, "\r%3ld %%  ",(accumLength * 100) / fileLength);
}

#pragma warn +par
#endif


/************************************************************************************************/
/************************************************************************************************/

main(int argc, char *argv[])
{
	JOBDEF	jd;
	int		fin;
	char	spoolFileFullName[256];
	int		doSTDIN = FALSE;
	int		i, iFirstFile;

	/* open user interface */
	if ( (uiH = uiOpen("LPR")) == NULL) return -1;

	/* find STinG cookie and initialize tpl (in LNK2STNG.C) */
	if (link2Sting() != 0) {
		uiPrintf( uiH, uiPrERR, "cannot link to STinG");
		goto errExit;
	}

	/* clear and initialize jobdef object */
	if (lprInit(&jd) != 0) {
		uiPrintf( uiH, uiPrERR, "cannot init lpr");
		goto errExit;
	}


	lprLookupQueue(&jd, "lp");		/* lp is default queue */

	/* scan cmdline for options */

	for (i=1, iFirstFile=1; i<argc; i++) {

		if (argv[i][0] == '-') {
			char opt = argv[i][1];
			iFirstFile = i+1;		/* skip this element of argv */

			switch (opt) {
			char *arg;
			case '\0':	/* just a '-' ignore it */
				break;

			/* options to be forwarded to lpd without following argument */
				/* filtering or formatting; all are mutually exclusive */
				/* largely historic */
			case 'c':	/* cifplot, sometimes to indicate landscape mode */
			case 'd':	/* TeX DVI */
			case 'f':	/* FORTRAN carrige control*/
			case 'g':	/* raw data, was plot */
			case 'l':	/* raw data */
			case 'n':	/* ditroff, sometimes to indicate two columns */
			case 'o':	/* postcript ??? */
			case 'p':	/* postcript */
			case 'v':	/* formatted ISO 8859 Latin1, was raster */
			case 't':	/* troff */
				jd.optFormat[0] = opt;
				break;

				/* other options; may be present in addition*/
			case 'h':	/* no banner */
				jd.optNoBanner=TRUE;
				break;

			case 'm':	/* send mail */
				jd.optSendMail=TRUE;
				break;

			case 'r':	/* remove the file */
			case 's':	/* link to the file instead of copy */
				uiPrintf(uiH, uiPrWARN, "option >%c< not supported", opt);
				break;


			/* options with following argument */
			case 'P':	/* name of remote printer */
			case '#':	/* # of copies */
			case 'i':	/* # columns to indent */
			case 'w':	/* line width */
			case 'T':	/* title */
				if (argv[i][2] != '\0')	{	/* argument is not separated by white space */
					arg = argv[i]+2;
				} else {
					i++;				/* step to next arg */
					iFirstFile = i+1;	/* skip this element of argv */
					arg = argv[i];
				}
				/* discern */
				switch (opt) {
				case 'P':	/* arg is queue name (local or remote) */
					if (lprLookupQueue(&jd, arg) != 0) {
						uiPrintf( uiH, uiPrERR, "unknown queue >%s<", arg);
						goto errExit;
					}
					break;

				case '#':	/* # of copies */
					jd.optNCopies = arg;
					break;

				case 'i':	/* # columns to indent */
					jd.optNIndent = arg;
					break;

				case 'w':	/* line width */
					jd.optNWidth = arg;
					break;

				case 'T':	/* title */
					jd.optTitle = arg;
					break;

				}	/* switch option with argument */

				break;

				default:
					uiPrintf(uiH, uiPrWARN, "option >%c< ignored", opt);

			}	/* switch letter after '-' */

		}	/* if '-' */

	}	/* for all arguments */


/* spoolfile is only used if input is stdin */
	strcpy(spoolFileFullName, jd.spoolDir);
	/* make shure drectory ends with a slash */
	if (spoolFileFullName[strlen(spoolFileFullName)-1] != '\\')
		strcat(spoolFileFullName, "\\");

	strcat(spoolFileFullName, jd.spoolFile);

	/* scan rest of cmdline for files to print */

	if (iFirstFile == argc) {	/* no files given? */
		int c;
		doSTDIN = TRUE;

		/* read from stdin and copy to temporary file */
		if ( (fin = Fcreate(spoolFileFullName, 0)) <0 ) {
			uiPrintf(uiH, uiPrERR, "cannot create spoolfile");
			goto errExit;
		}

		while ( (c=fgetc(stdin)) != EOF ) {
			char t = c;
			if (Fwrite(fin, 1, &t) != 1) {
				uiPrintf(uiH, uiPrERR, "cannot write to spoolfile");
				goto errExit;
			}
		}	/* while more chars in stdin */

		Fclose(fin);

	}	/* if iFirstfile == argc */


	/* do all files mentioned on cmd line */

	for (i=iFirstFile; i<argc || doSTDIN; i++) {
		int16 cnId;
#ifdef DEBUG
		uiPrintf(uiH, uiPrOK, "connecting to print server %s|device %s|file %s",
			jd.rmHost, jd.rmPrinter, jd.spoolFile);
#endif
		/* for each file a new connection */
		if( (cnId = lprConnect(jd.rmHost)) > 0 ) {
			lprPrintfile(
				&jd,
				doSTDIN ? "unknown"			: argv[i],
				doSTDIN ? spoolFileFullName	: argv[i],
				cnId,
#ifdef METER
				printPercent);
#else
				(void (*)(long, long, long)) 0L);
#endif
			TCP_close(cnId, TIMEOUT, NULL);	/* = disconnect */
		} else {
			break;	/* exit loop 'for each file' */
		}

		doSTDIN = FALSE;	/* make shure loop does only one iteration */
	}	/* for each file */



errExit:
	uiClose(uiH);			/* close user interface */
	return 0 ;
}
@


1.3
log
@stripped down, uses lpraux
@
text
@d5 1
a5 1
$Id: lpr.c 1.2 1999/11/06 19:01:08 Thomas Exp Thomas $
d13 3
a15 2
#include "lpraux.h"
#include "transprt.h"
d20 1
a20 1
int initialise(void);	/* from LNK2DRV.C */
d22 1
d26 1
d30 3
d35 1
a35 4
		printf("\r%3ld %%  ",(accumLength * 100) / fileLength);
		if (accumLength+actLength == fileLength)
			printf("\n===\n");
		fflush(stdout);
d38 3
d47 13
a59 11
	int fin;
	char  spoolFileFullName[256];
	char *spoolFileName;
	int doSTDIN = FALSE;
	int i, iFirstFile;
	int error;

	if ( !initialise() ) {
		fprintf(stderr, "press any key\n");
		getchar();
		return 0;
d62 4
a65 4
	if ( !initLpr() ) {
		fprintf(stderr, "press any key\n");
		getchar();
		return 0;
d68 3
d81 1
a81 1
			case '\0':	/* just a - ignore it */
d84 2
a85 2
			/* options to be handed to lpd without following argument */
				/* filtering or formatting; mutually exclusive */
d97 1
a97 1
				optFormat[0] = opt;
d100 1
a100 1
				/* other; in addition*/
d102 1
a102 1
				optNoBanner=TRUE;
d106 1
a106 1
				optSendMail=TRUE;
d111 1
a111 1
				fprintf(stderr, "lpr: option >%c< not supported\n", opt);
d130 5
a134 2
				case 'P':	/* name of remote printer */
					rmPrinter = arg;
d138 1
a138 1
					optNCopies = arg;
d142 1
a142 1
					optNIndent = arg;
d146 1
a146 1
					optNWidth = arg;
d150 1
a150 1
					optTitle = arg;
d153 1
a153 1
				}	/* switch opt */
d158 1
a158 1
					fprintf(stderr, "lpr: option >%c< ignored\n", opt);
d160 1
a160 1
			}	/* switch letter after - */
d162 1
a162 1
		}	/* if - */
d167 7
a173 3
	getSpoolFilePath(spoolFileFullName);
	spoolFileName  = spoolFileFullName+strlen(spoolFileFullName);
	getSpoolFileName(spoolFileName);
a180 1
		spoolFileName[8] = '\0';	/* sorry, no more than eight chars */
d183 2
a184 2
			fprintf(stderr, "lpr: error: can't create tmpfile, aborting\n");
			return -1;
d190 2
a191 2
				fprintf(stderr, "lpr: error: can't write to tmpfile, aborting\n");
				return -1;
d200 2
a201 1
	error = 0;
d204 8
a211 6

		printf("lpr: connecting to print server %s, device %s, file %s\n",
			rmHost, rmPrinter, spoolFileName);

		if( (cnId = connect(rmHost)) > 0 ) {
			printfile(
d214 7
a220 2
				spoolFileName, cnId, printPercent); 
			TCP_close(cnId, TIMEOUT);	/* = disconnect */
a221 1
			error++;
d230 2
a231 6
	if(error) {
		fprintf(stderr, "press any key\n");
		getchar();
		return -1;
	}

@


1.2
log
@Corrected bug in control file, works with Linux now
@
text
@d5 1
a5 1
$Id$
a10 1
#include <time.h>
d13 1
a15 69
int initialise(void);	/* from LNK2DRV.C */



#define min(a,b) (((a) < (b)) ? (a) : (b))
#define RESPONSESIZE	1024
#define FILEBUFFSIZE	1000


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
char optFormat = 'l';		/* defaults to binary */
char* rmHost;
char* userName;
char* hostName;
long number;
static int error;


#define LPR_REM_PORT	515		/* remote port used by lp daemon */
#define LPR_LOC_PORT	721		/* to 731 inclusive used by this client */



/************************************************************************************************/
/* open a connection and return tcp connection handle, 0 if error				*/
/************************************************************************************************/

int16 connect(char* host)
{
	CAB cab;
	int16 tcpHndl, state;

/* remote and local port numbers for lpr connection */

	cab.rport = LPR_REM_PORT;
	cab.lport = LPR_LOC_PORT+(int)(Random() % 10);
	cab.lhost = 0;

	if (resolve(host, NULL, &(cab.rhost), 1) < 1) {
		fprintf(stderr, "lpr: error: unknown host\n");
		return 0;
	}

	if( (tcpHndl = TCP_open((uint32)&cab, TCP_ACTIVE, 0, tcpBuffSize)) <= 0 ) {
		fprintf(stderr, "lpr: error: could not open connection\n");
		return 0;
	}

    if ( (state = TCP_wait_state(tcpHndl, TESTABLISH, 30)) < 0 ) {
        fprintf(stderr, "lpr: error: %s\n", get_err_text(state));
		return 0;
    }

	return tcpHndl;
}



a17 2
/************************************************************************************************/
/************************************************************************************************/
d19 1
a19 4
void output(int16 cnId, char *o_str, int o_len)
{
	int16 rc;
	clock_t to = clock() + (clock_t)TIMEOUT * CLK_TCK;	/* time to quit at */
a20 12
	while (TRUE) {
		rc = TCP_send(cnId, o_str, o_len);
		if (rc != E_OBUFFULL) break;
		if (clock() > to) {
			fprintf(stderr, "lpr: error: output: send timed out\n");
			return;
		}
	} 

	if (rc != E_NORMAL) {
		fprintf(stderr, "lpr: error: output: %s\n", get_err_text(rc));
	}
a21 1
}	/* end output */
d27 1
a27 1
int16 get_response(int16 cnId)
d29 4
a32 21
	int16 nInQueue;
	int16 rc;
	clock_t to = clock() + (clock_t)TIMEOUT * CLK_TCK;	/* time to quit at */

	/* poll for input */
	while (TRUE) {
		nInQueue = CNbyte_count(cnId);
		if (nInQueue > 0) break;
		if (clock() > to) {
			fprintf(stderr, "lpr: error: get timed out\n");
			return 0;
		}
	} 

	rc = CNget_block(cnId, response, min(nInQueue, RESPONSESIZE) );
	if (rc != min(nInQueue, RESPONSESIZE)) {
		fprintf(stderr, "lpr: error: get failed\n");
		return 0;
	}

	return nInQueue;
a38 155
void printfile(char* oriFileName, FILE *fin, int16 cnId)
{
	long fileLength;
	long lenData = 0;
	long lenSent = 0;    
	char spoolFileName[50];
	char o_str[100];


	fseek(fin, 0L,SEEK_END);
	fileLength = ftell(fin);
	fseek(fin, 0L, 0);

	/* start the lprd protocol for this file */

/* command 0x02 "receive  printer job" */

	sprintf(o_str, "\2%s\n", rmPrinter);
	output(cnId, o_str, (int)strlen(o_str));

	get_response(cnId);

	if (*response != 0x00) {
		fprintf(stderr, "lpr: error: lp server didn't accept printer\n");
		return;
	}

	/* construct spool file name */
	sprintf(spoolFileName, "fA%03ld%s", (number++) % 1000, hostName);


/* subcommand 0x02 "receive control file" */

	/* build the control file */
	sprintf(fileBuff,                  "H%s\n", hostName);		/* mandatory */
	sprintf(fileBuff+strlen(fileBuff), "P%s\n", userName);		/* mandatory */
	sprintf(fileBuff+strlen(fileBuff), "N%s\n", oriFileName);	/* name of file */

	if (optSendMail)
		sprintf(fileBuff+strlen(fileBuff), "M%s\n", userName);

	if (!optNoBanner) {
		sprintf(fileBuff+strlen(fileBuff), "C%s\n", hostName);		/* class for banner */
		sprintf(fileBuff+strlen(fileBuff), "J%s\n", oriFileName);	/* job name for banner */
		sprintf(fileBuff+strlen(fileBuff), "L%s\n", userName);		/* banner */
	}

#if 0	/* not supported */
	sprintf(fileBuff+strlen(fileBuff), "U%s\n", spoolFileName);	/* unlink data file */
#endif

	if (optNCopies)
		sprintf(fileBuff+strlen(fileBuff), "#%s\n", optNCopies);

	if (optNIndent)
		sprintf(fileBuff+strlen(fileBuff), "I%s\n", optNIndent);

	if (optNWidth)
		sprintf(fileBuff+strlen(fileBuff), "W%s\n", optNWidth);

	if (optTitle)
		sprintf(fileBuff+strlen(fileBuff), "T%s\n", optTitle);

	sprintf(fileBuff+strlen(fileBuff), "%cd%s\n", optFormat, spoolFileName);	/* formatting option */

#ifdef DEBUG
	printf("%s", fileBuff);
#endif

	sprintf(o_str, "\2%ld c%s\n", strlen(fileBuff), spoolFileName);
	output(cnId, o_str, (int)strlen(o_str));
	get_response(cnId);

	if        (*response == 0x01) {
		fprintf(stderr, "lpr: error: connection messed up, try again\n");
		return;
	} else if (*response == 0x02) {
		fprintf(stderr, "lpr: error: server out of storage space\n");
		return;
	} else if (*response != 0x00) {
		fprintf(stderr, "lpr: error: no ack on sub command 3\n");
		return;
	}

	output(cnId, fileBuff, (int)strlen(fileBuff));

	fileBuff[0] = 0;
	output(cnId, fileBuff, 1);	/* terminator */

	get_response(cnId);

	if (*response != 0x00) {
		fprintf(stderr, "lpr: error: control file not properly transferred\n");
		return;
	}


/* subcommand 0x03 "receive data file" */

	sprintf(o_str, "\3%ld d%s\n", fileLength, spoolFileName);
#ifdef DEBUG
	fprintf(stderr, "file d%s %ld bytes\n", spoolFileName, fileLength);
#endif
	output(cnId, o_str, (int)strlen(o_str));

	get_response(cnId);

	if        (*response == 0x01) {
		fprintf(stderr, "lpr: error: connection messed up, try again\n");
		return;
	} else if (*response == 0x02) {
		fprintf(stderr, "lpr: error: server out of storage space\n");
		return;
	} else if (*response != 0x00) {
		fprintf(stderr, "lpr: error: unknown\n");
		return;
	}


	do {
		lenData = fread(fileBuff, 1, min(FILEBUFFSIZE, fileLength), fin);
#ifdef DEBUG
		fprintf(stderr, "read %ld bytes", lenData);
#endif
		if (lenData <= 0) {
			fileBuff[0] = 0;
			output(cnId, fileBuff, 1);	/* terminator */
		}
		if (lenData < 0) {
			return;
		}
		lenSent += lenData;
		printf("\r%3ld %%  ",(lenSent * 100) / fileLength);
		fflush(stdout);
		output(cnId, fileBuff, (int)lenData);
	} while(lenData > 0); 

	printf("\n");

	get_response(cnId);

	if (*response != 0x00) {
		fprintf(stderr, "lpr: error: data file not properly transferred, aborting\n");
		return;
	}
#ifdef DEBUG
	fprintf(stderr, "\nfile closed\n");
#endif

}	/* print_file */


/************************************************************************************************/
/************************************************************************************************/

d41 3
a43 1
	FILE* fin;
d46 1
a46 1
	char *p;
d54 4
a57 29
	if ( (p = getenv("TCPWND")) != NULL ) tcpBuffSize = atoi(p);

	if ( (rmPrinter = getenv("PRINTER")) == NULL )
		rmPrinter = "lp";

	if ( (userName = getenv("USER")) == NULL ) {
		userName = getvstr("USERNAME");
		if (userName[0] == '0') {
			fprintf(stderr, "lpr: error: no USER in env or USERNAME in default.cnf\n");
			return -1;
		}
	}

	if ( (hostName = getenv("HOST")) == NULL ) {
		hostName = getvstr("HOSTNAME");
		if (hostName[0] == '0') {
			fprintf(stderr, "lpr: error: no HOST in env or HOSTNAME in default.cnf\n");
			return -1;
		}
	}
	strtok(hostName,".");   /* chop off domainname */


	if ( (rmHost = getenv("PRINTHOST")) == NULL ) {
		rmHost = getvstr("PRINTHOST");
		if (rmHost[0] == '0') {
			fprintf(stderr, "lpr: error: no PRINTHOST in env or default.cnf\n");
			return -1;
		}
a59 1

d86 1
a86 1
				optFormat = opt;
d153 4
d162 2
d165 1
a165 1
		if ( (fin = tmpfile()) == NULL ) {
d171 2
a172 1
			if (fputc(c, fin) == EOF) {
d178 1
a178 2
		/* rewind tmpfile */
		fseek(fin, 0L, 0);
a185 3
		long timev;
		char *actFile;

a186 11
		if( doSTDIN ) { 
			actFile = "unknown";
		} else {
			actFile = argv[i];
			if ( (fin=fopen(argv[i], "rb")) == NULL ) {
				fprintf(stderr, "lpr: error: can't open file >%s<\n", actFile);
				error++;
				continue;	/* skip this file */
			}
		}

d188 1
a188 4
		rmHost, rmPrinter, actFile);

		timev = clock();
		number = (((timev >> 24) & 0xff) + ((timev >> 16) & 0xff))*15 + ((timev >> 10) );
d191 4
a194 1
			printfile(actFile, fin, cnId); 
a197 1
			fclose(fin);
d201 1
a201 3
		fclose(fin);

		doSTDIN = FALSE;
@


1.1
log
@Initial revision
@
text
@d4 3
d206 1
a206 1
	sprintf(fileBuff+strlen(fileBuff), "%c%s\n", optFormat, spoolFileName);	/* formatting option */
d244 1
a244 1
	fprintf(stderr, "file %s %ld bytes\n", spoolFileName, fileLength);
@
