/*
 * mexpand.c - Expands a msg file.  V.1.2
 *
 * 90Jun05 A&R	Renamed expand.prg to mexpand.prg
 * 87Apr07 orc	diddles for v.??
 * 87Mar01 orc	hacked up for STadel.
 * 85Nov16 HAW	Modified for MS-DOS.
 * 85Apr22 HAW	Move to MS-DOS.
 * 84Dec09 HAW	Now merely expands a file, rather than copying & expanding.
 * 84Jun22 HAW	Version 1.1 created -- handles any file expansion.
 * 84Jun19 HAW	Created.
 */

#include "ctdl.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"

/*
 * copy_remainder()	Copies remainder of split msg into file
 * first_part()		Remembers remainder of split msg
 * getNumber()		prompt user for a number, limited range
 * getString()		gets a string from the console
 * main()		Main controller for this program
 */

#define ascii8(c)	(((int)(c))&0xff)

int msgfl;
char split_buffer[2*MAXTEXT];
char *program = "mexpand";
extern char VERSION[];

void getString();

/*
 * copy_remainder() - copies the remainder of the split msg onto "end" of file
 */
unsigned int
copy_remainder(unsigned int offset)
{
    char *beg;
    int  count, i;
    int temp;

    beg = split_buffer;
    count = 0;
    temp = (offset)?(offset/BLKSIZE+1):0;
    printf("Transfer %d sector%s to cover split msg\n",temp, (temp==1)?"":"s");

    while (1) {
	if (offset < BLKSIZE)
	    break;
	crypte(beg + (BLKSIZE * count), BLKSIZE, 0);
	if (dwrite(msgfl, beg + (BLKSIZE * count), BLKSIZE) != BLKSIZE)
	    crashout("write error 1");
	count++;
	offset -= BLKSIZE;
    }
    if (offset == 0)
	return count;
    for (i = 0; ascii8(beg[BLKSIZE * count + i]) != 0xff; i++)
	;
    for (i++; i < BLKSIZE; i++)
	beg[BLKSIZE * count + i] = 0;
    crypte(beg + BLKSIZE * count, BLKSIZE, 0);
    if (dwrite(msgfl, beg + (BLKSIZE * count), BLKSIZE) != BLKSIZE)
	crashout("write error 2");
    return 1+count;
}

/*
 * first_part() -- remembers remainder of first msg
 */
int
first_part(void)
{
    int  offset, i;
    static char buf[BLKSIZE];
    char done;

    offset = 0;
    done = FALSE;
    do {
	if (dread(msgfl, buf, BLKSIZE) != BLKSIZE)
	    crashout("read error");
	crypte(buf, BLKSIZE, 0);
	i = 0;
	while (ascii8(buf[i]) != 0xff && i < BLKSIZE)
	    split_buffer[offset++] = buf[i++];
	done = !(i == BLKSIZE);
    } while (!done);
    dseek(msgfl, 0L, 0);
    return offset;
}

/*
 * getNumber() -- get a number
 */
unsigned int
getNumber(char *prompt, unsigned int bottom, unsigned int top)
{
    unsigned try;
    char numstring[80];
    int atoi();

    do {
	getString(prompt, numstring, 80);
	try = atoi(numstring);
	if (try < bottom)
	    printf("Sorry, must be at least %d\n", bottom);
	if (try > top)
	    printf("Sorry, must be no more than %d\n", top);
    } while (try < bottom || try > top);
    return try;
}

/*
 * getString() -- get a string
 */
void
getString(char *prompt, char *buf, int lim)
{
    int c, i;

    if (strlen(prompt) > 0)
	printf("\nEnter %s\n : ", prompt);

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
	    buf[i++] = c;
	    putchar((c>=32) ? c : '@');
	}
	else
	    putchar(BELL);
    }
    putchar('\n');
    buf[i] = 0;
}

main()
{
    static char temp[BLKSIZE];
    PATHBUF msgFile;
    int s, i, offset;
    unsigned oldsize, fudge;
    long work;
    long mbsize;
    long msgK, newsiz;
    int p;

    setbuf(stdout, NULL);	/* avoid 'fflush(stdout)' calls */
    printf("%s for Fnordadel V%s\n\n", program, VERSION);

    printf("Have you backed up the ctdlmsg.sys file yet (Y/N)? ");
    if (toupper(getch()) != 'Y') {
	puts("\nBetter do it before you run mexpand.");
	exit(1);
    }
    if (readSysTab(TRUE) && makelock(&p)) {
	ctdlfile(msgFile, cfg.msgdir, "ctdlmsg.sys");
	if ((msgfl = dopen(msgFile, O_RDWR)) < 0)
	    crashout("no %s", msgFile);

	oldsize = cfg.maxMSector;
	mbsize = ((long)cfg.maxMSector * (long)BLKSIZE)/1024L;

	printf("\nOld messagebase was %ldK\n", mbsize);
	msgK = newsiz = getNumber( "size of new messagebase (in Kbytes)",
				    (int)mbsize, 32000);
	
	cfg.maxMSector = ((newsiz*1024L)+BLKSIZE-1)/BLKSIZE;
	newsiz = ((long)cfg.maxMSector * (long)BLKSIZE)/1024L;

	printf("expanded messagebase will be %ld Kbytes\n",newsiz);

	puts("Working...");
	offset = first_part();

	dunlink(indextable);

	work = ((long)BLKSIZE) * ((long)oldsize);

	dseek(msgfl, work - 1L, 0);	  /* Get to EOF */

	while (dread(msgfl, temp, BLKSIZE) == BLKSIZE)
	    printf("Looping\n");
	fudge = copy_remainder(offset);
	for (i = 0; i < BLKSIZE; i++)
	    temp[i] = 0;
	crypte(temp, BLKSIZE, 0);
	i = cfg.maxMSector - oldsize - fudge;
	printf("And now %d sector%s left to initialize\n", i, (i==1)?"":"s");
	for (; i; i--) {
	    printf("%7d\r", i);
	    if ((s = dwrite(msgfl, temp, BLKSIZE)) != BLKSIZE)
		crashout("write error");
	}
	dclose(msgfl);
	wipelock(&p);
	printf("\nFinished.\n\
change MESSAGEK to %ld in CTDLCNFG.SYS and reconfigure!\n", msgK);
    }
    if (fromdesk())
	hitkey();
}
