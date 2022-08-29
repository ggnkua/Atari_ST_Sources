/* Example program 2.9:    C-Program Produces Sea Shore noise */

#include <geminit.h>       
int i=1;

main()
{
 openwork();
 xbios(28,247,7+128);                  /* Noise generator to chan #1   */
 xbios(28,16,8+128);                   /* Set the noise  amplifier     */

 xbios(28,0,11+128);                   /* LowByte Enveloper            */
 xbios(28,60,12+128);                  /* HighByte Enveloper           */
 xbios(28,14,13+128);                  /* Select the Envelope          */
 
 xbios(28,0,6+128);                    /* Noise period set up          */
 printf("To terminate strike a key twice!\n");
 gemdos(8);                            /* Wait on the key strikes.     */

 xbios(28,0,8+128);                    /* Zero the Amplifier           */
 xbios(28,255,7+128);
 closework();
}

