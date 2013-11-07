#include <stdio.h>
#include <stdlib.h>

char data[32768UL];

int main(void)
{
  FILE *f;
  f=fopen("hland.pi1","rb");
  if(f==NULL)
  {
    printf("File open error!\n");
    exit(-1);
  }
  fread(data,32034, 1,f);
  fclose(f);
  f=fopen("wolk.dat","wb");
  if(f==NULL)
  {
    printf("File open error!\n");
    exit(-1);
  }
  fwrite(data+34+160*18,160*14, 1,f);
  fclose(f);
}