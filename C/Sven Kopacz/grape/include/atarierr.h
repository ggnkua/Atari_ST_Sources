#ifndef _ATARIERR_H
#define _ATARIERR_H

#define	E_OK	0

/* BIOS errors */

#define ERROR	-1		/* generic error */
#define EDRVNR	-2		/* drive not ready */
#define EUNCMD	-3		/* unknown command */
#define E_CRC	-4		/* crc error */
#define EBADRQ	-5		/* bad request */
#define E_SEEK	-6		/* seek error */
#define EMEDIA	-7		/* unknown media */
#define ESECNF	-8		/* sector not found */
#define EPAPER	-9		/* out of paper */
#define EWRITF	-10		/* write fault */
#define EREADF	-11		/* read fault */

#define EWRPRO	-13		/* device write protected */
#define E_CHNG	-14		/* media change detected */
#define EUNDEV	-15		/* unknown device */
#define EBADSF	-16		/* bad sectors on format */
#define EOTHER	-17		/* insert other disk request */

/* GEMDOS errors */

#define EINVFN	-32		/* invalid function */
#define EFILNF	-33		/* file not found */
#define EPTHNF	-34		/* path not found */
#define ENHNDL	-35		/* no more handles */
#define EACCDN	-36		/* access denied */
#define EIHNDL	-37		/* invalid handle */
#define ENSMEM	-39		/* insufficient memory */
#define EIMBA	-40		/* invalid memory block address */
#define EDRIVE	-46		/* invalid drive specification */
#define EXDEV	-48		/* cross device rename */
#define ENMFIL	-49		/* no more files (from fsnext) */
#define ELOCKED	-58		/* record is locked already */
#define ENSLOCK	-59		/* invalid lock removal request */
#define ERANGE	-64		/* range error */
#define EINTRN	-65		/* internal error */
#define EPLFMT	-66		/* invalid program load format */
#define ENOEXEC EPLFMT
#define EGSBF	-67		/* memory block growth failure */

#define ENAMETOOLONG ERANGE	/* a filename component is too long */
#define ELOOP -80		/* too many symbolic links */
#define EPIPE -81		/* broken pipe */

/* this isn't really an error at all, just an indication to the kernel
 * that a mount point may have been crossed
 */

#define EMOUNT	-200

#define EINVAL	EINVFN

#endif /* _ATARIERR_H */
