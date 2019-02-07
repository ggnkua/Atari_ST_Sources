/* printer: functions used for graphics printing
 * phil comeau 28-may-88
 * last edited 15-jul-89 0004
 *
 * Copyright 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <obdefs.h>
#include <osbind.h>
#include <mylib.h>
#include "scoredef.h"
#include "config.h"

#define FINALDOTRPT 3			/* # times dots repeated horizontally
					 * in final mode.
					 */

struct scrBits {
	unsigned char	bit0;
	unsigned char	filler0[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit1;
	unsigned char	filler1[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit2;
	unsigned char	filler2[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit3;
	unsigned char	filler3[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit4;
	unsigned char	filler4[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit5;
	unsigned char	filler5[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit6;
	unsigned char	filler6[SCSMAXX / BITSPERBYTE - 1];
	unsigned char	bit7;
	unsigned char	filler7[SCSMAXX / BITSPERBYTE - 1];
};

extern FILE *Debug;

/* prtInit: Initialize the printer to print in a specified quality mode. */
int prtInit(qual)
int qual;
{
	register PRTCONFIG *prtCfg;
	extern CONFIG Config;
	int prtBlk();

	/* Send the initialization string appropriate to the quality mode.
	 */
	prtCfg = qual == DRAFT ? &Config.draftPrtCfg : &Config.finalPrtCfg;
	if (prtBlk(prtCfg->initStr, prtCfg->initLen) == CANCEL) {
		return (CANCEL);
	}

	return (DONE);
}

/* prtTerm: Reset the printer. */
int prtTerm(qual)
int qual;
{
	register PRTCONFIG *prtCfg;
	extern CONFIG Config;
	int prtBlk();

	/* Send the termination string appropriate to the quality mode. */
	prtCfg = qual == DRAFT ? &Config.draftPrtCfg : &Config.finalPrtCfg;
	if (prtBlk(prtCfg->termStr, prtCfg->termLen) == CANCEL) {
		return (CANCEL);
	}

	return (DONE);
}

/* prtScr: Print a screen on the printer. */
int prtScr(pScr, maxY, qual)
unsigned char *pScr;
int maxY, qual;
{
	static unsigned char prtBitMsk0Dn[] = {
	    0x00, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10,
	    0x00, 0x08, 0x00, 0x04, 0x00, 0x02, 0x00, 0x01
	};
	static unsigned char prtBitMsk0Up[] = {
	    0x00, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08,
	    0x00, 0x10, 0x00, 0x20, 0x00, 0x40, 0x00, 0x80
	};
	static unsigned char scrBitMskTbl[] = {
	    0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
	};
	register unsigned char *prtBitMskTbl, *pLine, scrBitMsk;
	register unsigned int col;
	unsigned int ln;
	static unsigned char line[SCSMAXX];
	register struct scrBits *p;
	register PRTCONFIG *prtCfg;
	int prtLine();
	extern CONFIG Config;

	/* Determine which screen byte/printer byte map to use. This will
	 * vary depending on whether the printer aligns bit 0 at the top of
	 * a line or the bottom.
	 */
	prtCfg = qual == DRAFT ? &Config.draftPrtCfg : &Config.finalPrtCfg;
	prtBitMskTbl = prtCfg->bit0Dn ? prtBitMsk0Dn : prtBitMsk0Up;

	/* For each line that we'll print, construct printer bytes by
	 * taking 8 vertical bits from the screen.
	 */
	for (ln = 0; ln < maxY / BITSPERBYTE; ++ln) {
		pLine = line;
		p = (struct scrBits *)&pScr[SCSMAXX * ln];
		for (col = 0; col < SCSMAXX; ++col) {
			scrBitMsk = scrBitMskTbl[col & (BITSPERBYTE - 1)];

			/* Here's how this ugly code works. The result of
			 * the "!=" (0 or 1) is used to index the
			 * bit mask in prtBitMskTbl, based on whether the
			 * screen bit is set.
			 */
			*pLine++ =
			    prtBitMskTbl[0 + ((p->bit0 & scrBitMsk) != 0)] |
			    prtBitMskTbl[2 + ((p->bit1 & scrBitMsk) != 0)] |
			    prtBitMskTbl[4 + ((p->bit2 & scrBitMsk) != 0)] |
			    prtBitMskTbl[6 + ((p->bit3 & scrBitMsk) != 0)] |
			    prtBitMskTbl[8 + ((p->bit4 & scrBitMsk) != 0)] |
			    prtBitMskTbl[10 + ((p->bit5 & scrBitMsk) != 0)] |
			    prtBitMskTbl[12 + ((p->bit6 & scrBitMsk) != 0)] |
			    prtBitMskTbl[14 + ((p->bit7 & scrBitMsk) != 0)];

			/* Advance to the next screen byte only if all the
			 * bits in this one have been exhausted.
		 	 */
			if ((col & (BITSPERBYTE - 1)) == BITSPERBYTE - 1) {
				p = (struct scrBits *)((long)p + 1);
			}
		}
		if (prtLine(line, qual) == CANCEL) {
			return (CANCEL);
		}
	}

	return (DONE);
}

/* prtLine: Print a graphics line buffer in a device-independent manner. */
int prtLine(line, qual)
unsigned char *line;
int qual;
{
	register unsigned char *p;
	unsigned char c;
	int len;
	register PRTCONFIG *prtCfg;
	extern CONFIG Config;
	int prtBlk(), finalPrtBlk(), prtStartStr();

	prtCfg = qual == DRAFT ? &Config.draftPrtCfg : &Config.finalPrtCfg;

	/* Print the line start string. */
	if (prtStartStr(prtCfg, line, qual, &len) == CANCEL) {
		return (CANCEL);
	}

	/* Print the graphic line. */
	if (qual == DRAFT) {
		if (prtBlk(line, len) == CANCEL) {
			return (CANCEL);
		}
	}
	else {
		if (finalPrtBlk(line, len, FALSE) == CANCEL) {
			return (CANCEL);
		}

		/* Print the line again, 1 dot-height lower. Also, jam a
		 * column of empty dots in at the beginning. This will
		 * result in more uniform lines for printers that just
		 * print every other dot at this density.
		 */
		if (prtBlk(prtCfg->vertDotStr, prtCfg->vertDotLen) ==
		    CANCEL) {
			return (CANCEL);
		}
		if (prtStartStr(prtCfg, line, qual, &len) == CANCEL) {
			return (CANCEL);
		}
		if (finalPrtBlk(line, len, TRUE) == CANCEL) {
			return (CANCEL);
		}
	}

	/* Move to the next line. */
	if (prtBlk(prtCfg->lnEndStr, prtCfg->lnEndLen) == CANCEL) {
		return (CANCEL);
	}

	return (DONE);
}

/* prtStartStr:	Print the graphic line start string. */
int prtStartStr(prtCfg, line, qual, len)
PRTCONFIG *prtCfg;
unsigned char *line;
int qual;
register int *len;
{
	register unsigned char *p;
	unsigned char lnLenBfr[2];
	int prtBlk();

	if (prtBlk(prtCfg->lnStartStr, prtCfg->lnStartLen) == CANCEL) {
		return (CANCEL);
	}

	*len = qual == DRAFT ? SCSMAXX : SCSMAXX * FINALDOTRPT;

	/* Format the line length as specified in the configuration. */
	if (prtCfg->apndLnSz) {

		/* Determine the length of the graphic line by locating the
		 * last nonzero byte in the line.
		 */
		p = &line[SCSMAXX - 1];
		for (*len = SCSMAXX; *len > 0 && *p == 0x00; --(*len)) {
			--p;
		}
		if (qual == FINAL) {
			*len *= FINALDOTRPT;
		}
		if (prtCfg->lnSzLsbMsb) {
			lnLenBfr[0] = LOW8(*len);
			lnLenBfr[1] = HI8(*len);
		}
		else {
			lnLenBfr[0] = HI8(*len);
			lnLenBfr[1] = LOW8(*len);
		}
		if (prtBlk(lnLenBfr, sizeof(lnLenBfr)) == CANCEL) {
			return (CANCEL);
		}
	}

	return (DONE);
}

/* prtBlk: Send a block of bytes to the printer. */
int prtBlk(pBlk, n)
register unsigned char *pBlk;
register int n;
{
	int prtByte();

	while (n-- > 0) {
		if (prtByte(*pBlk++) == CANCEL) {
			return (CANCEL);
		}
	}
	return (DONE);
}

/* finalPrtBlk: Send a block of graphic bytes to the printer, performing
 *	 some magic for final mode.
 */
int finalPrtBlk(pBlk, n, pad)
unsigned char *pBlk;
register int n;
BOOLEAN pad;
{
	int prtByte();
	register int dot;

	/* If this line is to be padded, jam a column of blank dots at
	 * the beginning.
	 */
	if (pad) {
		if (prtByte(0x0) == CANCEL) {
			return (CANCEL);
		}
		--n;
	}
	while (n > 0) {
		for (dot = 0; dot < FINALDOTRPT && n > 0; ++dot) {
			if (prtByte(*pBlk) == CANCEL) {
				return (CANCEL);
			}
			--n;
		}
		++pBlk;
	}

	return (DONE);
}

/* prtNewPage: Move the printer to the top of the next page. */
int prtNewPage(qual)
int qual;
{
	register PRTCONFIG *prtCfg;
	extern CONFIG Config;
	int prtBlk();

	prtCfg = qual == DRAFT ? &Config.draftPrtCfg : &Config.finalPrtCfg;
	if (prtBlk(prtCfg->ffStr, prtCfg->ffLen) == CANCEL) {
		return (CANCEL);
	}

	return (DONE);
}

/* prtByte: Send a byte to the printer. */
int prtByte(b)
register unsigned char b;
{
	char str[MAXSTR];
	register BOOLEAN cancel, printed;
	register unsigned char *logScr, *physScr;

	cancel = printed = FALSE;
	do {
		if (!Cprnout(b)) {

			/* We have to draw an alert. The logical screen
			 * has been set to a buffer containing the part
			 * of the page being drawn. Temporarily set the
			 * logical screen back to the physical screen.
			 */
			logScr = (unsigned char *)Logbase();
			physScr = (unsigned char *)Physbase();
			Setscreen(physScr, physScr, -1);
			sprintf(str, "[%s][%s|%s|%s][%s|%s]", "2",
			    "The printer isn't responding.",
			    "Please place it online or",
			    "select Cancel to abort.",
			    "Retry", "Cancel");
			if (form_alert(1, str) == 2) {
				cancel = TRUE;
			}
			Setscreen(logScr, physScr, -1);
		}
		else {
			printed = TRUE;
		}
	} while (!cancel && !printed);

	return (cancel ? CANCEL : DONE);
}
