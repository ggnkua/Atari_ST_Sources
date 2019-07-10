/*
 * getlog.c -- get a Fnordadel log entry
 *
 * 90Aug27 AA	Split off from liblog.c
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

/* We need some better place to put these declarations */
struct logBuffer logBuf;		/* Log buffer of a person	*/
struct logBuffer origlogBuf;		/* logBuf at start of this call	*/
int		logindex;		/* The userlog slot of user	*/
long		highlogin;		/* Highest message at login	*/

void
getlog(p, n, file)
struct logBuffer *p;
int n;
int file;		/* file handle to work with */
{
    int size;
    long address = ((long)n) * ((long)LB_TOTAL_SIZE);

    dseek(file, address, 0);
    if ((size=dread(file, p, LB_SIZE)) != LB_SIZE)
	crashout("getlog(%d) read %d/expected %d", n, size, LB_SIZE);
    crypte((char *)p, LB_SIZE, n*3);
    if ((size=dread(file, p->lbgen, GEN_BULK)) != GEN_BULK)
	crashout("getlog(%d) read %d/expected %d", n, size, GEN_BULK);
    if ((size=dread(file, p->lbmail, MAIL_BULK)) != MAIL_BULK)
	crashout("getlog(%d) read %d/expected %d", n, size, MAIL_BULK);
}
