/*
 * libfloor.c - Library for floor code
 *
 * 89May10 orc	Rebuild - use loadfloor/updtfloor for disk maint	*
 * 88Jul19 orc	Move loadfloor() in, support variable # of floors
 * 87Aug12 orc	Created.
 */

#include "ctdl.h"
#include "floor.h"
#include "config.h"
#include "room.h"
#include "log.h"
#include "citlib.h"

/*
 * putFloor()		Write floor to disk.
 * cleanFloor()		Discard unused floors.
 * loadFloor()		Try to load up the floor table.
 */

struct flTab *floorTab;			/* floor table			*/
int thisFloor = LOBBYFLOOR;		/* current floor		*/

#define FLSIZE	(sizeof floorTab[0])

/*
 * updtfloor() - clean out unused floors and write to disk
 */
void
updtfloor(void)
{
    int rover, i;
    int floor;
    PATHBUF fname;

    for (i = 0; i < cfg.floorCount; i++)
	floorTab[i].flInUse = 0;

    for (rover = 0; rover < MAXROOMS; rover++)
	if (readbit(roomTab[rover],INUSE))
	    for (i = 0; i < cfg.floorCount; i++)
		if (roomTab[rover].rtfloorGen == floorTab[i].flGen) {
		    floorTab[i].flInUse++;
		    break;
		}
    ctdlfile(fname, cfg.sysdir, "ctdlflr.sys");
    if ((floor = dopen(fname, O_WRONLY)) >= 0) {
	dwrite(floor, floorTab, cfg.floorCount * sizeof floorTab[0]);
	dclose(floor);
    }
}

/*
 * loadfloor() - try to load up the floor table.
 */
void
loadfloor(void)
{
    int floor;
    PATHBUF fname;

    floorTab = (struct flTab *) xmalloc(cfg.floorCount * sizeof floorTab[0]);
    ctdlfile(fname, cfg.sysdir, "ctdlflr.sys");
    if ((floor = dopen(fname, O_RDONLY)) < 0)
	crashout("Cannot open %s", fname);
    dread(floor, floorTab, cfg.floorCount * sizeof floorTab[0]);
    dclose(floor);
    updtfloor();	/* update disk image */
}
