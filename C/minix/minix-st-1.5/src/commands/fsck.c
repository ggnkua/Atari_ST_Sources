/* fsck - file system checker		Author: Robbert van Renesse */

/* Modified by Norbert Schlenker
*   Removed vestiges of standalone/DOS versions:
*     - various unused variables and buffers removed
*     - now uses library functions rather than private internal routines
*     - bytewise structure copies replaced by structure assignment
*     - fixed one bug with 14 character file names
*     - other small tweaks for speed
*
* Modified by Lars Fredriksen at the request of Andy Tanenbaum, 90-03-10.
*   Removed -m option, by which fsck could be told to make a file
*   system on a 360K floppy.  The code had limited utility, was buggy,
*   and failed due to a bug in the ACK C compiler.  Use mkfs instead!
*/

#include <sys/types.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <minix/config.h>
#include <minix/const.h>
#include <minix/type.h>
#include "../fs/const.h"
#include "../fs/type.h"

#undef printf			/* defined as printk in "../fs/const.h" */

#include <stdio.h>

#if INTEL_32BITS
#define BITSHIFT	  5	/* = log2(#bits(int)) */
#else
#define BITSHIFT	  4	/* = log2(#bits(int)) */
#endif

#define BITMAPSHIFT	 13	/* = log2(#bits(block)); 13 means 1K blocks */
#define MAXPRINT	  8	/* max. number of error lines in chkmap */
#define MAXDIRSIZE     5000	/* max. size of a reasonable directory */
#define CINDIR		128	/* number of indirect zno's read at a time */
#define CDIRECT		 16	/* number of dir entries read at a time */
#define BITMASK		((1 << BITSHIFT) - 1)
#define setbit(w, b)	(w[(b) >> BITSHIFT] |= 1 << ((b) & BITMASK))
#define clrbit(w, b)	(w[(b) >> BITSHIFT] &= ~(1 << ((b) & BITMASK)))
#define bitset(w, b)	(w[(b) >> BITSHIFT] & (1 << ((b) & BITMASK)))

#define ZONE_CT 	360	/* default zones  (when making file system) */
#define INODE_CT	 95	/* default inodes (when making file system) */

/* DEBUG FIXME.  This and other things repeat stuff from fs, not necessarily
 * identically.  This is part of a structure in fs/super.h, and old versions
 * had the wrong type for s_magic.
 */
struct dsb {
  ino_t s_ninodes;		/* # inodes on the minor device */
  zone_nr s_nzones;		/* total dev size, incl. bit maps etc */
  unsigned short s_imap_blocks;	/* # of blocks used by inode bit map */
  unsigned short s_zmap_blocks;	/* # of blocks used by zone bit map */
  zone_nr s_firstdatazone;	/* number of first data zone */
  short s_log_zone_size;	/* log2 of blocks/zone */
  off_t s_maxsize;		/* maximum file size on this device */
  short s_magic;		/* magic number for super blocks */
} sb;

#define STICKY_BIT	01000	/* not defined anywhere else */

/* Ztob gives the block address of a zone
 * btoa gives the byte address of a block
 */
#define ztob(z)		((block_nr) (z) << sb.s_log_zone_size)
#define btoa(b)		((long) (b) * BLOCK_SIZE)
#define SCALE		((int) ztob(1))	/* # blocks in a zone */
#define FIRST		sb.s_firstdatazone	/* as the name says */

/* # blocks of each type */
#define N_SUPER		1
#define N_IMAP		(sb.s_imap_blocks)
#define N_ZMAP		(sb.s_zmap_blocks)
#define N_ILIST		((sb.s_ninodes+INODES_PER_BLOCK-1) / INODES_PER_BLOCK)
#define N_DATA		(sb.s_nzones - FIRST)

/* Block address of each type */
#define BLK_SUPER	(SUPER_BLOCK)
#define BLK_IMAP	(BLK_SUPER + N_SUPER)
#define BLK_ZMAP	(BLK_IMAP  + N_IMAP)
#define BLK_ILIST	(BLK_ZMAP  + N_ZMAP)
#define BLK_FIRST	ztob(FIRST)
#define ZONE_SIZE	((int) ztob(BLOCK_SIZE))
#define NLEVEL		(NR_ZONE_NUMS - NR_DZONE_NUM + 1)

/* Byte address of a zone/of an inode */
#define zaddr(z)	btoa(ztob(z))
#define inoaddr(i)	((long) (i - 1) * INODE_SIZE + btoa(BLK_ILIST))
#define INDCHUNK	(CINDIR * ZONE_NUM_SIZE)
#define DIRCHUNK	(CDIRECT * DIR_ENTRY_SIZE)

char *prog, *device;		/* program name (fsck), device name */
int firstcnterr;		/* is this the first inode ref cnt error? */
unsigned *imap, *spec_imap;	/* inode bit maps */
unsigned *zmap, *spec_zmap;	/* zone bit maps */
unsigned *dirmap;		/* directory (inode) bit map */
char rwbuf[BLOCK_SIZE];		/* one block buffer cache */
block_nr thisblk;		/* block in buffer cache */
char nullbuf[BLOCK_SIZE];	/* null buffer */
nlink_t *count;			/* inode count */
int changed;			/* has the diskette been written to? */
struct stack {
  dir_struct *st_dir;
  struct stack *st_next;
  char st_presence;
} *ftop;

int dev;			/* file descriptor of the device */

#define DOT	1
#define DOTDOT	2

/* Counters for each type of inode/zone. */
int nfreeinode, nregular, ndirectory, nblkspec, ncharspec, nbadinode;
int npipe, nfreezone, ztype[NLEVEL];

int repair, automatic, listing, listsuper;	/* flags */
int firstlist;			/* has the listing header been printed? */
unsigned part_offset;		/* sector offset for this partition */
char answer[] = {"Answer questions with y or n.  Then hit RETURN"};

/* Initialize the variables used by this program. */
initvars()
{
  register level;

  nregular = ndirectory = nblkspec = ncharspec = nbadinode = npipe = 0;
  for (level = 0; level < NLEVEL; level++) ztype[level] = 0;
  changed = 0;
  thisblk = NO_BLOCK;
  firstlist = 1;
  firstcnterr = 1;
}

/* Print the string `s' and exit. */
void fatal(s)
char *s;
{
  printf("%s\nfatal\n", s);
  exit(-1);
}

/* Test for end of line. */
eoln(c)
{
  return(c == EOF || c == '\n' || c == '\r');
}

/* Ask a question and get the answer unless automatic is set. */
int yes(question)
char *question;
{
  register c, answer;

  if (!repair) {
	printf("\n");
	return(0);
  }
  printf("%s? ", question);
  if (automatic) {
	printf("yes\n");
	return(1);
  }
  fflush(stdout);
  if ((c = answer = getchar()) == 'q' || c == 'Q') exit(1);
  while (!eoln(c)) c = getchar();
  return !(answer == 'n' || answer == 'N');
}

/* Convert string to integer.  Representation is octal. */
int atoo(s)
register char *s;
{
  register int n = 0;

  while ('0' <= *s && *s < '8') {
	n <<= 3;
	n += *s++ - '0';
  }
  return n;
}

/* If repairing the file system, print a prompt and get a string from user. */
input(buf, size)
char *buf;
{
  register char *p = buf;

  printf("\n");
  if (repair) {
	printf("--> ");
	fflush(stdout);
	while (--size) {
		*p = getchar();
		if (eoln(*p)) {
			*p = 0;
			return(p > buf);
		}
		p++;
	}
	*p = 0;
	while (!eoln(getchar()));
	return(1);
  }
  return(0);
}

/* Allocate some memory and zero it. */
char *alloc(nelem, elsize)
unsigned nelem, elsize;
{
  char *p;

  if ((p = (char *) malloc(nelem * elsize)) == 0) fatal("out of memory");
  memset(p, 0, nelem * elsize);
  return(p);
}

/* Print the name in a directory entry. */
void printname(s)
char *s;
{
  register n = NAME_MAX;
  int c;

  do {
	if ((c = *s) == 0) break;
	if (!isprint(c)) c = '?';
	putchar(c);
	s++;
  } while (--n);
}

/* Print the pathname given by a linked list pointed to by `sp'.  The
 * names are in reverse order.
 */
printrec(sp)
struct stack *sp;
{
  if (sp->st_next != 0) {
	printrec(sp->st_next);
	putchar('/');
	printname(sp->st_dir->d_name);
  }
}

/* Print the current pathname.  */
printpath(mode, nlcr)
{
  if (ftop->st_next == 0)
	putchar('/');
  else
	printrec(ftop);
  switch (mode) {
      case 1:
	printf(" (ino = %u, ", ftop->st_dir->d_inum);
	break;
      case 2:
	printf(" (ino = %u)", ftop->st_dir->d_inum);
	break;
  }
  if (nlcr) printf("\n");
}

/* Open the device.  */
devopen()
{
  if ((dev = open(device, repair ? O_RDWR : O_RDONLY)) < 0) {
	perror(device);
	fatal("");
  }
}

/* Close the device. */
devclose()
{
  if (close(dev) != 0) {
	perror("close");
	fatal("");
  }
}

/* Read or write a block. */
devio(bno, dir)
block_nr bno;
{
  if (dir == READING && bno == thisblk) return;
  thisblk = bno;

  lseek(dev, btoa(bno), SEEK_SET);
  if (dir == READING) {
	if (read(dev, rwbuf, BLOCK_SIZE) == BLOCK_SIZE)
		return;
  } else {
	if (write(dev, rwbuf, BLOCK_SIZE) == BLOCK_SIZE)
		return;
  }

  printf("%s: can't %s block %ld (error = 0x%x)\n", prog,
         dir == READING ? "read" : "write", (long) bno, errno);
  fatal("");
}

/* Read `size' bytes from the disk starting at byte `offset'. */
devread(offset, buf, size)
long offset;
char *buf;
{
  devio((block_nr) (offset / BLOCK_SIZE), READING);
  memmove(buf, &rwbuf[(int) (offset % BLOCK_SIZE)], size);
}

/* Write `size' bytes to the disk starting at byte `offset'. */
devwrite(offset, buf, size)
long offset;
char *buf;
{
  if (!repair) fatal("internal error (devwrite)");
  if (size != BLOCK_SIZE) devio((block_nr) (offset / BLOCK_SIZE), READING);
  memmove(&rwbuf[(int) (offset % BLOCK_SIZE)], buf, size);
  devio((block_nr) (offset / BLOCK_SIZE), WRITING);
  changed = 1;
}

/* Print a string with either a singular or a plural pronoun. */
pr(fmt, cnt, s, p)
char *fmt, *s, *p;
{
  printf(fmt, cnt, cnt == 1 ? s : p);
}

/* Convert string to number. */
bit_nr getnumber(s)
register char *s;
{
  register bit_nr n = 0;

  if (s == (char *) NULL)
	return NO_BIT;
  while (isdigit(*s))
	n = (n << 1) + (n << 3) + *s++ - '0';
  return (*s == '\0') ? n : NO_BIT;
}

/* See if the list pointed to by `argv' contains numbers. */
char **getlist(argv, type)
char ***argv, *type;
{
  register char **list = *argv;
  register empty = 1;

  while (getnumber(**argv) != NO_BIT) {
	(*argv)++;
	empty = 0;
  }
  if (empty) {
	printf("warning: no %s numbers given\n", type);
	return(0);
  }
  return(list);
}

/* Make a listing of the super block.  If `repair' is set, ask the user
 * for changes.
 */
lsuper()
{
  char buf[80];

  do {
	printf("ninodes       = %u", sb.s_ninodes);
	if (input(buf, 80)) sb.s_ninodes = atol(buf);
	printf("nzones        = %u", sb.s_nzones);
	if (input(buf, 80)) sb.s_nzones = atol(buf);
	printf("imap_blocks   = %u", sb.s_imap_blocks);
	if (input(buf, 80)) sb.s_imap_blocks = atol(buf);
	printf("zmap_blocks   = %u", sb.s_zmap_blocks);
	if (input(buf, 80)) sb.s_zmap_blocks = atol(buf);
	printf("firstdatazone = %u", sb.s_firstdatazone);
	if (input(buf, 80)) sb.s_firstdatazone = atol(buf);
	printf("log_zone_size = %u", sb.s_log_zone_size);
	if (input(buf, 80)) sb.s_log_zone_size = atol(buf);
	printf("maxsize       = %lu", sb.s_maxsize);
	if (input(buf, 80)) sb.s_maxsize = atol(buf);
	if (yes("ok now")) {
		devwrite(btoa(BLK_SUPER), (char *) &sb, sizeof(sb));
		return;
	}
  } while (yes("Do you want to try again"));
  if (repair) exit(0);
}

/* Get the super block from either disk or user.  Do some initial checks. */
getsuper()
{
  devread(btoa(BLK_SUPER), (char *) &sb, sizeof(sb));
  if (listsuper) lsuper();
  if (sb.s_magic != SUPER_MAGIC) fatal("bad magic number in super block");
  if ((short) sb.s_ninodes <= 0) fatal("no inodes");
  if (sb.s_nzones <= 2) fatal("no zones");
  if ((short) sb.s_imap_blocks <= 0) fatal("no imap");
  if ((short) sb.s_zmap_blocks <= 0) fatal("no zmap");
  if ((short) sb.s_firstdatazone <= 1) fatal("first data zone too small");
  if ((short) sb.s_log_zone_size < 0) fatal("zone size < block size");
  if (sb.s_maxsize <= 0) fatal("max. file size <= 0");
}

/* Check the super block for reasonable contents. */
chksuper()
{
  register n;
  register off_t maxsize;

  n = bitmapsize(1 + sb.s_ninodes);
  if (sb.s_magic != SUPER_MAGIC) fatal("bad magic number in super block");
  if ((short) sb.s_imap_blocks < n) fatal("too few imap blocks");
  if (sb.s_imap_blocks != n) {
	pr("warning: expected %d imap_block%s", n, "", "s");
	printf(" instead of %d\n", sb.s_imap_blocks);
  }
  n = bitmapsize(sb.s_nzones);
  if ((short) sb.s_zmap_blocks < n) fatal("too few zmap blocks");
  if (sb.s_zmap_blocks != n) {
	pr("warning: expected %d zmap_block%s", n, "", "s");
	printf(" instead of %d\n", sb.s_zmap_blocks);
  }
  if ((short) sb.s_firstdatazone >= sb.s_nzones)
	fatal("first data zone too large");
  if ((unsigned short) sb.s_log_zone_size >= 8 * sizeof(block_nr))
	fatal("log_zone_size too large");
  if (sb.s_log_zone_size > 8) printf("warning: large log_zone_size (%d)\n",
	       sb.s_log_zone_size);
  n = (BLK_ILIST + N_ILIST + SCALE - 1) >> sb.s_log_zone_size;
  if ((short) sb.s_firstdatazone < n) fatal("first data zone too small");
  if (sb.s_firstdatazone != n) {
	printf("warning: expected first data zone to be %d ", n);
	printf("instead of %u\n", sb.s_firstdatazone);
  }
  maxsize = MAX_FILE_POS;
  if (((maxsize - 1) >> sb.s_log_zone_size) / BLOCK_SIZE >= MAX_ZONES)
	maxsize = ((long) MAX_ZONES * BLOCK_SIZE) << sb.s_log_zone_size;
  if (sb.s_maxsize != maxsize) {
	printf("warning: expected max size to be %ld ", maxsize);
	printf("instead of %ld\n", sb.s_maxsize);
  }
}

/* Convert from bit count to a block count. The usual expression
 *
 *	(nr_bits + (1 << BITMAPSHIFT) - 1) >> BITMAPSHIFT
 *
 * doesn't work because of overflow.
 *
 * Other overflow bugs, such as the expression for N_ILIST overflowing when
 * s_inodes is just over INODES_PER_BLOCK less than the maximum+1, are not
 * fixed yet, because that number of inodes is silly.
 */
int bitmapsize(nr_bits)
bit_nr nr_bits;
{
  int nr_blocks;

  nr_blocks = nr_bits >> BITMAPSHIFT;
  if ((nr_blocks << BITMAPSHIFT) < nr_bits) ++nr_blocks;
  return(nr_blocks);
}

/* Make a listing of the inodes given by `clist'.  If `repair' is set, ask
 * the user for changes.
 */
lsi(clist)
char **clist;
{
  register bit_nr bit;
  register ino_t ino;
  d_inode inode, *ip = &inode;
  char buf[80];

  if (clist == 0) return;
  while ((bit = getnumber(*clist++)) != NO_BIT) {
	setbit(spec_imap, bit);
	ino = bit;
	do {
		devread(inoaddr(ino), (char *) ip, INODE_SIZE);
		printf("inode %u:\n", ino);
		printf("    mode   = %06o", ip->i_mode);
		if (input(buf, 80)) ip->i_mode = atoo(buf);
		printf("    nlinks = %6u", ip->i_nlinks);
		if (input(buf, 80)) ip->i_nlinks = atol(buf);
		printf("    size   = %6ld", ip->i_size);
		if (input(buf, 80)) ip->i_size = atol(buf);
		if (yes("Write this back")) {
			devwrite(inoaddr(ino), (char *) ip, INODE_SIZE);
			break;
		}
	} while (yes("Do you want to change it again"));
  }
}

/* Allocate `nblk' blocks worth of bitmap. */
unsigned *allocbitmap(nblk)
{
  register unsigned *bitmap;

  bitmap = (unsigned *) alloc(nblk, BLOCK_SIZE);
  *bitmap |= 1;
  return(bitmap);
}

/* Load the bitmap starting at block `bno' from disk. */
loadbitmap(bitmap, bno, nblk)
unsigned *bitmap;
block_nr bno;
{
  register i;
  register unsigned *p;

  p = bitmap;
  for (i = 0; i < nblk; i++, bno++, p += INTS_PER_BLOCK)
	devread(btoa(bno), (char *) p, BLOCK_SIZE);
  *bitmap |= 1;
}

/* Write the bitmap starting at block `bno' to disk. */
dumpbitmap(bitmap, bno, nblk)
unsigned *bitmap;
block_nr bno;
{
  register i;
  register unsigned *p = bitmap;

  for (i = 0; i < nblk; i++, bno++, p += INTS_PER_BLOCK)
	devwrite(btoa(bno), (char *) p, BLOCK_SIZE);
}

/* Initialize the given bitmap by setting all the bits starting at `bit'. */
initbitmap(bitmap, bit, nblk)
unsigned *bitmap;
bit_nr bit;
{
  register unsigned *first, *last;

  while (bit & BITMASK) {
	setbit(bitmap, bit);
	bit++;
  }
  first = &bitmap[bit >> BITSHIFT];
  last = &bitmap[nblk * INTS_PER_BLOCK];
  while (first < last) *first++ = ~(unsigned) 0;
}

/* Set the bits given by `list' in the bitmap. */
fillbitmap(bitmap, lwb, upb, list)
unsigned *bitmap;
bit_nr lwb, upb;
char **list;
{
  register bit_nr bit;

  if (list == 0) return;
  while ((bit = getnumber(*list++)) != NO_BIT)
	if (bit < lwb || bit >= upb) {
		if (bitmap == spec_imap)
			printf("inode number %u ", bit);
		else
			printf("zone number %u ", bit);
		printf("out of range (ignored)\n");
	} else
		setbit(bitmap, bit - lwb + 1);
}

/* Deallocate the bitmap `p'. */
freebitmap(p)
unsigned *p;
{
  free((char *) p);
}

/* Get all the bitmaps used by this program. */
getbitmaps()
{
  imap = allocbitmap(N_IMAP);
  zmap = allocbitmap(N_ZMAP);
  spec_imap = allocbitmap(N_IMAP);
  spec_zmap = allocbitmap(N_ZMAP);
  dirmap = allocbitmap(N_IMAP);
}

/* Release all the space taken by the bitmaps. */
putbitmaps()
{
  freebitmap(imap);
  freebitmap(zmap);
  freebitmap(spec_imap);
  freebitmap(spec_zmap);
  freebitmap(dirmap);
}

/* `w1' and `w2' are differing words from two bitmaps that should be
 * identical.  Print what's the matter with them.
 */
chkword(w1, w2, bit, nbit, type, n, report)
unsigned w1, w2;
char *type;
bit_nr bit, nbit;
int *n, *report;
{
  for (; (w1 | w2) && bit < nbit; w1 >>= 1, w2 >>= 1, bit++)
	if ((w1 ^ w2) & 1 && ++(*n) % MAXPRINT == 0 && *report &&
	    (!repair || automatic || yes("stop this listing")))
		*report = 0;
	else if (*report)
		if ((w1 & 1) && !(w2 & 1))
			printf("%s %u is missing\n", type, bit);
		else if (!(w1 & 1) && (w2 & 1))
			printf("%s %u is not free\n", type, bit);
}

/* Check if the given (correct) bitmap is identical with the one that is
 * on the disk.  If not, ask if the disk should be repaired.
 */
chkmap(cmap, dmap, bit, blkno, nblk, nbit, type)
unsigned *cmap, *dmap;
bit_nr bit, nbit;
block_nr blkno;
char *type;
{
  register unsigned *p = dmap, *q = cmap;
  int report = 1, nerr = 0;

  printf("Checking %s map\n", type);
  loadbitmap(dmap, blkno, nblk);
  do {
	if (*p != *q) chkword(*p, *q, bit, nbit, type, &nerr, &report);
	p++;
	q++;
  } while ((bit += 8 * sizeof(unsigned)) < nbit
	 && bit >= 8 * sizeof(unsigned));	/* += may overflow */
  if ((!repair || automatic) && !report) printf("etc. ");
  if (nerr > MAXPRINT || nerr > 10) printf("%d errors found. ", nerr);
  if (nerr != 0 && yes("install a new map")) dumpbitmap(cmap, blkno, nblk);
  if (nerr > 0) printf("\n");
}

/* See if the inodes that aren't allocated are cleared. */
chkilist()
{
  register ino_t ino = 1;
  mode_t mode;

  printf("Checking inode list\n");
  do
	if (!bitset(imap, (bit_nr) ino)) {
		devread(inoaddr(ino), (char *) &mode, sizeof(mode));
		if (mode != I_NOT_ALLOC) {
			printf("mode inode %u not cleared", ino);
			if (yes(". clear")) devwrite(inoaddr(ino), nullbuf,
					 INODE_SIZE);
		}
	}
  while (++ino <= sb.s_ninodes);
  printf("\n");
}

/* Allocate an array to maintain the inode reference counts in. */
getcount()
{
  count = (nlink_t *) alloc(sb.s_ninodes + 1, sizeof(nlink_t));
}

/* The reference count for inode `ino' is wrong.  Ask if it should be adjusted. */
counterror(ino)
ino_t ino;
{
  d_inode inode;

  if (firstcnterr) {
	printf("INODE NLINK COUNT\n");
	firstcnterr = 0;
  }
  devread(inoaddr(ino), (char *) &inode, INODE_SIZE);
  count[ino] += inode.i_nlinks;
  printf("%5u %5u %5u", ino, (unsigned) inode.i_nlinks, count[ino]);
  if (yes(" adjust")) {
	if ((inode.i_nlinks = count[ino]) == 0) {
		fatal("internal error (counterror)");
/* This would be a patch
		inode.i_mode = I_NOT_ALLOC;
		clrbit(imap, (bit_nr) ino);
*/
	}
	devwrite(inoaddr(ino), (char *) &inode, INODE_SIZE);
  }
}

/* Check if the reference count of the inodes are correct.  The array `count'
 * is maintained as follows:  an entry indexed by the inode number is
 * incremented each time a link is found; when the inode is read the link
 * count in there is substracted from the corresponding entry in `count'.
 * Thus, when the whole file system has been traversed, all the entries
 * should be zero.
 */
chkcount()
{
  register ino_t ino;

  for (ino = 1; ino <= sb.s_ninodes; ino++)
	if (count[ino] != 0) counterror(ino);
  if (!firstcnterr) printf("\n");
}

/* Deallocate the `count' array. */
freecount()
{
  free((char *) count);
}

/* Print the inode permission bits given by mode and shift. */
printperm(mode, shift, special, overlay)
mode_t mode;
{
  if (mode >> shift & R_BIT)
	putchar('r');
  else
	putchar('-');
  if (mode >> shift & W_BIT)
	putchar('w');
  else
	putchar('-');
  if (mode & special)
	putchar(overlay);
  else
	if (mode >> shift & X_BIT)
		putchar('x');
	else
		putchar('-');
}

/* List the given inode. */
list(ino, ip)
ino_t ino;
d_inode *ip;
{
  if (firstlist) {
	firstlist = 0;
	printf(" inode permission link   size name\n");
  }
  printf("%6u ", ino);
  switch (ip->i_mode & I_TYPE) {
      case I_REGULAR:		putchar('-');	break;
      case I_DIRECTORY:		putchar('d');	break;
      case I_CHAR_SPECIAL:	putchar('c');	break;
      case I_BLOCK_SPECIAL:	putchar('b');	break;
      case I_NAMED_PIPE:	putchar('p');	break;
      default:			putchar('?');
}
  printperm(ip->i_mode, 6, I_SET_UID_BIT, 's');
  printperm(ip->i_mode, 3, I_SET_GID_BIT, 's');
  printperm(ip->i_mode, 0, STICKY_BIT, 't');
  printf(" %3u ", ip->i_nlinks);
  switch (ip->i_mode & I_TYPE) {
      case I_CHAR_SPECIAL:
      case I_BLOCK_SPECIAL:
	printf("  %2x,%2x ", (dev_t) ip->i_zone[0] >> MAJOR & 0xFF,
	       (dev_t) ip->i_zone[0] >> MINOR & 0xFF);
	break;
      default:	printf("%7ld ", ip->i_size);
}
  printpath(0, 1);
}

/* Remove an entry from a directory if ok with the user.
 * Don't name the function remove() - that is owned by ANSI, and chaos results
 * when it is a macro.
 */
Remove(dp)
dir_struct *dp;
{
  setbit(spec_imap, (bit_nr) dp->d_inum);
  if (yes(". remove entry")) {
	count[dp->d_inum]--;
	memset((void *) dp, 0, sizeof(dir_struct));
	return(1);
  }
  return(0);
}

/* Convert string so that embedded control characters are printable. */
void make_printable_name(dst, src, n)
register char *dst;
register char *src;
register int n;
{
  register int c;

  while (--n >= 0 && (c = *src++) != '\0') {
	if (isprint(c) && c != '\\')
		*dst++ = c;
	else {
		*dst++ = '\\';
		switch (c) {
		      case '\\':
			*dst++ = '\\'; break;
		      case '\b':
			*dst++ = 'b'; break;
		      case '\f':
			*dst++ = 'f'; break;
		      case '\n':
			*dst++ = 'n'; break;
		      case '\r':
			*dst++ = 'r'; break;
		      case '\t':
			*dst++ = 't'; break;
		      default:
			*dst++ = '0' + ((c >> 6) & 03);
			*dst++ = '0' + ((c >> 3) & 07);
			*dst++ = '0' + (c & 07);
		}
	}
  }
  *dst = '\0';
}

/* See if the `.' or `..' entry is as expected. */
chkdots(ino, pos, dp, exp)
ino_t ino, exp;
off_t pos;
dir_struct *dp;
{
  char printable_name[4 * NAME_MAX + 1];

  if (dp->d_inum != exp) {
	make_printable_name(printable_name, dp->d_name, sizeof(dp->d_name));
	printf("bad %s in ", printable_name);
	printpath(1, 0);
	printf("%s is linked to %u ", printable_name, dp->d_inum);
	printf("instead of %u)", exp);
	setbit(spec_imap, (bit_nr) ino);
	setbit(spec_imap, (bit_nr) dp->d_inum);
	setbit(spec_imap, (bit_nr) exp);
	if (yes(". repair")) {
		count[dp->d_inum]--;
		dp->d_inum = exp;
		count[exp]++;
		return(0);
	}
  } else if (pos != (dp->d_name[1] ? DIR_ENTRY_SIZE : 0)) {
	make_printable_name(printable_name, dp->d_name, sizeof(dp->d_name));
	printf("warning: %s has offset %ld in ", printable_name, pos);
	printpath(1, 0);
	printf("%s is linked to %u)\n", printable_name, dp->d_inum);
	setbit(spec_imap, (bit_nr) ino);
	setbit(spec_imap, (bit_nr) dp->d_inum);
	setbit(spec_imap, (bit_nr) exp);
  }
  return(1);
}

/* Check the name in a directory entry. */
chkname(ino, dp)
ino_t ino;
dir_struct *dp;
{
  register n = NAME_MAX + 1;
  register char *p = dp->d_name;

  if (*p == '\0') {
	printf("null name found in ");
	printpath(0, 0);
	setbit(spec_imap, (bit_nr) ino);
	if (Remove(dp)) return(0);
  }
  while (*p != '\0' && --n != 0)
	if (*p++ == '/') {
		printf("found a '/' in entry of directory ");
		printpath(1, 0);
		setbit(spec_imap, (bit_nr) ino);
		printf("entry = '");
		printname(dp->d_name);
		printf("')");
		if (Remove(dp)) return(0);
		break;
	}
  return(1);
}

/* Check a directory entry.  Here the routine `descendtree' is called
 * recursively to check the file or directory pointed to by the entry.
 */
chkentry(ino, pos, dp)
ino_t ino;
off_t pos;
dir_struct *dp;
{
  if (dp->d_inum < ROOT_INODE || dp->d_inum > sb.s_ninodes) {
	printf("bad inode found in directory ");
	printpath(1, 0);
	printf("ino found = %u, ", dp->d_inum);
	printf("name = '");
	printname(dp->d_name);
	printf("')");
	if (yes(". remove entry")) {
		memset((void *) dp, 0, sizeof(dir_struct));
		return(0);
	}
	return(1);
  }
  if ((unsigned) count[dp->d_inum] == LINK_MAX) {
	printf("too many links to ino %u\n", dp->d_inum);
	printf("discovered at entry '");
	printname(dp->d_name);
	printf("' in directory ");
	printpath(0, 1);
	if (Remove(dp)) return(0);
  }
  count[dp->d_inum]++;
  if (strcmp(dp->d_name, ".") == 0) {
	ftop->st_presence |= DOT;
	return(chkdots(ino, pos, dp, ino));
  }
  if (strcmp(dp->d_name, "..") == 0) {
	ftop->st_presence |= DOTDOT;
	return(chkdots(ino, pos, dp, ino == ROOT_INODE ? ino :
			ftop->st_next->st_dir->d_inum));
  }
  if (!chkname(ino, dp)) return(0);
  if (bitset(dirmap, (bit_nr) dp->d_inum)) {
	printf("link to directory discovered in ");
	printpath(1, 0);
	printf("name = '");
	printname(dp->d_name);
	printf("', dir ino = %u)", dp->d_inum);
	return !Remove(dp);
  }
  return(descendtree(dp));
}

/* Check a zone of a directory by checking all the entries in the zone.
 * The zone is split up into chunks to not allocate too much stack.
 */
chkdirzone(ino, ip, pos, zno)
ino_t ino;
d_inode *ip;
off_t pos;
zone_nr zno;
{
  dir_struct dirblk[CDIRECT];
  register dir_struct *dp;
  register n = SCALE * (NR_DIR_ENTRIES / CDIRECT), dirty;
  register long offset = zaddr(zno);

  do {
	devread(offset, (char *) dirblk, DIRCHUNK);
	dirty = 0;
	for (dp = dirblk; dp < &dirblk[CDIRECT]; dp++) {
		if (ip->i_size - pos < DIR_ENTRY_SIZE) {
			printf("bad format in directory ");
			printpath(2, 0);
			if (yes(". truncate")) {
				setbit(spec_imap, (bit_nr) ino);
				ip->i_size = pos;
				dirty = 1;
			} else
				return(0);
		}
		if (dp->d_inum != NO_ENTRY && !chkentry(ino, pos, dp))
			dirty = 1;
		if ((pos += DIR_ENTRY_SIZE) >= ip->i_size) break;
	}
	if (dirty) devwrite(offset, (char *) dirblk, DIRCHUNK);
	offset += DIRCHUNK;
  } while (--n && pos < ip->i_size);
  return(1);
}

/* There is something wrong with the given zone.  Print some details. */
errzone(mess, zno, level, pos)
char *mess;
zone_nr zno;
off_t pos;
{
  printf("%s zone in ", mess);
  printpath(1, 0);
  printf("zno = %u, type = ", zno);
  switch (level) {
      case 0:	printf("DATA");	break;
      case 1:	printf("SINGLE INDIRECT");	break;
      case 2:	printf("DOUBLE INDIRECT");	break;
      default:	printf("VERY INDIRECT");
}
  printf(", pos = %ld)\n", pos);
}

/* Found the given zone in the given inode.  Check it, and if ok, mark it
 * in the zone bitmap.
 */
markzone(ino, zno, level, pos)
ino_t ino;
zone_nr zno;
off_t pos;
{
  register bit_nr bit = (bit_nr) zno - FIRST + 1;

  ztype[level]++;
  if (zno < FIRST || zno >= sb.s_nzones) {
	errzone("out-of-range", zno, level, pos);
	return(0);
  }
  if (bitset(zmap, bit)) {
	setbit(spec_zmap, bit);
	errzone("duplicate", zno, level, pos);
	return(0);
  }
  nfreezone--;
  if (bitset(spec_zmap, bit)) errzone("found", ino, zno, level, pos, bit);
  setbit(zmap, bit);
  return(1);
}

/* Check an indirect zone by checking all of its entries.
 * The zone is split up into chunks to not allocate too much stack.
 */
chkindzone(ino, ip, pos, zno, level)
ino_t ino;
d_inode *ip;
off_t *pos;
zone_nr zno;
{
  zone_nr indirect[CINDIR];
  register n = NR_INDIRECTS / CINDIR;
  register long offset = zaddr(zno);

  do {
	devread(offset, (char *) indirect, INDCHUNK);
	if (!chkzones(ino, ip, pos, indirect, CINDIR, level - 1)) return(0);
	offset += INDCHUNK;
  } while (--n && *pos < ip->i_size);
  return(1);
}

/* Return the size of a gap in the file, represented by a null zone number
 * at some level of indirection.
 */
off_t jump(level)
{
  off_t power = ZONE_SIZE;

  if (level != 0) do
		power *= NR_INDIRECTS;
	while (--level);
  return(power);
}

/* Check a zone, which may be either a normal data zone, a directory zone,
 * or an indirect zone.
 */
zonechk(ino, ip, pos, zno, level)
ino_t ino;
d_inode *ip;
off_t *pos;
zone_nr zno;
{
  if (level == 0) {
	if ((ip->i_mode & I_TYPE) == I_DIRECTORY &&
	    !chkdirzone(ino, ip, *pos, zno))
		return(0);
	*pos += ZONE_SIZE;
	return(1);
  } else
	return chkindzone(ino, ip, pos, zno, level);
}

/* Check a list of zones given by `zlist'. */
chkzones(ino, ip, pos, zlist, len, level)
ino_t ino;
d_inode *ip;
off_t *pos;
zone_nr *zlist;
{
  register ok = 1, i;

  for (i = 0; i < len && *pos < ip->i_size; i++)
	if (zlist[i] == NO_ZONE)
		*pos += jump(level);
	else if (!markzone(ino, zlist[i], level, *pos)) {
		*pos += jump(level);
		ok = 0;
	} else if (!zonechk(ino, ip, pos, zlist[i], level))
		ok = 0;
  return(ok);
}

/* Check a file or a directory. */
chkfile(ino, ip)
ino_t ino;
d_inode *ip;
{
  register ok, i, level;
  off_t pos = 0;

  ok = chkzones(ino, ip, &pos, &ip->i_zone[0], NR_DZONE_NUM, 0);
  for (i = NR_DZONE_NUM, level = 1; i < NR_ZONE_NUMS; i++, level++)
	ok &= chkzones(ino, ip, &pos, &ip->i_zone[i], 1, level);
  return(ok);
}

/* Check a directory by checking the contents.  Check if . and .. are present. */
chkdirectory(ino, ip)
ino_t ino;
d_inode *ip;
{
  register ok;

  setbit(dirmap, (bit_nr) ino);
  if (ip->i_size > MAXDIRSIZE) {
	printf("warning: huge directory: ");
	printpath(2, 1);
  }
  ok = chkfile(ino, ip);
  if (!(ftop->st_presence & DOT)) {
	printf(". missing in ");
	printpath(2, 1);
	ok = 0;
  }
  if (!(ftop->st_presence & DOTDOT)) {
	printf(".. missing in ");
	printpath(2, 1);
	ok = 0;
  }
  return(ok);
}

/* Check the mode of an inode, and if it is a file or a directory, check
 * the contents.
 */
chkmode(ino, ip)
ino_t ino;
d_inode *ip;
{
  switch (ip->i_mode & I_TYPE) {
      case I_REGULAR:
	nregular++;
	return chkfile(ino, ip);
	break;
      case I_DIRECTORY:
	ndirectory++;
	return chkdirectory(ino, ip);
      case I_BLOCK_SPECIAL:
	nblkspec++;
	return(1);
      case I_CHAR_SPECIAL:
	ncharspec++;
	return(1);
      case I_NAMED_PIPE:
	npipe++;
	return(1);
      default:
	nbadinode++;
	printf("bad mode of ");
	printpath(1, 0);
	printf("mode = %o)", ip->i_mode);
	return(0);
  }
}

/* Check an inode. */
chkinode(ino, ip)
ino_t ino;
d_inode *ip;
{
  if (ino == ROOT_INODE && (ip->i_mode & I_TYPE) != I_DIRECTORY) {
	printf("root inode is not a directory ");
	printf("(ino = %u, mode = %o)\n", ino, ip->i_mode);
	fatal("");
  }
  if (ip->i_nlinks == 0) {
	printf("link count zero of ");
	printpath(2, 0);
	return(0);
  }
  nfreeinode--;
  setbit(imap, (bit_nr) ino);
  if ((unsigned) ip->i_nlinks > LINK_MAX) {
	printf("link count too big in ");
	printpath(1, 0);
	printf("cnt = %u)\n", (unsigned) ip->i_nlinks);
	count[ino] -= LINK_MAX;
	setbit(spec_imap, (bit_nr) ino);
  } else
	count[ino] -= (unsigned) ip->i_nlinks;
  return chkmode(ino, ip);
}

/* Check the directory entry pointed to by dp, by checking the inode. */
descendtree(dp)
dir_struct *dp;
{
  d_inode inode;
  register ino_t ino = dp->d_inum;
  register visited;
  struct stack stk;

  stk.st_dir = dp;
  stk.st_next = ftop;
  ftop = &stk;
  if (bitset(spec_imap, (bit_nr) ino)) {
	printf("found inode %u: ", ino);
	printpath(0, 1);
  }
  visited = bitset(imap, (bit_nr) ino);
  if (!visited || listing) {
	devread(inoaddr(ino), (char *) &inode, INODE_SIZE);
	if (listing) list(ino, &inode);
	if (!visited && !chkinode(ino, &inode)) {
		setbit(spec_imap, (bit_nr) ino);
		if (yes("remove")) {
			count[ino] += inode.i_nlinks - 1;
			clrbit(imap, (bit_nr) ino);
			devwrite(inoaddr(ino), nullbuf, INODE_SIZE);
			memset((void *) dp, 0, sizeof(dir_struct));
			ftop = ftop->st_next;
			return(0);
		}
	}
  }
  ftop = ftop->st_next;
  return(1);
}

/* Check the file system tree. */
chktree()
{
  dir_struct dir;

  nfreeinode = sb.s_ninodes;
  nfreezone = N_DATA;
  dir.d_inum = ROOT_INODE;
  dir.d_name[0] = 0;
  if (!descendtree(&dir)) fatal("bad root inode");
  putchar('\n');
}

/* Print the totals of all the objects found. */
printtotal()
{
  printf("blocksize = %5d        ", BLOCK_SIZE);
  printf("zonesize  = %5d\n", ZONE_SIZE);
  printf("\n");
  pr("%6u    Regular file%s\n", nregular, "", "s");
  pr("%6u    Director%s\n", ndirectory, "y", "ies");
  pr("%6u    Block special file%s\n", nblkspec, "", "s");
  pr("%6u    Character special file%s\n", ncharspec, "", "s");
  if (nbadinode != 0) pr("%6u    Bad inode%s\n", nbadinode, "", "s");
  pr("%6u    Free inode%s\n", nfreeinode, "", "s");
  pr("%6u    Named pipe%s\n", npipe, "", "s");
/* Don't print some fields.
  printf("\n");
  pr("%6u    Data zone%s\n",		  ztype[0],	 "",   "s");
  pr("%6u    Single indirect zone%s\n",	  ztype[1],	 "",   "s");
  pr("%6u    Double indirect zone%s\n",	  ztype[2],	 "",   "s");
*/
  pr("%6u    Free zone%s\n", nfreezone, "", "s");
}

/* Check the device which name is given by `f'.  The inodes listed by `clist'
 * should be listed separately, and the inodes listed by `ilist' and the zones
 * listed by `zlist' should be watched for while checking the file system.
 */

chkdev(f, clist, ilist, zlist)
char *f, **clist, **ilist, **zlist;
{
  if (automatic) repair = 1;
  device = f;
  initvars();

  devopen();

  getsuper();
  chksuper();

  lsi(clist);

  getbitmaps();
  initbitmap(imap, (bit_nr) sb.s_ninodes + 1, N_IMAP);
  initbitmap(zmap, (bit_nr) sb.s_nzones - FIRST + 1, N_ZMAP);

  fillbitmap(spec_imap, (bit_nr) 1, (bit_nr) sb.s_ninodes + 1, ilist);
  fillbitmap(spec_zmap, (bit_nr) FIRST, (bit_nr) sb.s_nzones, zlist);

  getcount();
  chktree();
  chkmap(zmap, spec_zmap, (bit_nr) FIRST - 1, BLK_ZMAP, N_ZMAP,
         (bit_nr) sb.s_nzones, "zone");
  chkcount();
  chkmap(imap, spec_imap, (bit_nr) 0, BLK_IMAP, N_IMAP,
         (bit_nr) sb.s_ninodes + 1, "inode");
  chkilist();
  printtotal();

  putbitmaps();
  freecount();
  devclose();

  if (changed) printf("----- FILE SYSTEM HAS BEEN MODIFIED -----\n\n");
}

main(argc, argv)
char **argv;
{
  register char **clist = 0, **ilist = 0, **zlist = 0;

  register devgiven = 0;
  register char *arg;

  if ((1 << BITSHIFT) != 8 * sizeof(int)) {
	printf("Fsck was compiled with the wrong BITSHIFT!\n");
	exit(1);
  }

  sync();
  prog = *argv++;
  while ((arg = *argv++) != 0)
	if (arg[0] == '-' && arg[1] != 0 && arg[2] == 0) switch (arg[1]) {
		    case 'a':	automatic ^= 1;	break;
		    case 'c':
			clist = getlist(&argv, "inode");
			break;
		    case 'i':
			ilist = getlist(&argv, "inode");
			break;
		    case 'z':
			zlist = getlist(&argv, "zone");
			break;
		    case 'r':	repair ^= 1;	break;
		    case 'l':	listing ^= 1;	break;
		    case 's':	listsuper ^= 1;	break;
		    default:
			printf("%s: unknown flag '%s'\n", prog, arg);
		}
	else {
		chkdev(arg, clist, ilist, zlist);
		clist = 0;
		ilist = 0;
		zlist = 0;
		devgiven = 1;
	}
  if (!devgiven) {
	printf("Usage: fsck [-acilrsz] file\n");
	exit(1);
  }
  return(0);
}

