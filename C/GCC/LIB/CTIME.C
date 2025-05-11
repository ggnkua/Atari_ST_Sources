
/* not sure whether this is right... */

char ctime_buf[26];		/* is it safe to use a static one? */

char * month_name[] = {"???", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
		       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
char * day_name[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

char * ctime(date_and_time)
long * date_and_time;
{
  int date = (*date_and_time >> 16) & 0xFFFF;
  int time = *date_and_time & 0xFFFF;
  int year, month, day, hour, min, sec;

  year = ((date >> 9) & 0x7F);
  if ((year < 1) || (year > 19))	/* 1999 ought to be enough... */
	year = 0;
    else
	year += 1980;
  month = (date >> 5) & 0x0F;
  if ((month < 1) || (month > 12))
	month = 0;
  day = date & 0x1F;
  hour = (time >> 11) & 0x1F;
  min = (time >> 5) & 0x3F;
  sec = (time & 0x01F) * 2;
  
  sprintf(ctime_buf, "    %s %02d %02d:%02d:%02d %04d\n",
	month_name[month], day, hour, min, sec, year);

  return((char * )&ctime_buf);
}

