/*
 * driver.c -- Comm port routines for the Atari ST
 *
 * 88Apr12 orc	Routines moved from LIBDEP.C.
 */

#include "ctdl.h"
#include "log.h"
#include "dirlist.h"
#include "modem.h"
#include "room.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * dobreak()		Set or clear a break.			*
 * gotcarrier()		Does the modem have carrier?		*
 * setBaud()		Set the system baud rate.		*
 * modemOpen()		Let the modem accept calls		*
 * modemClose()		Do not let the modem accept calls	*
 * setmodem()		Set up the modem the way citadel wants	*
 * fixmodem()		Restore the modem to original state	*
 * mflush()		clear i/o on the modem.			*
 */

static short obufsiz;
struct iorec {
    char *i_buf;
    short i_size;
    short i_head;
    short i_tail;
    short i_highwater;
    short i_lowwater;
};

int byteRate;
static int CDmfp;

#define MFP	((char*)0xfffffa01L)		/* rs232 status register */

/*
 * setmodem() -- condition the modem for the BBS
 *
 * On the ST, we make the output buffer as small as possible so that the
 * output queuing won't drive people nuts.
 */
void
setmodem(int interactive)
{
    register struct iorec *iop;
    register short i;

    iop = (struct iorec *)Iorec(0);
    obufsiz = iop[1].i_size;
    do {		/* Allow buffer to empty before we nuke said buffer */
	if ((i = iop[1].i_tail - iop[1].i_head) < 0)
	    i += iop[1].i_size;
    } while (i > 0);
    if (interactive)
	iop[1].i_size = 2;
}

/*
 * fixmodem() - restore the modem to non-bbs state
 */
void
fixmodem(void)
{
    register struct iorec *iop;

    iop = (struct iorec *)Iorec(0);
    iop[1].i_size = obufsiz;
}

#if 0	/* this isn't actually used anywhere, but we'll keep the code around */
/*
 * dobreak() - set or clear a break condition
 */
void
dobreak(int setit)
{
    long ssp;
    register char *tsr = (char *)0xfffffa2dL;

    ssp = Super(0L);
    *tsr = setit ? 0x09 : 0x01;
    Super(ssp);
}
#endif

/*
 * setBaud() - Set the system baud rate.
 */
void
setBaud(int x)
{
    static int baud [] = {  9,   7,   4,   1, 0    };
    static int rates[] = { 30, 120, 240, 960, 1920 };

    if (x < NUMBAUDS) {
	Rsconf(baud[x], 0, -1, -1, -1, -1);
	byteRate = rates[x];
    }
}

/*
 * gotcarrier() - Do we have carrier?
 */
static void
CDFunc(void)	/* MUST BE EXECUTED IN SUPERVISOR MODE! */
{
    CDmfp = *MFP;
}

int
gotcarrier(void)
{
    Supexec(CDFunc);
    return (CDmfp & 02)?0:1;	/* bit clear if carrier is there... */
}

/*
 * modemClose() - Disable DTR
 */
void
modemClose(void)
{
    Ongibit(0x10);
}

/*
 * modemOpen() - Enable DTR
 */
void
modemOpen(void)
{
    Offgibit(0xffef);
}

/*
 * mflush() - clear the modem input buffer
 */
void
mflush(void)
{
    while (MIReady())
	getraw();
}
