/*
  music ripper, this time in C
*/


#include <stdio.h>
#include <string.h>
#include <ext.h>
#include <tos.h>
#include <stdlib.h>

#define save_regs movem_save();reglist();
#define restore_regs movem_load();reglist();

void movem_save(void) 0x48e7;     /* movem.l reglist,-(sp) */
void movem_load(void) 0x4cdf;     /* movem.l (sp)+,reglist */
void reglist(void) 0xffff;        /* -1, alle registers */

typedef unsigned int word;
typedef unsigned char byte;

byte music[65536UL];
byte sample[1024UL*512UL];
void (*init_music)(unsigned long data);
void (*play_music)(void);
char *naam="gameover.dat";


void ripper(void);
void play_mus(void);

int main(void)
{
  #if 0
  Supexec((long)(ripper));
  #endif
  Supexec((long)(play_mus));
  return 0;
}

void ripper(void)
{
  { /* load music */
    FILE *f;
    f=fopen("m:\\muziek\\musics\\dsots_01.mus","rb");
    if(f==NULL)
    {
      printf("Source file open error!\n");
      return;
    }
    fread(music, 1, 65535UL, f);
    fclose(f);
  }
  /* init music */
  /*
    Count Zero music:
    ;Sound = Startadresse Musik
    init    =   bsr sound+0
    play    =   bsr sound+6
    quit    =   bsr sound+0
    Mad Max music:
    ;Sound = Startadresse Musik
    init    =   bsr sound+0
    play    =   bsr sound+8
    quit    =   bsr sound+0
  */
  init_music=(void*)music;
  play_music=(void*)(music+8);
  while(kbhit())
  {
    ;
  }
  save_regs;
  init_music(3L); /* init music */
  restore_regs;
  { /* play music */
    unsigned long *p=(unsigned long*)0x4ba; /* 200 Hz timer */
    unsigned long t=*p;
    byte *q=sample;
    byte *r=(byte*)0xffff8800UL;
    long count=0;
    do
    {
      t+=4;
      while(*p<t)
      { /* wait 20 ms */
        ;
      }
      save_regs;
      play_music(); /* play music */
      restore_regs;
      printf("pos = %li  \r",count);
      count++;
      *r=0;
      *q++=*r;
      *r=1;
      *q++=*r;
      *r=2;
      *q++=*r;
      *r=3;
      *q++=*r;
      *r=4;
      *q++=*r;
      *r=5;
      *q++=*r;
      *r=6;
      *q++=*r;
      *r=7;
      *q++=*r;
      *r=8;
      *q++=*r;
      *r=9;
      *q++=*r;
      *r=10;
      *q++=*r;
      *r=11;
      *q++=*r;
      *r=12;
      *q++=*r;
      *r=13;
      *q++=*r;
    }
    while(!kbhit());
    printf("Lengte = %li, bytes = %li\n",count, count*14);
    {
    #if 01
      FILE *f=fopen(naam, "wb");
      if(f==NULL)
      {
        printf("File open error!\n");
        return;
      }
      fwrite(sample, q-sample,1,f);
      fclose(f);
    #endif
    }
  }
  init_music(0); /* exit music */
  printf("\007");
}

void help(void)
{
  printf(
  ", shorter\n"
  ". longer\n"
  "< one second shorter\n"
  "> one second longer\n"
  "r restart\n"
  "e last 2 seconds\n"
  "s save song with current length\n"
  "h help\n"
  "q end\n"
  );
}

void play_mus(void)
{
  long len;
  char key;
  {
    FILE *f=fopen(naam, "rb");
    if(f==NULL)
    {
      printf("File open error!\n");
      return;
    }
    len=fread(sample, 1, 512*1024UL, f);
    fclose(f);
  }
  len/=14;
  help();
  printf("Lengte = %li = %li s, bytes = %li\n", len, len/50, len*14);
  {
    unsigned long *p=(unsigned long*)0x4ba; /* 200 Hz timer */
    unsigned long t=*p;
    long maxlen=len;
    byte *q=sample;
    byte *r=(byte*)0xffff8800UL;
    byte *s=(byte*)0xffff8802UL;
    long count=0;
    do
    {
      if(kbhit())
      {
        key=getch();
      }
      else
      {
        key=0;
      }
      switch(key)
      {
        case '.': /* longer */
        if(len<maxlen)
        {
          len++;
          printf("Lengte = %li = %li s, bytes = %li\n", len, len/50, len*14);
        }
        break;
        case '>': /* 1s longer */
        len+=50;
        if(len>maxlen)
        {
          len=maxlen;
        }
        printf("Lengte = %li = %li s, bytes = %li\n", len, len/50, len*14);
        break;
        case ',': /* shorter */
        if(len>0)
        {
          len--;
          printf("Lengte = %li = %li s, bytes = %li\n", len, len/50, len*14);
        }
        break;
        case '<': /* 1s shorter */
        len-=50;
        if(len<0)
        {
          len=0;
        }
        printf("Lengte = %li = %li s, bytes = %li\n", len, len/50, len*14);
        break;
        case 'r': /* restart */
        count=0;
        q=sample;
        break;
        case 'e':
        count=len-100;
        if(count<0)
        {
          count=0;
        }
        q=sample+14*count;
        break;
        case 's':
        {
          FILE *f=fopen(naam, "wb");
          if(f==NULL)
          {
            printf("File open error!\n");
          }
          else
          {
            fwrite(sample, len*14,1,f);
            fclose(f);
            printf("Song saved as: %s.\n", naam);
          }
        }
        break;
        case 'h':
        help();
        break;
      }
      t+=4;
      while(*p<t)
      { /* wait 20 ms */
        ;
      }
      printf("pos = %li  \r",count);
      *r=0;
      *s=*q++;
      *r=1;
      *s=*q++;
      *r=2;
      *s=*q++;
      *r=3;
      *s=*q++;
      *r=4;
      *s=*q++;
      *r=5;
      *s=*q++;
      *r=6;
      *s=*q++;
      *r=7;
      *s=*q++;
      *r=8;
      *s=*q++;
      *r=9;
      *s=*q++;
      *r=10;
      *s=*q++;
      *r=11;
      *s=*q++;
      *r=12;
      *s=*q++;
      *r=13;
      *s=*q++;
      count++;
      if(count>=len)
      {
        count=0;
        q=sample;
      }
    }
    while(key!='q');
  }
  printf("\007");
}
