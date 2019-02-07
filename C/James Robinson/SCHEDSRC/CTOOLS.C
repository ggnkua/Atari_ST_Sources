/************************************************************/
/*                         CTOOLS.C                         */
/*                                                          */
/*             C tools developed by James Robinson          */
/************************************************************/

#define AND &&
#define OR  ||
#define NE  !=
#define EQ  ==

#define FALSE 0
#define TRUE  1

#define MAX_CLMS 256

/* TABLES FOR COMPUTING DAY OF WEEK FROM 1700-2099 */

/* Computing the day of the week can be done in a much simpler  */
/* and faster way for a practically unlimited number of years.  */
/* If upgrades are made, I will probably use this other method. */
/* There are also faster methods for calculating between dates. */

static int dayarray[14][12]={{4,7,7,3,5,1,3,6,2,4,7,2},  /* A */
                             {5,1,1,4,6,2,4,7,3,5,1,3},  /* B */
                             {6,2,3,6,1,4,6,2,5,7,3,5},  /* C */
                             {1,4,4,7,2,5,7,3,6,1,4,6},  /* D */
                             {2,5,5,1,3,6,1,4,7,2,5,7},  /* E */
                             {3,6,6,2,4,7,2,5,1,3,6,1},  /* F */
                             {4,7,1,4,6,2,4,7,3,5,1,3},  /* G */
                             {6,2,2,5,7,3,5,1,4,6,2,4},  /* H */
                             {7,3,3,6,1,4,6,2,5,7,3,5},  /* I */
                             {2,5,6,2,4,7,2,5,1,3,6,1},  /* J */
                             {7,3,4,7,2,5,7,3,6,1,4,6},  /* K */
                             {1,4,5,1,3,6,1,4,7,2,5,7},  /* L */
                             {3,6,7,3,5,1,3,6,2,4,7,2},  /* M */
                             {5,1,2,5,7,3,5,1,4,6,2,4}}; /* N */

static int find_year[14][12]={

{1710,1721,1727,1806,1817,1823,1902,1913,1919,2014,2025,2031}, /* A */
{1705,1711,1722,1801,1807,1818,1903,1914,1925,2015,2026,2037}, /* B */
{1712,1808,1904,2016,-999,-999,-999,-999,-999,-999,-999,-999}, /* C */
{1702,1713,1719,1809,1815,1826,1905,1911,1922,2017,2023,2034}, /* D */
{1703,1714,1725,1810,1821,1827,1906,1917,1923,2018,2029,2035}, /* E */
{1709,1715,1726,1805,1811,1822,1901,1907,1918,2013,2019,2030}, /* F */
{1716,1812,1908,2020,-999,-999,-999,-999,-999,-999,-999,-999}, /* G */
{1706,1717,1723,1802,1813,1819,1909,1915,1926,2021,2027,2038}, /* H */
{1701,1707,1718,1803,1814,1825,1910,1921,1927,2022,2033,2039}, /* I */
{1720,1816,1912,2024,-999,-999,-999,-999,-999,-999,-999,-999}, /* J */
{1724,1820,1916,2028,-999,-999,-999,-999,-999,-999,-999,-999}, /* K */
{1708,1804,1928,2040,-999,-999,-999,-999,-999,-999,-999,-999}, /* L */
{1704,1828,1924,2036,-999,-999,-999,-999,-999,-999,-999,-999}, /* M */
{1728,1824,1920,2032,-999,-999,-999,-999,-999,-999,-999,-999}};/* N */

extern char *malloc();

extern char *ct_buff;

char *right(string,n)
char string[];
int n;
{
   register int l,i;
   char result[MAX_CLMS];

   i=0;

   for (l=strlen(string)-n; l<strlen(string); l++)
   {
      if(string[l]=='\0')
         break;
      result[i]=string[l];
      i++;
   }
   result[i]='\0';

   strcpy(ct_buff,result);
   return ct_buff;
}

char *left(string,n)
char string[];
int n;
{
   register int l,i;
   char result[MAX_CLMS];

   i=0;

   for (l=0; l<=n-1; l++)
   {
      if(string[l]=='\0')
         break;
      result[i]=string[l];
      i++;
   }
   result[i]='\0';

   strcpy(ct_buff,result);
   return ct_buff;
}

char *mid(string,start,n)
char string[];
int start,n;
{
   register int l,i;
   char result[MAX_CLMS];

   i=0;

   if (start>0 AND n>0)
   {
      for (l=start-1; l<start+n-1; l++)
      {
         if(string[l]=='\0')
            break;
         result[i]=string[l];
         i++;
      }
   }
   result[i]='\0';

   strcpy(ct_buff,result);
   return ct_buff;
}

char *replicate(chr,n)
char chr;
int n;
{
   char temp[MAX_CLMS];
   int i;

   for(i=0; i<n; i++)
      temp[i]=chr;

   temp[i]='\0';

   if(strlen(temp)>0)
      strcpy(ct_buff,temp);
   else
      strcpy(ct_buff,"");
   return ct_buff;
}

char *rjustify(s,n)
char *s;
int n;
{
   char temp[MAX_CLMS];
   int i;

   for(i=0; i<n-strlen(s); i++)
      temp[i]=' ';

   temp[i] ='\0';

   strcat(temp,s);

   strcpy(ct_buff,temp);

   return ct_buff;
}

char *month_str(date)
char date[];
{
   int mn;
   static char *m_name[]={
                           "Invalid\0",
                           "January\0",
                           "February\0",
                           "March\0",
                           "April\0",
                           "May\0",
                           "June\0",
                           "July\0",
                           "August\0",
                           "September\0",
                           "October\0",
                           "November\0",
                           "December\0" };

   mn=atoi(mid(date,5,2));

   return((mn<1 OR mn>12) ? m_name[0] : m_name[mn]);
}

num_days(month,year)
int month,year;
{
   static int days[13]={ 0,31,28,31,30,31,30,31,31,30,31,30,31 };

   if (year % 4 EQ 0)
      days[2]=29;
   else
      days[2]=28;

   return(days[month]);
}

mday(date)
char date[];
{
   int day;

   day=atoi(right(date,2));

   return(day);
}

year(date)
char date[];
{
   int yr;

   yr=atoi(left(date,4));

   return(yr);
}

month(date)
char date[];
{
   int mn;

   mn=atoi(mid(date,5,2));

   return(mn);
}

wday(date)
char date[];
{
   register i,j,k;
   int yr,mn,md,row,column,found,day;

   /* CURRENTLY WORKS DURING 1700-2099 PERIOD */

   yr=year(date); mn=month(date); md=mday(date);

   if(yr<1700 || yr>2099)
      return(-1);

   i=found=0;

   while(i<14 AND !found)
   {
      for(j=0; j<12; j++)
      {
         for(k=0; k<4; k++)
            if(yr EQ find_year[i][j]+28*k)
               found=TRUE;
      }
   i++;
   }

   if(yr==1700 || yr==1800 || yr==1900) /* SPECIAL CASES */
   {
      found=TRUE;
      if(yr==1700)
         column=7; /* H */
      if(yr==1800)
         column=0; /* A */
      if(yr==1900)
         column=4; /* E */
   }
   else if(yr==1803 || yr==1910) /* VERY SPECIAL CASES */
      column=8; /* I */
   else if(yr==1804)
      column=11; /* L */
   else if(yr==1805 || yr==1811 || yr==1901 || yr==1907)
      column=5; /* F */
   else
      column=i-1;

   row=mn-1;

   if(!found)
      return(-1);

   day=dayarray[column][row];

   for (i=0; i<md-1; i++) 
   {
      day++;
      if (day>7)
         day=1;
   }
   return(day);
}

char *wday_str(date)
char date[];
{
   int dayweek;
   static char *day_str[]={
                            "\0",
                            "Sunday\0",
                            "Monday\0",
                            "Tuesday\0",
                            "Wednesday\0",
                            "Thursday\0",
                            "Friday\0",
                            "Saturday\0" };

   dayweek=wday(date);
   return((dayweek<1 OR dayweek>7) ? day_str[0] : day_str[dayweek]);
}   

long calc_bd(sdate,edate)  /* returns number of days between two dates */
char sdate[],edate[];
{
   register int syr,smn,sdy;
   int eyr,emn,edy,done;
   register long tot;

   syr=year(sdate); smn=month(sdate); sdy=mday(sdate);
   eyr=year(edate); emn=month(edate); edy=mday(edate);

   if(smn==emn && syr==eyr)
   {
      tot=edy-sdy;
      return(tot);
   }

   tot=0; done=FALSE;

   for(;;)
   {
      if(syr==eyr-1? syr==eyr-1 : syr==eyr)
         break;
      tot+=days_year(syr);
      syr++;
   }

   for(;;)
   {
      tot+=num_days(smn,syr);
      smn++;
       if(smn>12)
       {
          smn=1;
          syr++;
       }
       if(smn>emn && syr>=eyr)
          break;
       if(syr>eyr)
          break;
   }

   tot-=num_days(emn);
   tot+=edy-sdy;

   return(tot);
}

days_year(year)
int year;
{
   if(year % 4 == 0)
      return(366);
   else
      return(365);
}

char *fd_forward(date,days)
char date[];
int days;
{
   register int yr,mn,dy,tot;
   char *ptr_date[9];
   char mns[3],dys[3],yrs[5],ret_date[9];

   yr=year(date); mn=month(date); dy=mday(date);

   tot=0;

   if(dy+days>num_days(mn,yr))
   {
      while(days-num_days(mn,yr)>tot-dy)
      {
         tot+=num_days(mn,yr);
         mn++;
         if(mn>12)
         {
            mn=1;
            yr++;
         }
      }
      dy=(dy+days)-tot;
      if(dy<=0)
         dy+=num_days(mn,yr);
   }
   else
      dy+=days;

   itoa(mn,mns); itoa(dy,dys); itoa(yr,yrs);

   strcpy(ret_date,"");
   strcat(ret_date,yrs);
   if(mn<10)
      strcat(ret_date,"0");
   strcat(ret_date,mns);
   if(dy<10)
      strcat(ret_date,"0");
   strcat(ret_date,dys);
   strcpy(ptr_date,ret_date);

   return ptr_date;
}

char *fd_backward(date,days)
char date[];
int days;
{
   register int yr,mn,dy,tot;
   char *ptr_date[9];
   char mns[3],dys[3],yrs[5],ret_date[9];

   yr=year(date); mn=month(date); dy=mday(date);

   tot=0;

   if(dy-days<=0)
   {
      while(days-dy>=tot)
      {
         if(mn==1)
            tot+=num_days(12,yr);
         else
            tot+=num_days(mn-1,yr);
         mn--;
         if(mn<1)
         {
            mn=12;
            yr--;
         }
      }
      dy=tot-days+dy;
   }
   else
      dy-=days;

   itoa(mn,mns); itoa(dy,dys); itoa(yr,yrs);

   strcpy(ret_date,"");
   strcat(ret_date,yrs);
   if(mn<10)
      strcat(ret_date,"0");
   strcat(ret_date,mns);
   if(dy<10)
      strcat(ret_date,"0");
   strcat(ret_date,dys);
   strcpy(ptr_date,ret_date);

   return ptr_date;
}

itoa(n,s)
int n;
char s[];
{
   int i, sign;

   if ((sign=n) <0)
      n = -n;
   i=0;
   do
   {
      s[i++] = n % 10 + '0';
   } while ((n /= 10) >0);
   if (sign<0)
      s[i++]='-';
   s[i]='\0';
   reverse(s);
}

ltoa(n,s)
long n;
char s[];
{
   long i,sign;

   if ((sign=n) <0)
      n = -n;
   i=0;
   do
   {
      s[i++] = n % 10 + '0';
   } while ((n /= 10) >0);
   if (sign<0)
      s[i++]='-';
   s[i]='\0';
   reverse(s);
}

reverse(s)
char s[];
{
   int c, i, j;

   for (i = 0, j = strlen(s)-1; i < j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
   }
}

int
instr(string,substring)
char string[],substring[];
{
   int i,j,k;

   if(strlen(substring)==0)
      return(FALSE);

   for(i=0; string[i]!='\0'; i++)
      for(j=i,k=0; substring[k]==string[j]; k++,j++)
         if(substring[k+1]=='\0')
            return(TRUE);

   return(FALSE);
}

chg_chr(s,old,new)
char *s,old,new;
{
   int i;

   for(i=0; i<strlen(s); i++)
      if(s[i]==old)
         s[i]=new;
}

num_suffix(str)
char *str;
{
   if(strcmp(mid(str,strlen(str)-1,1),"1")!=0)
   {
      if(strcmp(right(str,1),"1")==0)
         strcat(str,"st");
      else if(strcmp(right(str,1),"2")==0)
         strcat(str,"nd");
      else if(strcmp(right(str,1),"3")==0)
         strcat(str,"rd");
      else
         strcat(str,"th");
   }
   else
         strcat(str,"th");
}

ltrim(str)
char *str;
{
   int i;

   for(i=0; str[i]==' '; i++);

   strcpy(str,right(str,strlen(str)-i));
}

rtrim(str)
char *str;
{
   int i,end;

   end=strlen(str);

   for(i=end-1; str[i]==' '; i--)
      str[i]='\0';
}

upper(str)
char *str;
{
   int i;

   for(i=0; str[i]!='\0'; i++)
      str[i]=toupper(str[i]);
}

word_end(chr)
char chr;
{
   if(chr==' ' || chr=='/' || chr=='.' ||
      chr=='-' || chr==';' || chr==':' ||
      chr=='|' || chr==',' || chr=='\\'||
      chr==']' || chr=='\''|| chr=='\"'||
      chr=='}' || chr==')')
      return(TRUE);
   else
      return(FALSE);
}

int
hours_between(start,end)
char start[6],end[6];
{
   int shour,ehour;

   shour=atoi(mid(start,2,2));
   if(start[0]=='p')
      shour+=12;

   ehour=atoi(mid(end,2,2));
   if(end[0]=='p')
      ehour+=12;

   return(ehour-shour);
}

int
mins_between(start,end)
char start[6],end[6];
{
   int smin,emin;

   smin=atoi(right(start,2));

   emin=atoi(right(end,2));

   return(emin-smin);
}


