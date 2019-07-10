/*
 * putlog.c -- put a Fnordadel log entry
 *
 * 90Aug27 AA	Split off from liblog.c
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

void
putlog(p, n, file)
struct logBuffer *p;
int n;
int file;			/* file handle to operate on */
{
    int size;
    long address = ((long)n) * ((long)LB_TOTAL_SIZE);

    crypte((char *)p, LB_SIZE, n*3);
    dseek(file, address, 0);
    if ((size=dwrite(file, p, LB_SIZE)) != LB_SIZE)
	crashout("putlog(%d) wrote %d/expected %d", n, size, LB_SIZE);
    if ((size=dwrite(file, p->lbgen, GEN_BULK)) != GEN_BULK)
	crashout("putlog(%d) wrote %d/expected %d", n, size, GEN_BULK);
    if ((size=dwrite(file, p->lbmail, MAIL_BULK)) != MAIL_BULK)
	crashout("putlog(%d) wrote %d/expected %d", n, size, MAIL_BULK);
    crypte((char *)p, LB_SIZE, n*3);
}
