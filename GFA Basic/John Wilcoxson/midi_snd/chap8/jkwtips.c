/*  8.4.1  C-Programm: Tone Outputs over  Soundchip and MIDI*/ 

#include <geminit.h>   /*    Multivoice Demo: Soundchip and MIDI        */    
                       /*    Voice 1 with  Envelope Generator           */
                       /*    Voices 2+3 Accompaning                     */
                       /*    But without any timing control? Have you   */
                       /*    ever heard a song where all the notes play */
                       /*    at the same rate?  Need more Data. TEMPO!  */
                       /*   JKW extended this a little bit by making it */ 
                       /*    larger to extend the length of the tune.   */
 
int ton[264] = {0,0,0,0,   0,0,0,0,    0,0,0,0,      /* The Array with  */
               2,238,0,69, 4, 28,1,57, 4,203,2,64,   /* the Tone Values */ 
               2, 12,1,71, 4, 62,1, 0, 4,203,2,68,
               2, 28,1,73, 4,101,1,52, 4,203,2,71,
               2, 62,1,74, 4,123,1, 0, 4,187,3,64,
               2,101,1,76, 4,169,1, 0, 4,133,3, 0,
               2, 62,1,78, 4,123,1, 0, 4,187,3, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,73, 4,101,1,52, 4,203,2,71,
               2, 62,1,74, 4,123,1, 0, 4,187,3,64,
               2,101,1,76, 4,169,1, 0, 4,133,3, 0,
               2, 62,1,78, 4,123,1, 0, 4,187,3, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2, 28,1,80, 4,101,1, 0, 4,203,2, 0,
               2,101,1,81, 4,221,1, 0, 4,203,2, 0};  
int s1=0,s2=4,s3=8,i=0;                              /* Pointers to the  */
int t1=0,t2=0,t3=0;                                  /* three voices.    */

main()
{
 openwork();
som_out();                                   /* Call on the Note output  */
 xbios(28,0,8+128);                          /* All amplifiers set to  0 */
 xbios(28,0,9+128);
 xbios(28,0,10+128); 
 xbios(28,255,7+128);                        /* Soundchip turned off     */
closework();
}


som_out()                              /* This is the output function    */
{
xbios(28,0,0+128);xbios(28,0,1+128);   /* Initialize the Soundchip       */
xbios(28,0,2+128);xbios(28,0,3+128);   /* Oscillators all cleared.       */
xbios(28,0,4+128);xbios(28,0,5+128);
xbios(28,248,7+128);                   /* All Amplifier on, Noise - Off  */
xbios(28,16,8+128);                    /* Amplifier OUT Ch#1 to ADSR */
xbios(28,12,9+128);                    /* Amplifier for Ch#2 3/4     */
xbios(28, 8,10+128);                   /* Amplifier for Ch#3 1/2     */
xbios(28,0,11+128);xbios(28,30,12+128); /* Envelope period set H1E00 */

 while(i!=264)                       /* Output loop for the whole list */
 {
  if (t1==ton[s1])                   /* Begin Output of Voice  1       */
  {                                  /* The MIDI output is deactivated */
                                     /* to turn it on just 'Turn-on' the */
                                     /* XBIOS calls.                   */ 
   s1+=12;t1=1;i+=12;                            /* Pointer high count */
  /*  bios(3,3,128);bios(3,3,ton[s1-9]);bios(3,3,0);    MIDI-Output  */
   xbios(28,ton[s1+1],0+128);                     /* Soundchip LowByte */
   xbios(28,ton[s1+2],1+128);                     /* and HighByte      */  
   xbios(28,8,13+128);                    /* Set up the Enveloper      */  
  /*  bios(3,3,144);bios(3,3,ton[s1+3]);bios(3,3,127);      MIDI-Output  */
  } else t1++;                             /* Set up the tone duration */
  if (t2==ton[s2])                    /* Begin Output on voice 2       */ 
  {
   s2+=12;t2=1;
  /*  bios(3,3,128);bios(3,3,ton[s2-9]);bios(3,3,0);  */
   xbios(28,ton[s2+1],2+128);
   xbios(28,ton[s2+2],3+128);
  /*  bios(3,3,144);bios(3,3,ton[s2+3]);bios(3,3,127);  */
  } else t2++;
  if (t3==ton[s3])                    /*  Begin Output on voice  3     */
  {
    s3+=12;t3=1;
 /*  bios(3,3,128);bios(3,3,ton[s3-9]);bios(3,3,0);        */
    xbios(28,ton[s3+1],4+128);
    xbios(28,ton[s3+2],5+128);
 /*    bios(3,3,144);bios(3,3,ton[s3+3]);bios(3,3,127);    */
  } else t3++;
    
  evnt_timer(100,0);                                    /* Wait a While */
 }                        /* End of the While-Loop */
}                               /* End MIDI-Output Function:   som_out()*/
