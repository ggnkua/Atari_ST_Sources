/* 15.11.86  Max B”hm */

#include <osbind.h>

read_str (str, len)      /* str[] muss len+1 Elemente haben */
char str[];
int len;
{
long c;
int scan,ascii,i;
   i=0;
   do
   {  c=Crawcin ();
      ascii=c;
      scan=c>>16;
      if ((scan==14||scan==75)&&i)      /* Backspace */
      {  Cconws ("\10 \10");
         i--;
      }
      if (i<len&&ascii>=32&&ascii!=127&&(scan<58||scan==74||scan==78||scan>98))
      {  Cconout (ascii);
         str[i++]=ascii;
      }
   }
   while (scan!=28&&scan!=114);      /* nicht Return */
   Cconws ("\r\n");
   str[i]=0;
   return (i);
}

get_date (day, month, year)
int *day, *month, *year;
{
unsigned int date;
   date=Tgetdate ();
   *day=date&31;
   *month=date>>5&15;
   *year=(date>>9)+80;
}

set_date (day, month, year)
int day, month, year;
{
   Tsetdate (day+(month<<5)+((year-80)<<9));
}

get_time (hour, minute, second)
int *hour, *minute, *second;
{
unsigned int time;
   time=Tgettime ();
   *second=2*(time&31);
   *minute=time>>5&63;
   *hour=time>>11;
}

set_time (hour, minute, second)
int hour, minute, second;
{
   Tsettime (second/2+(minute<<5)+(hour<<11));
}

atoi (str_pt, n, num)
char **str_pt;
int n, *num;
{
char ch;
   do
   {  if (!(ch=**str_pt))
         return;
      (*str_pt)++;
   }
   while (ch<'0'||ch>'9');
   *num=ch-'0';
   while (--n&&(ch=**str_pt)>='0'&&ch<='9')
   {  *num=10 * *num + ch-'0';
      (*str_pt)++;
   }
}

itoa_2 (str, num)
char *str;
int num;
{
   str[0]=(num/10)%10 + '0';
   str[1]=num%10 + '0';
}

set_num (str, a, b, c)
char *str;
int *a, *b, *c;
{
   atoi (&str, 2, a);
   atoi (&str, 2, b);
   atoi (&str, 0, c);
   *c%=100;
}

set_str (str, a, b, c, ch)
char *str, ch;
int a, b, c;
{
   itoa_2 (str, a);
   itoa_2 (str+3, b);
   itoa_2 (str+6, c);
   str[2]=str[5]=ch;
   str[8]=0;
}

put_date (str)
char *str;
{
int day, month, year;
   get_date (&day, &month, &year);
   set_num (str, &day, &month, &year);
   set_date (day, month, year);
   get_date (&day, &month, &year);
   set_str (str, day, month, year, '/');
}

put_time (str)
char *str;
{
int hour, minute, second;
   get_time (&hour, &minute, &second);
   second=0;
   set_num (str, &hour, &minute, &second);
   set_time (hour, minute, second);
   get_time (&hour, &minute, &second);
   set_str (str, hour, minute, second, ':');
}


main ()
{
char str[9];
unsigned int date, time;
   Cconws ("\33eDatum: ");
   read_str (str, 8);
   put_date (str);
   Cconws ("\33IDatum: ");
   puts (str);
   Cconws ("Zeit : ");
   read_str (str, 8);
   put_time (str);
   Cconws ("\33IZeit : ");
   puts (str);
   date=Tgetdate ();
   time=Tgettime ();
   Settime(((long)date<<16) + time);
}
