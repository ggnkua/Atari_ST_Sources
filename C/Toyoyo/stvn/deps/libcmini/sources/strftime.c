#include <string.h>
#include <time.h>
#include <mint/osbind.h>
#include <sys/time.h>


#define DAYSPERWEEK  7


static const char *const wday_name[] = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" };
static const char *const mon_name[] = { "January", "February", "March", "April", "May", "June", "July", "August", "Sepember", "October", "November", "December" };


static int get_week(const struct tm *tp, int start_monday)
{
	int week = tp->tm_yday + DAYSPERWEEK;

	if (start_monday)
	{
		if (tp->tm_wday == 0)
		{
			week -= DAYSPERWEEK - 1;
		} else
		{
			week -= tp->tm_wday - 1;
		}
	} else
	{
		week -= tp->tm_wday;
	}

	return week / DAYSPERWEEK;
}


size_t strftime(char *s, size_t smax, const char *fmt, const struct tm *tp)
{
	char *ptr = s;
	size_t count = 0;

	tzset();

	do
	{
		if (*fmt == '%')
		{
			int addlen = -1;
			char addval[80];
			const char *addstr = addval;
			int week;

			addval[0] = '\0';
			switch (*++fmt)
			{
			case 'a':
				addlen = 3; /* abbrevation = first three characters */

				/* FALLTHROUGH */

			case 'A':
				if (tp->tm_wday < 0 || tp->tm_wday > 6)
				{
					addstr = "?";
					addlen = -1;
				} else
				{
					addstr = wday_name[tp->tm_wday];
				}
				break;

			case 'b':
				addlen = 3; /* abbrevation = first three characters */

				/* FALLTHROUGH */

			case 'B':
				if (tp->tm_mon < 0 || tp->tm_mon > 11)
				{
					addstr = "?";
					addlen = -1;
				} else
				{
					addstr = mon_name[tp->tm_mon];
				}
				break;

			case 'c':
				strftime(addval, sizeof(addval), "%a %b %d %x %Y", tp);
				break;

			case 'd':
				addval[0] = '0' + (tp->tm_mday / 10);
				addval[1] = '0' + (tp->tm_mday % 10);
				addval[2] = '\0';
				break;

			case 'H':
				addval[0] = '0' + (tp->tm_hour / 10);
				addval[1] = '0' + (tp->tm_hour % 10);
				addval[2] = '\0';
				break;

			case 'I':
				{
					int hour12 = tp->tm_hour % 12;

					if (hour12 == 0)
					{
						hour12 = 12;
					}

					addval[0] = '0' + (hour12 / 10);
					addval[1] = '0' + (hour12 % 10);
					addval[2] = '\0';
				}
				break;

			case 'j':
				addval[0] = '0' + ((tp->tm_yday + 1) / 100);
				addval[1] = '0' + (((tp->tm_yday + 1) % 100) / 10);
				addval[2] = '0' + ((tp->tm_yday + 1) % 10);
				addval[3] = '\0';
				break;

			case 'm':
				addval[0] = '0' + ((tp->tm_mon + 1) / 10);
				addval[1] = '0' + ((tp->tm_mon + 1) % 10);
				addval[2] = '\0';
				break;

			case 'M':
				addval[0] = '0' + (tp->tm_min / 10);
				addval[1] = '0' + (tp->tm_min % 10);
				addval[2] = '\0';
				break;

			case 'p':
				if (tp->tm_hour > 0 && tp->tm_hour < 13)
				{
					addstr = "AM";
				} else
				{
					addstr = "PM";
				}
				break;

			case 'S':
				addval[0] = '0' + (tp->tm_sec / 10);
				addval[1] = '0' + (tp->tm_sec % 10);
				addval[2] = '\0';
				break;

			case 'U':
			case 'W':
				week = get_week(tp, *fmt == 'U' ? 0 : 1);
				addval[0] = '0' + (week / 10);
				addval[1] = '0' + (week % 10);
				addval[2] = '\0';
				break;

			case 'w':
				addval[0] = '0' + (tp->tm_wday % 10);
				addval[1] = '\0';
				break;

			case 'X':
				strftime(addval, 80, "%H:%M:%S", tp);
				break;

			case 'x':
				strftime(addval, 80, "%d.%m.%Y", tp);
				break;

			case 'y':
				addval[0] = '0' + ((tp->tm_year % 100) / 10);
				addval[1] = '0' + ((tp->tm_year % 100) % 10);
				addval[2] = '\0';
				break;

			case 'Y':
				addval[0] = '0' + ((tp->tm_year + 1900) / 1000);
				addval[1] = '0' + (((tp->tm_year + 1900) % 1000) / 100);
				addval[2] = '0' + (((tp->tm_year + 1900) % 100) / 10);
				addval[3] = '0' + ((tp->tm_year + 1900) % 10);
				addval[4] = '\0';
				break;

			case 'Z':
				addstr = tzname[tp->tm_isdst > 0];
				break;

			case '%':
				addstr = "%";
				break;

			default:
				addval[0] = '%';
				addval[1] = *fmt;
				addval[2] = '\0';
				break;
			}

			if (*addstr != '\0')
			{
				size_t len;

				if (addlen < 0)
				{
					len = strlen(addstr);
				} else
				{
					len = addlen;
				}

				if (count + len > smax)
				{
					len = smax - count;
				}

				strncpy(ptr, addstr, len);

				ptr += len;
				count += len;
			}

			++fmt;
		} else
		{
			if (count <= smax)
			{
				*ptr++ = *fmt;
			}

			++fmt;
		}
	} while (fmt[-1] != '\0');

	if (count > smax)
	{
		count = 0;
	}

	return count;
}
