/* Example program 2.13:   C-Program: Three voice tune, a Melody thread 
                            plus intersperced doublets.  
 */
#include <geminit.h>     
int ton[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};
int i=0;                       /* List 'ton' is indexed by integer 'i' */

main()
{
 openwork();
 printf("\33E");
 xbios(28,248,7+128);           /* All three channels turned on    */
 xbios(28,12,8+128);            /* w/ amplifiers set the same,     */
 xbios(28,12,9+128);            /* but without the envelope gener. */
 xbios(28,12,10+128);

 xbios(28,56,0+128);            /* Tone 1 remains the same         */
 xbios(28,2,1+128);       
 xbios(28,123,2+128);           /* Tone 2 remains the same         */
 xbios(28,1,3+128);

 while(i!=16)                   /* Loop; this plays the melody     */
 {                              /* over the two fixed tones.       */
  xbios(28,ton[i],4+128);       /* The melody is read out of       */
  xbios(28,ton[i+1],5+128);     /* the list 'ton()'.              */ 
  evnt_timer(200,0);            /* Wait between the notes of the   */ 
  i+=2;                         /* melody.                         */
 }                              /* End of the melody loop.         */ 
  
 evnt_timer(1000,0);            /* Wait 1 second after the last note.*/ 

 xbios(28,0,8+128);             /* All of the amplifiers are set   */
 xbios(28,0,9+128);             /* to amplitude level 0.           */
 xbios(28,0,10+128); 
 printf("Press any key to return to desktop!\n");
 gemdos(8);                     /* wait for next key entry         */
closework();                    /* And return to the desktop on    */
}                               /* nezt key stroke.                */

