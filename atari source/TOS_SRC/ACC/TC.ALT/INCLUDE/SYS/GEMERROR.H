/* GEMERROR.H	Standard error numbers for BIOS/GEMDOS
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900129 kbad	reviewed
 * 890829 kbad	ERANGE changed to ESOOR to comply with ANSI spec.
 */

/* ................................................................
 * BIOS-level errors					MS-DOS
 *							equivalents
 */
#define	E_OK	  0L	/* OK, the anti-error			 0 */
#define	ERROR	 -1L	/* Basic, fundamental error		na */
#define	EDRVNR	 -2L	/* Drive not ready			21 */
#define	EUNCMD	 -3L	/* Unknown command			22 */
#define	E_CRC	 -4L	/* CRC error				23 */
#define	EBADRQ	 -5L	/* Bad request (invalid length)		24 */
#define	E_SEEK	 -6L	/* Seek error				25 */
#define	EMEDIA	 -7L	/* Unknown medium			26 */
#define	ESECNF	 -8L	/* Sector not found			27 */
#define	EPAPER	 -9L	/* No paper				28 */
#define	EWRITF	-10L	/* Write fault				29 */
#define	EREADF	-11L	/* Read fault				30 */
#define	EGENRL	-12L	/* General failure			31 */
			/* Sharing violation			32 */
			/* Lock violation			33 */
#define	EWRPRO	-13L	/* Write protect			19 */
#define	E_CHNG	-14L	/* Media change				na */
#define	EUNDEV	-15L	/* Unknown device			20 */
#define	EBADSF	-16L	/* Bad sectors on format		na */
#define	EOTHER	-17L	/* Insert other disk			34 */
			/* FCB unavailable			35 */
			/* Sharing buffer exceeded		36 */
			/* Reserved				37 */
			/* Handle EOF operation not completed	38 */
			/* Reserved			     39-49 */
			/* NetBIOS errors		     50-90 */

/* ................................................................
 * GEMDOS-level errors.					MS-DOS
 *							equivalents
 */
#define	EINVFN	-32L	/* Invalid function number		 1 */
#define	EFILNF	-33L	/* File not found			 2 */
#define	EPTHNF	-34L	/* Path not found			 3 */
#define	ENHNDL	-35L	/* Too many open files (no handles left) 4 */
#define	EACCDN	-36L	/* Access denied			 5 */
#define	EIHNDL	-37L	/* Invalid handle			 6 */
			/* Memory control blocks destroyed	 7 */
#define	ENSMEM	-39L	/* Insufficient memory			 8 */
#define EIMBA	-40L	/* Invalid memory block address		 9 */
			/* Invalid environment			10 */
			/* Invalid format			11 */
			/* Invalid access code			12 */
			/* Invlaid data				13 */
			/* Reserved				14 */
#define	EDRIVE	-46L	/* Invalid drive			15 */
			/* Attempt to remove CWD		16 */
#define ENSAME	-48L	/* Not same drive (on rename)		17 */
#define	ENMFIL	-49L	/* No more files			18 */

/* Homegrown error numbers				"TOS error #"
 */
#define	ESOOR	-64L	/* Seek Out Of Range			(33) */
/* NOTE:  ESOOR (Seek Out Of Range) used to be called ERANGE, but
 *	  ERANGE is defined by ANSI for math function errors.
 */

#define	EINTRN	-65L	/* Internal error			(34) */
#define ELDFMT	-66L	/* Invalid program load format		(35) */
#define EGSBF	-67L	/* Setblock failed: growth restrictions	(36) */

