/* Example program 2.17: C-Program: Plays the melody in Interrupt mode. */
 
#include <geminit.h>
#define Dosound(a) xbios(32,a)   /* This is the XBIOS-Routine that writes
                                      to the sound chip while an 
                                      interrupt is being processed.     */

char snd[] = { 0,0,1,0, 2,0,3,0, 4,0,5,0, 8,16,9,16,10,0, 11,0,12,64, 13,9, 
                    7,252,255,1,
2,238,
               0,222,1,1,13,9,255,60,
2,0,
               0,170,13,9,255,20,
2,253,
               0,123,13,9,255,40,
2,0,
               0,170,13,9,255,40,
2,28,3,1,
               0,102,13,9,255,40, 
2,0,3,0,
               0,123,13,9,255,40,
2,62,3,1,
               0,170,13,9,255,20,

               0,250,13,9,255,20,
2,238,3,0,
               0,222,13,10,255,60,
                    7,255,255,0 };
int i=0;

main()
{
 openwork();
 printf("\33E");  
 Dosound(snd);
 while(i!=25)
 {
  printf("This print out is interrupting the sound generator!\n");
  evnt_timer(200,0);
  i++;
 }
 printf("End of output, strike any key to return to desktop!\n");
 gemdos(8);                     /* wait for next key entry         */
 closework();
}

