/*
 * MAC_XFS.H  -  MagiC-XFS extensions for Macintosh file system
 */

/*
 * Some Mac OS types:
 */

#ifndef __MWERKS__

typedef unsigned long OSType;

typedef struct {
	short	v;
	short	h;
} Point;

typedef struct {
	OSType			fdType;			/* file's Type */
	OSType			fdCreator;		/* file's Creator */
	unsigned short	fdFlags;		/* file's flags */
	Point			fdLocation;		/* file's location in folder */
	short			fdFldr;			/* (unsued) */
} FInfo;

#endif

/*
 * MacMiNT functions:
 */

#define FMACOPENRES     (('F' << 8) | 72)	/* open resource fork */
#define FMACGETTYCR     (('F' << 8) | 73)	/* get Type & Creator */
#define FMACSETTYCR     (('F' << 8) | 74)	/* set Type & Creator */

/*
 * MagiCMac specific functions:
 */

typedef struct {
	short	funcNo;
	long		longVal;
	void		*srcPtr;
	void		*destPtr;
} MMEXRec;

#define FMACMAGICEX     (('F' << 8) | 75)
#define MMEX_INFO       0	/* Dcntl & Fcntl */
#define MMEX_GETFREFNUM 1	/* Fcntl         */
#define MMEX_GETFSSPEC  2	/* Dcntl         */
#define MMEX_GETRSRCLEN 3	/* Dcntl         */
#define MMEX_GETCATINFO 4	/* Dcntl & Fcntl */
#define MMEX_SETCATINFO 5	/* Dcntl & Fcntl */

/* EOF */
