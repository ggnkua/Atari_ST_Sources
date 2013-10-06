#include "osbind.h"
#include "f:\dspspar\rev21\tsr\dspbind.h"

long buffer;
char ch;
long gl_val;
long value;
long counter;

receiver(val)
long val;
{
  gl_val = val;
}

long transmitter()
{
   counter += 10;
   return(counter);
}
main()
{
   buffer = Malloc(5000L);
   Dsp_LoadProg("divdelay.lod",3,buffer);
   Dsp_SetVectors(receiver,transmitter);
   value = 2;
   counter = 0;
   printf(" All I/O being done through interrupts\n");
   while(ch != 'q')
   {
      printf("Global value = %D\n",gl_val);
      ch = Bconin(2);
   }
   Dsp_RemoveInterrupts(3);
}


