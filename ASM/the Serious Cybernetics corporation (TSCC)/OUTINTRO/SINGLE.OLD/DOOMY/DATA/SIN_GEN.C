#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[]) {
  
  FILE * table;
  int i, s;
  
  table = fopen("sin.tbl","wb");
  
  for (i=0;i<2048;i++) {
      s = (int)(16384*sin(i*3.1415926/1024));
      putc(s >> 8,  table);
      putc(s & 0xff, table);
  }
  
  fclose(table);
  
  return 0;
}
