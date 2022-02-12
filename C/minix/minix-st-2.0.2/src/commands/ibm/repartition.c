/*	repartition 1.15 - Load a partition table	Author: Kees J. Bot
 *								30 Nov 1991
 */
#define nil 0
#include <stdio.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <minix/config.h>
#include <minix/const.h>
#include <minix/partition.h>
#include <ibm/partition.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>

#if !__minix_vmd
#define div64u(i, j)	((i) / (j))
#define mul64u(i, j)	((i) * (j))
#endif

#define DEV_FD0		0x200

#define SECTOR_SIZE	512

#define arraysize(a)	(sizeof(a)/sizeof((a)[0]))
#define arraylimit(a)	((a) + arraysize(a))

char *arg0;
char *dev_file;		/* Device to repartition. */

void report(const char *label)
{
	fprintf(stderr, "%s: %s: %s\n", arg0, label, strerror(errno));
}

void fatal(const char *label)
{
	report(label);
	exit(1);
}

#ifndef makedev
#define minor(dev)	(((dev) >> MINOR) & BYTE)
#define major(dev)	(((dev) >> MAJOR) & BYTE)
#define makedev(major, minor)	\
			((dev_t) (((major) << MAJOR) | ((minor) << MINOR)))
#endif

#define MINOR_hd1a	128

void partsort(struct part_entry *pe)
/* DOS has the misguided idea that partition tables must be sorted. */
{
  int i,j;
  struct part_entry tmp;

  for (i = 0; i < NR_PARTITIONS; i++)
	for (j = 0; j < NR_PARTITIONS-1; j++)
		if ((pe[j].sysind == NO_PART && pe[j+1].sysind != NO_PART) ||
		 (pe[j].lowsec > pe[j+1].lowsec && pe[j+1].sysind != NO_PART)) {
			tmp = pe[j];
			pe[j] = pe[j+1];
			pe[j+1] = tmp;
		}
}

char *devname(dev_t dev)
/* Create a device name for device number dev.  Use dev_file as template. */
{
	static char *dname;
	char *p;
	int prefix;
	int drive, par, sub;
	static char subs[]= { 0, 'a', 'b', 'c', 'd' };

	if (dname != nil) free(dname);

	if ((p= strrchr(dev_file, '/')) == nil) p= dev_file; else p++;
	while (('a' <= *p && *p <= 'z') || ('A' <= *p && *p <= 'Z')) p++;
	prefix= p - dev_file;

	if ((dname= malloc((prefix + 4) * sizeof(dname[0]))) == nil)
		fatal("malloc()");
	if (major(dev) == major(DEV_FD0)) {
		/* Floppies are different. */
		drive= minor(dev) & 0x03;
		par= (minor(dev) & 0x7C) >> 2;
		par= par < 28 ? 0 : par - 28 + 1;
		sprintf(dname, "%.*s%d%c", prefix, dev_file, drive, subs[par]);
	} else {
		/* Some hard disk. */
		if (minor(dev) < 128) {
			drive= minor(dev) / 5;
			par= minor(dev) % 5;
			sub= 0;
		} else {
			drive= (minor(dev) - 128) >> 4;
			par= (((minor(dev) - 128) >> 2) & 0x03) + 1;
			sub= ((minor(dev) - 128) & 0x03) + 1;
		}
		sprintf(dname, "%.*s%d%c", prefix, dev_file,
						drive * 5 + par, subs[sub]);
	}
	return dname;
}

#define DSETP	0
#define DGETP	1

int diocntl(dev_t device, int request, struct partition *entry)
/* Get or set the geometry of a device. */
{
	char *name;
	int r, f, err;
	struct partition geometry;

	name= devname(device);

	if ((f= open(name, O_RDONLY)) < 0) return -1;
	r= ioctl(f, request == DSETP ? DIOCSETP : DIOCGETP, (void *) entry);
	err= errno;
	(void) close(f);
	errno= err;
	return r;
}

struct partition geometry;	/* Geometry of the device. */

void print_chs(unsigned long sector)
{
	unsigned secspcyl = geometry.heads * geometry.sectors;
	int delta= 0;

	if (sector == -1) { sector= 0; delta= -1; }

	printf("  %4d/%03d/%02d",
		(int) (sector / secspcyl),
		(int) (sector % secspcyl) / geometry.sectors,
		(int) (sector % geometry.sectors) + delta);
}

void show_part(char *name, unsigned long base, unsigned long size)
{
	int i;
	static int len= 0;

	if (len == 0) {
		len= strlen(name) + 3;
		printf("device");
		for (i = 6; i < len; i++) fputc(' ', stdout);
		printf(
		"      first         last        base      size       kb\n");
	}

	printf("%s", name);
	for (i = strlen(name); i < len; i++) fputc(' ', stdout);

	print_chs(base);
	print_chs(base + size - 1);
	printf("  %8lu  %8lu  %7lu\n", base, size, size / (1024/SECTOR_SIZE));
}

int main(int argc, char **argv)
{
	struct stat hdst;
	struct partition whole, entry;
	struct part_entry table[4], *pe;
	int drive, par, device, incr;
	int partf;
	char *table_file;
	int hd_major, hd_minor;
	int needsort;
	int shrink;		/* True if partitions are shrinked to fit. */
	unsigned long base, size, limit;

	if ((arg0= strrchr(argv[0], '/')) == nil) arg0= argv[0]; else arg0++;

	if (argc < 2 || argc > 3) {
		fprintf(stderr,
			"Usage: %s device [partition-file]\n", arg0);
		exit(1);
	}
	dev_file= argv[1];
	table_file= argv[argc - 1];
	shrink= (argc == 2);

	if (stat(dev_file, &hdst) < 0) fatal(dev_file);
	if (strcmp(dev_file, devname(hdst.st_rdev)) != 0) {
		fprintf(stderr, "%s: can't do anything with the name of %s\n",
			arg0, dev_file);
		exit(1);
	}

	/* Geometry (to print nice numbers.) */
	if (diocntl(hdst.st_rdev, DGETP, &geometry) < 0) fatal(dev_file);

	if (!S_ISBLK(hdst.st_mode)) {
		fprintf(stderr, "%s: %s is not a device\n", arg0, dev_file);
		exit(1);
	}
	hd_major= major(hdst.st_rdev);
	hd_minor= minor(hdst.st_rdev);

	if (hd_minor >= MINOR_hd1a) {
		errno= EINVAL;
		fatal(dev_file);
	}

	if (hd_major == major(DEV_FD0)) {
		/* HD is actually a floppy. */
		if (hd_minor >= 4) {
			errno= EINVAL;
			fatal(dev_file);
		}
		device= hd_minor + (28 << 2);
		incr= 4;
		needsort= 0;
	} else
	if (hd_minor % (1 + NR_PARTITIONS) == 0) {
		/* Partitioning hd0, hd5, ... */
		device= hd_minor + 1;
		incr= 1;
		needsort= 1;
	} else {
		/* Subpartitioning hd[1-4], hd[6-9], ... */
		drive= hd_minor / (1 + NR_PARTITIONS);
		par= hd_minor % (1 + NR_PARTITIONS) - 1;

		device= MINOR_hd1a
				+ (drive * NR_PARTITIONS + par) * NR_PARTITIONS;
		if (device + NR_PARTITIONS - 1 > BYTE) {
			errno= EINVAL;
			fatal(dev_file);
		}
		incr= 1;
		needsort= 0;
	}
	/* Device is now the first of the minor devices to be repartitioned. */

	/* Read the partition table from the boot block. */
	if ((partf= open(table_file, O_RDONLY)) < 0
		|| lseek(partf, (off_t) PART_TABLE_OFF, SEEK_SET) == -1
		|| (par= read(partf, (char *) table, (int) sizeof(table))) < 0
	) fatal(table_file);

	if (par < sizeof(table)) {
		fprintf(stderr, "%s: %s does not contain a partition table\n",
			arg0, table_file);
		exit(1);
	}
	if (needsort) partsort(table);

	/* Show the geometry of the affected drive or partition. */
	if (diocntl(hdst.st_rdev, DGETP, &whole) < 0) fatal(dev_file);

	/* Use sector numbers. */
	base = div64u(whole.base, SECTOR_SIZE);
	size = div64u(whole.size, SECTOR_SIZE);
	limit = base + size;

	show_part(dev_file, base, size);

	/* Send the partition table entries to the device driver. */
	for (par= 0; par < NR_PARTITIONS; par++, device+= incr) {
		pe = &table[par];
		if (shrink && pe->size != 0) {
			/* Shrink the partition entry to fit within the
			 * enclosing device just like the driver does.
			 */
			unsigned long part_limit= pe->lowsec + pe->size;

			if (part_limit < pe->lowsec) part_limit= limit;
			if (part_limit > limit) part_limit= limit;
			if (pe->lowsec < base) pe->lowsec= base;
			if (part_limit < pe->lowsec) part_limit= pe->lowsec;
			pe->size= part_limit - pe->lowsec;
		}

		entry.base= mul64u(pe->lowsec, SECTOR_SIZE);
		entry.size= mul64u(pe->size, SECTOR_SIZE);
		if (diocntl(makedev(hd_major, device), DSETP, &entry) < 0)
			fatal(dev_file);

		show_part(devname(makedev(hd_major, device)),
							pe->lowsec, pe->size);
	}
	exit(0);
}
