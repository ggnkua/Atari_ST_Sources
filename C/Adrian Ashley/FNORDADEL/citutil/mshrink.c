/*
 * mshrink.c -- Shrink the Fnordadel message file, on approval.
 *
 * 90May29 A&R	Created as part of 1.3 release.
 */

#include "ctdl.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"

void doCR() {}
mAbort() {}
mPrintf() {}
xprintf() {}	/* because something somewhere is linking in libroute.o */

char prevChar;
char echo;
#if 0
struct aRoom roomBuf;		/* to avoid linking in libroom.o	*/
#endif

char *program = "mshrink";
int tempdir = NO, tempfl;
PATHBUF tempfile, msgfile;
char buf[BLKSIZE];

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

/* Copy 'num' blocks of size BLKSIZE from mfl/mfile to tfl/tfile */
void
mcopy(int mfl, char *mfile, int tfl, char *tfile, int num)
{
    register int i;

    for (i = 1; i <= num; i++) {
	printf("\rCopying block %d of %d", i, num);
	fflush(stdout);
	if (dread(mfl, &buf[0], BLKSIZE) != BLKSIZE)
	    crashout("could not read %d bytes from block %d of %s", BLKSIZE,
		i, mfile);
#if 0
	if (i == num)	/* Nuke remnants of last sector */
	    memset(&buf[cfg.catChar], 0, BLKSIZE - cfg.catChar);
#endif
	if (dwrite(tfl, &buf[0], BLKSIZE) != BLKSIZE)
	    crashout("could not write %d bytes to block %d of %s", BLKSIZE,
		i, tfile);
    }
    printf("\rCopied %d blocks from %s to %s.\n", num, mfile, tfile);
}

/* Chop the message file to 'size' K */
void
chopit(int size)
{
    long msg;

    ctdlfile(msgfile, cfg.msgdir, "ctdlmsg.sys");
    if ((msgfl = dopen(msgfile, O_RDONLY)) < 0)
	crashout("cannot open %s", msgfile);
    if ((tempfl = dcreat(tempfile)) < 0)
	crashout("cannot create %s", tempfile);

    msgseek(0, 0);	/* Find ID# of message in ctdlmsg.sys sector 0 */
    getmessage();
    msg = msgBuf.mbid;
    printf("The oldest message used to be %ld; it's now %ld.\n", cfg.oldest,
	msg);
    printf("The message file size used to be %dK; it's now %dK.\n",
	(int) ((long)cfg.maxMSector * (long)BLKSIZE / 1024L), size);

    cfg.oldest = msg;
    cfg.maxMSector = cfg.catSector + 1;

    dseek(msgfl, 0L, 0);	/* Return file pointer to start of file */
    mcopy(msgfl, msgfile, tempfl, tempfile, cfg.maxMSector);
    dclose(msgfl);
    dclose(tempfl);
    if (dunlink(msgfile))	/* Kill old ctdlmsg.sys */
	crashout("cannot unlink %s", msgfile);

    if (tempdir) {		/* Did we use a separate temp directory? */
/* next line changed to tempfl from msgfl by AA 90Oct04 */
	if ((tempfl = dopen(tempfile, O_RDONLY)) < 0)
	    crashout("cannot open %s", tempfile);
	if ((msgfl = dcreat(msgfile)) < 0)
	    crashout("cannot create new %s", msgfile);
	mcopy(tempfl, tempfile, msgfl, msgfile, cfg.maxMSector);
	dclose(tempfl);
	dclose(msgfl);
	if (dunlink(tempfile))		/* Kill temp file */
	    crashout("cannot unlink %s", tempfile);
    }
    else	/* Used #sysDir, so just rename temp file to ctdlmsg.sys */
	if (drename(tempfile, msgfile))
	    crashout("cannot rename %s to %s", tempfile, msgfile);
}

main(int argc, char **argv)
{
    int p, pos, junk;

    setbuf(stdout, NULL);

    printf("%s for Fnordadel V%s\n", program, VERSION);

    tempfile[0] = 0;
    if (argc == 2) {
	tempdir = YES;		/* Flag that we're using another directory */
	strcat(tempfile, argv[1]);
	junk = strlen(tempfile);
	if (tempfile[junk - 1] == '\\')
	    tempfile[junk - 1] = 0;
	strcat(tempfile, "\\ctdlmsg.tmp");
	printf("\nThe temporary file will be %s.\n", tempfile);
	printf("If this looks wrong, don't let mshrink do the chop.\n");
    }
    else if (argc > 2) {
	fprintf(stderr, "usage: %s [pathname]\n", program);
	if (fromdesk())
	    hitkey();
	exit(1);
    }

    if (readSysTab(FALSE) && makelock(&p)) {
	if (!tempfile[0])
	    ctdlfile(tempfile, cfg.msgdir, "ctdlmsg.tmp");
	pos = (int) ((long)(cfg.catSector + 1) * (long)BLKSIZE / 1024L);
	printf("\nThe message pointer is currently %dK into the message file.\n",
	    pos);
	printf("Do you wish to chop the message file at this size? (y/n) ");
	if (getyesno()) {
	    putchar('\n');
	    if (cfg.catSector == cfg.maxMSector - 1)
		printf("\nThe message file is already that size.\n");
	    else {
		chopit(pos);
		printf("\nBe sure to change ctdlcnfg.sys to reflect the new value of\n");
		printf("messagek (%d).  Then run configur.  If you don't, your\n",
		    pos);
		printf("system will explode.\n"); 
		writeSysTab();
	    }
	}
	wipelock(&p);
    }
    if (fromdesk())
	hitkey();
    exit(0);
}
