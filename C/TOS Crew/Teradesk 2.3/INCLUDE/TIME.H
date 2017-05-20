/*      TIME.H

        ANSI Time functions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __TIME )
#define    __TIME

#define     CLK_TCK 200

typedef     unsigned long size_t;
typedef     long time_t;
typedef     long clock_t;


extern long timezone;
extern int    daylight;


struct tm
{
    int tm_sec;   /* seconds after the minute -- [0,  59] */
    int tm_min;   /* minutes after the hour   -- [0,  59] */
    int tm_hour;  /* hours since midnight     -- [0,  23] */
    int tm_mday;  /* day of the month         -- [1,  31] */
    int tm_mon;   /* months since January     -- [0,  11] */
    int tm_year;  /* years since 1900         -- [      ] */
    int tm_wday;  /* day since Sunday         -- [0,   6] */
    int tm_yday;  /* day since January 1      -- [0, 365] */
    int tm_isdst; /* daylight saving time flag            */
};

char         *asctime( const struct tm *tblock );
char         *ctime( const time_t *timer );

struct tm    *gmtime( const time_t *clock );
struct tm    *localtime( const time_t *clock );

time_t       time( time_t *timer );
time_t       mktime( struct tm *timeptr );

clock_t      clock( void );

size_t       strftime( char *s, size_t max_size, const char *format,
                       const struct tm *timeptr );

double       difftime( time_t time2, time_t time1 );


#endif



/***********************************************************************/
