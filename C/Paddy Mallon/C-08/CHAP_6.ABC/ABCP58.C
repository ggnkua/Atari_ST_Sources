/*  ABC p58 ex 6.2                    */
/*  pseudo random numbers             */
/*  tested and working 29/11/86       */

#define MAXINT 32767
#define PSHIFT 4
#define QSHIFT 11
#include <stdio.h>
int ticks = 200;
static int n=1;
main()
     {    int k= 200,i;
        for (i=0;i<10;i++)
          {  
            printf("number = %3d\n",random(200));
          }
     delay(ticks);
     }

random(range)
     int range;
         
     {
/*          static int n=1;       */
          
          n=n^n>>PSHIFT;
          n=(n^n<<QSHIFT)&MAXINT;

          return(n%(range+1));
     }
