#include "window.h"
/********************************************************************/
/********************************************************************/
int WindowClose(long id)
{
  window *tempwindow;
  tempwindow=WindowFind(id);
  if(tempwindow==0)
    return(FAIL);
  tempwindow->status=WINDOW_STATUS_CLOSED;
  return(SYSTEM_OK);
}