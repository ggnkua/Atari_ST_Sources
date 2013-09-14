/*
 * BSL.H
 *    Constants defined for routines associate with the Bad Sector List.
 */

/* portions of BSL */ 
#define	VENDOR 0	/* vendor BSL */
#define	USER 1		/* user BSL */
#define	MEDIA 2 	/* media (vendor + user) BSL */
#define	UNUSED 3	/* unused part of BSL */

/* magic sum (byte-wise) of a valid BSL */
#define	BSLMAGIC 0xa5

/* BSL info */
#define	STBSL 1L	/* BSL STarts at physical sector 1 */
#define BPE 3		/* Bytes Per Entry */
#define RENT 2		/* num Reserved ENTries */
#define	EPS (512/BPE)	/* Entries Per Sector */

/* kind of BSL to be created */
#define	NEW 0		/* create a totally new BSL */
#define	EXPAND 1	/* expand an existing BSL */


/* Maximum number of entries allowed for USER bad sectors in BSL */
#define WARNBADSECTS	128

/* error numbers returned by rountines manipulating the BSL */
#define	NOBSL  (-2)	/* BSL does not exist */
#define	INVALID  (-3)	/* BSL does not checksum to BSLMAGIC */
#define	NOMEM (-4)	/* not enough memory to read in BSL */
#define NOTADDED (-5)	/* no entry is added to BSL */
#define	USRFULL (-6)	/* user list is full */
