/* Example Program 2.5:  C-Program that plays the Tone 'a1' with envelope*/

#include <geminit.h>
int i=1;

main()
{
openwork();
while(i!=12)                  /* Establish a loop to play the tone 10 times */
 {
  xbios(28,254,7+128);        /* Set Chan 1 pitch freq , a1 = 440 Hz     */
  xbios(28,16,8+128);         /* Amplifier register for channel 1 to 16  */

  xbios(28,0,11+128);         /* LowByte of the enveloper period         */
  xbios(28,i,12+128);         /* HighByte of the enveloper period        */
  xbios(28,9,13+128);         /* Use envelope #  9                       */
  
  xbios(28,28,0+128);         /* Play the tone                           */
  xbios(28,1,1+128);

  evnt_timer(500,0);         /* Wait a half second or so                     */
  i++;                        /*                     Index increment     */
 }                            /*                       End of the loop   */
 xbios(28,0,8+128);           
 xbios(28,255,7+128);
 printf("Thats all Folks!\n");
 closework();
} 

