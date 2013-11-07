/*
 * progje om te tellen hoeveel verschillende blok combinaties in het veld zitten.
 * er wordt uitgegaan van een 20x11 veld, 11 om te compeseren voor top en bottom line
 */

#include <stdio.h>
#include <string.h>

#define MAPLEN 540 /* maplengte is 540 words */
#define MAPHEIGHT 100UL /* map hoogte */

char count[65536UL];
unsigned int veld[100000UL];

int main(void)
{
  FILE*f;
  unsigned int i=54000U;
  int maxpairs=0;
  if((f=fopen("map.dat", "rb"))==NULL)
  {
    printf("File open error!\n");
    return -1;
  }
  fread(veld, 640L*100L*2L, 1, f);
  fclose(f);
  do
  {
    int j;
    int k;
    int pairs=0;
    unsigned int* p=veld+i;
    memset(count, 0, 65536L);
    k=0;
    do
    {
      j=0;
      do
      {
        unsigned int index;
        index=p[k*MAPLEN+j];
        index+=p[k*MAPLEN+j+1]>>8;
        if(count[index]==0)
        {
          pairs++;
          count[index]=1;
        }
      }
      while(++j<20);
    }
    while(++k<11);
    if(pairs>maxpairs)
    {
      maxpairs=pairs;
      printf("Maximaal aantal pairs = %i\n",maxpairs);
    }
    printf("%u\r",i);
  }
  while(i-->0);
  printf("Maximaal aantal pairs = %i\n",maxpairs);
  return 0;
}
