/*
 * neterror.c -- error logging to a file for citadel
 *
 * 88Jul30 orc	created.
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */
#include <stdarg.h>

FILE *errfile = NULL;			/* error logfile		*/
PATHBUF logfile;			/* the name of ^^^		*/

void
neterror(int hup, char *format, ...)
{
    va_list arg;

    if (hup)
	hangup();

    if (errfile == NULL) {
	ctdlfile(logfile, cfg.netdir, "$logfile");
	dunlink(logfile);
	if (errfile = safeopen(logfile,"wb")) {
	    fputc(0xff,errfile);
	    fputc(0,   errfile);
	    fputc('M', errfile);
	}
	else {
	    fprintf(stderr, "Logfile open failure!\n");
	    return;
	}
    }

    if (rmtname[0])
	fprintf(errfile, "While netting with %s: ", rmtname);
    va_start(arg, format);
    vfprintf(errfile, format, arg);
    va_end(arg);
    fputc('\r', errfile);
    fflush(errfile);
}
