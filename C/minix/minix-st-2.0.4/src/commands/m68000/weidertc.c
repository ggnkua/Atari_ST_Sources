/*



                               rtc

                        Copyright (c) 1988

                           Bert Reuling

              This rtc program may be copied freely.



     This rtc program is for use with the Weide RTC clock module.
     This is a clock module for the ATARI 260, 520 and 1040ST. As
     this  clock  module  is  NOT  compatible  with  the  MEGA ST
     built-in clock, you cannot use the  megartc.c  program  from
     the distribution. The module is produced by:


                        Weide Elektronik
                        Regerstrasse 34
                        D-4010 Hilden
                        Tel. 02103-41226
                        BRD (West Germany)


     Please send bug reports, remarks, etc to:

                       ...!hp4nl!bebux!bert


                 /             /      Bert Reuling
                /-,  ,--, ,-, /-      p/a Radio Holland bv
               /  / /--- /   /        Jan Rebelstraat 20
               `-'  `--  `   `--      1069 CC Amsterdam
                                      The Netherlands

                  MINIX werkgroep UNIXgg/HCC
 */
/*
 *  rtc.c  -  Weijde RTC for minix v1.0. Copyright (c) 1988 Bert Reuling
 */
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>

_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(int isleap, (int year));
_PROTOTYPE(void message, (int phase, char *message_string));

#define RTC_ADDRESS   0x00fffc00L

static int verbose;
static char *name, *Copyright = "\0rtc v1.0 Copyright (c) 1988 Bert Reuling";

int main(argc, argv)
int argc;
char *argv[];
{
   char msg[20];
   int regn, regs[12], fd, i, year, month, day,
       hour, minute, second, wkd, lyr;
   long clock, ticks = 0L;
   static char *nday[7] = {
      "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
   };
   static char *nmonth[13] = {
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
   };
   static int mdays[2][12] = {
      { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
      { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
   };

   if (getuid() != 0) {
      fprintf(stderr, "%s: cannot execute. (must be root)\n", argv[0]);
      exit(-1);
   }

   name = argv[0];
   verbose = (argc != 1);

   message(1, "open /dev/mem");

   if ((fd = open("/dev/mem", O_RDWR, 0)) < 0)
      message(1, "failed");

   message(2, "reading rtc registers");

   for (i = 0x9600; i < 0x960d; i++) {
      if (lseek(fd, RTC_ADDRESS, 0) == -1)
         message(2, "seek failed");
      if (write(fd, (char *)&i, 2) != 2) {
         sprintf(msg, "register set %d failed\n", (i & 0x000f));
         message(2, msg);
      }
      if (lseek(fd, RTC_ADDRESS, 0) == -1)
         message(2, "seek failed");
      if (read(fd, (char *)&regn, 2) != 2) {
         sprintf(msg, "register get %d failed", (i & 0x000f));
         message(2, msg);
      }
      regs[i & 0x0f] = regn & 0x000f;
      sprintf(msg, "register %2d = $%02x", (i & 0x000f), (regn & 0x00ff));
      message(2, msg);
   }

   message(3, "closing /dev/mem");

   if (close(fd) == -1)
      message(3, "failed");

   message(4, "assemble rtc data");

   year = 1900 + regs[12] * 10 + regs[11];
   month = regs[10] * 10 + regs[9] - 1;
   day = regs[8] * 10 + regs[7];
   wkd = regs[6];
   hour = (regs[5] & 0x03) * 10 + regs[4];
   minute = regs[3] * 10 + regs[2];
   second = regs[1] * 10 + regs[0];
   lyr = isleap(year);

   if (year < 1970)
      message(4, "error in year part");
   if ((month < 0) || (month > 11))
      message(4,"error in month part");
   if ((day < 1) || (day > 31))
      message(4, "error in day part");
   if ((wkd < 0) || (wkd > 6))
      message(4, "error in week-day part");
   if ((hour < 0) || (hour > 23))
      message(4,  "error in hour part");
   if ((minute < 0) || (minute > 59))
      message(4, "error in minute part");
   if ((second < 0) || (second > 59))
      message(4, "error in seconds part");

   for (i = 1970; i < year; i++)
      ticks += (long) (isleap(i) ? 366 : 365);
   for (i = 0; i < month; i++)
      ticks += (long) mdays[lyr][i];
   ticks -= 1L;
   ticks += (long) day;
   ticks *= 24L;
   ticks += (long) hour;
   ticks *= 60L;
   ticks += (long) minute;
   ticks *= 60L;
   ticks += (long) second;

   message(5,  "checking time");

   time(&clock);
   if (clock < ticks)
      message(5,  "time is set backwards");

   message(6,  "setting system time");

   if (stime(&ticks) < 0)
      message(6, "failed");

   printf("%s %s %2d %02d:%02d:%02d %d\n", nday[wkd], nmonth[month], day, hour, minute, second, year);

   return(0);
}

/*
 *  isleap  -  return 1 if 'year' is a leap year
 */
int isleap(year)
int year;
{
   return ((((year % 4) == 0) && ((year % 100) != 0)) || ((year % 400) == 0));
}

/*
 *  message  -  print error/diagnostics message
 */
void message(phase, message_string)
int phase;
char *message_string;
{
   if (verbose)
      printf("%s: ** phase %d - %s\n", name, phase, message_string);
}

