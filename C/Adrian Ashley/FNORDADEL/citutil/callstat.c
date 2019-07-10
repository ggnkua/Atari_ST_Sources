/*
 * callstat:  Generate lotsa statistics for citadel.
 *
 * Written 1987-1988 by Royce Howland.
 *
 * DON'T RELEASE SOURCES!!!!
 */

#include "ctdl.h"
#include "calllog.h"
#include "terminat.h"
#include "config.h"
#include "citlib.h"

struct {
    unsigned hour,min;
} on,off,last;

char newuser,termstay,disconnect,preempt;
char timeout,evile,nosysop,update,docb,debug;
char ch,date[20],str[20];
int baud,dur;
FILE *safeopen(),*fp;
PATHBUF fnlog,fndat,fnstat,fncallbaud;

unsigned total,calls[24],durations[20],bauds[5],callbaud[24][5],
        nnewusers,ntermstays,ndisconnects,nnewdiscons,npreempts,
        ntimeouts,neviles;
long    totalduration,totalidle;

extern struct config    cfg;

char *program = "callstat";

main(argc,argv)
char **argv;
{
    char *p;
    extern char VERSION[];

    setbuf(stdout, NULL);
    printf("%s for Fnordadel V%s\n", program, VERSION);

    nosysop = NO;
    update = NO;
    docb = NO;
    debug = NO;
    while (argc > 1) {
	--argc;
	++argv;
	p = *argv;
	if (*p == '-') {	/* Is it a flag of some kind? */
	    while (*++p)
		switch (tolower(*p)) {
		    case 'c':
			docb = YES;
			break;
		    case 'd':
			debug = YES;
			break;
		    case 's':
			nosysop = YES;
			break;
		    case 'u':
			update = YES;
			break;
		    case 'h':
			printf("usage: callstat [-csu]\n");
			printf("       -c writes callbaud.sys\n");
			printf("       -s turns off sysConsole stats\n");
			printf("       -u deletes calllog.sys & updates calldata.sys\n");
			if (fromdesk())
			    hitkey();
			exit(0);
		}
	}
    }

    if (!readSysTab(NO)) {
	if (fromdesk())
	    hitkey();
	exit(1);
    }
    if (((cfg.call_log & aEXIT) == 0) || ((cfg.call_log & aLOGIN) == 0)) {
	printf("Sorry, but callstat currently needs system ups & downs\n");
	printf("and user logins to be recorded.\n");
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    ctdlfile(fnlog, cfg.auditdir, "calllog.sys");
/* calldata.sys moved from auditdir to sysdir by AA 89Jan31 */
    ctdlfile(fndat, cfg.sysdir, "calldata.sys");
    ctdlfile(fnstat, cfg.auditdir, "callstat.sys");
    ctdlfile(fncallbaud, cfg.auditdir, "callbaud.sys");

    last.hour = 100;
    get_data();
    munch();
    if (update) {
	dunlink(fnlog);
	write_data();
    }
    write_stat_file();
    if (fromdesk())
	hitkey();

}


file_error(file,access)
char *file,*access;
{
    printf("Can't open %s for %s!\n", file, access);
}

get_data()
{
    unsigned i,j;

    if ((fp = safeopen(fndat,"r")) == NULL) {
	date[0] = '\0';
	total = 0;
	zero_array(calls);
	zero_array(durations);
	totalduration = 0;
	totalidle = 0;
	zero_array(bauds);
	zero_array(callbaud);
	nnewusers = 0;
	ntermstays = 0;
	ndisconnects = 0;
	nnewdiscons = 0;
	npreempts = 0;
	ntimeouts = 0;
	neviles = 0;
    }
    else {
	printf("Reading cumulative data...\n");
	fscanf(fp,"%s\n",date);
	fscanf(fp,"%d\n",&total);
	for (i = 0; i <= 23; i++)
	    fscanf(fp,"%d\n",&calls[i]);
	for (i = 0; i <= 19; i++)
	    fscanf(fp,"%d\n",&durations[i]);
	fscanf(fp,"%ld\n",&totalduration);
	fscanf(fp,"%ld\n",&totalidle);
	for (i = 0; i <= 4; i++)
	    fscanf(fp,"%d\n",&bauds[i]);
	for (i = 0; i <= 23; i++)
	    for (j = 0; j <= 4; j++)
		fscanf(fp,"%d\n",&callbaud[i][j]);
	fscanf(fp,"%d\n",&nnewusers);
	fscanf(fp,"%d\n",&ntermstays);
	fscanf(fp,"%d\n",&ndisconnects);
	fscanf(fp,"%d\n",&nnewdiscons);
	fscanf(fp,"%d\n",&npreempts);
	fscanf(fp,"%d\n",&ntimeouts);
	fscanf(fp,"%d\n",&neviles);
	fclose(fp);
    }
}

baud_code(baud)
{
    if (baud == 300)
	return 1;
    else if (baud == 1200)
	return 2;
    else if (baud == 2400)
	return 3;
    else if (baud == 9600)
	return 4;
    else
	return 0;
}

find_on()       /* Scan for next user login time. */
{
    int rc;

    do {
	str[0] = '\0';
	rc = fscanf(fp,"%s ",str);
	if (debug)
	    printf("%s",str);
	/* Next if handles system down/up. */
	if ((rc == 1) && (str[0] == '@')) {
	    if (debug)
		putchar('\n');
	    if (last.hour != 100) {
		fscanf(fp,"%d:",&on.hour);
		fscanf(fp,"%d\n",&on.min);
	    }
	    else {
		fscanf(fp,"%d:",&last.hour);
		fscanf(fp,"%d\n",&last.min);
		on.hour = 100;
	    }
	    if (on.hour != 100) {
		if (last.hour > on.hour)
		    on.hour += 24;
		dur = ((on.hour * 60 + on.min) - (last.hour * 60 + last.min));
		totalidle += dur;
		last.hour = 100;
	    }
	}
    } while ((rc != EOF) && ((str[0] != ':') || (str[1] != '\0')));
    /*
       Bug: Normally, the only time the substring " : " shows up in the
	    calllog, is between a userID and the date of the login.  Thus
	    the previous while loop scans for words (i.e. a sequence of
	    characters terminated by white-space), and terminates when it
	    finds the word ": ".  Normally, this means that the date and
	    time of signon are to immediately follow.
	    However, if some userID contains the substring " : " (or ": "
	    at the start), callstat will rapidly go to heg.  More
	    stringent error-checking is needed to guard against this
	    (e.g., check to make sure that something of the form ddCccdd
	    follows the current instance of ": ", where d is a digit and
	    C/c is a character)...
    */
    if (debug)
	putchar('\n');
    if (rc == EOF)
	return NO;
    else {
	fscanf(fp,"%s ",str);	/* Skip the date */
	if (date[0] == '\0')	/* Record it if needed (first time) */
	    strcpy(date,str);
	return YES;
    }
}

get_stuff()
{
    int rc;

    fscanf(fp,"%d:",&on.hour);
    fscanf(fp,"%d - ",&on.min);
    rc = fscanf(fp,"%d:",&off.hour);
    if (rc != 1) {
	printf("\nYuck!  Your calllog.sys file is corrupted!\n");
	printf("(A user is recorded as logging in, but not out.)\n");
	printf("Please use an editor to fix things before rerunning.\n");
	fclose(fp);
	if (fromdesk())
	    hitkey();
	exit(1);
    }
    fscanf(fp,"%d (",&off.min);
    rc = fscanf(fp,"%d)",&baud);
    if (rc == 0) {                  /* Login was at sysConsole */
	baud = 0;
	fscanf(fp,"%s)",str);
    }
    baud = baud_code(baud);
    newuser = NO;
    termstay = NO;
    disconnect = NO;
    preempt = NO;
    timeout = NO;
    evile = NO;
    do {
	ch = getc(fp);
	switch (ch) {
	case '+' :
	    newuser = YES;
	    break;
	case tSTAY :
	    termstay = YES;
	    break;
	case tDISCONNECT :
	    disconnect = YES;
	    break;
	case tEVENTPUNT :
	    preempt = YES;
	    break;
	case tTIMEOUT :
	    timeout = YES;
	    break;
	case tEVIL :
	    evile = YES;
	default :
	    break;
	}
    } while (ch != '\n');
}

munch()
{
    if ((fp = safeopen(fnlog,"r")) == NULL) {
	file_error("calllog.sys","input");
	return;
    }
    printf("Munching...\n");
    while (find_on()) {
	get_stuff();
	total++;
	printf("\r%d",total);
	calls[on.hour]++;
	if (last.hour > on.hour)
	    on.hour += 24;
	dur = ((on.hour * 60 + on.min) - (last.hour * 60 + last.min));
	totalidle += dur;
	if (on.hour >= 24)
	    on.hour -= 24;
	last.hour = off.hour;
	last.min = off.min;
	if (on.hour > off.hour)
	    off.hour += 24;
	dur = ((off.hour * 60 + off.min) - (on.hour * 60 + on.min));
	totalduration += dur;
	dur /= 15;
	if (dur > 19)
	    dur = 19;
	durations[dur]++;
	bauds[baud]++;
	callbaud[on.hour][baud]++;
	if (newuser)
	    nnewusers++;
	if (termstay)
	    ntermstays++;
	if (disconnect) {
	    ndisconnects++;
	    if (newuser)
		nnewdiscons++;
	}
	if (preempt)
	    npreempts++;
	if (timeout)
	    ntimeouts++;
	if (evile)
	    neviles++;
    }
    fclose(fp);
    putchar('\n');
}

write_data()
{
    int i, j;

    if ((fp = safeopen(fndat,"w")) == NULL)
	file_error("calldata.sys","output");
    else {
	printf("Writing cumulative data...\n");
	fprintf(fp,"%s\n",date);
	fprintf(fp,"%d\n",total);
	for (i = 0; i <= 23; i++)
	    fprintf(fp,"%d\n",calls[i]);
	for (i = 0; i <= 19; i++)
	    fprintf(fp,"%d\n",durations[i]);
	fprintf(fp,"%ld\n",totalduration);
	fprintf(fp,"%ld\n",totalidle);
	for (i = 0; i <= 4; i++)
	    fprintf(fp,"%d\n",bauds[i]);
	for (i = 0; i <= 23; i++)
	    for (j = 0; j <= 4; j++)
		fprintf(fp,"%d\n",callbaud[i][j]);
	fprintf(fp,"%d\n",nnewusers);
	fprintf(fp,"%d\n",ntermstays);
	fprintf(fp,"%d\n",ndisconnects);
	fprintf(fp,"%d\n",nnewdiscons);
	fprintf(fp,"%d\n",npreempts);
	fprintf(fp,"%d\n",ntimeouts);
	fprintf(fp,"%d\n",neviles);
	fclose(fp);
    }
}

write_hist_bar(stat,factor)
float factor;
{
    int i;

    fprintf(fp,": ");
    if ((stat / factor) >= 1.0)
	for (i = 1; i <= (int) (stat / factor); i++)
	    fprintf(fp,"*");
    else if (stat >= 1)
	fprintf(fp,"*");
    fprintf(fp," (%d)",stat);	/* line added by AA 89Jan16 */
    fprintf(fp,"\n");
    fflush(fp);
}


write_a_stat(desc,stat)
char *desc;
unsigned stat;
{
    fprintf(fp,"%s: %d (%d%%)\n",desc,stat,stat * 100 / total);
}

write_stat_file()
{
    int i,j,max;
    float factor;

    dunlink(fnstat);
    if ((fp = safeopen(fnstat,"w")) == NULL)
	file_error("callstat.sys","output");
    else {
	printf("Writing stat file...\n");
	fprintf(fp,"\n The Antithesystem Memorial Histogram.\n\n");
	fprintf(fp," The following statistics have been collected since %s.\n\n",date);
	fprintf(fp," Total number of calls represented: %d\n\n",total);
	max = 25;
	for (i = 0; i <= 23; i++)
	    if (calls[i] > max)
		max = calls[i];
	factor = max / 25.0;
	fprintf(fp," Usage histogram (each number represents an hour of the day, each '*'\n");
	fprintf(fp,"represents about %d calls at that hour):\n",(int) factor);
	for (i = 0; i <= 23; i++) {
	    fprintf(fp,"%3d",i);
	    write_hist_bar(calls[i],factor);
	}
	fprintf(fp,"\n");
	max = 25;
	for (i = 0; i <= 19; i++)
	    if (durations[i] > max)
		max = durations[i];
	factor = max / 25.0;
	fprintf(fp," Call duration histogram (each number represents a call duration of at\n");
	fprintf(fp,"most that much time, each '*' represents about %d calls of that duration):\n",(int) factor);
	for (i = 0; i <= 19; i++) {
	    fprintf(fp,"%2d:%d",(i + 1) * 15 / 60,(i + 1) * 15 % 60);
	    if (i % 4 == 3)
		fprintf(fp,"0");
	    write_hist_bar(durations[i],factor);
	}
	fprintf(fp," The average call duration is about %ld minutes.\n",totalduration / total);
	fprintf(fp," The average idle time before/after a call is about %ld minutes.\n\n",totalidle / total);
	max = 25;
	for (i = 0; i <= 4; i++)
	    if (bauds[i] > max)
		max = bauds[i];
	factor = max / 25.0;
	fprintf(fp," Baud rate histogram (each number represents a baud rate, each '*' represents\n");
	fprintf(fp,"about %d calls at that baud rate):\n",(int) factor);
	for (i = 0 + nosysop; i <= cfg.sysBaud + 1; i++) {
	    switch (i) {
	    case 0 :
		fprintf(fp,"  sys");
		break;
	    case 1 :
		fprintf(fp,"  300");
		break;
	    case 2 :
		fprintf(fp," 1200");
		break;
	    case 3 :
		fprintf(fp," 2400");
		break;
	    case 4 :
		fprintf(fp," 9600");
		break;
	    }
	    write_hist_bar(bauds[i],factor);
	}
	fprintf(fp,"\n");
	write_a_stat(" Number of new users",nnewusers);
	write_a_stat(" Number of uses of .T(erminate) S(tay)",ntermstays);
	write_a_stat(" Number of disconnects",ndisconnects);
	write_a_stat(" Number of new user disconnects",nnewdiscons);
	write_a_stat(" Number of preemptions",npreempts);
	write_a_stat(" Number of time-outs",ntimeouts);
	write_a_stat(" Number of EVILE users",neviles);
	fclose(fp);
    }
    if (docb != YES)
	return;
    dunlink(fncallbaud);
    if ((fp = safeopen(fncallbaud,"w")) == NULL)
	file_error("callbaud.sys","output");
    else {
	printf("Writing call/baud file...\n");
	fprintf(fp,"\n");
	fprintf(fp," The following statistics have been collected since %s.\n\n",date);
	fprintf(fp," Total number of calls represented: %d\n\n",total);
	max = 25;
	for (i = 0; i <= 23; i++)
	    for (j = 0; j <= 4; j++)
		if (callbaud[i][j] > max)
		    max = callbaud[i][j];
	factor = max / 25.0;
	fprintf(fp," Usage/baud rate histogram (each pair of numbers represents an hour of the\n");
	fprintf(fp,"day and a baud rate, each '*' represents about %d calls at that hour and\n",(int) factor);
	fprintf(fp,"baud rate):\n");
	for (i = 0; i <= 23; i++)
	    for (j = 0 + nosysop; j <= cfg.sysBaud + 1; j++) {
		fprintf(fp,"%3d,",i);
		switch (j) {
		case 0 :
		    fprintf(fp," sys");
		    break;
		case 1 :
		    fprintf(fp," 300");
		    break;
		case 2 :
		    fprintf(fp,"1200");
		    break;
		case 3 :
		    fprintf(fp,"2400");
		    break;
		case 4 :
		    fprintf(fp,"9600");
		    break;
		}
		write_hist_bar(callbaud[i][j],factor);
	    }
	fclose(fp);
    }
}
