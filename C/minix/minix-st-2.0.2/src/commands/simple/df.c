/* df - disk free block printout	Author: Andy Tanenbaum */

#include <sys/types.h>
#include <sys/stat.h>
#include <limits.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <minix/minlib.h>
#include <minix/config.h>
#include <minix/const.h>
#include <minix/type.h>
#include "../../fs/const.h"
#include "../../fs/type.h"
#include "../../fs/super.h"

#include <stdio.h>

#define REPORT 0
#define SILENT 1
#define NL    12		/* name length */

_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(int df, (char *name, char *mnton, char *version, char *rw_flag, int silent ));
_PROTOTYPE(bit_t bit_count, (int blocks, bit_t bits, int fd ));
_PROTOTYPE(void defaults, (void ));

int main(argc, argv)
int argc;
char *argv[];
{
  register int i;
  int ex= 0;

  sync();			/* have to make sure disk is up-to-date */
  fprintf(stdout, "\nDevice     Inodes  Inodes  Inodes     Blocks  Blocks  Blocks");
  if (argc == 1)
	fprintf(stdout, "  Mounted      V Pr\n");
  else
	fprintf(stdout, "\n");

  fprintf(stdout, "           total   used    free       total   used    free");

  if (argc == 1)
	fprintf(stdout, "      on\n");
  else
	fprintf(stdout, "\n");

  fprintf(stdout, "           -----   -----   -----      -----   -----   -----");

  if (argc == 1)
	fprintf(stdout, "   -------      - --\n");
  else
	fprintf(stdout, "\n");

  if (argc == 1) defaults();

  for (i = 1; i < argc; i++) ex |= df(argv[i], "", "", "", SILENT);
  return(ex);
}


#define percent(num, tot)  ((int) ((100L * (num) + ((tot) - 1)) / (tot)))

int df(name, mnton, version, rw_flag, silent)
char *name, *mnton, *version, *rw_flag;
int silent;
{
  register int j, fd;
  char devname[32];
  bit_t i_count, z_count, b;
  block_t totblocks, busyblocks;
  struct super_block super, *sp;

  if ((fd = open(name, O_RDONLY)) < 0) {
	if (!silent) {
		int e = errno;

		fprintf(stderr, "df: ");
		errno = e;
		perror(name);
	}
	return(1);
  }
  lseek(fd, (off_t) BLOCK_SIZE, SEEK_SET);	/* skip boot block */
  if (read(fd, (char *) &super, (unsigned) SUPER_SIZE) != SUPER_SIZE) {
	fprintf(stderr, "df: Can't read super block of %s\n", name);
	close(fd);
	return(1);
  }
  lseek(fd, (off_t) BLOCK_SIZE * 2L, SEEK_SET);	/* skip rest of super block */
  sp = &super;
  if (sp->s_magic == SUPER_MAGIC)
	sp->s_zones = sp->s_nzones;
  else if (sp->s_magic != SUPER_V2) {
	close(fd);
	if (sp->s_magic == SUPER_REV || sp->s_magic == SUPER_V2_REV) 
		fprintf(stderr, "df: %s: Foreign (byte-swapped) file system\n", name);
	else
		fprintf(stderr, "df: %s: Not a valid file system\n", name);
	return(1);
  }
  i_count = bit_count(sp->s_imap_blocks, (bit_t) sp->s_ninodes + 1, fd);
  if (i_count == -1) {
	fprintf(stderr, "df: Can't find bit maps of %s\n", name);
	close(fd);
	return(1);
  }
  i_count--;			/* There is no inode 0. */

  b = (bit_t) sp->s_zones - (sp->s_firstdatazone - 1);
  z_count = bit_count(sp->s_zmap_blocks, b, fd);
  if (z_count == -1) {
	fprintf(stderr, "df: Can't find bit maps of %s\n", name);
	close(fd);
	return(1);
  }
  totblocks = (block_t) sp->s_zones << sp->s_log_zone_size;
  z_count += sp->s_firstdatazone - 1;
  busyblocks = (block_t) z_count << sp->s_log_zone_size;

  /* Truncate device name to NL chars. */
  for (j = 0; j < NL; j++) devname[j] = ' ';
  strncpy(devname, mnton, (size_t)NL);
  for (j = 0; j < NL; j++) if(devname[j] == '\0') devname[j] = ' ';
  devname[NL] = '\0';

  /* Print results. */
  fprintf(stdout, "%s", name);
  j = 10 - strlen(name);
  while (j > 0) {
	fprintf(stdout, " ");
	j--;
  }

 
  fprintf(stdout, " %5u   %5ld   %5ld    %7ld %7ld %7ld   %s %s %s\n",
	sp->s_ninodes,		/* total inodes */
	i_count,		/* inodes used */
	sp->s_ninodes - i_count,/* inodes free */

	totblocks,		/* total blocks */
	busyblocks,		/* blocks used */
	totblocks - busyblocks,	/* blocks free */

	devname,		/* mounted on */
	version,		/* 1 or 2 */
	rw_flag			/* rw or ro */
	);
  close(fd);
  return(0);
}

bit_t bit_count(blocks, bits, fd)
int blocks;
bit_t bits;
int fd;
{
  register char *wptr;
  register int i;
  register int b;
  register bit_t busy;
  register char *wlim;
  static char buf[BLOCK_SIZE];
  static unsigned bits_in_char[1 << CHAR_BIT];

  /* Precalculate bitcount for each char. */
  if (bits_in_char[1] != 1) {
	for (b = (1 << 0); b < (1 << CHAR_BIT); b <<= 1)
		for (i = 0; i < (1 << CHAR_BIT); i++)
			if (i & b) bits_in_char[i]++;
  }

  /* Loop on blocks, reading one at a time and counting bits. */
  busy = 0;
  for (i = 0; i < blocks && bits != 0; i++) {
	if (read(fd, buf, (unsigned) BLOCK_SIZE) != BLOCK_SIZE) return(-1);

	wptr = &buf[0];
	if (bits >= CHAR_BIT * BLOCK_SIZE) {
		wlim = &buf[BLOCK_SIZE];
		bits -= CHAR_BIT * BLOCK_SIZE;
	} else {
		b = (int) bits / CHAR_BIT;	/* whole chars in map */
		wlim = &buf[b];
		bits -= b * CHAR_BIT;	/* bits in last char, if any */
		b = *wlim & ((1 << bits) - 1);	/* bit pattern from last ch */
		busy += bits_in_char[b];
		bits = 0;
	}

	/* Loop on the chars of a block. */
	while (wptr != wlim)
		busy += bits_in_char[*wptr++ & ((1 << CHAR_BIT) - 1)];
  }
  return(busy);
}



void defaults()
{
/* Use the root file system and all mounted file systems. */

  char special[PATH_MAX+1], mounted_on[PATH_MAX+1], version[10], rw_flag[10];
  int ex= 0;

  /* Read in /etc/mtab. */
  if (load_mtab("df") < 0) exit(1);

  /* Read /etc/mtab and iterate on the lines. */
  while (1) {
	get_mtab_entry(special, mounted_on, version, rw_flag);
	if (special[0] == '\0') exit(0);
	ex |= df(special, mounted_on, version, rw_flag, REPORT);
  }
  exit(ex);
}
