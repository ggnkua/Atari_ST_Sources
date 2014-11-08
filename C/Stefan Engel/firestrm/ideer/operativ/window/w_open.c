#include "window.h"
/********************************************************************/
/********************************************************************/
int WindowOpen(long id, short xy[4])
{
  window *tempwindow;
  tempwindow=WindowFind(id);
  if(tempwindow==0)
    return(FAIL);
  tempwindow->status|=WINDOW_STATUS_OPENED;
  return(SYSTEM_OK);
}