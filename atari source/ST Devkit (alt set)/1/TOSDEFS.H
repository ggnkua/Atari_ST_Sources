/************************************************************************/
/*	TOSDEFS.H	TOS Definitions.				*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

/* File Access Types */

#define RMODE_RD 0
#define RMODE_WR 1
#define RMODE_RW 2

/* Device Identifiers */

#define	PRT:	0
#define	AUX:	1
#define	CON:	2
#define	MIDI:	3
#define	IKBD:	4

/* File Attributes */

#define F_RDONLY 0x01
#define F_HIDDEN 0x02
#define F_SYSTEM 0x04
#define F_VOLUME 0x08
#define F_SUBDIR 0x10
#define F_ARCHIVE 0x20

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
#define	ENSMEM	-39L	/* insufficient memory				 8 */
#define EIMBA	-40L	/* invalid memory block address			 9 */
#define	EDRIVE	-46L	/* invalid drive was specified			15 */
#define	ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define	ERANGE	-64L	/* range error					33 */
#define	EINTRN	-65L	/* internal error				34 */
#define EPLFMT  -66L	/* invalid program load format			35 */
#define EGSBF	-67L	/* setblock failure due to growth restrictions  36 */
