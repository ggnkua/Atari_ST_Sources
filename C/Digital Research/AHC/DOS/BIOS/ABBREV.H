/*****************************************************************************
**
** abbrev.h - Switches and symbolic constants for VME/10 GEM DOS BIOS
**
** MODIFICATIONS
** 17 sep 85 scc	Removed definition of NOTUNDERCPM, HDISKDIV, LOADER.
**
** NAMES
**	scc	Steven C. Cavender
**
******************************************************************************
*/

/*  The following defines determine how Gemdos is to be compiled     */
/*  on the VME-10.  Diskc tells the size of the hard disk.  Select        */
/*  values of either 40 or 15 depending on which disk (in MBytes) you     */
/*  have.  MVME410 is a boolean which tells whether you have a parallel	  */
/*  printer or not.  INITIALIZE is the	  */
/*  switch to set when one is making the version of the O/S which has the */
/*  built-in Command Line Interpreter (= 1).  This switch should normally */
/*  be set to 0 since such a version of the O/S is special demanding 	  */
/*  special versions of command.c, coma.s, main.c, biosaa.s.		  */
				
#define DISKC		15			/* size of hard disk 	  */
#define MVME410 	0			/* parallel printer 	  */
#define INITIALIZE	0			/* O/S has built-in CLI   */

#define MAXDSK		3
#define CTLTYPE 	0
#define MEMDSK 		0
#define DISKB		0				/* drive B: */
#define DISKD		0				/* drive D: */
#define TEST 		0
#define	NO_ASM_SUPPORT	0
#define h_PRT 		0				/* PRT: */
#define h_AUX 		1				/* AUX: */
#define h_CON 		2				/* CON: */
#define dev_RDY 	-1L

/* MODE TYPES --used in conio.c and bios.c    */
 
#define BLANK	0x01		 	/* blank locking mode key is down    */
#define CTRL	0x02			/* CTRL is down.		     */
#define SHIFT	0x04			/* one or both of shift keys is down */
#define PAD	0x08			/* FUNC/PAD is down (PAD).	     */
#define ALPHA_LOCK 0x10			/* ALPHA LOCK is down. 		     */
#define ALT	0x20			/* ALT is down.			     */
#define ALOCK_OR_SHIFT 0x14		/* either lock of shift are down     */

#define LEFT		0x01		/* left shift key is down	     */
#define RIGHT		0x02		/* right shift key is down	     */

#define M400_1		0		/* indices for the 2 auxillary ports */
#define M400_2		1
#define AUX 		M400_1		/* Auxllary Serial Device	     */
#define LST 		M400_2		/* List Device (line printer)	     */

/************************************************************************/
/* Define Disk I/O Addresses and Related Constants			*/
/*	used in disk.c and in bios.c					*/
/************************************************************************/

#if DISKC == 5
#define HDRMC	1023		/* hard disk C: directory maximum */
#define	HDSMC	1215		/* hard disk C: storage maximum - 5 MB */
#define CMCYL	305		/* hard disk C: maximum cylinder */
#define CMHD	1		/* hard disk C: maximum head */
#endif

#if DISKC == 15
#define HDRMC	2047		/* hard disk C: directory maximum */
#define	HDSMC	3655		/* hard disk C: storage maximum - 15 MB */
#define CMCYL	305		/* hard disk C: maximum cylinder */
#define CMHD	5		/* hard disk C: maximum head */

/* CP/M-68K running underneath must use CMCYL 153  & HDSMC 1817 */
/* this is the 32 X 128 boundary track # between partitions */
/* 153 tracks X 6 heads/track X 16 sec/track X 2 log/phys = 29376 */

#define Hfudge 29376L

#endif 						/* DISKC == 15 */

#if DISKC == 40
#define CMCYL 	829
#define CMHD 	5
#define HDRMC 	5563		/* wild guess by EWF on 5/22/85 */
#define HDSMC 	6091		/* wild guess by EWF on 5/22/85 */
/* CP/M-68K underneath must use CMCYL 305  & HDSMC 3655 (15Meg normal) */
#define Hfudge 	58752L

#endif 						/* DISKC == 40 */

#if DISKD == 5
#define HDRMD	1023		/* hard disk D: directory maximum */
#define	HDSMD	1215		/* hard disk D: storage maximum - 5 MB */
#define DMCYL	305		/* hard disk D: maximum cylinder */
#define DMHD	1		/* hard disk D: maximum head */
#endif

#if DISKD == 15
#define HDRMD	2047		/* hard disk D: directory maximum */
#define	HDSMD	3655		/* hard disk D: storage maximum - 15 MB */
#define DMCYL	305		/* hard disk D: maximum cylinder */
#define DMHD	5		/* hard disk D: maximum head */
#endif

#if DISKD == 0
#define HDRMD	0		/* hard disk D: directory maximum */
#define	HDSMD	0		/* hard disk D: storage maximum - 15 MB */
#define DMCYL	0		/* hard disk D: maximum cylinder */
#define DMHD	0		/* hard disk D: maximum head */
#endif
