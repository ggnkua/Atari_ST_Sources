/*  ABC p42     eg 4.3             */
/*  switch                         */
/*  tested and works  23/11/86     */


#include <stdio.h>
int ticks = 200;

main()
     {
     int reply;
     char let;
          printf("gimme a number..(0-100)...");
          scanf("%2d",&reply); printf("%2d\n",reply);
          printf("grade is ..%c\n",grade(reply));
          printf("finished\n");
     delay(ticks);
     }

grade(mark)
     int mark;
     {
          char g ;
          switch(mark/20)
               {
                   case 0:  g = 'e'; break;
                   case 1:  g = 'd'; break;
                   case 2:  g = 'c'; break;
                   case 3:  g = 'b'; break;
                   case 4:  g = 'a'; break;
               }
          return(g);
     }
