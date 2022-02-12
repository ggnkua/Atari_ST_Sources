/*	partition 1.10 - Make a partition table		Author: Kees J. Bot
 *								27 Apr 1992
 */
#define nil 0
#include <stdio.h>
#include <sys/types.h>
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
#include <sys/ioctl.h>
#include <limits.h>

#if !__minix_vmd
#define div64u(i, j)	((i) / (j))
#endif

#define SECTOR_SIZE	512

#define arraysize(a)	(sizeof(a)/sizeof((a)[0]))
#define arraylimit(a)	((a) + arraysize(a))

char *arg0;

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

int aflag;			/* Add a new partition to the current table. */
int mflag;			/* Minix rules, no need for alignment. */
int rflag;			/* Report current partitions. */
int fflag;			/* Force making a table even if too small. */

int cylinders, heads, sectors;	/* Device's geometry */
int pad;			/* Partitions must be padded. */

/* Descriptions of the device to divide and the partitions to make, including
 * gaps between partitions.
 */
struct part_entry primary, table[2 * NR_PARTITIONS + 1];
int npart;

/* Extra flag at construction time. */
#define EXPAND_FLAG	0x01	/* Add the remaining sectors to this one */

#define MINOR_hd1a	128

void sec2dos(unsigned long sec, unsigned char *dos)
/* Translate a sector number into the three bytes DOS uses. */
{
	unsigned secspcyl= heads * sectors;
	unsigned cyl;

	cyl= sec / secspcyl;
	dos[2]= cyl;
	dos[1]= ((sec % sectors) + 1) | ((cyl >> 2) & 0xC0);
	dos[0]= (sec % secspcyl) / sectors;
}

void show_chs(unsigned long pos)
{
	int cyl, head, sec;

	if (pos == -1) {
		cyl= head= 0;
		sec= -1;
	} else {
		cyl= pos / (heads * sectors);
		head= (pos / sectors) - (cyl * heads);
		sec= pos % sectors;
	}
	printf("  %4d/%02d/%02d", cyl, head, sec);
}

void show_part(struct part_entry *p)
{
	static int banner= 0;
	int n;

	n= p - table;
	if ((n % 2) == 0) return;

	if (!banner) {
		printf(
		"Part     First        Last        Base      Size       Kb\n");
		banner= 1;
	}

	printf("%3d ", (n-1) / 2);
	show_chs(p->lowsec);
	show_chs(p->lowsec + p->size - 1);
	printf("  %8lu  %8lu  %7lu\n", p->lowsec, p->size, p->size / 2);
}

void usage(void)
{
	fprintf(stderr,
		"Usage: partition [-mf] device [type:]length[+*] ...\n");
	exit(1);
}

#define between(a, c, z)	((unsigned) ((c) - (a)) <= ((z) - (a)))

void parse(char *descr)
{
	int seen= 0, sysind, flags, c;
	unsigned long size;

	if (strchr(descr, ':') == nil) {
		/* A hole. */
		if ((npart % 2) != 0) {
			fprintf(stderr, "%s: Two holes can't be adjacent.\n",
				arg0);
			exit(1);
		}
		sysind= NO_PART;
		seen|= 1;
	} else {
		/* A partition. */
		if ((npart % 2) == 0) {
			/* Need a hole before this partition. */
			if (npart == 0) {
				/* First hole contains the partition table. */
				table[0].size= 1;
			}
			npart++;
		}
		sysind= 0;
		for (;;) {
			c= *descr++;
			if (between('0', c, '9'))
				c= (c - '0') + 0x0;
			else
			if (between('a', c, 'z'))
				c= (c - 'a') + 0xa;
			else
			if (between('A', c, 'Z'))
				c= (c - 'A') + 0xA;
			else
				break;
			sysind= 0x10 * sysind + c;
			seen|= 1;
		}
		if (c != ':') usage();
	}

	size= 0;
	while (between('0', (c= *descr++), '9')) {
		size= 10 * size + (c - '0');
		seen|= 2;
	}

	flags= 0;
	for (;;) {
		if (c == '*')
			flags|= ACTIVE_FLAG;
		else
		if (c == '+')
			flags|= EXPAND_FLAG;
		else
			break;
		c= *descr++;
	}
	if (seen != 3 || c != 0) usage();

	if (npart == arraysize(table)) {
		fprintf(stderr, "%s: too many partitions, only %d possible.\n",
			arg0, NR_PARTITIONS);
		exit(1);
	}
	table[npart].bootind= flags;
	table[npart].sysind= sysind;
	table[npart].size= size;
	npart++;
}

void geometry(char *device)
/* Get the geometry of the drive the device lives on, and the base and size
 * of the device.
 */
{
	int fd;
	struct partition geometry;

	if ((fd= open(device, O_RDONLY)) < 0) fatal(device);

	/* Get the geometry of the drive, and the device's base and size. */
	if (ioctl(fd, DIOCGETP, &geometry) < 0) fatal(device);
	close(fd);
	primary.lowsec= div64u(geometry.base, SECTOR_SIZE);
	primary.size= div64u(geometry.size, SECTOR_SIZE);
	cylinders= geometry.cylinders;
	heads= geometry.heads;
	sectors= geometry.sectors;

	/* Is this a primary partition table?  If so then pad partitions. */
	pad= (!mflag && primary.lowsec == 0);
}

void boundary(struct part_entry *pe, int exp)
/* Expand or reduce a primary partition to a track or cylinder boundary to
 * avoid giving the fdisk's of simpler operating systems a fit.
 */
{
	unsigned n;

	n= !pad ? 1 : pe == &table[0] ? sectors : heads * sectors;
	if (exp) pe->size+= n - 1;
	pe->size= ((pe->lowsec + pe->size) / n * n) - pe->lowsec;
}

void distribute(char *device)
/* Fit the partitions onto the device.  Try to start and end them on a
 * cylinder boundary if so required.  The first partition is to start on
 * track 1, not on cylinder 1.
 */
{
	struct part_entry *pe, *exp;
	long count;
	unsigned long base, size;

	do {
		exp= nil;
		base= primary.lowsec;
		count= primary.size;

		for (pe= table; pe < arraylimit(table); pe++) {
			pe->lowsec= base;
			boundary(pe, 1);
			base+= pe->size;
			count-= pe->size;
			if (pe->bootind & EXPAND_FLAG) exp= pe;
		}
		if (count < 0) {
			if (fflag) break;
			fprintf(stderr, "%s: %s is %ld sectors too small\n",
				arg0, device, -count);
			exit(1);
		}
		if (exp != nil) {
			/* Add leftover space to the partition marked for
			 * expanding.
			 */
			exp->size+= count;
			boundary(exp, 0);
			exp->bootind&= ~EXPAND_FLAG;
		}
	} while (exp != nil);

	for (pe= table; pe < arraylimit(table); pe++) {
		if (pe->sysind == NO_PART) {
			memset(pe, 0, sizeof(*pe));
		} else {
			sec2dos(pe->lowsec, &pe->start_head);
			sec2dos(pe->lowsec + pe->size - 1, &pe->last_head);
			pe->bootind&= ACTIVE_FLAG;
		}
		show_part(pe);
	}
}

void write_table(char *device)
{
	int f;
	short signature= 0xAA55;
	struct part_entry newtable[NR_PARTITIONS];
	int i;

	for (i= 0; i < NR_PARTITIONS; i++) newtable[i]= table[1 + 2*i];

	if ((f= open(device, O_WRONLY)) < 0

		|| lseek(f, (off_t) PART_TABLE_OFF, SEEK_SET) == -1

		|| write(f, newtable, sizeof(newtable)) < 0

		|| write(f, &signature, sizeof(signature)) < 0

		|| close(f) < 0
	) fatal(device);
}

int main(int argc, char **argv)
{
	int i;
	char *device;

	if ((arg0= strrchr(argv[0], '/')) == nil) arg0= argv[0]; else arg0++;

	i= 1;
	while (i < argc && argv[i][0] == '-') {
		char *opt= argv[i++] + 1;

		if (opt[0] == '-' && opt[1] == 0) break;

		while (*opt != 0) switch (*opt++) {
		case 'a':	aflag= 1;	break;
		case 'm':	mflag= 1;	break;
		case 'r':	rflag= 1;	break;
		case 'f':	fflag= 1;	break;
		default:	usage();
		}
	}

	if (rflag) {
		if (aflag) usage();
		if ((argc - i) != 1) usage();
		fprintf(stderr, "%s: -r is not yet implemented\n");
		exit(1);
	} else {
		if ((argc - i) < 1) usage();
		if (aflag) fprintf(stderr, "%s: -a is not yet implemented\n");

		device= argv[i++];
		geometry(device);

		while (i < argc) parse(argv[i++]);

		distribute(device);
		write_table(device);
	}
	exit(0);
}
