/* Example program 2.15:     C-Program: 3 voices with enveloper */

#include <geminit.h>   /* Multi voice Demo, two tone with Melody */    
                       /* All voices with enveloper              */
                       /* All voices are always triggered        */
#define sound(a,b) xbios(28,a,b+128) /* replace xbios with sound */
int ton[16] = {28,1,253,0,225,0,212,0,189,0,168,0,150,0,142,0};
int i=0;

main()
{
 openwork();
 printf("\33E");
 sound(248,7);              /* All voices turned on!      */
 sound(16,8);               /* All voices with enveloper  */
 sound(16,9);
 sound(16,10);
 sound(0,11);               /* Program the enveloper      */
 sound(30,12);
 sound(9,13);

 sound(56,0);               /* Tone 1 set up and on       */
 sound(2,1);
 sound(123,2);              /* Tone 2 set up and on       */
 sound(1,3);

 while(i!=16)                      /* Melody loop                */
 {
  sound(ton[i],4);
  sound(ton[i+1],5);
  sound(9,13);
  evnt_timer(200,0);
  i+=2;
 }
  
 evnt_timer(1000,0);               /* The familiar close.        */ 

 sound(0,8);
 sound(0,9);
 sound(0,10); 
 printf("Press any key, to return to the desktop!\n");
 gemdos(8);                     /* wait for next key entry         */
closework();
}

