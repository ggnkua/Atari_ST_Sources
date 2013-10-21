#include <stdio.h>
#include <limits.h>

unsigned long wortel(unsigned long value);
unsigned long sqrt_newton(unsigned long x);
unsigned long sqrt_newtonf(unsigned long x);


int main(void)
{
  unsigned long i;
#if 0
  for(i=0;i<0xffffffffUL;i++)
  {
    sqrt_newtonf(i);
  }
#else
  {
    long res0;
    long res1;
    for(i=0;i<0xffffffff;i++)
    {
      res0=wortel(i);
      res1=sqrt_newtonf(i);
      if((res0!=res1) && (res0+1!=res1))
      {
        printf("sqrt(%lx) = %lx (bits), %lx (newton)\n",i,res0,res1);
      }
      if((i&0xffffff)==0)
      {
        printf("%lx\n",i);
      }
    }
  }
#endif
  return 0;
}

unsigned long wortel(unsigned long value)
{
  unsigned long mask=1UL<<(sizeof(unsigned long) * CHAR_BIT-2); /* mask 2^30 */
  unsigned long result=0;

  do
  {
    unsigned long tmp=result+mask;
    result>>=1;
    if(value>=tmp)
    {
      value-=tmp;
      result+=mask;
    }
  }
  while((mask>>=2)!=0);
  return result;
}

unsigned long sqrt_newton(unsigned long x)
{
  int i=0;
  unsigned long tmp;
  
  if(x<2)
  {
    return x;
  }
  tmp=x;
  do
  {
    i++;
    tmp>>=2;
  }
  while(tmp!=0);
  tmp=1<<i;    /* order 0 */
  tmp+=x/tmp;
  tmp>>=1;     /* order 1 */
  tmp+=x/tmp;
  tmp>>=1;     /* order 2 */
  tmp+=x/tmp;
  tmp>>=1;     /* order 3 */
  tmp+=x/tmp;
  return tmp>>=1;     /* order 4 */
}

unsigned char sqrt_tab[]={
  0,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,
  4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,
  5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,
  6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
  9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,
  10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,
  11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,
  12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,
  12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,
  13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,
  13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,
  14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
  14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
  15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
};

unsigned long sqrt_newtonf(unsigned long x)
{
  int i;
  unsigned long tmp;
  
  if(x<0x100)
  {
    return (unsigned long)sqrt_tab[x];
  }
  i=0;
  tmp=x;
  do
  {
    i++;
    tmp>>=2;
  }
  while(tmp>0xff);
  tmp=(unsigned long)sqrt_tab[tmp];
  tmp<<=i;    /* order 0 */
  tmp+=x/tmp;
  tmp>>=1;     /* order 1 */
  tmp+=x/tmp;
  return tmp>>=1;     /* order 2 */
}
