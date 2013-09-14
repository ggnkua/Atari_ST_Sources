/*
 * errno.h -- manifest constants for error codes.
 *
 * Copyright (c) 1981-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef ERRNO_H
#define ERRNO_H
/*
 * Atari ST error code names begin "AE", to avoid conflict with
 * draft ANSI standard.
 * The names of the positive error codes all begin with 'E'.
 */
/*
 * BIOS-level errors
 */
#define	AE_OK	  0L	/* OK, no error */
#define	AERROR	 (-1L)	/* Basic, fundamental error */
#define	AEDRVNR	 (-2L)	/* Drive not ready */
#define	AEUNCMD	 (-3L)	/* Unknown command */
#define	AE_CRC	 (-4L)	/* CRC error */
#define	AEBADRQ	 (-5L)	/* Bad request */
#define	AE_SEEK	 (-6L)	/* Seek error */
#define	AEMEDIA	 (-7L)	/* Unknown medium */
#define	AESECNF	 (-8L)	/* Sector not found */
#define	AEPAPER	 (-9L)	/* No paper */
#define	AEWRITF	(-10L)	/* Write fault */
#define	AEREADF	(-11L)	/* Read fault */
#define	AEGENRL	(-12L)	/* General error */
#define	AEWRPRO	(-13L)	/* Write protect */
#define	AE_CHNG	(-14L)	/* Medium change */
#define	AEUNDEV	(-15L)	/* Unknown device */
#define	AEBADSF	(-16L)	/* Bad sectors on format */
#define	AEOTHER	(-17L)	/* Insert other disk */
/*
 * BDOS-level errors. The trailing number is the equivalent MS-DOS error.
 */
#define	AEINVFN	(-32L)	/* Invalid function number		 1 */
#define	AEFILNF	(-33L)	/* File not found			 2 */
#define	AEPTHNF	(-34L)	/* Path not found			 3 */
#define	AENHNDL	(-35L)	/* Too many open files (no handles left) 4 */
#define	AEACCDN	(-36L)	/* Access denied			 5 */
#define	AEIHNDL	(-37L)	/* Invalid handle			 6 */
#define	AENSMEM	(-39L)	/* Insufficient memory			 8 */
#define AEIMBA	(-40L)	/* Invalid memory block address		 9 */
#define	AEDRIVE	(-46L)	/* Invalid drive was specified		15 */
#define AEXDEV	(-48L)	/* Cross device rename (not documented)	   */
#define	AENMFIL	(-49L)	/* No more files			18 */
#define	AERANGE	(-64L)	/* Range error, context unknown		33 */
#define	AEINTRN	(-65L)	/* Internal error			34 */
#define AEPLFMT (-66L)	/* Invalid program load format		35 */
#define AEGSBF	(-67L)	/* Setblock failed: growth restrictions	36 */
/*
 * COHERENT system aliases for the negative bios/gemdos error
 * stored in errno:
 */
#define	EMFILE	(-AENHNDL)	/* Too many files, a la COHERENT 	*/
#define ENOEXEC	(-AEPLFMT)	/* bad exec format, a la COHERENT	*/
#define EIO	(-AESECNF)	/* Almost nothing but IO errors		*/
#define EINTR	(-AEINVFN)	/* An interrupted exec			*/
/*
 * Some necessary error codes, sandwiched into unused space
 */
#define EDOM	31		/* Domain error in libm */
#define ERANGE	30		/* Range error in libm */

extern int errno;
extern int sys_nerr;
extern char *sys_errlist[];
#endif

/* End of errno.h */
