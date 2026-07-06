/*  ABC p12  -   main() and #define
                    delay() is used to pause the display.  
                            a count of 60 is approx. 1 second.    */

     #include stdio.h
     #define STARS printf("*****************\n")
     main()
          {    int ticks = 200;
               STARS;
               printf("the answer is 42\n");
               STARS;

               delay(ticks);
          }



