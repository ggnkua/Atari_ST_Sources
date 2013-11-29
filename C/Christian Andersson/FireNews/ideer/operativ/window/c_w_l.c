#include "window.h"
/********************************************************************/
/********************************************************************/
_windowlist* CreateWindowList(_windowlist* previouslist)
{
  _windowlist*  templist;
  byte counter;
  
  templist=(_windowlist*)Malloc((long)sizeof(_windowlist)+(long)sizeof(_windowentry)*windowsystem.createwindowlist);
  if(templist==0)
    return ((_windowlist*)0);
  if(previouslist!=0)
     previouslist->nextwindowlist=templist;
  templist->nextwindowlist=0;
  templist->windowlisttotalsize=windowsystem.createwindowlist;
  templist->windowlistsize=0;
  templist->list=(_windowentry*)((long)templist+(long)sizeof(_windowlist));
  for(counter=0;counter<windowsystem.createwindowlist;counter++)
  {
    templist->list[counter].used=FALSE;
  }
  
  return templist;
}
/********************************************************************/
/********************************************************************/
