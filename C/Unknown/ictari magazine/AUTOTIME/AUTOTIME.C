/*
 *   AUTOTIME - program to set the system clock on startup.
 *   It's OK to link this with "mmdummy".
 *   Modified 871213.
 */

#include <osbind.h>

#define WORD	int	/* 16 bits: 'int' in Megamax */

#define OK	0

/* read unsigned bytes and Intel-style integers */
#define US(p,o)	(p[o]&0xFF)
#define UI(p,o)	(US(p,o)+256*US(p,o+1))

#define fixup(s) (s[s[1]+2] = '\0')	/* null-terminate a GEMDOS string */

int
strlen(s)
	char *s;
{
	register int i=0;
	while (s[i++]);
	return (i-1);
}

iprint(i)
	int i;
{
	Bconout(2, (i/10)+'0');
	Bconout(2, (i%10)+'0');
}

int
dotime(s)
	register char *s;
{
	register int  len;
	register int  hour, minute, second;
	register WORD time;

	len = strlen(s);
	if (len < 4 || len == 5 || len > 6) goto badtime;

	hour = (s[0]-'0') * 10 + (s[1]-'0');
	minute = (s[2]-'0') * 10 + (s[3]-'0');
	if (len == 6) second = (s[4]-'0') * 10 + (s[5]-'0');
	else second = 0;

	if (hour < 0 || hour > 23 ||
	    minute < 0 || minute > 59 ||
	    second < 0 || second > 59) goto badtime;

	time = (WORD)((hour << 11) | (minute << 5) | (second >> 1));

	if (Tsettime(time) == 0)
	    return (0);

badtime:
	Cconws("\r\n\tIllegal time (bad format or out of range)\r\n");
	return (1);
}

int
dodate(s)
	register char *s;
{
	register int  len;
	register int  month,day,year;
	register WORD date;

	len = strlen(s);
	if (len != 6) goto baddate;

	year =  (s[0]-'0') * 10 + (s[1]-'0') - 80;
	month = (s[2]-'0') * 10 + (s[3]-'0');
	day =   (s[4]-'0') * 10 + (s[5]-'0');

	if (year < 0 || year > 119 || 
	    month < 1 || month > 12 || 
	    day < 1 || day > 31) goto baddate;

	date = (WORD)((year << 9) | (month << 5) | day);

	if (Tsetdate(date) == 0)
		return (0);

baddate:
	Cconws("\r\n\tIllegal date (bad format or out of range)\r\n");
	return (1);
}

main()
{
	register int i;
	register char *buf;
	int	minute, hour, day, month, year;
	WORD	date, time;
	long	datime;
	char	str[10];

	/* see if IKBD time is valid */
	datime = Gettime();		/* get ikbd date & time */
	date = (WORD) (datime >> 16);
	time = (WORD) (datime & 0xffff);
	minute = ((time >>  5) & 0x3F);
	hour   = ((time >> 11) & 0x1F);
	day    = ((date      ) & 0x1F);
	month  = ((date >>  5) & 0x0F);
	year   = ((date >>  9) & 0x3F);
	if (minute<60 && hour<24 && day<32
	  && day>0 && month<13 && month>0 && year>6) {
		if (Tsetdate(date)==0 && Tsettime(time)==0) {
			Cconws("\r\n\tTime: ");
			iprint(hour);
			iprint(minute);
			Cconws("\r\n\tDate: ");
			iprint(year+80);
			iprint(month);
			iprint(day);
			Cconws("\r\n\n");
			_exit(0);
		}
	}

	/* we want to prompt the user	*/

	str[0] = 7;	/* set up buffer for Cconrs call */
	do {
		Cconws("\r\n\n\tEnter the time (hhmm[ss]): ");
		Cconrs(str);
		fixup(str);
	} while (dotime(str+2));

	str[0] = 7;
	do {
		Cconws("\r\n\tEnter the date (yymmdd): ");
		Cconrs(str);
		fixup(str);
	} while (dodate(str+2));

	/* get GEM's time */
	datime = ((long)Tgetdate()<<16) | (((long)Tgettime())&0x0000FFFF);

	/* update the ikbd's time */
	Settime(datime);
}
