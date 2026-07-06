/*   ABC  p16  eg 2.3       more functions          */
/*   tested & run 22/11/86                          */

         #include <stdio.h>
         #define gap printf("\n\n\n\n\n");
        
     main()

           {
              int ticks= 300;

                         bigH(); gap;
                         bigI(); gap;

              delay(ticks);
           }

     bigH()
          {  
               endstars();endstars();endstars();
               allstars();
               endstars();endstars();endstars();
          }
     bigI()
          {   
               allstars();
               midstars(); midstars();midstars();
               midstars(); midstars();
               allstars();
          }          

     allstars()
               { printf("*****\n"); }

     endstars()
               { printf("*   *\n");}

     midstars()
               { printf("  *  \n");}


