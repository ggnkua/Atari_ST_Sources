/* ftpd.h
 *
 * This file is part of ftpd.
 *
 *
 * 01/25/96 Initial Release	Michael Temari, <temari@ix.netcom.com>
 */

_PROTOTYPE(int ChkLoggedIn, (void));
_PROTOTYPE(int doUSER, (char *buff));
_PROTOTYPE(int doPASS, (char *buff));
_PROTOTYPE(int doQUIT, (char *buff));
