/* Example program 2.14:         C-Program: Three voice, The 
                                  melody voice is played with 
                                  envelope generator.             */
#include <geminit.h>    /* Melody played over two toned chord     */    
                        /*               with enveloper.          */ 

int ton[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};
int i=0;

main()
{
 openwork();
 printf("\33E");
 xbios(28,248,7+128);              /* All sound channels on.          */
 xbios(28,12,8+128);               /* Channel 1 and 2 with fixed      */
 xbios(28,12,9+128);               /* amplifier settings.             */
 xbios(28,16,10+128);              /* Channel 3 amplified with        */ 
 xbios(28,0,11+128);               /* Envelope generator programing.  */      
 xbios(28,30,12+128);
 xbios(28,9,13+128);

 xbios(28,56,0+128);               /* Tone 1                              */
 xbios(28,2,1+128);
 xbios(28,123,2+128);              /* Tone 2                              */
 xbios(28,1,3+128);

 while(i!=16)                      /* Melody  loop                        */
 {
  xbios(28,ton[i],4+128);          /* Low Byte                            */
  xbios(28,ton[i+1],5+128);        /* High Byte                           */
  xbios(28,9,13+128);              /* Envelope                            */
  evnt_timer(200,0);               /* Wait                                */
  i+=2;
 }                                 /* End of the loop.                    */
  
 evnt_timer(1000,0);               /* After the last tone, wait 1 second. */

 xbios(28,0,8+128);                /* All amplifiers set to  0            */
 xbios(28,0,9+128);
 xbios(28,0,10+128); 
 printf("Press any key to return to the desktop!\n");
 gemdos(8);                        /* Wait for key entry  On keystroke,   */
closework();                       /*   return to the desktop             */
}

