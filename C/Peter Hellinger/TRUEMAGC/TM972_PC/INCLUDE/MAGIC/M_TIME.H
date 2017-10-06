/*
   Modul: M_TIME.C (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPTIME_
#define _MPTIME_

typedef enum
{
   German,
   English,
   French
} Language;

int EncodeDate(int day,int month,int year);
void DecodeDate(int date,int *day,int *month,int *year);
long DateInNum(int date);
int NumInDate(long number);
void DateString(int date,char *str);
int DayOfYear(int date);
int WeekOfYear(int date);
int DayOfWeek(int date);
void NameOfDay(Language lang,int day,char *name);
void NameOfMonth(Language lang,int month,char *name);
int EncodeTime(int hour,int minute,int second);
void DecodeTime(int time,int *hour,int *minute,int *second);
long TimeInNum(int time);
int NumInTime(long num);
void TimeString(int time,char *str);

#endif
