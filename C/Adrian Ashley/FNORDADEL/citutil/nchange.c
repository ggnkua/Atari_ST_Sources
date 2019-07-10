/*
 * nchange.c -- change the value of #sharedrooms (the limit to the number
 *		of rooms which may be shared with any given network node.)
 *
 * 90May19 A&R	Created as part of 1.3 release.
 */

#include "ctdl.h"
#include "net.h"
#include "room.h"
#include "config.h"
#include "citlib.h"

char *program = "nchange";
int newroomshared, maxroomshared = 0;
int newnetfl;

/* Get a yes/no response from console */
int
getyesno(void)
{
    int c;

    while (1) {
	c = toupper(getch());
	if (c == 'Y' || c == 'N')
	    break;
    }
    putchar(c);
    putchar('\n');
    if (c == 'N')
	return NO;
    else
	return YES;
}

/* Output a new net node */
void
ourputNet(int n)
{
    crypte((char *)&netBuf, NB_SIZE, n);

    dseek(newnetfl, ((long)n) * ((long)NB_TOTAL_SIZE), 0);
    if (dwrite(newnetfl, &netBuf, NB_SIZE) != NB_SIZE)
	crashout("ourputNet-write(1) failed");
    if (dwrite(newnetfl, netBuf.shared, SR_BULK) != SR_BULK)
	crashout("ourputNet-write(2) failed");

    crypte((char *)&netBuf, NB_SIZE, n);
}

/* Get each net node and alter the number of shared rooms to the new value */
int
changenodes(int new)
{
    int i, j, old;

    old = SHARED_ROOMS;
    if (old == new) {
	printf("No compression done; new size would be the same as before.\n");
	return NO;
    }
    for (i = 0; i < cfg.netSize; i++) {
	SHARED_ROOMS = old;
	getNet(i);
	netBuf.shared = (struct netroom *)realloc(netBuf.shared, new *
	    sizeof(struct netroom));
	netTab[i].Tshared = (struct netroom *)realloc(netTab[i].Tshared, new *
	    sizeof(struct netroom));
	if (new > old)
	    for (j=old; j < new; j++)	/* ensure that new slots are empty */
		netBuf.shared[j].NRidx = netTab[i].Tshared[j].NRidx = -1;
	SHARED_ROOMS = new;
	ourputNet(i);
    }
    return YES;
}

/* Scan each net node and find the highest shared room slot used */
int
scannodes(void)
{
    int i, j, room, c;

    for (i = 0; i < cfg.netSize; i++) {
	if readbit(netTab[i],N_INUSE) {
	    for (j = SHARED_ROOMS - 1; j >= 0; j--) {
		room = netTab[i].Tshared[j].NRidx;
		if (room >= 0 &&
			roomTab[room].rtgen == netTab[i].Tshared[j].NRgen)
		    if (j > maxroomshared)
			maxroomshared = j;
	    }
	}
    }
    maxroomshared++;
    if (maxroomshared <= newroomshared) {
	return changenodes(newroomshared);
    }
    else {
	if (maxroomshared == SHARED_ROOMS) {
	    printf("No compression possible.\n");
	    return NO;
	}
	printf("Error: desired size of %d cannot be achieved.\n",
	    newroomshared);
	printf("The best that can be done is %d; go ahead? (y/n) ",
	    maxroomshared);
	while (1) {
	    c = toupper(getch());
	    if (c == 'Y' || c == 'N')
		break;
	}
	putchar(c);
	putchar('\n');
 	if (c == 'Y')
	    return changenodes(maxroomshared);
    }
    return NO;
}

main(int argc, char **argv)
{
    PATHBUF net1, net2;
    int p, junk;

    setbuf(stdout, NULL);
    printf("%s for Fnordadel V%s\n", program, VERSION);

    if (argc == 2)
	newroomshared = atoi(argv[1]);
    else {
	fprintf(stderr, "usage: %s <new number of shared rooms>\n", program);
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    if ((newroomshared > MAXSHAREDROOMS) || (newroomshared < MINSHAREDROOMS))
	crashout("new sharedrooms must be between %d and %d", MINSHAREDROOMS,
		MAXSHAREDROOMS);
    else if (newroomshared > SANESHAREDROOMS) {
	printf("Do you really want %d shared rooms? (y/n) ", newroomshared);
	if (!getyesno())
	    crashout("Okay");
    }
    else if (newroomshared == SHARED_ROOMS)
	crashout("sharedrooms is already %d", newroomshared);

    if (readSysTab(FALSE) && makelock(&p)) {
	initnetBuf(&netBuf);

	ctdlfile(net1, cfg.netdir, "ctdlnet.sys");
	netfl = dopen(net1, O_RDONLY);
	if (netfl < 0)
	    crashout("can't open %s", net1);
	ctdlfile(net2, cfg.netdir, "ctdlnet.tmp");
	newnetfl = dcreat(net2);
	if (newnetfl < 0)
	    crashout("can't open %s", net2);
	if (scannodes()) {			/* did we change anything? */
	    dclose(netfl);
	    dclose(newnetfl);
	    if (dunlink(net1))		/* remove "ctdlnet.sys" */
		crashout("cannot unlink %s", net1);
	    if (drename(net2, net1))	/* "ctdlnet.tmp" --> "ctdlnet.sys" */
		crashout("cannot rename %s to %s", net1, net2);
	    printf("Be sure to change ctdlcnfg.sys to reflect the new number of\n");
	    printf("shared rooms.  Then run configur.  If you don't, your\n");
	    printf("system will explode.\n");
	    junk = writeSysTab();
	}
	else {
	    dclose(netfl);
	    dclose(newnetfl);
	    if (dunlink(net2))
		crashout("cannot unlink %s", net2);
	}
    wipelock(&p);
    }
    if (fromdesk())
	hitkey();
    exit(0);
}
