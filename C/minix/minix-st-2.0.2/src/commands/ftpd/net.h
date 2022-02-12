/* net.h
 *
 * This file is part of ftpd.
 *
 *
 * 01/25/96 Initial Release	Michael Temari, <temari@ix.netcom.com>
 */

_PROTOTYPE(int doPASV, (char *buff));
_PROTOTYPE(int doPORT, (char *buff));
_PROTOTYPE(int DataConnect, (void));
_PROTOTYPE(int CleanUpData, (void));
_PROTOTYPE(void GetNetInfo, (void));
