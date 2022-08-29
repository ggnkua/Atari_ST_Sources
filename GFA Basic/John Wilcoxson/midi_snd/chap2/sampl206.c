/* Example Program 2.6:     C-Programm play a tone with different envelopes*/

#include <geminit.h>  
int i=0;

main()
{
 openwork();
 while(i<=16)
 {
 xbios(28,254,7+128);                    /* Only use Chan 1            */
 xbios(28,16,8+128);                     /* Amplifier 1 set to 16,     */
                                         /*  with enveloper            */

 xbios(28,0,11+128);                     /* LowByte Envelope period    */
 xbios(28,5,12+128);                     /* HighByte Envelope period   */
 xbios(28,i,13+128);                     /* Select the envelope type   */
                                         /*  using the loop index count*/

 xbios(28,238,0+128);                    /* LowByte of the pitch       */
 xbios(28,0,1+128);                      /* HighByte of the pitch      */
 evnt_timer(500,0);                      /* Half'a second delay        */

 i++;                                    /* Increment the loop index   */
 }
 xbios(28,0,8+128);
 xbios(28,255,7+128);
 printf("Thats all Folks!\n");
 closework();
}

