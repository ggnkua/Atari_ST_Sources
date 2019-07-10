/*
 * Logedit.c -- Userlog editor
 *
 * 88Jul17 orc	Modify log editing selection.
 * 87Apr07 orc	modified for 2.??
 * 87Mar01 orc	hacked up for STadel
 * 85Nov16 HAW	Modified for MS-DOS libraries.
 * 85Aug10 HAW	Created.
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

/*
 * getNumber()	Gets number from console
 * getString()	Gets string from console
 * logSum()	Sums up the log for logTab
 * main()	Main controller
 */

int logfl;		 		/* log file descriptor		*/
char *program = "logedit";

/*
 * getString() -- gets a string from the user
 */
void
getString(char *prompt, char *buf, int lim)
{
    char c;
    int  i;

    if(strlen(prompt) > 0)
	printf("%s: ", prompt, lim);

    i = 0;
    while ( (c = getch()) != '\r') {
	/* handle delete chars: */
	if (c == '\b') {
	    if (i > 0) {
		i--;
		fputs("\b \b", stdout);
	    }
	    else
		putchar(BELL);
	}
	else if (i < lim) {
	    putchar((c<' ')?'@':c);
	    buf[i++] = c;
	}
	else
	    putchar(BELL);
    }
    buf[i] = 0;
    putchar('\n');
}

/*
 * editlog() - edit an account.
 */
int
editlog(void)
{
    LABEL user;
    LABEL tmp;
    int   account;
    char  c;
    int   idx, tHash;

    getString("Username or log #", user, NAMESIZE);
    if (strlen(user) < 1)
	return NO;

    for (account=idx=0; user[idx]; idx++)
	if (isdigit(user[idx]))
	    account = (account*10) + (user[idx]-'0');
	else {
	    account = -1L;
	    break;
	}

    if (account >= 0 && account < cfg.logsize) {
	getlog(&logBuf, account, logfl);
	if (!readbit(logBuf,uINUSE)) {
	    puts("Account not in use");
	    return YES;
	}
    }
    else if ((account=getnmlog(user, &logBuf, logfl)) == ERROR) {
	puts("No such person");
	return YES;
    }

    do {
	printf("Edit (%s): ", logBuf.lbname);
	switch (c=toupper(getch())) {
	case 'N':
	    getString("new name", tmp, NAMESIZE);
	    if (strlen(tmp) > 0) {
		if (!stricmp(tmp, "Sysop") || strpbrk(tmp, "%!@")) {
		    puts("Illegal character in name.");
		    break;
		}
		tHash = hash(tmp);
		for (idx=0; idx<cfg.logsize; idx++)
		    if (readbit(logBuf,uINUSE) && idx != account
				    && tHash == logTab[idx].ltnmhash) {
			puts("Name in use.\n");
			break;
		    }
		if (idx >= cfg.logsize) {
		    strcpy(logBuf.lbname, tmp);
		    logTab[account].ltnmhash = tHash;
		    putlog(&logBuf, account, logfl);
		}
	    }
	    break;
	case 'P':
	    getString("new password", tmp, NAMESIZE);
	    if (strlen(tmp) > 2) {
		tHash = hash(tmp);
		for (idx=0; idx<cfg.logsize; idx++)
		    if (readbit(logBuf,uINUSE) && idx != account
			    && tHash == logTab[idx].ltpwhash) {
			puts("Bad password.");
			break;
		    }
		if (idx>=cfg.logsize) {
		    strcpy(logBuf.lbpw, tmp);
		    logTab[account].ltpwhash = tHash;
		    putlog(&logBuf, account, logfl);
		}
	    }
	    break;
	case 'K':
	    printf("Kill account; Confirm (Y/N): ");
	    if (toupper(getch()) == 'Y') {
		puts("Yes");
		clear(logBuf,uINUSE);	/* replaces zero_struct(logBuf); AA */
		putlog(&logBuf, account, logfl);
		c = 'Q';
	    }
	    else
		puts("No");
	    break;
	case 'Q':
	    puts("Quit");
	    break;
	default:
	    puts("?");
	case '?':
	    printf("\nN)ame change\nP)assword change\n");
	    printf("K)ill account\nQ)uit\n");
	    break;
	}
    } while (c != 'Q');
    return YES;
}

/*
 * logSort()
 */
int
logSort(const struct lTable *s1, const struct lTable *s2)
{
    if (s1->ltnmhash == 0 && s2->ltnmhash == 0)
	return 0;
    if (s1->ltnmhash == 0 && s2->ltnmhash != 0)
	return 1;
    if (s1->ltnmhash != 0 && s2->ltnmhash == 0)
	return -1;
    if (s1->ltnewest < s2->ltnewest)
	return 1;
    if (s1->ltnewest > s2->ltnewest)
	return -1;
    return 0;
}

/*
 * logSum() - go through the log to correct logTab
 */
void
logSum(void)
{
    int i;
    int logSort();
    int count = 0;

    dseek(logfl,0L,0);
    /* clear logTab */
    for (i = 0; i < cfg.logsize; i++)
	logTab[i].ltnewest = 0l;

    /* load logTab: */
    for (i=0; i < cfg.logsize; i++) {
	getlog(&logBuf, i, logfl);

	if readbit(logBuf,uINUSE) {
	    count++;
	    printf("log#%3d %-20s\n", i, logBuf.lbname);
	}

	/* copy relevant info into index:   */
	logTab[i].ltnewest = logBuf.lbvisit[0];
	logTab[i].ltlogSlot= i;
	if readbit(logBuf,uINUSE) {
	    logTab[i].ltnmhash = hash(logBuf.lbname);
	    logTab[i].ltpwhash = hash(logBuf.lbpw  );
	}
	else {
	    logTab[i].ltnmhash = 0;
	    logTab[i].ltpwhash = 0;
	}
    }
    printf("logInit--%d valid log entr%s\n", count, (count==1)?"y":"ies");
    qsort((void *)logTab, (size_t)cfg.logsize, sizeof(*logTab),
	(int (*)(const void *, const void *))logSort);
}

main()
{
    PATHBUF logfile;
    int p;
    extern char VERSION[];

    setbuf(stdout, NULL);	/* AA 89May03 */
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (makelock(&p) && readSysTab(TRUE)) {

	initlogBuf(&logBuf);

	ctdlfile(logfile, cfg.sysdir, "ctdllog.sys");
	if ((logfl = dopen(logfile, O_RDWR)) < 0)
	    crashout("no %s", logfile);
	while (editlog())
	    ;
	logSum();
	writeSysTab();

	killlogBuf(&logBuf);
    }
    wipelock(&p);
    if (fromdesk())
	hitkey();
}
