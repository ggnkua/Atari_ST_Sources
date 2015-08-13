/* Dr. Thomas Redelberger, Nov 1999 */
/* tcp/ip lpr printer client functions for Atari computers using STinG */
/* conforming to RFC 1179 */
/*
$Id: lpraux.h 1.2 1999/12/30 13:03:18 Thomas Exp Thomas $
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
