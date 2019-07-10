/*
 * calllog.c -- handles Citadel call log
 */

/*
 * 88Sep15 orc	Create record() function, put download info into filelog.sys
 * 87Dec30 orc	Baudrate registration fixed
 * 87Dec15 orc	File download auditing cleaned up a bit.
 * 87Aug28 orc	New clock scheme.
 * 87Jul25 orc	toss old baud rate figuring....
 * 86Mar07 HAW	New users and .ts signals.
 * 86Feb09 HAW	System up and down times.
 * 86Jan22 HAW	Set extern var so entire system knows baud.
 * 85Dec08 HAW	Put blank lines in file.
 * 85Nov?? HAW	Created.
 */

#include "ctdl.h"
#include "calllog.h"
#include "config.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

#include <stdarg.h>

static char newuser, evil;
static LABEL person = { 0 };
static int lastdy, curBaud = 0;
static int userBaud;

/*
 * record() statistics in a logfile
 */
static void
record(char *file, char *format, ...)
{
    PATHBUF fn;
    FILE *fd;
    va_list arg;

    ctdlfile(fn, cfg.auditdir, "%slog.sys", file);
    if (fd=safeopen(fn, "a")) {
	va_start(arg, format);
	vfprintf(fd, format, arg);
	va_end(arg);
	fclose(fd);
    }
    else
	crashout("audit failure on %slog.sys", file);
}

/*
 * logMessage() - Puts message out. Also, on date change, and first output of
 * system, insert blank line.
 */
void
logMessage(char val, char *str, char sig)
{
    LABEL x;
    char *dt;
    char *sep = "";

    if (!cfg.call_log)
	return;

    switch (val) {
	case FIRST_IN:
	    if (cfg.call_log & aEXIT)
		record("call", "\nSystem brought up %s @ %s\n",
				formDate(), tod(NO));
	    lastdy = now.tm_mday;
	    break;
	case LAST_OUT:
	    if (cfg.call_log & aEXIT)
		record("call", "System brought down %s @ %s\n",
					formDate(), tod(NO));
	    return;
	case BAUD:
	    curBaud = byteRate;
	    return;
	case L_IN:
	    strcpy(person, str);
	    newuser = sig;
	    /* if we logged in while on console, set our baudrate
	     * to zero.
	     */
	    userBaud = onConsole ? 0 : curBaud;
	    evil = NO;
	    dt = formDate();
	    if (lastdy != now.tm_mday) {
		sep = "\n";
		lastdy = now.tm_mday;
	    }
	    if (cfg.call_log & aLOGIN) {
		record("call", "%s%-20s: %s %s - ", sep, str, dt, tod(NO));
	    }
	    if (Debug)
		splitF(debuglog, "login: %s @ %s %s\n", person, dt, tod(NO));
	    break;
	case EVIL_SIGNAL:
	    evil = YES;
	    break;
	case L_OUT:
	    if (person[0] && (cfg.call_log & aLOGIN)) {
		sprintf(x, userBaud ? "%d0" : "console", curBaud);
		record("call", "%s (%s) %c %c %c\n",
			      tod(NO), x,   newuser ? newuser : ' ',
			      sig ? sig : ' ', evil ? 'E' : ' ');

	    }
	    if (Debug)
		splitF(debuglog, "logout: %s @ %s\n", person, tod(NO));
	    else
		printf("logout: %s @ %s\n", person, tod(NO));
	    person[0] = 0;
	    break;
	case READ_FILE:
	    if (cfg.call_log & aDNLOAD)
		record("file", "%s read by %s (%s @ %s)\n", str, person,
				formDate(), tod(YES));
	    break;
    }
} 
