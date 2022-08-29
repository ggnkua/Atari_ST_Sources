/* Sample program 2.1:   C-Programm Plays the Tone A = 440 Hz  */

#include <geminit.h>            /* GEM environment Set-up      */            

main()                          /* Main program start-up       */

{
 openwork();                    /* Clear the screen             */
                                /* Load the registers of the    */
                                /* Sound chip                   */
 xbios(28,254,7+128);           /* Only turn on channel #1      */              
 xbios(28,15,8+128);            /* Set the amplifier to Maximum */
 xbios(28,28,0+128);            /* Low Byte and                 */
 xbios(28,1,1+128);             /* High Byte of the Tone        */
 evnt_timer(1000,0);            /* Wait for one second, then    */
 xbios(28,255,7+128);           /* Turn channel #1 off          */

 printf("That was the main A. Please hit any key!\n");
 gemdos(8);                     /* Wait for a key strike        */

 closework();                   /* Return to the Desk           */
}                               /*  Top on the key (RETURN)     */

