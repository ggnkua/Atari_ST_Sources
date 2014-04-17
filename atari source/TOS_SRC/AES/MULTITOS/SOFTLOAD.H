/*	SOFTLOAD.H	4/20/93			Hans-Martin Krober	*/

/*
 *	Set these flags to implement soft loaded resources for
 *	the GEM AES and the DESKTOP.
 */

/*	Set the SOFTLOAD flag to implement softloaded GEM AES/DESKTOP
 *	resources. The AES will then try to read its resource file from
 *	[A|C]:\MULTITOS\GEM.RSC.  
 */
#define SOFTLOAD	1

/*	Set the ONERSC flag to indicate that the system just has the
 *	U.S. desktop resource in ROMs. If the system cannot load the
 *	GEM.RSC from disk, it will displaying a warning, saying that
 *	the U.S. version from ROM will be used.
 *	This variable is in DESKTOP.C and DESKROM.C
 *	See below at the SOFTLOAD.H
 */
#define ONERSC		0

/*	Turn on resource file version number checking by setting the
 *	GEMRSVER to 1. Use "rscvers versnr GEM.RSC"
 *	to create a GEM.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	This variable GEMRSVER is found in DESKROM.C
 */
#define GEMRSVER	0

/*	Turn on resource file version number checking by setting the
 *	DESKRSVER to 1. Use "rscvers versnr DESKTOP.RSC"
 *	to create a DESKTOP.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	This variable DESKRSVER is found in DESKROM.C
 */
#define DESKRSVER	0
 
/*	Set the LOADKBT flag to implement softloaded keyboard tables. The
 *	system will try to load the keyboad table from  [A|C]:\MULTITOS\KEYBD.TBL.
 *	This variable LOADKBT is found in GEMINIT.C
 */
#define LOADKBT		0

/*
 * The DESKPRG variable controls whether we are compiling a stand alone desktop
 * or not
 */
#ifndef DESKPRG
#define DESKPRG		0
#endif
