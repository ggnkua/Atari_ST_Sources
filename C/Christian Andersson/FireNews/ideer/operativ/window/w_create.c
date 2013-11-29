#include "window.h"
/********************************************************************/
/********************************************************************/
window *WindowCreate(int type, int parent)
{
  long count=0;
  _windowlist  *templist=windowsystem.firstlist;
  _windowentry *tempentry;
  window       *tempwindow;

  while(windowsystem.lockwindowsystem);
  while(windowsystem.lockwindowlistchange);
  windowsystem.lockwindowlistchange=TRUE;
  do
  {
    if(templist->windowlistsize==templist->windowlisttotalsize)
    {
      if(templist->nextwindowlist==0)
      {
        templist=CreateWindowList(templist);
        if(templist==0)
        {
          windowsystem.lockwindowlistchange=FALSE;
          return((window*)0);
        }
      }
      else
        templist=templist->nextwindowlist;
      count+=templist->windowlisttotalsize;
    }
    else
    {
      tempentry=templist->list;
      while(tempentry->used)
      {
        count++;
        tempentry++;
      }
      tempwindow=(window*)Malloc(sizeof(window));
      if(tempwindow==0)
      {
        windowsystem.lockwindowlistchange=FALSE;
        return((window*)0);
      }
      tempentry->currwindow=tempwindow;
      tempentry->used=TRUE;
      if(windowsystem.firstentry==0)
        windowsystem.firstentry=tempentry;
      if(windowsystem.lastentry!=0)
        windowsystem.lastentry->nextentry=tempentry;
      windowsystem.lastentry=tempentry;
      windowsystem.lastentry->nextentry=0;
      templist->windowlistsize++;
      break;
    }
  }while(TRUE);
  tempwindow->id=windowsystem.highid++;
  tempwindow->parentid=0;
  tempwindow->status=WINDOW_STATUS_CLOSED;
  windowsystem.lockwindowlistchange=FALSE;
  return(tempwindow);
}
/********************************************************************/
/********************************************************************/
