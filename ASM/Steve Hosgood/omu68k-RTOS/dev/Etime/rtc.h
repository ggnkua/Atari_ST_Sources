/******************************************************************************
 *	Rtc.h		Timer specs for Eltec kit using M 3000 chip
 ******************************************************************************
 */

char *M3000 = (char *)0xFA0021L;	/* Location of timmer chip */

/* Contents of chip */

struct	timechip{
	char	seconds;
	char	minutes;
	char	hours;
	char	date;
	char	month;
	char	year;
	char	weekday;
	char	weekno;
	char	alarm_s;
	char	alarm_m;
	char	alarm_h;
	char	alarm_d;
	char	timer_s;
	char	timer_m;
	char	timer_h;
	char	status;
};
