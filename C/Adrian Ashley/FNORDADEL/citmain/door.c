#undef NEW_REDIRECT

/*
 * door.c -- Code to handle shell escapes
 *
 * 91Jan07 AA	Added some new code to hopefully do stdin/out redirects right
 * 88Jul17 orc	`l' modeflag added in
 * 88Feb25 orc	Created.
 */

#include "ctdl.h"
#include "door.h"
#include "room.h"
#include "log.h"
#include "config.h"
#include "archiver.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * * pickdoor()		low-level find a shell escape
 * * legaldoor()	is this door visible at this time?
 * * islegal()		
 * * finddoor()		Find and validate a shell escape
 * rundoor()		Redirect i/o and run a shell escape.
 * * makedoor()		add a shell escape to the list.
 * initdoor()		read a list of shell escapes.
 * dodoor()		menu-level execute shell escape
 */

struct doorway *doors = NULL;	/* doors defined in the system	*/
struct doorway *shell = NULL;	/* "outside" doorway...		*/
struct doorway *login_door = NULL;	/* door to be run on user login */
struct doorway *logout_door = NULL;	/* ...you guessed it... 	*/
struct doorway *newuser_door = NULL;	/* etc 				*/

static char *link = NULL;	/* directory linked via mode `l', or	*/
				/* room linked via mode `i'		*/

#define	AUX	-2		/* GEMDOS AUX: device		*/

/*
 * pickdoor() -- find a shell escape
 */
static struct doorway *
pickdoor(char *cmd, struct doorway *list)
{
    while (list && stricmp(list->dr_name, cmd) != 0)
	list = list->dr_next;
    return list;
}

/*
 * legaldoor() -- is this door visible at this time?
 */
static struct doorway *
legaldoor(struct doorway *list)
{
    if (((list->dr_mode & DR_SPECIAL) || (list->dr_mode & DR_THESYSOP))
	&& !(TheSysop() || onConsole))
	return DR_ACCESS;

    switch (list->dr_mode & DR_UMASK) {
    case DR_SYSOP:
	if (!(SomeSysop() || onConsole))
	    return DR_ACCESS;
	break;
    case DR_AIDE:
	if (!(readbit(logBuf,uAIDE) || onConsole))
	    return DR_ACCESS;
	break;
    }
    switch (list->dr_mode & DR_IOMASK) {
    case DR_CONSOLE:
	if (!onConsole)
	    return DR_ACCESS;
	break;
    case DR_MODEM:
	if (onConsole)
	    return DR_ACCESS;
	break;
    }
    /*
     * check room accessability...
     */
    if ((list->dr_mode & DR_ROOM) &&
		labelcmp(list->dr_link, roomBuf.rbname) != 0)
	return DR_BADROOM;
    if (list->dr_mode & DR_DIR) {
	if (!readbit(roomBuf,ISDIR))
	    return DR_BADROOM;
	if ((list->dr_mode & DR_READ) && !readbit(roomBuf,DOWNLOAD))
	    return DR_BADROOM;
	if ((list->dr_mode & DR_WRITE) && !readbit(roomBuf,UPLOAD))
	    return DR_BADROOM;
    }

    return list;
}

static int
islegal(struct doorway *list, struct doorway **ptr)
{
    *ptr = legaldoor(list);

    return (*ptr != DR_ACCESS && *ptr != DR_BADROOM);
}

/*
 * finddoor() -- find and validate a shell escape
 */
static struct doorway *
finddoor(char *cmd, struct doorway *list)
{
    struct doorway *ptr;
    
    for (ptr=NULL; list; list=list->dr_next)
	if (stricmp(list->dr_name, cmd) == 0 && islegal(list, &ptr))
	    break;
    return ptr;
}

/*
 * rundoor() -- execute a shell escape
 */
void
rundoor(struct doorway *door, char *tail)
{
    char realtail[129];
    long status;
#ifndef NEW_REDIRECT
    int hold[3];
    int i;
#else
    int infd, outfd, oldin, oldout;
#endif

    strcpy(realtail, door->dr_tail);
    /*
     * if a tail can be passed in, check to make sure there are no pathnames
     * associated with it....
     */
    if (tail && (door->dr_mode & DR_TAIL)) {
	if (!SomeSysop() && (strchr(tail,':') || strchr(tail, '\\'))) {
	    mprintf("Cannot have `:' or `\\' in arguments\r");
	    return;
	}
	sprintf(ENDOFSTR(realtail), " %s", tail);
    }
    if (door->dr_mode & DR_NAMED)
	sprintf(ENDOFSTR(realtail), " %s", logBuf.lbname);

    if (door->dr_mode & DR_HOME)
	homeSpace();

    if ((door->dr_mode & DR_LINKED) && !xchdir(door->dr_link))
	return;

    if ((door->dr_mode & DR_ROOM) &&
		labelcmp(door->dr_link, roomBuf.rbname) != 0)
	return;
    
    /* Execute the door iff:
     *    1. Door executes in BBS home directory (linked earlier);
     * or 2. Explicit directory link present (linked earlier);
     * or 3. Room is not a directory room;
     * or 4. Door link to directory room dir succeeds.
     */
    if ((door->dr_mode & DR_HOME) || (door->dr_mode & DR_LINKED) ||
		!readbit(roomBuf,ISDIR) || xchdir(roomBuf.rbdirname)) {
	if (!onConsole) {
#ifndef NEW_REDIRECT
	    for (i = 0;i < 3; i++) {
		hold[i] = Fdup(i);
		Fforce(i,AUX);
	    }
#else
	    oldin = Fdup(0);
	    infd = Fopen("AUX:", 2);
	    if (infd < 0)	xprintf("Can't redirect stdin!\n");
	    else {
		(void)Fforce(0, infd);
		(void)Fclose(infd);
	    }
	    oldout = Fdup(1);
	    outfd = Fopen("AUX:", 2);
	    if (outfd < 0)	xprintf("Can't redirect stdout!\n");
	    else {
		(void)Fforce(1, outfd);
		(void)Fclose(outfd);
	    }
#endif
	}
	status = dosexec(door->dr_cmd, realtail);
	if (onConsole) {
	    if (dropDTR && !gotcarrier())
		modemClose();
	}
	else {
#ifndef NEW_REDIRECT
	    for (i=0;i<3;i++) {
		Fforce(i, hold[i]);
		Fclose(hold[i]);
	    }
#else
	    if (oldin > 0) {
		(void) Fforce(0, oldin);
		(void) Fclose(oldin);
		oldin = -1;
	    }
	    if (oldout > 0) {
		(void) Fforce(1, oldout);
		(void) Fclose(oldout);
		oldout = -1;
	    }
#endif
	}
	if (status < 0)
	    mprintf("%s: status=%d\r", door->dr_name, (int)status);

	homeSpace();			/* flip back to the citadel homedir */
    }
}

/*
 * makedoor() -- add a shell escape to the system list
 */
static void
makedoor(struct doorway **rp, int mode, char *name, char *line, char *remark)
{
    char *cname, *ctail;
    struct doorway *tmp;

    cname = strtok(line," \t");
    ctail = strtok(NULL,"\n");

    tmp = (struct doorway *)malloc(sizeof tmp[0]);
    tmp->dr_mode = mode;
    strcpy(tmp->dr_name, name);
    tmp->dr_cmd  = xstrdup(cname);
    tmp->dr_link  = link ? xstrdup(link) : "";
    tmp->dr_tail = ctail ? xstrdup(ctail) : "";
    tmp->dr_remark = remark ? xstrdup(remark) : "";
    tmp->dr_next = *rp;
    *rp = tmp;
}

/*
 * initdoor() -- read the list of shell escapes from disk
 */
void
initdoor(void)
{
    int  mode, i;
    char *p, *name, *command, *remark;
    char line[180];
    FILE *f;
    struct doorway *tmp;

    /*
     *  <name> <mode> <command> [tail] [#remark]
     */

    ctdlfile(line, cfg.sysdir, "ctdldoor.sys");
    if (f=safeopen(line, "r")) {
	while (fgets(line, 180, f)) {
	    strtok(line, "\n");
	    mode = 0;
	    if (remark = strrchr(line, '#'))
		*remark++ = 0;
	    name = strtok(line,"\t ");
	    if (!name)
		continue;
	    if (strlen(name) >= DOORSIZE)
		crashout("door name <%s> is too long", name);

	    for (p = strtok(NULL,"\t "); p && *p; p++)
		switch(tolower(*p)) {
		case 'u': mode &= ~DR_UMASK;				break;
		case 'z': mode = (mode & ~DR_UMASK) | DR_THESYSOP;	break;
		case 's': mode = (mode & ~DR_UMASK) | DR_SYSOP;		break;
		case 'a': mode = (mode & ~DR_UMASK) | DR_AIDE;		break;
		case 'd': mode |= DR_DIR;				break;
		case 'r': mode |= DR_READ;				break;
		case 'w': mode |= DR_WRITE;				break;
		case 'n': mode |= DR_NAMED;				break;
		case 't': mode |= DR_TAIL;				break;
		case 'c': mode = (mode & ~DR_IOMASK) | DR_CONSOLE;	break;
		case 'm': mode = (mode & ~DR_IOMASK) | DR_MODEM;	break;
		case 'x': mode |= DR_SPECIAL;				break;
		case 'v': mode |= DR_ARCHIVER;				break;
		case 'p': mode |= DR_PROTOCOL;				break;
		case 'h': mode |= DR_HOME;				break;
		case 'i': mode |= DR_ROOM;	link = 1+p;	goto finis;
		case 'l': mode |= DR_LINKED;	link = 1+p;	goto finis;
		default:
		    crashout("mode <%c> for door %s", *p, name);
		}
    finis:  if (command = strtok(NULL, "\0"))
		makedoor(&doors, mode, name, command, remark);
	    link = NULL;
	}
	/*
	 * set up the shell for outside commands
	 */
	shell = pickdoor("shell", doors);
	/*
	 * set up the automatic login & logout doors
	 */
	login_door = pickdoor("login", doors);
	logout_door = pickdoor("logout", doors);
	newuser_door = pickdoor("newuser", doors);
	/*
	 * set up the archiver handler doors
	 */
	for (i=0; i<cfg.arch_count; i++) {
	    tmp = pickdoor(archTab[i].doorname, doors);
	    archTab[i].doorptr = ((tmp && (tmp->dr_mode & DR_ARCHIVER)) ? tmp
								: NULL);
	}
	fclose(f);
    }
    if (cfg.shell && !shell)
	makedoor(&shell, DR_SYSOP, "^L shell", &cfg.codeBuf[cfg.shell], NULL);
}

/*
 * dodoor() -- do a shell escape
 */
void
dodoor(void)
{
    char cmdline[80];
    char *cmd, *tail;
    struct doorway *p, *toexec;
    int stat;

    /* Let user run door if:
     * 1) on console
     *     OR
     * 2) logged in AND (has door privs or is SomeSysop())
     */
    if (!(onConsole ||
		(loggedIn && (SomeSysop() || readbit(logBuf,uDOORPRIV)))))
	return;

    if (!(onConsole || SomeSysop()) && event_pending(YES))
    	return;

    oChar('!');
    getString("",cmdline,80,'?',YES);
    if (cmdline[0] == '?') {
	for (stat=0, p=doors; p; p=p->dr_next)
	    if (islegal(p, &toexec)) {
		if (!stat)
		    mprintf("Available doors:\r");
		CRfill = "%10c : ";
		CRftn = retfmt;
		mprintf("%-10s : %s", p->dr_name, p->dr_remark);
		CRftn = NULL;
		doCR();
		stat=1;
	    }
	if (!stat)
	    mprintf("No available doors.\r");
	return;
    }
    normalise(cmdline);

    if (cmdline[0]) {
	cmd = strtok(cmdline,"\t ");
	tail= strtok(NULL, "\n");

	toexec = finddoor(cmd, doors);
	if (toexec == NULL)
	    mprintf("%s: no such doorway\r", cmd);
	else if (toexec == DR_ACCESS)
	    mprintf("%s: permission denied\r", cmd);
	else if (toexec == DR_BADROOM)
	    mprintf("Not here!\r");
	else
	    rundoor(toexec, tail);
    }
}
