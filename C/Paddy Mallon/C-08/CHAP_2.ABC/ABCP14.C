/*   ABC p14    eg.2.1    functions            */
/*   tested & run 22/11/86            */

         #include <stdio.h>
         #define gap printf("\n\n\n\n\n");
        
     main()

           {
              long ticks;
               ticks = 300;

                         bigH();  gap;
                         bigI();  gap;

              delay(ticks);
           }

     bigH()
          { 
               printf("*   *\n"); 
               printf("*   *\n"); 
               printf("*   *\n"); 
               printf("*****\n"); 
               printf("*   *\n"); 
               printf("*   *\n");
               printf("*   *\n"); 
          }
     bigI()
          {  
               printf("*****\n"); 
               printf("  *  \n"); 
               printf("  *  \n"); 
               printf("  *  \n"); 
               printf("  *  \n"); 
               printf("*****\n"); 
          }          




