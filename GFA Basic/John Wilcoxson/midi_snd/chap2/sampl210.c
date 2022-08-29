/* Sample program 2.10:   C-Program generates a rim-shot and a tone*/

#include <geminit.h>       
int i=0;

main()                            /* Start the main program    */
{
 openwork();
 while(i!=10)                     /* LOOP, call the Sound Function */
 {                                /* ten times.                    */
  sound();                        /* sound() routine execute       */
  evnt_timer(250,0);              /* and wait 1/4 sec              */
  i++;                            /* Increment the index           */
 }                                /* End LOOP                      */
 printf("Done.\n ");
 printf("To return to the desktop, strike any key!\n");
 gemdos(8);                       /* Wait for a key stroke!        */
 closework();
}

sound()                           /* Function Sound()               */
{
 xbios(28,246,7+128);             /* Noise and Sound register 1 on  */
 xbios(28,16,8+128);              /* Access to the Enveloper        */

 xbios(28,0,11+128);              /* Program the enveloper.         */
 xbios(28,15,12+128);
 xbios(28,0,13+128);

 xbios(28,238,0+128);             /* Play the tone                  */
 xbios(28,0,1+128);  
 xbios(28,0,6+128);               /* Period for noise generator     */
}

