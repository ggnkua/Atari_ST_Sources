/*
 * showparts - list partitions on an asci-device.
 */
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <minix/config.h>
#include "../../kernel/sthdc.h"

#define	TOT_SZ_OFFSET	0x1c2L
#define	PI_OFFSET	0x1c6L

#define	PRIMARY	1
#define	EXTENDED 2

char *devname = "/dev/hdxx";
long total_sectors;
int decimal, hex;

struct pi baseparts[4];
struct ext_pi {
	struct ext_pi	*next;
	struct pi	pi;
} *extended_parts;

void error(char *s)
{
  char *msg = strerror(errno);
  write(2, s, strlen(s));
  write(2, ". ", 2);
  write(2, msg, strlen(msg)); 
  write(2, "\n", 1);
  exit(1);
}

void error2(char *s1, char *s2)
{
  write(2, s2, strlen(s2));
  error(s1);
}

void print_pi(int n, int type, struct pi *p)
{
  printf("%2d %c ", n, type == PRIMARY ? 'p' : 'e');
  printf("%2x %c%c%c ",
	p->pi_flag & 0xff, p->pi_id[0], p->pi_id[1], p->pi_id[2]);
  if (decimal) {
	printf("%8ld", p->pi_start);
	if (hex) printf("/");
  }
  if (hex) printf("%6lx", p->pi_start);
  printf("  ");
  if (decimal) {
	printf("%8ld", p->pi_size);
	if (hex) printf("/");
  }
  if (hex) printf("%6lx", p->pi_size);
  printf("\n");
}

void read_extended(int *np, struct pi *p)
{
  long base, pos;
  struct pi pi2[2];
  struct ext_pi *p1, *p2;
  int fd;

  if ((extended_parts = malloc(sizeof(struct ext_pi))) == NULL)
	error("out of memory");
  extended_parts->pi = *p;
  pos = base = extended_parts->pi.pi_start;

  devname[8] = 'a';
  if ((fd = open(devname, O_RDONLY)) < 0)
	error2(" could not be opened", devname);

  p1 = extended_parts;

  do {
	if ((long) lseek(fd, (pos - 1) * 512 + PI_OFFSET, SEEK_SET) < 0)
		error("lseek error");
	if (read(fd, pi2, 2*sizeof(struct pi)) < 0) error("read error");
	if ((p2 = malloc(sizeof(struct ext_pi))) == NULL)
		error("out of memory");
	p2->pi = pi2[0];
	p2->pi.pi_start += pos;
	p1->next = p2;
	p1 = p2;
	(*np)++;
	print_pi(*np, EXTENDED, &p1->pi);
	pos = base + pi2[1].pi_start;
  } while(pos != base && !strncmp(&pi2[1].pi_id[0], "XGM", 3));
	/* in other words: pi2[1].pi_start != 0 and XGM partition following */
  close(fd);
}

int main(int argc, char *argv[])
{
  int dev, fd, i, iext;
  struct pi *p;
  char *s;

  if (argc == 1)
	error("device number missing");
  dev = -1;
  for (i = 1; i < argc; i++) {
	if (*argv[i] == '-') {
		s = &argv[i][1];
		while (*s) {
			switch (*s) {
			  case 'd': decimal = 1; break;
			  case 'x': hex = 1; break;
			default:
				error2(s, "unknown command: ");
			}
			s++;
		}
	} else
		dev = atol(argv[i]);
  }

  if (dev < 0 || dev > 6)
	error2(argv[1], "device has to be between 0 and 6: ");

  /* default is dezimale Ausgabe */
  if (decimal|hex == 0) decimal = 1;

  devname[7] = '0' + dev;
  devname[8] = 'n';

  if ((fd = open(devname, O_RDONLY)) < 0)
	error2(" can not be opened", devname);

  if ((long) lseek(fd, TOT_SZ_OFFSET, SEEK_SET) < 0) error("lseek error");
  if (read(fd, &total_sectors, 4) < 0) error("read error");
  printf("Total number of sectors: %ld\n", total_sectors);
  if ((long) lseek(fd, PI_OFFSET, SEEK_SET) < 0) error("lseek error");
  if (read(fd, baseparts, 4*sizeof(struct pi)) < 0) error("read error");
  close(fd);

  for (i = 0, p=&baseparts[0]; i < 4; i++, p++) {
	print_pi(i, PRIMARY, p);
	if (!strncmp(&p->pi_id[0], "XGM", 3)) {
		iext = i;
		read_extended(&iext, p);
	}
  }
  return(0);
}
