/*
 * popular.c -- Rough popularity estimator for rooms
 *
 * 90May09 AA	add -a flag for allowing all rooms to be shown
 * 88Feb06 orc	add -s flag to sort rooms by # messages, etc
 * 87Apr07 orc	changes for 2.??
 * 87Mar01 orc	ST hacks...
 * 86May12 HAW	Version 2.1.
 * 86Apr?? HAW	Version 2.0.
 * 86Apr07 HAW	Version 1.1.
 * 86Apr01 HAW	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "room.h"
#include "log.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"

struct cTab {
    int c_rmno;
    int c_forgot, c_messages;
};

struct cTab *countTab;

int domesg = FALSE;
int allowall = FALSE;
int sorted = FALSE;
#define	SORTSIZE	0x1
#define	SORTZED		0x2

int thisRoom = LOBBY;

int logfl;		 		/* log file descriptor		*/

char *program = "popular";
static char *LINE = "\
--------------------------------------------------------------------------";

char inNet = TRUE;
char loggedIn = FALSE;
char usingWCprotocol = 0;
int (*sendPFchar)();

void handle();

/*
 * decoy routines to avoid linker hysterics
 */
mPrintf() {}
void doCR() {}
mAbort() {}
xprintf() {}	/* because something somewhere is linking in libroute.o */

/*
 * decoy variables to avoid linker hysterics
 */
char prevChar;
struct aRoom roomBuf;		/* to avoid linking in libroom.o	*/
char echo;

/*
 * display() -- displays results
 */
void
display(int activeLogs, int activeForgots)
{
    int rover;
    int rmno;
    int PublicRoomCount = 0, ForgetCount = 0;
    char whatm = 'a';

    printf("%s @ %s\n\n", formDate(), tod(TRUE));

    printf(
"Out of a log of %d entries, %d are in use; %d (%d%%) have used [Z]forget.\n\n",
 cfg.logsize, activeLogs, activeForgots, (100* activeForgots) / activeLogs);

    printf("%35s%16s%10s\n", "# of Users", "% of Total", "% of [Z]");
    printf("%-25s%-16s%-13s%s", "Room name", "Forgetting", "User Base",
					"Users");
    if (domesg)
	printf("%15s", "Messages");
    printf("\n%s\n", LINE);

    for (rover = 0;  rover < MAXROOMS;	rover++) {
	rmno = countTab[rover].c_rmno;
	if (readbit(roomTab[rmno],INUSE) && 
		(allowall || readbit(roomTab[rmno],PUBLIC))) {
	    PublicRoomCount++;
	    ForgetCount += countTab[rover].c_forgot;
	    printf("%s%-28s%-15d%-9d%3d",
		(readbit(roomTab[rmno],PUBLIC) ? "  " : "* "),
		roomTab[rmno].rtname, countTab[rover].c_forgot,
   (activeLogs != 0) ? (100 * countTab[rover].c_forgot) / activeLogs : 0,
   (activeForgots != 0) ? (100 * countTab[rover].c_forgot) / activeForgots : 0);
	    if (domesg) printf("%14d", countTab[rover].c_messages);
	    putchar('\n');
	}
    }

    ForgetCount /= PublicRoomCount;
    printf("%s\n\n", LINE);
    printf("There are %d %srooms, ", PublicRoomCount, (allowall ? "" :
	"public "));
    printf("an average %d forgetting them (%d%% and %d%%)\n\n",
					ForgetCount,
    (activeLogs != 0) ? (100 * ForgetCount) / activeLogs : 0,
    (activeForgots != 0) ? (100 * ForgetCount) / activeForgots : 0);
}

/*
 * doMessages() -- loops thru msg file until finished.
 */
void
doMessages(void)
{
    long msg, firstMessage;
    unsigned total;	     /* For stat keeping. */
    PATHBUF msgFile;

    fprintf(stderr, "Mulching...\n");

    ctdlfile(msgFile, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = dopen(msgFile, O_RDWR)) < 0)
	crashout("no %s", msgFile);

    msgseek(0, 0);
    getmessage();
    msg = msgBuf.mbid;
    fprintf(stderr, "%ld\r", msg);
    firstMessage = msg;
    handle();
    
    total = 0;
    do {
	total++;
	getmessage();
	msg = msgBuf.mbid;
	fprintf(stderr, "%ld\r", msg);
	handle();
    } while (msg != firstMessage);

    printf("%u message%s.\n", total, (total!=1)?"s":"");
}

void
doflags(int argc, char **argv)
{
    int i;
    char *p;

    for (i = 0; i < MAXROOMS; i++) {
	countTab[i].c_rmno = i;
	countTab[i].c_forgot = countTab[i].c_messages = 0;
    }

    while (argc > 1) {
	--argc;
	if ( *(p=argv[argc]) == '-') {
	    while (*++p) switch (tolower(*p)) {
	    case 'm':
		domesg = TRUE;
		break;
	    case 'a':
		allowall = TRUE;
		break;
	    case 's':
		switch (tolower(p[1])) {
		case 'z':
		    p++;
		    sorted |= SORTZED;
		    break;
		case 'b':
		    p++;
		    sorted |= (SORTZED|SORTSIZE);
		    break;
		case 'p':
		    p++;
		default:
		    sorted |= SORTSIZE;
		    break;
		}
		break;
	    default:
		fprintf(stderr,"usage: popular [-ams[z|p|b]]\n");
		if (fromdesk())
		    hitkey();
		exit(255);
	    }
	}
    }
    if (!domesg)		/* not -m so we can't sort by size... */
	sorted &= ~SORTSIZE;
}

void
handle(void)
{
    int rover;

    for (rover = 0; rover < MAXROOMS; rover++)
	if (stricmp(roomTab[rover].rtname, msgBuf.mbroom) == 0) {
	    countTab[rover].c_messages++;
	    return;
	}
}

int
sortCount(const struct cTab *p1, const struct cTab *p2)
{
    int diff;

    diff = (sorted & SORTSIZE) ? (p2->c_messages - p1->c_messages) : 0;
    
    if (diff == 0 && (sorted & SORTZED))
	diff = p2->c_forgot - p1->c_forgot;

    return diff;
}

main(int argc, char **argv)
{
    PATHBUF logFile;
    int Index;
    int logCount = 0, forgotCount = 0;

    printf("%s for Fnordadel V%s\n", program, VERSION);
    fprintf(stderr, "Munching...\n");
    if (readSysTab(FALSE)) {
	initlogBuf(&logBuf);
	countTab = (struct cTab *) xmalloc(MAXROOMS * sizeof(struct cTab));
	doflags(argc, argv);	/* references countTab[]! */

	ctdlfile(logFile, cfg.sysdir, "ctdllog.sys");
	if ((logfl=dopen(logFile, O_RDONLY)) < 0)
	    crashout("Can't open %s", logFile);

	for (Index = 0; Index < cfg.logsize; Index++) {
	    getlog(&logBuf, Index, logfl);
	    if readbit(logBuf,uINUSE) {
		logCount++;
		forgotCount += mulchAcct();
	    }
	    fprintf(stderr, "%d\r", Index);
	}

	if (domesg)
	    doMessages();

	if (sorted)
	    qsort((void *)countTab, (size_t)MAXROOMS, sizeof countTab[0],
		(int (*)(const void *, const void *))sortCount);
	display(logCount, forgotCount);
	killlogBuf(&logBuf);
    }
    if (fromdesk())
	hitkey();
}

int
mulchAcct(void)
{
    int i, j, g, usedForget;

    usedForget = 0;
    for (i = 0;  i < MAXROOMS;	i++) {
	if (readbit(roomTab[i],PUBLIC) || allowall) {
	    if ((logBuf.lbgen[i] >> GENSHIFT) != roomTab[i].rtgen)  {
		j = roomTab[i].rtgen - (logBuf.lbgen[i] >> GENSHIFT);
		if (j < 0)
		    g = -j;
		else
		    g = j;
		if (g == FORGET_OFFSET) {
		    usedForget = 1;
		    (countTab[i].c_forgot)++;
		}
	    }
	}
    }
    return usedForget;
}
