/*	GEMDOS.H			9/23/92		D.Mui		*/

#ifndef _GEMDOS_H_
#define _GEMDOS_H_

#include	"portab.h"

#define	X_TABOUT	0x02
#define	X_PRTOUT	0x05
#define	X_RAWCON	0x06
#define	X_SETDRV	0x0E
#define	X_GETDRV	0x19
#define	X_SETDTA	0x1A
#define X_GETDTA	0x2F
#define	X_GETFREE	0x36
#define	X_MKDIR		0x39
#define	X_RMDIR		0x3A
#define	X_CHDIR		0x3B
#define	X_CREAT		0x3C
#define	X_OPEN		0x3D
#define	X_CLOSE		0x3E
#define	X_READ		0x3F
#define	X_WRITE		0x40
#define	X_UNLINK	0x41
#define	X_LSEEK		0x42
#define	X_CHMOD		0x43
#define X_XMALLOC	0x44
#define	X_GETDIR	0x47
#define	X_MALLOC	0x48
#define	X_MFREE		0x49
#define	X_MSHRINK	0x4A
#define	X_SETBLOCK	0x4A
#define	X_EXEC		0x4B
#define X_TERM		0x4C
#define	X_SFIRST	0x4E
#define	X_SNEXT		0x4F
#define	X_RENAME	0x56
#define	X_GSDTOF	0x57

#define STDIN 0x0000
#define STDOUT 0x0001
#define STDERR 0x0002
#define STDAUX 0x0003
#define STDPRN 0x0004

#define E_BADFUNC 1
#define E_FILENOTFND 2
#define E_PATHNOTFND 3
#define E_NOHANDLES 4
#define E_NOACCESS 5
#define E_BADHANDLE 6
#define E_MEMBLKERR 7
#define E_NOMEMORY 8
#define E_BADMEMBLK 9
#define E_BADENVIR 10
#define E_BADFORMAT 11
#define E_BADACCESS 12
#define E_BADDATA 13
#define E_BADDRIVE 15
#define E_NODELDIR 16
#define E_NOTDEVICE 17
#define E_NOFILES 18

#define F_RDONLY 0x01
#define F_HIDDEN 0x02
#define F_SYSTEM 0x04
#define F_VOLUME 0x08
#define F_SUBDIR 0x10
#define F_ARCHIVE 0x20

#define F_GETMOD 0x0
#define F_SETMOD 0x1

#define F_ATTR 		0		/* file attribute for creating	*/
#define SMODE 		0		/* seek mode is absolute offset	*/

#define RMODE_RD 	0		/* Open file to read only	*/
#define RMODE_WR 	1		/* Open file to write only	*/
#define RMODE_RW 	2		/* OPen file read and write	*/	


/* BIOS level errors */

#define	E_OK	  0L	/* OK, no error			*/
#define	ERROR	 -1L	/* basic, fundamental error	*/
#define	EDRVNR	 -2L	/* drive not ready		*/
#define	EUNCMD	 -3L	/* unknown command		*/
#define	E_CRC	 -4L	/* CRC error			*/
#define	EBADRQ	 -5L	/* bad request			*/
#define	E_SEEK	 -6L	/* seek error			*/
#define	EMEDIA	 -7L	/* unknown media		*/
#define	ESECNF	 -8L	/* sector not found		*/
#define	EPAPER	 -9L	/* no paper			*/
#define	EWRITF	-10L	/* write fault			*/
#define	EREADF	-11L	/* read fault			*/
#define	EGENRL	-12L	/* general error		*/
#define	EWRPRO	-13L	/* write protect		*/
#define	E_CHNG	-14L	/* media change			*/
#define	EUNDEV	-15L	/* unknown device		*/
#define	EBADSF	-16L	/* bad sectors on format	*/
#define	EOTHER	-17L	/* insert other disk		*/

/* BDOS level errors */

#define	EINVFN	-32L	/* invalid function number			 1 */
#define	EFILNF	-33L	/* file not found				 2 */
#define	EPTHNF	-34L	/* path not found				 3 */
#define	ENHNDL	-35L	/* too many open files (no handles left)	 4 */
#define	EACCDN	-36L	/* access denied				 5 */
#define	EIHNDL	-37L	/* invalid handle				 6 */
#define ENSMEM	-39L
#define EIMBA	-40L	/* invalid memory block address			 9 */

#define	EDRIVE	-46L	/* invalid drive was specified			15 */

#define	ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define	ERANGE	-64L	/* range error					33 */
#define	EINTRN	-65L	/* internal error				34 */
#define EPLFMT  -66L	/* invalid program load format			35 */
#define EGSBF	-67L	/* setblock failure due to growth restrictions  36 */



typedef struct exec_blk
{
	WORD		eb_segenv;
	LONG		eb_pcmdln;
	LONG		eb_pfcb1;
	LONG		eb_pfcb2;
} EXEC_BLK;


typedef struct over_blk
{
	WORD		ob_seglod;
	WORD		ob_relfac;
} OVER_BLK;

#endif

