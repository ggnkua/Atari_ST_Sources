/*{{{  #includes*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __GNUC__
#include <osbind.h>
#include <unistd.h>
#else /* TurboC / PureC */
#include <tos.h>
#include <ext.h>
#endif
/*}}}  */

typedef struct
{
  unsigned int ph_branch;
  unsigned long ph_tlen;
  unsigned long ph_dlen;
  unsigned long ph_blen;
  unsigned long ph_slen;

  unsigned long ph_res1;
  unsigned long ph_res2;
  unsigned int ph_flag;
} PH;
PH header;

#ifndef __GNUC__
/*{{{  void putw(unsigned int w, FILE *s)*/
void putw(unsigned int w, FILE *s)
{
  putc(w>>8,s);
  putc(w&0xff,s);
}
/*}}}  */
/*{{{  void putl(unsigned int w, FILE *s)*/
void putl(unsigned long w, FILE *s)
{
  putc((w>>24) & 0xff,s);
  putc((w>>16) & 0xff,s);
  putc((w>>8) & 0xff,s);
  putc(w&0xff,s);
}
/*}}}  */
/*{{{  unsigned int getw(FILE *s)*/
unsigned int getw(FILE *s)
{
  unsigned int w;

  w=(getc(s)<<8) & 0xff00;
  w|=(getc(s))   & 0x00ff;
  return w;
}
/*}}}  */
/*{{{  unsigned long getl(FILE *s)*/
unsigned long getl(FILE *s)
{
  unsigned long w;

  w=(getc(s)<<24)  & 0xff000000l;
  w|=(getc(s)<<16) & 0x00ff0000l;
  w|=(getc(s)<<8)  & 0x0000ff00l;
  w|=(getc(s))     & 0x000000ffl;

  return w;
}
/*}}}  */
#endif
/*{{{  int do_strip(char *name)*/
int do_sum(char *name)
{
  /*{{{  local vars*/
  FILE *in;
  long i;
  unsigned int xor,sum,x,num_relo=0;
  /*}}}  */

  in = fopen(name,"r+b");
  if (in == 0)
    return 1; /* file does not exist */
  /*{{{  read header*/
  header.ph_branch = getw(in);
  if (header.ph_branch != 0x601a)
  {
    fclose(in);
    return 3;  /* no executable file */
  }

  header.ph_tlen = getl(in);
  header.ph_dlen = getl(in);
  header.ph_blen = getl(in);
  header.ph_slen = getl(in);
  header.ph_res1 = getl(in);
  header.ph_res2 = getl(in);
  header.ph_flag = getw(in);

  printf("text: %ld bytes\n",header.ph_tlen);
  printf("data: %ld bytes\n",header.ph_dlen);
  printf("Bss: %ld bytes (not in file)\n",header.ph_blen);

  fseek(in,0x2e,SEEK_SET);
	sum = xor = 0;  
  for (i = 0; i<header.ph_tlen + header.ph_dlen - (0x2e-0x1c); i+=2)
  {
  	x = getw(in);
  	sum += x;
  	xor ^= x;
  }
  printf("sum: $%04x   xor: $%04x\n",sum,xor);
  fseek(in,0x26,SEEK_SET);
  putw(sum,in);
  putw(0,in);
  putw(xor,in);
  putw(0,in);
  
  fclose(in);
  return 0;
}
/*}}}  */
/*{{{  int main(int argc, char *argv[])*/
int main(int argc, char *argv[])
{
  int i;
  DTA MyDta;

  Fsetdta(&MyDta);

  if (argc == 1)
  {
    fprintf(stderr,"checksum v1.0 (C) 1995 M. Schwingen\nusage: checksum file [...]\n");
    return -1;
  }
  for (i=1; i<argc; i++)
  {
    puts(argv[i]);
    switch(do_sum(argv[i]))
    {
      case 4: fprintf(stderr,"strip %s: not enough memory for symbols.\n",argv[i]);
              return -1;
      case 3: fprintf(stderr,"strip %s: not an executable file.\n",argv[i]);
              return -1;
      case 2: fprintf(stderr,"strip %s: cannot create output file.\n",argv[i]);
              return -1;
      case 1: fprintf(stderr,"strip %s: file not found.\n",argv[i]);
              return -1;
      case 0: printf("%s successfully modified.\n",argv[i]);
              break;
    }
  }
  return 0;
}
/*}}}  */
