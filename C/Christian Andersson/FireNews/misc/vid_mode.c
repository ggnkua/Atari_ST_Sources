#include <stdio.h>
#include <ext.h>
#include <tos.h>

void main(void)
{
  int mode;
  mode=Vsetmode(0);
  Vsetmode(mode);
  printf("Video-mode=%d",mode);
  getch();
}