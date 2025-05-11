/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: errno.h,v 1.2 88/02/03 20:07:07 m68k Exp $
 *
 * $Log:	errno.h,v $
 * Revision 1.2  88/02/03  20:07:07  m68k
 * Added ENOTTY for ioctl()
 * 
 * Revision 1.1  88/01/29  17:18:36  m68k
 * Initial revision
 * 
 */
#define	ENOERR		  0		/* no error */
#define	EERROR		 -1		/* generic error */
#define	EDRNRDY		 -2		/* drive not ready */
#define	EUKCMD		 -3		/* unknown command */
#define	ECRC		 -4		/* crc error */
#define	EBADREQ		 -5		/* bad request */
#define	ESEEK		 -6		/* seek error */
#define	EUKMEDIA	 -7		/* unknown media */
#define	ESECTOR		 -8		/* sector not found */
#define	EPAPER		 -9		/* no paper */
#define	EWRITE		-10		/* write fault */
#define	EREAD		-11		/* read fault */
#define	EGENERIC	-12		/* general mishap */
#define	EROFS		-13		/* write protect */
#define	ECHMEDIA	-14		/* media change */
#define	EUKDEV		-15		/* unknown device */
#define	EBADSEC		-16		/* bad sectors */
#define	EIDISK		-17		/* insert disk */
					/* (gap) */
#define	EINVAL		-32		/* invalid function number */
#define	ENOENT		-33		/* file not found */
#define	EPATH		-34		/* path not found */
#define	EMFILE		-35		/* too many open files */
#define	EACCESS		-36		/* access denied */
#define	EBADF		-37		/* invalid handle */
#define	ENOMEM		-39		/* insufficient memory */
#define	EFAULT		-40		/* invalid memory block request */
#define	ENXIO		-46		/* invalid drive */
#define	EXDEV		-48		/* cross device rename */
#define	ENMFILES	-49		/* no more files (fnext) */
#define	EBADARG		-64		/* range error/context unknown */
#define	EINTERNAL	-65		/* internal error */
#define	ENOEXEC		-66		/* invalid program load format */
#define	ESBLOCK		-67		/* set block failed/growth restraints */
					/* (gap) */
#define	EEXIST		-80		/* file exists (open) */
#define	ENAMETOOLONG	-81		/* file exists (open) */
#define	ENOTTY		-82		/* not a tty (ioctl) */

extern	int	errno;
extern	int	sys_nerr;
extern	char *	sys_errlist[];
