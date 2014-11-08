#include "window.h"
/********************************************************************/
/********************************************************************/
int WindowDelete(long id)
{
  _windowentry *tempentry1=windowsystem.firstlist->list,*tempentry2;
  _windowlist  *templist=windowsystem.firstlist;
  byte counter=0;
  while(windowsystem.lockwindowsystem);
  while(windowsystem.lockwindowlistchange);
  windowsystem.lockwindowlistchange=TRUE;  
  while((tempentry1->currwindow->id!=id)||(!tempentry1->used))
  {
    counter++;
    tempentry1++;
    if(counter==templist->windowlisttotalsize)
    {
      templist=templist->nextwindowlist;
      if(templist==0)
      {
        windowsystem.lockwindowlistchange=FALSE;  
        return(1);
      }
      tempentry1=templist->list;
      counter=0;
    }
  }
  if(tempentry1->currwindow->status&WINDOW_STATUS_OPENED)
  {
//    printf("Delete: Window is opened\n");                                    /* Anrop till WindowClose skall utf”ras i "slutgiltig" version */
//    printf("Deletet: Window needs to be closed before it can be deleted\n"); /* S† dessa rader skall i princip tas bort                     */
    windowsystem.lockwindowlistchange=FALSE;                                 /* */
    return(2);                                                               /* */
  }

  tempentry2=windowsystem.firstentry;
  if(tempentry1!=tempentry2)
  {
    while(tempentry2->nextentry!=tempentry1)
    {
      tempentry2=tempentry2->nextentry;
    }
    if(tempentry1==windowsystem.lastentry)
      windowsystem.lastentry=tempentry2;
  }
  else
  {
    windowsystem.firstentry=tempentry1->nextentry;
  }
  tempentry2->nextentry=tempentry1->nextentry;
  templist->windowlistsize--;
  tempentry1->used=FALSE;
  Mfree(tempentry1->currwindow);  
  windowsystem.lockwindowlistchange=FALSE;  
  return SYSTEM_OK;
}
