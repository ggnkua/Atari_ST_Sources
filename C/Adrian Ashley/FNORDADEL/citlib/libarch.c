/*
 * libarch.c -- Archive handling for Citadel bulletin board system
 *
 * 88Aug10 orc	remove code to do free/realloc on archive names
 * 88Jul15 orc	Modified to use xstrdup()
 * 87Jan30 orc	move safeopen to sysdep()
 * 87Jan03 orc	have safeopen() use fopenb for "xxb" files
 * 86Dec31 orc	perverted.
 * 86Aug01 HAW	Created.
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"

/*
 * addArchiveList()	add new archive to room archive list
 * * addanylist()	common for addAr.. and initArch...
 * findArchiveName()	gets requested archive name
 * initArchiveList()	eat archive list
 */

static struct any_list {
    int    any_room;
    char   *any_name;
    struct any_list *any_next;
} roomarchive;

static char archive[] = "ctdlarch.sys";

FILE *safeopen();
char *xstrdup();

/*
 * addanylist() -- Adds filename to archive list
 */
static int
addanylist(struct any_list *base, int room, char *fn)
{
    char found;
    struct any_list *p;

    for (p=base; p->any_next && p->any_next->any_room != room;
		     p=p->any_next)
	;

    if (p->any_next) {
	p = p->any_next;
	free(p->any_name);
	found = YES;
    }
    else {
	p->any_next = (struct any_list *) xmalloc(sizeof roomarchive);
	p = p->any_next;
	p->any_next = NULL;
	found = NO;
    }

    p->any_room = room;
    p->any_name = xstrdup(fn);

    return found;
}

/*
 * initList() - set up list
 */
static int
initList(char *fileName, struct any_list *base)
{
    FILE *fd;
    char name[120];
    int room;

    base->any_next = NULL;

    if (fd = safeopen(fileName, "r")) {
	room = 0;
	while (fgets(name, 118, fd) != NULL) {
	    strtok(name,"\n");
	    addanylist(base, room++, name);
	}
	fclose(fd);
	return YES;
    }
    return NO;
}

/*
 * findArchiveName() - get the archive filename for a room
 */
char *
findArchiveName(int room)
{
    struct any_list *p;

    for (p = roomarchive.any_next; p; p = p->any_next)
	if (p->any_room == room)
	    return p->any_name;
    return NULL;
}

/*
 * initArchiveList() - set up archive list
 */
void
initArchiveList(void)
{
    struct any_list *p;
    char *strchr(), *runner, *hold;
    PATHBUF temp;

    ctdlfile(temp, cfg.sysdir, archive);
    initList(temp, &roomarchive);
    for (p = roomarchive.any_next; p; p = p->any_next) {
	p->any_room = atoi(hold=p->any_name);
	if (runner = strchr(hold, ' '))
	    runner++;
	else
	    runner = "";
	p->any_name = xstrdup(runner);
	free(hold);
    }
}

/*
 * addArchiveList() add to archive list
 */
int
addArchiveList(int room, char *fn)
{
    FILE  *arch;
    struct any_list *p;
    char  replace;
    PATHBUF filename;
    static char format[] = "%d %s\n";

    ctdlfile(filename, cfg.sysdir, archive);

    replace = addanylist(&roomarchive, room, fn);

    if (arch = safeopen(filename, replace ? "w" : "a")) {
	if (replace) {
	    for (p = roomarchive.any_next; p; p = p->any_next)
		fprintf(arch, format, p->any_room, p->any_name);
	}
	else
	    fprintf(arch, format, room, fn);
	fclose(arch);
	return YES;
    }
    mprintf("Can't open %s\n ", filename);
    return NO;
}
