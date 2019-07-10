/*
 * vlog: printout gunk for each user on the system
 *
 * written 1987-1988? By Eric A. Griff
 */
#include "ctdl.h"
#include "config.h"
#include "log.h"

extern struct config	cfg;
extern struct logBuffer	logBuf;
extern struct lTable	*logTab;

int logfl;	/* log file descriptor */

#define cn(cond) (cond) ? "Yes" : "No"

char *program = "vlog";

main()
{
    int i;
    char fn[50];
    extern char VERSION[];
    
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (!readSysTab(FALSE))
	exit(1);

    initlogBuf(&logBuf);

    ctdlfile(fn, cfg.sysdir, "ctdllog.sys");
    if ((logfl = dopen(fn, O_RDONLY)) < 0)
	crashout("Can't open %s\n", fn);

    printf("%-17.16s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-5s%-4s%-5s%-4s\n",
	"NAME","LF","EXP","SYS","AID","TIM","OLD","NET","MAI","DOR","WID","NUL",
	"CRED","CAL","TIME","CLO");
    for (i=0; i<cfg.logsize; i++) {
        getlog(&logBuf,i,logfl);
        if readbit(logBuf,uINUSE)
            showlog();
    }

    dclose(logfl);
    killlogBuf(&logBuf);

    if (fromdesk())
	hitkey();
}

showlog()
{
    printf("%-17.16s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4s%-4d%-4d%-5d%-4d%-5d%-4d\n",
	logBuf.lbname,
	cn(readbit(logBuf,uLINEFEEDS)), cn(readbit(logBuf,uEXPERT)),
	cn(readbit(logBuf,uSYSOP)), cn(readbit(logBuf,uAIDE)),
	cn(readbit(logBuf,uSHOWTIME)), cn(readbit(logBuf,uLASTOLD)),
	cn(readbit(logBuf,uNETPRIVS)), cn(readbit(logBuf,uMAILPRIV)),
	cn(readbit(logBuf, uDOORPRIV)),
	logBuf.lbwidth, 0xff & logBuf.lbnulls, logBuf.credit,
	logBuf.lbcalls, logBuf.lbtime, logBuf.lbclosecalls);
}

