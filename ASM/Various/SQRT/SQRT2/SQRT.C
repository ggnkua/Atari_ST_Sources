#include <math.h>
#include <stdio.h>
#include <time.h>

#define TEST_RANGE 100000L

long sqrt_earx(unsigned long i);
long sqrt_nyh0(unsigned long i);
long sqrt_nyh1(unsigned long i);
long sqrt_tobe(unsigned long i);
long sqrt_strt(unsigned long i);
unsigned long wortel(unsigned long value);
unsigned long sqrt_newton(unsigned long x);
unsigned long sqrt_newtonf(unsigned long x);

int main(void)
{
  long start=0;
  unsigned long i;
  
  /* sanity test */
  
  for(i=0;i<10;i++)
  {
    printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"        
           , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  }
  i=37;                                                                                                                                                    
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=128;                                                                                                                                                   
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=1023;                                                                                                                                                 
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=10234567L;                                                                                                                                            
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0xfffffffL;                                                                                                                                           
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0x7fffffffL;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0x12345678L;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0x77654321L;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0x87654321UL;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0xabcdef01UL;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0xfbcdef01UL;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));
  i=0xffffffffUL;                                                                                                                                          
  printf("sqrt(%10li) = %5li strt, %5li earx, %5li nyh1, %5li tobe, %7.0f mlib\n"
         , i, sqrt_strt(i), sqrt_earx(i), sqrt_nyh1(i), sqrt_tobe(i), sqrt((double)i));

#if 0
  {
    FILE* f;
    if((f=fopen("sqrt_res.txt","w"))==NULL)
    {
      printf("File open error!\n");
      return -1;
    }
    start = clock();
    i=0x0UL;
    do
    {
      long res=sqrt_strt(i);
      long res2=sqrt_nyh1(i);
      if((res!=res2) && (res!=res2+1))
      {
        printf("sqrt(%lX) = %lX strt, %lX math\n",i, res,res2);
        fprintf(f,"sqrt(%lX) = %lX strt, %lX math\n",i, res,res2);

      }
      i++;
    }
    while(i!=0);
    printf("Time used for sqrt strt: %lf sec.\n",
           ((float)((clock()-start))/(float)CLK_TCK));
    fprintf(f,"Time used for sqrt strt: %lf sec.\n",
           ((float)((clock()-start))/(float)CLK_TCK));
    fclose(f);
  }
#endif

#if 1
  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_strt(i);
  }
  printf("Time used for sqrt strt: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_earx(i);
  }
  printf("Time used for sqrt earx: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_nyh1(i);
  }
  printf("Time used for sqrt nyh1: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_tobe(i);
  }
  printf("Time used for sqrt tobe: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));


  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt((double)i);
  }
  printf("Time used for sqrt flib: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    wortel(i);
  }
  printf("Time used for sqrt wortel: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_newton(i);
  }
  printf("Time used for sqrt newton: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));

  start = clock();
  for(i=0;i<TEST_RANGE;i++)
  {
    sqrt_newtonf(i);
  }
  printf("Time used for sqrt newtonf: %lf sec.\n",
         ((float)((clock()-start))/(float)CLK_TCK));
#endif
  return 0;
}

unsigned long wortel(unsigned long value)
{
  unsigned long mask=1UL<<(sizeof(unsigned long) * 8-2); /* mask 2^30 */
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
