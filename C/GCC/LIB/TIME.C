
/* julian date */

#include <osbind.h>

/* days in months = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}; */

short month_days[] = {	0,
			31, 
			31 + 28,
			31 + 28 + 31,
			31 + 28 + 31 + 30,
			31 + 28 + 31 + 30 + 31,
			31 + 28 + 31 + 30 + 31 + 30,
			31 + 28 + 31 + 30 + 31 + 30 + 31,
			31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
			31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
			31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
			31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30
			};
/* note that the value returned from this is NOT suitable for calling 
   ctime on */

long time(place)
long * place;
{
  int today = Tgetdate();
  int now = Tgettime();
  int year, month, day, hour, min, sec;
  long result;

  year = ((today >> 9) & 0x7F);
  month = (today >> 5) & 0x0F;
  if ((month < 1) || (month > 12))
	month = 1;
  day = today & 0x1F;
  hour = (now >> 11) & 0x1F;
  min = (now >> 5) & 0x3F;
  sec = (now & 0x01F) * 2;

  result = 	sec + 
		(min * 60) + 
		(hour * 3600) + 
		((day + month_days[month]) * 86400) +
		year * 31536000;
/* ignores leap years for now */
  if (place)
	*place = result;
  return(result);
}
