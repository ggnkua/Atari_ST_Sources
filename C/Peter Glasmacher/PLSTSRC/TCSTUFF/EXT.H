/*      EXT.H

        Extended library definitions

        Copyright (c) Borland International 1988
        All Rights Reserved.
*/


#if !defined( __EXT )
#define __EXT


#define FA_UPDATE       0x00
#define FA_RDONLY       0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_LABEL        0x08
#define FA_DIREC        0x10
#define FA_ARCH         0x20


struct ffblk   {
    char ff_reserved[21];               /* Reserved by TOS */
    char ff_attrib;                     /* Attribute found */
    int  ff_ftime;                      /* File time */
    int  ff_fdate;                      /* File date */
    long ff_fsize;                      /* File size */
    char ff_name[13];                   /* File name found */
};

struct date
{
    int    da_year;                     /* Current year */
    char   da_day;                      /* Day of the month */
    char   da_mon;                      /* Month ( 1 = Jan ) */
};

struct time
{
    unsigned char   ti_min;             /* Minutes */
    unsigned char   ti_hour;            /* Hours */
    unsigned char   ti_hund;            /* Hundredths of seconds */
    unsigned char   ti_sec;             /* Seconds */
};

struct ftime   {
   struct   {
      unsigned ft_hour:   5;
      unsigned ft_min:    6;
      unsigned ft_tsec:   5;
      unsigned ft_year:   7;
      unsigned ft_month:  4;
      unsigned ft_day:    5;
   }tbit;
   long fltime;
};

int             findfirst( char *filename, struct ffblk *ffblk,
                           int attrib );
int             findnext( struct ffblk *ffblk );

void            getdate( struct date *dateRec );
void            gettime( struct time *timeRec );
void            setdate( struct date *dateRec );
void            settime( struct time *timeRec );
int             getftime( int handle, struct ftime *ftimep );
int             setftime( int handle, struct ftime *ftimep );

int             kbhit( void );
int             getch( void );
int             putch( int c);
int             chdir( char *filename );

/* impl by glasi  */

int strnicmp(char *,char *,int);
int stricmp(char *,char *);
char *strdup(char *);
int isatty(int);
void tzset(void);
long filelength(int);
char *getscreen(void);

#if !defined(TIME_T)
typedef long time_t;
#endif
time_t unixtime(unsigned int,unsigned int);
unsigned int swapword(unsigned int);
unsigned long swaplong(unsigned long);
#endif



/***********************************************************************/
