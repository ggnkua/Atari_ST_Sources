/*
 * version.c - Citadel version #'s in a file of their very own.
 *
 * Banners should be Fnordadel$MACHINE $VERSION-$PATCHNUM
 *
 * 91Feb06 RH	Version 1.32 (various changes, incl. ctdllog.sys conversion)
 * 90Nov07 AA	Version 1.31 (gcc + 3.4a extensions)
 * 90Jul29 AA	Moved PATCHNUM to its own file (patchnum.c, oddly...)
 * 88Aug10 orc	Added MACHINE field for different machine versions
 * 88Jul30 orc	fixVer variable changed to PATCHNUM
 * 87Apr11 orc	created.
 */

/* Fnordadel numbering scheme put in by AA 89Jan31 */
/* ...and modified by AA 90Jul19 */

char VERSION[] = "1.32";
#ifdef MSDOS
char MACHINE[] = "-PC";
#endif
#ifdef ATARIST
char MACHINE[] = "";
#endif
