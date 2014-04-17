#include "osbind.h"
#include "f:\dspspar\rev21\tsr\dspbind.h"

int dummy;
long outl;
int  outi;
char outc;

long i;
int  j;
char k;
long buffer;
main()
{
   buffer = Malloc(5000L);
   printf(" This program sends 5 numbers from 10 - 18 to the DSP to be\n");
   printf(" divided in half.  Expected output = 5,6,7,8,9\n\n");

   Dsp_LoadProg("divby2.lod",3,buffer);
   
   printf("Send/receive unpacked longs\n");
   for(i = 10; i < 20;i+=2)
   {
     Dsp_BlkUnpacked(&i,1L,&outl,1L);
     printf("output = %D\n",outl);
   }
   Bconin(2);

   printf("Send/receive unpacked signed words\n");
   for(j = 10; j < 20;j+=2)
   {
     Dsp_BlkWords(&j,1L,&outi,1L);
     printf("output = %d\n",outi);
   }
   Bconin(2);

   printf("Send/receive unpacked unsigned chars\n");
   for(k = 10; k < 20;k+=2)
   {
     Dsp_BlkBytes(&k,1L,&outc,1L);
     printf("output = %d\n",outc);
   }
   Bconin(2);

}
