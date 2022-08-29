/* Sample program  2.12:     C-Program to play a doublet */
 
#include <geminit.h>   

main()
{
 openwork();
 xbios(28,252,7+128);               /* Turn on channels 1 & 2 */
 xbios(28,15,8+128);                /* Amplifier set to maximum, but */
 xbios(28,15,9+128);                /* do not use the  enveloper.    */
 
 xbios(28,221,0+128);               /* Here is Tone 1       Low Byte */
 xbios(28,1,1+128);                 /*                 and High Byte */
 xbios(28,123,2+128);               /* and here Tone 2      Low Byte */
 xbios(28,1,3+128);                 /*                 and High Byte */

 evnt_timer(3000,0);                /* 2 Second wait.                */

 xbios(28,0,8+128);                 /* Set amplifiers for channel    */
 xbios(28,0,9+128);                 /*  1 & 2 to 0.                  */
 printf("That was C and E. \n Hit any key to return.!\n");
 gemdos(8);                         /* Wait for a key stroke.        */
 closework();                       /* Mit Tastendruck zum Desktop   */
}

