/* getbits.c, bit level routines                                            */

#include <stdio.h>
#include <stdlib.h>

#include "config.h"
#include "global.h"

void nextpacket(void);
int getbyte(void);
static int getword(void);
static int getlong(void);

/* initialize buffer, call once before first getbits or showbits */

void initbits()
{
  ld->incnt = 0;
  ld->rdptr = ld->rdbfr + 2048;
  ld->rdmax = ld->rdptr;
  ld->bitcnt = 0;
  ld->bfr = 0;
  flushbits(0); /* fills valid data into bfr */
}

void fillbfr()
{
  int l;

  l = read(ld->infile,ld->rdbfr,2048);
  ld->rdptr = ld->rdbfr;

  if (sysstream)
    ld->rdmax -= 2048;

  if (l<2048)
  {
    if (l<0)
      l = 0;

    while (l & 3)
      ld->rdbfr[l++] = 0;

    while (l<2048)
    {
      ld->rdbfr[l++] = SEQ_END_CODE>>24;
      ld->rdbfr[l++] = SEQ_END_CODE>>16;
      ld->rdbfr[l++] = SEQ_END_CODE>>8;
      ld->rdbfr[l++] = SEQ_END_CODE&0xff;
    }
  }
}


/* MPEG-1 system layer demultiplexer */

int getbyte()
{
  while(ld->rdptr >= ld->rdbfr+2048)
  {
    read(ld->infile,ld->rdbfr,2048);
    ld->rdptr -= 2048;
    ld->rdmax -= 2048;
  }
  return *ld->rdptr++;
}

static int getword()
{
  int i;

  i = getbyte();
  return (i<<8) | getbyte();
}

static int getlong()
{
  int i;

  i = getword();
  return (i<<16) | getword();
}

/* parse system layer, ignore everything we don't need */

void nextpacket()
{
  unsigned int code;
  int l;

  for(;;)
  {
    code = getlong();
    switch(code)
    {
    case PACK_START_CODE: /* pack header */
      /* skip pack header (system_clock_reference and mux_rate) */
      ld->rdptr += 8;
      break;
    case 0x1e0: /* video stream 0 packet */
      code = getword(); /* packet length */
      ld->rdmax = ld->rdptr + code;

      /* parse packet header */
      while((code=getbyte()) == 0xff)
        ; /* stuffing bytes */
      if(code>=0x40)
      {
        if(code>=0x80)
        {
          fprintf(stderr,"Error in packet header\n");
          exit(1);
        }
        /* skip STD_buffer_scale */
        ld->rdptr++;
        code = getbyte();
      }

      if(code>=0x30)
      {
        if(code>=0x40)
        {
          fprintf(stderr,"Error in packet header\n");
          exit(1);
        }
        /* skip presentation and decoding time stamps */
        ld->rdptr += 9;
      }
      else if(code>=0x20)
      {
        /* skip presentation time stamps */
        ld->rdptr += 4;
      }
      else if(code!=0x0f)
      {
        fprintf(stderr,"Error in packet header\n");
        exit(1);
      }
      return;
    case ISO_END_CODE: /* end */
      /* simulate a buffer full of sequence end codes */
      l = 0;
      while (l<2048)
      {
        ld->rdbfr[l++] = SEQ_END_CODE>>24;
        ld->rdbfr[l++] = SEQ_END_CODE>>16;
        ld->rdbfr[l++] = SEQ_END_CODE>>8;
        ld->rdbfr[l++] = SEQ_END_CODE&0xff;
      }
      ld->rdptr = ld->rdbfr;
      ld->rdmax = ld->rdbfr + 2048;
      return;
    default:
      if(code>=SYSTEM_START_CODE)
      {
        /* skip system headers and non-video packets*/
        code = getword();
        ld->rdptr += code;
      }
      else
      {
        fprintf(stderr,"Unexpected startcode %08x in system layer\n",code);
        exit(1);
      }
      break;
    }
  }
}

/* advance by n bits */

void flushbits(n)
int n;
{
  int incnt;

  ld->bfr <<= n;

  incnt = ld->incnt -= n;

  if (incnt <= 24)
  {
    if (sysstream && (ld->rdptr >= ld->rdmax-4))
    {
      do
      {
        if (ld->rdptr >= ld->rdmax)
          nextpacket();
        ld->bfr |= getbyte() << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    else if (ld->rdptr < ld->rdbfr+2044)
    {
      do
      {
        ld->bfr |= *ld->rdptr++ << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    else
    {
      do
      {
        if (ld->rdptr >= ld->rdbfr+2048)
          fillbfr();
        ld->bfr |= *ld->rdptr++ << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    ld->incnt = incnt;
  }
}

void flushbits32()
{
  int incnt;

  ld->bfr = 0;

  incnt = ld->incnt;
  incnt -= 32;

  if (sysstream && (ld->rdptr >= ld->rdmax-4))
  {
    while (incnt <= 24)
    {
      if (ld->rdptr >= ld->rdmax)
        nextpacket();
      ld->bfr |= getbyte() << (24 - incnt);
      incnt += 8;
    }
  }
  else
  {
    while (incnt <= 24)
    {
      if (ld->rdptr >= ld->rdbfr+2048)
        fillbfr();
      ld->bfr |= *ld->rdptr++ << (24 - incnt);
      incnt += 8;
    }
  }
  ld->incnt = incnt;
}


/* return next n bits (right adjusted) */

unsigned int getbits(n)
int n;
{
  unsigned int l;

  l = showbits(n);
  flushbits(n);

  return l;
}

unsigned int getbits32()
{
  unsigned int l;

  l = showbits(32);
  flushbits32();

  return l;
}
