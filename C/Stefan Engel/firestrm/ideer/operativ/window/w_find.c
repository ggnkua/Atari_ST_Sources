#include "window.h"
/********************************************************************/
/********************************************************************/
window *WindowFind(long id)
{
  _windowentry *tempentry=windowsystem.firstlist->list;
  window *tempwindow=0;
  while(tempentry!=0)
  {
    if(tempentry->currwindow->id==id)
    {
      tempwindow=tempentry->currwindow;
      break;
    }
    tempentry=tempentry->nextentry;
  }
  return(tempwindow);
}