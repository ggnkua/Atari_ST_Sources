/*  ABC p47   eg 5.2               */  
/*  loops                          */
/*  tested & works 24/11/86        */


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
     {    
          int count = 0;

          while(getchar() != '\n') count++;
          return(count);
     }

