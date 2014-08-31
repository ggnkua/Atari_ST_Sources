
/*********************************************************************/
/*                                                                   */
/*     STinG : Modem Dialer, Logging module                          */
/*                                                                   */
/*                                                                   */
/*      Version 1.1                        from 16. Januar 1997      */
/*                                                                   */
/*      Module for logging connection times                          */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>


#define  MIN(a,b)     (((a) < (b)) ? (a) : (b))
#define  CEIL(a,b)    ((a) / (b) + (((a) % (b)) ? 1 : 0))


typedef  struct tm  UNI_TIME;


void  read_counter (long *read, long *write);

void  write_time_log (char mask[]);
void  write_extra_line (void);
void  write_log_text (char text[]);
int   find_next_cr (char **walk);
void  convert_time (char string[], UNI_TIME *uni_ptr);
long  diff_time (void);
int   read_fee (char *buffer);
long  calc_charge (long dur_total);
int   find_tariff (UNI_TIME *now, long *more_time);
void  calc_festivals (UNI_TIME *now);
void  add_duration (UNI_TIME *now, long duration);
void  add_days (UNI_TIME *now, int number);
long  calc_factor (UNI_TIME *now);
int   read_offset (int index, int *offset, int lower, int upper);
long  test_interval (UNI_TIME *now, int index);
int   get_time_info (char **walk, UNI_TIME *this_time, int end_flag);
int   is_later (UNI_TIME *now, UNI_TIME *reference);


extern char  config_path[], script_path[], fee_file[];
extern long  ISP_u_time, ISP_u_sent, ISP_u_recvd;
extern long  ISP_c_time, ISP_c_sent, ISP_c_recvd;

UNI_TIME  begin, end, easter, advent;
int       duration[17], digits, tariff_next;
long      fee_unit;
int       max_days[]   = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
char      month[][4]   = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
                           "Sep", "Oct", "Nov", "Dec"  };
char      weekday[][4] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"  };
char      unit[10], tariff_name[17], log_buffer[256], *tariff_time[200];



void  write_time_log (mask)

char  mask[];

{
   time_t  now;
   char    line[128], *work;

   time (&now);
   strcpy (line, ctime (&now));
   line[32] = '\0';
   if ((work = strchr (line, '\n')) != NULL)
        *work = '\0';

   strcat (line, " : ");   strcat (line, mask);
   write_log_text (line);
 }


void  write_extra_line()

{
   UNI_TIME  temp;
   long      duration, charge, calc, received, sent;
   char      *walk, *buffer;
   char      extra_line[128], part[64], dec[10];

   for (walk = log_buffer; *walk != '\0'; walk++);

   if (find_next_cr (&walk))   return;
   if (walk < log_buffer)      return;
   convert_time (walk, &end);

   if (find_next_cr (&walk))   return;
   if (walk < log_buffer)      return;
   convert_time (walk, &begin);

   if ((calc = duration = diff_time()) < 0L)
        return;

   temp.tm_hour = (int) (calc / 3600);   calc %= 3600;
   temp.tm_min  = (int) (calc / 60);     calc %= 60;
   temp.tm_sec  = (int) (calc);

   part[0] = '\0';
   if (temp.tm_hour > 0) {
        sprintf (dec, " %d h", temp.tm_hour);
        strcat (part, dec);
      }
   if (temp.tm_min > 0) {
        sprintf (dec, " %d min", temp.tm_min);
        strcat (part, dec);
      }
   if (temp.tm_sec > 0) {
        sprintf (dec, " %d sec", temp.tm_sec);
        strcat (part, dec);
      }
   sprintf (extra_line, "  Total time%s, ", part);

   if ((buffer = (char *) Malloc (10250L)) != NULL) {
        if (read_fee (buffer) == 0) {
             charge = calc_charge (duration) * fee_unit;
             if (charge > 0) {
                  sprintf (dec, "%-ld", charge % 1000);
                  dec[digits] = '\0';
                  sprintf (part, "charge is %s %ld.%s", unit, charge / 1000, dec);
                  strcat (extra_line, part);
                  if (tariff_name[0]) {
                       sprintf (part, " (%s)", tariff_name);
                       strcat (extra_line, part);
                     }
                  strcat (extra_line, ".");
                }
               else
                  strcat (extra_line, "problem evaluating fee file !");
           }
          else
             strcat (extra_line, "problem reading fee file !");
        Mfree (buffer);
      }

   write_log_text (extra_line);

   read_counter (&received, &sent);
   sprintf (extra_line, "  IP traffic %ld Kb sent, %ld Kb received",
                 CEIL (sent, 1024), CEIL (received, 1024));
   charge = CEIL (duration, ISP_u_time) * ISP_c_time +
         CEIL (sent, ISP_u_sent) * ISP_c_sent + CEIL (received, ISP_u_recvd) * ISP_c_recvd;
   if (charge > 0) {
        sprintf (dec, "%-ld", charge % 1000);
        dec[digits] = '\0';
        sprintf (part, ", ISP charge is %s %ld.%s", unit, charge / 1000, dec);
        strcat (extra_line, part);
      }
   strcat (extra_line, ".");

   write_log_text (extra_line);
 }


void  write_log_text (text)

char  text[];

{
   int   handle, count;
   long  error, length;
   char  log_path[256];

   strcpy (log_path, config_path);
   if (strrchr (log_path, '\\'))
        strcpy (strrchr (log_path, '\\') + 1, "DIAL.LOG");
     else
        strcat (log_path, "DIAL.LOG");

   if ((error = Fopen (log_path, FO_RW)) < 0)
        if ((error = Fcreate (log_path, 0)) < 0)   return;

   handle = (int) error;

   Fseek (0, handle, 2);
   Fwrite (handle, strlen (text), text);
   Fwrite (handle, 2L, "\r\n");

   for (length = count = -250; length < 0 && count < 0; count++)
        length = Fseek (count, handle, 2);

   length = Fread (handle, 255, log_buffer);
   Fclose (handle);

   if (length >= 0)
        log_buffer[length] = '\0';
 }


int  find_next_cr (walk)

char  **walk;

{
   int  count;

   for (count = 200; count > 0; --count)
        if (strncmp (--*walk, " : Modem ", 9) == 0)
             break;

   *walk -= 24;

   return (count <= 0);
 }


void  convert_time (string, this_time)

char      string[];
UNI_TIME  *this_time;

{
   int  count;

   this_time->tm_year = atoi (&string[20]);

   for (count = 0; count < 12; count++)
        if (strncmp (month[count], &string[4], 3) == 0)
             this_time->tm_mon = count;

   this_time->tm_mday = atoi (&string[8]);

   for (count = 0; count < 7; count++)
        if (strncmp (weekday[count], &string[0], 3) == 0)
             this_time->tm_wday = count;

   this_time->tm_hour = atoi (&string[11]);
   this_time->tm_min  = atoi (&string[14]);
   this_time->tm_sec  = atoi (&string[17]);
 }


long  diff_time ()

{
   long  diff;

   diff = (calc_factor (&end) - calc_factor (&begin)) * 86400L;

   diff += (end.tm_hour - begin.tm_hour) * 3600L;
   diff += (end.tm_min  - begin.tm_min)  * 60;
   diff +=  end.tm_sec  - begin.tm_sec;

   return (diff);
 }


int  read_fee (buffer)

char  *buffer;

{
   int   handle, count, tariff = 0;
   long  error, len;
   char  *walk, *line, *look;

   strcpy (buffer, script_path);
   if (strrchr (buffer, '\\'))
        strcpy (strrchr (buffer, '\\') + 1, fee_file);
     else
        return (-1);

   if ((error = Fopen (buffer, FO_READ)) < 0)
        return (-1);
   handle = (int) error;

   len = Fread (handle, 10245L, buffer);
   Fclose (handle);

   if (len <= 0 || 10240L < len)
        return (-1);
   buffer[len] = '\0';

   tariff_next = 0;
   walk = buffer;
   unit[0] = tariff_name[0] = '\0';

   do {
        line = walk;

        for (count = 0; count < 130; count++, walk++)
             if (*walk == '\0' || *walk == '\r' || *walk == '\n')
                  break;

        if (*walk == '\r' || *walk == '\n') {
             *walk++ = '\0';
             while (*walk == '\r' || *walk == '\n')
                  walk++;
           }

        switch (line[0]) {
           case '+' :
             switch (line[1]) {
                case 'e' :
                  digits = 0;
                  if (strchr (&line[2], '.')) {
                       for (digits = 0, look = strchr (&line[2], '.') + 1; ; digits++, look++)
                            if (*look < '0' || '9' < *look)   break;
                       for (look = strchr (&line[2], '.'); *look != '\0'; look++)
                            *look = *(look + 1);
                     }
                  fee_unit = atol (&line[2]) * ((digits == 0) ? 1000 :
                                 ((digits == 1) ? 100 : ((digits == 2) ? 10 : 1) ) );
                  break;
                case 'u' :
                  for (look = &line[2]; *look == ' '; look++);
                  strncpy (unit, look, 10);
                  break;
                default :
                  if (atoi (&line[1]) != ++tariff)
                       return (-1);
                  break;
                }
             break;
           case '#' :
             if (tariff == 0)   return (-1);

             for (count = 1, look = line; count <= MIN (tariff, 16) ; count++) {
                  for (; *look && *look != ' '; look++);
                  for (; *look == ' '; look++);
                  if (*look == '\0')   return (-1);

                  duration[count] = atoi (look);
                  for (; '0' <= *look && *look <= '9'; look++);
                  switch (*look) {
                     case 's' :   break;
                     case 'm' :   duration[count] *= 60;    break;
                     case 'h' :   duration[count] *= 3600;  break;
                     default :    return (-1);
                     }
                }
             for (; *look && *look != ' '; look++);
             for (; *look == ' '; look++);
             strncpy (tariff_name, look, 16);
             tariff_name[16] = '\0';
             break;
           default :
             if (tariff == 0 || tariff_next == 200)
                  return (-1);
             *(tariff_time[tariff_next++] = line - 1) = (char) tariff;
           }
     } while (*walk != '\0');

   return (0);
 }


long  calc_charge (dur_total)

long  dur_total;

{
   int   tariff;
   long  charge = 0L, more_time;

   do {
        if ((tariff = find_tariff (&begin, &more_time)) == -1)
             return (-1);

        if (more_time > dur_total)
             charge += CEIL (dur_total, duration[tariff]);
          else {
             more_time = CEIL (more_time, duration[tariff]) * duration[tariff];
             add_duration (&begin, more_time);
             charge += more_time / duration[tariff];
           }
     } while ((dur_total = dur_total - more_time) > 0);

   return (charge);
 }


int  find_tariff (now, more_time)

UNI_TIME  *now;
long      *more_time;

{
   UNI_TIME  temp;
   int       count, offset, tariff, prio = -1;
   char      *walk;

   calc_festivals (now);

   for (count = 0; count < tariff_next; count++) {
        temp = advent;
        switch (tariff_time[count][1]) {
           case 'a' :
             if (prio < 0) {
                  if ((*more_time = test_interval (now, count)) > 0) {
                       prio = 0;
                       tariff = tariff_time[count][0];
                     }
                }
             break;
           case 'w' :
             if (prio < 1) {
                  if (read_offset (count, &offset, 0, 6) == 0)
                       break;
                  if (offset == now->tm_wday)
                       if ((*more_time = test_interval (now, count)) > 0) {
                            prio = 1;
                            tariff = tariff_time[count][0];
                          }
                }
             break;
           case 'm' :
             if (prio < 1) {
                  if (read_offset (count, &offset, 0, max_days[now->tm_mon] - 1) == 0)
                       break;
                  if (offset == now->tm_mday - 1)
                       if ((*more_time = test_interval (now, count)) > 0) {
                            prio = 1;
                            tariff = tariff_time[count][0];
                          }
                }
             break;
           case 'E' :
             temp = easter;
           case 'A' :
             if (prio < 2) {
                  if (read_offset (count, &offset, -365, 365) == 0)
                       break;
                  add_days (&temp, offset);
                  if (temp.tm_year == now->tm_year && temp.tm_mon == now->tm_mon &&
                                 temp.tm_mday == now->tm_mday)
                       if ((*more_time = test_interval (now, count)) > 0) {
                            prio = 2;
                            tariff = tariff_time[count][0];
                          }
                }
             break;
           default :
             walk = &tariff_time[count][1];
             if ('0' <= *walk && *walk <= '9') {
                  if (prio < 3) {
                       temp.tm_mday = atoi (walk);
                       if ((walk = strchr (walk, '.')) == NULL)
                            break;
                       temp.tm_mon = atoi (walk + 1) - 1;
                       if ((walk = strchr (walk + 1, '.')) == NULL)
                            break;
                       if (temp.tm_mon == now->tm_mon && temp.tm_mday == now->tm_mday)
                            if ((*more_time = test_interval (now, count)) > 0) {
                                 prio = 3;
                                 tariff = tariff_time[count][0];
                               }
                     }
                }
               else
                  return (-1);
             break;
           }
      }

   if (prio == -1)   return (-1);

   return (tariff);
 }


void  calc_festivals (now)

UNI_TIME  *now;

{
   long  temp;

   easter.tm_year = advent.tm_year = now->tm_year;

   temp =  ((easter.tm_year % 19) * 19 + 24) % 30;
   temp += ((easter.tm_year % 4) * 2 +
            (easter.tm_year % 7) * 4 + temp * 6 + 5) % 7 + 21;
   easter.tm_mday = 1;   easter.tm_mon = 2;
   add_days (&easter, (int) temp);

   advent.tm_mday = 24;   advent.tm_mon = 11;
   calc_factor (&advent);
   add_days (&advent, -21 - advent.tm_wday);
 }


void  add_duration (now, duration)

UNI_TIME  *now;
long      duration;

{
   long  temp;

   temp = now->tm_sec  + duration;    now->tm_sec  = (int) (temp % 60);
   temp = now->tm_min  + temp / 60;   now->tm_min  = (int) (temp % 60);
   temp = now->tm_hour + temp / 60;   now->tm_hour = (int) (temp % 24);

   add_days (now, (int) (temp / 24));
 }


void add_days (now, number)

UNI_TIME  *now;
int       number;

{
   int  temp;

   temp = now->tm_mday + number;
   max_days[1] = ((int) (now->tm_year / 4) * 4 == now->tm_year) ? 29 : 28;

   while (temp > max_days[now->tm_mon]) {
        temp = temp - max_days[now->tm_mon];
        if (++now->tm_mon == 12) {
             now->tm_mon = 0;   now->tm_year++;
             max_days[1] = ((int) (now->tm_year / 4) * 4 == now->tm_year) ? 29 : 28;
           }
      }

   while (temp <= 0) {
        if (--now->tm_mon == -1) {
             now->tm_mon = 11;   now->tm_year--;
             max_days[1] = ((int) (now->tm_year / 4) * 4 == now->tm_year) ? 29 : 28;
           }
        temp = temp + max_days[now->tm_mon];
      }

   now->tm_mday = (int) temp;
   calc_factor (now);
 }


long  calc_factor (now)

UNI_TIME  *now;

{
   long  factor;

   factor = 365L * now->tm_year + now->tm_mday + 31 * now->tm_mon - 1;

   if (now->tm_mon <= 1) {
        factor +=  (now->tm_year - 1) / 4;
        factor -= ((now->tm_year - 1) / 100 + 1) * 3 / 4;
      }
     else {
        factor +=   now->tm_year / 4;
        factor -= ((now->tm_mon + 1) * 4 + 23) / 10;
        factor -=  (now->tm_year / 100 + 1) * 3 / 4;
      }

   now->tm_wday = (int) (factor % 7);

   return (factor);
 }


int  read_offset (index, offset, lower, upper)

int  index, *offset, lower, upper;

{
   int   neg = 0;
   char  *walk, *test;

   *offset = 0;

   if (*(walk = &tariff_time[index][2]) == ' ')
        return (1);
   if (*walk != '(')   return (0);

   if ((test = strchr (walk, ')')) == NULL)
        return (0);
   if (strchr (walk, ' ') != test + 1)
        return (0);

   if (*++walk == '-') {
        ++walk;
        neg = 1;
      }
   *offset = atoi (walk) * ((neg) ? -1 : 1);

   for (; *walk; walk++)
        if (*walk < '0' || '9' < *walk)
             break;
   if (*walk != ')')   return (0);

   if (*offset < lower || upper < *offset)
        return (0);

   return (1);
 }


long  test_interval (now, index)

UNI_TIME  *now;
int       index;

{
   UNI_TIME  lower, upper, temp, *reference;
   long      more_time;
   char      *walk;

   walk = &tariff_time[index][1];

   while (*walk != ' ')   walk++;

   if (get_time_info (&walk, &lower, 0) == 0)
        return (-1L);

   if (get_time_info (&walk, &upper, 1) == 0)
        return (-1L);

   if (is_later (&lower, &upper)) {
        if (is_later (&lower, now) && ! is_later (&upper, now))
             return (0L);
        if (! is_later (&lower, now)) {
             reference = &temp;
             temp.tm_hour = 24;   temp.tm_min = 0;
           }
          else
             reference = &upper;
      }
     else {
        if (is_later (&lower, now) || ! is_later (&upper, now))
             return (0L);
        reference = &upper;
      }

   more_time = (reference->tm_hour - now->tm_hour) * 3600L +
               (reference->tm_min  - now->tm_min)  * 60L - now->tm_sec;

   return (more_time);
 }


int  get_time_info (walk, this_time, end_flag)

char      **walk;
UNI_TIME  *this_time;
int       end_flag;

{
   while (**walk == ' ')   (*walk)++;

   this_time->tm_hour = atoi (*walk);
   while ('0' <= **walk && **walk <= '9')
        (*walk)++;
   if (*(*walk)++ != ':')   return (0);

   this_time->tm_min = atoi (*walk);
   while ('0' <= **walk && **walk <= '9')
        (*walk)++;
   if (*(*walk)++ == ' ')   return (1);

   if (end_flag && *(--(*walk)) == '\0')
        return (1);

   return (0);
 }


int  is_later (now, reference)

UNI_TIME  *now, *reference;

{
   if (now->tm_hour == reference->tm_hour)
        return (now->tm_min > reference->tm_min);
     else
        return (now->tm_hour > reference->tm_hour);
 }
