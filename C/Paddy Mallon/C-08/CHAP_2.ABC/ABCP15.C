/*   ABC  p15   eg. 2.2     functions            */
/*   tested & run 22/11/86                       */

         #include <stdio.h>
         #define gap printf("\n\n\n\n\n");
         #define allstars  printf("*****\n")
         #define endstars  printf("*   *\n")
         #define midstars  printf("  *  \n")

        
     main()

           {
                    int ticks=300;
               

                         bigH(); gap;
                         bigI(); gap;

                      delay(ticks);
           }

     bigH()
          {   
               endstars;endstars;endstars;
               allstars;
               endstars;endstars;endstars;
          }
     bigI()
          {   
               allstars;
               midstars; midstars;midstars;
               midstars; midstars;
               allstars;
          }          

