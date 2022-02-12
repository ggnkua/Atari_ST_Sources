/* ftpd.h
 *
 * This file is part of ftpd.
 *
 *
 * 01/25/96 Initial Release	Michael Temari, <temari@ix.netcom.com>
 */

#define	GOOD	0
#define	BAD	1

#define	TYPE_A	0
#define	TYPE_I	1

extern char *FtpdVersion;
extern int type, format, mode, structure;
extern ipaddr_t myipaddr, rmtipaddr, dataaddr;
extern tcpport_t myport, rmtport, dataport;
extern int ftpdata_fd;
extern int loggedin, gotuser, anonymous;
extern char *days[], *months[];
extern char username[80];
extern char anonpass[128];
extern char myhostname[256], rmthostname[256];
extern char line[512];

_PROTOTYPE(void cvtline, (char **args));
_PROTOTYPE(void logit, (char *type, char *parm));
_PROTOTYPE(void loganon, (int anon));
