/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemerror.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:22:10 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemerror.h,v $
* Revision 2.2  89/04/26  18:22:10  mui
* TT
* 
* Revision 2.1  89/02/22  05:25:48  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:31:39  lozben
* Initial revision
* 
*************************************************************************
*/
/* gemerror.h - standard error numbers for GEMDOS
*/

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

#define EIMBA	-40L	/* invalid memory block address			 9 */

#define	EDRIVE	-46L	/* invalid drive was specified			15 */

#define	ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define	ERANGE	-64L	/* range error					33 */
#define	EINTRN	-65L	/* internal error				34 */
#define EPLFMT  -66L	/* invalid program load format			35 */
#define EGSBF	-67L	/* setblock failure due to growth restrictions  36 */
