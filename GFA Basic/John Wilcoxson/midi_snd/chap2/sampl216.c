/*
Example program 2.16:    C-Program:Three shaped (enveloper) voices with 
                                    pauses in two of the voices.
*/
#include <geminit.h>   /* Multi voice demo; 3 enveloped voices, two tone */
                       /* chord with the melody in the 3rd voice.        */    
                       /* All amplifiers are controlled by the Enveloper */
                       /* Voice 1+2 only on the 1st. and 5th Notes.      */

int ton1[16] = {56,2,0,0,0,0,0,0, 56,2,0,0,0,0,0,0};        /* Voice 1   */
int ton2[16] = {123,1,0,0,0,0,0,0, 123,1,0,0,0,0,0,0};
int ton3[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};
int i=0;

main()
{
 openwork();
 printf("\33E");
 xbios(28,248,7+128);  /* The familiar entry, turn everything on!        */
 xbios(28,16,8+128);
 xbios(28,16,9+128);
 xbios(28,16,10+128);
 xbios(28,0,11+128);
 xbios(28,30,12+128);
 xbios(28,9,13+128);

 while(i!=16)          /* This time all three voices are controlled in    */
                       /* the loop, each voice has its own list of notes  */
 {
 xbios(28,ton1[i],0+128);         /* Voice  1                             */
 xbios(28,ton1[i+1],1+128);
 xbios(28,ton2[i],2+128);         /* Voice  2                             */
 xbios(28,ton2[i+1],3+128);
 xbios(28,ton3[i],4+128);         /* Voice  3                             */
 xbios(28,ton3[i+1],5+128);
 xbios(28,9,13+128);              /* Enveloper for everybody.             */
  evnt_timer(200,0);
  i+=2;
 }                                /* End loop.                            */
  
 xbios(28,0,8+128);               /* The ever present closing!            */    
 xbios(28,0,9+128);
 xbios(28,0,10+128); 
 printf("Press any key to return to the desktop!\n");
 gemdos(8);                       /* wait for next key entry              */
closework();
}

