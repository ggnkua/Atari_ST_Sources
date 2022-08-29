
/* Example program 2.3:     C-Programm plays a C Major Scale*/


#include <geminit.h>                     /* GEM environment setup */

int ton[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};

 /* The table Ton contains the note values for the scale.   */

int i=0;                          /* index parameter for the main loop */

main()                                    /* Start of the Main program */
{
 openwork();                                  
 while(i!=16)                                            /* Main  LOOP */ 
 {
  xbios(28,254,7+128);                             /* Sound chip setup */
  xbios(28,15,8+128);
  xbios(28,ton[i],0+128);                   /* Here the note values    */        
  xbios(28,ton[i+1],1+128);                 /* are read from the array */   
  evnt_timer(500,0);                     /* Wait for half a second     */
  i+=2;           /* Increment the loop index by two for high and low  */
 }                                             /* End of the main loop */
 xbios(28,255,7+128);                    /* The rest is well known     */               
 printf("Ende");
 closework();
}

