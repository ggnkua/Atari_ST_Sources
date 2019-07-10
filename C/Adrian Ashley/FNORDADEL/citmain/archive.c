/*
 * archive.c -- Routines to archive messages & things
 */

#include "ctdl.h"
#include "protocol.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

static int (*pfc)(int);
static int otermwidth;
static char oprotocol;

/*
 * sendARchar() -- dump a character to a file
 */
int
sendARchar(int c)
{
    return (fputc(c, upfd) != EOF);
}

/*
 * ARsetup() -- set up the system for archiving
 */
int
ARsetup(char *file)
{
    if (upfd = safeopen(file, "a")) {
	otermwidth = logBuf.lbwidth;	logBuf.lbwidth = 79;
	oprotocol = usingWCprotocol;	usingWCprotocol = TODISK;
	pfc = sendPFchar;		sendPFchar = sendARchar;
	return 1;
    }
    return 0;
}

/*
 * sendARend() -- restore everything
 */
int
sendARend(void)
{
    sendPFchar = pfc;
    usingWCprotocol = oprotocol;
    logBuf.lbwidth = otermwidth;
    return fclose(upfd);
}
