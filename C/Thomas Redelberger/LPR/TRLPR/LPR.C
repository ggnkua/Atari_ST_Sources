/* Dr. Thomas Redelberger, Oct 1998 */
/* tcp/ip lpr printer client for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpr.c 1.4 1999/12/30 12:55:34 Thomas Exp Thomas $
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
