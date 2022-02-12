/* diskcheck - test a disk for bad blocks	Author: Andy Tanenbaum */

#include <minix/config.h>
#include <minix/const.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#undef ERROR			/* ERROR might be defined in <errno.h> :-( */
#define ERROR (-99)
#define OK 0
#define PRINTFREQ  10
#define N 30
#define SHORTS_PER_BLOCK (BLOCK_SIZE / sizeof(short))

char purgebuf[BLOCK_SIZE * N];
char buf[BLOCK_SIZE], zero[BLOCK_SIZE];
short pat1[SHORTS_PER_BLOCK], pat2[SHORTS_PER_BLOCK];
int blk = -1;			/* number of the block in buf, or -1 */
int pfd;			/* file descriptor for purging */
int fd;				/* file descriptor for data I/O */
unsigned long initblock;	/* first block to test */
unsigned long curblock;		/* current block */
unsigned long limit;		/* first block beyond test zone */
unsigned long errors;		/* # errors so far */
unsigned long ct;		/* # blocks read so far */
int intflag;			/* set when signal seen */
int rawdev;			/* set when I/O done on raw device */
char *purgefile = "/dev/ram";

_PROTOTYPE(int main, (int argc , char *argv []));
_PROTOTYPE(int testblock, (unsigned long b ));
_PROTOTYPE(void status, (void ));
_PROTOTYPE(void nonfatal, (char *s , unsigned long b ));
_PROTOTYPE(void fatal, (char *s , unsigned long b ));
_PROTOTYPE(void catch, (int sig ));
_PROTOTYPE(void usage, (void ));
_PROTOTYPE(int wtest, (off_t pos , short *pat ));
_PROTOTYPE(void purge_cache, (void ));

int main(argc, argv)
int argc;
char *argv[];
{
  unsigned long b;
  int i;
  struct stat s;

  signal(SIGINT, catch);
  signal(SIGQUIT, catch);
  if (argc != 4) usage();
  if (stat(argv[1], &s)) {
	printf("Cannot stat %s\n", argv[1]);
	exit(1);
  }
  rawdev = S_ISCHR(s.st_mode);
  if ((fd = open(argv[1], O_RDWR)) < 0) {
	printf("Cannot open %s\n", argv[1]);
	exit(1);
  }
  if ((pfd = open(purgefile, O_RDONLY)) < 0) {
	printf("Cannot open %s\n", purgefile);
	exit(1);
  }
  initblock = atol(argv[2]);
  limit = initblock + atol(argv[3]);
  if (limit <= initblock) usage();

  for (i = 0; i < SHORTS_PER_BLOCK; i++) {
	pat1[i] = i;
	pat2[i] = 1000 - i;
  }

  for (b = initblock; b < limit; b++) {
	if (intflag) break;
	if (testblock(b) == ERROR) {
		errors++;
		if (blk == b) {
			/* Read ok, write failed; try to restore block. */
			lseek(fd, (off_t) BLOCK_SIZE * (off_t) b, SEEK_SET);
			write(fd, buf, BLOCK_SIZE);
		}
	}
	curblock = b;
	ct++;
	if (ct % PRINTFREQ == 0) status();
  }

  status();
  printf("\n");
  return(0);
}


int testblock(b)
unsigned long b;
{
/* Read block b in, save it in buf.  Then overwrite that block with a
 * known test pattern and read it back.  Finally, replace the block.
 * Return OK or ERROR.
 */

  off_t pos;
  int s;

  blk = -1;
  pos = (off_t) BLOCK_SIZE * (off_t) b;
  purge_cache();
  if (lseek(fd, pos, SEEK_SET) != pos) fatal("Cannot seek to block ", b);

  /* Read block b into 'buf'. */
  s = read(fd, buf, BLOCK_SIZE);

  /* Test for various outcomes of the read. */
  if (s == BLOCK_SIZE) {
	blk = b;
	if (wtest(pos, pat1) == ERROR) return(ERROR);
	if (wtest(pos, pat2) == ERROR) return (ERROR);
	lseek(fd, pos, SEEK_SET);
	if (write(fd, buf, BLOCK_SIZE) != BLOCK_SIZE) {
		nonfatal("Cannot rewrite block ", b);
		return(ERROR);
	} else {
		return(OK);
	}
  }
  if (s < 0) {
	if (errno == EIO)
		nonfatal("Read error on block ", b);
	else {
		printf("\nError.  Read returned %d.  errno=%d.   ", s, errno);
		fatal("Block ", b);
	}
	return(ERROR);
  }
  if (s == 0) fatal("End of file reached trying to read block ", b);


  nonfatal("Read size error on block ", b);
  return(ERROR);
}

void status()
{
  printf("%8lu blocks tested, %lu errors detected (last block tested = %5lu)\r",
         ct, errors, curblock);
  fflush(stdout);
}

void nonfatal(s, b)
char *s;
unsigned long b;
{
  printf("\n%s%lu\n", s, b);
}

void fatal(s, b)
char *s;
unsigned long b;
{
  printf("\n%s%lu\n", s, b);
  status();
  exit(1);
}


void catch(sig)
int sig;			/* prototype says there has to be 1 arg */
{
  signal(SIGINT, catch);
  signal(SIGQUIT, catch);
  intflag = 1;
}


void usage()
{
  printf("Usage: diskcheck device start-block block-count\n");
  exit(1);
}

int wtest(pos, pat)
off_t pos;
short *pat;
{
  short testb[SHORTS_PER_BLOCK];
  int i;

  lseek(fd, pos, SEEK_SET);
  if (write(fd, (char *) pat, BLOCK_SIZE) != BLOCK_SIZE) return(ERROR);
  sync();			/* force the write to the disk */
  purge_cache();
  lseek(fd, pos, SEEK_SET);
  if (read(fd, (char *) testb, BLOCK_SIZE) != BLOCK_SIZE) return(ERROR);
  for (i = 0; i < SHORTS_PER_BLOCK; i++)
	if (testb[i] != pat[i]) {
		printf("%d %d\n", testb[i], pat[i]);
		return(ERROR);
	}
  return(OK);
}

void purge_cache()
{
/* Do enough reads that the cache is purged. */
  static int warned = 0;
  int left, count, r;

  if (rawdev) return;
  pfd = open(purgefile, O_RDONLY);
#ifdef NR_BUFS
  left = NR_BUFS;
#else
  /* XXX - buffers are dynamically allocated and there are likely to be
   * several MB worth.  This purge is unlikely to work.  There should be
   * raw devices to avoid such complications.
   */
  left = 8000;
#endif
  while (left > 0) {
	count = (left < N ? left : N);
	r = read(pfd, purgebuf, (size_t) (count * BLOCK_SIZE));
	if (r != count * BLOCK_SIZE) {
		if (r == 0) {
			if (!warned) printf("WARNING: Cannot purge cache.\n");
			warned = 1;
			break;
		}
		printf("ERROR: count=%d  left=%d r=%d.  ", count, left, r);
		fatal("Cannot purge cache.  errno= ", (unsigned long) errno);
	}
	left -= count;
  }
  close(pfd);
}
