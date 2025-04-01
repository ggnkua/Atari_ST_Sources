#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#define ADR1 0x00fc0000L      /* Adresse, LÑnge fÅr ST-ROM. */
#define LG1  (192*1024L)
#define ADR2 0x00e00000L      /* Adresse, LÑnge fÅr STE-ROM.*/
#define LG2  (256*1024L)

static char buffer[LG2];      /* Zwischenpuffers fÅrs ROM.  */

static void read_tos(char *ptr,long size)
{
   long i;
   for (i=0; i<size; i++)
      buffer[i] = ptr[i];
}

static void buf_out(long size)
{
   static char filename[] = "ROM.OS";
   int  handle;
   long lwr = 0L;

   handle = (int)Fcreate(filename,0);	
   if (handle>0)
   {
      lwr = Fwrite(handle,size,buffer);
      Fclose(handle); 
   }
   if (lwr!=size)
      printf("Schreibfehler!\n");
   else
      printf("ROM.OS erzeugt.\n");
   return;
}

int main()
{
   char ch;
   printf("ROM.OS Generator\n");
   printf("Welches ROM?  ( 1: ST-ROM 192 KBytes  )\n");
   printf("              ( 2: STE-ROM 256 KBytes )\n");
   ch = bios(2,2);
   if (ch=='1') 
   {
      printf("ST-ROM: \n");
      read_tos((char *) ADR1,LG1);
      buf_out(LG1);
   }
   else if (ch=='2')
   {
       printf("STE-ROM:\n");
       read_tos((char *) ADR2,LG2);
       buf_out(LG2);
   }
   else
       printf("Nichts getan!\n");
   printf("Return drÅcken!\n");
   do
      ch = bios(2,2); 
   while (ch!=13);
   return(0);
}