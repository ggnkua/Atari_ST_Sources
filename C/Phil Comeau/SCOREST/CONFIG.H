/* Config:	Definitions used for Score Configuration
 * phil comeau 12-jul-89
 * last edited 12-jul-89 0001
 * 
 * Copyright 1990 Antic Publishing Inc.
 */

/* PRTCONFIG: Structure defining printer configuration information */

typedef struct {
	BOOLEAN bit0Dn;			/* TRUE if bit 0 is at the bottom
					 * of a print line.
					 */
	int initLen;			/* Size of the initialization string.
					 */
	char initStr[20];		/* Initialization string. */
	int lnStartLen;			/* Length of the line start string.
					 */
	char lnStartStr[20];		/* Line start string. */
	BOOLEAN apndLnSz;		/* TRUE: line size follows start
					 * FALSE: no line size
					 */
	BOOLEAN lnSzLsbMsb;		/* TRUE: use LSB,MSB byte ordering
					 * FALSE: use MSB,LSB byte ordering
					 *     in line size
					 */
	int lnEndLen;			/* Length of the line end string. */
	char lnEndStr[20];		/* Line end string. */
	int vertDotLen;			/* Length of the dot-height vertical
					 * motion string.
					 */
	char vertDotStr[20];		/* Vertical dot-height motion string.
					 */
	int ffLen;			/* Size of the formfeed string. */
	char ffStr[20];			/* Formfeed string. */
	int termLen;			/* Size of the termination string. */
	char termStr[20];		/* termination string. */
} PRTCONFIG;

/* CONFIG: Score configuration information structure */

typedef struct {
	PRTCONFIG	draftPrtCfg;	/* Draft Printer configuration */
	PRTCONFIG	finalPrtCfg;	/* Final printer configuration */
} CONFIG;
