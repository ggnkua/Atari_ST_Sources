#include "window.h"
/********************************************************************/
/********************************************************************/
#define WINDOW 10
/********************************************************************/
/********************************************************************/
int main(void)
{
  int counter;
  short xy[4];
  window* win[WINDOW+1];
  _WindowSystem();
  for(counter=0;counter<=WINDOW;counter++)
    win[counter]=WindowCreate(0,0);
  printlist();  

  if(!WindowOpen(5,xy))
    printf("Window successfully opened\n");
  else
    printf("Window cannot be opened\n");

  for(counter=0;counter<=WINDOW;counter++)
    WindowDelete(win[counter]->id);
  printlist();  
  
  WindowClose(5);
  
  WindowDelete(5);
  
  printlist();
  return(0);
}

/********************************************************************/
/********************************************************************/
void printlist()
{
  _windowentry *tempentry=windowsystem.firstentry;
  int counter=0;  
  printf("Opened windows (id, and pointers in memory)\n\n");
  printf("%5s%15s%15s%15s%7s%7s\n","ID","windowentry","window","nextentry","Parent","Status");
  while(tempentry!=0)
  {
    printf("%5ld%15ld%15ld%15ld%7ld%7ld\n",tempentry->currwindow->id,tempentry,tempentry->currwindow,tempentry->nextentry,tempentry->currwindow->parentid,tempentry->currwindow->status);
    counter++;
    if(counter==25)
    {
      counter=0;
      getch();
    }
    tempentry=tempentry->nextentry;
  }
  getch();
}