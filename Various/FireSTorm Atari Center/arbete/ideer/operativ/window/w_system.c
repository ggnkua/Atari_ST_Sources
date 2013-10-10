#include "window.h"
/********************************************************************/
/********************************************************************/
_windowsystem  windowsystem;
/********************************************************************/
/********************************************************************/
void _WindowSystem(void)
{
  windowsystem.lockwindowsystem=TRUE;
  windowsystem.lockwindowlistchange=FALSE;
  windowsystem.createwindowlist=20;
  windowsystem.deletewindowlist=10;
  windowsystem.highid=windowsystem.lowid=0;
  windowsystem.firstlist=CreateWindowList(0);
  if(windowsystem.firstlist==0)
  {
    exit(FATAL_WINDOW);
  }
  windowsystem.lockwindowsystem=FALSE;
}