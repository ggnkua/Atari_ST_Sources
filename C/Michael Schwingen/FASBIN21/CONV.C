/*
   convert FAS Hex-output to binary
   (C) 1992 Michael Schwingen
   Michael Schwingen @ AC3 (Mausnet)
   michaels@pool.informatik.rwth-aachen.de (Internet)

   this may be distributed freely.
*/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <ext.h>

#define MAX_DATA 65536L
unsigned char data[MAX_DATA];

int main(int argc, char *argv[])
{
  FILE *fp;
  unsigned i,j,num;
  unsigned adr, last_adr = 0, dat;
  
  for (i=0;i<65535u; i++)
    data[i] = 0xFF;
  if (argc != 3)
  {
    fprintf(stderr,"use: conv infile outfile\n");
    return -1;
  }
  fp = fopen(argv[1],"r");
  if (fp == 0)
  {
    fprintf(stderr,"error: cannot open file %s\n",argv[1]);
    return -1;
  }
  while (1)
  {
    while (getc(fp) != ':')
      ;
    if (fscanf(fp,"%02x",&num) != 1)
    {
      fprintf(stderr,"file %s format error.\n",argv[1]);
      fclose(fp);
      return -1;
    }
    if (num == 0)
    {
      fclose(fp);
      break;
    }
    if (fscanf(fp,"%04x",&adr) != 1)
    {
      fprintf(stderr,"file %s format error.\n",argv[1]);
      fclose(fp);
      return -1;
    }
    if ((long) adr + (long) num > MAX_DATA)
    {
      fprintf(stderr,"file %s: too high address. Buffer space is %ld bytes.\n",argv[1],(long) MAX_DATA);
      fclose(fp);
      return -1;
    }
    for (i=0;i<2;i++)
      getc(fp);
    for (i=0;i<num; i++)
    {
      fscanf(fp,"%02x",&dat);
      data[adr++] = dat;
    }
    fscanf(fp,"%02x",&dat);
    if (adr > last_adr)
      last_adr = adr;
  }
  fclose(fp);
  
  fp = fopen(argv[2],"wb");
  if (fp == 0)
  {
    fprintf(stderr,"error: cannot write file %s\n",argv[2]);
    return -1;
  }
 
  for (j=0;j<8;j++) 
	  for (i=0;i<8192;i++)
	  	fputc(data[i],fp);
  fclose(fp);
  return 0;
}
