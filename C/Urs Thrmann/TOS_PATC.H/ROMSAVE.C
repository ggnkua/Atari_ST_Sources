/* ROMSAVE.C 
   utility for copying the TOS-ROM to file TOS.IMG
   2.3.1989 by Urs ThÅrmann/SH 
*/

#include <osbind.h>

#define ROM (char *)0xFC0000L
#define SIZE (long)(192 * 1024)

int main()
{  
   int fh;
   long index, stack;
   char *adr=ROM, *buf, *buf_start;

   stack = Super(0L);

   buf= buf_start=(char*)Malloc(SIZE);
   if (buf< (char*)-1)
      return(-1);
   Cconws("Ich lese die Daten ein...\n");
   for (index=0; index<SIZE; index++)
      *buf++ = *adr++;

   Super(stack);

   if ((fh = Fcreate("tos.img",0)) <0)
   {
      Cconws("Datei konnte nicht erzeugt werden\r\n");
      return(-2);
   }
   Cconws("Ich schreibe die Daten auf Disk...\n");
   Fwrite(fh, SIZE,buf_start);
   Fclose(fh);

   Mfree(buf_start);
   return(0);
}

