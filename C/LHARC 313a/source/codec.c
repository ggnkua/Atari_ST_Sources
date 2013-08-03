/* @(#)codec.c, -dh- 23.05.1996
 * ausgelagerte Codier- und Decodier-Routinen aus lharc.c
 */

#include <stdio.h>
#include "lhaconst.h"
#include "lhatypes.h"

/* Importe aus decode5.s
 */
extern uint getbits(int);
extern int make_table(int,uchar*,int,ushort*);
extern void fillbuf(int);
extern void putbits(int,uint);
extern void send_block(void);

/* Importe aus util.s
 */
extern void count_len(int);

/* sonstwo ...
 */
#ifndef SFX
extern  int *dad;
#endif
extern uint bitbuf;
extern ushort *sortptr;
extern int bitcount;
extern uint subbitbuf;
extern uchar text_buf[];


ushort left[2*NC-1], right[2*NC-1];
uchar c_len[NC], pt_len[NPT], *len;
ushort c_freq[2*NC-1], c_code[NC], p_freq[2*NP-1], pt_table[256], pt_code[NPT], t_freq[2*NT-1];
ushort len_cnt[17];
int heap[NC+1];

int read_pt_len(int nn,int nbit,int i_special)
{
  register uchar *ptlen=pt_len;
  register int n;

  if ((n=getbits(nbit))==0)
  {
    register ushort *table=pt_table,c;

    for (n=nn,c=0;--n>=0;)
      *ptlen++=c;
    for (n=256,c=getbits(nbit);--n>=0;)
      *table++=c;
  }
  else
  {
    register int c,i=0;
    register uint mask,bibu;

    while (i<n)
    {
      bibu=bitbuf;
      if ((c=bibu>>13)==7)
      {
        mask=1U<<12;
        while (mask&bibu)
        {
          mask>>=1;
          c++;
        }
      }

      fillbuf((c<7) ? 3 : c-3);
      *ptlen++=c;

      i++;
      if (i==i_special)
      {
        i+=(c=getbits(2));
        mask=0;
        while (--c>=0)
          *ptlen++=mask;
      }
    }

    c=0;
    n=nn;
    while (i<n)
    {
      *ptlen++=c;
      i++;
    }

    if (!make_table(n,pt_len,8,pt_table))
      return(FAULT);
  }

  return(SUCCS);
}

int read_c_len(void)
{
  register uchar *clen=c_len;
  register int n, i;

  if ((n=getbits(CBIT))==0)
  {
    register ulong *daddy=(ulong *) dad,k;

    for (i=(NC>>1),k=0;--i>=0;*((int *) clen)++=(int) k);
    k=getbits(CBIT);
    k=(k<<16)|k;
    for (i=2048;--i>=0;*daddy++=k);
  }
  else
  {
    register ushort *pttable=pt_table;
    register uint mask,bibu;
    register int c;

    i=0;
    while (i<n)
    {
      bibu=bitbuf;
      c=pttable[bibu>>8];
      if (c>=NT)
      {
        mask=1U<<7;
        do
        {
          if (bibu&mask)
            c=right[c];
          else
            c=left[c];
          mask>>=1;
        } while (c>=NT);
      }

      fillbuf(pt_len[c]);
      if (c>2)
      {
        *clen++=(c-2);
        i++;
      }
      else if (c)
      {
        if (--c==0)
          c=getbits(4)+3;
        else
          c=getbits(CBIT)+20;
        i+=c;
        mask=0;
        while (--c>=0)
          *clen++=mask;
      }
      else
      {
        *clen++=c;
        i++;
      }
    }

    mask=0;
    bibu=NC;
    while (i<bibu)
    {
      *clen++=mask;
      i++;
    }

    if (!make_table(NC,c_len,12,(ushort *) dad))
      return(FAULT);
  }

  return(SUCCS);
}

void write_pt_len(register int n,int nbit,register int i_special)
{
  register uchar *ptlen;
  register int i, k, c=3;

  ptlen=&pt_len[n];
  while (*--ptlen==0 && --n>=0);

  putbits(nbit,n);

  i=0;
  ptlen=pt_len;
  while (i<n)
  {
    i++;
    if ((k=*ptlen++)<=6)
      putbits(3,k);
    else
    {
      k-=c;
      putbits(k,(1U<<k)-2);
    }

    if (i==i_special)
    {
      while (i<6 && *ptlen==0)
      {
        ptlen++;
        i++;
      }

      putbits(2,(i-c) & c);
    }
  }
}

void write_c_len(void)
{
  register int i, k, n;
  register uchar l0=pt_len[0], *clen;
  register ushort c0=pt_code[0], c1=pt_code[1];

  clen=&c_len[n=NC];
  while (*--clen==0 && --n>=0);

  putbits(CBIT,n);

  i=0;
  clen=c_len;
  while (i<n)
  {
    i++;
    if ((k=*clen++)==0)
    {
      k=1;
      while (i<n && *clen==0)
      {
        clen++;
        k++;
        i++;
      }

      switch (k)
      {
        case 2:
          putbits(l0,c0);
        case 1:
          putbits(l0,c0);
          break;
        case 19:
          putbits(l0,c0);
          putbits(pt_len[1],c1);
          putbits(4,15);
          break;
        default:
          if (k<=18)
          {
            putbits(pt_len[1],c1);
            putbits(4,k-3);
          }
          else
          {
            putbits(pt_len[2],pt_code[2]);
            putbits(CBIT,k-20);
          }
      }
    }
    else
      putbits(pt_len[k+2],pt_code[k+2]);
  }
}

void make_len(int root)
{
  register int i, k;
  register uint cum=0;
  register ushort *lencnt=len_cnt, *spt=sortptr;

  for (i=17;--i>=0;)
    *lencnt++=cum;

  count_len(root);
  for (i=17,k=0,lencnt=&len_cnt[17];--i>=0;)
    cum+=(*--lencnt)<<(k++);

  while (cum!=(1U<<16))
  {
    len_cnt[16]--;

    for (i=17,lencnt=&len_cnt[17];--i>=0;)
      if (*--lencnt)
      {
        lencnt[0]--;
        lencnt[1]+=2;
        break;
      }
    cum--;
  }

  for (i=17,lencnt=&len_cnt[17];--i>=0;)
  {
    k=*--lencnt;
    while (--k>=0)
      len[*spt++]=i;
  }

  sortptr=spt;
}

void start_huf(void)
{
  register ushort *p, v=0;
  register int i;

  text_buf[0]=v;
  for (i=NC,p=c_freq;--i>=0;)
    *p++=v;

  for (i=NP,p=p_freq; --i>=0;)
    *p++=v;

  subbitbuf=v;
  bitcount=CHAR_BIT;
}

void end_huf(void)
{
  send_block();
  putbits(CHAR_BIT-1,0);
}

void count_t_freq(void)
{
  register int i, k, n;
  register ushort *tfreq, tf0, tf1;
  register uchar *clen;

  for (i=NT,tfreq=t_freq,k=0;--i>=0;)
    *tfreq++=k;

  clen=&c_len[n=NC];
  while (*--clen==0 && --n>=0);

  i=tf0=tf1=0;
  clen=c_len;
  tfreq=t_freq;

  while (i<n)
  {
    i++;
    if ((k=*clen++)==0)
    {
      k=1;
      while (i<n && *clen==0)
      {
        clen++;
        k++;
        i++;
      }

      if (k<=2)
        tf0+=k;
      else if (k<=18)
        tf1++;
      else if (k==19)
      {
        tf0++;
        tf1++;
      }
      else
        tfreq[2]++;
    }
    else
      tfreq[k+2]++;
  }

  tfreq[0]+=tf0;
  tfreq[1]+=tf1;
}

