/* deflst.h */


/* 22-Jan-88	ml	Started this.					*/
/* 27-Jun-88	ml	Per John Hoenig, the sync field at end of each	*/
/*			sector for RLL format is made longer, and bytes */
/*			per sector is reduced by 20 bytes.		*/
/* 14-Apr-89	ml	Modified to handle ST225R (for MEGAFILE 20).	*/

/*
 * Physical block address.
 */
#define	PADDR struct _paddr
PADDR {
    unsigned int exist;		/* TRUE: real entry */
    unsigned int head;		/* head number */
    unsigned int cylndr;	/* cylinder number */
    unsigned int btoffst;	/* byte offset from index */
};

/* Disk format */
#define	MFM	0
#define	RLL	1

/* Bytes per sector of disk (according to ADAPTEC manual) */
#define BPSMFM  576		/* 17 sectors per track */
#define BPSRLL  559		/* 26 sectors per track */

/* Bytes per track of disk */
/* Per John Hoenig:
 *	These numbers are number of bytes per revolution
 * calculated at 3600 rpm.
 * MFM :  (1000*1000/60) / 1.6  = 10417
 * RLL :  ((1000*1000/60) / 1.6) * 1.5 = 15625
 *
 *	The ST225R originally has 31 sectors per track.  The firmware
 * has been modified to make it look like it has 26 sectors per track.
 * Bytes per sector for the ST225R is calculated at 3000 rpm.
 * 3000rpm => 50Hz => 20000usec
 * RLL (ST225R) :  (20000 / (8/7.5)) = 18750 (18742 to be conservative)
 */
#define BPTMFM	 10417
#define BPTRLL	 15625
#define BPT31RLL 18742

/* Duration of index pulse on each track */
#define NDXPULS 150

/* Largest physical block address possible */
PADDR maxpaddr;

/* Variables for disk format and tester */
int fmt, tst;

/* error for defect entries */
#define	EMPTY	(-7)	/* entry is empty */
#define	INCMPL	(-8)	/* entry is incomplete */
#define HD2BIG	(-9)	/* head number entered is too big */
#define CYLNUM0	(-10)	/* cylinder number entered is too big */
#define CYL2BIG	(-11)	/* cylinder number entered is too big */
#define BYT2BIG	(-12)	/* byte offset entered is too big */


