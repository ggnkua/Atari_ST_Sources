/* diskset - r set the date	in bms	Author: Howard Johnson
 * taken from minix date, Author: Adri Koppes
 */

#include <sys/types.h>
#include <minix/config.h>
#include <fcntl.h>
#include <sgtty.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void cv_time, (long t));
_PROTOTYPE(void fatal, (char *s1, char *s2));

#define	SECL	0
#define	SECH	1
#define	MINL	2
#define	MINH	3
#define	HOURL	4
#define	HOURH	5

#define DAYW	6

#define	DAYL	7
#define	DAYH	8
#define	MONL	9
#define	MONH	10
#define	YEARL	11
#define	YEARH	12

#define	N	13

int	fd;
unsigned char	a[N];

int days_per_month[] =
  { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

struct {
	int year, month, day, hour, min, sec;
} tm;

long s_p_min;
long s_p_hour;
long s_p_day;
long s_p_year;
int leap = 0;

int main(argc, argv)
int argc;
char **argv;
{
  long t;
  int x;
  int n,i;

	if(argc == 1) {
usage:
		fatal("Usage: %s [bms1|bms2]\n", argv[0]);
		exit(1);
	}
	if(strcmp(argv[1],"bms1") == 0)
		x = DC_WBMS100;
	else if(strcmp(argv[1],"bms2") == 0)
		x =  DC_WBMS200;
	else
		goto usage;

  s_p_min = 60;
  s_p_hour = 60 * s_p_min;
  s_p_day = 24 * s_p_hour;
  s_p_year = 365 * s_p_day;

	time(&t);
	cv_time(t);
/* expected fmt
Thu Nov 10 13:59:34 EST 1988
.month 0-11
.day 1-31
.hour 0-23
.minute 0-59
.second 0-59
.year 1970 - 
*/
	tm.year -= 1980;
	tm.month += 1;

	
	a[SECL] = (tm.sec % 10) & 0xf;
	a[SECH] = (tm.sec / 10) & 0xf;
	a[SECL] = 0;
	a[SECH] = 0;
	a[MINL] = (tm.min % 10) & 0xf;
	a[MINH] = (tm.min / 10) & 0xf;
	a[HOURL] = (tm.hour % 10) & 0xf;
	a[HOURH] = ((tm.hour / 10) & 0xf) | 0x8; /* 24 hr format */

	a[DAYL] = (tm.day % 10) & 0xf;
	a[DAYH] = ((tm.day / 10) & 0xf) | (leap?4:0);
	a[MONL] = (tm.month % 10) & 0xf;
	a[MONH] = (tm.month / 10) & 0xf;
	a[YEARL] = (tm.year % 10) & 0xf;
	a[YEARH] = (tm.year / 10) & 0xf;
  	
	a[DAYW] = 0;
	
	fd = open("/dev/rhd0", 1);
	if (fd < 0)
		fatal("cannot open /dev/rhd0  ", "");
	for(n=0;n<3;n++) {
		i = ioctl(fd,x,(struct sgttyb *)a);
		if(i == 0)
			exit(0);
	}
	perror("write");

	return(1);
}

void cv_time(t)
long t;
{
  tm.year = 0;
  tm.month = 0;
  tm.day = 1;
  tm.hour = 0;
  tm.min = 0;
  tm.sec = 0;
  while (t >= s_p_year) {
	if (((tm.year + 2) % 4) == 0)
		t -= s_p_day;
	tm.year += 1;
	t -= s_p_year;
  }
  if (((tm.year + 2) % 4) == 0) {
	days_per_month[1]++;
	leap = 1;
  }
  tm.year += 1970;
  while ( t >= (days_per_month[tm.month] * s_p_day))
	t -= days_per_month[tm.month++] * s_p_day;
  while (t >= s_p_day) {
	t -= s_p_day;
	tm.day++;
  }
  while (t >= s_p_hour) {
	t -= s_p_hour;
	tm.hour++;
  }
  while (t >= s_p_min) {
	t -= s_p_min;
	tm.min++;
  }
  tm.sec = (int) t;
}

void fatal(s1, s2)
char *s1;
char *s2;
{
	printf("diskset: ");
	printf(s1, s2);
	printf(" (fatal)\n");
	exit(1);
}
