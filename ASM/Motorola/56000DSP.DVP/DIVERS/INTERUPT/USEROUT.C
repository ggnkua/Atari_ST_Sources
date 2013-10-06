#include "osbind.h"
#include "f:\dspspar\rev21\tsr\dspbind.h"

#define BUFSIZE	(4L*1000L)

long buffer;
char ch;
long gl_val;
long value;

receiver(val)
long val;
{
  gl_val = val;
}

main()
{
   buffer = Malloc(5000L);
   Dsp_LoadProg("divby2.lod",3,buffer);
   Dsp_SetVectors(receiver,0L);
   value = 2;
   while(ch != 'q')
   {
      printf("Sending value\n");
      Dsp_BlkUnpacked(&value,1L,0L,0L);
      printf("Global value = %D\n",gl_val);
      value += 2;
      ch = Bconin(2);
   }
   Dsp_RemoveInterrupts(1);
}


