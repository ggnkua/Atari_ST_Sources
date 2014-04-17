/* maak sqrt lookup table */

#include <stdio.h>
#include <math.h>

int main(void)
{
  int i;
  FILE* f;
  
  if((f=fopen("sqrt_tab.txt","w"))==NULL)
  {
    printf("File open error!\n");
    return -1;
  }
  
  for(i=0;i<16;i++)
  {
    int j;
    
    fprintf(f, "dc.b ");
    
    for(j=0;j<16;j++)
    {
      fprintf(f,"%i,", (int)sqrt((double)((i<<4)+j)));
    }
    fprintf(f, "\n");
  }
  fclose(f);
  return 0;
}