/* InstSST: ScoreST Installation Program
 * phil comeau 27-jul-88
 * last edited 14-oct-89 0004
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <strings.h>
#include <ctype.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <mylib.h>
#include "graph.h"
#include "scoredef.h"
#include "config.h"

#define MAXCMDSZ 20			/* printer command size limit */
#define MAXLINE 20
#define SVCFGFILE "scorebak.cfg"	/* backup config file name */
#define ESC '\033'

main()
{
	CONFIG cfg;
	BOOLEAN getYN(), getCmd(), getLine(), yn;
	char s[MAXLINE];
	int fd;
	extern char Version[];

	printf("\n\n\nInstSST - Instalation program for ScoreST %s\n",
	    Version);

	printf("\n\nInstSST configures a printer for use by ScoreST. To\n");
	printf("use InstSST, you answer questions about the commands your\n");
	printf("printer requires to print graphics. Read INSTSST.TXT\n");
	printf("for more information.\n\n");
	printf("InstSST will create a file called %s, containing the\n",
	    CFGFILE);
	printf("printer configuration information. If a file by that\n");
	printf("exists, it will be renamed to %s.\n\n", SVCFGFILE);

	/* See if we've scared anybody away. */
	if (!getYN("Do you want to continue? (Y/n): ", TRUE, &yn)) {
		exit(1);
	}
	if (!yn) {
		exit(1);
	}

	printf("\nDefine printer initialization command\n");
	printf("This command is sent to the printer before a score is ");
	printf("printed.\n");
	bzero(cfg.draftPrtCfg.initStr, MAXCMDSZ);
	cfg.draftPrtCfg.initLen = 0;
	if (!getCmd("Draft-mode Initialization command",
	    cfg.draftPrtCfg.initStr, &cfg.draftPrtCfg.initLen)) {
		exit(1);
	}
	bcopy(cfg.draftPrtCfg.initStr, cfg.finalPrtCfg.initStr, MAXCMDSZ);
	cfg.finalPrtCfg.initLen = cfg.draftPrtCfg.initLen;
	if (!getCmd("Final-mode Initialization command",
	    cfg.finalPrtCfg.initStr, &cfg.finalPrtCfg.initLen)) {
		exit(1);
	}

	printf("\nDefine graphic line start command\n");
	printf("This command is sent to the printer before each line of ");
	printf("graphics.\n");
	bzero(cfg.draftPrtCfg.lnStartStr, MAXCMDSZ);
	cfg.draftPrtCfg.lnStartLen = 0;
	if (!getCmd("Draft-mode Graphic line start command",
	    cfg.draftPrtCfg.lnStartStr, &cfg.draftPrtCfg.lnStartLen)) {
		exit(1);
	}
	bcopy(cfg.draftPrtCfg.lnStartStr, cfg.finalPrtCfg.lnStartStr,
	    MAXCMDSZ);
	cfg.finalPrtCfg.lnStartLen = cfg.draftPrtCfg.lnStartLen;
	if (!getCmd("Final-mode Graphic line start command",
	    cfg.finalPrtCfg.lnStartStr, &cfg.finalPrtCfg.lnStartLen)) {
		exit(1);
	}

	printf("\nDefine bit 0 position\n");
	printf("Bit 0 may be drawn at the top or bottom of each graphic ");
	printf("line.\n");
	do {
		printf("Bit 0 position: Is bit 0 at the Top or Bottom ");
		printf("of the print line? (T/B): ");
		fflush(stdout);
		if (!getLine(s)) {
			exit(1);
		}
		s[0] = toupper(s[0]);
		if (s[0] != 'T' && s[0] != 'B') {
			printf("Please enter 'T' or 'B'.\n");
		}
	} while (s[0] != 'T' && s[0] != 'B');
	cfg.draftPrtCfg.bit0Dn = cfg.finalPrtCfg.bit0Dn = s[0] == 'B';

	printf("\nAppend line size\n");
	printf("ScoreST can append the calculated size of each graphic line\n");
	printf("to the graphic line start command. This line size is\n");
	printf("always two bytes long.\n");
	if (!getYN("Append line size in draft mode? (Y/N): ", TRUE, &yn)) {
		exit(1);
	}
	cfg.draftPrtCfg.apndLnSz = yn;
	if (!getYN("Append line size in final mode? (Y/N): ", TRUE, &yn)) {
		exit(1);
	}
	cfg.finalPrtCfg.apndLnSz = yn;

	if (cfg.draftPrtCfg.apndLnSz || cfg.finalPrtCfg.apndLnSz) {
		printf("\nDefine line size byte ordering\n");
		printf("The line size appended by ScoreST can have its ");
		printf("bytes ordered\n(LSB,MSB) or (MSB,LSB).\n");
		printf("\tLSB = Least Significant Byte\n");
		printf("\tMSB = Most Signficant Byte\n");
		do {
			printf("LSB/MSB: (LSB,MSB) order (L) or (MSB,LSB) ");
			printf("order (M) (L/M): ");
			fflush(stdout);
			if (!getLine(s)) {
				exit(1);
			}
			s[0] = toupper(s[0]);
			if (s[0] != 'L' && s[0] != 'M') {
				printf("Please enter 'L' or 'M'.\n");
			}
		} while (s[0] != 'L' && s[0] != 'M');
		cfg.draftPrtCfg.lnSzLsbMsb = cfg.finalPrtCfg.lnSzLsbMsb =
		    s[0] == 'L';
	}

	printf("\nDefine vertical motion command\n");
	printf("This command directs the printer to move the paper\n");
	printf("forward by the smallest possible distance. This distance\n");
	printf("should be less than the height of a dot. The Final mode\n");
	printf("line end command will advance the paper the rest of the\n");
	printf("way to the top of the next line.\n");
	bzero(cfg.finalPrtCfg.vertDotStr, MAXCMDSZ);
	cfg.draftPrtCfg.vertDotLen = cfg.finalPrtCfg.vertDotLen = 0;
	if (!getCmd("Final-mode vertical motion command",
	    cfg.finalPrtCfg.vertDotStr, &cfg.finalPrtCfg.vertDotLen)) {
		exit(1);
	}

	printf("\nDefine graphic line end command\n");
	printf("This command is sent to the printer following each\n");
	printf("graphic line. Normally, it would tell the printer to\n");
	printf("perform a carriage return and advance the paper by the\n");
	printf("height of an 8-dot graphic line. In Final mode, the\n");
	printf("command must take into account the distance already\n");
	printf("advanced by the vertical motion command.\n");
	bzero(cfg.draftPrtCfg.lnEndStr, MAXCMDSZ);
	cfg.draftPrtCfg.lnEndLen = 0;
	if (!getCmd("Draft-mode graphic line end command",
	    cfg.draftPrtCfg.lnEndStr, &cfg.draftPrtCfg.lnEndLen)) {
		exit(1);
	}
	bcopy(cfg.draftPrtCfg.lnEndStr, cfg.finalPrtCfg.lnEndStr,
	    MAXCMDSZ);
	cfg.finalPrtCfg.lnEndLen = cfg.draftPrtCfg.lnEndLen;
	if (!getCmd("Final-mode graphic line end command",
	    cfg.finalPrtCfg.lnEndStr, &cfg.finalPrtCfg.lnEndLen)) {
		exit(1);
	}

	printf("\nDefine new page command\n");
	printf("This command directs the printer to advance to the top\n");
	printf("of the next page. This command isn't needed if your\n");
	printf("printer's vertical dot density is 72 dpi and your paper\n");
	printf("height is 11 inches.\n");
	bzero(cfg.draftPrtCfg.ffStr, MAXCMDSZ);
	cfg.draftPrtCfg.ffLen = 0;
	if (!getCmd("Draft-mode new page command",
	    cfg.draftPrtCfg.ffStr, &cfg.draftPrtCfg.ffLen)) {
		exit(1);
	}
	bcopy(cfg.draftPrtCfg.ffStr, cfg.finalPrtCfg.ffStr,
	    MAXCMDSZ);
	cfg.finalPrtCfg.ffLen = cfg.draftPrtCfg.ffLen;
	if (!getCmd("Final-mode new page command",
	    cfg.finalPrtCfg.ffStr, &cfg.finalPrtCfg.ffLen)) {
		exit(1);
	}

	printf("\nDefine printer reset command\n");
	printf("This command resets the printer back to its initial\n");
	printf("state. It is sent after a score is printed.\n");
	bzero(cfg.draftPrtCfg.termStr, MAXCMDSZ);
	cfg.draftPrtCfg.termLen = 0;
	if (!getCmd("Draft-mode printer reset command",
	    cfg.draftPrtCfg.termStr, &cfg.draftPrtCfg.termLen)) {
		exit(1);
	}
	bcopy(cfg.draftPrtCfg.termStr, cfg.finalPrtCfg.termStr,
	    MAXCMDSZ);
	cfg.finalPrtCfg.termLen = cfg.draftPrtCfg.termLen;
	if (!getCmd("Final-mode printer reset command",
	    cfg.finalPrtCfg.termStr, &cfg.finalPrtCfg.termLen)) {
		exit(1);
	}

	printf("\n");
	if (!getYN("Do you want to save the configuration? (Y/N): ",
	    TRUE, &yn)) {
		exit(1);
	}
	if (yn) {
		if ((fd = Fopen(CFGFILE, 0)) >= 0) {
			printf("Renaming existing %s to %s\n",
			    CFGFILE, SVCFGFILE);
			Fclose(fd);
			Fdelete(SVCFGFILE);
			Frename(0, CFGFILE, SVCFGFILE);
		}
		if ((fd = Fcreate(CFGFILE, 0)) < 0) {
			printf("%d error creating %s\n", fd, CFGFILE);
			exit(1);
		}
		if (Fwrite(fd, (long)sizeof(cfg), &cfg) != sizeof(cfg)) {
			printf("Error writing configuration file.\n");
			printf("Disk may be full.\n");
			exit(1);
		}
		Fclose(fd);
	}
	exit(0);
}

BOOLEAN getCmd(msg, cmd, size)
register char *msg, *cmd;
register int *size;
{
	register int i;
	register char *pCmd;
	BOOLEAN yn, getNum(), getYN();

	do {
		do {
			printf("%s: Enter command size ", msg);
			printf("(in bytes) (%d): ", *size);
			if (!getNum(size)) {
				return (FALSE);
			}
			if (*size < 0 || *size > MAXCMDSZ) {
				printf("Command string size must be ");
				printf("between 0 and %d\n", MAXCMDSZ);
			}
		} while (*size < 0 || *size > MAXCMDSZ);

		pCmd = cmd;
		for (i = 0; i < *size; ++i) {
			printf("%s: Enter byte %d (0x%02x): ", msg, i + 1,
			    *pCmd & 0xff);
			if (!getByte(pCmd++)) {
				break;
			}
		}
		if (!getYN("Is this Ok? (Y/N): ", TRUE, &yn)) {
			return (FALSE);
		}
	} while (!yn);

	return (TRUE);
}

BOOLEAN getByte(pByte)
register char *pByte;
{
	char s[MAXLINE];
	register char *p;
	int v;
	BOOLEAN getLine();

	fflush(stdout);
	if (!getLine(s)) {
		return (FALSE);
	}
	p = s;
	switch (*p) {

	case '\0':
		/* remains unchanged */
		break;

	case '\'':
		*pByte = *(++p);
		break;

	case '0':
		if (toupper(*(p + 1)) == 'X') {
			sscanf(p + 2, "%x", &v);
		}
		else {
			sscanf(p, "%o", &v);
		}
		*pByte = v;
		break;

	case '^':
		*pByte = toupper(*(p + 1)) - 0x40;
		break;

	default:
		sscanf(p, "%d", &v);
		*pByte = v;
		break;
	}

	return (TRUE);
}

BOOLEAN getNum(n)
register int *n;
{
	char s[MAXLINE];
	BOOLEAN getLine();

	fflush(stdout);
	if (!getLine(s)) {
		return (FALSE);
	}

	/* *n remains unchanged if <cr> entered */
	if (s[0] != '\0') {
		if (toupper(s[1]) == 'X') {
			sscanf(&s[2], "%x", n);
		}
		else {
			sscanf(s, "%o", n);
		}
	}
	else {
		sscanf(s, "%d", n);
	}

	return (TRUE);
}

BOOLEAN getLine(s)
register char *s;
{
	register int i;
	register char c;
	register BOOLEAN eol;

	eol = FALSE;
	for (i = 0; i < MAXLINE - 1 && !eol; ++i) {
		c = Cconin() & 0xff;
		if (c == '\r') {
			eol = TRUE;
		}
		else if (c == ESC) {
			return (FALSE);
		}
		else if (c == '\b') {
			if (i > 0) {
				--s;
				--i;
			}
		}
		else {
			*s++ = c;
		}
	}
	*s = '\0';
	Cconout('\n');

	return (TRUE);
}

BOOLEAN getYN(msg, dflt, yn)
char *msg;
register BOOLEAN dflt, *yn;
{
	char s[MAXLINE];
	BOOLEAN getLine();

	do {
		printf(msg);
		fflush(stdout);
		if (!getLine(s)) {
			return (FALSE);
		}
		s[0] = toupper(s[0]);
		if (s[0] != 'Y' && s[0] != 'N' && s[0] != '\0') {
			printf("Please enter 'Y' or 'N'.\n");
		}
	} while (s[0] != 'Y' && s[0] != 'N' && s[0] != '\0');

	if (s[0] == '\0') {
		*yn = dflt;
	}
	else {
		*yn = s[0] == 'Y';
	}

	return (TRUE);
}
