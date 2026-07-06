/*  ABC p46                    */
/*  operators  ++ and  !       */
/*  works ok  24/11/86         */


#include <stdio.h>
int ticks = 200;

main()
     {
     int count;
     char ch;
     
          count = 0;
          ch = getchar();
          while ( ch!='\n')
               { 
                    count++;
                    ch = getchar();
               }
       printf("count = %d\n",count);   
     delay(ticks);
     }


