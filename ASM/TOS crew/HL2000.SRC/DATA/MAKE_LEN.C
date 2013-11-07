/*
  bepaal lengte van sample
*/


#include <stdio.h>

char buffer[100000UL];

#define LEN 10570UL
char *naam="card.dat";

int main(void)
{
  char *same=buffer;
  FILE *f=fopen(naam, "rb");
  if(f==NULL)
  {
    printf("File open error!\n");
    return -1;
  }
  fread(buffer,LEN,1,f);
  fclose(f);
  {
    char *p=buffer;
    while(p<(buffer+LEN-14))
    {
      int i;
      for(i=0;i<14;i++)
      {
        if(p[i]!=p[i+14])
        {
          same=p+28;
          break;
        }
      }
      printf("%06li: %02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X\n",p-buffer,
      p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],p[11],p[12],p[13]);
      p+=14;
    }
    printf("Orig len=%li, nieuw len=%li\n",LEN,(same-buffer));
    f=fopen(naam,"wb");
    if(f==NULL)
    {
      printf("file open error!\n");
      return -1;
    }
    fwrite(buffer,same-buffer,1,f);
    fclose(f);
  }
  return 0;
}