/*
* background scroller
* (c) 2006 Hans Wessels
* placed in public domain
*/

#include <stdio.h>
#include <tos.h>

#define BOUNCE 128
#define MUS_LEN 75250UL

void demo(void);
void preshift(char* buffer);
void copy_2plane(char* src1, char* src2, long dst);
int load_data(char* path, void* dst, long size);
void vsync(void);
void trap3_handler(void);
void do_music(void);

int main(void)
{
  Supexec((long (*)( ))(demo));
  return 0;
}

char screen[32256UL];
char buf[17*32000UL];
char txt[32000];
char mus[MUS_LEN];
char *musp;
char *muse;
int colors[16];


void demo(void)
{
  char* scr;
  char old_res;
  long old_scrp;
  int old_colors[16];
  int bounce[BOUNCE];
  void* old_trap3;
  long scrp;
  if(load_data("bg_pic.pi2", buf+32000UL, 32034UL))
  {
    return;
  }
  if(load_data("txt.pi1", screen+222, 32034UL))
  {
    return;
  }
  if(load_data("musix.dat", mus, MUS_LEN))
  {
    return;
  }
  { /* copy colors */
    long* p=(void*)(buf+32000UL+2);
    long* q=(void*)colors;
    *q++=*p++;
    *q++=*p++;
    p=(void*)(screen+222+2+8);
    *q++=*p++;
    *q++=*p++;
    *q++=*p++;
    *q++=*p++;
    *q++=*p++;
    *q++=*p++;
  }
  { /* copy picture data */
    int i;
    long* p=(void*)(buf+32000UL+34);
    long* q=(void*)buf;
    long* r;
    for(i=0;i<(32000/4);i++)
    {
      *q++=*p++;
    }
    preshift(buf);
    p=(void*)(screen+222+34+4);
    q=(void*)txt;
    r=(void*)(txt+16000);
    for(i=0;i<(16000/4);i++)
    {
      *q++=*p;
      *r++=*p;
      p+=2;
    }
  }
  { /* init */
    old_scrp=*(long*)0xFF8200UL;
    old_trap3=*(void **)0x8c;
    *(void**)0x8c=trap3_handler;
    scr=(char*)(((long)screen+256)&0xffff00UL);
    scrp=(long)scr;
    scrp+=(scrp&0xff00)>>8;
    *(long*)0xFF8200UL=scrp;
    old_res=*(char*)0xff8260UL;
    vsync();
    *(char*)0xff8260UL=0; /* st low */
    {
      int i;
      for(i=0;i<16;i++)
      {
        old_colors[i]=((int*)0xff8240UL)[i];
        ((int*)0xff8240UL)[i]=colors[i];
      }
    }
    {
      int i;
      float x;
      for(i=0;i<BOUNCE;i++)
      {
        x=(float)(i-BOUNCE/2)/(float)(BOUNCE/2);
        bounce[i]=32000-160*(int)(200.0*x*x);
      }
    }
    muse=mus+MUS_LEN;
    musp=mus;
  }
  { /* display */
    long i=0;
    int j=0;
    int k=0;
    int dir=1;
    do
    {
      i+=dir;
      if(i>=320)
      {
        dir=-1;
        i=318;
      }
      else if(i<0)
      {
        i=1;
        dir=1;
      }
      j++;
      if(j>=200)
      {
        j=0;
      }
      k++;
      if(k>=BOUNCE)
      {
        k=0;
      }
      *((int*)0xff8240UL)=0x700; 
      vsync();
      *((int*)0xff8240UL)=*colors;
      copy_2plane(buf+(i&0xf)*32000+bounce[k]+((i&0xff0)>>2),txt+j*80, (long)scr); 
      do_music();
    }
    while((*(char*)0xfffc02UL)!=57);
  }
  { /* exit */
    { /* kill mus */
      char *p=(char*)0xffff8800UL;
      *p=8;
      p[2]=0;
      *p=9;
      p[2]=0;
      *p=10;
      p[2]=0;
    }
    vsync();
    {
      int i;
      for(i=0;i<16;i++)
      {
        ((int*)0xff8240UL)[i]=old_colors[i];
      }
    }
    *(void **)0x8c=old_trap3;
    *(char*)0xff8260UL=old_res;
    *(long*)0xFF8200UL=old_scrp;
  }
}

void vsync(void)
{
  char reg;
  long base;
  base=*(char*)0xffff8201UL;
  base<<=8;
  base+=*(char*)0xffff8203UL;
  base<<=8;
  base+=32000;
  reg=(base>>16)&0xff;
  while(*(char*)0xffff8205UL!=reg)
  {
    (void)0;
  }
  reg=(base>>8)&0xff;
  while(*(char*)0xffff8207UL!=reg)
  {
    (void)0;
  }
}

int load_data(char* path, void* dst, long size)
{
  FILE *f;
  f=fopen(path,"rb");
  if(f==NULL)
  {
    printf("Source file: %s open error!\n", path);
    return -1;
  }
  fread(dst, 1, size, f);
  fclose(f);
  return 0;
}

void do_music(void)
{
  char *p;
  char *q=(char*)0xffff8800UL;
  char *r=(char*)0xffff8802UL;
  p=musp;
  if(p>=muse)
  {
    p=mus;
  }
  *q=0;
  *r=*p++;
  *q=1;
  *r=*p++;
  *q=2;
  *r=*p++;
  *q=3;
  *r=*p++;
  *q=4;
  *r=*p++;
  *q=5;
  *r=*p++;
  *q=6;
  *r=*p++;
  *q=7;
  *r=*p++;
  *q=8;
  *r=*p++;
  *q=9;
  *r=*p++;
  *q=10;
  *r=*p++;
  *q=11;
  *r=*p++;
  *q=12;
  *r=*p++;
  *q=13;
  *r=*p++;
  musp=p;
}
