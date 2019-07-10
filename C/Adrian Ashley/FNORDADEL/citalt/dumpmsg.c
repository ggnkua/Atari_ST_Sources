/*
 * dumpmsg.c -- dump raw ctdlmsg.sys to stdout
 */

#include "ctdl.h"
#include "config.h"
#include <fcntl.h>
#include <osbind.h>

unsigned char buffer[BLKSIZE];
    
int msgfl;
int tty = YES;	/* is stdout a tty? */

char *program = "dumpmsg";

main(argc, argv)
char **argv;
{
    long address = 0L;
    long low, high;
    long atol();
    PATHBUF mfile;
    extern struct config cfg;
    int gotTabl;

    setbuf(stdout, NULL);
    tty = isatty(stdout);

    gotTabl = readSysTab(0);

    if (gotTabl) {
	ctdlfile(mfile, cfg.msgdir, "ctdlmsg.sys");
	msgfl = dopen(mfile, O_RDONLY);
    }
    else {
	if (argc < 2)
	    crashout("usage: %s [<blk0>|<blki-blkj> ... <blkN>|<blkk-blkl>] <cryptSeed>", argv[0]);
	cfg.cryptSeed = atoi(argv[--argc]);
	msgfl = dopen("ctdlmsg.sys", O_RDONLY);
    }

    if (msgfl >= 0) {
	if (argc > 1) {
	    while (argc > 1) {
		--argc;
		if (sscanf(argv[argc], "%ld-%ld", &low, &high) == 2) {
		    for (address = low; address <= high; address++) {
			dseek(msgfl, address * BLKSIZE, 0);
			printf("\nblock %ld\n", address);
			dumpblk();
		    }
		}
		else {
		    address = atol(argv[argc]);
		    dseek(msgfl, address * BLKSIZE, 0);
		    printf("\nblock %ld\n", address);
		    dumpblk();
		}
	    }
	}
	else while (1) {
	    printf("\nblock %ld\n", address++);
	    dumpblk();
	}
	dclose(msgfl);
    }
    else
	crashout("cannot open ctdlmsg.sys");
}

void esc(int c)
{
	putchar(27);
	putchar('p');
	putchar(c);
	putchar(27);
	putchar('q');
}

dumpblk()
{
    int i;

    if (dread(msgfl, buffer, BLKSIZE) != BLKSIZE)
	crashout("read error");
    crypte((char *)buffer, BLKSIZE, 0);
    for (i = 0; i < BLKSIZE; i++) {
	if (buffer[i] == (unsigned char)0xff)
	    esc('X');
	else if (buffer[i] == '\0')
	    esc('0');
	else if (buffer[i] == '\n')
	    esc('N');
	else if (buffer[i] == '\r')
	    esc('R');
	else if (buffer[i] == '\t')
	    esc('T');
	else if (buffer[i] == '\f')
	    esc('F');
	else
	    putchar((buffer[i] >= 32 && buffer[i] <= 127) ? buffer[i] : '?');
    }
    putchar('\n');
}
