#include <time.h>
#include <ext.h>
/*----------------------------------------------------------------------*
*-----------------------------------------------------------------------*/
extern time_t _cnvDatS();
extern long timezone;

static struct TT   {
 int  sec, min, hour, day, month, year;
};


time_t unixtime(unsigned time,unsigned date)
{
struct TT tt;

   ltime(time,date,&tt);
   tt.year += 80;
   tt.month--;
   return((_cnvDatS(&tt) - timezone));
}

