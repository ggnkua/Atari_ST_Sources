#include "firecall.h"
#include <time.h>
/********************************************************************/
/********************************************************************/
void getdate(char *date)
{
  time_t    timedata;

  timedata=time(NULL);
  strftime(date,SIZE_TIME,"%y%m%d %X",localtime(&timedata));
}