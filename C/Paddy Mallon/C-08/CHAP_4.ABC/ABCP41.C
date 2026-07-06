/*  ABC p41   eg 4.2               */
/* grade using if--then--else      */
/* tested and working 23/11/86     */



#include <stdio.h>
int ticks = 200;

main()
     {
     int reply;
     char let;
          printf("gimme a number..(0-100)...");
          scanf("%2d",&reply); printf("%2d\n",reply);
          let = grade(reply);
          printf("grade is ..%c\n",let);
          printf("finished\n");
     delay(ticks);
     }

grade(mark)
     int mark;
     {
          char g ;
          if (mark<0) g = NULL;
          else  if (mark<20)  g = 'e';
          else  if (mark<40)  g = 'd';
          else  if (mark<60)  g = 'c';
          else  if (mark<80)  g = 'b';
          else  if (mark<100) g = 'a';
          else  g = NULL;
          return(g);
     }
