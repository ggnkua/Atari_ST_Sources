/*   ABC p46  eg 5.1                */
/*   loops                          */ 
/*     tested & working 24/11/86    */




#include <stdio.h>
int ticks = 200;

main()
     {
     int kount;
     char ch;
     
     
       printf("kount = %d\n",counter());   
     delay(ticks);
     }

counter()
     {    char ch;
          int count = 0;

          while((ch=getchar()) != '\n') count++;
          return(count);
     }

