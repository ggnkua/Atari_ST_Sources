/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"
#include "proto.h"

void nextpacket(void);
UINT32 getbyte(void);
static UINT32 getword(void);
static UINT32 getlong(void);


/* initialize buffer, call once before first getbits or showbits */

void initbits()
{
  ld_incnt = 0;
  ld_rdptr = ld_rdbfr + 8192;
  ld_rdmax = ld_rdptr;
  ld_bitcnt = 0;
  ld_bfr = 0;
  flushbits(0); /* fills valid data into bfr */
}

void fillbfr()
{
  INT32 l;

  l = read(ld_infile,ld_rdbfr,8192l);
  ld_rdptr = ld_rdbfr;
  if (sysstream)
    ld_rdmax -= 8192;
  if (l<8192)
  {
    if (l<0)
      l = 0;

    while (l & 3)
      ld_rdbfr[l++] = 0;

    while (l<8192)
    {
      ld_rdbfr[l++] = SEQ_END_CODE>>24;
      ld_rdbfr[l++] = SEQ_END_CODE>>16;
      ld_rdbfr[l++] = SEQ_END_CODE>>8;
      ld_rdbfr[l++] = SEQ_END_CODE&0xff;
    }
  }
}


/* MPEG-1 system layer demultiplexer */

UINT32 getbyte()
{
  while(ld_rdptr >= ld_rdbfr+8192)
  {
    read(ld_infile,ld_rdbfr,8192);
    ld_rdptr -= 8192;
    ld_rdmax -= 8192;
  }
  return ((UINT32) *ld_rdptr++);
}

static UINT32 getword()
{
  UINT32 i;

  i = getbyte();
  i <<= 8;
  i |= getbyte();
  return i;
}

static UINT32 getlong()
{
  UINT32 i;

  i = getbyte();
  i <<= 8;
  i |= getbyte();
  i <<= 8;
  i |= getbyte();
  i <<= 8;
  i |= getbyte();
  
  return i;
}

/* parse system layer, ignore everything we don't need */

void nextpacket()
{
  UINT32 code;
  INT32 l;

  for(;;)
  {
    code = getlong();
    switch(code)
    {
    case PACK_START_CODE: /* pack header */
      /* skip pack header (system_clock_reference and mux_rate) */
      ld_rdptr += 8;
      break;
    case 0x1e0: /* video stream 0 packet */
      code = getword(); /* packet length */
      ld_rdmax = ld_rdptr + code;

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
        ld_rdptr++;
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
        ld_rdptr += 9;
      }
      else if(code>=0x20)
      {
        /* skip presentation time stamps */
        ld_rdptr += 4;
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
      while (l<8192)
      {
        ld_rdbfr[l++] = SEQ_END_CODE>>24;
        ld_rdbfr[l++] = SEQ_END_CODE>>16;
        ld_rdbfr[l++] = SEQ_END_CODE>>8;
        ld_rdbfr[l++] = SEQ_END_CODE&0xff;
      }
      ld_rdptr = ld_rdbfr;
      ld_rdmax = ld_rdbfr + 8192;
      return;
      
    default:
      if(code>=SYSTEM_START_CODE)
      {
        /* skip system headers and non-video packets*/
        code = getword();
        ld_rdptr += code;
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


/* return next n bits (right adjusted) without advancing */

UINT32 showbits(n)
INT32 n;
{
  return (ld_bfr >> (32-n));
}


/* return next bit (could be made faster than getbits(1)) */

UINT32 getbits1()
{
  return getbits(1);
}


/* advance by n bits */

void flushbits(n)
INT32 n;
{
  INT32 incnt;

  ld_bfr <<= n;

  incnt = ld_incnt -= n;

  if (incnt <= 24)
  {
    if (sysstream && (ld_rdptr >= ld_rdmax-4))
    {
      do
      {
        if (ld_rdptr >= ld_rdmax)
          nextpacket();
        ld_bfr |= (UINT32) getbyte() << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    else if (ld_rdptr < ld_rdbfr+8192-4)
    {
      do
      {
        ld_bfr |= (UINT32) *ld_rdptr++ << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    else
    {
      do
      {
        if (ld_rdptr >= ld_rdbfr+8192)
          fillbfr();
        ld_bfr |= (UINT32) *ld_rdptr++ << (24 - incnt);
        incnt += 8;
      }
      while (incnt <= 24);
    }
    ld_incnt = incnt;
  }
}

/* return next n bits (right adjusted) */

UINT32 getbits(n)
INT32 n;
{
  UINT32 l;

  l =  (ld_bfr >> (32-n));
  flushbits(n);

  return l;
}
